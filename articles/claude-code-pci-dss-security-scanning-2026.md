---
title: "Claude Code for PCI-DSS Security Scanning (2026)"
permalink: /claude-code-pci-dss-security-scanning-2026/
description: "Implement PCI-DSS v4.0 security scanning with Claude Code. Detect cardholder data exposure, validate encryption, and audit access controls."
last_tested: "2026-04-22"
domain: "payment security"
render_with_liquid: false
---

## Why Claude Code for PCI-DSS Security Scanning

PCI-DSS v4.0 (effective March 2025) introduced 64 new requirements including mandatory multi-factor authentication for all CDE access, targeted risk analysis for each requirement, and automated detection of cleartext PAN storage. Organizations processing card payments must demonstrate continuous compliance, not just pass annual QSA assessments. The new customized approach allows flexibility but requires more evidence of control effectiveness.

Claude Code can scan codebases for PCI-DSS Requirement 3 (protect stored account data), Requirement 4 (protect with strong cryptography during transmission), Requirement 6 (develop secure systems), and Requirement 8 (identify users and authenticate access). It identifies where cardholder data enters, flows through, and is stored in the system.

## The Workflow

### Step 1: Define Cardholder Data Detection Rules

```bash
mkdir -p ~/pci-scan/{rules,output}

# PAN (Primary Account Number) detection regex
# Covers Visa, Mastercard, Amex, Discover, JCB
cat > ~/pci-scan/rules/pan-patterns.txt << 'EOF'
# Visa: starts with 4, 13-19 digits
4[0-9]{12}(?:[0-9]{3,6})?

# Mastercard: starts with 51-55 or 2221-2720
(?:5[1-5][0-9]{2}|222[1-9]|22[3-9][0-9]|2[3-6][0-9]{2}|27[01][0-9]|2720)[0-9]{12}

# Amex: starts with 34 or 37, 15 digits
3[47][0-9]{13}

# Discover: starts with 6011, 644-649, 65
(?:6011|65[0-9]{2}|64[4-9][0-9])[0-9]{12}

# Track data patterns (magnetic stripe)
%B[0-9]{13,19}\^.+\^[0-9]{4}
;[0-9]{13,19}=[0-9]{4}
EOF
```

### Step 2: Scan for Cardholder Data Exposure

```python
#!/usr/bin/env python3
"""PCI-DSS v4.0 cardholder data scanner.
Covers Requirements 3, 4, 6, and 8."""

import re
from pathlib import Path
from dataclasses import dataclass

PAN_PATTERNS = [
    re.compile(r'\b4[0-9]{12}(?:[0-9]{3,6})?\b'),
    re.compile(r'\b(?:5[1-5][0-9]{2}|222[1-9]|22[3-9][0-9]|2[3-6][0-9]{2}|27[01][0-9]|2720)[0-9]{12}\b'),
    re.compile(r'\b3[47][0-9]{13}\b'),
    re.compile(r'\b(?:6011|65[0-9]{2}|64[4-9][0-9])[0-9]{12}\b'),
]

CVV_PATTERNS = [
    re.compile(r'(?:cvv|cvc|cvv2|csc|security.code)\s*[:=]\s*["\']?\d{3,4}', re.I),
]

@dataclass
class PCIFinding:
    requirement: str
    severity: str
    file: str
    line: int
    category: str
    description: str
    remediation: str

def scan_requirement_3(filepath: Path, content: str, lines: list) -> list[PCIFinding]:
    """Req 3: Protect stored account data."""
    findings = []
    for i, line in enumerate(lines, 1):
        # 3.4.1: PAN must be rendered unreadable when stored
        for pattern in PAN_PATTERNS:
            if pattern.search(line):
                # Check Luhn algorithm to reduce false positives
                matches = pattern.findall(line)
                for match in matches:
                    if luhn_check(match):
                        findings.append(PCIFinding(
                            requirement="3.4.1",
                            severity="CRITICAL",
                            file=str(filepath), line=i,
                            category="CLEARTEXT_PAN",
                            description="Potential cleartext PAN detected",
                            remediation="Apply tokenization, truncation, or AES-256 encryption"
                        ))

        # 3.3.2: SAD (CVV/CVC) must not be stored after authorization
        for pattern in CVV_PATTERNS:
            if pattern.search(line):
                findings.append(PCIFinding(
                    requirement="3.3.2",
                    severity="CRITICAL",
                    file=str(filepath), line=i,
                    category="CVV_STORAGE",
                    description="CVV/CVC value appears to be stored or logged",
                    remediation="Never store SAD after authorization. Remove immediately."
                ))

        # 3.5.1: PAN stored with reversible encryption must use strong keys
        if re.search(r'(?:DES|3DES|RC4|MD5)\b', line, re.I):
            if any(kw in line.lower() for kw in ['encrypt', 'cipher', 'key']):
                findings.append(PCIFinding(
                    requirement="3.5.1",
                    severity="HIGH",
                    file=str(filepath), line=i,
                    category="WEAK_ENCRYPTION",
                    description="Weak encryption algorithm for cardholder data",
                    remediation="Use AES-256 or stronger. Remove DES/3DES/RC4."
                ))
    return findings

def scan_requirement_4(filepath: Path, content: str, lines: list) -> list[PCIFinding]:
    """Req 4: Protect cardholder data with strong cryptography during transmission."""
    findings = []
    for i, line in enumerate(lines, 1):
        # 4.2.1: Strong cryptography for PAN transmission
        if re.search(r'http://(?!localhost|127\.0\.0\.1)', line):
            findings.append(PCIFinding(
                requirement="4.2.1",
                severity="HIGH",
                file=str(filepath), line=i,
                category="UNENCRYPTED_TRANSMISSION",
                description="Non-TLS HTTP endpoint for potential cardholder data",
                remediation="Enforce HTTPS/TLS 1.2+ for all cardholder data transmission"
            ))

        # 4.2.1.1: Trusted certificates
        if re.search(r'verify\s*[=:]\s*(?:false|False|0)|rejectUnauthorized.*false', line):
            findings.append(PCIFinding(
                requirement="4.2.1.1",
                severity="HIGH",
                file=str(filepath), line=i,
                category="CERT_VALIDATION_DISABLED",
                description="TLS certificate validation disabled",
                remediation="Enable certificate verification for all external connections"
            ))
    return findings

def luhn_check(number: str) -> bool:
    """Validate PAN with Luhn algorithm to reduce false positives."""
    digits = [int(d) for d in number if d.isdigit()]
    odd_digits = digits[-1::-2]
    even_digits = digits[-2::-2]
    total = sum(odd_digits) + sum(d*2 - 9 if d*2 > 9 else d*2 for d in even_digits)
    return total % 10 == 0
```

### Step 3: Validate Requirement 6 and 8

```python
def scan_requirement_6(filepath: Path, content: str, lines: list) -> list[PCIFinding]:
    """Req 6: Develop and maintain secure systems and software."""
    findings = []
    for i, line in enumerate(lines, 1):
        # 6.2.4: SQL injection prevention
        if re.search(r'["\'].*\+.*(?:SELECT|INSERT|UPDATE|DELETE|WHERE)', line, re.I):
            findings.append(PCIFinding(
                requirement="6.2.4",
                severity="HIGH",
                file=str(filepath), line=i,
                category="SQL_INJECTION",
                description="String concatenation in SQL query",
                remediation="Use parameterized queries or prepared statements"
            ))

        # 6.2.4: XSS prevention
        if re.search(r'innerHTML\s*=|document\.write\(|\.html\(.*\$', line):
            findings.append(PCIFinding(
                requirement="6.2.4",
                severity="MEDIUM",
                file=str(filepath), line=i,
                category="XSS_RISK",
                description="Potential XSS via unsafe DOM manipulation",
                remediation="Use textContent, sanitize HTML input, or use framework escaping"
            ))
    return findings

def scan_requirement_8(filepath: Path, content: str, lines: list) -> list[PCIFinding]:
    """Req 8: Identify users and authenticate access to system components."""
    findings = []
    for i, line in enumerate(lines, 1):
        # 8.3.6: Password complexity
        if re.search(r'(?:min.*length|password.*length)\s*[:=<>]\s*[1-7]\b', line, re.I):
            findings.append(PCIFinding(
                requirement="8.3.6",
                severity="HIGH",
                file=str(filepath), line=i,
                category="WEAK_PASSWORD_POLICY",
                description="Password minimum length below PCI-DSS requirement (12 chars in v4.0)",
                remediation="Set minimum password length to 12+ characters"
            ))

        # 8.6.1: Hardcoded credentials
        if re.search(r'(?:password|api_key|secret)\s*[:=]\s*["\'][^"\']{4,}["\']', line, re.I):
            findings.append(PCIFinding(
                requirement="8.6.1",
                severity="CRITICAL",
                file=str(filepath), line=i,
                category="HARDCODED_CREDENTIAL",
                description="Hardcoded credential or API key",
                remediation="Use environment variables or secrets manager"
            ))
    return findings
```

### Step 4: Verify

```bash
# Run PCI-DSS scan
python3 ~/pci-scan/scanner.py \
  --root /path/to/payment-app \
  --output ~/pci-scan/output/findings.json

# Generate compliance summary
python3 -c "
import json
from collections import Counter
with open('output/findings.json') as f:
    findings = json.load(f)
by_req = Counter(f['requirement'] for f in findings)
print('Findings by PCI-DSS Requirement:')
for req, count in sorted(by_req.items()):
    print(f'  Req {req}: {count} findings')
"
```

## CLAUDE.md for PCI-DSS Security Scanning

```markdown
# PCI-DSS v4.0 Security Scanning Standards

## Domain Rules
- PAN must never be stored in cleartext (Req 3.4.1)
- CVV/CVC must never be stored after authorization (Req 3.3.2)
- Use AES-256 minimum for encryption at rest (Req 3.5.1)
- TLS 1.2+ required for all cardholder data transmission (Req 4.2.1)
- Parameterized queries only, no SQL string concatenation (Req 6.2.4)
- Minimum 12-character passwords in v4.0 (Req 8.3.6)
- MFA required for all CDE access (Req 8.4.2)
- No hardcoded credentials anywhere in code (Req 8.6.1)

## File Patterns
- Scan: *.js, *.ts, *.py, *.java, *.cs, *.go, *.rb
- Config: *.env, *.yaml, *.json, *.xml, *.properties
- Exclude: node_modules/, vendor/, .git/, test fixtures

## Common Commands
- python3 pci_scanner.py --root src/ --output findings.json
- npm audit --production
- trivy fs --security-checks vuln,config .
- semgrep --config=p/owasp-top-ten src/
```

## Common Pitfalls in PCI-DSS Security Scanning

- **Log files containing PAN:** Application logs, web server access logs, and error logs may capture full PAN from request/response bodies. Claude Code scans log configurations and adds PAN-masking middleware that shows only the last 4 digits.

- **Test PANs in source code:** Developers use test card numbers (4111111111111111) in unit tests and fixtures. While these are not real PANs, they trigger scanners and indicate code paths that handle unmasked PANs. Claude Code flags these and verifies the code paths also work with tokenized values.

- **Third-party iframe vs redirect:** PCI-DSS SAQ scope depends heavily on how card data is collected. Claude Code verifies that payment forms use iframe embed (SAQ A) or redirect (SAQ A-EP) patterns rather than direct card field handling (SAQ D).

## Related

- [Claude Code for HIPAA Compliance Code Review](/claude-code-hipaa-compliance-code-review-2026/)
- [Claude Code for SOX Audit Automation](/claude-code-sox-audit-automation-2026/)
- [Claude Code for ISO 27001 Controls Implementation](/claude-code-iso-27001-controls-implementation-2026/)
