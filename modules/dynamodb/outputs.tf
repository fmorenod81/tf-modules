# -----------------------------------------------------------------------------
# DynamoDB Module Outputs
# -----------------------------------------------------------------------------

output "table_name" {
  description = "Name of the DynamoDB table"
  value       = aws_dynamodb_table.this.name
}

output "table_arn" {
  description = "ARN of the DynamoDB table"
  value       = aws_dynamodb_table.this.arn
}

output "dev_iam_user_arn" {
  description = "ARN of the dev IAM user for DynamoDB access"
  value       = aws_iam_user.dev_db_user.arn
}
