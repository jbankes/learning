# Steps to creating your VPC

## Requirements

* AWS CLI
* Terraform
* AWS Credentials
  * `AWS_ACCESS_KEY_ID`
  * `AWS_SECRET_ACCESS_KEY`

## Set Up the Environment and Terraform

### Make sure to get your Credentials set

Get these from AWS IAM and export them as:

```bash
export AWS_ACCESS_KEY_ID=<replace>
export AWS_SECRET_ACCESS_KEY=<replace>

# verify that you're hitting your account and aws is setup correctly
aws sts get-caller-identity 
```

### Create needed AWS infra

There is a script here name `s3_state_prep.sh` which will prepare an s3 bucket and a dynamodb table
that will be used for Terraform state. It will ask you two questions:

* Prefix for the bucket. Bucket names must be globally uniqure across ALL ACCOUNTS so make this descriptive but easy
  * `jbankes` becomes `jbankes-terraform-states`
  * The script checks to see if it already exists in your account
* Region - this defaults to `us-west-2`

```bash
$ ./s3_state_prep.sh
Enter a prefix for the S3 bucket to store Terraform state: <replace>
Enter the AWS region to create the resources in [us-west-2]:
```

You will have two resources created:

* AWS S3 bucket for Remote Terraform State [Docs: s3 backend](https://developer.hashicorp.com/terraform/language/settings/backends/s3)
* DynamoDB table for locking
* Updated `main.tf` `backend{}` block with the generated names above

### Setup Terraform

First, make sure you are in the same directory where your Terraform code is. I have set up the files for you but you
will need to go into `main.tf` and verify the `bucket` and `dynamodb_table` entries point to the AWS resources
generated above.The prep script should handle it for you but better safe than sorry. Once you've changed those values
you need to initialize Terraform.

```bash
terraform init
```

A new hidden `.terraform` directory will exist as well as a `.terraform.lock.hcl` which keeps track of provider
versions similar to a `package-lock.json` for NPM. The `.terraform` directory will contain downloaded providers and
a local state file. You normally want to add the lock file to your Git repo but add  `.terraform/` to your
`.gitgnore` file so you don't commit it.

## Deploy VPC

### Some Terraform Background

We are going to use the AWS-IA module they created. See the [Terraform Module: aws-ia/vpc/aws](https://registry.terraform.io/modules/aws-ia/vpc/aws/latest).
This is a well designed set of resources that are shared and managed by the community. They're open sourece and on [GitHub: AWS-IA VPC](https://github.com/aws-ia/terraform-aws-vpc).
Normally you would build out all the resources separate using resources from the [AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs).

### Run Terraform

Make sure you're still in the directory with your configuration files. Terraform will look for all files that are
`*.tf` when you run a `terraform plan` or `terraform apply`. To see what will be created you can run.

```bash
terraform plan
```

If you want to change the name of the vpc, you can pass in the variable:

```bash
terraform plan -var="vpc_name=cool-prefix" # creates cool-prefix-vpc
```

To actually deploy run the following. You will need to approve by typing `yes`.

```bash
terraform plan -var="vpc_name=cool-prefix" # creates cool-prefix-vpc
```

### Check your Creation in the Console

SUCCESS!! Feel free to log into your account and check it out!
