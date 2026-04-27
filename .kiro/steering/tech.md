# Tech Stack

## Infrastructure as Code
- **Terraform** >= 1.5.0
- **AWS Provider** >= 5.0 (hashicorp/aws)

## AWS Services Used
- RDS Aurora MySQL (engine: `aurora-mysql`, default version `8.0.mysql_aurora.3.05.2`)
- RDS Aurora PostgreSQL (engine: `aurora-postgresql`, default version `14.12`)
- DynamoDB
- S3
- AWS Backup (for DynamoDB and RDS backup plans)
- IAM (users, roles, policies)
- S3 Control (multi-region access points)

## Common Commands

```bash
# Initialize a module or example
terraform init

# Preview changes
terraform plan

# Apply changes
terraform apply

# Destroy resources
terraform destroy

# Format code
terraform fmt -recursive

# Validate configuration
terraform validate
```

Run these commands from the relevant directory (root, a module directory, or an example directory).

## Provider Configuration

Modules that support multi-region (RDS, S3) require **two provider aliases**:

```hcl
provider "aws" {
  region = "us-east-1"
}

provider "aws" {
  alias  = "secondary"
  region = "eu-west-1"
}
```

These must be passed explicitly via the `providers` block when calling the root module:

```hcl
providers = {
  aws           = aws
  aws.secondary = aws.secondary
}
```

Modules declare `configuration_aliases = [aws.secondary]` in their `versions.tf` to support this pattern.
