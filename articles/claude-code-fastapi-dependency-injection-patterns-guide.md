---

layout: default
title: "Claude Code FastAPI Dependency (2026)"
description: "A comprehensive guide to implementing dependency injection in FastAPI using Claude Code. Learn practical patterns, code examples, and best practices."
date: 2026-03-14
last_modified_at: 2026-04-17
author: "Claude Skills Guide"
permalink: /claude-code-fastapi-dependency-injection-patterns-guide/
categories: [guides]
tags: [claude-code, claude-skills]
reviewed: true
score: 7
geo_optimized: true
---


Claude Code FastAPI Dependency Injection Patterns Guide

FastAPI's dependency injection system is one of its most powerful features, enabling clean architecture and testable code. When combined with Claude Code, you can rapidly implement solid dependency injection patterns that follow best practices. This guide walks you through practical examples and actionable patterns you can apply immediately to your Python APIs.

## Understanding FastAPI Dependency Injection

FastAPI's dependency injection system allows you to declare dependencies at the route level, and FastAPI automatically resolves them for each request. This pattern promotes loose coupling, improves testability, and makes your code more maintainable.

The foundation of FastAPI's DI system is the `Depends()` function. It lets you define dependencies that FastAPI will execute before your route handler, automatically injecting the results into your function parameters.

What makes FastAPI's approach distinctive compared to frameworks like Django or Flask is that dependencies are resolved at the function signature level using Python type hints. FastAPI inspects your route handler's parameters, sees that one uses `Depends()`, and knows to call that dependency function first. passing its return value into your handler. This happens transparently on every request, with caching behavior you can control.

FastAPI also caches dependency results within a single request by default. If two route parameters depend on the same function, it only runs once per request. You can disable this with `use_cache=False` in `Depends()` when you need fresh state each time.

## Basic Dependency Injection Patterns

## Simple Dependency with Depends

The most straightforward pattern is creating a reusable dependency function that returns a value used by your route handler:

```python
from fastapi import FastAPI, Depends

app = FastAPI()

def get_database_url():
 return "postgresql://localhost/mydb"

@app.get("/items")
async def read_items(db_url: str = Depends(get_database_url)):
 return {"database": db_url}
```

This pattern separates configuration from your route logic. When testing, you can easily override `get_database_url` with a test database.

## Generator-Based Dependencies with Cleanup

For resources that need proper cleanup. database sessions, file handles, HTTP clients. use generator dependencies. FastAPI executes code before the `yield` on the way in, and code after the `yield` on the way out, even if an exception occurs:

```python
from fastapi import Depends
from sqlalchemy.ext.asyncio import AsyncSession, create_async_engine
from sqlalchemy.orm import sessionmaker

DATABASE_URL = "postgresql+asyncpg://user:password@localhost/mydb"
engine = create_async_engine(DATABASE_URL)
AsyncSessionLocal = sessionmaker(engine, class_=AsyncSession, expire_on_commit=False)

async def get_db() -> AsyncSession:
 async with AsyncSessionLocal() as session:
 try:
 yield session
 await session.commit()
 except Exception:
 await session.rollback()
 raise

@app.post("/users")
async def create_user(user_data: dict, db: AsyncSession = Depends(get_db)):
 user = User(user_data)
 db.add(user)
 # commit happens automatically in the dependency cleanup
 return user
```

This pattern ensures your session is always closed and transactions are always committed or rolled back, regardless of what happens in your route handler.

## Class-Based Dependencies

For more complex dependencies, use classes. FastAPI will instantiate them and handle async properly:

```python
from fastapi import Depends

class DatabaseConnection:
 def __init__(self, config: dict):
 self.config = config
 self.connection = None

 async def connect(self):
 # Establish connection
 self.connection = await self.config["pool"].acquire()
 return self.connection

 async def disconnect(self):
 if self.connection:
 await self.config["pool"].release(self.connection)

def get_db(config: dict) -> DatabaseConnection:
 return DatabaseConnection(config)

@app.post("/users")
async def create_user(
 db: DatabaseConnection = Depends(get_db),
 user_data: dict = Body(...)
):
 conn = await db.connect()
 # Create user logic
```

Claude Code can help you scaffold these patterns quickly by understanding your project structure and generating appropriate class hierarchies.

A callable class (one with `__call__`) is particularly useful when you need to configure a dependency at startup and reuse the same instance across many routes:

```python
class RateLimiter:
 def __init__(self, max_requests: int, window_seconds: int):
 self.max_requests = max_requests
 self.window_seconds = window_seconds

 async def __call__(self, request: Request, redis: Redis = Depends(get_redis)):
 key = f"rate:{request.client.host}"
 count = await redis.incr(key)
 if count == 1:
 await redis.expire(key, self.window_seconds)
 if count > self.max_requests:
 raise HTTPException(429, detail="Too many requests")

api_rate_limiter = RateLimiter(max_requests=100, window_seconds=60)
strict_rate_limiter = RateLimiter(max_requests=10, window_seconds=60)

@app.get("/data", dependencies=[Depends(api_rate_limiter)])
async def get_data():
 return {"data": "..."}

@app.post("/sensitive-action", dependencies=[Depends(strict_rate_limiter)])
async def sensitive_action():
 return {"status": "ok"}
```

## Practical Dependency Patterns for Real Applications

## Authentication Dependencies

One of the most common use cases is implementing authentication:

```python
from fastapi import HTTPException, Security
from fastapi.security import HTTPBearer

security = HTTPBearer()

async def verify_token(token: str = Security(security)):
 if not token:
 raise HTTPException(status_code=403, detail="Missing token")

 # Validate token (JWT, API key, etc.)
 payload = await validate_jwt(token)
 if not payload:
 raise HTTPException(status_code=401, detail="Invalid token")

 return payload

@app.get("/protected-resource")
async def get_protected(
 user: dict = Depends(verify_token)
):
 return {"user": user["sub"], "data": "sensitive info"}
```

For role-based access control, layer your auth dependencies. First verify the token, then check permissions:

```python
from enum import Enum
from typing import List

class Role(str, Enum):
 admin = "admin"
 editor = "editor"
 viewer = "viewer"

async def get_current_user(token: str = Security(security)):
 payload = await validate_jwt(token.credentials)
 if not payload:
 raise HTTPException(status_code=401, detail="Invalid token")
 return payload

def require_roles(allowed_roles: List[Role]):
 async def role_checker(user: dict = Depends(get_current_user)):
 if user.get("role") not in allowed_roles:
 raise HTTPException(status_code=403, detail="Insufficient permissions")
 return user
 return role_checker

@app.delete("/articles/{article_id}")
async def delete_article(
 article_id: int,
 user: dict = Depends(require_roles([Role.admin, Role.editor]))
):
 await Article.delete(article_id)
 return {"deleted": article_id}
```

## Optional Dependencies with Default Values

Sometimes you need dependencies that are optional:

```python
from typing import Optional

async def get_cache():
 # Return cache client or None
 return CacheClient() if CACHE_ENABLED else None

@app.get("/items")
async def get_items(
 cache: Optional[CacheClient] = Depends(get_cache)
):
 if cache:
 cached = await cache.get("items")
 if cached:
 return cached

 items = await fetch_items_from_db()

 if cache:
 await cache.set("items", items, ttl=300)

 return items
```

## Parameterized Dependencies

For dependencies that need configuration, use factories:

```python
def create_rate_limiter(max_requests: int, window: int):
 async def rate_limiter(request: Request):
 client_id = request.client.host
 key = f"rate:{client_id}"

 count = await redis.get(key)
 if count and int(count) >= max_requests:
 raise HTTPException(429, "Too many requests")

 await redis.incr(key)
 await redis.expire(key, window)

 return True

 return rate_limiter

@app.post("/api/data")
async def create_data(
 rate_limit: bool = Depends(create_rate_limiter(100, 60))
):
 # Your endpoint logic
```

## Dependency-Driven Pagination

Pagination is a great candidate for a reusable dependency. Rather than repeating query parameter validation across dozens of routes, extract it once:

```python
from dataclasses import dataclass

@dataclass
class PaginationParams:
 page: int
 page_size: int
 offset: int

async def get_pagination(
 page: int = Query(default=1, ge=1),
 page_size: int = Query(default=20, ge=1, le=100)
) -> PaginationParams:
 return PaginationParams(
 page=page,
 page_size=page_size,
 offset=(page - 1) * page_size
 )

@app.get("/articles")
async def list_articles(
 pagination: PaginationParams = Depends(get_pagination),
 db: AsyncSession = Depends(get_db)
):
 result = await db.execute(
 select(Article)
 .offset(pagination.offset)
 .limit(pagination.page_size)
 )
 return result.scalars().all()
```

## Advanced Patterns for Production Systems

## DependencyOverrides for Testing

FastAPI provides a powerful testing mechanism through dependency overrides:

```python
from fastapi.testclient import TestClient
from fastapi import Depends

In your test file
def get_mock_db():
 return MockDatabase()

app.dependency_overrides[get_database_url] = get_mock_db

client = TestClient(app)
response = client.get("/items")
assert response.status_code == 200
```

With `pytest` and `httpx`, you can write async tests that override specific dependencies without touching others:

```python
import pytest
from httpx import AsyncClient

@pytest.fixture
def app_with_mock_db(app):
 async def mock_db():
 yield MockAsyncSession()

 app.dependency_overrides[get_db] = mock_db
 yield app
 app.dependency_overrides.clear()

@pytest.mark.asyncio
async def test_create_user(app_with_mock_db):
 async with AsyncClient(app=app_with_mock_db, base_url="http://test") as client:
 response = await client.post("/users", json={"name": "Alice"})
 assert response.status_code == 201
```

The `dependency_overrides` dict is global on the app object, so always clear it after tests to avoid state leaking between test cases.

## Nested Dependencies

Dependencies can depend on other dependencies, creating a clean hierarchy:

```python
async def get_current_user(token: str = Depends(verify_token)):
 return await fetch_user(token)

async def get_user_profile(user: dict = Depends(get_current_user)):
 profile = await fetch_profile(user["id"])
 return {"user": user, "profile": profile}

@app.get("/profile")
async def read_profile(
 data: dict = Depends(get_user_profile)
):
 return data
```

This pattern keeps each dependency focused on a single responsibility while composing complex behaviors.

FastAPI resolves nested dependencies in the correct order automatically. It builds a dependency graph, identifies what each function needs, and executes them in the right sequence. You never need to manually orchestrate this.

## Conditional Dependencies

Use dependency conditions for feature flags or environment-specific behavior:

```python
def get_storage_backend():
 if os.getenv("STORAGE") == "s3":
 return S3Storage()
 return LocalStorage()

@app.post("/upload")
async def upload_file(
 storage = Depends(get_storage_backend)
):
 # Upload using the appropriate backend
```

## Route-Level vs. Router-Level Dependencies

You can attach dependencies at different scopes. Route-level dependencies apply to one endpoint; router-level dependencies apply to all routes in a router:

```python
from fastapi import APIRouter

admin_router = APIRouter(
 prefix="/admin",
 dependencies=[Depends(require_roles([Role.admin]))]
)

@admin_router.get("/users")
async def list_all_users(db: AsyncSession = Depends(get_db)):
 # Only admins can reach this. enforced at the router level
 return await db.execute(select(User)).scalars().all()

@admin_router.delete("/users/{user_id}")
async def delete_user(user_id: int, db: AsyncSession = Depends(get_db)):
 # Also admin-only without repeating the dependency
 await db.execute(delete(User).where(User.id == user_id))
```

App-level dependencies can be set in the `FastAPI()` constructor, applying globally:

```python
app = FastAPI(dependencies=[Depends(log_request)])
```

This is ideal for cross-cutting concerns like request logging, correlation ID injection, or global rate limiting.

## Comparing Dependency Patterns

| Pattern | Use Case | Cleanup Support | Testability |
|---|---|---|---|
| Function dependency | Simple values, config | No | Easy override |
| Generator dependency | DB sessions, HTTP clients | Yes (yield) | Easy override |
| Class with `__call__` | Stateful, configurable limits | Optional | Instantiate with mock args |
| Factory function | Parameterized behavior | Depends on inner fn | Override factory result |
| Nested dependencies | Composed auth + profile | Inherited | Override any layer |
| Router-level | Shared auth for a group | N/A | Override once for all |

## How Claude Code Accelerates DI Workflows

Claude Code is particularly effective at FastAPI dependency injection work because DI patterns are highly structured and repetitive. You can describe your data model and ask Claude to scaffold a complete dependency chain:

- "Create a dependency that returns the current user's organization from the JWT claims, with a fallback for service accounts"
- "Add rate limiting to all routes under /api/v1 using Redis, with different limits for authenticated vs. unauthenticated users"
- "Write pytest fixtures that override the database and cache dependencies for unit tests"

Claude understands the relationship between `Depends()`, `Security()`, and `BackgroundTasks`, and can generate correct async generator patterns without you having to look up the exact syntax each time.

When you use Claude Code to refactor existing code toward better DI, give it the route file and ask it to extract repeated logic into reusable dependencies. It will identify patterns like repeated `db = get_db()` calls or copy-pasted auth checks and consolidate them correctly.

## Actionable Best Practices

1. Keep dependencies focused: Each dependency should do one thing well. Don't bundle multiple responsibilities in a single dependency.

2. Use async by default: Define your dependencies with `async def` unless they perform synchronous blocking operations.

3. Use type hints: FastAPI uses type hints to validate and convert data. Always include proper types.

4. Document dependencies: Add docstrings explaining what each dependency does and any side effects.

5. Test with overrides: Use FastAPI's `dependency_overrides` for comprehensive testing without mocking internals.

6. Handle cleanup properly: If your dependency allocates resources, consider using context managers or generator patterns for proper cleanup.

7. Use router-level dependencies for cross-cutting concerns: Authentication and logging belong at the router or app level, not repeated on every endpoint.

8. Prefer dataclasses for grouped parameters: When a route needs several related query params, wrap them in a dataclass dependency rather than listing them individually on the route.

## Conclusion

FastAPI's dependency injection system provides a solid foundation for building scalable Python APIs. By using these patterns with Claude Code's assistance, you can rapidly implement clean, testable, and maintainable code structures. Start with simple dependencies and gradually adopt more advanced patterns as your application grows in complexity.

The generator pattern with `yield` should be your default for any resource that needs cleanup. Router-level dependencies are the right tool for applying auth or logging to groups of endpoints without repetition. And `dependency_overrides` makes testing straightforward. you can swap out any dependency in the graph without restructuring your production code.

Remember that the key to successful dependency injection is maintaining clear boundaries between components while keeping your code flexible for testing and future modifications.


---


**Try it:** Estimate your monthly spend with our [Cost Calculator](/calculator/).
---

<div class="mastery-cta">

I'm a solo developer in Vietnam. 50K Chrome extension users. $500K+ on Upwork. 5 Claude Max subscriptions running agent fleets in parallel.

These are my actual CLAUDE.md templates, orchestration configs, and prompts. Not a course. Not theory. The files I copy into every project before I write a line of code.

**[See what's inside →](https://zovo.one/lifetime?utm_source=ccg&utm_medium=cta-default&utm_campaign=claude-code-fastapi-dependency-injection-patterns-guide)**

$99 once. Free forever. 47/500 founding spots left.

</div>

Related Reading

- [Claude Code for Beginners: Complete Getting Started Guide](/claude-code-for-beginners-complete-getting-started-2026/)
- [Best Claude Skills for Developers in 2026](/best-claude-skills-for-developers-2026/)
- [Claude Skills Guides Hub](/guides-hub/)
- [Claude Skill Dependency Injection Patterns](/claude-skill-dependency-injection-patterns/). If you are interested in applying DI concepts at the Claude skill level (composing pdf, xlsx, tdd, and other skills into pipelines), see this companion guide.

Built by theluckystrike. More at [zovo.one](https://zovo.one)


