---
layout: default
title: "Claude Skills for PHP Laravel Development Workflow"
description: "Learn how to create Claude skills that accelerate your PHP Laravel development workflow. Practical examples for code generation, testing, debugging, and database operations."
date: 2026-03-14
categories: [development, laravel, php]
tags: [claude-skills, php, laravel, workflow, automation]
author: "Claude Skills Guide"
reviewed: true
score: 8
---

# Claude Skills for PHP Laravel Development Workflow

PHP Laravel remains one of the most productive frameworks for web application development. By combining Claude Code with [custom skills tailored for Laravel](/claude-skills-guide/articles/how-to-write-a-skill-md-file-for-claude-code/), you can dramatically accelerate your development workflow—from scaffolding new projects to running database migrations and generating tests.

This guide shows you how to build Claude skills specifically designed for PHP Laravel development. These skills help you generate boilerplate code, run artisan commands, work with Eloquent models, and maintain test coverage without leaving your terminal.

## Why Laravel Benefits from Custom Claude Skills

Laravel follows strict conventions for directory structure, naming, and coding patterns. These conventions are exactly what makes [custom skills powerful](/claude-skills-guide/articles/claude-skill-md-format-complete-specification-guide/)—once you teach Claude your preferred patterns, it applies them consistently across every file it generates.

Consider the difference between asking Claude to "create a user registration controller" versus invoking a skill that knows your exact namespace structure, uses your preferred validation approach, and follows your team's coding style. The skill produces code that fits your project immediately, without repeated refinement.

## Core Skills for Laravel Development

### 1. Laravel Controller Generator

Create a skill that generates controllers following your project conventions:

```
name: laravel-controller
description: Generate Laravel controllers with standard CRUD operations
body: |
  When asked to create a Laravel controller, follow these patterns:
  
  Use App\Http\Controllers\Controller as the base class.
  Apply the $model property to determine the related model.
  Use Form Requests for validation - generate these automatically.
  Implement resource methods: index, show, create, store, edit, update, destroy.
  Add type hints and return types throughout.
  Include $this->authorize() calls for policy integration.
  
  Generate the controller in the appropriate namespace.
  Create corresponding Form Request classes for store and update.
  Output all file paths before writing.
```

This skill ensures every controller follows your team's structure. When you invoke it with `/laravel-controller User`, Claude generates the complete controller with all CRUD methods, proper imports, and documentation comments.

### 2. Model and Migration Assistant

Laravel's database layer requires synchronized models and migrations. A well-designed skill handles both:

```
name: laravel-model
description: Create Laravel Eloquent models with migrations and relationships
body: |
  For model creation:
  
  Generate the model file in app/Models/
  Include $fillable, $hidden, $casts, and $dates as appropriate.
  Add relationship methods: hasMany, belongsTo, belongsToMany, etc.
  Generate a corresponding migration in database/migrations/
  Include up() and down() methods with proper column definitions.
  Add foreign key constraints where needed.
  Generate a seeder class for test data.
  
  Ask for the table name, columns, and relationships before generating.
  Follow Laravel naming conventions automatically.
```

### 3. Test Generator

Maintaining [test coverage](/claude-skills-guide/articles/claude-skills-for-writing-unit-tests-automatically/) in Laravel projects becomes effortless with a dedicated skill:

```
name: laravel-test
description: Generate PHPUnit tests for Laravel applications
body: |
  Create Feature and Unit tests following Laravel conventions:
  
  Feature tests go in tests/Feature/
  Unit tests go in tests/Unit/
  Use Laravel's testing helpers: $this->actingAs(), $this->get(), $this->post()
  Include assertions for response status, headers, and content.
  Use factories for model generation - include factory definitions if missing.
  Test validation by sending invalid data and checking error messages.
  Test authentication and authorization flows.
  
  Generate clean, readable test methods with descriptive names.
```

## Advanced Workflow Integration

### Running Artisan Commands

Your Laravel skills should work directly with artisan. Create a skill that handles command execution. For CI/CD integration patterns, see [Claude Skills with GitHub Actions CI/CD Pipeline](/claude-skills-guide/articles/claude-skills-with-github-actions-ci-cd-pipeline/).

```
name: artisan
description: Execute Laravel artisan commands with proper output handling
body: |
  Execute artisan commands in the project root:
  
  For migrations: run php artisan migrate, migrate:fresh, or migrate:rollback
  For seeding: use php artisan db:seed with --class flag
  For clearing cache: run optimize:clear or config:clear, cache:clear, route:clear
  For serving: start the development server with php artisan serve
  
  Always show command output to the user.
  Report success or failure clearly.
  Suggest related commands when appropriate.
```

### Database Operations with Tinker

For interactive database work, integrate Laravel's tinker:

```
name: laravel-tinker
description: Run database queries and model operations via Tinker
body: |
  Use Tinker for database interactions:
  
  Execute: php artisan tinker --execute="..." for single commands
  Or start an interactive session for complex operations.
  Work with Eloquent models directly: User::all(), User::find(1)
  Create records: User::create(['name' => 'Test', 'email' => 'test@test.com'])
  Run queries: User::where('active', true)->get()
  
  Show query results clearly.
  Warn before destructive operations (deleting records, etc).
```

## Practical Example: Building a Feature End-to-End

Imagine you need to add a comments feature to your Laravel application. With properly configured skills, here's your workflow:

1. **Invoke `/laravel-model`** — Generate the Comment model with migration, including relationships to Post and User models
2. **Invoke `/laravel-controller`** — Create CommentController with full CRUD
3. **Invoke `/laravel-test`** — Generate feature tests for all endpoints
4. **Invoke `/artisan`** — Run migrations to create the table
5. **Invoke `/artisan`** — Clear routes cache and verify routes with `route:list`

Each skill produces code that follows your project conventions, reducing the back-and-forth typically required to integrate new features.

## Optimizing Skills for Laravel Projects

When building Laravel-specific skills, consider these patterns:

**Project Detection**: Start skills by checking for the presence of ` artisan` in the project root. This ensures you're working within a Laravel environment.

**Configuration Awareness**: Read `config/app.php` to determine the application namespace and locale settings. Use these values when generating code.

**Package Integration**: If your project uses Spatie packages (permissions, activity log), add relevant includes to your skills. For Spatie permissions:

```
name: laravel-permission
description: Add Spatie permission checks to controllers and routes
body: |
  When adding permission checks:
  
  Use $this->authorize() in controllers for policy-based authorization.
  Add @can directives in Blade templates.
  Include 'permission:manage-users' middleware on routes.
  Generate permission seeders for common roles.
```

## Testing Your Laravel Skills

Before deploying skills team-wide, validate them against a test project:

1. Create a fresh Laravel application
2. Invoke each skill with realistic inputs
3. Run `php artisan route:list` to verify routing
4. Execute `php artisan test` to confirm tests pass
5. Check code style with PHP CS Fixer or Pint

Iterate on skill prompts based on results. The goal is producing code that requires zero modifications before your first commit.

## Conclusion

Claude skills for PHP Laravel development transform how you build applications. By codifying your team's conventions, automating repetitive tasks, and integrating with Laravel's artisan CLI, you focus on business logic rather than boilerplate. Start with the skills outlined here, customize them to your project structure, and watch your development velocity increase significantly.

## Related Reading

- [How to Write a Skill MD File for Claude Code](/claude-skills-guide/articles/how-to-write-a-skill-md-file-for-claude-code/) — create your own Laravel-specific skills from scratch
- [Claude Skills for Writing Unit Tests Automatically](/claude-skills-guide/articles/claude-skills-for-writing-unit-tests-automatically/) — automated test generation workflows for PHP and other languages
- [Claude Skills with GitHub Actions CI/CD Pipeline](/claude-skills-guide/articles/claude-skills-with-github-actions-ci-cd-pipeline/) — integrate Laravel testing into CI/CD pipelines
- [Claude Code Skills for Backend Developers: Node.js and Python](/claude-skills-guide/articles/claude-code-skills-for-backend-developers-node-and-python/) — backend skill patterns applicable across frameworks

Built by theluckystrike — More at [zovo.one](https://zovo.one)
