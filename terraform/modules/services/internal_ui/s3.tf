# create s3 bucket for application version

resource "aws_s3_bucket" "eb" {
  bucket = "${var.domain}-${var.environment}-eb-${var.eb_app_name}"
}

resource "aws_s3_object" "eb-object" {
  bucket = aws_s3_bucket.eb.id
  key    = "beanstalk/docker-compose-${var.docker_config.version}.yml"
  source = "${path.module}/docker-compose.yml"
}

resource "aws_s3_bucket_public_access_block" "eb-pab" {
  bucket = aws_s3_bucket.eb.id

  block_public_acls       = true
  block_public_policy     = true
  restrict_public_buckets = true
  ignore_public_acls      = true
}
