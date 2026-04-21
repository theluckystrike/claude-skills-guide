---
title: "Large File Read Memory Spike Fix"
permalink: /claude-code-large-file-read-memory-spike-fix-2026/
description: "Fix memory spike when Claude Code reads large files. Use line ranges and targeted reads to avoid loading entire files into the context window."
last_tested: "2026-04-22"
render_with_liquid: false
---

## The Error

```
Error: File read exceeded memory threshold. File 'database-dump.sql' (248MB)
caused memory allocation failure. Process killed by OOM killer.
```

This occurs when Claude Code attempts to read a very large file into memory, causing the Node.js process to spike in memory usage and get killed by the operating system.

## The Fix

```bash
claude "Read only lines 1-100 of database-dump.sql"
```

1. Never ask Claude Code to read entire large files. Specify line ranges instead.
2. For files over 1,000 lines, use targeted reads: `"Read lines 500-600 of src/generated/schema.ts"`.
3. Use grep-based search to find relevant sections first: `"Search for 'createUser' in database-dump.sql and show surrounding 10 lines"`.

## Why This Happens

Claude Code's Read tool loads the entire file content into a string, which then gets serialized into the conversation context as a tool result. A 10MB file becomes roughly 10 million characters of context, consuming tens of thousands of tokens and gigabytes of memory during JSON serialization. The Node.js process cannot handle this and gets terminated.

## If That Doesn't Work

Split large files before working with them:

```bash
split -l 1000 large-file.sql chunks/chunk_
claude "Read chunks/chunk_aa"
```

Use the Bash tool to extract only what you need:

```bash
claude "Run: head -50 database-dump.sql"
```

Add the file to Claude Code's ignore list:

```bash
echo "database-dump.sql" >> .claudeignore
```

## Prevention

```markdown
# CLAUDE.md rule
Never read files larger than 500 lines in full. Use grep or head/tail to extract relevant sections. Add generated files, SQL dumps, and binary files to .claudeignore.
```
