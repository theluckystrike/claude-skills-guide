---
layout: default
title: "Claude MD Example for .NET ASP.NET Core Project"
description: "Practical guide to creating Claude skill files for .NET ASPNET Core projects. Includes real examples, patterns, and integration tips."
date: 2026-03-14
author: theluckystrike
permalink: /claude-md-example-for-dotnet-aspnet-core-project/
---

{% raw %}

# Claude MD Example for .NET ASPNET Core Project

Creating effective Claude skill files for .NET ASP.NET Core projects requires understanding both the skill format and how Claude Code processes .NET-specific workflows. This guide provides practical examples you can adapt immediately.

## The Claude Skill Format

Claude skills are Markdown files with a specific structure that Claude reads when you invoke them. For .NET projects, these skills help Claude understand your tooling, conventions, and preferred patterns.

A basic skill file follows this structure:

```markdown
# Skill Name

## Description
Brief description of what this skill does.

## When to Use
Situations where this skill applies.

## Guidelines
- Specific instruction 1
- Specific instruction 2
```

The skill loads when you type `/skillname` in Claude Code, making these instructions part of the AI's context for your session.

## Example: ASP.NET Core API Skill

For an ASP.NET Core Web API project, create a skill that guides Claude through your preferred patterns. Save this as `~/.claude/skills/dotnet-api.md`:

```markdown
# dotnet-api

## Description
Guides Claude through ASP.NET Core Web API development following my team's conventions.

## When to Use
- Creating new API controllers
- Adding endpoints to existing controllers
- Working with Entity Framework Core
- Implementing authentication/authorization

## Guidelines

### Controller Structure
- Use attribute routing exclusively
- Return ActionResult<T> for flexible responses
- Include XML documentation for public APIs
- Follow RESTful naming conventions

### Dependency Injection
- Inject services through constructors
- Use interfaces for service abstractions
- Register services in Program.cs with proper lifetimes

### Error Handling
- Use problem details for error responses
- Implement exception middleware for global handling
- Return appropriate HTTP status codes

### Testing
- Use the tdd skill for test-first development
- Write integration tests using WebApplicationFactory
- Mock external dependencies with Moq or NSubstitute
```

To use this skill, type `/dotnet-api` in your Claude session, then describe what you need. Claude will apply your conventions throughout the task.

## Example: Entity Framework Core Skill

Database interactions deserve their own skill. Create `~/.claude/skills/efcore.md`:

```markdown
# efcore

## Description
Guides Entity Framework Core operations with focus on migrations and query optimization.

## When to Use
- Creating or running migrations
- Writing LINQ queries
- Configuring relationships
- Performance tuning database access

## Guidelines

### Migrations
- Always review generated migration SQL before applying
- Use explicit foreign key names
- Include descriptive migration names

### Queries
- Use AsNoTracking() for read-only queries
- Avoid lazy loading; use eager loading explicitly
- Project to DTOs rather than returning entities
- Split queries for complex relationships

### Performance
- Index foreign keys and frequently queried columns
- Use pagination for large result sets
- Monitor query execution plans
```

Combine this with the tdd skill by typing `/tdd` followed by `/efcore` to get test-first guidance with database-specific optimizations.

## Example: Blazor Skill

For Blazor projects, create a skill that addresses component patterns:

```markdown
# blazor

## Description
Guides Blazor Server and WebAssembly development.

## When to Use
- Creating Blazor components
- Managing state in Blazor Server
- Implementing cascading values
- Handling forms and validation

## Guidelines

### Components
- Use partial classes for code-behind
- Implement IDisposable for resource cleanup
- Use Parameter attributes for component inputs
- Leverage RenderMode appropriately for Blazor Server

### State Management
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

This组合 gives you test-driven development, .NET API conventions, and frontend design patterns in a single session. The tdd skill ensures you write tests first, while dotnet-api applies your backend conventions, and frontend-design helps with UI implementation.

## Project-Specific Skills

Beyond general skills, create project-specific ones for your codebase:

```markdown
# myapp-api

## Description
Specific conventions for YourAppName project.

## When to Use
Working within the YourAppName codebase.

## Guidelines

### API Versioning
- Use URL versioning: /api/v1/resource
- Include version in response headers

### Authentication
- JWT Bearer tokens only
- 15-minute access token, 7-day refresh token
- Scope-based authorization

### Response Format
- Always wrap in ApiResponse<T> wrapper
- Include correlation IDs for tracing
```

## Testing Your Skills

After creating a skill, test it by invoking it and asking Claude to perform a task. If the results don't match your expectations, refine the guidelines. Skills are iterative—start simple and add complexity as you discover edge cases.

You can view your loaded skills at any time using the skills list command, and skills persist across sessions until you modify or remove them.

## Integration with Other Skills

The .NET skills work well with other Claude skills. The pdf skill helps generate documentation from your API specs. The supermemory skill maintains context across sessions about your project decisions. The canvas-design skill assists with architecture diagrams and flowcharts.

Built by theluckystrike — More at [zovo.one](https://zovo.one)

{% endraw %}
