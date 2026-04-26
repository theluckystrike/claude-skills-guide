---
layout: default
title: "Claude Code Permission Modes: Default vs Allowlist vs YOLO (2026)"
description: "Compare Claude Code's three permission modes: Default asks every time, Allowlist auto-approves safe tools, YOLO skips all prompts. Security tradeoffs explained."
date: 2026-04-26
author: "Claude Skills Guide"
permalink: /claude-code-permission-modes-default-allowlist-yolo/
reviewed: true
categories: [configuration]
tags: [claude, claude-code, permissions, security, configuration]
---

# Claude Code Permission Modes: Default vs Allowlist vs YOLO

Claude Code has three permission modes that control how much autonomy the agent gets. Default mode asks you to approve every tool call. Allowlist mode auto-approves specific tools you trust. YOLO mode skips all permission checks entirely. Choosing the right mode determines your balance between safety and speed. Use the [Permissions Configurator](/permissions/) to generate the right settings for your risk tolerance.

The wrong choice has real consequences. Default mode slows you down with constant approval prompts. YOLO mode in production can delete files, run destructive commands, or push to main without confirmation.

## Default Mode: Maximum Safety

Default mode is what you get out of the box. Every tool call requires explicit approval before execution.

```bash
# Default mode (no flags needed)
claude

# What happens:
# Claude: "I'll read src/auth/login.ts"
# [Allow] [Deny]              <-- you must click
# Claude: "I'll edit line 42..."
# [Allow] [Deny]              <-- you must click again
# Claude: "I'll run: npm test"
# [Allow] [Deny]              <-- and again
```

**When to use Default mode:**
- First time using Claude Code on a project
- Working with sensitive code (payment processing, auth, database migrations)
- Onboarding new team members who should learn what Claude Code does
- When you want to review every action before it executes

**Tradeoffs:**
- Safest option -- nothing executes without your approval
- Slowest workflow -- a 10-step task requires 10 approval clicks
- Approval fatigue -- after the 50th "Allow" click, you stop reading the prompts

## Allowlist Mode: Daily Driver

Allowlist mode auto-approves specific tools while blocking everything else. This is the mode most experienced developers settle on.

```json
// .claude/settings.json
{
  "permissions": {
    "allow": [
      "Read",
      "Glob",
      "Grep",
      "Edit",
      "Write",
      "NotebookEdit",
      "Bash(npm test)",
      "Bash(npm run lint)",
      "Bash(npx tsc --noEmit)",
      "Bash(git diff)",
      "Bash(git status)",
      "Bash(git log)"
    ],
    "deny": [
      "Bash(rm -rf *)",
      "Bash(git push --force)",
      "Bash(git reset --hard)",
      "Bash(DROP TABLE)",
      "Bash(sudo *)"
    ]
  }
}
```

**What gets auto-approved:** File reads, edits, writes, and specific safe bash commands you have whitelisted. Claude Code proceeds immediately without prompting.

**What still requires approval:** Any Bash command not in your allow list. This means `npm install new-package`, `git commit`, or any command you have not explicitly permitted.

```bash
# With allowlist configured:
# Claude: "I'll read src/auth/login.ts"     <- auto-approved
# Claude: "I'll edit line 42..."             <- auto-approved
# Claude: "I'll run: npm test"               <- auto-approved
# Claude: "I'll run: npm install express"    <- PROMPTS (not in allow list)
# [Allow] [Deny]
```

**When to use Allowlist mode:**
- Daily development on projects you own
- When you trust Claude Code with reads, edits, and safe commands
- When you want speed without giving up all control
- Team environments with shared settings

## YOLO Mode: CI/CD Only

YOLO mode (`--dangerously-skip-permissions`) disables all permission checks. Every tool call executes immediately, including destructive ones.

```bash
# YOLO mode
claude --dangerously-skip-permissions

# What happens:
# Claude: reads files          <- executes immediately
# Claude: edits code           <- executes immediately
# Claude: runs rm -rf dist/    <- executes immediately (!)
# Claude: runs git push        <- executes immediately (!)
# No approval prompts. Ever.
```

**When to use YOLO mode:**
- CI/CD pipelines where no human is present to approve
- Sandboxed environments (Docker containers, ephemeral VMs)
- Automated batch processing with known-safe operations
- Never on a developer's local machine with production access

**Security implications:**
- Claude Code can delete files, modify git history, and run arbitrary commands
- No guardrails against destructive operations
- If Claude Code misunderstands your intent, there is no safety net
- Only use in environments where the worst-case outcome is acceptable

```yaml
# GitHub Actions with YOLO mode (sandboxed)
name: Claude Code Review
on: pull_request
jobs:
  review:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Run Claude Code
        run: |
          claude --dangerously-skip-permissions \
            "Review the changes in this PR for bugs and security issues.
             Output findings as PR comments."
        env:
          ANTHROPIC_API_KEY: ${{ secrets.ANTHROPIC_API_KEY }}
```

## Comparison Matrix

| Feature | Default | Allowlist | YOLO |
|---|---|---|---|
| File reads | Prompted | Auto-approved | Auto-approved |
| File edits | Prompted | Auto-approved | Auto-approved |
| Safe bash (tests, lint) | Prompted | Auto-approved | Auto-approved |
| Risky bash (install, git push) | Prompted | Prompted | Auto-approved |
| Destructive bash (rm, force push) | Prompted | Denied | Auto-approved |
| Setup effort | None | 5 minutes | None |
| Speed | Slow | Fast | Fastest |
| Safety | Highest | High | Low |
| Best for | New users | Daily work | CI/CD |

## Migration Path: Default to Allowlist

Start with Default mode for a week. Note which tools you approve every time. Those go into your allowlist:

```bash
# Step 1: Use Default mode and track approvals
# After a week, you'll notice patterns:
# - Read: approved 100% of the time
# - Edit: approved 98% of the time
# - Bash(npm test): approved 100%
# - Bash(git commit): approved 80% (sometimes you want to review first)

# Step 2: Add consistently-approved tools to allowlist
# Step 3: Keep occasionally-rejected tools as prompted
```

Use the [Permissions Configurator](/permissions/) to generate your settings.json based on your project stack and risk tolerance. It produces a ready-to-use configuration file.

## Try It Yourself

The [Permissions Configurator](/permissions/) walks you through selecting the right mode and generating a complete settings.json. Answer questions about your project type, team size, and risk tolerance. It outputs a configuration file you can drop directly into `.claude/settings.json`.

## Frequently Asked Questions

<details>
<summary>Can I switch between modes mid-session?</summary>
No. Permission mode is set at session start via CLI flags or settings.json. To change modes, exit the current session and start a new one with different flags. However, within Allowlist mode, you can modify the allow/deny lists in settings.json and they take effect on the next tool call without restarting.
</details>

<details>
<summary>Does Allowlist mode work with MCP tools?</summary>
Yes. MCP tools can be added to the allow list using their full tool name (e.g., "mcp__filesystem__read_file"). Check the <a href="/configuration/">Configuration Guide</a> for MCP tool naming conventions.
</details>

<details>
<summary>Is YOLO mode safe in Docker containers?</summary>
Safer than on bare metal, but not risk-free. Claude Code can still make network requests, write to mounted volumes, and consume excessive resources. Use Docker with read-only filesystem mounts, no network access to production, and resource limits. See <a href="/best-practices/">Best Practices</a> for container security.
</details>

<details>
<summary>What happens if I deny a tool call in Default mode?</summary>
Claude Code acknowledges the denial and attempts an alternative approach. For example, if you deny a file edit, it may suggest the change for you to make manually or try a different implementation strategy. Denials do not terminate the session.
</details>

<script type="application/ld+json">
{
  "@context": "https://schema.org",
  "@type": "FAQPage",
  "mainEntity": [
    {
      "@type": "Question",
      "name": "Can I switch between Claude Code permission modes mid-session?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "No. Permission mode is set at session start via CLI flags or settings.json. To change modes, exit and start a new session. Within Allowlist mode, you can modify allow/deny lists in settings.json and they take effect on the next tool call."
      }
    },
    {
      "@type": "Question",
      "name": "Does Claude Code Allowlist mode work with MCP tools?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "Yes. MCP tools can be added to the allow list using their full tool name, such as mcp__filesystem__read_file."
      }
    },
    {
      "@type": "Question",
      "name": "Is Claude Code YOLO mode safe in Docker containers?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "Safer than on bare metal, but not risk-free. Claude Code can still make network requests and write to mounted volumes. Use Docker with read-only filesystem mounts, no network access to production, and resource limits."
      }
    },
    {
      "@type": "Question",
      "name": "What happens if I deny a Claude Code tool call in Default mode?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "Claude Code acknowledges the denial and attempts an alternative approach. Denials do not terminate the session."
      }
    }
  ]
}
</script>



**Find the right skill →** Browse 155+ skills in our [Skill Finder](/skill-finder/).

## Related Guides

- [Permissions Configurator](/permissions/) -- Generate your ideal settings.json
- [Configuration Guide](/configuration/) -- Full settings.json reference
- [Commands Reference](/commands/) -- CLI flags for permission modes
- [Best Practices](/best-practices/) -- Security guidelines for teams
- [Project Starter](/starter/) -- Set up permissions as part of project initialization
