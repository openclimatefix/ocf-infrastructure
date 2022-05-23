# Creates various objects to do with elastic beanstalk (EB)
# 1. EB Application
# 2. EB Environment
# 3. EB application version
# 4. Application version gets deployed to environment using docker compose file


resource "aws_elastic_beanstalk_application" "eb-data_visualization-application" {
  name        = "nowcasting-data-visualization-${var.environment}"
  description = "Nowcasting data_visualization"
}

resource "aws_elastic_beanstalk_environment" "eb-data_visualization-env" {
  name        = "nowcasting-data-visual-${var.environment}"
  application = aws_elastic_beanstalk_application.eb-data_visualization-application.name
  cname_prefix = "nowcasting-data-visualization-${var.environment}"
  version_label = "nowcasting-data-visualization-${var.docker_version}"

  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "InstanceType"
    value     = "t4g.small"
  }

  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "RootVolumeSize"
    value     = "22"
  }

  # the next line IS NOT RANDOM,
#  see https://docs.aws.amazon.com/elasticbeanstalk/latest/dg/concepts.platforms.html
  solution_stack_name = "64bit Amazon Linux 2 v3.4.15 running Docker"

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
    name      = "API_URL"
    value     = "http://${var.api_url}"
  }

  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "DATA_VISUALIZATION_VERSION"
    value     = var.docker_version
  }

  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "NWP_AWS_FILENAME"
    value     = "s3://nowcasting-nwp-development/data/latest.netcdf"
  }

  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "SATELLITE_AWS_FILENAME"
    value     = "s3://nowcasting-sat-development/data/latest/latest.zarr.zip"
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
    value    = var.subnets[0].id
    resource = ""
  }
  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "SecurityGroups"
    value     = aws_security_group.data_visualization-sg_data_visualization.id
  }
  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "IamInstanceProfile"
    value     = aws_iam_instance_profile.ec2_data_visualization.arn
  }
  setting {
    namespace = "aws:elasticbeanstalk:environment"
    name      = "ServiceRole"
    value     = aws_iam_role.data_visualization-service-role.arn
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
    value     = "30"
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
    value     = "30"
    resource  = ""
  }

    # make sure that when the application is made, the latest version is deployed to it
  provisioner "local-exec" {
    command = join("", ["aws elasticbeanstalk update-environment ",
      "--region ${var.region} ",
      "--application-name ${aws_elastic_beanstalk_application.eb-data_visualization-application.name} ",
      "--version-label ${aws_elastic_beanstalk_application_version.latest.name} ",
      "--environment-name ${aws_elastic_beanstalk_environment.eb-data_visualization-env.name}"
    ])
  }

}

resource "aws_elastic_beanstalk_application_version" "latest" {
  name        = "nowcasting-data-visualization-${var.docker_version}"
  application = aws_elastic_beanstalk_application.eb-data_visualization-application.name
  description = "application version created by terraform (${var.docker_version})"
  bucket      = aws_s3_bucket.eb_data_visualization.id
  key         = aws_s3_bucket_object.eb-object_data_visualization.id

}
