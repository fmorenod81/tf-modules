# -----------------------------------------------------------------------------
# Tier 0 Multi-Region Deployment Example
# -----------------------------------------------------------------------------
# This example deploys all three modules (RDS Aurora MySQL, DynamoDB, S3) with
# Tier 0 protection: multi-AZ + multi-region availability, hourly backups,
# Aurora Global Database, DynamoDB Global Tables, and S3 cross-region replication.
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
  region = "us-east-1"
}

provider "aws" {
  alias  = "secondary"
  region = "eu-west-1"
}

module "tiered_aws" {
  source = "../../"

  tier_of_protection = 0
  primary_region     = "us-east-1"
  secondary_region   = "eu-west-1"
  workload_name      = "payment-service"

  cost_center  = "3200"
  project_name = "payments"
  environment  = "prod"
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
  description = "ARN of the dev IAM user for RDS access"
  value       = module.tiered_aws.rds_dev_iam_user_arn
}

output "dynamodb_dev_iam_user_arn" {
  description = "ARN of the dev IAM user for DynamoDB access"
  value       = module.tiered_aws.dynamodb_dev_iam_user_arn
}
