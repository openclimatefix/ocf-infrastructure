# Creates various objects to do with elastic beanstalk (EB)
# 1. EB Application
# 2. EB Environment
# 3. EB application version
# 4. Application version gets deployed to environment using docker compose file


# Create the EB Application itself
resource "aws_elastic_beanstalk_application" "eb-app" {
  name        = "${var.domain}-${var.environment}-${var.eb_app_name}"
  description = "Beanstalk API"

  tags = {
    name = "internal-ui"
    type = "eb"
  }
}

# Create the EB Environment
resource "aws_elastic_beanstalk_environment" "eb-env" {
  name        = "${var.domain}-${var.environment}-${var.eb_app_name}"
  application = aws_elastic_beanstalk_application.eb-app.name
  cname_prefix = "${var.domain}-${var.environment}-${var.eb_app_name}"
  version_label = "${var.domain}-${var.environment}-${var.eb_app_name}-${var.docker_config.version}"

  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "InstanceType"
    value     = "t3.small"
  }

  # the next line IS NOT RANDOM,
  #  see https://docs.aws.amazon.com/elasticbeanstalk/latest/dg/concepts.platforms.html
  solution_stack_name = "64bit Amazon Linux 2 v3.5.4 running Docker"

  # There are a LOT of settings, see here for the basic list:
  # https://is.gd/vfB51g
  # This should be the minimally required set for Docker.

  # ======== Env Vars ========= #

  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "DB_URL"
    value     = var.database_config.secret
  }

  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "SITES_DB_URL"
    value     = jsondecode(data.aws_secretsmanager_secret_version.database-sites-version.secret_string)["url"]
  }

  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "ORIGINS"
    value     = "*" #TODO change
  }

  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "DOCKER_IMAGE"
    value     = var.docker_config.image
  }

  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "DOCKER_IMAGE_VERSION"
    value     = var.docker_config.version
  }

  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "EB_APP_NAME"
    value     = var.eb_app_name
  }

  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "ENVIRONMENT"
    value     = var.environment
  }

  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "AUTH0_CLIENT_ID"
    value     = var.auth_config.auth0_client_id
  }

  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "AUTH0_DOMAIN"
    value     = var.auth_config.auth0_domain
  }

  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "SHOW_PVNET_GSP_SUM"
    value     = var.show_pvnet_gsp_sum
  }

  # =========== EB Settings =========== #

  setting {
    namespace = "aws:ec2:vpc"
    name      = "VPCId"
    value     = var.networking_config.vpc_id
  }

  setting {
    namespace = "aws:ec2:vpc"
    name      = "Subnets"
    #    value     = "${join(",", var.subnets)}"
    #    value     = var.subnets
    value    = var.networking_config.subnets[0]
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

  # Following https://discuss.streamlit.io/t/howto-streamlit-on-aws-with-elastic-beanstalk-and-docker/10353
  setting {
    namespace = "aws:elb:listener"
    name      = "ListenerProtocol"
    value     = "TCP"
  }

  # ============ Logging ============ #

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
      "--application-name ${aws_elastic_beanstalk_application.eb-app.name} ",
      "--version-label ${aws_elastic_beanstalk_application_version.latest.name} ",
      "--environment-name ${aws_elastic_beanstalk_environment.eb-env.name}"
    ])
  }

}

# Create the EB Application Version
resource "aws_elastic_beanstalk_application_version" "latest" {
  name        = "${var.domain}-${var.environment}-${var.eb_app_name}-${var.docker_config.version}"
  application = aws_elastic_beanstalk_application.eb-app.name
  description = "application version created by terraform (${var.docker_config.version})"
  bucket      = aws_s3_bucket.eb.id
  key         = aws_s3_object.eb-object.id
}
