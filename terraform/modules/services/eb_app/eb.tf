# Creates various objects to do with elastic beanstalk (EB)
# 1. EB Application
# 2. EB Environment
# 3. EB application version
# 4. Application version gets deployed to environment using docker compose file


resource "aws_elastic_beanstalk_application" "eb-application" {
  name        = "${var.domain}-${var.aws-environment}-${var.eb-app_name}"
  description = "${var.eb-app_name} elastic beanstalk app"

  tags = {
    name = "${var.eb-app_name}"
    type = "eb"
  }
}

resource "aws_elastic_beanstalk_environment" "eb-environment" {
  name        = "${var.domain}-${var.aws-environment}-${var.eb-app_name}"
  application = aws_elastic_beanstalk_application.eb-application.name
  cname_prefix = "${var.domain}-${var.aws-environment}-${var.eb-app_name}"
  version_label = "${var.domain}-${var.aws-environment}-${var.eb-app_name}-${var.container-tag}"

  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "InstanceType"
    value     = var.eb-instance_type
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
        }
    }

  setting {
    namespace = "aws:ec2:vpc"
    name      = "VPCId"
    value     = var.aws-vpc_id
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
    value     = aws_security_group.sg.id
  }
  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "IamInstanceProfile"
    value     = aws_iam_instance_profile.ec2.name
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
    resource  = ""
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
      "--region ${var.aws-region} ",
      "--application-name ${aws_elastic_beanstalk_application.eb-application.name} ",
      "--version-label ${aws_elastic_beanstalk_application_version.latest.name} ",
      "--environment-name ${aws_elastic_beanstalk_environment.eb-environment.name}"
    ])
  }
}

resource "aws_elastic_beanstalk_application_version" "latest" {
  name        = "${var.domain}-${var.aws-environment}-${var.eb-app_name}-${var.container-tag}"
  application = aws_elastic_beanstalk_application.eb-application.name
  description = "Application version created by terraform (${var.container-tag})"
  bucket      = aws_s3_bucket.eb-app-docker-bucket.id
  key         = aws_s3_object.eb-object.id
}