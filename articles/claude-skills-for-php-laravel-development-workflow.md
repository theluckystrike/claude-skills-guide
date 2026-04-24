---
layout: default
title: "Claude Skills For Php Laravel (2026)"
description: "Learn how to create Claude skills that accelerate your PHP Laravel development workflow. Practical examples for code generation, testing, debugging, and."
date: 2026-03-14
last_modified_at: 2026-04-17
categories: [guides]
tags: [claude-code, claude-skills, php, laravel, workflow]
author: "Claude Skills Guide"
reviewed: true
score: 8
permalink: /claude-skills-for-php-laravel-development-workflow/
geo_optimized: true
---
# Claude Skills for PHP Laravel Development Workflow

PHP Laravel remains one of the most productive frameworks for web application development. By combining Claude Code with [custom skills tailored for Laravel](/how-to-write-a-skill-md-file-for-claude-code/), you can dramatically accelerate your development workflow, from scaffolding new projects to running database migrations and generating tests.

This guide shows you how to build Claude skills specifically designed for PHP Laravel development. These skills help you generate boilerplate code, run artisan commands, work with Eloquent models, and maintain test coverage without leaving your terminal.

## Why Laravel Benefits from Custom Claude Skills

Laravel follows strict conventions for directory structure, naming, and coding patterns. These conventions are exactly what makes [custom skills powerful](/claude-skill-md-format-complete-specification-guide/), once you teach Claude your preferred patterns, it applies them consistently across every file it generates.

Consider the difference between asking Claude to "create a user registration controller" versus invoking a skill that knows your exact namespace structure, uses your preferred validation approach, and follows your team's coding style. The skill produces code that fits your project immediately, without repeated refinement.

## Core Skills for Laravel Development

1. Laravel Controller Generator

Create a skill that generates controllers following your project conventions:

```
name: laravel-controller
description: Generate Laravel controllers with standard CRUD operations
```

This skill ensures every controller follows your team's structure. When you invoke it with `/laravel-controller User`, Claude generates the complete controller with all CRUD methods, proper imports, and documentation comments.

2. Model and Migration Assistant

Laravel's database layer requires synchronized models and migrations. A well-designed skill handles both:

```
name: laravel-model
description: Create Laravel Eloquent models with migrations and relationships
```

3. Test Generator

Maintaining [test coverage](/claude-skills-for-writing-unit-tests-automatically/) in Laravel projects becomes much faster with a dedicated skill:

```
name: laravel-test
description: Generate PHPUnit tests for Laravel applications
```

## Advanced Workflow Integration

## Running Artisan Commands

Your Laravel skills should work directly with artisan. Create a skill that handles command execution. For CI/CD integration patterns, see [Claude Skills with GitHub Actions CI/CD Pipeline](/claude-skills-with-github-actions-ci-cd-pipeline/).

```
name: artisan
description: Execute Laravel artisan commands with proper output handling
```

## Database Operations with Tinker

For interactive database work, integrate Laravel's tinker:

```
name: laravel-tinker
description: Run database queries and model operations via Tinker
```

## Practical Example: Building a Feature End-to-End

Imagine you need to add a comments feature to your Laravel application. With properly configured skills, here's your workflow:

1. Invoke `/laravel-model`. Generate the Comment model with migration, including relationships to Post and User models
2. Invoke `/laravel-controller`. Create CommentController with full CRUD
3. Invoke `/laravel-test`. Generate feature tests for all endpoints
4. Invoke `/artisan`. Run migrations to create the table
5. Invoke `/artisan`. Clear routes cache and verify routes with `route:list`

Each skill produces code that follows your project conventions, reducing the back-and-forth typically required to integrate new features.

## Writing Effective Skill Prompts for Laravel

The quality of code your skills generate depends entirely on the instructions inside the skill file. Vague prompts produce generic Laravel code that still needs heavy editing. Precise prompts produce code you can commit immediately.

Weak prompt:
```
Generate a Laravel controller for the resource.
```

Strong prompt:
```
Generate a Laravel resource controller for the given model name. Follow these rules:
- Namespace: App\Http\Controllers\Api\V1
- Use FormRequest classes for validation (create them if they do not exist)
- Return resources using App\Http\Resources. create the resource class if missing
- All responses use the ApiResponse helper at App\Helpers\ApiResponse
- Include PHPDoc blocks on every public method
- index() must accept query string filters: per_page (default 15), sort_by, sort_dir
- Wrap database writes in DB::transaction()
```

The second version gives Claude everything it needs to produce code that matches your actual project. Document your team's conventions once inside the skill, and every developer on the team gets consistent output without needing to remember the rules.

## Handling Form Requests and Validation

Validation logic scattered across controllers is a common Laravel code smell. Build a dedicated skill that generates FormRequest classes with your validation conventions:

```
/laravel-request StoreCommentRequest
```

A well-written skill for this produces the FormRequest class, fills in `authorize()` with sensible logic, and adds `rules()` with typed validation based on the model's migration columns. It should also generate the corresponding test that posts invalid payloads and asserts 422 responses.

Example output from a strong skill:

```php
class StoreCommentRequest extends FormRequest
{
 public function authorize(): bool
 {
 return $this->user()->can('create', Comment::class);
 }

 public function rules(): array
 {
 return [
 'post_id' => ['required', 'integer', 'exists:posts,id'],
 'body' => ['required', 'string', 'min:3', 'max:2000'],
 'parent_id'=> ['nullable', 'integer', 'exists:comments,id'],
 ];
 }
}
```

This saves roughly 15 minutes per feature and eliminates the class of bugs where a developer forgets to add `exists:` constraints.

## Service Layer Pattern

Larger Laravel applications benefit from a service layer that keeps controllers thin. Create a skill that generates the full stack: controller, service class, and repository interface together.

Invoke it as:

```
/laravel-service CommentService
```

Your skill should produce:
- `app/Services/CommentService.php` with constructor injection of the repository
- `app/Repositories/Contracts/CommentRepositoryInterface.php`
- `app/Repositories/EloquentCommentRepository.php` implementing the interface
- A service provider binding entry to paste into `AppServiceProvider`

Generating all four pieces together prevents the common mistake of creating a service class that directly calls the model, bypassing the repository abstraction you already have in place.

## Debugging with Laravel Telescope Integration

When something breaks, you want Claude to help you debug using your actual log data rather than guessing. Build a skill that reads from Laravel Telescope or your log files and summarizes errors:

```
name: laravel-debug
description: Read Laravel logs or Telescope entries and identify the root cause
```

Invoke it with a reference to the failing endpoint or an error message excerpt. The skill reads `storage/logs/laravel.log`, identifies the relevant stack trace, and suggests a fix with context about which part of the framework is involved. This is faster than grepping log files manually and more targeted than pasting raw stack traces into a chat.

## Optimizing Skills for Laravel Projects

When building Laravel-specific skills, consider these patterns:

Project Detection: Start skills by checking for the presence of `artisan` in the project root. This ensures you're working within a Laravel environment.

Configuration Awareness: Read `config/app.php` to determine the application namespace and locale settings. Use these values when generating code.

Package Integration: If your project uses Spatie packages (permissions, activity log), add relevant includes to your skills. For Spatie permissions:

```
name: laravel-permission
description: Add Spatie permission checks to controllers and routes
```

API Versioning: If your project uses versioned APIs under `app/Http/Controllers/Api/V1/`, hardcode that namespace expectation into your controller skill so no generated file ends up in the wrong directory.

Soft Deletes: Add a flag to your model skill so it asks whether to include `SoftDeletes`. One flag prevents a migration oversight that is painful to fix after data exists in production.

## Testing Your Laravel Skills

Before deploying skills team-wide, validate them against a test project:

1. Create a fresh Laravel application
2. Invoke each skill with realistic inputs
3. Run `php artisan route:list` to verify routing
4. Execute `php artisan test` to confirm tests pass
5. Check code style with PHP CS Fixer or Pint

Iterate on skill prompts based on results. The goal is producing code that requires zero modifications before your first commit.

## Team Adoption Strategy

The fastest way to get a team using Laravel skills consistently is to commit the skill files into the repository under `.claude/skills/`. Every developer who clones the repo gets the same skills automatically. When a convention changes, say, you adopt a new API response format, you update one skill file, commit it, and the entire team picks it up on the next pull.

Document each skill's expected inputs and outputs in a brief comment at the top of the skill file. A developer who has never used the skill before should be able to invoke it correctly after reading five lines.

Start with the two or three most repetitive tasks your team does: usually controller generation, migration creation, and test scaffolding. Get those three skills producing clean output on your existing codebase before expanding. Once developers see that `/laravel-controller` produces commit-ready code on the first try, adoption takes care of itself.

## Conclusion

Claude skills for PHP Laravel development transform how you build applications. By codifying your team's conventions, automating repetitive tasks, and integrating with Laravel's artisan CLI, you focus on business logic rather than boilerplate. Start with the skills outlined here, customize them to your project structure, and watch your development velocity increase significantly.

---

---

<div class="mastery-cta">

This site was built by 5 autonomous agents running in tmux while I was in Bali. 2,500 articles. Zero manual work. 100% quality gate pass rate.

The orchestration configs, sprint templates, and quality gates that made that possible are in the Zovo Lifetime bundle. Along with 16 CLAUDE.md templates and 80 tested prompts.

**[See how the pipeline works →](https://zovo.one/lifetime?utm_source=ccg&utm_medium=cta-skills&utm_campaign=claude-skills-for-php-laravel-development-workflow)**

$99 once. I'm a solo dev in Da Nang. This is how I scale.

</div>

Related Reading

- [How to Write a Skill MD File for Claude Code](/how-to-write-a-skill-md-file-for-claude-code/). create your own Laravel-specific skills from scratch
- [Claude Skills for Writing Unit Tests Automatically](/claude-skills-for-writing-unit-tests-automatically/). automated test generation workflows for PHP and other languages
- [Claude Skills with GitHub Actions CI/CD Pipeline](/claude-skills-with-github-actions-ci-cd-pipeline/). integrate Laravel testing into CI/CD pipelines
- [Claude Code Skills for Backend Developers: Node.js and Python](/claude-code-skills-for-backend-developers-node-and-python/). backend skill patterns applicable across frameworks

Built by theluckystrike. More at [zovo.one](https://zovo.one)


