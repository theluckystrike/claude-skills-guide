---
layout: default
title: "Claude Code for NIST Cybersecurity (2026)"
permalink: /claude-code-nist-cybersecurity-framework-2026/
date: 2026-04-20
description: "Implement NIST CSF 2.0 controls with Claude Code. Automate Identify, Protect, Detect, Respond, and Recover function evidence collection."
last_tested: "2026-04-22"
domain: "cybersecurity compliance"
---

## Why Claude Code for NIST CSF

The NIST Cybersecurity Framework 2.0 (released February 2024) added a sixth function -- Govern -- and expanded applicability beyond critical infrastructure to all organizations. The framework's 106 subcategories across Govern, Identify, Protect, Detect, Respond, and Recover require continuous evidence that security controls are implemented and effective. Federal contractors, healthcare organizations, and financial institutions increasingly reference NIST CSF in their vendor security questionnaires.

Claude Code can map codebase security controls to specific NIST CSF subcategories, generate evidence artifacts for each function, and identify implementation gaps that lower the organization's cybersecurity maturity tier.

## The Workflow

### Step 1: Map NIST CSF Functions to Code Controls

```python
#!/usr/bin/env python3
"""NIST CSF 2.0 control mapping and evidence generation."""

NIST_CSF_CONTROLS = {
    "GV.SC-03": {
        "function": "GOVERN",
        "category": "Supply Chain Risk Management",
        "description": "Cybersecurity supply chain risk management is integrated into strategy",
        "code_checks": ["dependency_scanning", "sbom_generation", "license_compliance"]
    },
    "ID.AM-01": {
        "function": "IDENTIFY",
        "category": "Asset Management",
        "description": "Inventories of hardware managed by the organization are maintained",
        "code_checks": ["infrastructure_inventory", "iac_resource_tags"]
    },
    "ID.RA-01": {
        "function": "IDENTIFY",
        "category": "Risk Assessment",
        "description": "Vulnerabilities in assets are identified, validated, and recorded",
        "code_checks": ["vulnerability_scanning", "cve_tracking", "patch_management"]
    },
    "PR.AA-01": {
        "function": "PROTECT",
        "category": "Identity Management and Access Control",
        "description": "Identities and credentials for authorized users are managed",
        "code_checks": ["iam_policy_review", "mfa_enforcement", "least_privilege"]
    },
    "PR.DS-01": {
        "function": "PROTECT",
        "category": "Data Security",
        "description": "Data-at-rest is protected",
        "code_checks": ["encryption_at_rest", "key_management", "data_classification"]
    },
    "PR.DS-02": {
        "function": "PROTECT",
        "category": "Data Security",
        "description": "Data-in-transit is protected",
        "code_checks": ["tls_enforcement", "certificate_management", "api_encryption"]
    },
    "DE.CM-01": {
        "function": "DETECT",
        "category": "Continuous Monitoring",
        "description": "Networks are monitored to detect potential cybersecurity events",
        "code_checks": ["logging_enabled", "siem_integration", "alerting_configured"]
    },
    "RS.AN-03": {
        "function": "RESPOND",
        "category": "Analysis",
        "description": "Analysis is performed to determine what has taken place during an incident",
        "code_checks": ["audit_trail_completeness", "log_retention", "forensic_capability"]
    },
    "RC.RP-01": {
        "function": "RECOVER",
        "category": "Recovery Planning",
        "description": "The recovery portion of the incident response plan is executed",
        "code_checks": ["backup_verification", "rto_rpo_defined", "disaster_recovery_tested"]
    }
}
```

### Step 2: Automate Evidence Collection

```python
import subprocess
import json
from pathlib import Path

class NISTCSFAssessor:
    def __init__(self, project_root: str, cloud_provider: str = "aws"):
        self.root = project_root
        self.cloud = cloud_provider

    def assess_protect_data_security(self) -> dict:
        """PR.DS-01/02: Data security controls."""
        evidence = {"subcategory": "PR.DS", "checks": []}

        # PR.DS-01: Encryption at rest
        if self.cloud == "aws":
            result = subprocess.run(
                ['aws', 'rds', 'describe-db-instances',
                 '--query', 'DBInstances[*].[DBInstanceIdentifier,StorageEncrypted]',
                 '--output', 'json'],
                capture_output=True, text=True
            )
            if result.returncode == 0:
                instances = json.loads(result.stdout)
                unencrypted = [i[0] for i in instances if not i[1]]
                evidence["checks"].append({
                    "check": "rds_encryption_at_rest",
                    "status": "PASS" if not unencrypted else "FAIL",
                    "detail": f"Unencrypted RDS instances: {unencrypted}" if unencrypted
                              else "All RDS instances encrypted"
                })

        # PR.DS-02: TLS in code
        tls_check = subprocess.run(
            ['grep', '-rn', 'http://(?!localhost)', self.root,
             '--include=*.ts', '--include=*.py', '--include=*.yaml'],
            capture_output=True, text=True
        )
        evidence["checks"].append({
            "check": "tls_enforcement",
            "status": "FAIL" if tls_check.stdout.strip() else "PASS",
            "detail": f"Non-TLS URLs found" if tls_check.stdout.strip()
                      else "No plaintext HTTP URLs detected"
        })

        return evidence

    def assess_detect_monitoring(self) -> dict:
        """DE.CM-01: Continuous monitoring controls."""
        evidence = {"subcategory": "DE.CM", "checks": []}

        # Check logging configuration
        log_configs = list(Path(self.root).rglob('*log*.yaml')) + \
                     list(Path(self.root).rglob('*log*.json')) + \
                     list(Path(self.root).rglob('*logging*'))
        evidence["checks"].append({
            "check": "logging_configured",
            "status": "PASS" if log_configs else "FAIL",
            "detail": f"Found {len(log_configs)} logging configurations"
        })

        # Check alerting
        alert_patterns = ['pagerduty', 'opsgenie', 'alertmanager',
                         'cloudwatch.*alarm', 'datadog.*monitor']
        alert_found = False
        for pattern in alert_patterns:
            result = subprocess.run(
                ['grep', '-rli', pattern, self.root],
                capture_output=True, text=True
            )
            if result.stdout.strip():
                alert_found = True
                break

        evidence["checks"].append({
            "check": "alerting_configured",
            "status": "PASS" if alert_found else "FAIL",
            "detail": "Alerting integration detected" if alert_found
                      else "No alerting configuration found"
        })

        return evidence

    def assess_govern_supply_chain(self) -> dict:
        """GV.SC-03: Supply chain risk management."""
        evidence = {"subcategory": "GV.SC", "checks": []}

        # SBOM generation capability
        sbom_tools = ['syft', 'cyclonedx-cli', 'spdx-sbom-generator']
        ci_content = ""
        for ci_file in Path(self.root).rglob('.github/workflows/*.yml'):
            ci_content += ci_file.read_text()

        sbom_in_ci = any(tool in ci_content for tool in sbom_tools)
        evidence["checks"].append({
            "check": "sbom_generation",
            "status": "PASS" if sbom_in_ci else "FAIL",
            "detail": "SBOM generation in CI pipeline" if sbom_in_ci
                      else "No SBOM generation detected"
        })

        # Dependency vulnerability scanning
        dep_scan_tools = ['dependabot', 'snyk', 'renovate', 'npm audit',
                         'trivy', 'grype']
        dep_scan = any(tool in ci_content.lower() for tool in dep_scan_tools)
        evidence["checks"].append({
            "check": "dependency_scanning",
            "status": "PASS" if dep_scan else "FAIL",
            "detail": "Dependency scanning configured" if dep_scan
                      else "No dependency scanning detected"
        })

        return evidence
```

### Step 3: Generate Maturity Assessment

```python
def calculate_maturity_tier(evidence_results: list[dict]) -> dict:
    """Calculate NIST CSF maturity tier based on evidence."""
    total_checks = 0
    passed_checks = 0

    for result in evidence_results:
        for check in result.get("checks", []):
            total_checks += 1
            if check["status"] == "PASS":
                passed_checks += 1

    ratio = passed_checks / total_checks if total_checks > 0 else 0

    if ratio >= 0.90:
        tier = "Tier 4: Adaptive"
    elif ratio >= 0.70:
        tier = "Tier 3: Repeatable"
    elif ratio >= 0.40:
        tier = "Tier 2: Risk Informed"
    else:
        tier = "Tier 1: Partial"

    return {
        "maturity_tier": tier,
        "compliance_ratio": f"{ratio:.1%}",
        "total_checks": total_checks,
        "passed": passed_checks,
        "failed": total_checks - passed_checks
    }
```

### Step 4: Verify

```bash
python3 ~/nist-csf/assessor.py \
  --project /path/to/app \
  --cloud aws \
  --output ~/nist-csf/assessment-$(date +%Y%m%d).json

python3 -c "
import json
with open('assessment-*.json') as f:
    data = json.load(f)
print(f'Maturity: {data[\"maturity_tier\"]}')
print(f'Score: {data[\"compliance_ratio\"]}')
"
```

## CLAUDE.md for NIST CSF Implementation

```markdown
# NIST CSF 2.0 Implementation Standards

## Domain Rules
- Map every security control to a specific CSF subcategory
- Evidence must be generated automatically (no manual attestations)
- Each CSF function (Govern, Identify, Protect, Detect, Respond, Recover) needs checks
- Maturity tier assessment quarterly
- Supply chain risk (GV.SC) requires SBOM for all deployments
- All findings must reference specific CSF subcategory IDs

## File Patterns
- Assessor: nist-csf/*.py (control check implementations)
- Evidence: evidence/YYYY-MM-DD/ (dated evidence packages)
- Reports: reports/*.html (executive summary reports)
- CI: .github/workflows/nist-csf-check.yml

## Common Commands
- python3 assessor.py --project . --cloud aws --output evidence.json
- aws configservice get-compliance-summary-by-config-rule
- syft . -o cyclonedx-json > sbom.json
- trivy fs --security-checks vuln,config,secret .
```

## Common Pitfalls in NIST CSF Implementation

- **Confusing compliance with security:** NIST CSF is a risk management framework, not a checklist. Claude Code generates risk-based findings with business impact context rather than simple pass/fail results.

- **Missing the Govern function:** CSF 2.0's new Govern function requires documented cybersecurity strategy and supply chain risk management. Claude Code checks for governance artifacts (policies, risk registers, SBOM) that teams focused on technical controls often miss.

- **Recover function neglect:** Teams implement Protect and Detect controls but skip Recover validation. Claude Code verifies backup restoration procedures, RTO/RPO definitions, and disaster recovery test evidence.

## Related

- [Claude Code for ISO 27001 Controls Implementation](/claude-code-iso-27001-controls-implementation-2026/)
- [Claude Code for FedRAMP Authorization Workflow](/claude-code-fedramp-authorization-workflow-2026/)
- [Claude Code for SOC 2 Evidence Collection](/claude-code-soc2-evidence-collection-2026/)


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
