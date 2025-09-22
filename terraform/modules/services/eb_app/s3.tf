# Create an S3 bucket containing the docker-compose.yml file
# for the Elastic Beanstalk app

resource "aws_s3_bucket" "eb-app-docker-bucket" {
  bucket = "${var.domain}-${var.aws-environment}-eb-${var.eb-app_name}"
}

resource "aws_s3_object" "eb-object" {
  bucket = aws_s3_bucket.eb-app-docker-bucket.id
  key    = "beanstalk/docker-compose-${var.container-tag}.yml"
  content = yamlencode({
    "version" = "3",
    "services" = {
      "eb-app" = {
        "image" = "${var.container-registry}/${var.container-name}:${var.container-tag}",
        "environment" = [for kv in var.container-env_vars : format("%s=$%s", kv.name, kv.name)],
        "container_name" = (var.container-name),
        "command" = (var.container-command),
        "ports" = ["${var.container-host-port}:${var.container-port}"],
      }
    }
  })
}

resource "aws_s3_bucket_public_access_block" "eb-s3-pab" {
  bucket = aws_s3_bucket.eb-app-docker-bucket.id

  block_public_acls       = true
  block_public_policy     = true
  restrict_public_buckets = true
  ignore_public_acls      = true

}
