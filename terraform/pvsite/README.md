# PVSite Infrastructure

Contains all the infrastructure as code for the pvsite domain.

## Folder structure

The subfolders specify the two environments for the nowcasting domain:

```yaml
pvsite:
  development: # This is for development purposes, eg trying new things out. It is not meant to be up 100% of the time.
  production: # The production environment
```

## Nowcasting Environment Architecture

TODO - diagram

## Using Terraform

To setup the project:

```bash
$ cd terraform/pvsite/development
$ terraform init
```

To push changes:

```bash
$ terraform plan
$ terraform apply
```

You can then destroy the stack:

```bash
$ terraform destroy
```

## Check List

- [ ] Is there a [VPC](https://eu-west-1.console.aws.amazon.com/vpc/home?region=eu-west-1#vpcs:)?
- [ ] Has the [RDS](https://eu-west-1.console.aws.amazon.com/rds/home?region=eu-west-1#) database started up?
- [ ] Has the API [Elastic Beanstalk ](https://eu-west-1.console.aws.amazon.com/elasticbeanstalk/home?region=eu-west-1#/environments) service started?
- [ ] Is there an [ECS](https://eu-west-1.console.aws.amazon.com/ecs/home?region=eu-west-1#/clusters) cluster?
- [ ] Is there an [S3](https://s3.console.aws.amazon.com/s3/home?region=eu-west-2) bucket for the NWPs, i.e `nowcasting-nwp-development`
- [ ] After 5 minutes: Did the forecast task run ok? Check in [cloudwatch](https://eu-west-1.console.aws.amazon.com/cloudwatch/home?region=eu-west-1#logsV2:log-groups/)
      or in database insights in [RDS](https://eu-west-1.console.aws.amazon.com/rds/home?region=eu-west-1#)
