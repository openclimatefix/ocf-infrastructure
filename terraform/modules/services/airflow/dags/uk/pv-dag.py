import os
from datetime import datetime, timedelta, timezone
from airflow import DAG
from airflow.providers.amazon.aws.operators.ecs import EcsRunTaskOperator
from airflow.decorators import dag

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

# Tasks can still be defined in terraform, or defined here

pv_consumer_error_message = (
    "⚠️ The task {{ ti.task_id }} failed. "
    "But its ok, this isnt needed for any production services. "
    "No out of office hours support is required."
)

region = "uk"

with DAG(
    f"{region}-pv-consumer",
    schedule_interval="*/5 * * * *",
    default_args=default_args,
    concurrency=10,
    max_active_tasks=10,
) as dag:
    dag.doc_md = "Get PV data"

    latest_only = LatestOnlyOperator(task_id="latest_only")

    pv_consumer = EcsRunTaskOperator(
        task_id=f"{region}-pv-consumer",
        task_definition="pv",
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
        on_failure_callback=slack_message_callback(pv_consumer_error_message),
        awslogs_group="/aws/ecs/consumer/pv",
        awslogs_stream_prefix="streaming/pv-consumer",
        awslogs_region="eu-west-1",
    )

    latest_only >> pv_consumer
