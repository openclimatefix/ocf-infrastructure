output "iam-policy-s3-nwp-write" {
  value = aws_iam_policy.iam-policy-s3-nwp-write
}

output "iam-policy-s3-nwp-read" {
  value = aws_iam_policy.iam-policy-s3-nwp-read
}

output "s3-nwp-bucket" {
  value = aws_s3_bucket.s3-nwp-bucket
}

output "iam-policy-s3-sat-write" {
  value = aws_iam_policy.iam-policy-s3-sat-write
}

output "iam-policy-s3-sat-read" {
  value = aws_iam_policy.iam-policy-s3-sat-read
}

output "s3-sat-bucket" {
  value = aws_s3_bucket.s3-sat-bucket
}

output "iam-policy-s3-ml-read" {
  value = aws_iam_policy.iam-policy-s3-ml-read
}

output "iam-policy-s3-ml-write" {
  value = aws_iam_policy.iam-policy-s3-ml-write
}

output "s3-ml-bucket" {
  value = data.aws_s3_bucket.s3-ml
}
