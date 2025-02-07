""" Dags to rotate ec2 machine in elastic beanstalk """
import os
from datetime import datetime, timedelta, timezone

from airflow import DAG
from airflow.operators.latest_only import LatestOnlyOperator
from airflow.operators.python import PythonOperator
from utils.elastic_beanstalk import scale_elastic_beanstalk_instance
from utils.slack import slack_message_callback

default_args = {
    "owner": "airflow",
    "depends_on_past": False,
    "start_date": datetime.now(tz=timezone.utc) - timedelta(days=60),
    "retries": 1,
    "retry_delay": timedelta(minutes=1),
    "max_active_runs": 10,
    "concurrency": 10,
    "max_active_tasks": 10,
}

elb_error_message = (
    "⚠️ The task {{ ti.task_id }} failed,"
    " but its ok. This task tried to reset the Elastic Beanstalk instances. "
    "No out of hours support is required."
)

region = "uk"
env = os.getenv("ENVIRONMENT", "development")
names = [
    f"uk-{env}-airflow",
    f"uk-{env}-internal-ui",
    f"uk-{env}-nowcasting-api",
    f"uk-{env}-sites-api",
]

with DAG(
    f"{region}-reset-elb",
    schedule_interval="0 0 1 * *",
    default_args=default_args,
    concurrency=10,
    max_active_tasks=10,
) as dag:
    dag.doc_md = "Reset the elastic beanstalk instance"

    latest_only = LatestOnlyOperator(task_id="latest_only")

    for name in names:

        elb_2 = PythonOperator(
            task_id=f"scale_elb_2_{name}",
            python_callable=scale_elastic_beanstalk_instance,
            op_kwargs={"name": name, "number_of_instances": 2, "sleep_seconds": 60 * 5},
            task_concurrency=2,
            on_failure_callback=slack_message_callback(elb_error_message),
        )

        elb_1 = PythonOperator(
            task_id=f"scale_elb_1_{name}",
            python_callable=scale_elastic_beanstalk_instance,
            op_kwargs={"name": name, "number_of_instances": 1},
            task_concurrency=2,
            on_failure_callback=slack_message_callback(elb_error_message),
        )

        latest_only >> elb_2 >> elb_1
