---
layout: default
title: "Claude Code for Nushell"
description: "Run Claude Code in Nushell with structured data pipelines. Tested setup with copy-paste CLAUDE.md config."
date: 2026-04-18
permalink: /claude-code-for-nushell-workflow-guide/
render_with_liquid: false
categories: [workflow, niche-tools]
tags: [claude-code, nushell, workflow]
---

## The Setup

You are using Nushell, the shell that treats everything as structured data — tables, records, and lists instead of plain text streams. Running Claude Code inside Nushell lets you pipe its output through Nushell's powerful data manipulation commands. But Claude Code generates bash/zsh commands that do not work in Nushell's different syntax.

## What Claude Code Gets Wrong By Default

1. **Generates bash syntax for shell commands.** Claude writes `export VAR=value`, `if [ -f file ]`, and `command1 && command2`. Nushell uses `$env.VAR = value`, `if ("file" | path exists)`, and `command1; command2`.

2. **Uses text-parsing pipes (grep, awk, sed).** Claude pipes output through `grep pattern | awk '{print $2}'`. Nushell returns structured tables — use `where column =~ pattern | get column` instead of text munging.

3. **Writes `.bashrc` or `.zshrc` configurations.** Claude adds environment setup to bash config files. Nushell uses `config.nu` for configuration and `env.nu` for environment variables.

4. **Assumes command output is plain text.** Claude parses JSON output with `jq`. Nushell natively understands JSON, YAML, CSV, and TOML — `open file.json` returns a structured record, and `from json` converts piped text to data.

## The CLAUDE.md Configuration

```
# Nushell Development Environment

## Shell
- Shell: Nushell (nu)
- Config: ~/.config/nushell/config.nu
- Env: ~/.config/nushell/env.nu
- Data-oriented: tables, records, lists — not text streams

## Nushell Rules
- Variables: let name = value (immutable), mut name = value (mutable)
- Environment: $env.VAR_NAME = "value"
- Conditions: if condition { } else { } (no square brackets)
- Pipes return structured data, not text
- Use 'where' instead of grep: ls | where name =~ ".ts"
- Use 'get' instead of awk: ps | get name
- JSON handled natively: open data.json | get users
- String interpolation: $"Hello ($name)"

## Conventions
- Claude Code commands should output plain text (default works)
- Process Claude output with Nushell data commands
- Custom commands in ~/.config/nushell/scripts/
- Use 'complete' for capturing stdout + stderr + exit code
- Path operations: "file.ts" | path parse | get stem
- Never use bash-specific syntax (&&, ||, $(), backticks)
```

## Workflow Example

You want to analyze Claude Code's git output with Nushell's data tools. Prompt Claude Code:

"Show me all TypeScript files changed in the last 5 commits, grouped by directory, with the change count per directory. Use Nushell-compatible commands."

Claude Code should run `git log --oneline -5 --name-only --diff-filter=M` and pipe through Nushell commands: `lines | where $it ends-with ".ts" | each { path parse } | group-by parent | transpose dir files | each { {dir: $in.dir, count: ($in.files | length)} }`.

## Common Pitfalls

1. **Subshell syntax differences.** Claude uses `$(command)` for command substitution. Nushell uses parentheses: `(command)`. The bash `$(...)` syntax causes parse errors in Nushell.

2. **Boolean operator differences.** Claude writes `command1 && command2` for sequential execution. Nushell does not have `&&` — use `; ` for sequential commands or wrap in a block: `do { command1; command2 }`.

3. **Environment variable persistence.** Claude sets env vars with `$env.VAR = value` in a script expecting them in later commands. Nushell scopes environment changes to the current block. Use `load-env` or set variables in `env.nu` for persistence across shell sessions.

## Related Guides

- [Building a CLI Devtool with Claude Code Walkthrough](/building-a-cli-devtool-with-claude-code-walkthrough/)
- [Why Is Claude Code Terminal Based Not GUI](/why-is-claude-code-terminal-based-not-gui-application/)
- [Claude Code for Ghostty Terminal Workflow](/claude-code-for-ghostty-terminal-workflow-tutorial/)

## Related Articles

- [Claude Code For Zksync Era — Complete Developer Guide](/claude-code-for-zksync-era-workflow-guide/)
- [Claude Code for ctags Configuration Workflow Tutorial](/claude-code-for-ctags-configuration-workflow-tutorial/)
- [Claude Code for WASI Workflow Tutorial Guide](/claude-code-for-wasi-workflow-tutorial-guide/)
- [Claude Code for Appsmith Dashboard Workflow Guide](/claude-code-for-appsmith-dashboard-workflow-guide/)
- [Claude Code for Domain Events Workflow Guide](/claude-code-for-domain-events-workflow-guide/)
- [Claude Code for Distributed Tracing Workflow Tutorial](/claude-code-for-distributed-tracing-workflow-tutorial/)
- [Claude Code for Symbol Search Workflow Tutorial Guide](/claude-code-for-symbol-search-workflow-tutorial-guide/)
- [Claude Code Qwik City Routing SSR — Complete Developer Guide](/claude-code-qwik-city-routing-ssr-workflow-tutorial/)
