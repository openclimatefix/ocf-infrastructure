# # This is an temporary module.
# # This will schedule the aws task to run on cron job.
# # We want to move to Dagster but for the moment its useful to have this setup
#
# // Cloudwatch execution role
# data "aws_iam_policy_document" "cloudwatch_assume_role" {
#   statement {
#     principals {
#       type = "Service"
#       identifiers = [
#         "events.amazonaws.com",
#         "ecs-tasks.amazonaws.com",
#       ]
#     }
#     actions = ["sts:AssumeRole"]
#   }
# }
#
# data "aws_iam_policy_document" "cloudwatch" {
# 
#   statement {
#     effect    = "Allow"
#     actions   = ["ecs:RunTask"]
#     resources = [aws_ecs_task_definition.forecast-task-definition.arn]
#   }
#   statement {
#     effect  = "Allow"
#     actions = ["iam:PassRole"]
#     resources = concat([
#       aws_iam_role.ecs_task_execution_role-forecast.arn,
#     aws_iam_role.forecast-iam-role.arn])
#   }
# }
#
# resource "aws_iam_role" "cloudwatch_role" {
#   name               = "forecast-schedule-cloudwatch-execution"
#   assume_role_policy = data.aws_iam_policy_document.cloudwatch_assume_role.json
#
# }
#
# resource "aws_iam_role_policy_attachment" "cloudwatch" {
#   role       = aws_iam_role.cloudwatch_role.name
#   policy_arn = aws_iam_policy.cloudwatch.arn
# }
#
# resource "aws_iam_role_policy_attachment" "cloudwatch-secret" {
#   role       = aws_iam_role.cloudwatch_role.name
#   policy_arn = var.iam-policy-rds-read-secret.arn
# }
#
# resource "aws_iam_policy" "cloudwatch" {
#   name   = "forecast-schedule-cloudwatch-execution"
#   policy = data.aws_iam_policy_document.cloudwatch.json
# }
