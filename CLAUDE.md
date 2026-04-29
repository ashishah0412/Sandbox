# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What This Project Does

This is a Terraform framework that provisions secure, cost-controlled AWS sandbox environments. It implements a VPC with three subnet tiers (public, private, firewall), an AWS Network Firewall for traffic inspection, and automated budget-based resource shutdown via Lambda.

## Terraform Commands

All Terraform commands run from the `aws_sandbox/` directory with `input.tfvars`:

```bash
cd aws_sandbox

# Initialize (requires S3 backend access)
terraform init -backend-config=backend.config

# Validate syntax
terraform validate

# Preview changes
terraform plan -var-file="input.tfvars"

# Apply changes
terraform apply -var-file="input.tfvars"

# Destroy all resources
terraform destroy -var-file="input.tfvars"
```

The remote state is stored in S3 bucket `ashi0412-tfstate-bucket` at key `sandboxfw/terraform.tfstate` (us-east-1). AWS credentials must be active in the shell before running any command — the pipeline uses OIDC federation via the `aws-oidc-sandbox-federation` Azure DevOps service connection.

## Architecture

### Two-Layer Design

**Execution layer** (`aws_sandbox/`) — calls all modules and owns resource orchestration. The only file you edit for infrastructure changes is `input.tfvars`; `main.tf` is the wiring harness.

**Module layer** (`golden_modules/`) — reusable, parameterized modules with no business logic hardcoded:

| Module | Provisions |
|--------|-----------|
| `VPC/` | VPC, optional IGW, optional NAT GW + EIP, optional Flow Logs |
| `Subnet/` | Subnets → calls nested `NACL/` and `RouteTable/` submodules |
| `SecurityGroup/` | Security groups with dynamic ingress/egress rules |
| `AWSNetworkFirewall/` | Stateless + stateful rule groups, firewall policy, firewall instance |
| `Automation/` | AWS Budgets + Lambda shutdown handler (`lambda_handler.py`) |

### Key Patterns

**Gateway reference resolution** — `main.tf` defines a `gateway_references` local that maps logical names (e.g. `"igw-sandbox"`, `"nat-sandbox-0"`, `"vpce-netfw"`) to actual AWS resource IDs at apply time. Route table entries in `input.tfvars` use these logical names; `RouteTable/main.tf` resolves them. When adding a new routable gateway, add it to the `gateway_references` local.

**NAT Gateway lives in `main.tf`, not the VPC module** — NAT GW creation was moved out of `golden_modules/VPC` because it needs actual subnet IDs from the `Subnet` module. The VPC module accepts `enable_nat_gateway = false` and `nat_gateway_count = 0` — NAT resources are managed directly in `aws_sandbox/main.tf` via `aws_eip.nat` and `aws_nat_gateway.this`.

**Flattened composite keys** — NACLs, SG rules, and route entries all use `for` + `flatten` patterns with composite keys like `"${rt_key}_${idx}"` to produce flat maps for `for_each`. This is the standard pattern to follow when adding new multi-rule resources.

**Everything is data-driven** — no CIDR, rule number, or resource name is hardcoded in module logic. All values come from `input.tfvars` variables. Adding a subnet, route, or firewall rule means only editing `input.tfvars`.

### Network Layout

```
10.10.0.0/16 (VPC)
├── public-a    10.10.0.0/25    — public-facing, maps public IPs
├── firewall-a  10.10.0.128/27  — Network Firewall endpoints only
└── private-a   10.10.4.0/22    — private workloads, routed via firewall
```

Traffic from the internet hits the IGW → firewall subnet (inspection) → public/private subnets. The IGW edge route table (`igw-edge-rt`) steers inbound traffic through the firewall endpoint.

### Budget Automation

`golden_modules/Automation/lambda_handler.py` is triggered when spend reaches 95% of the configured budget. It stops all EC2 and RDS instances tagged `Environment = <env>` and publishes a summary to SNS. Requires `ENVIRONMENT` and `SNS_TOPIC` environment variables set on the Lambda function.

## CI/CD (Azure Pipelines)

`azure-pipelines.yml` runs on PRs targeting `main`. It auto-detects the Terraform version from `aws_sandbox/terraform.tf`, installs it, federates into AWS via OIDC, then runs `init → validate → plan → apply`. Direct push triggers are disabled (`trigger: none`).

Provider version is pinned to `hashicorp/aws = 6.37.0` — update both `terraform.tf` and the lock file (`terraform.lock.hcl`) together when upgrading.
