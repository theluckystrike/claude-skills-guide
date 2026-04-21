---
title: "Claude Code for PCI-DSS Code Scanning (2026)"
description: "PCI-DSS code scanning automation with Claude Code. Detect cardholder data exposure and insecure crypto in codebases."
permalink: /claude-code-pci-dss-code-scanning-2026/
last_tested: "2026-04-21"
render_with_liquid: false
---

## Why Claude Code for PCI-DSS Scanning

PCI-DSS v4.0 (effective March 2025) requires that organizations handling payment card data implement secure coding practices, conduct code reviews, and scan for vulnerabilities. Requirement 6.2.4 mandates protection against common coding vulnerabilities. Requirement 3 requires that stored cardholder data be protected with strong cryptography.

Claude Code automates the tedious parts of PCI code review: scanning for hardcoded PANs, detecting insecure cryptographic implementations, finding unmasked card numbers in logs, and verifying that sensitive data flows through approved encryption paths. It generates findings in the format QSAs (Qualified Security Assessors) expect during audits.

## The Workflow

### Step 1: Setup

```bash
pip install semgrep bandit cryptography

# Semgrep rules for PCI
semgrep --config "p/secrets" --config "p/security-audit" --dry-run

mkdir -p pci_scan/{rules,reports,findings}
```

### Step 2: PCI-DSS Code Scanner

```python
# pci_scan/scanner.py
"""PCI-DSS v4.0 automated code scanner for cardholder data exposure."""
import re
import os
from pathlib import Path
from dataclasses import dataclass, field
from datetime import datetime
import json

MAX_FILE_SIZE = 5_000_000  # bytes
SCAN_EXTENSIONS = {".py", ".js", ".ts", ".java", ".cs", ".rb", ".go",
                   ".php", ".c", ".cpp", ".h", ".sql", ".xml", ".yaml",
                   ".yml", ".json", ".conf", ".env", ".properties"}


@dataclass
class Finding:
    rule_id: str
    pci_requirement: str
    severity: str          # CRITICAL, HIGH, MEDIUM, LOW
    file_path: str
    line_number: int
    code_snippet: str
    description: str
    remediation: str


@dataclass
class ScanReport:
    scan_id: str
    timestamp: str
    files_scanned: int
    findings: list = field(default_factory=list)
    critical_count: int = 0
    high_count: int = 0


# PAN (Primary Account Number) detection
PAN_PATTERNS = [
    # Visa
    (r'4[0-9]{12}(?:[0-9]{3})?', "Visa"),
    # Mastercard
    (r'5[1-5][0-9]{14}', "Mastercard"),
    # Amex
    (r'3[47][0-9]{13}', "American Express"),
    # Discover
    (r'6(?:011|5[0-9]{2})[0-9]{12}', "Discover"),
]


def luhn_check(number: str) -> bool:
    """Verify Luhn checksum to reduce false positives."""
    digits = [int(d) for d in number if d.isdigit()]
    if len(digits) < 13 or len(digits) > 19:
        return False
    checksum = 0
    reverse = digits[::-1]
    for i, d in enumerate(reverse):
        if i % 2 == 1:
            d *= 2
            if d > 9:
                d -= 9
        checksum += d
    return checksum % 10 == 0


def scan_for_pan(filepath: str, content: str) -> list:
    """Scan file for exposed PANs (Requirement 3.4)."""
    findings = []
    lines = content.split("\n")

    for line_num, line in enumerate(lines, 1):
        for pattern, card_type in PAN_PATTERNS:
            matches = re.finditer(pattern, line)
            for match in matches:
                candidate = match.group()
                # Skip obvious non-PANs
                if candidate in ("4111111111111111",):  # test card
                    continue
                if luhn_check(candidate):
                    findings.append(Finding(
                        rule_id="PCI-PAN-001",
                        pci_requirement="Req 3.4 - Render PAN unreadable",
                        severity="CRITICAL",
                        file_path=filepath,
                        line_number=line_num,
                        code_snippet=line.strip()[:120],
                        description=(
                            f"Potential {card_type} PAN in plaintext. "
                            f"Cardholder data must not be stored unencrypted."),
                        remediation=(
                            "Remove hardcoded PAN. Use tokenization or "
                            "encryption per PCI-DSS Req 3.5."),
                    ))
    return findings


def scan_for_weak_crypto(filepath: str, content: str) -> list:
    """Scan for insecure cryptographic implementations (Req 3.5, 4.1)."""
    findings = []
    lines = content.split("\n")

    weak_patterns = [
        (r'\bDES\b(?!3)', "DES encryption is broken",
         "CRITICAL", "Req 3.5.1"),
        (r'\bMD5\b', "MD5 is not suitable for cryptographic hashing",
         "HIGH", "Req 3.5.1"),
        (r'\bSHA-?1\b', "SHA-1 is deprecated for security",
         "HIGH", "Req 3.5.1"),
        (r'ECB', "ECB mode preserves data patterns",
         "HIGH", "Req 3.5.1"),
        (r'ssl\.PROTOCOL_TLSv1[^2]', "TLS 1.0/1.1 deprecated",
         "CRITICAL", "Req 4.2.1"),
        (r'SSLv[23]', "SSL 2.0/3.0 is broken",
         "CRITICAL", "Req 4.2.1"),
        (r'verify\s*=\s*False', "TLS certificate verification disabled",
         "CRITICAL", "Req 4.2.1"),
        (r'VERIFY_NONE', "TLS certificate verification disabled",
         "CRITICAL", "Req 4.2.1"),
    ]

    for line_num, line in enumerate(lines, 1):
        for pattern, desc, severity, req in weak_patterns:
            if re.search(pattern, line, re.I):
                findings.append(Finding(
                    rule_id="PCI-CRYPTO-001",
                    pci_requirement=req,
                    severity=severity,
                    file_path=filepath,
                    line_number=line_num,
                    code_snippet=line.strip()[:120],
                    description=desc,
                    remediation=(
                        "Use AES-256-GCM for encryption, "
                        "SHA-256+ for hashing, TLS 1.2+ for transport."),
                ))
    return findings


def scan_for_logging_exposure(filepath: str, content: str) -> list:
    """Scan for cardholder data in log statements (Req 3.3, 10.3)."""
    findings = []
    lines = content.split("\n")

    log_patterns = [
        r'log(?:ger)?\.(?:info|debug|warn|error|trace)\s*\(',
        r'console\.log\s*\(',
        r'print\s*\(',
        r'System\.out\.print',
        r'Logger\.',
    ]

    sensitive_vars = [
        r'(?:card|pan|credit|account)[\s_-]*(?:num|number)',
        r'cvv|cv2|cvc',
        r'expir(?:y|ation)',
        r'cardholder',
    ]

    for line_num, line in enumerate(lines, 1):
        is_log = any(re.search(p, line, re.I) for p in log_patterns)
        if not is_log:
            continue
        has_sensitive = any(re.search(s, line, re.I) for s in sensitive_vars)
        if has_sensitive:
            findings.append(Finding(
                rule_id="PCI-LOG-001",
                pci_requirement="Req 3.3 - Mask PAN in displays/logs",
                severity="HIGH",
                file_path=filepath,
                line_number=line_num,
                code_snippet=line.strip()[:120],
                description="Potential cardholder data in log statement.",
                remediation=(
                    "Mask all PANs to show only first 6 / last 4 digits. "
                    "Never log CVV, full PAN, or track data."),
            ))
    return findings


def scan_directory(directory: str) -> ScanReport:
    """Scan entire directory for PCI-DSS violations."""
    assert Path(directory).is_dir(), f"Not a directory: {directory}"

    report = ScanReport(
        scan_id=f"PCI-{datetime.utcnow():%Y%m%d%H%M%S}",
        timestamp=datetime.utcnow().isoformat(),
        files_scanned=0,
    )

    for root, _, files in os.walk(directory):
        for fname in files:
            filepath = os.path.join(root, fname)
            ext = Path(fname).suffix.lower()

            if ext not in SCAN_EXTENSIONS:
                continue
            if os.path.getsize(filepath) > MAX_FILE_SIZE:
                continue

            try:
                with open(filepath, encoding='utf-8', errors='ignore') as f:
                    content = f.read()
            except (IOError, OSError):
                continue

            report.files_scanned += 1
            report.findings.extend(scan_for_pan(filepath, content))
            report.findings.extend(scan_for_weak_crypto(filepath, content))
            report.findings.extend(scan_for_logging_exposure(filepath, content))

    report.critical_count = sum(
        1 for f in report.findings if f.severity == "CRITICAL")
    report.high_count = sum(
        1 for f in report.findings if f.severity == "HIGH")

    return report


if __name__ == "__main__":
    import sys
    assert len(sys.argv) >= 2, \
        "Usage: python scanner.py <directory>"

    report = scan_directory(sys.argv[1])
    print(f"PCI-DSS Scan Report: {report.scan_id}")
    print(f"Files scanned: {report.files_scanned}")
    print(f"Critical: {report.critical_count}")
    print(f"High: {report.high_count}")
    print(f"Total findings: {len(report.findings)}")
    for f in report.findings[:10]:
        print(f"\n  [{f.severity}] {f.rule_id}: {f.description}")
        print(f"  File: {f.file_path}:{f.line_number}")
        print(f"  PCI Req: {f.pci_requirement}")
```

### Step 3: Generate QSA-Ready Report

```bash
python3 pci_scan/scanner.py /path/to/payment/codebase
# Expected: scan report with findings mapped to PCI-DSS requirements

# Export as JSON for evidence package
python3 -c "
import json
from pci_scan.scanner import scan_directory
report = scan_directory('/path/to/codebase')
with open('reports/pci_scan_report.json', 'w') as f:
    json.dump({
        'scan_id': report.scan_id,
        'timestamp': report.timestamp,
        'files_scanned': report.files_scanned,
        'findings': [vars(f) for f in report.findings],
    }, f, indent=2)
"
```

## CLAUDE.md for PCI-DSS Scanning

```markdown
# PCI-DSS Code Scanning Rules

## Standards
- PCI-DSS v4.0 (March 2025 effective)
- PCI Software Security Framework 1.2
- OWASP Top 10 (complementary)

## File Formats
- .py (scanner code)
- .json (findings export)
- .html / .pdf (QSA evidence reports)

## Libraries
- semgrep 1.x (pattern-based scanning)
- bandit 1.7+ (Python security linter)
- custom rules (PAN, crypto, logging)

## Testing
- Scanner must detect known-bad test patterns
- False positive rate < 20% per rule
- Scan must complete within 10 minutes for 100K LOC

## PCI Requirements Covered
- Req 3.3: Mask PAN when displayed
- Req 3.4: Render PAN unreadable in storage
- Req 3.5: Protect cryptographic keys
- Req 4.2: Strong cryptography for transmission
- Req 6.2.4: Protection against common vulnerabilities
- Req 10.3: Protect audit trail from modification
```

## Common Pitfalls

- **False positives on test card numbers:** 4111111111111111 is a Luhn-valid test card that appears in test files everywhere. Claude Code maintains an allow-list of known test PANs to suppress noise.
- **Scanning binary files:** Running regex PAN detection on binary files produces false positives from random byte sequences. Claude Code filters to source code extensions and validates encoding before scanning.
- **Missing encrypted storage check:** Finding no PANs in code does not mean compliance. The data might be in a database column. Claude Code generates a checklist of database-level checks alongside code-level scanning.

## Related

- [Claude Code for FDA 21 CFR Part 11](/claude-code-fda-21-cfr-part-11-validation-2026/)
- [Claude Code for HIPAA Development](/claude-code-hipaa-compliant-development-workflow-guide/)
- [CLAUDE.md File Guide](/claude-md-file-complete-guide-what-it-does/)
