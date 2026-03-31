# -----------------------------------------------------------------------------
# Root Module Outputs
# -----------------------------------------------------------------------------

output "rds_cluster_endpoint" {
  description = "Primary Aurora MySQL cluster endpoint"
  value       = module.rds_aurora_mysql.cluster_endpoint
}

output "dynamodb_table_name" {
  description = "Name of the DynamoDB table"
  value       = module.dynamodb.table_name
}

output "dynamodb_table_arn" {
  description = "ARN of the DynamoDB table"
  value       = module.dynamodb.table_arn
}

output "s3_bucket_id" {
  description = "ID of the S3 bucket"
  value       = module.s3.bucket_id
}

output "s3_bucket_arn" {
  description = "ARN of the S3 bucket"
  value       = module.s3.bucket_arn
}

output "rds_dev_iam_user_arn" {
  description = "ARN of the dev IAM user for RDS access"
  value       = module.rds_aurora_mysql.dev_iam_user_arn
}

output "dynamodb_dev_iam_user_arn" {
  description = "ARN of the dev IAM user for DynamoDB access"
  value       = module.dynamodb.dev_iam_user_arn
}
