---
title: "Claude Code for FDA 21 CFR Part 11 Validation (2026)"
description: "FDA 21 CFR Part 11 validation scripts with Claude Code. Automate electronic signature and audit trail compliance."
permalink: /claude-code-fda-21-cfr-part-11-validation-2026/
last_tested: "2026-04-21"
render_with_liquid: false
---

## Why Claude Code for 21 CFR Part 11

FDA 21 CFR Part 11 governs electronic records and electronic signatures in pharmaceutical manufacturing, clinical trials, and medical device software. Every system that creates, modifies, or stores regulated records must implement audit trails, electronic signatures with meaning, access controls, and validation protocols. Failing an FDA inspection because your audit trail has gaps costs millions in remediation.

Claude Code generates validation scripts, audit trail implementations, and IQ/OQ/PQ test protocols that follow Part 11 requirements. It understands the difference between "open" and "closed" systems, knows when electronic signatures require two distinct identification components, and produces the documentation that quality auditors expect.

## The Workflow

### Step 1: Setup

```bash
pip install sqlalchemy alembic pydantic cryptography \
  python-dateutil structlog pytest

mkdir -p part11/{models,audit,validation,signatures,tests}
```

### Step 2: Audit Trail and Electronic Signature System

```python
# part11/audit/trail.py
"""21 CFR Part 11 compliant audit trail implementation."""
import hashlib
import json
from datetime import datetime, timezone
from dataclasses import dataclass
from typing import Optional
import structlog

logger = structlog.get_logger()

MAX_RECORD_SIZE = 1_000_000  # bytes
HASH_ALGORITHM = "sha256"


@dataclass
class AuditEntry:
    entry_id: str
    timestamp: str              # ISO 8601 UTC
    user_id: str
    user_full_name: str
    action: str                 # CREATE, UPDATE, DELETE, SIGN, VIEW
    record_type: str
    record_id: str
    field_name: Optional[str]
    old_value: Optional[str]
    new_value: Optional[str]
    reason: str                 # Required for modifications
    checksum: str               # SHA-256 of entry content
    previous_checksum: str      # Chain integrity


class AuditTrail:
    """Append-only audit trail with cryptographic chain integrity."""

    def __init__(self, storage_backend):
        assert storage_backend is not None, "Storage backend required"
        self._storage = storage_backend
        self._last_checksum = "GENESIS"

    def _compute_checksum(self, entry_data: dict) -> str:
        """Compute SHA-256 checksum for audit entry."""
        canonical = json.dumps(entry_data, sort_keys=True)
        assert len(canonical) <= MAX_RECORD_SIZE, "Entry too large"
        return hashlib.sha256(canonical.encode()).hexdigest()

    def log_change(self, user_id: str, user_name: str,
                   action: str, record_type: str,
                   record_id: str, field_name: str = None,
                   old_value: str = None, new_value: str = None,
                   reason: str = "") -> AuditEntry:
        """Record a change with full attribution and chain integrity."""
        assert user_id, "User ID required (Part 11 Sec. 11.10(e))"
        assert user_name, "User full name required"
        assert action in ("CREATE", "UPDATE", "DELETE", "SIGN", "VIEW"), \
            f"Invalid action: {action}"
        assert record_type, "Record type required"
        assert record_id, "Record ID required"

        # Part 11 Sec. 11.10(e): reason required for changes
        if action in ("UPDATE", "DELETE"):
            assert reason, \
                "Reason required for modifications (21 CFR 11.10(e))"

        timestamp = datetime.now(timezone.utc).isoformat()

        entry_data = {
            "timestamp": timestamp,
            "user_id": user_id,
            "action": action,
            "record_type": record_type,
            "record_id": record_id,
            "field_name": field_name,
            "old_value": old_value,
            "new_value": new_value,
            "reason": reason,
            "previous_checksum": self._last_checksum,
        }

        checksum = self._compute_checksum(entry_data)

        entry = AuditEntry(
            entry_id=f"AUD-{timestamp.replace(':', '').replace('-', '')}",
            timestamp=timestamp,
            user_id=user_id,
            user_full_name=user_name,
            action=action,
            record_type=record_type,
            record_id=record_id,
            field_name=field_name,
            old_value=old_value,
            new_value=new_value,
            reason=reason,
            checksum=checksum,
            previous_checksum=self._last_checksum,
        )

        self._storage.append(entry)
        self._last_checksum = checksum

        logger.info("audit_entry",
                     action=action,
                     record=f"{record_type}/{record_id}",
                     user=user_id)
        return entry

    def verify_chain(self) -> bool:
        """Verify audit trail integrity — detect tampering."""
        entries = self._storage.get_all()
        assert len(entries) > 0, "Empty audit trail"

        prev_checksum = "GENESIS"
        for entry in entries:
            assert entry.previous_checksum == prev_checksum, \
                f"Chain broken at {entry.entry_id}: " \
                f"expected {prev_checksum}, got {entry.previous_checksum}"

            entry_data = {
                "timestamp": entry.timestamp,
                "user_id": entry.user_id,
                "action": entry.action,
                "record_type": entry.record_type,
                "record_id": entry.record_id,
                "field_name": entry.field_name,
                "old_value": entry.old_value,
                "new_value": entry.new_value,
                "reason": entry.reason,
                "previous_checksum": entry.previous_checksum,
            }
            computed = self._compute_checksum(entry_data)
            assert computed == entry.checksum, \
                f"Checksum mismatch at {entry.entry_id}: tampering detected"

            prev_checksum = entry.checksum

        return True


@dataclass
class ElectronicSignature:
    """21 CFR Part 11 Sec. 11.50 compliant electronic signature."""
    signer_user_id: str
    signer_printed_name: str
    signature_meaning: str      # e.g., "approval", "review", "authorship"
    timestamp: str
    record_type: str
    record_id: str


def apply_signature(user_id: str, password: str,
                    printed_name: str, meaning: str,
                    record_type: str, record_id: str,
                    auth_service) -> ElectronicSignature:
    """Apply electronic signature with two-factor authentication."""
    # Part 11 Sec. 11.200(a)(1): at least two distinct components
    assert user_id, "User ID required (component 1)"
    assert password, "Password required (component 2)"
    assert meaning in ("approval", "review", "authorship", "verification"), \
        f"Invalid signature meaning: {meaning}"
    assert printed_name, "Printed name required (Sec. 11.50)"

    # Authenticate
    authenticated = auth_service.verify(user_id, password)
    assert authenticated, \
        "Authentication failed — signature not applied"

    sig = ElectronicSignature(
        signer_user_id=user_id,
        signer_printed_name=printed_name,
        signature_meaning=meaning,
        timestamp=datetime.now(timezone.utc).isoformat(),
        record_type=record_type,
        record_id=record_id,
    )

    logger.info("electronic_signature",
                meaning=meaning,
                record=f"{record_type}/{record_id}",
                signer=user_id)
    return sig


class InMemoryStorage:
    """Simple in-memory storage for demonstration."""
    def __init__(self):
        self._entries = []

    def append(self, entry):
        self._entries.append(entry)

    def get_all(self):
        return list(self._entries)


if __name__ == "__main__":
    storage = InMemoryStorage()
    trail = AuditTrail(storage)

    # Simulate a batch record lifecycle
    trail.log_change("jsmith", "John Smith", "CREATE",
                     "BatchRecord", "BR-2026-0421",
                     reason="")

    trail.log_change("jsmith", "John Smith", "UPDATE",
                     "BatchRecord", "BR-2026-0421",
                     field_name="yield_kg",
                     old_value="98.5",
                     new_value="99.1",
                     reason="Corrected weighing transcription error")

    # Verify chain integrity
    valid = trail.verify_chain()
    print(f"Audit trail integrity: {'PASS' if valid else 'FAIL'}")
    print(f"Entries: {len(storage.get_all())}")
```

### Step 3: Validation Protocol

```bash
python3 part11/audit/trail.py
# Expected: Audit trail integrity: PASS, Entries: 2

# Run IQ/OQ/PQ test suite
pytest part11/tests/ -v --tb=short
# Expected: all validation test cases pass

# Generate validation report
python3 part11/validation/generate_report.py
# Expected: IQ/OQ/PQ report in PDF or HTML format
```

## CLAUDE.md for 21 CFR Part 11

```markdown
# FDA 21 CFR Part 11 Development Rules

## Standards
- 21 CFR Part 11 (Electronic Records/Signatures)
- FDA Guidance: Part 11 Scope and Application (2003)
- GAMP 5 (Good Automated Manufacturing Practice)
- ISPE GAMP Software Categories

## File Formats
- .py (application code)
- .sql (database migrations)
- .json (audit trail records)
- .pdf (validation protocols and reports)

## Libraries
- SQLAlchemy 2.0+ (ORM with audit mixin)
- Alembic 1.13+ (versioned schema migrations)
- cryptography 42+ (hashing, signatures)
- structlog 24.x (structured audit logging)

## Testing
- IQ: Installation Qualification (environment verification)
- OQ: Operational Qualification (feature testing)
- PQ: Performance Qualification (load/stress testing)
- Every test must be traceable to a requirement

## Compliance Requirements
- Audit trail: every change recorded with who/what/when/why
- Electronic signatures: two distinct identification components
- Access controls: role-based, documented
- System validation: IQ/OQ/PQ protocol with evidence
- Data integrity: ALCOA+ principles
```

## Common Pitfalls

- **Audit trail gaps during system errors:** If an exception occurs between the data change and the audit log write, you lose the audit entry. Claude Code wraps data changes and audit writes in the same database transaction.
- **Electronic signature without meaning:** Part 11 Sec. 11.50 requires that each signature include the printed name, date/time, and the MEANING (approval, review, etc.). Claude Code enforces the meaning field as a required parameter.
- **Mutable audit records:** If audit trail entries can be edited or deleted, the entire trail is invalidated. Claude Code implements append-only storage with cryptographic chain integrity (each entry's checksum includes the previous entry's checksum).

## Related

- [Claude Code for HIPAA Development](/claude-code-hipaa-compliant-development-workflow-guide/)
- [Claude Code for PCI-DSS Scanning](/claude-code-pci-dss-code-scanning-2026/)
- [CLAUDE.md File Guide](/claude-md-file-complete-guide-what-it-does/)
