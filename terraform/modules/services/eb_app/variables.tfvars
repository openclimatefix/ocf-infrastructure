s3_nwp_buckets = [
  "arn:aws:s3:::satellite-bucket-1",
  "arn:aws:s3:::satellite-bucket-2",
  # More ARNs can be added as needed
]

## Command to apply the buckets
#  terraform apply -var-file="variables.tfvars"

## Optionally, if you don't want an additional file, use the following command
# terraform apply -var="s3_nwp_buckets=[\"arn:aws:s3:::satellite-bucket-1\", \"arn:aws:s3:::satellite-bucket-2\"]"
