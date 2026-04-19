---
layout: default
title: "Claude Code for Devbox — Workflow Guide"
description: "Create reproducible dev environments with Devbox and Claude Code. Tested setup with copy-paste CLAUDE.md config."
date: 2026-04-18
permalink: /claude-code-for-devbox-jetify-workflow-guide/
render_with_liquid: false
categories: [workflow, niche-tools]
tags: [claude-code, devbox, workflow]
---

## The Setup

You are using Devbox by Jetify to create isolated, reproducible development environments without Docker. Devbox uses Nix under the hood but provides a simple CLI that adds packages to a shell environment defined in `devbox.json`. Claude Code can set up Devbox configurations and manage dependencies, but it confuses Devbox with Docker, Homebrew, or raw Nix.

## What Claude Code Gets Wrong By Default

1. **Writes Dockerfiles for environment isolation.** Claude creates multi-stage Docker builds for dev environments. Devbox achieves the same isolation without containers — `devbox shell` drops you into an environment with your exact package versions.

2. **Uses `brew install` or `apt install` for tools.** Claude reaches for system package managers. Devbox uses `devbox add package@version` which installs from the Nix package registry and pins the exact version in `devbox.json`.

3. **Generates raw Nix expressions.** Claude writes `{ pkgs ? import <nixpkgs> {} }` flake files. Devbox wraps Nix so you never write Nix code — just `devbox add nodejs@20` and it handles the rest.

4. **Ignores the `devbox.json` file.** Claude installs tools globally or in project `node_modules`. Devbox tracks all project dependencies in `devbox.json` which should be committed to version control for reproducibility.

## The CLAUDE.md Configuration

```
# Devbox Development Environment

## Tooling
- Environment: Devbox (Jetify) — Nix-based, no Docker needed
- Config: devbox.json at project root
- Shell: devbox shell (activates isolated environment)
- Services: devbox services for background processes

## Devbox Rules
- Add tools with: devbox add package@version
- Remove tools with: devbox remove package
- Enter environment with: devbox shell
- Run commands in env: devbox run <command>
- Init scripts in devbox.json "shell.init_hook" field
- Services (databases, etc) in devbox.json "services" section
- Never install tools globally — devbox manages everything
- devbox.json and devbox.lock committed to git

## Conventions
- Node.js version pinned: devbox add nodejs@20
- Database services defined in devbox services, not Docker
- Environment variables in .envrc loaded by direnv integration
- Scripts defined in devbox.json "shell.scripts" section
- Use devbox run test, devbox run dev for project commands
```

## Workflow Example

You want to set up a development environment for a Python project with PostgreSQL. Prompt Claude Code:

"Configure a Devbox environment with Python 3.12, Poetry, and PostgreSQL 16. Add an init hook that runs poetry install, and set up PostgreSQL as a Devbox service with automatic startup."

Claude Code should run `devbox add python@3.12 poetry postgresql@16`, configure the `shell.init_hook` in `devbox.json` to run `poetry install`, and set up the PostgreSQL service in the `services` section so it starts automatically with `devbox services start`.

## Common Pitfalls

1. **Mixing system and Devbox installations.** Claude installs some tools via Devbox and others via Homebrew. This defeats reproducibility — a teammate without Homebrew cannot build the project. Everything must go through `devbox add`.

2. **Forgetting to commit `devbox.lock`.** Claude adds `devbox.lock` to `.gitignore` like `package-lock.json` was often ignored in the past. The lock file pins exact Nix store hashes and must be committed for reproducible builds across machines.

3. **Init hook performance on shell entry.** Claude puts heavy build commands in `shell.init_hook` that run every time you type `devbox shell`. Keep init hooks fast (environment variable exports, path setup) and put heavy operations in explicit scripts.

## Related Guides

- [Claude Code for Devenv Nix Development Shell Workflow](/claude-code-for-devenv-nix-development-shell-workflow/)
- [Claude Code Docker Compose Development Workflow](/claude-code-docker-compose-development-workflow/)
- [Best Way to Set Up Claude Code for New Project](/best-way-to-set-up-claude-code-for-new-project/)

## Related Articles

- [Claude Code for LitServe Lightning Workflow Guide](/claude-code-for-litserve-lightning-workflow-guide/)
- [Claude Code for Reentrancy Guard Workflow](/claude-code-for-reentrancy-guard-workflow/)
- [Claude Code For Mitre Attck — Complete Developer Guide](/claude-code-for-mitre-attck-workflow-guide/)
- [Claude Code with Astro Content Collections Workflow](/claude-code-with-astro-content-collections-workflow/)
- [How to Use Web3Modal Wallet Integration (2026)](/claude-code-for-web3modal-wallet-workflow/)
- [Claude Code for Synthetic Monitoring Workflow Guide](/claude-code-for-synthetic-monitoring-workflow-guide/)
- [Claude Code Prompt Management Workflow Guide](/claude-code-prompt-management-workflow-guide/)
- [Claude Code for FreeRTOS Workflow Tutorial Guide](/claude-code-for-freertos-workflow-tutorial-guide/)
