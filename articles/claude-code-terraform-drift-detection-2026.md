---
layout: default
title: "Claude Code for Terraform Drift (2026)"
description: "Claude Code for Terraform Drift — practical guide with working examples, tested configurations, and tips for developer workflows."
permalink: /claude-code-terraform-drift-detection-2026/
date: 2026-04-20
last_tested: "2026-04-21"
---

## Why Claude Code for Terraform Drift

Infrastructure drift is the silent killer of IaC (Infrastructure as Code) practices. Someone clicks in the AWS console, a Lambda function gets manually updated, a security group rule is added outside Terraform, and now your state file lies about what actually exists in production. When you run `terraform plan` three months later, you get 47 unexpected changes and no idea which ones are intentional.

Claude Code generates drift detection pipelines that run terraform plan on a schedule, parse the JSON output to classify changes by severity, and produce actionable reports that distinguish "someone added a tag" from "someone opened port 22 to the world."

## The Workflow

### Step 1: Setup

```bash
# Terraform and analysis tools
brew install terraform jq
pip install python-terraform pydantic structlog

# Project structure
mkdir -p drift/{scripts,reports,remediation,tests}
```

### Step 2: Drift Analysis Pipeline

```python
# drift/scripts/analyze_drift.py
"""Analyze Terraform plan output for infrastructure drift."""
import json
import subprocess
from pathlib import Path
from dataclasses import dataclass, field
from datetime import datetime

MAX_RESOURCES = 10000
CRITICAL_RESOURCE_TYPES = {
    "aws_security_group_rule",
    "aws_iam_role_policy",
    "aws_iam_policy_attachment",
    "aws_kms_key",
    "aws_s3_bucket_policy",
    "aws_s3_bucket_public_access_block",
    "aws_rds_cluster",
    "aws_db_instance",
}

HIGH_RISK_ATTRIBUTES = {
    "ingress", "egress",           # security group rules
    "policy",                       # IAM policies
    "publicly_accessible",          # RDS
    "encrypted", "kms_key_id",     # encryption
    "block_public_acls",           # S3 public access
    "vpc_security_group_ids",      # network access
}


@dataclass
class DriftItem:
    resource_type: str
    resource_name: str
    action: str            # create, update, delete, read
    severity: str          # CRITICAL, HIGH, MEDIUM, LOW
    changed_attributes: list
    before_values: dict
    after_values: dict


@dataclass
class DriftReport:
    timestamp: str
    workspace: str
    total_resources: int
    drifted_resources: int
    items: list = field(default_factory=list)
    critical_count: int = 0
    high_count: int = 0


def run_terraform_plan(tf_dir: str) -> dict:
    """Run terraform plan and return JSON output."""
    assert Path(tf_dir).is_dir(), f"Not a directory: {tf_dir}"

    # Refresh state first
    result = subprocess.run(
        ["terraform", "plan", "-refresh-only",
         "-out=drift.tfplan", "-no-color"],
        capture_output=True, text=True, cwd=tf_dir,
        timeout=600)
    assert result.returncode == 0, \
        f"Terraform plan failed: {result.stderr[:500]}"

    # Convert to JSON
    json_result = subprocess.run(
        ["terraform", "show", "-json", "drift.tfplan"],
        capture_output=True, text=True, cwd=tf_dir)
    assert json_result.returncode == 0, "Failed to export plan JSON"

    plan = json.loads(json_result.stdout)
    assert "resource_changes" in plan, "Invalid plan output"

    return plan


def classify_severity(resource_type: str,
                      changed_attrs: list) -> str:
    """Classify drift severity based on resource type and attributes."""
    if resource_type in CRITICAL_RESOURCE_TYPES:
        return "CRITICAL"

    has_high_risk = any(
        attr in HIGH_RISK_ATTRIBUTES for attr in changed_attrs)
    if has_high_risk:
        return "HIGH"

    if any(attr in ("tags", "tags_all") for attr in changed_attrs):
        return "LOW"

    return "MEDIUM"


def analyze_plan(plan: dict, workspace: str = "default") -> DriftReport:
    """Analyze terraform plan JSON for drift."""
    changes = plan.get("resource_changes", [])
    assert len(changes) <= MAX_RESOURCES, \
        f"Too many resources: {len(changes)}"

    report = DriftReport(
        timestamp=datetime.utcnow().isoformat(),
        workspace=workspace,
        total_resources=len(changes),
        drifted_resources=0,
    )

    for change in changes:
        actions = change.get("change", {}).get("actions", [])

        # Skip no-op resources
        if actions == ["no-op"] or actions == ["read"]:
            continue

        resource_type = change.get("type", "unknown")
        resource_name = change.get("address", "unknown")
        before = change.get("change", {}).get("before", {}) or {}
        after = change.get("change", {}).get("after", {}) or {}

        # Find changed attributes
        changed_attrs = []
        all_keys = set(list(before.keys()) + list(after.keys()))
        for key in all_keys:
            if before.get(key) != after.get(key):
                changed_attrs.append(key)

        if not changed_attrs:
            continue

        severity = classify_severity(resource_type, changed_attrs)

        item = DriftItem(
            resource_type=resource_type,
            resource_name=resource_name,
            action="+".join(actions),
            severity=severity,
            changed_attributes=changed_attrs,
            before_values={k: before.get(k) for k in changed_attrs},
            after_values={k: after.get(k) for k in changed_attrs},
        )
        report.items.append(item)
        report.drifted_resources += 1

        if severity == "CRITICAL":
            report.critical_count += 1
        elif severity == "HIGH":
            report.high_count += 1

    return report


def generate_remediation(report: DriftReport, output_path: str) -> None:
    """Generate remediation script to resolve drift."""
    assert len(report.items) > 0, "No drift to remediate"

    lines = [
        "#!/bin/bash",
        f"# Drift remediation generated {report.timestamp}",
        f"# Workspace: {report.workspace}",
        f"# Drifted resources: {report.drifted_resources}",
        "",
        "set -euo pipefail",
        "",
    ]

    for item in report.items:
        lines.append(f"# {item.severity}: {item.resource_name}")
        lines.append(f"# Changed: {', '.join(item.changed_attributes)}")

        if item.action == "update":
            lines.append(
                f"# Option 1: Import actual state")
            lines.append(
                f"# terraform import {item.resource_name} <resource-id>")
            lines.append(
                f"# Option 2: Apply to restore declared state")
            lines.append(
                f"terraform apply -target={item.resource_name} -auto-approve")
        elif item.action == "create":
            lines.append(
                f"# Resource exists in config but not in cloud — apply")
            lines.append(
                f"terraform apply -target={item.resource_name} -auto-approve")
        elif item.action == "delete":
            lines.append(
                f"# Resource exists in cloud but not in config — import or remove")
            lines.append(
                f"# terraform state rm {item.resource_name}")

        lines.append("")

    with open(output_path, 'w') as f:
        f.write("\n".join(lines))
    print(f"Remediation script: {output_path}")


def print_report(report: DriftReport) -> None:
    """Print drift report summary."""
    print(f"\nTerraform Drift Report — {report.workspace}")
    print(f"{'='*60}")
    print(f"Total resources: {report.total_resources}")
    print(f"Drifted:         {report.drifted_resources}")
    print(f"Critical:        {report.critical_count}")
    print(f"High:            {report.high_count}")

    for item in sorted(report.items,
                       key=lambda x: {"CRITICAL": 0, "HIGH": 1,
                                      "MEDIUM": 2, "LOW": 3}[x.severity]):
        print(f"\n  [{item.severity}] {item.resource_name}")
        print(f"  Action: {item.action}")
        print(f"  Changed: {', '.join(item.changed_attributes)}")


if __name__ == "__main__":
    import sys
    assert len(sys.argv) >= 2, \
        "Usage: python analyze_drift.py <terraform_directory>"

    plan = run_terraform_plan(sys.argv[1])
    report = analyze_plan(plan)
    print_report(report)

    if report.drifted_resources > 0:
        generate_remediation(report, "reports/remediation.sh")
```

### Step 3: Schedule and Validate

```bash
# Run drift detection
python3 drift/scripts/analyze_drift.py /path/to/terraform/
# Expected: drift report with severity classifications

# Schedule via cron or CI
# 0 6 * * * cd /terraform && python3 drift/scripts/analyze_drift.py . >> drift.log 2>&1
```

## CLAUDE.md for Terraform Drift

```markdown
# Terraform Drift Detection Rules

## Standards
- Terraform 1.7+ (JSON plan output)
- AWS/GCP/Azure provider best practices
- CIS Benchmarks for cloud security

## File Formats
- .tf (Terraform configuration)
- .tfplan (binary plan)
- .json (plan export)
- .sh (remediation scripts)

## Libraries
- terraform CLI 1.7+
- jq (JSON processing)
- python-terraform (Python wrapper)
- pydantic (report validation)

## Testing
- Drift detection must run without applying changes
- Severity classification: test with known drift patterns
- Remediation scripts must be reviewed before execution

## Severity Classification
- CRITICAL: IAM, security groups, encryption, public access
- HIGH: network rules, database config, KMS
- MEDIUM: compute config, storage settings
- LOW: tags, descriptions, non-functional attributes
```

## Common Pitfalls

- **Plan-time errors hiding drift:** If terraform plan fails on one resource, it may skip others. Claude Code runs `terraform plan -refresh-only` first and handles partial failures separately.
- **Tag-only drift noise:** Auto-applied tags (AWS Cost Allocation, etc.) cause constant drift reports. Claude Code classifies tag-only changes as LOW severity and supports an ignore list.
- **Remediation without approval:** Auto-applying terraform to fix drift can break things. Claude Code generates remediation scripts for human review, not auto-execution.

## Related

- [Claude Code for SOC 2 Evidence](/claude-code-soc2-evidence-collection-2026/)
- [Claude Code for Beginners](/claude-code-for-beginners-complete-getting-started-2026/)
- [CLAUDE.md File Guide](/claude-md-file-complete-guide-what-it-does/)


## Frequently Asked Questions

### Do I need a paid Anthropic plan to use this?

Claude Code works with any Anthropic API plan, including the free tier. However, the free tier has lower rate limits (requests per minute and tokens per minute) that may slow down multi-step workflows. For professional use, the Build or Scale plan provides higher limits and priority access during peak hours.

### How does this affect token usage and cost?

The token cost depends on the size of your prompts and Claude's responses. Typical development tasks consume 10K-50K tokens per interaction. Using a CLAUDE.md file and skills reduces exploration tokens by 50-80%, which directly lowers costs. Monitor your usage at console.anthropic.com/settings/billing.

### Can I customize this for my specific project?

Yes. All Claude Code behavior can be customized through CLAUDE.md (project rules), `.claude/settings.json` (permissions), and `.claude/skills/` (domain knowledge). The most impactful customization is adding your project's specific patterns, conventions, and common commands to CLAUDE.md so Claude Code follows your standards from the start.

### What happens when Claude Code makes a mistake?

Claude Code creates files and edits through standard filesystem operations, so all changes are visible in `git diff`. If a change is wrong, revert it with `git checkout -- <file>` for a single file or `git stash` for all changes. Claude Code does not make irreversible changes unless you explicitly allow destructive commands in settings.json.


## Practical Details

When working with Claude Code on this topic, keep these implementation details in mind:

**Project Configuration.** Your CLAUDE.md should include specific references to how your project handles this area. Include file paths, naming conventions, and any project-specific patterns that differ from defaults. Claude Code reads this file at session start and uses it to guide all operations.

**Integration with Existing Tools.** Claude Code works alongside your existing development tools rather than replacing them. It respects .gitignore for file visibility, uses your project's installed dependencies, and follows the build/test scripts defined in package.json (or equivalent). Ensure your toolchain is working correctly before involving Claude Code.

**Performance Considerations.** For large codebases (10,000+ files), Claude Code's file scanning can be slow if not properly scoped. Use `.claudeignore` to exclude generated directories (dist, build, .next, coverage) and dependency directories (node_modules, vendor). This typically reduces scan time by 80-90%.

**Version Control Integration.** All changes Claude Code makes are regular filesystem operations visible to git. Use `git diff` after each significant change to review what was modified. For experimental changes, create a branch first with `git checkout -b experiment/topic` so you can easily discard or keep the results.


## Related Guides

- [Migrate Terraform Backends with Claude](/claude-code-for-terraform-backend-migration-workflow/)
- [Claude Code Terraform Cloud Workflow](/claude-code-terraform-cloud-workflow-guide/)
- [Terraform with Claude Code](/claude-code-for-terraform-workflow-tutorial-guide/)
- [Claude Code Skills for Terraform IaC](/claude-code-skills-for-infrastructure-as-code-terraform/)

<script type="application/ld+json">
{
  "@context": "https://schema.org",
  "@type": "FAQPage",
  "mainEntity": [
    {
      "@type": "Question",
      "name": "Do I need a paid Anthropic plan to use this?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "Claude Code works with any Anthropic API plan, including the free tier. However, the free tier has lower rate limits (requests per minute and tokens per minute) that may slow down multi-step workflows. For professional use, the Build or Scale plan provides higher limits and priority access during peak hours."
      }
    },
    {
      "@type": "Question",
      "name": "How does this affect token usage and cost?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "The token cost depends on the size of your prompts and Claude's responses. Typical development tasks consume 10K-50K tokens per interaction. Using a CLAUDE.md file and skills reduces exploration tokens by 50-80%, which directly lowers costs. Monitor your usage at console.anthropic.com/settings/billing."
      }
    },
    {
      "@type": "Question",
      "name": "Can I customize this for my specific project?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "Yes. All Claude Code behavior can be customized through CLAUDE.md (project rules), `.claude/settings.json` (permissions), and `.claude/skills/` (domain knowledge). The most impactful customization is adding your project's specific patterns, conventions, and common commands to CLAUDE.md so Claude Code follows your standards from the start."
      }
    },
    {
      "@type": "Question",
      "name": "What happens when Claude Code makes a mistake?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "Claude Code creates files and edits through standard filesystem operations, so all changes are visible in `git diff`. If a change is wrong, revert it with `git checkout -- <file>` for a single file or `git stash` for all changes. Claude Code does not make irreversible changes unless you explicitly allow destructive commands in settings.json. When working with Claude Code on this topic, keep these implementation details in mind: **Project Configuration.** Your CLAUDE.md should include specific references to how your project handles this area. Include file paths, naming conventions, and any project-specific patterns that differ from defaults. Claude Code reads this file at session start and uses it to guide all operations. **Integration with Existing Tools.** Claude Code works alongside your existing development tools rather than replacing them. It respects .gitignore for file visibility, uses your project's installed dependencies, and follows the build/test scripts defined in package.json (or equivalent). Ensure your toolchain is working correctly before involving Claude Code. **Performance Considerations.** For large codebases (10,000+ files), Claude Code's file scanning can be slow if not properly scoped. Use `.claudeignore` to exclude generated directories (dist, build, .next, coverage) and dependency directories (node_modules, vendor). This typically reduces scan time by 80-90%. **Version Control Integration.** All changes Claude Code makes are regular filesystem operations visible to git. Use `git diff` after each significant change to review what was modified. For experimental changes, create a branch first with `git checkout -b experiment/topic` so you can easily discard or keep the results."
      }
    }
  ]
}
</script>
