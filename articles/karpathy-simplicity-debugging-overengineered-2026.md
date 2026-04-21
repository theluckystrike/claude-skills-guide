---
title: "Fix Claude Code Overengineering (Karpathy) (2026)"
description: "Diagnose and fix Claude Code overengineering — identify unnecessary abstractions, flatten indirection, and add Simplicity First rules to CLAUDE.md."
permalink: /karpathy-simplicity-debugging-overengineered-2026/
last_tested: "2026-04-22"
render_with_liquid: false
---

# Fix Claude Code Overengineering (Karpathy) (2026)

Claude Code generated a solution 5x more complex than necessary. Here's how to identify overengineering, simplify the output, and prevent it from happening again.

## The Problem

You asked for a feature. Claude Code delivered:
- 6 files when 1 would suffice
- Abstract base classes with single implementations
- Design patterns (Factory, Strategy, Observer) for trivial logic
- Configuration systems for 3 hardcoded values
- Generic utilities used in exactly one place

## Root Cause

Claude Code's training distribution skews toward production-grade open-source code that uses mature patterns. When asked to build anything, it pattern-matches to the most "professional" version, regardless of whether the problem warrants it.

Three triggers make it worse:
1. **Vague requirements** — "build an API" doesn't specify scale, so Claude Code assumes production scale
2. **No simplicity constraints** — without CLAUDE.md rules, there's no pressure toward simplicity
3. **Framework-heavy context** — if your codebase already uses patterns, Claude Code amplifies them

## The Fix

### Step 1: Identify the Unnecessary Complexity

For each file Claude Code created, ask:
- Is this file called from more than one place?
- Does this abstraction have more than one implementation?
- Would removing this layer break functionality, or just remove indirection?

### Step 2: Flatten the Stack

Request a simplified version with explicit constraints:

```
Rewrite this feature with these constraints:
- Maximum 1 file for the implementation
- No abstract classes or interfaces with single implementations
- No utility functions that are called from only one place
- Inline all one-hop indirection
```

### Step 3: Add Simplicity Rules to CLAUDE.md

```markdown
## Anti-Overengineering Rules
- Before creating a new file, explain why existing files can't hold this code
- No interfaces/abstract classes unless 3+ implementations exist right now
- No utility extraction for code used in 1 place
- No design patterns (Factory, Strategy, Observer) unless the requirement explicitly needs extensibility
- Maximum 1 level of indirection between caller and actual logic
- If the simple version is under 50 lines, do not create an abstracted version
```

### Step 4: Verify

Give the same task again and confirm the output is simpler. If it's still overengineered, make the rules more specific:

```markdown
## Specific Anti-Patterns (DO NOT generate these)
- UserRepository → UserService → UserController chain for a single CRUD endpoint
- EventEmitter with fewer than 3 events
- Config loader for fewer than 5 config values
- Custom error class hierarchy for fewer than 10 error types
```

## Verification

Test with a prompt that typically triggers overengineering:

```
Add a feature to send email notifications when a user signs up.
```

**Overengineered output** (bad):
- NotificationService interface
- EmailNotificationService implements NotificationService
- NotificationFactory
- NotificationConfig
- NotificationTemplate abstract class
- 6 files, 200+ lines

**Simple output** (good):
```typescript
import { Resend } from 'resend';
const resend = new Resend(process.env.RESEND_API_KEY);

async function sendWelcomeEmail(email: string, name: string) {
  await resend.emails.send({
    from: 'noreply@example.com',
    to: email,
    subject: 'Welcome!',
    html: `<p>Hi ${name}, welcome aboard.</p>`,
  });
}
```

1 function, 10 lines, zero abstractions. If you later need SMS notifications, refactor then.

## Common Mistakes

1. **Oversimplifying to the point of tech debt** — simplicity doesn't mean ignoring error handling, types, or tests. It means no unnecessary patterns.

2. **Applying retroactively to existing code** — if the codebase already uses patterns, new code should match. Apply simplicity rules to new projects or isolated features.

3. **Not distinguishing library code from app code** — library code serves unknown consumers and often needs more abstraction. App code serves known requirements and usually doesn't.

## Related Principles

- [Simplicity First Principle](/karpathy-simplicity-first-principle-claude-code-2026/) — the underlying principle
- [Before and After Code Examples](/karpathy-simplicity-first-examples-2026/) — 6 side-by-side comparisons
- [Stop Claude Code Writing Excessive Code](/claude-code-writes-too-much-code-fix-2026/) — related problem
- [CLAUDE.md Best Practices](/claude-md-file-best-practices-guide/) — structuring rules
