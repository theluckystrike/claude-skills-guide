---
layout: default
title: "CLAUDE.md for Python Projects (2026)"
description: "Python-specific CLAUDE.md with type hints, pytest conventions, virtual environment rules, and linting config. Updated April 2026."
date: 2026-04-26
permalink: /claudemd-for-python-projects-2026/
categories: [guides, claude-code]
tags: [CLAUDE.md, Python, configuration, best-practices]
last_modified_at: 2026-04-26
---

# CLAUDE.md for Python Projects (2026)

Python's flexibility is its greatest strength and its biggest liability when working with AI coding assistants. Without explicit guidance, Claude Code generates Python that works but clashes with your project's conventions. It might use f-strings where your team uses format(), create functions without type hints in a fully typed codebase, or install packages with pip when you use poetry.

A Python-specific CLAUDE.md eliminates these inconsistencies. This guide provides a battle-tested template covering type hints, testing, virtual environments, linting, and project structure. You can also generate one instantly with the [CLAUDE.md Generator](/generator/).

## The Python CLAUDE.md Template

```markdown
# CLAUDE.md — Python Project

## Project Stack
- Python: 3.12+
- Framework: FastAPI 0.115
- Package manager: uv (never use pip directly)
- Virtual env: .venv/ (created by uv)
- Type checking: mypy (strict mode)
- Linting: ruff
- Testing: pytest + pytest-asyncio
- Database: SQLAlchemy 2.0 + Alembic

## Type Hint Rules
- All function signatures must have type hints
- Use builtin generics: list[str] not List[str]
- Use X | None not Optional[X]
- Use TypedDict for structured dicts
- Return types required, even for None (-> None)
- No Any types unless interfacing with untyped libraries

## Code Style
- Maximum function length: 50 lines
- Maximum file length: 300 lines
- Use pathlib.Path, never os.path
- Use f-strings for string formatting
- Prefer dataclasses or Pydantic models over raw dicts
- Use structural pattern matching for 3+ conditions
- Imports: stdlib, blank line, third-party, blank line, local

## File Organization
- Source code: src/[package_name]/
- API routes: src/[package_name]/api/routes/
- Models: src/[package_name]/models/
- Services: src/[package_name]/services/
- Tests: tests/ (mirroring src/ structure)
- Migrations: alembic/versions/

## Testing Requirements
- Use pytest fixtures, never setUp/tearDown
- Async tests with pytest-asyncio
- Factory pattern for test data (tests/factories/)
- Mock external services, never real API calls
- Minimum 85% coverage on new code
- Test file naming: test_[module].py

## Forbidden Patterns
- No global mutable state
- No bare except clauses (use specific exceptions)
- No star imports (from module import *)
- No print() for logging (use structlog)
- No requirements.txt (use pyproject.toml)
```

## Why Python Projects Need Custom Configuration

Python has undergone significant changes in recent versions. Claude Code's training data spans multiple Python eras, and without guidance it mixes modern and legacy patterns:

**Type hints.** Python 3.12 supports `list[str]` natively, but Claude often generates `from typing import List` followed by `List[str]`. Your CLAUDE.md must specify which syntax to use.

**Package management.** The Python packaging landscape includes pip, poetry, pipenv, pdm, and uv. Claude defaults to pip unless told otherwise. If your project uses uv or poetry, this must be explicit.

**String formatting.** Claude switches between f-strings, `.format()`, and percent formatting depending on context. Pick one and enforce it.

**Path handling.** Claude uses `os.path.join()` in projects that standardized on `pathlib.Path`. This creates an inconsistent API surface.

## Adapting for Common Python Frameworks

### Django Projects

```markdown
## Project Stack
- Framework: Django 5.1
- API: Django REST Framework 3.15
- Database: PostgreSQL via Django ORM

## Django Rules
- Models in [app]/models.py (one model per file if complex)
- Views: class-based for CRUD, function-based for custom logic
- Serializers: one per model, separate for list/detail
- URL patterns: [app]/urls.py included in project urls.py
- Migrations: always run makemigrations after model changes
- Settings: split into base.py, local.py, production.py
```

### Data Science / ML Projects

```markdown
## Project Stack
- Framework: None (scripts + notebooks)
- ML: PyTorch 2.4 / scikit-learn 1.5
- Data: pandas 2.2 + polars 1.0
- Notebooks: Jupyter (exploration only, not production)

## Data Science Rules
- Production code in src/, never in notebooks
- Notebooks are for exploration; extract to modules before merge
- Use polars for new DataFrames, pandas only for legacy code
- Pin all dependency versions in pyproject.toml
- Log experiments with MLflow, not print statements
```

### CLI Tool Projects

```markdown
## Project Stack
- CLI framework: Click 8.1 or Typer 0.12
- Distribution: PyPI via build + twine

## CLI Rules
- One command per file in src/[package]/commands/
- Use Click groups for subcommands
- Rich for formatted terminal output
- Always provide --help text for every option
- Exit codes: 0 success, 1 user error, 2 system error
```

## Type Hint Examples That Matter

The difference between a typed and untyped Python codebase with Claude is dramatic. With proper type hint rules in CLAUDE.md, Claude generates:

```python
from dataclasses import dataclass
from datetime import datetime


@dataclass
class UserProfile:
    user_id: str
    email: str
    created_at: datetime
    is_active: bool = True


def get_active_users(
    profiles: list[UserProfile],
    since: datetime | None = None,
) -> list[UserProfile]:
    """Filter profiles to active users, optionally after a date."""
    result: list[UserProfile] = []
    for profile in profiles:
        if not profile.is_active:
            continue
        if since and profile.created_at < since:
            continue
        result.append(profile)
    return result
```

Without type hint rules, Claude generates the same logic with no annotations, raw dicts instead of dataclasses, and ambiguous parameter expectations.

## Try It Yourself

Configuring CLAUDE.md for Python means remembering every convention from type hints to import ordering to test patterns. The [CLAUDE.md Generator](/generator/) handles this automatically. Select Python as your language, specify your framework and tooling, and receive a complete CLAUDE.md covering all the patterns described here. It takes less than a minute and catches conventions you might overlook.

## Validating Your Python CLAUDE.md

Run this checklist after installing your CLAUDE.md:

1. Ask Claude to create a new module. Verify it uses your import ordering, type hints, and file placement.
2. Ask Claude to write tests. Confirm it uses pytest fixtures (not unittest), your naming convention, and your mock strategy.
3. Ask Claude to add a dependency. Check that it uses your package manager (uv/poetry), not pip.
4. Ask Claude to create a database model. Verify it matches your ORM patterns (SQLAlchemy/Django ORM).

If any check fails, tighten the relevant CLAUDE.md section with a concrete code example showing the expected pattern.

## Related Guides

- [Perfect CLAUDE.md File Template](/perfect-claudemd-file-template-2026/) — The universal annotated template
- [CLAUDE.md Best Practices for Projects](/claude-code-claude-md-best-practices/) — Adherence optimization
- [Best AI Coding Tools for Python](/best-ai-coding-tools-python-comparison-2026/) — Python tooling landscape
- [Best Claude Code Plugins for Python](/best-claude-code-plugins-python-2026/) — Python-specific extensions
- [Claude Code FastAPI Async Python Guide](/claude-code-fastapi-async-python-guide/) — FastAPI patterns with Claude
- [CLAUDE.md Generator](/generator/) — Generate your Python CLAUDE.md instantly

## Frequently Asked Questions

### Should I include linting rules in CLAUDE.md or just rely on ruff?
Include the key rules in CLAUDE.md so Claude generates compliant code from the start. Ruff catches violations after the fact, but it is more efficient when Claude writes correct code initially. Focus on rules that ruff cannot autofix like function length and architectural patterns.

### How do I handle Python 2 compatibility in CLAUDE.md?
Add an explicit rule: "Target Python 3.12+ only. Never use Python 2 patterns like print statements without parentheses or unicode_literals imports." If you genuinely need Python 2 support, specify it clearly but note that modern Claude Code works best with Python 3.10+.

### Does CLAUDE.md work with Jupyter notebooks?
Claude Code can edit notebooks, and CLAUDE.md rules apply when it does. Add a section specifying notebook conventions: "Notebooks for exploration only. Keep cells under 20 lines. Extract reusable logic to src/ modules. Clear all outputs before committing."

### How often should I update my Python CLAUDE.md?
Update when you change tools (new linter, package manager, or framework version), add new architectural patterns, or notice Claude consistently generating non-conforming code. Quarterly reviews work well for most teams.

<script type="application/ld+json">
{
  "@context": "https://schema.org",
  "@type": "FAQPage",
  "mainEntity": [
    {
      "@type": "Question",
      "name": "Should I include linting rules in CLAUDE.md or just rely on ruff?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "Include key rules in CLAUDE.md so Claude generates compliant code initially. Ruff catches violations after the fact but it is more efficient when Claude writes correct code from the start. Focus on rules ruff cannot autofix."
      }
    },
    {
      "@type": "Question",
      "name": "How do I handle Python 2 compatibility in CLAUDE.md?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "Add an explicit rule targeting Python 3.12+ only and prohibiting Python 2 patterns. If you need Python 2 support specify it clearly but modern Claude Code works best with Python 3.10 or newer."
      }
    },
    {
      "@type": "Question",
      "name": "Does CLAUDE.md work with Jupyter notebooks?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "Yes. Claude Code can edit notebooks and CLAUDE.md rules apply. Add a section specifying notebook conventions like cell length limits and extracting reusable logic to source modules."
      }
    },
    {
      "@type": "Question",
      "name": "How often should I update my Python CLAUDE.md?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "Update when you change tools, add new architectural patterns, or notice Claude generating non-conforming code. Quarterly reviews work well for most teams."
      }
    }
  ]
}
</script>
