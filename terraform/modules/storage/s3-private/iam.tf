# Make IAM policy to read and write to the s3-private bucket for NWP

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy
resource "aws_iam_policy" "read-policy" {
  name        = "s3-${var.service_name}-read-policy"
  description = "Policy to read bucket: ${aws_s3_bucket.bucket.bucket}"

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
          aws_s3_bucket.bucket.arn,
        "${aws_s3_bucket.bucket.arn}/*"]
      },
    ]
  })
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy
resource "aws_iam_policy" "write-policy" {
  name        = "s3-${var.service_name}-write-policy"
  description = "Policy to write to bucket: ${aws_s3_bucket.bucket.bucket}"

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = ["s3:ListBucket",
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject"
        ]
        Effect = "Allow"
        Resource = [
          aws_s3_bucket.bucket.arn,
        "${aws_s3_bucket.bucket.arn}/*"]
      },
    ]
  })
}
