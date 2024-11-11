import os
from datetime import datetime, timedelta, timezone
from airflow import DAG
from airflow.providers.amazon.aws.operators.ecs import EcsRunTaskOperator

from airflow.operators.latest_only import LatestOnlyOperator
from utils.slack import on_failure_callback

default_args = {
    "owner": "airflow",
    "depends_on_past": False,
    "retries": 2,
    "retry_delay": timedelta(minutes=1),
    "max_active_runs": 10,
    "concurrency": 10,
    "max_active_tasks": 10,
    "execution_timeout":timedelta(minutes=30),
}

env = os.getenv("ENVIRONMENT", "development")
subnet = os.getenv("ECS_SUBNET")
security_group = os.getenv("ECS_SECURITY_GROUP")
cluster = f"india-ecs-cluster-{env}"

# Tasks can still be defined in terraform, or defined here

region = 'india'

with DAG(
    f'{region}-satellite-consumer',
    schedule_interval="*/5 * * * *",
    default_args=default_args,
    concurrency=10,
    max_active_tasks=10,
    start_date=datetime.now(tz=timezone.utc) - timedelta(hours=0.5),
) as dag:
    dag.doc_md = "Get Satellite data"

    latest_only = LatestOnlyOperator(task_id="latest_only")

    sat_consumer = EcsRunTaskOperator(
        task_id=f'{region}-satellite-consumer',
        task_definition='sat-consumer',
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
        on_failure_callback=on_failure_callback
    )

    latest_only >> sat_consumer
