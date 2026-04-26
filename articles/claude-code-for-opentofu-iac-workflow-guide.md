---
layout: default
title: "Claude Code for OpenTofu IaC (2026)"
description: "Claude Code for OpenTofu IaC — practical guide with working examples, tested configurations, and tips for developer workflows."
date: 2026-04-18
permalink: /claude-code-for-opentofu-iac-workflow-guide/
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


## Frequently Asked Questions

### What is the minimum setup required?

You need Claude Code installed (Node.js 18+), a project with a `CLAUDE.md` file, and the relevant toolchain for your project type (e.g., npm for JavaScript, pip for Python). The CLAUDE.md file should describe your project structure, conventions, and common commands so Claude Code can work effectively.

### How long does the initial setup take?

For a typical project, initial setup takes 10-20 minutes. This includes creating the CLAUDE.md file, configuring `.claude/settings.json` for permissions, and running a test task to verify everything works. Subsequent sessions start immediately because the configuration persists.

### Can I use this with a team?

Yes. Commit your `.claude/` directory and `CLAUDE.md` to version control so the entire team uses the same configuration. Each developer can add personal preferences in `~/.claude/settings.json` (user-level) without affecting the project configuration. Review CLAUDE.md changes in pull requests like any other configuration file.

### What if Claude Code produces incorrect output?

First check that your CLAUDE.md accurately describes your project conventions. Incorrect or outdated context is the most common cause of wrong output. If the output is still wrong, provide feedback in the same session — Claude Code learns from corrections within a conversation. For persistent issues, add explicit rules to CLAUDE.md (e.g., "Always use single quotes" or "Never modify files in the config/ directory").


<script type="application/ld+json">
{
  "@context": "https://schema.org",
  "@type": "FAQPage",
  "mainEntity": [
    {
      "@type": "Question",
      "name": "What is the minimum setup required?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "You need Claude Code installed (Node.js 18+), a project with a CLAUDE.md file, and the relevant toolchain for your project type (e.g., npm for JavaScript, pip for Python). The CLAUDE.md file should describe your project structure, conventions, and common commands so Claude Code can work effectively."
      }
    },
    {
      "@type": "Question",
      "name": "How long does the initial setup take?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "For a typical project, initial setup takes 10-20 minutes. This includes creating the CLAUDE.md file, configuring .claude/settings.json for permissions, and running a test task to verify everything works. Subsequent sessions start immediately because the configuration persists."
      }
    },
    {
      "@type": "Question",
      "name": "Can I use this with a team?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "Yes. Commit your .claude/ directory and CLAUDE.md to version control so the entire team uses the same configuration. Each developer can add personal preferences in ~/.claude/settings.json (user-level) without affecting the project configuration."
      }
    },
    {
      "@type": "Question",
      "name": "What if Claude Code produces incorrect output?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "First check that your CLAUDE.md accurately describes your project conventions. Incorrect or outdated context is the most common cause of wrong output. If the output is still wrong, provide feedback in the same session — Claude Code learns from corrections within a conversation."
      }
    }
  ]
}
</script>
