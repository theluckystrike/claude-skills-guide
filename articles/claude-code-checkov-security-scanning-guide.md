---
layout: default
title: "Claude Code Checkov Security Scanning Guide"
description: "Learn how to integrate Checkov static analysis into your Claude Code workflow to automatically detect security misconfigurations in infrastructure-as-code and cloud deployments."
date: 2026-03-14
author: theluckystrike
permalink: /claude-code-checkov-security-scanning-guide/
---

# Claude Code Checkov Security Scanning Guide

Infrastructure-as-code has revolutionized how teams provision and manage cloud resources, but it has also introduced new security attack surfaces. Misconfigured Terraform, CloudFormation, Kubernetes manifests, and Dockerfiles can expose your infrastructure to serious vulnerabilities. Checkov, an open-source static code analysis tool, scans infrastructure definitions for security and compliance issues before deployment. Integrating Checkov into your Claude Code workflow transforms infrastructure security from a manual review process into an automated guardrail.

## What Checkov Detects

Checkov performs static analysis on infrastructure code across multiple frameworks. The tool ships with over 800 built-in policy checks covering common misconfigurations. For Terraform files, it detects issues like unsecured S3 buckets, overly permissive IAM policies, missing encryption at rest, and public RDS instances. In Kubernetes manifests, Checkov identifies privileged containers, missing resource limits, insecure security contexts, and network policies that are too permissive. Dockerfiles get scanned for exposed sensitive ports, usage of vulnerable base images, and running processes as root.

The tool categorizes findings by severity—critical, high, medium, low, and informational—so you can prioritize remediation efforts. Each policy check includes a description explaining the security risk and remediation guidance. This makes Checkov an excellent companion for Claude Code because the AI can parse these findings and help you write corrected infrastructure code.

## Setting Up Checkov with Claude Code

The installation process takes moments. Checkov runs as a Python package, so you need Python 3.8 or later on your system:

```bash
pip install checkov
```

Verify the installation by running:

```bash
checkov --version
```

You should see output displaying the installed version number. Once Checkov is available, you can invoke it directly from within Claude Code using bash commands. The integration requires no special skills—you simply call the `checkov` binary as part of your workflow.

## Running Your First Scan

Navigate to a directory containing your infrastructure code and run Checkov:

```bash
checkov -d ./terraform/aws-production
```

The `-d` flag tells Checkov to scan a directory. For individual files, use the `-f` flag instead:

```bash
checkov -f main.tf
```

Checkov outputs results directly to your terminal. The summary shows the total number of passed and failed checks, broken down by severity. Each failed check includes the policy ID, resource affected, and a one-line explanation of the issue.

For more detailed output in a format Claude can parse easily, export results to JSON:

```bash
checkov -d ./terraform/aws-production --output json > checkov-results.json
```

The JSON output provides structured data that Claude Code can process programmatically. You can ask Claude to summarize findings, explain specific failures, or generate corrected infrastructure code based on the scan results.

## Integrating Checkov into Claude Code Workflows

The real power emerges when you make Checkov part of your daily development cycle. Here is a practical workflow for infrastructure development:

### 1. Pre-Commit Scanning

Create a pre-commit hook that runs Checkov before any infrastructure changes enter your repository:

```bash
#!/bin/bash
# .git/hooks/pre-commit

terraform_dirs=$(find . -name "*.tf" -type f | xargs dirname | sort -u)

for dir in $terraform_dirs; do
    checkov -d "$dir" --soft-fail
    if [ $? -ne 0 ]; then
        echo "Security issues found. Commit blocked."
        exit 1
    fi
done
```

This hook scans all Terraform directories in your repository. The `--soft-fail` flag ensures Checkov returns a non-zero exit code on findings, which blocks the commit while still displaying results.

### 2. Claude-Assisted Remediation

When Checkov reports failures, paste the output into Claude and ask for help:

```
These Checkov findings appeared in my Terraform code. Explain each issue and provide corrected configuration:

[paste Checkov output here]
```

Claude analyzes the findings, explains the security implications, and generates fixed Terraform code. This turns remediation from a research task into a collaborative debugging session.

### 3. CI/CD Pipeline Integration

Add Checkov to your GitHub Actions workflow for automated scanning on pull requests:

```yaml
name: Infrastructure Security Scan

on: [pull_request]

jobs:
  checkov:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: bridgecrewio/checkov-action@master
        with:
          directory: terraform/
          framework: terraform
          output_format: sarif
          output_file_path: results.sarif
      - uses: github/codeql-action/upload-sarif@v3
        with:
          sarif_file: results.sarif
```

This configuration runs Checkov on every pull request and uploads results as SARIF format, which GitHub displays as code scanning alerts. The integration requires no additional skills—just standard CI/CD configuration.

## Scanning Specific Frameworks

Checkov supports numerous infrastructure frameworks. Here is how to target specific resources:

**Kubernetes manifests:**

```bash
checkov -f deployment.yaml --framework kubernetes
```

**Dockerfiles:**

```bash
checkov -f Dockerfile --framework dockerfile
```

**CloudFormation templates:**

```bash
checkov -f template.yaml --framework cloudformation
```

**ARM templates:**

```bash
checkov -f template.json --framework arm
```

You can also scan multiple frameworks simultaneously or let Checkov auto-detect the file types present in your directory.

## Custom Policy Development

When built-in policies do not cover your organization's specific requirements, Checkov allows custom policy creation. Write policies in Python and register them in your Checkov configuration:

```python
# custom_policies/no_public_buckets.py
from checkov.common.models.enums import CheckResult, CheckCategories
from checkov.terraform.checks.resource.base_resource_check import BaseResourceCheck

class S3BucketNotPublic(BaseResourceCheck):
    def __init__(self):
        super().__init__(
            name="S3 Bucket should not be public",
            id="CUSTOM_001",
            categories=[CheckCategories.ENCRYPTION],
            supported_resources=["aws_s3_bucket"]
        )

    def scan_resource_conf(self, conf):
        acl = conf.get("acl", [])
        if "public-read" in acl or "public-read-write" in acl:
            return CheckResult.FAILED
        return CheckResult.PASSED

check = S3BucketNotPublic()
```

Place this file in a custom policies directory and reference it when running scans. Claude Code can help you write custom policies by describing your organization's security requirements.

## Suppressing False Positives

Some findings may not apply to your specific context. Checkov supports suppression comments directly in your infrastructure code:

```hcl
resource "aws_s3_bucket" "audit_logs" {
  bucket = "company-audit-logs"

  # checkov:skip=CKV_AWS_18:This bucket is intentionally public for analytics
  acl    = "public-read"
}
```

The skip comment includes the Checkov ID and a reason. This documentation approach ensures your team understands why certain controls are bypassed while preventing the same finding from appearing in future scans.

## Combining Checkov with Claude Skills

For comprehensive security automation, combine Checkov with other Claude Code capabilities. The **tdd** skill helps you write test cases that verify your infrastructure behaves as expected after remediation. The **pdf** skill can generate formatted security reports from Checkov JSON output for stakeholder distribution. The **supermemory** skill maintains a knowledge base of recurring issues and their solutions across your infrastructure codebase.

This multi-skill approach turns infrastructure security from a point-in-time scan into a continuous improvement practice. Claude becomes your security partner—running scans, explaining findings, generating fixes, and documenting the remediation process.

Built by theluckystrike — More at [zovo.one](https://zovo.one)
