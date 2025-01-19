import boto3
import json
import logging
import os


# Setup the logger
logger = logging.getLogger()
logger.setLevel(logging.INFO)


def handler(event, context):
    s3 = boto3.client("s3")
    bucket_name = os.environ.get("REPORTS_BUCKET_NAME", "reports_bucket")
    folder_name = "reports/"

    # List objects in the folder
    response = s3.list_objects_v2(Bucket=bucket_name, Prefix=folder_name)
    files = [
        obj["Key"] for obj in response.get("Contents", []) if obj["Key"] != folder_name
    ]

    # Generate file list JSON
    file_list = {"files": files}

    # Upload JSON file back to S3
    s3.put_object(
        Bucket=bucket_name,
        Key=f"{folder_name}file-list.json",
        Body=json.dumps(file_list),
        ContentType="application/json",
    )
    logger.info(f"Updated file list: {file_list}")
    return {"statusCode": 200, "body": json.dumps(file_list)}
