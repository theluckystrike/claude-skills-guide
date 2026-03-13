---
layout: post
title: "Claude Code 2026: Skills and Hooks Feature Roundup"
description: "Claude Code 2026 skills and hooks roundup: pdf, tdd, supermemory, webapp-testing, and the hook system with real invocation examples and configuration patterns."
date: 2026-03-13
categories: [guides, tutorials]
tags: [claude-code, claude-skills, hooks, pdf, tdd, supermemory, webapp-testing]
author: "Claude Skills Guide"
reviewed: true
score: 6
---

# Claude Code 2026 New Features: Skills and Hooks Roundup

Claude Code has expanded significantly in 2026. The skills ecosystem now covers over fifty specialized capabilities, and the hook system gives developers structured control over when and how Claude acts. This roundup covers the most impactful additions.

Skills are `.md` files in `~/.claude/skills/`, invoked with `/skill-name`. Hooks are shell commands configured in `~/.claude/settings.json` that fire before and after Claude's actions.

## PDF Processing with the pdf Skill

The `pdf` skill handles technical documentation, contracts, and data extraction. It now supports batch processing and encrypted documents:

```
/pdf process all files in invoices/ and extract the vendor, amount, and date from each. Format as a markdown table.
```

```
/pdf extract the data table from page 7 of technical-spec.pdf. The table has columns: Parameter, Type, Default, Description.
```

```
/pdf merge cover-letter.pdf and portfolio.pdf into application-packet.pdf
```

The skill integrates into documentation pipelines by pulling code examples, API signatures, and configuration blocks from PDF-based resources — technical docs distributed as PDFs are no longer a dead end.

## Frontend Design with the frontend-design Skill

The `frontend-design` skill generates component code and validates UI implementations:

```
/frontend-design create a responsive card component in React with Tailwind: image top, title H3, description text, CTA button. Primary color #1A73E8, 8px spacing grid.
```

```
/frontend-design audit this component for WCAG 2.1 AA violations — check contrast ratios, aria labels, and keyboard navigation: [paste component]
```

```
/frontend-design verify this implementation matches the Figma spec: [paste spec details and component code]
```

The skill's Figma integration (paste spec, receive code) is the most-used new capability in 2026 for frontend teams.

## Test-Driven Development with the tdd Skill

The `tdd` skill guides test-first development and generates meaningful test cases:

```
/tdd write Jest tests for UserService.authenticate() — include valid credential tests, invalid credential tests, and network timeout handling
```

```
/tdd given this failing test, implement the function that makes it pass: [paste test]
```

```
/tdd add property-based tests for this pure function using fast-check: [paste function]
```

Property-based testing support and fuzz input generation are new in 2026 — the skill can now generate randomized inputs to find edge cases that manually written tests miss.

## Memory Management with the supermemory Skill

The `supermemory` skill provides persistent context across sessions:

```
/supermemory store: project-stack = Next.js 14, TypeScript, PostgreSQL, Prisma, Railway deployment
```

```
/supermemory store: linting = ESLint Airbnb config, Prettier, 2-space indent, single quotes
```

```
/supermemory recall project-stack
```

The semantic search capability added in 2026 makes recall more flexible:

```
/supermemory recall any decisions about the database setup
```

Previously this required remembering exact key names. Now the skill searches stored context by meaning.

## Web Testing with the webapp-testing Skill

The `webapp-testing` skill provides Playwright integration for frontend testing:

```
/webapp-testing verify the checkout flow on http://localhost:3000: add item to cart, proceed to checkout, fill in test card 4242424242424242, submit, confirm redirect to /confirmation
```

```
/webapp-testing take a baseline screenshot of /dashboard and save as dashboard-baseline.png
```

```
/webapp-testing compare the current /dashboard against dashboard-baseline.png and report visual differences above 5%
```

Visual regression testing is the most impactful new capability — screenshot comparisons catch layout regressions without manual inspection.

## Hook System

Claude Code's hook system lets you intercept and modify behavior at key decision points. Hooks are shell commands, not JavaScript functions. Configure them in `~/.claude/settings.json`:

```json
{
  "hooks": {
    "preToolUse": [
      {
        "matcher": "Bash",
        "hooks": [
          {
            "type": "command",
            "command": "echo 'Running bash command: ' >> ~/.claude/audit.log"
          }
        ]
      }
    ],
    "postToolUse": [
      {
        "matcher": "Write",
        "hooks": [
          {
            "type": "command",
            "command": "npx prettier --write \"$CLAUDE_TOOL_OUTPUT_PATH\""
          }
        ]
      }
    ]
  }
}
```

### Available Hook Types

- **PreToolUse** — fires before Claude executes a tool (Bash, Write, Edit, etc.)
- **PostToolUse** — fires after tool execution with access to the output
- **Notification** — fires when Claude sends a notification

Hooks receive context about the current operation as environment variables. `CLAUDE_TOOL_NAME`, `CLAUDE_TOOL_INPUT`, and `CLAUDE_TOOL_OUTPUT_PATH` are available depending on the hook type.

### Practical Hook Uses

**Auto-format writes:** Run Prettier after every file write.

**Audit logging:** Log every bash command to a file for review.

**Enforce commit hooks:** Run lint-staged before any git commit the agent makes.

**Block dangerous operations:** Exit with a non-zero code in a PreToolUse hook to block a specific operation and surface an error to Claude.

```json
{
  "hooks": {
    "preToolUse": [
      {
        "matcher": "Bash",
        "hooks": [
          {
            "type": "command",
            "command": "if echo \"$CLAUDE_TOOL_INPUT\" | grep -q 'rm -rf'; then echo 'Blocked: rm -rf not allowed' >&2; exit 1; fi"
          }
        ]
      }
    ]
  }
}
```

## Combining Skills with Hooks

The real leverage comes from combining skills with hooks in automation pipelines. For example, a documentation-to-test workflow:

```
Step 1: /pdf extract all function signatures from api-docs.pdf
Step 2: /tdd generate unit tests for each of these function signatures: [paste output]
```

Add a PostToolUse hook that runs your test suite after every Write operation, so you immediately know if a generated test file is syntactically valid:

```json
{
  "hooks": {
    "postToolUse": [
      {
        "matcher": "Write",
        "hooks": [
          {
            "type": "command",
            "command": "if [[ \"$CLAUDE_TOOL_OUTPUT_PATH\" == *.test.* ]]; then npx jest \"$CLAUDE_TOOL_OUTPUT_PATH\" --passWithNoTests 2>&1 | tail -5; fi"
          }
        ]
      }
    ]
  }
}
```

This gives you immediate feedback on generated tests without manually switching to the terminal.

---

## Related Reading

- [Best Claude Skills for Developers in 2026](/claude-skills-guide/articles/best-claude-skills-for-developers-2026/) — Top skills every developer should know
- [Claude Skills vs Prompts: Which Is Better?](/claude-skills-guide/articles/claude-skills-vs-prompts-which-is-better/) — Decide when skills beat plain prompts
- [Claude Skills Auto Invocation: How It Works](/claude-skills-guide/articles/claude-skills-auto-invocation-how-it-works/) — How skills activate automatically


---

*Built by theluckystrike — More at [zovo.one](https://zovo.one)*
