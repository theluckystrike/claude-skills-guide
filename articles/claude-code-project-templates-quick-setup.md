---
layout: default
title: "Claude Code Project Templates: Quick Setup for Any Stack (2026)"
description: "Ready-to-use Claude Code templates for 8 stacks: React/Next.js, Python/FastAPI, Rust, Go, Rails, Spring, Express, and React Native. CLAUDE.md + settings.json included."
date: 2026-04-26
author: "Claude Skills Guide"
permalink: /claude-code-project-templates-quick-setup/
reviewed: true
categories: [getting-started]
tags: [claude, claude-code, templates, project-setup, configuration]
---

# Claude Code Project Templates: Quick Setup for Any Stack

Every framework has different conventions, build tools, and file structures. A generic CLAUDE.md wastes tokens and misses framework-specific rules. These templates give you a stack-specific CLAUDE.md and settings.json you can drop into any project. Copy the template for your stack, customize the project-specific details, and start coding. Or use the [Project Starter](/starter/) to generate a customized version automatically.

## React / Next.js (App Router)

```markdown
# CLAUDE.md

## Stack
Next.js 15 App Router, TypeScript strict, Tailwind CSS, pnpm

## Commands
- `pnpm dev` -- dev server on :3000
- `pnpm build` -- production build
- `pnpm test` -- Vitest unit tests
- `pnpm e2e` -- Playwright end-to-end
- `pnpm lint` -- ESLint + Prettier check
- `pnpm typecheck` -- tsc --noEmit

## Rules
- Server components by default. "use client" only for interactivity.
- App Router file conventions: page.tsx, layout.tsx, loading.tsx, error.tsx
- Colocate tests: Component.test.tsx next to Component.tsx
- Use Zod for form validation, server actions for mutations
- Tailwind only -- no CSS modules, no styled-components
- Images via next/image with explicit width/height
```

```bash
# .claudeignore
node_modules/
.next/
dist/
coverage/
*.lock
public/og-images/
```

## Python / FastAPI

```markdown
# CLAUDE.md

## Stack
Python 3.12, FastAPI, SQLAlchemy 2.0, Alembic, pytest, uv

## Commands
- `uv run fastapi dev` -- dev server on :8000
- `uv run pytest` -- run test suite
- `uv run pytest --cov` -- tests with coverage
- `uv run ruff check .` -- linting
- `uv run ruff format .` -- formatting
- `uv run mypy src/` -- type checking

## Rules
- Type hints on all functions (params + return)
- Pydantic models for all request/response schemas
- Async endpoints by default: `async def endpoint()`
- Alembic for migrations: never edit models without migration
- Tests in tests/ mirroring src/ structure
- Dependencies via `uv add`, not pip install
```

```bash
# .claudeignore
__pycache__/
.venv/
*.pyc
.pytest_cache/
htmlcov/
*.egg-info/
dist/
```

## Rust / Axum

```markdown
# CLAUDE.md

## Stack
Rust 1.78+, Axum 0.7, SQLx, Tokio, cargo

## Commands
- `cargo run` -- start server
- `cargo test` -- run all tests
- `cargo clippy -- -D warnings` -- linting (treat warnings as errors)
- `cargo fmt --check` -- format check
- `cargo build --release` -- release build

## Rules
- Handle all Results explicitly. No .unwrap() in production code.
- Use thiserror for custom error types, anyhow for application errors.
- Async handlers return impl IntoResponse.
- SQL via SQLx compile-time checked queries.
- Tests use #[tokio::test] for async tests.
- Modules: one file per module, mod.rs for re-exports only.
```

```bash
# .claudeignore
target/
Cargo.lock
*.rlib
```

## Go / Gin

```markdown
# CLAUDE.md

## Stack
Go 1.22+, Gin, GORM, go test

## Commands
- `go run ./cmd/server` -- start server
- `go test ./...` -- run all tests
- `go vet ./...` -- static analysis
- `golangci-lint run` -- comprehensive linting
- `go build -o bin/server ./cmd/server` -- build binary

## Rules
- Error handling: check every error, no _ = err
- Interfaces in consumer package, implementations in provider
- Table-driven tests with t.Run subtests
- Context propagation: pass ctx as first parameter
- Struct tags: json, db, validate
- No init() functions. Explicit initialization only.
```

```bash
# .claudeignore
vendor/
bin/
*.exe
*.test
```

## Ruby / Rails

```markdown
# CLAUDE.md

## Stack
Ruby 3.3, Rails 7.2, PostgreSQL, RSpec, Tailwind

## Commands
- `bin/rails server` -- dev server on :3000
- `bin/rspec` -- run test suite
- `bin/rubocop` -- linting
- `bin/rails db:migrate` -- run migrations
- `bin/rails console` -- Rails console

## Rules
- Fat models, skinny controllers. Business logic in models/services.
- RSpec with FactoryBot. No fixtures.
- Strong params in every controller.
- Scopes over class methods for queries.
- Service objects in app/services/ for complex operations.
- Never edit existing migrations. Create new ones.
```

```bash
# .claudeignore
tmp/
log/
vendor/bundle/
node_modules/
public/assets/
coverage/
```

## Java / Spring Boot

```markdown
# CLAUDE.md

## Stack
Java 21, Spring Boot 3.3, Maven, JUnit 5, PostgreSQL

## Commands
- `./mvnw spring-boot:run` -- start server
- `./mvnw test` -- run tests
- `./mvnw verify` -- integration tests
- `./mvnw compile` -- compile only
- `./mvnw spotless:check` -- format check

## Rules
- Constructor injection only. No @Autowired on fields.
- DTOs for all API request/response. Never expose entities.
- @Transactional on service methods, not controllers.
- JUnit 5 + Mockito. @SpringBootTest for integration only.
- Lombok: @Data for DTOs, @Builder for complex objects.
- Package by feature, not by layer.
```

```bash
# .claudeignore
target/
.mvn/wrapper/maven-wrapper.jar
*.class
*.jar
```

## Node.js / Express

```markdown
# CLAUDE.md

## Stack
Node.js 22, Express 5, TypeScript, Prisma, Jest, pnpm

## Commands
- `pnpm dev` -- nodemon dev server
- `pnpm test` -- Jest tests
- `pnpm lint` -- ESLint
- `pnpm build` -- tsc compilation
- `pnpm prisma:generate` -- regenerate Prisma client

## Rules
- TypeScript strict mode. No any types.
- Express middleware pattern: (req, res, next)
- Prisma for all database operations. Raw SQL only for complex queries.
- Error handling via express-async-errors + central error handler.
- Validation with Zod schemas in src/validators/
- Environment vars via dotenv, accessed through src/config.ts only.
```

```bash
# .claudeignore
node_modules/
dist/
coverage/
prisma/generated/
*.lock
```

## React Native / Expo

```markdown
# CLAUDE.md

## Stack
React Native 0.74, Expo SDK 51, TypeScript, Zustand, React Navigation

## Commands
- `npx expo start` -- start Expo dev server
- `npx expo run:ios` -- run on iOS simulator
- `npx expo run:android` -- run on Android emulator
- `pnpm test` -- Jest tests
- `pnpm lint` -- ESLint

## Rules
- Functional components only. No class components.
- Zustand for state management. No Redux.
- React Navigation for routing. Type-safe navigation params.
- StyleSheet.create for all styles. No inline styles.
- Platform-specific code via .ios.tsx / .android.tsx suffixes.
- Use expo-image instead of React Native Image.
```

```bash
# .claudeignore
node_modules/
.expo/
ios/Pods/
android/.gradle/
android/app/build/
*.lock
```

## Using These Templates

1. Copy the CLAUDE.md and .claudeignore for your stack
2. Customize project-specific details (database names, API endpoints, team conventions)
3. Generate a matching settings.json with the [Project Starter](/starter/)
4. Commit all three files to your repository

## Try It Yourself

The [Project Starter](/starter/) generates customized versions of these templates. Select your stack, answer a few questions about your project specifics, and get a complete CLAUDE.md, .claudeignore, and settings.json -- ready to commit. It handles the edge cases these templates cannot cover, like monorepo configurations and custom build pipelines.

## Frequently Asked Questions

<details>
<summary>Can I combine templates for full-stack projects?</summary>
Yes. For a Next.js frontend with a FastAPI backend, merge the relevant sections from both templates. Put shared rules at the top and stack-specific rules under labeled sections. The <a href="/starter/">Project Starter</a> handles multi-stack configurations automatically.
</details>

<details>
<summary>How do I handle templates for monorepos?</summary>
Monorepos can have a root CLAUDE.md with shared conventions and per-package CLAUDE.md files with package-specific rules. Claude Code reads the nearest CLAUDE.md to the file being edited. See the <a href="/configuration/">Configuration Guide</a> for monorepo setup, or use the dedicated <a href="/claude-code-monorepo-setup-guide/">Monorepo Setup Guide</a>.
</details>

<details>
<summary>Should I include all the commands even if I rarely use some?</summary>
Include only commands you use regularly. Each command in CLAUDE.md adds context tokens to every session. If you run integration tests once a week, leave that command out and type it manually when needed. The <a href="/skill-finder/">Skill Finder</a> helps identify which commands matter most for your workflow.
</details>

<details>
<summary>Are these templates kept up to date with framework changes?</summary>
These templates reflect current versions as of April 2026. Framework updates may change CLI commands, file conventions, or best practices. Check the <a href="/best-practices/">Best Practices</a> page for updates, or regenerate your config with the <a href="/starter/">Project Starter</a>, which tracks framework version changes.
</details>

<script type="application/ld+json">
{
  "@context": "https://schema.org",
  "@type": "FAQPage",
  "mainEntity": [
    {
      "@type": "Question",
      "name": "Can I combine Claude Code templates for full-stack projects?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "Yes. Merge relevant sections from both templates. Put shared rules at the top and stack-specific rules under labeled sections. The Project Starter handles multi-stack configurations automatically."
      }
    },
    {
      "@type": "Question",
      "name": "How do I handle Claude Code templates for monorepos?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "Monorepos can have a root CLAUDE.md with shared conventions and per-package CLAUDE.md files with package-specific rules. Claude Code reads the nearest CLAUDE.md to the file being edited."
      }
    },
    {
      "@type": "Question",
      "name": "Should I include all commands in CLAUDE.md even if I rarely use some?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "Include only commands you use regularly. Each command adds context tokens to every session. Leave rarely-used commands out and type them manually when needed."
      }
    },
    {
      "@type": "Question",
      "name": "Are Claude Code project templates kept up to date?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "These templates reflect current versions as of April 2026. Regenerate your config with the Project Starter, which tracks framework version changes."
      }
    }
  ]
}
</script>

## Related Guides

- [Project Starter](/starter/) -- Generate customized templates for your specific project
- [CLAUDE.md Generator](/generator/) -- Create optimized CLAUDE.md files interactively
- [Configuration Guide](/configuration/) -- Full settings.json and .claudeignore reference
- [Skill Finder](/skill-finder/) -- Discover which Claude Code skills fit your workflow
- [Best Practices](/best-practices/) -- General guidelines across all stacks
