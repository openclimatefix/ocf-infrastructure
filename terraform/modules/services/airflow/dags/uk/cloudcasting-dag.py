import os
from datetime import datetime, timedelta, timezone
from airflow import DAG
from airflow.providers.amazon.aws.operators.ecs import EcsRunTaskOperator

from airflow.operators.latest_only import LatestOnlyOperator
from utils.slack import slack_message_callback

default_args = {
    "owner": "airflow",
    "depends_on_past": False,
    # the start_date needs to be less than the last cron run
    "start_date": datetime.now(tz=timezone.utc) - timedelta(hours=3),
    "retries": 2,
    "retry_delay": timedelta(minutes=1),
    "max_active_runs": 10,
    "concurrency": 10,
    "max_active_tasks": 10,
}

env = os.getenv("ENVIRONMENT", "development")
subnet = os.getenv("ECS_SUBNET")
security_group = os.getenv("ECS_SECURITY_GROUP")
cluster = f"Nowcasting-{env}"

cloudcasting_error_message = (
    "⚠️ The task {{ ti.task_id }} failed,"
    " but its ok. The cloudcasting is currently not critical. "
    "No out of hours support is required."
)

# Tasks can still be defined in terraform, or defined here

region = "uk"

with DAG(
    f"{region}-cloudcasting",
    schedule_interval="20,50 * * * *",
    default_args=default_args,
    concurrency=10,
    max_active_tasks=10,
) as dag:
    dag.doc_md = "Run Cloudcasting app"

    latest_only = LatestOnlyOperator(task_id="latest_only")

    cloudcasting_forecast = EcsRunTaskOperator(
        task_id=f"{region}-cloudcasting",
        task_definition="cloudcasting",
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
        on_failure_callback=slack_message_callback(cloudcasting_error_message),
        awslogs_group="/aws/ecs/forecast/cloudcasting",
        awslogs_stream_prefix="streaming/cloudcasting-forecast",
        awslogs_region="eu-west-1",
    )

    latest_only >> cloudcasting_forecast

