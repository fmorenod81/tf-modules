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

variable "force_destroy" {
  type        = bool
  description = "Whether to allow force destroying the bucket even if it contains objects"
  default     = false
}

variable "block_public_access" {
  type        = bool
  description = "Whether to block all public access to the bucket"
  default     = true
}

variable "sse_algorithm" {
  type        = string
  description = "Server-side encryption algorithm for the bucket"
  default     = "aws:kms"
}

variable "noncurrent_version_expiration_days" {
  type        = number
  description = "Number of days after which noncurrent object versions expire"
  default     = 90
}
