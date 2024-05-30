import os
from datetime import datetime, timedelta, timezone
from airflow import DAG
from airflow.providers.amazon.aws.operators.ecs import EcsRunTaskOperator
from airflow.decorators import dag
from airflow.operators.bash import BashOperator

from airflow.operators.latest_only import LatestOnlyOperator
from utils.slack import on_failure_callback

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

region = 'uk'

if env == 'development':
    url = "http://api-dev.quartz.solar"
else:
    url = "http://api.quartz.solar"

with DAG(
    f'{region}-national-satellite-consumer',
    schedule_interval="*/5 * * * *",
    default_args=default_args,
    concurrency=10,
    max_active_tasks=10,
    start_date=datetime.now(tz=timezone.utc) - timedelta(hours=0.5),
) as dag:
    dag.doc_md = "Get Satellite data"

    latest_only = LatestOnlyOperator(task_id="latest_only")

    sat_consumer = EcsRunTaskOperator(
        task_id=f'{region}-national-satellite-consumer',
        task_definition='sat',
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

    file = f's3://nowcasting-sat-{env}/data/latest/latest.zarr.zip'
    command = f'curl -X GET "{url}/v0/solar/GB/update_last_data?component=satellite&file={file}"'
    satellite_update = BashOperator(
        task_id=f"{region}-satellite-update",
        bash_command=command,
    )

    latest_only >> sat_consumer >> satellite_update

with DAG(
    f'{region}-national-satellite-cleanup',
    schedule_interval="0 0,6,12,18 * * *",
    default_args=default_args,
    concurrency=10,
    max_active_tasks=10,
    start_date=datetime.now(tz=timezone.utc) - timedelta(hours=7),
) as dag:
    dag.doc_md = "Satellite data clean up"

    latest_only = LatestOnlyOperator(task_id="latest_only")

    sat_consumer = EcsRunTaskOperator(
        task_id=f'{region}-national-satellite-cleanup',
        task_definition='sat-clean-up',
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
