---
layout: default
title: "Claude Code Hooks (2026)"
description: "Every Claude Code hook type explained with JSON config, real examples, and use cases. PreToolUse, PostToolUse, Notification, and Stop hooks."
permalink: /claude-code-hooks-complete-guide/
date: 2026-04-20
last_tested: "2026-04-24"
---

# Claude Code Hooks: Complete Reference (2026)

Claude Code hooks let you run custom scripts automatically when specific events happen during a Claude Code session. They execute shell commands at defined trigger points: before a tool runs, after a tool runs, when a notification fires, or when Claude stops.

Hooks solve the problem of manual intervention. Instead of watching Claude Code and manually running linters, formatters, security scanners, or notification scripts, you define them once and they run automatically every time. If you are new to Claude Code, start with the [beginner guide](/how-to-use-claude-code-beginner-guide/) first, then return here to add hooks to your workflow.

This guide covers every hook type, the JSON configuration format, practical examples for real workflows, and troubleshooting for common issues.

## How Hooks Work

Hooks are defined in your Claude Code settings files. When Claude Code encounters a trigger event, it:

1. Checks if any hooks match the event type
2. Filters hooks by the optional `matcher` (tool name, file pattern)
3. Executes the hook command as a shell subprocess
4. Reads the hook's stdout and exit code
5. Decides how to proceed based on the result

Hooks run synchronously. Claude Code waits for the hook to complete before continuing. A hook that takes 30 seconds blocks Claude Code for 30 seconds.

## Configuration Location

Hooks are configured in `.claude/settings.json` (project-level) or `~/.claude/settings.json` (global). Project-level hooks override global hooks.

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Write",
        "command": "echo 'About to write a file'"
      }
    ]
  }
}
```

You can also configure hooks in `.claude/settings.local.json` for personal hooks that should not be committed to version control.

## Hook Types

### PreToolUse

Fires **before** Claude Code executes a tool. Use this to validate, modify, or block tool invocations.

**Trigger**: Right before any tool call (Bash, Write, Edit, Read, etc.)

**Environment variables available**:
- `CLAUDE_TOOL_NAME`: The tool being called (e.g., "Write", "Bash", "Edit")
- `CLAUDE_TOOL_INPUT`: JSON string of the tool's input parameters
- `CLAUDE_SESSION_ID`: Current session identifier

**Exit code behavior**:
- `0`: Allow the tool call to proceed
- `1`: Block the tool call (Claude sees the rejection)
- `2`: Block silently (Claude does not see feedback)

**stdout behavior**: Output from the hook is shown to Claude as context.

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Bash",
        "command": "/Users/you/scripts/validate-bash-command.sh"
      }
    ]
  }
}
```

**Example: Block dangerous commands**

```bash
#!/bin/bash
# validate-bash-command.sh
# Block rm -rf, force pushes, and other dangerous operations

TOOL_INPUT="$CLAUDE_TOOL_INPUT"
COMMAND=$(echo "$TOOL_INPUT" | jq -r '.command')

if echo "$COMMAND" | grep -qE 'rm -rf /|git push.*--force|DROP TABLE|format c:'; then
  echo "BLOCKED: Dangerous command detected: $COMMAND"
  exit 1
fi

exit 0
```

### PostToolUse

Fires **after** a tool executes successfully. Use this for linting, formatting, logging, or triggering side effects.

**Trigger**: After any tool call completes successfully

**Environment variables available**:
- `CLAUDE_TOOL_NAME`: The tool that was called
- `CLAUDE_TOOL_INPUT`: JSON string of the tool's input parameters
- `CLAUDE_TOOL_OUTPUT`: JSON string of the tool's output/result
- `CLAUDE_SESSION_ID`: Current session identifier

**Exit code behavior**:
- `0`: Continue normally
- Non-zero: Claude sees the error output (but the tool call already happened)

```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Write",
        "command": "/Users/you/scripts/auto-lint.sh"
      }
    ]
  }
}
```

**Example: Auto-format after file writes**

```bash
#!/bin/bash
# auto-lint.sh
# Run Prettier on any file Claude writes

FILE_PATH=$(echo "$CLAUDE_TOOL_INPUT" | jq -r '.file_path // .path // empty')

if [ -z "$FILE_PATH" ]; then
  exit 0
fi

# Only format supported file types
case "$FILE_PATH" in
  *.ts|*.tsx|*.js|*.jsx|*.json|*.css|*.md)
    npx prettier --write "$FILE_PATH" 2>/dev/null
    echo "Formatted: $FILE_PATH"
    ;;
esac

exit 0
```

### Notification

Fires when Claude Code generates a notification (e.g., when a long-running task completes or when Claude needs user input).

**Trigger**: Terminal notification events

**Environment variables available**:
- `CLAUDE_NOTIFICATION_MESSAGE`: The notification text
- `CLAUDE_SESSION_ID`: Current session identifier

**Exit code behavior**:
- Exit code does not affect Claude Code behavior

```json
{
  "hooks": {
    "Notification": [
      {
        "command": "/Users/you/scripts/notify-slack.sh"
      }
    ]
  }
}
```

**Example: Send Slack notification**

```bash
#!/bin/bash
# notify-slack.sh
# Post Claude Code notifications to Slack

WEBHOOK_URL="https://hooks.slack.com/services/YOUR/WEBHOOK/URL"
MESSAGE="$CLAUDE_NOTIFICATION_MESSAGE"

curl -s -X POST "$WEBHOOK_URL" \
  -H 'Content-type: application/json' \
  -d "{\"text\": \"Claude Code: $MESSAGE\"}"
```

### Stop

Fires when Claude Code stops (either completes a task or is interrupted).

**Trigger**: Session ending or task completion

**Environment variables available**:
- `CLAUDE_STOP_REASON`: Why Claude stopped ("end_turn", "max_tokens", "user_interrupt")
- `CLAUDE_SESSION_ID`: Current session identifier

**Exit code behavior**:
- `0`: If stdout is non-empty, Claude sees it and may continue working
- Non-zero: Claude sees the error output and may continue working

This hook is powerful: returning output from a Stop hook can make Claude continue working. Use this for automated verification loops.

```json
{
  "hooks": {
    "Stop": [
      {
        "command": "/Users/you/scripts/verify-on-stop.sh"
      }
    ]
  }
}
```

**Example: Run tests before allowing Claude to stop**

```bash
#!/bin/bash
# verify-on-stop.sh
# Run test suite when Claude finishes. If tests fail, Claude sees the output and continues fixing.

if [ "$CLAUDE_STOP_REASON" = "end_turn" ]; then
  TEST_OUTPUT=$(npm test 2>&1)
  if [ $? -ne 0 ]; then
    echo "Tests failed. Please fix these failures:"
    echo "$TEST_OUTPUT"
    exit 0  # Exit 0 with output = Claude continues
  fi
fi
```

## Matcher Patterns

The `matcher` field filters which tool invocations trigger a hook. It matches against the tool name.

### Exact Match

```json
{
  "matcher": "Write",
  "command": "echo 'File written'"
}
```

Only triggers for the `Write` tool.

### Regex Match

```json
{
  "matcher": "Write|Edit",
  "command": "echo 'File modified'"
}
```

Triggers for both `Write` and `Edit` tools.

### No Matcher (Match All)

```json
{
  "command": "echo 'Any tool was used'"
}
```

Omitting `matcher` triggers the hook for every tool call. Use this sparingly as it runs on every single tool invocation.

### Available Tool Names

Tools you can match against:

| Tool Name | Description |
|-----------|-------------|
| `Bash` | Shell command execution |
| `Write` | Creating or overwriting files |
| `Edit` | Editing existing files |
| `Read` | Reading file contents |
| `Glob` | File pattern matching |
| `Grep` | Content search |
| `WebFetch` | Fetching web content |
| `WebSearch` | Web search |
| `NotebookEdit` | Jupyter notebook editing |

## Complete Configuration Example

Here is a full `.claude/settings.json` with hooks for a production TypeScript project:

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Bash",
        "command": "/Users/you/project/.claude/hooks/block-dangerous-commands.sh"
      },
      {
        "matcher": "Write",
        "command": "/Users/you/project/.claude/hooks/check-file-path.sh"
      }
    ],
    "PostToolUse": [
      {
        "matcher": "Write|Edit",
        "command": "/Users/you/project/.claude/hooks/auto-format.sh"
      },
      {
        "matcher": "Write",
        "command": "/Users/you/project/.claude/hooks/log-file-change.sh"
      },
      {
        "matcher": "Bash",
        "command": "/Users/you/project/.claude/hooks/log-commands.sh"
      }
    ],
    "Notification": [
      {
        "command": "/Users/you/project/.claude/hooks/notify.sh"
      }
    ],
    "Stop": [
      {
        "command": "/Users/you/project/.claude/hooks/run-checks.sh"
      }
    ]
  }
}
```

## Practical Use Cases

### Use Case 1: Security Gate

Prevent Claude from writing to sensitive directories or files:

```bash
#!/bin/bash
# check-file-path.sh (PreToolUse for Write)

FILE_PATH=$(echo "$CLAUDE_TOOL_INPUT" | jq -r '.file_path // .path // empty')

# Block writes to sensitive locations
BLOCKED_PATTERNS=(
  ".env"
  "credentials"
  "secrets"
  ".ssh"
  "node_modules"
  "*.pem"
  "*.key"
)

for pattern in "${BLOCKED_PATTERNS[@]}"; do
  if echo "$FILE_PATH" | grep -qi "$pattern"; then
    echo "BLOCKED: Cannot write to sensitive path: $FILE_PATH"
    exit 1
  fi
done

exit 0
```

### Use Case 2: Auto-Lint on Save

Run ESLint and fix issues automatically after Claude writes TypeScript files:

```bash
#!/bin/bash
# auto-format.sh (PostToolUse for Write|Edit)

FILE_PATH=$(echo "$CLAUDE_TOOL_INPUT" | jq -r '.file_path // .path // empty')

if [ -z "$FILE_PATH" ] || [ ! -f "$FILE_PATH" ]; then
  exit 0
fi

case "$FILE_PATH" in
  *.ts|*.tsx)
    LINT_OUTPUT=$(npx eslint --fix "$FILE_PATH" 2>&1)
    if [ $? -ne 0 ]; then
      echo "ESLint issues in $FILE_PATH:"
      echo "$LINT_OUTPUT"
    fi
    npx prettier --write "$FILE_PATH" 2>/dev/null
    ;;
  *.css|*.scss)
    npx prettier --write "$FILE_PATH" 2>/dev/null
    ;;
esac

exit 0
```

### Use Case 3: Audit Log

Log every Claude Code action for compliance:

```bash
#!/bin/bash
# log-commands.sh (PostToolUse for Bash)

LOG_FILE="$HOME/.claude/audit.log"
TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
COMMAND=$(echo "$CLAUDE_TOOL_INPUT" | jq -r '.command // empty')

echo "[$TIMESTAMP] SESSION=$CLAUDE_SESSION_ID TOOL=$CLAUDE_TOOL_NAME CMD=$COMMAND" >> "$LOG_FILE"

exit 0
```

### Use Case 4: Test Verification Loop

Force Claude to fix test failures before completing:

```bash
#!/bin/bash
# run-checks.sh (Stop hook)

if [ "$CLAUDE_STOP_REASON" != "end_turn" ]; then
  exit 0
fi

# Run type checking
TSC_OUTPUT=$(npx tsc --noEmit 2>&1)
if [ $? -ne 0 ]; then
  echo "TypeScript errors found. Please fix:"
  echo "$TSC_OUTPUT"
  exit 0  # Output + exit 0 = Claude continues
fi

# Run tests
TEST_OUTPUT=$(npm test 2>&1)
if [ $? -ne 0 ]; then
  echo "Test failures. Please fix:"
  echo "$TEST_OUTPUT"
  exit 0
fi

# All checks passed, let Claude stop
exit 0
```

### Use Case 5: Branch Protection

Prevent Claude from running git commands on protected branches:

```bash
#!/bin/bash
# protect-branches.sh (PreToolUse for Bash)

COMMAND=$(echo "$CLAUDE_TOOL_INPUT" | jq -r '.command // empty')

# Only check git commands
if ! echo "$COMMAND" | grep -q "^git "; then
  exit 0
fi

CURRENT_BRANCH=$(git branch --show-current 2>/dev/null)
PROTECTED_BRANCHES=("main" "master" "production" "staging")

for branch in "${PROTECTED_BRANCHES[@]}"; do
  if [ "$CURRENT_BRANCH" = "$branch" ]; then
    if echo "$COMMAND" | grep -qE 'git (push|reset|rebase|merge|commit)'; then
      echo "BLOCKED: Cannot run '$COMMAND' on protected branch '$branch'"
      exit 1
    fi
  fi
done

exit 0
```

### Use Case 6: Cost Tracking

Track token-related costs in real-time:

```bash
#!/bin/bash
# track-cost.sh (PostToolUse, no matcher = all tools)

COST_FILE="$HOME/.claude/session-costs.jsonl"
TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

echo "{\"timestamp\":\"$TIMESTAMP\",\"session\":\"$CLAUDE_SESSION_ID\",\"tool\":\"$CLAUDE_TOOL_NAME\"}" >> "$COST_FILE"
exit 0
```

## Hook Script Best Practices

### 1. Keep Hooks Fast

Hooks run synchronously. A slow hook blocks Claude Code on every tool call. Target under 2 seconds per hook.

```bash
# Bad: Running full test suite on every file write
npm test  # Could take 60+ seconds

# Good: Running only affected tests
npx jest --findRelatedTests "$FILE_PATH" --passWithNoTests
```

### 2. Handle Missing Dependencies

Your hook may run in environments where tools are not installed:

```bash
#!/bin/bash
if ! command -v eslint &> /dev/null; then
  # ESLint not installed, skip
  exit 0
fi

npx eslint --fix "$FILE_PATH"
```

### 3. Use Exit Codes Correctly

| Exit Code | PreToolUse | PostToolUse | Stop |
|-----------|-----------|-------------|------|
| 0 | Allow tool call | Continue | Stop (unless stdout) |
| 1 | Block + show message | Show error | Continue |
| 2 | Block silently | Show error | Continue |

### 4. Parse JSON Safely

Tool input/output is JSON. Use `jq` for reliable parsing:

```bash
# Bad: grep/sed parsing
FILE=$(echo "$CLAUDE_TOOL_INPUT" | grep -o '"file_path":"[^"]*"' | cut -d'"' -f4)

# Good: jq parsing
FILE=$(echo "$CLAUDE_TOOL_INPUT" | jq -r '.file_path // empty')
```

### 5. Log Errors Separately

Do not let hook errors pollute Claude's context:

```bash
#!/bin/bash
# Redirect errors to log file, only show relevant output to Claude
exec 2>>/tmp/claude-hook-errors.log

# Hook logic here...
```

### 6. Make Scripts Executable

```bash
chmod +x .claude/hooks/*.sh
```

Claude Code will not execute scripts that lack the executable permission.

*Need the complete toolkit? [The Claude Code Playbook](https://zovo.one/pricing) includes 200 production-ready templates.*

## Combining Hooks with Other Features

### Hooks + CLAUDE.md

Use [CLAUDE.md](/claude-md-best-practices-definitive-guide/) to tell Claude about your hooks:

```markdown
## Hooks
This project uses Claude Code hooks:
- PreToolUse: Blocks writes to .env and credentials files
- PostToolUse: Auto-formats with Prettier after Write/Edit
- Stop: Runs `npm test` before allowing task completion

Do not try to disable or work around these hooks.
```

### Hooks + MCP Servers

Hooks and [MCP servers](/claude-code-mcp-server-setup/) are independent systems. Hooks trigger on built-in tool events; MCP servers provide additional tools. However, you can write hooks that interact with MCP-related files:

```bash
# PostToolUse hook that validates MCP configuration after edits
FILE_PATH=$(echo "$CLAUDE_TOOL_INPUT" | jq -r '.file_path // empty')
if echo "$FILE_PATH" | grep -q "mcp.json"; then
  # Validate MCP config
  jq empty "$FILE_PATH" 2>/dev/null || echo "Invalid JSON in MCP config"
fi
```

### Hooks + Git Hooks

Claude Code hooks and [Git hooks](/claude-code-git-hooks-pre-commit-automation/) serve different purposes but can work together:

- **Git hooks**: Run on git operations (pre-commit, pre-push)
- **Claude Code hooks**: Run on Claude Code tool operations

You might use a Claude Code PostToolUse hook to stage files, then rely on a Git pre-commit hook for final validation.

## Debugging Hooks

### Hook Not Firing

1. Check the file path in settings.json is absolute and correct
2. Verify the script is executable (`chmod +x`)
3. Check the matcher matches the exact tool name (case-sensitive)
4. Look for JSON syntax errors in settings.json

### Hook Blocks Everything

1. Check exit codes. `exit 1` blocks PreToolUse hooks.
2. Add logging to see what the hook receives:

```bash
echo "DEBUG: TOOL=$CLAUDE_TOOL_NAME INPUT=$CLAUDE_TOOL_INPUT" >> /tmp/hook-debug.log
```

### Hook Output Not Visible

1. PreToolUse hooks show stdout to Claude only on exit code 0 or 1
2. PostToolUse hooks always show stdout to Claude
3. Stop hooks with empty stdout do not trigger Claude to continue

### Performance Issues

If hooks slow down Claude Code:

1. Profile your hook scripts with `time`
2. Move heavy operations to background processes where possible
3. Add early-exit conditions for irrelevant tool calls
4. Use file caching for expensive lookups

## Migration from Earlier Versions

If you set up hooks before the stable API, update your configuration:

1. Move hooks from `~/.claude.json` to `~/.claude/settings.json`
2. Update environment variable names (older versions used `TOOL_NAME` without the `CLAUDE_` prefix)
3. Verify matcher patterns still work with current tool names

## Frequently Asked Questions

### Can hooks modify the tool input before it executes?
No. PreToolUse hooks can only allow or block tool calls. They cannot modify the tool's parameters. If you need to change what Claude does, return feedback text that Claude will see and respond to.

### Do hooks work with Claude Code headless mode?
Yes. Hooks fire in both interactive and headless (`--print`) mode. This makes them useful for [CI/CD integrations](/claude-code-ci-cd-integration-guide-2026/).

### Can I have multiple hooks for the same event?
Yes. Define multiple entries in the array. They execute in order, and all must pass for the tool call to proceed (for PreToolUse).

### Are hooks sandboxed?
No. Hooks run with the same permissions as your shell user. A hook can do anything your terminal can do. Review hook scripts carefully before installing them.

### Do hooks persist across sessions?
Hook definitions in settings.json persist. Each new Claude Code session loads and applies them. Session-specific state (like counters) must be stored in files.

### Can I share hooks with my team?
Yes. Commit `.claude/settings.json` and `.claude/hooks/` to your repository. Team members get the hooks when they clone the project. Use `.claude/settings.local.json` for personal hooks that should not be shared.

### What happens if a hook script crashes?
A crashing hook (signal-terminated, segfault) is treated as a non-zero exit code. For PreToolUse, this blocks the tool call. For PostToolUse, Claude sees the error.

### Can hooks access the internet?
Yes. Hooks are regular shell scripts. They can make HTTP requests, call APIs, send notifications, or do anything else a shell script can do.

### Where can I find pre-built hook scripts?
Check the [best Claude Code hooks collection](/best-claude-code-hooks-code-quality-2026/) for community-maintained hooks. The [SuperClaude framework](/super-claude-code-framework-guide/) also includes hook templates. For cost-related hooks, see our [token usage audit guide](/audit-claude-code-token-usage-step-by-step/) and [cost saving tools](/best-claude-code-cost-saving-tools-2026/).


{% raw %}
<script type="application/ld+json">
{
  "@context": "https://schema.org",
  "@type": "FAQPage",
  "mainEntity": [
    {
      "@type": "Question",
      "name": "### Can hooks modify the tool input before it executes?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "No. PreToolUse hooks can only allow or block tool calls. They cannot modify the tool's parameters. If you need to change what Claude does, return feedback text that Claude will see and respond to."
      }
    },
    {
      "@type": "Question",
      "name": "Do hooks work with Claude Code headless mode?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "Yes. Hooks fire in both interactive and headless (--print) mode. This makes them useful for CI/CD integrations."
      }
    },
    {
      "@type": "Question",
      "name": "Can I have multiple hooks for the same event?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "Yes. Define multiple entries in the array. They execute in order, and all must pass for the tool call to proceed (for PreToolUse)."
      }
    },
    {
      "@type": "Question",
      "name": "Are hooks sandboxed?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "No. Hooks run with the same permissions as your shell user. A hook can do anything your terminal can do. Review hook scripts carefully before installing them."
      }
    },
    {
      "@type": "Question",
      "name": "Do hooks persist across sessions?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "Hook definitions in settings.json persist. Each new Claude Code session loads and applies them. Session-specific state (like counters) must be stored in files."
      }
    },
    {
      "@type": "Question",
      "name": "Can I share hooks with my team?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "Yes. Commit .claude/settings.json and .claude/hooks/ to your repository. Team members get the hooks when they clone the project. Use .claude/settings.local.json for personal hooks that should not be shared."
      }
    },
    {
      "@type": "Question",
      "name": "What happens if a hook script crashes?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "A crashing hook (signal-terminated, segfault) is treated as a non-zero exit code. For PreToolUse, this blocks the tool call. For PostToolUse, Claude sees the error."
      }
    },
    {
      "@type": "Question",
      "name": "Can hooks access the internet?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "Yes. Hooks are regular shell scripts. They can make HTTP requests, call APIs, send notifications, or do anything else a shell script can do."
      }
    },
    {
      "@type": "Question",
      "name": "Where can I find pre-built hook scripts?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "Check the best Claude Code hooks collection for community-maintained hooks. The SuperClaude framework also includes hook templates. For cost-related hooks, see our token usage audit guide and cost saving tools."
      }
    }
  ]
}
</script>



**Know your costs →** Use our [Claude Code Cost Calculator](/calculator/) to estimate your monthly spend.

## See Also

**Try it:** Paste your error into our [Error Diagnostic](/diagnose/) for an instant fix.

- [Claude Code Spec Workflow Guide](/claude-code-spec-workflow-guide/)
- [CLAUDE.md Best Practices Definitive Guide](/claude-md-best-practices-definitive-guide/)
- [Super Claude Code Framework Guide](/super-claude-code-framework-guide/)
- [Advanced Usage Guide](/advanced-usage/). Power user techniques and advanced patterns

{% endraw %}
