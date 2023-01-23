# Module/S3

This module makes
- s3 bucket for NWP, Sat, and ML data
- IAM policy to read data for each bucket
- IAM policy to write data for each bucket
- Public access blocks on te NWP and Sat buckets
- Lifecycles on certain prefixes in the NWP and Sat buckets

## !! Deprecation Warning

This demonstrates an inefficient way of designing modules, however moving over the pre-existing nowcasting domain to
the more generic `s3-private` was not feasible as it would require tearing down the nowcasting buckets.
It's use it not advised, instead use the `s3-private` module.
