---
layout: post
title: "Claude Code for FastAPI Development (2026)"
description: "Build FastAPI applications with Claude Code: endpoint generation, Pydantic models, async handlers, and OpenAPI spec automation with examples."
permalink: /claude-code-fastapi-development-workflow-2026/
date: 2026-04-21
last_tested: "2026-04-21"
---

## The Workflow

Use Claude Code to accelerate FastAPI development: generate Pydantic models from database schemas, scaffold async route handlers, write dependency injection patterns, and auto-generate OpenAPI documentation. Ideal for Python backend developers building REST APIs.

Expected time: 10 minutes setup, then ongoing use
Prerequisites: Python 3.11+, FastAPI 0.110+, Claude Code CLI installed

## Setup

### 1. Create Project Structure

```bash
mkdir -p myapi/{app/{routers,models,schemas,services,db},tests}
cd myapi

# Create virtual environment
python3 -m venv .venv
source .venv/bin/activate

# Install dependencies
pip install fastapi uvicorn sqlalchemy asyncpg pydantic-settings pytest httpx
pip freeze > requirements.txt
```

### 2. Create CLAUDE.md for FastAPI Context

```markdown
# Project: MyAPI

Python 3.12 FastAPI application with async SQLAlchemy.

## Stack
- FastAPI 0.115
- SQLAlchemy 2.0 with async engine (asyncpg)
- Pydantic v2 for schemas
- Alembic for migrations
- pytest + httpx for testing

## Conventions
- All route handlers must be async
- Use dependency injection for database sessions
- Pydantic models: FooCreate (input), FooResponse (output), FooUpdate (partial)
- All endpoints return typed responses, never raw dicts
- Use HTTPException with detail messages, not generic 500s
- Router files: one per resource in app/routers/
- Tests mirror source structure in tests/
```

### 3. Set Up Base Application

```python
# app/main.py
from fastapi import FastAPI
from contextlib import asynccontextmanager
from app.db.session import engine, Base

@asynccontextmanager
async def lifespan(app: FastAPI):
    # Startup
    async with engine.begin() as conn:
        await conn.run_sync(Base.metadata.create_all)
    yield
    # Shutdown
    await engine.dispose()

app = FastAPI(
    title="MyAPI",
    version="1.0.0",
    lifespan=lifespan,
)
```

### 4. Verify

```bash
claude --print "Read app/main.py and suggest improvements based on FastAPI best practices"
# Expected output:
# Suggestions for middleware, CORS, exception handlers, etc.
```

## Usage Example

Generate a complete CRUD resource with Claude Code:

```bash
claude

> Generate a complete "Product" resource for our FastAPI app:
> - SQLAlchemy async model with id, name, description, price, stock, created_at
> - Pydantic schemas for create, update, and response
> - Async CRUD service layer
> - Router with GET (list + detail), POST, PUT, DELETE
> - Pytest tests using httpx AsyncClient
```

Claude Code generates the model:

```python
# app/models/product.py
from datetime import datetime
from sqlalchemy import String, Text, Numeric, Integer, DateTime, func
from sqlalchemy.orm import Mapped, mapped_column
from app.db.session import Base

class Product(Base):
    __tablename__ = "products"

    id: Mapped[int] = mapped_column(primary_key=True, index=True)
    name: Mapped[str] = mapped_column(String(255), nullable=False, index=True)
    description: Mapped[str | None] = mapped_column(Text, nullable=True)
    price: Mapped[float] = mapped_column(Numeric(10, 2), nullable=False)
    stock: Mapped[int] = mapped_column(Integer, default=0)
    created_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), server_default=func.now()
    )
```

Schemas with Pydantic v2:

```python
# app/schemas/product.py
from datetime import datetime
from pydantic import BaseModel, ConfigDict, Field

class ProductCreate(BaseModel):
    name: str = Field(..., min_length=1, max_length=255)
    description: str | None = None
    price: float = Field(..., gt=0)
    stock: int = Field(default=0, ge=0)

class ProductUpdate(BaseModel):
    name: str | None = Field(None, min_length=1, max_length=255)
    description: str | None = None
    price: float | None = Field(None, gt=0)
    stock: int | None = Field(None, ge=0)

class ProductResponse(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: int
    name: str
    description: str | None
    price: float
    stock: int
    created_at: datetime
```

Router with async handlers:

```python
# app/routers/products.py
from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy.ext.asyncio import AsyncSession
from app.db.session import get_session
from app.schemas.product import ProductCreate, ProductUpdate, ProductResponse
from app.services.product import ProductService

router = APIRouter(prefix="/products", tags=["products"])

@router.get("", response_model=list[ProductResponse])
async def list_products(
    skip: int = Query(0, ge=0),
    limit: int = Query(20, ge=1, le=100),
    db: AsyncSession = Depends(get_session),
):
    service = ProductService(db)
    return await service.list(skip=skip, limit=limit)

@router.get("/{product_id}", response_model=ProductResponse)
async def get_product(
    product_id: int,
    db: AsyncSession = Depends(get_session),
):
    service = ProductService(db)
    product = await service.get(product_id)
    if not product:
        raise HTTPException(status_code=404, detail="Product not found")
    return product

@router.post("", response_model=ProductResponse, status_code=201)
async def create_product(
    data: ProductCreate,
    db: AsyncSession = Depends(get_session),
):
    service = ProductService(db)
    return await service.create(data)
```

Test file:

```python
# tests/test_products.py
import pytest
from httpx import ASGITransport, AsyncClient
from app.main import app

@pytest.fixture
async def client():
    transport = ASGITransport(app=app)
    async with AsyncClient(transport=transport, base_url="http://test") as ac:
        yield ac

@pytest.mark.anyio
async def test_create_product(client):
    response = await client.post("/products", json={
        "name": "Widget", "price": 9.99, "stock": 100
    })
    assert response.status_code == 201
    data = response.json()
    assert data["name"] == "Widget"
    assert data["price"] == 9.99
```

## Common Issues

- **"async generator" errors in route handlers:** Ensure your database session dependency uses `async_sessionmaker` and `async with` pattern, not synchronous Session.
- **Pydantic v2 validation errors:** If migrating from v1, add `model_config = ConfigDict(from_attributes=True)` to replace `orm_mode = True`.
- **Tests hanging on database operations:** Use a separate test database URL and ensure `get_session` dependency is properly overridden in test fixtures.

## Why This Matters

Claude Code generates FastAPI resources 5x faster than writing manually, including tests and proper type annotations. A complete CRUD resource that typically takes 45 minutes is ready in under 10 minutes.



**Set it up →** Build your permission config with our [Permission Configurator](/permissions/).

## Related Guides

**Try it:** Paste your error into our [Error Diagnostic](/diagnose/) for an instant fix.

- [Claude Code for Hono Framework Workflow Guide](/claude-code-for-hono-framework-workflow-guide/)
- [Claude Code Skills for Scientific Python NumPy SciPy](/claude-code-skills-for-scientific-python-numpy-scipy/)
- [Claude Code for Test-Driven Development Workflow](/claude-code-for-test-driven-development-workflow-tutorial/)


## Frequently Asked Questions

### What is the minimum setup required?

You need Claude Code installed (Node.js 18+), a project with a `CLAUDE.md` file, and the relevant toolchain for your project type (e.g., npm for JavaScript, pip for Python). The CLAUDE.md file should describe your project structure, conventions, and common commands so Claude Code can work effectively.

### How long does the initial setup take?

For a typical project, initial setup takes 10-20 minutes. This includes creating the CLAUDE.md file, configuring `.claude/settings.json` for permissions, and running a test task to verify everything works. Subsequent sessions start immediately because the configuration persists.

### Can I use this with a team?

Yes. Commit your `.claude/` directory and `CLAUDE.md` to version control so the entire team uses the same configuration. Each developer can add personal preferences in `~/.claude/settings.json` (user-level) without affecting the project configuration. Review CLAUDE.md changes in pull requests like any other configuration file.

### What if Claude Code produces incorrect output?

First check that your CLAUDE.md accurately describes your project conventions. Incorrect or outdated context is the most common cause of wrong output. If the output is still wrong, provide feedback in the same session — Claude Code learns from corrections within a conversation. For persistent issues, add explicit rules to CLAUDE.md (e.g., "Always use single quotes" or "Never modify files in the config/ directory").


## Best Practices

1. **Start with a clear CLAUDE.md.** Describe your project structure, tech stack, coding conventions, and common commands in under 300 words. This single file has the largest impact on Claude Code's accuracy and efficiency.

2. **Use skills for domain knowledge.** Move detailed reference information (API routes, database schemas, deployment procedures) into `.claude/skills/` files. This keeps CLAUDE.md concise while making specialized knowledge available when needed.

3. **Review changes before committing.** Always run `git diff` after Claude Code makes changes. Verify the edits are correct, match your project style, and do not introduce unintended side effects. This habit prevents compounding errors across sessions.

4. **Set up permission guardrails.** Configure `.claude/settings.json` with explicit allow and deny lists. Allow your standard development commands (test, build, lint) and deny destructive operations (rm -rf, git push --force, database drops).

5. **Keep sessions focused.** Give Claude Code one clear task per prompt. Multi-step requests like "refactor auth, add tests, and update docs" produce better results when broken into three separate prompts, each building on the previous result.


<script type="application/ld+json">
{
  "@context": "https://schema.org",
  "@type": "FAQPage",
  "mainEntity": [
    {
      "@type": "Question",
      "name": "What is the minimum setup required?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "You need Claude Code installed (Node.js 18+), a project with a CLAUDE.md file, and the relevant toolchain for your project type (e.g., npm for JavaScript, pip for Python). The CLAUDE.md file should describe your project structure, conventions, and common commands so Claude Code can work effectively."
      }
    },
    {
      "@type": "Question",
      "name": "How long does the initial setup take?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "For a typical project, initial setup takes 10-20 minutes. This includes creating the CLAUDE.md file, configuring .claude/settings.json for permissions, and running a test task to verify everything works. Subsequent sessions start immediately because the configuration persists."
      }
    },
    {
      "@type": "Question",
      "name": "Can I use this with a team?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "Yes. Commit your .claude/ directory and CLAUDE.md to version control so the entire team uses the same configuration. Each developer can add personal preferences in ~/.claude/settings.json (user-level) without affecting the project configuration."
      }
    },
    {
      "@type": "Question",
      "name": "What if Claude Code produces incorrect output?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "First check that your CLAUDE.md accurately describes your project conventions. Incorrect or outdated context is the most common cause of wrong output. If the output is still wrong, provide feedback in the same session — Claude Code learns from corrections within a conversation."
      }
    }
  ]
}
</script>
