# tf experimenets directory

## Directories

* [ec2_root_encryption](./ec2_root_encryption/README.md)
* [s3_state_experiment](./s3_state_experiment/README.md)

## s3_state_prep.sh

This file will create a new dynamodb table and s3 bucket to store state for the various experiments. It writes a new
`main.tf` file in this directory that can be moved to a new experiment directory.

## TODO

* [ ] Create s3_state_cleanup.sh to remove existing state files/tables
