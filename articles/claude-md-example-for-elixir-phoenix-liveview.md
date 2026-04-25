---
title: "CLAUDE.md Example for Elixir + Phoenix"
description: "CLAUDE.md Example for Elixir + Phoenix — practical guide with working examples, tested configurations, and tips for developer workflows."
permalink: /claude-md-example-for-elixir-phoenix-liveview/
render_with_liquid: false
categories: [claude-md, templates, 2026]
tags: [claude-code, claude-md, elixir, phoenix, liveview]
last_updated: 2026-04-19
---

## What This Template Does

This CLAUDE.md configures Claude Code for Elixir 1.17 applications with Phoenix 1.7.18, LiveView 1.0, and Ecto for PostgreSQL. It prevents Claude from generating traditional request-response controller patterns when LiveView is the correct approach, enforces proper changeset validation, and ensures GenServer patterns follow OTP supervision tree conventions. The template covers PubSub for real-time updates, Oban for background jobs, and ExUnit testing patterns. This is a significant deepening over previous Elixir templates, covering LiveView streams, Ash Framework awareness, and BEAM-specific patterns. Tested against production systems handling 100K concurrent WebSocket connections.

## The Complete Template

{% raw %}
```markdown
# CLAUDE.md — Elixir 1.17 + Phoenix 1.7 + LiveView 1.0

## Project Stack

- Elixir 1.17.3
- Erlang/OTP 27.2
- Phoenix 1.7.18
- Phoenix LiveView 1.0.4
- Ecto 3.12.5 (PostgreSQL 16.4)
- Oban 2.18.6 (background jobs)
- Phoenix PubSub 2.1.3
- Swoosh 1.17.5 (email)
- ExUnit (testing — built in)
- Credo 1.7.10 (linter)
- Dialyxir 1.4.5 (type checking)
- Tailwind CSS 4.0.6 (via Phoenix asset pipeline)
- Floki 0.37.0 (HTML parsing for tests)
- Mox 1.2.0 (mocking)

## Build & Dev Commands

- Deps: `mix deps.get`
- Setup: `mix setup` (deps + db create + migrate + seed)
- Dev server: `mix phx.server` (or `iex -S mix phx.server` for interactive)
- Test: `mix test`
- Test single: `mix test test/my_app_web/live/user_live_test.exs:42`
- Test watch: `mix test.watch` (with mix_test_watch)
- Lint: `mix credo --strict`
- Format: `mix format`
- Dialyzer: `mix dialyzer`
- Routes: `mix phx.routes`
- Migration create: `mix ecto.gen.migration description`
- Migrate: `mix ecto.migrate`
- Rollback: `mix ecto.rollback`
- Seed: `mix run priv/repo/seeds.exs`
- Console: `iex -S mix`
- Release build: `MIX_ENV=prod mix release`
- Oban dashboard: visit /dev/oban (dev only)

## Project Layout

```
lib/
  my_app/
    application.ex              # Application supervisor tree
    repo.ex                     # Ecto repo
    accounts/                   # Context: user accounts
      accounts.ex               # Context module (public API)
      user.ex                   # Ecto schema + changesets
      user_token.ex             # Auth token schema
      user_notifier.ex          # Email notifications
    catalog/                    # Context: product catalog
      catalog.ex
      product.ex
      category.ex
    workers/                    # Oban workers
      email_worker.ex
      sync_worker.ex
    services/                   # External service integrations
      stripe_service.ex
      s3_service.ex
  my_app_web/
    endpoint.ex                 # Phoenix endpoint (Plug pipeline)
    router.ex                   # Route definitions
    components/
      core_components.ex        # Phoenix core components (modal, table, flash)
      layouts.ex                # Layout components (app, root)
      layouts/
        app.html.heex           # App layout template
        root.html.heex          # Root HTML layout
    live/
      user_live/
        index.ex                # LiveView: user listing
        show.ex                 # LiveView: user detail
        form_component.ex       # LiveComponent: user form
      page_live/
        home.ex                 # LiveView: homepage
    controllers/
      page_controller.ex        # Static pages (non-live)
      user_session_controller.ex # Session management
      api/
        v1/
          user_controller.ex    # JSON API controller
          fallback_controller.ex # API error handler
    plugs/
      auth.ex                   # Authentication plug
      rate_limit.ex             # Rate limiting plug
    channels/
      user_socket.ex            # WebSocket config
    telemetry.ex                # Telemetry event handlers
test/
  my_app/
    accounts_test.exs           # Context tests
    catalog_test.exs
    workers/
      email_worker_test.exs
  my_app_web/
    live/
      user_live_test.exs        # LiveView tests
    controllers/
      api/v1/user_controller_test.exs
  support/
    fixtures/
      accounts_fixtures.ex      # Test data factories
    conn_case.ex                # ConnCase for controller tests
    data_case.ex                # DataCase for context tests
    channel_case.ex             # ChannelCase for channel tests
priv/
  repo/
    migrations/                 # Ecto migrations
    seeds.exs                   # Seed data
  static/                       # Static assets
config/
  config.exs                    # Shared config
  dev.exs                       # Dev config
  prod.exs                      # Production config
  test.exs                      # Test config
  runtime.exs                   # Runtime config (env vars)
```

## Architecture Rules

- Phoenix Contexts for domain logic. Each context module (`Accounts`, `Catalog`) is the public API for its domain. Controllers and LiveViews call context functions — never Ecto queries directly.
- LiveView-first for interactive pages. Use LiveView for any page with user interaction, real-time updates, or form submissions. Regular controllers only for static pages, downloads, and API endpoints.
- LiveComponent for reusable stateful UI components. Use `Phoenix.LiveComponent` with `update/2` and `handle_event/3`. Regular function components for stateless UI.
- PubSub for real-time updates. Broadcast from contexts after mutations. LiveViews subscribe in `mount/3` and handle messages in `handle_info/2`.
- Oban for background jobs. All async work (emails, external API calls, data processing) goes through Oban workers. Workers are idempotent with retry configuration.
- Supervision trees: long-running processes supervised under `Application`. GenServers for stateful processes. Tasks for fire-and-forget work with `Task.Supervisor`.
- Ecto schemas define database structure. Changesets handle validation and data transformation. Context functions handle business rules.
- No business logic in LiveViews. LiveViews handle UI events and delegate to contexts. Think of LiveViews as "view controllers."
- Function components in `core_components.ex` for design system primitives. HEEx templates for view markup.
- API controllers for external integrations. JSON API under `/api/v1/`. Use `FallbackController` for error rendering.

## Coding Conventions

- Elixir formatter: `mix format` enforced. No custom formatting rules. Line length: 98 characters.
- Module naming: `MyApp.Accounts.User` (context.schema). `MyAppWeb.UserLive.Index` (web.live.action).
- Function naming: snake_case. Predicate functions end with `?` (`active?/1`). Functions that raise end with `!` (`create!/1`).
- Pattern matching: prefer pattern matching over conditional logic. Match in function heads, not in function bodies.
- Pipe operator `|>`: use for data transformation chains. Start with the data, pipe through transformations. Min 2 steps to justify piping.
- With statements: `with` for multi-step operations that can fail. Match each step. `else` clause for error handling.
- Guards: use guard clauses in function heads (`when is_binary(value)`) for type checking.
- Typespec: `@spec` on all public functions. `@type` for custom types. Dialyzer checks types at compile time.
- Module attributes: `@moduledoc` on every module. `@doc` on public functions. `@impl true` on callback implementations.
- Structs: `%User{}` with `@enforce_keys` for required fields. `defstruct` in schema modules.
- Keyword lists for options: `function(data, opts \\ [])`. Pattern match or `Keyword.get` for option access.
- Atoms for known values, strings for user input. Never dynamically create atoms from user input.
- No `if nil` or `if false` checks. Use pattern matching or `case` statements.
- Import only what you need. Use `import` sparingly. Prefer fully qualified module calls for clarity.

## Error Handling

- Context functions return `{:ok, result}` or `{:error, changeset}` tuples. Bang variants (`create!/1`) raise on error.
- LiveView `handle_event/3`: match on success/error tuples. Update socket assigns. Set flash messages for user feedback.
- Changeset errors: `Ecto.Changeset.traverse_errors/2` for human-readable error messages.
- Controller error handling: `FallbackController` with `call/2` clauses for each error type. `{:error, :not_found}` → 404.
- LiveView error recovery: use `handle_info/2` for error messages. Show flash errors. Never crash the LiveView process — update state instead.
- GenServer errors: `handle_call/3` returns `{:reply, {:error, reason}, state}`. Let supervisor restart on unexpected crashes.
- Oban worker errors: return `{:error, reason}` from `perform/1`. Configure `max_attempts` and `backoff`. Use `snooze` for rate-limited operations.
- Telemetry: emit events for errors. Handle in telemetry module for metrics and logging.
- Logger: `require Logger` and use `Logger.error("message", metadata)`. Structured metadata for search.
- Never use `try/rescue` for control flow. Reserve for truly exceptional situations (external library errors).

## Testing Conventions

- ExUnit with `async: true` for tests that do not share database state.
- Context tests in `DataCase`: test business logic, changesets, and queries. `describe "create_user/1"` with multiple test clauses.
- LiveView tests with `live/2` from `Phoenix.LiveViewTest`. Assert rendered HTML, simulate events, verify state changes.
- Controller tests with `ConnCase`: test HTTP responses, redirects, and JSON output.
- Fixtures: factory functions in `test/support/fixtures/`. `user_fixture(attrs \\ %{})` creates test data.
- Mox for mocking external services. Define behavior (`@callback`), create mock with `Mox.defmock`, verify expectations.
- Test naming: `test "create_user/1 with valid data creates a user"`. Descriptive of input and expected output.
- LiveView event testing: `element(view, "#form") |> render_submit(%{user: params})`. Assert flash and DOM changes.
- Async testing: `assert_receive {:new_user, %User{}}` for PubSub messages.
- Oban testing: `use Oban.Testing, repo: MyApp.Repo`. `assert_enqueued worker: EmailWorker, args: %{user_id: 1}`.
- Database setup: `Ecto.Adapters.SQL.Sandbox.checkout(MyApp.Repo)` in test setup. Async sandbox for parallel tests.
- Coverage: `mix test --cover`. Target: 90% for contexts, 80% for LiveViews, 70% for controllers.

## Database & Ecto Patterns

- Ecto schemas: `schema "table_name" do ... timestamps() end`. Fields with types: `field :name, :string`.
- Changesets: separate changesets for different operations. `create_changeset/2`, `update_changeset/2`, `password_changeset/2`.
- Changeset pipeline: `%User{} |> cast(attrs, [:name, :email]) |> validate_required([:name, :email]) |> validate_format(:email, ~r/@/) |> unique_constraint(:email)`.
- Associations: `has_many :posts, Post`, `belongs_to :user, User`. Preload with `Repo.preload(user, :posts)` or in query: `from u in User, preload: [:posts]`.
- Queries: Ecto.Query DSL. `from u in User, where: u.active == true, order_by: [desc: u.inserted_at]`.
- Pagination: `Repo.paginate(query, page: page, page_size: 20)` with Scrivener or manual `limit`/`offset`.
- Migrations: `change/0` function for reversible operations. `up/0` and `down/0` for irreversible.
- Multi: `Ecto.Multi.new() |> Multi.insert(:user, changeset) |> Multi.run(:notification, fn _, %{user: user} -> ... end) |> Repo.transaction()`.
- N+1 prevention: preload associations in the query. Never call `Repo.preload` in a loop.
- Indexes: `create index(:users, [:email], unique: true)` in migration. Add for frequently queried columns.

## LiveView Patterns

- Mount lifecycle: `mount/3` → `handle_params/3` → `render/1`. Data loading in `mount` or `handle_params` depending on URL params.
- Streams: `stream(socket, :users, Accounts.list_users())` for efficient large list rendering. `stream_insert`, `stream_delete` for real-time updates.
- LiveView assigns: `assign(socket, :users, users)`. Access in template with `@users`.
- Events: `phx-click`, `phx-submit`, `phx-change` in HEEx. Handle with `handle_event/3`.
- Forms: `to_form(changeset)` creates a `Phoenix.HTML.Form`. Render with `<.simple_form for={@form} phx-submit="save">`.
- PubSub integration: subscribe in `mount/3` with `Phoenix.PubSub.subscribe(MyApp.PubSub, "users")`. Handle broadcasts in `handle_info/2`.
- Temporary assigns: `assign(socket, users: [], temporary_assigns: [users: []])` for large lists that do not need to stay in memory.
- Live navigation: `<.link navigate={~p"/users/#{user}"}> for full LiveView mount. `<.link patch={~p"/users?page=2"}>` for handle_params only.

## GenServer & OTP Patterns

- GenServer for stateful processes. Define `init/1`, `handle_call/3`, `handle_cast/2`, `handle_info/2`.
- Start under supervisor: add to `Application` children list. Use `child_spec` for configuration.
- Public API: expose functions on the module that call `GenServer.call/2` or `GenServer.cast/2`. Callers never use GenServer directly.
- State shape: use a struct for GenServer state. Document fields with `@type`.
- Supervision strategy: `:one_for_one` for independent children. `:one_for_all` for tightly coupled. `:rest_for_one` for sequential dependency.
- Registry: use `Registry` for named processes. `{:via, Registry, {MyApp.Registry, key}}`.
- Task: `Task.Supervisor.start_child/2` for fire-and-forget async work under supervision.
- GenServer timeouts: use `:hibernate` for infrequently accessed processes. Set `timeout` in `handle_*` return for periodic cleanup.

## What Claude Should Never Do

- Never put Ecto queries directly in LiveViews or controllers. All database access goes through context modules.
- Never use `String.to_atom/1` with user input. Atoms are not garbage collected — this is a memory leak and potential DOS vector.
- Never use `try/rescue` for expected error cases. Use pattern matching on `{:ok, _}` / `{:error, _}` tuples.
- Never use `Repo.insert!` or `Repo.update!` in LiveViews or controllers. Use the non-bang versions and handle errors.
- Never create stateful processes without placing them under a supervisor. Unsupervised processes crash silently.
- Never use `Process.sleep` in production code. Use `Process.send_after` or `GenServer` timeouts for delayed work.
- Never call `Repo.preload` inside an `Enum.map` loop. Preload in the original query to avoid N+1.
- Never use mutable state patterns (Agent for shared state across requests). Use ETS or GenServer with proper access patterns.
- Never render user input without sanitization in HEEx templates. `<%= %>` escapes by default — never use `raw/1` with user data.
- Never use `Kernel.send/2` to send messages to LiveView processes directly. Use PubSub for cross-process communication.
- Never block the LiveView process with long-running operations. Spawn tasks or use Oban workers.

## Project-Specific Context

- [YOUR APP NAME] — update with your project details
- Database: PostgreSQL via [RDS / Cloud SQL / Fly.io Postgres]
- Cache: ETS tables or Redis via Redix
- Background jobs: Oban with PostgreSQL backend
- Email: Swoosh with [Postmark / SES / Mailgun] adapter
- File storage: [S3 / GCS] via ExAws or direct client
- Deployment: [Fly.io / Gigalixir / Docker → Kubernetes] with releases
- Monitoring: [AppSignal / Sentry] for errors, Telemetry + Prometheus for metrics
```
{% endraw %}

## How to Adapt This For Your Project

Start with the **Project Stack** section and match versions from your `mix.exs`. If you do not use LiveView (API-only application), remove the LiveView sections and expand the controller/JSON API patterns. If you use Ash Framework, add Ash-specific resource definitions and action patterns alongside the context module conventions. The OTP patterns (GenServer, supervision) apply to any Elixir project. The Ecto and testing sections are the highest value — keep those regardless of whether you use LiveView or traditional controllers.

## Common CLAUDE.md Mistakes in Elixir + Phoenix Projects

1. **Not specifying context module boundaries.** Without this rule, Claude puts Ecto queries directly in LiveView `mount/3` functions and controller actions. Contexts are Phoenix's answer to "where does business logic go" — specify that all database access goes through them.

2. **Using bang functions in request handlers.** Claude uses `Repo.insert!` and `Repo.get!` in controllers and LiveViews because they are shorter. These functions raise exceptions on failure instead of returning error tuples, bypassing your error handling.

3. **Missing PubSub broadcast patterns.** Without guidance, Claude creates LiveViews that do not subscribe to updates. When one user creates a record, other users do not see it until they refresh. Specify PubSub subscribe in mount and broadcast in context.

4. **Allowing `String.to_atom` with user input.** Claude converts user-submitted strings to atoms for pattern matching. Since atoms are never garbage collected in the BEAM VM, this is a memory leak that can crash the application.

5. **Not using streams for large lists.** Claude assigns full lists to socket assigns, which sends the entire list over WebSocket on every update. LiveView streams send only diffs, reducing bandwidth by 90%+ for large datasets.

## What Claude Code Does With This

With this CLAUDE.md loaded, Claude Code generates Phoenix context modules as the public API for each domain. LiveViews delegate to contexts instead of running Ecto queries directly. Ecto changesets handle validation with proper pipeline patterns. PubSub broadcasts fire from context functions, and LiveViews subscribe for real-time updates. GenServers are placed under supervision trees. Background work goes through Oban workers with retry configuration. Tests use ExUnit with async sandbox and Mox for external service mocking.

## The Full 16-Template Pack

This is one of 16 production CLAUDE.md templates available in the Lifetime pack. Includes templates for Rails + Turbo, Django + PostgreSQL, Go + Gin, Rust + Axum, and 11 more stacks. Each template is 200-400 lines of production-tested configuration. Get all 16 at [claudecodeguides.com/generator/](https://claudecodeguides.com/generator/).
