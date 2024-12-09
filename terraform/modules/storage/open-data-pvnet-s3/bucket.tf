# Public S3 bucket

# Bucket itself
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket
resource "aws_s3_bucket" "bucket" {
  bucket = "ocf-open-data-pvnet"

  tags = {
    Name        = "Open_Data_PVNet"
  }
}
