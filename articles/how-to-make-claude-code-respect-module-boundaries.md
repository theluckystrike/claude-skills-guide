---

layout: default
title: "How to Make Claude Code Respect Module"
description: "Practical techniques for controlling Claude Code's context awareness across module boundaries in multi-file projects. Learn to scope Claude's knowledge."
date: 2026-03-14
last_modified_at: 2026-04-17
author: "Claude Skills Guide"
categories: [guides]
tags: [claude-code, claude-skills, module-boundaries, context-management, project-structure]
permalink: /how-to-make-claude-code-respect-module-boundaries/
reviewed: true
score: 7
geo_optimized: true
---

When working on large codebases, Claude Code often pulls context from across your entire project. This behavior works well for small projects but becomes problematic when you need focused analysis within specific module boundaries. Here's how to control Claude's scope effectively.

## The Module Boundary Problem

Claude Code excels at understanding project-wide relationships, but sometimes you need it to stay within a specific module. For example, when using the tdd skill to write tests for a single service, you don't want Claude pulling in unrelated code from other modules. Similarly, when the pdf skill generates documentation, it should reference only the relevant component.

The problem compounds as projects grow. A mono-repo with eight services, a shared library, an admin panel, and a CLI tool contains tens of thousands of lines across hundreds of files. When Claude is asked to "add input validation to the user service," it may scan models from the payment service, pull in utility functions from the admin panel, and generate suggestions that technically work but import across boundaries you've deliberately kept separate. The result is subtle coupling that makes services harder to deploy and test independently.

The solution involves combining project-specific configuration files, explicit directory structure, and targeted prompts that make the desired scope unambiguous.

## Understanding How Claude Selects Context

Before diving into techniques, it helps to understand what drives Claude's context selection. Claude Code reads files it discovers through a combination of:

- The current working directory when the session starts
- Files you explicitly mention in prompts
- Files it traverses when following imports or references
- Configuration files it discovers at startup (`CLAUDE.md`, `.claude/settings.json`)

When you start a session from your project root, Claude has access to everything. When you start from a subdirectory and also have a `CLAUDE.md` there, Claude reads that instruction file first and uses it as a framing document for the entire session. This is the fundamental lever you control.

## Using CLAUDE.md for Module Scoping

Create a `CLAUDE.md` file in your module's root directory. This file instructs Claude Code to treat that directory as an isolated context.

Navigate to the module you want to isolate:

```bash
cd /your-project/backend-api
```

Create `CLAUDE.md` in the module directory:

```markdown
Module: backend-api

This directory contains the authentication service.
- API endpoints in `src/routes/`
- Database models in `src/models/`
- Business logic in `src/services/`

Scope Rules

Do not reference code outside this directory unless explicitly asked.

When generating tests, import only from within this module.
When suggesting refactors, do not propose changes that require importing from ../payment or ../admin.
This module exposes its public API through src/index.ts. treat that as the external boundary.
```

The more specific you are about what "outside the boundary" means, the more reliably Claude respects it. Simply saying "don't go outside" is weaker than naming the specific directories that are off-limits.

When you start a session with `claude` from this directory, Claude reads the local `CLAUDE.md` and limits its context accordingly.

## CLAUDE.md Placement Strategy

You can have multiple `CLAUDE.md` files at different directory levels. Claude reads them hierarchically. the root-level file provides broad project context, while module-level files narrow the scope. This lets you communicate both global constraints and local ones simultaneously:

```
/your-project/
 CLAUDE.md # "This is a mono-repo. Services must not import across boundaries."
 backend-api/
 CLAUDE.md # "This module owns authentication. Scope to src/ here."
 frontend/
 CLAUDE.md # "This module owns the React app. Do not touch backend code."
 shared/
 CLAUDE.md # "Shared utilities only. No business logic lives here."
```

## Project-Wide Boundaries with .claude/settings.json

For more granular control across multiple modules, create a `.claude/settings.json` in your project root:

```json
{
 "projectBounds": {
 "enabled": true,
 "modules": [
 {
 "name": "frontend",
 "path": "./frontend",
 "description": "React components and state management"
 },
 {
 "name": "backend",
 "path": "./backend",
 "description": "Node.js API and database layer"
 },
 {
 "name": "shared",
 "path": "./shared",
 "description": "Types and utilities used by both"
 }
 ]
 }
}
```

This configuration helps Claude understand which modules exist and their relationships, enabling more accurate context selection when you reference modules by name in prompts.

## Skill-Specific Boundary Techniques

Different skills benefit from different scoping approaches.

## For Testing with tdd

When using the tdd skill, explicitly scope your requests:

```
/tdd Write unit tests for the auth module only. Located at src/auth/
```

This prevents the skill from analyzing unrelated modules and generates more focused test coverage. You can go further by specifying what the tests should not touch:

```
/tdd Write unit tests for src/auth/login.service.ts
Only mock dependencies within src/auth/. Do not import from src/payment/ or src/user/.
```

## For Documentation with pdf

The pdf skill works similarly. Scope documentation requests to avoid pulling in tangential modules:

```
/pdf Generate API documentation for the payment module at src/payment/
Include only the public methods exported from src/payment/index.ts
```

## For Frontend Work with frontend-design

When the frontend-design skill analyzes your UI, specify component boundaries:

```
/frontend-design Review components in src/components/auth/ only
Do not analyze src/components/admin/. that is a separate team's concern
```

## Directory Structure as a Boundary Signal

The physical layout of your project communicates intent to Claude. A flat structure makes boundaries ambiguous; a well-organized hierarchy makes them obvious. Compare these two layouts:

Ambiguous structure:
```
src/
 authService.ts
 paymentService.ts
 authController.ts
 paymentController.ts
 authModel.ts
 paymentModel.ts
```

Boundary-aware structure:
```
src/
 auth/
 index.ts # Public API surface
 auth.service.ts
 auth.controller.ts
 auth.model.ts
 payment/
 index.ts # Public API surface
 payment.service.ts
 payment.controller.ts
 payment.model.ts
```

In the second layout, when you tell Claude "work in src/auth/," the boundary is visually and structurally unambiguous. Claude's context gathering follows directory traversal patterns, so a clean hierarchy makes scoping instructions easier to honor.

## The index.ts Boundary Pattern

One effective convention is to treat each module's `index.ts` as the formal boundary. Document this in your root `CLAUDE.md`:

```markdown
Import Rules

Each service module exposes a public API through its `index.ts`.
Do not import directly from internal files of other modules.

Correct: import { createUser } from '../user/index'
Incorrect: import { hashPassword } from '../user/services/password.util'
```

When Claude sees this rule, it generates cross-module code correctly and flags violations when reviewing existing code.

## Using Directory-Specific Prompts

For persistent module awareness, add a prompt file to each module:

```
/your-project
 frontend/
 .claude/
 prompt.md # Frontend-specific instructions
 src/
 backend/
 .claude/
 prompt.md # Backend-specific instructions
 src/
 shared/
```

The `.claude/prompt.md` file within each module contains:

```markdown
You are working in the frontend module. Focus only on:
- React components in src/components/
- State management in src/store/
- Styling in src/styles/

Do not analyze backend code unless the user explicitly requests it.
When the user mentions "the API," they mean the REST interface at /api. not
any backend source files. Reference API contracts from src/types/api.ts.
```

Claude reads this file when you change into that directory, maintaining module isolation throughout your session.

## Context Switching Techniques

When you need to switch modules mid-session, explicitly tell Claude to change scope:

```
Let's switch to the backend module. Focus on src/services/user.ts
Forget the frontend context from earlier in this session.
```

Claude will release the previous context and load only the new module's files. This works because Claude Code tracks your current working directory and any explicit scope directives. The phrase "forget the frontend context" is useful here. it signals a deliberate scope change rather than an accidental one.

## Comparison: Implicit vs. Explicit Scope Switching

| Approach | What happens | Risk |
|---|---|---|
| Just ask about a new module | Claude may blend both contexts | Cross-module suggestions appear |
| Say "switch to backend module" | Moderate context change | Some prior context lingers |
| Say "forget X, now focus on Y only" | Stronger scope signal | Most reliable for clean switch |
| Start a new session in new directory | Full context reset | No bleed at all, but loses session history |

For clean isolation, starting a fresh session from the target directory is the most reliable option.

## Best Practices for Module Boundaries

Keep your module structure explicit in documentation. If you use the supermemory skill to store project context, create separate memories for each module:

```
/supermemory Remember: payment module handles all billing logic in src/payment/
/supermemory Remember: user module manages authentication in src/auth/
/supermemory Remember: cross-module imports must go through index.ts files
```

This approach creates persistent, scoped references that Claude can access without pulling in unrelated context.

## What to Document in Each Module's CLAUDE.md

Every module-level `CLAUDE.md` should answer these questions:

- What does this module own? (the happy-path description)
- What does this module explicitly not own?
- What are the import rules?
- Where is the public API surface?
- Are there any files that should never be modified directly?

A concrete template:

```markdown
Module: payments

Owns
- All payment processing logic
- Stripe integration in src/stripe/
- Invoice generation in src/invoices/

Does Not Own
- User account management (see ../user/)
- Email delivery (see ../notifications/)

Import Rules
- Import from other modules only via their index.ts
- Never import from ../user/internal/ or ../notifications/internal/

Public API
- src/index.ts exports: createPayment, refundPayment, getInvoice

Protected Files
- src/stripe/webhook.ts. requires security review before changes
```

## Debugging Boundary Issues

If Claude isn't respecting boundaries, check three things:

1. Working directory: Confirm you're in the correct module directory when starting sessions
2. CLAUDE.md existence: Verify the file exists in your current directory
3. Explicit prompts: Include module paths in your requests

When troubleshooting, try starting a fresh session with:

```bash
cd /your-project/backend && claude
```

This forces a clean context load tied to that specific module.

Beyond those three, watch for these specific failure patterns:

- Claude suggests imports from sibling directories: Your CLAUDE.md is not explicit enough about what directories are off-limits. Name them directly.
- Claude asks to read files in other modules: Add "Do not read files outside this directory" to your CLAUDE.md.
- Boundary respected at first but drifts over a long session: Create a note at the top of your session prompt that you can re-paste when scope drift occurs: "Reminder: we are working in src/auth/ only."

## Summary

Making Claude Code respect module boundaries requires a combination of configuration files, explicit prompts, and session management. The key techniques are:

- Place `CLAUDE.md` files in module directories with specific scope rules and named exclusions
- Use `.claude/settings.json` for project-wide module definitions
- Adopt a directory structure that makes boundaries visually obvious
- Use `index.ts` files as formal boundary contracts and document that convention
- Include explicit module paths in skill invocations
- Create directory-specific prompt files for persistent awareness
- Use the supermemory skill to persist scoped module descriptions across sessions

These approaches work together to give you precise control over Claude's context, regardless of whether you're using xlsx for data processing, canvas-design for UI prototyping, or any other skill in your workflow.

---

---

<div class="mastery-cta">

I'm a solo developer in Vietnam. 50K Chrome extension users. $500K+ on Upwork. 5 Claude Max subscriptions running agent fleets in parallel.

These are my actual CLAUDE.md templates, orchestration configs, and prompts. Not a course. Not theory. The files I copy into every project before I write a line of code.

**[See what's inside →](https://zovo.one/lifetime?utm_source=ccg&utm_medium=cta-default&utm_campaign=how-to-make-claude-code-respect-module-boundaries)**

$99 once. Free forever. 47/500 founding spots left.

</div>

Related Reading

- [Claude Skills Context Window Management Best Practices](/claude-md-too-long-context-window-optimization/). Context management across module boundaries
- [How to Write Effective CLAUDE.md for Your Project](/how-to-write-effective-claude-md-for-your-project/). CLAUDE.md is the primary tool for constraining Claude's scope
- [Claude Code Multi-Agent Subagent Communication Guide](/claude-code-multi-agent-subagent-communication-guide/). Module isolation patterns in multi-agent setups
- [Advanced Claude Skills Hub](/advanced-hub/). Advanced patterns for controlling Claude's behavior

Built by theluckystrike. More at [zovo.one](https://zovo.one)


