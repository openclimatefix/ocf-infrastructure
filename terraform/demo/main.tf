# run 'terraform init'


resource "aws_s3_bucket" "s3-demo-bucket" {
  bucket = "demo-bucket"
  acl    = "private"
}

resource "aws_iam_policy" "iam-policy-demo-read" {
  name        = "s3-demo-read-policy"
  description = "Policy to read bucket: ${aws_s3_bucket.s3-demo-bucket.bucket}"

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
          aws_s3_bucket.s3-demo-bucket.arn,
        "${aws_s3_bucket.s3-demo-bucket.arn}/*"]
      },
    ]
  })
}