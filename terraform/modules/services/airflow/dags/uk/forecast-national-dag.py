import os
from datetime import datetime, timedelta, timezone
from airflow import DAG
from airflow.providers.amazon.aws.operators.ecs import EcsRunTaskOperator

from airflow.operators.latest_only import LatestOnlyOperator
from utils.slack import on_failure_callback

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

# Tasks can still be defined in terraform, or defined here

region = "uk"

with DAG(
    f"{region}-national-forecast",
    schedule_interval="15 */2 * * *",
    default_args=default_args,
    concurrency=10,
    max_active_tasks=10,
) as dag:
    dag.doc_md = "Get PV data"

    latest_only = LatestOnlyOperator(task_id="latest_only")

    national_forecast = EcsRunTaskOperator(
        task_id=f"{region}-national-forecast",
        task_definition="forecast_national",
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
        on_failure_callback=on_failure_callback,
        awslogs_group="/aws/ecs/forecast/forecast_national",
        awslogs_stream_prefix="streaming/forecast_national-forecast",
        awslogs_region="eu-west-1",
    )

    forecast_blend = EcsRunTaskOperator(
        task_id=f"{region}-forecast-blend-national-xg",
        task_definition="forecast_blend",
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
        on_failure_callback=on_failure_callback,
        awslogs_group="/aws/ecs/blend/forecast_blend",
        awslogs_stream_prefix="streaming/forecast_blend-blend",
        awslogs_region="eu-west-1",
    )

    latest_only >> national_forecast >> forecast_blend
