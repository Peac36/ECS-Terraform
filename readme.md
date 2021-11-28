# Terraform flow

## Set up

* Set [AWS Credentials](https://docs.aws.amazon.com/sdk-for-java/v1/developer-guide/setup-credentials.html#itemizedlist) using `nstoqnov` for profile.
* Execute `terraform apply ${image}` (Make sure you pick correct workspace).

## What it contains

* 1 VPC
* 4 Subnets(2 public and 2 private)
* 2 Elastic IP
* 2 NAT
* 1 ALB - http & https listeners and one target group
* 1 ECS Cluster
* 2 ECS Service
* 2 SQS

## Modules

* `env` - module that based on selected workspace specify what environment will be used across the whole deployment
* `security` - generate role/security groups and etc...
* `workers` - a module that represents worker instance.

## How to deploy

1. Select the environment you want with following command - `terraform workspace select ${environment}`.
2. Execute `terraform apply` and provide the required container image parameter.
3. If deploy plan is OK, type yes.

## How to SSH into a task

`aws ecs execute-command --profile ${aws_profile} --region us-east-1 --cluster ${cluster_name} --task ${task} --command bash --interactive`