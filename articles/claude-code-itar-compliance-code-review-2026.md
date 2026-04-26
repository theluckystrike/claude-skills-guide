---
layout: default
title: "Claude Code for ITAR Compliance Code (2026)"
permalink: /claude-code-itar-compliance-code-review-2026/
date: 2026-04-20
description: "Enforce ITAR technical data controls with Claude Code. Detect export-controlled code patterns, validate access restrictions, and audit data flows."
last_tested: "2026-04-22"
domain: "export control compliance"
---

## Why Claude Code for ITAR Compliance

The International Traffic in Arms Regulations (ITAR) govern the export of defense-related articles and services, including technical data and software. Violations carry penalties up to $1 million per violation and 20 years imprisonment. Software development teams working on USML (United States Munitions List) Category XI (military electronics), Category XII (fire control), or Category XV (spacecraft) items must ensure that technical data never reaches non-US persons, that code repositories enforce access controls, and that cloud infrastructure stays within US boundaries.

Claude Code can audit code repositories for ITAR-controlled technical data patterns, verify that CI/CD pipelines enforce nationality-based access controls, and ensure cloud resources are provisioned only in US-sovereign regions. It identifies export-controlled algorithms, missile technology parameters, and classified data handling patterns that require DDTC authorization.

## The Workflow

### Step 1: Identify ITAR-Controlled Technical Data

```python
#!/usr/bin/env python3
"""ITAR technical data scanner for code repositories."""

import re
from dataclasses import dataclass
from pathlib import Path

# USML categories with code-detectable patterns
ITAR_INDICATORS = {
    "cat_xi_military_electronics": {
        "patterns": [
            r"radar.*cross.section", r"electronic.*countermeasure",
            r"jamming.*frequency", r"signal.*intelligence",
            r"crypto.*military", r"comsec", r"sigint",
            r"anti.tamper", r"tempest.*shielding"
        ],
        "usml_category": "XI - Military Electronics"
    },
    "cat_xii_fire_control": {
        "patterns": [
            r"fire.*control.*algorithm", r"ballistic.*trajectory",
            r"target.*acquisition", r"weapon.*guidance",
            r"inertial.*navigation.*military", r"kill.*probability",
            r"circular.*error.*probable", r"cep\s*[=<>]"
        ],
        "usml_category": "XII - Fire Control"
    },
    "cat_xv_spacecraft": {
        "patterns": [
            r"orbit.*determination", r"attitude.*control.*system",
            r"reaction.*wheel", r"star.*tracker.*algorithm",
            r"radiation.*hardening", r"space.*qualified",
            r"itar.*restricted", r"export.*controlled"
        ],
        "usml_category": "XV - Spacecraft and Related"
    },
    "missile_technology": {
        "patterns": [
            r"propulsion.*system.*design", r"rocket.*motor",
            r"warhead.*design", r"re.entry.*vehicle",
            r"guidance.*set", r"thrust.*vector.*control"
        ],
        "usml_category": "IV - Launch Vehicles/Missiles (MTCR)"
    }
}

@dataclass
class ITARFinding:
    file: str
    line: int
    category: str
    usml_category: str
    matched_pattern: str
    context: str
    severity: str

def scan_for_itar_content(filepath: Path) -> list[ITARFinding]:
    """Scan a file for potential ITAR-controlled technical data."""
    findings = []
    try:
        content = filepath.read_text(errors='ignore')
    except Exception:
        return findings

    lines = content.split('\n')

    for i, line in enumerate(lines, 1):
        line_lower = line.lower()
        for category, config in ITAR_INDICATORS.items():
            for pattern in config["patterns"]:
                if re.search(pattern, line_lower):
                    findings.append(ITARFinding(
                        file=str(filepath),
                        line=i,
                        category=category,
                        usml_category=config["usml_category"],
                        matched_pattern=pattern,
                        context=line.strip()[:150],
                        severity="CRITICAL"
                    ))
    return findings
```

### Step 2: Verify Access Controls and Data Boundaries

```python
def audit_access_controls(repo_path: str) -> dict:
    """Verify ITAR access control requirements."""
    import subprocess

    results = {"controls": []}

    # Check: Repository is private
    proc = subprocess.run(
        ['gh', 'repo', 'view', '--json', 'isPrivate,visibility'],
        capture_output=True, text=True, cwd=repo_path
    )
    if proc.returncode == 0:
        import json
        repo_info = json.loads(proc.stdout)
        results["controls"].append({
            "check": "repository_private",
            "status": "PASS" if repo_info.get("isPrivate") else "CRITICAL_FAIL",
            "detail": "ITAR technical data must NEVER be in a public repository"
        })

    # Check: All contributors are US persons
    proc = subprocess.run(
        ['gh', 'api', 'repos/{owner}/{repo}/collaborators',
         '--jq', '.[].login'],
        capture_output=True, text=True, cwd=repo_path
    )
    results["controls"].append({
        "check": "contributor_nationality_review",
        "status": "MANUAL_REVIEW",
        "detail": "All repository contributors must be verified US persons",
        "collaborators": proc.stdout.strip().split('\n') if proc.stdout.strip() else []
    })

    # Check: Cloud region restrictions
    for tf_file in Path(repo_path).rglob("*.tf"):
        content = tf_file.read_text()
        non_us_regions = re.findall(
            r'region\s*=\s*"(eu-|ap-|sa-|af-|me-|ca-)[^"]*"', content
        )
        if non_us_regions:
            results["controls"].append({
                "check": "cloud_region_us_only",
                "status": "CRITICAL_FAIL",
                "file": str(tf_file),
                "detail": f"Non-US regions detected: {non_us_regions}",
                "remediation": "ITAR data must reside in US regions only (us-east-*, us-west-*)"
            })

    # Check: No external API calls that could transmit technical data
    for code_file in Path(repo_path).rglob("*.py"):
        content = code_file.read_text(errors='ignore')
        external_apis = re.findall(
            r'(?:requests\.(?:get|post|put)|fetch|axios\.(?:get|post))\s*\(["\']https?://([^"\']+)',
            content
        )
        for api in external_apis:
            if not any(safe in api for safe in ['localhost', '127.0.0.1', '.mil', '.gov']):
                results["controls"].append({
                    "check": "external_data_transmission",
                    "status": "REVIEW",
                    "file": str(code_file),
                    "detail": f"External API call to {api} - verify no technical data transmitted"
                })

    return results
```

### Step 3: Generate Compliance Report

```python
def generate_itar_report(findings: list, access_audit: dict) -> dict:
    """Generate ITAR compliance report for export control officer."""
    critical = [f for f in findings if f.severity == "CRITICAL"]
    return {
        "report_type": "ITAR Code Review",
        "date": __import__('datetime').datetime.now().isoformat(),
        "summary": {
            "itar_indicators_found": len(findings),
            "critical_findings": len(critical),
            "usml_categories_detected": list(set(f.usml_category for f in findings)),
            "access_control_status": "REVIEW_REQUIRED"
        },
        "recommendation": (
            "STOP: This repository contains potential ITAR-controlled technical data. "
            "Engage Empowered Official before any external sharing, cloud deployment "
            "to non-US regions, or granting access to non-US persons."
            if critical else
            "No obvious ITAR indicators found. Periodic review recommended."
        ),
        "findings": [vars(f) for f in findings],
        "access_controls": access_audit
    }
```

### Step 4: Verify

```bash
# Run ITAR scan
python3 ~/itar-review/scanner.py \
  --repo /path/to/defense-project \
  --output ~/itar-review/findings.json

# Check access controls
python3 ~/itar-review/access_audit.py \
  --repo /path/to/defense-project \
  --output ~/itar-review/access-audit.json

# Generate report for Empowered Official
python3 ~/itar-review/report.py \
  --findings findings.json \
  --access access-audit.json \
  --output ~/Desktop/itar-review-report.html
```

## CLAUDE.md for ITAR Code Review

```markdown
# ITAR Compliance Code Review Standards

## Domain Rules
- ITAR technical data MUST NOT be accessible to non-US persons
- Repositories containing ITAR data MUST be private
- Cloud resources MUST be in US-only regions (us-east-*, us-west-*)
- No external SaaS/API transmissions of technical data without DDTC license
- All repository contributors must be verified US persons
- Export-controlled algorithms must be marked with ITAR notices
- ITAR-controlled source code is "defense services" under USML

## File Patterns
- Scan: *.py, *.c, *.cpp, *.h, *.java, *.rs, *.go, *.m, *.f90
- Config: *.tf, *.yaml, *.json (infrastructure boundary checks)
- Reports: reports/*.html (for Empowered Official review)
- Notices: ITAR_NOTICE.md (required in repository root)

## Common Commands
- python3 scanner.py --repo . --output findings.json
- gh repo view --json isPrivate
- gh api repos/{owner}/{repo}/collaborators
- aws sts get-caller-identity (verify account and region)
```

## Common Pitfalls in ITAR Compliance

- **GitHub Copilot and AI tools:** Code completion tools trained on public data may inadvertently suggest ITAR-controlled algorithms. Claude Code flags any auto-generated code that matches ITAR patterns for human review by the Empowered Official.

- **Cloud region drift:** Auto-scaling or disaster recovery configurations may provision resources in non-US regions. Claude Code adds region constraint checks to CI/CD that block deployments to non-US regions.

- **Open source contributions:** Developers may inadvertently contribute ITAR-derived code to public open source projects. Claude Code scans outgoing pull requests to external repositories for ITAR indicators before submission.

## Related

- [Claude Code for FedRAMP Authorization Workflow](/claude-code-fedramp-authorization-workflow-2026/)
- [Claude Code for NIST Cybersecurity Framework](/claude-code-nist-cybersecurity-framework-2026/)
- [Claude Code for SOX Audit Automation](/claude-code-sox-audit-automation-2026/)
- [Review Claude Code PRs Efficiently (2026)](/claude-code-review-prs-efficiently-2026/)


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

**Try it:** Estimate your monthly spend with our [Cost Calculator](/calculator/).

- [Claude Code for Prowler Compliance](/claude-code-for-prowler-compliance-workflow/)
- [Claude Code SOC 2 Compliance Audit Prep](/claude-code-soc2-compliance-audit-preparation-guide-2026/)
- [CCPA Compliance with Claude Code (2026)](/claude-code-ccpa-privacy-compliance-guide/)
- [Claude Code for SOX Compliance Audits](/claude-code-sox-financial-code-audit-workflow-guide/)

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
        "text": "Claude Code works with any Anthropic API plan, including the free tier. However, the free tier has lower rate limits (requests per minute and tokens per minute) that may slow down multi-step workflows."
      }
    },
    {
      "@type": "Question",
      "name": "How does this affect token usage and cost?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "The token cost depends on the size of your prompts and Claude's responses. Typical development tasks consume 10K-50K tokens per interaction. Using a CLAUDE.md file and skills reduces exploration tokens by 50-80%, which directly lowers costs."
      }
    },
    {
      "@type": "Question",
      "name": "Can I customize this for my specific project?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "Yes. All Claude Code behavior can be customized through CLAUDE.md (project rules), .claude/settings.json (permissions), and .claude/skills/ (domain knowledge). The most impactful customization is adding your project's specific patterns, conventions, and common commands to CLAUDE.md so Claude Code..."
      }
    },
    {
      "@type": "Question",
      "name": "What happens when Claude Code makes a mistake?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "Claude Code creates files and edits through standard filesystem operations, so all changes are visible in git diff. If a change is wrong, revert it with git checkout -- <file> for a single file or git stash for all changes."
      }
    }
  ]
}
</script>
