---
layout: default
title: "Setting Up Claude Code for Python/Django: Walkthrough (2026)"
description: "Django-specific Claude Code setup: CLAUDE.md with Django conventions, .claudeignore for __pycache__, manage.py permissions, pytest testing, and project structure."
date: 2026-04-26
author: "Claude Skills Guide"
permalink: /setting-up-claude-code-python-django-walkthrough/
reviewed: true
categories: [getting-started]
tags: [claude, claude-code, python, django, setup, walkthrough]
---

# Setting Up Claude Code for Python/Django: Walkthrough

Django projects have conventions that generic AI tools routinely violate -- editing migrations instead of creating new ones, mixing business logic into views, ignoring the ORM in favor of raw SQL. A properly configured Claude Code respects Django's architecture and follows your project's patterns. This walkthrough creates a Django-specific setup that prevents common mistakes. Use the [Project Starter](/starter/) to generate these files automatically or follow the manual steps below.

## CLAUDE.md for Django

```markdown
# CLAUDE.md

## Project
Django 5.1, Python 3.12, PostgreSQL, DRF, Celery, Redis

## Package Manager
uv (use `uv add` for dependencies, `uv run` for commands)

## Commands
- `uv run python manage.py runserver` -- dev server at :8000
- `uv run pytest` -- run test suite
- `uv run pytest --cov` -- tests with coverage report
- `uv run ruff check .` -- linting
- `uv run ruff format .` -- auto-format
- `uv run mypy .` -- type checking
- `uv run python manage.py makemigrations` -- create migrations
- `uv run python manage.py migrate` -- apply migrations
- `uv run python manage.py shell_plus` -- enhanced Django shell

## Django Architecture Rules

### Models (apps/*/models.py)
- All fields require verbose_name and help_text
- Use choices for enum-like fields (TextChoices/IntegerChoices)
- Custom managers in separate managers.py files
- Meta class: ordering, verbose_name, verbose_name_plural, indexes
- __str__ on every model
- get_absolute_url() on models with detail views

### Views (apps/*/views.py)
- Class-based views for CRUD, function-based for simple endpoints
- Business logic in services.py, NOT in views
- DRF ViewSets for API endpoints
- Permission classes on every API view
- Pagination on all list endpoints

### Serializers (apps/*/serializers.py)
- DRF serializers for all API data
- Validation in validate_<field> methods or validate()
- Never expose internal fields (id is OK, passwords are not)
- Use SerializerMethodField for computed properties

### Migrations
- NEVER edit existing migration files
- ALWAYS create new migrations with makemigrations
- Data migrations in separate files from schema migrations
- Test migrations pass: `uv run python manage.py migrate --check`

### Templates (templates/)
- Base template: templates/base.html
- App templates: templates/<app_name>/*.html
- Template tags/filters in apps/*/templatetags/
- Use {% block %} inheritance, not {% include %} for layouts

## File Structure
- apps/<app_name>/ -- Django apps (models, views, urls, tests)
- apps/<app_name>/services.py -- business logic
- apps/<app_name>/selectors.py -- complex queries
- config/ -- project settings, root URLs, WSGI/ASGI
- config/settings/ -- split settings (base, local, production)
- templates/ -- HTML templates
- static/ -- static assets
- tests/ -- integration tests (unit tests in apps/*/tests/)

## Testing
- pytest + pytest-django for all tests
- Factory Boy for test data (no fixtures)
- conftest.py for shared fixtures
- Test files: tests/test_<module>.py or apps/*/tests/test_<module>.py
- Mark slow tests: @pytest.mark.slow
- Use Django test client for view tests, APIClient for DRF
```

## .claudeignore for Django

Django projects generate `__pycache__`, migration files accumulate, and static collection creates duplicates. Exclude them all:

```bash
# .claudeignore

# Python bytecode
__pycache__/
*.pyc
*.pyo

# Virtual environment
.venv/
venv/
env/

# Django generated
staticfiles/
media/
*.sqlite3
db.sqlite3

# Test/coverage
.pytest_cache/
htmlcov/
.coverage
coverage.xml

# IDE
.idea/
.vscode/
*.swp

# Build
dist/
*.egg-info/

# Large fixtures (read individual ones as needed)
fixtures/*.json

# Compiled assets
node_modules/
```

## Permissions for Django Development

```json
{
  "permissions": {
    "allow": [
      "Read",
      "Glob",
      "Grep",
      "Edit",
      "Write",
      "Bash(uv run pytest *)",
      "Bash(uv run pytest)",
      "Bash(uv run ruff check *)",
      "Bash(uv run ruff format *)",
      "Bash(uv run mypy *)",
      "Bash(uv run python manage.py makemigrations *)",
      "Bash(uv run python manage.py migrate --check)",
      "Bash(uv run python manage.py showmigrations *)",
      "Bash(uv run python manage.py check)",
      "Bash(git diff *)",
      "Bash(git status)",
      "Bash(git log *)",
      "Bash(wc -l *)",
      "Bash(ls *)"
    ],
    "deny": [
      "Bash(rm -rf *)",
      "Bash(git push --force *)",
      "Bash(git reset --hard *)",
      "Bash(uv run python manage.py migrate)",
      "Bash(uv run python manage.py flush)",
      "Bash(uv run python manage.py dbshell)",
      "Bash(DROP *)",
      "Bash(DELETE FROM *)",
      "Bash(sudo *)"
    ]
  }
}
```

Key decisions:
- **makemigrations allowed:** Claude Code can create new migration files
- **migrate denied:** Applying migrations to the database requires human approval
- **flush denied:** Prevents accidental database wipe
- **dbshell denied:** No raw database access through the shell

## Django-Specific Prompting Patterns

Frame your requests using Django terminology for better results:

```bash
# Model creation
"Create a Product model in apps/catalog/models.py with name,
 description, price (DecimalField), SKU, and created/updated
 timestamps. Add a custom manager for active products.
 Create the migration."

# API endpoint
"Add a DRF ViewSet for Product in apps/catalog/views.py
 with list, retrieve, and create actions. Use ProductSerializer
 from serializers.py. Add IsAuthenticated permission for create.
 Register in apps/catalog/urls.py."

# Service layer
"Create a services.py in apps/orders/ with a create_order
 function that validates inventory, creates the order,
 deducts stock, and sends a confirmation via Celery task."

# Testing
"Write pytest tests for the Product ViewSet: test list
 returns paginated results, test create requires auth,
 test retrieve returns correct serialized data. Use Factory
 Boy for test data."
```

## Model-View-Service Pattern

Add a note about your service layer to prevent Claude Code from putting logic in views:

```python
# apps/orders/services.py -- Claude Code follows this pattern
from apps.orders.models import Order
from apps.catalog.models import Product
from apps.orders.tasks import send_order_confirmation

def create_order(user, items: list[dict]) -> Order:
    """Create order, validate inventory, deduct stock."""
    assert len(items) > 0, "Order must have at least one item"
    assert user.is_authenticated, "User must be authenticated"

    total = sum(
        Product.objects.get(id=item["product_id"]).price * item["quantity"]
        for item in items
    )

    order = Order.objects.create(user=user, total=total)

    for item in items:
        product = Product.objects.get(id=item["product_id"])
        assert product.stock >= item["quantity"], f"Insufficient stock for {product.name}"
        product.stock -= item["quantity"]
        product.save()
        order.items.create(product=product, quantity=item["quantity"])

    send_order_confirmation.delay(order.id)
    return order
```

## Try It Yourself

The [Project Starter](/starter/) detects Django projects by checking for `manage.py` and `settings.py`. It generates a CLAUDE.md with your installed apps, database backend, and testing framework -- plus a `.claudeignore` and `settings.json` tailored to your project. Run it to skip the manual setup.

## Frequently Asked Questions

<details>
<summary>How does Claude Code handle Django migrations?</summary>
With the CLAUDE.md rules above, Claude Code creates new migrations via makemigrations but never edits existing ones. The deny rule on `manage.py migrate` prevents automatic migration application -- you review and apply manually. This prevents accidental schema changes on shared databases. See <a href="/permissions/">Permissions</a> for fine-tuning migration controls.
</details>

<details>
<summary>Should I include Django settings in CLAUDE.md?</summary>
Include the settings structure (base/local/production split) and key configuration choices (database backend, cache backend, auth backend). Never include secret values. Claude Code needs to know you use PostgreSQL and Redis to suggest appropriate code, but does not need connection strings. See the <a href="/configuration/">Configuration Guide</a> for secure patterns.
</details>

<details>
<summary>How do I configure Claude Code for Django REST Framework?</summary>
Add DRF-specific rules to CLAUDE.md: serializer conventions, ViewSet patterns, permission classes, pagination settings, and authentication backends. The template above includes DRF rules. If you use drf-spectacular for API docs, mention that too so Claude Code generates proper schema annotations. Use the <a href="/starter/">Project Starter</a> to auto-detect DRF.
</details>

<details>
<summary>Can Claude Code work with Django Channels and async views?</summary>
Yes. Add async conventions to CLAUDE.md: "Use async views for I/O-heavy endpoints. Channels consumers in apps/*/consumers.py. ASGI routing in config/asgi.py." Claude Code understands async def views, database_sync_to_async, and WebSocket consumers when given these conventions. See <a href="/commands/">Commands</a> for async-specific workflow tips.
</details>

<script type="application/ld+json">
{
  "@context": "https://schema.org",
  "@type": "FAQPage",
  "mainEntity": [
    {
      "@type": "Question",
      "name": "How does Claude Code handle Django migrations?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "Claude Code creates new migrations via makemigrations but never edits existing ones. The deny rule on manage.py migrate prevents automatic application -- you review and apply manually."
      }
    },
    {
      "@type": "Question",
      "name": "Should I include Django settings in CLAUDE.md?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "Include settings structure and key configuration choices (database backend, cache backend) but never secret values. Claude Code needs to know you use PostgreSQL to suggest appropriate code."
      }
    },
    {
      "@type": "Question",
      "name": "How do I configure Claude Code for Django REST Framework?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "Add DRF-specific rules to CLAUDE.md: serializer conventions, ViewSet patterns, permission classes, pagination settings. The Project Starter auto-detects DRF."
      }
    },
    {
      "@type": "Question",
      "name": "Can Claude Code work with Django Channels and async views?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "Yes. Add async conventions to CLAUDE.md covering async def views, database_sync_to_async, and WebSocket consumers. Claude Code understands these patterns when given the conventions."
      }
    }
  ]
}
</script>

## Related Guides

- [Project Starter](/starter/) -- Auto-generate Django-specific Claude Code configuration
- [CLAUDE.md Generator](/generator/) -- Create framework-aware instruction files
- [Permissions Configurator](/permissions/) -- Set up Django-safe permissions
- [Commands Reference](/commands/) -- Claude Code commands for development workflows
- [Configuration Guide](/configuration/) -- Full .claudeignore and settings.json reference
