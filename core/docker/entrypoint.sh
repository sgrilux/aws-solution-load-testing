#!/bin/bash

set -euxo pipefail

DATE=$(date +%Y-%m-%d-%H-%M)

source .env

REPORT_OUTPUT_FILE=${APPLICATION}/${ENVIRONMENT}/${DATE}.html

# Copy the script from S3 to the container
echo "Copying script from S3"
aws s3 cp s3://${ARTIFACTS_BUCKET}/${APPLICATION}/${ENVIRONMENT}/${K6_SCRIPT} /tmp/k6-script.js
aws s3 cp s3://${ARTIFACTS_BUCKET}/${APPLICATION}/${ENVIRONMENT}/${CONFIG_FILE} /tmp/

# Run K6 load testing
echo "Running K6 load testing"
/app/k6 --no-color run \
    --quiet \
    /tmp/k6-script.js \
    -e URL="${URL}" \
    -e CONFIG_FILE="${CONFIG_FILE}" \
    --out dashboard=export=/tmp/test-report.html

# Upload the test report to S3
echo "Uploading test report to S3"
aws s3 cp /tmp/test-report.html s3://${K6_REPORTS_BUCKET}/reports/${REPORT_OUTPUT_FILE}

# Publish the test report to SNS
if [ -n "${SNS_TOPIC}" ]; then
    aws sns publish --topic-arn "${SNS_TOPIC}" --message "K6 test report: https://${K6_REPORTS_BUCKET}/reports/${REPORT_OUTPUT_FILE}"
fi
