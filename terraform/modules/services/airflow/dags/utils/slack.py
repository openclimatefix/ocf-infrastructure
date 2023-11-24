from airflow.providers.slack.notifications.slack import send_slack_notification
import os

# get the env
env = os.getenv("ENVIRONMENT", "development")

# decare on_failure_callback
on_failure_callback = [
        send_slack_notification(
            text="The task {{ ti.task_id }} failed",
            channel=f"tech-ops-airflow-{env}",
            username="Airflow",
        )
    ]
