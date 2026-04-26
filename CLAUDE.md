# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is an AWS Solutions Architect Associate learning repository containing Terraform infrastructure examples. The project uses LocalStack for local AWS service emulation and includes security scanning (tfsec) and cost estimation (infracost) in the development workflow.

## Development Environment

**Prerequisites:**
- Terraform (managed via tfenv, version specified in `.terraform-version`)
- Docker and Docker Compose (for LocalStack)
- tfsec (security scanner): https://github.com/aquasecurity/tfsec
- infracost (cost estimator): https://oneuptime.com/blog/post/2026-01-26-infracost-iac-cost/view
- LocalStack Auth Token set in environment: `LOCALSTACK_AUTH_TOKEN`

**LocalStack Setup:**
```bash
# Start LocalStack (provides: S3, DynamoDB, IAM, KMS, STS, Lambda)
make start

# Stop LocalStack
make stop

# Clean up LocalStack (removes volumes and data)
make clean
```

LocalStack is configured to run on `localhost:4566` with optional persistence via the `PERSISTENCE` environment variable.

## Repository Structure

The repository contains three main Terraform projects:

1. **backends/** - Terraform backend infrastructure (S3 bucket + DynamoDB table for state management)
   - Uses modular structure with separate `s3/` and `dynamodb/` submodules
   - Creates state bucket and lock table for other projects

2. **s3-bucket/** - Simple S3 bucket example
   - References backend created by `backends/`

3. **images-storage/** - Complete application stack with S3, DynamoDB, and Lambda
   - Lambda function triggered by S3 events
   - Python code in `code.py` writes image metadata to DynamoDB
   - Modular structure: `s3/`, `dynamodb/`, `lambda/` submodules

## Terraform Workflow

Each project directory contains a Makefile with standardized commands:

```bash
# Initialize and validate (includes tfsec security scan)
make validate

# Show cost estimate
make cost

# Plan changes (runs validate + cost first)
make plan

# Apply changes (runs validate first)
make apply

# Force apply without validation
make force-apply

# Destroy infrastructure
make clean

# Force clean (removes all Terraform files without destroy)
make force-clean
```

**Important Workflow Notes:**
- `make validate` runs both `terraform validate` and `tfsec` security scanning
- `make plan` automatically runs validation and cost estimation
- All Makefiles follow the same pattern for consistency
- Projects use remote state backends (except `backends/` itself, which creates the backend)

## Provider Configuration

All projects are configured for **LocalStack by default**. Provider files (`provider.tf`) contain commented-out AWS configurations.

**To switch from LocalStack to AWS:**
1. Uncomment the AWS provider block in `provider.tf`
2. Comment out the LocalStack provider configuration
3. Update `backend.tf` to use AWS endpoints (comment LocalStack endpoints)
4. Ensure AWS credentials are configured (`aws configure`)

**LocalStack Endpoints:**
- Uses `http://localhost:4566` for most services
- S3 uses `http://s3.localhost.localstack.cloud:4566` for proper path-style access
- Provider configured with test credentials (access_key/secret_key = "test")
- `skip_credentials_validation` and `skip_metadata_api_check` enabled

## Terraform Backend

Projects use S3 remote backend with DynamoDB state locking:
- Bucket: `aws-solutions-architect-tf-states`
- DynamoDB Table: `aws-solutions-architect-tf-states-locks`
- State encryption enabled

The `backends/` project must be applied first to create these resources.

## Module Pattern

Projects use a consistent module pattern:
1. Root `main.tf` defines locals (tags, identifiers, CIDRs)
2. Submodules in dedicated directories (`s3/`, `dynamodb/`, `lambda/`)
3. Data passed between modules via outputs
4. Common tags applied via locals

## Security Scanning

tfsec runs automatically during `make validate` and `make plan`. It scans for:
- Security misconfigurations
- Best practice violations
- Uses `--tfvars-file=terraform.tfvars` to include variable values in scans

## Cost Estimation

infracost runs automatically during `make cost` and `make plan`. Shows estimated AWS costs for planned infrastructure changes.
