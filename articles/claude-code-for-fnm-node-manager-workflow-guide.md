---
layout: default
title: "Claude Code for fnm Node Manager — Guide"
description: "Manage Node.js versions with fnm and Claude Code. Tested setup with copy-paste CLAUDE.md config."
date: 2026-04-18
permalink: /claude-code-for-fnm-node-manager-workflow-guide/
render_with_liquid: false
categories: [workflow, niche-tools]
tags: [claude-code, fnm, workflow]
---

## The Setup

You are managing Node.js versions with fnm (Fast Node Manager), a Rust-based version manager that is significantly faster than nvm. fnm provides automatic version switching via `.node-version` or `.nvmrc` files, cross-platform support (macOS, Linux, Windows), and near-instant version switches. Claude Code can set up Node.js, but it defaults to nvm commands and configuration.

## What Claude Code Gets Wrong By Default

1. **Uses nvm commands.** Claude writes `nvm install 20` and `nvm use 20`. fnm uses `fnm install 20` and `fnm use 20` — while similar, some flags and behaviors differ.

2. **Sources nvm.sh in shell config.** Claude adds `source ~/.nvm/nvm.sh` to `.zshrc`. fnm uses `eval "$(fnm env)"` for shell integration — it does not use the nvm initialization script.

3. **Creates .nvmrc without considering fnm.** Claude creates `.nvmrc` files, which fnm supports, but fnm also supports `.node-version` files which are the more standard convention used by other tools like Volta and asdf.

4. **Does not leverage fnm's speed.** Claude treats version switching as a slow operation. fnm switches versions instantly — there is no delay, so workflows can switch versions between commands without performance concerns.

## The CLAUDE.md Configuration

```
# fnm Node Version Management

## Tooling
- Manager: fnm (Fast Node Manager, Rust-based)
- Config: .node-version file at project root
- Shell: eval "$(fnm env --use-on-cd)" in shell config
- Speed: near-instant version switching

## fnm Rules
- Install: fnm install 20 (or fnm install --lts)
- Use: fnm use 20 (or auto from .node-version)
- Default: fnm default 20
- List: fnm list (installed), fnm list-remote (available)
- Config file: .node-version (preferred) or .nvmrc
- Auto-switch: fnm env --use-on-cd enables auto-switching

## Conventions
- .node-version at project root with version number
- eval "$(fnm env --use-on-cd)" in .zshrc/.bashrc
- Use .node-version over .nvmrc for compatibility
- fnm install before fnm use for new versions
- Pin exact version in .node-version (e.g., "20.12.0")
- CI: fnm install && fnm use before npm commands
```

## Workflow Example

You want to configure a project with fnm and automatic version switching. Prompt Claude Code:

"Set up fnm for our project with Node.js 20 LTS. Create the version file, add shell integration with auto-switching to the zsh config, and update the CI workflow to use fnm instead of the setup-node action."

Claude Code should create `.node-version` with `20`, add `eval "$(fnm env --use-on-cd)"` to `.zshrc`, and update the CI workflow with `fnm install` and `fnm use` commands before running npm commands.

## Common Pitfalls

1. **Shell integration missing auto-switch.** Claude adds `eval "$(fnm env)"` without `--use-on-cd`. Without `--use-on-cd`, fnm does not automatically switch versions when you `cd` into a project with a `.node-version` file — you have to run `fnm use` manually.

2. **Version file format mismatch.** Claude writes `v20.12.0` with the `v` prefix in `.node-version`. Some tools expect the version without the prefix. Use `20.12.0` (no `v`) for maximum compatibility across fnm, Volta, and other managers.

3. **CI not finding fnm.** Claude installs fnm in CI but the PATH is not updated. Run `eval "$(fnm env)"` after installation in CI to add fnm's shims to the PATH before running `node` or `npm` commands.

## Related Guides

- [Claude Code for Mise Dev Tool Manager Workflow Guide](/claude-code-for-mise-dev-tool-manager-workflow-guide/)
- [Best Way to Set Up Claude Code for New Project](/best-way-to-set-up-claude-code-for-new-project/)
- [Claude Code for Bun Runtime Workflow Guide](/claude-code-for-bun-runtime-workflow-guide/)

## Related Articles

- [Claude Code SDK Development Workflow Guide](/claude-code-sdk-development-workflow-guide/)
- [Claude Code for Wing Cloud Language Workflow](/claude-code-for-wing-cloud-language-workflow/)
- [Claude Code for ScoutSuite Audit Workflow Guide](/claude-code-for-scoutsuite-audit-workflow-guide/)
- [Claude Code for RabbitMQ Topic Exchange Workflow](/claude-code-for-rabbitmq-topic-exchange-workflow/)
- [Claude Code for Upbound Marketplace Workflow Guide](/claude-code-for-upbound-marketplace-workflow-guide/)
- [Claude Code for Lottie Animation Workflow Tutorial](/claude-code-for-lottie-animation-workflow-tutorial/)
- [Claude Code for License Scanning Workflow Tutorial](/claude-code-for-license-scanning-workflow-tutorial/)
- [Claude Code for SharedArrayBuffer Workflow](/claude-code-for-shared-array-buffer-workflow/)
