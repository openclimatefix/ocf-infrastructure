import os
from datetime import datetime, timedelta, timezone
from airflow import DAG
from airflow.providers.amazon.aws.operators.ecs import EcsRunTaskOperator
from airflow.decorators import dag
from airflow.operators.bash import BashOperator

from airflow.operators.latest_only import LatestOnlyOperator
from utils.slack import on_failure_callback, slack_message_callback

default_args = {
    "owner": "airflow",
    "depends_on_past": False,
    "retries": 1,
    "retry_delay": timedelta(minutes=1),
    "max_active_runs": 10,
    "concurrency": 10,
    "max_active_tasks": 10,
    "execution_timeout": timedelta(minutes=30),
}

env = os.getenv("ENVIRONMENT", "development")
subnet = os.getenv("ECS_SUBNET")
security_group = os.getenv("ECS_SECURITY_GROUP")
cluster = f"Nowcasting-{env}"

satellite_error_message = (
    "⚠️ The task {{ ti.task_id }} failed. "
    "But it's OK, the forecast will automatically move over to PVNET-ECMWF, "
    "which doesn't need satellite data. "
    "EUMETSAT status links are <https://uns.eumetsat.int/uns/|here> "
    "and <https://masif.eumetsat.int/ossi/webpages/level3.html?ossi_level3_filename=seviri_rss_hr.html&ossi_level2_filename=seviri_rss.html|here>. "
    "No out-of-hours support is required, but please log in an incident log."
)

satellite_both_files_missing_error_message = (
    "⚠️ Tried to update the database to show when the latest satellite data was collected, " 
    "but could not find the 5-min or the 15-min satellite files."
)

satellite_clean_up_error_message = (
    "⚠️ The task {{ ti.task_id }} failed. "
    "But it's OK, this is only used for cleaning up the EUMETSAT customisation, "
    "and the satellite consumer should also do this. "
    "No out-of-hours support is required."
)

region = "uk"

if env == "development":
    url = "http://api-dev.quartz.solar"
else:
    url = "http://api.quartz.solar"

with DAG(
    f"{region}-national-satellite-consumer",
    schedule_interval="*/5 * * * *",
    default_args=default_args,
    concurrency=10,
    max_active_tasks=10,
    start_date=datetime.now(tz=timezone.utc) - timedelta(hours=0.5),
    catchup=False,
) as dag:
    dag.doc_md = "Get Satellite data"

    latest_only = LatestOnlyOperator(task_id="latest_only")

    sat_consumer = EcsRunTaskOperator(
        task_id=f"{region}-national-satellite-consumer",
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
        on_failure_callback=slack_message_callback(satellite_error_message),
        awslogs_group="/aws/ecs/consumer/sat",
        awslogs_stream_prefix="streaming/sat-consumer",
        awslogs_region="eu-west-1",
    )

    file_5min = f"s3://nowcasting-sat-{env}/data/latest/latest.zarr.zip"
    command_5min = (
        f'curl -X GET '
        f'"{url}/v0/solar/GB/update_last_data?component=satellite&file={file_5min}"'
    )

    satellite_update_5min = BashOperator(
        task_id=f"{region}-satellite-update-5min",
        bash_command=command_5min,
    )

    file_15min = f"s3://nowcasting-sat-{env}/data/latest/latest_15.zarr.zip"
    command_15min = (
        f'curl -X GET '
        f'"{url}/v0/solar/GB/update_last_data?component=satellite&file={file_15min}"'
    )

    satellite_update_15min = BashOperator(
        task_id=f"{region}-satellite-update-15min",
        bash_command=command_15min,
        trigger_rule="all_failed",
        on_failure_callback=slack_message_callback(satellite_both_files_missing_error_message),
    )

    latest_only >> sat_consumer >> satellite_update_5min >> satellite_update_15min

with DAG(
    f"{region}-national-satellite-cleanup",
    schedule_interval="0 0,6,12,18 * * *",
    default_args=default_args,
    concurrency=10,
    max_active_tasks=10,
    start_date=datetime.now(tz=timezone.utc) - timedelta(hours=7),
    catchup=False,
) as dag_cleanup:
    dag_cleanup.doc_md = "Satellite data clean up"

    latest_only_cleanup = LatestOnlyOperator(task_id="latest_only")

    sat_consumer_cleanup = EcsRunTaskOperator(
        task_id=f"{region}-national-satellite-cleanup",
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
        on_failure_callback=slack_message_callback(satellite_clean_up_error_message),
        awslogs_group="/aws/ecs/consumer/sat-clean-up",
        awslogs_stream_prefix="streaming/sat-clean-up-consumer",
        awslogs_region="eu-west-1",
    )

    latest_only_cleanup >> sat_consumer_cleanup


