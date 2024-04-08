# Modules/Services/ecs_task

Generic ECS task creator.

This module makes
- AWS ECS Task Definition, with configurable
  - Injected Env vars from AWS Secrets
- IAM role to run the ECS Task, with configurable
  - S3 read/write permissions

## Roles

ECS tasks require two roles, an *Execution Role* and a *Task Role*.

The *Execution Role*:
  - Pulls and stores OCI Images
  - Writes cloudwatch logs
  - Accesses AWS Secrets for injection into Environment Variables
The *Task Role*:
  - Runs the task itself
  - Is used for reading/writing from S3 during operation
 
This module assumes an ECS Cluster-wide *Execution Role* that can be passed in through variables.
It instantiates the *Task Role* with any required read/write policies for S3. 

## Secret Variables

In order to pass in sensitive environment variables to the ECS task runtime,
values can be injected from an AWS Secrets Manager secret.
For this, create a Secret with `key`s corresponding to the desired environment variable keys,
e.g.

```txt
EXAMPLE_API_KEY: ==ex43hf9i4nfewlkr9fjwalkjo34
EXAMPLE_API_SECRET: 34ofihruegfq43iorevfjsgbjworjiq3qrgtu
```

The secret ARN should then be passed into the ECS task through the relevant variable.
Now, these keys can be loaded as like-named env vars in the task through the secret vars variable.
