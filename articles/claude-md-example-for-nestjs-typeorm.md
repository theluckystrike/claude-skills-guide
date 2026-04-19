---
title: "CLAUDE.md Example for NestJS + TypeORM — Production Template (2026)"
description: "Complete 310-line CLAUDE.md for NestJS 11 with TypeORM 0.3. Covers modules, providers, guards, interceptors, and pipe patterns. Tested on NestJS 11.0.1."
permalink: /claude-md-example-for-nestjs-typeorm/
render_with_liquid: false
categories: [claude-md, templates, 2026]
tags: [claude-code, claude-md, nestjs, typeorm, typescript]
last_updated: 2026-04-19
---

## What This Template Does

This CLAUDE.md configures Claude Code for NestJS 11.0 applications with TypeORM 0.3, PostgreSQL, and the full NestJS decorator ecosystem. It enforces proper module boundaries, prevents circular dependency issues, and ensures guards/interceptors/pipes are used correctly instead of raw Express middleware. The template covers the provider registration pattern, DTO validation with class-validator, and TypeORM migration workflows. Tested against production microservices with 50+ modules and 200+ endpoints.

## The Complete Template

{% raw %}
```markdown
# CLAUDE.md — NestJS 11 + TypeORM 0.3

## Project Stack

- Node.js 22.12.0 (LTS)
- NestJS 11.0.1 (@nestjs/core, @nestjs/common, @nestjs/platform-express)
- TypeORM 0.3.20 (@nestjs/typeorm)
- PostgreSQL 16.4
- TypeScript 5.6.3 (strict mode)
- class-validator 0.14.1 + class-transformer 0.5.1
- Passport 0.7.0 (@nestjs/passport, passport-jwt)
- Swagger/OpenAPI (@nestjs/swagger 8.1.0)
- Bull 4.16.5 (@nestjs/bull) for job queues
- Redis (ioredis 5.4.2)
- Jest 30.0.0 (@nestjs/testing)
- pnpm 9.15.4

## Build & Dev Commands

- Dev: `pnpm start:dev` (nest start --watch)
- Debug: `pnpm start:debug` (nest start --debug --watch)
- Build: `pnpm build` (nest build)
- Start prod: `pnpm start:prod` (node dist/main.js)
- Test: `pnpm test` (jest)
- Test watch: `pnpm test:watch`
- Test e2e: `pnpm test:e2e` (jest --config jest-e2e.json)
- Test coverage: `pnpm test:cov`
- Lint: `pnpm lint` (eslint)
- Format: `pnpm format` (prettier)
- Migration generate: `pnpm typeorm migration:generate src/database/migrations/Description`
- Migration run: `pnpm typeorm migration:run`
- Migration revert: `pnpm typeorm migration:revert`
- Swagger: visit http://localhost:3000/api (auto-generated docs)

## Project Layout

```
src/
  main.ts                       # Bootstrap: create app, configure, listen
  app.module.ts                 # Root module importing all feature modules
  app.controller.ts             # Health check endpoint
  config/
    configuration.ts            # ConfigService factory (typed config)
    database.config.ts          # TypeORM configuration
    validation.schema.ts        # Joi schema for env validation
  common/
    decorators/                 # Custom decorators
      current-user.decorator.ts # @CurrentUser() parameter decorator
      public.decorator.ts       # @Public() skip auth decorator
      roles.decorator.ts        # @Roles('admin') decorator
    filters/
      http-exception.filter.ts  # Global exception filter
      all-exceptions.filter.ts  # Catch-all filter for unhandled errors
    guards/
      jwt-auth.guard.ts         # JWT authentication guard
      roles.guard.ts            # Role-based authorization guard
    interceptors/
      logging.interceptor.ts    # Request/response logging
      transform.interceptor.ts  # Wrap responses in { data, meta } envelope
      timeout.interceptor.ts    # Request timeout (30s)
    pipes/
      parse-uuid.pipe.ts        # UUID parameter validation
    dto/
      pagination.dto.ts         # PaginationQueryDto base class
  modules/
    users/
      users.module.ts           # Module declaration
      users.controller.ts       # REST endpoints
      users.service.ts          # Business logic
      entities/
        user.entity.ts          # TypeORM entity
      dto/
        create-user.dto.ts      # Input validation DTO
        update-user.dto.ts      # Partial input DTO
        user-response.dto.ts    # Response serialization DTO
      users.repository.ts       # Custom repository (if extending base)
      users.controller.spec.ts  # Controller unit test
      users.service.spec.ts     # Service unit test
    auth/
      auth.module.ts
      auth.controller.ts
      auth.service.ts
      strategies/
        jwt.strategy.ts         # Passport JWT strategy
        local.strategy.ts       # Username/password strategy
  database/
    migrations/                 # TypeORM migration files
    seeds/                      # Seed scripts
    data-source.ts              # TypeORM DataSource for CLI
```

## Architecture Rules

- Modular architecture. Every feature is a NestJS module with its own controller, service, entities, and DTOs.
- Module boundaries: modules communicate through exported services. Never import a service directly from another module — import the module and use its exported provider.
- Dependency injection everywhere. Never use `new ServiceClass()`. Let NestJS IoC container manage lifecycle.
- Controller → Service → Repository layering. Controllers handle HTTP decorators and validation. Services contain business logic. Repositories (or TypeORM EntityManager) handle database queries.
- Global modules: `ConfigModule`, `DatabaseModule`, `AuthModule` (with guards). Register as global with `@Global()` or import in `AppModule`.
- Guards for authentication and authorization. `JwtAuthGuard` globally applied via `APP_GUARD`. `@Public()` decorator exempts specific endpoints.
- Interceptors for cross-cutting concerns: logging, response transformation, caching, timeout.
- Pipes for input transformation and validation. `ValidationPipe` globally with `whitelist: true, transform: true`.
- Exception filters for error formatting. Global `HttpExceptionFilter` formats all error responses consistently.
- DTOs for every endpoint: `CreateUserDto` (input), `UpdateUserDto` (partial input), `UserResponseDto` (output with `@Exclude` on sensitive fields).

## Coding Conventions

- TypeScript strict mode. No `any`. No `@ts-ignore`.
- NestJS decorators: `@Controller()`, `@Injectable()`, `@Module()`, `@Get()`, `@Post()`, `@Body()`, `@Param()`, `@Query()`.
- Class-based: services and controllers are classes with constructor injection. No functional patterns for NestJS providers.
- DTO validation: class-validator decorators on properties. `@IsString()`, `@IsEmail()`, `@MinLength(8)`, `@IsOptional()`.
- Entity naming: PascalCase class, singular name (`User`, not `Users`). Table name auto-derived (lowercase, configurable).
- File naming: kebab-case. `user.entity.ts`, `create-user.dto.ts`, `users.service.ts`, `jwt-auth.guard.ts`.
- Module structure: every module in `src/modules/<feature>/`. Module file: `<feature>.module.ts`.
- Controller routes: plural nouns (`/users`, `/posts`). RESTful: GET for reads, POST for creates, PATCH for partial updates, DELETE for deletes.
- Service methods: `create()`, `findAll()`, `findOne()`, `update()`, `remove()` for CRUD. Custom methods for complex operations.
- Swagger decorators: `@ApiTags()`, `@ApiOperation()`, `@ApiResponse()`, `@ApiBearerAuth()` on every controller and endpoint.
- Import order: NestJS core, NestJS modules, third-party, local modules, relative imports.
- Barrel exports: each module exports through its `module.ts`. No `index.ts` barrel files.
- Async/await for all async operations. No raw Promises or callbacks.

## Error Handling

- Global exception filter: `@Catch()` catches all exceptions. Formats response as `{ statusCode, message, error, timestamp, path }`.
- NestJS built-in exceptions: `NotFoundException`, `BadRequestException`, `UnauthorizedException`, `ForbiddenException`, `ConflictException`.
- Custom exceptions: extend `HttpException` or NestJS built-in exceptions. Add error codes for machine-readable identification.
- Validation errors: `ValidationPipe` with `exceptionFactory` returns structured field-level errors.
- TypeORM errors: catch in service layer. Unique violation (code `23505`) → `ConflictException`. Foreign key violation → `BadRequestException`.
- Never throw raw `Error()` in services. Use NestJS exception classes.
- Business rule violations: create custom exceptions (`InsufficientFundsException extends BadRequestException`).
- Logging: use NestJS `Logger` service. Inject with `private readonly logger = new Logger(UsersService.name)`.
- Unhandled promise rejections: handled by NestJS built-in exception zone. No process-level handlers needed.

## Testing Conventions

- Jest with `@nestjs/testing` `Test.createTestingModule()`.
- Unit tests: test services with mocked repositories. Use `jest.fn()` or `@golevelup/ts-jest` for mock providers.
- Controller tests: test with `Test.createTestingModule()`. Mock services. Assert decorator behavior via `supertest`.
- E2E tests: `INestApplication` with real database. Test full HTTP request lifecycle.
- Test file naming: `<name>.spec.ts` co-located with source. E2E tests in `test/` directory.
- Module testing setup:
  ```
  const module = await Test.createTestingModule({
    providers: [UsersService, { provide: getRepositoryToken(User), useValue: mockRepo }],
  }).compile();
  ```
- Mock repository: `{ find: jest.fn(), findOne: jest.fn(), save: jest.fn(), create: jest.fn() }`.
- Assert patterns: `expect(result).toBeDefined()`, `expect(service.create).toHaveBeenCalledWith(dto)`.
- Test database: separate PostgreSQL. Migrate before suite. Truncate between tests.
- Coverage: 90% for services, 80% for controllers, 70% for guards and interceptors.

## Database & TypeORM Patterns

- Entity definition: `@Entity()` decorator. `@Column()` for fields. `@PrimaryGeneratedColumn('uuid')` for IDs.
- Relations: `@ManyToOne`, `@OneToMany`, `@ManyToMany` with `@JoinColumn()` and `@JoinTable()`.
- Base entity: `BaseEntity` with `id`, `createdAt`, `updatedAt`, `deletedAt` columns. All entities extend it.
- Eager loading: use `relations` option in `find()`. Specify exactly which relations: `{ relations: ['posts', 'profile'] }`.
- QueryBuilder: use for complex queries. `this.repo.createQueryBuilder('user').where(...)`.
- Migrations: auto-generate with `migration:generate`. Review generated SQL. Never use `synchronize: true` in production.
- Transactions: `this.dataSource.transaction(async (manager) => { ... })`. Pass `manager` to all operations.
- Repository custom methods: extend `Repository<Entity>` with `@Injectable()`. Register in module providers.
- Soft deletes: `@DeleteDateColumn()` on base entity. Use `softDelete()` and `restore()`. Query with `withDeleted: true`.
- Pagination: `findAndCount()` with `skip` and `take`. Return `{ items, total, page, pages }`.
- Indexes: `@Index(['email'], { unique: true })` on entity class. Composite indexes as class decorator.

## Security

- JWT auth: Passport strategy validates token. Guard globally applied. `@Public()` exempts endpoints.
- Role-based access: `@Roles('admin')` decorator + `RolesGuard`. Check user role from JWT payload.
- Helmet: `app.use(helmet())` in bootstrap. Security headers.
- CORS: `app.enableCors({ origin: allowedOrigins })`. No wildcard in production.
- Rate limiting: `@nestjs/throttler` with `ThrottlerGuard` globally applied. `@SkipThrottle()` for internal endpoints.
- Validation whitelist: `ValidationPipe({ whitelist: true, forbidNonWhitelisted: true })` strips unknown properties.
- Password: bcrypt with 12 rounds. `@Exclude()` on password field in response DTO.

## What Claude Should Never Do

- Never use `new ServiceClass()` to create service instances. NestJS dependency injection manages all providers.
- Never import a service directly from another module's internal files. Import the module, then inject the exported service.
- Never use raw Express middleware (`app.use(fn)`) for authentication, validation, or authorization. Use NestJS Guards, Pipes, and Interceptors.
- Never use `synchronize: true` in TypeORM production configuration. Use migrations exclusively.
- Never use `@Res()` decorator to access the raw Express response unless absolutely necessary (it disables NestJS interceptors).
- Never put business logic in controllers. Controllers delegate to services.
- Never skip `class-validator` decorators on DTO properties. Every field must have validation.
- Never use `any` type in TypeScript. Define proper interfaces, DTOs, and entity types.
- Never create circular module dependencies. If A imports B and B imports A, extract shared logic into a third module.
- Never use `console.log`. Use NestJS `Logger` service for structured logging.
- Never skip Swagger decorators on API endpoints. Every endpoint must be documented.

## Project-Specific Context

- [YOUR PROJECT NAME] — update with your project details
- Database: PostgreSQL via [RDS / Cloud SQL / Supabase]
- Cache: Redis via [ElastiCache / Upstash]
- Queue: Bull with Redis backend
- Deployment: Docker → [Kubernetes / ECS / Cloud Run / Railway]
- Monitoring: [Sentry] for errors, [Prometheus + Grafana] for metrics
- CI/CD: GitHub Actions → test → build → Docker push → deploy
```
{% endraw %}

## How to Adapt This For Your Project

Start with the **Project Stack** section and match versions to your `package.json`. If you use Prisma instead of TypeORM, replace the entity patterns with Prisma schema definitions and replace `@InjectRepository` with a Prisma service. If you use microservices (NestJS transport layers), add a section on message patterns and event handling. The module structure and decorator patterns are NestJS-specific and should stay as-is. The guard/interceptor/pipe patterns are the highest-value section — they prevent Claude from falling back to raw Express patterns.

## Common CLAUDE.md Mistakes in NestJS Projects

1. **Not prohibiting raw Express patterns.** Without explicit rules, Claude uses `app.use()` for authentication and `(req, res, next)` middleware instead of NestJS Guards and Interceptors. This bypasses the NestJS lifecycle and breaks decorator functionality.

2. **Missing module boundary rules.** Claude imports services directly from other modules' files instead of importing the module and using exported providers. This creates tight coupling and breaks NestJS dependency injection.

3. **Allowing `synchronize: true` in production.** Claude enables TypeORM synchronize for convenience, which auto-modifies database schema on every restart — a catastrophic production risk.

4. **Skipping class-validator decorators.** Without validation rules, Claude creates DTOs as plain interfaces (which cannot be validated at runtime) instead of classes with class-validator decorators.

5. **Using `@Res()` to send responses.** Claude accesses the raw Express response object, which disables NestJS interceptors and exception filters. Specify that return values and exceptions are the correct response mechanism.

## What Claude Code Does With This

With this CLAUDE.md loaded, Claude Code generates proper NestJS modules with controllers, services, entities, and DTOs following the decorator pattern. Authentication uses Guards instead of Express middleware. Input validation uses class-validator DTOs with the global `ValidationPipe`. Response transformation uses Interceptors. Error handling uses Exception Filters. TypeORM entities get proper decorators, relations, and migration-based schema management. Module boundaries are respected — services are exported and imported through module declarations.

## The Full 16-Template Pack

This is one of 16 production CLAUDE.md templates available in the Lifetime pack. Includes templates for Node.js + Express + Prisma, Next.js + TypeScript, Django + PostgreSQL, Rails + Turbo, and 11 more stacks. Each template is 200-400 lines of production-tested configuration. Get all 16 at [claudecodeguides.com/generator/](https://claudecodeguides.com/generator/).
