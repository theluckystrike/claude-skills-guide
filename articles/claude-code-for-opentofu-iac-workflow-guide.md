---
layout: default
title: "Claude Code for OpenTofu IaC"
description: "Write infrastructure as code with OpenTofu and Claude Code. Tested setup with copy-paste CLAUDE.md config."
date: 2026-04-18
permalink: /claude-code-for-opentofu-iac-workflow-guide/
render_with_liquid: false
categories: [workflow, niche-tools]
tags: [claude-code, opentofu, workflow]
---

## The Setup

You are managing cloud infrastructure with OpenTofu, the open-source fork of Terraform maintained by the Linux Foundation. OpenTofu is API-compatible with Terraform but adds features like client-side state encryption. Claude Code can write OpenTofu configurations, but it generates Terraform-specific patterns that differ in key areas and misses OpenTofu-exclusive features.

## What Claude Code Gets Wrong By Default

1. **References Terraform Cloud for state management.** Claude configures `terraform { cloud { } }` backend. OpenTofu does not support Terraform Cloud — use S3, GCS, or other open backends, with optional client-side state encryption.

2. **Uses Terraform-specific provider constraints.** Claude writes `required_providers` with HashiCorp registry paths that may not resolve correctly. OpenTofu uses the same provider ecosystem but has its own registry and resolution logic.

3. **Misses state encryption.** Claude stores state in plain text. OpenTofu supports client-side state encryption — a feature not available in Terraform. Configure `encryption { }` block for encrypted state files.

4. **Uses `terraform` CLI commands.** Claude writes `terraform plan`, `terraform apply`. OpenTofu uses `tofu plan`, `tofu apply` — the CLI binary is `tofu`, not `terraform`.

## The CLAUDE.md Configuration

```
# OpenTofu Infrastructure

## IaC Tool
- Tool: OpenTofu (open-source Terraform fork)
- CLI: tofu (NOT terraform)
- State: S3 backend with client-side encryption
- Config: .tf files in infra/ directory

## OpenTofu Rules
- CLI: tofu init, tofu plan, tofu apply
- State encryption: encryption { } block in backend config
- Providers: from OpenTofu registry or custom sources
- Modules: reusable in modules/ directory
- Variables: variables.tf, terraform.tfvars
- Outputs: outputs.tf for exported values
- No Terraform Cloud — use open backends (S3, GCS, etc.)

## Conventions
- Infrastructure in infra/ directory
- Environment configs: infra/envs/dev/, infra/envs/prod/
- Shared modules: infra/modules/
- State per environment in separate S3 paths
- Use tofu fmt for formatting
- Always run tofu plan before tofu apply
- Lock provider versions in required_providers
- Never store state locally in production
```

## Workflow Example

You want to provision a VPC with subnets and an RDS instance. Prompt Claude Code:

"Create OpenTofu configuration for an AWS VPC with public and private subnets across 3 AZs, a NAT gateway, and an RDS PostgreSQL instance in the private subnets. Use modules for reusability and enable state encryption."

Claude Code should create modular `.tf` files using `tofu`-compatible syntax, define the VPC module with subnet CIDR calculations, configure the RDS instance with proper security groups, set up the S3 backend with `encryption { }` block, and use variables for environment-specific values.

## Common Pitfalls

1. **Using `terraform` command by muscle memory.** Claude writes `terraform plan` in scripts and CI configs. OpenTofu uses `tofu` as the CLI binary. All commands are identical except the binary name — search-replace `terraform` with `tofu`.

2. **Provider version pinning drift.** Claude uses `>= 5.0` for provider versions. Pin exact versions with `= 5.30.0` or narrow ranges to prevent unexpected breaking changes when providers update.

3. **State encryption key management.** Claude hardcodes the encryption passphrase in the config. Use environment variables or a key management service for the encryption key. Never commit encryption keys to version control.

## Related Guides

- [Best Claude Skills for DevOps and Deployment](/best-claude-skills-for-devops-and-deployment/)
- [Claude Code Atlantis Terraform Automation](/claude-code-atlantis-terraform-automation/)
- [Best Way to Use Claude Code with Existing CI/CD](/best-way-to-use-claude-code-with-existing-ci-cd/)
