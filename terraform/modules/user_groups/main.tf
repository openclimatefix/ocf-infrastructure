resource "aws_iam_group" "developer_group" {
  name = "${var.region}-developer"
}

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

resource "aws_iam_policy_attachment" "attach_full_access_policy" {
  name       = "${var.region}-full-access-attachment"
  policy_arn = aws_iam_policy.full_access_policy.arn
  groups     = [aws_iam_group.developer_group.name]
}

# Explicit permissions for each service
resource "aws_iam_policy_attachment" "ecs_policy_attachment" {
  name       = "${var.region}-ecs-attachment"
  policy_arn = "arn:aws:iam::aws:policy/AmazonECS_FullAccess"
  groups     = [aws_iam_group.developer_group.name]
}

resource "aws_iam_policy_attachment" "s3_policy_attachment" {
  name       = "${var.region}-s3-attachment"
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
  groups     = [aws_iam_group.developer_group.name]
}

resource "aws_iam_policy_attachment" "secrets_manager_policy_attachment" {
  name       = "${var.region}-secrets-manager-attachment"
  policy_arn = "arn:aws:iam::aws:policy/SecretsManagerReadWrite"
  groups     = [aws_iam_group.developer_group.name]
}

resource "aws_iam_policy_attachment" "cloudwatch_policy_attachment" {
  name       = "${var.region}-cloudwatch-attachment"
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchFullAccess"
  groups     = [aws_iam_group.developer_group.name]
}

resource "aws_iam_policy_attachment" "beanstalk_policy_attachment" {
  name       = "${var.region}-beanstalk-attachment"
  policy_arn = "arn:aws:iam::aws:policy/AWSElasticBeanstalkFullAccess"
  groups     = [aws_iam_group.developer_group.name]
}

resource "aws_iam_policy_attachment" "rds_policy_attachment" {
  name       = "${var.region}-rds-attachment"
  policy_arn = "arn:aws:iam::aws:policy/AmazonRDSFullAccess"
  groups     = [aws_iam_group.developer_group.name]
}

resource "aws_iam_policy_attachment" "ec2_policy_attachment" {
  name       = "${var.region}-ec2-attachment"
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2FullAccess"
  groups     = [aws_iam_group.developer_group.name]
}
