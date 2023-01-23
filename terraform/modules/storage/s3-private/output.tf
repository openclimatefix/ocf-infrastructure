output "bucket" {
  value = aws_s3_bucket.bucket
}

output "write-policy" {
  value = aws_iam_policy.write-policy
}

output "read-policy" {
  value = aws_iam_policy.read-policy
}
