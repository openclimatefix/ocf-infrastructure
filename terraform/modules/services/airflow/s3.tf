# create s3 bucket for application verions and copy DAGs to it

resource "aws_s3_bucket" "airflow-s3" {
  bucket = "ocf-airflow-${var.environment}-bucket"
}

resource "aws_s3_object" "eb_object" {
  bucket = aws_s3_bucket.airflow-s3.id
  key = "beanstalk/docker-compose.yml"
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
  name        = "s3-airflow-read-policy"
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


resource "aws_s3_object" "dags" {
  for_each = fileset("./dags/", "*")

  bucket = aws_s3_bucket.airflow-s3.id
  key    = "./dags/${each.value}"
  source = "./dags/${each.value}"
  etag   = filemd5("./dags/${each.value}")
}
