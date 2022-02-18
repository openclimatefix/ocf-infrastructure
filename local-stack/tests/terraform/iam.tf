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

data "aws_iam_policy" "iam-policy-s3-ml-read" {
  name = "s3-ml-read-policy"
}

resource "aws_iam_user_policy_attachment" "attach-s3-policy" {
  user       = aws_iam_user.local-stack-tests-user.name
  policy_arn = data.aws_iam_policy.iam-policy-s3-ml-read.arn
}


