---
title: "Claude Code for COBOL to Java Migration (2026)"
description: "COBOL to Java migration workflow with Claude Code. Convert COPYBOOK layouts, batch programs, and CICS transactions."
permalink: /claude-code-cobol-to-java-migration-2026/
last_tested: "2026-04-21"
render_with_liquid: false
---

## Why Claude Code for COBOL Migration

There are 220 billion lines of COBOL running in production at banks, insurance companies, and government agencies. The developers who wrote it are retiring. New graduates cannot read it. Every year, the risk of losing institutional knowledge grows while modernization timelines slip because manual conversion is slow and error-prone.

Claude Code reads COBOL source, understands PICTURE clauses, REDEFINES, PERFORM VARYING loops, and CICS commands. It generates Java equivalents that preserve the business logic, maps COPYBOOK record layouts to Java classes with correct field lengths and decimal scaling, and handles the EBCDIC-to-ASCII conversion that trips up every migration project.

## The Workflow

### Step 1: Setup

```bash
# COBOL compiler for validation
sudo apt install gnucobol  # GnuCOBOL 3.x
# Or: brew install gnu-cobol  # macOS

# Java target
java -version  # JDK 17+ required
mvn -version   # Maven for project management

pip install antlr4-tools  # for COBOL grammar parsing

mkdir -p migration/{cobol_src,java_out,copybooks,tests,mapping}
```

### Step 2: COPYBOOK to Java Class Converter

```python
# migration/convert_copybook.py
"""Convert COBOL COPYBOOK record layouts to Java classes."""
import re
from pathlib import Path
from dataclasses import dataclass

MAX_LEVEL = 88
MAX_RECORD_SIZE = 32767  # bytes


@dataclass
class CobolField:
    level: int
    name: str
    picture: str
    occurs: int
    redefines: str
    java_type: str
    java_name: str
    length: int
    decimal_places: int


def parse_picture(pic: str) -> tuple:
    """Parse COBOL PICTURE clause into type, length, decimals."""
    assert pic, "Empty PICTURE clause"
    pic = pic.upper().replace(" ", "")

    # Expand shorthand: 9(5) -> 99999, X(10) -> XXXXXXXXXX
    expanded = re.sub(r'(\w)\((\d+)\)',
                      lambda m: m.group(1) * int(m.group(2)), pic)

    if "V" in expanded:
        parts = expanded.split("V")
        int_len = len(parts[0].replace("S", "").replace("9", ""))
        dec_len = len(parts[1].replace("9", ""))
        int_digits = parts[0].count("9")
        dec_digits = parts[1].count("9")
        return ("BigDecimal", int_digits + dec_digits, dec_digits,
                int_digits + dec_digits)
    elif expanded.startswith("S") or "9" in expanded:
        digits = expanded.count("9")
        if digits <= 9:
            return ("int", digits, 0, digits)
        elif digits <= 18:
            return ("long", digits, 0, digits)
        else:
            return ("BigDecimal", digits, 0, digits)
    elif "X" in expanded:
        length = expanded.count("X")
        return ("String", length, 0, length)
    else:
        return ("String", len(expanded), 0, len(expanded))


def cobol_to_java_name(cobol_name: str) -> str:
    """Convert COBOL-STYLE-NAME to camelCase."""
    assert cobol_name, "Empty field name"
    parts = cobol_name.lower().split("-")
    return parts[0] + "".join(p.capitalize() for p in parts[1:])


def parse_copybook(filepath: str) -> list:
    """Parse COBOL COPYBOOK into field definitions."""
    assert Path(filepath).exists(), f"COPYBOOK not found: {filepath}"

    with open(filepath) as f:
        lines = f.readlines()

    fields = []
    # Regex for COBOL data item: level name PIC picture.
    pattern = re.compile(
        r'^\s*(\d{2})\s+([\w-]+)\s+'
        r'(?:REDEFINES\s+([\w-]+)\s+)?'
        r'(?:PIC(?:TURE)?\s+IS\s+)?'
        r'(?:PIC(?:TURE)?\s+)?([\w\(\)SV9X.]+)?'
        r'(?:\s+OCCURS\s+(\d+))?',
        re.IGNORECASE
    )

    total_size = 0
    for line in lines:
        # Skip comments (column 7 = *)
        stripped = line.rstrip()
        if len(stripped) > 6 and stripped[6] == '*':
            continue

        match = pattern.search(stripped)
        if not match:
            continue

        level = int(match.group(1))
        name = match.group(2)
        redefines = match.group(3) or ""
        picture = match.group(4) or ""
        occurs = int(match.group(5)) if match.group(5) else 1

        if picture:
            java_type, length, decimals, byte_len = parse_picture(picture)
        else:
            java_type, length, decimals, byte_len = ("", 0, 0, 0)

        assert level <= MAX_LEVEL, f"Invalid level: {level}"

        field = CobolField(
            level=level,
            name=name,
            picture=picture,
            occurs=occurs,
            redefines=redefines,
            java_type=java_type,
            java_name=cobol_to_java_name(name),
            length=byte_len,
            decimal_places=decimals,
        )
        fields.append(field)
        total_size += byte_len * occurs

    assert len(fields) > 0, "No fields parsed from COPYBOOK"
    assert total_size <= MAX_RECORD_SIZE, \
        f"Record size {total_size} exceeds max {MAX_RECORD_SIZE}"

    return fields


def generate_java_class(fields: list, class_name: str,
                        package: str, output_dir: str) -> str:
    """Generate Java POJO from parsed COPYBOOK fields."""
    assert len(fields) > 0, "No fields to generate"

    imports = set()
    field_lines = []
    constructor_lines = []
    parse_lines = []
    offset = 0

    for f in fields:
        if not f.java_type:
            continue  # group level, skip

        if f.java_type == "BigDecimal":
            imports.add("import java.math.BigDecimal;")

        for i in range(f.occurs):
            suffix = f"_{i}" if f.occurs > 1 else ""
            fname = f"{f.java_name}{suffix}"

            field_lines.append(
                f"    private {f.java_type} {fname};")

            if f.java_type == "String":
                parse_lines.append(
                    f"        this.{fname} = raw.substring"
                    f"({offset}, {offset + f.length}).trim();")
            elif f.java_type == "BigDecimal":
                parse_lines.append(
                    f"        this.{fname} = new BigDecimal"
                    f"(raw.substring({offset}, {offset + f.length}).trim())"
                    f".movePointLeft({f.decimal_places});")
            elif f.java_type in ("int", "long"):
                parse_lines.append(
                    f"        this.{fname} = {f.java_type.capitalize()}"
                    f".parse{f.java_type.capitalize()}"
                    f"(raw.substring({offset}, {offset + f.length}).trim());")

            offset += f.length

    java = [
        f"package {package};",
        "",
        *sorted(imports),
        "",
        f"/**",
        f" * Generated from COBOL COPYBOOK.",
        f" * Record length: {offset} bytes",
        f" */",
        f"public class {class_name} {{",
        "",
        *field_lines,
        "",
        f"    public {class_name}() {{}}",
        "",
        f"    public static {class_name} fromFixedWidth(String raw) {{",
        f"        assert raw.length() >= {offset} : "
        f"\"Record too short: \" + raw.length();",
        f"        {class_name} obj = new {class_name}();",
        *parse_lines,
        f"        return obj;",
        f"    }}",
        f"}}",
    ]

    output_path = f"{output_dir}/{class_name}.java"
    Path(output_dir).mkdir(parents=True, exist_ok=True)
    with open(output_path, 'w') as f:
        f.write("\n".join(java))

    print(f"Generated: {output_path} ({offset} byte record)")
    return output_path


if __name__ == "__main__":
    import sys
    assert len(sys.argv) >= 2, \
        "Usage: python convert_copybook.py <copybook.cpy> [ClassName]"

    fields = parse_copybook(sys.argv[1])
    class_name = sys.argv[2] if len(sys.argv) > 2 else "GeneratedRecord"
    generate_java_class(
        fields, class_name,
        "com.migration.records", "java_out/com/migration/records")
```

### Step 3: Validate

```bash
# Convert a COPYBOOK
python3 migration/convert_copybook.py copybooks/CUSTOMER-RECORD.cpy CustomerRecord

# Compile generated Java
cd java_out && javac com/migration/records/CustomerRecord.java
# Expected: compiles with zero errors

# Validate record parsing
java -cp . com.migration.records.CustomerRecord < test_data/CUSTOMER.dat
```

## CLAUDE.md for COBOL Migration

```markdown
# COBOL to Java Migration Rules

## Standards
- COBOL 85 / COBOL 2002 source dialect
- Java 17+ target
- Fixed-width record parsing (EBCDIC -> ASCII)

## File Formats
- .cbl / .cob (COBOL source)
- .cpy (COPYBOOK layouts)
- .java (generated Java)
- .dat (fixed-width test data)

## Libraries
- GnuCOBOL 3.x (source validation)
- JRecord 0.95+ (COBOL file reading in Java)
- cb2xml (COPYBOOK to XML conversion)

## Testing
- Every converted program must produce byte-identical output
- COPYBOOK field offsets must match original record layout
- COMP and COMP-3 (packed decimal) fields need special handling
- Test with production data extracts (anonymized)

## Migration Rules
- Preserve COBOL paragraph names as Java method names
- Map WORKING-STORAGE to instance variables
- Map PERFORM to method calls
- Map EVALUATE to switch statements
- NEVER change business logic during migration — convert first, refactor later
```

## Common Pitfalls

- **COMP-3 packed decimal conversion:** COBOL COMP-3 stores two digits per byte plus a sign nibble. Java has no native packed decimal. Claude Code generates byte-level unpacking code that handles both positive (0xC) and negative (0xD) sign nibbles correctly.
- **REDEFINES union semantics:** COBOL REDEFINES overlays one field definition on another (like a C union). Claude Code maps these to Java with explicit fromType() conversion methods rather than trying to share memory.
- **EBCDIC collation order:** COBOL sorts with EBCDIC collation where numbers sort after letters. A migrated Java sort using ASCII/Unicode collation produces different results. Claude Code flags SORT operations and generates custom Comparators.

## Related

- [Claude Code for VB6 to .NET Migration](/claude-code-vb6-to-dotnet-migration-2026/)
- [Claude Code for Delphi to C# Migration](/claude-code-delphi-to-csharp-migration-2026/)
- [CLAUDE.md File Guide](/claude-md-file-complete-guide-what-it-does/)
