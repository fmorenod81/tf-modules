# Product Overview

This project is a collection of opinionated Terraform modules for deploying AWS data storage infrastructure with tiered protection levels. It provides a single, consistent interface for provisioning RDS Aurora MySQL, DynamoDB, and S3 across three protection tiers.

## Core Concept: Tiers of Protection

Every module is driven by a `tier_of_protection` variable (0, 1, or 2):

| Tier | Availability | Backup Frequency | Notes |
|------|-------------|-----------------|-------|
| 0 | Multi-AZ + Multi-Region | Hourly | Aurora Global DB, DynamoDB Global Tables, S3 cross-region replication |
| 1 | Multi-AZ only | Every 3 hours | Single region, PITR enabled, S3 versioning on |
| 2 | Single-AZ, Single-Region | Daily at 1 AM GMT | Minimal footprint, no PITR, S3 versioning suspended |

## Mandatory Inputs (no defaults)

All modules require these inputs — they must always be explicitly provided by the caller:

- `tier_of_protection` — 0, 1, or 2
- `primary_region` — AWS region string
- `workload_name` — used as a prefix for all resource names
- `tags` — map containing at minimum: `cost_center` (1000–9999), `project_name`, `environment`, `workload`
- `environment` — one of: `dev`, `qa`, `uat`, `prod`

## IAM Users

Each module provisions a **development IAM user** for direct database/storage access. These are scoped to development use only and named `{workload_name}-{environment}-dev-db-user`.
