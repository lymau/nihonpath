#!/usr/bin/env bash
set -eo pipefail

echo "=========================================="
echo "Initializing NihonPath LocalStack S3..."
echo "=========================================="

REGION="${AWS_DEFAULT_REGION:-ap-southeast-3}"

# Create buckets for packs and audio assets
awslocal s3 mb s3://nihonpath-packs --region "$REGION" || true
awslocal s3 mb s3://nihonpath-audio --region "$REGION" || true

echo "Configured LocalStack S3 buckets:"
awslocal s3 ls

echo "LocalStack S3 initialization complete."
