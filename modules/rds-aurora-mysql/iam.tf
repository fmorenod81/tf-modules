# -----------------------------------------------------------------------------
# Dev IAM User for RDS Aurora MySQL Access
# -----------------------------------------------------------------------------

resource "aws_iam_user" "dev_db_user" {
  name = local.iam_user_name
  tags = var.tags
}

resource "aws_iam_user_policy" "rds_connect" {
  name = "${var.workload_name}-rds-connect"
  user = aws_iam_user.dev_db_user.name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = "rds-db:connect"
        Resource = "arn:aws:rds-db:${var.primary_region}:${data.aws_caller_identity.current.account_id}:dbuser:${aws_rds_cluster.primary.cluster_resource_id}/*"
      }
    ]
  })
}
