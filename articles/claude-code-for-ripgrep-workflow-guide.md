---
layout: default
title: "Claude Code for Ripgrep"
description: "Search codebases faster with Ripgrep and Claude Code. Tested setup with copy-paste CLAUDE.md config."
date: 2026-04-18
permalink: /claude-code-for-ripgrep-workflow-guide/
render_with_liquid: false
categories: [workflow, niche-tools]
tags: [claude-code, ripgrep, workflow]
---

## The Setup

You are using Ripgrep (`rg`) as your primary code search tool — a faster alternative to grep that respects `.gitignore`, searches recursively by default, and supports PCRE2 regex. When Claude Code needs to find patterns across your codebase, Ripgrep provides results significantly faster than grep. Claude Code can use Ripgrep, but it defaults to basic grep syntax and misses Ripgrep's powerful features.

## What Claude Code Gets Wrong By Default

1. **Uses `grep -r` instead of `rg`.** Claude writes `grep -rn "pattern" .` which is slower and searches ignored files. Ripgrep is faster, respects `.gitignore`, and defaults to recursive search.

2. **Misses Ripgrep's type filtering.** Claude greps through all files then pipes through `grep -l "*.ts"`. Ripgrep has `--type ts` (or `-t ts`) for built-in filetype filtering without extra commands.

3. **Pipes through `grep` for secondary filtering.** Claude chains `rg pattern | grep filter`. Ripgrep supports `--glob` for path filtering and PCRE2 regex for complex patterns — multiple greps are usually unnecessary.

4. **Does not use `--json` for structured output.** Claude parses Ripgrep's text output with awk/sed. Ripgrep has `--json` output format for machine-readable results.

## The CLAUDE.md Configuration

```
# Ripgrep Search Workflow

## Search
- Tool: Ripgrep (rg) — fast recursive code search
- Default: recursive, .gitignore-aware, no binary files
- Regex: PCRE2 enabled with -P flag

## Ripgrep Rules
- Basic: rg "pattern" (recursive from current dir)
- Type filter: rg -t ts "pattern" (TypeScript files only)
- Glob filter: rg --glob "*.test.ts" "pattern"
- Case insensitive: rg -i "pattern"
- Fixed string (no regex): rg -F "exact.match()"
- Context: rg -C 3 "pattern" (3 lines before/after)
- Count: rg -c "pattern" (count per file)
- Files only: rg -l "pattern" (list matching files)
- Replace: rg "old" --replace "new" (preview only)

## Conventions
- Use rg for all codebase searches, not grep
- Use -t flag for language filtering
- Use -F for literal string search (avoids regex escaping)
- Use --glob to include/exclude paths
- Use -l for file listing (pipe to other commands)
- Use rg -c for codebase-wide usage counts
- Use --json for machine-parseable output
```

## Workflow Example

You want to find all usage of a deprecated API across the codebase. Prompt Claude Code:

"Find all files that use the deprecated `fetchUser` function, excluding test files and node_modules. Show the filename and line number for each occurrence, with 2 lines of context."

Claude Code should run `rg "fetchUser" -t ts -t tsx --glob "!*test*" -C 2 -n` which searches TypeScript files, excludes test files, shows 2 lines of context, and includes line numbers — all in a single command.

## Common Pitfalls

1. **Regex metacharacters not escaped.** Claude searches for `User.findOne({id})` without escaping dots and braces. Use `-F` for literal strings: `rg -F "User.findOne({id})"` avoids regex interpretation entirely.

2. **Searching in wrong directory scope.** Claude runs `rg` from the home directory, searching everything. Always `cd` to the project root or specify the path: `rg "pattern" ./src` to limit scope.

3. **Missing `--hidden` for dotfiles.** Claude searches for config patterns but misses `.env`, `.eslintrc`, etc. Ripgrep skips hidden files by default. Add `--hidden` to include dotfiles, or `--no-ignore` to also search gitignored files.

## Related Guides

- [Best Way to Set Up Claude Code for New Project](/best-way-to-set-up-claude-code-for-new-project/)
- [Building a CLI Devtool with Claude Code Walkthrough](/building-a-cli-devtool-with-claude-code-walkthrough/)
- [Why Is Claude Code Terminal Based Not GUI](/why-is-claude-code-terminal-based-not-gui-application/)
