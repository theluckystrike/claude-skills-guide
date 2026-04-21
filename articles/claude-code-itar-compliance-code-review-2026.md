---
title: "Claude Code for ITAR Compliance Code Review (2026)"
permalink: /claude-code-itar-compliance-code-review-2026/
description: "Enforce ITAR technical data controls with Claude Code. Detect export-controlled code patterns, validate access restrictions, and audit data flows."
last_tested: "2026-04-22"
domain: "export control compliance"
render_with_liquid: false
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
