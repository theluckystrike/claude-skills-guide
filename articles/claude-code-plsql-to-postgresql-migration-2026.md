---
layout: default
title: "Claude Code for PL/SQL to PostgreSQL (2026)"
permalink: /claude-code-plsql-to-postgresql-migration-2026/
date: 2026-04-20
description: "Migrate Oracle PL/SQL to PostgreSQL with Claude Code. Convert packages, cursors, autonomous transactions, and Oracle-specific syntax."
last_tested: "2026-04-22"
domain: "database migration"
---

## Why Claude Code for PL/SQL to PostgreSQL

Oracle-to-PostgreSQL migration is one of the most common database modernization projects, driven by Oracle's licensing costs that can reach seven figures annually. While the SQL is mostly compatible, PL/SQL stored procedures, packages, autonomous transactions, Oracle-specific functions (NVL, DECODE, CONNECT BY), and materialized view refresh logic require careful rewriting. Ora2Pg handles schema conversion but leaves complex procedural code for manual effort.

Claude Code can parse PL/SQL package specifications and bodies, convert Oracle cursors to PostgreSQL's RETURN QUERY pattern, replace autonomous transactions with dblink calls, and map Oracle's hierarchical queries (CONNECT BY PRIOR) to PostgreSQL recursive CTEs.

## The Workflow

### Step 1: Export and Analyze Oracle Schema

```bash
# Use Ora2Pg for initial schema assessment
pip install ora2pg  # or build from source
ora2pg -t SHOW_REPORT -c ora2pg.conf > migration_report.txt

# Export PL/SQL source
sqlplus -S user/pass@orcl <<'SQL'
SET LONG 999999 PAGES 0 LINES 32767
SPOOL plsql_export.sql
SELECT text FROM all_source
WHERE owner = 'MY_SCHEMA'
ORDER BY type, name, line;
SPOOL OFF
SQL

# Count objects by type
grep -c "PACKAGE BODY" plsql_export.sql
grep -c "PROCEDURE" plsql_export.sql
grep -c "FUNCTION" plsql_export.sql
grep -c "TRIGGER" plsql_export.sql
```

### Step 2: Convert Oracle Packages to PostgreSQL Schemas

Oracle PL/SQL package:

```sql
-- Oracle PL/SQL Package
CREATE OR REPLACE PACKAGE pkg_order_mgmt AS
  TYPE order_rec IS RECORD (
    order_id    NUMBER,
    cust_id     NUMBER,
    total_amt   NUMBER(12,2),
    status      VARCHAR2(20)
  );

  TYPE order_cursor IS REF CURSOR RETURN order_rec;

  PROCEDURE create_order(
    p_cust_id   IN  NUMBER,
    p_items     IN  SYS.ODCINUMBERLIST,
    p_order_id  OUT NUMBER
  );

  FUNCTION get_customer_orders(
    p_cust_id IN NUMBER
  ) RETURN order_cursor;

  PROCEDURE cancel_order(
    p_order_id IN NUMBER
  );

  -- Autonomous transaction for audit logging
  PROCEDURE log_audit(
    p_action  IN VARCHAR2,
    p_details IN VARCHAR2
  );
END pkg_order_mgmt;
/

CREATE OR REPLACE PACKAGE BODY pkg_order_mgmt AS

  PROCEDURE create_order(
    p_cust_id   IN  NUMBER,
    p_items     IN  SYS.ODCINUMBERLIST,
    p_order_id  OUT NUMBER
  ) IS
    v_total NUMBER(12,2) := 0;
  BEGIN
    SELECT order_seq.NEXTVAL INTO p_order_id FROM DUAL;

    INSERT INTO orders (order_id, cust_id, status, created_date)
    VALUES (p_order_id, p_cust_id, 'PENDING', SYSDATE);

    FOR i IN 1..p_items.COUNT LOOP
      INSERT INTO order_items (order_id, product_id, qty, unit_price)
      SELECT p_order_id, p_items(i), 1, price
      FROM products WHERE product_id = p_items(i);
    END LOOP;

    SELECT NVL(SUM(qty * unit_price), 0) INTO v_total
    FROM order_items WHERE order_id = p_order_id;

    UPDATE orders SET total_amt = v_total WHERE order_id = p_order_id;

    log_audit('CREATE_ORDER', 'Order ' || p_order_id || ' total: ' || v_total);
  EXCEPTION
    WHEN OTHERS THEN
      log_audit('CREATE_ORDER_ERROR', SQLERRM);
      RAISE;
  END create_order;

  PROCEDURE log_audit(
    p_action  IN VARCHAR2,
    p_details IN VARCHAR2
  ) IS
    PRAGMA AUTONOMOUS_TRANSACTION;
  BEGIN
    INSERT INTO audit_log (action, details, log_date)
    VALUES (p_action, p_details, SYSDATE);
    COMMIT;
  END log_audit;

END pkg_order_mgmt;
/
```

Claude Code converts to PostgreSQL:

```sql
-- PostgreSQL: Package becomes schema + functions
CREATE SCHEMA IF NOT EXISTS order_mgmt;

-- Custom types replace package-level types
CREATE TYPE order_mgmt.order_rec AS (
    order_id    BIGINT,
    cust_id     BIGINT,
    total_amt   NUMERIC(12,2),
    status      VARCHAR(20)
);

-- Sequence replaces Oracle sequence (auto-created with BIGSERIAL)
-- But explicit if needed:
CREATE SEQUENCE order_mgmt.order_seq;

-- Autonomous transaction via dblink (PostgreSQL workaround)
CREATE EXTENSION IF NOT EXISTS dblink;

CREATE OR REPLACE FUNCTION order_mgmt.log_audit(
    p_action  TEXT,
    p_details TEXT
) RETURNS VOID
LANGUAGE plpgsql AS $$
BEGIN
    -- Autonomous transaction: commits independently via dblink
    PERFORM dblink_exec(
        'dbname=' || current_database(),
        format(
            'INSERT INTO audit_log (action, details, log_date) VALUES (%L, %L, NOW())',
            p_action, p_details
        )
    );
END;
$$;

-- Main procedure
CREATE OR REPLACE FUNCTION order_mgmt.create_order(
    p_cust_id BIGINT,
    p_items   BIGINT[]     -- replaces SYS.ODCINUMBERLIST
) RETURNS BIGINT
LANGUAGE plpgsql AS $$
DECLARE
    v_order_id BIGINT;
    v_total    NUMERIC(12,2) := 0;
    v_item     BIGINT;
BEGIN
    v_order_id := nextval('order_mgmt.order_seq');

    INSERT INTO orders (order_id, cust_id, status, created_date)
    VALUES (v_order_id, p_cust_id, 'PENDING', NOW());

    -- FOREACH replaces Oracle collection FOR loop
    FOREACH v_item IN ARRAY p_items LOOP
        INSERT INTO order_items (order_id, product_id, qty, unit_price)
        SELECT v_order_id, v_item, 1, price
        FROM products WHERE product_id = v_item;
    END LOOP;

    -- COALESCE replaces NVL
    SELECT COALESCE(SUM(qty * unit_price), 0) INTO v_total
    FROM order_items WHERE order_id = v_order_id;

    UPDATE orders SET total_amt = v_total WHERE order_id = v_order_id;

    PERFORM order_mgmt.log_audit(
        'CREATE_ORDER',
        'Order ' || v_order_id || ' total: ' || v_total
    );

    RETURN v_order_id;

EXCEPTION
    WHEN OTHERS THEN
        PERFORM order_mgmt.log_audit('CREATE_ORDER_ERROR', SQLERRM);
        RAISE;
END;
$$;

-- REF CURSOR becomes RETURNS SETOF
CREATE OR REPLACE FUNCTION order_mgmt.get_customer_orders(
    p_cust_id BIGINT
) RETURNS SETOF order_mgmt.order_rec
LANGUAGE plpgsql AS $$
BEGIN
    RETURN QUERY
    SELECT order_id, cust_id, total_amt, status
    FROM orders
    WHERE cust_id = p_cust_id
    ORDER BY created_date DESC;
END;
$$;
```

### Step 3: Convert CONNECT BY to Recursive CTE

```sql
-- Oracle hierarchical query
SELECT employee_id, manager_id, LEVEL, SYS_CONNECT_BY_PATH(name, '/')
FROM employees
START WITH manager_id IS NULL
CONNECT BY PRIOR employee_id = manager_id;

-- PostgreSQL recursive CTE equivalent
WITH RECURSIVE emp_hierarchy AS (
    SELECT employee_id, manager_id, 1 AS level,
           '/' || name AS path
    FROM employees
    WHERE manager_id IS NULL
    UNION ALL
    SELECT e.employee_id, e.manager_id, h.level + 1,
           h.path || '/' || e.name
    FROM employees e
    JOIN emp_hierarchy h ON e.manager_id = h.employee_id
)
SELECT * FROM emp_hierarchy ORDER BY path;
```

### Step 4: Verify

```bash
# Run Ora2Pg validation
ora2pg -t TEST -c ora2pg.conf

# Compare row counts
psql -d target_db -c "
  SELECT schemaname, tablename,
         (SELECT count(*) FROM pg_class WHERE relname = tablename) as row_count
  FROM pg_tables WHERE schemaname = 'public'
  ORDER BY tablename;"

# Run converted function tests
psql -d target_db -c "SELECT order_mgmt.create_order(1, ARRAY[101, 102, 103]);"
psql -d target_db -c "SELECT * FROM order_mgmt.get_customer_orders(1);"
```

## CLAUDE.md for PL/SQL to PostgreSQL Migration

```markdown
# Oracle PL/SQL to PostgreSQL Migration Standards

## Domain Rules
- PL/SQL packages map to PostgreSQL schemas + functions
- REF CURSOR RETURN maps to RETURNS SETOF or RETURNS TABLE
- NVL() maps to COALESCE()
- DECODE() maps to CASE WHEN
- SYSDATE maps to NOW() or CURRENT_TIMESTAMP
- DUAL table references removed (SELECT without FROM)
- SYS.ODCINUMBERLIST maps to native ARRAY types
- Autonomous transactions use dblink_exec workaround
- CONNECT BY maps to WITH RECURSIVE CTE

## File Patterns
- Source: *.pks (package spec), *.pkb (package body), *.sql
- Target: migrations/*.sql (Flyway or pgmigrate format)
- Functions: sql/functions/schema_name/
- Types: sql/types/

## Common Commands
- ora2pg -t SHOW_REPORT -c ora2pg.conf
- ora2pg -t FUNCTION -c ora2pg.conf -o output/functions.sql
- psql -d target -f migrations/V001__schema.sql
- pgbench -c 10 -T 60 target_db  (performance comparison)
- pg_prove -d target_db tests/*.sql  (pgTAP tests)
```

## Common Pitfalls in PL/SQL to PostgreSQL Migration

- **Exception handling differences:** Oracle's `WHEN NO_DATA_FOUND` maps to PostgreSQL's `WHEN NO_DATA_FOUND`, but `WHEN TOO_MANY_ROWS` requires adding `STRICT` to `SELECT INTO` statements. Claude Code adds STRICT annotations and proper exception blocks.

- **Implicit type coercion:** Oracle silently converts between VARCHAR2 and NUMBER. PostgreSQL requires explicit casts. Claude Code adds `::numeric`, `::text` casts wherever Oracle relied on implicit conversion.

- **Sequence behavior after failed inserts:** Oracle sequences increment even on rollback; PostgreSQL sequences also do this by default, but the gap behavior can differ. Claude Code documents these gaps for audit compliance.

## Related

- [Claude Code for COBOL to Java Migration](/claude-code-cobol-to-java-migration-2026/)
- [Claude Code for Clipper to PostgreSQL Migration](/claude-code-clipper-to-postgresql-migration-2026/)
- [Claude Code for FoxPro Database Modernization](/claude-code-foxpro-database-modernization-2026/)


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




**Build yours →** Create a custom CLAUDE.md with our [Generator Tool](/generator/).

## Related Guides

**Estimate tokens →** Calculate your usage with our [Token Estimator](/token-estimator/).

**Try it:** Estimate your monthly spend with our [Cost Calculator](/calculator/).

- [Claude Code for PostgreSQL JSONB](/claude-code-for-postgres-jsonb-workflow-tutorial/)
- [Claude Code MongoDB to PostgreSQL](/claude-code-mongodb-to-postgresql-migration-workflow/)
- [Claude Code for PostgreSQL Full-Text](/claude-code-for-postgres-full-text-search-workflow/)

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
