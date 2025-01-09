import os
from datetime import datetime, timedelta, timezone
from airflow import DAG
from airflow.providers.amazon.aws.operators.ecs import EcsRunTaskOperator

from airflow.operators.latest_only import LatestOnlyOperator
from utils.slack import on_failure_callback
from utils.s3 import determine_latest_zarr

default_args = {
    'owner': 'airflow',
    'depends_on_past': False,
    'start_date': datetime.now(tz=timezone.utc) - timedelta(hours=1.5),
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

with DAG(
    f'{region}-nwp-consumer',
    schedule_interval="0 * * * *",
    default_args=default_args,
    concurrency=10,
    max_active_tasks=10,
) as dag:
    dag.doc_md = "Get NWP data"

    latest_only = LatestOnlyOperator(task_id="latest_only")

    nwp_consumer_ecmwf = EcsRunTaskOperator(
         task_id=f'{region}-nwp-consumer-ecmwf-india',
         task_definition='nwp-consumer-ecmwf-india',
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

    nwp_consumer_gfs = EcsRunTaskOperator(
         task_id=f'{region}-nwp-consumer-gfs-india',
         task_definition='nwp-consumer-gfs-india',
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

    nwp_consumer_metoffice = EcsRunTaskOperator(
        task_id=f'{region}-nwp-consumer-metoffice-india',
        task_definition='nwp-consumer-metoffice-india',
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
    rename_zarr_metoffice = determine_latest_zarr.override(
            task_id="determine_latest_zarr_metoffice",
    )(bucket=f"india-nwp-{env}", prefix="metoffice/data")

    rename_zarr_ecmwf = determine_latest_zarr.override(
        task_id="determine_latest_zarr_ecmwf",
    )(bucket=f'india-nwp-{env}', prefix='ecmwf/data')

    latest_only >> rename_zarr_ecmwf >> nwp_consumer_ecmwf
    latest_only >> nwp_consumer_gfs
    latest_only >> nwp_consumer_metoffice >> rename_zarr_metoffice

