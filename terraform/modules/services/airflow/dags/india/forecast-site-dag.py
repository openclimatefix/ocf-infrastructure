import os
from datetime import datetime, timedelta, timezone
from airflow import DAG
from airflow.providers.amazon.aws.operators.ecs import EcsRunTaskOperator
from utils.slack import slack_message_callback

from airflow.operators.latest_only import LatestOnlyOperator

default_args = {
    "owner": "airflow",
    "depends_on_past": False,
    "start_date": datetime.now(tz=timezone.utc) - timedelta(hours=3),
    "retries": 1,
    "retry_delay": timedelta(minutes=1),
    "max_active_runs": 10,
    "concurrency": 10,
    "max_active_tasks": 10,
}

env = os.getenv("ENVIRONMENT", "development")
subnet = os.getenv("ECS_SUBNET")
security_group = os.getenv("ECS_SECURITY_GROUP")
cluster = f"india-ecs-cluster-{env}"

region = "india"

forecast_ruvnl_error_message = (
    "❌ The task {{ ti.task_id }} failed. "
    "This would ideally be fixed before for DA actions at 09.00 IST"
    "Please see run book for appropriate actions."
)

forecast_ad_error_message = (
    "❌ The task {{ ti.task_id }} failed.  "
    "Please see run book for appropriate actions. "
)

# hour the forecast can run, not include 7,8,19,20
hours = "0,1,2,3,4,5,6,9,10,11,12,13,14,15,16,17,18,21,22,23"

with DAG(
    f"{region}-runvl-forecast",
    schedule_interval=f"0 {hours} * * *",
    default_args=default_args,
    concurrency=10,
    max_active_tasks=10,
) as dag:
    dag.doc_md = "Run the forecast"

    latest_only = LatestOnlyOperator(task_id="latest_only")

    forecast = EcsRunTaskOperator(
        task_id=f"{region}-forecast-ruvnl",
        task_definition="forecast",
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
        on_failure_callback=slack_message_callback(forecast_ruvnl_error_message),
        task_concurrency=10,
        awslogs_group="/aws/ecs/forecast/forecast",
        awslogs_stream_prefix="streaming/forecast-forecast",
        awslogs_region="ap-south-1",
    )

    latest_only >> [forecast]

with DAG(
    f"{region}-ad-forecast",
    schedule_interval=f"0,15,30,45 * * * *",
    default_args=default_args,
    concurrency=10,
    max_active_tasks=10,
) as dag:
    dag.doc_md = "Run the forecast for client AD"

    latest_only = LatestOnlyOperator(task_id="latest_only")

    forecast = EcsRunTaskOperator(
        task_id=f"{region}-forecast-ad",
        task_definition="forecast-ad",
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
        on_failure_callback=slack_message_callback(forecast_ad_error_message),
        task_concurrency=10,
        awslogs_group="/aws/ecs/forecast/forecast-ad",
        awslogs_stream_prefix="streaming/forecast-ad-forecast",
        awslogs_region="ap-south-1",
    )

    latest_only >> [forecast]
