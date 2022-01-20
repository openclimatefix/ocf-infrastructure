# Make IAM policy to read and write to the s3 bucket for NWP

resource "aws_iam_policy" "iam-policy-s3-nwp-read" {
  name        = "s3-nwp-read-policy"
  description = "Policy to read bucket: ${aws_s3_bucket.s3-nwp-bucket.bucket}"

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
          aws_s3_bucket.s3-nwp-bucket.arn,
        "${aws_s3_bucket.s3-nwp-bucket.arn}/*"]
      },
    ]
  })
}

resource "aws_iam_policy" "iam-policy-s3-nwp-write" {
  name        = "s3-nwp-write-policy"
  description = "Policy to write to bucket: ${aws_s3_bucket.s3-nwp-bucket.bucket}"

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
          aws_s3_bucket.s3-nwp-bucket.arn,
        "${aws_s3_bucket.s3-nwp-bucket.arn}/*"]
      },
    ]
  })
}
