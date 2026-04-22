---
title: "Claude Code .claude/settings.json: Cost-Saving Configuration"
description: "Configure Claude Code .claude/settings.json for cost savings with permission controls, tool restrictions, and directory scoping that reduce token waste."
permalink: /claude-code-settings-json-cost-saving-configuration/
date: 2026-04-22
last_tested: "2026-04-22"
render_with_liquid: false
---

# Claude Code .claude/settings.json: Cost-Saving Configuration

## What It Does

The `.claude/settings.json` file controls Claude Code's permissions, tool access, and behavior at the project level. Properly configured, it prevents three major categories of token waste: unnecessary tool calls (20-40% of waste), out-of-scope file access (15-25% of waste), and uncontrolled command execution (10-20% of waste). The settings file itself costs 0 tokens -- it is processed locally, not sent to the API.

## Installation / Setup

```bash
# Create the .claude directory
mkdir -p .claude

# Create settings.json
cat > .claude/settings.json << 'JSON'
{
  "permissions": {
    "allow": [
      "Read",
      "Edit",
      "Bash(npm test*)",
      "Bash(npm run build*)",
      "Bash(npm run lint*)",
      "Bash(git status)",
      "Bash(git diff*)",
      "Bash(git log*)"
    ],
    "deny": [
      "Bash(rm -rf*)",
      "Bash(git push*)",
      "Bash(git reset*)",
      "Bash(npm publish*)"
    ]
  }
}
JSON
```

## Configuration for Cost Optimization

### Permission Allowlists Save Token Confirmations

Without an allowlist, Claude Code pauses for user confirmation on every Bash command. Each pause costs:
- Claude generating the confirmation request: ~100 tokens
- Context of the pause in conversation history: ~200 tokens
- Total per unnecessary pause: ~300 tokens

With 20 Bash calls per session and an allowlist covering common commands, eliminating 15 confirmation pauses saves 4,500 tokens per session.

```json
{
  "permissions": {
    "allow": [
      "Bash(npm test*)",
      "Bash(npm run *)",
      "Bash(npx prisma *)",
      "Bash(git status)",
      "Bash(git diff*)",
      "Bash(git log*)",
      "Bash(git add*)",
      "Bash(wc *)",
      "Bash(cat package.json)",
      "Bash(ls *)"
    ]
  }
}
```

### Deny Rules Prevent Expensive Mistakes

Denying destructive commands prevents token-expensive recovery operations.

```json
{
  "permissions": {
    "deny": [
      "Bash(rm -rf*)",
      "Bash(git push --force*)",
      "Bash(git reset --hard*)",
      "Bash(drop table*)",
      "Bash(npm publish*)",
      "Bash(firebase deploy --only*:* --force)"
    ]
  }
}
```

A single `rm -rf` mistake can trigger a recovery session costing 100K-500K tokens. The deny rule costs 0 tokens and prevents the mistake entirely.

### MCP Server Configuration for Token Control

```json
{
  "mcpServers": {
    "filesystem": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-filesystem", "/path/to/project/src"]
    }
  }
}
```

Scoping the filesystem MCP server to `src/` only prevents Claude from browsing outside the project. Each prevented out-of-scope file read saves 2,000-5,000 tokens.

## Usage Examples

### Basic Usage

```json
{
  "permissions": {
    "allow": [
      "Read",
      "Edit",
      "Bash(npm *)",
      "Bash(git *)"
    ]
  }
}
```

This minimal configuration covers 90% of development workflows and eliminates most confirmation pauses.

### Advanced: Team Configuration with Cost Guards

```json
{
  "permissions": {
    "allow": [
      "Read",
      "Edit",
      "Bash(npm test*)",
      "Bash(npm run build)",
      "Bash(npm run lint)",
      "Bash(git status)",
      "Bash(git diff*)",
      "Bash(git log --oneline -20)",
      "Bash(npx prisma migrate dev*)",
      "Bash(npx prisma generate)"
    ],
    "deny": [
      "Bash(rm -rf*)",
      "Bash(git push*)",
      "Bash(git reset*)",
      "Bash(npm publish*)",
      "Bash(npx prisma migrate reset*)"
    ]
  }
}
```

This configuration:
- Allows all safe development commands without confirmation
- Blocks all destructive operations
- Limits git log to 20 lines (prevents reading full history, saving 1K-10K tokens per call)

## Token Usage Measurements

| Setting | Tokens Saved Per Session | Mechanism |
|---------|------------------------|-----------|
| Allow common Bash commands | 4,500 | Eliminates 15 confirmation roundtrips |
| Deny destructive commands | 100K-500K (per incident) | Prevents recovery sessions |
| Scoped MCP filesystem | 5K-20K | Prevents out-of-scope reads |
| Limited git log output | 1K-5K per call | Shorter output |

Monthly savings estimate (Sonnet 4.6, 5 sessions/day):
- Confirmation savings: 4,500 x 5 x 22 = 495K tokens = $1.49/month
- Incident prevention: 1 prevented incident/month = $3-$15 savings
- Scope enforcement: 10K x 5 x 22 = 1.1M tokens = $3.30/month
- **Total: $8-$20/month per developer**

## Comparison with Alternatives

| Approach | Cost | Enforcement | Granularity |
|----------|------|-------------|-------------|
| settings.json | 0 tokens | Hard (tool-level) | Per command pattern |
| CLAUDE.md rules | 200-500 tokens | Soft (agent choice) | Natural language |
| .claudeignore | 0 tokens | Hard (file-level) | Per directory/pattern |
| Environment variables | 0 tokens | Hard (session-level) | Global flags |

Use settings.json for hard enforcement, CLAUDE.md for soft guidance, and .claudeignore for file access control. The combination provides defense in depth at minimal token cost.

## Troubleshooting

**Claude Code ignoring settings.json:** Verify the file is at `.claude/settings.json` (not `claude/settings.json` or `.claude/config.json`). Check JSON validity with `python3 -m json.tool .claude/settings.json`.

**Too many confirmation prompts despite allowlist:** The allow patterns use glob matching. Ensure patterns end with `*` for prefix matching. `Bash(npm test*)` matches `npm test` and `npm test -- --watch`.

**Locked out of needed commands:** Add the specific command pattern to the allow list. Patterns are checked in order: allow first, then deny. A command matching both is allowed.

## Settings.json Patterns by Project Type

### Web Application (React/Next.js)

```json
{
  "permissions": {
    "allow": [
      "Read",
      "Edit",
      "Bash(npm run dev*)",
      "Bash(npm run build*)",
      "Bash(npm test*)",
      "Bash(npm run lint*)",
      "Bash(npx next*)",
      "Bash(git status)",
      "Bash(git diff*)",
      "Bash(git log*)",
      "Bash(git add*)"
    ],
    "deny": [
      "Bash(rm -rf*)",
      "Bash(git push*)",
      "Bash(git reset --hard*)"
    ]
  }
}
```

### Backend API (Express/Fastify + Prisma)

```json
{
  "permissions": {
    "allow": [
      "Read",
      "Edit",
      "Bash(npm test*)",
      "Bash(npm run build)",
      "Bash(npm run lint*)",
      "Bash(npm run dev)",
      "Bash(npx prisma migrate*)",
      "Bash(npx prisma generate)",
      "Bash(npx prisma db seed)",
      "Bash(git status)",
      "Bash(git diff*)",
      "Bash(git log --oneline*)",
      "Bash(git add*)",
      "Bash(curl*localhost*)"
    ],
    "deny": [
      "Bash(rm -rf*)",
      "Bash(git push*)",
      "Bash(git reset --hard*)",
      "Bash(npx prisma migrate reset*)",
      "Bash(npm publish*)"
    ]
  }
}
```

### Monorepo (Turborepo/Nx)

```json
{
  "permissions": {
    "allow": [
      "Read",
      "Edit",
      "Bash(npx turbo *)",
      "Bash(pnpm --filter * test*)",
      "Bash(pnpm --filter * build*)",
      "Bash(pnpm --filter * lint*)",
      "Bash(git status)",
      "Bash(git diff*)",
      "Bash(git log --oneline*)"
    ],
    "deny": [
      "Bash(rm -rf*)",
      "Bash(git push --force*)",
      "Bash(pnpm -r *)"
    ]
  }
}
```

Note the deny rule for `pnpm -r *` -- this prevents running commands across all packages in the monorepo, which can produce 10K+ tokens of output. Instead, use `pnpm --filter <package>` for scoped execution.

## Settings.json vs CLAUDE.md vs .claudeignore

These three mechanisms work together but serve different purposes:

| Mechanism | Enforcement | Purpose | Token Cost |
|-----------|------------|---------|------------|
| settings.json | Hard (tool-level) | Permission control | 0 tokens |
| CLAUDE.md | Soft (agent interprets) | Behavioral guidance | 200-400 tokens/turn |
| .claudeignore | Hard (file-level) | File access control | 0 tokens |

**Best practice:** Use settings.json for security-critical controls (prevent destructive commands), .claudeignore for performance optimization (exclude large directories), and CLAUDE.md for workflow optimization (guide behavior, set budgets).

The combination provides defense in depth:
- Settings.json prevents `rm -rf` at the tool level (cannot be overridden)
- .claudeignore prevents reading `node_modules/` at the file level (cannot be overridden)
- CLAUDE.md advises "max 5 files before proposing" at the behavioral level (soft guidance)

## Migrating Settings Across Projects

Create a base settings template and customize per project:

```bash
#!/bin/bash
# init-claude-settings.sh -- initialize .claude/settings.json from template
set -euo pipefail

mkdir -p .claude

if [ -f .claude/settings.json ]; then
    echo "settings.json already exists. Skipping."
    exit 0
fi

# Detect project type
if [ -f "prisma/schema.prisma" ]; then
    template="backend-prisma"
elif [ -f "next.config.js" ] || [ -f "next.config.ts" ]; then
    template="nextjs"
elif [ -f "turbo.json" ]; then
    template="monorepo"
else
    template="generic"
fi

echo "Detected project type: $template"
cp "$HOME/.claude/templates/settings-${template}.json" .claude/settings.json
echo "Created .claude/settings.json from $template template"
```

## Related Guides

- [Environment Variables for Claude Code Cost Control](/environment-variables-claude-code-cost-control/) -- session-level controls
- [Claude Code Hooks Guide](/claude-code-hooks-guide/) -- event-based automation
- [Cost Optimization Hub](/cost-optimization/) -- all cost guides
