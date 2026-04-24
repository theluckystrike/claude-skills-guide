---
title: "CLAUDE.md for Architecture Decisions (2026)"
description: "How to encode architectural decisions in CLAUDE.md so Claude Code enforces layer boundaries, dependency rules, and design patterns automatically."
permalink: /claude-md-for-architecture-decisions/
categories: [claude-md, patterns]
tags: [claude-md, architecture, design-patterns, layer-boundaries, claude-code]
last_updated: 2026-04-19
---

## The Architecture Erosion Problem

Architecture erodes one shortcut at a time. A developer imports the database client directly from a controller. Another adds business logic to a repository. A third bypasses the event bus with a direct function call. Each violation is small. Collectively, they destroy the architecture you spent months designing.

CLAUDE.md stops this erosion by encoding your architectural decisions as instructions Claude Code follows on every interaction. When Claude generates code, it respects layer boundaries, dependency direction, and design patterns -- not because it understands your architecture theory, but because you told it the concrete rules.

## Layer Boundary Rules

Most backend applications follow a layered architecture. Encode the boundaries explicitly:

```markdown
## Architecture Layers (strict boundaries)

### Layer 1: Routes (src/routes/)
- Accept HTTP requests, validate input with zod, call services
- NEVER import from repositories or database modules
- NEVER contain business logic beyond input validation
- Return responses through src/responses/envelope.ts

### Layer 2: Services (src/services/)
- Contain all business logic
- Call repositories for data access
- Call external APIs through src/clients/
- NEVER import Express request/response types
- NEVER access database directly — always through repositories

### Layer 3: Repositories (src/repositories/)
- Sole interface to database via Prisma
- Return domain objects, not Prisma models
- NEVER contain business logic
- NEVER throw HTTP-specific errors

### Layer 4: Shared (src/shared/)
- Types, constants, utilities used across layers
- NEVER import from layers 1-3
- No side effects — pure functions only
```

These rules are concrete enough for Claude to verify. "NEVER import Express request/response types in services" is a binary check Claude can perform on every file it generates or modifies.

## Dependency Direction Rules

Dependency direction is the most common architectural violation. Make it explicit:

```markdown
## Dependency Direction (violations = architecture bugs)
- Routes → Services → Repositories → Database
- Any layer may import from Shared
- Shared imports from NO other layer
- No circular dependencies between modules in the same layer
- External API clients (src/clients/) are called only from Services
```

## Design Pattern Enforcement

If your codebase uses specific patterns, encode them:

```markdown
## Design Patterns in Use
- **Repository Pattern**: Every database entity has a repository in src/repositories/
  with standard methods: findById, findMany, create, update, delete
- **Result Pattern**: Services return Result<T, AppError> instead of throwing.
  Never use try/catch for expected error cases in service layer.
- **Event Bus**: Cross-module communication uses src/events/bus.ts.
  Never call another module's service directly for side effects.
  Emit an event and let the subscriber handle it.
```

## Using .claude/rules/ for Module-Specific Decisions

Some architectural rules apply only to specific modules. Use path-specific rules files:

```markdown
# .claude/rules/auth-module.md
---
paths:
  - "src/modules/auth/**"
---

## Auth Module Architecture
- Session tokens stored in Redis, never in PostgreSQL
- Password hashing uses bcrypt with cost factor 12
- JWT tokens are signed with RS256, keys in src/config/keys/
- Rate limiting: 5 failed attempts per IP per 15 minutes
- All auth endpoints log to the security audit trail
```

This loads only when Claude works on auth module files. Other modules get their own rules files. The root CLAUDE.md stays lean and focused on cross-cutting concerns.

## ADR Integration

If your team uses Architecture Decision Records, reference them from CLAUDE.md:

```markdown
## Architecture Decision Records
- @docs/adr/001-repository-pattern.md
- @docs/adr/002-event-driven-communication.md
- @docs/adr/003-result-type-over-exceptions.md

When making architectural choices, check ADRs first.
If a decision contradicts an existing ADR, flag it — do not silently deviate.
```

The `@` import syntax pulls ADR content into Claude's context. This lets Claude reference the reasoning behind decisions, not just the rules.

## Verifying Enforcement

After adding architecture rules, test them by asking Claude to make a change that would violate a boundary. For example: "Add a function in the user service that queries the database directly." Claude should refuse or restructure the code to go through the repository layer.

If Claude ignores a rule, check three things with `/memory`: is the file loaded, are there contradictions, and is the total instruction count under 200 lines?

## Module Boundary Enforcement

For larger applications with distinct modules, encode the allowed communication paths:

```markdown
## Module Communication Rules
- Auth module → User module: allowed (auth needs user data)
- Order module → Payment module: allowed (orders trigger payments)
- Payment module → Order module: NOT allowed (use events instead)
- User module → Auth module: NOT allowed (circular dependency)
- Any module → Shared: allowed (utilities, types, constants)
- Shared → Any module: NOT allowed (shared has no dependencies)
```

This prevents Claude from creating imports that introduce circular dependencies or bypass the event-driven architecture. Each allowed path is a concrete rule Claude can verify when generating import statements.

## Evolution of Architecture Rules

Architecture rules change as projects grow. When updating rules, add context about the change:

```markdown
## Architecture Notes
- 2026-01: Migrated from direct service calls to event bus for cross-module communication
- 2026-03: Added Result types — services no longer throw exceptions for expected errors
- Previous patterns (throw/catch) still exist in legacy code; do not introduce new ones
```

This context helps Claude understand why certain patterns exist in the codebase and which direction new code should follow. Without it, Claude might replicate legacy patterns it finds in existing files.

For coding standards that complement architecture rules, see the [coding standards enforcement guide](/claude-md-for-coding-standards-enforcement/). For the complete file format and loading mechanics, see the [CLAUDE.md complete guide](/claude-md-file-complete-guide-what-it-does/). Teams working on large codebases should also read the [large codebase best practices](/claude-md-best-practices-for-large-codebases/).
