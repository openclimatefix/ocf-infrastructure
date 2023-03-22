# This is an temporary module.
# This will schedule the aws task to run on cron job.
# We want to move to Dagster but for the moment its useful to have this setup

resource "aws_cloudwatch_event_rule" "event_rule" {
  name                = "gsp-schedule-${var.environment}"
  schedule_expression = "cron(6,9,12,14,20,39,42,44,50 * * * ? *)"
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
  schedule_expression = "cron(30 10,11 * * ? *)"
  # Calculation is run at 10.30 local time by sheffield solar. At most this takes 1 hour.
  # Therefore we run this every morning at 10:30 and 11:30 UTC.
  # Service only runs when local time is between 11 and 12.
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

resource "aws_cloudwatch_event_rule" "event_rule_national_day_after" {
  name                = "national-day-after-schedule-${var.environment}"
  schedule_expression = "cron(45 9,10 * * ? *)"
  # Calculation is made at 10.30 local time by sheffield solar.
  # Therefore we run this every morning at 9:45 UTC and 10.45 UTC.
  # Service only runs when local time is between 10 and 11.
}

resource "aws_cloudwatch_event_target" "ecs_scheduled_task_national_day_after" {

  rule      = aws_cloudwatch_event_rule.event_rule_national_day_after.name
  target_id = "national-schedule-day-after-${var.environment}"
  arn       = var.ecs-cluster.arn
  role_arn  = aws_iam_role.cloudwatch_role.arn

  ecs_target {

    launch_type         = "FARGATE"
    platform_version    = "1.4.0"
    task_count          = 1
    task_definition_arn = aws_ecs_task_definition.national-day-after-task-definition.arn
    network_configuration {

      subnets          = var.public_subnet_ids
      assign_public_ip = true

    }

  }

}
