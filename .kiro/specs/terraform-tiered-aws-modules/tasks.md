# Implementation Plan: Terraform Tiered AWS Modules

## Overview

Implement three reusable Terraform modules (RDS Aurora MySQL, DynamoDB, S3) with a tiered protection model (0, 1, 2), mandatory tagging, input validation, IAM authentication for database modules, and sensible defaults. The implementation follows the project structure defined in the design, building incrementally from shared infrastructure through each module to final wiring and examples.

## Tasks

- [x] 1. Set up project structure and shared root module
  - [x] 1.1 Create `versions.tf` with Terraform >= 1.5.0 and AWS provider >= 5.0 constraints
    - _Requirements: 9.1_
  - [x] 1.2 Create `providers.tf` with primary AWS provider and secondary region alias for tier 0 deployments
    - _Requirements: 9.2, 3.1, 3.3, 3.5_
  - [x] 1.3 Create `variables.tf` with all shared input variables and validation blocks
    - Define `tier_of_protection` with validation for {0, 1, 2}
    - Define `environment` with validation for {dev, qa, uat, prod}
    - Define `cost_center` with 4-digit validation (1000-9999)
    - Define `workload_name` with lowercase alphanumeric + hyphens regex validation
    - Define `primary_region`, `secondary_region` (required when tier=0), `project_name`
    - _Requirements: 1.1, 1.2, 1.3, 1.4, 1.5, 1.6, 9.1_
  - [x] 1.4 Create empty module directory structure for `modules/rds-aurora-mysql/`, `modules/dynamodb/`, `modules/s3/`
    - _Requirements: 9.1_

- [x] 2. Checkpoint - Validate root module structure
  - Run `terraform validate` on the root module to confirm variable definitions and provider config are syntactically correct. Ask the user if questions arise.

- [x] 3. Implement the RDS Aurora MySQL module
  - [x] 3.1 Create `modules/rds-aurora-mysql/variables.tf` with module inputs and sensible defaults
    - Define `tier_of_protection`, `primary_region`, `secondary_region`, `workload_name`, `tags`
    - Default `engine_version` to "8.0.mysql_aurora.3.05.2", `instance_class` to "db.r6g.large", `instance_count` to 2, `database_name` to "app", `backup_retention_period` to 7, `deletion_protection` to true, `storage_encrypted` to true
    - _Requirements: 10.1_
  - [x] 3.2 Create `modules/rds-aurora-mysql/locals.tf` with tier configuration map and AZ resolution
    - Define `tier_config` local with multi_az, multi_region, backup_cron per tier
    - Resolve availability zones from the primary region
    - _Requirements: 12.1, 12.2, 12.3, 12.4_
  - [x] 3.3 Create `modules/rds-aurora-mysql/main.tf` with Aurora cluster resources
    - Tier 0: Aurora Global Database spanning primary + secondary regions with hourly backups
    - Tier 1: Multi-AZ cluster in primary region with 3-hour backup window
    - Tier 2: Single-AZ instance with daily backup at 01:00-02:00 UTC
    - Enable `iam_database_authentication_enabled = true` on all tiers
    - Set `storage_encrypted = true` on all tiers
    - Apply `var.tags` to all resources
    - _Requirements: 3.1, 3.2, 4.1, 4.2, 5.1, 5.2, 6.1, 7.1, 2.4_
  - [x] 3.4 Create `modules/rds-aurora-mysql/iam.tf` with Dev IAM user and RDS connect policy
    - Create IAM user named `{workload_name}-{environment}-dev-db-user`
    - Attach `rds-db:connect` policy scoped to the cluster resource
    - Apply `var.tags` to the IAM user
    - _Requirements: 6.1, 6.2, 6.4, 6.6_
  - [x] 3.5 Create `modules/rds-aurora-mysql/outputs.tf` exposing cluster endpoint, ARN, and IAM user ARN
    - _Requirements: 11.1, 11.4_
  - [ ]* 3.6 Write property test for RDS Aurora module tier consistency
    - **Property 1: Tier Consistency** — Verify tier 0 creates global DB, tier 1 creates multi-AZ, tier 2 creates single-AZ
    - **Property 6: Encryption Invariant** — Verify `storage_encrypted = true` across all tiers
    - **Validates: Requirements 3.1, 3.2, 4.1, 4.2, 5.1, 5.2, 7.1, 12.2, 12.3, 12.4**

- [x] 4. Implement the DynamoDB module
  - [x] 4.1 Create `modules/dynamodb/variables.tf` with module inputs and sensible defaults
    - Define `tier_of_protection`, `primary_region`, `secondary_region`, `workload_name`, `tags`
    - Default `billing_mode` to "PAY_PER_REQUEST", `hash_key` to "id", `hash_key_type` to "S", `range_key` to "", `range_key_type` to "S", `enable_encryption` to true, `table_class` to "STANDARD"
    - _Requirements: 10.2_
  - [x] 4.2 Create `modules/dynamodb/locals.tf` with tier configuration map
    - _Requirements: 12.1_
  - [x] 4.3 Create `modules/dynamodb/main.tf` with DynamoDB table resource
    - Tier 0: Enable Global Tables with secondary region replica, PITR enabled
    - Tier 1: Single region, PITR enabled
    - Tier 2: Single region, PITR disabled
    - Enable server-side encryption on all tiers
    - Apply `var.tags` to all resources
    - _Requirements: 3.3, 3.4, 4.3, 4.4, 5.3, 5.4, 7.2, 2.5_
  - [x] 4.4 Create `modules/dynamodb/backup.tf` with tier-driven backup configuration
    - Tier 0: Hourly backup exports to S3
    - Tier 1: 3-hour backup exports
    - Tier 2: Daily on-demand backup via AWS Backup at 1 AM GMT
    - _Requirements: 3.4, 4.3, 5.4_
  - [x] 4.5 Create `modules/dynamodb/iam.tf` with Dev IAM user and DynamoDB access policy
    - Create IAM user named `{workload_name}-{environment}-dev-db-user`
    - Attach CRUD policy (GetItem, PutItem, UpdateItem, DeleteItem, Query, Scan, BatchGetItem, BatchWriteItem) scoped to table and indexes
    - Apply `var.tags` to the IAM user
    - _Requirements: 6.3, 6.5, 6.7_
  - [x] 4.6 Create `modules/dynamodb/outputs.tf` exposing table name, ARN, and IAM user ARN
    - _Requirements: 11.2, 11.4_
  - [ ]* 4.7 Write property test for DynamoDB module tier consistency
    - **Property 1: Tier Consistency** — Verify tier 0 enables global tables, tier 1 enables PITR only, tier 2 has neither
    - **Property 5: Backup Schedule Invariant** — Verify backup cron matches tier specification
    - **Property 6: Encryption Invariant** — Verify server-side encryption enabled across all tiers
    - **Validates: Requirements 3.3, 3.4, 4.3, 4.4, 5.3, 5.4, 7.2, 12.2, 12.3, 12.4**

- [x] 5. Checkpoint - Validate RDS and DynamoDB modules
  - Run `terraform validate` on each module. Ensure all variable definitions, resource blocks, and outputs are syntactically correct. Ask the user if questions arise.

- [x] 6. Implement the S3 module
  - [x] 6.1 Create `modules/s3/variables.tf` with module inputs and sensible defaults
    - Define `tier_of_protection`, `primary_region`, `secondary_region`, `workload_name`, `tags`
    - Default `force_destroy` to false, `block_public_access` to true, `sse_algorithm` to "aws:kms", `noncurrent_version_expiration_days` to 90
    - _Requirements: 10.3_
  - [x] 6.2 Create `modules/s3/locals.tf` with tier configuration map
    - _Requirements: 12.1_
  - [x] 6.3 Create `modules/s3/main.tf` with S3 bucket, versioning, encryption, and public access block
    - Tier 0 & 1: Versioning enabled
    - Tier 2: Versioning suspended
    - Block all public access on all tiers
    - KMS server-side encryption with bucket key enabled on all tiers
    - Apply `var.tags` to all resources
    - _Requirements: 3.5, 4.5, 4.6, 5.5, 5.6, 7.3, 8.1, 8.2, 8.3, 8.4, 2.6_
  - [x] 6.4 Create `modules/s3/replication.tf` with cross-region replication for tier 0
    - Create replica bucket in secondary region
    - Configure CRR replication rules
    - Create multi-region access point for tier 0
    - _Requirements: 3.5, 3.6_
  - [x] 6.5 Create `modules/s3/outputs.tf` exposing bucket ID and ARN
    - _Requirements: 11.3_
  - [ ]* 6.6 Write property tests for S3 module
    - **Property 3: Multi-Region Invariant** — Verify tier 0 creates replica bucket, tier 1/2 do not
    - **Property 6: Encryption Invariant** — Verify KMS encryption on all tiers
    - **Property 7: Public Access Invariant** — Verify all four public access block settings are true on all tiers
    - **Validates: Requirements 3.5, 3.6, 4.5, 4.6, 5.5, 5.6, 7.3, 8.1, 8.2, 8.3, 8.4**

- [x] 7. Wire root module to child modules and define outputs
  - [x] 7.1 Create `main.tf` in root module invoking all three child modules
    - Construct `common_tags` local map from input variables (cost_center, project_name, environment, workload, managed_by=terraform)
    - Pass `tier_of_protection`, `primary_region`, `secondary_region`, `workload_name`, and `common_tags` to each child module
    - _Requirements: 2.1, 2.2, 2.3, 9.2, 9.3, 12.1_
  - [x] 7.2 Create `outputs.tf` in root module aggregating outputs from all child modules
    - Output RDS cluster endpoint, DynamoDB table name/ARN, S3 bucket ID/ARN, IAM user ARNs
    - _Requirements: 11.1, 11.2, 11.3, 11.4_
  - [ ]* 7.3 Write property test for tag propagation
    - **Property 2: Tag Propagation** — Verify every resource in the plan contains all mandatory tag keys with non-empty values
    - **Validates: Requirements 2.1, 2.3, 2.4, 2.5, 2.6**
  - [ ]* 7.4 Write property test for multi-region invariant
    - **Property 3: Multi-Region Invariant** — Verify tier 0 creates resources in both regions, tier 1/2 only in primary
    - **Validates: Requirements 3.1, 3.3, 3.5, 4.4, 4.6, 5.6**
  - [ ]* 7.5 Write property test for IAM authentication invariant
    - **Property 4: IAM Authentication Invariant** — Verify RDS and DynamoDB modules each create a correctly named and scoped Dev_IAM_User
    - **Validates: Requirements 6.1, 6.2, 6.3, 6.4, 6.5**

- [x] 8. Checkpoint - Full validation
  - Run `terraform validate` and `terraform plan` (with example tfvars) on the complete root module. Ensure all modules wire together correctly and the plan produces expected resources. Ask the user if questions arise.

- [x] 9. Create usage examples
  - [x] 9.1 Create `examples/tier-0/main.tf` with a Tier 0 multi-region deployment example
    - _Requirements: 3.1, 3.3, 3.5_
  - [x] 9.2 Create `examples/tier-1/main.tf` with a Tier 1 multi-AZ deployment example
    - _Requirements: 4.1, 4.3, 4.5_
  - [x] 9.3 Create `examples/tier-2/main.tf` with a Tier 2 minimal deployment example
    - _Requirements: 5.1, 5.3, 5.5, 10.4_
  - [ ]* 9.4 Write property test for input validation completeness
    - **Property 8: Validation Completeness** — Verify invalid tier, environment, cost_center, and workload_name values all cause plan failure with descriptive errors
    - **Validates: Requirements 1.1, 1.2, 1.3, 1.4**

- [x] 10. Final checkpoint - Ensure all validations pass
  - Run `terraform validate` on root module and all examples. Ensure all tests pass, ask the user if questions arise.

## Notes

- Tasks marked with `*` are optional and can be skipped for faster MVP
- Each task references specific requirements for traceability
- Checkpoints ensure incremental validation at key milestones
- Property tests use Terratest (Go) or equivalent Terraform testing framework
- The design uses HCL directly, so all implementation is in Terraform/HCL
- Tier 0 deployments require an AWS provider alias for the secondary region
