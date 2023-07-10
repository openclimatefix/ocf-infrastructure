from datetime import datetime, timedelta
from airflow import DAG
from airflow.providers.amazon.aws.operators.ecs import EcsRunTaskOperator
from airflow.decorators import dag

from airflow.operators.latest_only import LatestOnlyOperator

default_args = {
    "owner": "airflow",
    "depends_on_past": False,
    "start_date": datetime.now(),
    "retries": 1,
    "retry_delay": timedelta(minutes=1),
    "max_active_runs": 10,
    "concurrency": 10,
    "max_active_tasks": 10,
}

cluster = "Nowcasting-development"

# Tasks can still be defined in terraform, or defined here

with DAG(
    "national_day_after",
    schedule_interval="0 11 * * *",
    default_args=default_args,
    concurrency=10,
    max_active_tasks=10,
) as dag1:
    latest_only = LatestOnlyOperator(task_id="latest_only")

    national_day_after = EcsRunTaskOperator(
        task_id="national-day-after",
        task_definition="national-day-after",
        cluster=cluster,
        overrides={},
        awslogs_region="eu-west-1",
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

    latest_only >> national_day_after

with DAG(
    "gsp_day_after",
    schedule_interval="30 11 * * *",
    default_args=default_args,
    concurrency=10,
    max_active_tasks=10,
) as dag2:
    latest_only = LatestOnlyOperator(task_id="latest_only")

    gsp_day_after = EcsRunTaskOperator(
        task_id="gsp-day-after",
        task_definition="gsp-day-after",
        cluster=cluster,
        overrides={},
        launch_type="FARGATE",
        awslogs_group="eu-west-1",
        network_configuration={
            "awsvpcConfiguration": {
                "subnets": ["subnet-0c3a5f26667adb0c1"],
                "securityGroups": ["sg-05ef23a462a0932d9"],
                "assignPublicIp": "ENABLED",
            },
        },
        task_concurrency=10,
    )

    metrics = EcsRunTaskOperator(
        task_id="metrics",
        task_definition="metrics",
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

    latest_only >> gsp_day_after
    gsp_day_after >> metrics
