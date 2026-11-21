# Automated Private S3 Backup & Serverless Audit Pipeline on AWS

An end-to-end, zero-NAT cloud backup architecture built on AWS. A private EC2 application server with no public IP automatically archives application logs, uploads them privately to Amazon S3 via a VPC Gateway Endpoint using append-only IAM permissions (`s3:PutObject`), and triggers an event-driven AWS Lambda + DynamoDB audit trail.

## Architecture Overview

- **VPC (`10.0.0.0/16`):** Public subnet (Bastion Host) and Private subnet (Private App Server with no public IP).
- **S3 Gateway VPC Endpoint:** Routes S3 traffic privately over the AWS backbone without ongoing NAT Gateway costs.
- **Least-Privilege IAM:**
  - EC2 Instance Role allows only `s3:PutObject` on `backups/*` (`s3:DeleteObject` is denied).
  - Lambda Execution Role allows only `dynamodb:PutItem` on the `backup-log` table (plus CloudWatch Logs).
- **Linux Automation (`systemd` + `bash` + `cron`):** Continuous log generation via `data-generator.service` and scheduled `.tar.gz` archival/upload every 10 minutes via `backup.sh`.
- **Serverless Audit Trail:** S3 `PUT` events trigger a Python Lambda function to record backup metadata (`backup_id`, `size_bytes`, `uploaded_at`, `bucket`) in DynamoDB.

## Deployment Summary

1. **Networking:** Provisioned VPC, subnets, Internet Gateway, route tables, a temporary NAT Gateway for AWS CLI v2 installation, and an S3 Gateway VPC Endpoint attached to the private route table (followed by immediate NAT Gateway deletion).
2. **Storage & IAM:** Created a private S3 bucket (Block Public Access enabled) and attached the `s3:PutObject`-only role to the private EC2 instance.
3. **Serverless Audit:** Created an on-demand DynamoDB table (`backup-log`, partition key `backup_id`) and configured the Python Lambda function with an S3 `PUT` trigger on `backups/`.
4. **Linux Services:** Configured `data-generator.service` under `/etc/systemd/system/`, placed `backup.sh` in `/usr/local/bin/`, and scheduled `*/10 * * * * /usr/local/bin/backup.sh` in root's `crontab`.

## Verification Highlights

- **Append-Only Enforcement:** `aws s3 cp` succeeds while `aws s3 rm` returns `AccessDenied`.
- **Zero-NAT Private Routing:** Outbound internet requests (`curl -m 5 https://example.com`) time out after NAT deletion while S3 uploads continue working via the VPC Endpoint.
- **Automated Audit Trail:** Every scheduled backup automatically creates a matching metadata item in DynamoDB.

## Author

- **Adewumi** — [Read the full write-up on Medium]([YOUR-MEDIUM-ARTICLE-LINK](https://medium.com/@adebayoadewumi_45437/build-with-me-a-tamper-proof-zero-nat-automated-backup-serverless-audit-pipeline-on-aws-a49125ed8541))
