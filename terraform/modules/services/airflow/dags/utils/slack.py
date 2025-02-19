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


def task_success_if_previous_failed(context):
    """ Send a slack message if the previous dag run failed """
    last_dag_run = context["dag_run"].get_previous_dagrun()
    last_dag_run_state = last_dag_run.get_state()
    task_id = context["task_instance"].task_id
    slack_message = (
        f"✅ Task {task_id} was successful. "
        f"Previous run {last_dag_run_state} at {last_dag_run.execution_date}"
    )
    if last_dag_run_state == "failed":
        send_slack_notification(
            text=slack_message,
            channel=f"tech-ops-airflow-{env}",
            username="Airflow",
        )(context)


def slack_message_callback(message):
    return [
        send_slack_notification(
            text=message,
            channel=f"tech-ops-airflow-{env}",
            username="Airflow",
        )
    ]
