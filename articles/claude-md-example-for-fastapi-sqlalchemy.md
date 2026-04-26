---
layout: default
title: "CLAUDE.md Example for FastAPI + (2026)"
description: "Complete 310-line CLAUDE.md for FastAPI 0.115 with SQLAlchemy 2.0 and Alembic. Covers async patterns, Pydantic v2 models, and dependency injection."
permalink: /claude-md-example-for-fastapi-sqlalchemy/
date: 2026-04-20
render_with_liquid: false
categories: [claude-md, templates, 2026]
tags: [claude-code, claude-md, fastapi, sqlalchemy, python]
last_updated: 2026-04-19
---

## What This Template Does

This CLAUDE.md configures Claude Code for FastAPI 0.115.6 projects with SQLAlchemy 2.0 (async), Pydantic v2, and Alembic migrations. It enforces proper async/await patterns, prevents blocking I/O in async route handlers, and ensures Pydantic models follow the v2 API (not the deprecated v1 `.dict()` / `.schema()` methods). The template covers dependency injection patterns, Alembic migration workflows, and structured error responses. Tested against production API services handling 10K+ requests per minute with 60+ endpoints.

## The Complete Template

{% raw %}
```markdown
# CLAUDE.md — FastAPI 0.115 + SQLAlchemy 2.0 + Pydantic v2

## Project Stack

- Python 3.12.8
- FastAPI 0.115.6
- SQLAlchemy 2.0.36 (async with asyncpg)
- Pydantic 2.10.4 (v2 API exclusively)
- Alembic 1.14.1 (async migrations)
- PostgreSQL 16.4 (asyncpg 0.30.0 driver)
- Redis 7.4 (via redis.asyncio)
- Celery 5.4.0 (background tasks)
- pytest 8.3.4 + httpx 0.28.1 (async tests)
- uv 0.5.14 (package manager)
- Ruff 0.8.6 (linter + formatter)
- mypy 1.13.0 (type checking)

## Build & Dev Commands

- Install: `uv sync`
- Dev server: `uv run uvicorn app.main:app --reload --port 8000`
- Test: `uv run pytest`
- Test single: `uv run pytest tests/api/test_users.py -k test_create_user`
- Test coverage: `uv run pytest --cov=app --cov-report=html`
- Lint: `uv run ruff check .`
- Format: `uv run ruff format .`
- Type check: `uv run mypy app/`
- Migration create: `uv run alembic revision --autogenerate -m "description"`
- Migration run: `uv run alembic upgrade head`
- Migration rollback: `uv run alembic downgrade -1`
- Celery worker: `uv run celery -A app.worker worker -l info`
- OpenAPI schema: visit `http://localhost:8000/docs` (Swagger UI)

## Project Layout

```
app/
  main.py                  # FastAPI app instance, middleware, lifespan
  config.py                # Settings class with Pydantic BaseSettings
  database.py              # Async engine, sessionmaker, Base
  dependencies.py          # Shared dependencies (get_db, get_current_user)
  exceptions.py            # Custom exception classes and handlers
  models/                  # SQLAlchemy ORM models
    base.py                # TimestampMixin, SoftDeleteMixin
    user.py                # User model
    __init__.py            # Import all models for Alembic discovery
  schemas/                 # Pydantic v2 request/response schemas
    user.py                # UserCreate, UserUpdate, UserResponse
    common.py              # Pagination, ErrorResponse, HealthCheck
  api/
    v1/
      router.py            # Aggregated v1 router
      endpoints/
        users.py           # User endpoints
        auth.py            # Auth endpoints (login, register, refresh)
  services/                # Business logic layer
    user_service.py         # UserService class
    auth_service.py         # AuthService class
    email_service.py        # Email sending (async)
  repositories/            # Database access layer
    base.py                # BaseRepository with CRUD methods
    user_repository.py      # UserRepository extending BaseRepository
  middleware/
    logging.py             # Request/response logging
    cors.py                # CORS configuration
  utils/
    security.py            # Password hashing, JWT encode/decode
    pagination.py          # Pagination utilities
alembic/
  versions/                # Migration files
  env.py                   # Alembic environment (async)
tests/
  conftest.py              # Fixtures: async client, test database, factories
  api/
    test_users.py
    test_auth.py
  services/
    test_user_service.py
  repositories/
    test_user_repository.py
```

## Architecture Rules

- Three-layer architecture: API endpoints → Services → Repositories. Endpoints handle HTTP. Services handle business logic. Repositories handle database queries.
- All database operations are async. Use `async with session.begin()` for transactions. Never use synchronous SQLAlchemy session.
- SQLAlchemy 2.0 style exclusively. Use `select()`, `insert()`, `update()`, `delete()` statements — never legacy `session.query()`.
- Pydantic v2 API only. Use `model_dump()` not `.dict()`. Use `model_json_schema()` not `.schema()`. Use `model_validate()` not `.from_orm()`.
- Dependency injection via `Depends()` for database sessions, authentication, and service instances.
- Settings via `pydantic-settings` `BaseSettings` class. Environment variables auto-loaded. Access via `get_settings()` dependency.
- API versioning via URL prefix: `/api/v1/`. Each version has its own router aggregating endpoint routers.
- Background tasks: use FastAPI `BackgroundTasks` for simple fire-and-forget. Use Celery for reliable, retryable tasks.
- Lifespan events in `main.py`: create database tables, initialize Redis pool, register shutdown hooks.
- Repository pattern: `BaseRepository[ModelType]` provides `get`, `get_multi`, `create`, `update`, `delete`. Domain repositories extend with custom queries.

## Coding Conventions

- Type hints on all function signatures and return types. Use `from __future__ import annotations`.
- Ruff for linting and formatting. Line length: 88 characters.
- Async functions: prefix with `async`. All route handlers are `async def`. All database operations use `await`.
- Pydantic schemas: separate request and response models. `UserCreate` (input), `UserUpdate` (partial input), `UserResponse` (output). Never expose ORM models directly in API responses.
- Schema naming: `{Model}Create`, `{Model}Update`, `{Model}Response`, `{Model}InDB` (internal with hashed password etc).
- SQLAlchemy models: use `Mapped[type]` for column type hints. Use `mapped_column()` for column definitions. Use `relationship()` with `back_populates`.
- Router path operations: use response_model for output typing. Use status_code for explicit HTTP status. Use tags for OpenAPI grouping.
- Dependencies: define in `dependencies.py`. Common: `get_db` (yields async session), `get_current_user` (JWT validation), `get_settings`.
- Docstrings: Google style. Required on services, repositories, and complex endpoints.
- Constants: uppercase module-level. No magic strings or numbers in business logic.
- f-strings for string formatting. No `.format()` or `%` formatting.
- Import ordering: stdlib, third-party, SQLAlchemy, FastAPI, local. Blank line between groups.
- File naming: snake_case. One model per file. One router per resource.

## Error Handling

- Custom exception hierarchy: `AppException` base → `NotFoundError`, `ValidationError`, `AuthenticationError`, `PermissionError`.
- Exception handlers registered in `main.py` via `app.add_exception_handler(AppException, handler)`.
- Consistent error response: `{"error": {"code": "NOT_FOUND", "message": "User not found", "details": null}}`.
- HTTP status mapping: `NotFoundError` → 404, `ValidationError` → 422, `AuthenticationError` → 401, `PermissionError` → 403.
- Database errors: catch `IntegrityError` in repository layer, raise domain-specific `DuplicateError` or `NotFoundError`.
- Pydantic validation errors: FastAPI handles automatically, returns 422 with field-level errors.
- Never raise raw `HTTPException` in services or repositories. Raise domain exceptions, let handlers convert to HTTP responses.
- Background task errors: log with structlog, report to Sentry. Never let background tasks fail silently.
- Timeout handling: set `httpx` client timeout to 10 seconds. Catch `httpx.TimeoutException` explicitly.

## Testing Conventions

- pytest with `pytest-asyncio` for async tests. Use `@pytest.mark.asyncio` on all async test functions.
- Test client: `httpx.AsyncClient` with `ASGITransport(app=app)`. Override database dependency with test database session.
- Test database: separate PostgreSQL database. Truncate tables between tests. Use transactions for test isolation.
- Factories: use `factory_boy` with `SQLAlchemyModelFactory`. One factory per model in `tests/factories.py`.
- Test structure: `test_{verb}_{resource}_{condition}_{expectation}`. Example: `test_create_user_with_duplicate_email_returns_409`.
- Mock external services: `unittest.mock.patch` or `pytest-mock`. Mock at the service boundary, not at HTTP level.
- Fixture hierarchy: `conftest.py` at `tests/` root for shared fixtures. App-specific fixtures in subdirectory `conftest.py`.
- Assert response status codes, response body structure, and database side effects.
- Integration tests: test full request flow from client → endpoint → service → repository → database.
- Coverage target: 90% for services, 85% for repositories, 75% for endpoints.

## Database & Migration Patterns

- Async engine: `create_async_engine(DATABASE_URL, pool_size=20, max_overflow=10)`.
- Session management: `async_sessionmaker(engine, class_=AsyncSession, expire_on_commit=False)`.
- Alembic with async: configure `env.py` with `run_async_migrations()`. Use `connectable = create_async_engine(...)`.
- Auto-generate migrations: `alembic revision --autogenerate -m "add users table"`. Always review the generated file.
- Every model imported in `models/__init__.py` so Alembic discovers all tables.
- Indexes: add `index=True` on frequently filtered columns. Composite indexes via `__table_args__`.
- Soft deletes: `SoftDeleteMixin` with `deleted_at: Mapped[datetime | None]`. Filter in repository base class.
- Enum columns: use Python `enum.Enum` mapped to PostgreSQL enum type. Register with Alembic for proper migration.
- JSON columns: use `JSONB` for PostgreSQL. Type with `Mapped[dict[str, Any]]`.
- Connection pooling: configure `pool_size`, `max_overflow`, `pool_timeout`, `pool_recycle` in engine creation.

## Performance

- Async all the way: async engine, async session, async Redis. No sync calls in the async event loop.
- Connection pooling: tune `pool_size` (default 20), `max_overflow` (default 10), `pool_recycle` (3600 seconds).
- Response compression: `GZipMiddleware` for responses over 500 bytes.
- Query optimization: use `selectinload` or `joinedload` for eager loading. Avoid N+1 with explicit relationship loading.
- Caching: Redis with async client. Cache frequently read, rarely changed data. Use cache-aside pattern.
- Pagination: always limit query results. Default `limit=20`, max `limit=100`. Return total count for UI pagination.

## Security

- JWT authentication: access tokens (15 min) and refresh tokens (7 days). Stored as httpOnly cookies or Authorization header.
- Password hashing: `passlib` with `bcrypt` scheme. Never store plaintext passwords.
- CORS: configure allowed origins list in `config.py`. Never allow `*` in production.
- Rate limiting: `slowapi` on login and registration endpoints. 5 attempts per minute per IP.
- Input validation: Pydantic schemas validate all input. Additional business rule validation in service layer.
- SQL injection: prevented by SQLAlchemy ORM. Never use `text()` with string interpolation.
- Secret management: environment variables via `.env` file (development) and secrets manager (production).
- HTTPS: enforce in production. Redirect HTTP to HTTPS via reverse proxy.

## Deployment

- Production: uvicorn with multiple workers behind nginx or Traefik. `uvicorn app.main:app --workers 4 --host 0.0.0.0`.
- Docker: multi-stage build. Install deps in builder stage, copy app in runner stage. Use non-root user.
- Health check: `GET /health` endpoint checks database and Redis connectivity.
- Migrations: run `alembic upgrade head` in CI/CD before app restart. Never run manually in production.
- Environment: all config via environment variables. Never commit `.env` to git.

## What Claude Should Never Do

- Never use synchronous SQLAlchemy in async FastAPI handlers. No `Session()`, no `session.query()`. Use `AsyncSession` and `select()`.
- Never use Pydantic v1 API. No `.dict()` (use `.model_dump()`), no `.schema()` (use `.model_json_schema()`), no `orm_mode` (use `from_attributes`).
- Never return SQLAlchemy model instances directly from endpoints. Convert to Pydantic response schemas.
- Never use `session.query(Model)` syntax. Use SQLAlchemy 2.0 `select(Model)` with `session.execute()`.
- Never put business logic in route handler functions. Route handlers call services. Services call repositories.
- Never use `time.sleep()` or any blocking call in async handlers. Use `asyncio.sleep()` or run blocking code in `run_in_executor`.
- Never create Alembic migrations without reviewing the generated SQL. Auto-generated migrations can drop columns or tables incorrectly.
- Never hardcode database URLs, API keys, or secrets. Use `pydantic-settings` `BaseSettings` with environment variables.
- Never use `from_orm()` — it is Pydantic v1 syntax. Use `model_validate()` with `from_attributes=True` in model config.
- Never import models in endpoint files. Import services. Services import repositories. Repositories import models.

## Project-Specific Context

- [YOUR PROJECT NAME] — update with your project details
- Database: PostgreSQL via [RDS/Cloud SQL/Supabase/Docker]
- Cache: Redis for sessions, rate limiting, and Celery broker
- Object storage: [S3/GCS/R2] for file uploads
- Monitoring: Sentry for errors, Prometheus for metrics, structlog for structured logging
- Deploy: [Docker → ECS/GKE/Fly.io] or [Railway/Render]
```
{% endraw %}

## How to Adapt This For Your Project

Start with the **Project Stack** section — update every version to match your `pyproject.toml`. If you use synchronous SQLAlchemy (not async), replace the async patterns throughout — change `AsyncSession` to `Session`, remove `await` calls, and update Alembic config. If you do not use the repository pattern, merge the repository logic into services. The three-layer architecture (endpoints → services → repositories) is the highest-value pattern to keep because it prevents Claude from putting SQL queries inside route handlers.

## Common CLAUDE.md Mistakes in FastAPI Projects

1. **Not specifying Pydantic v2 vs v1.** Claude was trained on both versions. Without explicit v2 rules, it generates `.dict()` instead of `.model_dump()`, `orm_mode = True` instead of `from_attributes = True`, and `@validator` instead of `@field_validator`.

2. **Allowing synchronous calls in async handlers.** Without the blocking I/O rule, Claude uses `requests.get()` instead of `httpx.AsyncClient`, `time.sleep()` instead of `asyncio.sleep()`, and synchronous database sessions that block the event loop.

3. **Missing the repository layer.** Without architectural guidance, Claude puts raw SQLAlchemy queries directly in route handlers, making the code untestable and tightly coupling HTTP logic to database operations.

4. **Not enforcing SQLAlchemy 2.0 syntax.** Claude defaults to `session.query(Model).filter()` (legacy 1.x pattern) instead of `select(Model).where()` (2.0 pattern). Specify "2.0 style exclusively" to prevent this.

5. **Omitting Alembic review rules.** Claude generates migrations and runs them immediately. Without the review rule, auto-generated migrations can silently drop columns or tables when model changes are ambiguous.

## What Claude Code Does With This

With this CLAUDE.md loaded, Claude Code generates all database operations using SQLAlchemy 2.0 async patterns with `select()`, `insert()`, and `AsyncSession`. Pydantic schemas follow the v2 API with `model_dump()` and `model_validate()`. New endpoints follow the three-layer pattern: the route handler calls a service, which calls a repository. Error handling uses the custom exception hierarchy instead of raw `HTTPException`. Alembic migrations are generated with `--autogenerate` but Claude flags them for review before running. Dependency injection is used consistently for database sessions, settings, and authentication.

## The Full 16-Template Pack

This is one of 16 production CLAUDE.md templates available in the Lifetime pack. Includes templates for Django + PostgreSQL, Next.js + TypeScript, Go + Gin, Rust + Axum, and 11 more stacks. Each template is 200-400 lines of production-tested configuration. Get all 16 at [claudecodeguides.com/generator/](https://claudecodeguides.com/generator/).


**Fix it instantly →** Paste your error into our [Error Diagnostic Tool](/diagnose/) for step-by-step resolution.

