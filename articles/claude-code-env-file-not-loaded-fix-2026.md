---
title: ".env File Not Loaded by Claude Fix"
permalink: /claude-code-env-file-not-loaded-fix-2026/
description: "Fix .env file not loaded by Claude Code. Export variables manually or use dotenv in CLAUDE.md to make environment variables available to Bash commands."
last_tested: "2026-04-22"
render_with_liquid: false
---

## The Error

```
Error: DATABASE_URL is not defined
  process.env.DATABASE_URL returned undefined
  .env file exists at /project/.env but Claude Code Bash tool did not load it
  dotenv auto-loading does not apply to raw shell commands
```

This appears when Claude Code runs commands that depend on `.env` variables, but the Bash tool does not automatically source `.env` files.

## The Fix

```bash
# Add to CLAUDE.md:
# Before running commands that need environment variables, source .env:
# export $(grep -v '^#' .env | xargs) && your_command
```

1. Instruct Claude Code to source the `.env` file before commands that need it.
2. Or use a tool like `dotenv` to load variables: `npx dotenv -- your_command`.
3. Add the sourcing pattern to your CLAUDE.md for automatic application.

## Why This Happens

The `.env` file is a convention used by frameworks (Next.js, Django, Rails) and libraries (dotenv). These tools load `.env` at application startup, not at shell level. Claude Code's Bash tool starts a fresh shell that does not know about `.env` conventions. Running raw commands like `node script.js` or `psql` directly will not have access to `.env` variables because no dotenv library is loading them at the shell level.

## If That Doesn't Work

Source the `.env` file explicitly:

```bash
set -a && source .env && set +a && node server.js
```

Use npx dotenv to load variables:

```bash
npx dotenv -e .env -- node server.js
```

Pass variables inline for one-off commands:

```bash
DATABASE_URL=postgres://localhost/mydb node migrate.js
```

## Prevention

```markdown
# CLAUDE.md rule
Environment variables are in .env file. Before running any command that needs them, use: 'set -a && source .env && set +a && your_command'. Never hardcode secrets in commands — always reference .env.
```

## See Also

- [Claude Code .env File Not Loaded — Fix (2026)](/claude-code-env-file-not-loaded-project-scope-fix/)
