output "iam-policy-s3-nwp-write" {
  value = aws_iam_policy.iam-policy-s3-nwp-write
}

output "s3-nwp-bucket" {
  value = aws_s3_bucket.s3-nwp-bucket
}
