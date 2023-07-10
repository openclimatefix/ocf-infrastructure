# IAM role for EB Service role and instance role
# Service role is what monitors the application
# Instance role is the role used when running the app
# Instance role needs to be able to kick off ECS tasks

data "aws_iam_policy_document" "service" {
  # Policy document for Service role

  statement {
    actions = [
      "sts:AssumeRole"
    ]

    principals {
      type        = "Service"
      identifiers = ["elasticbeanstalk.amazonaws.com"]
    }

    effect = "Allow"
  }
}

data "aws_iam_policy_document" "instance" {
  # Policy document for ec2 instance role

  statement {
    actions = [
      "sts:AssumeRole",
    ]

    principals {
      type        = "Service"
      identifiers = [
      "ec2.amazonaws.com",
      "ecs-tasks.amazonaws.com"]
    }

    effect = "Allow"
  }
}





resource "aws_iam_policy" "cloudwatch" {
  name        = "ocf-airflow-cloudwatch-read-and-write"
  path        = "/"
  description = "Policy to allow read and write to cloudwatch logs"

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "logs:PutLogEvents",
          "logs:CreateLogStream",
          "logs:DescribeLogStreams",
          "logs:DescribeLogGroups",
        ]
        Effect   = "Allow"
        Resource = "arn:aws:logs:*:*:log-group:/aws/elasticbeanstalk*"
      },
    ]
  })
}



resource "aws_iam_policy" "ecs-run" {
  name        = "ocf-airflow-ecs-run"
  path        = "/"
  description = "Policy to run all ecs tasks"

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "ecs:RunTask",
        ]
        Effect   = "Allow"
        Resource = "arn:aws:task-definition:*"
      },
    ]
  })
}


##################
# Service role
##################

resource "aws_iam_role" "api-service-role" {
  name = "ocf-airflow-${var.environment}-service-role"
  path = "/"

  assume_role_policy = join("", data.aws_iam_policy_document.service.*.json)

}

resource "aws_iam_role_policy_attachment" "enhanced_health" {

  role       = join("", aws_iam_role.api-service-role.*.name)
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSElasticBeanstalkEnhancedHealth"
}

resource "aws_iam_role_policy_attachment" "service" {

  role       = join("", aws_iam_role.api-service-role.*.name)
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSElasticBeanstalkService"
}

resource "aws_iam_role_policy_attachment" "attach-logs-service" {
  role       = aws_iam_role.api-service-role.name
  policy_arn = aws_iam_policy.cloudwatch.arn
}

resource "aws_iam_role_policy_attachment" "attach-read-s3" {
  role       = aws_iam_role.api-service-role.name
  policy_arn = aws_iam_policy.read-policy.arn
}





##################
# Instance role
##################

resource "aws_iam_role" "instance-role" {
  name = "ocf-airflow-${var.environment}-role"
  path = "/"

  assume_role_policy = join("", data.aws_iam_policy_document.instance.*.json)
}

resource "aws_iam_role_policy_attachment" "web_tier" {

  role       = join("", aws_iam_role.instance-role.*.name)
  policy_arn = "arn:aws:iam::aws:policy/AWSElasticBeanstalkWebTier"
}

resource "aws_iam_role_policy_attachment" "worker_tier" {

  role       = join("", aws_iam_role.instance-role.*.name)
  policy_arn = "arn:aws:iam::aws:policy/AWSElasticBeanstalkWorkerTier"
}


resource "aws_iam_role_policy_attachment" "attach-logs" {
  role       = aws_iam_role.instance-role.name
  policy_arn = aws_iam_policy.cloudwatch.arn
}


resource "aws_iam_instance_profile" "ec2" {

  name = "ocf-airflow-instance-eb-${var.environment}"
  role = join("", aws_iam_role.instance-role.*.name)
}

resource "aws_iam_role_policy_attachment" "attach-read-s3-instance-role" {
  role       = aws_iam_role.instance-role.name
  policy_arn = aws_iam_policy.read-policy.arn
}

#Add ability to read tasks definitions and set off ECS tasks
resource "aws_iam_role_policy_attachment" "ecs-task-execution-role-policy-attachment" {
  role       = aws_iam_role.instance-role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_role_policy_attachment" "attach-ecs-run" {
  role       = aws_iam_role.instance-role.name
  policy_arn = aws_iam_policy.cloudwatch.arn
}
