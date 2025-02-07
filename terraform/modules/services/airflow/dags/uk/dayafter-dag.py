from datetime import datetime, timedelta
from airflow import DAG
from airflow.providers.amazon.aws.operators.ecs import EcsRunTaskOperator
import os
from utils.slack import slack_message_callback

from airflow.operators.latest_only import LatestOnlyOperator

# note that the start_date needs to be slightly more than how often it gets run
default_args = {
    "owner": "airflow",
    "depends_on_past": False,
    "start_date": datetime.now() - timedelta(hours=25),
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

day_after_error_message = (
    "⚠️ The task {{ ti.task_id }} failed,"
    " but its ok. This task is not critical for live services. "
    "No out of hours support is required."
)

region = "uk"

with DAG(
    f"{region}-national-day-after",
    schedule_interval="0 11 * * *",
    default_args=default_args,
    concurrency=10,
    max_active_tasks=10,
) as dag1:
    dag1.doc_md = "Get National PVLive updated values"

    national_day_after = EcsRunTaskOperator(
        task_id=f"{region}-national-day-after",
        task_definition="pvlive-national-day-after",
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
        on_failure_callback=slack_message_callback(day_after_error_message),
        task_concurrency=10,
        awslogs_group="/aws/ecs/consumer/pvlive-national-day-after",
        awslogs_stream_prefix="streaming/pvlive-national-day-after-consumer",
        awslogs_region="eu-west-1",
    )

with DAG(
    f"{region}-gsp-day-after",
    schedule_interval="30 11 * * *",
    default_args=default_args,
    concurrency=10,
    max_active_tasks=10,
) as dag2:

    dag2.doc_md = "Get GSP PVLive updated values"

    gsp_day_after = EcsRunTaskOperator(
        task_id=f"{region}-gsp-day-after",
        task_definition="pvlive-gsp-day-after",
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
        on_failure_callback=slack_message_callback(day_after_error_message),
        task_concurrency=10,
        awslogs_group="/aws/ecs/consumer/pvlive-gsp-day-after",
        awslogs_stream_prefix="streaming/pvlive-gsp-day-after-consumer",
        awslogs_region="eu-west-1",
    )

    gsp_day_after

with DAG(
    f"{region}-metrics-day-after",
    schedule_interval="0 21 * * *",
    default_args=default_args,
    concurrency=10,
    max_active_tasks=10,
) as dag3:
    dag3.doc_md = "Get Metrics"

    metrics = EcsRunTaskOperator(
        task_id=f"{region}-metrics",
        task_definition="metrics",
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
        on_failure_callback=slack_message_callback(day_after_error_message),
        task_concurrency=10,
        awslogs_group="/aws/ecs/analysis/metrics",
        awslogs_stream_prefix="streaming/metrics-analysis",
        awslogs_region="eu-west-1",
    )

    metrics
