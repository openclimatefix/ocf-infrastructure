# This is an temporary module.
# This will schedule the aws task to run on cron job.
# We want to move to Dagster but for the moment its useful to have this setup

resource "aws_cloudwatch_event_rule" "event_rule" {
  name                = "pv-schedule-${var.environment}"
  schedule_expression = "cron(4,9,14,19,24,29,34,39,44,49,54,59 * * * ? *)"
  # runs every 5 minutes, with 1 minute buffer to start the ECS task
}

resource "aws_cloudwatch_event_target" "ecs_scheduled_task" {

  rule      = aws_cloudwatch_event_rule.event_rule.name
  target_id = "pv-schedule-${var.environment}"
  arn       = var.ecs-cluster.arn
  role_arn  = aws_iam_role.cloudwatch_role.arn

  ecs_target {

    launch_type         = "FARGATE"
    platform_version    = "1.4.0"
    task_count          = 1
    task_definition_arn = aws_ecs_task_definition.pv-task-definition.arn
    network_configuration {

      subnets          = var.public_subnet_ids
      assign_public_ip = true

    }

  }

}
