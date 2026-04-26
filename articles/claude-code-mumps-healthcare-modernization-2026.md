---
layout: default
title: "Claude Code for MUMPS Healthcare (2026)"
description: "Claude Code for MUMPS Healthcare — practical guide with working examples, tested configurations, and tips for developer workflows."
permalink: /claude-code-mumps-healthcare-modernization-2026/
date: 2026-04-20
last_tested: "2026-04-21"
---

## Why Claude Code for MUMPS Modernization

MUMPS (Massachusetts General Hospital Utility Multi-Programming System) — also called M — runs the VA's VistA system, Epic's backend, and hundreds of hospital information systems. The language is intentionally terse: single-character commands, global arrays as databases, naked references, and implicit operations that make code nearly unreadable to anyone who did not write it.

Claude Code can parse MUMPS routines, expand abbreviated commands (S->SET, W->WRITE, I->IF, D->DO), trace global references through the hierarchical database, and generate documented API wrappers in Python or Java that expose the business logic trapped in 40-year-old M code.

## The Workflow

### Step 1: Setup

```bash
# Install GT.M / YottaDB (open-source M runtime)
# Ubuntu/Debian
sudo apt install yottadb

# Or via Docker
docker pull yottadb/yottadb

# Python extraction tools
pip install ply antlr4-tools pyyaml

mkdir -p mumps_migration/{routines,extracted,api,tests}
```

### Step 2: MUMPS Routine Parser and Extractor

```python
# mumps_migration/parse_mumps.py
"""Parse MUMPS/M routines and extract structured business logic."""
import re
from pathlib import Path
from dataclasses import dataclass, field

MAX_ROUTINE_SIZE = 100_000  # characters
MAX_LINES = 5000

# MUMPS command expansion table
COMMAND_EXPAND = {
    "S": "SET", "W": "WRITE", "R": "READ", "I": "IF",
    "E": "ELSE", "D": "DO", "Q": "QUIT", "G": "GOTO",
    "F": "FOR", "N": "NEW", "K": "KILL", "H": "HALT",
    "O": "OPEN", "C": "CLOSE", "U": "USE", "L": "LOCK",
    "X": "XECUTE", "V": "VIEW", "M": "MERGE",
    "ZW": "ZWRITE", "ZL": "ZLOAD",
}


@dataclass
class MumpsEntry:
    label: str
    parameters: list
    lines: list
    globals_read: list = field(default_factory=list)
    globals_written: list = field(default_factory=list)
    calls: list = field(default_factory=list)


@dataclass
class MumpsRoutine:
    name: str
    entries: list
    globals_used: set = field(default_factory=set)
    total_lines: int = 0


def expand_commands(line: str) -> str:
    """Expand abbreviated MUMPS commands to full form."""
    # Match command at start of line or after space/tab
    for abbrev, full in COMMAND_EXPAND.items():
        # Only match standalone abbreviations followed by space or colon
        pattern = rf'(?<![A-Za-z]){re.escape(abbrev)}(?=[\s:])'
        line = re.sub(pattern, full, line)
    return line


def extract_globals(line: str) -> tuple:
    """Extract global references (^NAME) from a MUMPS line."""
    # ^GLOBAL(subscripts) pattern
    reads = set()
    writes = set()

    # SET ^GLOBAL = value (write)
    set_globals = re.findall(r'SET\s+\^(\w+)', line, re.I)
    writes.update(set_globals)

    # All ^GLOBAL references (reads)
    all_globals = re.findall(r'\^(\w+)', line)
    for g in all_globals:
        if g not in writes:
            reads.add(g)

    return reads, writes


def extract_calls(line: str) -> list:
    """Extract DO (subroutine call) targets."""
    calls = []
    # DO LABEL^ROUTINE or DO LABEL
    do_matches = re.findall(r'DO\s+(\w+)(?:\^(\w+))?', line, re.I)
    for label, routine in do_matches:
        target = f"{label}^{routine}" if routine else label
        calls.append(target)
    return calls


def parse_routine(filepath: str) -> MumpsRoutine:
    """Parse a MUMPS routine file into structured representation."""
    assert Path(filepath).exists(), f"Routine not found: {filepath}"

    with open(filepath) as f:
        content = f.read()

    assert len(content) <= MAX_ROUTINE_SIZE, \
        f"Routine too large: {len(content)} chars"

    lines = content.split("\n")
    assert len(lines) <= MAX_LINES, f"Too many lines: {len(lines)}"

    routine_name = Path(filepath).stem
    entries = []
    current_entry = None
    all_globals = set()

    for line_num, raw_line in enumerate(lines):
        if not raw_line.strip():
            continue

        # Labels start at column 1 (no leading space/tab)
        label_match = re.match(r'^(\w+)(?:\(([^)]*)\))?\s*(.*)', raw_line)
        if label_match and not raw_line[0].isspace():
            if current_entry:
                entries.append(current_entry)

            label = label_match.group(1)
            params_str = label_match.group(2) or ""
            params = [p.strip() for p in params_str.split(",") if p.strip()]
            rest = label_match.group(3)

            current_entry = MumpsEntry(
                label=label,
                parameters=params,
                lines=[],
            )

            if rest.strip():
                expanded = expand_commands(rest)
                current_entry.lines.append(expanded)
                reads, writes = extract_globals(expanded)
                current_entry.globals_read.extend(reads)
                current_entry.globals_written.extend(writes)
                all_globals.update(reads | writes)
                current_entry.calls.extend(extract_calls(expanded))
        elif current_entry:
            expanded = expand_commands(raw_line)
            current_entry.lines.append(expanded)
            reads, writes = extract_globals(expanded)
            current_entry.globals_read.extend(reads)
            current_entry.globals_written.extend(writes)
            all_globals.update(reads | writes)
            current_entry.calls.extend(extract_calls(expanded))

    if current_entry:
        entries.append(current_entry)

    return MumpsRoutine(
        name=routine_name,
        entries=entries,
        globals_used=all_globals,
        total_lines=len(lines),
    )


def generate_api_wrapper(routine: MumpsRoutine,
                         output_dir: str) -> str:
    """Generate Python API wrapper from parsed MUMPS routine."""
    assert len(routine.entries) > 0, "No entries to wrap"

    lines = [
        f'"""API wrapper for MUMPS routine: {routine.name}',
        f'Globals accessed: {", ".join(sorted(routine.globals_used))}',
        f'"""',
        f'import subprocess',
        f'from typing import Optional',
        f'',
    ]

    for entry in routine.entries:
        params = ", ".join(entry.parameters) if entry.parameters else ""
        doc_globals = ", ".join(set(entry.globals_read + entry.globals_written))

        lines.append(f'def {entry.label.lower()}({params}) -> str:')
        lines.append(f'    """Call {routine.name}:{entry.label}.')
        lines.append(f'    Globals: {doc_globals or "none"}')
        lines.append(f'    Original lines: {len(entry.lines)}')
        lines.append(f'    """')
        if entry.parameters:
            for p in entry.parameters:
                lines.append(f'    assert {p} is not None, "{p} required"')
        lines.append(f'    cmd = "DO {entry.label}^{routine.name}"')
        lines.append(f'    result = subprocess.run(')
        lines.append(f'        ["yottadb", "-run", cmd],')
        lines.append(f'        capture_output=True, text=True)')
        lines.append(f'    assert result.returncode == 0, result.stderr')
        lines.append(f'    return result.stdout')
        lines.append(f'')

    output_path = f"{output_dir}/{routine.name.lower()}_api.py"
    Path(output_dir).mkdir(parents=True, exist_ok=True)
    with open(output_path, 'w') as f:
        f.write("\n".join(lines))

    print(f"Generated: {output_path}")
    print(f"  Entries: {len(routine.entries)}")
    print(f"  Globals: {len(routine.globals_used)}")
    return output_path


if __name__ == "__main__":
    import sys
    assert len(sys.argv) >= 2, \
        "Usage: python parse_mumps.py <routine.m>"
    routine = parse_routine(sys.argv[1])
    print(f"Routine: {routine.name}")
    print(f"Entries: {len(routine.entries)}")
    print(f"Globals: {routine.globals_used}")
    for e in routine.entries:
        print(f"  {e.label}({', '.join(e.parameters)}): "
              f"{len(e.lines)} lines, "
              f"reads {set(e.globals_read)}, writes {set(e.globals_written)}")
    generate_api_wrapper(routine, "api")
```

### Step 3: Validate

```bash
python3 mumps_migration/parse_mumps.py routines/DGPT.m
# Expected: entry point listing with global dependencies

# Cross-reference with VistA FileMan data dictionary
# Verify global names match expected FileMan files
```

## CLAUDE.md for MUMPS Modernization

```markdown
# MUMPS/M Modernization Rules

## Standards
- ANSI/MDC X11.1-1995 (M Language standard)
- VistA FileMan data dictionary conventions
- HL7 v2.x message format (healthcare interop)

## File Formats
- .m / .ro (M routine source)
- .zwr (global export, ZWRITE format)
- .gld (YottaDB global directory)

## Libraries
- YottaDB r1.38+ (open-source M runtime)
- GT.M V7.0+ (alternative runtime)
- ply / lark-parser (Python MUMPS parser)

## Testing
- Global read/write tracing for each entry point
- Compare M routine output against Python wrapper output
- HL7 message generation parity tests

## Safety
- NEVER modify production M globals without backup
- Preserve all naked reference semantics during extraction
- Log all global access patterns before modernization
- PHI (Protected Health Information) in globals — handle per HIPAA
```

## Common Pitfalls

- **Naked references:** In MUMPS, `^PATIENT(123,"NAME")` followed by `SET ^("DOB")=...` uses the LAST global reference implicitly. Claude Code tracks naked reference state through the routine to resolve all implicit global paths.
- **Argumentless IF/ELSE:** MUMPS `IF` without an argument tests the special variable $TEST. Claude Code traces $TEST state through conditionals to generate explicit boolean expressions.
- **XECUTE indirection:** `XECUTE` runs a string as code at runtime, making static analysis impossible for those lines. Claude Code flags XECUTE statements and extracts the string patterns from common usage to generate equivalent static code.

## Related

**Try it:** Estimate your monthly spend with our [Cost Calculator](/calculator/).

- [Claude Code for COBOL to Java](/claude-code-cobol-to-java-migration-2026/)
- [Claude Code for HIPAA Development](/claude-code-hipaa-compliant-development-workflow-guide/)
- [CLAUDE.md File Guide](/claude-md-file-complete-guide-what-it-does/)
- [Claude Code for PowerBuilder Modernization (2026)](/claude-code-powerbuilder-modernization-2026/)
- [Claude Code for SCADA Modernization (2026)](/claude-code-scada-modernization-2026/)
- [Claude Code for RPG/AS400 to Modern API (2026)](/claude-code-rpg-as400-modernization-2026/)


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
