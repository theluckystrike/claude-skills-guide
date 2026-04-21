---
layout: post
title: "Claude Code Context Window Management Guide 2026"
description: "Manage Claude Code's context window effectively: monitor usage, compress context, use .claudeignore, and optimize for long coding sessions."
permalink: /claude-code-context-window-management-2026/
date: 2026-04-21
last_tested: "2026-04-21"
render_with_liquid: false
---

## The Workflow

Monitor and optimize Claude Code's context window usage to maintain quality responses during long coding sessions. This covers context monitoring, strategic .claudeignore usage, session splitting, and compression techniques that keep Claude focused on relevant code.

Expected time: 15 minutes for initial setup
Prerequisites: Claude Code installed, a project with multiple files

## Setup

### 1. Check Current Context Usage

```bash
claude --print "/context"
# Expected output:
# Context usage: 45,000 / 200,000 tokens (22%)
# Files in context: 12
# Conversation turns: 8
```

The `/context` command shows how much of the available window is consumed.

### 2. Create a .claudeignore for Large Projects

```bash
cat > .claudeignore << 'EOF'
# Generated files (large, not useful for context)
dist/
build/
.next/
out/
coverage/
*.min.js
*.min.css
*.map

# Dependencies (never need to read these)
node_modules/
vendor/
venv/
.venv/
__pycache__/

# Large binary/data files
*.sqlite
*.db
*.png
*.jpg
*.gif
*.svg
*.woff2
*.ttf
*.pdf

# Lock files (huge, rarely relevant)
package-lock.json
yarn.lock
pnpm-lock.yaml
Gemfile.lock
poetry.lock
Cargo.lock

# Test fixtures and snapshots (large, low signal)
**/__snapshots__/
**/fixtures/*.json
**/test-data/

# Git history
.git/
EOF
```

This prevents Claude from reading files that waste context tokens without providing useful information.

### 3. Verify Ignore Patterns Work

```bash
claude --print "How many files can you see in this project?"
# Then compare with:
find . -type f | wc -l
# The Claude count should be significantly lower
```

## Usage Example

Monitor and manage context throughout a long development session:

```bash
# Start a session with explicit scope
claude "I'm working on the authentication module only. \
Focus on src/auth/ and src/middleware/auth.ts. \
Ignore all other directories unless I explicitly ask."
```

When context gets heavy mid-session, use compression techniques:

```bash
# Ask Claude to summarize what it knows (resets effective context)
claude --print "/compact"
```

The `/compact` command triggers Claude to summarize the conversation history into a shorter representation, freeing context space for new information.

For very large codebases, create scoped CLAUDE.md files per module:

```markdown
# src/auth/CLAUDE.md

## Module Scope
This is the authentication module. When working here:
- Only read files in src/auth/, src/middleware/auth*, and src/types/auth.ts
- The database schema for auth tables is in prisma/schema.prisma (users, sessions, tokens tables only)
- Tests are in tests/auth/
- Do NOT read files from other modules unless explicitly asked

## Key Files (read these first)
1. src/auth/service.ts — main auth logic
2. src/auth/strategies/ — OAuth providers
3. src/middleware/auth.ts — request authentication
4. src/types/auth.ts — shared types
```

Session splitting strategy for large tasks:

```bash
#!/bin/bash
# split-session.sh — Break large tasks into context-efficient sessions

TASK_FILE="$1"
OUTPUT_DIR="./session-outputs"
mkdir -p "$OUTPUT_DIR"

# Step 1: Planning session (small context, produces a plan)
PLAN=$(claude --print "Read $TASK_FILE and create a numbered list of \
independent subtasks. Each subtask should be completable without \
knowledge of other subtasks. Output only the list.")

echo "$PLAN" > "$OUTPUT_DIR/plan.md"

# Step 2: Execute each subtask in a fresh session
STEP=0
while IFS= read -r task; do
  [ -z "$task" ] && continue
  STEP=$((STEP + 1))
  echo "=== Executing step $STEP ==="

  # Fresh session per subtask = full context available
  claude --print "Complete this specific subtask: $task
Context: This is step $STEP of a larger task. Focus only on this step.
Do not refactor unrelated code." > "$OUTPUT_DIR/step-${STEP}-output.md"

done <<< "$PLAN"

echo "=== All $STEP steps complete ==="
```

Context budget monitoring script:

```bash
cat > ~/bin/claude-context-check.sh << 'SCRIPT'
#!/bin/bash
# Estimate context cost of files Claude will read

PROJECT_DIR="${1:-.}"
TOTAL_TOKENS=0
MAX_CONTEXT=200000

echo "=== Context Budget Estimate ==="
echo "Project: $PROJECT_DIR"
echo ""

# Count tokens (rough estimate: 1 token ≈ 4 characters)
while IFS= read -r -d '' file; do
  CHARS=$(wc -c < "$file")
  TOKENS=$((CHARS / 4))
  TOTAL_TOKENS=$((TOTAL_TOKENS + TOKENS))

  if [ $TOKENS -gt 5000 ]; then
    echo "  LARGE: $(basename "$file") (~${TOKENS} tokens)"
  fi
done < <(find "$PROJECT_DIR" -type f \
  -not -path "*/node_modules/*" \
  -not -path "*/.git/*" \
  -not -path "*/dist/*" \
  -not -path "*/*.lock" \
  -name "*.ts" -o -name "*.js" -o -name "*.py" -o -name "*.rs" \
  -print0 2>/dev/null)

PERCENT=$((TOTAL_TOKENS * 100 / MAX_CONTEXT))
echo ""
echo "Estimated total: ~${TOTAL_TOKENS} tokens (${PERCENT}% of context)"

if [ $PERCENT -gt 60 ]; then
  echo "WARNING: Project may exceed context. Use .claudeignore or scope sessions."
fi
SCRIPT
chmod +x ~/bin/claude-context-check.sh
```

Run it:

```bash
~/bin/claude-context-check.sh ./src
# Expected output:
# === Context Budget Estimate ===
# Project: ./src
#
#   LARGE: schema.prisma (~8200 tokens)
#   LARGE: api-client.ts (~6100 tokens)
#
# Estimated total: ~45000 tokens (22% of context)
```

## Common Issues

- **Claude forgets earlier conversation:** You have exceeded effective context. Use `/compact` to compress history, or start a new session with a summary of what was accomplished.
- **Claude reads irrelevant files:** Add them to .claudeignore or prefix your prompt with scope: "Only look at files in src/payments/".
- **Responses degrade after 30+ turns:** This is context saturation. Split into a new session. Pass only the essential state: "Continue from where we left off. Current state: [2-3 sentence summary]."

## Why This Matters

Context window mismanagement causes Claude to lose track of requirements mid-task, leading to incorrect code and wasted time. Proper context hygiene keeps response quality consistent across sessions of any length.

## Related Guides

- [Context Window Size Drives Claude API Bills](/context-window-size-drives-claude-api-bills/)
- [Reduce Claude API Token Usage 50 Percent](/reduce-claude-api-token-usage-50-percent/)
- [Claude Code Stuck in Loop Repeating Same Output Fix](/claude-code-stuck-in-loop-repeating-same-output-fix/)
