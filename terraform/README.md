# Nowcasting Infrastructure

## Modules

This folder contains all the terraform code for the different modules.
The different environments will run off these modules.

## Environments

- Unittest: This environment is only used for unittesting
- Development: This is for development.
This trying new things out, and is not meant to be up 100% of the time.


## Using terraform

To setup the project:
```bash
terraform init
```
To push changes:
```bash
terraform plan
terram apply
```

You can then destroy the stack:
```bash
terraform destroy
```

## Check List

- Is there a [VPC](https://eu-west-1.console.aws.amazon.com/vpc/home?region=eu-west-1#vpcs:)?
- Has the [RDS](https://eu-west-1.console.aws.amazon.com/rds/home?region=eu-west-1#) database started up? 
- Has the API [Elastic Beanstalk ](https://eu-west-1.console.aws.amazon.com/elasticbeanstalk/home?region=eu-west-1#/environments) service started? 
- Is there an [ECS](https://eu-west-1.console.aws.amazon.com/ecs/home?region=eu-west-1#/clusters) cluster? 
- Is there an [S3](https://s3.console.aws.amazon.com/s3/home?region=eu-west-2) bucket for the NWPs, i.e 'nowcasting-nwp-development'


After 5 minutes
- Did the forecast task run ok? Check in [cloudwatch](https://eu-west-1.console.aws.amazon.com/cloudwatch/home?region=eu-west-1#logsV2:log-groups/) 
or in database insights in [RDS](https://eu-west-1.console.aws.amazon.com/rds/home?region=eu-west-1#)