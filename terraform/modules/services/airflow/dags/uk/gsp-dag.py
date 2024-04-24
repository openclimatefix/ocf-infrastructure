import os
from datetime import datetime, timedelta
from airflow import DAG
from airflow.providers.amazon.aws.operators.ecs import EcsRunTaskOperator

from airflow.operators.latest_only import LatestOnlyOperator
from utils.slack import on_failure_callback

default_args = {
    'owner': 'airflow',
    'depends_on_past': False,
    'start_date': datetime.utcnow() - timedelta(hours=0.5),
    'retries': 1,
    'retry_delay': timedelta(minutes=1),
    'max_active_runs': 10,
    'concurrency': 10,
    'max_active_tasks': 10,
}

env = os.getenv("ENVIRONMENT", "development")
subnet = os.getenv("ECS_SUBNET")
security_group = os.getenv("ECS_SECURITY_GROUP")
cluster = f"Nowcasting-{env}"

# Tasks can still be defined in terraform, or defined here

region = 'uk'

with DAG(f'{region}-gsp-pvlive-consumer', schedule_interval="6,9,12,14,20,36,39,42,44,50 * * * *", default_args=default_args, concurrency=10, max_active_tasks=10) as dag:
    dag.doc_md = "Get PV data"

    latest_only = LatestOnlyOperator(task_id="latest_only")

    gsp_consumer = EcsRunTaskOperator(
        task_id=f'{region}-gsp-consumer',
        task_definition='gsp',
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

    latest_only >> gsp_consumer



