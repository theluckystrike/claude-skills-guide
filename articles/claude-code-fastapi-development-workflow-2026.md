---
layout: post
title: "Claude Code for FastAPI Development Workflow 2026"
description: "Build FastAPI applications with Claude Code: endpoint generation, Pydantic models, async handlers, and OpenAPI spec automation with examples."
permalink: /claude-code-fastapi-development-workflow-2026/
date: 2026-04-21
last_tested: "2026-04-21"
render_with_liquid: false
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

## Related Guides

- [Claude Code for Hono Framework Workflow Guide](/claude-code-for-hono-framework-workflow-guide/)
- [Claude Code Skills for Scientific Python NumPy SciPy](/claude-code-skills-for-scientific-python-numpy-scipy/)
- [Claude Code for Test-Driven Development Workflow](/claude-code-for-test-driven-development-workflow-tutorial/)
