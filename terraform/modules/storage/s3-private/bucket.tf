# Private, Lifecycled S3 bucket

# Bucket itself
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket
resource "aws_s3_bucket" "bucket" {
  bucket = "${var.domain}-${var.service_name}-${var.environment}"

  tags = {
    Name        = "${var.environment}-s3"
    Environment = var.environment
  }
}

# Block all public access
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_public_access_block
resource "aws_s3_bucket_public_access_block" "access_block" {
  bucket = aws_s3_bucket.bucket.id

  block_public_acls       = true
  block_public_policy     = true
  restrict_public_buckets = true
  ignore_public_acls      = true

}

resource "aws_s3_bucket_ownership_controls" "aws_s3_bucket_ownership_controls" {
  bucket = aws_s3_bucket.bucket.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

# Private ACL for bucket
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_acl
resource "aws_s3_bucket_acl" "acl" {
  depends_on = [aws_s3_bucket_ownership_controls.aws_s3_bucket_ownership_controls]

  bucket = "${var.domain}-${var.service_name}-${var.environment}"
  acl = "private"
}

# Lifecycle for prefixed bucket data
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_lifecycle_configuration
resource "aws_s3_bucket_lifecycle_configuration" "lifecycle" {

  # this makes sure that the lifecyle is not made, if there are no rules.
  count = length(var.lifecycled_prefixes) == 0 ? 0 : 1

  bucket = aws_s3_bucket.bucket.id

  # loop over all rules
  dynamic "rule" {
    for_each = toset(var.lifecycled_prefixes)
    content {
        id = "remove_old_${rule.value}_files"
        status = "Enabled"
        filter {
          prefix = "${rule.value}/"
        }
        expiration {
          days = 7
        }
    }
  }
}
