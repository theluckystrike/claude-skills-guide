---
title: "Claude Code for Mainframe REXX (2026)"
permalink: /claude-code-mainframe-rexx-modernization-2026/
description: "Modernize mainframe REXX scripts with Claude Code. Convert ISPF panels, EXECIO file I/O, and TSO commands to Python automation."
last_tested: "2026-04-22"
domain: "mainframe modernization"
---

## Why Claude Code for Mainframe REXX

REXX (Restructured Extended Executor) is the scripting glue that holds mainframe operations together. System programmers use REXX EXECs for JCL generation, ISPF panel automation, VSAM file manipulation, DB2 queries via EXECSQL, and TSO/ISPF command orchestration. These scripts handle batch scheduling, dataset management, and operator console automation across z/OS, z/VM, and z/VSE environments. As mainframe operations teams shrink, organizations need to either modernize these scripts or replicate their functionality off-platform.

Claude Code understands REXX's unique features: stem variables (arrays), the PARSE instruction, EXECIO for file I/O, ADDRESS TSO/ISPF/MVS command routing, and the OUTTRAP function. It can convert REXX EXECs to Python scripts that interact with mainframes via z/OSMF REST APIs or replicate the logic entirely on distributed systems.

## The Workflow

### Step 1: Inventory REXX Assets

```bash
# If files are downloaded from mainframe
mkdir -p ~/rexx-migration/{source,output}

# Count REXX scripts by type
find ~/rexx-migration/source -name "*.rexx" -o -name "*.exec" | wc -l

# Identify patterns
grep -rn "EXECIO" ~/rexx-migration/source/ | wc -l       # File I/O
grep -rn "EXECSQL" ~/rexx-migration/source/ | wc -l      # DB2 access
grep -rn "ADDRESS ISPEXEC" ~/rexx-migration/source/ | wc -l  # ISPF
grep -rn "ADDRESS TSO" ~/rexx-migration/source/ | wc -l   # TSO commands
grep -rn "OUTTRAP" ~/rexx-migration/source/ | wc -l       # Output capture
```

### Step 2: Convert REXX EXECIO and Stem Variables

Original REXX EXEC:

```rexx
/* REXX - Process daily transaction file and generate summary */
TRACE OFF
ARG input_dsn output_dsn

/* Read input dataset using EXECIO */
"ALLOC FI(INFILE) DA('"input_dsn"') SHR REUSE"
"EXECIO * DISKR INFILE (STEM inrec. FINIS)"
"FREE FI(INFILE)"

IF RC <> 0 THEN DO
  SAY 'Error reading' input_dsn '- RC=' RC
  EXIT 12
END

SAY 'Read' inrec.0 'records from' input_dsn

/* Initialize counters using stem variables */
total.  = 0
count.  = 0

/* Process each record (fixed-length 80-byte format) */
DO i = 1 TO inrec.0
  PARSE VAR inrec.i acct_no 11 txn_type 12 amount 23 txn_date 31 .

  acct_no  = STRIP(acct_no)
  txn_type = STRIP(txn_type)
  amount   = STRIP(amount) + 0   /* Force numeric */

  IF txn_type = 'C' THEN DO      /* Credit */
    total.acct_no = total.acct_no + amount
    count.acct_no = count.acct_no + 1
  END
  ELSE IF txn_type = 'D' THEN DO /* Debit */
    total.acct_no = total.acct_no - amount
    count.acct_no = count.acct_no + 1
  END
  ELSE DO
    SAY 'WARNING: Unknown txn type' txn_type 'at record' i
  END
END

/* Write summary output */
outrec.  = ''
outrec.0 = 0
j = 0

DO i = 1 TO inrec.0
  PARSE VAR inrec.i acct_no 11 .
  acct_no = STRIP(acct_no)
  IF count.acct_no > 0 THEN DO
    j = j + 1
    outrec.j = LEFT(acct_no,10) || RIGHT(FORMAT(total.acct_no,12,2),14) ||,
               RIGHT(count.acct_no,6)
    count.acct_no = 0   /* Prevent duplicates */
  END
END
outrec.0 = j

"ALLOC FI(OUTFILE) DA('"output_dsn"') NEW CATALOG",
  "SPACE(1,1) TRACKS RECFM(F B) LRECL(80) BLKSIZE(8000)"
"EXECIO" outrec.0 "DISKW OUTFILE (STEM outrec. FINIS)"
"FREE FI(OUTFILE)"

SAY 'Wrote' outrec.0 'summary records to' output_dsn
EXIT 0
```

Claude Code converts to Python:

```python
#!/usr/bin/env python3
"""Process daily transaction file and generate summary.
Converted from REXX EXEC — preserves fixed-length record format logic."""

import sys
from collections import defaultdict
from decimal import Decimal, InvalidOperation
import logging

logging.basicConfig(level=logging.INFO, format='%(levelname)s: %(message)s')
logger = logging.getLogger(__name__)

def process_transactions(input_path: str, output_path: str) -> int:
    """Process fixed-format transaction records into account summaries."""

    # Read input (replaces EXECIO * DISKR INFILE STEM inrec.)
    try:
        with open(input_path, 'r') as f:
            records = f.readlines()
    except FileNotFoundError:
        logger.error(f'Error reading {input_path}')
        return 12

    logger.info(f'Read {len(records)} records from {input_path}')

    # Initialize counters (replaces stem variables total. and count.)
    totals = defaultdict(Decimal)
    counts = defaultdict(int)

    # Process records (replaces DO i = 1 TO inrec.0 with PARSE)
    for i, record in enumerate(records, 1):
        # PARSE VAR positions: acct_no(1-10) txn_type(11) amount(12-22) date(23-30)
        acct_no  = record[0:10].strip()
        txn_type = record[10:11].strip()
        try:
            amount = Decimal(record[11:22].strip())
        except (InvalidOperation, ValueError):
            logger.warning(f'Invalid amount at record {i}')
            continue

        if txn_type == 'C':
            totals[acct_no] += amount
            counts[acct_no] += 1
        elif txn_type == 'D':
            totals[acct_no] -= amount
            counts[acct_no] += 1
        else:
            logger.warning(f'Unknown txn type {txn_type!r} at record {i}')

    # Write summary (replaces EXECIO DISKW OUTFILE STEM outrec.)
    summary_count = 0
    with open(output_path, 'w') as f:
        for acct_no in sorted(totals.keys()):
            if counts[acct_no] > 0:
                line = f'{acct_no:<10}{totals[acct_no]:>14.2f}{counts[acct_no]:>6d}\n'
                f.write(line)
                summary_count += 1

    logger.info(f'Wrote {summary_count} summary records to {output_path}')
    return 0

if __name__ == '__main__':
    if len(sys.argv) != 3:
        print(f'Usage: {sys.argv[0]} <input_file> <output_file>')
        sys.exit(8)
    sys.exit(process_transactions(sys.argv[1], sys.argv[2]))
```

### Step 3: Convert TSO/ISPF Commands to z/OSMF API Calls

```python
# For scripts that must still interact with the mainframe
import requests

class ZosmfClient:
    """Replaces ADDRESS TSO and ADDRESS ISPEXEC commands."""

    def __init__(self, host: str, port: int = 443):
        self.base_url = f"https://{host}:{port}/zosmf"
        self.session = requests.Session()
        self.session.verify = True

    def submit_jcl(self, jcl: str) -> dict:
        """Replaces: ADDRESS TSO 'SUBMIT' """
        resp = self.session.put(
            f"{self.base_url}/restjobs/jobs",
            json={"input": jcl},
            headers={"Content-Type": "application/json"}
        )
        resp.raise_for_status()
        return resp.json()

    def list_datasets(self, pattern: str) -> list:
        """Replaces: ADDRESS TSO 'LISTDS' pattern """
        resp = self.session.get(
            f"{self.base_url}/restfiles/ds",
            params={"dslevel": pattern}
        )
        resp.raise_for_status()
        return resp.json().get("items", [])
```

### Step 4: Verify

```bash
# Test with sample mainframe-format data
python3 ~/rexx-migration/output/process_transactions.py \
  ~/rexx-migration/test/sample_input.dat \
  ~/rexx-migration/test/output.dat

# Compare outputs
diff ~/rexx-migration/test/expected_output.dat \
     ~/rexx-migration/test/output.dat

# Run full test suite
cd ~/rexx-migration/output && python3 -m pytest tests/ -v
```

## CLAUDE.md for Mainframe REXX Modernization

```markdown
# Mainframe REXX to Python Migration Standards

## Domain Rules
- EXECIO DISKR/DISKW maps to open()/read()/write()
- Stem variables (var.index) map to dict or defaultdict
- PARSE VAR with column positions maps to string slicing
- ADDRESS TSO commands map to z/OSMF REST API calls
- OUTTRAP maps to subprocess.run(capture_output=True)
- Fixed-length records must preserve column positions exactly
- Return codes: 0=success, 4=warning, 8=error, 12=severe, 16=fatal

## File Patterns
- Source: *.rexx, *.exec, *.clist
- Target: Python 3.10+ with type hints
- REXX EXECs: src/scripts/ (standalone)
- ISPF panels: src/web/ (if converting to web UI)
- JCL generators: src/templates/ (Jinja2)

## Common Commands
- python3 script.py input.dat output.dat
- python3 -m pytest tests/ -v
- mypy src/ --strict
- flake8 src/ --max-line-length 100
```

## Common Pitfalls in REXX Modernization

- **Stem variable default values:** REXX stem variables return their own name when uninitialized (e.g., `total.NEWKEY` returns `TOTAL.NEWKEY`). Claude Code uses `defaultdict` with explicit zero/empty defaults to avoid this gotcha.

- **PARSE template alignment:** REXX PARSE uses absolute column positions that can silently shift if records have different encodings (EBCDIC vs ASCII). Claude Code adds assertion checks on record length before parsing.

- **TSO command return codes:** REXX scripts check RC after every TSO command. Claude Code preserves this pattern with explicit return code checking on every subprocess call or API response.

## Related

- [Claude Code for COBOL to Java Migration](/claude-code-cobol-to-java-migration-2026/)
- [Claude Code for Natural/ADABAS Migration](/claude-code-natural-adabas-migration-2026/)
- [Claude Code for Ada Legacy System Updates](/claude-code-ada-legacy-system-updates-2026/)
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
        "text": "Claude Code creates files and edits through standard filesystem operations, so all changes are visible in `git diff`. If a change is wrong, revert it with `git checkout -- <file>` for a single file or `git stash` for all changes. Claude Code does not make irreversible changes unless you explicitly allow destructive commands in settings.json."
      }
    }
  ]
}
</script>
