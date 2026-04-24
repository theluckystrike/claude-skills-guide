---
layout: default
title: "Claude Code for Direnv — Workflow Guide (2026)"
description: "Claude Code for Direnv — Workflow Guide — practical guide with working examples, tested configurations, and tips for developer workflows."
date: 2026-04-18
permalink: /claude-code-for-direnv-workflow-guide/
categories: [workflow, niche-tools]
tags: [claude-code, direnv, workflow]
---

## The Setup

You are using Direnv to automatically load and unload environment variables when entering and leaving project directories. Direnv eliminates the need to manually source `.env` files and ensures each project has its own isolated environment. Claude Code can configure Direnv, but it modifies `.bashrc` or `.zshrc` for environment variables instead of using `.envrc` files.

## What Claude Code Gets Wrong By Default

1. **Adds environment variables to shell config.** Claude writes `export DATABASE_URL=...` in `.zshrc`. Direnv uses per-project `.envrc` files that activate automatically when you `cd` into the directory.

2. **Sources `.env` files manually.** Claude adds `source .env` to shell config or startup scripts. Direnv loads variables automatically with `dotenv` in `.envrc` — no manual sourcing needed.

3. **Uses `.env` for secrets without gitignore.** Claude puts secrets in `.env` and commits it. Direnv uses `.envrc` (which can be committed with non-secret config) and `.env.local` (gitignored for secrets), loaded together.

4. **Ignores Direnv's stdlib functions.** Claude writes raw shell commands in `.envrc`. Direnv provides stdlib functions: `layout node`, `use nix`, `dotenv`, `PATH_add` that handle common setups elegantly.

## The CLAUDE.md Configuration

```
# Direnv Environment Management

## Environment
- Tool: Direnv (auto-load env vars per directory)
- Config: .envrc at project root
- Secrets: .env.local (gitignored), loaded via dotenv_if_exists

## Direnv Rules
- .envrc is the config file (committed to git)
- Run direnv allow after creating/modifying .envrc
- Use dotenv for loading .env files
- Use dotenv_if_exists for optional .env.local
- Use layout node for Node.js PATH setup
- Use PATH_add for adding to PATH
- Never put secrets in .envrc — use .env.local
- eval "$(direnv hook zsh)" required in .zshrc

## Conventions
- .envrc: non-secret environment setup (committed)
- .env.local: secrets and personal config (gitignored)
- .envrc loads .env.local with dotenv_if_exists .env.local
- Use layout commands for language-specific setup
- direnv allow must be run after .envrc changes (security feature)
- Use source_env_if_exists for parent directory env
```

## Workflow Example

You want to set up Direnv for a project with multiple environments. Prompt Claude Code:

"Configure Direnv for this project with a DATABASE_URL, API_KEY, and custom PATH for local bin scripts. Non-secret vars should be in .envrc (committed), secrets in .env.local (gitignored). Include Node.js layout setup."

Claude Code should create `.envrc` with `layout node`, `PATH_add bin`, non-secret variable exports, and `dotenv_if_exists .env.local` at the end. Create `.env.local.example` with placeholder values for secrets, and add `.env.local` to `.gitignore`.

## Common Pitfalls

1. **Forgetting `direnv allow`.** Claude creates `.envrc` but forgets that Direnv blocks untrusted files by default. After creating or modifying `.envrc`, run `direnv allow` to trust the file. This is a security feature to prevent malicious `.envrc` files.

2. **Shell hook not configured.** Claude installs Direnv but does not add the shell hook. Without `eval "$(direnv hook zsh)"` in `.zshrc`, Direnv does not activate when changing directories.

3. **Overriding system PATH.** Claude writes `export PATH=/project/bin` in `.envrc`, replacing the entire PATH. Use `PATH_add bin` instead, which prepends to PATH without removing existing entries.

## Related Guides

- [Best Way to Set Up Claude Code for New Project](/best-way-to-set-up-claude-code-for-new-project/)
- [Building a CLI Devtool with Claude Code Walkthrough](/building-a-cli-devtool-with-claude-code-walkthrough/)
- [Why Is Claude Code Terminal Based Not GUI](/why-is-claude-code-terminal-based-not-gui-application/)

## Related Articles

- [Claude Code For Cloudwatch Rum — Complete Developer Guide](/claude-code-for-cloudwatch-rum-workflow/)
- [Claude Code for Aave Flash Loan Workflow](/claude-code-for-aave-flash-loan-workflow/)
- [Claude Code for Find References Workflow Tutorial](/claude-code-for-find-references-workflow-tutorial/)
- [How Claude Code Changed My — Complete Developer Guide](/how-claude-code-changed-my-development-workflow/)
- [Claude Code for README Generation Workflow Tutorial](/claude-code-for-readme-generation-workflow-tutorial/)
- [Claude Code for Echidna Fuzzing Workflow](/claude-code-for-echidna-fuzzing-workflow/)
- [Claude Code for Metacontroller Workflow Guide](/claude-code-for-metacontroller-workflow-guide/)
- [Claude Code For Go To Definition — Complete Developer Guide](/claude-code-for-go-to-definition-workflow-tutorial/)
