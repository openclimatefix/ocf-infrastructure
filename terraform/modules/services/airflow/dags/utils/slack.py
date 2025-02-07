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

slack_message_callback_no_action_required = [
        send_slack_notification(
            text="⚠️ The task {{ ti.task_id }} failed,"
    " but its ok. No out of hours support is required.",
            channel=f"tech-ops-airflow-{env}",
            username="Airflow",
        )
    ]

def slack_message_callback(message):
    return [
        send_slack_notification(
            text=message,
            channel=f"tech-ops-airflow-{env}",
            username="Airflow",
        )
    ]

