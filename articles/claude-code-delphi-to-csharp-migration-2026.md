---
title: "Claude Code for Delphi to C# Migration (2026)"
description: "Delphi to C# conversion with Claude Code. Migrate Object Pascal forms, units, and database code to .NET 8."
permalink: /claude-code-delphi-to-csharp-migration-2026/
last_tested: "2026-04-21"
render_with_liquid: false
---
{% raw %}


## Why Claude Code for Delphi Migration

Millions of lines of Delphi code power business applications in logistics, healthcare, and manufacturing. Borland is gone, Embarcadero licenses are expensive, and the Delphi developer pool shrinks every year. Migrating to C#/.NET preserves the business logic while moving to an ecosystem with abundant tooling and developers.

Claude Code understands Object Pascal syntax: class declarations with published/private sections, TForm descendants, VCL event handlers, and the BDE/ADO database layer. It generates C# equivalents that map Delphi idioms to modern .NET patterns while preserving the form layout logic that took years to build.

## The Workflow

### Step 1: Setup

```bash
# .NET 8 SDK
dotnet --version  # 8.0+

# Project scaffolding
dotnet new winforms -n MigratedApp
dotnet new classlib -n MigratedApp.Core

# Python conversion tools
pip install antlr4-tools lark-parser

mkdir -p migration/{delphi_src,csharp_out,mapping,tests}
```

### Step 2: Delphi Unit Converter

```python
# migration/convert_delphi.py
"""Convert Delphi .pas units to C# classes."""
import re
from pathlib import Path
from dataclasses import dataclass

MAX_FILE_SIZE = 500_000  # characters
TYPE_MAP = {
    "integer": "int",
    "longint": "int",
    "int64": "long",
    "cardinal": "uint",
    "byte": "byte",
    "word": "ushort",
    "string": "string",
    "ansistring": "string",
    "widestring": "string",
    "boolean": "bool",
    "double": "double",
    "single": "float",
    "extended": "decimal",
    "currency": "decimal",
    "tdatetime": "DateTime",
    "tstrings": "List<string>",
    "tstringlist": "List<string>",
    "tlist": "List<object>",
    "tobjectlist": "List<object>",
    "variant": "object",
}


@dataclass
class DelphiMethod:
    name: str
    return_type: str
    params: list
    is_class_method: bool
    body: str
    visibility: str


def map_type(delphi_type: str) -> str:
    """Map Delphi type to C# equivalent."""
    assert delphi_type, "Empty type"
    lower = delphi_type.lower().strip()
    if lower in TYPE_MAP:
        return TYPE_MAP[lower]
    if lower.startswith("tarray<"):
        inner = lower[7:-1]
        return f"{map_type(inner)}[]"
    if lower.startswith("array of "):
        inner = lower[9:]
        return f"{map_type(inner)}[]"
    # Preserve custom type names with T prefix removed
    if lower.startswith("t") and len(lower) > 1:
        return delphi_type[1:]
    return delphi_type


def convert_params(param_str: str) -> str:
    """Convert Delphi parameter list to C#."""
    if not param_str.strip():
        return ""
    params = []
    for group in param_str.split(";"):
        group = group.strip()
        is_var = group.lower().startswith("var ")
        is_const = group.lower().startswith("const ")
        is_out = group.lower().startswith("out ")

        group = re.sub(r'^(var|const|out)\s+', '', group, flags=re.I)

        if ":" in group:
            names_part, type_part = group.split(":", 1)
            cs_type = map_type(type_part.strip())
            for name in names_part.split(","):
                name = name.strip()
                prefix = ""
                if is_var:
                    prefix = "ref "
                elif is_out:
                    prefix = "out "
                params.append(f"{prefix}{cs_type} {name}")

    return ", ".join(params)


def convert_method_body(body: str) -> str:
    """Convert Delphi statements to C# syntax."""
    assert body is not None

    result = body
    # Assignment operator
    result = result.replace(":=", "=")
    # String concatenation
    result = re.sub(r"'([^']*)'", r'"\1"', result)
    # Boolean literals
    result = re.sub(r'\bTrue\b', 'true', result)
    result = re.sub(r'\bFalse\b', 'false', result)
    # nil -> null
    result = re.sub(r'\bnil\b', 'null', result)
    # begin/end -> braces
    result = re.sub(r'\bbegin\b', '{', result, flags=re.I)
    result = re.sub(r'\bend\b', '}', result, flags=re.I)
    # if..then -> if..
    result = re.sub(r'\bthen\b', '', result, flags=re.I)
    # <> -> !=
    result = result.replace("<>", "!=")
    # Writeln -> Console.WriteLine
    result = re.sub(r'\bWriteln\b', 'Console.WriteLine', result, flags=re.I)

    return result


def convert_unit(filepath: str, namespace: str = "MigratedApp") -> str:
    """Convert a Delphi .pas unit to a C# class file."""
    assert Path(filepath).exists(), f"File not found: {filepath}"

    with open(filepath) as f:
        content = f.read()

    assert len(content) <= MAX_FILE_SIZE, \
        f"File too large: {len(content)} chars"

    # Extract unit name
    unit_match = re.search(r'unit\s+(\w+)\s*;', content, re.I)
    unit_name = unit_match.group(1) if unit_match else Path(filepath).stem

    # Extract class declarations
    class_matches = re.findall(
        r'(\w+)\s*=\s*class\s*(?:\((\w+)\))?\s*(.*?)end\s*;',
        content, re.DOTALL | re.I)

    cs_lines = [
        f"namespace {namespace}",
        "{",
        f"    using System;",
        f"    using System.Collections.Generic;",
        "",
    ]

    for cls_name, parent, body in class_matches:
        cs_parent = map_type(parent) if parent else "object"
        cs_class = cls_name
        if cs_class.startswith("T"):
            cs_class = cs_class[1:]

        cs_lines.append(f"    public class {cs_class} : {cs_parent}")
        cs_lines.append("    {")

        # Extract fields
        for field_match in re.finditer(
            r'(\w+)\s*:\s*(\w[\w<>]*)\s*;', body):
            fname = field_match.group(1)
            ftype = map_type(field_match.group(2))
            cs_lines.append(f"        public {ftype} {fname} {{ get; set; }}")

        # Extract methods
        for method_match in re.finditer(
            r'(procedure|function)\s+(\w+)\s*(?:\(([^)]*)\))?\s*'
            r'(?::\s*(\w+))?\s*;',
            body, re.I):
            kind = method_match.group(1).lower()
            mname = method_match.group(2)
            params = method_match.group(3) or ""
            ret_type = method_match.group(4)

            cs_ret = map_type(ret_type) if ret_type else "void"
            cs_params = convert_params(params)
            cs_lines.append(f"        public {cs_ret} {mname}({cs_params})")
            cs_lines.append("        {")
            cs_lines.append("            throw new NotImplementedException();")
            cs_lines.append("        }")
            cs_lines.append("")

        cs_lines.append("    }")
        cs_lines.append("")

    cs_lines.append("}")

    output_path = f"csharp_out/{unit_name}.cs"
    with open(output_path, 'w') as f:
        f.write("\n".join(cs_lines))

    print(f"Converted: {filepath} -> {output_path}")
    return output_path


if __name__ == "__main__":
    import sys
    assert len(sys.argv) >= 2, \
        "Usage: python convert_delphi.py <unit.pas>"
    convert_unit(sys.argv[1])
```

### Step 3: Compile and Test

```bash
python3 migration/convert_delphi.py delphi_src/CustomerManager.pas
# Expected: csharp_out/CustomerManager.cs generated

dotnet build MigratedApp.Core/
# Expected: zero compilation errors

dotnet test MigratedApp.Tests/
# Run unit tests comparing Delphi output vs C# output
```

## CLAUDE.md for Delphi Migration

```markdown
# Delphi to C# Migration Rules

## Standards
- Source: Delphi 7 / 2007 / XE+ Object Pascal
- Target: C# 12 / .NET 8
- WinForms for VCL form migration

## File Formats
- .pas (Delphi unit source)
- .dfm (Delphi form layout)
- .dpr (Delphi project file)
- .cs (C# output)
- .resx (WinForms resource)

## Libraries
- .NET 8 SDK
- System.Data.SqlClient (replaces BDE/ADO)
- Dapper 2.x (lightweight ORM, replaces TDataSet)

## Migration Rules
- TForm -> Form (WinForms) or Window (WPF)
- TDataSet -> IDbConnection + Dapper
- TStringList -> List<string>
- Preserve Delphi method names in C#
- Convert first, refactor second — do not change logic during migration
```

## Common Pitfalls

- **1-based string indexing:** Delphi strings are 1-indexed, C# strings are 0-indexed. Claude Code adjusts all string index operations by -1 during conversion.
- **DFM form layout loss:** Binary .dfm files contain pixel-perfect form layouts. Claude Code converts DFM to text format first, then maps component properties to WinForms designer code.
- **With statement ambiguity:** Delphi's `with` statement implicitly scopes field access. Claude Code expands all `with` blocks to explicit qualified references before conversion.

## Related

- [Claude Code for COBOL to Java](/claude-code-cobol-to-java-migration-2026/)
- [Claude Code for VB6 to .NET](/claude-code-vb6-to-dotnet-migration-2026/)
- [CLAUDE.md File Guide](/claude-md-file-complete-guide-what-it-does/)
{% endraw %}
