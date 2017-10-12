#!/bin/bash
#
#
# Shell script to automatically deploy the index-style to the given S3 Bucket
# specified in the context.sh
# 
# @author mcayanan
#

source ./context.sh

S3_BUCKET_LISTING_HOME=/home/ops/mozart/ops/s3-bucket-listing

# Modify the BUCKET_URL variable in the index.html to the BUCKET_URL specified in the context.sh
sed -i -E 's/(\s*var\sBUCKET_URL\s=\s*)(.*)/\1\"http:\/\/'"${DATASET_BUCKET}"'.'"${DATASET_S3_ENDPOINT}"'\"/g' ${S3_BUCKET_LISTING_HOME}/index.html


aws s3 cp $S3_BUCKET_LISTING_HOME/index.html s3://${DATASET_BUCKET}/
aws s3 cp $S3_BUCKET_LISTING_HOME/list.js s3://${DATASET_BUCKET}/
aws s3 cp $S3_BUCKET_LISTING_HOME/index-style s3://${DATASET_BUCKET}/index-style --recursive
