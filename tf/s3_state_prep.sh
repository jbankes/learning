#!/bin/bash
# This script prepares the state for the S3 state backend.

# Get name and region from user
read -p "Enter a prefix for the S3 bucket to store Terraform state: " TF_PREFIX
read -p "Enter the AWS region to create the resources in [us-west-2]: " REGION
REGION=${REGION:-us-west-2}

# check for aws s3 bucket and create if not there 
if aws s3api head-bucket --bucket "$TF_PREFIX-terraform-states" 2>/dev/null; then
  echo "Bucket exists"
else
  aws s3api create-bucket \
    --bucket "$TF_PREFIX-terraform-states" \
    --create-bucket-configuration LocationConstraint=$REGION \
    --region $REGION \
    --no-cli-pager

  aws s3api put-bucket-versioning \
    --bucket "$TF_PREFIX-terraform-states" \
    --versioning-configuration Status=Enabled

  echo "$TF_PREFIX-terraform-states bucket created and versioning enabled"
  
  # replace BUCKET-PREFIX in main.tf with $TF_PREFIX
  sed -i "s/BUCKET-PREFIX/$TF_PREFIX/g" main.tf
  echo "main.tf bucket in backend block updated with $TF_PREFIX"
fi

# check for dynamodb table and create if not there
if aws dynamodb describe-table --table-name "$TF_PREFIX-terraform-locks" 2>/dev/null; then
  echo "Table exists"
else
  aws dynamodb create-table \
    --table-name "$TF_PREFIX-terraform-locks" \
    --attribute-definitions AttributeName=LockID,AttributeType=S \
    --key-schema AttributeName=LockID,KeyType=HASH \
    --provisioned-throughput ReadCapacityUnits=1,WriteCapacityUnits=1 \
    --region $REGION \
    --no-cli-pager

   echo "$TF_PREFIX-terraform-locks table created" 

  # replace DBTABLE-PREFIX in main.tf with $TF_PREFIX
  sed -i "s/DBTABLE-PREFIX/$TF_PREFIX/g" main.tf
  echo "main.tf dynamodb_table in backend block updated with $TF_PREFIX"
fi
