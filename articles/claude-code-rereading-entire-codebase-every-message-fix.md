---
title: "Claude Code re-reading entire codebase every message -- fix"
description: "Stop Claude Code from re-reading files it already has in context -- this pattern wastes 10K-30K tokens per session through redundant Read and Grep calls."
permalink: /claude-code-rereading-entire-codebase-every-message-fix/
date: 2026-04-22
last_tested: "2026-04-22"
render_with_liquid: false
---

# Claude Code re-reading entire codebase every message -- fix

## The Problem

Claude Code is reading the same files over and over, re-executing the same grep searches, and re-discovering project structure on every message. Each redundant file read costs 150 tokens overhead plus the file content (500-5,000+ tokens). Five redundant reads per message across a 20-message session wastes 50,000-200,000 tokens. At Opus 4.6 rates, that is $0.75-$15.00 in pure waste per session.

## Quick Fix (2 Minutes)

1. **Add a CLAUDE.md rule:** "Do not re-read files that are already in the conversation context."
2. **Run `/compact` with a focus directive** that explicitly tells the summarizer to preserve file content summaries.
3. **Restate the task with file paths included** so the agent does not need to rediscover them.

```yaml
# Add to CLAUDE.md immediately:
## File Reading Rules
- Before reading any file, check if its contents are already in the conversation
- Never run the same grep or glob search twice in a session
- If a file was read in the last 10 turns and has not been modified, do not re-read it
- Reference file contents from memory, not by re-reading
```

## Why This Happens

Three causes drive redundant file reading:

1. **Post-compaction amnesia** -- after `/compact`, the agent loses detailed file content from the summary. It re-reads files to recover information that was compacted away. This is the most common cause, accounting for an estimated 60% of redundant reads.

2. **Lack of context awareness** -- the agent does not always track which files are already in its context window. Without an explicit reminder, it defaults to reading files "to be sure," especially for long sessions with many exchanges.

3. **Prompt-triggered re-exploration** -- when the user provides a new prompt that references a module or feature, the agent interprets this as a signal to re-explore the relevant code, even if it already has the content in context.

The cost mechanism: each file re-read adds the full file content to the context again. If a 200-line file (approximately 1,500 tokens) is re-read 5 times, that is 7,500 tokens of duplicated content, plus 750 tokens of Read tool overhead, totaling 8,250 wasted tokens.

## The Full Fix

### Step 1: Diagnose

```bash
# Check for redundant reads in the conversation:
# Look for patterns like:
# - Same file path appearing in multiple Read tool calls
# - Same grep pattern being run multiple times
# - Directory listing (ls, glob) of the same directory

# Check the token cost
/cost
# If input tokens are growing faster than expected (>5K per exchange
# with no new information), redundant reads are likely the cause
```

### Step 2: Fix

Add explicit file-tracking rules to CLAUDE.md:

```yaml
# CLAUDE.md -- redundant read prevention
## File Context Tracking
- Maintain a mental list of files already read in this session
- Before calling Read: check if the file content is already in the conversation
- Before calling Grep: check if the same search was already performed
- After /compact: the following files may need re-reading (but check the summary first):
  [List key files for the current task]

## Read Efficiency Rules
- Use offset and limit to read only the specific section needed
- For files over 200 lines: read structure (first 30 lines) then target sections
- Never re-read a file just to "refresh" -- the content has not changed unless explicitly modified
```

### Step 3: Prevent

Structure prompts to include file references so the agent does not need to rediscover:

```bash
# Anti-pattern prompt (triggers re-exploration):
"Fix the auth bug"

# Optimized prompt (eliminates re-reads):
"Fix the JWT expiration bug in src/auth/middleware.ts line 47.
The file uses jsonwebtoken v9.0.2, already read earlier in this session.
The issue: token.exp is in seconds but Date.now() returns milliseconds."
```

Use focused compaction to preserve file content awareness:

```bash
/compact Keep: contents of src/auth/middleware.ts (especially lines 40-60), contents of src/auth/token.ts, test results from auth.test.ts, current task description. Discard: initial exploration, package.json contents, directory listings.
```

## Cost Recovery

```text
After identifying redundant reads:

Typical waste: 10K-30K tokens per session in redundant reads
Remaining session (10 turns): 100K-300K tokens of re-sent duplicates

Fix: Add CLAUDE.md rules + compact with focus directive
Expected reduction: 70-90% fewer redundant reads
Token savings: 7K-27K per session * 20 sessions/month = 140K-540K tokens/month
Cost savings at Opus: $2.10-$40.50/month
Cost savings at Sonnet: $0.42-$8.10/month
```

## Prevention Rules for CLAUDE.md

```yaml
# CLAUDE.md -- copy-paste this section

## No Redundant Reads
- NEVER re-read a file that was read in the last 15 exchanges (unless it was modified)
- NEVER re-run the same grep/glob search in a session
- After /compact: check the compacted summary before re-reading any file
- When referencing file contents: cite from memory ("As seen earlier in middleware.ts line 47...")
- If unsure whether a file is in context: ask the user rather than re-reading
- Maximum file reads per session: 20 (forces efficient reading)
```

## Related Guides

- [The Compaction Strategy: When to /compact and When Not To](/compaction-strategy-when-compact-when-not/) -- preventing post-compaction re-reads
- [Structured Metadata vs Discovery Queries](/structured-metadata-vs-discovery-queries-token-gap/) -- pre-loading context to eliminate discovery reads
- [Claude Code Context Window Management](/claude-code-context-window-management/) -- managing what stays in and what gets evicted
