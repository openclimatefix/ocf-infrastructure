import os
from datetime import datetime, timedelta, timezone
from airflow import DAG
from airflow.providers.amazon.aws.operators.ecs import EcsRunTaskOperator
from utils.slack import on_failure_callback

from airflow.operators.latest_only import LatestOnlyOperator

default_args = {
    'owner': 'airflow',
    'depends_on_past': False,
    'start_date': datetime.now(tz=timezone.utc) - timedelta(hours=25),
    'retries': 1,
    'retry_delay': timedelta(minutes=1),
    'max_active_runs':10,
    'concurrency':10,
    'max_active_tasks':10,
}

env = os.getenv("ENVIRONMENT", "development")
subnet = os.getenv("ECS_SUBNET")
security_group = os.getenv("ECS_SECURITY_GROUP")
cluster = f"Nowcasting-{env}"

# Tasks can still be defined in terraform, or defined here

region = 'uk'

with DAG(f'{region}-site-forecast', schedule_interval="*/15 * * * *", default_args=default_args, concurrency=10, max_active_tasks=10) as dag:
    dag.doc_md = "Run the site forecast"

    latest_only = LatestOnlyOperator(task_id="latest_only")

    forecast = EcsRunTaskOperator(
        task_id=f'{region}-site-forecast',
        task_definition='pvsite_forecast',
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
        on_failure_callback=on_failure_callback,
     task_concurrency = 10,
    )

with DAG(f'{region}-site-forecast-db-clean', schedule_interval="0 0 * * *", default_args=default_args, concurrency=10, max_active_tasks=10) as dag:
    dag.doc_md = "Clean up the forecast db"

    latest_only = LatestOnlyOperator(task_id="latest_only")

    database_clean_up = EcsRunTaskOperator(
        task_id=f'{region}-site-forecast-db-clean',
        task_definition='database_clean_up',
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
        on_failure_callback=on_failure_callback
    )


    latest_only >> database_clean_up

