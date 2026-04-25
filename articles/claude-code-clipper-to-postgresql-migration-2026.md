---
layout: default
title: "Claude Code for Clipper to PostgreSQL (2026)"
permalink: /claude-code-clipper-to-postgresql-migration-2026/
date: 2026-04-20
description: "Migrate CA-Clipper and Harbour applications to PostgreSQL with Claude Code. Convert DBF data, Xbase code, and NTX indexes."
last_tested: "2026-04-22"
domain: "legacy modernization"
---

## Why Claude Code for Clipper Migration

CA-Clipper applications from the late 1980s and 1990s still run in warehouses, government offices, and small manufacturers. These DOS-era programs use DBF/NTX file-based databases with Xbase syntax, memory variables, and screen I/O via @..SAY..GET commands. Many were later ported to Harbour (the open-source Clipper compiler), but the underlying architecture remains tied to file-level locking and sequential record processing that cannot scale.

Claude Code understands Clipper's Xbase dialect including its unique scoping rules (PRIVATE, PUBLIC, LOCAL), its macro substitution operator (&), and the index expression syntax in NTX/CDX files. It generates proper SQL schemas and application code that preserves the business logic buried in decades-old PRG files.

## The Workflow

### Step 1: Catalog and Extract the Clipper Codebase

```bash
# Inventory Clipper project
mkdir -p ~/clipper-migration/{source,output,sql}
find /path/to/clipper-app -type f \( \
  -name "*.prg" -o -name "*.ch" -o -name "*.dbf" \
  -o -name "*.ntx" -o -name "*.cdx" -o -name "*.mem" \) \
  | sort > ~/clipper-migration/inventory.txt

# Extract DBF structures using Harbour's hbrun
hbrun -e "
  USE /path/to/clipper-app/CUSTOMER.DBF
  FOR i := 1 TO FCount()
    ? FieldName(i), FieldType(i), FieldLen(i), FieldDec(i)
  NEXT
  CLOSE
"

# Or use Python for DBF inspection
pip install dbf
python3 -c "
import dbf
table = dbf.Table('/path/to/clipper-app/CUSTOMER.DBF')
table.open()
for field in table.field_names:
    info = table.field_info(field)
    print(f'{field}: type={info[0]}, len={info[1]}, dec={info[2]}')
table.close()
"
```

### Step 2: Convert Clipper Xbase to Python with SQL

Original Clipper code:

```clipper
// INVOICE.PRG - Calculate and print invoices
#include "inkey.ch"

FUNCTION CalcInvoice(cCustCode)
  LOCAL nTotal := 0, nTax := 0

  SELECT 2
  USE INVLINES INDEX INVLINES
  SEEK cCustCode

  DO WHILE .NOT. EOF() .AND. INVLINES->CUSTCODE == cCustCode
    nLineAmt := INVLINES->QTY * INVLINES->PRICE
    IF INVLINES->DISCOUNT > 0
      nLineAmt := nLineAmt * (1 - INVLINES->DISCOUNT / 100)
    ENDIF
    REPLACE INVLINES->LINEAMT WITH nLineAmt
    nTotal += nLineAmt
    SKIP
  ENDDO

  SELECT 3
  USE TAXRATES INDEX TAXRATES
  SEEK CUSTOMER->STATE
  IF FOUND()
    nTax := nTotal * TAXRATES->RATE / 100
  ENDIF

  SELECT 1
  REPLACE CUSTOMER->BALANCE WITH CUSTOMER->BALANCE + nTotal + nTax
  REPLACE CUSTOMER->LASTINV WITH DATE()

  CLOSE DATABASES
RETURN nTotal + nTax
```

Claude Code generates:

```python
# services/invoice.py
from decimal import Decimal
from datetime import date
import asyncpg

async def calculate_invoice(pool: asyncpg.Pool, cust_code: str) -> Decimal:
    async with pool.acquire() as conn:
        async with conn.transaction():
            # Fetch and calculate line items (replaces SEEK + DO WHILE)
            lines = await conn.fetch("""
                SELECT id, qty, price, discount
                FROM invoice_lines
                WHERE cust_code = $1
                ORDER BY id
            """, cust_code)

            total = Decimal('0.00')
            for line in lines:
                line_amt = line['qty'] * line['price']
                if line['discount'] and line['discount'] > 0:
                    line_amt *= (1 - Decimal(str(line['discount'])) / 100)
                line_amt = line_amt.quantize(Decimal('0.01'))

                await conn.execute("""
                    UPDATE invoice_lines SET line_amt = $1 WHERE id = $2
                """, line_amt, line['id'])
                total += line_amt

            # Tax lookup (replaces SEEK on TAXRATES)
            state = await conn.fetchval("""
                SELECT state FROM customers WHERE cust_code = $1
            """, cust_code)

            tax_rate = await conn.fetchval("""
                SELECT rate FROM tax_rates WHERE state = $1
            """, state)
            tax = (total * tax_rate / 100) if tax_rate else Decimal('0.00')

            # Update customer balance (replaces REPLACE command)
            await conn.execute("""
                UPDATE customers
                SET balance = balance + $1, last_inv = $2
                WHERE cust_code = $3
            """, total + tax, date.today(), cust_code)

            return total + tax
```

### Step 3: Migrate NTX Indexes to PostgreSQL

```sql
-- Clipper NTX index expressions -> PostgreSQL indexes
-- INDEX ON UPPER(CUSTCODE) TO CUST_CD.NTX
CREATE INDEX idx_customers_code ON customers (UPPER(cust_code));

-- INDEX ON DTOS(INVDATE)+CUSTCODE TO INVDATE.NTX
CREATE INDEX idx_inv_date_cust ON invoices (inv_date DESC, cust_code);

-- INDEX ON STR(ZIPCODE,5)+UPPER(LASTNAME) TO CUSTZIP.NTX
CREATE INDEX idx_cust_zip_name ON customers (
    LPAD(zip_code::text, 5, '0'), UPPER(last_name)
);

-- Clipper SET FILTER TO equivalent
CREATE VIEW active_customers AS
    SELECT * FROM customers WHERE is_active = TRUE;
```

### Step 4: Verify

```bash
# Record count parity check
python3 -c "
import dbf
for tbl in ['CUSTOMER', 'INVLINES', 'TAXRATES']:
    t = dbf.Table(f'/path/to/clipper-app/{tbl}.DBF')
    t.open()
    print(f'{tbl}: {len(t)} records')
    t.close()
"

psql -d migrated_db -c "
  SELECT 'customers', count(*) FROM customers
  UNION ALL SELECT 'invoice_lines', count(*) FROM invoice_lines
  UNION ALL SELECT 'tax_rates', count(*) FROM tax_rates;"

# Balance reconciliation
psql -d migrated_db -c "
  SELECT SUM(balance) as total_ar FROM customers;"
```

## CLAUDE.md for Clipper Migration

```markdown
# Clipper/Harbour to PostgreSQL Migration Standards

## Domain Rules
- DBF tables map to PostgreSQL tables with SERIAL primary keys
- NTX/CDX index expressions map to functional indexes
- SEEK command maps to WHERE clause with indexed column
- DO WHILE/SKIP loops map to SELECT queries with cursors or fetchall
- REPLACE command maps to UPDATE statements
- Memory variables (PRIVATE/PUBLIC) map to function-scoped variables
- Macro substitution (&variable) must be replaced with parameterized queries

## File Patterns
- Source: *.prg, *.ch, *.dbf, *.ntx, *.cdx, *.mem, *.fmt
- Target: Python (asyncpg + FastAPI + PostgreSQL)
- PRG files: src/services/ (business logic)
- FMT files: src/templates/ (Jinja2 templates)
- Reports: src/reports/ (WeasyPrint)

## Common Commands
- hbrun -e "USE table.dbf; ? RecCount(); CLOSE"
- psql -d target_db -f migrations/001_schema.sql
- python3 scripts/migrate_data.py --source /path/to/dbfs
- pytest tests/test_data_parity.py -v
- python3 -m uvicorn main:app --reload
```

## Common Pitfalls in Clipper Migration

- **Work area confusion:** Clipper uses numbered work areas (SELECT 1, SELECT 2) for multi-table operations. Claude Code eliminates this concept entirely, using explicit query joins instead of the implicit cursor-based model.

- **Macro substitution injection risk:** Clipper's `&variable` macro evaluates strings as code, which cannot translate directly to SQL. Claude Code replaces all macro patterns with parameterized queries to prevent SQL injection.

- **Date handling inconsistencies:** Clipper's `SET DATE` command changes date parsing globally. Claude Code normalizes all dates to ISO 8601 during migration and uses PostgreSQL DATE type consistently.

## Related

- [Claude Code for FoxPro Database Modernization](/claude-code-foxpro-database-modernization-2026/)
- [Claude Code for COBOL to Java Migration](/claude-code-cobol-to-java-migration-2026/)
- [Claude Code for PL/SQL to PostgreSQL Migration](/claude-code-plsql-to-postgresql-migration-2026/)


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

- [Claude Code for PostgreSQL JSONB](/claude-code-for-postgres-jsonb-workflow-tutorial/)
- [Claude Code MongoDB to PostgreSQL](/claude-code-mongodb-to-postgresql-migration-workflow/)
- [Claude Code for PostgreSQL Full-Text](/claude-code-for-postgres-full-text-search-workflow/)
- [Notion Web Clipper Chrome Extension](/chrome-extension-notion-web-clipper/)

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
