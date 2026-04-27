# Data source for IAM policy ARN construction (used in iam.tf)
data "aws_caller_identity" "current" {}

# -----------------------------------------------------------------------------
# Aurora Global Database (Tier 0 only)
# -----------------------------------------------------------------------------
resource "aws_rds_global_cluster" "this" {
  count = local.current_tier.multi_region ? 1 : 0

  global_cluster_identifier = "${var.workload_name}-aurora-global"
  engine                    = "aurora-postgresql"
  engine_version            = var.engine_version
  database_name             = var.database_name
  storage_encrypted         = var.storage_encrypted
  deletion_protection       = var.deletion_protection
}

# -----------------------------------------------------------------------------
# Primary Aurora Cluster
# -----------------------------------------------------------------------------
resource "aws_rds_cluster" "primary" {
  cluster_identifier              = "${var.workload_name}-aurora-primary"
  engine                          = "aurora-postgresql"
  engine_version                  = var.engine_version
  database_name                   = local.current_tier.multi_region ? null : var.database_name
  master_username                 = local.current_tier.multi_region ? null : "admin"
  manage_master_user_password     = local.current_tier.multi_region ? null : true
  storage_encrypted               = var.storage_encrypted
  deletion_protection             = var.deletion_protection
  backup_retention_period         = var.backup_retention_period
  preferred_backup_window         = local.current_tier.multi_az ? null : "01:00-02:00"
  iam_database_authentication_enabled = true
  availability_zones              = local.current_tier.multi_az ? local.primary_azs : [local.primary_azs[0]]

  # Tier 0: Link to global database
  global_cluster_identifier = local.current_tier.multi_region ? aws_rds_global_cluster.this[0].id : null

  tags = var.tags
}

# -----------------------------------------------------------------------------
# Primary Cluster Instances
# Tier 0/1: var.instance_count instances across AZs
# Tier 2: Single instance
# -----------------------------------------------------------------------------
resource "aws_rds_cluster_instance" "primary" {
  count = local.current_tier.multi_az ? var.instance_count : 1

  identifier         = "${var.workload_name}-aurora-primary-${count.index}"
  cluster_identifier = aws_rds_cluster.primary.id
  instance_class     = var.instance_class
  engine             = aws_rds_cluster.primary.engine
  engine_version     = aws_rds_cluster.primary.engine_version

  tags = var.tags
}

# -----------------------------------------------------------------------------
# Secondary Aurora Cluster (Tier 0 only — global database)
# -----------------------------------------------------------------------------
resource "aws_rds_cluster" "secondary" {
  count = local.current_tier.multi_region ? 1 : 0

  provider = aws.secondary

  cluster_identifier              = "${var.workload_name}-aurora-secondary"
  engine                          = "aurora-postgresql"
  engine_version                  = var.engine_version
  storage_encrypted               = var.storage_encrypted
  deletion_protection             = var.deletion_protection
  backup_retention_period         = var.backup_retention_period
  iam_database_authentication_enabled = true

  global_cluster_identifier = aws_rds_global_cluster.this[0].id

  tags = var.tags

  depends_on = [aws_rds_cluster.primary]
}

# -----------------------------------------------------------------------------
# Secondary Cluster Instances (Tier 0 only)
# -----------------------------------------------------------------------------
resource "aws_rds_cluster_instance" "secondary" {
  count = local.current_tier.multi_region ? var.instance_count : 0

  provider = aws.secondary

  identifier         = "${var.workload_name}-aurora-secondary-${count.index}"
  cluster_identifier = aws_rds_cluster.secondary[0].id
  instance_class     = var.instance_class
  engine             = aws_rds_cluster.secondary[0].engine
  engine_version     = aws_rds_cluster.secondary[0].engine_version

  tags = var.tags
}
