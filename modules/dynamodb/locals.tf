locals {
  tier_config = {
    0 = {
      multi_region     = true
      pitr_enabled     = true
      backup_cron      = "cron(0 * * * ? *)"
      backup_frequency = "hourly"
    }
    1 = {
      multi_region     = false
      pitr_enabled     = true
      backup_cron      = "cron(0 */3 * * ? *)"
      backup_frequency = "3-hourly"
    }
    2 = {
      multi_region     = false
      pitr_enabled     = false
      backup_cron      = "cron(0 1 * * ? *)"
      backup_frequency = "daily"
    }
  }

  current_tier = local.tier_config[var.tier_of_protection]

  iam_user_name = "${var.workload_name}-${var.tags["environment"]}-dev-db-user"
}
