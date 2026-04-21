---
title: "Claude Code for GDPR Data Mapping Implementation (2026)"
permalink: /claude-code-gdpr-data-mapping-2026/
description: "Implement GDPR Article 30 data mapping with Claude Code. Auto-discover personal data flows, generate processing records, and map retention policies."
last_tested: "2026-04-22"
domain: "privacy compliance"
render_with_liquid: false
---

## Why Claude Code for GDPR Data Mapping

GDPR Article 30 requires organizations to maintain Records of Processing Activities (ROPA), documenting every system that processes personal data, the legal basis for processing, data retention periods, and cross-border transfer mechanisms. In a typical enterprise with hundreds of microservices and databases, manually mapping personal data flows takes months. When systems change, the mapping becomes stale. Data Protection Officers need automated discovery that can trace personal data from API ingestion through storage, processing, and deletion.

Claude Code can analyze codebases to identify personal data fields in database schemas, API payloads, and log outputs. It generates Article 30 compliant processing records and identifies gaps in consent management, retention enforcement, and data subject rights implementation.

## The Workflow

### Step 1: Discover Personal Data in Schemas

```bash
mkdir -p ~/gdpr-mapping/{output,reports}

# Extract database schemas for analysis
pg_dump --schema-only mydb > ~/gdpr-mapping/schema.sql

# Find potential PII columns across all services
find /path/to/services -name "*.prisma" -o -name "*.sql" \
  -o -name "*.entity.ts" -o -name "*.model.py" \
  | sort > ~/gdpr-mapping/schema-files.txt
```

### Step 2: Auto-Classify Personal Data Fields

```python
#!/usr/bin/env python3
"""GDPR Article 30 data mapping: auto-discover personal data in schemas."""

import re
from dataclasses import dataclass, field
from pathlib import Path

# GDPR personal data categories per Article 4(1) and Recital 30
PII_CLASSIFIERS = {
    "identifying": {
        "patterns": ["name", "first_name", "last_name", "full_name",
                     "username", "user_name", "display_name"],
        "gdpr_category": "Identifying Information",
        "special_category": False
    },
    "contact": {
        "patterns": ["email", "phone", "mobile", "fax", "address",
                     "street", "city", "postal", "zip_code", "country"],
        "gdpr_category": "Contact Information",
        "special_category": False
    },
    "financial": {
        "patterns": ["credit_card", "card_number", "iban", "bank_account",
                     "billing", "payment", "salary", "income"],
        "gdpr_category": "Financial Data",
        "special_category": False
    },
    "identity_documents": {
        "patterns": ["ssn", "social_security", "passport", "national_id",
                     "driver_license", "tax_id", "vat_number"],
        "gdpr_category": "Government Identifiers",
        "special_category": False
    },
    "special_category_art9": {
        "patterns": ["ethnicity", "race", "religion", "political",
                     "health", "medical", "diagnosis", "disability",
                     "genetic", "biometric", "sexual_orientation",
                     "trade_union"],
        "gdpr_category": "Special Category Data (Art. 9)",
        "special_category": True
    },
    "tracking": {
        "patterns": ["ip_address", "device_id", "cookie", "session_id",
                     "user_agent", "geolocation", "latitude", "longitude"],
        "gdpr_category": "Online Identifiers",
        "special_category": False
    }
}

@dataclass
class DataField:
    source_file: str
    table_or_model: str
    field_name: str
    gdpr_category: str
    special_category: bool
    requires_consent: bool
    retention_policy: str | None = None
    legal_basis: str | None = None
    cross_border: bool = False

@dataclass
class ProcessingRecord:
    """GDPR Article 30 Record of Processing Activity."""
    processing_name: str
    controller: str
    purpose: str
    legal_basis: str
    data_subjects: list[str]
    data_categories: list[str]
    recipients: list[str]
    transfers: list[str]
    retention: str
    security_measures: list[str]
    data_fields: list[DataField] = field(default_factory=list)

def scan_schema_file(filepath: Path) -> list[DataField]:
    """Scan a schema file for personal data fields."""
    findings = []
    content = filepath.read_text()
    current_table = "unknown"

    for line in content.split('\n'):
        # Detect table/model name
        table_match = re.search(
            r'(?:CREATE TABLE|model|class)\s+["\']?(\w+)', line, re.I
        )
        if table_match:
            current_table = table_match.group(1)

        # Check each field against PII classifiers
        field_match = re.search(r'(\w+)\s+(?:VARCHAR|TEXT|STRING|Int|String|str)', line, re.I)
        if not field_match:
            continue

        field_name = field_match.group(1).lower()

        for category, config in PII_CLASSIFIERS.items():
            for pattern in config["patterns"]:
                if pattern in field_name:
                    findings.append(DataField(
                        source_file=str(filepath),
                        table_or_model=current_table,
                        field_name=field_name,
                        gdpr_category=config["gdpr_category"],
                        special_category=config["special_category"],
                        requires_consent=config["special_category"]
                    ))
                    break

    return findings

def generate_ropa(fields: list[DataField]) -> list[ProcessingRecord]:
    """Generate Article 30 Records of Processing Activities from discovered data."""
    # Group fields by table/model to create processing records
    by_table: dict[str, list[DataField]] = {}
    for f in fields:
        by_table.setdefault(f.table_or_model, []).append(f)

    records = []
    for table, table_fields in by_table.items():
        categories = list(set(f.gdpr_category for f in table_fields))
        has_special = any(f.special_category for f in table_fields)

        records.append(ProcessingRecord(
            processing_name=f"Processing: {table}",
            controller="[Company Name]",
            purpose="[TO BE COMPLETED by DPO]",
            legal_basis="Art. 9(2)(a) Explicit Consent" if has_special
                        else "Art. 6(1)(b) Contract Performance",
            data_subjects=["Customers", "Users"],
            data_categories=categories,
            recipients=["[Internal teams]"],
            transfers=["[Check for non-EU processors]"],
            retention="[TO BE DEFINED]",
            security_measures=["Encryption at rest", "TLS in transit",
                              "Access controls", "Audit logging"],
            data_fields=table_fields
        ))

    return records
```

### Step 3: Map Data Flows Across Services

```python
def trace_data_flow(service_dir: Path) -> dict:
    """Trace personal data through API endpoints, services, and storage."""
    flows = {
        "ingestion_points": [],   # Where PII enters the system
        "storage_locations": [],   # Where PII is persisted
        "processing_steps": [],    # Where PII is transformed
        "output_points": [],       # Where PII leaves the system
        "deletion_paths": []       # How PII is deleted (Art. 17)
    }

    for filepath in service_dir.rglob('*.ts'):
        content = filepath.read_text(errors='ignore')

        # Detect API ingestion of PII
        if re.search(r'req\.body\.(name|email|phone|address)', content):
            flows["ingestion_points"].append({
                "file": str(filepath),
                "type": "API endpoint",
                "data": re.findall(r'req\.body\.(\w+)', content)
            })

        # Detect data deletion endpoints (GDPR Art. 17)
        if re.search(r'DELETE|destroy|remove.*user|erase', content, re.I):
            flows["deletion_paths"].append({
                "file": str(filepath),
                "method": "hard_delete" if "DELETE FROM" in content else "soft_delete"
            })

    return flows
```

### Step 4: Verify

```bash
# Run data mapping
python3 ~/gdpr-mapping/scanner.py \
  --schemas ~/gdpr-mapping/schema-files.txt \
  --services /path/to/services \
  --output ~/gdpr-mapping/output/ropa.json

# Validate Article 30 completeness
python3 -c "
import json
with open('output/ropa.json') as f:
    ropa = json.load(f)
for record in ropa['records']:
    gaps = []
    if 'TO BE' in record['purpose']: gaps.append('purpose')
    if 'TO BE' in record['retention']: gaps.append('retention')
    if gaps:
        print(f'INCOMPLETE: {record[\"processing_name\"]} - missing: {gaps}')
    else:
        print(f'COMPLETE: {record[\"processing_name\"]}')
"
```

## CLAUDE.md for GDPR Data Mapping

```markdown
# GDPR Data Mapping Standards

## Domain Rules
- Every database table with personal data needs an Article 30 processing record
- Special category data (Art. 9) requires explicit consent or specific exemption
- All personal data must have defined retention periods
- Data subject rights (access, rectification, erasure, portability) must have code paths
- Cross-border transfers require adequacy decision, SCCs, or BCRs documentation
- Cookie consent must be granular (not bundled) per EDPB guidelines

## File Patterns
- Schema files: *.prisma, *.sql, *.entity.ts, *.model.py
- API routes: routes/*.ts, controllers/*.py (ingestion/output points)
- ROPA output: ropa/*.json (Article 30 records)
- DPIA: dpia/*.md (Data Protection Impact Assessments)

## Common Commands
- python3 scanner.py --schemas schema-files.txt --output ropa.json
- pg_dump --schema-only database > schema.sql
- python3 trace_flows.py --services /path/to/services
- python3 verify_deletion.py --test-user test@example.com
```

## Common Pitfalls in GDPR Data Mapping

- **Soft deletes violate erasure:** Many applications use `deleted_at` timestamps instead of actual deletion. Claude Code identifies soft-delete patterns and flags them as potential Article 17 violations that need either hard-delete implementation or documented retention justification.

- **Third-party SDK data collection:** Analytics SDKs, error tracking, and customer support widgets often process personal data without documented legal basis. Claude Code scans package dependencies for known data-collecting SDKs and adds them to the ROPA.

- **Backup retention exceeds policy:** Database backups may retain personal data long after the defined retention period. Claude Code checks backup retention configurations against ROPA retention periods and flags conflicts.

## Related

- [Claude Code for CCPA Data Handling](/claude-code-ccpa-data-handling-2026/)
- [Claude Code for HIPAA Compliance Code Review](/claude-code-hipaa-compliance-code-review-2026/)
- [Claude Code for EU AI Act Compliance](/claude-code-eu-ai-act-compliance-2026/)
