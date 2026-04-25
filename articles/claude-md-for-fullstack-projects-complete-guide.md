---
layout: default
title: "Claude Md For Fullstack Projects (2026)"
description: "Master Claude Code .md skill files for fullstack development. Learn to create, organize, and deploy Claude skills across frontend, backend, and."
date: 2026-03-14
last_modified_at: 2026-04-17
categories: [guides]
tags: [claude-code, claude-skills, fullstack, markdown, development]
author: theluckystrike
reviewed: true
score: 8
permalink: /claude-md-for-fullstack-projects-complete-guide/
geo_optimized: true
---
# Claude MD for Fullstack Projects Complete Guide

Claude Code has evolved into a powerful development assistant that works across the entire fullstack development workflow. The .md skill file format provides a flexible way to define reusable prompts, workflows, and project-specific guidance that accelerates development across frontend, backend, and infrastructure layers.

This guide covers everything you need to know about creating and organizing Claude skills in markdown format for fullstack projects, with practical examples you can apply immediately.

## Understanding Claude Skill Files

A Claude skill is simply a markdown file with front matter that defines metadata and a body containing the skill's instructions. The format follows this structure:

```yaml
---
name: skill-name
description: What this skill does
---

Skill Instructions
Your prompt content goes here...
```

The front matter uses YAML syntax to declare the skill's capabilities, while the markdown body provides detailed instructions, examples, and context that Claude uses when responding to queries.

## What Makes a Good Skill File

The quality of a skill file is the single biggest factor in the quality of Claude's output. A skill that only says "write clean code" produces mediocre results. A skill that specifies naming conventions, import ordering, error handling patterns, and provides a concrete before/after example produces output you can ship.

The anatomy of a high-quality skill file has five parts:

1. Role declaration: Tell Claude what expert it should act as for this skill
2. Hard rules: Non-negotiable constraints (no class components, always use TypeScript, etc.)
3. Soft preferences: Style choices the developer prefers but can override
4. Examples: At least one complete, realistic code sample showing the expected output
5. Anti-patterns: Explicit list of things the skill should never do

Here is the contrast between a weak and a strong skill:

Weak skill (produces inconsistent output):

```yaml
---
name: react-component
description: Make React components
---

Write good React components with hooks.
```

Strong skill (produces consistent, shippable output):

```yaml
---
name: react-component
description: Generate production-ready React components following our team conventions
---

React Component Builder

You are a senior React engineer writing components for a TypeScript + Tailwind project.

Hard Rules
- Functional components only. no class components ever
- TypeScript interfaces for all props, no `any` types
- CSS Modules or Tailwind utility classes. no inline styles
- `aria-label` or `aria-labelledby` on all interactive elements
- Export components as named exports, not default exports

Soft Preferences
- Prefer `const` arrow functions over `function` declarations
- Co-locate tests in a `__tests__` folder next to the component
- Group imports: external libs, then internal utils, then styles

Example Output

```tsx
import React from 'react';
import styles from './Button.module.css';

interface ButtonProps {
 label: string;
 onClick: () => void;
 disabled?: boolean;
 variant?: 'primary' | 'secondary';
}

export const Button: React.FC<ButtonProps> = ({
 label,
 onClick,
 disabled = false,
 variant = 'primary',
}) => (
 <button
 className={styles[variant]}
 onClick={onClick}
 disabled={disabled}
 aria-label={label}
 type="button"
 >
 {label}
 </button>
);
```

Anti-patterns
- Never use `React.FC` without explicit props interface
- Never use `index` as a key in list renders
- Never fetch data directly inside render. use custom hooks
```

The second skill generates output that matches your project conventions from the first request, without follow-up corrections.

## Creating Skills for Frontend Development

Frontend work with Claude benefits significantly from specialized skills. The `frontend-design` skill helps generate component structures, styling decisions, and responsive layouts. Here's how to structure a frontend skill:

```yaml
---
name: react-component-builder
description: Generate React components with proper structure and styling
---

React Component Builder

When asked to create React components, follow these rules:

1. Always use functional components with hooks
2. Include PropTypes or TypeScript interfaces
3. Extract reusable styles to CSS modules
4. Add proper accessibility attributes

Example response format:
```

This approach ensures consistent component quality across your project. The `canvas-design` skill complements frontend work by generating visual assets directly in your project directory, eliminating the need for external design tools.

## A Complete Frontend Skill Suite

A production frontend skill library covers more than component scaffolding. These are the skills most teams need when working on a React or Vue codebase:

Custom hook generator. Encapsulates data-fetching and stateful logic into reusable hooks:

```yaml
---
name: react-hook-builder
description: Generate custom React hooks with proper error handling and loading states
---

Custom Hook Builder

When generating custom hooks:

1. Always return a consistent shape: `{ data, error, isLoading }`
2. Handle the AbortController pattern for fetch cleanup on unmount
3. Use `useCallback` for memoized event handlers returned from hooks
4. Export the hook as a named export from `src/hooks/`

useFetch hook

```ts
import { useState, useEffect, useRef } from 'react';

export function useFetch<T>(url: string) {
 const [data, setData] = useState<T | null>(null);
 const [error, setError] = useState<Error | null>(null);
 const [isLoading, setIsLoading] = useState(true);

 useEffect(() => {
 const controller = new AbortController();
 setIsLoading(true);

 fetch(url, { signal: controller.signal })
 .then(res => {
 if (!res.ok) throw new Error(`HTTP ${res.status}`);
 return res.json() as Promise<T>;
 })
 .then(setData)
 .catch(err => {
 if (err.name !== 'AbortError') setError(err);
 })
 .finally(() => setIsLoading(false));

 return () => controller.abort();
 }, [url]);

 return { data, error, isLoading };
}
```
```

Form validation skill. Enforces consistent validation patterns across all forms:

```yaml
---
name: form-validator
description: Generate form validation logic using React Hook Form and Zod
---

Form Validation Guidelines

Always pair React Hook Form with Zod for type-safe schema validation.

Schema-first pattern

```ts
import { z } from 'zod';
import { useForm } from 'react-hook-form';
import { zodResolver } from '@hookform/resolvers/zod';

const loginSchema = z.object({
 email: z.string().email('Invalid email address'),
 password: z.string().min(8, 'Password must be at least 8 characters'),
});

type LoginFormData = z.infer<typeof loginSchema>;

export function LoginForm() {
 const { register, handleSubmit, formState: { errors } } = useForm<LoginFormData>({
 resolver: zodResolver(loginSchema),
 });

 const onSubmit = (data: LoginFormData) => {
 // data is fully typed and validated
 };

 return (
 <form onSubmit={handleSubmit(onSubmit)}>
 <input {...register('email')} aria-describedby="email-error" />
 {errors.email && <span id="email-error">{errors.email.message}</span>}
 <input type="password" {...register('password')} />
 {errors.password && <span>{errors.password.message}</span>}
 <button type="submit">Login</button>
 </form>
 );
}
```
```

## Backend Skill Organization

Backend development with Claude requires different skill focuses. Create separate skills for API design, database modeling, and server configuration:

```yaml
---
name: api-rest-designer
description: Design RESTful APIs with proper HTTP semantics
---

REST API Design Guidelines

Follow these conventions for all API endpoints:

- Use plural nouns for resources: /users, /orders, /products
- Return appropriate HTTP status codes
- Include pagination for list endpoints
- Version APIs in the path: /api/v1/resource
```

The `tdd` skill integrates with backend development by generating test-first implementations. When combined with your API skills, you get comprehensive coverage from design through testing.

## Building a Complete Backend Skill Set

A REST API design skill is a start, but backend work involves more surface area. These additional skills round out a Node.js or Python backend:

Error handling skill. Standardizes error responses across all routes:

```yaml
---
name: api-error-handling
description: Implement consistent error handling for Express APIs
---

API Error Handling

All Express routes must use a centralized error handler. Never return raw error objects to clients.

Error class hierarchy

```ts
export class AppError extends Error {
 constructor(
 public message: string,
 public statusCode: number,
 public code: string
 ) {
 super(message);
 this.name = 'AppError';
 }
}

export class NotFoundError extends AppError {
 constructor(resource: string) {
 super(`${resource} not found`, 404, 'NOT_FOUND');
 }
}

export class ValidationError extends AppError {
 constructor(message: string) {
 super(message, 422, 'VALIDATION_ERROR');
 }
}
```

Express error middleware

```ts
import { Request, Response, NextFunction } from 'express';
import { AppError } from './errors';

export function errorHandler(
 err: Error,
 req: Request,
 res: Response,
 next: NextFunction
) {
 if (err instanceof AppError) {
 return res.status(err.statusCode).json({
 error: { code: err.code, message: err.message }
 });
 }

 console.error('Unhandled error:', err);
 res.status(500).json({
 error: { code: 'INTERNAL_ERROR', message: 'An unexpected error occurred' }
 });
}
```
```

Authentication middleware skill. Keeps auth logic consistent across protected routes:

```yaml
---
name: auth-middleware
description: Generate JWT authentication middleware for Express routes
---

Auth Middleware Pattern

Use a `requireAuth` middleware on all protected routes. Never inline token verification logic.

```ts
import jwt from 'jsonwebtoken';
import { Request, Response, NextFunction } from 'express';

interface AuthRequest extends Request {
 user?: { id: string; role: string };
}

export function requireAuth(req: AuthRequest, res: Response, next: NextFunction) {
 const token = req.headers.authorization?.replace('Bearer ', '');
 if (!token) return res.status(401).json({ error: { code: 'UNAUTHORIZED' } });

 try {
 const payload = jwt.verify(token, process.env.JWT_SECRET!) as { id: string; role: string };
 req.user = payload;
 next();
 } catch {
 res.status(401).json({ error: { code: 'TOKEN_INVALID' } });
 }
}
```
```

## Database and Infrastructure Skills

Fullstack projects require database skills that work alongside your application code. The `pdf` skill helps generate database documentation, while custom skills can manage schema migrations:

```yaml
---
name: postgres-schema-designer
description: Design PostgreSQL schemas with proper normalization
---

PostgreSQL Schema Design

When designing schemas:

1. Use appropriate data types (UUID for IDs, TIMESTAMP for dates)
2. Add indexes for frequently queried columns
3. Include foreign key constraints for relationships
4. Add created_at and updated_at timestamps
```

Infrastructure skills using the `supermemory` skill pattern help maintain context across deployments and environment configurations.

## Expanding Your Database Skill Library

The schema design skill handles table creation, but you need additional skills for the full database lifecycle:

Migration skill. Generates forward and rollback migration files:

```yaml
---
name: db-migration
description: Generate numbered migration files with up and down functions
---

Database Migration Pattern

Always generate paired up/down migrations. File names follow: `YYYYMMDDHHMMSS_description.ts`

```ts
// 20260314120000_add_refresh_tokens.ts
import { Knex } from 'knex';

export async function up(knex: Knex): Promise<void> {
 await knex.schema.createTable('refresh_tokens', (table) => {
 table.uuid('id').primary().defaultTo(knex.raw('gen_random_uuid()'));
 table.uuid('user_id').notNullable().references('id').inTable('users').onDelete('CASCADE');
 table.string('token_hash', 64).notNullable().unique();
 table.timestamp('expires_at').notNullable();
 table.timestamp('created_at').defaultTo(knex.fn.now());
 table.index(['user_id']);
 table.index(['token_hash']);
 });
}

export async function down(knex: Knex): Promise<void> {
 await knex.schema.dropTableIfExists('refresh_tokens');
}
```
```

Query optimization skill. Guides Claude toward performant queries for your specific schema:

```yaml
---
name: query-optimizer
description: Write optimized PostgreSQL queries with proper index usage
---

Query Optimization Rules

1. Always use EXPLAIN ANALYZE before finalizing queries on large tables
2. Prefer CTEs for readability on complex queries, but inline for performance-critical paths
3. Never use SELECT * in application code
4. Use connection pooling (pg-pool or pgBouncer). never open raw connections in request handlers
5. Parameterize all user input. never interpolate variables into query strings

Paginated query with cursor

```sql
-- Keyset pagination outperforms OFFSET at scale
SELECT id, user_id, created_at, amount
FROM orders
WHERE created_at < $1 -- cursor value from last page
 AND status = $2
ORDER BY created_at DESC
LIMIT $3;
```
```

## Comparing Skill Approaches: Inline vs. Dedicated Files

There are two ways to give Claude database guidance: inline in a CLAUDE.md project file, or as dedicated skill files. Each has its place:

| Approach | Best For | Drawback |
|----------|----------|----------|
| Inline in CLAUDE.md | Project-wide rules, small teams, single repo | Gets long; harder to compose selectively |
| Dedicated skill files | Reusable across projects, team libraries, CI integration | Requires skill invocation discipline |
| Both combined | Large fullstack teams with shared conventions | Initial setup overhead |

For most solo developers and small teams, start with inline rules in CLAUDE.md. Move to dedicated skill files when you find yourself copying the same instructions across multiple projects.

## Cross-Cutting Skills for Fullstack Projects

Beyond layer-specific skills, create skills that span the entire stack:

- Code Review Skills: Analyze both frontend and backend changes holistically
- Debug Skills: Trace issues across API boundaries and database queries
- Documentation Skills: Generate docs for APIs, components, and databases simultaneously
- Migration Skills: Handle data and schema migrations across stack updates

```yaml
---
name: fullstack-debug
description: Debug issues across frontend, API, and database layers
---

Fullstack Debugging Workflow

When debugging issues:

1. Start with frontend error messages and console logs
2. Trace API requests to understand data flow
3. Check backend logs for exceptions
4. Verify database queries and connection states
5. Reproduce the issue in development before proposing fixes
```

## A Production-Grade Code Review Skill

Code review skills are some of the most valuable in a team library because they encode collective knowledge about what typically goes wrong in your codebase:

```yaml
---
name: fullstack-code-review
description: Perform systematic code review across frontend and backend changes
---

Fullstack Code Review Checklist

Security (block on any of these)
- [ ] No raw SQL string interpolation. parameterized queries only
- [ ] No secrets or API keys in source code or client-side bundles
- [ ] Authentication checks on all protected API routes
- [ ] Input validation before any database write
- [ ] No sensitive data in console.log or error responses

Performance
- [ ] No N+1 query patterns. use joins or batch fetching
- [ ] Frontend: no unnecessary re-renders (check dependency arrays in useEffect)
- [ ] API responses paginated for list endpoints
- [ ] Database indexes exist for all filtered/sorted columns

Correctness
- [ ] Error states handled and surfaced to the user
- [ ] Loading states shown during async operations
- [ ] Form validation matches backend validation rules
- [ ] Edge cases: empty states, null values, zero counts

Code Quality
- [ ] No commented-out code
- [ ] TypeScript `any` types justified with a comment
- [ ] New environment variables documented in .env.example
```

## A Structured Debugging Workflow Skill

The debugging skill above covers the basics. An extended version guides Claude through a more systematic investigation:

```yaml
---
name: api-debug
description: Systematically debug API issues with request/response tracing
---

API Debugging Protocol

When an API endpoint behaves unexpectedly:

Step 1: Reproduce with curl
Always start by reproducing outside the browser. Provide a minimal curl command.

```bash
curl -v -X POST https://api.example.com/v1/orders \
 -H "Authorization: Bearer $TOKEN" \
 -H "Content-Type: application/json" \
 -d '{"product_id": "abc123", "quantity": 2}'
```

Step 2: Isolate the layer
- 4xx errors: input validation or auth. check request headers and body
- 5xx errors: server-side exception. check application logs
- Timeout: database query or external service. check slow query logs

Step 3: Trace the database
For 500 errors, log the exact SQL and parameters being executed. Enable query logging in development.

Step 4: Propose fix with test
Every bug fix must be accompanied by a test that fails before the fix and passes after.
```

## Organizing Your Skill Library

Structure your skill files for discoverability and maintainability:

```
skills/
 frontend/
 react-components.md
 vue-composition.md
 styling-guide.md
 backend/
 api-design.md
 auth-patterns.md
 error-handling.md
 database/
 postgres-schemas.md
 migrations.md
 shared/
 code-review.md
 debugging.md
```

This organization mirrors your project structure, making skills easy to find when working in specific areas.

## Versioning and Maintaining Skills

Skills are code. They deserve the same maintenance discipline as your application code. Apply these practices:

Track skills in git. Commit skill files alongside the code they influence. A PR that changes your API error handling conventions should update `skills/backend/error-handling.md` in the same commit.

Date-stamp major changes. Add a `last_updated` field to skill front matter so team members know when a skill was last reviewed:

```yaml
---
name: react-component-builder
description: Generate React components following team conventions
last_updated: 2026-03-14
version: 2.1
---
```

Review skills after incidents. If Claude generated code that caused a bug or required significant rework, update the relevant skill to prevent recurrence. Add the anti-pattern explicitly to the skill's "Never do" list.

Prune stale skills. A skill that describes your old class-component patterns will actively confuse Claude. Delete or archive skills that no longer reflect your codebase.

## Sharing Skills Across Projects

When you work on multiple projects with similar tech stacks, a shared skill library reduces duplication. One pattern that works well is a separate git repository for shared skills, included as a git submodule or symlinked into each project:

```
~/dev/
 skills-library/ # shared skill repo
 react/
 node-api/
 postgres/
 project-alpha/
 skills -> ../skills-library # symlink
 project-beta/
 skills -> ../skills-library # symlink
```

Project-specific overrides live in the project's own `skills/` directory at higher precedence. Claude uses the project-specific skill when both exist.

## Advanced Skill Composition

Combine multiple skills effectively by understanding their interaction. A typical fullstack session might invoke:

1. `frontend-design` for UI components
2. `api-rest-designer` for backend endpoints
3. `tdd` for test coverage
4. `pdf` for generating project documentation

Claude automatically selects relevant skills based on context, but you can explicitly invoke skills using the skill invocation syntax.

## How Skill Composition Works in Practice

When multiple skills apply to a task, Claude merges their guidance. The order of invocation matters when skills have conflicting instructions. Resolving conflicts explicitly is better than leaving it to chance.

For example, your `react-component` skill might specify named exports, while an older `legacy-patterns` skill specifies default exports. If both are active, Claude will pick one. and it may not be consistent across requests. Explicit conflict resolution in the skill file prevents this:

```yaml
---
name: react-component-builder
description: Generate React components. overrides legacy-patterns for all .tsx files
---

React Component Builder

Override Note
This skill supersedes `legacy-patterns` for all component generation tasks.
Named exports only. ignore any default export guidance from other skills.
```

## Skill Templates for Common Fullstack Stacks

To accelerate setup, here are starter skill configurations for three common stacks:

Next.js + PostgreSQL + Prisma:
- `skills/frontend/nextjs-pages.md`. page structure, getServerSideProps vs getStaticProps decision tree
- `skills/frontend/nextjs-api-routes.md`. API route conventions, error handling
- `skills/database/prisma-schema.md`. model naming, relation conventions, migration workflow
- `skills/shared/nextjs-auth.md`. NextAuth.js session handling patterns

Express + TypeORM + React:
- `skills/backend/express-routes.md`. router organization, middleware order
- `skills/database/typeorm-entities.md`. entity naming, relation decorators, migration generation
- `skills/frontend/react-query.md`. TanStack Query patterns, cache invalidation strategies
- `skills/shared/monorepo-conventions.md`. shared types, import paths across packages

FastAPI + SQLAlchemy + Vue:
- `skills/backend/fastapi-routers.md`. router organization, dependency injection patterns
- `skills/database/sqlalchemy-models.md`. declarative model conventions, Alembic migrations
- `skills/frontend/vue-composition.md`. Composition API patterns, Pinia store structure
- `skills/shared/openapi-types.md`. generating TypeScript types from FastAPI's OpenAPI schema

## Real-World Example: Adding a New Feature

Consider adding user authentication to a fullstack application. Your workflow with Claude skills:

1. Design Phase: Use `api-rest-designer` to define auth endpoints
2. Backend Implementation: Apply `tdd` skill for test-driven auth logic
3. Frontend Integration: Invoke `frontend-design` for login/registration forms
4. Documentation: Use `pdf` skill to generate API docs
5. Database: Apply `postgres-schema-design` for users table

Each skill contributes specialized guidance while maintaining consistency across the full stack.

## Walking Through the Authentication Feature in Detail

A concrete walkthrough shows how skills interact in a real implementation session.

Step 1. API design. You invoke the `api-rest-designer` skill and ask for authentication endpoints. The skill enforces REST conventions and Claude returns:

```
POST /api/v1/auth/register → 201 Created + { user, token }
POST /api/v1/auth/login → 200 OK + { user, token, refreshToken }
POST /api/v1/auth/refresh → 200 OK + { token }
DELETE /api/v1/auth/logout → 204 No Content
```

Step 2. Database schema. You invoke `postgres-schema-designer` and describe the users table requirements. The skill enforces UUID primary keys and timestamp columns. Claude generates:

```sql
CREATE TABLE users (
 id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
 email VARCHAR(255) NOT NULL UNIQUE,
 password_hash VARCHAR(255) NOT NULL,
 role VARCHAR(50) NOT NULL DEFAULT 'user',
 email_verified_at TIMESTAMP,
 created_at TIMESTAMP NOT NULL DEFAULT NOW(),
 updated_at TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_users_email ON users(email);
```

Step 3. Test-driven backend. You invoke `tdd` and `auth-middleware` together. Claude writes failing tests first, then the implementation:

```ts
// auth.test.ts. generated before implementation
describe('POST /api/v1/auth/login', () => {
 it('returns 200 with tokens for valid credentials', async () => {
 const res = await request(app)
 .post('/api/v1/auth/login')
 .send({ email: 'test@example.com', password: 'password123' });
 expect(res.status).toBe(200);
 expect(res.body).toHaveProperty('token');
 expect(res.body).toHaveProperty('refreshToken');
 });

 it('returns 401 for invalid password', async () => {
 const res = await request(app)
 .post('/api/v1/auth/login')
 .send({ email: 'test@example.com', password: 'wrong' });
 expect(res.status).toBe(401);
 });
});
```

Step 4. Frontend forms. You invoke `react-component-builder` and `form-validator`. Claude generates a typed LoginForm component with Zod schema validation and proper aria attributes in one pass, conforming to all your frontend skill rules.

This four-step flow produces consistent, reviewable output because every decision. naming, error codes, validation approach, component structure. is governed by a skill file rather than Claude's defaults.

## Best Practices

- Keep skills focused: Single-responsibility skills are easier to maintain and compose
- Use descriptive names: Skill names should indicate their purpose at a glance
- Include examples: Real code examples in skills improve output quality
- Version your skills: Track changes in git alongside your project code
- Test skill outputs: Verify that skill-generated code meets your standards

## Measuring Skill Effectiveness

Measuring Skill Effectiveness is worth tracking whether your skills are actually improving output quality. These are practical signals to watch:

- Revision rate: How often do you edit Claude's output before committing? Skills should reduce this over time.
- Convention violations: Run your linter and type checker on Claude-generated code. Skills should drive violation counts toward zero.
- Session length: If you need more follow-up prompts to get correct output, the relevant skill needs more specificity.
- Cross-session consistency: Generate the same type of component in two separate sessions. If the results look meaningfully different, the skill needs stronger constraints.

A well-maintained skill library typically reduces first-draft revision time by 50-70% compared to general-purpose prompting, because Claude is working within your conventions rather than inventing its own.

## Conclusion

Claude .md skill files provide a powerful mechanism for standardizing fullstack development workflows. By creating layer-specific skills for frontend, backend, and database work, and combining them with cross-cutting skills for debugging and documentation, you build a personalized development assistant that understands your project conventions and accelerates delivery across the entire stack.

Start with skills for your most frequent tasks, then expand as you identify patterns worth codifying. Treat skills as living documents that evolve with your codebase. update them after incidents, after convention changes, and whenever Claude's output requires too many corrections. The investment in creating and maintaining your skill library pays dividends in consistent code quality, faster development cycles, and a team that ships with more confidence.

---

---

<div class="mastery-cta">

This site was built by 5 autonomous agents running in tmux while I was in Bali. 2,500 articles. Zero manual work. 100% quality gate pass rate.

The orchestration configs, sprint templates, and quality gates that made that possible are in the Zovo Lifetime bundle. Along with 16 CLAUDE.md templates and 80 tested prompts.

**[See how the pipeline works →](https://zovo.one/lifetime?utm_source=ccg&utm_medium=cta-skills&utm_campaign=claude-md-for-fullstack-projects-complete-guide)**

$99 once. I'm a solo dev in Da Nang. This is how I scale.

</div>

Related Reading

- [Claude MD Example for Remix Fullstack Application](/claude-md-example-for-remix-fullstack-application/)
- [Using Claude Code with Bun Runtime for JavaScript Projects](/using-claude-code-with-bun-runtime-javascript-projects/)
- [Best Way to Use Claude Code for Rapid Prototyping](/best-way-to-use-claude-code-for-rapid-prototyping/)

Built by theluckystrike. More at [zovo.one](https://zovo.one)

## See Also

- [CLAUDE.md for Security Rules — Prevent Vulnerabilities at Generation Time (2026)](/claude-md-security-rules/)
- [CLAUDE.md for Frontend Projects — React, Component, and State Rules (2026)](/claude-md-frontend-projects/)
