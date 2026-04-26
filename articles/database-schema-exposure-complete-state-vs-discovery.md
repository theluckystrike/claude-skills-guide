---
layout: default
title: "Database Schema Exposure (2026)"
description: "Exposing complete database schema upfront saves Claude Code 3,000-10,000 tokens per session by eliminating iterative discovery queries against the database."
permalink: /database-schema-exposure-complete-state-vs-discovery/
date: 2026-04-22
last_tested: "2026-04-22"
---

# Database Schema Exposure: Complete State vs Discovery Queries

## The Pattern

Complete schema exposure provides Claude Code with the full database structure (tables, columns, types, relationships, constraints) upfront, either through a pre-generated summary file or a single MCP call. This eliminates the iterative discovery pattern where Claude Code runs 5-15 queries to understand the database incrementally.

## Why It Matters for Token Cost

Database discovery is one of the most expensive exploration patterns in Claude Code. Without schema exposure, a typical discovery sequence looks like:

1. List tables: `\dt` (~345 tokens)
2. Describe users table: `\d users` (~345 tokens + ~500 response)
3. Describe orders table: `\d orders` (~345 tokens + ~400 response)
4. Check foreign keys: query `information_schema` (~345 tokens + ~600 response)
5. Check indexes: another information_schema query (~345 tokens + ~400 response)
6. Repeat for 3-5 more tables (~1,725-2,875 tokens)

Total: 3,450-5,255 tokens in overhead, plus 1,900-3,775 tokens in responses = 5,350-9,030 tokens.

Complete exposure costs: one Read of a summary file (~150 tokens overhead + ~400-800 tokens content) = 550-950 tokens.

**Savings: 4,400-8,080 tokens per schema discovery sequence.**

## The Anti-Pattern (What NOT to Do)

```bash
# Anti-pattern: iterative schema discovery
# Claude Code runs these commands sequentially:

psql -c "\dt"
# Returns: 15 tables listed

psql -c "\d users"
# Returns: 12 columns with types and constraints

psql -c "\d orders"
# Returns: 10 columns with types

psql -c "SELECT tc.table_name, kcu.column_name, ccu.table_name AS foreign_table
FROM information_schema.table_constraints tc
JOIN information_schema.key_column_usage kcu ON tc.constraint_name = kcu.constraint_name
JOIN information_schema.constraint_column_usage ccu ON ccu.constraint_name = tc.constraint_name
WHERE tc.constraint_type = 'FOREIGN KEY' LIMIT 50;"
# Returns: all foreign key relationships

# 4+ tool calls, each adding to conversation history
# Total: ~6,000-8,000 tokens
```

## The Pattern in Action

### Step 1: Generate a Schema Exposure File

```bash
#!/bin/bash
# scripts/expose-schema.sh
# Generates a compact schema file for Claude Code consumption
set -euo pipefail

OUTPUT=".claude/skills/db-schema.md"
mkdir -p .claude/skills

DB_URL="${DATABASE_URL:-postgresql://localhost/myapp}"

echo "# Database Schema (auto-generated $(date +%Y-%m-%d))" > "$OUTPUT"
echo "" >> "$OUTPUT"

# Extract table and column info (bounded: max 50 tables)
psql "$DB_URL" -t -c "
SELECT table_name
FROM information_schema.tables
WHERE table_schema = 'public'
ORDER BY table_name
LIMIT 50;" | while IFS= read -r table; do
  table=$(echo "$table" | tr -d ' ')
  [ -z "$table" ] && continue

  echo "## $table" >> "$OUTPUT"
  psql "$DB_URL" -t -c "
  SELECT column_name || ' ' || data_type ||
    CASE WHEN is_nullable = 'NO' THEN ' NOT NULL' ELSE '' END
  FROM information_schema.columns
  WHERE table_name = '$table' AND table_schema = 'public'
  ORDER BY ordinal_position
  LIMIT 30;" | sed 's/^/- /' >> "$OUTPUT"
  echo "" >> "$OUTPUT"
done

# Add foreign keys
echo "## Relationships" >> "$OUTPUT"
psql "$DB_URL" -t -c "
SELECT tc.table_name || '.' || kcu.column_name || ' -> ' || ccu.table_name || '.' || ccu.column_name
FROM information_schema.table_constraints tc
JOIN information_schema.key_column_usage kcu ON tc.constraint_name = kcu.constraint_name
JOIN information_schema.constraint_column_usage ccu ON ccu.constraint_name = tc.constraint_name
WHERE tc.constraint_type = 'FOREIGN KEY'
LIMIT 50;" | sed 's/^/- /' >> "$OUTPUT"

WORDS=$(wc -w < "$OUTPUT" | tr -d ' ')
echo "Schema exposed: $WORDS words (~$((WORDS * 100 / 75)) tokens)"
```

### Step 2: For Prisma Projects, Use the Schema Directly

```bash
#!/bin/bash
# scripts/prisma-schema-summary.sh
# Extracts a compact summary from prisma/schema.prisma
set -euo pipefail

OUTPUT=".claude/skills/db-schema.md"
SCHEMA="prisma/schema.prisma"
mkdir -p .claude/skills

echo "# Database Schema (from Prisma, $(date +%Y-%m-%d))" > "$OUTPUT"
echo "" >> "$OUTPUT"

# Extract model names and fields (bounded: max 60 models)
grep -n "^model " "$SCHEMA" | head -60 | while IFS=: read -r linenum rest; do
  model=$(echo "$rest" | sed 's/model \([A-Za-z]*\).*/\1/')
  echo "## $model" >> "$OUTPUT"

  # Get fields until closing brace (bounded: max 30 fields)
  sed -n "$((linenum+1)),/^}/p" "$SCHEMA" | head -30 | \
    grep -E '^\s+\w+\s+' | grep -v '^\s*//' | \
    sed 's/^\s*/- /' >> "$OUTPUT"
  echo "" >> "$OUTPUT"
done

WORDS=$(wc -w < "$OUTPUT" | tr -d ' ')
echo "Generated: $WORDS words (~$((WORDS * 100 / 75)) tokens)"
```

### Step 3: Add CLAUDE.md Reference

```markdown
# CLAUDE.md

## Database
- Full schema: see db-schema skill (auto-generated, 15 tables)
- Run `./scripts/expose-schema.sh` to regenerate after migrations
- Do NOT run discovery queries (\dt, \d, information_schema) -- use the cached schema
- For live data counts, use the inspect endpoint: `curl localhost:3000/api/inspect`
```

## Before and After

| Metric | Discovery Queries | Complete Exposure | Savings |
|--------|------------------|-------------------|---------|
| Tool calls | 5-15 | 1 (Read skill) | 80-93% |
| Token overhead | 1,725-5,175 | ~150 | 91-97% |
| Response tokens | 1,900-3,775 | 400-800 | 72-79% |
| Total tokens | 5,350-9,030 | 550-950 | 87-89% |
| Monthly cost (100 sessions) | $1.61-$2.71 | $0.17-$0.29 | **$1.44-$2.42** |

### Domain-Specific Schema Views

For large databases, create focused views per domain rather than one massive schema file:

```markdown
# .claude/skills/schema-auth.md -- Authentication domain (~150 tokens)
## Auth Domain Models
- users: id (uuid), email (unique), password_hash, role (USER|ADMIN), verified, created_at
- sessions: id (uuid), user_id -> users, token (unique), ip, user_agent, expires_at
- password_resets: id, user_id -> users, token (unique), expires_at, used_at
- Indexes: users(email), sessions(token), sessions(user_id, expires_at)
```

```markdown
# .claude/skills/schema-billing.md -- Billing domain (~200 tokens)
## Billing Domain Models
- subscriptions: id, user_id -> users, plan (FREE|PRO|TEAM), status, stripe_id, period_end
- invoices: id, user_id -> users, amount_cents, currency, status, stripe_invoice_id, paid_at
- payment_methods: id, user_id -> users, type (CARD|BANK), last4, exp_month, exp_year, is_default
- Indexes: subscriptions(user_id, status), invoices(user_id, status)
```

When working on authentication features, Claude Code loads only the auth schema (~150 tokens). When working on billing, only the billing schema (~200 tokens). The full database might have 15 tables across 4 domains, but a focused task only needs 3-4 tables.

**Savings: 60-80% compared to loading the full schema for every database task**

## When to Use This Pattern

- **Any project with a database**: The schema summary is a universal win. Every project benefits.
- **Microservices**: Each service with its own database gets its own schema exposure file.
- **Team projects**: Multiple developers querying the same schema multiply the savings.

## When NOT to Use This Pattern

- **Databases with 100+ tables**: The schema file itself becomes expensive to read. Use focused, domain-specific summaries instead of one giant file.
- **Schemas that change hourly**: In rapid prototyping phases, the cache maintenance overhead may not justify itself. Consider an MCP tool that generates the summary on-demand.

### Keeping Schema Exposure Files Current

Stale schema files are worse than no schema files -- they cause Claude Code to write queries against columns that no longer exist, leading to expensive error-and-retry cycles. Automate regeneration:

```bash
# Add to CI pipeline or git hooks
#!/bin/bash
# scripts/check-schema-freshness.sh
set -uo pipefail

SCHEMA_FILE="prisma/schema.prisma"
EXPOSURE_FILE=".claude/skills/db-schema.md"

if [ ! -f "$EXPOSURE_FILE" ]; then
  echo "WARN: Schema exposure file does not exist. Run expose-schema.sh"
  exit 0
fi

# Compare modification times
SCHEMA_MOD=$(stat -f%m "$SCHEMA_FILE" 2>/dev/null || stat -c%Y "$SCHEMA_FILE")
EXPOSURE_MOD=$(stat -f%m "$EXPOSURE_FILE" 2>/dev/null || stat -c%Y "$EXPOSURE_FILE")

if [ "$SCHEMA_MOD" -gt "$EXPOSURE_MOD" ]; then
  echo "STALE: Schema changed since last exposure generation"
  echo "Run: ./scripts/expose-schema.sh"
  exit 1
fi

echo "OK: Schema exposure is current"
```

The cost of a stale schema: Claude Code writes a query referencing a renamed column, gets an error (~500 tokens), reads the actual schema to diagnose (~3,000 tokens), rewrites the query (~500 tokens). Total: ~4,000 tokens wasted versus ~200 tokens to regenerate the exposure file.

## Implementation in CLAUDE.md

```markdown
# CLAUDE.md -- Schema Exposure Rules

## Database Access Protocol
1. Read the db-schema skill FIRST for any database-related task
2. Use the cached schema for: writing queries, designing API endpoints, understanding relationships
3. Read prisma/schema.prisma directly only when: creating migrations, modifying models
4. Never run information_schema queries for discovery -- the cached schema has this information
5. Regenerate cache after any migration: `./scripts/expose-schema.sh`
```

### Schema Exposure for Different ORMs

The exposure approach adapts to any ORM or database framework:

**Drizzle ORM:**
```bash
#!/bin/bash
# scripts/drizzle-schema-summary.sh
set -euo pipefail

OUTPUT=".claude/skills/db-schema.md"
mkdir -p .claude/skills

echo "# Database Schema (Drizzle, $(date +%Y-%m-%d))" > "$OUTPUT"
echo "" >> "$OUTPUT"

# Extract table definitions from Drizzle schema files
for file in src/db/schema/*.ts; do
  [ -f "$file" ] || continue
  TABLE=$(basename "$file" .ts)
  echo "## $TABLE" >> "$OUTPUT"
  # Extract column definitions (lines with column helpers)
  grep -E '^\s+(varchar|integer|text|boolean|timestamp|uuid|serial)' "$file" | \
    sed 's/^\s*/- /' >> "$OUTPUT"
  echo "" >> "$OUTPUT"
done

echo "Generated: $(wc -w < "$OUTPUT" | tr -d ' ') words"
```

**TypeORM entities:**
```bash
#!/bin/bash
# scripts/typeorm-schema-summary.sh
set -euo pipefail

OUTPUT=".claude/skills/db-schema.md"
mkdir -p .claude/skills

echo "# Database Schema (TypeORM, $(date +%Y-%m-%d))" > "$OUTPUT"

# Extract @Entity decorated classes and their @Column decorations
for file in src/entities/*.ts; do
  [ -f "$file" ] || continue
  ENTITY=$(grep -m1 '@Entity' "$file" | grep -oP "name:\s*['\"](\w+)" | sed "s/name:\s*['\"]//")
  [ -z "$ENTITY" ] && ENTITY=$(basename "$file" .ts)
  echo "" >> "$OUTPUT"
  echo "## $ENTITY" >> "$OUTPUT"
  grep -E '@Column|@PrimaryColumn|@ManyToOne|@OneToMany' "$file" | \
    head -30 | sed 's/^\s*/- /' >> "$OUTPUT"
done

echo "Generated: $(wc -w < "$OUTPUT" | tr -d ' ') words"
```

Each ORM has different file structures, but the output format is the same: a compact markdown file listing tables and columns. Claude Code reads the summary (~400-800 tokens) instead of parsing ORM decorators and configuration across multiple source files (~3,000-8,000 tokens).

### Measuring the Impact of Schema Exposure

Track the before-and-after difference to quantify savings:

```bash
# Before enabling schema exposure:
# Run 5 database-related sessions, note average token count
# Typical: 80,000-120,000 tokens per session

# After enabling schema exposure:
# Run 5 equivalent sessions, note average token count
# Typical: 50,000-80,000 tokens per session

# Calculate savings:
# Average reduction: 30,000-40,000 tokens per session
# At Sonnet 4.6 rates: $0.09-$0.12 per session
# Monthly (100 sessions): $9.00-$12.00
```

The measurement is straightforward because database discovery tokens are concentrated at the beginning of sessions, making before-and-after comparison reliable.



**Find the right skill →** Browse 155+ skills in our [Skill Finder](/skill-finder/).

## Related Guides

**Configure MCP →** Build your server config with our [MCP Config Generator](/mcp-config/).

**Try it:** Estimate your monthly spend with our [Cost Calculator](/calculator/).

- [Prisma with Claude Code: Reducing Schema Discovery Tokens](/prisma-claude-code-reducing-schema-discovery-tokens/) -- Prisma-specific optimization
- [State Inspection Pattern: Give Agents Full Backend State in One Call](/state-inspection-pattern-agents-full-state-one-call/) -- same principle for runtime state
- [Claude Code Caching Strategies: Don't Re-Discover What You Already Know](/claude-code-caching-strategies-dont-rediscover/) -- broader caching framework
