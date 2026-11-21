#!/bin/bash
set -euo pipefail

BUCKET="YOUR-S3-BUCKET-NAME"
LOG_FILE="/var/log/backup.log"
TIMESTAMP=$(date +"%Y-%m-%d-%H%M")
ARCHIVE_NAME="backup-${TIMESTAMP}.tar.gz"
TMP_ARCHIVE="/tmp/${ARCHIVE_NAME}"

log_msg() {
    echo "$(date -u +"%Y-%m-%d %H:%M:%S UTC") - $1" >> "${LOG_FILE}"
}

trap 'log_msg "ERROR: Backup failed for ${ARCHIVE_NAME}"; rm -f "${TMP_ARCHIVE}"' ERR

/usr/bin/tar -czf "${TMP_ARCHIVE}" -C / var/app/data
/usr/local/bin/aws s3 cp "${TMP_ARCHIVE}" "s3://${BUCKET}/backups/${ARCHIVE_NAME}" --region eu-north-1
log_msg "SUCCESS: Uploaded ${ARCHIVE_NAME} to s3://${BUCKET}/backups/${ARCHIVE_NAME}"
rm -f "${TMP_ARCHIVE}"
