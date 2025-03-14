# create s3 bucket for application verions and copy DAGs to it

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


# resource "aws_s3_object" "dags" {
#   for_each = fileset("${local.dags_loc}/", "*")
#
#   bucket = aws_s3_bucket.airflow-s3.id
#   key    = "./dags/${each.value}"
#   source = "${local.dags_loc}/${each.value}"
#   etag   = filemd5("${local.dags_loc}/${each.value}")
# }

# resource "aws_s3_object" "dags-utils" {
#   for_each = fileset("${path.module}/dags/utils", "*")
#
#   bucket = aws_s3_bucket.airflow-s3.id
#   key    = "./dags/utils/${each.value}"
#   source = "${path.module}/dags/utils/${each.value}"
#   etag   = filemd5("${path.module}/dags/utils/${each.value}")
# }
