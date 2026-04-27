variable "tier_of_protection" {
  type        = number
  description = "Protection tier: 0 (multi-AZ + multi-region), 1 (multi-AZ), 2 (single-AZ)"
}

variable "primary_region" {
  type        = string
  description = "Primary AWS region for all resources"
}

variable "secondary_region" {
  type        = string
  description = "Secondary AWS region for multi-region deployments (required when tier = 0)"
  default     = ""
}

variable "workload_name" {
  type        = string
  description = "Name of the workload, used for resource naming"
}

variable "tags" {
  type        = map(string)
  description = "Mandatory tags to apply to all resources"
}

# Defaulted variables

variable "engine_version" {
  type        = string
  description = "PostgreSQL engine version"
  default     = "14.12"
}

variable "instance_class" {
  type        = string
  description = "Instance class for Aurora instances"
  default     = "db.r6g.large"
}

variable "instance_count" {
  type        = number
  description = "Number of Aurora instances in the cluster"
  default     = 2
}

variable "database_name" {
  type        = string
  description = "Name of the default database to create"
  default     = "app"
}

variable "backup_retention_period" {
  type        = number
  description = "Number of days to retain automated backups"
  default     = 7
}

variable "deletion_protection" {
  type        = bool
  description = "Whether deletion protection is enabled on the cluster"
  default     = true
}

variable "storage_encrypted" {
  type        = bool
  description = "Whether storage encryption is enabled"
  default     = true
}
