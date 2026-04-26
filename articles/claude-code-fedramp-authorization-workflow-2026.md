---
layout: default
title: "Claude Code for FedRAMP Authorization (2026)"
permalink: /claude-code-fedramp-authorization-workflow-2026/
date: 2026-04-20
description: "Automate FedRAMP authorization with Claude Code. Generate SSP documentation, OSCAL artifacts, and continuous monitoring evidence from code."
last_tested: "2026-04-22"
domain: "federal compliance"
---

## Why Claude Code for FedRAMP

FedRAMP authorization requires Cloud Service Providers to document and demonstrate compliance with 300+ NIST SP 800-53 Rev 5 controls for Moderate impact level (the most common). The System Security Plan (SSP) alone can exceed 400 pages, and continuous monitoring requires monthly vulnerability scans, annual penetration testing, and ongoing POA&M management. The transition to OSCAL (Open Security Controls Assessment Language) machine-readable formats adds another layer of complexity.

Claude Code can generate OSCAL-compliant artifacts from infrastructure-as-code, map Terraform/CloudFormation resources to specific 800-53 controls, and maintain the SSP as a living document that updates when infrastructure changes. It transforms a year-long authorization process into a continuously maintained compliance posture.

## The Workflow

### Step 1: Map Infrastructure to 800-53 Controls

```python
#!/usr/bin/env python3
"""FedRAMP control mapping from infrastructure-as-code."""

import json
import hcl2
from pathlib import Path

# NIST 800-53 Rev 5 controls relevant to cloud infrastructure
CONTROL_MAPPINGS = {
    "aws_s3_bucket": {
        "SC-28": "Protection of Information at Rest",
        "SC-13": "Cryptographic Protection",
        "AC-3": "Access Enforcement",
        "AU-3": "Content of Audit Records"
    },
    "aws_rds_instance": {
        "SC-28": "Protection of Information at Rest",
        "SC-8": "Transmission Confidentiality and Integrity",
        "CP-9": "System Backup",
        "AU-12": "Audit Record Generation"
    },
    "aws_iam_policy": {
        "AC-2": "Account Management",
        "AC-3": "Access Enforcement",
        "AC-6": "Least Privilege"
    },
    "aws_cloudtrail": {
        "AU-2": "Event Logging",
        "AU-3": "Content of Audit Records",
        "AU-6": "Audit Record Review and Reporting",
        "AU-12": "Audit Record Generation"
    },
    "aws_kms_key": {
        "SC-12": "Cryptographic Key Establishment and Management",
        "SC-13": "Cryptographic Protection",
        "SC-28": "Protection of Information at Rest"
    },
    "aws_waf_web_acl": {
        "SC-7": "Boundary Protection",
        "SI-4": "System Monitoring"
    }
}

def parse_terraform(tf_dir: Path) -> list[dict]:
    """Extract resources from Terraform files."""
    resources = []
    for tf_file in tf_dir.rglob("*.tf"):
        with open(tf_file) as f:
            try:
                parsed = hcl2.load(f)
                for resource_block in parsed.get("resource", []):
                    for resource_type, instances in resource_block.items():
                        for name, config in instances.items():
                            resources.append({
                                "type": resource_type,
                                "name": name,
                                "file": str(tf_file),
                                "config": config,
                                "controls": CONTROL_MAPPINGS.get(resource_type, {})
                            })
            except Exception:
                continue
    return resources

def check_s3_controls(config: dict) -> list[dict]:
    """Verify SC-28, SC-13 for S3 buckets."""
    findings = []

    # SC-28: Encryption at rest
    sse = config.get("server_side_encryption_configuration")
    if not sse:
        findings.append({
            "control": "SC-28",
            "status": "FAIL",
            "detail": "S3 bucket missing server-side encryption"
        })

    # AC-3: Public access blocked
    public_access = config.get("block_public_acls")
    if not public_access:
        findings.append({
            "control": "AC-3",
            "status": "FAIL",
            "detail": "S3 bucket public access not explicitly blocked"
        })

    # AU-3: Access logging enabled
    logging = config.get("logging")
    if not logging:
        findings.append({
            "control": "AU-3",
            "status": "FAIL",
            "detail": "S3 bucket access logging not configured"
        })

    return findings
```

### Step 2: Generate OSCAL SSP Artifacts

```python
def generate_oscal_ssp(resources: list[dict], system_name: str) -> dict:
    """Generate OSCAL-format System Security Plan."""
    implemented_controls = {}

    for resource in resources:
        for control_id, control_name in resource.get("controls", {}).items():
            if control_id not in implemented_controls:
                implemented_controls[control_id] = {
                    "control-id": control_id,
                    "description": control_name,
                    "implementation-status": "implemented",
                    "responsible-roles": ["cloud-engineer"],
                    "statements": []
                }
            implemented_controls[control_id]["statements"].append({
                "resource": f"{resource['type']}.{resource['name']}",
                "file": resource["file"],
                "description": f"{resource['type']} resource '{resource['name']}' "
                              f"implements {control_id} ({control_name})"
            })

    return {
        "system-security-plan": {
            "metadata": {
                "title": f"{system_name} System Security Plan",
                "oscal-version": "1.1.2",
                "version": "1.0"
            },
            "system-characteristics": {
                "system-name": system_name,
                "security-sensitivity-level": "moderate",
                "security-impact-level": {
                    "security-objective-confidentiality": "moderate",
                    "security-objective-integrity": "moderate",
                    "security-objective-availability": "moderate"
                }
            },
            "control-implementation": {
                "implemented-requirements": list(implemented_controls.values())
            }
        }
    }
```

### Step 3: Continuous Monitoring Evidence

```bash
# Monthly vulnerability scan evidence
trivy fs --security-checks vuln . \
  --format json > evidence/vuln-scan-$(date +%Y%m).json

# Monthly inventory update
aws configservice get-discovered-resource-counts \
  --output json > evidence/inventory-$(date +%Y%m).json

# POA&M tracking from findings
python3 ~/fedramp/poam_tracker.py \
  --findings evidence/vuln-scan-*.json \
  --output evidence/poam-$(date +%Y%m).json
```

### Step 4: Verify

```bash
# Validate OSCAL document
oscal-cli ssp validate ssp.json

# Check control coverage
python3 -c "
import json
with open('ssp.json') as f:
    ssp = json.load(f)
controls = ssp['system-security-plan']['control-implementation']['implemented-requirements']
print(f'Documented controls: {len(controls)}')
print(f'FedRAMP Moderate requires: ~325 controls')
print(f'Coverage: {len(controls)/325*100:.0f}%')
"
```

## CLAUDE.md for FedRAMP Authorization

```markdown
# FedRAMP Authorization Standards

## Domain Rules
- Target: NIST 800-53 Rev 5 Moderate baseline (325 controls)
- SSP must be in OSCAL format for Rev 5 submissions
- All infrastructure must be IaC-defined (no manual provisioning)
- FIPS 140-2/3 validated cryptography required
- FedRAMP boundary must be clearly defined in code and docs
- ConMon: monthly vulnerability scans, annual pen test, ongoing POA&M
- All systems must be in FedRAMP-authorized regions (GovCloud preferred)

## File Patterns
- Terraform: infra/*.tf (infrastructure definitions)
- OSCAL: oscal/*.json (SSP, SAP, SAR, POA&M)
- Evidence: evidence/YYYY-MM/ (monthly ConMon artifacts)
- Policies: policies/*.md (system-specific policies)

## Common Commands
- terraform plan -out=plan.tfplan
- oscal-cli ssp validate ssp.json
- trivy fs --severity HIGH,CRITICAL --format json .
- aws configservice get-compliance-summary-by-config-rule
- python3 poam_tracker.py --findings scan.json
```

## Common Pitfalls in FedRAMP Authorization

- **Boundary creep:** Services outside the authorization boundary processing federal data invalidate the ATO. Claude Code scans for external service calls (APIs, SaaS integrations) and flags any that cross the boundary without documented interconnection agreements.

- **FIPS cryptography violations:** Standard AWS SDK defaults may not use FIPS endpoints. Claude Code verifies all AWS service calls use FIPS endpoints (*.fips.*.amazonaws.com) and that TLS libraries are FIPS-validated builds.

- **POA&M staleness:** FedRAMP requires active POA&M management with target remediation dates. Claude Code tracks open findings, calculates remediation SLA adherence, and flags overdue items before they trigger JAB review escalation.

## Related

- [Claude Code for NIST Cybersecurity Framework](/claude-code-nist-cybersecurity-framework-2026/)
- [Claude Code for ISO 27001 Controls Implementation](/claude-code-iso-27001-controls-implementation-2026/)
- [Claude Code for ITAR Compliance Code Review](/claude-code-itar-compliance-code-review-2026/)


## Frequently Asked Questions

### What is the minimum setup required?

You need Claude Code installed (Node.js 18+), a project with a `CLAUDE.md` file, and the relevant toolchain for your project type (e.g., npm for JavaScript, pip for Python). The CLAUDE.md file should describe your project structure, conventions, and common commands so Claude Code can work effectively.

### How long does the initial setup take?

For a typical project, initial setup takes 10-20 minutes. This includes creating the CLAUDE.md file, configuring `.claude/settings.json` for permissions, and running a test task to verify everything works. Subsequent sessions start immediately because the configuration persists.

### Can I use this with a team?

Yes. Commit your `.claude/` directory and `CLAUDE.md` to version control so the entire team uses the same configuration. Each developer can add personal preferences in `~/.claude/settings.json` (user-level) without affecting the project configuration. Review CLAUDE.md changes in pull requests like any other configuration file.

### What if Claude Code produces incorrect output?

First check that your CLAUDE.md accurately describes your project conventions. Incorrect or outdated context is the most common cause of wrong output. If the output is still wrong, provide feedback in the same session — Claude Code learns from corrections within a conversation. For persistent issues, add explicit rules to CLAUDE.md (e.g., "Always use single quotes" or "Never modify files in the config/ directory").


## Best Practices

1. **Start with a clear CLAUDE.md.** Describe your project structure, tech stack, coding conventions, and common commands in under 300 words. This single file has the largest impact on Claude Code's accuracy and efficiency.

2. **Use skills for domain knowledge.** Move detailed reference information (API routes, database schemas, deployment procedures) into `.claude/skills/` files. This keeps CLAUDE.md concise while making specialized knowledge available when needed.

3. **Review changes before committing.** Always run `git diff` after Claude Code makes changes. Verify the edits are correct, match your project style, and do not introduce unintended side effects. This habit prevents compounding errors across sessions.

4. **Set up permission guardrails.** Configure `.claude/settings.json` with explicit allow and deny lists. Allow your standard development commands (test, build, lint) and deny destructive operations (rm -rf, git push --force, database drops).

5. **Keep sessions focused.** Give Claude Code one clear task per prompt. Multi-step requests like "refactor auth, add tests, and update docs" produce better results when broken into three separate prompts, each building on the previous result.




**Set it up →** Build your permission config with our [Permission Configurator](/permissions/).

## Related Guides

**Try it:** Paste your error into our [Error Diagnostic](/diagnose/) for an instant fix.

- [Claude Code for Envoy Authorization](/claude-code-for-envoy-authz-workflow-tutorial/)

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
