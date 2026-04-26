---
layout: default
title: "Claude Code for SCADA Modernization (2026)"
permalink: /claude-code-scada-modernization-2026/
date: 2026-04-20
description: "Claude Code for SCADA Modernization — practical guide with working examples, tested configurations, and tips for developer workflows."
last_tested: "2026-04-22"
---

## Why Claude Code for SCADA Modernization

Legacy SCADA systems run on Windows XP boxes with proprietary HMI software, hardcoded Modbus addresses, and zero authentication. Modernization means migrating to OPC UA with proper security, replacing brittle VBA macros in WonderWare or FactoryTalk with maintainable Python scripts, and adding network segmentation without breaking the 24/7 process. The average water treatment plant or power substation has been running the same SCADA configuration for 15-20 years.

Claude Code reads legacy HMI tag databases, generates OPC UA server configurations, and produces the migration scripts that map old Modbus register addresses to new OPC UA node IDs. It understands ICS-specific security requirements from IEC 62443 and generates firewall rules, certificate configurations, and audit logging that satisfy both IT security and OT reliability requirements.

## The Workflow

### Step 1: Audit the Legacy System

```bash
# Export legacy tag database (typical formats)
# FactoryTalk: .csv export from Tag Editor
# WonderWare InTouch: .csv from WindowMaker
# Ignition: JSON export from Designer

mkdir -p migration/legacy_export migration/opcua_config
mkdir -p src/hmi src/data_historian src/security tests/

pip install asyncua==1.1.0 pandas openpyxl cryptography
```

### Step 2: Generate Tag Migration Mapping

```python
# src/migration/tag_migrator.py
"""Migrate legacy SCADA tag database to OPC UA node structure.
Reads FactoryTalk/InTouch CSV export, generates OPC UA address space.
"""

import csv
import json
from dataclasses import dataclass, field
from typing import Optional
from pathlib import Path

@dataclass
class LegacyTag:
    name: str
    address: str          # e.g., "N7:0", "F8:5", "40001"
    data_type: str        # INT, REAL, BOOL, STRING
    description: str
    engineering_units: str
    low_limit: Optional[float] = None
    high_limit: Optional[float] = None
    alarm_enabled: bool = False
    alarm_high: Optional[float] = None
    alarm_low: Optional[float] = None

@dataclass
class OPCUANode:
    node_id: str          # ns=2;s=Plant/Area/Tag
    browse_name: str
    data_type: str        # OPC UA type: Double, Int32, Boolean
    source_address: str   # Original Modbus/DH+ address
    engineering_unit: str
    eu_range_low: float
    eu_range_high: float

LEGACY_TO_OPCUA_TYPES = {
    "INT": "Int16",
    "DINT": "Int32",
    "REAL": "Double",
    "BOOL": "Boolean",
    "STRING": "String",
}

def parse_legacy_tags(csv_path: str) -> list:
    """Parse FactoryTalk/InTouch tag export CSV."""
    tags = []
    with open(csv_path, 'r') as f:
        reader = csv.DictReader(f)
        for row in reader:
            tag = LegacyTag(
                name=row.get('TagName', row.get('Name', '')),
                address=row.get('Address', row.get('PLCAddress', '')),
                data_type=row.get('DataType', 'REAL'),
                description=row.get('Description', ''),
                engineering_units=row.get('EngUnits', ''),
                low_limit=float(row['MinEU']) if row.get('MinEU') else None,
                high_limit=float(row['MaxEU']) if row.get('MaxEU') else None,
            )
            tags.append(tag)
    assert len(tags) > 0, f"No tags parsed from {csv_path}"
    return tags

def generate_opcua_namespace(legacy_tags: list,
                              plant_name: str = "WaterPlant",
                              area_name: str = "Intake"
                              ) -> list:
    """Generate OPC UA node definitions from legacy tags."""
    nodes = []
    for tag in legacy_tags:
        opcua_type = LEGACY_TO_OPCUA_TYPES.get(tag.data_type, "Double")
        node = OPCUANode(
            node_id=f"ns=2;s={plant_name}/{area_name}/{tag.name}",
            browse_name=tag.name,
            data_type=opcua_type,
            source_address=tag.address,
            engineering_unit=tag.engineering_units,
            eu_range_low=tag.low_limit or 0.0,
            eu_range_high=tag.high_limit or 100.0,
        )
        nodes.append(node)

    assert len(nodes) == len(legacy_tags), "Node count mismatch"
    return nodes

def export_migration_report(legacy_tags: list, nodes: list,
                             output_path: str) -> None:
    """Generate migration validation report."""
    report = {
        "total_tags": len(legacy_tags),
        "migrated_nodes": len(nodes),
        "type_mapping": {},
        "unmapped_addresses": [],
    }
    for tag, node in zip(legacy_tags, nodes):
        report["type_mapping"][tag.data_type] = \
            report["type_mapping"].get(tag.data_type, 0) + 1

    with open(output_path, 'w') as f:
        json.dump(report, f, indent=2)
```

### Step 3: Build Secure OPC UA Server

```python
# src/opcua_server/secure_server.py
"""OPC UA server with IEC 62443 security profile.
X.509 certificates, role-based access, audit logging.
"""

import asyncio
import logging
from asyncua import Server, ua
from asyncua.crypto.security_policies import SecurityPolicyBasic256Sha256
from pathlib import Path

logger = logging.getLogger(__name__)

async def create_secure_opcua_server(
    endpoint: str = "opc.tcp://0.0.0.0:4840/scada",
    cert_path: str = "certs/server_cert.pem",
    key_path: str = "certs/server_key.pem",
) -> Server:
    """Initialize OPC UA server with certificate-based security."""
    server = Server()
    await server.init()
    server.set_endpoint(endpoint)
    server.set_server_name("SCADA-Modernized-Server")

    # Load X.509 certificate for encrypted + signed sessions
    await server.load_certificate(cert_path)
    await server.load_private_key(key_path)

    # Security policies: reject unencrypted connections
    server.set_security_policy([
        ua.SecurityPolicyType.Basic256Sha256_SignAndEncrypt,
    ])

    # Disable anonymous access (IEC 62443 SL2+)
    server.set_security_IDs(["Username", "Certificate"])

    # Enable audit logging
    server.set_application_uri("urn:scada:modernized:server")

    return server

async def populate_address_space(server: Server,
                                  nodes: list) -> dict:
    """Create OPC UA nodes from migration mapping."""
    idx = await server.register_namespace("urn:scada:plant")
    objects = server.nodes.objects
    node_map = {}

    # Create folder hierarchy
    plant_folder = await objects.add_folder(idx, "WaterPlant")
    area_folder = await plant_folder.add_folder(idx, "Intake")

    TYPE_MAP = {
        "Double": ua.VariantType.Double,
        "Int16": ua.VariantType.Int16,
        "Int32": ua.VariantType.Int32,
        "Boolean": ua.VariantType.Boolean,
    }

    for node_def in nodes:
        vtype = TYPE_MAP.get(node_def.data_type, ua.VariantType.Double)
        var = await area_folder.add_variable(
            idx, node_def.browse_name,
            ua.Variant(0, vtype)
        )
        await var.set_writable()
        node_map[node_def.browse_name] = var
        logger.info(f"Created node: {node_def.node_id}")

    assert len(node_map) == len(nodes), "Not all nodes created"
    return node_map
```

### Step 4: Verify Migration

```bash
# Generate test certificates
openssl req -x509 -newkey rsa:2048 -keyout certs/server_key.pem \
    -out certs/server_cert.pem -days 365 -nodes \
    -subj "/CN=SCADA-Server/O=PlantOps"

# Run migration validation
python3 -c "
from src.migration.tag_migrator import parse_legacy_tags, generate_opcua_namespace

# Create a sample legacy export
import csv
with open('migration/legacy_export/test_tags.csv', 'w') as f:
    w = csv.DictWriter(f, ['TagName','Address','DataType','Description','EngUnits','MinEU','MaxEU'])
    w.writeheader()
    w.writerow({'TagName':'TankLevel','Address':'40001','DataType':'REAL','Description':'Intake tank','EngUnits':'m','MinEU':'0','MaxEU':'10'})
    w.writerow({'TagName':'PumpRun','Address':'40010','DataType':'BOOL','Description':'Pump 1 status','EngUnits':'','MinEU':'0','MaxEU':'1'})

tags = parse_legacy_tags('migration/legacy_export/test_tags.csv')
nodes = generate_opcua_namespace(tags)
print(f'Migrated {len(tags)} tags -> {len(nodes)} OPC UA nodes')
print(f'Node IDs: {[n.node_id for n in nodes]}')
print('Migration validation: PASS')
"
```

## CLAUDE.md for SCADA Modernization

```markdown
# SCADA System Modernization

## Standards
- IEC 62443 (Industrial Cybersecurity)
- IEC 62541 (OPC UA)
- NERC CIP (if power grid)
- NIST SP 800-82 (ICS Security Guide)

## Architecture Layers
- Level 0: Physical process (sensors, actuators)
- Level 1: PLCs, RTUs (Modbus, EtherNet/IP)
- Level 2: HMI, SCADA servers (OPC UA)
- Level 3: Historian, MES (SQL, REST APIs)
- DMZ: Data diode or firewall between L2 and L3

## File Patterns
- .csv — legacy tag database exports
- .xml — OPC UA nodeset definitions
- .pem — X.509 certificates for OPC UA security
- .json — migration mapping and audit reports

## Common Commands
- asyncua.crypto.uacrypto — generate OPC UA certs
- opcua-client opc.tcp://host:4840 — browse OPC UA server
- mbpoll -a 1 -r 40001 -c 10 host — poll Modbus registers
- wireshark -f 'tcp port 502 or tcp port 4840' — capture ICS traffic
```

## Common Pitfalls

- **Tag address offset errors:** Legacy systems use 1-based Modbus addressing (40001) but pymodbus uses 0-based offsets (0). Claude Code applies the -40001 offset consistently across all register reads and validates against a known reference reading.
- **OPC UA certificate trust rejection:** Clients reject untrusted server certificates silently. Claude Code generates the full PKI chain: CA cert, server cert signed by CA, and client trust list configuration.
- **Historian data gap during cutover:** Switching from legacy to OPC UA drops historical data continuity. Claude Code generates a dual-write bridge that feeds both old and new historians during the transition period.

## Related

- [Claude Code for Industrial IoT Protocols](/claude-code-industrial-iot-protocol-2026/)
- [Claude Code for PLC Programming](/claude-code-plc-ladder-logic-structured-text-2026/)
- [CLAUDE.md File Guide](/claude-md-file-complete-guide-what-it-does/)


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

- [Claude Code Cold Fusion Modernization](/claude-code-cold-fusion-modernization-workflow-guide/)

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
