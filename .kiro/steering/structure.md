# Project Structure

```
.
├── main.tf                        # Root module — composes all four child modules
├── modules/
│   ├── rds-aurora-mysql/          # Aurora MySQL module
│   │   ├── main.tf                # Cluster, instances (primary + secondary)
│   │   ├── locals.tf              # tier_config map + derived locals
│   │   ├── variables.tf           # Input variables
│   │   ├── outputs.tf             # Exported values
│   │   ├── iam.tf                 # Dev IAM user + policy
│   │   └── versions.tf            # Provider requirements + aliases
│   ├── rds-postgresql/            # Aurora PostgreSQL module
│   │   ├── main.tf                # Cluster, instances (primary + secondary)
│   │   ├── locals.tf              # tier_config map + derived locals
│   │   ├── variables.tf           # Input variables
│   │   ├── outputs.tf             # Exported values
│   │   ├── iam.tf                 # Dev IAM user + policy
│   │   └── versions.tf            # Provider requirements + aliases
│   ├── dynamodb/
│   │   ├── main.tf                # Table resource (with optional replica)
│   │   ├── locals.tf              # tier_config map + derived locals
│   │   ├── variables.tf
│   │   ├── outputs.tf
│   │   ├── backup.tf              # AWS Backup vault, plan, selection
│   │   └── iam.tf                 # Dev IAM user + policy
│   └── s3/
│       ├── main.tf                # Primary bucket + versioning + encryption
│       ├── locals.tf              # tier_config map + derived locals
│       ├── variables.tf
│       ├── outputs.tf
│       ├── replication.tf         # Replica bucket, IAM role, CRR config, MRAP
│       └── versions.tf            # Provider requirements + aliases
└── examples/
    ├── tier-0/main.tf             # Multi-region example (prod)
    ├── tier-1/main.tf             # Multi-AZ example (uat)
    └── tier-2/main.tf             # Single-AZ example (dev)
```

## Conventions

### File Organization
Each module follows the same file layout: `main.tf`, `locals.tf`, `variables.tf`, `outputs.tf`, plus feature-specific files (`backup.tf`, `replication.tf`, `iam.tf`, `versions.tf`). Do not consolidate these into a single file.

### Tier Logic Pattern
All tier-specific behavior is driven by a `locals.tf` `tier_config` map keyed by tier number (0, 1, 2). Always use `local.current_tier.<property>` to branch behavior — never use `var.tier_of_protection` directly in conditionals outside of `locals.tf`.

```hcl
locals {
  tier_config = {
    0 = { multi_region = true,  ... }
    1 = { multi_region = false, ... }
    2 = { multi_region = false, ... }
  }
  current_tier = local.tier_config[var.tier_of_protection]
}
```

### Resource Naming
All resources are prefixed with `var.workload_name`. Follow the pattern:
- `"${var.workload_name}-<resource-descriptor>"`
- IAM users: `"${var.workload_name}-${var.tags["environment"]}-dev-db-user"`
- S3 buckets: `"${var.workload_name}-${var.tags["environment"]}-${var.primary_region}"`

### Conditional Resources
Use `count = local.current_tier.multi_region ? 1 : 0` for resources that only exist at tier 0. Reference them with index `[0]`.

### Tags
All resources receive `tags = var.tags`. The tags map is constructed in the root `main.tf` `locals` block and passed down — modules never construct tags themselves.

### Variables
- Mandatory inputs (no defaults): `tier_of_protection`, `primary_region`, `workload_name`, `tags`
- Optional inputs always have a `default` and a clear `description`
- `secondary_region` defaults to `""` and is only used when `local.current_tier.multi_region == true`

### Outputs
Every module exports at minimum: the primary resource identifier, its ARN, and the dev IAM user ARN. Output names use snake_case descriptors without module-name prefixes (e.g., `cluster_endpoint`, not `rds_cluster_endpoint`).

### Examples
Each example in `examples/` targets a single tier and uses realistic but fictional values for `workload_name`, `cost_center`, `project_name`, and `environment`. Examples always declare their own `terraform` and `provider` blocks.
