#!/bin/bash
#
#
# Shell script to automatically deploy the index-style to the given S3 Bucket
# specified in the SDS config
# 
# @author mcayanan
#

# source yaml parser
source ./yaml.sh


echoerr() { echo "$@" 1>&2; }


function check_error {
  STATUS=$?
  if [ $STATUS -ne 0 ]; then
    echo "Failed to run $1." 1>&2
    exit $STATUS
  fi
}


# source sds config
SDS_CFG=$HOME/.sds/config
if [ ! -e "$SDS_CFG" ]; then
  echoerr "Failed to find SDS configuration at $SDS_CFG. Run 'sds configure'."
  exit 1
fi
create_variables $SDS_CFG


S3_BUCKET_LISTING_HOME=/home/ops/mozart/ops/s3-bucket-listing

# Modify the BUCKET_URL variable in the index.html to the BUCKET_URL specified in the SDS config
sed -i -E 's/(\s*var\sBUCKET_URL\s=\s*)(.*)/\1\"http:\/\/'"${DATASET_BUCKET}"'.'"${DATASET_S3_ENDPOINT}"'\"/g' ${S3_BUCKET_LISTING_HOME}/index.html


aws s3 cp $S3_BUCKET_LISTING_HOME/index.html s3://${DATASET_BUCKET}/
aws s3 cp $S3_BUCKET_LISTING_HOME/list.js s3://${DATASET_BUCKET}/
aws s3 cp $S3_BUCKET_LISTING_HOME/index-style s3://${DATASET_BUCKET}/index-style --recursive
