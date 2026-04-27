locals {
  common_tags = {
    cost_center  = var.cost_center
    project_name = var.project_name
    environment  = var.environment
    workload     = var.workload_name
    managed_by   = "terraform"
  }
}

module "rds_aurora_mysql" {
  source = "./modules/rds-aurora-mysql"

  tier_of_protection = var.tier_of_protection
  primary_region     = var.primary_region
  secondary_region   = var.secondary_region
  workload_name      = var.workload_name
  tags               = local.common_tags

  providers = {
    aws           = aws
    aws.secondary = aws.secondary
  }
}

module "rds_postgresql" {
  source = "./modules/rds-postgresql"

  tier_of_protection = var.tier_of_protection
  primary_region     = var.primary_region
  secondary_region   = var.secondary_region
  workload_name      = var.workload_name
  tags               = local.common_tags

  providers = {
    aws           = aws
    aws.secondary = aws.secondary
  }
}

module "dynamodb" {
  source = "./modules/dynamodb"

  tier_of_protection = var.tier_of_protection
  primary_region     = var.primary_region
  secondary_region   = var.secondary_region
  workload_name      = var.workload_name
  tags               = local.common_tags
  environment        = var.environment
}

module "s3" {
  source = "./modules/s3"

  tier_of_protection = var.tier_of_protection
  primary_region     = var.primary_region
  secondary_region   = var.secondary_region
  workload_name      = var.workload_name
  tags               = local.common_tags

  providers = {
    aws           = aws
    aws.secondary = aws.secondary
  }
}
