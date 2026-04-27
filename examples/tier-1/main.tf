# -----------------------------------------------------------------------------
# Tier 1 Multi-AZ Deployment Example
# -----------------------------------------------------------------------------
# This example deploys all four modules (RDS Aurora MySQL, RDS PostgreSQL,
# DynamoDB, S3) with Tier 1 protection: multi-AZ availability within a single
# region, 3-hour backup schedules, PITR for DynamoDB, and S3 versioning enabled.
# No cross-region replication or global tables are provisioned.
# -----------------------------------------------------------------------------

terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}

provider "aws" {
  region = "us-west-2"
}

provider "aws" {
  alias  = "secondary"
  region = "us-east-1"
}

module "tiered_aws" {
  source = "../../"

  tier_of_protection = 1
  primary_region     = "us-west-2"
  workload_name      = "order-service"

  cost_center  = "4100"
  project_name = "ecommerce"
  environment  = "uat"
}

# -----------------------------------------------------------------------------
# Outputs
# -----------------------------------------------------------------------------

output "rds_cluster_endpoint" {
  description = "Primary Aurora MySQL cluster endpoint"
  value       = module.tiered_aws.rds_cluster_endpoint
}

output "dynamodb_table_name" {
  description = "Name of the DynamoDB table"
  value       = module.tiered_aws.dynamodb_table_name
}

output "dynamodb_table_arn" {
  description = "ARN of the DynamoDB table"
  value       = module.tiered_aws.dynamodb_table_arn
}

output "s3_bucket_id" {
  description = "ID of the S3 bucket"
  value       = module.tiered_aws.s3_bucket_id
}

output "s3_bucket_arn" {
  description = "ARN of the S3 bucket"
  value       = module.tiered_aws.s3_bucket_arn
}

output "rds_dev_iam_user_arn" {
  description = "ARN of the dev IAM user for RDS MySQL access"
  value       = module.tiered_aws.rds_dev_iam_user_arn
}

output "rds_postgresql_dev_iam_user_arn" {
  description = "ARN of the dev IAM user for RDS PostgreSQL access"
  value       = module.tiered_aws.rds_postgresql_dev_iam_user_arn
}

output "dynamodb_dev_iam_user_arn" {
  description = "ARN of the dev IAM user for DynamoDB access"
  value       = module.tiered_aws.dynamodb_dev_iam_user_arn
}
