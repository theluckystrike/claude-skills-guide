---
title: "Claude Code .env File Not Loaded — Fix (2026)"
description: "Fix Claude Code .env file not loaded in project scope. Source the file or use direnv for automatic loading. Step-by-step solution."
permalink: /claude-code-env-file-not-loaded-project-scope-fix/
last_tested: "2026-04-21"
render_with_liquid: false
---

## The Error

```
Error: ANTHROPIC_API_KEY is not set.
  (But it's defined in your .env file)

# Or when Claude Code runs your app:
Error: Missing required environment variable DATABASE_URL
  dotenv: .env file not found or not loaded

# Or:
process.env.API_SECRET is undefined
  (The .env file exists in the project root but variables aren't available)
```

## The Fix

1. **Source the .env file before starting Claude Code**

```bash
# Export all variables from .env into your shell
set -a && source .env && set +a

# Verify the variable is set
echo $ANTHROPIC_API_KEY | cut -c1-10
# Expected: First 10 chars of your key
```

2. **Use direnv for automatic loading (recommended)**

```bash
# Install direnv
brew install direnv  # macOS
# or: sudo apt install direnv  # Ubuntu

# Add to shell profile
echo 'eval "$(direnv hook zsh)"' >> ~/.zshrc
source ~/.zshrc

# Create .envrc that sources .env
echo 'dotenv' > .envrc
direnv allow
```

3. **Verify the fix:**

```bash
# Start Claude Code and verify env vars are available
claude -p "Run: echo \$ANTHROPIC_API_KEY | cut -c1-10" --trust --yes
# Expected: First 10 characters of your API key printed
```

## Why This Happens

`.env` files are not automatically loaded by the shell or by Claude Code. They require explicit loading via `source`, `dotenv` (in Node.js), or a tool like `direnv`. When you start Claude Code from a terminal, it inherits only the shell's current environment variables — not variables defined in `.env` files. Node.js applications typically use the `dotenv` package to load these at runtime, but Claude Code's own process doesn't call `dotenv.config()` on your project's `.env` file.

## If That Doesn't Work

- **Alternative 1:** Add the variables to your shell profile (`~/.zshrc`) for persistent availability across all terminals
- **Alternative 2:** Pass variables inline: `ANTHROPIC_API_KEY=sk-ant-... claude -p "test"`
- **Check:** Run `env | grep -c "."` inside and outside the project directory to compare which variables are loaded

## Prevention

Add to your `CLAUDE.md`:
```markdown
Use direnv with a .envrc file containing `dotenv` to auto-load .env variables. Never commit .env files to git — use .env.example as a template. Verify required environment variables are set before starting long Claude Code sessions.
```

**Related articles:** [Config File Location](/claude-code-config-file-location/), [Invalid API Key After Rotation](/claude-code-error-invalid-api-key-after-rotation-fix/), [Troubleshooting Hub](/troubleshooting-hub/)
