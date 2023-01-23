# Modules/Database

This module makes
- 2x [RDS](https://eu-west-2.console.aws.amazon.com/rds/home) postgres database
- 2x Secret to store database access credentials
- 2x IAM to read secret

One for forecast db and one for pv db.

## !! Deprecation Warning

This demonstrates an inefficient way of designing modules, however moving over the pre-existing nowcasting domain to
the more generic `postgres` was not feasible as it would require tearing down the nowcasting database.
It's use it not advised, instead use the `postgres` module.
