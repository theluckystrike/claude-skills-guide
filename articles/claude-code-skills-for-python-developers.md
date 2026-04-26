---
layout: default
title: "Claude Code Skills for Python Developers: 15 Must-Have (2026)"
description: "15 essential Claude Code skills for Python developers: pytest runner, Django management, FastAPI scaffolding, type checker, docstring generator, and more."
date: 2026-04-26
author: "Claude Skills Guide"
permalink: /claude-code-skills-for-python-developers/
reviewed: true
categories: [skills]
tags: [claude, claude-code, python, skills, pytest, django, fastapi]
---

# Claude Code Skills for Python Developers: 15 Must-Have

Claude Code is model-agnostic -- it works with any language. But Python developers get the most value by installing skills that encode Python-specific best practices, framework conventions, and toolchain knowledge. These 15 skills cover testing, web frameworks, type checking, packaging, and data science workflows. Each includes the install command and a concrete usage example so you can evaluate whether it fits your workflow. Find more Python skills with the [Skill Finder](/skill-finder/).

## Testing Skills

### 1. Pytest Runner

Writes and runs pytest tests with proper fixtures, parametrize decorators, and mocking patterns. Understands conftest.py hierarchy and test discovery.

```bash
/install pytest-runner
```

**Usage:**

```
Write tests for src/auth/password.py using pytest. Include parametrize for edge cases and mock the database calls.
```

**Output (example):**

```python
import pytest
from unittest.mock import patch, MagicMock
from src.auth.password import hash_password, verify_password, check_strength

@pytest.fixture
def mock_db():
    with patch("src.auth.password.get_db") as mock:
        mock.return_value = MagicMock()
        yield mock.return_value

@pytest.mark.parametrize("password,expected_strength", [
    ("abc", "weak"),
    ("Abc123!@#", "strong"),
    ("aaaaaaaaaaaa", "medium"),
    ("", "invalid"),
])
def test_check_strength(password, expected_strength):
    assert check_strength(password) == expected_strength

def test_hash_password_returns_bcrypt():
    hashed = hash_password("test_password")
    assert hashed.startswith("$2b$")
    assert len(hashed) == 60
```

### 2. Coverage Analyzer

Analyzes test coverage gaps and generates tests specifically for uncovered branches and functions.

```bash
/install coverage-analyzer
```

**Usage:**

```
Run coverage on src/payments/ and write tests for the uncovered lines.
```

### 3. Integration Test Builder

Creates integration tests that set up real databases (via Docker), seed test data, and verify end-to-end flows.

```bash
/install integration-tests
```

## Web Framework Skills

### 4. Django Management

Manages Django projects: creates models, views, serializers, URLs, migrations, and management commands following Django conventions.

```bash
/install django-manager
```

**Usage:**

```
Create a Django model for UserProfile with fields: bio (text), avatar_url (url), created_at (auto). Include the serializer, viewset, and URL config.
```

### 5. FastAPI Scaffolding

Generates FastAPI endpoints with Pydantic models, dependency injection, middleware, and OpenAPI documentation.

```bash
/install fastapi-scaffold
```

**Usage:**

```
Create a FastAPI router for /api/v1/products with CRUD endpoints. Use SQLAlchemy async session and Pydantic v2 models.
```

**Output (example):**

```python
from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.ext.asyncio import AsyncSession
from pydantic import BaseModel, ConfigDict

router = APIRouter(prefix="/api/v1/products", tags=["products"])

class ProductCreate(BaseModel):
    name: str
    price: float
    description: str | None = None

class ProductResponse(ProductCreate):
    model_config = ConfigDict(from_attributes=True)
    id: int
    created_at: datetime

@router.post("/", response_model=ProductResponse, status_code=status.HTTP_201_CREATED)
async def create_product(
    product: ProductCreate,
    db: AsyncSession = Depends(get_db),
):
    db_product = Product(**product.model_dump())
    db.add(db_product)
    await db.commit()
    await db.refresh(db_product)
    return db_product
```

### 6. Flask Blueprint Generator

Creates Flask blueprints with routes, templates, forms, and SQLAlchemy models following Flask best practices.

```bash
/install flask-blueprint
```

## Type Checking and Code Quality Skills

### 7. Mypy Type Fixer

Identifies and fixes mypy type errors. Adds type annotations to untyped functions, fixes type incompatibilities, and adds proper generics.

```bash
/install mypy-fixer
```

**Usage:**

```
Fix all mypy errors in src/utils/ and add type annotations to untyped functions.
```

### 8. Docstring Generator

Generates Google-style or NumPy-style docstrings for all functions, classes, and modules. Reads the actual implementation to document parameters, return types, exceptions, and examples.

```bash
/install python-docstrings
```

**Usage:**

```
Add Google-style docstrings to all public functions in src/core/engine.py. Include Args, Returns, Raises, and Example sections.
```

### 9. Ruff Linter Integration

Applies ruff rules, fixes auto-fixable violations, and explains non-auto-fixable issues with suggested manual fixes.

```bash
/install ruff-linter
```

## Data Science and ML Skills

### 10. Pandas Optimizer

Reviews pandas code for performance: vectorization opportunities, chunked reading for large CSVs, proper dtypes, and avoiding iterrows.

```bash
/install pandas-optimizer
```

**Usage:**

```
Optimize the data processing pipeline in notebooks/analysis.py. Focus on replacing loops with vectorized operations.
```

### 11. Jupyter Notebook Cleaner

Cleans Jupyter notebooks: removes output cells, strips metadata, standardizes cell ordering, and extracts reusable functions into .py modules.

```bash
/install notebook-cleaner
```

## Packaging and Deployment Skills

### 12. Virtual Environment Manager

Sets up and manages Python virtual environments, handles dependency resolution, creates requirements.txt and pyproject.toml, and fixes version conflicts.

```bash
/install venv-manager
```

**Usage:**

```
Set up a new virtual environment for this project. Create pyproject.toml with the dependencies from requirements.txt. Pin all versions.
```

### 13. Package Publisher

Prepares Python packages for PyPI: builds with setuptools or hatch, creates pyproject.toml, writes classifiers, and handles versioning.

```bash
/install package-publisher
```

### 14. Docker Python Builder

Creates optimized Dockerfiles for Python applications: multi-stage builds, minimal base images, proper pip caching, and non-root user setup.

```bash
/install docker-python
```

**Usage:**

```
Create a Dockerfile for this FastAPI application. Use multi-stage build with python:3.12-slim. Include health check and non-root user.
```

**Output (example):**

```dockerfile
FROM python:3.12-slim AS builder
WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir --prefix=/install -r requirements.txt

FROM python:3.12-slim
RUN useradd --create-home appuser
WORKDIR /app
COPY --from=builder /install /usr/local
COPY . .
RUN chown -R appuser:appuser /app
USER appuser
EXPOSE 8000
HEALTHCHECK CMD curl -f http://localhost:8000/health || exit 1
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]
```

### 15. Celery Task Writer

Creates Celery tasks with proper retry logic, error handling, rate limiting, and monitoring hooks.

```bash
/install celery-tasks
```

## Combining Skills for Maximum Effect

The most effective setup for Python developers combines 4-5 skills from different categories:

```
Testing:    pytest-runner
Framework:  django-manager OR fastapi-scaffold
Quality:    mypy-fixer + python-docstrings
Deployment: docker-python
```

This combination covers the full development lifecycle without overloading your context window. Each skill adds approximately 500-800 tokens to your system prompt. Five skills total roughly 3,000 tokens, well within the recommended [configuration limits](/configuration/).

## Try It Yourself

Search for Python-specific skills by framework, library, or task type. The **[Skill Finder](/skill-finder/)** filters by language and shows install commands, descriptions, and compatibility information for every skill.

**[Try the Skill Finder -->](/skill-finder/)**

## Common Questions

<details><summary>Do these skills work with Python 3.12+ features?</summary>
Yes. Skills like mypy-fixer and fastapi-scaffold understand modern Python syntax including match statements, type union with <code>|</code>, and <code>Self</code> type. They generate code using the latest stable syntax appropriate for your Python version.
</details>

<details><summary>Can I use Django and FastAPI skills in the same project?</summary>
You can install both, but it is not recommended. The skills may provide conflicting conventions (e.g., Django ORM vs SQLAlchemy). Install only the framework skill matching your active project.
</details>

<details><summary>Which testing skill should I use: pytest-runner or integration-tests?</summary>
Use pytest-runner for unit tests (fast, isolated, no external dependencies). Use integration-tests when you need to test database queries, API calls, or multi-service interactions. Most projects benefit from both.
</details>

<details><summary>Do skills replace tools like Black, mypy, or ruff?</summary>
No. Skills enhance Claude Code's understanding of these tools -- they do not replace the tools themselves. The ruff-linter skill helps Claude Code apply ruff fixes correctly, but you should still have ruff installed in your project's development dependencies.
</details>

<script type="application/ld+json">
{"@context":"https://schema.org","@type":"FAQPage","mainEntity":[
{"@type":"Question","name":"Do these skills work with Python 3.12+ features?","acceptedAnswer":{"@type":"Answer","text":"Yes. Skills understand modern Python syntax including match statements, type union with |, and Self type. They generate code using the latest stable syntax."}},
{"@type":"Question","name":"Can I use Django and FastAPI skills in the same project?","acceptedAnswer":{"@type":"Answer","text":"You can install both, but it is not recommended due to conflicting conventions. Install only the framework skill matching your active project."}},
{"@type":"Question","name":"Which testing skill should I use: pytest-runner or integration-tests?","acceptedAnswer":{"@type":"Answer","text":"Use pytest-runner for unit tests and integration-tests for database queries, API calls, or multi-service interactions. Most projects benefit from both."}},
{"@type":"Question","name":"Do skills replace tools like Black, mypy, or ruff?","acceptedAnswer":{"@type":"Answer","text":"No. Skills enhance Claude Code's understanding of these tools but do not replace them. You should still have them installed in your development dependencies."}}
]}
</script>

## Related Guides

- [Best Claude Code Skills Ranked](/best-claude-code-skills-2026-ranked/)
- [How to Install Skills Guide](/how-to-install-claude-code-skills-guide/)
- [CLAUDE.md Generator](/generator/)
- [Commands Reference](/commands/)
- [Skill Finder](/skill-finder/) -- search all Python skills
