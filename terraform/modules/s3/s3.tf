# Creates S3 bucket for nwp data

# make sure all public access is blocked
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_public_access_block
resource "aws_s3_bucket_public_access_block" "s3-nwp-block-public-access" {
  bucket = aws_s3_bucket.s3-nwp-bucket.id

  block_public_acls       = true
  block_public_policy     = true
  restrict_public_buckets = true
  ignore_public_acls      = true

}

# Documentation: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket
resource "aws_s3_bucket" "s3-nwp-bucket" {
  bucket = "nowcasting-nwp-${var.environment}"
  acl    = "private"

  lifecycle_rule {
    id      = "remove_old_files"
    enabled = true

    prefix = "data/"

    expiration {
      days = 30
    }
  }

  tags = {
    Name        = "${var.environment}-s3"
    Environment = "${var.environment}"
  }
}


# get s3 bucket
# This means this bucket is not destroyed, we are just referencing it
data "aws_s3_bucket" "s3-ml" {
  bucket = "nowcasting-ml-models-${var.environment}"
}

# Creates S3 bucket for satellite data

# make sure all public access is blocked
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_public_access_block
resource "aws_s3_bucket_public_access_block" "s3-sat-block-public-access" {
  bucket = aws_s3_bucket.s3-sat-bucket.id

  block_public_acls       = true
  block_public_policy     = true
  restrict_public_buckets = true
  ignore_public_acls      = true

}

# Documentation: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket
resource "aws_s3_bucket" "s3-sat-bucket" {
  bucket = "nowcasting-sat-${var.environment}"

  acl    = "private"

  lifecycle_rule {
    id      = "remove_old_files"
    enabled = true

    prefix = "data/"

    expiration {
      days = 30
    }
  }

  tags = {
    Name        = "${var.environment}-s3"
    Environment = "${var.environment}"
  }
}
