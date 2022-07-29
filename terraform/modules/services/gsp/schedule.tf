# This is an temporary module.
# This will schedule the aws task to run on cron job.
# We want to move to Dagster but for the moment its useful to have this setup

resource "aws_cloudwatch_event_rule" "event_rule" {
  name                = "gsp-schedule-${var.environment}"
  schedule_expression = "cron(9,12,14,20,39,42,44,50 * * * ? *)"
  # runs every 30 minutes at 9 and 39 past
}

resource "aws_cloudwatch_event_target" "ecs_scheduled_task" {

  rule      = aws_cloudwatch_event_rule.event_rule.name
  target_id = "gsp-schedule-${var.environment}"
  arn       = var.ecs-cluster.arn
  role_arn  = aws_iam_role.cloudwatch_role.arn

  ecs_target {

    launch_type         = "FARGATE"
    platform_version    = "1.4.0"
    task_count          = 1
    task_definition_arn = aws_ecs_task_definition.gsp-task-definition.arn
    network_configuration {

      subnets          = var.public_subnet_ids
      assign_public_ip = true

    }

  }

}

resource "aws_cloudwatch_event_rule" "event_rule_day_after" {
  name                = "gsp-day-after-schedule-${var.environment}"
  schedule_expression = "cron(0 7 * * ? *)"
  # runs every morning at 7 UTC
}

resource "aws_cloudwatch_event_target" "ecs_scheduled_task_day_after" {

  rule      = aws_cloudwatch_event_rule.event_rule_day_after.name
  target_id = "gsp-schedule-day-after-${var.environment}"
  arn       = var.ecs-cluster.arn
  role_arn  = aws_iam_role.cloudwatch_role.arn

  ecs_target {

    launch_type         = "FARGATE"
    platform_version    = "1.4.0"
    task_count          = 1
    task_definition_arn = aws_ecs_task_definition.gsp-day-after-task-definition.arn
    network_configuration {

      subnets          = var.public_subnet_ids
      assign_public_ip = true

    }

  }

}
