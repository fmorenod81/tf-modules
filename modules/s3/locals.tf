locals {
  tier_config = {
    0 = {
      multi_region       = true
      versioning_enabled = true
    }
    1 = {
      multi_region       = false
      versioning_enabled = true
    }
    2 = {
      multi_region       = false
      versioning_enabled = false
    }
  }

  current_tier = local.tier_config[var.tier_of_protection]
}
