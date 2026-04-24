---
layout: default
title: "Set Up Django MCP Server for Claude (2026)"
description: "Connect Claude Code to Django projects via MCP. Query models, run migrations, and debug views with a custom Django MCP server configuration."
date: 2026-04-17
last_modified_at: 2026-04-17
author: "Claude Skills Guide"
permalink: /claude-code-django-mcp/
categories: [guides]
tags: [claude-code, claude-skills, django, mcp, python]
reviewed: true
score: 6
geo_optimized: true
---

A Django MCP server gives Claude Code direct access to your Django ORM, management commands, and project structure. Instead of Claude guessing at model fields or query patterns, it can introspect your actual database schema, run migrations, and execute Django shell commands through the MCP protocol.

## The Problem

Claude Code does not natively understand your Django project's models, relationships, or custom management commands. It reads your Python files but cannot execute ORM queries, check migration state, or test views. This leads to generated code that assumes wrong field names, missing relationships, or outdated schema.

## Quick Solution

1. Install the Django MCP server package:

```bash
pip install django-mcp-server
```

2. Add it to your Django settings:

```python
# settings.py
INSTALLED_APPS = [
    # ... existing apps
    'django_mcp_server',
]
```

3. Configure the MCP server in your project `.mcp.json`:

```json
{
  "mcpServers": {
    "django": {
      "command": "python",
      "args": ["manage.py", "mcp_server"],
      "env": {
        "DJANGO_SETTINGS_MODULE": "myproject.settings",
        "DATABASE_URL": "postgres://localhost:5432/mydb"
      }
    }
  }
}
```

4. Verify the connection in Claude Code:

```bash
claude mcp list
# Should show "django" as connected
```

5. Use Django tools in your Claude session:

```bash
claude "List all models in the users app with their
fields and relationships. Then write a queryset that
finds all active users who signed up in the last 30 days."
```

## How It Works

The Django MCP server runs as a child process spawned by Claude Code. It loads your Django settings, initializes the ORM, and exposes tools over the MCP protocol via stdio transport. These tools allow Claude to interact with your Django project programmatically.

Typical tools exposed by a Django MCP server include:

- **list_models** -- returns all models with fields, types, and relationships
- **run_query** -- executes a Django ORM query and returns results
- **check_migrations** -- shows pending migrations and migration state
- **run_management_command** -- executes Django management commands like `collectstatic` or custom commands
- **describe_urls** -- lists all URL patterns with their view names

When Claude needs to write a view or serializer, it first calls `list_models` to get the exact field names and types. When debugging a query, it calls `run_query` to test the ORM expression against real data. This feedback loop eliminates the guesswork that causes incorrect generated code.

The MCP server runs with your full Django configuration, so it respects your database routers, custom managers, and model mixins. All queries run against your development database.

## Common Issues

**DJANGO_SETTINGS_MODULE not found.** The MCP server needs to import your settings module. Ensure the `DJANGO_SETTINGS_MODULE` environment variable in `.mcp.json` matches your actual settings path. For a project named `myproject`, it should be `myproject.settings`:

```json
{
  "env": {
    "DJANGO_SETTINGS_MODULE": "myproject.settings",
    "PYTHONPATH": "/path/to/your/project"
  }
}
```

**Database connection refused.** The MCP server connects to whatever database your Django settings configure. If you use environment-specific databases, ensure the MCP config points to your development database. Never point it at production.

**Import errors on startup.** If your Django app has import-time side effects or requires services that are not running locally (Redis, Celery), the MCP server may fail to start. Wrap those imports in try/except or use a dedicated MCP settings file that disables optional services:

```python
# settings_mcp.py
from .settings import *
CACHES = {"default": {"BACKEND": "django.core.cache.backends.locmem.LocMemCache"}}
CELERY_ALWAYS_EAGER = True
```

## Example CLAUDE.md Section

```markdown
# Django MCP Server

## Available Tools
- `list_models`: Shows all models with fields and relations
- `run_query`: Executes ORM queries (read-only in production)
- `check_migrations`: Shows pending migration state
- `run_management_command`: Runs manage.py commands

## Project Structure
- Apps: users, products, orders, payments
- Database: PostgreSQL 15
- Cache: Redis (not available in MCP context)

## Conventions
- All models inherit from BaseModel (uuid pk, created_at, updated_at)
- Soft delete via is_active field, use .active() manager
- Queries: always use select_related/prefetch_related for FKs
- Never use .all() without filtering in production code

## Django MCP Settings
- Settings module: myproject.settings_mcp
- PYTHONPATH must include project root
```

## Best Practices

- **Use a separate settings file for MCP** that disables external service dependencies like Redis, Celery, and external APIs. This ensures the MCP server starts cleanly without requiring your full infrastructure.
- **Make MCP queries read-only by default.** Configure the Django MCP server to use a read-only database user or add a middleware that prevents writes during MCP sessions.
- **Document your model conventions in CLAUDE.md.** If all models use UUID primary keys or soft deletes, Claude needs to know this to generate correct queries and migrations.
- **Include PYTHONPATH in the MCP env block.** Django imports require the project root on the Python path, and the MCP child process does not inherit your virtualenv's path configuration automatically.
- **Test the MCP server independently** by running `python manage.py mcp_server` manually before adding it to `.mcp.json`. This surfaces import errors and database issues immediately.

---

---

<div class="mastery-cta">

I'm a solo developer in Vietnam. 50K Chrome extension users. $500K+ on Upwork. 5 Claude Max subscriptions running agent fleets in parallel.

These are my actual CLAUDE.md templates, orchestration configs, and prompts. Not a course. Not theory. The files I copy into every project before I write a line of code.

**[See what's inside →](https://zovo.one/lifetime?utm_source=ccg&utm_medium=cta-default&utm_campaign=claude-code-django-mcp)**

$99 once. Free forever. 47/500 founding spots left.

</div>

Related Reading

- [Claude Code MCP Server Setup](/claude-code-mcp-server-setup/)
- [AI-Assisted Database Schema Design Workflow](/ai-assisted-database-schema-design-workflow/)
- [Claude Code Database Schema Design Guide](/claude-code-database-schema-design-guide/)

Built by theluckystrike. More at [zovo.one](https://zovo.one)
