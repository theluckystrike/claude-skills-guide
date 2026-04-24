---
title: "Claude Code for RPG/AS400 to Modern API"
description: "RPG AS/400 modernization with Claude Code. Wrap legacy RPG programs as REST APIs with proper data mapping."
permalink: /claude-code-rpg-as400-modernization-2026/
last_tested: "2026-04-21"
render_with_liquid: false
---

## Why Claude Code for RPG Modernization

IBM i (AS/400) systems running RPG programs process billions of transactions annually in manufacturing, distribution, and insurance. The green-screen interfaces are functional but cannot integrate with modern web applications, mobile apps, or API-first architectures. Many organizations need to expose RPG program logic as REST APIs without rewriting the business rules that took decades to perfect.

Claude Code understands RPG IV (ILE RPG) syntax: fixed-format and free-format declarations, data structures, file specifications, and the program call interface. It generates API wrappers using IBM's PCML (Program Call Markup Language) or direct JDBC calls that invoke RPG programs and map their input/output data structures to JSON.

## The Workflow

### Step 1: Setup

```bash
# Java environment for JT400 (IBM Toolbox for Java)
java -version  # JDK 17+

# Maven project with JT400 dependency
mvn archetype:generate \
  -DgroupId=com.legacy.api \
  -DartifactId=rpg-api-wrapper \
  -DarchetypeArtifactId=maven-archetype-quickstart

# Add JT400 to pom.xml
# <dependency>
#   <groupId>net.sf.jt400</groupId>
#   <artifactId>jt400</artifactId>
#   <version>20.0.7</version>
# </dependency>

pip install pyodbc  # Alternative: Python with IBM i Access ODBC

mkdir -p rpg_migration/{rpg_src,pcml,java_api,tests}
```

### Step 2: RPG Data Structure Mapper

```python
# rpg_migration/map_rpg_ds.py
"""Map RPG data structures to JSON-compatible schemas."""
import re
from pathlib import Path
from dataclasses import dataclass
import json

MAX_DS_FIELDS = 200
MAX_FIELD_LENGTH = 32766


@dataclass
class RPGField:
    name: str
    from_pos: int
    to_pos: int
    data_type: str    # A=Alpha, S=Zoned, P=Packed, B=Binary
    decimals: int
    length: int
    json_name: str
    json_type: str


def parse_dspec(line: str) -> dict:
    """Parse RPG D-spec (data definition) in fixed format."""
    # Fixed format columns:
    # 6: D-spec type
    # 7-21: Name
    # 22: External description
    # 23-25: Length/From
    # 26-32: Definition type / To position
    # 33-39: Data type/decimal
    # 40-80: Keywords

    if len(line) < 40:
        return None

    name = line[6:21].strip()
    if not name:
        return None

    ds_type = line[21:22].strip()
    from_to = line[25:32].strip()
    data_def = line[32:39].strip()

    return {
        "name": name,
        "ds_type": ds_type,
        "from_to": from_to,
        "data_def": data_def,
    }


def parse_free_format_ds(content: str) -> list:
    """Parse free-format RPG data structure declarations."""
    fields = []

    # Match: DCL-DS name; ... END-DS;
    ds_blocks = re.findall(
        r'DCL-DS\s+(\w+).*?;(.*?)END-DS\s*;',
        content, re.DOTALL | re.I)

    for ds_name, body in ds_blocks:
        for line in body.split(";"):
            line = line.strip()
            if not line:
                continue

            # field_name type(length[:decimals])
            match = re.match(
                r'(\w+)\s+(CHAR|VARCHAR|ZONED|PACKED|INT|UNS|DATE|TIME|TIMESTAMP)'
                r'\((\d+)(?::(\d+))?\)',
                line, re.I)

            if match:
                fname = match.group(1)
                dtype = match.group(2).upper()
                length = int(match.group(3))
                decimals = int(match.group(4)) if match.group(4) else 0

                json_type = "string"
                if dtype in ("ZONED", "PACKED", "INT", "UNS"):
                    json_type = "number" if decimals > 0 else "integer"
                elif dtype in ("DATE", "TIME", "TIMESTAMP"):
                    json_type = "string"  # ISO format

                fields.append(RPGField(
                    name=fname,
                    from_pos=0,
                    to_pos=length,
                    data_type=dtype[0],
                    decimals=decimals,
                    length=length,
                    json_name=to_camel_case(fname),
                    json_type=json_type,
                ))

    assert len(fields) <= MAX_DS_FIELDS, \
        f"Too many fields: {len(fields)}"
    return fields


def to_camel_case(rpg_name: str) -> str:
    """Convert RPG field name to camelCase."""
    assert rpg_name, "Empty field name"
    # RPG often uses UPPER_CASE or abbreviations
    parts = rpg_name.lower().split("_")
    return parts[0] + "".join(p.capitalize() for p in parts[1:])


def generate_json_schema(fields: list, ds_name: str) -> dict:
    """Generate JSON Schema from RPG data structure fields."""
    assert len(fields) > 0, "No fields to map"

    properties = {}
    required = []
    for f in fields:
        prop = {"type": f.json_type}
        if f.json_type == "string" and f.data_type == "A":
            prop["maxLength"] = f.length
        if f.json_type == "number":
            prop["multipleOf"] = 10 ** (-f.decimals)
        properties[f.json_name] = prop
        required.append(f.json_name)

    return {
        "$schema": "https://json-schema.org/draft/2020-12/schema",
        "title": ds_name,
        "type": "object",
        "properties": properties,
        "required": required,
    }


def generate_pcml(fields: list, program_name: str,
                  output_path: str) -> None:
    """Generate PCML (Program Call Markup Language) for JT400."""
    assert len(fields) > 0
    assert program_name

    pcml_lines = [
        '<?xml version="1.0" encoding="UTF-8"?>',
        f'<pcml version="6.0">',
        f'  <program name="{program_name}" path="/QSYS.LIB/MYLIB.LIB/{program_name}.PGM">',
    ]

    type_map = {
        "A": "char",
        "S": "zoned",
        "P": "packed",
        "B": "int",
    }

    for f in fields:
        pcml_type = type_map.get(f.data_type, "char")
        attrs = f'name="{f.name}" type="{pcml_type}" length="{f.length}"'
        if f.decimals > 0:
            attrs += f' precision="{f.length}" count="{f.decimals}"'
        attrs += ' usage="inputoutput"'
        pcml_lines.append(f'    <data {attrs}/>')

    pcml_lines.append('  </program>')
    pcml_lines.append('</pcml>')

    with open(output_path, 'w') as fp:
        fp.write("\n".join(pcml_lines))
    print(f"Generated PCML: {output_path}")


if __name__ == "__main__":
    import sys
    assert len(sys.argv) >= 2, \
        "Usage: python map_rpg_ds.py <program.rpgle>"

    filepath = sys.argv[1]
    assert Path(filepath).exists(), f"File not found: {filepath}"

    with open(filepath) as f:
        content = f.read()

    fields = parse_free_format_ds(content)
    print(f"Parsed {len(fields)} fields")

    if fields:
        schema = generate_json_schema(fields, Path(filepath).stem)
        schema_path = f"rpg_migration/java_api/{Path(filepath).stem}_schema.json"
        with open(schema_path, 'w') as f:
            json.dump(schema, f, indent=2)
        print(f"Schema: {schema_path}")

        pcml_path = f"rpg_migration/pcml/{Path(filepath).stem}.pcml"
        generate_pcml(fields, Path(filepath).stem.upper(), pcml_path)
```

### Step 3: Test the API Wrapper

```bash
python3 rpg_migration/map_rpg_ds.py rpg_src/CUSTINQ.rpgle
# Expected: JSON schema and PCML generated

# Validate PCML with JT400
java -cp jt400.jar com.ibm.as400.data.PcmlDocument pcml/CUSTINQ.pcml
# Expected: PCML parsed successfully

# Integration test (requires IBM i access)
curl -X POST http://localhost:8080/api/custinq \
  -H "Content-Type: application/json" \
  -d '{"customerNumber": "100234"}'
```

## CLAUDE.md for RPG Modernization

```markdown
# RPG/AS400 Modernization Rules

## Standards
- ILE RPG (RPG IV) free-format preferred
- PCML 6.0 for program call interface
- IBM i Access ODBC for database queries

## File Formats
- .rpgle (ILE RPG source)
- .dspf (display file / screen definition)
- .pf / .lf (physical/logical file DDS)
- .pcml (Program Call Markup Language)
- .json (API schema)

## Libraries
- JT400 20.x (IBM Toolbox for Java)
- Spring Boot 3.x (REST API framework)
- pyodbc + IBM i ODBC driver (Python alternative)

## Testing
- Call RPG program via PCML and compare output to green-screen
- Packed decimal (COMP-3) field round-trip test
- Date field format conversion (CYMD -> ISO 8601)

## Data Mapping
- RPG CHAR -> JSON string
- RPG PACKED/ZONED -> JSON number (preserve decimal places)
- RPG DATE (*ISO) -> JSON string "YYYY-MM-DD"
- RPG indicator (*IN01-*IN99) -> JSON boolean
```

## Common Pitfalls

- **Packed decimal precision loss:** RPG packed(7,2) stores 5 integer digits and 2 decimal digits. Converting to Java double loses precision. Claude Code maps packed fields to BigDecimal with explicit scale.
- **CCSID character encoding:** IBM i uses EBCDIC (CCSID 37 or 297). JT400 handles conversion automatically, but direct ODBC connections may not. Claude Code specifies CCSID in all connection strings.
- **RPG indicator flags:** RPG uses *IN01 through *IN99 as boolean flags shared between program and display file. Claude Code maps each indicator to a named boolean field instead of a magic number.

## Related

- [Claude Code for COBOL to Java](/claude-code-cobol-to-java-migration-2026/)
- [Claude Code for MUMPS Modernization](/claude-code-mumps-healthcare-modernization-2026/)
- [CLAUDE.md File Guide](/claude-md-file-complete-guide-what-it-does/)
