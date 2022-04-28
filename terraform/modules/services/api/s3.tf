# create s3 bucket for application verions

resource "aws_s3_bucket" "eb" {
  bucket = "nowcasting-eb-applicationversion"
}

resource "aws_s3_bucket_object" "eb-object" {
  bucket = aws_s3_bucket.eb.id
  key    = "beanstalk/docker-compose-${var.docker_version}.yml"
  source = "${path.module}/docker-compose.yml"
}

resource "aws_s3_bucket_acl" "eb-acl" {
  bucket = aws_s3_bucket.eb.id
  acl    = "private"
}