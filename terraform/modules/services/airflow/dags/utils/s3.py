from airflow.providers.amazon.aws.hooks.s3 import S3Hook
from airflow.decorators import task

import xarray as xr

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
    if size_old != size_new and size_new > 500 * 1e3:  # Expecting at least 500KB

        # open file
        s3hook.log.info(f"Opening {zarrs[0]}")
        ds = xr.open_zarr(f"s3://{bucket}/{prefix}/{zarrs[0]}")

        # re-chunk
        s3hook.log.info("Re-chunking")
        ds = ds.chunk({"init_time": 1,
                       "step": len(ds.step) // 4,
                       "variable": len(ds.variable),
                       "latitude": len(ds.latitude) // 2,
                       "longitude": len(ds.longitude) // 2})

        # save to latest_temp.zarr
        s3hook.log.info(f"Saving {prefix}/latest_temp.zarr/")
        ds.to_zarr(f"s3://{bucket}/{prefix}/latest_temp.zarr/", mode="w")

        # delete latest.zarr
        s3hook.log.info(f"Deleting {prefix}/latest.zarr/")
        if prefix + "/latest.zarr/" in prefixes:
            s3hook.log.debug(f"Deleting {prefix}/latest.zarr/")
            keys_to_delete = s3hook.list_keys(bucket_name=bucket, prefix=prefix + "/latest.zarr/")
            s3hook.delete_objects(bucket=bucket, keys=keys_to_delete)

        # move latest_temp.zarr to latest.zarr
        s3hook.log.info(f"Move {prefix}/latest_temp.zarr/ to {prefix}/latest.zarr/")
        keys_to_move = s3hook.list_keys(bucket_name=bucket, prefix=prefix + "/latest_temp.zarr/")
        for key in keys_to_move:
            s3hook.copy_object(
                source_bucket_name=bucket,
                source_bucket_key=key,
                dest_bucket_name=bucket,
                dest_bucket_key=prefix + "/latest.zarr/" + key.split(prefix + "/latest_temp.zarr/")[-1],
            )
        s3hook.delete_objects(bucket=bucket, keys=keys_to_move)

    else:
        s3hook.log.info("No changes to latest.zarr required")

