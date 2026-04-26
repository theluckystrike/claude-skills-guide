---

layout: default
title: "Fix Claude Code Using Deprecated APIs (2026)"
description: "Stop Claude Code from generating deprecated API calls. Configure version pinning, add API docs to context, and enforce modern method usage patterns."
date: 2026-03-14
last_modified_at: 2026-04-17
last_tested: "2026-04-21"
author: "Claude Skills Guide"
categories: [troubleshooting]
tags: [claude-code, troubleshooting, deprecated-apis, code-quality, claude-skills]
permalink: /claude-code-keeps-using-deprecated-api-methods/
reviewed: true
score: 7
geo_optimized: true
---

> Note: This article addresses Claude Code *generating* deprecated third-party library methods in the code it writes for you (urllib, numpy, old JavaScript patterns, etc.). If you are looking to fix deprecated Anthropic API calls in your own integration code. such as migrating from `/v1/completions` to `/v1/messages`. see [Fixing Claude Code Deprecated API Methods](/claude-code-uses-deprecated-api-methods-fix/) instead.

One of the most common frustrations developers encounter when working with Claude Code is that it consistently generates code using deprecated API methods. Whether it's an outdated JavaScript method, a legacy Python function, or an old library version, Claude Code sometimes gravitates toward patterns it's seen more frequently in its training data, often older ones. This guide explains why this happens and provides concrete strategies to get Claude Code to use modern, non-deprecated APIs.

## Why Claude Code Defaults to Deprecated Methods

Claude Code's training data includes millions of code repositories spanning many years. Older patterns stick in the model's weights because they appeared frequently in the training corpus. When you ask for code without specifying version constraints, Claude Code often defaults to what it knows best, which is outdated.

Several factors contribute to this behavior. First, the model doesn't inherently know your project's dependency versions. If you don't specify that you're using Python 3.12 or Node.js 22, Claude Code might generate code compatible with older versions. Second, certain deprecated methods have modern replacements that look very similar, making it easy for the model to choose the wrong one. Third, some deprecated methods persist in long-standing codebases that the model has learned from extensively.

For example, you might ask Claude Code to write a simple HTTP request and receive code using `urllib.request.urlopen()` instead of `requests.get()`, or `http.client` instead of `httpx`. The model isn't being difficult, it genuinely doesn't know which library you prefer unless you tell it.

## Solution 1: Specify Your Dependency Versions Explicitly

The most effective fix is providing context about your project's technology stack. Include your dependency versions in the project context or CLAUDE.md file.

Create or update your project's CLAUDE.md with explicit version information:

```markdown
Project Context

Dependencies
- Python 3.12+
- FastAPI 0.109+
- Pydantic 2.5+
- httpx 0.26+ (NOT requests library)
- SQLAlchemy 2.0+

API Style
- Use async/await throughout
- Prefer dataclasses over Pydantic models where possible
- Use modern Python type hints with `|` union syntax, not `Union[]`
```

When you provide this context, Claude Code becomes significantly more accurate about choosing appropriate APIs. The model responds well to explicit constraints and will follow version specifications when they're clearly stated.

## Solution 2: Define a Deprecated Methods Rejection List

Create a skill or include a section in your CLAUDE.md that explicitly lists deprecated methods Claude Code should never use. This creates a persistent memory that carries across conversations.

```markdown
Code Standards

Never Use These Deprecated APIs

Python
- `urllib.request.urlopen` → Use `httpx.AsyncClient` or `aiohttp`
- `json.loads()` on strings → Use `orjson` or built-in `json.loads()` on bytes
- `datetime.datetime.utcnow()` → Use `datetime.datetime.now(timezone.utc)`
- `dict.keys()`, `dict.values()` for iteration → Iterate dict directly
- `np.int`, `np.float`, `np.bool` → Use `np.int64`, `np.float64`, etc.

JavaScript/TypeScript
- `Array.prototype.find()` returning index → Use `findIndex()`
- `Promise.prototype.done()` → Remove (was removed from spec)
- `Object.assign()` for shallow copy → Use spread operator `{...obj}`
- `require()` in ESM → Use `import`
- `__dirname`, `__filename` in ESM → Use `import.meta.url`
```

This approach works because Claude Code processes the CLAUDE.md file at the start of each conversation and treats the instructions as high-priority constraints.

## Solution 3: Use Correction Prompts With Modern Alternatives

When Claude Code uses a deprecated method, correct it immediately with the specific modern alternative. The key is being explicit about what to use instead.

Instead of:
```
Don't use that deprecated method.
```

Use:
```
Replace `urllib.request.urlopen()` with `httpx.AsyncClient.get()`. The project uses httpx for all HTTP requests. Here's the pattern:

```python
async with httpx.AsyncClient() as client:
 response = await client.get("https://api.example.com/data")
 return response.json()
```

This correction pattern works better because Claude Code learns from concrete examples. One specific correction with working code often sticks better than multiple vague warnings.

Solution 4: Create a Code Review Skill

Set up a dedicated skill that reviews generated code for deprecated API usage. This is especially useful for larger projects where you want consistent enforcement.

Create `skills/api-modernizer.md`:

```markdown
---
name: api-modernizer
description: Reviews code for deprecated API usage and suggests modern alternatives
trigger: always
---

## API Modernizer Review

Before outputting any code, check for these common deprecated patterns and replace them:

Python Corrections
| Deprecated | Use Instead |
|------------|-------------|
| `datetime.utcnow()` | `datetime.now(timezone.utc)` |
| `functools.lru_cache(maxsize=128)` | `functools.cache` (Python 3.9+) or specify size |
| `typing.Dict`, `typing.List` | `dict`, `list` (Python 3.9+) |
| `with urllib.request.urlopen()` | `async with httpx.AsyncClient()` |
| `xml.etree.ElementTree` | `lxml` for performance |

JavaScript Corrections
| Deprecated | Use Instead |
|------------|-------------|
| `module.exports` | `export default` / `export` |
| `require()` in Node | `import` with ESM |
| `Buffer()` | `Buffer.from()` |
| `__dirname` | `import.meta.url` + `fileURLToPath` |
| `process.env.NODE_ENV === 'development'` | `process.env.NODE_ENV !== 'production'` |

Apply these corrections to all code before presenting it.
```

Load this skill in your project with:
```
Load the api-modernizer skill for all code reviews.
```

Solution 5: Pin Library Versions in Dependencies

One root cause of Claude Code choosing deprecated methods is ambiguity about which version of a library you're using. Make your dependency files explicit and include them in context.

In your `requirements.txt` or `pyproject.toml`:

```
Always specify minimum versions for modern APIs
httpx>=0.26.0
fastapi>=0.109.0
pydantic>=2.5.0
```

In your `package.json`:

```json
{
 "dependencies": {
 "httpx": "^0.26.0",
 "fastapi": "^0.109.0"
 },
 "engines": {
 "node": ">=20.0.0"
 }
}
```

When Claude Code sees these files, it gains important context about available modern APIs.

Solution 6: Use Pre-Commit Hooks for Enforcement

For teams using Claude Code extensively, automate the detection of deprecated API usage with pre-commit hooks. This provides a safety net even when Claude Code occasionally slips up.

Create a `.pre-commit-config.yaml`:

```yaml
repos:
 - repo: https://github.com/pre-commit/pre-commit-hooks
 hooks:
 - id: check-merge-conflict
 - id: trailing-whitespace
 
 - repo: https://github.com/pycqa/isort
 hooks:
 - id: isort
 args: [--profile, black]
 
 - repo: https://github.com/astral-sh/ruff-pre-commit
 hooks:
 - id: ruff
 args: [--fix, --exit-non-zero-on-fix]
 - id: ruff-format
```

Configure ruff in `pyproject.toml` to catch deprecated Python APIs:

```toml
[tool.ruff.lint]
select = ["F", "E", "W", "PIE", "T20"]
ignore = ["E501"]

[tool.ruff.lint.per-file-ignores]
"__init__.py" = ["F401"]
```

This catches deprecated API usage at the commit stage, providing feedback that helps train better habits in subsequent Claude Code interactions.

Conclusion

Claude Code's tendency to use deprecated API methods stems from training data patterns and lack of explicit version context. By providing clear dependency information, creating rejection lists, using specific correction prompts, employing code review skills, and automating enforcement with pre-commit hooks, you can dramatically reduce this issue.

The most important takeaway: Claude Code needs explicit context about your project's modern stack. Without it, the model defaults to what it knows best, often older, more prevalent patterns in its training data. Help Claude Code help you by making your technology choices clear from the start.

---


**Try it:** Paste your error into our [Error Diagnostic](/diagnose/) for an instant fix.
---

<div class="mastery-cta">

I'm a solo developer in Vietnam. 50K Chrome extension users. $500K+ on Upwork. 5 Claude Max subscriptions running agent fleets in parallel.

These are my actual CLAUDE.md templates, orchestration configs, and prompts. Not a course. Not theory. The files I copy into every project before I write a line of code.

**[See what's inside →](https://zovo.one/lifetime?utm_source=ccg&utm_medium=cta-default&utm_campaign=claude-code-keeps-using-deprecated-api-methods)**

$99 once. Free forever. 47/500 founding spots left.

</div>

Related Reading

- [Fixing Claude Code Deprecated API Methods](/claude-code-uses-deprecated-api-methods-fix/). Migrate your own Anthropic API integrations away from deprecated endpoints and parameters
- [Claude Code for Beginners: Complete Getting Started Guide](/claude-code-for-beginners-complete-getting-started-2026/)
- [Claude Code Not Working After Update: How to Fix](/claude-code-not-working-after-update-how-to-fix/)
- [Claude Code Troubleshooting Hub](/troubleshooting-hub/)

Built by theluckystrike. More at [zovo.one](https://zovo.one)
```


