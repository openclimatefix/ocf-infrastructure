import os
from datetime import datetime, timedelta, timezone
from airflow import DAG
from airflow.providers.amazon.aws.operators.ecs import EcsRunTaskOperator
from airflow.operators.bash import BashOperator

from airflow.operators.latest_only import LatestOnlyOperator
from utils.slack import slack_message_callback

default_args = {
    "owner": "airflow",
    "depends_on_past": False,
    "start_date": datetime.now(tz=timezone.utc) - timedelta(hours=0.5),
    "retries": 1,
    "retry_delay": timedelta(minutes=1),
    "max_active_runs": 10,
    "concurrency": 10,
    "max_active_tasks": 10,
}

env = os.getenv("ENVIRONMENT", "development")
subnet = os.getenv("ECS_SUBNET")
security_group = os.getenv("ECS_SECURITY_GROUP")
cluster = f"Nowcasting-{env}"

pvlive_error_message = (
    "⚠️ The task {{ ti.task_id }} failed. "
    "This is needed for the adjuster in the Forecast."
    "No out of office hours support needed."
    "Its good to check <https://www.solar.sheffield.ac.uk/pvlive/|PV Live> to see if its working. "
                        )

# Tasks can still be defined in terraform, or defined here

region = "uk"

if env == "development":
    url = "http://api-dev.quartz.solar"
else:
    url = "http://api.quartz.solar"

with DAG(
    f"{region}-gsp-pvlive-consumer",
    schedule_interval="6,9,12,14,20,36,39,42,44,50 * * * *",
    default_args=default_args,
    concurrency=10,
    max_active_tasks=10,
) as dag:
    dag.doc_md = "Get PV data"

    latest_only = LatestOnlyOperator(task_id="latest_only")

    gsp_consumer = EcsRunTaskOperator(
        task_id=f"{region}-gsp-consumer",
        task_definition="pvlive",
        cluster=cluster,
        overrides={},
        launch_type="FARGATE",
        network_configuration={
            "awsvpcConfiguration": {
                "subnets": [subnet],
                "securityGroups": [security_group],
                "assignPublicIp": "ENABLED",
            },
        },
        task_concurrency=10,
        on_failure_callback=slack_message_callback(pvlive_error_message),
        awslogs_group="/aws/ecs/consumer/pvlive",
        awslogs_stream_prefix="streaming/pvlive-consumer",
        awslogs_region="eu-west-1",
    )

    command = f"curl -X GET {url}/v0/solar/GB/update_last_data?component=gsp"
    gsp_update = BashOperator(
        task_id=f"{region}-gsp-update",
        bash_command=command,
    )

    latest_only >> gsp_consumer >> gsp_update
