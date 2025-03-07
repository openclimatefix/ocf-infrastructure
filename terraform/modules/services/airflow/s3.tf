# Create S3 Bucket for Airflow to pick up dags from

locals {
  dags_loc = "${path.module}/dags/${var.dags_folder}"
}

resource "aws_s3_bucket" "airflow-s3" {
  bucket = "${var.aws-domain}-${var.aws-environment}-eb-airflow"
}

resource "aws_s3_object" "eb_object" {
  bucket = aws_s3_bucket.airflow-s3.id
  key = "beanstalk/docker-compose-${var.docker-compose-version}.yml"
  source = "${path.module}/docker-compose.yml"
}

resource "aws_s3_bucket_public_access_block" "eb-pab" {
  bucket = aws_s3_bucket.airflow-s3.id

  block_public_acls       = true
  block_public_policy     = true
  restrict_public_buckets = true
  ignore_public_acls      = true

}


resource "aws_iam_policy" "read-policy" {
  name        = "${var.aws-domain}-${var.aws-environment}-airflow-read-policy"
  description = "Policy to read bucket: ${aws_s3_bucket.airflow-s3.bucket}"

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = ["s3:ListBucket",
          "s3:GetObject",
        ]
        Effect = "Allow"
        Resource = [
          aws_s3_bucket.airflow-s3.arn,
        "${aws_s3_bucket.airflow-s3.arn}/*"]
      },
    ]
  })
}

