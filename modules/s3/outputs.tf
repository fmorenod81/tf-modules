# -----------------------------------------------------------------------------
# S3 Module Outputs
# -----------------------------------------------------------------------------

output "bucket_id" {
  description = "ID of the S3 bucket"
  value       = aws_s3_bucket.primary.id
}

output "bucket_arn" {
  description = "ARN of the S3 bucket"
  value       = aws_s3_bucket.primary.arn
}
