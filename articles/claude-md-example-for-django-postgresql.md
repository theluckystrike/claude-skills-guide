---
title: "CLAUDE.md Example for Django + PostgreSQL — Production Template (2026)"
description: "Complete 320-line CLAUDE.md for Django 5.1 with DRF, PostgreSQL, and Celery. Enforces migration safety, ViewSet patterns, and settings split. Tested on Django 5.1.4."
permalink: /claude-md-example-for-django-postgresql/
render_with_liquid: false
categories: [claude-md, templates, 2026]
tags: [claude-code, claude-md, django, postgresql, python]
last_updated: 2026-04-19
---

## What This Template Does

This CLAUDE.md configures Claude Code for Django 5.1.4 projects with Django REST Framework, PostgreSQL 16, and Celery for background tasks. It enforces proper model manager usage, prevents migration footguns (like adding non-nullable fields without defaults), and ensures ViewSets follow consistent serializer patterns. The template covers the settings split pattern (base/dev/prod), CSRF handling for API views, and pytest-django testing conventions. Tested against production codebases with 80+ models and 200+ API endpoints.

## The Complete Template

{% raw %}
```markdown
# CLAUDE.md — Django 5.1 + PostgreSQL + DRF

## Project Stack

- Python 3.12.8
- Django 5.1.4
- Django REST Framework 3.15.2
- PostgreSQL 16.4 (psycopg 3.2.4, not psycopg2)
- Celery 5.4.0 + Redis 7.4 (broker and result backend)
- pytest 8.3.4 + pytest-django 4.9.0
- uv 0.5.14 (package manager — not pip, not poetry)
- Ruff 0.8.6 (linter and formatter — not Black, not flake8)
- mypy 1.13.0 (type checking)
- Docker Compose for local development
- Gunicorn 23.0.0 + uvicorn workers for production

## Build & Dev Commands

- Install deps: `uv sync`
- Dev server: `uv run python manage.py runserver`
- Migrations: `uv run python manage.py makemigrations`
- Migrate: `uv run python manage.py migrate`
- Shell: `uv run python manage.py shell_plus` (django-extensions)
- Test: `uv run pytest`
- Test single: `uv run pytest apps/users/tests/test_views.py::TestUserViewSet::test_create`
- Test coverage: `uv run pytest --cov=apps --cov-report=html`
- Lint: `uv run ruff check .`
- Format: `uv run ruff format .`
- Type check: `uv run mypy apps/`
- Celery worker: `uv run celery -A config worker -l info`
- Celery beat: `uv run celery -A config beat -l info`
- Create superuser: `uv run python manage.py createsuperuser`
- Collect static: `uv run python manage.py collectstatic --noinput`

## Project Layout

```
config/
  settings/
    base.py               # Shared settings (INSTALLED_APPS, MIDDLEWARE, etc.)
    development.py         # Debug=True, local database, CORS allow all
    production.py          # Debug=False, Sentry, HTTPS settings, caching
    test.py                # Fast passwords, in-memory cache, sync Celery
  urls.py                  # Root URL configuration
  celery.py                # Celery app configuration
  wsgi.py                  # WSGI entrypoint
  asgi.py                  # ASGI entrypoint
apps/
  users/                   # User management app
    models.py              # Custom User model (AbstractUser)
    serializers.py         # DRF serializers
    views.py               # ViewSets and APIViews
    urls.py                # App-level URL routing
    admin.py               # Admin customization
    managers.py            # Custom model managers
    tasks.py               # Celery tasks
    signals.py             # Post-save, pre-delete signals
    filters.py             # django-filter FilterSets
    permissions.py         # Custom DRF permissions
    tests/
      test_models.py
      test_views.py
      test_serializers.py
      test_tasks.py
      factories.py         # Factory Boy factories
      conftest.py          # App-level fixtures
  core/                    # Shared app: base models, mixins, utilities
    models.py              # TimestampedModel, SoftDeleteModel base classes
    mixins.py              # ViewSet and serializer mixins
    pagination.py          # Custom pagination classes
    exceptions.py          # Custom exception handler
    middleware.py          # Request logging, tenant context
    utils.py               # Pure utility functions
templates/                 # Django templates (admin customization, emails)
static/                    # Static files (CSS, JS for admin)
media/                     # User-uploaded files (gitignored)
requirements/              # If not using uv: base.txt, dev.txt, prod.txt
```

## Architecture Rules

- Settings split: `config/settings/base.py` for shared config. `development.py`, `production.py`, `test.py` import from base. Use `DJANGO_SETTINGS_MODULE=config.settings.development` in env.
- Custom User model: always `apps.users.models.User` extending `AbstractUser`. Set `AUTH_USER_MODEL = "users.User"` in base settings. Never reference `django.contrib.auth.models.User` directly.
- All models inherit from `core.models.TimestampedModel` which adds `created_at` and `updated_at` fields with `auto_now_add` and `auto_now`.
- One Django app per domain concept. Apps live in `apps/` directory. Each app is registered as `apps.appname` in `INSTALLED_APPS`.
- Fat models, thin views. Business logic lives in model methods, managers, or service functions — never in views or serializers.
- Django signals only for cross-app communication. Never use signals within the same app — call the method directly.
- URL namespacing: every app registers its own `urls.py` with `app_name`. Root `urls.py` includes with namespace: `path("api/users/", include("apps.users.urls", namespace="users"))`.
- API versioning via URL prefix: `/api/v1/`. Configure in DRF settings with `DEFAULT_VERSIONING_CLASS`.

## Coding Conventions

- Type hints on all function signatures. Use `from __future__ import annotations` at the top of every file.
- Ruff for linting and formatting (replaces Black + isort + flake8). Line length: 88 characters.
- Imports: sorted by Ruff. Standard library, third-party, Django, local apps. One blank line between groups.
- Model field ordering: primary key, foreign keys, required fields, optional fields, timestamps, Meta class, __str__, properties, methods.
- QuerySet methods return QuerySets. Manager methods that return single objects raise explicit exceptions, not silent None.
- Custom managers on models: `objects = CustomManager()`. Default manager must always be first.
- Model `__str__` returns a human-readable representation. Always define it.
- Model `Meta` class: always set `ordering`, `verbose_name`, `verbose_name_plural`, and `db_table` explicitly.
- Serializer fields: explicit `fields` list in Meta — never `fields = "__all__"`. Sensitive fields explicitly excluded.
- ViewSets: use `ModelViewSet` for full CRUD. Override `get_queryset()` to filter by user/tenant. Override `get_serializer_class()` for different serializers per action.
- Permissions: custom permission classes in `permissions.py`. Combine with `permission_classes = [IsAuthenticated, IsOwnerOrAdmin]`.
- Filtering: django-filter `FilterSet` classes. Attach with `filterset_class` on ViewSet. Searchable fields via `SearchFilter`.
- Celery tasks: all tasks in `tasks.py` per app. Use `@shared_task(bind=True, max_retries=3)`. Idempotent tasks only.
- String formatting: f-strings everywhere. No `%` formatting. No `.format()`.
- Constants: uppercase in module-level or in `constants.py`. No magic numbers in business logic.
- Docstrings: Google style. Required on all public functions, classes, and methods.

## Error Handling

- DRF custom exception handler in `core/exceptions.py`. Register in settings: `EXCEPTION_HANDLER = "apps.core.exceptions.custom_exception_handler"`.
- API errors return consistent shape: `{"error": {"code": "VALIDATION_ERROR", "message": "...", "details": {...}}}`.
- Model validation in `clean()` method. Call `full_clean()` before `save()` in business logic. DRF serializers call `validate()`.
- Database integrity errors (unique constraint, foreign key): catch `IntegrityError` and convert to DRF `ValidationError`.
- 404 responses: use `get_object_or_404()` in views. DRF handles conversion to JSON response.
- Permission denied: raise `PermissionDenied` from `rest_framework.exceptions`. Never return raw 403 responses.
- Celery task failures: use `on_failure` handler to log to Sentry. Implement exponential backoff: `self.retry(countdown=2 ** self.request.retries)`.
- Never catch bare `except Exception`. Catch specific exceptions. Log unexpected errors with full traceback.
- Form/serializer validation errors: return field-level errors as `{"field_name": ["Error message"]}`.
- Unhandled exceptions in production: caught by Sentry middleware. Return generic 500 response.

## Testing Conventions

- pytest-django with `@pytest.mark.django_db` decorator for database tests. Default `conftest.py` sets `DJANGO_SETTINGS_MODULE=config.settings.test`.
- Factory Boy for model instances. One `factories.py` per app in `tests/` directory. Use `factory.SubFactory` for related models.
- API tests: use DRF `APIClient`. Authenticate with `client.force_authenticate(user=user)`. Test response status, response data shape, and database state.
- Test file naming: `test_models.py`, `test_views.py`, `test_serializers.py`, `test_tasks.py`, `test_services.py`.
- Test method naming: `test_verb_condition_expectation`. Example: `test_create_user_with_valid_data_returns_201`.
- Fixtures: prefer factories over fixtures. Use `conftest.py` for shared fixtures (authenticated client, admin user).
- Mock external services: `@patch("apps.payments.services.stripe.Customer.create")`. Mock at the call site, not the definition.
- Celery task tests: use `CELERY_ALWAYS_EAGER=True` in test settings. Test task logic as a regular function call.
- Database setup: use `pytest.mark.django_db(transaction=True)` only when testing transaction behavior. Default is faster wrapped transaction.
- Performance: run tests in parallel with `pytest-xdist`: `pytest -n auto`.
- Coverage target: 90% for models and services, 80% for views, 70% for serializers.

## Database & Migration Patterns

- PostgreSQL-specific fields: `ArrayField`, `JSONField`, `CITextField`. Use them when appropriate instead of workarounds.
- Indexes: add `db_index=True` on fields used in `filter()`, `exclude()`, and `order_by()`. Add composite indexes in `Meta.indexes`.
- Migrations: always review generated migration files. Check for `RunPython` operations, data migrations, and irreversible operations.
- Adding fields to existing tables: always provide `default` value or `null=True`. Never add a non-nullable field without a default to a table with existing data.
- Renaming fields: use `RenameField` operation, not remove + add (which loses data).
- Data migrations: separate file from schema migrations. Use `RunPython` with both forward and reverse functions.
- Migration squashing: squash old migrations periodically with `squashmigrations`. Keep the last 20 migrations unsquashed.
- Database transactions: use `transaction.atomic()` for multi-model operations. Use `select_for_update()` for concurrent access protection.
- Raw SQL: avoid when possible. When necessary, use `connection.cursor()` with parameterized queries — never string interpolation.
- N+1 queries: use `select_related()` for foreign keys, `prefetch_related()` for many-to-many and reverse foreign keys. Install django-debug-toolbar for detection.

## Security

- CSRF: enabled for session-based views. DRF API views use token authentication (exempt from CSRF).
- CORS: `django-cors-headers`. Whitelist specific origins in production. Never `CORS_ALLOW_ALL_ORIGINS = True` in production.
- Authentication: JWT via `djangorestframework-simplejwt`. Access token: 15 min. Refresh token: 7 days. Rotate refresh tokens.
- Password validation: use all four default validators plus minimum length of 10.
- Sensitive data: never log passwords, tokens, or PII. Use Django `mark_safe` only for admin display, never for user input.
- SQL injection: always use ORM or parameterized raw queries. Never use f-strings in SQL.
- File uploads: validate file type and size in serializer. Store in cloud storage (S3), not local filesystem.
- Rate limiting: django-ratelimit on login, registration, and password reset views.

## Performance

- QuerySet evaluation: use `.only()` and `.defer()` to limit fields fetched. Use `.values()` or `.values_list()` for lightweight queries.
- Caching: use Django cache framework with Redis backend. Cache expensive querysets with `cache.get_or_set()`.
- Pagination: DRF `LimitOffsetPagination` for API endpoints. `Paginator` for template views. Default page size: 20.
- Database connection management: configure `CONN_MAX_AGE = 600` in production for persistent connections.
- Async views: use `async def` for I/O-bound views in Django 5.x. Wrap sync ORM calls with `sync_to_async`.
- Template caching: `{% cache 3600 fragment_name %}` for expensive template fragments.
- Static file serving: WhiteNoise middleware for simple deployments. CDN for high-traffic production.

## Deployment

- Production: Gunicorn with uvicorn workers behind nginx. `gunicorn config.asgi:application -k uvicorn.workers.UvicornWorker`.
- Static files: `collectstatic` → S3/CloudFront or whitenoise for simple setups.
- Environment variables: `django-environ` reads from `.env` file. Never hardcode secrets.
- Database: managed PostgreSQL (RDS, Cloud SQL, Supabase). Connection pooling via PgBouncer.
- Migrations: run in CI/CD before deployment. Never run `migrate` manually in production.
- Health check: `/api/health/` endpoint returns `{"status": "ok", "db": "ok", "cache": "ok"}`.
- Docker: multi-stage build. First stage installs deps, second stage copies app. Use non-root user.
- CI/CD: run `ruff check`, `mypy`, and `pytest` in pipeline. Block deploy on failures.

## What Claude Should Never Do

- Never use `fields = "__all__"` in serializer Meta. Always list fields explicitly. Sensitive fields must be explicitly excluded.
- Never add a non-nullable field to an existing model without a `default` value. This will crash `migrate` on tables with existing rows.
- Never reference `django.contrib.auth.models.User` directly. Always use `get_user_model()` or `settings.AUTH_USER_MODEL`.
- Never put business logic in views or serializers. Views handle HTTP concerns. Serializers handle validation. Business logic lives in model methods, managers, or services.
- Never use `print()` for logging. Use `import logging; logger = logging.getLogger(__name__)`.
- Never use `.filter().first()` when you expect exactly one result. Use `.get()` and handle `DoesNotExist`.
- Never use `CORS_ALLOW_ALL_ORIGINS = True` in production settings. Whitelist specific origins.
- Never use `manage.py migrate` with `--fake` unless you understand exactly which migration state you are correcting.
- Never create circular imports between apps. If app A needs app B's model, use string references: `ForeignKey("appb.ModelName")`.
- Never store uploaded files in the project directory. Use cloud storage with signed URLs.
- Never write raw SQL with string interpolation. Use parameterized queries to prevent SQL injection.

## Project-Specific Context

- [YOUR PROJECT NAME] — update with your project details
- Database: PostgreSQL via [RDS/Cloud SQL/Supabase/local Docker]
- Cache: Redis for sessions, cache, and Celery broker
- File storage: [S3/GCS/Azure Blob] via django-storages
- Monitoring: Sentry for errors, Prometheus + Grafana for metrics
- CI/CD: GitHub Actions → Docker build → deploy to [ECS/GKE/Railway]
```
{% endraw %}

## How to Adapt This For Your Project

Start with the **Project Stack** section and update all version numbers from your `pyproject.toml` or `requirements.txt`. If you do not use Celery, remove the task-related sections and the Celery commands. If you use a different authentication method (session-based, OAuth2), replace the JWT section in Security. The **Settings split** pattern is essential — adapt the file paths if you use a different project structure (like `myproject/settings/` instead of `config/settings/`). Add your most common model patterns to the Architecture section as you discover them.

## Common CLAUDE.md Mistakes in Django Projects

1. **Not specifying the settings module pattern.** Without this, Claude creates a monolithic `settings.py` and puts debug settings alongside production configuration. Specify your `base/development/production` split explicitly.

2. **Allowing `fields = "__all__"` in serializers.** This is a security risk — Claude defaults to `__all__` for brevity, which exposes every field including password hashes, internal IDs, and soft-delete flags. Mandate explicit field lists.

3. **Not mentioning `select_related` / `prefetch_related`.** Without this rule, Claude writes views that trigger N+1 queries on every list endpoint. A 20-item list page makes 21 database queries instead of 2.

4. **Missing migration safety rules.** Claude generates `makemigrations` with non-nullable fields on existing tables, which crashes production. The "always provide a default" rule prevents deployment failures.

5. **Using `psycopg2` instead of `psycopg` 3.** Claude defaults to the older `psycopg2-binary` import. Django 5.x supports `psycopg` 3 natively, which has better async support and type safety.

## What Claude Code Does With This

When this CLAUDE.md is loaded, Claude Code generates Django models with proper `TimestampedModel` inheritance, explicit `Meta` classes, and custom managers. DRF serializers get explicit field lists instead of `__all__`. New API endpoints follow the ViewSet + Router pattern with proper permission classes and FilterSets. Database queries include `select_related` and `prefetch_related` calls. Migrations are generated safely with defaults on new fields. Claude uses `pytest` fixtures and Factory Boy instead of Django's test case classes, and structures tests by model/view/serializer.

## The Full 16-Template Pack

This is one of 16 production CLAUDE.md templates available in the Lifetime pack. Includes templates for FastAPI + SQLAlchemy, Rails + Turbo, Next.js + TypeScript, Go + Gin, and 11 more stacks. Each template is 200-400 lines of production-tested configuration. Get all 16 at [claudecodeguides.com/generator/](https://claudecodeguides.com/generator/).
