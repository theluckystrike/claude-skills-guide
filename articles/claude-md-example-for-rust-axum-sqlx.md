---
title: "CLAUDE.md Example for Rust + Axum + SQLx — Production Template (2026)"
description: "Complete 310-line CLAUDE.md for Rust 1.83 with Axum 0.8 and SQLx. Covers Tower middleware, extractors, thiserror/anyhow patterns, and compile-time query checks. Tested on Axum 0.8.1."
permalink: /claude-md-example-for-rust-axum-sqlx/
render_with_liquid: false
categories: [claude-md, templates, 2026]
tags: [claude-code, claude-md, rust, axum, sqlx]
last_updated: 2026-04-19
---

## What This Template Does

This CLAUDE.md configures Claude Code for Rust web services using Axum 0.8.1, SQLx 0.8 with PostgreSQL, and Tower middleware. It enforces proper error handling with `thiserror` for library errors and `anyhow` for application errors, prevents common Rust footguns (blocking in async context, unnecessary cloning, missing error conversions), and ensures extractors are ordered correctly in handler signatures. The template covers compile-time query verification, Tower layer composition, and structured testing patterns. Tested on production APIs with 30+ endpoints serving 100K requests per second.

## The Complete Template

{% raw %}
```markdown
# CLAUDE.md — Rust 1.83 + Axum 0.8 + SQLx

## Project Stack

- Rust 1.83.0 (2024 edition)
- Axum 0.8.1 (HTTP framework)
- SQLx 0.8.3 (async PostgreSQL, compile-time checked queries)
- PostgreSQL 16.4
- Tokio 1.42.0 (async runtime)
- Tower 0.5.2 (middleware framework)
- Tower-HTTP 0.6.2 (HTTP-specific middleware)
- Serde 1.0.217 (serialization)
- Tracing 0.1.41 + tracing-subscriber 0.3.19
- thiserror 2.0.9 (library error types)
- anyhow 1.0.95 (application error handling)
- validator 0.19.0 (input validation)
- jsonwebtoken 9.3.0 (JWT)
- dotenvy 0.15.7 (environment variables)
- sqlx-cli 0.8.3 (migration tool)
- cargo-watch 8.5.3 (dev hot reload)

## Build & Dev Commands

- Dev: `cargo watch -x run` (auto-restart on changes)
- Build: `cargo build --release`
- Run: `cargo run`
- Test: `cargo test`
- Test single: `cargo test test_create_user`
- Test module: `cargo test handler::user_handler::tests`
- Clippy: `cargo clippy -- -D warnings`
- Format: `cargo fmt`
- Check: `cargo check` (fast type checking without building)
- Doc: `cargo doc --open`
- Migration create: `sqlx migrate add description`
- Migration run: `sqlx migrate run`
- Migration revert: `sqlx migrate revert`
- Prepare queries: `cargo sqlx prepare` (generate offline query metadata)
- Audit deps: `cargo audit`
- Unused deps: `cargo machete`

## Project Layout

```
src/
  main.rs                   # Entry: config, DB pool, router, server start
  config.rs                 # Configuration from environment variables
  lib.rs                    # Re-exports and app state definition
  router.rs                 # Axum router with all routes and middleware
  handler/
    mod.rs                  # Handler module declarations
    user_handler.rs         # User endpoint handlers
    auth_handler.rs         # Auth endpoint handlers
    health_handler.rs       # Health check handler
  service/
    mod.rs
    user_service.rs         # User business logic
    auth_service.rs         # Authentication logic
  repository/
    mod.rs
    user_repository.rs      # SQLx database queries
  model/
    mod.rs
    user.rs                 # Database row structs (sqlx::FromRow)
  dto/
    mod.rs
    user_dto.rs             # Request/Response structs (Deserialize/Serialize)
    auth_dto.rs
    pagination.rs           # Pagination request/response
  error/
    mod.rs
    app_error.rs            # AppError enum with thiserror
    error_response.rs       # JSON error response struct
  middleware/
    mod.rs
    auth.rs                 # JWT authentication layer
    request_id.rs           # Request ID injection
  extractors/
    mod.rs
    validated_json.rs       # Custom extractor: JSON + validation
    auth_user.rs            # Extract authenticated user from request
migrations/
  20240101000000_create_users.sql
tests/
  common/
    mod.rs                  # Shared test utilities and fixtures
  api/
    user_test.rs            # Integration tests for user endpoints
    auth_test.rs            # Integration tests for auth endpoints
Cargo.toml
sqlx-data.json              # Offline query metadata (committed)
.env                        # Local environment (gitignored)
.env.example                # Template for environment variables
```

## Architecture Rules

- Three-layer architecture: Handler → Service → Repository. Handlers extract and validate input, call services, format output. Services contain business logic. Repositories execute database queries.
- Shared application state in `AppState` struct (database pool, config, redis client). Pass to router with `with_state()`. Access in handlers via `State<AppState>` extractor.
- Error handling: `thiserror` for defining error enums with specific variants. `AppError` implements `IntoResponse` for automatic HTTP error mapping.
- No `.unwrap()` or `.expect()` in application code. Use `?` operator for error propagation. `.unwrap()` only allowed in tests.
- Async everywhere. All handlers are `async fn`. All database operations use `sqlx::query!` macro (compile-time checked) or `sqlx::query_as!`.
- Tower middleware stack: logging → request ID → CORS → compression → auth → rate limiting. Applied via `ServiceBuilder::new().layer()`.
- Extractor ordering in handler signatures matters. `State` and `Path` before `Json`. Body-consuming extractors (`Json`, `Form`) must be last.
- No blocking operations in async context. Use `tokio::task::spawn_blocking()` for CPU-intensive work (hashing, compression, image processing).
- Dependency injection via traits. Define service traits, implement on concrete types, pass as trait objects or generics through AppState.
- Feature flags in `Cargo.toml` for optional functionality (e.g., `features = ["redis-cache", "email"]`).

## Coding Conventions

- Rust 2024 edition idioms. Use `let-else` for pattern matching with early return. Use `if let` chains.
- `cargo fmt` and `cargo clippy -- -D warnings` must pass. Zero warnings policy.
- Module structure: one file per module. `mod.rs` for module declarations and re-exports.
- Struct naming: PascalCase. Functions and methods: snake_case. Constants: SCREAMING_SNAKE_CASE. Type parameters: single uppercase letter (`T`, `E`).
- Derive macros order: `Debug, Clone, Serialize, Deserialize` for DTOs. `Debug, Clone, sqlx::FromRow` for models.
- Serde attributes: `#[serde(rename_all = "camelCase")]` on response DTOs. `#[serde(rename_all = "snake_case")]` on database models.
- Lifetimes: avoid explicit lifetimes where possible. Use owned types (String, Vec) in DTOs and models. Borrow in function parameters.
- Error types: each module has its own error enum. Convert between error types with `From` implementations or `map_err`.
- Handler return types: `Result<Json<T>, AppError>` for JSON responses. `Result<StatusCode, AppError>` for empty responses.
- Validation: use `validator` crate derive macros on request DTOs. Custom extractor `ValidatedJson<T>` validates on extraction.
- Tracing: use `#[tracing::instrument]` on handlers and service methods. Structured fields with `tracing::info!(user_id = %id, "creating user")`.
- Imports: group by crate. Standard library, then external crates, then internal modules. Use `use crate::` for internal imports.
- Dead code: no `#[allow(dead_code)]` without a comment explaining why. Remove unused code.
- Clippy: fix all warnings. `#[allow(clippy::lint_name)]` only with justification comment.

## Error Handling

- `AppError` enum with `thiserror` derive:
  - `NotFound(String)` → 404
  - `Validation(String)` → 422
  - `Unauthorized(String)` → 401
  - `Forbidden(String)` → 403
  - `Conflict(String)` → 409
  - `Internal(#[from] anyhow::Error)` → 500
- `impl IntoResponse for AppError`: converts error to JSON response with status code.
- `From<sqlx::Error>` implementation: maps database errors to appropriate `AppError` variants. Unique violation → `Conflict`. Not found → `NotFound`.
- Service methods return `Result<T, AppError>`. Repository methods return `Result<T, sqlx::Error>`. Handler methods return `Result<impl IntoResponse, AppError>`.
- Tracing on errors: log error details at service layer with `tracing::error!`. Handler layer converts to user-safe message.
- No error details leaked to client in production. Internal errors return generic "Internal server error" message.
- Validation errors: return field-level error messages as JSON object.

## Testing Conventions

- Unit tests in `#[cfg(test)] mod tests` block at bottom of each file.
- Integration tests in `tests/` directory. Each test spins up the full app with test database.
- Test database: separate PostgreSQL database. Migrations run before tests. Truncate tables between tests.
- Test helpers in `tests/common/mod.rs`: `spawn_app()` returns test server URL and database pool.
- HTTP tests: use `reqwest::Client` against test server. Assert status codes and response bodies.
- Database tests: use `sqlx::PgPool` directly. Wrap in transactions that roll back after each test.
- Mock: `mockall` crate for mocking traits in unit tests. Define trait-based boundaries for mockable interfaces.
- Test naming: `test_create_user_with_valid_data_returns_201`, `test_create_user_with_duplicate_email_returns_409`.
- Property-based tests: `proptest` for testing with random inputs on validation and parsing logic.
- Assert macros: `assert_eq!`, `assert!(result.is_ok())`, `assert!(matches!(err, AppError::NotFound(_)))`.
- Coverage: `cargo tarpaulin` for coverage reports. Target: 80% for services, 75% for repositories.

## Database & SQLx Patterns

- Compile-time query verification: use `sqlx::query!("SELECT ...")` macro. Requires `DATABASE_URL` at compile time or `sqlx-data.json` for offline mode.
- Offline mode: run `cargo sqlx prepare` to generate `sqlx-data.json`. Commit this file. CI builds without database access.
- Migrations: plain SQL files in `migrations/` directory. Numbered with timestamps.
- Connection pool: `PgPoolOptions::new().max_connections(20).connect(&database_url).await`.
- Transactions: `let mut tx = pool.begin().await?; ... tx.commit().await?;`. Pass `&mut tx` to repository methods.
- Query returning: `sqlx::query_as!(User, "INSERT INTO users ... RETURNING *", ...)`.
- Optional results: `sqlx::query_as!(User, "SELECT ... WHERE id = $1", id).fetch_optional(&pool).await?`.
- Pagination: `LIMIT $1 OFFSET $2` with parameters. Return total count via separate `COUNT(*)` query or window function.
- JSON columns: use `sqlx::types::Json<T>` for typed JSON columns. `serde_json::Value` for dynamic JSON.
- UUID columns: `sqlx::types::Uuid`. Generate with `uuid::Uuid::new_v4()`.
- Timestamps: `sqlx::types::chrono::NaiveDateTime` or `time::OffsetDateTime`. Use `chrono` for consistency.

## Security

- JWT: RS256 or HS256 via `jsonwebtoken`. Validate in auth middleware. Extract claims into `AuthUser` extractor.
- Password hashing: `argon2` crate. Hash on registration, verify on login. Never use bcrypt (argon2 is current standard).
- Input validation: `validator` derive macros. Validate email, length, range. Custom validators for business rules.
- CORS: `tower-http::cors::CorsLayer`. Specify allowed origins, methods, headers. No wildcard in production.
- Rate limiting: `tower-governor` middleware. Per-IP rate limiting on auth endpoints.
- SQL injection: prevented by SQLx parameterized queries. Never use `format!` to build SQL strings.
- Environment secrets: `dotenvy` loads `.env`. Never commit `.env`. Use secrets manager in production.

## What Claude Should Never Do

- Never use `.unwrap()` or `.expect()` in non-test code. Use `?` for error propagation or explicit match/if-let.
- Never call blocking functions (std::fs, reqwest::blocking, std::thread::sleep) in async context. Use tokio async equivalents or `spawn_blocking`.
- Never use `String` formatting to build SQL queries. Use SQLx parameterized queries (`$1`, `$2`).
- Never clone large structs unnecessarily. Use references or `Arc` for shared ownership.
- Never put body-consuming extractors (Json, Form) before non-consuming extractors (State, Path, Query) in handler signatures.
- Never use `#[allow(unused)]` to hide dead code. Remove unused code or explain why it exists.
- Never skip `cargo clippy` warnings. All Clippy suggestions must be addressed or explicitly allowed with justification.
- Never use `Box<dyn Error>` when `thiserror` or `anyhow` provides better ergonomics and type safety.
- Never use `unsafe` blocks without security review comments and detailed justification.
- Never hardcode connection strings, API keys, or secrets. Load from environment variables via config module.

## Project-Specific Context

- [YOUR PROJECT NAME] — update with your project details
- Database: PostgreSQL via [RDS / Cloud SQL / Supabase / Docker]
- Cache: Redis via [ElastiCache / Docker] (optional)
- Deployment: Docker → [Kubernetes / ECS / Cloud Run / Fly.io]
- Monitoring: [Datadog / Jaeger] for tracing, [Sentry] for errors
- CI/CD: GitHub Actions → cargo build/test/clippy → Docker → deploy
```
{% endraw %}

## How to Adapt This For Your Project

Start with the **Project Stack** section and update crate versions from your `Cargo.toml`. If you use Diesel instead of SQLx, replace the query patterns — Diesel uses a Rust-based query DSL while SQLx uses raw SQL with compile-time checks. If you use `actix-web` instead of Axum, replace the handler and middleware patterns but keep the three-layer architecture and error handling approach. The `thiserror` + `anyhow` combination works across any Rust web framework. Remove the SQLx offline mode section if your CI has database access.

## Common CLAUDE.md Mistakes in Rust + Axum Projects

1. **Not specifying extractor ordering.** Axum requires body-consuming extractors (`Json<T>`) to be the last parameter. Claude places them before `State<AppState>` or `Path<i64>`, causing compile errors about missing implementations.

2. **Allowing `.unwrap()` in application code.** Claude uses `.unwrap()` liberally for quick prototyping. In production Rust, every `.unwrap()` is a potential panic that crashes the service. Mandate `?` for error propagation.

3. **Missing `From` implementations for error types.** Without explicit error conversion rules, Claude uses `.map_err(|e| AppError::Internal(e.into()))` everywhere instead of implementing `From<sqlx::Error> for AppError` once.

4. **Blocking in async context.** Claude calls synchronous functions like `std::fs::read_to_string` or CPU-heavy computations directly in async handlers, which blocks the Tokio runtime. Specify `spawn_blocking` for these cases.

5. **Using `String` everywhere instead of references.** Claude creates function signatures with `fn process(name: String)` instead of `fn process(name: &str)`, causing unnecessary allocations. Specify ownership conventions.

## What Claude Code Does With This

With this CLAUDE.md loaded, Claude Code generates Axum handlers with correct extractor ordering and proper `Result<impl IntoResponse, AppError>` return types. Error handling uses the `thiserror` enum with `From` implementations for automatic conversion. SQLx queries use the compile-time checked `query!` and `query_as!` macros. Async operations avoid blocking calls. Tower middleware layers are composed in the correct order. Tests use the integration test pattern with a real database.

## The Full 16-Template Pack

This is one of 16 production CLAUDE.md templates available in the Lifetime pack. Includes templates for Go + Gin, Next.js + TypeScript, Django + PostgreSQL, Rails + Turbo, and 11 more stacks. Each template is 200-400 lines of production-tested configuration. Get all 16 at [claudecodeguides.com/generator/](https://claudecodeguides.com/generator/).
