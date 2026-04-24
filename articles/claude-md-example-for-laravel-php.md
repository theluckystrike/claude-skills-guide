---
title: "CLAUDE.md Example for Laravel + PHP (2026)"
description: "CLAUDE.md Example for Laravel + PHP — practical guide with working examples, tested configurations, and tips for developer workflows."
permalink: /claude-md-example-for-laravel-php/
render_with_liquid: false
categories: [claude-md, templates, 2026]
tags: [claude-code, claude-md, laravel, php]
last_updated: 2026-04-19
---

## What This Template Does

This CLAUDE.md configures Claude Code for Laravel 11.36 projects with PHP 8.3, Eloquent ORM, Blade components, and queue-based background processing. It prevents Claude from using raw DB queries when Eloquent is available, enforces proper Form Request validation, and ensures Blade components follow the class-based component pattern. The template covers queue job patterns, event/listener architecture, and Pest PHP testing conventions. This is a significant upgrade over previous Laravel templates — it covers Sail, Pint, and the streamlined Laravel 11 directory structure. Tested against production applications with 120+ models and complex multi-tenant architectures.

## The Complete Template

{% raw %}
```markdown
# CLAUDE.md — Laravel 11 + PHP 8.3

## Project Stack

- PHP 8.3.14
- Laravel 11.36.1
- Eloquent ORM (MySQL 8.4 / PostgreSQL 16.4)
- Blade with class-based components
- Laravel Livewire 3.5.14 (reactive UI)
- Inertia.js 2.0 (optional — if SPA pages needed)
- Laravel Sail 1.38.0 (Docker dev environment)
- Laravel Horizon 5.29.6 (Redis queue dashboard)
- Laravel Pint 1.18.3 (code formatter — PSR-12)
- Pest PHP 3.7.0 (testing framework)
- Laravel Sanctum 4.0.6 (API authentication)
- Vite 6.1.0 (asset bundling)

## Build & Dev Commands

- Start environment: `./vendor/bin/sail up -d`
- Stop environment: `./vendor/bin/sail down`
- Artisan: `./vendor/bin/sail artisan` (or `php artisan` outside Sail)
- Dev server: `./vendor/bin/sail npm run dev` (Vite HMR)
- Build assets: `./vendor/bin/sail npm run build`
- Test: `./vendor/bin/sail pest`
- Test single: `./vendor/bin/sail pest --filter=UserTest`
- Test coverage: `./vendor/bin/sail pest --coverage`
- Lint: `./vendor/bin/sail pint`
- Lint check: `./vendor/bin/sail pint --test`
- Static analysis: `./vendor/bin/sail php vendor/bin/phpstan analyse`
- Migration: `./vendor/bin/sail artisan migrate`
- Migration rollback: `./vendor/bin/sail artisan migrate:rollback`
- Seed: `./vendor/bin/sail artisan db:seed`
- Queue worker: `./vendor/bin/sail artisan queue:work`
- Horizon: `./vendor/bin/sail artisan horizon`
- Cache clear: `./vendor/bin/sail artisan cache:clear`
- Route list: `./vendor/bin/sail artisan route:list`
- Tinker: `./vendor/bin/sail artisan tinker`

## Project Layout

```
app/
  Console/
    Commands/               # Custom artisan commands
  Events/                   # Event classes
  Exceptions/               # Custom exceptions
  Http/
    Controllers/            # Controller classes (single-action or resource)
    Middleware/              # Custom middleware
    Requests/               # Form Request validation classes
    Resources/              # API Resource transformations
  Jobs/                     # Queue jobs
  Listeners/                # Event listeners
  Mail/                     # Mailable classes
  Models/                   # Eloquent models
    Concerns/               # Model traits (HasUuid, Searchable, SoftDeletes)
  Notifications/            # Notification classes (mail, database, Slack)
  Observers/                # Model observers
  Policies/                 # Authorization policies
  Providers/
    AppServiceProvider.php  # App bindings (Laravel 11: single provider)
  Services/                 # Business logic services
  Actions/                  # Single-purpose action classes
config/                     # Configuration files
database/
  factories/                # Model factories for testing
  migrations/               # Timestamped migrations
  seeders/                  # Database seeders
resources/
  views/
    components/             # Blade components
    layouts/                # Layout templates
    livewire/               # Livewire component views
    mail/                   # Email templates
    pages/                  # Page views organized by feature
  css/                      # Tailwind CSS
  js/                       # JavaScript (Vite entry)
routes/
  web.php                   # Web routes (session, CSRF)
  api.php                   # API routes (Sanctum, stateless)
  console.php               # Console commands
tests/
  Feature/                  # Feature/integration tests
  Unit/                     # Unit tests
  Pest.php                  # Pest configuration
```

## Architecture Rules

- Laravel 11 streamlined structure. Single `AppServiceProvider`. No separate `RouteServiceProvider` or `AuthServiceProvider` unless needed.
- Controller types: resource controllers for CRUD (`UserController` with index/show/create/store/edit/update/destroy), invokable controllers for single actions (`GenerateReportController`).
- Form Request classes for all input validation. Never validate in controllers. `php artisan make:request StoreUserRequest`.
- API Resources for all JSON responses. Never return Eloquent models directly from API endpoints. `UserResource::collection($users)`.
- Service classes for complex business logic spanning multiple models. Actions for single-purpose operations.
- Repository pattern only when needed (multi-database, caching layer). Default: query directly via Eloquent in services.
- Events and Listeners for cross-domain side effects. Dispatch events from services: `UserRegistered::dispatch($user)`.
- Observers for model lifecycle hooks when logic is reusable. Prefer observers over model boot closures.
- Policies for authorization. Register in `AppServiceProvider`. Check in controllers: `$this->authorize('update', $post)`.
- Queue jobs for anything that takes more than 500ms: emails, PDF generation, API calls, image processing.
- Eloquent scopes for reusable query filters. `scopeActive`, `scopePublished`, `scopeForUser`.

## Coding Conventions

- PSR-12 coding standard enforced by Laravel Pint. Run before every commit.
- PHP 8.3 features: readonly properties, enums, named arguments, match expressions, union types, intersection types, fibers.
- Type declarations on all method parameters and return types. No `mixed` unless truly necessary.
- Eloquent models: define `$fillable` (whitelist) not `$guarded`. Cast attributes in `$casts` array. Define relationships as methods returning relationship types.
- Relationship naming: `belongsTo` singular (`user()`), `hasMany` plural (`posts()`), `belongsToMany` plural (`roles()`).
- Migration naming: `create_users_table`, `add_email_to_users_table`, `drop_legacy_column_from_users_table`. Verb-first.
- Route naming: `users.index`, `users.show`, `users.store`. Use `Route::resource` for CRUD routes.
- Blade: use `{{ }}` for escaped output. Never use `{!! !!}` for user input. Use `@auth`, `@guest`, `@can` directives.
- Blade components: class-based in `app/View/Components/`. Anonymous components in `resources/views/components/`. Use `<x-component-name>` syntax.
- Config access: `config('app.name')`. Never use `env()` outside of config files — cached config does not call `env()`.
- String helpers: `Str::slug()`, `Str::uuid()`, `Str::kebab()`. Use Laravel string helpers, not raw PHP functions.
- Collections: use collection methods (`->map()`, `->filter()`, `->pluck()`) instead of `array_map`, `array_filter`.
- No global helper functions. Use class methods, service classes, or Laravel Facades.
- Comments: PHPDoc blocks on public methods. Inline comments explain WHY, not WHAT.

## Error Handling

- Custom exception classes in `app/Exceptions/`. Extend `RuntimeException` or `HttpException`.
- Exception rendering: override `render()` on custom exceptions to return appropriate HTTP responses.
- API error format: `{"message": "...", "errors": {"field": ["error"]}}` matching Laravel's default validation error structure.
- `abort(404)` for missing resources. `abort(403)` for unauthorized access. Use named exceptions for readability.
- Try/catch in service methods for external API calls and file operations. Never swallow exceptions without logging.
- Database transaction errors: wrap multi-model operations in `DB::transaction()`. Catch and rethrow with context.
- Queue job failures: implement `failed()` method on job class. Log to Sentry/Bugsnag. Set `$maxExceptions` and `$tries`.
- Validation errors: handled automatically by Form Requests. Return 422 with field-level errors.
- Report errors to monitoring: configure `report()` on exception classes. Use `report($exception)` helper.

## Testing Conventions

- Pest PHP (not PHPUnit directly). Expressive syntax with `it()`, `test()`, `expect()`.
- Feature tests in `tests/Feature/`. Test HTTP requests, database state, and queue dispatches.
- Unit tests in `tests/Unit/`. Test services, actions, and utility functions in isolation.
- Model factories: one per model in `database/factories/`. Use states for variations: `User::factory()->admin()->create()`.
- Database: `RefreshDatabase` trait for clean state per test. `LazilyRefreshDatabase` for speed.
- HTTP tests: `$this->postJson('/api/users', $data)->assertStatus(201)->assertJsonStructure(['data' => ['id', 'name']])`.
- Auth tests: `$this->actingAs($user)->get('/dashboard')->assertStatus(200)`.
- Queue assertions: `Queue::fake()` then `Queue::assertPushed(SendWelcomeEmail::class)`.
- Event assertions: `Event::fake([UserRegistered::class])` then `Event::assertDispatched(UserRegistered::class)`.
- Mail assertions: `Mail::fake()` then `Mail::assertSent(WelcomeMail::class)`.
- Notification assertions: `Notification::fake()` then `Notification::assertSentTo($user, InvoicePaid::class)`.
- Test naming: `it('creates a user with valid data')` or `test('guests cannot access dashboard')`.
- Coverage target: 90% for services and actions, 80% for controllers, 70% for models.

## Database & Eloquent Patterns

- Migrations: always reversible. Define both `up()` and `down()` methods.
- Adding columns to existing tables: always provide `default()` or `nullable()`. Never add non-nullable column without default on production tables.
- Eloquent relationships: always define both sides. If `User hasMany Post`, then `Post belongsTo User`.
- Eager loading: use `with()` on queries to prevent N+1. In controllers: `User::with('posts', 'roles')->get()`.
- Chunking: use `chunk()` or `chunkById()` for processing large result sets. Never `all()` on large tables.
- Query scopes: local scopes on model for reusable conditions. `scopeActive($query) { return $query->where('active', true); }`.
- Mass assignment: define `$fillable` explicitly. Never use `$guarded = []`.
- Soft deletes: `use SoftDeletes` trait. Always filter with `->withoutTrashed()` in queries unless explicitly showing deleted records.
- Accessors/Mutators: use `Attribute::make(get: fn(), set: fn())` syntax (Laravel 11 attribute casting).
- Database-specific: `whereJsonContains` for JSON columns, `whereFullText` for full-text search (MySQL), `whereRaw` with bindings only when ORM cannot express the query.

## Security

- CSRF: automatic on web routes. Blade forms include `@csrf`. API routes use Sanctum token authentication.
- XSS: Blade `{{ }}` escapes output. Never use `{!! !!}` with user-supplied content.
- SQL injection: Eloquent parameterizes queries. Never concatenate user input into `whereRaw()` or `DB::raw()`.
- Mass assignment protection: always define `$fillable` on models. Never bypass with `forceFill()` on user input.
- Authentication: Sanctum for SPA/API tokens. Hash passwords with `Hash::make()`. Never store plaintext.
- Authorization: Gate/Policy for every user action. `$this->authorize()` in controllers. `@can` in Blade.
- Rate limiting: configure in `AppServiceProvider` with `RateLimiter::for()`. Apply to login, register, and API routes.
- File uploads: validate with `'file' => 'required|file|mimes:pdf,jpg|max:10240'`. Store with `Storage::disk('s3')->put()`.

## Deployment

- Production: `php artisan config:cache`, `route:cache`, `view:cache`, `event:cache`.
- Queue: Laravel Horizon for Redis-backed queues. Supervisor for process management.
- Assets: `npm run build` generates production Vite bundle.
- Environment: `.env` per environment. Never commit `.env`. Use server environment variables or secrets manager.
- Zero-downtime: Envoyer or Kamal for atomic deployments.
- Health check: `GET /up` returns 200 (Laravel 11 default).

## What Claude Should Never Do

- Never use `env()` outside of config files. `config()` reads cached values; `env()` does not after `config:cache`.
- Never use `$guarded = []` to disable mass assignment protection. Always define `$fillable` explicitly.
- Never return Eloquent models directly from API controllers. Use API Resources for transformation.
- Never validate input in controller methods. Create Form Request classes with `rules()` method.
- Never use raw DB facade (`DB::select`, `DB::insert`) when Eloquent can express the query.
- Never create routes outside of `routes/web.php` or `routes/api.php` without registering them.
- Never use `{!! !!}` to render user-supplied HTML content. Escape with `{{ }}` or sanitize with HTMLPurifier.
- Never put queue job logic inline in controllers. Create dedicated job classes in `app/Jobs/`.
- Never use `Model::all()` on tables with more than 1,000 rows. Use pagination or chunking.
- Never skip writing a `down()` method in migrations. Migrations must be reversible.
- Never use `sleep()` in queue jobs for rate limiting. Use `$this->release(30)` to re-queue with delay.
- Never store API keys or secrets in config files. Use `.env` and `config()` to access them.

## Project-Specific Context

- [YOUR PROJECT NAME] — update with your project details
- Database: [MySQL 8.4 / PostgreSQL 16.4] via [RDS / PlanetScale / Supabase]
- Cache/Queue: Redis via [ElastiCache / Upstash / Docker]
- File storage: [S3 / R2 / DigitalOcean Spaces] via Laravel Filesystem
- Email: [Postmark / SES / Mailgun] via Laravel Mail
- Deployment: [Forge / Vapor / Kamal / Envoyer] to [AWS / DigitalOcean / Hetzner]
- Monitoring: [Sentry / Flare] for errors, [Horizon dashboard] for queues
```
{% endraw %}

## How to Adapt This For Your Project

Start with the **Project Stack** section and match every version to your `composer.json`. If you do not use Livewire, remove those references and keep Blade components. If you use Inertia.js with Vue/React for the frontend, add a section describing the Inertia page component conventions. The Sail commands assume Docker-based development — replace with plain `php artisan` if you develop directly on your machine. The testing section uses Pest PHP — if you prefer PHPUnit syntax, adjust the test examples but keep the assertion patterns.

## Common CLAUDE.md Mistakes in Laravel Projects

1. **Not banning `env()` outside config files.** Claude uses `env('APP_KEY')` directly in service classes. After running `config:cache`, these calls return `null` because the `.env` file is not read. Specify that only `config()` is allowed outside config files.

2. **Allowing `Model::all()` without size warnings.** Claude generates `User::all()` for listing pages, which loads every row into memory. Specify pagination or chunking for tables above a threshold.

3. **Missing Form Request validation pattern.** Without this rule, Claude validates input inline in controller methods with `$request->validate()`, which is functional but does not follow Laravel's separation of concerns. Form Requests move validation logic into dedicated, testable classes.

4. **Not specifying Eloquent relationship direction.** Claude defines `hasMany` on one model but forgets `belongsTo` on the related model, which causes relationship queries to fail silently.

5. **Using `$guarded = []` for convenience.** Claude sets `$guarded` to an empty array to avoid listing fields, which disables mass assignment protection entirely — a security vulnerability that allows attackers to set admin flags or other protected attributes.

## What Claude Code Does With This

With this CLAUDE.md loaded, Claude Code generates Eloquent models with explicit `$fillable` arrays, proper relationship definitions in both directions, and attribute casts. Controllers use Form Request classes for validation and API Resources for JSON responses. New features get event classes with listeners for side effects. Queue jobs handle any operation over 500ms. Tests use Pest PHP with model factories and proper queue/event faking. Blade templates use class-based components with the `<x-component>` syntax.

## The Full 16-Template Pack

This is one of 16 production CLAUDE.md templates available in the Lifetime pack. Includes templates for Django + PostgreSQL, Next.js + TypeScript, Rails + Turbo, FastAPI + SQLAlchemy, and 11 more stacks. Each template is 200-400 lines of production-tested configuration. Get all 16 at [claudecodeguides.com/generator/](https://claudecodeguides.com/generator/).
