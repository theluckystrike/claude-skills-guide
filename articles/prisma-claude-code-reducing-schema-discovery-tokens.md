---
layout: default
title: "Prisma with Claude Code (2026)"
description: "Prisma schema files cost Claude Code 3,000-15,000 tokens to read and parse. Pre-computed schema summaries cut discovery cost by 70-85% per session."
permalink: /prisma-claude-code-reducing-schema-discovery-tokens/
date: 2026-04-22
last_tested: "2026-04-22"
---

# Prisma with Claude Code: Reducing Schema Discovery Tokens

## What It Does

Prisma schema files (`schema.prisma`) are the source of truth for database structure, but they grow large in production projects -- 200-800 lines for 20-60 models. When Claude Code reads a full schema to understand database structure, it consumes 3,000-15,000 tokens. A pre-computed schema summary reduces this to 500-1,500 tokens, saving 70-85% on every session that touches the database. At Sonnet 4.6 rates ($3/$15 per MTok), a team of 5 developers saves $3-$12 per month from this single optimization.

## Installation / Setup

No special installation required. This guide uses standard Prisma CLI tools and Claude Code skills.

Confirm Prisma is available:

```bash
npx prisma --version
# Expected: prisma 6.x.x or similar
```

## Configuration for Cost Optimization

### Generate a Schema Summary Skill

Create a script that extracts model names, key fields, and relationships into a compact summary:

```bash
#!/bin/bash
# scripts/generate-schema-summary.sh
# Extracts a compact schema summary for Claude Code
set -euo pipefail

SCHEMA_FILE="prisma/schema.prisma"
OUTPUT_FILE=".claude/skills/database-schema.md"

if [ ! -f "$SCHEMA_FILE" ]; then
  echo "ERROR: $SCHEMA_FILE not found"
  exit 1
fi

mkdir -p .claude/skills

cat > "$OUTPUT_FILE" << 'HEADER'
# Database Schema Summary

## Models and Key Fields
HEADER

# Extract model definitions with their fields (bounded: max 100 models)
MODEL_COUNT=0
MAX_MODELS=100

grep -n "^model " "$SCHEMA_FILE" | head -"$MAX_MODELS" | while IFS= read -r line; do
  MODEL_NAME=$(echo "$line" | sed 's/.*model \([A-Za-z]*\).*/\1/')
  LINE_NUM=$(echo "$line" | cut -d: -f1)

  echo "" >> "$OUTPUT_FILE"
  echo "### $MODEL_NAME" >> "$OUTPUT_FILE"

  # Extract fields until closing brace (bounded: max 50 fields per model)
  sed -n "$((LINE_NUM+1)),/^}/p" "$SCHEMA_FILE" | head -50 | \
    grep -E '^\s+\w+\s+' | \
    grep -v '^\s*//' | \
    sed 's/^\s*/- /' >> "$OUTPUT_FILE"

  MODEL_COUNT=$((MODEL_COUNT + 1))
done

WORD_COUNT=$(wc -w < "$OUTPUT_FILE" | tr -d ' ')
echo "Generated schema summary: ${WORD_COUNT} words (~$((WORD_COUNT * 100 / 75)) tokens)"
```

```bash
chmod +x scripts/generate-schema-summary.sh
./scripts/generate-schema-summary.sh
```

### Example Output: Schema Summary Skill

For a project with 25 models, the generated summary looks like:

```markdown
# Database Schema Summary

## Models and Key Fields

### User
- id            String   @id @default(uuid())
- email         String   @unique
- name          String?
- role          Role     @default(USER)
- createdAt     DateTime @default(now())
- orders        Order[]
- subscriptions Subscription[]

### Order
- id            String   @id @default(uuid())
- userId        String
- user          User     @relation(fields: [userId], references: [id])
- status        OrderStatus @default(PENDING)
- totalCents    Int
- createdAt     DateTime @default(now())
- items         OrderItem[]

### Subscription
- id            String   @id @default(uuid())
- userId        String
- plan          Plan     @default(FREE)
- status        SubStatus @default(ACTIVE)
- stripeId      String?  @unique
- expiresAt     DateTime?
```

This summary (~600 tokens for 25 models) versus the full schema (~8,000 tokens) gives Claude Code everything needed for most tasks: model names, field types, relationships, and constraints.

## Usage Examples

### Basic Usage

Reference the schema summary in CLAUDE.md:

```markdown
# CLAUDE.md

## Database
- Schema summary: see database-schema skill
- Full schema: prisma/schema.prisma (read only when modifying schema)
- Migrations: `npx prisma migrate dev --name description`
```

Claude Code reads the 600-token summary instead of the 8,000-token full schema for query writing, service implementation, and API development. It reads the full schema only when creating migrations or modifying model definitions.

### Advanced: Auto-Regenerate on Schema Changes

Add a git hook to keep the summary current:

```bash
#!/bin/bash
# .git/hooks/post-commit
# Regenerate schema summary if schema changed

CHANGED_FILES=$(git diff-tree --no-commit-id --name-only -r HEAD)

if echo "$CHANGED_FILES" | grep -q "prisma/schema.prisma"; then
  echo "Schema changed -- regenerating summary..."
  ./scripts/generate-schema-summary.sh
  git add .claude/skills/database-schema.md
  # Note: does not auto-commit; developer reviews at next commit
fi
```

### Advanced: Query-Specific Schema Extraction

For targeted database work, create focused skill files:

```markdown
# .claude/skills/user-schema.md
# Only loaded when working on user-related features (~200 tokens)

## User Domain Models

### User: id (uuid), email (unique), name, role (USER|ADMIN), createdAt
### UserProfile: id, userId -> User, bio, avatarUrl, location
### UserSession: id, userId -> User, token (unique), expiresAt, ipAddress

## Key Queries
- Find user by email: `prisma.user.findUnique({ where: { email } })`
- Active sessions: `prisma.userSession.findMany({ where: { expiresAt: { gt: new Date() } } })`
- User with profile: `prisma.user.findUnique({ where: { id }, include: { profile: true } })`
```

This 200-token focused skill replaces reading 3 model definitions from the full schema (~2,400 tokens) when working on user features.

## Token Usage Measurements

| Approach | Tokens per Schema Read | Sessions/Month | Monthly Cost (Sonnet 4.6) |
|----------|----------------------|----------------|--------------------------|
| Full schema (25 models) | ~8,000 | 100 | $2.40 |
| Summary skill | ~600 | 100 | $0.18 |
| Focused domain skill | ~200 | 100 | $0.06 |

**Savings: $1.80-$2.34 per developer per month** on schema-related reads alone.

For a team of 5 developers, each touching the database 3 times per day: **$9-$12/month in schema discovery savings**.

### Advanced: Relationship Map for Complex Schemas

For projects with many inter-model relationships, add a visual relationship map to the skill:

```markdown
# .claude/skills/schema-relationships.md

## Model Relationships

### User-centric
- User 1--* Order (userId)
- User 1--* Subscription (userId)
- User 1--1 UserProfile (userId)
- User 1--* Session (userId)
- User 1--* ApiKey (userId)

### Order-centric
- Order 1--* OrderItem (orderId)
- Order *--1 User (userId)
- OrderItem *--1 Product (productId)

### Team-centric
- Team 1--* TeamMember (teamId)
- TeamMember *--1 User (userId)
- Team 1--* Webhook (teamId)

## Common Join Patterns
- User + active subscriptions: `include: { subscriptions: { where: { status: "ACTIVE" } } }`
- Order + items + products: `include: { items: { include: { product: true } } }`
- Team + members + user details: `include: { members: { include: { user: true } } }`
```

This relationship map (~250 tokens) eliminates the need for Claude Code to trace foreign keys across the full schema to understand data relationships. Tracing relationships manually requires reading multiple model definitions: 3-5 file reads at 500-1,500 tokens each = 1,500-7,500 tokens.

**Savings: 1,250-7,250 tokens per relationship query**

## Comparison with Alternatives

| Approach | Token Cost | Accuracy | Maintenance |
|----------|-----------|----------|-------------|
| Read full schema.prisma | 3,000-15,000 | 100% | Zero |
| Generated summary skill | 500-1,500 | 95% (may lag) | Auto-gen on change |
| Manual CLAUDE.md schema | 300-800 | Varies | Manual updates |
| Database MCP introspection | 1,200+ per query | 100% (live) | MCP setup |

The generated summary is the best balance: high accuracy (auto-generated from source), low tokens, and minimal maintenance (git hook regeneration).

### Integration with Claude Code Workflows

Add schema-aware prompts to common workflows:

```bash
# Database migration workflow with schema context
claude -p "Create a Prisma migration to add a 'phone' column (optional string)
to the users table. Check the database-schema skill for current schema.
Then run npx prisma migrate dev --name add-user-phone."

# Query optimization with schema context
claude -p "The query for listing orders with user details is slow.
Check the database-schema skill for table structure and indexes.
Suggest index additions and query optimizations."
```

By referencing the schema skill in the prompt, Claude Code reads the compact summary first (~400 tokens) instead of the full schema (~5,000 tokens), then only reads the full schema if it needs to create a migration.

### Handling Multi-Schema Projects

For projects with multiple Prisma schema files (multi-database setups):

```markdown
# .claude/skills/multi-schema.md

## Database Schemas

### Primary (PostgreSQL) -- prisma/schema.prisma
- Core application data: users, orders, subscriptions
- 25 models, ~350 columns total
- See database-schema skill for full summary

### Analytics (ClickHouse) -- prisma/analytics.prisma
- Event tracking: page_views, clicks, conversions
- 8 models, append-only tables
- Connection: ANALYTICS_DATABASE_URL

### Cache metadata (SQLite) -- prisma/cache.prisma
- Cache invalidation tracking
- 3 models: cache_entries, cache_tags, cache_dependencies
- File: .data/cache.db
```

This multi-schema index (~200 tokens) prevents Claude Code from reading all three schema files when only one is relevant to the current task. Without it, Claude Code might read all schemas (~15,000 tokens combined) to find the right one.

## Troubleshooting

**Summary out of date**: Run `./scripts/generate-schema-summary.sh` manually. Consider adding it to the project's build script or CI pipeline.

**Script fails on complex schemas**: Schemas with composite types, views, or multi-file setups may need script adjustments. Extend the grep patterns to handle Prisma's extended syntax.

**Claude reads full schema anyway**: Add an explicit CLAUDE.md rule: "For database work, read .claude/skills/database-schema.md first. Only read prisma/schema.prisma when creating or modifying migrations."

**Large schema files cause slow generation**: For schemas with 50+ models, the generation script may take several seconds. Add a progress indicator and consider splitting the summary into domain-specific files (auth, billing, inventory) rather than one monolithic summary. Domain-specific summaries at ~200 tokens each are more token-efficient than a single 2,000-token summary when most tasks only touch one domain. The domain split also enables progressive disclosure: Claude Code loads only the auth schema when working on authentication features, keeping context lean and focused.

## Related Guides

**Try it:** Estimate your monthly spend with our [Cost Calculator](/calculator/).

- [Database Schema Exposure: Complete State vs Discovery Queries](/database-schema-exposure-complete-state-vs-discovery/) -- broader schema optimization patterns
- [Claude Code Skills Guide](/skills/) -- creating and managing skill files
- [Cost Optimization Hub](/cost-optimization/) -- all cost reduction strategies
