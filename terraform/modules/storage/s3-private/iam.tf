# Make IAM policy to read and write to the s3-private bucket for NWP

data "aws_iam_policy_document" "read_policy_description" {
  version = "2012-10-17"
  statement {
    actions = [
      "s3:ListBucket",
      "s3:GetObject",
      "s3:GetObjectAttributes"
    ]
    resources = [aws_s3_bucket.bucket.arn, "${aws_s3_bucket.bucket.arn}/*"]
    effect = "Allow"
  }
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy
resource "aws_iam_policy" "read-policy" {
  name        = "s3-${var.domain}-${var.service_name}-read-policy"
  description = "Policy to read bucket: ${aws_s3_bucket.bucket.bucket}"

  policy = data.aws_iam_policy_document.read_policy_description.json
}

data "aws_iam_policy_document" "write_policy_description" {
  version = "2012-10-17"
  statement {
    actions = [
      "s3:ListBucket",
      "s3:GetObject",
      "s3:PutObject",
      "s3:DeleteObject"
    ]
    resources = [aws_s3_bucket.bucket.arn, "${aws_s3_bucket.bucket.arn}/*"]
    effect = "Allow"
  }
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy
resource "aws_iam_policy" "write-policy" {
  name        = "s3-${var.domain}-${var.service_name}-write-policy"
  description = "Policy to write to bucket: ${aws_s3_bucket.bucket.bucket}"

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  policy = data.aws_iam_policy_document.write_policy_description.json
}
