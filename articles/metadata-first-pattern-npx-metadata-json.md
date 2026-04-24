---
title: "Metadata-First Pattern"
description: "The metadata-first pattern uses pre-computed project metadata to eliminate 3,000-15,000 discovery tokens per Claude Code session through structured lookups."
permalink: /metadata-first-pattern-npx-metadata-json/
date: 2026-04-22
last_tested: "2026-04-22"
render_with_liquid: false
---

# The Metadata-First Pattern: npx metadata --json Before Any Operation

## The Pattern

Metadata-first is an architecture pattern where every agent operation begins with a structured metadata lookup instead of an exploratory discovery phase. The agent reads a pre-computed, compact metadata file (or runs a metadata command) that provides enough context to skip the 3-8 tool calls typically needed to understand the project, module, or task context.

## Why It Matters for Token Cost

Discovery is the most expensive phase of any Claude Code session. Before doing actual work, the agent must understand the project structure, conventions, dependencies, and current state. Without metadata, this understanding comes from reading files, running commands, and grepping -- each costing 245-2,000+ tokens per call.

A typical discovery phase consumes 5,000-15,000 tokens across 3-8 tool calls. A metadata lookup delivers the same understanding for 200-500 tokens in a single read. Over a month of daily sessions, this gap represents $15-$75 at Opus 4.6 rates.

## The Anti-Pattern (What NOT to Do)

```bash
# Anti-pattern: Agent discovers project context through exploration
# Tool call 1: ls (245 overhead + 300 content = 545 tokens)
ls -la

# Tool call 2: Read package.json (150 overhead + 900 content = 1,050 tokens)
# Discovers dependencies, scripts, project name

# Tool call 3: Check directory structure (245 + 400 = 645 tokens)
find src -type f -name "*.ts" | head -20

# Tool call 4: Read tsconfig (150 + 500 = 650 tokens)
# Discovers TypeScript configuration

# Tool call 5: Check test setup (245 + 300 = 545 tokens)
grep -r "describe\|it\(" --include="*.test.ts" -l | head -10

# Total discovery cost: ~3,435 tokens overhead + ~2,400 content = 5,835 tokens
# Time: 5 tool calls, 5 round-trips, 15-30 seconds
```

## The Pattern in Action

### Step 1: Create a Project Metadata File

Build a compact, structured metadata file that answers the questions agents always ask.

```json
// .claude/metadata.json (~300 tokens)
{
  "project": "invoice-service",
  "stack": {
    "language": "TypeScript 5.4",
    "runtime": "Node 22",
    "framework": "Fastify 5.0",
    "orm": "Prisma 6.2",
    "test": "Vitest",
    "package_manager": "pnpm"
  },
  "commands": {
    "test": "pnpm test",
    "lint": "pnpm lint",
    "build": "pnpm build",
    "dev": "pnpm dev",
    "migrate": "pnpm prisma migrate dev"
  },
  "directories": {
    "routes": "src/routes/",
    "services": "src/services/",
    "models": "prisma/schema.prisma",
    "tests": "tests/",
    "generated": "src/generated/ (DO NOT MODIFY)"
  },
  "conventions": {
    "error_handling": "Result<T> return types, never throw",
    "validation": "Zod schemas in src/schemas/",
    "naming": "camelCase functions, PascalCase types, snake_case db columns"
  }
}
```

### Step 2: Reference Metadata in CLAUDE.md

Point the agent to the metadata file as the first step for any task.

```yaml
# CLAUDE.md
## First Step for Every Task
Read .claude/metadata.json before making any other tool calls.
This file contains project structure, commands, and conventions.
Do not explore the filesystem to discover information that is in metadata.json.
```

### Step 3: Automate Metadata Generation

For larger projects, generate the metadata file from actual project state to keep it current.

```bash
#!/bin/bash
# scripts/generate-metadata.sh
# Run after dependency changes or structure changes

set -euo pipefail

METADATA_FILE=".claude/metadata.json"
MAX_DIRS=20

# Extract key info from package.json
PROJECT_NAME=$(jq -r '.name' package.json)
NODE_VERSION=$(cat .nvmrc 2>/dev/null || echo "not specified")

# Build directory map (bounded to MAX_DIRS entries)
DIRS=$(find src -maxdepth 2 -type d | head -"$MAX_DIRS" | jq -R -s 'split("\n") | map(select(. != ""))')

# Generate metadata
jq -n \
  --arg name "$PROJECT_NAME" \
  --arg node "$NODE_VERSION" \
  --argjson dirs "$DIRS" \
  '{
    project: $name,
    node: $node,
    directories: $dirs,
    generated_at: (now | strftime("%Y-%m-%dT%H:%M:%SZ"))
  }' > "$METADATA_FILE"

echo "Metadata written to $METADATA_FILE ($(wc -c < "$METADATA_FILE") bytes)"
```

## Before and After

| Metric | Before (Discovery) | After (Metadata-First) | Savings |
|--------|--------------------|-----------------------|---------|
| Tool calls for orientation | 5-8 | 1 (Read metadata) | 80-88% |
| Tokens for orientation | 5,000-15,000 | 200-500 | 96-97% |
| Time for orientation | 15-30 seconds | 2-3 seconds | 85-90% |
| Monthly cost (Opus, daily use) | $1.50-$4.50 | $0.06-$0.15 | $1.44-$4.35 saved |
| Compounding (20-turn sessions) | 100K-300K cumulative | 4K-10K cumulative | 96-97% |

## When to Use This Pattern

- Projects where Claude Code is used daily by one or more developers
- Codebases with more than 20 files or 3 directories
- Team environments where multiple developers use Claude Code on the same project
- Any project where the first 3-5 tool calls of a session are always the same exploration commands

## When NOT to Use This Pattern

- Throwaway scripts or single-file projects where the entire context is already minimal
- Projects that change structure so frequently that metadata would be stale within hours (in this case, auto-generate metadata as a pre-commit hook)

## Implementation in CLAUDE.md

```yaml
# CLAUDE.md -- metadata-first enforcement
## Context Loading Protocol
1. Before any task, read .claude/metadata.json (if it exists)
2. Do not run ls, find, or directory exploration commands for information available in metadata
3. If metadata.json is missing or stale, report to the user and suggest running scripts/generate-metadata.sh
4. For module-specific work, also check for {module}/CLAUDE.md before exploring

## Metadata Maintenance
- Run `./scripts/generate-metadata.sh` after adding new dependencies or directories
- The metadata file should be under 500 tokens
- Include metadata.json in version control so all team members benefit
```

## Related Guides

- [Structured Metadata vs Discovery Queries](/structured-metadata-vs-discovery-queries-token-gap/) -- the theory behind metadata-first approaches
- [CLAUDE.md as Cost Control](/claude-md-cost-control-rules-prevent-token-waste/) -- using CLAUDE.md to enforce metadata-first behavior
- [Agent-First Architecture](/agent-first-architecture-backends-dont-waste-tokens/) -- the broader pattern of designing for agent consumption
