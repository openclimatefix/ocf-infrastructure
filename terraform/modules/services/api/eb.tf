# Creates various objects to do with elastic beanstalk (EB)
# 1. EB Application
# 2. EB Environment
# 3. EB application version
# 4. Application version gets deployed to environment using docker compose file


resource "aws_elastic_beanstalk_application" "eb-api-application" {
  name        = "nowcasting-${var.environment}"
  description = "Nowcasting API"

  tags = {
    name = "nowcasting-api"
    type = "eb"
  }
}

resource "aws_elastic_beanstalk_environment" "eb-api-env" {
  name        = "nowcasting-api-${var.environment}"
  application = aws_elastic_beanstalk_application.eb-api-application.name
  cname_prefix = "nowcasting-api-${var.environment}"
  version_label = "nowcasting-api-${var.docker_version}"

  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "InstanceType"
    value     = "t3.medium"
  }

  # the next line IS NOT RANDOM,
#  see https://docs.aws.amazon.com/elasticbeanstalk/latest/dg/concepts.platforms.html
  solution_stack_name = "64bit Amazon Linux 2 v3.4.16 running Docker"

  # There are a LOT of settings, see here for the basic list:
  # https://is.gd/vfB51g
  # This should be the minimally required set for Docker.

  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "DB_URL"
    value     = var.database_forecast_secret_url
  }

  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "DB_URL_PV"
    value     = var.database_pv_secret_url
  }

  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "AUTH0_DOMAIN"
    value     = var.auth_domain
  }

  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "AUTH0_API_AUDIENCE"
    value     = var.auth_api_audience
  }

  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "AUTH0_RULE_NAMESPACE"
    value     = "https://openclimatefix.org"
  }

  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "ORIGINS"
    value     = "*" #TODO change
  }

  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "N_HISTORY_DAYS"
    value     = var.n_history_days
  }

    setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "ADJUST_MW_LIMIT"
    value     = var.adjust_limit
  }

  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "SENTRY_DSN"
    value     = var.sentry_dsn
  }

  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "ENVIRONMENT"
    value     = var.environment
  }

  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "API_VERSION"
    value     = var.docker_version
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
    value    = var.subnet_id
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
  name        = "nowcasting-api-${var.docker_version}"
  application = aws_elastic_beanstalk_application.eb-api-application.name
  description = "application version created by terraform (${var.docker_version})"
  bucket      = aws_s3_bucket.eb.id
  key         = aws_s3_object.eb_object.id
}
