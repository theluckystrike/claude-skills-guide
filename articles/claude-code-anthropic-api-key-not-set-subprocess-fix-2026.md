---
title: "ANTHROPIC_API_KEY Not Set in Subprocess Fix"
permalink: /claude-code-anthropic-api-key-not-set-subprocess-fix-2026/
description: "Fix ANTHROPIC_API_KEY not set in subprocess spawned by Claude Code. Export the key in shell profile or pass it explicitly to child process environments."
last_tested: "2026-04-22"
render_with_liquid: false
---

## The Error

```
Error: ANTHROPIC_API_KEY environment variable is not set
  Subprocess spawned by Claude Code cannot authenticate
  Parent process has the key, but child process does not inherit it
  at ApiClient.validateKey (api-client.js:12)
```

This appears when a script or tool spawned by Claude Code tries to use the Anthropic API but cannot access the API key because it was not exported to child process environments.

## The Fix

```bash
export ANTHROPIC_API_KEY="sk-ant-..."
```

1. Ensure the API key is `export`ed (not just `set`) so child processes inherit it.
2. Add the export to your `~/.zshrc` or `~/.bashrc` for persistence.
3. Verify it propagates: `env | grep ANTHROPIC_API_KEY`.

## Why This Happens

In Unix shells, variables set with `VAR=value` are local to the current shell. Only `export VAR=value` makes them available to child processes. If you set `ANTHROPIC_API_KEY` without `export` in a shell config file, or if you set it in a parent shell but the child process (like a Python script calling the Anthropic SDK) starts in a new environment, the key is not inherited. Docker containers, CI runners, and subshells each have their own environment.

## If That Doesn't Work

Check if the key is actually exported:

```bash
env | grep ANTHROPIC
# vs
set | grep ANTHROPIC  # shows local vars too
```

Pass the key explicitly to a subprocess:

```bash
ANTHROPIC_API_KEY="$ANTHROPIC_API_KEY" python script.py
```

For Docker containers, pass it as a build arg or runtime env:

```bash
docker run -e ANTHROPIC_API_KEY="$ANTHROPIC_API_KEY" my-image
```

Check for shadowed variable names:

```bash
grep -r "ANTHROPIC_API_KEY" ~/.zshrc ~/.bashrc ~/.profile
```

## Prevention

```markdown
# CLAUDE.md rule
Ensure ANTHROPIC_API_KEY is exported (not just set) in your shell profile. Verify with 'env | grep ANTHROPIC_API_KEY'. For Docker and CI, pass the key explicitly via -e flag or secrets.
```
