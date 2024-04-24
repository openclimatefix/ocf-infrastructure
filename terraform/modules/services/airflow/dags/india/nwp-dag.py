import os
from datetime import datetime, timedelta
from airflow import DAG
from airflow.providers.amazon.aws.operators.ecs import EcsRunTaskOperator

from airflow.operators.latest_only import LatestOnlyOperator
from utils.slack import on_failure_callback

default_args = {
    'owner': 'airflow',
    'depends_on_past': False,
    'start_date': datetime.utcnow() - timedelta(hours=1.5),
    'retries': 1,
    'retry_delay': timedelta(minutes=1),
    'max_active_runs':10,
    'concurrency':10,
    'max_active_tasks':10,
}

env = os.getenv("ENVIRONMENT", "development")
subnet = os.getenv("ECS_SUBNET")
security_group = os.getenv("ECS_SECURITY_GROUP")
cluster = f"india-ecs-cluster-{env}"

region = 'india'

with DAG(f'{region}-nwp-consumer', schedule_interval="0 * * * *", default_args=default_args, concurrency=10, max_active_tasks=10) as dag:
    dag.doc_md = "Get NWP data"

    latest_only = LatestOnlyOperator(task_id="latest_only")

    nwp_consumer_ecmwf = EcsRunTaskOperator(
         task_id=f'{region}-nwp-consumer-ecmwf-india',
         task_definition=f'{region}-nwp-consumer-ecmwf-india',
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
    )

    latest_only >> [nwp_consumer_ecmwf]

