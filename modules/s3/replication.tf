# Data source for account ID (used in multi-region access point)
data "aws_caller_identity" "current" {}

# -----------------------------------------------------------------------------
# Replica Bucket in Secondary Region (Tier 0 only)
# -----------------------------------------------------------------------------
resource "aws_s3_bucket" "replica" {
  count = local.current_tier.multi_region ? 1 : 0

  provider = aws.secondary

  bucket        = "${var.workload_name}-${var.tags["environment"]}-${var.secondary_region}-replica"
  force_destroy = var.force_destroy
  tags          = var.tags
}

resource "aws_s3_bucket_versioning" "replica" {
  count = local.current_tier.multi_region ? 1 : 0

  provider = aws.secondary

  bucket = aws_s3_bucket.replica[0].id
  versioning_configuration {
    status = "Enabled"
  }
}

# -----------------------------------------------------------------------------
# IAM Role for S3 Cross-Region Replication (Tier 0 only)
# -----------------------------------------------------------------------------
resource "aws_iam_role" "replication" {
  count = local.current_tier.multi_region ? 1 : 0

  name = "${var.workload_name}-s3-replication"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "s3.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = var.tags
}

resource "aws_iam_role_policy" "replication" {
  count = local.current_tier.multi_region ? 1 : 0

  name = "${var.workload_name}-s3-replication"
  role = aws_iam_role.replication[0].id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetReplicationConfiguration",
          "s3:ListBucket"
        ]
        Resource = aws_s3_bucket.primary.arn
      },
      {
        Effect = "Allow"
        Action = [
          "s3:GetObjectVersionForReplication",
          "s3:GetObjectVersionAcl",
          "s3:GetObjectVersionTagging"
        ]
        Resource = "${aws_s3_bucket.primary.arn}/*"
      },
      {
        Effect = "Allow"
        Action = [
          "s3:ReplicateObject",
          "s3:ReplicateDelete",
          "s3:ReplicateTags"
        ]
        Resource = "${aws_s3_bucket.replica[0].arn}/*"
      }
    ]
  })
}

# -----------------------------------------------------------------------------
# Cross-Region Replication Configuration on Primary Bucket (Tier 0 only)
# -----------------------------------------------------------------------------
resource "aws_s3_bucket_replication_configuration" "primary" {
  count = local.current_tier.multi_region ? 1 : 0

  depends_on = [aws_s3_bucket_versioning.primary]

  role   = aws_iam_role.replication[0].arn
  bucket = aws_s3_bucket.primary.id

  rule {
    id     = "cross-region-replication"
    status = "Enabled"

    destination {
      bucket        = aws_s3_bucket.replica[0].arn
      storage_class = "STANDARD"
    }
  }
}

# -----------------------------------------------------------------------------
# Multi-Region Access Point (Tier 0 only)
# -----------------------------------------------------------------------------
resource "aws_s3control_multi_region_access_point" "this" {
  count = local.current_tier.multi_region ? 1 : 0

  details {
    name = "${var.workload_name}-multi-region-ap"

    region {
      bucket = aws_s3_bucket.primary.id
    }

    region {
      bucket = aws_s3_bucket.replica[0].id
    }
  }
}
