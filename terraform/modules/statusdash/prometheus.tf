resource "aws_prometheus_workspace" "statusdash" {
  alias = "statusdash-nowcasting"
}

resource "aws_ecs_service" "monitoring" {
  name            = "monitoring"
  cluster         = var.ecs-cluster.id

  task_definition = aws_ecs_task_definition.statusdash-task-definition.arn
  desired_count   = 1

  network_configuration {

      subnets          = var.subnet_ids
      assign_public_ip = true

    }
}

resource "aws_ecs_task_definition" "statusdash-task-definition" {
  family = "statusdash"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"

  cpu    = 256
  memory = 512

  task_role_arn      = aws_iam_role.statusdash-iam-role.arn
  execution_role_arn = aws_iam_role.ecs_task_execution_role-statusdash.arn
  container_definitions = jsonencode([
    {
      name      = "prometheus"
      image     = "openclimatefix/nowcasting_status:v0.1.0"
      essential = true

      logConfiguration : {
        "logDriver" : "awslogs",
        "options" : {
          "awslogs-group" : var.log-group-name,
          "awslogs-region" : var.region,
          "awslogs-stream-prefix" : "streaming"
        }
      }
    }
  ])
}

# +++++++++++++++++++++++++++
# IAM
# +++++++++++++++++++++++++++
resource "aws_iam_role" "ecs_task_execution_role-statusdash" {
  name = "ecs-statusdash-execution-role"

  assume_role_policy = <<EOF
{
 "Version": "2012-10-17",
 "Statement": [
   {
     "Action": "sts:AssumeRole",
     "Principal": {
       "Service": "ecs-tasks.amazonaws.com"
     },
     "Effect": "Allow",
     "Sid": ""
   }
 ]
}
EOF
}

resource "aws_iam_role" "statusdash-iam-role" {
  name               = "statusdash-iam-role"
  path               = "/statusdash/"
  assume_role_policy = data.aws_iam_policy_document.statusdash-assume-role-policy.json
}

data "aws_iam_policy_document" "statusdash-assume-role-policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}