# This is an temporary module.
# This will schedule the aws task to run on cron job.
# We want to move to Dagster but for the moment its useful to have this setup

resource "aws_cloudwatch_event_rule" "event_rule" {
  name                = "sat-schedule-${var.environment}"
  schedule_expression = "cron(*/5 * * * ? *)"
  # runs every 5 minutes
}

resource "aws_cloudwatch_event_target" "ecs_scheduled_task" {

  rule      = aws_cloudwatch_event_rule.event_rule.name
  target_id = "sat-schedule-${var.environment}"
  arn       = var.ecs-cluster.arn
  role_arn  = aws_iam_role.cloudwatch_role.arn

  ecs_target {

    launch_type         = "FARGATE"
    platform_version    = "1.4.0"
    task_count          = 1
    task_definition_arn = aws_ecs_task_definition.sat-task-definition.arn
    network_configuration {

      subnets          = var.public_subnet_ids
      assign_public_ip = true

    }

  }

}


# run data tailor clean up
resource "aws_cloudwatch_event_rule" "event_rule_sat_clean_up" {
  name                = "sat-clean-up-schedule-${var.environment}"
  schedule_expression = "cron(0 6,18 * * ? *)"
  # runs every 5 minutes
}

resource "aws_cloudwatch_event_target" "ecs_scheduled_task_sat_clean_up" {

  rule      = aws_cloudwatch_event_rule.event_rule_sat_clean_up.name
  target_id = "sat-clean-up-schedule-${var.environment}"
  arn       = var.ecs-cluster.arn
  role_arn  = aws_iam_role.cloudwatch_role.arn

  ecs_target {

    launch_type         = "FARGATE"
    platform_version    = "1.4.0"
    task_count          = 1
    task_definition_arn = aws_ecs_task_definition.sat-clean-up-task-definition.arn
    network_configuration {

      subnets          = var.public_subnet_ids
      assign_public_ip = true

    }

  }

}
