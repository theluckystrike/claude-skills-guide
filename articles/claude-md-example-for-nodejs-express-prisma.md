---
title: "CLAUDE.md Example for Node.js + Express (2026)"
description: "Complete 300-line CLAUDE.md for Node.js 22 with Express 5 and Prisma 6. Covers middleware patterns, Prisma schema design, and error middleware chains."
permalink: /claude-md-example-for-nodejs-express-prisma/
render_with_liquid: false
categories: [claude-md, templates, 2026]
tags: [claude-code, claude-md, nodejs, express, prisma]
last_updated: 2026-04-19
---

## What This Template Does

This CLAUDE.md configures Claude Code for Node.js 22 REST APIs using Express 5, Prisma 6, and TypeScript 5.6. It enforces proper Express middleware ordering, prevents Prisma N+1 queries through explicit `include` rules, and ensures error handling follows the centralized error middleware pattern instead of try/catch in every route. The template covers the Prisma migration workflow, request validation with Zod, and structured logging with Pino. Tested against production APIs with 80+ Prisma models and 150+ Express routes.

## The Complete Template

{% raw %}
```markdown
# CLAUDE.md — Node.js 22 + Express 5 + Prisma 6

## Project Stack

- Node.js 22.12.0 (LTS)
- Express 5.0.1
- TypeScript 5.6.3 (strict mode)
- Prisma 6.2.1 (PostgreSQL)
- Zod 3.24.1 (request validation)
- Pino 9.6.0 (structured logging)
- Passport 0.7.0 + passport-jwt (authentication)
- Redis (ioredis 5.4.2) for caching and sessions
- Bull 4.16.5 (job queue on Redis)
- Vitest 2.1.8 (testing)
- pnpm 9.15.4 (package manager)
- ESLint 9.17.0 (flat config + typescript-eslint)

## Build & Dev Commands

- Dev: `pnpm dev` (tsx watch mode)
- Build: `pnpm build` (tsc → dist/)
- Start: `pnpm start` (node dist/index.js)
- Test: `pnpm test` (vitest)
- Test watch: `pnpm test:watch`
- Test coverage: `pnpm test:coverage`
- Lint: `pnpm lint` (eslint)
- Format: `pnpm format` (prettier)
- Type check: `pnpm typecheck` (tsc --noEmit)
- Prisma generate: `pnpm prisma generate`
- Prisma migrate dev: `pnpm prisma migrate dev`
- Prisma migrate deploy: `pnpm prisma migrate deploy`
- Prisma studio: `pnpm prisma studio`
- Prisma seed: `pnpm prisma db seed`
- Docker: `docker compose up -d` (PostgreSQL + Redis)

## Project Layout

```
src/
  index.ts                  # Entry: create app, start server
  app.ts                    # Express app factory with middleware
  config/
    env.ts                  # Environment variable validation (Zod)
    database.ts             # Prisma client singleton
    redis.ts                # Redis client singleton
    logger.ts               # Pino logger configuration
  middleware/
    errorHandler.ts         # Centralized error handler (MUST be last)
    notFound.ts             # 404 handler for unmatched routes
    auth.ts                 # JWT authentication middleware
    validate.ts             # Zod validation middleware factory
    requestId.ts            # Attach request ID to each request
    rateLimiter.ts          # Rate limiting middleware
  routes/
    index.ts                # Route aggregator: mount all routers
    userRoutes.ts           # /api/v1/users routes
    authRoutes.ts           # /api/v1/auth routes
    healthRoutes.ts         # /api/health routes
  controllers/
    userController.ts       # User request handlers
    authController.ts       # Auth request handlers
  services/
    userService.ts          # User business logic
    authService.ts          # Authentication logic
    emailService.ts         # Email sending
  repositories/
    userRepository.ts       # Prisma queries for users
    baseRepository.ts       # Generic CRUD repository
  schemas/
    userSchemas.ts          # Zod schemas for user endpoints
    authSchemas.ts          # Zod schemas for auth endpoints
    common.ts               # Shared schemas (pagination, ID params)
  types/
    express.d.ts            # Express type augmentation (req.user)
    common.ts               # Shared TypeScript types
  utils/
    asyncHandler.ts         # Async error wrapper for Express
    hash.ts                 # Password hashing utilities
    jwt.ts                  # JWT sign/verify helpers
    pagination.ts           # Pagination helper
  jobs/
    emailJob.ts             # Bull queue job for emails
    processor.ts            # Job processor setup
prisma/
  schema.prisma             # Prisma schema (models, relations)
  migrations/               # Migration history
  seed.ts                   # Database seeding
tests/
  setup.ts                  # Test setup: database, mocks
  helpers.ts                # Test utilities
  integration/
    users.test.ts           # User endpoint integration tests
    auth.test.ts            # Auth endpoint integration tests
  unit/
    services/
      userService.test.ts   # Service unit tests
```

## Architecture Rules

- Three-layer architecture: Controller → Service → Repository. Controllers handle HTTP (parse request, send response). Services contain business logic. Repositories execute Prisma queries.
- Express middleware order: (1) request ID, (2) Pino logger, (3) CORS, (4) helmet, (5) compression, (6) JSON parser, (7) rate limiter, (8) routes, (9) 404 handler, (10) error handler. Error handler MUST be last.
- Centralized error handling: never try/catch in controllers. Use `asyncHandler()` wrapper that catches rejected promises and passes to error middleware.
- Prisma client: singleton in `src/config/database.ts`. Never instantiate `new PrismaClient()` outside this file.
- Request validation: Zod schemas in `src/schemas/`. Validate with `validate(schema)` middleware before controller runs.
- Route files: each resource gets its own router file. Mount in `src/routes/index.ts`. API versioned under `/api/v1/`.
- Environment config: validate all env vars at startup with Zod schema in `src/config/env.ts`. Crash immediately on invalid config.
- No ORM logic in controllers. Controllers call services. Services call repositories. Repositories use Prisma.
- Background jobs: Bull queues for anything over 500ms (emails, file processing, external API calls). Jobs are idempotent.

## Coding Conventions

- TypeScript strict mode. No `any`. No `@ts-ignore`. No `as` type assertions unless provably safe.
- Named exports everywhere. No default exports.
- File naming: camelCase (`userController.ts`). One primary export per file.
- Function signatures: typed parameters and return types. Express handlers: `(req: Request, res: Response, next: NextFunction) => void`.
- Error classes extend `AppError` with status code and error code. Example: `NotFoundError`, `ValidationError`, `UnauthorizedError`.
- Import path alias: `@/` maps to `src/`. Configure in `tsconfig.json` and build tool.
- Import order: (1) node built-ins, (2) express, (3) third-party, (4) @/config, (5) @/middleware, (6) @/services, (7) @/types, (8) relative.
- Controller functions are thin: validate input (via middleware), call service, send response. Max 15 lines per controller function.
- Service functions: pure business logic. Accept typed DTOs, return typed results. Never access `req` or `res` objects.
- Repository functions: typed Prisma queries. Return Prisma model types. Handle Prisma-specific errors.
- Async/await everywhere. No raw Promises with `.then()`. No callbacks.
- Prefer `const` over `let`. Never use `var`.
- Arrow functions for short utilities. Named function declarations for exported functions.
- Template literals for string interpolation.

## Error Handling

- AppError base class: `{ statusCode: number, code: string, message: string, details?: unknown }`.
- Specific error classes: `NotFoundError(resource)` → 404, `ValidationError(details)` → 400, `UnauthorizedError()` → 401, `ForbiddenError()` → 403, `ConflictError(resource)` → 409.
- `asyncHandler` wrapper catches rejected promises: `const asyncHandler = (fn) => (req, res, next) => Promise.resolve(fn(req, res, next)).catch(next)`.
- Error handler middleware (last middleware): checks `err instanceof AppError` for known errors. Unknown errors → 500 with generic message.
- Prisma error mapping in repository: `PrismaClientKnownRequestError` code `P2002` → `ConflictError`. Code `P2025` → `NotFoundError`.
- Validation errors: Zod parse errors mapped to structured `{ field: messages[] }` format.
- Logging: errors logged with Pino at error level. Request context (ID, path, method) included.
- Production: never expose stack traces or internal details. Log full error, respond with safe message.
- Process-level: `process.on('unhandledRejection')` and `process.on('uncaughtException')` log and exit gracefully.

## Testing Conventions

- Vitest with `supertest` for HTTP integration tests.
- Integration tests: spin up Express app, connect to test database, test full request/response cycle.
- Unit tests: test service functions with mocked repositories. Use Vitest `vi.mock()`.
- Test database: separate PostgreSQL database. Reset with `prisma migrate reset` before test suite.
- Test helpers: `createTestUser()`, `getAuthToken(user)`, `createTestApp()`.
- Test naming: `it("should return 201 when creating user with valid data")`.
- HTTP assertions: `const res = await request(app).post("/api/v1/users").send(data).expect(201)`.
- Database assertions: query database directly with Prisma to verify side effects.
- Mocking: mock at service boundaries. `vi.spyOn(userService, "create").mockResolvedValue(user)`.
- No snapshot tests. Assert specific fields and values.
- Coverage: 85% for services, 80% for repositories, 75% for controllers.

## Database & Prisma Patterns

- Prisma schema: one source of truth for database structure. Models, relations, enums, indexes all in `schema.prisma`.
- Prisma relations: define on both sides. `User` has `posts Post[]`, `Post` has `author User @relation(fields: [authorId], references: [id])`.
- Select specific fields: never return all columns. Use `select` for read queries. Use `include` only for relations you need.
- Pagination: cursor-based for infinite scroll (`cursor`, `take`, `skip: 1`). Offset-based for page numbers (`skip`, `take`).
- Transactions: `prisma.$transaction([...])` for sequential. `prisma.$transaction(async (tx) => {...})` for interactive. Pass `tx` to repository methods.
- Soft deletes: `deletedAt DateTime?` field. Prisma middleware or custom repository methods to filter.
- Migrations: `prisma migrate dev` creates migration file. Review SQL before applying. Never edit applied migrations.
- Seeding: `prisma/seed.ts` with idempotent seed logic. Use `upsert` for seed data.
- Connection management: Prisma handles pooling. In serverless, limit connections: `connection_limit=5` in URL.
- Raw queries: `prisma.$queryRaw` with tagged templates for parameterization. Never interpolate user input.

## Security

- Helmet middleware for security headers (CSP, HSTS, X-Frame-Options).
- CORS: `cors({ origin: allowedOrigins })`. No wildcard in production.
- JWT: RS256 signing. Access token 15 min, refresh token 7 days. Validate in auth middleware.
- Rate limiting: `express-rate-limit` on auth endpoints. Stricter limits on login (5/min) and registration (3/min).
- Input validation: Zod schemas on all endpoints. Reject unknown fields with `.strict()`.
- SQL injection: Prisma parameterizes all queries. Never use `$queryRawUnsafe` with user input.
- Password hashing: bcrypt with 12 rounds. Never store plaintext.
- Secrets: environment variables. Never commit `.env`. Use secrets manager in production.

## What Claude Should Never Do

- Never put try/catch blocks in controller functions. Use `asyncHandler` wrapper and centralized error middleware.
- Never instantiate `new PrismaClient()` outside `src/config/database.ts`. Use the singleton.
- Never use `any` type. Use `unknown` with type guards or define proper interfaces.
- Never use callbacks for async operations. Use async/await exclusively.
- Never use `var`. Use `const` by default, `let` only when reassignment is required.
- Never return Prisma model types directly from API responses. Transform through DTOs.
- Never put business logic in controllers. Controllers call services. Services contain logic.
- Never use `req.body` without validation. Every endpoint must have a Zod schema validated via middleware.
- Never use `console.log` for logging. Use the Pino logger instance.
- Never access `process.env` directly. Use the validated config module.
- Never modify the middleware order. Error handler MUST be the last middleware registered.

## Project-Specific Context

- [YOUR PROJECT NAME] — update with your project details
- Database: PostgreSQL via [RDS / Supabase / Neon / Docker]
- Cache: Redis via [ElastiCache / Upstash / Docker]
- Deployment: [Docker → ECS/GKE] or [Railway / Render / Fly.io]
- Monitoring: [Sentry] for errors, [Pino → Datadog/Loki] for logs
- CI/CD: GitHub Actions → test → build → deploy
```
{% endraw %}

## How to Adapt This For Your Project

Start with the **Project Stack** section and update versions from your `package.json`. If you use Drizzle ORM instead of Prisma, replace the Prisma-specific patterns with Drizzle schema definitions and query builder patterns. If you use Fastify instead of Express, replace the middleware chain — Fastify uses plugins and hooks instead of `app.use()`. The three-layer architecture and error handling patterns transfer to any Node.js framework. Remove the Bull job section if you do not use background processing.

## Common CLAUDE.md Mistakes in Node.js + Express Projects

1. **Not enforcing centralized error handling.** Without the `asyncHandler` + error middleware pattern, Claude puts try/catch blocks in every controller function. This leads to inconsistent error responses and duplicated error formatting logic.

2. **Missing middleware ordering rules.** Express middleware order matters. Without explicit ordering, Claude places the error handler before routes or adds CORS after route handlers, causing silent failures.

3. **Allowing `any` type in TypeScript.** Claude uses `any` to bypass complex TypeScript errors. Without explicit prohibition, type safety erodes and bugs slip through that TypeScript was supposed to catch.

4. **Not specifying Prisma singleton pattern.** Claude creates `new PrismaClient()` in service files, opening multiple database connections. In serverless environments, this exhausts the connection pool within minutes.

5. **Skipping request validation.** Without Zod validation middleware rules, Claude trusts `req.body` implicitly, casting it with `as CreateUserDto` instead of runtime-validating the input. This allows malformed data to reach business logic.

## What Claude Code Does With This

With this CLAUDE.md loaded, Claude Code generates Express routes wrapped in `asyncHandler` with centralized error middleware. Request validation uses Zod schemas applied as middleware before controllers execute. Prisma queries use the singleton client with explicit `select` and `include` clauses. Error responses follow the consistent `AppError` structure with proper HTTP status codes. Controllers stay thin (under 15 lines), calling service functions that contain the business logic. All TypeScript is strict with no `any` types.

## The Full 16-Template Pack

This is one of 16 production CLAUDE.md templates available in the Lifetime pack. Includes templates for NestJS + TypeORM, Next.js + TypeScript, Django + PostgreSQL, FastAPI + SQLAlchemy, and 11 more stacks. Each template is 200-400 lines of production-tested configuration. Get all 16 at [claudecodeguides.com/generator/](https://claudecodeguides.com/generator/).
