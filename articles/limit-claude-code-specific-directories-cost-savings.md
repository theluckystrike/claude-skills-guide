---
sitemap: false
layout: default
title: "How to limit Claude Code to specific (2026)"
description: "Limit Claude Code to specific directories for 40-70% token savings using .claudeignore, CLAUDE.md boundaries, and settings.json path restrictions."
permalink: /limit-claude-code-specific-directories-cost-savings/
date: 2026-04-22
last_tested: "2026-04-22"
---

# How to limit Claude Code to specific directories (cost savings)

## The Problem

Claude Code explores the entire project directory by default, reading files across all directories regardless of task scope. On a project with `src/`, `tests/`, `docs/`, `scripts/`, `config/`, and `legacy/` directories, a task targeting `src/api/` may trigger file reads in all six directories. This wastes 20K-80K tokens per task ($0.06-$0.24 Sonnet, $0.30-$1.20 Opus) on irrelevant context.

## Quick Fix (2 Minutes)

```bash
# Create .claudeignore to hard-exclude directories
cat > .claudeignore << 'EOF'
node_modules/
dist/
build/
.git/
legacy/
docs/archive/
scripts/internal/
vendor/
coverage/
EOF
```

This immediately prevents Claude from reading files in excluded directories, reducing the searchable file tree by 50-80%.

## Why This Happens

Claude Code has no built-in concept of "working directory" within a project. When given a task, it searches the entire project tree to build context. The search algorithms (Glob, Grep) default to recursive scanning from the project root.

Token cost per unnecessary directory scan:
- Glob scan of 100-file directory: ~1,000 tokens (file listing)
- Grep across 100 files: ~500-5,000 tokens (depending on matches)
- Reading 5 irrelevant files from a directory: ~12,500 tokens

For a project with 6 directories and a task targeting only 1, five directories are scanned unnecessarily: approximately 30K-60K wasted tokens per task.

## The Full Fix

### Step 1: Diagnose

Identify which directories Claude reads for a scoped task:

```bash
# Give a clearly scoped task
claude "Fix the typo in src/api/routes/users.ts on line 12.
Change 'recieve' to 'receive'."

# If Claude reads files outside src/api/routes/, scoping is needed
/cost
# Anything over 5K tokens for this task indicates unnecessary reads
```

### Step 2: Fix

**Layer 1: .claudeignore (prevents access)**

```bash
# .claudeignore -- directories Claude cannot access
node_modules/
dist/
build/
.git/
coverage/
legacy/
scripts/internal/
*.min.js
*.min.css
*.map
*.lock
```

**Layer 2: CLAUDE.md directory map (guides access)**

```markdown
# CLAUDE.md

## Directory Map
- src/api/ -- REST endpoints (THIS IS THE MAIN CODE)
- src/services/ -- business logic
- src/db/ -- database layer
- __tests__/ -- tests (only when task is about tests)

## Off-Limits Directories
Do NOT read files in these directories unless explicitly asked:
- docs/ -- documentation (not relevant to code tasks)
- scripts/ -- build/deploy scripts (managed separately)
- config/ -- configuration (read only for config tasks)
- legacy/ -- deprecated code (never modify)
- e2e/ -- end-to-end tests (managed by QA)
```

**Layer 3: Settings.json scope restriction**

```json
{
  "permissions": {
    "allow": [
      "Read",
      "Edit",
      "Bash(npm test*)",
      "Bash(npm run build)"
    ],
    "deny": [
      "Bash(rm -rf*)",
      "Bash(cat legacy/*)",
      "Bash(cat scripts/internal/*)"
    ]
  }
}
```

### Step 3: Prevent

Add directory scoping as a permanent CLAUDE.md rule:

```markdown
# CLAUDE.md

## Directory Scoping Protocol
1. Identify the target directory from the task description
2. Work ONLY within that directory and its subdirectories
3. Read parent-level files (CLAUDE.md, package.json) only if needed
4. If the task requires files from another directory, ask first
5. Never scan more than 2 directory levels outside the target
```

## Cost Recovery

For sessions where Claude has already read across unnecessary directories:

```bash
/compact
# Then redirect:
"For the rest of this session, only work in src/api/. Do not read files elsewhere."
```

## Prevention Rules for CLAUDE.md

```markdown
## Directory Boundaries
### Always in scope
- src/ (main source code)
- __tests__/ (when task involves tests)

### Only when relevant
- prisma/ (database tasks only)
- config/ (configuration tasks only)

### Never in scope (use .claudeignore)
- node_modules/, dist/, build/, .git/, coverage/
- legacy/ (deprecated, do not touch)
- docs/archive/ (outdated documentation)

### Rule
Before reading any file, check: is this file in the target directory?
If not, explain why it is needed. Maximum 3 out-of-scope file reads per task.
```

Implementing full directory limiting typically saves 40-70% of exploration tokens. For a developer running 15 tasks/day on Sonnet: **$39-$92/month saved.** On Opus: **$198-$462/month saved.**

## Directory Scoping by Project Type

### React/Next.js Frontend

```bash
# .claudeignore
node_modules/
.next/
out/
public/images/   # Static assets, not code
coverage/
__snapshots__/
```

```markdown
# CLAUDE.md
## Focus Directories
- src/app/ -- Next.js routes (primary)
- src/components/ -- React components
- src/hooks/ -- Custom hooks
- src/lib/ -- Utilities

## Avoid Unless Asked
- public/ -- static assets
- styles/globals.css -- global styles (rarely changed)
```

### Express/Fastify Backend

```bash
# .claudeignore
node_modules/
dist/
coverage/
prisma/migrations/**/migration_lock.toml
logs/
uploads/
```

```markdown
# CLAUDE.md
## Focus Directories
- src/routes/ -- API endpoints (primary)
- src/services/ -- Business logic
- src/repositories/ -- Database queries
- src/middleware/ -- Express middleware

## Avoid Unless Asked
- prisma/migrations/ -- auto-generated, never edit
- scripts/ -- DevOps scripts
- seeds/ -- Test data
```

### Python/Django

```bash
# .claudeignore
__pycache__/
.venv/
*.pyc
.mypy_cache/
htmlcov/
static/collected/
media/
```

```markdown
# CLAUDE.md
## Focus Directories
- app/views/ -- Request handlers
- app/models/ -- Database models
- app/serializers/ -- API serializers
- app/tests/ -- Only when task is about tests

## Avoid Unless Asked
- migrations/ -- auto-generated
- templates/ -- HTML templates (separate concern)
- static/ -- frontend assets
```

## Measuring Directory Scoping Effectiveness

Before and after implementing directory scoping:

```bash
# Before: track a typical session
claude "Add input validation to the user create endpoint"
/cost
# Record: 85K input tokens

# After: same type of task with scoping
claude "Add input validation to the user create endpoint"
/cost
# Record: 32K input tokens

# Savings: 62% (53K tokens = $0.16 Sonnet per task)
# Monthly savings at 15 tasks/day: $0.16 x 15 x 22 = $52.80
```

If savings are less than 40%, the scoping rules are not restrictive enough. If Claude is hitting scope limitations and asking for permission to read files, the rules may be too restrictive.

## Dynamic Scoping with Prompt Prefixes

For projects where different tasks target different directories, use prompt prefixes to set scope per task:

```bash
# Frontend task
claude "[SCOPE: src/components/ src/hooks/] Add a toast notification component"

# Backend task
claude "[SCOPE: src/routes/ src/services/] Add rate limiting to the auth endpoints"

# Full-stack task
claude "[SCOPE: src/] Update the user profile page and its API endpoint"
```

Add to CLAUDE.md:

```markdown
## Scope Prefixes
When a prompt starts with [SCOPE: dirs...], only read files in those directories.
If no scope prefix, default to the full src/ directory.
```

## Verifying Directory Limits Are Working

After implementing directory limiting, verify effectiveness:

```bash
# Test with a scoped task
claude "Add a comment to the top of src/utils/format.ts"

# Check /cost -- should be under 5K tokens for this trivial task
# If over 10K, Claude is still reading outside the target directory

# Check what files were read by reviewing the session output
# Look for Read or Grep tool calls targeting directories outside src/utils/
```

If directory limits are not being respected, the likely cause is that the task description is too vague. Adding explicit file paths to prompts reinforces directory scoping. For persistent issues, use `.claudeignore` to enforce hard boundaries on the most expensive non-essential directories. The combination of soft limits (CLAUDE.md rules) and hard limits (.claudeignore) provides defense in depth -- soft limits guide normal behavior while hard limits prevent worst-case exploration.



**Which model? →** Take the 5-question quiz in our [Model Selector](/model-selector/).

## Related Guides

**Configure permissions →** Build your settings with our [Permission Configurator](/permissions/).

**Try it:** Estimate your monthly spend with our [Cost Calculator](/calculator/).

- [Claude Code reading too many files](/claude-code-reading-too-many-files-scope-context/) -- complementary file-level scoping
- [Claude Code for Monorepos](/claude-code-monorepos-scoping-context-reduce-costs/) -- monorepo-specific directory scoping
- [Cost Optimization Hub](/cost-optimization/) -- all cost optimization guides
