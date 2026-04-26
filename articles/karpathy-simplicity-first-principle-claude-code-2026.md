---
layout: default
title: "Karpathy Simplicity First for Claude (2026)"
description: "Apply Karpathy's Simplicity First principle to stop Claude Code from overengineering — fewer abstractions, less code, simpler solutions."
permalink: /karpathy-simplicity-first-principle-claude-code-2026/
date: 2026-04-20
last_tested: "2026-04-22"
---

# Karpathy Simplicity First for Claude Code (2026)

The Simplicity First principle from Karpathy's behavioral guidelines targets Claude Code's strongest bias: overengineering. Left unconstrained, Claude Code builds abstractions, design patterns, and extensibility hooks that your project doesn't need. Simplicity First forces it to start with the minimum viable implementation.

## The Principle

**Simplicity First.** Implement the simplest solution that satisfies the requirements. Do not add abstractions, patterns, or extensibility unless the requirements explicitly demand them.

This means:

- Direct code over indirection
- Functions over classes (when both work)
- Inline logic over abstracted utilities (for one-time operations)
- Concrete implementations over generic frameworks
- Fewer files over more files

The principle doesn't mean "write bad code." Simple code is readable, testable, and maintainable. It just doesn't solve problems you don't have.

## Why It Matters

Claude Code's training data is full of production-grade open-source code with factories, builders, strategies, and dependency injection containers. When asked to build something, it pattern-matches to these complex solutions even when the use case doesn't warrant them.

Symptoms of overengineering by Claude Code:

- A simple CRUD endpoint wrapped in a Repository → Service → Controller → Factory chain
- Type-safe event systems for a feature that emits 2 events
- Plugin architectures for functionality with 1 implementation
- Abstract base classes with a single concrete subclass
- Configuration systems for 3 hardcoded values

Each unnecessary layer costs you: more files to understand, more code to maintain, more surface area for bugs.

## CLAUDE.md Implementation

```markdown
## Simplicity First (Karpathy Principle)

### Rules
- Start with the simplest implementation that works. Add complexity only when requirements demand it.
- Do NOT create abstractions preemptively. No base classes, no interfaces, no factories unless there are 3+ concrete implementations.
- Functions over classes for stateless operations.
- Inline one-time logic rather than extracting to utility files.
- Maximum 1 level of indirection for any operation. If calling A requires going through B which calls C, flatten it.
- When presenting a solution, explain why this is the simplest approach. If a simpler one exists, use that instead.

### Smell Tests
Before writing code, ask: "Would the simplest version of this work?" If yes, write the simple version.
Before adding an abstraction: "Will there be 3+ implementations within 6 months?" If uncertain, don't abstract.
Before creating a new file: "Can this logic live in an existing file without making it worse?" If yes, keep it there.
```

## Before/After Examples

### Before: Over-Abstracted API Endpoint

```typescript
// Without Simplicity First — Claude Code generates this
interface IUserRepository { find(id: string): Promise<User>; }
class UserRepository implements IUserRepository {
  constructor(private db: Database) {}
  async find(id: string) { return this.db.users.findUnique({ where: { id } }); }
}
class UserService {
  constructor(private repo: IUserRepository) {}
  async getUser(id: string) { return this.repo.find(id); }
}
class UserController {
  constructor(private service: UserService) {}
  async handle(req: Request) { return this.service.getUser(req.params.id); }
}
// + factory, + DI container, + 4 files
```

### After: Simple and Direct

```typescript
// With Simplicity First
app.get('/users/:id', async (req, res) => {
  const user = await db.users.findUnique({ where: { id: req.params.id } });
  if (!user) return res.status(404).json({ error: 'User not found' });
  res.json(user);
});
```

Same functionality, 5 lines instead of 30+, 1 file instead of 4+.

## Common Mistakes

1. **Confusing simplicity with sloppiness** — simple code still has error handling, types, and tests. It just doesn't have unnecessary layers.

2. **Never allowing complexity** — some problems genuinely need patterns. The rule is "start simple," not "stay simple forever." If you need 5 payment providers, an adapter pattern makes sense.

3. **Ignoring the codebase's existing complexity level** — if the project already uses a layered architecture, adding a simple function breaks consistency. Match the project's style.

4. **Applying to libraries differently than applications** — library code often needs more abstraction (it serves unknown consumers). Application code rarely does.

## Related Principles

- **Don't Assume** — don't assume the problem needs a complex solution
- **Surgical Changes** — simple changes are easier to keep surgical
- **Goal-Driven Execution** — the goal is to solve the stated problem, not to build an architecture
- [Full Karpathy Skills Guide](/karpathy-claude-code-skills-complete-guide-2026/)
- [Implement Simplicity First in CLAUDE.md](/karpathy-simplicity-first-implementation-2026/)
- [Claude Code Best Practices](/karpathy-skills-vs-claude-code-best-practices-2026/)

**Try it:** Browse 155+ skills in our [Skill Finder](/skill-finder/).
