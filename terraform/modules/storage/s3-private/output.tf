output "bucket_id" {
  value = aws_s3_bucket.bucket.id
}

output "bucket_arn" {
  value = aws_s3_bucket.bucket.arn
}

output "write_policy_arn" {
  value = aws_iam_policy.write-policy.arn
}

output "read_policy_arn" {
  value = aws_iam_policy.read-policy.arn
}
