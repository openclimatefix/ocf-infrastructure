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

  # make private

  tags = {
    Name        = "${var.environment}-s3"
    Environment = "${var.environment}"
  }
}
