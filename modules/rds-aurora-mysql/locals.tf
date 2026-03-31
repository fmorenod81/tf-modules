data "aws_availability_zones" "primary" {
  state = "available"
}

locals {
  tier_config = {
    0 = {
      multi_az           = true
      multi_region       = true
      backup_cron        = "cron(0 * * * ? *)"
      availability_zones = 3
    }
    1 = {
      multi_az           = true
      multi_region       = false
      backup_cron        = "cron(0 */3 * * ? *)"
      availability_zones = 3
    }
    2 = {
      multi_az           = false
      multi_region       = false
      backup_cron        = "cron(0 1 * * ? *)"
      availability_zones = 1
    }
  }

  current_tier = local.tier_config[var.tier_of_protection]

  primary_azs = slice(data.aws_availability_zones.primary.names, 0, local.current_tier.availability_zones)

  iam_user_name = "${var.workload_name}-${var.tags["environment"]}-dev-db-user"
}
