import os
from datetime import datetime, timedelta, timezone
from airflow import DAG
from airflow.providers.amazon.aws.operators.ecs import EcsRunTaskOperator
from airflow.operators.bash import BashOperator

from airflow.operators.latest_only import LatestOnlyOperator
from utils.slack import on_failure_callback

default_args = {
    'owner': 'airflow',
    'depends_on_past': False,
    'start_date': datetime.now(tz=timezone.utc) - timedelta(hours=0.5),
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

if env == 'development':
    url = "http://api-dev.quartz.solar"
else:
    url = "http://api.quartz.solar"

with DAG(f'{region}-nwp-consumer', schedule_interval="10,25,40,55 * * * *", default_args=default_args, concurrency=10, max_active_tasks=10) as dag:
    dag.doc_md = "Get NWP data"

    latest_only = LatestOnlyOperator(task_id="latest_only")

    nwp_national_consumer = EcsRunTaskOperator(
        task_id=f'{region}-metoffice-nwp-consumer',
        task_definition='nwp-metoffice',
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

    nwp_ecmwf_consumer = EcsRunTaskOperator(
        task_id=f'{region}-nwp-consumer-ecmwf-uk',
        task_definition='nwp-consumer-ecmwf-uk',
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

    file = f's3://nowcasting-nwp-{env}/data-metoffice/latest.zarr.zip'
    command = f'curl -X GET "{url}/v0/solar/GB/update_last_data?component=nwp&file={file}"'
    nwp_update_ukv = BashOperator(
        task_id="nwp-update-ukv",
        bash_command=command,
    )

    file = f's3://nowcasting-nwp-{env}/ecmwf/data/latest.zarr.zip'
    command = f'curl -X GET "{url}/v0/solar/GB/update_last_data?component=nwp&file={file}"'
    nwp_update_ecmwf = BashOperator(
        task_id="nwp-update-ecmwf",
        bash_command=command,
    )

    latest_only >> nwp_national_consumer >> nwp_update_ukv
    latest_only >> nwp_ecmwf_consumer >> nwp_update_ecmwf

