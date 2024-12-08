# Public S3 bucket

# Bucket itself
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket
resource "aws_s3_bucket" "bucket" {
  bucket = "${var.domain}-${var.service_name}-${var.environment}"

  tags = {
    Name        = "${var.environment}-s3"
    Environment = var.environment
  }
}
