---
title: "Claude Code for HIPAA Compliance Code"
permalink: /claude-code-hipaa-compliance-code-review-2026/
description: "Automate HIPAA compliance code reviews with Claude Code. Detect PHI exposure, audit encryption, and validate access controls systematically."
last_tested: "2026-04-22"
domain: "healthcare compliance"
render_with_liquid: false
---

## Why Claude Code for HIPAA Code Review

Healthcare applications handling Protected Health Information (PHI) face severe penalties for violations -- $1.5 million per violation category per year under the HIPAA Enforcement Rule. Manual code reviews catch only a fraction of PHI exposure risks: unencrypted data at rest, logging of patient identifiers, missing audit trails for data access, and insufficient access controls. The 18 PHI identifiers defined by the Safe Harbor method must be tracked through every code path, API response, and log statement.

Claude Code can systematically scan codebases for PHI data flows, verify encryption implementation at rest and in transit, validate that audit logging covers all PHI access points, and flag HIPAA Technical Safeguard gaps that human reviewers miss.

## The Workflow

### Step 1: Define PHI Detection Patterns

```bash
# Create a HIPAA review configuration
mkdir -p ~/hipaa-review
cat > ~/hipaa-review/phi-patterns.json << 'PATTERNS'
{
  "phi_field_patterns": [
    "ssn", "social_security", "mrn", "medical_record",
    "patient_name", "date_of_birth", "dob", "phone_number",
    "email_address", "address", "zip_code", "account_number",
    "health_plan", "diagnosis", "icd_code", "procedure_code",
    "medication", "lab_result", "insurance_id", "beneficiary"
  ],
  "high_risk_patterns": [
    "console\\.log.*patient", "print.*ssn", "logger.*mrn",
    "JSON\\.stringify.*health", "response\\.json.*diagnosis"
  ]
}
PATTERNS
```

### Step 2: Scan for PHI in Logs and API Responses

Claude Code generates a HIPAA compliance scanner:

```python
#!/usr/bin/env python3
"""HIPAA PHI exposure scanner for codebase review.
Checks logging, API responses, and data storage patterns."""

import re
import ast
import sys
from pathlib import Path
from dataclasses import dataclass

PHI_IDENTIFIERS = [
    'name', 'address', 'date_of_birth', 'dob', 'phone', 'fax',
    'email', 'ssn', 'social_security', 'mrn', 'medical_record',
    'health_plan', 'account_number', 'certificate', 'vehicle_id',
    'device_serial', 'url', 'ip_address', 'biometric', 'photo',
    'diagnosis', 'icd', 'medication', 'lab_result', 'insurance_id'
]

LOG_FUNCTIONS = [
    'console.log', 'console.error', 'console.warn',
    'logger.info', 'logger.debug', 'logger.error', 'logger.warn',
    'logging.info', 'logging.debug', 'logging.error',
    'print', 'puts', 'System.out.println'
]

@dataclass
class Finding:
    file: str
    line: int
    severity: str  # CRITICAL, HIGH, MEDIUM
    category: str
    message: str
    code_snippet: str

def scan_file(filepath: Path) -> list[Finding]:
    findings = []
    content = filepath.read_text(errors='ignore')
    lines = content.split('\n')

    for i, line in enumerate(lines, 1):
        line_lower = line.lower()

        # Check 1: PHI in log statements
        for log_fn in LOG_FUNCTIONS:
            if log_fn.lower() in line_lower:
                for phi in PHI_IDENTIFIERS:
                    if phi in line_lower:
                        findings.append(Finding(
                            file=str(filepath), line=i,
                            severity='CRITICAL',
                            category='PHI_IN_LOGS',
                            message=f'Potential PHI ({phi}) in log statement',
                            code_snippet=line.strip()[:120]
                        ))

        # Check 2: Unencrypted PHI storage
        if any(kw in line_lower for kw in ['insert into', 'update ', '.create(', '.save(']):
            for phi in PHI_IDENTIFIERS:
                if phi in line_lower and 'encrypt' not in line_lower:
                    findings.append(Finding(
                        file=str(filepath), line=i,
                        severity='HIGH',
                        category='UNENCRYPTED_PHI',
                        message=f'PHI ({phi}) stored without visible encryption',
                        code_snippet=line.strip()[:120]
                    ))

        # Check 3: PHI in API responses without field filtering
        if any(kw in line_lower for kw in ['res.json(', 'response.json(', 'jsonify(']):
            if any(phi in line_lower for phi in ['patient', 'record', 'health']):
                if 'select' not in line_lower and 'pick' not in line_lower:
                    findings.append(Finding(
                        file=str(filepath), line=i,
                        severity='HIGH',
                        category='PHI_IN_RESPONSE',
                        message='API response may expose full PHI record',
                        code_snippet=line.strip()[:120]
                    ))

    return findings

def scan_directory(root: Path, extensions: set) -> list[Finding]:
    all_findings = []
    for ext in extensions:
        for filepath in root.rglob(f'*{ext}'):
            if '.git' in filepath.parts or 'node_modules' in filepath.parts:
                continue
            all_findings.extend(scan_file(filepath))
    return sorted(all_findings, key=lambda f: (f.severity, f.file, f.line))
```

### Step 3: Validate Technical Safeguards

```python
# HIPAA Technical Safeguard verification checklist
TECHNICAL_SAFEGUARDS = {
    "164.312(a)(1)": {
        "name": "Access Control",
        "checks": [
            "Unique user identification (user IDs)",
            "Emergency access procedure",
            "Automatic logoff (session timeout)",
            "Encryption and decryption"
        ],
        "code_patterns": {
            "pass": ["session.*timeout", "jwt.*expire", "bcrypt|argon2|scrypt",
                     "middleware.*auth", "rbac|role.*check"],
            "fail": ["password.*plain", "token.*never.*expire",
                     "admin.*hardcoded"]
        }
    },
    "164.312(c)(1)": {
        "name": "Integrity Controls",
        "checks": [
            "Mechanism to authenticate ePHI",
            "Integrity verification on data access"
        ],
        "code_patterns": {
            "pass": ["checksum", "hmac", "digital.*signature", "hash.*verify"],
            "fail": ["md5", "sha1(?!.*deprecated)"]
        }
    },
    "164.312(e)(1)": {
        "name": "Transmission Security",
        "checks": [
            "Encryption in transit (TLS)",
            "Integrity controls on transmission"
        ],
        "code_patterns": {
            "pass": ["https", "tls", "ssl.*verify", "certificate"],
            "fail": ["http://(?!localhost)", "ssl.*false", "verify.*false",
                     "rejectUnauthorized.*false"]
        }
    }
}
```

### Step 4: Generate Compliance Report

```bash
# Run the scanner
python3 ~/hipaa-review/scanner.py \
  --root /path/to/healthcare-app \
  --extensions .js,.ts,.py,.java \
  --output ~/hipaa-review/findings.json

# Generate HTML report
python3 ~/hipaa-review/report_generator.py \
  --findings ~/hipaa-review/findings.json \
  --output ~/Desktop/hipaa-review-report.html

# Summary
python3 -c "
import json
with open('findings.json') as f:
    findings = json.load(f)
for sev in ['CRITICAL', 'HIGH', 'MEDIUM']:
    count = sum(1 for f in findings if f['severity'] == sev)
    print(f'{sev}: {count} findings')
"
```

## CLAUDE.md for HIPAA Code Review

```markdown
# HIPAA Compliance Code Review Standards

## Domain Rules
- All 18 PHI identifiers must be tracked through every code path
- PHI must NEVER appear in log output (console, file, or remote logging)
- PHI at rest requires AES-256 encryption minimum
- PHI in transit requires TLS 1.2+ (no fallback to TLS 1.0/1.1)
- Every PHI access must generate an audit log entry
- Session timeout must be 15 minutes or less for PHI-accessing sessions
- API responses must use field-level filtering (allowlist, not blocklist)
- Passwords: bcrypt/argon2/scrypt only, minimum 12 characters

## File Patterns
- Review: *.js, *.ts, *.py, *.java, *.cs, *.go
- Config: *.env, *.yaml, *.json (check for hardcoded credentials)
- Infrastructure: Dockerfile, docker-compose.yml, *.tf (TLS config)

## Common Commands
- python3 hipaa_scanner.py --root src/ --output findings.json
- npm audit --production
- trivy image healthcare-app:latest
- owasp-zap -quickurl https://app.example.com
- bandit -r src/ -f json (Python security scanner)
```

## Common Pitfalls in HIPAA Code Review

- **Structured logging leaks PHI:** JSON loggers like Winston or Bunyan may serialize entire request objects that contain PHI. Claude Code adds PHI-stripping middleware that redacts sensitive fields before any logging occurs.

- **Error messages expose PHI:** Stack traces and validation error messages can contain patient data (e.g., "Invalid SSN: 123-45-6789"). Claude Code replaces detailed errors with generic messages and logs details only to the audit trail.

- **Third-party analytics tracking PHI:** Google Analytics, Mixpanel, and Sentry can inadvertently capture PHI from URLs, form fields, or error payloads. Claude Code configures data scrubbing rules and validates no PHI reaches external services.

## Related

- [Claude Code for SOX Audit Automation](/claude-code-sox-audit-automation-2026/)
- [Claude Code for GDPR Data Mapping](/claude-code-gdpr-data-mapping-2026/)
- [Claude Code for FDA 21 CFR Part 11 Validation](/claude-code-fda-21-cfr-part-11-validation-2026/)
- [Claude Code for ITAR Compliance Code Review (2026)](/claude-code-itar-compliance-code-review-2026/)
