---
title: "Fix Claude Code Misunderstanding Requirements (2026)"
description: "Fix Claude Code misunderstanding requirements by structuring prompts with acceptance criteria, examples, and constraint definitions."
permalink: /claude-code-misunderstands-requirements-fix-2026/
last_tested: "2026-04-22"
render_with_liquid: false
---

# Fix Claude Code Misunderstanding Requirements (2026)

You say "add pagination to the user list" and Claude Code adds infinite scroll. You wanted numbered pages with a page selector. The feature works — just not the way you specified.

## The Problem

Claude Code interprets ambiguous requirements by filling in unstated assumptions:
- "Pagination" could mean numbered pages, infinite scroll, or cursor-based
- "Search" could mean client-side filtering, server-side full text, or fuzzy match
- "Authentication" could mean session cookies, JWT, or OAuth
- "Cache" could mean in-memory, Redis, CDN, or browser cache

## Root Cause

Natural language requirements are inherently ambiguous. Claude Code resolves ambiguity using its training data distribution — picking the most common interpretation. If 60% of "pagination" implementations it has seen use infinite scroll, that is what you get.

The [andrej-karpathy-skills](https://github.com/forrestchang/andrej-karpathy-skills) principle "Don't Hide Confusion" is designed exactly for this: the model should ask when requirements are unclear, not guess.

## The Fix

Use the PRD parsing approach from [claude-task-master](https://github.com/eyaltoledano/claude-task-master) (27K+ stars). Task Master structures requirements into unambiguous task definitions with acceptance criteria:

```bash
npm install -g task-master-ai
task-master parse-prd requirements.md
```

### Step 1: Structure Your Requirements

Instead of: "Add pagination to the user list"

Write:
```markdown
## Feature: User List Pagination
### What
Add server-side numbered pagination to GET /api/users

### Acceptance Criteria
- Page size: 25 users per page (configurable via query param)
- Navigation: numbered page buttons (1, 2, 3... N)
- URL updates with page number (?page=2)
- Shows total count: "Showing 26-50 of 234 users"
- First/Last/Prev/Next buttons

### NOT in Scope
- Infinite scroll
- Client-side filtering
- Sort functionality (separate ticket)
```

### Step 2: Add Context for Ambiguous Terms

```markdown
## Terminology (CLAUDE.md)
When I say:
- "pagination" → numbered pages with server-side offset/limit
- "search" → server-side PostgreSQL full-text search via tsvector
- "cache" → Redis cache with TTL, not browser cache
- "auth" → NextAuth.js session cookies, not JWT
- "deploy" → Vercel production deployment via CLI
```

### Step 3: Require Confirmation Before Building

```markdown
## Implementation Protocol
Before writing code for any feature:
1. Restate the requirement in your own words
2. List your assumptions
3. Ask about anything ambiguous
4. Wait for confirmation before proceeding
```

## CLAUDE.md Code to Add

```markdown
## Requirement Handling
- If a requirement has multiple valid interpretations, list them and ask which one
- Never assume scope beyond what is explicitly stated
- If acceptance criteria are missing, ask for them
- "Add X" means the minimal viable implementation unless specified otherwise
```

## Verification

1. Give Claude Code an ambiguous requirement
2. With proper CLAUDE.md rules, it should ask clarifying questions
3. After clarification, the implementation should match exactly
4. Check: Are there features beyond what was requested? If so, scope rules need tightening

## Prevention

Keep a requirements glossary in your CLAUDE.md that grows over time. Every time Claude Code misinterprets a term, add the correct definition.

The [claude-howto](https://github.com/luongnv89/claude-howto) repo provides visual requirement templates with Mermaid diagrams that reduce ambiguity.

For prompt engineering techniques, see the [prompt engineering guide](/claude-code-prompt-engineering-tips-2026/). For task breakdown strategies, read [The Claude Code Playbook](/playbook/). For team-wide requirement standards, check the [team onboarding playbook](/claude-code-team-onboarding-playbook-2026/).
