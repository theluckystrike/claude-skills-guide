---
layout: default
title: "Claude Code Infinite Loop"
description: "Claude Code stuck in a loop? Interrupt it instantly with keyboard shortcuts, config fixes, and prevention strategies that stop future loops too."
date: 2026-03-14
last_modified_at: 2026-04-17
author: "Claude Skills Guide"
categories: [troubleshooting]
tags: [claude-code, claude-skills, troubleshooting, debugging]
reviewed: true
score: 7
last_tested: "2026-04-21"
permalink: /claude-code-stuck-infinite-loop-how-to-interrupt/
geo_optimized: true
---

When Claude Code appears stuck in an infinite loop, it can interrupt your workflow and consume system resources. This guide covers practical methods to regain control and get your development environment back on track.

## Recognizing the Problem

An infinite loop in Claude Code typically manifests as repeated tool calls, continuously regenerating responses, or the interface becoming unresponsive. You might notice the same tool being called repeatedly with identical parameters, or the conversation spinning without making progress. This can happen when complex prompts trigger recursive behavior or when certain skills interact in unexpected ways.

Common scenarios include working with skills like frontend-design or algorithmic-art that generate code iteratively, or when using tdd workflows that attempt to run tests in a tight loop. The key is recognizing the pattern early and knowing how to interrupt gracefully.

## Signs You Are Stuck

Not every slow response is a loop. Here is how to tell the difference:

| Symptom | Likely Cause | Action |
|---|---|---|
| Same tool called 3+ times in a row | True loop. prompt triggered recursive behavior | Interrupt immediately |
| Incrementally growing output | Long-running generation | Wait, or set a limit |
| No output for 60+ seconds | Network stall or deadlock | Interrupt and retry |
| CPU/fan spins up constantly | Process consuming resources in background | Check process list |
| Terminal cursor blinking but silent | Waiting on stdin or blocked I/O | Ctrl+C once |

If you see the same file being written repeatedly, or the same command being run over and over in the output, you are in a loop. Do not wait. interrupt as soon as you notice the pattern.

## Keyboard Interrupt Methods

The fastest way to interrupt Claude Code is using keyboard shortcuts:

- Ctrl+C (Unix/Linux/macOS): Sends SIGINT, requesting graceful termination
- Ctrl+Z (macOS/Windows): Suspends the process temporarily
- Cmd+. (macOS): Some terminal emulators support this alternative interrupt

When you press Ctrl+C, Claude Code should stop its current operation and return to a prompt. If the first interrupt doesn't work, try pressing it multiple times. the first attempt requests termination, while subsequent attempts may force a harder kill.

```bash
Typical interrupt sequence
^C
Claude Code stops and shows prompt
```

One thing developers often miss: pressing Ctrl+C once sends SIGINT. The process can catch and handle that signal gracefully, which means it may still do cleanup work before exiting. If you press Ctrl+C a second time quickly, most terminal programs treat that as a harder interrupt. A third press will usually force-exit any well-behaved CLI program.

If you are on Windows using PowerShell or CMD, the behavior is slightly different. Ctrl+C still works, but Ctrl+Break (on keyboards that have it) sends a harder termination signal that bypasses graceful shutdown handlers.

## Process-Level Termination

When keyboard interrupts fail, you will need to terminate the process directly:

On macOS:
```bash
Find the process
ps aux | grep claude

Kill specific process
kill -9 <PID>
```

On Linux:
```bash
Similar process management
pkill -f claude-code
or
killall -9 node # if running via Node
```

Using pgrep for quick identification:
```bash
pgrep -f claude | xargs kill -9
```

This approach works when Claude Code becomes completely unresponsive to keyboard interrupts. The `-9` flag sends SIGKILL, which cannot be ignored. it immediately terminates the process.

## Finding the Right Process to Kill

Claude Code runs as a Node.js process in most installations. If you are not sure which process to kill, use a more targeted approach:

```bash
List all Claude-related processes with their full command lines
ps aux | grep -i claude | grep -v grep

Output will look like:
mike 12345 99.0 1.2 /usr/local/bin/node /usr/local/lib/node_modules/@anthropic-ai/claude-code/dist/cli.js

Grab just the PID from the second column
ps aux | grep -i "claude-code" | grep -v grep | awk '{print $2}'

Kill it
kill -15 $(ps aux | grep -i "claude-code" | grep -v grep | awk '{print $2}')
```

Signal `-15` (SIGTERM) is safer than `-9` because it gives the process time to save state. Only escalate to `-9` if `-15` does not work within a few seconds.

## When Multiple Claude Processes Are Running

If you are running multiple Claude Code sessions across different terminal tabs (a common pattern with fleet workflows), you need to be precise about which process to kill. Killing the wrong one will disrupt another working session.

```bash
List processes with their parent PIDs to understand session grouping
ps axo pid,ppid,command | grep claude

Kill only the process from the stuck terminal (use the PID shown in that tab)
kill -15 <specific-PID>
```

## Preventing Infinite Loops

Prevention is more effective than cure. Structure your interactions to avoid triggers:

## Set Clear Iteration Limits

When working with iterative tasks using skills like pdf for document generation or xlsx for spreadsheet automation, specify explicit boundaries:

```
"Generate up to 5 iterations of this report, then stop and show me the results."
```

## Use Confirmation Prompts

Ask Claude Code to confirm before proceeding with recursive operations:

```
"Before running each test cycle, confirm you want to continue."
```

## Break Complex Tasks

Instead of:
```
"Refactor the entire codebase"
```

Try:
```
"Refactor the authentication module first. Wait for my confirmation before proceeding to the next module."
```

## Structuring Prompts That Avoid Loops

The most loop-prone prompts share a common structure: they describe an outcome without a stopping condition. Compare these:

Loop-prone prompt:
```
"Keep running tests until everything passes."
```

Safe prompt:
```
"Run the test suite once. Show me the failures. Do not run tests again until I ask."
```

Loop-prone prompt:
```
"Fix all the bugs in this file."
```

Safe prompt:
```
"Look at the first 3 bugs in this file and fix them. List any additional bugs you find but do not fix them yet."
```

The pattern is always the same: give Claude Code a finite, bounded task with a clear exit condition. Unbounded instructions like "keep going until done" are the primary cause of loops.

## Using CLAUDE.md to Set Behavioral Guardrails

If you use a `CLAUDE.md` file in your project root, you can embed session-wide constraints that reduce loop risk:

```markdown
Behavioral Rules

- Never run any command more than once in a row without user confirmation
- If you are about to repeat an action you already took, stop and ask why
- Maximum 3 tool calls before pausing for user review on open-ended tasks
- Do not batch-process more than 10 files without a checkpoint
```

These rules are loaded at session start and apply throughout the conversation, acting as a persistent safety net even when individual prompts are ambiguous.

## Recovering After an Interrupt

After interrupting Claude Code, your project is in an inconsistent state. Here is how to recover:

1. Check file changes: Review any files modified during the loop
2. Restore unintended changes: Use version control to revert unwanted modifications
3. Clear cache files: Some skills create temporary files that may need cleanup

```bash
Check git status after interrupt
git status

Discard uncommitted changes if needed
git checkout -- .
```

## A Systematic Recovery Checklist

When you interrupt mid-operation, work through this sequence before continuing:

```bash
1. See what changed on disk
git status
git diff --stat

2. Review actual diff to spot partial or duplicate writes
git diff

3. If files look corrupted or truncated, restore them
git checkout -- path/to/file.js

4. If you want to fully discard all changes from the stuck session
git stash

5. Look for any temp files the loop may have created
ls -lt /tmp/ | head -20
ls -lt . | head -20

6. Check for orphaned background processes
jobs
or
ps aux | grep node
```

Step 4 (git stash) is particularly useful because it preserves the changes without committing them. You can review them later and cherry-pick anything useful instead of losing all work from the session.

## Working with Specific Skills

Certain skills benefit from additional precautions:

- tdd: When running test-driven development cycles, set explicit test count limits
- supermemory: Be cautious with recursive memory consolidation operations
- pptx: Large presentation generation can trigger extended processing loops

If you are using canvas-design or algorithmic-art, save your work frequently since these generate multiple output files that could accumulate during a loop.

## Skill-Specific Safe Invocation Patterns

Here are explicit prompt templates that reduce loop risk for the most loop-prone skill types:

For tdd:
```
"Run the test suite once and report which tests fail. Do not attempt to fix failures yet."
```

For frontend-design with iterative generation:
```
"Generate one version of this component. Show it to me. Do not generate variations unless I ask."
```

For pdf/docx document generation:
```
"Generate the document outline first. Wait for my approval before writing full content."
```

For algorithmic-art:
```
"Generate exactly 3 variations of this design. Stop after 3 regardless of quality."
```

## Long-Running Command Safeguards

For Claude Code commands that might take time, use timeout wrappers:

```bash
Run with timeout
timeout 60 claude --continue "your prompt"

Or in your shell profile
alias claude='timeout 300 claude'
```

This ensures no single operation can run indefinitely, providing a safety net when working with complex or experimental prompts.

You can also combine a timeout with a log file to capture partial output before termination:

```bash
Capture output even if terminated by timeout
timeout 120 claude --print "your prompt" 2>&1 | tee /tmp/claude-session.log
```

If the session times out, your log file still contains all the output up to that point. You can review it, understand how far the process got, and resume from a safe checkpoint.

## When to Force Quit

If standard interrupts don't work and you're confident the process is genuinely stuck:

1. Close the terminal window entirely
2. For desktop installations, force quit the application
3. On macOS: Cmd+Option+Escape to bring up Force Quit dialog
4. On Windows: Ctrl+Shift+Escape to open Task Manager

After force quitting, restart Claude Code in a new session. Your conversation history should be preserved depending on your configuration.

## After a Force Quit: Session State Recovery

Claude Code stores conversation context locally. After a force quit, check these locations for recoverable state:

```bash
macOS conversation history location (typical)
ls ~/.claude/

Look for any recent session files
ls -lt ~/.claude/projects/ | head -10
```

In most cases, Claude Code will offer to resume from the last checkpoint when you start a new session. If it does not, you can reconstruct context by copying the relevant portion of your conversation history into a new session prompt.

## Best Practices Summary

- Use Ctrl+C as your first intervention
- Process termination via `kill` when needed
- Structure prompts with clear boundaries and exit conditions
- Add behavioral guardrails in CLAUDE.md for persistent protection
- Set timeouts for long operations using the `timeout` command
- Review file changes after any interrupt with `git status` and `git diff`
- Restart in a fresh session if recovery fails
- Use skill-specific prompt patterns that include stopping conditions

Getting stuck in an infinite loop happens to every developer working with AI assistants. By knowing these interruption techniques, you can maintain control of your development environment and minimize disruption to your workflow.

---

---

<div class="mastery-cta">

I'm a solo developer in Vietnam. 50K Chrome extension users. $500K+ on Upwork. 5 Claude Max subscriptions running agent fleets in parallel.

These are my actual CLAUDE.md templates, orchestration configs, and prompts. Not a course. Not theory. The files I copy into every project before I write a line of code.

**[See what's inside →](https://zovo.one/lifetime?utm_source=ccg&utm_medium=cta-default&utm_campaign=claude-code-stuck-infinite-loop-how-to-interrupt)**

$99 once. Free forever. 47/500 founding spots left.

</div>

Related Reading

- [Claude Code Slow Response How to Fix Latency Issues](/claude-code-slow-response-how-to-fix-latency-issues/). Related: performance and responsiveness issues
- [Best Way to Scope Tasks for Claude Code Success](/best-way-to-scope-tasks-for-claude-code-success/). Better scoping prevents runaway loops
- [Claude Code Keeps Making the Same Mistake Fix Guide](/claude-code-keeps-making-same-mistake-fix-guide/). Another "stuck" behavior pattern and how to fix it
- [Claude Skills Troubleshooting Hub](/troubleshooting-hub/). Central hub for Claude Code behavioral issues

Built by theluckystrike. More at [zovo.one](https://zovo.one)

## See Also

- [Claude Code stuck in planning mode — token drain prevention](/claude-code-stuck-planning-mode-token-drain/)
