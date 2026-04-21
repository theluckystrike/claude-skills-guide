---
layout: default
title: "Fix Claude Code 'Bun Has Crashed' Error (2026)"
description: "Resolve the 'Bun has crashed' error in Claude Code with memory fixes, version updates, and diagnostic steps to get back to coding. Updated for 2026."
date: 2026-04-17
last_modified_at: 2026-04-17
author: "Claude Skills Guide"
permalink: /claude-code-bun-has-crashed/
categories: [guides]
tags: [claude-code, claude-skills, bun, crash-fix]
reviewed: true
score: 7
geo_optimized: true
last_tested: "2026-04-22"
---

The "Bun has crashed" message in Claude Code means the Bun runtime hit a fatal error — usually a segfault or out-of-memory condition. This guide gives you the exact diagnostic and fix steps to resolve it permanently.

## The Problem

You are working in Claude Code and suddenly see `Bun has crashed. Report this as a bug:` followed by a crash report with a stack trace. The process exits immediately, and you lose your current conversation context. This is different from a handled error — Bun itself has terminated due to an unrecoverable condition.

## Quick Solution

**Step 1:** Check the crash report. Bun prints a crash URL or stack trace. Look for the key indicator:

```bash
# If the crash just happened, check the most recent crash report:
ls -la /tmp/bun-crash-*
```

**Step 2:** Update Bun to the latest version. Most "Bun has crashed" issues are fixed in newer releases:

```bash
bun upgrade
bun --version
```

Verify you are on version 1.1+ at minimum.

**Step 3:** If the crash happens specifically during large file operations, increase memory:

```bash
export BUN_JSC_FORCE_RAM_SIZE=8192
claude
```

**Step 4:** If the crash is reproducible (happens every time you do the same operation), identify the trigger. Run with debug output:

```bash
BUN_DEBUG_QUIET_LOGS=0 BUN_GARBAGE_COLLECTOR_LEVEL=2 claude 2>/tmp/bun-debug.log
```

Then reproduce the crash and check the log:

```bash
tail -100 /tmp/bun-debug.log
```

**Step 5:** If nothing else works, switch to Node.js as your runtime:

```bash
npm install -g @anthropic-ai/claude-code
claude
```

This uses Node.js instead of Bun, bypassing the crash entirely.

## How It Works

"Bun has crashed" is Bun's top-level crash handler for unrecoverable errors. It triggers when JavaScriptCore (Bun's JS engine) encounters a segmentation fault, when the process runs out of memory, or when an internal assertion fails. Claude Code is a memory-intensive application — it holds conversation context, file buffers, and tool outputs in the JS heap simultaneously. Under Bun, the JSC garbage collector may handle these allocation patterns differently than V8 (Node.js), occasionally triggering a crash. The crash handler captures a stack trace and suggests filing a bug report with the Bun team.

## Common Issues

**Segfault during WebSocket operations.** Claude Code uses streaming WebSocket connections to the API. Bun's WebSocket implementation has had segfault bugs in certain connection lifecycle scenarios. Upgrading Bun usually fixes this.

**Crash on macOS after sleep/wake.** If your Mac went to sleep and you resume Claude Code, the network connection may be in a broken state that triggers a Bun crash. Close and reopen your terminal, then restart Claude Code.

**Crash in Docker containers with low memory.** If running Claude Code in a container with less than 2GB RAM, Bun may crash under memory pressure. Increase the container's memory limit:

```bash
docker run --memory=4g your-image claude
```

## Example CLAUDE.md Section

```markdown
# Crash Prevention

## Runtime
- Bun runtime with BUN_JSC_FORCE_RAM_SIZE=8192
- If "Bun has crashed" occurs, switch to Node.js: npm install -g @anthropic-ai/claude-code

## Stability Rules
- Commit code before large refactoring operations
- Do not read files larger than 1MB — use grep to find relevant sections
- Limit concurrent file operations to avoid memory spikes
- If working in Docker, ensure container has minimum 4GB RAM

## After a Crash
- Check git status for any partial writes
- Review /tmp/bun-crash-* for crash reports
- Restart Claude Code with: claude --no-resume
- Report persistent crashes to github.com/oven-sh/bun/issues
```

## Best Practices

1. **Auto-save with git commits.** Before any large operation (multi-file refactor, dependency update), commit your work. A "Bun has crashed" error can leave files in a partially modified state.

2. **Set BUN_JSC_FORCE_RAM_SIZE in your shell profile.** Do not rely on defaults. Add `export BUN_JSC_FORCE_RAM_SIZE=8192` to `~/.zshrc` so every Claude Code session has adequate memory.

3. **Keep both Node.js and Bun installed.** When Bun crashes block your work, switching to Node.js is the fastest path back to productivity. Have both runtimes ready.

4. **File crash reports.** The Bun team actively fixes crash bugs. Reporting the crash URL from the error message helps them prioritize fixes.

5. **Monitor for patterns.** If crashes happen at specific times (after sleep, during large reads, during network reconnects), document the pattern and avoid the trigger while waiting for a fix.

---

---

<div class="mastery-cta">

I'm a solo developer in Vietnam. 50K Chrome extension users. $500K+ on Upwork. 5 Claude Max subscriptions running agent fleets in parallel.

These are my actual CLAUDE.md templates, orchestration configs, and prompts. Not a course. Not theory. The files I copy into every project before I write a line of code.

**[See what's inside →](https://zovo.one/lifetime?utm_source=ccg&utm_medium=cta-default&utm_campaign=claude-code-bun-has-crashed)**

$99 once. Free forever. 47/500 founding spots left.

</div>

Related Reading

- [Claude Code Bun Crash Fix](/claude-code-bun-crash/)
- [Claude Code Docker Build Failed Fix](/claude-code-docker-build-failed-fix/)
- [Best Way to Use Claude Code for Debugging Sessions](/best-way-to-use-claude-code-for-debugging-sessions/)

Built by theluckystrike. More at [zovo.one](https://zovo.one)
