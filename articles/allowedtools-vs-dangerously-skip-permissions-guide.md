---
layout: default
title: "--allowedTools vs --dangerously-skip-permissions (2026)"
description: "Direct comparison of Claude Code's --allowedTools and --dangerously-skip-permissions flags: security, use cases, and how to migrate from YOLO to allowlist mode."
date: 2026-04-26
author: "Claude Skills Guide"
permalink: /allowedtools-vs-dangerously-skip-permissions-guide/
reviewed: true
categories: [configuration]
tags: [claude, claude-code, permissions, security, cli-flags]
---

# --allowedTools vs --dangerously-skip-permissions

Claude Code offers two CLI flags for unattended operation: `--allowedTools` restricts the agent to specific tools, while `--dangerously-skip-permissions` removes all restrictions. The naming tells you everything -- one flag has "dangerously" in it. This guide shows exactly what each does, when to use which, and how to migrate from the dangerous option to the safe one. Use the [Permissions Configurator](/permissions/) to generate the right tool list for your use case.

## What Each Flag Does

### --allowedTools

Whitelists specific tools. Claude Code can only use the tools you name. Everything else is blocked.

```bash
# Only allow reading files and running tests
claude --allowedTools "Read,Glob,Grep,Bash(npm test)" \
  "Review this code and run the test suite"

# Claude Code CAN:
# - Read any file (Read tool)
# - Search files (Glob, Grep tools)
# - Run npm test (Bash tool, specific command)

# Claude Code CANNOT:
# - Edit files (Edit tool not listed)
# - Write new files (Write tool not listed)
# - Run other bash commands (only npm test allowed)
# - Use MCP tools (none listed)
```

### --dangerously-skip-permissions

Disables ALL permission checks. Every tool call executes immediately without approval.

```bash
# Skip all permission prompts
claude --dangerously-skip-permissions \
  "Fix all lint errors and commit the changes"

# Claude Code CAN:
# - Read, edit, write, delete any file
# - Run ANY bash command (rm -rf, git push --force, etc.)
# - Use all MCP tools
# - Access environment variables
# - Make network requests
# - Everything. No restrictions.
```

## Side-by-Side Comparison

| Capability | --allowedTools | --dangerously-skip-permissions |
|---|---|---|
| File reads | Only if "Read" listed | Always allowed |
| File edits | Only if "Edit" listed | Always allowed |
| File deletion | Only if "Bash(rm *)" listed | Always allowed |
| Specific bash commands | Only if explicitly listed | Always allowed |
| Arbitrary bash commands | Blocked | Always allowed |
| MCP tools | Only if explicitly listed | Always allowed |
| Git operations | Only if explicitly listed | Always allowed |
| Environment variable access | Only if bash allowed | Always allowed |
| Network requests | Only if WebFetch listed | Always allowed |
| Security level | High (principle of least privilege) | None |
| Suitable for production CI | Yes | Only in sandboxed environments |

## Common --allowedTools Configurations

### Read-Only Analysis

```bash
# Code review, architecture analysis, documentation review
claude --allowedTools "Read,Glob,Grep" \
  "Analyze the authentication flow and identify security issues"
```

### Test Runner

```bash
# Run tests and report results
claude --allowedTools "Read,Glob,Grep,Bash(npm test),Bash(npm run lint)" \
  "Run the test suite and lint. Report any failures."
```

### Code Editor (Controlled)

```bash
# Edit code and verify with tests
claude --allowedTools "Read,Glob,Grep,Edit,Bash(npm test),Bash(npm run lint)" \
  "Fix the failing tests in src/auth/__tests__/"
```

### Documentation Generator

```bash
# Generate docs from code
claude --allowedTools "Read,Glob,Grep,Write" \
  "Generate API documentation for all public functions in src/api/"
```

### Full Development (No Destructive)

```bash
# Most things allowed except destructive operations
claude --allowedTools "Read,Glob,Grep,Edit,Write,Bash(npm *),Bash(git diff *),Bash(git status),Bash(git log *)" \
  "Implement the feature described in FEATURE.md"
```

## Migration: YOLO to Allowlist

If you are currently using `--dangerously-skip-permissions`, migrate to `--allowedTools` in three steps:

### Step 1: Audit Current Tool Usage

Run with `--dangerously-skip-permissions` one more time and log which tools Claude Code actually uses:

```bash
# Run with verbose output to see tool usage
claude --dangerously-skip-permissions \
  --output-format json \
  "Do your task" 2>&1 | tee session-log.json

# From the log, extract unique tools used:
# Read, Glob, Grep, Edit, Bash(npm test), Bash(git diff)
```

### Step 2: Build Your Allowlist

Take the tools from step 1 and create your allowlist. Add only what was actually used, plus obvious safe additions:

```bash
# Before (YOLO):
claude --dangerously-skip-permissions "Review and fix"

# After (Allowlist):
claude --allowedTools "Read,Glob,Grep,Edit,Bash(npm test),Bash(npm run lint),Bash(git diff *),Bash(git status)" \
  "Review and fix"
```

### Step 3: Test and Iterate

Run the allowlisted version. If Claude Code hits a permission wall, it will tell you which tool it needs. Add it if it is safe:

```bash
# Claude Code reports: "I need to use Bash(npm run build) but
# it's not in my allowed tools list"

# If safe, add it:
claude --allowedTools "Read,Glob,Grep,Edit,Bash(npm test),Bash(npm run lint),Bash(npm run build),Bash(git diff *),Bash(git status)" \
  "Review and fix"
```

## When YOLO Is Actually Acceptable

There are legitimate cases for `--dangerously-skip-permissions`:

```bash
# 1. Ephemeral CI containers that are destroyed after each run
docker run --rm -e ANTHROPIC_API_KEY=... node:20 \
  bash -c "npx @anthropic-ai/claude-code --dangerously-skip-permissions 'task'"

# 2. Local development with no production access
# (no deploy keys, no database credentials, no cloud access)

# 3. Sandboxed environments with restricted network
# (no outbound connections except Anthropic API)
```

Even in these cases, `--allowedTools` is preferred. The only real argument for YOLO is when you genuinely do not know which tools Claude Code will need and the environment is fully disposable.

## settings.json vs CLI Flags

You can achieve similar results with `settings.json` instead of CLI flags:

```json
// .claude/settings.json (equivalent to --allowedTools)
{
  "permissions": {
    "allow": [
      "Read", "Glob", "Grep", "Edit",
      "Bash(npm test)", "Bash(npm run lint)"
    ]
  }
}
```

```bash
# CLI flag approach (per-session)
claude --allowedTools "Read,Glob,Grep,Edit,Bash(npm test)"

# settings.json approach (persistent)
# Just run: claude
# Settings are loaded automatically
```

Use `settings.json` for persistent project defaults. Use `--allowedTools` for per-session overrides, especially in CI. Generate both with the [Permissions Configurator](/permissions/).

## Try It Yourself

The [Permissions Configurator](/permissions/) generates both `--allowedTools` command lines and `settings.json` files. Select your use case (CI review, automated fixes, local development) and it outputs the exact flag or config you need. No more guessing which tools to include.

## Frequently Asked Questions

<details>
<summary>Can I combine --allowedTools with settings.json permissions?</summary>
Yes. The --allowedTools flag acts as an additional constraint on top of settings.json. If settings.json allows Read, Edit, and Bash(*), but --allowedTools specifies only "Read,Grep", then only Read and Grep are available. The CLI flag narrows the permissions, never expands them. See the <a href="/commands/">Commands Reference</a> for details.
</details>

<details>
<summary>What happens if Claude Code needs a tool not in --allowedTools?</summary>
Claude Code receives an error indicating the tool is not available. It then attempts an alternative approach using only the allowed tools. If no alternative exists, it explains what it needs and why. You can then re-run with the additional tool in the allowlist. The <a href="/configuration/">Configuration Guide</a> covers permission error handling.
</details>

<details>
<summary>Is --dangerously-skip-permissions faster than --allowedTools?</summary>
No measurable difference. Both flags bypass the interactive approval prompt. The only speed difference is in how Claude Code plans its approach -- with --allowedTools it knows upfront which tools are available and plans accordingly, which can sometimes lead to more efficient execution since it avoids attempting unavailable tools.
</details>

<details>
<summary>Can --allowedTools use glob patterns for Bash commands?</summary>
Yes. Use * as a wildcard: Bash(npm run *) allows any npm script. Bash(git diff *) allows git diff with any arguments. Bash(npx prisma *) allows any Prisma CLI command. The pattern matching follows the same rules as settings.json permissions. The <a href="/best-practices/">Best Practices</a> guide covers common patterns.
</details>

<script type="application/ld+json">
{
  "@context": "https://schema.org",
  "@type": "FAQPage",
  "mainEntity": [
    {
      "@type": "Question",
      "name": "Can I combine --allowedTools with settings.json permissions in Claude Code?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "Yes. The --allowedTools flag acts as an additional constraint on top of settings.json. The CLI flag narrows the permissions, never expands them."
      }
    },
    {
      "@type": "Question",
      "name": "What happens if Claude Code needs a tool not in --allowedTools?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "Claude Code receives an error and attempts an alternative approach using only the allowed tools. If no alternative exists, it explains what it needs."
      }
    },
    {
      "@type": "Question",
      "name": "Is --dangerously-skip-permissions faster than --allowedTools?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "No measurable difference. Both bypass the interactive approval prompt. --allowedTools can sometimes be more efficient since Claude Code plans around available tools."
      }
    },
    {
      "@type": "Question",
      "name": "Can --allowedTools use glob patterns for Bash commands?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "Yes. Use * as a wildcard: Bash(npm run *) allows any npm script, Bash(git diff *) allows git diff with any arguments."
      }
    }
  ]
}
</script>



**Find the right skill →** Browse 155+ skills in our [Skill Finder](/skill-finder/).

## Related Guides

**Try it:** Paste your error into our [Error Diagnostic](/diagnose/) for an instant fix.

- [Permissions Configurator](/permissions/) -- Generate --allowedTools lists and settings.json
- [Commands Reference](/commands/) -- All CLI flags including --allowedTools
- [Configuration Guide](/configuration/) -- settings.json reference
- [Best Practices](/best-practices/) -- Security guidelines for choosing permission modes
- [Project Starter](/starter/) -- Set up the right permissions from the start
