# Airflow on AWS Elastic Beanstalk

Running `Airflow` on AWS using MWAA is expensive, roughly ~$400 per month.
This is a cheaper alternative by running it on AWS Elastic Beanstalk. This should cost around ~$15 per month.

This main set up for `Aiflow` is done using a docker-compose.yml. It has the following services:
- airflow webserver: This is the Airflow UI.
# TODO make password variable.
Something we did not quite understand was we need to set `AIRFLOW__WEBSERVER__WORKER_CLASS: "gevent"`
- airflow scheduler: This is the scheduler that runs the DAGs. Because our DAGs kick of ECS tasks, we dont need much compute and memory.
- postgres database: Temporary database for `Airflow`, we could move this to RDS
- sync s3: This syncs with a s3 bucket to get the DAGs. This is useful if we want to try out some new DAGs.
- source setup: This service makes common directories and makes sure all services have access to them.

This module makes
- Defines Airflow Dags
- Elastic Beanstalk application
- IAM role to setup application (service)
- IAM role for running application (ec2)
- s3 bucket to storage application versions and dags
- Security group for application
