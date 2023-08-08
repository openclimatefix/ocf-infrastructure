import os
from datetime import datetime, timedelta
from airflow import DAG
from airflow.providers.amazon.aws.operators.ecs import EcsRunTaskOperator
from airflow.decorators import dag

from airflow.operators.latest_only import LatestOnlyOperator

default_args = {
    'owner': 'airflow',
    'depends_on_past': False,
    'start_date': datetime.utcnow() - timedelta(hours=0.5),
    'retries': 1,
    'retry_delay': timedelta(minutes=1),
    'max_active_runs':10,
    'concurrency':10,
    'max_active_tasks':10,
}

env = os.getenv("ENVIRONMENT","development")
cluster = f"Nowcasting-{env}"

# Tasks can still be defined in terraform, or defined here


with DAG('nwp-consumer', schedule_interval="*/15 * * * *", default_args=default_args, concurrency=10, max_active_tasks=10) as dag:
    dag.doc_md = "Get NWP data"

    latest_only = LatestOnlyOperator(task_id="latest_only")

    nwp_consumer = EcsRunTaskOperator(
        task_id='nwp-consumer',
        task_definition="nwp",
        cluster=cluster,
        overrides={},
        launch_type = "FARGATE",
        network_configuration={
            "awsvpcConfiguration": {
                "subnets": ["subnet-0c3a5f26667adb0c1"],
                "securityGroups": ["sg-05ef23a462a0932d9"],
                "assignPublicIp": "ENABLED",
            },
        },
     task_concurrency = 10,
    )

    nwp_national_consumer = EcsRunTaskOperator(
        task_id='national-nwp-consumer',
        task_definition="nwp-national",
        cluster=cluster,
        overrides={},
        launch_type="FARGATE",
        network_configuration={
            "awsvpcConfiguration": {
                "subnets": ["subnet-0c3a5f26667adb0c1"],
                "securityGroups": ["sg-05ef23a462a0932d9"],
                "assignPublicIp": "ENABLED",
            },
        },
        task_concurrency=10,
    )

    latest_only >> [nwp_national_consumer, nwp_consumer]

