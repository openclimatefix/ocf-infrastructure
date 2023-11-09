# Modules/Services/nwp_consumer

This module makes
- AWS ECS Task Definition, with:
  - S3 and SecretsManager access
  - AWS CloudWatch Logs group
- IAM role to create the ECS Task
- IAM role to run the ECS Task
