---
title: "Claude Code for ISO 27001 Controls Implementation (2026)"
permalink: /claude-code-iso-27001-controls-implementation-2026/
description: "Implement ISO 27001:2022 Annex A controls with Claude Code. Automate evidence collection, policy-as-code, and continuous compliance monitoring."
last_tested: "2026-04-22"
domain: "information security"
render_with_liquid: false
---

## Why Claude Code for ISO 27001

ISO 27001:2022 restructured its Annex A controls from 114 to 93, organized into four themes: Organizational, People, Physical, and Technological. For technology teams, the 34 Technological controls require implementation in code, infrastructure, and CI/CD pipelines. Auditors expect documented evidence that controls like A.8.9 (Configuration Management), A.8.25 (Secure Development Life Cycle), and A.8.28 (Secure Coding) are actually enforced, not just written in a policy document.

Claude Code can translate ISO 27001 control requirements into automated checks that run in CI/CD, generate audit evidence on every build, and flag non-conformities before they reach production. It bridges the gap between security policy documents and actual code implementation.

## The Workflow

### Step 1: Map Annex A Technological Controls

```python
#!/usr/bin/env python3
"""ISO 27001:2022 Annex A Technological Controls mapping."""

ANNEX_A_TECH_CONTROLS = {
    "A.8.1": {
        "name": "User endpoint devices",
        "automated_check": "Verify MDM enrollment and OS patch level",
        "evidence_type": "device_inventory"
    },
    "A.8.5": {
        "name": "Secure authentication",
        "automated_check": "Verify MFA enforcement and password policy",
        "evidence_type": "iam_config",
        "code_checks": [
            "mfa_enabled_all_users",
            "password_min_length_12",
            "session_timeout_configured",
            "account_lockout_after_failures"
        ]
    },
    "A.8.9": {
        "name": "Configuration management",
        "automated_check": "Verify IaC drift detection and change tracking",
        "evidence_type": "config_audit",
        "code_checks": [
            "infrastructure_as_code",
            "no_manual_config_changes",
            "drift_detection_enabled"
        ]
    },
    "A.8.24": {
        "name": "Use of cryptography",
        "automated_check": "Verify encryption standards and key management",
        "evidence_type": "crypto_audit",
        "code_checks": [
            "aes_256_or_stronger",
            "no_deprecated_algorithms",
            "key_rotation_configured",
            "tls_1_2_minimum"
        ]
    },
    "A.8.25": {
        "name": "Secure development life cycle",
        "automated_check": "Verify SAST, DAST, dependency scanning in CI",
        "evidence_type": "sdlc_evidence",
        "code_checks": [
            "sast_in_pipeline",
            "dependency_scanning",
            "code_review_required",
            "branch_protection"
        ]
    },
    "A.8.28": {
        "name": "Secure coding",
        "automated_check": "Verify secure coding standards enforcement",
        "evidence_type": "code_quality",
        "code_checks": [
            "input_validation",
            "output_encoding",
            "parameterized_queries",
            "no_hardcoded_secrets"
        ]
    }
}
```

### Step 2: Implement Policy-as-Code Checks

```python
"""CI/CD pipeline checks implementing ISO 27001 Annex A controls."""

import subprocess
import json
from datetime import datetime

class ISO27001ComplianceChecker:
    def __init__(self, project_root: str):
        self.root = project_root
        self.findings = []
        self.timestamp = datetime.now().isoformat()

    def check_a_8_5_authentication(self) -> dict:
        """A.8.5: Secure authentication controls."""
        results = {"control": "A.8.5", "name": "Secure Authentication", "checks": []}

        # Check password policy in code
        proc = subprocess.run(
            ['grep', '-rn', 'minLength.*[0-9]', self.root,
             '--include=*.ts', '--include=*.js', '--include=*.py'],
            capture_output=True, text=True
        )
        for line in proc.stdout.strip().split('\n'):
            if line and any(f'minLength' in line.lower() for _ in [1]):
                import re
                match = re.search(r'minLength["\s:=]+(\d+)', line, re.I)
                if match and int(match.group(1)) < 12:
                    results["checks"].append({
                        "check": "password_min_length",
                        "status": "FAIL",
                        "detail": f"Password min length {match.group(1)} < 12",
                        "file": line.split(':')[0]
                    })

        # Check session timeout
        proc = subprocess.run(
            ['grep', '-rn', 'maxAge\|sessionTimeout\|expires', self.root,
             '--include=*.ts', '--include=*.js', '--include=*.py'],
            capture_output=True, text=True
        )
        results["checks"].append({
            "check": "session_timeout",
            "status": "PASS" if proc.stdout.strip() else "FAIL",
            "detail": "Session timeout configuration found" if proc.stdout.strip()
                      else "No session timeout configuration detected"
        })

        return results

    def check_a_8_24_cryptography(self) -> dict:
        """A.8.24: Use of cryptography."""
        results = {"control": "A.8.24", "name": "Cryptography", "checks": []}

        # Check for deprecated algorithms
        deprecated = ['MD5', 'SHA1', 'DES', 'RC4', 'RC2', 'Blowfish']
        proc = subprocess.run(
            ['grep', '-rni', '|'.join(deprecated), self.root,
             '--include=*.ts', '--include=*.js', '--include=*.py',
             '--include=*.java', '--include=*.go'],
            capture_output=True, text=True
        )
        if proc.stdout.strip():
            results["checks"].append({
                "check": "no_deprecated_algorithms",
                "status": "FAIL",
                "detail": f"Deprecated algorithms found in {len(proc.stdout.strip().split(chr(10)))} locations"
            })
        else:
            results["checks"].append({
                "check": "no_deprecated_algorithms",
                "status": "PASS",
                "detail": "No deprecated cryptographic algorithms detected"
            })

        # Check TLS version
        proc = subprocess.run(
            ['grep', '-rni', 'TLSv1\\.0\|TLSv1\\.1\|SSLv3', self.root],
            capture_output=True, text=True
        )
        results["checks"].append({
            "check": "tls_minimum_version",
            "status": "FAIL" if proc.stdout.strip() else "PASS",
            "detail": "Deprecated TLS/SSL versions found" if proc.stdout.strip()
                      else "No deprecated TLS versions"
        })

        return results

    def check_a_8_25_sdlc(self) -> dict:
        """A.8.25: Secure development life cycle."""
        results = {"control": "A.8.25", "name": "Secure SDLC", "checks": []}

        # Check for CI pipeline with security scanning
        ci_files = ['.github/workflows', '.gitlab-ci.yml', 'Jenkinsfile',
                    '.circleci/config.yml', 'bitbucket-pipelines.yml']
        from pathlib import Path
        ci_found = any((Path(self.root) / f).exists() for f in ci_files)

        results["checks"].append({
            "check": "ci_pipeline_exists",
            "status": "PASS" if ci_found else "FAIL",
            "detail": "CI/CD pipeline configuration found" if ci_found
                      else "No CI/CD pipeline detected"
        })

        # Check branch protection (via GitHub API)
        proc = subprocess.run(
            ['gh', 'api', 'repos/{owner}/{repo}/branches/main/protection'],
            capture_output=True, text=True
        )
        if proc.returncode == 0:
            protection = json.loads(proc.stdout)
            has_reviews = protection.get('required_pull_request_reviews', {})
            results["checks"].append({
                "check": "branch_protection",
                "status": "PASS" if has_reviews else "FAIL",
                "detail": "Branch protection with required reviews" if has_reviews
                          else "No required reviews on main branch"
            })

        return results

    def generate_evidence_package(self) -> dict:
        """Generate ISO 27001 audit evidence package."""
        return {
            "iso_27001_evidence": {
                "generated_at": self.timestamp,
                "scope": self.root,
                "controls": [
                    self.check_a_8_5_authentication(),
                    self.check_a_8_24_cryptography(),
                    self.check_a_8_25_sdlc(),
                ]
            }
        }
```

### Step 3: Verify

```bash
# Run ISO 27001 compliance check
python3 ~/iso27001/checker.py \
  --project /path/to/app \
  --output ~/iso27001/evidence-$(date +%Y%m%d).json

# Summary
python3 -c "
import json
with open('evidence-*.json') as f:
    data = json.load(f)
for control in data['iso_27001_evidence']['controls']:
    passed = sum(1 for c in control['checks'] if c['status'] == 'PASS')
    total = len(control['checks'])
    print(f'{control[\"control\"]} {control[\"name\"]}: {passed}/{total} PASS')
"
```

## CLAUDE.md for ISO 27001 Implementation

```markdown
# ISO 27001:2022 Implementation Standards

## Domain Rules
- All Annex A Technological controls must have automated evidence
- Policy-as-code: every policy statement maps to a testable check
- Evidence must be timestamped and generated automatically
- Non-conformities must be tracked in a corrective action register
- Annual ISMS review evidence must be programmatically generated
- Risk treatment plans map to specific code/config changes

## File Patterns
- Controls: controls/*.py (automated check implementations)
- Evidence: evidence/YYYY-MM-DD/*.json (dated evidence packages)
- Policies: policies/*.md (human-readable policy documents)
- CI: .github/workflows/iso27001-check.yml

## Common Commands
- python3 checker.py --project . --output evidence.json
- python3 risk_assessment.py --scope production
- gh api repos/{owner}/{repo}/branches/main/protection
- trivy fs --security-checks config,vuln .
```

## Common Pitfalls in ISO 27001 Implementation

- **Control evidence gaps between audits:** Annual audits examine a 12-month period, but evidence collected only during audit prep shows gaps. Claude Code generates evidence on every CI/CD run, creating a continuous compliance record.

- **Statement of Applicability drift:** The SoA declares which controls apply, but code changes may introduce new processing that requires additional controls. Claude Code compares the SoA against actual system capabilities and flags mismatches.

- **Shared responsibility confusion in cloud:** AWS/Azure/GCP shared responsibility models mean some controls are the CSP's responsibility. Claude Code checks which controls are covered by CSP certifications and which require customer-side implementation.

## Related

- [Claude Code for SOC 2 Evidence Collection](/claude-code-soc2-evidence-collection-2026/)
- [Claude Code for NIST Cybersecurity Framework](/claude-code-nist-cybersecurity-framework-2026/)
- [Claude Code for FedRAMP Authorization Workflow](/claude-code-fedramp-authorization-workflow-2026/)
