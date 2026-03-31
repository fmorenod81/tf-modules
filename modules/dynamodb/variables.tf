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

variable "environment" {
  type        = string
  description = "Deployment environment, used for IAM user naming"
}

# Defaulted variables

variable "billing_mode" {
  type        = string
  description = "DynamoDB billing mode"
  default     = "PAY_PER_REQUEST"
}

variable "hash_key" {
  type        = string
  description = "Hash (partition) key attribute name"
  default     = "id"
}

variable "hash_key_type" {
  type        = string
  description = "Hash key attribute type (S, N, or B)"
  default     = "S"
}

variable "range_key" {
  type        = string
  description = "Range (sort) key attribute name; empty string means no range key"
  default     = ""
}

variable "range_key_type" {
  type        = string
  description = "Range key attribute type (S, N, or B)"
  default     = "S"
}

variable "enable_encryption" {
  type        = bool
  description = "Whether server-side encryption is enabled"
  default     = true
}

variable "table_class" {
  type        = string
  description = "DynamoDB table class (STANDARD or STANDARD_INFREQUENT_ACCESS)"
  default     = "STANDARD"
}
