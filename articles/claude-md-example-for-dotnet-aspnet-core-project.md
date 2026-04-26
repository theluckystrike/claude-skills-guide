---
layout: default
title: "Claude Md Example For Dotnet Aspnet (2026)"
description: "Practical guide to creating Claude skill files for .NET ASPNET Core projects. Includes real examples, patterns, and integration tips."
date: 2026-03-14
last_modified_at: 2026-04-17
author: "Claude Skills Guide"
permalink: /claude-md-example-for-dotnet-aspnet-core-project/
categories: [guides]
reviewed: true
score: 7
tags: [claude-code, claude-skills]
geo_optimized: true
---
Creating effective Claude skill files for .NET ASP.NET Core projects requires understanding both the skill format and how Claude Code processes .NET-specific workflows. This guide provides practical examples you can adapt immediately.

## The Claude Skill Format

Claude skills are Markdown files with a specific structure that Claude reads when you invoke them. For .NET projects, these skills help Claude understand your tooling, conventions, and preferred patterns.

A basic skill file follows this structure:

```markdown
Skill Name

Description
Brief description of what this skill does.

When to Use
Situations where this skill applies.

Guidelines
- Specific instruction 1
- Specific instruction 2
```

The skill loads when you type `/skillname` in Claude Code, making these instructions part of the AI's context for your session.

## ASP.NET Core API Skill

For an ASP.NET Core Web API project, create a skill that guides Claude through your preferred patterns. Save this as `~/.claude/skills/dotnet-api.md`:

```markdown
dotnet-api

Description
Guides Claude through ASP.NET Core Web API development following my team's conventions.

When to Use
- Creating new API controllers
- Adding endpoints to existing controllers
- Working with Entity Framework Core
- Implementing authentication/authorization

Guidelines

Controller Structure
- Use attribute routing exclusively
- Return ActionResult<T> for flexible responses
- Include XML documentation for public APIs
- Follow RESTful naming conventions

Dependency Injection
- Inject services through constructors
- Use interfaces for service abstractions
- Register services in Program.cs with proper lifetimes

Error Handling
- Use problem details for error responses
- Implement exception middleware for global handling
- Return appropriate HTTP status codes

Testing
- Use the tdd skill for test-first development
- Write integration tests using WebApplicationFactory
- Mock external dependencies with Moq or NSubstitute
```

To use this skill, type `/dotnet-api` in your Claude session, then describe what you need. Claude will apply your conventions throughout the task.

## Entity Framework Core Skill

Database interactions deserve their own skill. Create `~/.claude/skills/efcore.md`:

```markdown
efcore

Description
Guides Entity Framework Core operations with focus on migrations and query optimization.

When to Use
- Creating or running migrations
- Writing LINQ queries
- Configuring relationships
- Performance tuning database access

Guidelines

Migrations
- Always review generated migration SQL before applying
- Use explicit foreign key names
- Include descriptive migration names

Queries
- Use AsNoTracking() for read-only queries
- Avoid lazy loading; use eager loading explicitly
- Project to DTOs rather than returning entities
- Split queries for complex relationships

Performance
- Index foreign keys and frequently queried columns
- Use pagination for large result sets
- Monitor query execution plans
```

Combine this with the tdd skill by typing `/tdd` followed by `/efcore` to get test-first guidance with database-specific optimizations.

## Blazor Skill

For Blazor projects, create a skill that addresses component patterns:

```markdown
blazor

Description
Guides Blazor Server and WebAssembly development.

When to Use
- Creating Blazor components
- Managing state in Blazor Server
- Implementing cascading values
- Handling forms and validation

Guidelines

Components
- Use partial classes for code-behind
- Implement IDisposable for resource cleanup
- Use Parameter attributes for component inputs
- Use RenderMode appropriately for Blazor Server

State Management
- Use CascadingValue for shared state
- Implement StateHasChanged() after async operations
- Consider Fluxor or similar for complex state
```

## Combining Multiple Skills

One of Claude's powerful features is combining skills. For a full-stack feature implementation:

```
/tdd
/dotnet-api
/frontend-design
```

This gives you test-driven development, .NET API conventions, and frontend design patterns in a single session. The tdd skill ensures you write tests first, while dotnet-api applies your backend conventions, and frontend-design helps with UI implementation.

## Project-Specific Skills

Beyond general skills, create project-specific ones for your codebase:

```markdown
myapp-api

Description
Specific conventions for YourAppName project.

When to Use
Working within the YourAppName codebase.

Guidelines

API Versioning
- Use URL versioning: /api/v1/resource
- Include version in response headers

Authentication
- JWT Bearer tokens only
- 15-minute access token, 7-day refresh token
- Scope-based authorization

Response Format
- Always wrap in ApiResponse<T> wrapper
- Include correlation IDs for tracing
```

## Testing Your Skills

After creating a skill, test it by invoking it and asking Claude to perform a task. If the results don't match your expectations, refine the guidelines. Skills are iterative, start simple and add complexity as you discover edge cases.

You can view your loaded skills at any time using the skills list command, and skills persist across sessions until you modify or remove them.

## Integration with Other Skills

The .NET skills work well with other Claude skills. The pdf skill helps generate documentation from your API specs. The supermemory skill maintains context across sessions about your project decisions. The canvas-design skill assists with architecture diagrams and flowcharts.

---


**Try it:** Paste your error into our [Error Diagnostic](/diagnose/) for an instant fix.
---

<div class="mastery-cta">

This site was built by 5 autonomous agents running in tmux while I was in Bali. 2,500 articles. Zero manual work. 100% quality gate pass rate.

The orchestration configs, sprint templates, and quality gates that made that possible are in the Zovo Lifetime bundle. Along with 16 CLAUDE.md templates and 80 tested prompts.

**[See how the pipeline works →](https://zovo.one/lifetime?utm_source=ccg&utm_medium=cta-skills&utm_campaign=claude-md-example-for-dotnet-aspnet-core-project)**

$99 once. I'm a solo dev in Da Nang. This is how I scale.

</div>

Related Reading

- [Claude MD Example for Android Kotlin Project](/claude-md-example-for-android-kotlin-project/)
- [Claude.md Example for Data Science Python Project](/claude-md-example-for-data-science-python-project/)
- [Claude MD Example for Go Fiber API Project](/claude-md-example-for-go-fiber-api-project/)
- [Claude MD Example For Next.js TypeScript — Developer Guide](/claude-md-example-for-nextjs-typescript-project/)
- [Claude Md Example For Machine Learning — Developer Guide](/claude-md-example-for-machine-learning-project/)
- [CLAUDE.md Example for Flutter + Dart + Riverpod — Production Template (2026)](/claude-md-example-for-flutter-dart-riverpod/)
- [CLAUDE.md Example for Laravel + PHP — Production Template (2026)](/claude-md-example-for-laravel-php/)
- [CLAUDE.md Example for Rails + Turbo + Stimulus — Production Template (2026)](/claude-md-example-for-rails-turbo-stimulus/)
- [CLAUDE.md Example for NestJS + TypeORM — Production Template (2026)](/claude-md-example-for-nestjs-typeorm/)
- [CLAUDE.md Example for Go + Gin + GORM — Production Template (2026)](/claude-md-example-for-go-gin-gorm/)
- [CLAUDE.md Example for Django + PostgreSQL — Production Template (2026)](/claude-md-example-for-django-postgresql/)

Built by theluckystrike. More at [zovo.one](https://zovo.one)

## Building a Complete CLAUDE.md for ASP.NET Core

A project-level `CLAUDE.md` at the repository root gives Claude Code persistent context about your codebase without requiring skill invocations. Here is a production-ready example for an ASP.NET Core API project:

```markdown
CLAUDE.md. MyApp API

Project Overview
This is an ASP.NET Core 8 Web API for the MyApp platform. It uses Clean Architecture
with CQRS via MediatR, Entity Framework Core 8 with PostgreSQL, and Serilog for structured logging.

Build and Run
dotnet build src/MyApp.sln
dotnet run --project src/MyApp.Api

Testing
dotnet test # run all tests
dotnet test --filter Category=Unit # unit tests only
dotnet test --filter Category=Integration # requires local postgres

Code Conventions
- Use records for DTOs and value objects
- Use FluentValidation for all command/query validation
- Commands use Result<T> return type from ErrorOr library
- Never return domain entities from API controllers. always map to response DTOs
- Follow vertical slice structure: Features/FeatureName/Command|Query files

Database
- Migrations live in src/MyApp.Infrastructure/Migrations
- Create migration: dotnet ef migrations add MigrationName -p src/MyApp.Infrastructure -s src/MyApp.Api
- Apply migration: dotnet ef database update -p src/MyApp.Infrastructure -s src/MyApp.Api

Key Patterns
Adding a New Feature
1. Create Feature folder under src/MyApp.Application/Features/FeatureName
2. Add command or query class implementing IRequest<Result<T>>
3. Add handler implementing IRequestHandler<Command, Result<T>>
4. Add FluentValidation validator
5. Add controller endpoint in appropriate controller or a dedicated minimal API

Error Handling
- Use ErrorOr.Error types for domain errors
- Global exception handler in MyApp.Api converts unhandled exceptions to ProblemDetails
- Never throw exceptions for expected business rule violations. use ErrorOr

What NOT to Do
- Do not use repository pattern. use DbContext directly in handlers
- Do not add service layers between handlers and DbContext
- Do not use AutoMapper. write explicit mapping methods
```

## Workflow Tips for .NET Projects

## Using Claude Code for Migrations

When you add a new property to a domain entity, describe the change to Claude Code and ask it to generate both the migration and update any affected queries:

```
I added a nullable DateTimeOffset? DeletedAt property to the User entity for soft deletes.
Generate:
1. The EF Core migration
2. Update GetUsersQuery to filter out soft-deleted users
3. A new RestoreUserCommand for undeleting a user
4. Unit tests for the restore command
```

Claude Code reads your existing code structure and generates components that match your conventions. including the correct namespace, FluentValidation placement, and Result<T> return patterns.

## Debugging Integration Tests

ASP.NET Core integration tests using `WebApplicationFactory` often fail in subtle ways. Describe the failure to Claude Code with the full stack trace and test setup:

```
My integration test for POST /api/users is returning 500 instead of 201.
The test uses WebApplicationFactory with an in-memory database.
Here is the test setup and the error: [paste error]
```

Common issues Claude Code surfaces quickly: missing service registrations in test configuration, EF Core not seeding required lookup data, JWT authentication not bypassed for test requests, and response body deserialization failing due to JSON naming policy mismatches.

## Combining Skills for Full-Stack .NET Development

When building features that span backend API and Blazor frontend, invoke skills in sequence:

```
/dotnet-api
Create the backend endpoint for user profile updates: PUT /api/users/{id}/profile

/blazor
Create the Blazor component that calls the new profile update endpoint,
with form validation matching the server-side validation rules
```

The `dotnet-api` skill ensures consistent response shapes and error handling on the server side. The `blazor` skill ensures the component handles loading states, error display, and form validation in the project's established style. rather than defaulting to generic patterns.




