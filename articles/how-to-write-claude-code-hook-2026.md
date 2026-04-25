---
layout: default
title: "Write Your First Claude Code Hook (2026)"
description: "Create a Claude Code hook that runs before or after tool execution. Step-by-step with pre-commit linting example, event types, and error handling."
permalink: /how-to-write-claude-code-hook-2026/
date: 2026-04-20
last_tested: "2026-04-22"
---

# How to Write Your First Claude Code Hook (2026)

Hooks let you run custom scripts before or after Claude Code executes tools. They automate quality checks, logging, notifications, and more. Here is how to create your first hook.

## Prerequisites

- Claude Code installed
- A project directory
- Basic scripting knowledge (bash, Python, or Node.js)

## Step 1: Understand Hook Types

Claude Code supports hooks at these lifecycle points:

- **PreToolUse** — Runs before Claude uses a tool (Read, Write, Bash, etc.)
- **PostToolUse** — Runs after a tool completes
- **Notification** — Runs when Claude sends a notification
- **Stop** — Runs when Claude finishes a response

Each hook receives context about the event and can modify behavior or block execution.

## Step 2: Create the Hook Configuration

Edit your project's `.claude/settings.json`:

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Bash",
        "hooks": [
          {
            "type": "command",
            "command": "bash /path/to/your/project/.claude/hooks/pre-bash.sh"
          }
        ]
      }
    ]
  }
}
```

This configures a hook that runs before every Bash tool execution.

## Step 3: Write the Hook Script

Create the hook script directory:

```bash
mkdir -p .claude/hooks
```

Create `.claude/hooks/pre-bash.sh`:

```bash
#!/bin/bash
# Pre-bash hook: log all bash commands Claude runs

# Hook receives input as JSON on stdin
INPUT=$(cat)

# Extract the command
COMMAND=$(echo "$INPUT" | python3 -c "import sys,json; print(json.load(sys.stdin)['tool_input']['command'])" 2>/dev/null)

# Log the command
echo "[$(date)] Bash: $COMMAND" >> .claude/hooks/command-log.txt

# Exit 0 to allow execution, non-zero to block
exit 0
```

Make it executable:

```bash
chmod +x .claude/hooks/pre-bash.sh
```

## Step 4: Create a Practical Hook — Pre-Commit Linting

A more useful hook: run a linter before Claude writes files.

Add to `.claude/settings.json`:

```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Write|Edit",
        "hooks": [
          {
            "type": "command",
            "command": "bash /path/to/your/project/.claude/hooks/post-write-lint.sh"
          }
        ]
      }
    ]
  }
}
```

Create `.claude/hooks/post-write-lint.sh`:

```bash
#!/bin/bash
# Post-write hook: lint modified files

INPUT=$(cat)
FILE_PATH=$(echo "$INPUT" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('tool_input',{}).get('file_path',''))" 2>/dev/null)

if [[ "$FILE_PATH" == *.js || "$FILE_PATH" == *.ts ]]; then
    npx eslint "$FILE_PATH" --fix 2>/dev/null
elif [[ "$FILE_PATH" == *.py ]]; then
    python3 -m ruff check "$FILE_PATH" --fix 2>/dev/null
fi

exit 0
```

```bash
chmod +x .claude/hooks/post-write-lint.sh
```

## Step 5: Test Your Hook

Start Claude Code and trigger the hook:

```bash
claude
```

Ask Claude to write or edit a file. Check that your hook runs:

- For the logging hook: inspect `.claude/hooks/command-log.txt`
- For the linting hook: check that written files are linted

## Verification

- [ ] Hook script is executable (`chmod +x`)
- [ ] Settings.json has valid JSON (no trailing commas)
- [ ] Matcher matches the correct tool name
- [ ] Hook script exits 0 for success
- [ ] Hook runs when the matched tool is used

## Advanced: Conditional Hooks

Hooks can include logic to only run under specific conditions:

**File-type specific hooks**: Only run the linter for Python files, the type checker for TypeScript, etc. (as shown in the linting example above).

**Branch-specific hooks**: Only run intensive checks on main/production branches:

```bash
#!/bin/bash
BRANCH=$(git branch --show-current 2>/dev/null)
if [[ "$BRANCH" == "main" || "$BRANCH" == "production" ]]; then
    # Run full test suite
    npm test 2>/dev/null
fi
exit 0
```

**Time-based hooks**: Skip slow hooks during rapid iteration:

```bash
#!/bin/bash
LAST_RUN_FILE=".claude/hooks/.last-full-check"
NOW=$(date +%s)
LAST_RUN=$(cat "$LAST_RUN_FILE" 2>/dev/null || echo 0)
ELAPSED=$((NOW - LAST_RUN))

# Only run full checks every 5 minutes
if [ "$ELAPSED" -gt 300 ]; then
    npm run lint && npm test
    echo "$NOW" > "$LAST_RUN_FILE"
fi
exit 0
```

## Hook Design Principles

Follow these guidelines to keep hooks maintainable:

1. **Always exit 0 unless you intend to block** — A non-zero exit blocks the tool execution. Only use this for security-critical checks.

2. **Keep hooks fast** — Hooks run synchronously. A slow hook makes every tool call feel sluggish. If a check takes more than 2 seconds, consider running it asynchronously or only periodically.

3. **Log output to files, not stdout** — Hook stdout may be captured or displayed unpredictably. Write logs to a dedicated file.

4. **Handle errors gracefully** — If your hook's dependency is missing (linter not installed), fail silently rather than blocking Claude's work.

5. **Use absolute paths** — Hooks may run from different working directories. Use absolute paths for all file references.

## Troubleshooting

**Hook does not run**: Verify the matcher string matches the tool name exactly. Tool names are case-sensitive: `Bash`, `Write`, `Edit`, `Read`. Also verify the hook file is executable: `chmod +x .claude/hooks/your-hook.sh`.

**Hook blocks execution unexpectedly**: Your script is exiting with a non-zero code. Add `exit 0` explicitly at the end. If you are using `set -e` in the script, any failing command will cause a non-zero exit.

**Hook script errors**: Test your script independently by piping sample JSON to it:
```bash
echo '{"tool_input":{"command":"ls"}}' | bash .claude/hooks/pre-bash.sh
```

**Settings.json parse error**: Validate with:
```bash
python3 -c "import json; json.load(open('.claude/settings.json'))"
```

**Hook runs but output is not visible**: Hook output goes to Claude's tool response context. For debugging, write output to a log file instead of stdout.

## Next Steps

- Explore [Claude Code hooks](/understanding-claude-code-hooks-system-complete-guide/) for advanced patterns
- See [best hooks for code quality](/best-claude-code-hooks-code-quality-2026/) for proven configurations
- Browse [Claude Code Templates](/how-to-install-claude-code-templates-cli-2026/) for pre-built hook templates
- Read [Claude Code best practices](/karpathy-skills-vs-claude-code-best-practices-2026/) for workflow integration

## See Also

- [Claude Code Hook Script Not Executable — Fix (2026)](/claude-code-hook-script-not-executable-fix-2026/)
