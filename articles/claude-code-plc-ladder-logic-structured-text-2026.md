---
layout: default
title: "Claude Code for PLC Ladder Logic to ST (2026)"
description: "Claude Code for PLC Ladder Logic to ST — practical guide with working examples, tested configurations, and tips for developer workflows."
permalink: /claude-code-plc-ladder-logic-structured-text-2026/
date: 2026-04-20
last_tested: "2026-04-21"
---

## Why Claude Code for PLC Migration

Industrial facilities run millions of lines of ladder logic on PLCs that were programmed in the 1990s. The original integrators are retired. The documentation is a binder in a closet. When these systems need upgrades, someone has to read relay-contact diagrams and translate them to IEC 61131-3 Structured Text for modern PLCs.

Claude Code can parse exported ladder logic (L5X from Allen-Bradley, XML from Siemens TIA Portal) and generate equivalent Structured Text. It preserves rung comments, handles timer/counter conversions, and flags rungs that use vendor-specific instructions needing manual review.

## The Workflow

### Step 1: Export Ladder Logic

```bash
# Allen-Bradley: Export .L5X from RSLogix 5000 / Studio 5000
# Siemens: Export XML from TIA Portal (Project > Export)
# CODESYS: Export .export from IDE

# Install parsing tools
pip install lxml defusedxml

# Project structure
mkdir -p plc_migration/{ladder_src,structured_text,tests,docs}
```

### Step 2: Parse and Convert Ladder to ST

```python
# plc_migration/convert_l5x.py
"""Convert Allen-Bradley L5X ladder logic to IEC 61131-3 Structured Text."""
import xml.etree.ElementTree as ET
from pathlib import Path
import sys

MAX_RUNG_INSTRUCTIONS = 50
MAX_PROGRAM_RUNGS = 10000


def parse_l5x(filepath: str) -> list:
    """Parse Allen-Bradley L5X export into rung structures."""
    assert Path(filepath).exists(), f"L5X file not found: {filepath}"
    tree = ET.parse(filepath)
    root = tree.getroot()

    programs = []
    for program in root.findall('.//Program'):
        prog_name = program.get('Name', 'UnnamedProgram')
        routines = []

        for routine in program.findall('.//Routine'):
            rout_name = routine.get('Name', 'MainRoutine')
            rungs = []

            for rung in routine.findall('.//Rung'):
                rung_text = rung.find('.//Text')
                comment_el = rung.find('.//Comment')
                rungs.append({
                    'text': rung_text.text if rung_text is not None else '',
                    'comment': comment_el.text if comment_el is not None else '',
                })

            assert len(rungs) <= MAX_PROGRAM_RUNGS, \
                f"Routine {rout_name} exceeds {MAX_PROGRAM_RUNGS} rungs"
            routines.append({'name': rout_name, 'rungs': rungs})

        programs.append({'name': prog_name, 'routines': routines})
    return programs


def ladder_to_st(rung_text: str) -> str:
    """Convert a single ladder rung to Structured Text."""
    assert rung_text is not None, "Null rung text"
    st_lines = []

    # XIC (Examine If Closed) -> contact check
    rung_text = rung_text.replace('XIC(', 'IF_CONTACT(')
    # XIO (Examine If Open) -> negated contact
    rung_text = rung_text.replace('XIO(', 'IF_NOT_CONTACT(')
    # OTE (Output Energize) -> assignment
    rung_text = rung_text.replace('OTE(', 'ASSIGN(')
    # TON (Timer On Delay)
    rung_text = rung_text.replace('TON(', 'TIMER_ON(')
    # CTU (Count Up)
    rung_text = rung_text.replace('CTU(', 'COUNT_UP(')

    # Pattern: IF_CONTACT(tag) ... ASSIGN(output)
    # becomes: IF tag THEN output := TRUE; END_IF;
    if 'IF_CONTACT' in rung_text and 'ASSIGN' in rung_text:
        contacts = extract_tags(rung_text, 'IF_CONTACT')
        negated = extract_tags(rung_text, 'IF_NOT_CONTACT')
        outputs = extract_tags(rung_text, 'ASSIGN')

        conditions = []
        for c in contacts:
            conditions.append(c)
        for n in negated:
            conditions.append(f'NOT {n}')

        if conditions and outputs:
            cond_str = ' AND '.join(conditions)
            for out in outputs:
                st_lines.append(f'IF {cond_str} THEN')
                st_lines.append(f'    {out} := TRUE;')
                st_lines.append('ELSE')
                st_lines.append(f'    {out} := FALSE;')
                st_lines.append('END_IF;')

    return '\n'.join(st_lines) if st_lines else f'(* MANUAL REVIEW: {rung_text} *)'


def extract_tags(text: str, prefix: str) -> list:
    """Extract tag names from converted instruction text."""
    tags = []
    start = 0
    while True:
        idx = text.find(f'{prefix}(', start)
        if idx == -1:
            break
        paren_start = idx + len(prefix) + 1
        paren_end = text.find(')', paren_start)
        if paren_end > paren_start:
            tags.append(text[paren_start:paren_end].strip())
        start = paren_end + 1
    return tags


def convert_program(l5x_path: str, output_dir: str) -> None:
    """Convert full L5X program to ST files."""
    programs = parse_l5x(l5x_path)
    out = Path(output_dir)
    out.mkdir(parents=True, exist_ok=True)

    for prog in programs:
        for routine in prog['routines']:
            st_file = out / f"{prog['name']}_{routine['name']}.st"
            with open(st_file, 'w') as f:
                f.write(f'PROGRAM {prog["name"]}_{routine["name"]}\n')
                f.write('VAR\n    (* Declare variables here *)\nEND_VAR\n\n')
                for i, rung in enumerate(routine['rungs']):
                    if rung['comment']:
                        f.write(f'(* Rung {i}: {rung["comment"]} *)\n')
                    st_code = ladder_to_st(rung['text'])
                    f.write(st_code + '\n\n')
                f.write('END_PROGRAM\n')
            print(f"Wrote: {st_file}")


if __name__ == '__main__':
    assert len(sys.argv) == 3, \
        "Usage: python convert_l5x.py <input.L5X> <output_dir>"
    convert_program(sys.argv[1], sys.argv[2])
```

### Step 3: Verify Conversion

```bash
# Syntax check with CODESYS or OpenPLC compiler
# OpenPLC Editor can import .st files for validation
python3 plc_migration/convert_l5x.py ladder_src/plant_a.L5X structured_text/
# Expected: one .st file per routine, MANUAL REVIEW comments on vendor-specific rungs

# Count conversion coverage
grep -c "MANUAL REVIEW" structured_text/*.st
# Target: <5% of rungs need manual review
```

## CLAUDE.md for PLC Migration

```markdown
# PLC Migration Rules

## Standards
- IEC 61131-3 (Structured Text)
- ISA-88 (Batch control) where applicable
- IEC 62443 (Industrial cybersecurity)

## File Formats
- .L5X (Allen-Bradley RSLogix/Studio 5000 export)
- .xml (Siemens TIA Portal export)
- .st (IEC 61131-3 Structured Text)
- .export (CODESYS)

## Libraries
- lxml 5.1+ (XML parsing)
- OpenPLC Editor (validation)
- CODESYS 3.5 SP19+ (target platform)

## Testing
- Every converted rung must produce identical I/O behavior
- Simulate with SoftPLC before deploying to hardware
- Timer/counter preset values must match original exactly

## Safety
- NEVER deploy to production PLC without hardware-in-the-loop test
- Preserve all safety-rated logic (SIL-rated rungs) without modification
- All MANUAL REVIEW tags must be resolved by a licensed controls engineer
```

## Common Pitfalls

- **Timer base mismatch:** Allen-Bradley TON uses milliseconds, Siemens S7 uses seconds. Claude Code flags timer instructions and converts the preset values to match the target platform's time base.
- **Retentive vs non-retentive outputs:** OTL/OTU (latch/unlatch) in AB have different semantics than SR/RS flip-flops in IEC 61131-3. Claude Code maps these correctly and adds comments explaining the behavioral difference.
- **Indirect addressing:** AB uses indirect tag references (e.g., `Tag[index]`) that have no direct ST equivalent. These get flagged with MANUAL REVIEW so a controls engineer can implement them as arrays or pointers.

## Related

- [Claude Code for Embedded Systems](/claude-skills-for-embedded-systems-iot-firmware/)
- [Claude Code for COBOL to Java Migration](/claude-code-cobol-to-java-migration-2026/)
- [Claude Code for Beginners](/claude-code-for-beginners-complete-getting-started-2026/)


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




**Get started →** Generate your project setup with our [Project Starter](/starter/).

## Related Guides

**Estimate tokens →** Calculate your usage with our [Token Estimator](/token-estimator/).

**Try it:** Paste your error into our [Error Diagnostic](/diagnose/) for an instant fix.

- [How to Test and Debug Multi Agent](/how-to-test-and-debug-multi-agent-workflows/)
- [Claude Code Debug Configuration](/claude-code-debug-configuration-workflow/)
- [How Do I Debug A Claude Skill](/how-do-i-debug-a-claude-skill-that-silently-fails/)
- [Claude Code Verbose Mode](/claude-code-verbose-mode-debug-output-2026/)


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
