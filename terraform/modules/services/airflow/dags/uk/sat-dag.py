"""Dag to download and process satellite data from EUMETSAT.

Consists of two tasks made from the same ECS operator,
one for RSS data and one for Odegree data.
The 0degree data task only runs if the RSS data task fails.
"""

import os
import datetime as dt
from airflow.providers.amazon.aws.operators.ecs import EcsRunTaskOperator, EcsRegisterTaskDefinitionOperator
from airflow.decorators import dag
from airflow.utils.trigger_rule import TriggerRule

from airflow.operators.latest_only import LatestOnlyOperator
from utils.slack import slack_message_callback

env = os.getenv("ENVIRONMENT", "development")

default_dag_args = {
    "owner": "airflow",
    "depends_on_past": False,
    "retries": 1,
    "retry_delay": dt.timedelta(minutes=1),
    "max_active_runs": 10,
    "concurrency": 10,
    "max_active_tasks": 10,
    "execution_timeout": dt.timedelta(minutes=30),
}
default_task_args = {
    "cluster": f"Nowcasting-{env}",
    "task_definition": "satellite-consumer",
    "launch_type": "FARGATE",
    "task_concurrency": 1,
    "network_configuration": {
        "awsvpcConfiguration": {
            "subnets": [os.getenv("ECS_SUBNET")],
            "securityGroups": [os.getenv("ECS_SECURITY_GROUP")],
            "assignPublicIp": "ENABLED",
        },
    },
    "awslogs_group": "/aws/ecs/consumer/sat",
    "awslogs_stream_prefix": "streaming/sat-consumer",
    "awslogs_region": "eu-west-1",
}

satellite_error_message = (
)

@dag(
    dag_id="uk-satellite-consumer",
    description=__doc__,
    schedule_interval="*/5 * * * *",
    start_date=dt.datetime.now(tz=dt.timezone.utc) - dt.timedelta(hours=0.5),
    catchup=False,
    default_args=default_dag_args,
)
def sat_consumer_dag():

    latest_only = LatestOnlyOperator(task_id="latest_only")
    
    sat_consumer_rss = EcsRunTaskOperator(
        task_id="satellite-consumer-rss",
        overrides={"containerOverrides": [{
            "name": "satellite-consumer",
            "environment": {
                "SATCONS_SATELLITE": "rss",
                "SATCONS_WORKDIR": "s3://nowcasting-sat-{env}/testdata",
            },
        }]},
        **default_task_args,
    )

    sat_consumer_odegree = EcsRunTaskOperator(
        task_id="satellite-consumer-odegree",
        trigger_rule=TriggerRule.ALL_FAILED,
        overrides={"containerOverrides": [{
            "name": "satellite-consumer",
            "environment": {
                "SATCONS_SATELLITE": "odegree",
                "SATCONS_WORKDIR": "s3://nowcasting-sat-{env}/testdata",
            },
        }]},
        on_failure_callback=slack_message_callback((
            "⚠️ The task {{ ti.task_id }} failed to collect odegree satellite data. "
            "The forecast will automatically move over to PVNET-ECMWF "
            "which doesn't need satellite data. "
            "Forecast quality may be impacted, but no out-of-hours support is required. "
            "Please log in an incident log. "
        )),
        **default_task_args,
    )

    latest_only >> sat_consumer_rss >> sat_consumer_odegree

sat_consumer_dag()

