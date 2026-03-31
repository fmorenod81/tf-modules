variable "tier_of_protection" {
  type        = number
  description = "Protection tier: 0 (multi-AZ + multi-region), 1 (multi-AZ), 2 (single-AZ)"
  validation {
    condition     = contains([0, 1, 2], var.tier_of_protection)
    error_message = "tier_of_protection must be 0, 1, or 2."
  }
}

variable "environment" {
  type        = string
  description = "Deployment environment"
  validation {
    condition     = contains(["dev", "qa", "uat", "prod"], var.environment)
    error_message = "environment must be one of: dev, qa, uat, prod."
  }
}

variable "cost_center" {
  type        = string
  description = "Cost center code (1000-9999)"
  validation {
    condition     = can(regex("^[0-9]{4}$", var.cost_center)) && tonumber(var.cost_center) >= 1000 && tonumber(var.cost_center) <= 9999
    error_message = "cost_center must be a number between 1000 and 9999."
  }
}

variable "workload_name" {
  type        = string
  description = "Name of the workload, used for resource naming"
  validation {
    condition     = can(regex("^[a-z0-9-]+$", var.workload_name))
    error_message = "workload_name must be lowercase alphanumeric with hyphens only."
  }
}

variable "primary_region" {
  type        = string
  description = "Primary AWS region for all resources"
  validation {
    condition     = length(var.primary_region) > 0
    error_message = "primary_region must not be empty."
  }
}

variable "secondary_region" {
  type        = string
  description = "Secondary AWS region for multi-region deployments (required when tier = 0)"
  default     = ""
  validation {
    condition     = var.tier_of_protection != 0 || length(var.secondary_region) > 0
    error_message = "secondary_region is required when tier_of_protection is 0."
  }
}

variable "project_name" {
  type        = string
  description = "Project name for tagging"
  validation {
    condition     = length(var.project_name) > 0
    error_message = "project_name must not be empty."
  }
}
