# TODO
# 1. add security groups

#2, Environment health has transitioned from Warning to Severe.
#Initialization completed 7 seconds ago and took 2 minutes.
#Access denied while accessing Auto Scaling and Elastic Load Balancing using
#role "arn:aws:iam::008129123253:role/api-development-service-role".
# Verify the role policy. ELB health is failing or not available for all instances.

resource "aws_elastic_beanstalk_application" "eb-api-application" {
  name        = "nowcasting-${var.environment}"
  description = "Nowcasting API"
}

resource "aws_elastic_beanstalk_environment" "eb-api-env" {
  name                = "nowcasting-api-${var.environment}"
  application         = aws_elastic_beanstalk_application.eb-api-application.name

  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name = "InstanceType"
    value = "t3.small"
  }

  # the next line IS NOT RANDOM, see "final notes" at the bottom
  solution_stack_name = "64bit Amazon Linux 2 v3.4.10 running Docker"

  # There are a LOT of settings, see here for the basic list:
  # https://is.gd/vfB51g
  # This should be the minimally required set for Docker.

  setting {
    namespace = "aws:ec2:vpc"
    name      = "VPCId"
    value     = "${var.vpc_id}"
  }
  setting {
    namespace = "aws:ec2:vpc"
    name      = "Subnets"
#    value     = "${join(",", var.subnets)}"
#    value     = var.subnets
    value = var.subnets[0].id
  }
  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "IamInstanceProfile"
    value     = "aws-elasticbeanstalk-ec2-role"
  }
  setting {
    namespace = "aws:elasticbeanstalk:environment"
    name      = "ServiceRole"
    value     = aws_iam_role.api-service-role.arn
  }

  setting {
    namespace = "aws:autoscaling:asg"
    name = "MinSize"
    value = "1"
  }
  setting {
    namespace = "aws:autoscaling:asg"
    name = "MaxSize"
    value = "1"
  }

  provisioner "local-exec" {
    command = "./deploy.sh"
  }



}

resource "aws_elastic_beanstalk_application_version" "latest" {
  name        = "latest-nowcasting-api"
  application = aws_elastic_beanstalk_application.eb-api-application.name
  description = "application version created by terraform"
  bucket      = aws_s3_bucket.eb.id
  key         = aws_s3_bucket_object.eb-object.id
}