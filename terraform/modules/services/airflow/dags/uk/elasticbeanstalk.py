from datetime import datetime, timedelta, timezone
from airflow import DAG

from functools import partial

import os
from utils.slack import on_failure_callback
from utils.elastic_beanstalk import scale_elastic_beanstalk_instance

from airflow.operators.python import PythonOperator

from airflow.operators.latest_only import LatestOnlyOperator

default_args = {
    'owner': 'airflow',
    'depends_on_past': False,
    'start_date': datetime.now(tz=timezone.utc) - timedelta(days=60),
    'retries': 1,
    'retry_delay': timedelta(minutes=1),
    'max_active_runs':10,
    'concurrency':10,
    'max_active_tasks':10,
}

region = 'uk'
env = os.getenv("ENVIRONMENT", "development")
names = [f'uk-{env}-airflow',f'uk-{env}-internal-ui', f'uk-{env}-nowcasting-api', f'uk-{env}-sites-api']
names = [f'uk-{env}-internal-ui']

with DAG(f'{region}-reset-elb', schedule_interval="0 0 1 * *", default_args=default_args, concurrency=10, max_active_tasks=10) as dag:
    dag.doc_md = "Reset the elastic beanstalk instance"

    latest_only = LatestOnlyOperator(task_id="latest_only")

    for name in names:

        elb_2 = PythonOperator(
            task_id=f"scale_2_{name}",
            python_callable=scale_elastic_beanstalk_instance,
            op_args = {'name': name, 'number_of_instances': 2, 'sleep_seconds': 60*5},
            task_concurrency=2,
            # on_failure_callback=on_failure_callback,
        )

        elb_1 = PythonOperator(
            task_id=f"scale_1_{name}",
            python_callable=scale_elastic_beanstalk_instance,
            op_args={'name': name, 'number_of_instances': 1},
            task_concurrency=2,
            # on_failure_callback=on_failure_callback,
        )

        latest_only >> elb_2 >> elb_1
