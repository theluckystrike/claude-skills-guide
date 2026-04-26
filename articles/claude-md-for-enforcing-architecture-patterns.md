---
layout: default
title: "Claude Md For Enforcing Architecture (2026)"
description: "Learn how to use Claude Code with custom skills to enforce architectural patterns consistently across your codebase. Practical examples and."
date: 2026-03-14
last_modified_at: 2026-04-17
author: "Claude Skills Guide"
categories: [guides]
tags: [claude-code, claude-skills, architecture-patterns, code-standards, software-design]
permalink: /claude-md-for-enforcing-architecture-patterns/
reviewed: true
score: 7
geo_optimized: true
---
Consistent architecture patterns across a codebase prevent technical debt, simplify onboarding, and make refactoring manageable. Yet enforcing these patterns manually through code reviews alone is time-consuming and error-prone. Claude Code, combined with custom skill definitions, offers a powerful solution for automating architectural consistency checks. This guide walks through exactly how to build, deploy, and iterate on architecture enforcement skills that keep your codebase clean as it grows.

## The Problem with Manual Pattern Enforcement

Development teams often document their architecture decisions in style guides, ADR records, or wiki pages. These documents serve as reference, but they don't actively prevent violations. A developer unfamiliar with the conventions might introduce a service that doesn't follow your layering rules, or create a component that bypasses your dependency injection patterns.

Traditional linters handle syntax and basic style concerns effectively. They catch missing semicolons, enforce naming conventions, and validate formatting. However, architectural patterns often exist at a higher abstraction level, relationships between modules, dependency direction, or the presence of specific abstractions, that standard linters cannot express.

Consider the gap between what ESLint can check and what your architecture actually requires:

| Concern | Standard Linter | Claude Architecture Skill |
|---|---|---|
| Naming conventions | Yes | Yes |
| Import sorting | Yes | Yes |
| Dependency direction between layers | No | Yes |
| DTO usage at layer boundaries | No | Yes |
| Repository interface compliance | No | Yes |
| Test coverage by layer type | No | Yes |
| Domain model purity | No | Yes |
| Cross-cutting concern placement | No | Yes |

This gap is where teams accumulate silent technical debt. Claude MD skills fill it.

## How Claude MD Skills Work

Claude Code uses a skill system that extends its capabilities through custom definitions. These skills live as markdown files stored in `~/.claude/skills/`, and each file teaches Claude about a specific domain of your project's conventions.

A skill definition typically includes:

- Metadata: Name, description, and trigger conditions
- Instructions: Detailed rules about how to handle specific patterns
- Examples: Demonstrations of correct and incorrect implementations
- Edge cases: Explicit guidance for ambiguous situations your team has already debated

When you invoke a skill using `/skill-name` inside a Claude Code session, Claude loads those instructions into its active context. From that point forward, every code generation, review, or suggestion in that session is filtered through your architectural rules. This makes skills ideal for enforcing architecture patterns because you encode your team's decisions once and apply them consistently, regardless of which developer is typing the prompt.

Skills are not magic, they work because Claude is reading detailed instructions at inference time. The quality of your skill definition directly determines the quality of enforcement. Vague rules produce vague feedback; precise rules with examples produce precise corrections.

## Creating an Architecture Enforcement Skill

Let's build a skill that enforces a layered architecture pattern. This example assumes a standard three-layer setup: presentation, business logic, and data access. Save this file to `~/.claude/skills/enforce-layered-architecture.md`:

```markdown
---
name: enforce-layered-architecture
description: "Enforces consistent layered architecture patterns across the codebase"
---

Layered Architecture Rules

Allowed Dependencies

- presentation → business-logic
- business-logic → data-access
- business-logic → domain
- presentation → domain (interfaces only)

Forbidden Patterns

- Never import data-access from presentation layer
- Never import presentation from business-logic
- Controllers must only depend on services, never access repositories directly
- All database operations must go through repository interfaces

File Organization

Each layer should have its own directory:
- /presentation/controllers, /presentation/components
- /business-logic/services, /business-logic/interfaces
- /data-access/repositories, /data-access/models

When Reviewing Code

For each import statement, identify which layer the importing file belongs to and which layer
the imported module belongs to. Flag any import that moves against the allowed dependency
direction as a violation. Explain the correct alternative.

When Generating Code

Before writing any file, determine which layer it belongs to. Only import from layers that
are allowed as dependencies for that layer. If a required operation would require a forbidden
import, introduce the appropriate abstraction (interface, service, DTO) instead.
```

To invoke this skill, use it explicitly in your prompts:

```
/enforce-layered-architecture
Review this pull request diff and identify any architecture violations.
```

Or inline within a generation request:

```
/enforce-layered-architecture
Create a new OrderService that retrieves order history for a user.
```

## Practical Examples

## Example 1: Validating Dependency Direction

Consider this TypeScript code in a presentation layer controller:

```typescript
// Violation: Presentation importing from Data Access
import { UserRepository } from '../data-access/repositories/UserRepository';
import { db } from '../data-access/database';

class UserController {
 private repo = new UserRepository();

 async getUser(id: string) {
 return this.repo.findById(id);
 }

 async getUserOrders(id: string) {
 return db.query('SELECT * FROM orders WHERE user_id = ?', [id]);
 }
}
```

When you run Claude with the architecture skill active, it identifies both violations and explains the correct approach:

```typescript
// Correct: Using service abstraction
import { UserService } from '../business-logic/services/UserService';
import { OrderService } from '../business-logic/services/OrderService';

class UserController {
 constructor(
 private readonly userService: UserService,
 private readonly orderService: OrderService
 ) {}

 async getUser(id: string) {
 return this.userService.findById(id);
 }

 async getUserOrders(id: string) {
 return this.orderService.getOrdersForUser(id);
 }
}
```

Claude will also explain why this matters: the presentation layer should have no knowledge of how data is stored. If you switch from SQL to a document database, only the data-access layer changes. The controller remains untouched.

## Example 2: Enforcing Interface Segregation

A skill focused on interface patterns can enforce that all data access goes through interfaces, making each component independently testable:

```markdown
Interface Requirements

- Every repository must implement an interface defined in the business-logic layer
- Services should only depend on interfaces, never concrete implementations
- Interface names should follow I{RepositoryName} convention
- Constructor injection is required, no service locator pattern
```

Here is what this looks like in practice. Without the skill enforced, a service might look like this:

```typescript
// Problematic: depends on concrete implementation
import { PostgresUserRepository } from '../data-access/PostgresUserRepository';

class UserService {
 private repo = new PostgresUserRepository();

 async findById(id: string) {
 return this.repo.findById(id);
 }
}
```

With the skill active, Claude generates the interface-first version:

```typescript
// In business-logic/interfaces/IUserRepository.ts
export interface IUserRepository {
 findById(id: string): Promise<User | null>;
 save(user: User): Promise<void>;
 delete(id: string): Promise<void>;
}

// In business-logic/services/UserService.ts
import { IUserRepository } from '../interfaces/IUserRepository';

class UserService {
 constructor(private readonly userRepository: IUserRepository) {}

 async findById(id: string): Promise<User | null> {
 return this.userRepository.findById(id);
 }
}

// In data-access/repositories/PostgresUserRepository.ts
import { IUserRepository } from '../../business-logic/interfaces/IUserRepository';

export class PostgresUserRepository implements IUserRepository {
 async findById(id: string): Promise<User | null> {
 // Postgres-specific implementation
 }
}
```

Now unit tests for `UserService` can inject a mock repository without any database. Swapping Postgres for another database means implementing the interface in a new file, nothing else changes.

## Example 3: Cross-Layer Communication with DTOs

Your skill can also govern how data moves between layers. Exposing raw database entities to the presentation layer creates invisible coupling that breaks unexpectedly during schema migrations.

```markdown
Communication Patterns

- Use Data Transfer Objects (DTOs) for cross-layer data transfer
- DTOs should be defined in the layer that consumes them
- Never expose database entity objects directly to the presentation layer
- Use mapper functions to convert between entity and DTO representations
- DTOs are plain objects with no methods, only data properties
```

Claude enforces this by generating mapper utilities alongside services:

```typescript
// business-logic/mappers/UserMapper.ts
import { UserEntity } from '../../data-access/models/UserEntity';
import { UserDTO } from '../dtos/UserDTO';

export class UserMapper {
 static toDTO(entity: UserEntity): UserDTO {
 return {
 id: entity.user_id,
 name: `${entity.first_name} ${entity.last_name}`,
 email: entity.email_address,
 createdAt: entity.created_at.toISOString()
 };
 }
}
```

The presentation layer never sees `user_id` or `email_address`, it only knows `id` and `email`. If your database schema renames a column, only the mapper changes.

## Skill Patterns for Common Architectures

Different teams use different architectural styles. Here is a comparison of what each enforcement skill should focus on:

| Architecture | Key Enforcement Rules | Common Violations |
|---|---|---|
| Layered (N-tier) | Dependency direction, layer isolation | Presentation accessing DB directly |
| Hexagonal / Ports & Adapters | Port interface compliance, adapter isolation | Domain logic in adapters |
| CQRS | Command/query separation, read model purity | Commands returning data |
| Domain-Driven Design | Aggregate boundaries, domain event patterns | Services reaching into other aggregates |
| Microservices | Service boundary contracts, API versioning | Shared database between services |

For each architecture style, the skill structure is the same, you describe the rules, list forbidden patterns, and provide before/after examples. The specifics change, but the approach scales.

## Combining Skills for Comprehensive Enforcement

You can create multiple skills that work together. A mature architecture enforcement strategy might include:

- enforce-layered-architecture: Validates dependency direction and layer organization
- tdd-skill: Ensures tests are written before implementation, following your testing conventions
- supermemory-skill: Maintains context about architectural decisions across sessions
- frontend-design-skill: Enforces component patterns specific to your UI framework
- api-contracts-skill: Validates that API responses conform to versioned schemas

The tdd skill, for instance, can verify that new features come with corresponding test files and that tests follow your established patterns, unit tests for business logic, integration tests for API endpoints, and component tests for UI.

Invoking multiple skills together is straightforward:

```
/enforce-layered-architecture /tdd-skill
Create a new PaymentService with full test coverage.
```

Claude loads both skill definitions into context and generates code that satisfies both simultaneously: correctly layered structure with tests in the right locations.

## Writing Effective Skill Definitions

The difference between a skill that works and one that produces inconsistent results often comes down to how precisely the rules are written. These practices make skill definitions more effective:

Be explicit about edge cases. If your codebase has a utility layer that is permitted to import from multiple layers, say so explicitly. If there is one service that legitimately accesses the database directly for performance reasons, document it as an approved exception.

Include before/after examples. Claude uses examples heavily. A rule stated in prose plus a code example is more reliable than prose alone. Show the wrong pattern, explain why it violates the rule, and show the corrected version.

State what to do, not just what not to do. "Never import repositories from controllers" is good. Adding "Instead, inject the appropriate service through the constructor" is better because Claude knows the target state, not just the forbidden state.

Version your skill definitions. Store skills in your project repository under a `/.claude/skills/` directory rather than only in `~/.claude/skills/`. This lets you track how your architectural rules evolve over time alongside the code they govern.

## Implementing Skills in Your Workflow

Start by documenting your existing patterns clearly. The skill format works best when you can express rules precisely. Begin with one architectural concern, create the skill, and test it against a few known violations in your codebase. If Claude catches all of them and explains them correctly, the skill is ready for daily use.

To apply skills during development, reference them in your prompts:

```
/enforce-layered-architecture
Create a new user service and its corresponding repository.
```

Claude will generate code that respects your patterns and explain the constraints it follows. During code review sessions:

```
/enforce-layered-architecture
Here is the diff for PR #142. List every architecture violation and the corrected version for each.
```

This makes code review faster. Reviewers can focus on logic, performance, and business correctness rather than pattern compliance. Claude handles the mechanical enforcement.

## Integrating with CI/CD

For teams that want automated enforcement, Claude skills can be part of a CI pipeline. A simple approach uses Claude Code's non-interactive mode with a review prompt against every pull request diff:

```bash
In your CI script
git diff origin/main...HEAD > pr_diff.txt
claude --skill enforce-layered-architecture \
 "Review this diff for architecture violations. Exit with code 1 if any violations are found." \
 < pr_diff.txt
```

This runs Claude as a review step before merging. Combined with the skill definition checked into your repository, every developer gets the same enforcement criteria applied consistently.

## Measuring Effectiveness

Track pattern violations over time by running Claude's review capabilities on pull requests. You should see violations decrease as developers internalize the patterns. Useful metrics to track:

- Number of architecture violations flagged per PR (week over week)
- Time spent in code review per PR (should decrease as obvious violations disappear)
- Onboarding time for new developers (skill definitions double as executable documentation)
- Number of architectural ADRs that required debate versus those the skill simply enforced

The skills also serve as excellent onboarding material, new team members can read the skill definitions to understand exactly what architectural expectations exist, then validate their understanding by having Claude review their first contributions.

## Conclusion

Claude MD skills transform architectural guidance from passive documentation into active enforcement. By encoding your patterns as skills, you get consistent application across your codebase, faster code reviews, and improved developer experience. The investment is modest, a well-written skill file for a layered architecture takes an hour to write and saves hundreds of hours of review time as the codebase grows.

Start with your most critical patterns, iterate on the skill definitions based on what Claude misses or misinterprets, and watch your architecture remain clean without manual policing. Store the skills in your repository so the rules evolve alongside the code they govern.

---

---

<div class="mastery-cta">

This site was built by 5 autonomous agents running in tmux while I was in Bali. 2,500 articles. Zero manual work. 100% quality gate pass rate.

The orchestration configs, sprint templates, and quality gates that made that possible are in the Zovo Lifetime bundle. Along with 16 CLAUDE.md templates and 80 tested prompts.

**[See how the pipeline works →](https://zovo.one/lifetime?utm_source=ccg&utm_medium=cta-skills&utm_campaign=claude-md-for-enforcing-architecture-patterns)**

$99 once. I'm a solo dev in Da Nang. This is how I scale.

</div>

Related Reading


- [Best Practices Guide](/best-practices/). Production-ready Claude Code guidelines and patterns
- [AI Assisted Architecture Design Workflow Guide](/ai-assisted-architecture-design-workflow-guide/)
- [Claude Code Agent Task Queue Architecture Deep Dive](/claude-code-agent-task-queue-architecture-deep-dive/)
- [Claude Code API Authentication Patterns Guide](/claude-code-api-authentication-patterns-guide/)

Built by theluckystrike. More at [zovo.one](https://zovo.one)

## See Also

**Try it:** Paste your error into our [Error Diagnostic](/diagnose/) for an instant fix.

- [CLAUDE.md for API Design — Consistent Endpoints, Responses, and Versioning (2026)](/claude-md-api-design-patterns/)
- [CLAUDE.md for Error Handling — Patterns That Prevent Silent Failures (2026)](/claude-md-error-handling-patterns/)
