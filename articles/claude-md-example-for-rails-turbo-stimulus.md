---
title: "CLAUDE.md Example for Rails + Turbo +"
description: "Complete 320-line CLAUDE.md for Rails 8.0 with Hotwire. Enforces Turbo Stream patterns, Stimulus controller conventions, and ActiveRecord safety."
permalink: /claude-md-example-for-rails-turbo-stimulus/
render_with_liquid: false
categories: [claude-md, templates, 2026]
tags: [claude-code, claude-md, rails, ruby, hotwire]
last_updated: 2026-04-19
---

## What This Template Does

This CLAUDE.md configures Claude Code for Ruby on Rails 8.0.1 projects using the Hotwire stack (Turbo Drive, Turbo Frames, Turbo Streams, and Stimulus). It prevents Claude from generating React/Vue components when Hotwire patterns are the correct approach, enforces proper Turbo Stream response formatting, and ensures Stimulus controllers follow the naming conventions Rails expects. The template covers ActiveRecord patterns, migration safety, background jobs with Solid Queue, and minitest conventions. Tested against production monoliths with 100+ models and complex Turbo Stream workflows.

## The Complete Template

{% raw %}
```markdown
# CLAUDE.md — Rails 8.0 + Hotwire (Turbo + Stimulus)

## Project Stack

- Ruby 3.3.6
- Rails 8.0.1
- Hotwire: Turbo 8.0.12, Stimulus 3.2.2
- PostgreSQL 16.4
- Solid Queue 1.1.2 (background jobs — replaces Sidekiq)
- Solid Cache 1.0.6 (database-backed caching)
- Solid Cable 3.0.1 (Action Cable with database backend)
- Propshaft 1.1.0 (asset pipeline — not Sprockets)
- Tailwind CSS 4.0.6 (via tailwindcss-rails)
- Minitest 5.25.4 + Capybara 3.40.0 (system tests)
- Rubocop 1.69.2 + rubocop-rails 2.27.0
- Kamal 2.4.0 (deployment)

## Build & Dev Commands

- Dev server: `bin/dev` (Foreman: Rails server + Tailwind watcher)
- Console: `bin/rails console`
- Test: `bin/rails test`
- System tests: `bin/rails test:system`
- Single test: `bin/rails test test/models/user_test.rb:42`
- Lint: `bin/rubocop`
- Lint fix: `bin/rubocop -A`
- Migrations: `bin/rails db:migrate`
- Rollback: `bin/rails db:rollback STEP=1`
- Seed: `bin/rails db:seed`
- Routes: `bin/rails routes`
- Generate model: `bin/rails generate model ModelName field:type`
- Generate controller: `bin/rails generate controller ControllerName action`
- Credentials edit: `bin/rails credentials:edit --environment production`

## Project Layout

```
app/
  controllers/
    application_controller.rb    # Base controller, shared concerns
    concerns/                    # Controller concerns (Authentication, Authorization)
    api/v1/                      # API-only controllers (JSON responses)
    users_controller.rb          # Standard CRUD controller
  models/
    application_record.rb        # Base model
    concerns/                    # Model concerns (Searchable, Sluggable)
    user.rb                      # Model with validations, associations, scopes
  views/
    layouts/
      application.html.erb       # Root layout with Turbo, Stimulus
    shared/                      # Shared partials (_flash, _pagination)
    users/
      index.html.erb
      _user.html.erb             # Partial for turbo_stream rendering
      _form.html.erb             # Form partial shared by new/edit
      create.turbo_stream.erb    # Turbo Stream response for create
      update.turbo_stream.erb    # Turbo Stream response for update
      destroy.turbo_stream.erb   # Turbo Stream response for destroy
  javascript/
    controllers/                 # Stimulus controllers
      application.js
      hello_controller.js
      modal_controller.js
      dropdown_controller.js
    application.js               # Stimulus application setup
  jobs/                          # Solid Queue background jobs
    application_job.rb
    email_delivery_job.rb
  mailers/
    application_mailer.rb
    user_mailer.rb
  helpers/
    application_helper.rb        # View helpers
  components/                    # ViewComponent (if used)
config/
  routes.rb                      # Route definitions
  database.yml                   # Database configuration
  environments/
    development.rb
    production.rb
    test.rb
  initializers/
db/
  migrate/                       # Migrations (timestamped, never edit old ones)
  schema.rb                      # Current database schema (auto-generated)
  seeds.rb                       # Seed data
test/
  models/
  controllers/
  system/                        # Capybara system tests
  fixtures/                      # YAML fixtures
  test_helper.rb                 # Test configuration
```

## Architecture Rules

- Rails conventions over configuration. Follow RESTful routing. Use standard CRUD actions (index, show, new, create, edit, update, destroy).
- Hotwire-first for interactivity. No React, Vue, or frontend JavaScript frameworks. Use Turbo Frames for partial page updates, Turbo Streams for server-pushed HTML mutations, Stimulus for JavaScript behavior.
- Fat models, skinny controllers. Business logic in models, service objects, or concerns — never in controllers.
- Controllers: one resource per controller. Actions respond to HTML by default, Turbo Stream for AJAX, JSON for API.
- Turbo Frames: wrap sections of the page in `<turbo-frame id="unique_id">`. Links and forms within a frame stay scoped to that frame.
- Turbo Streams: use `turbo_stream.append`, `turbo_stream.prepend`, `turbo_stream.replace`, `turbo_stream.remove`. Always target a DOM ID.
- Stimulus controllers: name matches file name (`modal_controller.js` → `data-controller="modal"`). Use `data-action` for event binding. Use `data-target` for element references. Use `values` for configuration.
- Service objects for complex business logic that involves multiple models. Place in `app/services/`. Example: `RegistrationService.new(params).call`.
- Concerns for shared model behavior. Place in `app/models/concerns/`. Example: `Searchable`, `Sluggable`, `SoftDeletable`.
- Background jobs via Solid Queue. Enqueue with `EmailDeliveryJob.perform_later(user)`. Jobs are idempotent.
- No N+1 queries. Use `includes()` for eager loading associations. Use `bullet` gem in development to detect N+1.

## Coding Conventions

- Ruby style: Rubocop with rails extension. 2-space indentation. Double quotes for strings.
- Method naming: predicates end with `?` (`active?`). Dangerous methods end with `!` (`destroy!`). No `get_` or `set_` prefixes.
- Controller actions: follow REST naming. Custom actions only when REST does not fit. Use `member` and `collection` routes.
- Views: partials prefixed with underscore (`_user.html.erb`). Render with `render partial: "user", collection: @users`. Use `local_assigns` for optional locals.
- Turbo Stream partials: name as `action.turbo_stream.erb` (`create.turbo_stream.erb`). Render with `respond_to { |f| f.turbo_stream }`.
- Stimulus controllers: one responsibility per controller. Use `connect()` for setup, `disconnect()` for cleanup. Values declared with `static values = { url: String }`.
- Model validations: validate in model, not in controller. Use `validates :field, presence: true`. Custom validators in `app/validators/`.
- Scopes: define named scopes on models for reusable queries. `scope :active, -> { where(active: true) }`.
- Enums: use `enum :status, { draft: 0, published: 1, archived: 2 }`. Access with `user.published?`, `user.published!`.
- Callbacks: use sparingly. `before_validation` and `after_create` are acceptable. Avoid `after_save` with side effects.
- Strong parameters: permit in private controller method `def user_params; params.require(:user).permit(:name, :email); end`.
- I18n: all user-facing strings in `config/locales/`. Use `t(".title")` in views for scoped translations.
- No monkey-patching. Extend classes through concerns and modules.

## Error Handling

- Controller rescue: use `rescue_from` in `ApplicationController` for common exceptions.
- `rescue_from ActiveRecord::RecordNotFound, with: :not_found` → render 404 page.
- `rescue_from ActiveRecord::RecordInvalid, with: :unprocessable_entity` → render errors.
- Flash messages: `flash[:notice]` for success, `flash[:alert]` for errors. Render in layout partial.
- Turbo Stream errors: on validation failure, render the form partial with errors via `turbo_stream.replace`.
- API controllers: render JSON error responses with consistent structure. `render json: { error: { message: "Not found" } }, status: :not_found`.
- Model errors: check `model.errors.full_messages` after failed save. Display in form partial.
- Background job retries: Solid Queue handles retries with exponential backoff. Set `retry_on StandardError, wait: :polynomially_longer, attempts: 5`.
- Log errors with `Rails.logger.error`. Include context (user_id, request_id). Structured logging with `lograge`.

## Testing Conventions

- Minitest, not RSpec. Test files in `test/` mirroring `app/` structure.
- Model tests: test validations, associations, scopes, and custom methods. Test file: `test/models/user_test.rb`.
- Controller tests: test response status, redirects, and flash messages. Test file: `test/controllers/users_controller_test.rb`.
- System tests: Capybara with headless Chrome. Test full user workflows. Test file: `test/system/users_test.rb`.
- Fixtures: YAML files in `test/fixtures/`. Reference with `users(:alice)`. Prefer fixtures over factories for speed.
- Test naming: `test "should create user with valid attributes"`. Descriptive, readable.
- Turbo Stream tests: assert `response.media_type == "text/vnd.turbo-stream.html"`. Assert stream actions with `assert_turbo_stream action: :replace, target: "user_1"`.
- Stimulus controller tests: test via system tests — click button, assert DOM change.
- Integration tests for multi-step workflows: login → create resource → verify listing.
- Test helpers: shared setup in `test_helper.rb`. Include `sign_in(user)` helper for authenticated tests.
- Run tests in parallel: `parallelize(workers: :number_of_processors)` in `test_helper.rb`.

## Database & Migration Patterns

- Migrations: always reversible. Provide `up` and `down` methods or use reversible DSL.
- Adding columns to large tables: use `add_column` (fast) not `change_column` (locks table). Add index concurrently: `add_index :users, :email, algorithm: :concurrently`.
- Never rename or remove columns in a single deploy. Use a multi-step process: (1) add new column, (2) backfill, (3) update code, (4) remove old column.
- Foreign keys: always add `foreign_key: true` on references. `add_reference :posts, :user, foreign_key: true`.
- Null constraints: add `null: false` with a default for existing tables. Never add `null: false` without a default on tables with data.
- UUID primary keys: use `id: :uuid` in `create_table` when needed. Configure generator in model.
- Database seeds: idempotent. Use `find_or_create_by` in seed files.
- Schema.rb: auto-generated. Never edit manually. Commit to version control.
- Connection pooling: `pool: ENV.fetch("RAILS_MAX_THREADS") { 5 }` in `database.yml`.

## Security

- CSRF protection: enabled by default. Turbo handles CSRF tokens automatically in forms and fetch requests. API controllers: `skip_before_action :verify_authenticity_token` with token auth.
- Strong parameters: never use `params.permit!`. Always whitelist fields.
- Authentication: has_secure_password for password hashing. Or Devise with lockable, trackable modules.
- Authorization: Pundit policies or Action Policy. One policy per model. Check in controller: `authorize @user`.
- SQL injection: use ActiveRecord parameterized queries. Never interpolate user input into SQL strings.
- Content Security Policy: configure in `config/initializers/content_security_policy.rb`.
- Mass assignment: strong parameters prevent. Never call `update(params)` directly — always `update(permitted_params)`.

## Deployment

- Kamal 2 for deployment. Configuration in `config/deploy.yml`.
- Docker-based: `Dockerfile` in project root. Multi-stage build for smaller images.
- Precompile assets: `RAILS_ENV=production bin/rails assets:precompile`.
- Database migration: run in deploy hook before restarting app servers.
- Credentials: `bin/rails credentials:edit --environment production`. Never commit master key.
- Health check: `GET /up` returns 200 when app is healthy (Rails 8 default).

## What Claude Should Never Do

- Never generate React, Vue, or Angular components. This project uses Hotwire (Turbo + Stimulus) for all interactivity.
- Never use `Sprockets` or `Webpacker`. This project uses Propshaft for asset pipeline.
- Never use `after_save` callbacks for sending emails or external API calls. Use background jobs.
- Never use `params.permit!` to allow all parameters. Always whitelist specific fields.
- Never create migrations that add `null: false` constraints to existing columns without a default value.
- Never use `find_by_sql` with string interpolation. Use ActiveRecord query methods or parameterized SQL.
- Never skip Turbo Stream responses for create/update/destroy actions on AJAX-submitted forms.
- Never create a Stimulus controller that directly manipulates DOM outside its scope (element + targets).
- Never use `render json:` in controllers that should respond with Turbo Streams. Check `request.format`.
- Never edit files in `db/migrate/` after they have been committed and run. Create a new migration.
- Never use `belongs_to` without `optional: true` if the association is not always present (Rails 8 requires presence by default).

## Project-Specific Context

- [YOUR PROJECT NAME] — update with your project details
- Database: PostgreSQL [RDS / Cloud SQL / Render managed]
- Background jobs: Solid Queue with database backend
- File storage: Active Storage with [S3 / GCS / local disk]
- Email: Action Mailer with [Postmark / SendGrid / SES]
- Deployment: Kamal → [AWS EC2 / Hetzner / DigitalOcean]
- Monitoring: [Sentry / Honeybadger] for errors, [Scout / Skylight] for APM
```
{% endraw %}

## How to Adapt This For Your Project

Start with the **Project Stack** section and match versions to your `Gemfile.lock`. If you use RSpec instead of Minitest, replace the entire Testing section with RSpec conventions (describe blocks, let variables, shared examples). If you still use Sidekiq instead of Solid Queue, update the job patterns. The Hotwire patterns are critical — if your project mixes Hotwire with a React or Vue frontend for certain sections, add explicit boundary rules about which pages use which approach. Keep the migration safety rules regardless of your stack configuration.

## Common CLAUDE.md Mistakes in Rails Projects

1. **Not specifying Hotwire vs SPA.** Without this, Claude generates React components for interactive features instead of Turbo Frames and Stimulus controllers. The result is a hybrid that is harder to maintain than either approach alone.

2. **Missing Turbo Stream response conventions.** Claude generates standard HTML redirects for form submissions instead of `turbo_stream.replace` responses. Specify that create/update/destroy actions must respond to both HTML and Turbo Stream formats.

3. **Allowing raw SQL in migrations.** Without migration safety rules, Claude generates `change_column_null :users, :name, false` on tables with millions of rows, which locks the table for the duration of the update.

4. **Not specifying Stimulus naming conventions.** Claude creates JavaScript controllers with arbitrary names that do not match the `data-controller` attribute Rails expects. The convention is `modal_controller.js` mapping to `data-controller="modal"`.

5. **Using Webpacker references.** Claude was trained on Rails 6/7 code that uses Webpacker extensively. Without explicit guidance that the project uses Propshaft, Claude generates `javascript_pack_tag` calls and webpack configuration.

## What Claude Code Does With This

When this CLAUDE.md is loaded, Claude Code generates Hotwire-native patterns for all interactive features. Forms submit via Turbo with proper Stream responses for inline updates. New interactive behaviors get Stimulus controllers with correct naming conventions. Models use proper scopes, validations, and concerns instead of raw query logic in controllers. Migrations include safety guards (defaults for non-nullable columns, concurrent index creation). Background work routes through Solid Queue jobs instead of inline processing in controllers.

## The Full 16-Template Pack

This is one of 16 production CLAUDE.md templates available in the Lifetime pack. Includes templates for Django + PostgreSQL, Next.js + TypeScript, Laravel + PHP, Go + Gin, and 11 more stacks. Each template is 200-400 lines of production-tested configuration. Get all 16 at [claudecodeguides.com/generator/](https://claudecodeguides.com/generator/).
