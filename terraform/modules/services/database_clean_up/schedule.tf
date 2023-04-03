# This is a temporary module.
# This will schedule the aws task to run on cron job.
# We want to move to Dagster but for the moment its useful to have this setup

resource "aws_cloudwatch_event_rule" "event_rule" {
  name                = "${var.app-name}-schedule-${var.environment}"
  schedule_expression = var.scheduler_config.cron_expression
}

resource "aws_cloudwatch_event_target" "ecs_scheduled_task" {

  rule      = aws_cloudwatch_event_rule.event_rule.name
  target_id = "${var.app-name}-schedule-${var.environment}"
  arn       = var.scheduler_config.ecs_cluster_arn
  role_arn  = aws_iam_role.cloudwatch_role.arn

  ecs_target {

    launch_type         = "FARGATE"
    platform_version    = "1.4.0"
    task_count          = 1
    task_definition_arn = aws_ecs_task_definition.ecs-task-definition.arn
    network_configuration {

      subnets          = var.scheduler_config.subnet_ids
      assign_public_ip = true

    }

  }

}
