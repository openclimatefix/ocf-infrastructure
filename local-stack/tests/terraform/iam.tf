# create a iam user that will be used for infrastturcutre test.
# currently the user role will need at read access s3:nowcasting-ml-models-development

resource "aws_iam_user" "local-stack-tests-user" {
  name = "local-stack-tests-user"
  path = "/"

  tags = {
    tag-key = "testing"
  }
}

resource "aws_iam_access_key" "local-stack-tests-access-key" {
  user = aws_iam_user.local-stack-tests-user.name
}

# get s3 bucket
# This means this bucket is not destroyed, we are just referencing it
data "aws_s3_bucket" "s3-ml" {
  bucket = "nowcasting-ml-models-development"
}

resource "aws_iam_policy" "user-policy-s3-ml-read" {
  name        = "local-stack-s3-ml-read-policy"
  description = "Policy to read bucket: ${data.aws_s3_bucket.s3-ml.bucket}. Only to be used by local stack user"

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
          data.aws_s3_bucket.s3-ml.arn,
        "${data.aws_s3_bucket.s3-ml.arn}/*"]
      },
    ]
  })
}

resource "aws_iam_user_policy_attachment" "attach-s3-policy" {
  user       = aws_iam_user.local-stack-tests-user.name
  policy_arn = aws_iam_policy.user-policy-s3-ml-read.arn
}


