import os
from datetime import datetime, timedelta
from airflow import DAG
from airflow.providers.amazon.aws.operators.ecs import EcsRunTaskOperator
from airflow.decorators import dag

from airflow.operators.latest_only import LatestOnlyOperator
from .utils import on_failure_callback

default_args = {
    "owner": "airflow",
    "depends_on_past": False,
    "retries": 1,
    "retry_delay": timedelta(minutes=1),
    "max_active_runs": 10,
    "concurrency": 10,
    "max_active_tasks": 10,
    "execution_timeout":timedelta(minutes=30),
}

env = os.getenv("ENVIRONMENT","development")
subnet = os.getenv("ECS_SUBNET")
security_group = os.getenv("ECS_SECURITY_GROUP")
cluster = f"Nowcasting-{env}"

# Tasks can still be defined in terraform, or defined here


with DAG(
    "national-satellite-consumer",
    schedule_interval="*/5 * * * *",
    default_args=default_args,
    concurrency=10,
    max_active_tasks=10,
    start_date=datetime.utcnow() - timedelta(hours=0.5),
) as dag:
    dag.doc_md = "Get Satellite data"

    latest_only = LatestOnlyOperator(task_id="latest_only")

    sat_consumer = EcsRunTaskOperator(
        task_id="national-satellite-consumer",
        task_definition="sat",
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


with DAG(
    "national-satellite-cleanup",
    schedule_interval="0 0,6,12,18 * * *",
    default_args=default_args,
    concurrency=10,
    max_active_tasks=10,
    start_date=datetime.utcnow() - timedelta(hours=7),
) as dag:
    dag.doc_md = "Satellite data clean up"

    latest_only = LatestOnlyOperator(task_id="latest_only")

    sat_consumer = EcsRunTaskOperator(
        task_id="national-satellite-cleanup",
        task_definition="sat-clean-up",
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
