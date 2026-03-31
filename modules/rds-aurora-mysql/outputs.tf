# -----------------------------------------------------------------------------
# RDS Aurora MySQL Module Outputs
# -----------------------------------------------------------------------------

output "cluster_endpoint" {
  description = "Primary Aurora cluster endpoint"
  value       = aws_rds_cluster.primary.endpoint
}

output "cluster_arn" {
  description = "Primary Aurora cluster ARN"
  value       = aws_rds_cluster.primary.arn
}

output "dev_iam_user_arn" {
  description = "ARN of the dev IAM user for RDS access"
  value       = aws_iam_user.dev_db_user.arn
}
