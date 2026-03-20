---
layout: default
title: "Claude Code Python SDK Package Guide"
description: "A practical guide to building and publishing Python SDK packages with Claude Code. Learn setup, structure, and best practices for developers."
date: 2026-03-14
author: "Claude Skills Guide"
permalink: /claude-code-python-sdk-package-guide/
reviewed: true
score: 7
categories: [guides]
tags: [claude-code, claude-skills]
---

{% raw %}
# Claude Code Python SDK Package Guide

Building a Python SDK package for Claude Code opens up powerful automation possibilities. This guide walks you through creating, structuring, and publishing a Python package that integrates with Claude Code workflows — from the initial project scaffold through testing, publishing, and versioning best practices that real-world SDK consumers expect.

## Why Build a Python SDK for Claude Code

Before writing any code, it helps to be clear about what a Claude Code Python SDK does versus what Claude Code itself does. Claude Code is the AI assistant running in your terminal. An SDK package is a reusable library that other developers install into their own projects to interact with AI APIs, wrap Claude Code functionality, or automate workflows that would otherwise require manual prompting.

Common reasons to build one:

- **Internal tooling**: Your team wants a shared library with company-specific prompting conventions baked in
- **Domain-specific wrappers**: You are building a code review tool, documentation generator, or test scaffolder that uses Claude under the hood
- **Pipeline integration**: You want a Python API that can be imported into CI/CD scripts, data pipelines, or backend services
- **Open source contribution**: You have built something reusable and want to share it on PyPI

Each of these use cases benefits from proper package structure, clean interfaces, and thorough testing.

## Setting Up Your Python SDK Project

Before diving into code, ensure you have Python 3.9+ and the latest version of Claude Code installed. Create a new directory for your SDK and initialize it with proper tooling.

```bash
mkdir claude-sdk-mypackage && cd claude-sdk-mypackage
python3 -m venv venv
source venv/bin/activate
```

The foundation of any Claude Code Python SDK begins with a well-structured `pyproject.toml` file. This configuration defines your package metadata, dependencies, and build settings.

```toml
[build-system]
requires = ["setuptools>=61.0", "wheel"]
build-backend = "setuptools.build_meta"

[project]
name = "claude-sdk-mypackage"
version = "0.1.0"
description = "SDK for extending Claude Code workflows"
requires-python = ">=3.9"
dependencies = [
    "requests>=2.28.0",
    "pydantic>=2.0.0",
]

[project.optional-dependencies]
dev = ["pytest", "black", "mypy"]
```

One thing worth noting: the `[project.optional-dependencies]` section with a `dev` group is the modern way to handle development-only dependencies. Users who install your package with `pip install claude-sdk-mypackage` get only the runtime dependencies. Developers who clone the repo and run `pip install -e ".[dev]"` get everything they need to contribute.

## Core Package Structure

Organize your SDK with a clean, modular structure. The `src` layout prevents import issues and follows modern Python packaging best practices.

```
claude-sdk-mypackage/
├── src/
│   └── mypackage/
│       ├── __init__.py
│       ├── client.py
│       ├── models.py
│       ├── exceptions.py
│       └── utils.py
├── tests/
│   ├── __init__.py
│   ├── conftest.py
│   └── test_client.py
├── pyproject.toml
└── README.md
```

The `src` directory layout has an important benefit: it prevents you from accidentally importing your local package directory instead of the installed version during testing. Without `src`, Python can pick up the local folder even when you think you are testing the installed package.

The `__init__.py` should expose your public API clearly. Clients should only import what they need directly from your package root.

```python
# src/mypackage/__init__.py
from .client import ClaudeClient
from .models import Request, Response
from .exceptions import ClaudeAPIError, RateLimitError

__all__ = ["ClaudeClient", "Request", "Response", "ClaudeAPIError", "RateLimitError"]
__version__ = "0.1.0"
```

Explicit `__all__` definitions are important for SDK packages. They tell `from mypackage import *` what to expose, but more importantly, they signal to documentation generators and IDE tooling what your intended public surface area is.

## Designing Good Exception Classes

A well-designed SDK does not leak raw HTTP errors or unstructured exceptions to its users. Create a hierarchy of custom exceptions in `exceptions.py`:

```python
# src/mypackage/exceptions.py

class ClaudeSDKError(Exception):
    """Base exception for all SDK errors."""
    pass

class ClaudeAPIError(ClaudeSDKError):
    """Raised when the API returns a non-2xx response."""
    def __init__(self, status_code: int, message: str):
        self.status_code = status_code
        self.message = message
        super().__init__(f"API error {status_code}: {message}")

class RateLimitError(ClaudeAPIError):
    """Raised when the API returns a 429 response."""
    def __init__(self, retry_after: int = None):
        self.retry_after = retry_after
        super().__init__(429, "Rate limit exceeded")

class AuthenticationError(ClaudeSDKError):
    """Raised when the API key is invalid or missing."""
    pass
```

This hierarchy lets SDK users catch errors at whatever level of granularity they need:

```python
try:
    result = client.complete("Hello")
except RateLimitError as e:
    time.sleep(e.retry_after or 60)
except ClaudeAPIError as e:
    logger.error("API error %s: %s", e.status_code, e.message)
except ClaudeSDKError:
    logger.exception("Unexpected SDK error")
```

## Building the Client Interface

A reliable SDK needs a clean client interface. Use type hints throughout and use pydantic for request/response validation. This approach catches errors early and provides excellent IDE support.

```python
# src/mypackage/client.py
from typing import Optional
from pydantic import BaseModel
import requests
from .exceptions import ClaudeAPIError, RateLimitError, AuthenticationError

class ClaudeClient:
    def __init__(self, api_key: str, base_url: str = "https://api.claude.ai"):
        self.api_key = api_key
        self.base_url = base_url
        self.session = requests.Session()
        self.session.headers.update({"Authorization": f"Bearer {api_key}"})

    def complete(self, prompt: str, model: str = "claude-3") -> str:
        response = self.session.post(
            f"{self.base_url}/v1/completions",
            json={"prompt": prompt, "model": model}
        )
        self._handle_response_errors(response)
        return response.json()["completion"]

    def _handle_response_errors(self, response):
        if response.status_code == 401:
            raise AuthenticationError("Invalid or missing API key")
        if response.status_code == 429:
            retry_after = int(response.headers.get("Retry-After", 60))
            raise RateLimitError(retry_after=retry_after)
        if response.status_code >= 400:
            raise ClaudeAPIError(response.status_code, response.text)
```

This pattern works well for basic integrations. For more complex workflows, consider adding connection pooling, retry logic, and async support using `httpx` or `aiohttp`.

## Adding Retry Logic

Production SDKs need retry logic for transient failures. A simple exponential backoff implementation handles the common cases:

```python
import time
from functools import wraps
from typing import Callable, TypeVar

T = TypeVar("T")

def with_retry(max_attempts: int = 3, backoff_base: float = 2.0):
    """Decorator that retries on transient API errors."""
    def decorator(func: Callable[..., T]) -> Callable[..., T]:
        @wraps(func)
        def wrapper(*args, **kwargs) -> T:
            last_error = None
            for attempt in range(max_attempts):
                try:
                    return func(*args, **kwargs)
                except RateLimitError as e:
                    wait = e.retry_after or (backoff_base ** attempt)
                    time.sleep(wait)
                    last_error = e
                except ClaudeAPIError as e:
                    if e.status_code >= 500:
                        time.sleep(backoff_base ** attempt)
                        last_error = e
                    else:
                        raise
            raise last_error
        return wrapper
    return decorator
```

Apply it to the client methods where retries make sense:

```python
class ClaudeClient:
    @with_retry(max_attempts=3)
    def complete(self, prompt: str, model: str = "claude-3") -> str:
        # ... existing implementation
```

## Integrating Claude Skills

Your SDK can use existing Claude skills to extend functionality. Skills like `frontend-design` help generate UI components, while `pdf` handles document processing. The `tdd` skill assists with test-driven development workflows.

```python
# Using skills within your SDK
def generate_tests(client: ClaudeClient, code: str) -> str:
    prompt = f"""Using the tdd skill pattern, generate unit tests for:
{code}

Follow pytest conventions and include setup/teardown."""
    return client.complete(prompt, model="claude-3-sonnet")
```

The `supermemory` skill enables persistent context across sessions. Your SDK can tap into this for maintaining conversation history or user preferences.

```python
def save_context(client: ClaudeClient, key: str, value: dict):
    """Store context using supermemory pattern."""
    client.session.post(
        f"{client.base_url}/v1/memory",
        json={"key": key, "value": value, "skill": "supermemory"}
    )
```

## Async Support with httpx

Many modern Python applications use `asyncio`, particularly FastAPI backends and async pipeline scripts. Providing an async client increases your SDK's usefulness significantly:

```python
import asyncio
from httpx import AsyncClient
from .exceptions import ClaudeAPIError, RateLimitError

class AsyncClaudeClient:
    def __init__(self, api_key: str, base_url: str = "https://api.claude.ai"):
        self.api_key = api_key
        self.base_url = base_url
        self._headers = {"Authorization": f"Bearer {api_key}"}

    async def complete(self, prompt: str, model: str = "claude-3") -> str:
        async with AsyncClient(headers=self._headers) as client:
            response = await client.post(
                f"{self.base_url}/v1/completions",
                json={"prompt": prompt, "model": model}
            )
            if response.status_code == 429:
                retry_after = int(response.headers.get("Retry-After", 60))
                raise RateLimitError(retry_after=retry_after)
            if response.status_code >= 400:
                raise ClaudeAPIError(response.status_code, response.text)
            return response.json()["completion"]

    async def complete_many(self, prompts: list[str]) -> list[str]:
        """Complete multiple prompts concurrently."""
        tasks = [self.complete(p) for p in prompts]
        return await asyncio.gather(*tasks)
```

The `complete_many` method shows a practical async advantage: you can fire off multiple completions concurrently rather than serially. For batch processing tasks, this can dramatically reduce wall clock time.

## Testing Your SDK

Comprehensive testing builds confidence. Use pytest with fixtures for mocking API responses.

```python
# tests/test_client.py
import pytest
import requests
from mypackage import ClaudeClient
from mypackage.exceptions import RateLimitError, AuthenticationError

@pytest.fixture
def mock_client(monkeypatch):
    class MockResponse:
        status_code = 200
        headers = {}
        text = ""

        def json(self):
            return {"completion": "test response"}
        def raise_for_status(self):
            pass

    def mock_post(self, url, json=None):
        return MockResponse()

    monkeypatch.setattr(requests.Session, "post", mock_post)
    return ClaudeClient(api_key="test-key")

def test_complete(mock_client):
    result = mock_client.complete("Hello")
    assert result == "test response"

def test_rate_limit_raises(monkeypatch):
    class RateLimitResponse:
        status_code = 429
        headers = {"Retry-After": "30"}
        text = "Rate limited"
        def json(self):
            return {}

    monkeypatch.setattr(requests.Session, "post", lambda *a, **kw: RateLimitResponse())
    client = ClaudeClient(api_key="test-key")
    with pytest.raises(RateLimitError) as exc_info:
        client.complete("Hello")
    assert exc_info.value.retry_after == 30

def test_auth_error_raises(monkeypatch):
    class AuthErrorResponse:
        status_code = 401
        headers = {}
        text = "Unauthorized"
        def json(self):
            return {}

    monkeypatch.setattr(requests.Session, "post", lambda *a, **kw: AuthErrorResponse())
    client = ClaudeClient(api_key="bad-key")
    with pytest.raises(AuthenticationError):
        client.complete("Hello")
```

Run tests with coverage reporting to ensure critical paths work correctly.

```bash
pytest --cov=mypackage --cov-report=html
```

Aim for coverage above 80% on the client and exception modules. The retry logic and error handling paths are the most important to test because they are the most likely to break under real-world conditions.

## Publishing Your Package

Once your SDK is ready, publishing to PyPI makes it available to the community. Create an account at pypi.org and install the necessary tools.

```bash
pip install build twine
python -m build
twine upload dist/*
```

For CI/CD publishing, use a GitHub Actions workflow that triggers on new version tags:

```yaml
# .github/workflows/publish.yml
name: Publish to PyPI

on:
  push:
    tags:
      - "v*"

jobs:
  publish:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-python@v5
        with:
          python-version: "3.11"
      - run: pip install build twine
      - run: python -m build
      - run: twine upload dist/*
        env:
          TWINE_USERNAME: __token__
          TWINE_PASSWORD: ${{ secrets.PYPI_TOKEN }}
```

Store your PyPI API token as a repository secret named `PYPI_TOKEN`. This keeps credentials out of your source code and lets the CI system publish on your behalf.

## Versioning and the CHANGELOG

Version management matters. Follow semantic versioning and document changes in a CHANGELOG. Users should understand what changed between versions.

The practical rule for semantic versioning:

- Increment the **patch** version (`0.1.0` → `0.1.1`) for bug fixes that do not change any public API
- Increment the **minor** version (`0.1.0` → `0.2.0`) for new features that are backward-compatible
- Increment the **major** version (`0.1.0` → `1.0.0`) for breaking changes to the public API

Keep a `CHANGELOG.md` at the project root. A minimal but useful format:

```markdown
## [0.2.0] - 2026-03-20
### Added
- AsyncClaudeClient for asyncio-based applications
- with_retry decorator for automatic backoff on transient errors

### Fixed
- RateLimitError now correctly reads the Retry-After header

## [0.1.0] - 2026-03-14
### Added
- Initial release with ClaudeClient and basic completion support
```

## Best Practices

Keep these principles in mind throughout development. Type hints improve discoverability and catch errors early. Document public APIs thoroughly using docstrings. Handle errors gracefully with meaningful exceptions rather than exposing raw API errors.

A few additional practices that separate polished SDKs from rough ones:

**Context managers**: Let users manage client lifecycle cleanly by implementing `__enter__` and `__exit__`:

```python
class ClaudeClient:
    def __enter__(self):
        return self

    def __exit__(self, exc_type, exc_val, exc_tb):
        self.session.close()
        return False
```

This enables `with ClaudeClient(api_key=...) as client:` usage, which ensures connections are properly closed.

**Logging, not print**: Use Python's `logging` module throughout your SDK. Users can configure the log level without modifying your code:

```python
import logging
logger = logging.getLogger(__name__)

class ClaudeClient:
    def complete(self, prompt: str, model: str = "claude-3") -> str:
        logger.debug("Sending completion request, model=%s", model)
        # ...
```

**Configuration from environment**: Allow API keys to come from environment variables so users do not need to pass them explicitly:

```python
import os

class ClaudeClient:
    def __init__(self, api_key: str = None, base_url: str = "https://api.claude.ai"):
        self.api_key = api_key or os.environ.get("CLAUDE_API_KEY")
        if not self.api_key:
            raise AuthenticationError("API key required. Pass api_key or set CLAUDE_API_KEY.")
```

## Conclusion

Building a Python SDK for Claude Code follows established patterns. Focus on clean interfaces, thorough testing, and good documentation. Use skills like `pdf` for document handling or `tdd` for generating tests automatically. Start simple, iterate based on user feedback, and publish when ready.

The Python ecosystem benefits from well-designed packages. Your SDK contributes to that ecosystem and enables others to build powerful Claude Code integrations without reinventing the authentication, retry, and error-handling logic you have already worked through.


## Related Reading

- [Claude Code Tutorials Hub](/claude-skills-guide/tutorials-hub/)
- [Best Claude Skills for Developers in 2026](/claude-skills-guide/best-claude-skills-for-developers-2026/)
- [Skill MD File Format Explained With Examples](/claude-skills-guide/claude-skill-md-format-complete-specification-guide/)
- [Claude Code Guides Hub](/claude-skills-guide/guides-hub/)

Built by theluckystrike — More at [zovo.one](https://zovo.one)
{% endraw %}
