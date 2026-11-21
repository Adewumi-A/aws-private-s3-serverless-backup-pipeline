import boto3
import urllib.parse

table = boto3.resource("dynamodb").Table("backup-log")

def lambda_handler(event, context):
    for rec in event["Records"]:
        key = urllib.parse.unquote_plus(rec["s3"]["object"]["key"])
        table.put_item(Item={
            "backup_id": key,
            "size_bytes": rec["s3"]["object"]["size"],
            "uploaded_at": rec["eventTime"],
            "bucket": rec["s3"]["bucket"]["name"],
        })
    return {"statusCode": 200}
