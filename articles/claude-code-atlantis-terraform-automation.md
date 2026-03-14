---
layout: default
title: "Claude Code Atlantis Terraform Automation"
description: "Learn how to combine Claude Code with Atlantis for automated Terraform pull request workflows. Practical examples for infrastructure-as-code teams."
date: 2026-03-14
author: theluckystrike
permalink: /claude-code-atlantis-terraform-automation/
---
{% raw %}



# Claude Code Atlantis Terraform Automation

Infrastructure-as-code teams increasingly combine Claude Code with Atlantis to create powerful Terraform automation pipelines. This combination allows you to leverage AI-assisted infrastructure planning while maintaining established pull request workflows. The result is faster infrastructure changes with better review processes.

## What is Atlantis and Why Combine It With Claude Code?

Atlantis is an automation tool that runs Terraform commands in response to pull requests. When you open a PR modifying Terraform files, Atlantis automatically plans the changes and posts the output as comments. Team members review the plan before merging, and Atlantis then applies the changes. This workflow prevents accidental infrastructure modifications and ensures all changes receive proper review.

Claude Code enhances this workflow in several ways. First, Claude can generate Terraform configurations from high-level descriptions. Second, it can review existing Terraform code for security issues and best practices. Third, it can explain complex infrastructure changes to team members who may not be infrastructure specialists. The combination creates a pipeline where AI assists both creation and review of infrastructure code.

## Setting Up the Basic Workflow

The foundation of this automation requires configuring Atlantis to respond to your Git repository. Your Terraform configuration should exist in a repository with proper directory structure. Here is a practical example of how the workflow operates:

```hcl
# main.tf - Example AWS infrastructure
resource "aws_s3_bucket" "app_storage" {
  bucket = "my-app-storage-${var.environment}"
  
  tags = {
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

resource "aws_ec2_instance" "app_server" {
  ami           = var.ami_id
  instance_type = var.instance_type
  subnet_id     = aws_subnet.main.id
  
  tags = {
    Name = "app-server-${var.environment}"
  }
}
```

When you push this to your repository, Atlantis detects the changes and executes Terraform plan. The output appears as a PR comment, allowing reviewers to understand exactly what resources will be created, modified, or destroyed.

## Using Claude Code to Generate Terraform

One of the most valuable integrations involves using Claude Code to generate Terraform configurations. Rather than writing HCL from scratch, you describe your infrastructure requirements in natural language. Claude translates these descriptions into working Terraform code.

For instance, you might ask Claude to create an EKS cluster with specific node group configurations, or to set up an RDS instance with particular storage and backup requirements. Claude generates the necessary resource blocks, variables, and outputs. This approach accelerates infrastructure development significantly.

The integration works particularly well when combined with the tdd skill for infrastructure. You can describe the desired end state, and Claude produces the Terraform code to achieve it. After generation, Atlantis takes over the planning and application workflow.

## Automated Code Review With Claude

Beyond generation, Claude Code excels at reviewing Terraform code. When Atlantis posts a plan to your pull request, you can feed that output to Claude for analysis. Claude identifies potential issues such as missing tags, insecure configurations, or resources that might incur unexpected costs.

Consider this example of a potentially problematic Terraform configuration:

```hcl
# Problematic: No encryption, public access
resource "aws_s3_bucket" "sensitive_data" {
  bucket = "company-sensitive-data"
}

resource "aws_db_instance" "production" {
  identifier           = "production-db"
  engine               = "mysql"
  engine_version       = "8.0"
  instance_class       = "db.t3.micro"
  allocated_storage    = 20
  publicly_accessible = true  # Security risk
  skip_final_snapshot  = true  # Data loss risk
}
```

Claude would flag these issues: the S3 bucket lacks encryption and access controls, while the RDS instance allows public access and would lose data permanently upon deletion. The review happens before merge, preventing security incidents.

## Implementing the Combined Workflow

To implement Claude Code with Atlantis, follow these practical steps:

First, configure Atlantis in your infrastructure repository. Create an atlantis.yaml file that specifies how Atlantis should behave:

```yaml
version: 1
projects:
- name: production
  dir: .
  workspace: production
  terraform_version: 1.6.0
  apply_requirements: [approved, merged]
  plan_requirements: [approved, mergeable]
  import_requirements: []
  delete_source_branch_on_merge: true
```

Next, integrate Claude Code into your review process. When reviewing pull requests, share the Terraform plan output with Claude. Ask specific questions about security implications, cost estimates, and compliance with your infrastructure standards.

You can also use the frontend-design skill to generate documentation for your infrastructure. While primarily for web interfaces, this skill helps create visual documentation of your infrastructure architecture, which aids team communication.

## Advanced Patterns and Best Practices

For teams managing complex infrastructure, several advanced patterns enhance the Claude-Atlas combination.

Module reuse becomes more accessible when Claude generates standardized modules. Rather than copying configuration between projects, create modules that Claude can customize for specific use cases. Atlantis applies these modules consistently across environments.

The supermemory skill proves valuable for maintaining context across infrastructure changes. When modifying infrastructure over time, Claude can reference previous decisions stored in memory, ensuring consistency and preventing contradictory configurations.

For cost optimization, combine Claude with Infracost integration. Claude analyzes the Terraform plan and provides cost estimates before apply, helping teams make informed decisions about infrastructure spending.

## Common Challenges and Solutions

Teams adopting this workflow encounter several common challenges. One issue involves managing state across multiple environments. The solution involves using workspaces or separate state backends, which Atlantis supports natively.

Another challenge involves handling large Terraform plans that exceed token limits. Break your infrastructure into smaller modules that Atlantis can process independently. Claude can help refactor monolithic configurations into composable modules.

Security sensitive teams may worry about exposing infrastructure details to external AI services. Running Claude Code locally addresses this concern, as all processing occurs within your environment. The Atlantis workflow remains unchanged, while Claude provides local assistance.

## Conclusion

Combining Claude Code with Atlantis creates a robust infrastructure automation pipeline. Claude handles generation and review of Terraform code, while Atlantis manages the pull request workflow and apply execution. This combination accelerates infrastructure development while maintaining safety through automated planning and human review.

The workflow suits teams of all sizes, from small startups managing a few resources to enterprises running complex multi-environment deployments. By automating routine tasks and providing intelligent assistance, Claude Code and Atlantis together enable infrastructure teams to move faster without sacrificing quality or security.

Built by theluckystrike — More at [zovo.one](https://zovo.one)

{% endraw %}
