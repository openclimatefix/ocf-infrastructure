# Make IAM policy to write to the s3-public bucket

data "aws_iam_policy_document" "open_data_pvnet_write_policy_description" {
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
resource "aws_iam_policy" "open_data_pvnet_write_policy" {
  name        = "s3-open_data_pvnet_write_policy"
  description = "Policy to write to bucket: ${aws_s3_bucket.bucket.bucket}"

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  policy = data.aws_iam_policy_document.open_data_pvnet_write_policy_description.json

}


# resource group
resource "aws_iam_group" "open_data_pvnet_write_group" {
  name = "open_data_pvnet_write_group"
}

# attach policy to group
resource "aws_iam_policy_attachment" "open_data_pvnet_write_policy_attachment" {
  name       = "s3-write-attachment"
  policy_arn = aws_iam_policy.open_data_pvnet_write_policy.arn
  group      = aws_iam_group.open_data_pvnet_write_group.name
}