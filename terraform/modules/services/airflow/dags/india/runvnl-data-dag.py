import os
from datetime import datetime, timedelta, timezone
from airflow import DAG
from airflow.providers.amazon.aws.operators.ecs import EcsRunTaskOperator
from utils.slack import slack_message_callback_no_action_required

from airflow.operators.latest_only import LatestOnlyOperator

default_args = {
    "owner": "airflow",
    "depends_on_past": False,
    "start_date": datetime.now(tz=timezone.utc) - timedelta(hours=2),
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

with DAG(
    f"{region}-runvl-data-consumer",
    schedule_interval="*/3 * * * *",
    default_args=default_args,
    concurrency=10,
    max_active_tasks=10,
) as dag:
    dag.doc_md = "Run the forecast"

    latest_only = LatestOnlyOperator(task_id="latest_only")

    runvl_data = EcsRunTaskOperator(
        task_id=f"{region}-runvl-consumer",
        task_definition="runvl-consumer",
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
        on_failure_callback=slack_message_callback_no_action_required,
        task_concurrency=10,
        awslogs_group="/aws/ecs/consumer/runvl-consumer",
        awslogs_stream_prefix="streaming/runvl-consumer-consumer",
        awslogs_region="ap-south-1",
    )

    latest_only >> [runvl_data]
