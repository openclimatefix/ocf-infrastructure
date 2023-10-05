import os
from datetime import datetime, timedelta
from airflow import DAG
from airflow.providers.amazon.aws.operators.ecs import EcsRunTaskOperator
from airflow.decorators import dag

from airflow.operators.latest_only import LatestOnlyOperator
from airflow.operators.python import PythonOperator
from nowcasting_datamodel.read.read import update_latest_input_data_last_updated
from nowcasting_datamodel.connection import DatabaseConnection

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
subnet = os.getenv("ECS_SUBNET")
security_group = os.getenv("ECS_SECURITY_GROUP")
cluster = f"Nowcasting-{env}"

# Tasks can still be defined in terraform, or defined here

def task_update_latest_input_data():
    # connect to db
    connection = DatabaseConnection(url=os.getenv("DB_URL"))
    with connection.get_session() as session:
        # update the latest input data last updated
        update_latest_input_data_last_updated(session=session, component='nwp')




with DAG('nwp-consumer', schedule_interval="10,25,40,55 * * * *", default_args=default_args, concurrency=10, max_active_tasks=10) as dag:
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
                "subnets": [subnet],
                "securityGroups": [security_group],
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
                "subnets": [subnet],
                "securityGroups": [security_group],
                "assignPublicIp": "ENABLED",
            },
        },
        task_concurrency=10,
    )

    update_database = PythonOperator(
        task_id='task_update_latest_input_data',
        python_callable=task_update_latest_input_data,
        dag=dag,
    )

    latest_only >> [nwp_national_consumer, nwp_consumer]
    nwp_national_consumer >> update_database
    nwp_consumer >> update_database

