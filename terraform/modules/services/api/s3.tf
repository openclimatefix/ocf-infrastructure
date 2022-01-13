# create s3 bucket for application verions

resource "aws_s3_bucket" "eb" {
  bucket = "nowcasting-eb-applicationversion"
}

resource "aws_s3_bucket_object" "eb-object" {
  bucket = aws_s3_bucket.eb.id
  key    = "beanstalk/docker-compose.yml"
  source = "./modules/api/docker-compose.yml"
}
