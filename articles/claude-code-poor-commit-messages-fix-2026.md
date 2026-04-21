---
title: "Fix Claude Code Poor Commit Messages (2026)"
description: "Improve Claude Code commit messages with CLAUDE.md templates that enforce conventional commits, scope tagging, and why-not-what descriptions."
permalink: /claude-code-poor-commit-messages-fix-2026/
last_tested: "2026-04-22"
render_with_liquid: false
---

# Fix Claude Code Poor Commit Messages (2026)

Claude Code commits with messages like "Update files" or "Fix bug" — useless for git history. Here's how to get descriptive, conventional commits.

## The Problem

- Generic messages: "Update auth.ts", "Fix issue", "Add changes"
- No scope context: what part of the system changed?
- Missing "why": what was the bug? what feature was added?
- Inconsistent format: sometimes Conventional Commits, sometimes freeform

## Root Cause

Claude Code's commit message generation defaults to describing what files changed, not why they changed. Without a commit message template, it picks the shortest reasonable description.

## The Fix

```markdown
## Commit Messages

### Format
```
type(scope): description

Body explaining WHY this change was needed (not what changed — the diff shows that).
```

### Types
- feat: new feature
- fix: bug fix
- refactor: code change that neither fixes a bug nor adds a feature
- test: adding or updating tests
- docs: documentation only
- chore: build process, dependencies, tooling

### Rules
- Subject line ≤72 characters
- Use imperative mood: "add", "fix", "remove" (not "added", "fixes")
- Body explains the motivation, not the implementation
- Reference issue numbers when applicable: "Closes #123"
- NEVER use generic messages like "Update files" or "Fix bug"

### Examples
GOOD: "fix(auth): prevent double token refresh on concurrent requests"
BAD: "Fix auth.ts"

GOOD: "feat(api): add rate limiting to public endpoints"
BAD: "Add rate limiting"
```

## CLAUDE.md Rule to Add

```markdown
## Commit Quality
- Every commit message must follow Conventional Commits format
- The subject line must describe WHY the change was made
- NEVER commit with messages like "Update", "Fix", "Changes", or "WIP"
- Include scope in parentheses: fix(auth), feat(api), test(orders)
```

## Verification

After Claude Code makes changes and commits:
- Does the message follow `type(scope): description` format?
- Does the body explain why, not what?
- Could someone understand the change purpose from the message alone, without reading the diff?

Related: [Claude Code Best Practices](/claude-code-best-practices-2026/) | [The Claude Code Playbook](/the-claude-code-playbook/) | [CLAUDE.md Best Practices](/claude-md-file-best-practices-guide/)
