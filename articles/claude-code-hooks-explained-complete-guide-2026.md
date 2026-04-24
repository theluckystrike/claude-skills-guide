---
title: "Claude Code Hooks: How They Work (2026)"
description: "Complete guide to Claude Code hooks covering event types, configuration, practical examples for linting, testing, and security validation."
permalink: /claude-code-hooks-explained-complete-guide-2026/
last_tested: "2026-04-22"
---

# Claude Code Hooks: How They Work (2026)

Hooks are scripts that run automatically when Claude Code performs specific actions. They bridge the gap between what Claude Code generates and what your project requires — running linters, type checkers, security scans, and custom validators without manual intervention.

## What Are Hooks?

A hook is a shell command triggered by a Claude Code event. When Claude Code writes a file, the hook runs. When Claude Code finishes a task, the hook runs. The hook's output is fed back to Claude Code, influencing its next action.

Hooks live in `.claude/settings.json` at the project or user level. They require no external dependencies beyond what your shell provides.

## Hook Event Types

### pre-tool-use
Runs before Claude Code executes a tool. Use for:
- Blocking writes to protected files
- Validating that a command is safe to run
- Logging tool usage

### post-tool-use
Runs after Claude Code executes a tool. Use for:
- Linting written files
- Running type checks after edits
- Scanning for security issues
- Formatting code

### notification
Runs when Claude Code sends a notification (e.g., task completion). Use for:
- Sending Slack/Discord alerts
- Logging session summaries
- Triggering CI pipelines

## Configuration Format

Hooks are defined in `.claude/settings.json`:

```json
{
  "hooks": {
    "post-tool-use": [
      {
        "tool": "write_file",
        "command": "npx eslint --fix $FILE 2>&1 | tail -5"
      },
      {
        "tool": "edit_file",
        "command": "npx prettier --write $FILE"
      }
    ],
    "pre-tool-use": [
      {
        "tool": "bash",
        "command": "echo 'Running command: $COMMAND'"
      }
    ]
  }
}
```

### Available Variables
- `$FILE` — The file path being written or edited
- `$TOOL` — The tool being invoked
- `$COMMAND` — The command being executed (for bash tool)

## Practical Hook Recipes

### Recipe 1: Auto-Lint and Format

```json
{
  "hooks": {
    "post-tool-use": [
      {
        "tool": "write_file",
        "command": "npx eslint --fix $FILE 2>/dev/null; npx prettier --write $FILE 2>/dev/null"
      }
    ]
  }
}
```

Every file Claude Code writes gets linted and formatted automatically. Errors are silenced — you can remove `2>/dev/null` to see lint output.

### Recipe 2: Type Safety Check

```json
{
  "hooks": {
    "post-tool-use": [
      {
        "tool": "write_file",
        "command": "npx tsc --noEmit 2>&1 | head -20"
      },
      {
        "tool": "edit_file",
        "command": "npx tsc --noEmit 2>&1 | head -20"
      }
    ]
  }
}
```

Runs the TypeScript compiler after every file change. If there are type errors, Claude Code sees them and can fix them immediately.

### Recipe 3: Security Scanner

```json
{
  "hooks": {
    "post-tool-use": [
      {
        "tool": "write_file",
        "command": "grep -n 'API_KEY\\|SECRET\\|PASSWORD\\|TOKEN' $FILE | grep -v '\\.env' | head -5"
      }
    ]
  }
}
```

Scans every written file for hardcoded secrets. If found, the output alerts Claude Code to remove them.

### Recipe 4: Test Runner

```json
{
  "hooks": {
    "post-tool-use": [
      {
        "tool": "write_file",
        "command": "npx vitest run --reporter=verbose 2>&1 | tail -15"
      }
    ]
  }
}
```

Runs your test suite after every file write. Claude Code sees test failures and can fix them in the same session.

### Recipe 5: Protected File Guard

```json
{
  "hooks": {
    "pre-tool-use": [
      {
        "tool": "write_file",
        "command": "echo $FILE | grep -q 'migrations\\|.env\\|package-lock' && echo 'BLOCKED: This file is protected' && exit 1 || true"
      }
    ]
  }
}
```

Prevents Claude Code from writing to migration files, .env, or lockfiles.

### Recipe 6: Auto-Documentation Update

The [claude-code-docs](https://github.com/ericbuess/claude-code-docs) repo (832 stars) uses this pattern to keep offline docs in sync:

```json
{
  "hooks": {
    "post-tool-use": [
      {
        "tool": "write_file",
        "command": "node scripts/update-docs-index.js $FILE 2>/dev/null"
      }
    ]
  }
}
```

## Hook Design Guidelines

### Keep Hooks Fast
Hooks run synchronously. A 30-second test suite hook means Claude Code waits 30 seconds after every file write. Keep hook execution under 5 seconds for responsiveness.

### Limit Output
Pipe output through `tail -N` or `head -N` to prevent large outputs from consuming context. 5-20 lines is usually sufficient.

### Fail Gracefully
Add `2>/dev/null` or `|| true` to non-critical hooks so they do not block Claude Code on transient errors.

### Use Tool-Specific Hooks
Target specific tools (`write_file`, `edit_file`, `bash`) rather than running hooks on every tool use. This reduces unnecessary execution.

## Hook Scope

| Setting Location | Applies To |
|-----------------|------------|
| `.claude/settings.json` (project) | This project only |
| `~/.claude/settings.json` (user) | All projects |

Project hooks override user hooks for the same event+tool combination.

## Debugging Hooks

If a hook is not firing:
1. Check the tool name matches exactly (`write_file`, not `writeFile`)
2. Verify the command works standalone in your terminal
3. Check that `.claude/settings.json` is valid JSON
4. Look for hook output in the Claude Code session — it appears as tool results

## Hooks vs Skills vs Commands

| Feature | Hooks | Skills | Commands |
|---------|-------|--------|----------|
| Trigger | Automatic (event-based) | Manual (referenced) | Manual (slash command) |
| Format | Shell commands in JSON | Markdown in CLAUDE.md | Markdown in .claude/commands/ |
| Runs code | Yes | No (instructions only) | No (instructions only) |
| Token cost | Zero (output only) | Constant (always in context) | On-demand |

For a detailed comparison, see our [skills vs hooks vs commands article](/claude-code-skills-vs-hooks-vs-commands-2026/).

## FAQ

### Do hooks consume tokens?
The hook output is returned to Claude Code and consumes tokens. The hook configuration itself does not. Keep output minimal to control costs.

### Can hooks modify Claude Code's behavior?
Yes. Hook output appears as context. If a hook outputs "Type error on line 42," Claude Code can respond by fixing line 42.

### Are hooks sandboxed?
Hooks run with your user permissions — the same as any shell command. They can access the filesystem, network, and any installed tools. Be cautious with hooks from untrusted sources.

### Can I disable hooks temporarily?
Remove or comment out the hooks in `.claude/settings.json`. There is no runtime toggle.

### What happens if a hook fails?
If a pre-tool-use hook exits with a non-zero code, the tool action may be blocked. Post-tool-use hooks do not block — they report output.

For more on configuring Claude Code, see the [configuration hierarchy guide](/claude-code-configuration-hierarchy-explained-2026/). For building custom skills that complement hooks, read the [skill building guide](/how-to-build-your-own-claude-code-skill-2026/). For CI/CD integration with hooks, see the [CI/CD guide](/claude-code-ci-cd-integration-guide-2026/).
