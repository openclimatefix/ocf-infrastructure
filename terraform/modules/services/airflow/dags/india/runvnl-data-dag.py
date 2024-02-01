import os
from datetime import datetime, timedelta
from airflow import DAG
from airflow.providers.amazon.aws.operators.ecs import EcsRunTaskOperator
from utils.slack import on_failure_callback

from airflow.operators.latest_only import LatestOnlyOperator

default_args = {
    "owner": "airflow",
    "depends_on_past": False,
    "start_date": datetime.utcnow() - timedelta(hours=2),
    "retries": 1,
    "retry_delay": timedelta(minutes=1),
    "max_active_runs": 10,
    "concurrency": 10,
    "max_active_tasks": 10,
}

env = os.getenv("ENVIRONMENT", "development")
subnet = os.getenv("ECS_SUBNET")
security_group = os.getenv("ECS_SECURITY_GROUP")
cluster = "india-ecs-cluster-development"


with DAG(
    "runvl-data-consumer",
    schedule_interval="0,30 * * * *",
    default_args=default_args,
    concurrency=10,
    max_active_tasks=10,
) as dag:
    dag.doc_md = "Run the forecast"

    latest_only = LatestOnlyOperator(task_id="latest_only")

    runvl_data = EcsRunTaskOperator(
        task_id="runvl-consumer",
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
        on_failure_callback=on_failure_callback,
        task_concurrency=10,
    )

    latest_only >> [runvl_data]
