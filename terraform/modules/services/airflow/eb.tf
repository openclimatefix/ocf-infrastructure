# Creates various objects to do with elastic beanstalk (EB)
# 1. EB Application
# 2. EB Environment
# 3. EB application version
# 4. Application version gets deployed to environment using docker compose file


resource "aws_elastic_beanstalk_application" "eb-api-application" {
  name        = "ocf-airflow-${var.environment}"
  description = "OCF Airflow"

  tags = {
    name = "airflow"
    type = "eb"
  }
}

resource "aws_elastic_beanstalk_environment" "eb-api-env" {
  name        = "ocf-airflow-${var.environment}"
  application = aws_elastic_beanstalk_application.eb-api-application.name
  cname_prefix = "ocf-airflow-${var.environment}"
  version_label = "ocf-airflow-${var.docker-compose-version}-v1"

  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "InstanceType"
    value     = "t4g.large"
  }

  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name = "RootVolumeType"
    value = "gp3"
  }

  settings {
    namespace = "aws:autoscaling:launchconfiguration"
    name = "RootVolumeSize"
    value = "16"
  }

  # the next line IS NOT RANDOM,
  # see https://docs.aws.amazon.com/elasticbeanstalk/latest/dg/concepts.platforms.html
  solution_stack_name = "64bit Amazon Linux 2 v3.6.0 running Docker"

  # There are a LOT of settings, see here for the basic list:
  # https://is.gd/vfB51g
  # This should be the minimally required set for Docker.

  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "DB_URL"
    value     = var.db_url
  }

  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "AIRFLOW_UID"
    value     = "50000"
  }

  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "AWS_DEFAULT_REGION"
    value     = var.region
  }

  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "SECRET_KEY"
    value     = random_password.secret-password.result
  }

  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "FERNET_KEY"
    value     = "VFCFMh8gFtPkYNFJXQLjAloeILFyGvgqebnQNtnEbNQ="
  }

  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "PASSWORD"
    value     = random_password.airflow-password.result
  }

  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "ENVIRONMENT"
    value     = var.environment
  }

  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "ECS_SUBNET"
    value     = var.ecs_subnet
  }

  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "ECS_SECURITY_GROUP"
    value     = var.ecs_security_group
  }

  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "LOGLEVEL"
    value     = "INFO"
  }

  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "DB_URL"
    value     = var.db_url
  }

  setting {
    namespace = "aws:ec2:vpc"
    name      = "VPCId"
    value     = var.vpc_id
  }
  setting {
    namespace = "aws:ec2:vpc"
    name      = "Subnets"
    #    value     = "${join(",", var.subnets)}"
    #    value     = var.subnets
    value    = var.subnets[0]
    resource = ""
  }
  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "SecurityGroups"
    value     = aws_security_group.api-sg.id
  }
  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "IamInstanceProfile"
    value     = aws_iam_instance_profile.ec2.arn
  }
  setting {
    namespace = "aws:elasticbeanstalk:environment"
    name      = "ServiceRole"
    value     = aws_iam_role.api-service-role.arn
  }

  setting {
    namespace = "aws:autoscaling:asg"
    name      = "MinSize"
    value     = "1"
  }
  setting {
    namespace = "aws:autoscaling:asg"
    name      = "MaxSize"
    value     = "1"
  }

  ###=========================== Logging ========================== ###

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
      "--region ${var.region} ",
      "--application-name ${aws_elastic_beanstalk_application.eb-api-application.name} ",
      "--version-label ${aws_elastic_beanstalk_application_version.latest.name} ",
      "--environment-name ${aws_elastic_beanstalk_environment.eb-api-env.name}"
    ])
  }

}

resource "aws_elastic_beanstalk_application_version" "latest" {
  name        = "ocf-airflow-${var.docker-compose-version}-v1"
  application = aws_elastic_beanstalk_application.eb-api-application.name
  description = "application version created by terraform"
  bucket      = aws_s3_bucket.airflow-s3.id
  key         = aws_s3_object.eb_object.id
}
