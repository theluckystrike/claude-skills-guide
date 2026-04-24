---
layout: default
title: "Claude Code for fd (Find Alternative)"
description: "Find files faster with fd and Claude Code. Tested setup with copy-paste CLAUDE.md config."
date: 2026-04-18
permalink: /claude-code-for-fd-find-alternative-workflow-guide/
render_with_liquid: false
categories: [workflow, niche-tools]
tags: [claude-code, fd, workflow]
---

## The Setup

You are using fd as a replacement for `find`, a fast, user-friendly file finder written in Rust. fd provides intuitive syntax, colorized output, respects `.gitignore`, and is significantly faster than GNU find. Claude Code can search for files, but it generates verbose `find` commands with confusing flag combinations instead of fd's simple syntax.

## What Claude Code Gets Wrong By Default

1. **Uses `find` with complex syntax.** Claude writes `find . -name "*.ts" -type f -not -path "*/node_modules/*"`. fd simplifies this to `fd -e ts` — it is recursive, ignores gitignored files, and skips hidden directories by default.

2. **Chains find with xargs and grep.** Claude pipes `find . -name "*.ts" | xargs grep "pattern"`. fd integrates with ripgrep better — `fd -e ts -x rg "pattern"` runs ripgrep on each matched file with proper parallelism.

3. **Writes escape-heavy regex for find.** Claude uses `find . -regex ".*\.\(ts\|tsx\)$"`. fd uses simplified regex by default — `fd "\.(ts|tsx)$"` works without escaping parentheses and pipes.

4. **Ignores fd's exec capabilities.** Claude pipes fd output to `xargs` for batch operations. fd has built-in `-x` (exec per file) and `-X` (exec with all files as args) that handle special characters and parallelize automatically.

## The CLAUDE.md Configuration

```
# fd File Finder

## Tools
- Finder: fd (find alternative, Rust-based)
- Features: fast, gitignore-aware, colorized
- Regex: simplified regex (no excessive escaping)
- Exec: built-in parallel execution

## fd Rules
- Basic: fd pattern (recursive search from current dir)
- Extension: fd -e ts (TypeScript files only)
- Type: fd -t f (files), fd -t d (directories)
- Hidden: fd -H (include hidden files)
- No ignore: fd -I (include gitignored files)
- Exec: fd -e ts -x wc -l (count lines per file)
- Exec all: fd -e ts -X cat (all files as args)

## Conventions
- Use fd for all file finding, not find
- fd -e ext for extension filtering
- fd -t f/d/l for type filtering (file/dir/symlink)
- fd pattern path/ to search specific directory
- fd -x cmd for per-file execution
- fd -X cmd for batch execution
- fd --changed-within 1h for recent files
```

## Workflow Example

You want to find and process specific files across a project. Prompt Claude Code:

"Find all TypeScript test files modified in the last 24 hours, count lines in each, and list the 10 largest. Use fd instead of find for better performance and simpler syntax."

Claude Code should run `fd -e test.ts -e spec.ts --changed-within 24h -x wc -l | sort -rn | head -10` which finds test files modified recently, counts lines in each, sorts by line count descending, and shows the top 10.

## Common Pitfalls

1. **Expecting find flag syntax.** Claude uses `fd -name "*.ts"`. fd uses positional arguments for patterns and short flags — `fd "*.ts"` or `fd -e ts`, not `-name`.

2. **Pattern matches full path by default.** Claude writes `fd "src/utils"` expecting it to match only files in that directory. fd matches the pattern against file paths — use `fd pattern path/` with the path argument to restrict the search directory.

3. **Missing `--hidden` for dotfiles.** Claude searches for `.env` or `.eslintrc` without `--hidden`. fd skips hidden files by default (unlike find). Add `-H` when searching for dotfiles: `fd -H ".env"`.

## Related Guides

- [Claude Code for Ripgrep Workflow Guide](/claude-code-for-ripgrep-workflow-guide/)
- [Building a CLI Devtool with Claude Code Walkthrough](/building-a-cli-devtool-with-claude-code-walkthrough/)
- [Why Is Claude Code Terminal Based Not GUI](/why-is-claude-code-terminal-based-not-gui-application/)
