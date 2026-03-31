# -----------------------------------------------------------------------------
# AWS Backup Configuration for DynamoDB
# Tier 0: Hourly backups (cron every hour)
# Tier 1: 3-hour backups (cron every 3 hours)
# Tier 2: Daily on-demand backup at 1 AM GMT
# All tiers use AWS Backup with tier-specific cron schedule
# -----------------------------------------------------------------------------

resource "aws_backup_vault" "dynamodb" {
  name = "${var.workload_name}-dynamodb-backup-vault"
  tags = var.tags
}

resource "aws_backup_plan" "dynamodb" {
  name = "${var.workload_name}-dynamodb-backup-plan"

  rule {
    rule_name         = "${var.workload_name}-dynamodb-backup-rule"
    target_vault_name = aws_backup_vault.dynamodb.name
    schedule          = local.current_tier.backup_cron
  }

  tags = var.tags
}

resource "aws_iam_role" "backup" {
  name = "${var.workload_name}-dynamodb-backup-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "backup.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "backup" {
  role       = aws_iam_role.backup.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSBackupServiceRolePolicyForDynamoDB"
}

resource "aws_backup_selection" "dynamodb" {
  name         = "${var.workload_name}-dynamodb-backup-selection"
  plan_id      = aws_backup_plan.dynamodb.id
  iam_role_arn = aws_iam_role.backup.arn

  resources = [
    aws_dynamodb_table.this.arn
  ]
}
