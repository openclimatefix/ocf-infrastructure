from airflow.providers.amazon.aws.hooks.s3 import S3Hook
from airflow.decorators import task

@task(task_id="determine_latest_zarr")
def determine_latest_zarr(bucket: str, prefix: str):
    s3hook = S3Hook(aws_conn_id=None)  # Use Boto3 default connection strategy
    # Get a list of all the non-latest zarrs in the bucket prefix
    prefixes = s3hook.list_prefixes(bucket_name=bucket, prefix=prefix + "/", delimiter='/') 
    zarrs = sorted([
        p for p in prefixes if p.endswith('.zarr/') and "latest" not in p
    ], reverse=True)
    # Get the size of the most recent zarr and the latest.zarr zarr
    s3bucket = s3hook.get_bucket(bucket_name=bucket)
    size_old, size_new = (0, 0)
    if len(zarrs) == 0:
        s3hook.log.info("No non-latest zarrs found in bucket, exiting")
        return

    for obj in s3bucket.objects.filter(Prefix=zarrs[0]):
        size_new += obj.size

    if prefix + "/latest.zarr/" in prefixes:
        for obj in s3bucket.objects.filter(Prefix=prefix + "/latest.zarr/"):
            size_old += obj.size

    # If the sizes are different, create a new latest.zarr
    if size_old != size_new and size_new > 0:
        # Delete the old latest.zarr, if it exists
        if prefix + "/latest.zarr/" in prefixes:
            s3hook.log.debug(f"Deleting {prefix}/latest.zarr/")
            keys_to_delete = s3hook.list_keys(bucket_name=bucket, prefix=prefix + "/latest.zarr/")
            s3hook.delete_objects(bucket=bucket, keys=keys_to_delete)
        # Copy the new latest.zarr
        s3hook.log.info(f"Copying {zarrs[0]} to {prefix}/latest.zarr/")
        source_keys = s3hook.list_keys(bucket_name=bucket, prefix=zarrs[0])
        for key in source_keys:
            s3hook.copy_object(
                source_bucket_name=bucket,
                source_bucket_key=key,
                dest_bucket_name=bucket,
                dest_bucket_key=prefix + "/latest.zarr/" + key.split(zarrs[0])[-1],
            )

