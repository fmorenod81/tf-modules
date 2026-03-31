# -----------------------------------------------------------------------------
# DynamoDB Table
# Tier 0: Global Tables with secondary region replica, PITR enabled
# Tier 1: Single region, PITR enabled
# Tier 2: Single region, PITR disabled
# Server-side encryption enabled on all tiers
# -----------------------------------------------------------------------------
resource "aws_dynamodb_table" "this" {
  name         = "${var.workload_name}-table"
  billing_mode = var.billing_mode
  hash_key     = var.hash_key
  table_class  = var.table_class

  attribute {
    name = var.hash_key
    type = var.hash_key_type
  }

  dynamic "attribute" {
    for_each = var.range_key != "" ? [1] : []
    content {
      name = var.range_key
      type = var.range_key_type
    }
  }

  point_in_time_recovery {
    enabled = local.current_tier.pitr_enabled
  }

  # Tier 0: Global table replica in secondary region
  dynamic "replica" {
    for_each = local.current_tier.multi_region ? [var.secondary_region] : []
    content {
      region_name = replica.value
    }
  }

  server_side_encryption {
    enabled = var.enable_encryption
  }

  tags = var.tags
}
