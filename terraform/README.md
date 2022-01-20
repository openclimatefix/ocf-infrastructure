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
