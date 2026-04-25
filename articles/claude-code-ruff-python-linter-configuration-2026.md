---
layout: default
title: "Claude Code for Ruff Python Linter (2026)"
permalink: /claude-code-ruff-python-linter-configuration-2026/
date: 2026-04-20
description: "Configure Ruff for Python projects with Claude Code. Replace Flake8, isort, and Black with a single Rust-powered linter that runs in milliseconds."
last_tested: "2026-04-22"
domain: "Python tooling"
---

## Why Claude Code for Ruff

Ruff is a Rust-powered Python linter and formatter that replaces Flake8, isort, pycodestyle, pydocstyle, pyupgrade, autoflake, and Black -- running 10-100x faster than any of them. With 800+ rules from 50+ plugins, Ruff's challenge is not speed but configuration: selecting the right rule sets for your project, handling legacy code migration from existing linters, configuring per-file overrides for tests vs source code, and integrating with pre-commit and CI without conflicts.

Claude Code generates Ruff configurations that match your existing Flake8/Black/isort setup, sets up incremental adoption for large codebases, and configures the formatter and linter to work together without conflicts.

## The Workflow

### Step 1: Install and Migrate from Existing Linters

```bash
# Install Ruff
pip install ruff
# or: brew install ruff

# Check current linter config to migrate
cat .flake8 setup.cfg pyproject.toml | grep -A 20 "\[flake8\]\|\[isort\]\|\[tool.black\]"

# Run Ruff with default rules to see baseline
ruff check . --statistics
```

### Step 2: Configure Ruff in pyproject.toml

```toml
# pyproject.toml — Complete Ruff configuration
[tool.ruff]
# Target Python version
target-version = "py312"

# Line length (matches Black default)
line-length = 88

# Files to include/exclude
include = ["*.py", "*.pyi"]
exclude = [
    ".git",
    ".venv",
    "__pycache__",
    "build",
    "dist",
    "migrations",    # Auto-generated Django/Alembic migrations
    "node_modules",
    "*.pb2.py",      # Protobuf generated code
    "*.pb2_grpc.py",
]

# Fix violations automatically where safe
fix = true

[tool.ruff.lint]
# Rule selection: comprehensive but pragmatic
select = [
    "E",    # pycodestyle errors
    "W",    # pycodestyle warnings
    "F",    # Pyflakes
    "I",    # isort
    "N",    # pep8-naming
    "UP",   # pyupgrade (modernize Python syntax)
    "B",    # flake8-bugbear (common bugs)
    "A",    # flake8-builtins (shadowing builtins)
    "C4",   # flake8-comprehensions
    "DTZ",  # flake8-datetimez (timezone-aware datetimes)
    "T20",  # flake8-print (no print statements in production)
    "SIM",  # flake8-simplify
    "TCH",  # flake8-type-checking (TYPE_CHECKING imports)
    "RUF",  # Ruff-specific rules
    "PTH",  # flake8-use-pathlib
    "ERA",  # eradicate (commented-out code)
    "PL",   # Pylint subset
    "PERF", # Perflint (performance anti-patterns)
    "FURB", # refurb (modern Python idioms)
    "S",    # flake8-bandit (security)
    "D",    # pydocstyle
    "ANN",  # flake8-annotations (type hints)
]

ignore = [
    "D100",   # Missing docstring in public module (too noisy)
    "D104",   # Missing docstring in public package
    "D203",   # One blank line before class docstring (conflicts with D211)
    "D213",   # Multi-line summary second line (conflicts with D212)
    "ANN101", # Missing type annotation for self
    "ANN102", # Missing type annotation for cls
    "S101",   # Use of assert (needed in tests)
    "PLR0913",# Too many arguments (sometimes unavoidable)
]

# Allow autofix for all enabled rules
fixable = ["ALL"]
unfixable = []

[tool.ruff.lint.per-file-ignores]
# Tests: relax rules that conflict with test patterns
"tests/**/*.py" = [
    "S101",    # assert is fine in tests
    "D",       # No docstring requirements in tests
    "ANN",     # No type annotation requirements in tests
    "T20",     # print() allowed in tests
    "PLR2004", # Magic values OK in tests
]
# Migrations: auto-generated, skip most rules
"migrations/**/*.py" = ["ALL"]
# CLI scripts: print is expected
"scripts/**/*.py" = ["T20"]
# __init__.py: unused imports are re-exports
"__init__.py" = ["F401"]

[tool.ruff.lint.isort]
known-first-party = ["mypackage"]
combine-as-imports = true
force-sort-within-sections = true

[tool.ruff.lint.pydocstyle]
convention = "google"

[tool.ruff.lint.pylint]
max-args = 8

[tool.ruff.format]
# Formatter settings (replaces Black)
quote-style = "double"
indent-style = "space"
skip-magic-trailing-comma = false
line-ending = "auto"
docstring-code-format = true
docstring-code-line-length = 72
```

### Step 3: Set Up Pre-Commit and CI

```yaml
# .pre-commit-config.yaml
repos:
  - repo: https://github.com/astral-sh/ruff-pre-commit
    rev: v0.8.0
    hooks:
      - id: ruff
        args: [--fix]
      - id: ruff-format
```

```yaml
# .github/workflows/lint.yml
name: Lint
on: [push, pull_request]
jobs:
  ruff:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: astral-sh/ruff-action@v2
        with:
          args: check --output-format=github
      - uses: astral-sh/ruff-action@v2
        with:
          args: format --check
```

### Step 4: Verify

```bash
# Check for violations
ruff check .

# Format code
ruff format .

# Check formatting without modifying files
ruff format --check .

# Show statistics of violations
ruff check . --statistics

# Fix all auto-fixable violations
ruff check . --fix

# Show diff of what format would change
ruff format --diff .
```

## CLAUDE.md for Ruff Python Linting

```markdown
# Ruff Python Linter Standards

## Domain Rules
- Ruff replaces Flake8, isort, Black, pyupgrade, and autoflake
- Format then lint (ruff format, then ruff check --fix)
- Tests have relaxed rules (no docstrings, assert allowed, no type annotations)
- Auto-generated files (migrations, protobuf) are excluded entirely
- All new code must have type annotations (ANN rules)
- All public functions must have Google-style docstrings (D rules)
- Security rules (S) enabled for production code

## File Patterns
- pyproject.toml (Ruff configuration)
- .pre-commit-config.yaml (pre-commit hooks)
- .github/workflows/lint.yml (CI integration)

## Common Commands
- ruff check . (lint)
- ruff check . --fix (auto-fix)
- ruff format . (format)
- ruff format --check . (verify formatting)
- ruff check . --statistics (violation summary)
- ruff rule RULE_CODE (explain a rule)
- ruff linter (list available linters)
```

## Common Pitfalls in Ruff Configuration

- **pydocstyle D203/D211 and D212/D213 conflicts:** These rule pairs are mutually exclusive. Claude Code ignores D203 and D213 to use the more common convention (no blank line before class docstring, summary on first line).

- **isort and formatter fighting:** Ruff's linter isort rules and formatter can conflict on import ordering. Claude Code ensures `force-sort-within-sections = true` in isort config and runs format before lint to avoid oscillation.

- **Blanket ignore instead of per-file:** Teams add broad `ignore` rules instead of `per-file-ignores` for test/migration exceptions. Claude Code uses per-file overrides to keep production code strict while relaxing test conventions.

## Related

- [Claude Code for Biome Formatter Setup](/claude-code-biome-formatter-setup-2026/)
- [Claude Code for Pkl Configuration Language](/claude-code-pkl-configuration-language-2026/)
- [Claude Code for mise Development Environment](/claude-code-mise-development-environment-2026/)
- [Claude Code for Biome — Workflow Guide](/claude-code-for-biome-linter-formatter-workflow-guide/)


## Frequently Asked Questions

### Do I need a paid Anthropic plan to use this?

Claude Code works with any Anthropic API plan, including the free tier. However, the free tier has lower rate limits (requests per minute and tokens per minute) that may slow down multi-step workflows. For professional use, the Build or Scale plan provides higher limits and priority access during peak hours.

### How does this affect token usage and cost?

The token cost depends on the size of your prompts and Claude's responses. Typical development tasks consume 10K-50K tokens per interaction. Using a CLAUDE.md file and skills reduces exploration tokens by 50-80%, which directly lowers costs. Monitor your usage at console.anthropic.com/settings/billing.

### Can I customize this for my specific project?

Yes. All Claude Code behavior can be customized through CLAUDE.md (project rules), `.claude/settings.json` (permissions), and `.claude/skills/` (domain knowledge). The most impactful customization is adding your project's specific patterns, conventions, and common commands to CLAUDE.md so Claude Code follows your standards from the start.

### What happens when Claude Code makes a mistake?

Claude Code creates files and edits through standard filesystem operations, so all changes are visible in `git diff`. If a change is wrong, revert it with `git checkout -- <file>` for a single file or `git stash` for all changes. Claude Code does not make irreversible changes unless you explicitly allow destructive commands in settings.json.


## Practical Details

When working with Claude Code on this topic, keep these implementation details in mind:

**Project Configuration.** Your CLAUDE.md should include specific references to how your project handles this area. Include file paths, naming conventions, and any project-specific patterns that differ from defaults. Claude Code reads this file at session start and uses it to guide all operations.

**Integration with Existing Tools.** Claude Code works alongside your existing development tools rather than replacing them. It respects .gitignore for file visibility, uses your project's installed dependencies, and follows the build/test scripts defined in package.json (or equivalent). Ensure your toolchain is working correctly before involving Claude Code.

**Performance Considerations.** For large codebases (10,000+ files), Claude Code's file scanning can be slow if not properly scoped. Use `.claudeignore` to exclude generated directories (dist, build, .next, coverage) and dependency directories (node_modules, vendor). This typically reduces scan time by 80-90%.

**Version Control Integration.** All changes Claude Code makes are regular filesystem operations visible to git. Use `git diff` after each significant change to review what was modified. For experimental changes, create a branch first with `git checkout -b experiment/topic` so you can easily discard or keep the results.


## Related Guides

- [Python Virtualenv Not Activated — Fix (2026)](/claude-code-python-virtualenv-not-activated-fix-2026/)
- [Migrate VBA Excel Macros to Python](/claude-code-vba-excel-macros-to-python-migration/)
- [Best AI Coding Tools for Python (2026)](/best-ai-coding-tools-python-comparison-2026/)
- [Claude Code For Rye Python](/claude-code-for-rye-python-project-workflow-guide/)

<script type="application/ld+json">
{
  "@context": "https://schema.org",
  "@type": "FAQPage",
  "mainEntity": [
    {
      "@type": "Question",
      "name": "Do I need a paid Anthropic plan to use this?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "Claude Code works with any Anthropic API plan, including the free tier. However, the free tier has lower rate limits (requests per minute and tokens per minute) that may slow down multi-step workflows. For professional use, the Build or Scale plan provides higher limits and priority access during peak hours."
      }
    },
    {
      "@type": "Question",
      "name": "How does this affect token usage and cost?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "The token cost depends on the size of your prompts and Claude's responses. Typical development tasks consume 10K-50K tokens per interaction. Using a CLAUDE.md file and skills reduces exploration tokens by 50-80%, which directly lowers costs. Monitor your usage at console.anthropic.com/settings/billing."
      }
    },
    {
      "@type": "Question",
      "name": "Can I customize this for my specific project?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "Yes. All Claude Code behavior can be customized through CLAUDE.md (project rules), `.claude/settings.json` (permissions), and `.claude/skills/` (domain knowledge). The most impactful customization is adding your project's specific patterns, conventions, and common commands to CLAUDE.md so Claude Code follows your standards from the start."
      }
    },
    {
      "@type": "Question",
      "name": "What happens when Claude Code makes a mistake?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "Claude Code creates files and edits through standard filesystem operations, so all changes are visible in `git diff`. If a change is wrong, revert it with `git checkout -- <file>` for a single file or `git stash` for all changes. Claude Code does not make irreversible changes unless you explicitly allow destructive commands in settings.json. When working with Claude Code on this topic, keep these implementation details in mind: **Project Configuration.** Your CLAUDE.md should include specific references to how your project handles this area. Include file paths, naming conventions, and any project-specific patterns that differ from defaults. Claude Code reads this file at session start and uses it to guide all operations. **Integration with Existing Tools.** Claude Code works alongside your existing development tools rather than replacing them. It respects .gitignore for file visibility, uses your project's installed dependencies, and follows the build/test scripts defined in package.json (or equivalent). Ensure your toolchain is working correctly before involving Claude Code. **Performance Considerations.** For large codebases (10,000+ files), Claude Code's file scanning can be slow if not properly scoped. Use `.claudeignore` to exclude generated directories (dist, build, .next, coverage) and dependency directories (node_modules, vendor). This typically reduces scan time by 80-90%. **Version Control Integration.** All changes Claude Code makes are regular filesystem operations visible to git. Use `git diff` after each significant change to review what was modified. For experimental changes, create a branch first with `git checkout -b experiment/topic` so you can easily discard or keep the results."
      }
    }
  ]
}
</script>
