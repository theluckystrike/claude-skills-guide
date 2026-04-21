---
title: "Claude Code for PCB Layout Review with KiCad (2026)"
description: "PCB layout review workflow with Claude Code and KiCad. Catch DRC errors and net mismatches before fabrication."
permalink: /claude-code-pcb-layout-review-kicad-2026/
last_tested: "2026-04-21"
render_with_liquid: false
---

## Why Claude Code for PCB Review

PCB design review is tedious and error-prone. A missed net, wrong footprint, or violated clearance rule costs $500-$5,000 per board respin and weeks of delay. KiCad 8 stores schematics and board files as parseable S-expression text, which means Claude Code can read, diff, and audit your designs programmatically.

Claude Code will not replace your DRC engine, but it can parse KiCad netlists against your schematic, flag suspicious pad-to-track ratios, check BOM consistency, and generate review checklists that catch the mistakes your eyes miss at 2 AM before a tapeout deadline.

## The Workflow

### Step 1: Environment Setup

```bash
# KiCad 8 CLI tools
which kicad-cli || brew install kicad  # macOS
# Python parsing libraries
pip install kicad-skip sexpdata pcbnew-transition
# BOM and netlist tools
pip install kibot kibom
```

### Step 2: Export and Parse the Netlist

```python
# scripts/netlist_audit.py
"""Audit KiCad netlist for common PCB review issues."""
import sexpdata
import sys
from pathlib import Path

def parse_netlist(netlist_path: str) -> dict:
    """Parse KiCad XML netlist into component dict."""
    assert Path(netlist_path).exists(), f"Netlist not found: {netlist_path}"

    with open(netlist_path, 'r') as f:
        content = f.read()

    components = {}
    # Parse component references and values
    import xml.etree.ElementTree as ET
    root = ET.fromstring(content)
    for comp in root.findall('.//comp'):
        ref = comp.get('ref')
        value_el = comp.find('value')
        footprint_el = comp.find('footprint')
        assert ref is not None, "Component missing reference designator"
        components[ref] = {
            'value': value_el.text if value_el is not None else 'MISSING',
            'footprint': footprint_el.text if footprint_el is not None else 'MISSING',
        }
    return components


def check_missing_footprints(components: dict) -> list:
    """Flag components with no footprint assigned."""
    missing = []
    for ref, data in components.items():
        if data['footprint'] == 'MISSING':
            missing.append(ref)
    return missing


def check_passive_values(components: dict) -> list:
    """Flag resistors/capacitors with suspicious values."""
    warnings = []
    for ref, data in components.items():
        if ref.startswith('R') and data['value'] == 'MISSING':
            warnings.append(f"{ref}: resistor with no value")
        if ref.startswith('C') and data['value'] == 'MISSING':
            warnings.append(f"{ref}: capacitor with no value")
    return warnings


def audit(netlist_path: str) -> None:
    """Run all checks against netlist."""
    components = parse_netlist(netlist_path)
    assert len(components) > 0, "Empty netlist — check export"

    missing_fp = check_missing_footprints(components)
    bad_passives = check_passive_values(components)

    print(f"Components: {len(components)}")
    print(f"Missing footprints: {len(missing_fp)}")
    for m in missing_fp:
        print(f"  WARN: {m} has no footprint")
    print(f"Passive value issues: {len(bad_passives)}")
    for w in bad_passives:
        print(f"  WARN: {w}")

    assert len(missing_fp) == 0, f"{len(missing_fp)} components missing footprints"


if __name__ == '__main__':
    assert len(sys.argv) == 2, "Usage: python netlist_audit.py <netlist.xml>"
    audit(sys.argv[1])
```

### Step 3: Automated DRC via KiCad CLI

```bash
# Run DRC from command line (KiCad 8+)
kicad-cli pcb drc --output drc-report.json --format json my_board.kicad_pcb
# Run ERC on schematic
kicad-cli sch erc --output erc-report.json --format json my_schematic.kicad_sch

# Parse results
python3 -c "
import json
with open('drc-report.json') as f:
    report = json.load(f)
violations = report.get('violations', [])
print(f'DRC violations: {len(violations)}')
for v in violations[:10]:
    print(f'  {v[\"severity\"]}: {v[\"description\"]}')
"
# Expected: 0 violations for clean board
```

### Step 4: BOM Cross-Check

```bash
# Generate BOM with KiBot
kibot -c kibot.yaml -b my_board.kicad_pcb -s bom
# Compare BOM against approved parts list
python3 scripts/bom_compare.py bom_output.csv approved_parts.csv
```

## CLAUDE.md for PCB Review

```markdown
# PCB Design Review Rules

## Standards
- IPC-2221B (Generic PCB Design)
- IPC-7351B (Footprint land patterns)
- KiCad 8 S-expression format

## File Formats
- .kicad_sch (schematic)
- .kicad_pcb (board layout)
- .kicad_sym (symbol library)
- .kicad_mod (footprint library)
- .xml (netlist export)

## Libraries
- kicad-skip 0.3+ (S-expression parser)
- kibot 1.7+ (automation)
- sexpdata 1.0+ (S-expression handling)

## Testing
- DRC must pass with zero violations before review
- ERC must pass with zero errors (warnings acceptable with justification)
- BOM must match approved vendor list

## Design Rules
- Minimum trace width: 0.15mm (6 mil) for signal, 0.3mm for power
- Minimum clearance: 0.15mm
- Via drill: 0.3mm minimum
- All copper pours must have thermal relief
```

## Common Pitfalls

- **Footprint mismatch after symbol edit:** Changing a schematic symbol without updating the footprint association causes silent BOM errors. Claude Code can diff your .kicad_sch against the PCB netlist to catch orphaned associations.
- **Thermal pad not connected:** QFN and BGA thermal pads that are drawn but not connected to the copper pour are invisible in visual review. Scripted netlist parsing catches them instantly.
- **Missing courtyard on custom footprints:** KiCad DRC only flags courtyard overlap if courtyards exist. Claude Code checks that every footprint in your library has a courtyard layer defined.

## Related

- [Claude Code for FPGA Development](/claude-code-for-fpga-development-workflow-tutorial/)
- [Claude Code for Embedded Systems](/claude-skills-for-embedded-systems-iot-firmware/)
- [Claude Code for Beginners](/claude-code-for-beginners-complete-getting-started-2026/)
