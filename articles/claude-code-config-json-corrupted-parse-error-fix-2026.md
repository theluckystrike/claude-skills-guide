---
title: "Config File JSON Parse Error — Fix"
permalink: /claude-code-config-json-corrupted-parse-error-fix-2026/
description: "Fix 'unexpected token in JSON' config parse error. Reset corrupted Claude Code config file to defaults with one command."
last_tested: "2026-04-22"
render_with_liquid: false
---

## The Error

```
SyntaxError: Unexpected token } in JSON at position 342
  at JSON.parse (<anonymous>)
  Loading config from /Users/you/.claude/config.json
```

This error occurs when Claude Code's configuration file has been corrupted — typically by a partial write, manual edit mistake, or disk issue.

## The Fix

1. Back up the corrupted config:

```bash
cp ~/.claude/config.json ~/.claude/config.json.bak
```

2. Validate the JSON to find the error:

```bash
python3 -m json.tool ~/.claude/config.json
```

3. If the file is unrecoverable, reset to defaults:

```bash
rm ~/.claude/config.json
claude --version
```

Claude Code regenerates a default config on next launch.

4. Restore any custom settings you need:

```bash
claude config set model claude-sonnet-4-20250514
claude config set theme dark
```

## Why This Happens

The config file can become corrupted when Claude Code is killed mid-write (Ctrl+C during a config save), when multiple Claude Code instances write to the same config simultaneously, or when a user manually edits the JSON and introduces a syntax error (trailing comma, missing quote, extra bracket).

## If That Doesn't Work

- Try to fix the JSON manually using a validator:

```bash
# Show the exact error location
python3 -c "
import json
try:
    json.load(open('$HOME/.claude/config.json'))
except json.JSONDecodeError as e:
    print(f'Error at line {e.lineno}, column {e.colno}: {e.msg}')
"
```

- Check if the project-level config is also corrupted:

```bash
python3 -m json.tool .claude/config.json 2>&1 || echo "Project config also broken"
```

- Delete both global and project configs and start fresh.

## Prevention

Add this to your `CLAUDE.md`:

```markdown
# Configuration
- Never manually edit ~/.claude/config.json. Use claude config set instead.
- Do not run multiple Claude Code instances that modify config simultaneously.
- Back up config before major changes: cp ~/.claude/config.json ~/.claude/config.json.bak
```

## See Also

- [Claude Code Config YAML Parse Error — Fix (2026)](/claude-code-config-yaml-parse-error-fix/)
- [JSON Parse Error on Malformed Response Fix](/claude-code-json-parse-error-malformed-response-fix-2026/)
