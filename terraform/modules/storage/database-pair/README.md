# Modules/Database

This module makes
- 1x [RDS](https://eu-west-2.console.aws.amazon.com/rds/home) postgres database
- 1x Secret to store database access credentials
- 1x IAM to read secret

## !! Deprecation Warning

This demonstrates an inefficient way of designing modules, however moving over the pre-existing nowcasting domain to
the more generic `postgres` was not feasible as it would require tearing down the nowcasting database.
It's use it not advised, instead use the `postgres` module.

2024-01-04: We have removed teh PV database, so this module just makes on database
