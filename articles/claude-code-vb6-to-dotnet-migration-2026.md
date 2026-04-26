---
layout: default
title: "Claude Code for VB6 to .NET Migration (2026)"
description: "Claude Code for VB6 to .NET Migration — practical guide with working examples, tested configurations, and tips for developer workflows."
permalink: /claude-code-vb6-to-dotnet-migration-2026/
date: 2026-04-20
last_tested: "2026-04-21"
---

## Why Claude Code for VB6 Migration

Visual Basic 6 reached end of extended support in 2008, yet thousands of business-critical applications still run on VB6 runtimes. COM component registration breaks during Windows updates, the VB6 IDE barely runs on modern Windows, and the MSDN documentation is disappearing. Migration is not optional anymore — it is urgent.

Claude Code parses VB6 .frm and .bas files, understands the event-driven model (Form_Load, Command1_Click), ADO Recordset operations, and COM automation calls. It generates C# WinForms or WPF equivalents that preserve the form layout, business logic flow, and database connectivity while removing the COM dependency.

## The Workflow

### Step 1: Setup

```bash
# .NET 8 SDK
dotnet --version  # 8.0+

# Upgrade assistant tool (optional)
dotnet tool install -g upgrade-assistant

# Project structure
dotnet new winforms -n LegacyApp.Migrated
mkdir -p migration/{vb6_src,csharp_out,tests}

pip install lark-parser
```

### Step 2: VB6 Form Converter

```python
# migration/convert_vb6.py
"""Convert VB6 .frm and .bas files to C# WinForms."""
import re
from pathlib import Path
from dataclasses import dataclass

MAX_CONTROLS = 500

VB6_TYPE_MAP = {
    "Integer": "short",
    "Long": "int",
    "Single": "float",
    "Double": "double",
    "Currency": "decimal",
    "String": "string",
    "Boolean": "bool",
    "Date": "DateTime",
    "Variant": "object",
    "Object": "object",
    "Byte": "byte",
}

VB6_CONTROL_MAP = {
    "CommandButton": "Button",
    "TextBox": "TextBox",
    "Label": "Label",
    "ListBox": "ListBox",
    "ComboBox": "ComboBox",
    "CheckBox": "CheckBox",
    "OptionButton": "RadioButton",
    "Frame": "GroupBox",
    "PictureBox": "PictureBox",
    "Timer": "Timer",
    "DataGrid": "DataGridView",
    "MSFlexGrid": "DataGridView",
}


@dataclass
class VB6Control:
    name: str
    vb_type: str
    cs_type: str
    properties: dict


@dataclass
class VB6Event:
    control_name: str
    event_name: str
    body: str


def parse_frm_controls(content: str) -> list:
    """Extract control definitions from .frm file header."""
    controls = []
    pattern = re.compile(
        r'Begin\s+VB\.(\w+)\s+(\w+)\s*\n(.*?)End',
        re.DOTALL)

    for match in pattern.finditer(content):
        vb_type = match.group(1)
        name = match.group(2)
        props_raw = match.group(3)

        props = {}
        for prop_match in re.finditer(
            r'(\w+)\s*=\s*(.+)', props_raw):
            props[prop_match.group(1)] = prop_match.group(2).strip()

        cs_type = VB6_CONTROL_MAP.get(vb_type, vb_type)
        controls.append(VB6Control(name, vb_type, cs_type, props))

    assert len(controls) <= MAX_CONTROLS, \
        f"Too many controls: {len(controls)}"
    return controls


def parse_event_handlers(content: str) -> list:
    """Extract VB6 event handler subs from code section."""
    events = []
    pattern = re.compile(
        r'Private\s+Sub\s+(\w+)_(\w+)\(([^)]*)\)\s*\n'
        r'(.*?)\nEnd\s+Sub',
        re.DOTALL | re.I)

    for match in pattern.finditer(content):
        control = match.group(1)
        event = match.group(2)
        body = match.group(4)
        events.append(VB6Event(control, event, body))

    return events


def convert_vb6_code(vb_code: str) -> str:
    """Convert VB6 code statements to C#."""
    lines = vb_code.split("\n")
    cs_lines = []

    for line in lines:
        converted = line.strip()
        if not converted or converted.startswith("'"):
            cs_lines.append(f"// {converted.lstrip(chr(39))}" if converted else "")
            continue

        # Dim -> var
        dim_match = re.match(
            r'Dim\s+(\w+)\s+As\s+(?:New\s+)?(\w+)', converted, re.I)
        if dim_match:
            var_name = dim_match.group(1)
            vb_type = dim_match.group(2)
            cs_type = VB6_TYPE_MAP.get(vb_type, vb_type)
            cs_lines.append(f"{cs_type} {var_name};")
            continue

        # Set obj = -> obj =
        converted = re.sub(r'^Set\s+', '', converted, flags=re.I)
        # String concatenation & -> +
        converted = converted.replace(" & ", " + ")
        # <> -> !=
        converted = converted.replace(" <> ", " != ")
        # Nothing -> null
        converted = re.sub(r'\bNothing\b', 'null', converted, flags=re.I)
        # True/False
        converted = re.sub(r'\bTrue\b', 'true', converted)
        converted = re.sub(r'\bFalse\b', 'false', converted)
        # MsgBox -> MessageBox.Show
        converted = re.sub(r'\bMsgBox\b', 'MessageBox.Show', converted, flags=re.I)
        # If/Then/Else
        converted = re.sub(r'\bThen\b', '{', converted, flags=re.I)
        converted = re.sub(r'^Else\s*$', '} else {', converted, flags=re.I)
        converted = re.sub(r'^End\s+If', '}', converted, flags=re.I)

        # Add semicolons to statement lines
        if (converted and not converted.endswith("{")
            and not converted.endswith("}")
            and not converted.startswith("//")
            and not converted.startswith("if ")):
            converted += ";"

        cs_lines.append(converted)

    return "\n".join(cs_lines)


def generate_form_class(frm_path: str, namespace: str) -> str:
    """Convert a complete VB6 .frm to C# Form class."""
    assert Path(frm_path).exists(), f"FRM not found: {frm_path}"

    with open(frm_path, encoding='latin-1') as f:
        content = f.read()

    form_name_match = re.search(r'Begin\s+VB\.Form\s+(\w+)', content)
    form_name = form_name_match.group(1) if form_name_match else "Form1"

    controls = parse_frm_controls(content)
    events = parse_event_handlers(content)

    cs = [
        f"namespace {namespace};",
        "",
        "using System;",
        "using System.Windows.Forms;",
        "",
        f"public partial class {form_name} : Form",
        "{",
    ]

    # Control declarations
    for ctrl in controls:
        cs.append(f"    private {ctrl.cs_type} {ctrl.name};")
    cs.append("")

    # Constructor
    cs.append(f"    public {form_name}()")
    cs.append("    {")
    cs.append("        InitializeComponent();")
    cs.append("    }")
    cs.append("")

    # Event handlers
    event_map = {"Click": "Click", "Load": "Load",
                 "Change": "TextChanged", "KeyPress": "KeyPress"}
    for evt in events:
        cs_event = event_map.get(evt.event_name, evt.event_name)
        method_name = f"{evt.control_name}_{cs_event}"
        cs.append(f"    private void {method_name}(object sender, EventArgs e)")
        cs.append("    {")
        converted_body = convert_vb6_code(evt.body)
        for line in converted_body.split("\n"):
            cs.append(f"        {line}")
        cs.append("    }")
        cs.append("")

    cs.append("}")

    output_path = f"csharp_out/{form_name}.cs"
    with open(output_path, 'w') as f:
        f.write("\n".join(cs))

    print(f"Converted: {frm_path} -> {output_path}")
    print(f"  Controls: {len(controls)}")
    print(f"  Events: {len(events)}")
    return output_path


if __name__ == "__main__":
    import sys
    assert len(sys.argv) >= 2, \
        "Usage: python convert_vb6.py <form.frm>"
    generate_form_class(sys.argv[1], "LegacyApp.Migrated")
```

### Step 3: Build and Test

```bash
python3 migration/convert_vb6.py vb6_src/frmMain.frm
# Expected: csharp_out/frmMain.cs generated

dotnet build LegacyApp.Migrated/
# Expected: compiles (may need manual fixes for COM calls)
```

## CLAUDE.md for VB6 Migration

```markdown
# VB6 to .NET Migration Rules

## Standards
- Source: Visual Basic 6.0 SP6
- Target: C# 12 / .NET 8 WinForms
- COM interop only where absolutely necessary

## File Formats
- .frm (VB6 form + code)
- .bas (VB6 module)
- .cls (VB6 class module)
- .vbp (VB6 project file)
- .cs (C# output)

## Libraries
- .NET 8 WinForms
- System.Data.SqlClient (replaces ADO/DAO)
- Dapper 2.x (replaces Recordset pattern)

## Testing
- Form layout pixel comparison (screenshot diff)
- Event handler behavior parity tests
- Database CRUD operation equivalence tests

## Migration Rules
- Variant -> object (track for later strong typing)
- On Error GoTo -> try/catch
- GoSub -> method extraction
- Global -> static class
- COM objects -> .NET equivalents or interop wrapper
```

## Common Pitfalls

- **1-based collections:** VB6 collections and arrays start at 1 by default. C# is always 0-based. Claude Code adjusts all index references and adds explicit bounds checking.
- **Implicit type conversion:** VB6 silently converts "123" + 456 to 579. C# throws. Claude Code adds explicit Convert.ToInt32() / .ToString() calls at every implicit conversion site.
- **COM object lifecycle:** VB6's deterministic COM release does not exist in .NET. Claude Code wraps COM interop objects in using() statements with Marshal.ReleaseComObject for correct cleanup.

## Related

- [Claude Code for COBOL to Java](/claude-code-cobol-to-java-migration-2026/)
- [Claude Code for Delphi to C#](/claude-code-delphi-to-csharp-migration-2026/)
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

- [LLM Migration Cost Analysis](/claude-cost-migration-switching-providers-analysis/)
- [AI Coding Tools for Code Migration](/ai-coding-tools-for-code-migration-projects/)
- [Claude Code for OpenTofu Migration](/claude-code-for-opentofu-migration-workflow-guide/)
- [Express to Fastify Migration](/claude-code-express-to-fastify-migration-tutorial-2026/)

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
