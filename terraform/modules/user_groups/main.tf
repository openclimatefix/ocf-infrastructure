# Developer group
resource "aws_iam_group" "developer_group" {
  name = "${var.region}-developer"
}

# Full access policy
resource "aws_iam_policy" "full_access_policy" {
  name        = "${var.region}-full-access-policy"
  description = "Policy granting full access to AWS services in ${var.region}"
  policy      = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": "*",
      "Resource": "*"
    }
  ]
}
EOF
}

# Attach full access policy to the developer group
resource "aws_iam_policy_attachment" "attach_full_access_policy" {
  name       = "${var.region}-full-access-attachment"
  policy_arn = aws_iam_policy.full_access_policy.arn
  groups     = [aws_iam_group.developer_group.name]
}

# Custom policies with restricted access for each service

# ECS
resource "aws_iam_policy" "ecs_policy" {
  name        = "${var.region}-ecs-policy"
  description = "Policy granting ECS access in ${var.region}"
  policy      = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ecs:*"
      ],
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_iam_policy_attachment" "ecs_policy_attachment" {
  name       = "${var.region}-ecs-attachment"
  policy_arn = aws_iam_policy.ecs_policy.arn
  groups     = [aws_iam_group.developer_group.name]
}

# S3
resource "aws_iam_policy" "s3_policy" {
  name        = "${var.region}-s3-policy"
  description = "Policy granting S3 access in ${var.region}"
  policy      = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "s3:*"
      ],
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_iam_policy_attachment" "s3_policy_attachment" {
  name       = "${var.region}-s3-attachment"
  policy_arn = aws_iam_policy.s3_policy.arn
  groups     = [aws_iam_group.developer_group.name]
}

# Secrets Manager
resource "aws_iam_policy" "secrets_manager_policy" {
  name        = "${var.region}-secrets-manager-policy"
  description = "Policy granting Secrets Manager access in ${var.region}"
  policy      = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "secretsmanager:*"
      ],
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_iam_policy_attachment" "secrets_manager_policy_attachment" {
  name       = "${var.region}-secrets-manager-attachment"
  policy_arn = aws_iam_policy.secrets_manager_policy.arn
  groups     = [aws_iam_group.developer_group.name]
}

# CloudWatch
resource "aws_iam_policy" "cloudwatch_policy" {
  name        = "${var.region}-cloudwatch-policy"
  description = "Policy granting CloudWatch access in ${var.region}"
  policy      = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "cloudwatch:*"
      ],
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_iam_policy_attachment" "cloudwatch_policy_attachment" {
  name       = "${var.region}-cloudwatch-attachment"
  policy_arn = aws_iam_policy.cloudwatch_policy.arn
  groups     = [aws_iam_group.developer_group.name]
}

# Elastic Beanstalk
resource "aws_iam_policy" "beanstalk_policy" {
  name        = "${var.region}-beanstalk-policy"
  description = "Policy granting Elastic Beanstalk access in ${var.region}"
  policy      = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "elasticbeanstalk:*"
      ],
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_iam_policy_attachment" "beanstalk_policy_attachment" {
  name       = "${var.region}-beanstalk-attachment"
  policy_arn = aws_iam_policy.beanstalk_policy.arn
  groups     = [aws_iam_group.developer_group.name]
}

# RDS
resource "aws_iam_policy" "rds_policy" {
  name        = "${var.region}-rds-policy"
  description = "Policy granting RDS access in ${var.region}"
  policy      = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "rds:*"
      ],
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_iam_policy_attachment" "rds_policy_attachment" {
  name       = "${var.region}-rds-attachment"
  policy_arn = aws_iam_policy.rds_policy.arn
  groups     = [aws_iam_group.developer_group.name]
}

# EC2
resource "aws_iam_policy" "ec2_policy" {
  name        = "${var.region}-ec2-policy"
  description = "Policy granting EC2 access in ${var.region}"
  policy      = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ec2:*"
      ],
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_iam_policy_attachment" "ec2_policy_attachment" {
  name       = "${var.region}-ec2-attachment"
  policy_arn = aws_iam_policy.ec2_policy.arn
  groups     = [aws_iam_group.developer_group.name]
}