# Terraform Modules

This folder contains all the terraform modules for the project. The modules are
split into categories:

- `services` contains mostly single-use modules defining a specific service
  (e.g. an api or a consumer).
- `storage` contains modules for storage resources (e.g. s3 buckets and databases).
- `networking` contains modules for networking resources (e.g. vpc and subnets).

## Updating a module

Making a change to a module and merging it into main will trigger a new version to be
deployed in the development environment, since the modules are sourced using local relative
paths in any `development/main.tf` file.

To then propagate the update through to the production environment, you will need to
update the version of the module that is pinned by commit ref in the `production/main.tf`
file to match that of the PR for the initial module change. For example:


```shell
95d3758 Update README.md
f465e29 Update new-service-1 in production to module version ca67db4 (#303) <-- Deploys to prod, single-commit PR
ca67db4 Modify new-service-1 module in `/modules` (#302) <-- Deploys to Dev, squashed PR
792cfa7 Add new-service-1 to `production/main.tf` (#301) <-- Deploys to Prod, single-commit PR
4a53d90 Add new-service-1 to `development/main.tf` and create new-service-1 module to `/modules` (#300) <-- Deploys to Dev, squashed PR
367d936 ...
```

For more information, see the description for the PR implementing this workflow:
https://github.com/openclimatefix/ocf-infrastructure/pull/233
