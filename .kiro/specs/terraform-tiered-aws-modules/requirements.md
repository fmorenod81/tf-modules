# Requirements Document

## Introduction

This document defines the requirements for the Terraform Tiered AWS Modules feature. The system provides three reusable Terraform modules (RDS Aurora MySQL, DynamoDB, S3) configurable through a tiered protection model (Tier 0, 1, 2) that controls availability, redundancy, and backup strategies. It enforces organizational governance through mandatory tagging, input validation, and IAM-based authentication for database modules.

## Glossary

- **Root_Module**: The top-level Terraform module that orchestrates all three service modules, defines shared variables, and passes validated inputs downstream.
- **RDS_Aurora_Module**: The child Terraform module responsible for provisioning an Aurora MySQL cluster with tier-driven availability, backup, and IAM authentication.
- **DynamoDB_Module**: The child Terraform module responsible for provisioning a DynamoDB table with tier-driven replication, backup strategy, and IAM authentication.
- **S3_Module**: The child Terraform module responsible for provisioning an S3 bucket with tier-driven replication, versioning, and lifecycle policies.
- **Tier_Of_Protection**: A numeric input (0, 1, or 2) that determines the availability, redundancy, and backup configuration for all provisioned resources.
- **Common_Tags**: A map of mandatory tags (cost_center, project_name, environment, workload, managed_by) applied to every resource.
- **Dev_IAM_User**: An IAM user created by database modules for development access, with permissions scoped to the specific database resource.
- **Validation_Engine**: The Terraform variable validation blocks that enforce input constraints at plan time.

## Requirements

### Requirement 1: Input Validation

**User Story:** As an operator, I want the modules to validate all inputs at plan time, so that misconfigured deployments are caught before any resources are created.

#### Acceptance Criteria

1. WHEN an operator provides a `tier_of_protection` value not in {0, 1, 2}, THE Validation_Engine SHALL reject the plan with the message "tier_of_protection must be 0, 1, or 2."
2. WHEN an operator provides an `environment` value not in {dev, qa, uat, prod}, THE Validation_Engine SHALL reject the plan with the message "environment must be one of: dev, qa, uat, prod."
3. WHEN an operator provides a `cost_center` value that is not a 4-digit number between 1000 and 9999, THE Validation_Engine SHALL reject the plan with the message "cost_center must be a number between 1000 and 9999."
4. WHEN an operator provides a `workload_name` that does not match the pattern `^[a-z0-9-]+$`, THE Validation_Engine SHALL reject the plan with the message "workload_name must be lowercase alphanumeric with hyphens only."
5. WHEN an operator sets `tier_of_protection` to 0 and provides an empty `secondary_region`, THE Validation_Engine SHALL reject the plan with the message "secondary_region is required when tier_of_protection is 0."
6. WHEN an operator provides a `primary_region` that is empty, THE Validation_Engine SHALL reject the plan with a descriptive error.

### Requirement 2: Mandatory Tagging

**User Story:** As a cloud governance lead, I want all provisioned resources to carry mandatory tags, so that cost allocation and ownership tracking are enforced consistently.

#### Acceptance Criteria

1. THE Root_Module SHALL construct a Common_Tags map containing `cost_center`, `project_name`, `environment`, `workload`, and `managed_by` keys.
2. THE Root_Module SHALL set the `managed_by` tag value to "terraform".
3. WHEN any child module creates a resource, THE resource SHALL include all keys from the Common_Tags map with non-empty values.
4. WHEN the RDS_Aurora_Module creates Aurora cluster resources, instances, or global database resources, THE RDS_Aurora_Module SHALL apply the Common_Tags map to each resource.
5. WHEN the DynamoDB_Module creates table, backup, or IAM resources, THE DynamoDB_Module SHALL apply the Common_Tags map to each resource.
6. WHEN the S3_Module creates bucket, versioning, encryption, or replication resources, THE S3_Module SHALL apply the Common_Tags map to each resource.

### Requirement 3: Tier 0 Multi-Region Deployment

**User Story:** As a platform engineer, I want Tier 0 to deploy resources across two AWS regions with hourly backups, so that critical workloads have maximum availability and disaster recovery capability.

#### Acceptance Criteria

1. WHEN `tier_of_protection` is 0, THE RDS_Aurora_Module SHALL create an Aurora Global Database spanning the `primary_region` and `secondary_region`.
2. WHEN `tier_of_protection` is 0, THE RDS_Aurora_Module SHALL configure automated backups with an hourly schedule.
3. WHEN `tier_of_protection` is 0, THE DynamoDB_Module SHALL enable Global Tables with a replica in the `secondary_region`.
4. WHEN `tier_of_protection` is 0, THE DynamoDB_Module SHALL enable Point-in-Time Recovery and configure hourly backup exports.
5. WHEN `tier_of_protection` is 0, THE S3_Module SHALL enable versioning and configure cross-region replication to a bucket in the `secondary_region`.
6. WHEN `tier_of_protection` is 0, THE S3_Module SHALL create a multi-region access point.

### Requirement 4: Tier 1 Multi-AZ Deployment

**User Story:** As a platform engineer, I want Tier 1 to deploy resources with multi-AZ redundancy and 3-hour backups, so that workloads have high availability within a single region.

#### Acceptance Criteria

1. WHEN `tier_of_protection` is 1, THE RDS_Aurora_Module SHALL create a Multi-AZ Aurora cluster in the `primary_region` with replicas across 3 availability zones.
2. WHEN `tier_of_protection` is 1, THE RDS_Aurora_Module SHALL configure a 3-hour backup window.
3. WHEN `tier_of_protection` is 1, THE DynamoDB_Module SHALL enable Point-in-Time Recovery and configure 3-hour backup exports.
4. WHEN `tier_of_protection` is 1, THE DynamoDB_Module SHALL deploy the table in the `primary_region` only, with no replicas.
5. WHEN `tier_of_protection` is 1, THE S3_Module SHALL enable versioning on the bucket.
6. WHEN `tier_of_protection` is 1, THE S3_Module SHALL deploy the bucket in the `primary_region` only, with no cross-region replication.

### Requirement 5: Tier 2 Single-AZ Deployment

**User Story:** As a platform engineer, I want Tier 2 to deploy minimal single-AZ resources with daily backups, so that non-critical workloads are cost-effective.

#### Acceptance Criteria

1. WHEN `tier_of_protection` is 2, THE RDS_Aurora_Module SHALL create a single Aurora instance in one availability zone.
2. WHEN `tier_of_protection` is 2, THE RDS_Aurora_Module SHALL configure a daily backup window at 01:00-02:00 UTC.
3. WHEN `tier_of_protection` is 2, THE DynamoDB_Module SHALL disable Point-in-Time Recovery.
4. WHEN `tier_of_protection` is 2, THE DynamoDB_Module SHALL configure a daily on-demand backup via AWS Backup at 1 AM GMT.
5. WHEN `tier_of_protection` is 2, THE S3_Module SHALL suspend versioning on the bucket.
6. WHEN `tier_of_protection` is 2, THE S3_Module SHALL deploy the bucket in the `primary_region` only, with no cross-region replication.

### Requirement 6: IAM-Based Database Authentication

**User Story:** As a security engineer, I want database access to use IAM authentication with scoped dev users, so that password-based access is eliminated and permissions follow least-privilege.

#### Acceptance Criteria

1. THE RDS_Aurora_Module SHALL enable IAM database authentication on the Aurora cluster for all tiers.
2. WHEN the RDS_Aurora_Module provisions a cluster, THE RDS_Aurora_Module SHALL create a Dev_IAM_User with an `rds-db:connect` policy scoped to the cluster resource.
3. WHEN the DynamoDB_Module provisions a table, THE DynamoDB_Module SHALL create a Dev_IAM_User with CRUD permissions (GetItem, PutItem, UpdateItem, DeleteItem, Query, Scan, BatchGetItem, BatchWriteItem) scoped to the table and its indexes.
4. THE RDS_Aurora_Module SHALL name the Dev_IAM_User following the pattern `{workload_name}-{environment}-dev-db-user`.
5. THE DynamoDB_Module SHALL name the Dev_IAM_User following the pattern `{workload_name}-{environment}-dev-db-user`.
6. THE RDS_Aurora_Module SHALL apply the Common_Tags map to the Dev_IAM_User resource.
7. THE DynamoDB_Module SHALL apply the Common_Tags map to the Dev_IAM_User resource.

### Requirement 7: Encryption at Rest

**User Story:** As a security engineer, I want all storage resources to be encrypted at rest, so that data is protected regardless of the tier selected.

#### Acceptance Criteria

1. THE RDS_Aurora_Module SHALL set `storage_encrypted` to true on the Aurora cluster for all tiers.
2. THE DynamoDB_Module SHALL enable server-side encryption on the table for all tiers.
3. THE S3_Module SHALL configure server-side encryption using the `aws:kms` algorithm with bucket key enabled for all tiers.

### Requirement 8: S3 Public Access Protection

**User Story:** As a security engineer, I want all S3 buckets to block public access, so that data exposure risk is eliminated regardless of tier.

#### Acceptance Criteria

1. THE S3_Module SHALL set `block_public_acls` to true on the bucket for all tiers.
2. THE S3_Module SHALL set `block_public_policy` to true on the bucket for all tiers.
3. THE S3_Module SHALL set `ignore_public_acls` to true on the bucket for all tiers.
4. THE S3_Module SHALL set `restrict_public_buckets` to true on the bucket for all tiers.

### Requirement 9: Shared Variable Pattern

**User Story:** As a module consumer, I want common inputs defined once in the root module and passed consistently to each child module, so that configuration is uniform and DRY.

#### Acceptance Criteria

1. THE Root_Module SHALL define `tier_of_protection`, `primary_region`, `secondary_region`, `workload_name`, `cost_center`, `project_name`, and `environment` as input variables with validation.
2. THE Root_Module SHALL pass `tier_of_protection`, `primary_region`, `secondary_region`, `workload_name`, and the Common_Tags map to each child module.
3. WHEN a child module receives the shared variables, THE child module SHALL use the `tier_of_protection` value to determine its resource configuration.

### Requirement 10: Sensible Defaults

**User Story:** As a module consumer, I want non-required variables to have sensible defaults, so that I can deploy with minimal configuration.

#### Acceptance Criteria

1. THE RDS_Aurora_Module SHALL default `engine_version` to "8.0.mysql_aurora.3.05.2", `instance_class` to "db.r6g.large", `instance_count` to 2, `database_name` to "app", `backup_retention_period` to 7, `deletion_protection` to true, and `storage_encrypted` to true.
2. THE DynamoDB_Module SHALL default `billing_mode` to "PAY_PER_REQUEST", `hash_key` to "id", `hash_key_type` to "S", `range_key` to "", `range_key_type` to "S", `enable_encryption` to true, and `table_class` to "STANDARD".
3. THE S3_Module SHALL default `force_destroy` to false, `block_public_access` to true, `sse_algorithm` to "aws:kms", and `noncurrent_version_expiration_days` to 90.
4. WHEN an operator does not override any defaulted variable, THE module SHALL deploy successfully using only the required variables (`tier_of_protection`, `primary_region`, `workload_name`, `cost_center`, `project_name`, `environment`).

### Requirement 11: Module Outputs

**User Story:** As a module consumer, I want the root module to expose key resource identifiers, so that I can reference provisioned resources in downstream configurations.

#### Acceptance Criteria

1. THE Root_Module SHALL output the RDS Aurora cluster endpoint.
2. THE Root_Module SHALL output the DynamoDB table name and ARN.
3. THE Root_Module SHALL output the S3 bucket ID and ARN.
4. THE Root_Module SHALL output the Dev_IAM_User ARN for both the RDS and DynamoDB modules.

### Requirement 12: Tier Consistency Across Modules

**User Story:** As a platform engineer, I want all three modules to respect the same tier value, so that availability and backup characteristics are uniform across the entire workload.

#### Acceptance Criteria

1. WHEN a `tier_of_protection` value is provided, THE Root_Module SHALL pass the same value to the RDS_Aurora_Module, DynamoDB_Module, and S3_Module.
2. WHEN `tier_of_protection` is 0, THE RDS_Aurora_Module, DynamoDB_Module, and S3_Module SHALL each deploy multi-region resources.
3. WHEN `tier_of_protection` is 1, THE RDS_Aurora_Module, DynamoDB_Module, and S3_Module SHALL each deploy multi-AZ or single-region resources with no cross-region components.
4. WHEN `tier_of_protection` is 2, THE RDS_Aurora_Module, DynamoDB_Module, and S3_Module SHALL each deploy single-AZ, single-region resources.
