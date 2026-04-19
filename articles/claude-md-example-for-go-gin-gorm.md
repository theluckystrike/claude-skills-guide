---
title: "CLAUDE.md Example for Go + Gin + GORM — Production Template (2026)"
description: "Complete 300-line CLAUDE.md for Go 1.23 with Gin and GORM. Covers middleware chains, context propagation, error wrapping, and struct tags. Tested on Go 1.23.5."
permalink: /claude-md-example-for-go-gin-gorm/
render_with_liquid: false
categories: [claude-md, templates, 2026]
tags: [claude-code, claude-md, go, gin, gorm]
last_updated: 2026-04-19
---

## What This Template Does

This CLAUDE.md configures Claude Code for Go 1.23.5 microservices using Gin for HTTP routing and GORM for database access. It enforces proper Go idioms (error wrapping, context propagation, interface-based dependency injection), prevents Claude from generating Java-style or Python-style Go code, and ensures struct tags are consistent across JSON, GORM, and validation. The template covers middleware chains, graceful shutdown, migration patterns, and table-driven testing. Tested on production services handling 50K requests per second with 40+ endpoints.

## The Complete Template

{% raw %}
```markdown
# CLAUDE.md — Go 1.23 + Gin + GORM

## Project Stack

- Go 1.23.5
- Gin 1.10.0 (HTTP router)
- GORM 1.25.12 (ORM with PostgreSQL driver)
- PostgreSQL 16.4
- Redis 7.4 (go-redis/redis v9)
- golang-migrate v4 (database migrations)
- Zap 1.27.0 (structured logging)
- Viper 1.19.0 (configuration)
- Wire 0.6.0 (compile-time dependency injection)
- testify 1.9.0 (test assertions)
- golangci-lint 1.62.2

## Build & Dev Commands

- Run: `go run ./cmd/api`
- Build: `go build -o bin/api ./cmd/api`
- Test: `go test ./...`
- Test verbose: `go test -v ./internal/handler/...`
- Test single: `go test -run TestCreateUser ./internal/handler/...`
- Test coverage: `go test -coverprofile=coverage.out ./... && go tool cover -html=coverage.out`
- Lint: `golangci-lint run`
- Format: `gofmt -w .`
- Vet: `go vet ./...`
- Tidy: `go mod tidy`
- Migration create: `migrate create -ext sql -dir migrations -seq description`
- Migration up: `migrate -path migrations -database "$DATABASE_URL" up`
- Migration down: `migrate -path migrations -database "$DATABASE_URL" down 1`
- Generate Wire: `wire ./internal/di/`
- Generate mocks: `mockgen -source=internal/repository/user.go -destination=internal/repository/mock/user.go`
- Docker build: `docker build -t api .`

## Project Layout

```
cmd/
  api/
    main.go                # Entry point: config, DI, server start
internal/
  config/
    config.go              # Viper configuration loading
  handler/                 # HTTP handlers (Gin handler functions)
    user_handler.go
    auth_handler.go
    health_handler.go
    middleware/             # Gin middleware
      auth.go              # JWT authentication middleware
      logging.go           # Request logging middleware
      recovery.go          # Panic recovery middleware
      ratelimit.go         # Rate limiting middleware
      cors.go              # CORS middleware
  service/                 # Business logic layer
    user_service.go
    auth_service.go
  repository/              # Database access layer (GORM queries)
    user_repository.go
    base_repository.go
    mock/                  # Generated mocks for testing
  model/                   # GORM models (database structs)
    user.go
    base.go                # BaseModel with ID, timestamps, soft delete
  dto/                     # Request/Response structs (JSON binding)
    user_dto.go
    auth_dto.go
    pagination.go
    error.go
  domain/                  # Domain errors, interfaces
    errors.go              # Sentinel errors and error types
    interfaces.go          # Repository and service interfaces
  di/                      # Wire dependency injection
    wire.go
    wire_gen.go            # Generated — do not edit
pkg/
  validator/               # Custom validators
  response/                # Standardized API response helpers
  jwt/                     # JWT token utilities
  hash/                    # Password hashing utilities
migrations/                # SQL migration files (up and down)
docs/                      # Swagger/OpenAPI generated docs
```

## Architecture Rules

- Three-layer architecture: Handler → Service → Repository. Handlers handle HTTP. Services contain business logic. Repositories handle database queries.
- Dependency direction: handlers depend on service interfaces. Services depend on repository interfaces. Repositories depend on GORM models.
- Interfaces defined in `internal/domain/interfaces.go`. Implementations in their respective packages. Depend on interfaces, not concrete types.
- Wire for compile-time dependency injection. Provider sets in `internal/di/wire.go`. Generated code in `wire_gen.go` — never edit.
- Context propagation: pass `context.Context` as the first parameter of every function that does I/O (database, HTTP, Redis).
- Error wrapping: wrap errors with `fmt.Errorf("operation: %w", err)`. Use `errors.Is()` and `errors.As()` for comparison. Never compare error strings.
- No global state. No `init()` functions except for driver registration. Configuration loaded in `main()` and injected.
- Graceful shutdown: listen for `SIGINT`/`SIGTERM`. Call `server.Shutdown(ctx)` with timeout context. Close database and Redis connections.
- Package boundaries: `internal/` for private packages. `pkg/` for reusable packages. Never import from `cmd/` into `internal/`.
- One struct per file for models and DTOs. One handler file per resource. Group related service methods in one file.

## Coding Conventions

- Go standard formatting (gofmt). No custom style. Tab indentation.
- Naming: exported types PascalCase, unexported camelCase. Interfaces do not have `I` prefix. Acronyms all caps (`UserID`, `HTTPClient`).
- Receiver naming: single lowercase letter matching type initial (`u` for User, `s` for UserService`). Consistent within file.
- Error return: always the last return value. Never panic for recoverable errors. Log and return errors up the stack.
- Struct tags: JSON tags snake_case (`json:"first_name"`), GORM tags (`gorm:"column:first_name;type:varchar(100);not null"`), validation tags (`binding:"required,min=2,max=50"`).
- All three tag sets on every field that touches both database and API. Keep tag order consistent: `json`, `gorm`, `binding`.
- Gin handlers signature: `func (h *UserHandler) Create(c *gin.Context)`. Bind request with `c.ShouldBindJSON(&dto)`.
- Response helpers: `response.Success(c, data)`, `response.Error(c, statusCode, message)`, `response.Paginated(c, items, meta)`.
- GORM queries: use chainable methods (`db.Where().Order().Limit().Find()`). Never use raw SQL unless the query cannot be expressed with GORM.
- Goroutines: only spawn from service layer with proper context and error handling. Use `errgroup` for parallel operations.
- Channel usage: prefer `sync.Mutex` for simple shared state. Use channels for communication between goroutines, not for synchronization.
- No `else` after `if err != nil { return }`. Early return pattern.
- Comments: GoDoc format on exported types and functions. Start with the name: `// UserService handles user business logic.`
- Constants: `const` block at package level. Use `iota` for enums. Typed constants preferred over raw strings.

## Error Handling

- Sentinel errors in `internal/domain/errors.go`: `var ErrNotFound = errors.New("not found")`, `var ErrDuplicate = errors.New("duplicate entry")`.
- Repository layer: translate GORM errors to domain errors. `gorm.ErrRecordNotFound` → `domain.ErrNotFound`. Unique constraint violation → `domain.ErrDuplicate`.
- Service layer: wrap domain errors with context. `fmt.Errorf("create user: %w", domain.ErrDuplicate)`.
- Handler layer: map domain errors to HTTP status codes. `errors.Is(err, domain.ErrNotFound)` → 404. `errors.Is(err, domain.ErrDuplicate)` → 409.
- Validation errors: Gin binding returns `validator.ValidationErrors`. Map to structured error response with field names and messages.
- Panic recovery: Gin `Recovery()` middleware catches panics and returns 500. Log stack trace with Zap.
- Structured error logging: `logger.Error("failed to create user", zap.Error(err), zap.String("email", dto.Email))`.
- Never log and return the same error. Either log at the boundary (handler) or return to the caller.
- Timeout errors: use `context.WithTimeout` for database and external API calls. Handle `context.DeadlineExceeded`.

## Testing Conventions

- Table-driven tests for functions with multiple input/output combinations.
- Test file naming: `user_handler_test.go` alongside `user_handler.go`.
- Test function naming: `TestUserHandler_Create`, `TestUserHandler_Create_DuplicateEmail`.
- Mock generation: `mockgen` for interface-based mocks. Mocks in `internal/repository/mock/`.
- Handler tests: use `httptest.NewRecorder()` and `gin.CreateTestContext()`. Assert status code and response body.
- Service tests: inject mock repositories. Test business logic in isolation.
- Repository tests: test against real PostgreSQL in Docker (testcontainers-go). Test query correctness and error mapping.
- Test helpers in `internal/testutil/`: `NewTestDB()`, `NewTestRouter()`, `CreateTestUser()`.
- Subtests: use `t.Run("description", func(t *testing.T) { ... })` for organized test cases.
- No test globals. Each test function sets up its own dependencies. Use `t.Cleanup()` for teardown.
- Parallel tests: `t.Parallel()` on tests that do not share state. Database tests run sequentially.
- Coverage target: 85% for services, 80% for repositories, 70% for handlers.

## Database & Migration Patterns

- GORM AutoMigrate: only in development for rapid prototyping. Production uses golang-migrate SQL files.
- Migration files: numbered sequentially (`000001_create_users_table.up.sql`, `000001_create_users_table.down.sql`).
- Every migration has both `up.sql` and `down.sql`. Down migration reverses the up migration exactly.
- BaseModel with `ID` (UUID), `CreatedAt`, `UpdatedAt`, `DeletedAt` (soft delete). All models embed `BaseModel`.
- Indexes: add in migration SQL. GORM tags for reference: `gorm:"index:idx_user_email,unique"`.
- Transactions: `db.WithContext(ctx).Transaction(func(tx *gorm.DB) error { ... })`. Pass `tx` to repository methods.
- Connection pooling: configure `SetMaxOpenConns(25)`, `SetMaxIdleConns(10)`, `SetConnMaxLifetime(5 * time.Minute)`.
- Preloading: use `Preload("Posts")` to avoid N+1. Use `Joins()` for filtering on related tables.
- Pagination: cursor-based for infinite scroll. Offset-based with `Scopes(Paginate(page, perPage))`.
- Raw SQL: only for complex reports or performance-critical queries. Use `db.Raw().Scan(&result)` with parameterized queries.

## Security

- JWT: RS256 signing. Access token: 15 min. Refresh token: 7 days. Validate in auth middleware.
- Password hashing: bcrypt with cost 12. Use `golang.org/x/crypto/bcrypt`.
- Input validation: Gin binding tags on DTOs. Custom validators for complex rules.
- Rate limiting: token bucket per IP or user. Middleware with Redis backend.
- CORS: configure allowed origins, methods, headers in CORS middleware. No wildcard in production.
- SQL injection: GORM parameterizes queries. Never interpolate user input into `db.Raw()`.
- Secrets: environment variables loaded by Viper. Never hardcode.

## What Claude Should Never Do

- Never use `panic()` for error handling. Return errors. The only acceptable panic is truly unrecoverable state during initialization.
- Never use global variables for database connections, loggers, or configuration. Pass through dependency injection.
- Never use `init()` functions for application logic. Only for driver registration (`_ "github.com/lib/pq"`).
- Never compare errors with `==`. Use `errors.Is()` and `errors.As()` for wrapped error comparison.
- Never ignore errors with `_`. Handle every error. If truly ignorable, add a comment explaining why.
- Never use `interface{}` (empty interface). Use `any` (Go 1.18+) if needed, but prefer concrete types.
- Never use GORM `AutoMigrate` in production code. Use golang-migrate SQL migrations.
- Never put business logic in handlers. Handlers bind input, call services, and format output.
- Never spawn goroutines without proper context cancellation and error handling via `errgroup`.
- Never use `fmt.Println` for logging. Use structured logging with Zap.
- Never create circular dependencies between packages. Handler → Service → Repository, never backwards.

## Project-Specific Context

- [YOUR PROJECT NAME] — update with your project details
- Database: PostgreSQL via [RDS / Cloud SQL / Docker]
- Cache: Redis via [ElastiCache / Upstash / Docker]
- Message queue: [NATS / RabbitMQ / Redis Streams]
- Deployment: Docker → [Kubernetes / ECS / Cloud Run / Fly.io]
- Monitoring: [Datadog / Prometheus + Grafana] for metrics, [Sentry] for errors
- CI/CD: GitHub Actions → Docker build → deploy
```
{% endraw %}

## How to Adapt This For Your Project

Start with the **Project Stack** section and update Go and dependency versions from your `go.mod`. If you use a different router (chi, Echo, Fiber), replace Gin-specific handler patterns while keeping the three-layer architecture. If you use `sqlx` or `pgx` instead of GORM, replace the ORM patterns with query builder or raw SQL patterns. The dependency injection section uses Wire — if you prefer manual DI in `main()`, remove the Wire references but keep the interface-based design. The error handling pattern (sentinel errors + wrapping + mapping) works regardless of your HTTP framework.

## Common CLAUDE.md Mistakes in Go Projects

1. **Not specifying the error handling pattern.** Without rules about `%w` wrapping and `errors.Is()`, Claude generates Java-style try/catch patterns or Python-style string matching on error messages. Go's error wrapping chain is unique and must be explicitly described.

2. **Allowing global state.** Claude creates `var db *gorm.DB` at package level because it is the simplest approach. Without the DI rule, every test requires resetting global state instead of injecting mock dependencies.

3. **Missing struct tag consistency rules.** Claude generates JSON tags on some fields, GORM tags on others, and validation tags inconsistently. Specify that every model field needs all relevant tag sets in a consistent order.

4. **Not banning `panic` for error handling.** Claude trained on Go examples that use `log.Fatal` and `panic` liberally. Without explicit prohibition, it generates panics for database errors and HTTP failures.

5. **Using GORM `AutoMigrate` in production.** Claude calls `db.AutoMigrate(&User{})` in `main()` because it is convenient. This is dangerous in production — schema changes should go through versioned SQL migrations.

## What Claude Code Does With This

With this CLAUDE.md loaded, Claude Code generates Go code that follows proper idiomatic patterns: errors are wrapped with `%w` and checked with `errors.Is()`, context propagation flows through every function, and dependency injection uses interfaces rather than concrete types. New endpoints follow the Handler → Service → Repository pattern. Database queries use GORM with proper preloading and pagination scopes. Tests are table-driven with proper mock injection. Struct tags include JSON, GORM, and validation tags in consistent order.

## The Full 16-Template Pack

This is one of 16 production CLAUDE.md templates available in the Lifetime pack. Includes templates for Rust + Axum, Next.js + TypeScript, Django + PostgreSQL, FastAPI + SQLAlchemy, and 11 more stacks. Each template is 200-400 lines of production-tested configuration. Get all 16 at [claudecodeguides.com/generator/](https://claudecodeguides.com/generator/).
