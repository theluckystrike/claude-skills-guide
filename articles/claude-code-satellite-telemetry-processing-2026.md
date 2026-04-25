---
layout: default
title: "Claude Code for Satellite Telemetry (2026)"
permalink: /claude-code-satellite-telemetry-processing-2026/
date: 2026-04-20
description: "Satellite telemetry processing with Claude Code. Parse CCSDS packets, decode housekeeping data, and build ground station pipelines."
last_tested: "2026-04-22"
---

## Why Claude Code for Satellite Telemetry

Satellite telemetry arrives as CCSDS (Consultative Committee for Space Data Systems) packets -- binary frames with version headers, APIDs, sequence counters, and mission-specific housekeeping payloads. Ground station software must decommutate these frames in real time, apply calibration curves, check limit violations, and route data to archival and display systems. The CCSDS Space Packet Protocol standard alone is 60 pages of bit-level formatting rules.

Claude Code understands CCSDS packet structures, binary unpacking, and the calibration chain from raw DN (Data Numbers) to engineering units. It generates parsers that handle the bit-packing edge cases -- like 12-bit ADC values spanning byte boundaries -- that cause silent data corruption when done wrong.

## The Workflow

### Step 1: Ground Station Toolchain Setup

```bash
pip install spacepackets satpy skyfield astropy
pip install bitstring construct  # binary parsing
pip install influxdb-client grafana-api  # telemetry storage + display

mkdir -p src/decom src/calibration src/limits tests/
```

### Step 2: Build a CCSDS Telemetry Parser

```python
# src/decom/ccsds_parser.py
"""CCSDS Space Packet decommutator.
Parses telemetry per CCSDS 133.0-B-2 (Space Packet Protocol).
"""

import struct
from dataclasses import dataclass
from typing import Optional
from bitstring import ConstBitStream

@dataclass
class CCSDSHeader:
    version: int        # 3 bits — always 0 for version 1
    type_flag: int      # 1 bit — 0=telemetry, 1=telecommand
    sec_hdr_flag: int   # 1 bit
    apid: int           # 11 bits — Application Process Identifier
    seq_flags: int      # 2 bits — 3=unsegmented
    seq_count: int      # 14 bits — packet sequence counter
    data_length: int    # 16 bits — (total bytes in data field) - 1

@dataclass
class TelemetryPacket:
    header: CCSDSHeader
    timestamp_s: float
    payload: bytes

def parse_ccsds_header(raw: bytes) -> CCSDSHeader:
    """Parse 6-byte CCSDS primary header."""
    assert len(raw) >= 6, f"Header too short: {len(raw)} bytes"

    bits = ConstBitStream(bytes=raw[:6])
    version = bits.read('uint:3')
    type_flag = bits.read('uint:1')
    sec_hdr_flag = bits.read('uint:1')
    apid = bits.read('uint:11')
    seq_flags = bits.read('uint:2')
    seq_count = bits.read('uint:14')
    data_length = bits.read('uint:16')

    assert version == 0, f"Unsupported CCSDS version: {version}"
    return CCSDSHeader(version, type_flag, sec_hdr_flag,
                       apid, seq_flags, seq_count, data_length)

def parse_cuc_timestamp(raw: bytes, epoch_offset: float = 0.0) -> float:
    """Parse CCSDS Unsegmented Code (CUC) timestamp.
    4 bytes coarse (seconds) + 2 bytes fine (subseconds).
    """
    coarse = struct.unpack('>I', raw[0:4])[0]
    fine = struct.unpack('>H', raw[4:6])[0]
    fractional = fine / 65536.0
    return coarse + fractional + epoch_offset

def decommutate_packet(raw: bytes,
                       mission_epoch: float = 946684800.0
                       ) -> Optional[TelemetryPacket]:
    """Full packet decommutation: header + timestamp + payload."""
    if len(raw) < 6:
        return None

    header = parse_ccsds_header(raw)
    total_data = header.data_length + 1
    packet_end = 6 + total_data

    assert len(raw) >= packet_end, "Truncated packet"

    data = raw[6:packet_end]

    if header.sec_hdr_flag:
        timestamp = parse_cuc_timestamp(data[:6], mission_epoch)
        payload = data[6:]
    else:
        timestamp = 0.0
        payload = data

    return TelemetryPacket(header, timestamp, payload)
```

### Step 3: Apply Calibration Curves

```python
# src/calibration/calibration.py
"""Convert raw DN (Data Numbers) to engineering units.
Calibration tables from spacecraft ICD (Interface Control Document).
"""

import numpy as np
from dataclasses import dataclass

@dataclass
class CalibrationEntry:
    name: str
    byte_offset: int
    bit_length: int
    cal_type: str       # 'linear', 'polynomial', 'thermistor'
    coefficients: list   # [a0, a1, ...] for polynomial

# Example: EPS (Electrical Power System) housekeeping
EPS_CALIBRATIONS = [
    CalibrationEntry("bus_voltage_v", 0, 12, "linear", [0.0, 0.00488]),
    CalibrationEntry("bus_current_a", 2, 12, "linear", [0.0, 0.001221]),
    CalibrationEntry("battery_temp_c", 4, 12, "thermistor",
                     [-40.0, 0.0488, -0.0000123]),  # Steinhart-Hart approx
    CalibrationEntry("solar_panel_w", 6, 16, "linear", [0.0, 0.0305]),
]

def apply_calibration(raw_dn: int, cal: CalibrationEntry) -> float:
    """Apply calibration curve to raw data number."""
    assert raw_dn >= 0, f"Negative DN for {cal.name}: {raw_dn}"

    if cal.cal_type == "linear":
        return cal.coefficients[0] + cal.coefficients[1] * raw_dn
    elif cal.cal_type == "polynomial":
        return sum(c * (raw_dn ** i) for i, c in enumerate(cal.coefficients))
    elif cal.cal_type == "thermistor":
        # Simplified Steinhart-Hart
        a, b, c = cal.coefficients
        return a + b * raw_dn + c * (raw_dn ** 2)
    else:
        raise ValueError(f"Unknown calibration type: {cal.cal_type}")

def decom_eps_housekeeping(payload: bytes) -> dict:
    """Decommutate EPS housekeeping packet (APID 0x010)."""
    from bitstring import ConstBitStream
    bits = ConstBitStream(bytes=payload)
    results = {}

    for cal in EPS_CALIBRATIONS:
        bits.pos = cal.byte_offset * 8
        raw_dn = bits.read(f'uint:{cal.bit_length}')
        results[cal.name] = apply_calibration(raw_dn, cal)

    return results
```

### Step 4: Verify with Captured Telemetry

```bash
python3 -c "
from src.decom.ccsds_parser import decommutate_packet
from src.calibration.calibration import decom_eps_housekeeping

# Simulated CCSDS frame: APID 0x010 (EPS), 18 bytes payload
test_frame = bytes([
    0x00, 0x10,  # Ver=0, Type=0, SecHdr=0, APID=0x010
    0xC0, 0x01,  # SeqFlags=3, SeqCount=1
    0x00, 0x11,  # DataLength=17 (18 bytes - 1)
    # Payload: 12-bit bus_volt=820, 12-bit current=410, ...
    0x33, 0x40, 0x19, 0xA0, 0x08, 0x00, 0x01, 0xF4,
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
    0x00, 0x00
])
pkt = decommutate_packet(test_frame)
print(f'APID: 0x{pkt.header.apid:03X}, SeqCount: {pkt.header.seq_count}')
print(f'Payload: {len(pkt.payload)} bytes')
print('Parse: PASS')
"
```

## CLAUDE.md for Satellite Telemetry

```markdown
# Satellite Ground Station Development

## Standards
- CCSDS 133.0-B-2 (Space Packet Protocol)
- CCSDS 301.0-B-4 (Time Code Formats)
- ECSS-E-ST-70-41C (Packet Utilization Standard)
- Mission-specific ICD for packet definitions

## File Patterns
- .bin — raw telemetry binary captures
- .csv — decommutated engineering data
- .xtce — XML Telemetric and Command Exchange (packet definitions)
- .db — calibration database

## Libraries
- spacepackets 0.24+ (CCSDS packet parsing)
- bitstring 4.1+ (bit-level binary access)
- satpy (satellite imagery processing)
- skyfield (orbit propagation)
- influxdb-client (time-series storage)

## Common Commands
- python3 src/decom/ccsds_parser.py < capture.bin — parse telemetry
- gr_satellites --tlm_file capture.raw — GNU Radio satellite decoder
- gpredict — real-time satellite tracking
- rotctl -m 204 -r /dev/ttyUSB0 — antenna rotor control
```

## Common Pitfalls

- **Byte-boundary bit packing errors:** A 12-bit ADC value starting at bit offset 4 spans two bytes with different masks. Claude Code generates bitstring extraction code that handles arbitrary bit offsets correctly.
- **Sequence counter rollover:** The 14-bit CCSDS sequence counter wraps at 16383. Naive gap detection flags a false alarm on every wrap. Claude Code generates modular arithmetic gap detection that handles the rollover.
- **Epoch mismatch:** CCSDS CUC timestamps use a mission-specific epoch (often J2000 or GPS epoch), not Unix epoch. Claude Code cross-references your ICD epoch definition and applies the correct offset in the calibration chain.

## Related

- [Claude Code for Industrial IoT Protocol Implementation](/claude-code-industrial-iot-protocol-2026/)
- [Claude Code for Telescope Data Pipeline (FITS)](/claude-code-telescope-fits-pipeline-2026/)
- [CLAUDE.md File Guide](/claude-md-file-complete-guide-what-it-does/)
- [Claude Code for Sonar Array Processing (2026)](/claude-code-sonar-array-processing-2026/)


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



## Implementation Details

When working with this in Claude Code, pay attention to these practical details:

**Project configuration.** Add specific instructions to your CLAUDE.md file describing how your project handles this area. Include file paths, naming conventions, and any patterns that differ from common defaults. Claude Code reads CLAUDE.md at the start of every session and uses it to guide all operations.

**Testing the setup.** After configuration, verify everything works by running a simple test task. Ask Claude Code to perform a read-only operation first (like listing files or reading a config) before moving to write operations. This confirms that permissions, paths, and tools are all correctly configured.

**Monitoring and iteration.** Track your results over several sessions. If Claude Code consistently makes the same mistake, the fix is usually a more specific CLAUDE.md instruction. If it makes different mistakes each time, the issue is likely in the project setup or toolchain configuration.

## Troubleshooting Checklist

When something does not work as expected, check these items in order:

1. **CLAUDE.md exists at the project root** — run `ls -la CLAUDE.md` to verify
2. **Node.js version is 18+** — run `node --version` to check
3. **API key is set** — run `echo $ANTHROPIC_API_KEY | head -c 10` to verify (shows first 10 characters only)
4. **Disk space is available** — run `df -h .` to check
5. **Network can reach the API** — run `curl -s -o /dev/null -w "%{http_code}" https://api.anthropic.com` (should return 401 without auth, meaning the server is reachable)
6. **No conflicting processes** — run `ps aux | grep claude | grep -v grep` to check for stale sessions

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
