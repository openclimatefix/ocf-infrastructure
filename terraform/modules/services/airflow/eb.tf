# Creates various objects to do with elastic beanstalk (EB)
# 1. EB Application
# 2. EB Environment
# 3. EB application version
# 4. Application version gets deployed to environment using docker compose file


resource "aws_elastic_beanstalk_application" "eb-api-application" {
  name        = "${var.aws-domain}-${var.aws-environment}-airflow"
  description = "OCF Airflow"

  tags = {
    name = "airflow"
    type = "eb"
  }
}

resource "aws_elastic_beanstalk_environment" "eb-api-env" {
  name        = "${var.aws-domain}-${var.aws-environment}-airflow"
  application = aws_elastic_beanstalk_application.eb-api-application.name
  cname_prefix = "${var.aws-domain}-${var.aws-environment}-airflow"
  version_label = "${var.aws-domain}-${var.aws-environment}-airflow-${var.docker-compose-version}"

  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "InstanceType"
    value     = "t4g.large"
    resource  = ""
  }

  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name = "RootVolumeType"
    value = "gp3"
    resource  = ""
  }

  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name = "RootVolumeSize"
    value = "32"
    resource  = ""
  }

  # the next line IS NOT RANDOM,
  # see https://docs.aws.amazon.com/elasticbeanstalk/latest/dg/concepts.platforms.html
  solution_stack_name = "64bit Amazon Linux 2 v3.8.0 running Docker"

  # There are a LOT of settings, see here for the basic list:
  # https://is.gd/vfB51g
  # This should be the minimally required set for Docker.

  # use dynamic over all the container environment variables
  dynamic "setting" {
      for_each = var.container-env_vars
      content {
          namespace = "aws:elasticbeanstalk:application:environment"
          name      = "${setting.value["name"]}"
          value     = "${setting.value["value"]}"
          resource  = ""
      }
  }

  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "SECRET_KEY"
    value     = random_password.secret-password.result
    resource  = ""
  }

  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "FERNET_KEY"
    value     = "VFCFMh8gFtPkYNFJXQLjAloeILFyGvgqebnQNtnEbNQ="
    resource  = ""
  }

  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "PASSWORD"
    value     = random_password.airflow-password.result
    resource  = ""
  }

  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "BUCKET"
    value     = aws_s3_bucket.airflow-s3.id
    resource  = ""
  }

  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "AWS_OWNER_ID"
    value     = var.aws-owner_id
    resource  = ""
  }

  setting {
    namespace = "aws:ec2:vpc"
    name      = "VPCId"
    value     = var.aws-vpc_id
    resource  = ""
  }
  setting {
    namespace = "aws:ec2:vpc"
    name      = "Subnets"
    value    = var.aws-subnet_id
    resource = ""
  }
  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "SecurityGroups"
    value     = aws_security_group.api-sg.id
    resource  = ""
  }
  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "IamInstanceProfile"
    value     = aws_iam_instance_profile.ec2.name
    resource  = ""
  }
  setting {
    namespace = "aws:elasticbeanstalk:environment"
    name      = "ServiceRole"
    value     = aws_iam_role.api-service-role.arn
    resource  = ""
  }

  setting {
    namespace = "aws:autoscaling:asg"
    name      = "MinSize"
    value     = "1"
    resource  = ""
  }
  setting {
    namespace = "aws:autoscaling:asg"
    name      = "MaxSize"
    value     = "1"
    resource  = ""
  }

  ### =========================== Logging ========================== ###

  setting {
    namespace = "aws:elasticbeanstalk:cloudwatch:logs"
    name      = "StreamLogs"
    value     = "true"
    resource  = ""
  }

  setting {
    namespace = "aws:elasticbeanstalk:cloudwatch:logs"
    name      = "DeleteOnTerminate"
    value     = "false"
    resource  = ""
  }

  setting {
    namespace = "aws:elasticbeanstalk:cloudwatch:logs"
    name      = "RetentionInDays"
    value     = "7"
    resource  = ""
  }

  setting {
    namespace = "aws:elasticbeanstalk:cloudwatch:logs:health"
    name      = "HealthStreamingEnabled"
    value     = "true"
    resource  = ""
  }

  setting {
    namespace = "aws:elasticbeanstalk:cloudwatch:logs:health"
    name      = "DeleteOnTerminate"
    value     = "false"
    resource  = ""
  }

  setting {
    namespace = "aws:elasticbeanstalk:cloudwatch:logs:health"
    name      = "RetentionInDays"
    value     = "7"
    resource  = ""
  }

    # make sure that when the application is made, the latest version is deployed to it
    # TODO, doesnt seem to work at the moment
  provisioner "local-exec" {
    command = join("", ["aws elasticbeanstalk update-environment ",
      "--region ${var.aws-region} ",
      "--application-name ${aws_elastic_beanstalk_application.eb-api-application.name} ",
      "--version-label ${aws_elastic_beanstalk_application_version.latest.name} ",
      "--environment-name ${aws_elastic_beanstalk_environment.eb-api-env.name}"
    ])
  }

}

resource "aws_elastic_beanstalk_application_version" "latest" {
  name        = "${var.aws-domain}-${var.aws-environment}-airflow-${var.docker-compose-version}"
  application = aws_elastic_beanstalk_application.eb-api-application.name
  description = "application version created by terraform (${var.docker-compose-version})"
  bucket      = aws_s3_bucket.airflow-s3.id
  key         = aws_s3_object.eb_object.id
}
