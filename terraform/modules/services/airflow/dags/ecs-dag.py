# TODO needs tidying up
# from datetime import datetime, timedelta
# from airflow import DAG
# from airflow.providers.amazon.aws.operators.ecs import EcsRunTaskOperator
# from airflow.decorators import dag
#
# from airflow.operators.latest_only import LatestOnlyOperator
#
# default_args = {
#     'owner': 'airflow',
#     'depends_on_past': False,
#     'start_date': datetime.now(),
#     'retries': 1,
#     'retry_delay': timedelta(minutes=1),
#     'max_active_runs':10,
#     'concurrency':10,
#     'max_active_tasks':10,
# }
#
# cluster = 'Nowcasting-development'
#
# # Tasks can still be defined in terraform, or defined here
#
# # Process 4: General Data
#
# with DAG('general_data', schedule_interval="*/5 * * * *", default_args=default_args, concurrency=10, max_active_tasks=10) as dag4:
#     latest_only = LatestOnlyOperator(task_id="latest_only")
#
#     dag4.doc_md = "T"
#
#     pv_consumer = EcsRunTaskOperator(
#         task_id='pv-consumer',
#         task_definition="pv",
#         cluster=cluster,
#         overrides={},
#         launch_type = "FARGATE",
#         network_configuration={
#             "awsvpcConfiguration": {
#                 "subnets": ["subnet-0c3a5f26667adb0c1"],
#                 "securityGroups": ["sg-05ef23a462a0932d9"],
#                 "assignPublicIp": "ENABLED",
#             },
#         },
#      task_concurrency = 10,
#     )
#
#     gsp_consumer = EcsRunTaskOperator(
#         task_id='gsp-consumer',
#         task_definition="gsp",
#         cluster=cluster,
#         overrides={},
#         launch_type = "FARGATE",
#         network_configuration={
#             "awsvpcConfiguration": {
#                 "subnets": ["subnet-0c3a5f26667adb0c1"],
#                 "securityGroups": ["sg-05ef23a462a0932d9"],
#                 "assignPublicIp": "ENABLED",
#             },
#         },
#         task_concurrency=10
#     )
#
#     nwp_consumer = EcsRunTaskOperator(
#         task_id='nwp-consumer',
#         task_definition="nwp",
#         cluster=cluster,
#         overrides={},
#         launch_type="FARGATE",
#         network_configuration={
#             "awsvpcConfiguration": {
#                 "subnets": ["subnet-0c3a5f26667adb0c1"],
#                 "securityGroups": ["sg-05ef23a462a0932d9"],
#                 "assignPublicIp": "ENABLED",
#             },
#         },
#         task_concurrency=10
#     )
#
#     national_forecaster = EcsRunTaskOperator(
#         task_id='forecast-national',
#         task_definition="forecast_national",
#         cluster=cluster,
#         overrides={},
#         launch_type = "FARGATE",
#         network_configuration={
#             "awsvpcConfiguration": {
#                 "subnets": ["subnet-0c3a5f26667adb0c1"],
#                 "securityGroups": ["sg-05ef23a462a0932d9"],
#                 "assignPublicIp": "ENABLED",
#             },
#         },
#         task_concurrency=10
#     )
#
#     forecaster_pvnet1 = EcsRunTaskOperator(
#         task_id='forecast-pvnet1',
#         task_definition="forecast",
#         cluster=cluster,
#         overrides={},
#         launch_type="FARGATE",
#         network_configuration={
#             "awsvpcConfiguration": {
#                 "subnets": ["subnet-0c3a5f26667adb0c1"],
#                 "securityGroups": ["sg-05ef23a462a0932d9"],
#                 "assignPublicIp": "ENABLED",
#             },
#         },
#         task_concurrency=10
#     )
#
#     forecaster_pvnet2 = EcsRunTaskOperator(
#         task_id='forecast-pvnet2',
#         task_definition="forecast_pvnet",
#         cluster=cluster,
#         overrides={},
#         launch_type="FARGATE",
#         network_configuration={
#             "awsvpcConfiguration": {
#                 "subnets": ["subnet-0c3a5f26667adb0c1"],
#                 "securityGroups": ["sg-05ef23a462a0932d9"],
#                 "assignPublicIp": "ENABLED",
#             },
#         },
#         task_concurrency=10
#     )
#
#     latest_only >> [pv_consumer, gsp_consumer, nwp_consumer]
#     gsp_consumer >> forecaster_pvnet1
#     pv_consumer >> forecaster_pvnet1
#     nwp_consumer >> [national_forecaster, forecaster_pvnet1, forecaster_pvnet2]
#
