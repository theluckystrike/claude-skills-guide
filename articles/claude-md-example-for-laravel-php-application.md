---
layout: default
title: "Claude MD Example for Laravel PHP Application"
description: "A practical guide to using Claude Code with Laravel PHP. Real skill examples, code snippets, and workflow patterns for Laravel developers."
date: 2026-03-14
categories: [tutorials]
tags: [claude-code, claude-skills, laravel, php, markdown]
author: theluckystrike
reviewed: true
score: 8
permalink: /claude-md-example-for-laravel-php-application/
---

# Claude MD Example for Laravel PHP Application

Laravel is one of the most popular PHP frameworks, known for its elegant syntax and powerful features. When combined with Claude Code's skill system, you can create a highly productive development environment tailored specifically for Laravel development. This guide shows you how to create effective Claude MD files for your Laravel projects.

## Setting Up Claude Skills for Laravel

The Claude skills system works by placing Markdown files in your skills directory. Each skill file contains instructions that Claude follows when working on your project. For Laravel development, creating a dedicated skill helps Claude understand your coding conventions, package preferences, and architectural patterns.

Create a skill file at `~/.claude/skills/laravel.md`:

```markdown
# Laravel Development Skill

You are a Laravel PHP expert. When working on Laravel projects:

1. Follow Laravel's directory structure conventions
2. Use Eloquent ORM with proper relationships and scopes
3. Implement service classes for business logic
4. Write tests using PHPUnit with Laravel's testing utilities
5. Use Laravel's validation rules and form requests

When generating code, prefer:
- Service classes over fat controllers
- Laravel's built-in authentication scaffolding
- Laravel Mix or Vite for asset compilation
- Spatie packages for common functionality

Key conventions:
- Models go in app/Models/
- Controllers go in app/Http/Controllers/
- Services go in app/Services/
- Requests go in app/Http/Requests/
- Migrations go in database/migrations/
```

## Using the Laravel Skill in Your Projects

Activate the skill in your Claude Code session by typing:

```
/laravel
```

Then describe your task. For example, you might say:

> "Create an article management system with categories and tags. Use Laravel's pagination and include a search feature."

Claude will generate the models, migrations, controllers, and views following Laravel conventions.

## Real-World Example: Building an API Endpoint

When you need to create a RESTful API in Laravel, the skill helps you generate proper resource controllers with authentication. Here is what Claude produces:

```php
<?php
// app/Http/Controllers/Api/ArticleController.php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Article;
use App\Http\Resources\ArticleResource;
use App\Http\Requests\StoreArticleRequest;
use App\Services\ArticleService;
use Illuminate\Http\JsonResponse;

class ArticleController extends Controller
{
    public function __construct(
        protected ArticleService $articleService
    ) {}

    public function index(): JsonResponse
    {
        $articles = $this->articleService->getPublishedArticles();
        
        return response()->json([
            'data' => ArticleResource::collection($articles),
            'meta' => [
                'current_page' => $articles->currentPage(),
                'last_page' => $articles->lastPage(),
                'per_page' => $articles->perPage(),
                'total' => $articles->total(),
            ]
        ]);
    }

    public function store(StoreArticleRequest $request): JsonResponse
    {
        $article = $this->articleService->createArticle(
            $request->validated()
        );

        return response()->json([
            'data' => new ArticleResource($article),
            'message' => 'Article created successfully'
        ], 201);
    }

    public function show(Article $article): JsonResponse
    {
        return response()->json([
            'data' => new ArticleResource($article->load('category', 'tags'))
        ]);
    }

    public function update(
        StoreArticleRequest $request, 
        Article $article
    ): JsonResponse {
        $article = $this->articleService->updateArticle(
            $article,
            $request->validated()
        );

        return response()->json([
            'data' => new ArticleResource($article),
            'message' => 'Article updated successfully'
        ]);
    }

    public function destroy(Article $article): JsonResponse
    {
        $this->articleService->deleteArticle($article);

        return response()->json([
            'message' => 'Article deleted successfully'
        ]);
    }
}
```

## Enhancing Your Workflow with Additional Skills

For a complete Laravel development setup, consider combining the Laravel skill with other Claude skills. The **tdd** skill helps you write tests first, ensuring your code is properly tested before implementation. This works particularly well with Laravel's feature tests and unit tests.

If you are building APIs that return JSON, the **supermemory** skill helps maintain context across long conversations, remembering your API design decisions and endpoint conventions throughout the project lifecycle.

For frontend work in your Laravel application, the **frontend-design** skill assists with Vue.js or React components that might accompany your Laravel frontend. Laravel works seamlessly with modern JavaScript frameworks, and this skill ensures consistent styling and component patterns.

When generating documentation for your Laravel packages or APIs, the **pdf** skill can help create professional documentation files, though for most Laravel projects, Markdown-based documentation served via Laravel's markdown rendering capabilities is often sufficient.

## Practical Example: Database Migrations

The Laravel skill ensures your migrations follow best practices. Here is an example migration generated for a articles table:

```php
<?php
// database/migrations/2024_01_15_000001_create_articles_table.php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('articles', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained()->onDelete('cascade');
            $table->foreignId('category_id')->nullable()->constrained()->onDelete('set null');
            $table->string('title');
            $table->string('slug')->unique();
            $table->text('excerpt')->nullable();
            $table->longText('content');
            $table->string('featured_image')->nullable();
            $table->boolean('is_published')->default(false);
            $table->timestamp('published_at')->nullable();
            $table->timestamps();
            
            $table->index(['is_published', 'published_at']);
            $table->index('slug');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('articles');
    }
};
```

Notice how the migration includes proper foreign key constraints, appropriate indexes for query performance, and timestamps. The Laravel skill ensures these patterns are followed consistently.

## Testing Your Laravel Application

With the **tdd** skill loaded alongside Laravel, you can generate comprehensive test cases:

```php
<?php
// tests/Feature/ArticleApiTest.php

namespace Tests\Feature;

use App\Models\User;
use App\Models\Article;
use App\Models\Category;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class ArticleApiTest extends TestCase
{
    use RefreshDatabase;

    protected function setUp(): void
    {
        parent::setUp();
        
        $this->user = User::factory()->create();
    }

    public function test_can_list_published_articles(): void
    {
        Article::factory()->count(3)->create(['is_published' => true]);
        Article::factory()->create(['is_published' => false]);

        $response = $this->getJson('/api/articles');

        $response->assertStatus(200)
            ->assertJsonCount(3, 'data');
    }

    public function test_can_create_article_with_valid_data(): void
    {
        $category = Category::factory()->create();
        
        $response = $this->actingAs($this->user)
            ->postJson('/api/articles', [
                'title' => 'Test Article',
                'slug' => 'test-article',
                'content' => 'Test content here',
                'category_id' => $category->id,
            ]);

        $response->assertStatus(201)
            ->assertJsonFragment(['title' => 'Test Article']);
        
        $this->assertDatabaseHas('articles', [
            'title' => 'Test Article',
            'user_id' => $this->user->id,
        ]);
    }

    public function test_cannot_create_article_without_authentication(): void
    {
        $response = $this->postJson('/api/articles', [
            'title' => 'Test Article',
            'slug' => 'test-article',
            'content' => 'Test content',
        ]);

        $response->assertStatus(401);
    }
}
```

## Project-Specific Customization

For each Laravel project, create a `CLAUDE.md` file in your project root. This file overrides the general Laravel skill with project-specific details:

```markdown
# Project-Specific Laravel Conventions

Our project uses:
- Laravel 11 with Laravel Sanctum for API authentication
- PostgreSQL database
- Spatie Permission for role management
- Laravel Debugbar in development
- Custom naming: use 'Post' not 'Article' for blog posts
- API Resources in app/Http/Resources/V1/
- DTOs via spatie/laravel-data package

When generating code:
- Always use Laravel Data DTOs for request validation
- Include API versioning in routes
- Use policy classes for authorization
- Add OpenAPI annotations for API documentation
```

This project-specific file works alongside the general Laravel skill, giving you the best of both worlds: general Laravel conventions and project-specific patterns.

## Conclusion

Creating a Claude MD file for your Laravel PHP application significantly improves your development workflow. By defining your conventions, preferred packages, and architectural patterns, Claude generates code that matches your team's standards from the start. Combine this with skills like **tdd** for testing and **supermemory** for context retention, and you have a powerful development setup for Laravel projects.

Built by theluckystrike — More at [zovo.one](https://zovo.one)
