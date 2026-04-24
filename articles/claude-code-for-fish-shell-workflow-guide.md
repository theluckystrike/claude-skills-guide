---
layout: default
title: "Claude Code for Fish Shell (2026)"
description: "Claude Code for Fish Shell — practical guide with working examples, tested configurations, and tips for developer workflows."
date: 2026-04-18
permalink: /claude-code-for-fish-shell-workflow-guide/
categories: [workflow, niche-tools]
tags: [claude-code, fish-shell, workflow]
---

## The Setup

You are running Claude Code in Fish, the user-friendly command line shell with syntax highlighting, autosuggestions, and tab completions out of the box. Fish has a different scripting syntax from bash/zsh, and Claude Code generates bash commands that need translation. The key challenge is getting Claude Code to output Fish-compatible commands.

## What Claude Code Gets Wrong By Default

1. **Generates bash variable syntax.** Claude writes `export VAR=value` and `$()` subshells. Fish uses `set -x VAR value` for exports and `(command)` for command substitution — no dollar-sign parentheses.

2. **Uses bash conditional syntax.** Claude writes `if [ -f file ]; then ... fi`. Fish uses `if test -f file; ...; end` — no square brackets, no `then`, and blocks end with `end` not `fi`.

3. **Creates `.bashrc` configurations.** Claude adds config to `.bashrc` or `.zshrc`. Fish config goes in `~/.config/fish/config.fish` with different syntax.

4. **Uses `&&` and `||` for command chaining.** Claude writes `cmd1 && cmd2`. Fish uses `and`/`or` keywords or the semicolon: `cmd1; and cmd2`. Recent Fish versions support `&&` but the traditional approach differs.

## The CLAUDE.md Configuration

```
# Fish Shell Development Environment

## Shell
- Shell: Fish (user-friendly, NOT bash/zsh)
- Config: ~/.config/fish/config.fish
- Functions: ~/.config/fish/functions/ (one file per function)
- Variables: set, set -x (export), set -U (universal)

## Fish Rules
- Variables: set name value (NOT export name=value)
- Export: set -x NAME value
- Command sub: (command) NOT $(command)
- Conditionals: if test condition; ...; end
- Loops: for item in list; ...; end
- Functions: function name; ...; end
- No source .bashrc — Fish has its own syntax
- Path: fish_add_path /new/path (NOT export PATH=...)

## Conventions
- Claude Code runs fine in Fish — output is universal
- Shell commands from Claude Code may need bash-to-fish translation
- Use fish_add_path for PATH modifications
- Abbreviations instead of aliases: abbr -a gs git status
- Functions auto-loaded from config/fish/functions/name.fish
- Universal variables persist across sessions: set -U VAR value
- Use string command for text processing (Fish built-in)
```

## Workflow Example

You want to set up Fish for a new development project. Prompt Claude Code:

"Set up my Fish shell for this Node.js project. Add the project's bin directory to PATH, create abbreviations for common npm scripts, and set environment variables for the dev database."

Claude Code should use `fish_add_path ./node_modules/.bin`, `abbr -a nr 'npm run'`, `abbr -a nd 'npm run dev'`, and `set -x DATABASE_URL 'postgresql://...'` in `config.fish` — all in Fish syntax, not bash.

## Common Pitfalls

1. **Sourcing bash scripts in Fish.** Claude writes `source .env` expecting bash env file parsing. Fish cannot source bash-format env files. Use `bass source .env` (via bass plugin) or convert to Fish syntax: `set -x VAR value` per line.

2. **Using `export` keyword.** Claude writes `export PATH="$PATH:/new"`. Fish does not have an `export` keyword (recent versions add it for compatibility, but `set -x` is idiomatic). Use `set -x VAR value` for exported variables.

3. **Wildcard and glob differences.** Claude uses `**/*.ts` in commands. Fish handles globs differently from bash — `**` recursive glob works but some edge cases differ. Test glob patterns in Fish before relying on them in scripts.

## Related Guides

- [Building a CLI Devtool with Claude Code Walkthrough](/building-a-cli-devtool-with-claude-code-walkthrough/)
- [Why Is Claude Code Terminal Based Not GUI](/why-is-claude-code-terminal-based-not-gui-application/)
- [Claude Code for Ghostty Terminal Workflow](/claude-code-for-ghostty-terminal-workflow-tutorial/)

## Related Articles

- [Claude Code for Carvel imgpkg Workflow Tutorial](/claude-code-for-carvel-imgpkg-workflow-tutorial/)
- [Claude Code for Hackathon Development Workflow](/claude-code-for-hackathon-development-workflow/)
- [How to Use VSCode Reload: Hot Config (2026)](/claude-code-for-hot-config-reload-workflow-guide/)
- [Is Claude Code Good Enough For — Complete Developer Guide](/is-claude-code-good-enough-for-senior-developer-workflows/)
- [Claude Code for Bottleneck Identification Workflow](/claude-code-for-bottleneck-identification-workflow/)
- [Claude Code for Quantization with bitsandbytes Workflow](/claude-code-for-quantization-with-bitsandbytes-workflow/)
- [Claude Code for Flux Bootstrap Workflow Tutorial](/claude-code-for-flux-bootstrap-workflow-tutorial/)
- [Claude Code for Homebrew Bundle Workflow Tutorial](/claude-code-for-homebrew-bundle-workflow-tutorial/)
- [Shell RC File Not Sourced Error — Fix (2026)](/claude-code-shell-rc-not-sourced-fix-2026/)
