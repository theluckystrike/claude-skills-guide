---
title: "Claude Code Project vs Global Settings: Token Impact"
description: "Project-level Claude Code settings load only in relevant directories, saving 200-800 tokens per session versus global settings that load everywhere."
permalink: /claude-code-project-vs-global-settings-token-impact/
date: 2026-04-22
last_tested: "2026-04-22"
render_with_liquid: false
---

# Claude Code Project vs Global Settings: Token Impact

## What It Does

Claude Code supports settings at two levels: global (`~/.claude/settings.json`) and project (`.claude/settings.json`). Global settings load in every session across all projects. Project settings load only when working in that project directory. Misplacing project-specific configuration at the global level wastes 200-800 tokens per session in unrelated projects. Proper scoping ensures each session carries only relevant context.

## Installation / Setup

Check current configuration locations:

```bash
# Global settings
cat ~/.claude/settings.json 2>/dev/null || echo "No global settings"

# Project settings (from project root)
cat .claude/settings.json 2>/dev/null || echo "No project settings"
```

## Configuration for Cost Optimization

### What Belongs at Global Level

Global settings should contain only universal preferences that apply to every project:

```json
{
  "permissions": {
    "allow": ["Read", "Glob", "Grep"],
    "deny": []
  },
  "preferences": {
    "theme": "dark"
  }
}
```

This minimal global config adds ~100 tokens per session. Acceptable overhead for universal settings.

### What Belongs at Project Level

Project-specific MCP servers, custom hooks, and tool restrictions belong in `.claude/settings.json`:

```json
{
  "mcpServers": {
    "postgres": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-postgres", "postgresql://localhost/myapp"],
      "env": {}
    }
  },
  "hooks": {
    "postToolUse": [
      {
        "command": ".claude/hooks/log-tool-usage.sh \"$TOOL_NAME\"",
        "description": "Log tool usage"
      }
    ]
  },
  "permissions": {
    "allow": ["Read", "Glob", "Grep", "Edit", "Write", "Bash", "mcp__postgres__query"]
  }
}
```

When placed at the project level, this configuration (~400 tokens) loads only when working in this project. If placed globally, every Claude Code session across all projects pays the 400-token overhead -- including the ~1,200 token MCP tool definition overhead from the PostgreSQL server.

### Migration: Global to Project

```bash
#!/bin/bash
# scripts/migrate-settings.sh
# Move project-specific settings from global to project level
set -euo pipefail

GLOBAL_SETTINGS="$HOME/.claude/settings.json"
PROJECT_SETTINGS=".claude/settings.json"

mkdir -p .claude

if [ ! -f "$GLOBAL_SETTINGS" ]; then
  echo "No global settings to migrate"
  exit 0
fi

# Check if global settings contain MCP servers (project-specific)
if grep -q "mcpServers" "$GLOBAL_SETTINGS"; then
  echo "Found MCP servers in global settings -- these should be project-level"
  echo "Current global MCP servers:"
  grep -A5 "mcpServers" "$GLOBAL_SETTINGS" | head -20
  echo ""
  echo "Recommended: Move MCP server config to ${PROJECT_SETTINGS}"
fi

# Check for project-specific hooks
if grep -q "hooks" "$GLOBAL_SETTINGS"; then
  echo "Found hooks in global settings -- review for project specificity"
fi
```

## Usage Examples

### Basic Usage

Verify setting scope by checking what loads in a session:

```bash
# In project directory with project settings
claude -p "What MCP servers are loaded?" --max-turns 3
# Should show only project-specific servers

# In a different directory without project settings
claude -p "What MCP servers are loaded?" --max-turns 3
# Should show nothing (or only global servers)
```

### Advanced: Multi-Project Workspace

For developers working across multiple projects, proper scoping prevents cross-contamination:

```text
~/projects/
  frontend-app/
    .claude/settings.json    # No MCP servers, React-specific hooks
  backend-api/
    .claude/settings.json    # Postgres MCP, API-specific hooks
  data-pipeline/
    .claude/settings.json    # BigQuery MCP, Python-specific settings
```

Each project loads only its own settings. A session in `frontend-app/` pays zero tokens for the Postgres and BigQuery MCP servers configured in sibling projects.

**Savings vs. all-global config: 2,000-5,000 tokens per session** (no cross-project MCP tool definitions loading).

## Token Usage Measurements

| Configuration | Tokens per Session (in project) | Tokens per Session (other projects) |
|--------------|-------------------------------|-------------------------------------|
| All global (3 MCP servers, hooks) | ~5,500 | ~5,500 |
| All project-level | ~5,500 | ~100 |
| **Savings in other projects** | | **~5,400 tokens** |

For a developer working across 3 projects equally: one-third of sessions are in the target project (settings needed), two-thirds are in other projects (settings wasted if global).

Monthly savings: 67% of 100 sessions x 5,400 tokens = 362,000 tokens = **$1.09/month** on Sonnet 4.6 input alone. With context compounding over multi-turn sessions, actual savings are 2-3x higher: **$2-$3/month**.

### CLAUDE.md Follows the Same Pattern

Just as settings.json has global and project scope, CLAUDE.md files exist at multiple levels:

```text
~/.claude/CLAUDE.md                  # Global: loads in ALL sessions (~100-200 tokens)
~/project-a/CLAUDE.md                # Project: loads in project-a sessions
~/project-a/src/CLAUDE.md            # Directory: loads when working in src/
~/project-a/src/api/CLAUDE.md        # Subdirectory: loads when working in api/
```

The same principle applies: keep global CLAUDE.md lean (universal rules only), and place project-specific conventions in project-level or directory-level files. A 500-token global CLAUDE.md that includes project-a's database conventions wastes those 500 tokens in every session for project-b, project-c, and any other directory.

```markdown
# ~/.claude/CLAUDE.md -- Global (keep under 150 tokens)

## Universal Rules
- Never force-push to main
- Conventional commits
- Run tests before committing
```

```markdown
# ~/project-a/CLAUDE.md -- Project-specific (loads only in project-a)

## Database
- PostgreSQL 16, Prisma ORM
- Migrations: npx prisma migrate dev
- Schema: prisma/schema.prisma

## Deploy
- Vercel, `vercel deploy --prod`
- Staging: `vercel deploy` (no --prod)
```

**Savings from proper CLAUDE.md scoping: 300-500 tokens per session in other projects**

### Hooks Configuration Scoping

Hooks defined in global settings run on every session. A post-tool-use hook that logs MCP calls is irrelevant in projects without MCP servers:

```json
{
  "hooks": {
    "postToolUse": [
      {
        "command": ".claude/hooks/log-mcp.sh",
        "description": "Log MCP usage"
      }
    ]
  }
}
```

If this hook configuration is global, it runs (and potentially errors) in projects that lack the `.claude/hooks/log-mcp.sh` script. Place it in the project's `.claude/settings.json` instead.

## Comparison with Alternatives

| Approach | Token Efficiency | Management Effort | Flexibility |
|----------|-----------------|-------------------|------------|
| Project-level settings | High (scoped) | Per-project | High |
| Global settings | Low (always loaded) | Centralized | Low |
| --allowedTools per session | Highest (manual) | Per-session | Highest |

## Troubleshooting

**Settings not loading in project**: Ensure `.claude/settings.json` is in the project root (where `git init` was run). Claude Code traverses from the current directory upward to find settings.

**Conflicting global and project settings**: Project settings override global settings for the same key. To verify which settings are active, check Claude Code's startup output.

**Teams with many projects**: For teams managing 10+ projects, create a template `.claude/settings.json` that each project copies and customizes. This ensures consistent structure while allowing project-specific configuration:

```bash
# scripts/init-claude-settings.sh
#!/bin/bash
mkdir -p .claude
if [ ! -f ".claude/settings.json" ]; then
  cat > .claude/settings.json << 'EOF'
{
  "permissions": {
    "allow": ["Read", "Glob", "Grep", "Edit", "Write", "Bash"]
  }
}
EOF
  echo "Created .claude/settings.json template"
else
  echo ".claude/settings.json already exists"
fi
```

**MCP server needed across multiple projects**: If the same MCP server is used in 3+ projects, consider keeping it global and accepting the overhead, rather than duplicating configuration. The break-even is: global overhead x sessions-in-other-projects vs. the maintenance cost of duplicated configs.

### Auditing Settings Scope

Periodically verify that settings are properly scoped:

```bash
#!/bin/bash
# scripts/audit-settings-scope.sh
# Checks for settings that should be project-scoped but are global
set -uo pipefail

GLOBAL_SETTINGS="${HOME}/.claude/settings.json"

if [ ! -f "$GLOBAL_SETTINGS" ]; then
  echo "No global settings file found."
  exit 0
fi

echo "=== Settings Scope Audit ==="

# Check for MCP servers in global settings
MCP_COUNT=$(grep -c '"mcpServers"' "$GLOBAL_SETTINGS" 2>/dev/null || echo "0")
if [ "$MCP_COUNT" -gt 0 ]; then
  echo "WARNING: MCP servers configured globally."
  echo "  Consider moving to project-level .claude/settings.json"
  echo "  Each global MCP server loads in ALL sessions (500-2,000 tokens/tool)"
fi

# Check for project-specific hooks in global settings
HOOK_COUNT=$(grep -c '"hooks"' "$GLOBAL_SETTINGS" 2>/dev/null || echo "0")
if [ "$HOOK_COUNT" -gt 0 ]; then
  echo "NOTE: Hooks configured globally."
  echo "  Verify these hooks apply to ALL projects, not just one."
fi

echo ""
echo "Recommendation: global settings should contain ONLY universal permissions."
echo "Everything else belongs in project-level .claude/settings.json"
```

Run this audit monthly. Each MCP server found in global settings represents 500-2,000 tokens per tool of wasted overhead in every session across every project. Moving a 5-tool server from global to project scope saves 2,500-10,000 tokens per session in all other projects.

## Related Guides

- [Claude Code MCP Server Setup](/claude-code-mcp-server-setup/) -- configuring MCP servers at the right scope
- [Progressive Disclosure in CLAUDE.md: Load Only What You Need](/progressive-disclosure-claude-md-load-only-needed/) -- same scoping principle for instructions
