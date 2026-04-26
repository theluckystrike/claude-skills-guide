---
layout: default
title: "Claude MD Example for Elixir Phoenix (2026)"
description: "Claude MD skill examples for Elixir Phoenix applications. Ecto patterns, LiveView components, and Phoenix convention configurations included."
date: 2026-03-14
last_modified_at: 2026-04-17
categories: [tutorials]
tags: [claude-code, claude-skills, elixir, phoenix, markdown]
author: "Claude Skills Guide"
reviewed: true
score: 8
permalink: /claude-md-example-for-elixir-phoenix-application/
last_tested: "2026-04-21"
geo_optimized: true
---
# Claude MD Example for Elixir Phoenix Application

Elixir Phoenix applications benefit significantly from Claude Code's skill system. By creating custom `.md` files in your skills directory, you can teach Claude about Phoenix conventions, Ecto patterns, and LiveView components. This guide provides practical examples and real code snippets for integrating Claude into your Phoenix development workflow. For the complete skill file specification, see the [Claude skill .md format guide](/claude-skill-md-format-complete-specification-guide/).

## Setting Up Claude Skills for Phoenix

The Claude skills system uses Markdown files stored in `~/.claude/skills/`. Each skill is a plain Markdown file that Claude loads when activated. For Phoenix development, you can create a dedicated skill that understands your codebase conventions.

Create a skill file at `~/.claude/skills/phoenix.md`:

```markdown
Phoenix Development Skill

You are an Elixir Phoenix expert. When working on Phoenix projects:

1. Follow the Phoenix directory structure conventions
2. Use Ecto schemas with proper associations and migrations
3. Implement LiveView components for interactive features
4. Write tests using ExUnit with context modules
5. Follow the PhoenixContext pattern for business logic

When generating code, prefer:
- Context modules over direct Ecto calls in controllers
- LiveView for real-time features over Channels for new projects
- Component-based design in `MyAppWeb.Components`
- TailwindCSS classes for styling

Key conventions:
- Contexts go in lib/my_app/*_context.ex
- Controllers go in lib/my_app_web/controllers/
- LiveViews go in lib/my_app_web/live/
- Components go in lib/my_app_web/components/
```

## What to Put in Your Phoenix Skill File

The skill file is not documentation. it is a set of active instructions that shapes every response Claude gives while the skill is loaded. Think of it as a persistent system prompt scoped to Phoenix work. The most useful things to include are:

- Your team's naming conventions (e.g., context module suffix: `MyApp.Blog` not `MyApp.BlogContext`)
- Which libraries you use and which you avoid (e.g., "use `guardian` for auth tokens, never `devise`-style approaches")
- Architectural decisions that are not obvious from Phoenix defaults (e.g., "all background jobs use `Oban`, never `Task.async`")
- The shape of your existing codebase (e.g., "the `MyApp.Mailer` module exists and uses `Swoosh`")

The more project-specific your skill file, the less Claude has to guess. A well-crafted skill file is the difference between Claude generating idiomatic code that passes review on the first try and code that needs significant reworking to fit your patterns.

## Using the Phoenix Skill in Your Projects

Activate the skill in your Claude Code session by typing:

```
/phoenix
```

Then describe your task. For example, you might say:

> "Create a blog system with posts that have comments. Use LiveView for the comment form and Ecto for persistence."

Claude will generate the context, schema, migration, and LiveView components following Phoenix conventions.

## Prompts That Work Well with the Phoenix Skill

The skill sets context, but the prompt drives the output. Here are prompt patterns that consistently produce high-quality Phoenix code:

Generating a full context + schema + migration:
> "Add an `orders` context to the app. Each order belongs to a user and has a status (pending, confirmed, cancelled) and a total in cents. Include a migration, schema with changeset, and context functions for create, list by user, and update status."

Debugging Ecto queries:
> "This Ecto query is returning duplicate rows when I join associations. Here is the query: [paste query]. Why is this happening and how do I fix it?"

LiveView real-time updates:
> "Add PubSub to the OrdersLive.Index view so the list updates in real time when any order status changes. Show me the PubSub subscription and the handle_info callback."

Designing Ecto schemas with complex associations:
> "I need a many-to-many between users and projects with a join table that has a role field (admin, member, viewer). Show me the schemas, the join schema, and the migration."

## Real-World Example: User Authentication Context

Here is an example of what Claude generates when you ask for a complete authentication system:

```elixir
lib/my_app/accounts.ex
defmodule MyApp.Accounts do
 @moduledoc """
 The Accounts context handles user management and authentication.
 """
 alias MyApp.Accounts.{User, UserToken}
 alias MyApp.Repo

 def get_user!(id), do: Repo.get!(User, id)

 def get_user_by_email(email) when is_binary(email) do
 Repo.get_by(User, email: email)
 end

 def change_user_registration(attrs \\ %{}) do
 User.registration_changeset(%User{}, attrs)
 end

 def register_user(attrs) do
 result =
 Multi.new()
 |> Multi.insert(:user, User.registration_changeset(%User{}, attrs))
 |> Multi.run(:user_token, fn _repo, %{user: user} ->
 UserToken.build_email_token(user, "confirm")
 end)
 |> Repo.transaction()

 case result do
 {:ok, %{user: user, user_token: user_token}} ->
 {:ok, user}

 {:error, :user, changeset, _} ->
 {:error, changeset}
 end
 end
end
```

This follows the PhoenixContext pattern perfectly, keeping Ecto calls behind the context boundary. Notice the use of `Ecto.Multi` for the registration transaction. this pattern ensures the user record and the email confirmation token are created atomically. If the token creation fails, the user insert is rolled back. Claude generates this pattern reliably when your skill file specifies "use Ecto.Multi for operations that involve multiple database writes."

## Adding the User Schema and Changeset

A complete authentication system needs the schema alongside the context. Ask Claude to generate both together:

```elixir
lib/my_app/accounts/user.ex
defmodule MyApp.Accounts.User do
 use Ecto.Schema
 import Ecto.Changeset

 schema "users" do
 field :email, :string
 field :hashed_password, :string, redact: true
 field :confirmed_at, :naive_datetime
 field :password, :string, virtual: true, redact: true

 timestamps(type: :utc_datetime)
 end

 def registration_changeset(user, attrs, opts \\ []) do
 user
 |> cast(attrs, [:email, :password])
 |> validate_email(opts)
 |> validate_password(opts)
 end

 defp validate_email(changeset, opts) do
 changeset
 |> validate_required([:email])
 |> validate_format(:email, ~r/^[^\s]+@[^\s]+$/, message: "must have the @ sign and no spaces")
 |> validate_length(:email, max: 160)
 |> maybe_validate_unique_email(opts)
 end

 defp validate_password(changeset, opts) do
 changeset
 |> validate_required([:password])
 |> validate_length(:password, min: 12, max: 72)
 |> maybe_hash_password(opts)
 end

 defp maybe_hash_password(changeset, opts) do
 hash_password? = Keyword.get(opts, :hash_password, true)

 if hash_password? && changeset.valid? do
 changeset
 |> put_change(:hashed_password, Bcrypt.hash_pwd_salt(get_change(changeset, :password)))
 |> delete_change(:password)
 else
 changeset
 end
 end

 defp maybe_validate_unique_email(changeset, opts) do
 if Keyword.get(opts, :validate_email, true) do
 changeset
 |> unsafe_validate_unique(:email, MyApp.Repo)
 |> unique_constraint(:email)
 else
 changeset
 end
 end
end
```

The `redact: true` field option is a Phoenix 1.7+ convention that prevents password hashes from appearing in logs and inspect output. Claude knows these conventions when your skill file specifies which Phoenix version you are targeting.

## Combining Skills for Better Results

You can activate multiple skills for complex tasks. For a Phoenix application with comprehensive testing, activate both the phoenix and [tdd skills](/claude-tdd-skill-test-driven-development-workflow/):

```
/phoenix
/tdd
```

The tdd skill guides Claude to write tests first, then implement the code. When working on a new Phoenix context, Claude will generate the schema, context functions, and corresponding tests in `test/my_app/accounts_test.exs`.

## ExUnit Test Examples

With both skills active, asking for a context generates tests alongside the implementation:

```elixir
test/my_app/accounts_test.exs
defmodule MyApp.AccountsTest do
 use MyApp.DataCase

 alias MyApp.Accounts

 describe "register_user/1" do
 test "registers a user with valid data" do
 valid_attrs = %{email: "test@example.com", password: "valid_password123"}
 assert {:ok, user} = Accounts.register_user(valid_attrs)
 assert user.email == "test@example.com"
 assert is_nil(user.hashed_password) == false
 end

 test "returns error changeset with invalid email" do
 assert {:error, changeset} = Accounts.register_user(%{email: "not-an-email", password: "valid_password123"})
 assert %{email: ["must have the @ sign and no spaces"]} = errors_on(changeset)
 end

 test "returns error changeset with short password" do
 assert {:error, changeset} = Accounts.register_user(%{email: "test@example.com", password: "short"})
 assert %{password: ["should be at least 12 character(s)"]} = errors_on(changeset)
 end

 test "returns error changeset with duplicate email" do
 _ = Accounts.register_user(%{email: "test@example.com", password: "valid_password123"})
 assert {:error, changeset} = Accounts.register_user(%{email: "test@example.com", password: "another_password"})
 assert %{email: ["has already been taken"]} = errors_on(changeset)
 end
 end
end
```

The test structure follows Phoenix conventions: `DataCase` for database tests, `errors_on/1` helper from `MyApp.DataCase` for readable assertions, and `describe` blocks grouped by function. Claude generates this pattern consistently when the tdd skill is active alongside the phoenix skill.

## Generating Documentation with the PDF Skill

When you need to document your Phoenix API, the pdf skill can help generate comprehensive documentation. Activate it alongside your phoenix skill:

```
/phoenix
/pdf
```

This combination is useful for creating API documentation that you can share with external consumers of your Phoenix JSON API.

## Managing Project Context with Super Memory

For ongoing Phoenix projects, the [supermemory skill helps Claude remember your project structure](/claude-supermemory-skill-persistent-context-explained/) and conventions across sessions:

```
/phoenix
/supermemory
```

This is particularly useful when working on larger Phoenix applications with multiple contexts and custom conventions. Claude will remember which patterns you prefer and apply them consistently.

## Encoding Project-Specific Knowledge in Your Skill

As your project grows, update the skill file to capture decisions made:

```markdown
Phoenix Development Skill. MyApp

Project Structure
- Contexts: lib/my_app/ (Accounts, Catalog, Orders, Notifications)
- API controllers: lib/my_app_web/controllers/api/v1/
- Admin LiveViews: lib/my_app_web/live/admin/
- Public LiveViews: lib/my_app_web/live/public/

Established Patterns
- All monetary values stored in cents (integer), displayed using Money module
- Background jobs use Oban. never Task.async for user-triggered work
- Emails sent via MyApp.Mailer (Swoosh + Mailgun adapter)
- Feature flags checked via MyApp.FeatureFlags.enabled?/2
- All API responses use MyAppWeb.APIView.render_success/2 and render_error/2

Testing Conventions
- Use ExMachina factories in test/support/factories/
- Stub external HTTP with Bypass in integration tests
- All Oban jobs tested with perform_job/2 helper
```

This kind of accumulated knowledge in the skill file is the difference between Claude generating code that could work anywhere versus code that fits smoothly into your specific codebase.

## LiveView Component Examples

Here is a practical LiveView component that Claude might generate for a Phoenix application:

```elixir
defmodule MyAppWeb.ProductLive.Index do
 use MyAppWeb, :live_view

 alias MyApp.Catalog
 alias MyApp.Catalog.Product

 @impl true
 def mount(_params, _session, socket) do
 {:ok, stream_new(socket, :products, Catalog.list_products())}
 end

 @impl true
 def handle_params(params, _url, socket) do
 {:noreply, apply_action(socket, socket.assigns.live_action, params)}
 end

 defp apply_action(socket, :edit, %{"id" => id}) do
 socket
 |> assign(:page_title, "Edit Product")
 |> assign(:product, Catalog.get_product!(id))
 end

 defp apply_action(socket, :new, _params) do
 socket
 |> assign(:page_title, "New Product")
 |> assign(:product, %Product{})
 end

 defp apply_action(socket, :index, _params) do
 socket
 |> assign(:page_title, "Listing Products")
 |> assign(:product, nil)
 end
end
```

This follows the current Phoenix LiveView conventions, including the use of `stream_new` for efficient list rendering.

## Adding Real-Time Updates to the LiveView

The component above renders a static list. To make it update in real time when products change, ask Claude to add PubSub integration:

```elixir
defmodule MyAppWeb.ProductLive.Index do
 use MyAppWeb, :live_view

 alias MyApp.Catalog
 alias MyApp.Catalog.Product

 @impl true
 def mount(_params, _session, socket) do
 if connected?(socket) do
 Phoenix.PubSub.subscribe(MyApp.PubSub, "catalog:products")
 end

 {:ok, stream(socket, :products, Catalog.list_products())}
 end

 @impl true
 def handle_info({:product_created, product}, socket) do
 {:noreply, stream_insert(socket, :products, product, at: 0)}
 end

 @impl true
 def handle_info({:product_updated, product}, socket) do
 {:noreply, stream_insert(socket, :products, product)}
 end

 @impl true
 def handle_info({:product_deleted, product}, socket) do
 {:noreply, stream_delete(socket, :products, product)}
 end

 # ... handle_params and apply_action unchanged
end
```

The `connected?(socket)` guard ensures subscriptions only happen for connected LiveView processes, not the static render. Claude generates this pattern correctly when you ask: "Add real-time updates to this LiveView using PubSub so inserts, updates, and deletes are reflected without a page reload."

## Skill File Maintenance Over Time

A Phoenix skill file has a useful lifespan proportional to how actively you maintain it. As Phoenix releases new major versions and your application grows, the skill should evolve too.

Treat skill file updates like code reviews. When Claude generates something and you have to correct it, add the correction as a rule to the skill file. Over time this builds a compendium of your team's preferences:

```markdown
DO NOT DO
- Do not use `Repo.all/1` directly in controllers. use context functions
- Do not use `Phoenix.Token` for user auth. we use Guardian
- Do not create new Channels. use LiveView for all real-time features
- Do not use `Logger.warn`. use `Logger.warning` (Elixir 1.15+)
```

Negative rules ("do not") are often more useful than positive ones because they address the specific patterns Claude defaults to that do not match your codebase.

## Key Takeaways

Creating a custom Claude skill for Phoenix development significantly improves the quality and consistency of generated code. The skill file acts as a set of instructions that Claude follows when working on your Elixir projects.

Remember these key points:

- Skills are plain Markdown files stored in `~/.claude/skills/`
- You can combine multiple skills for complex workflows
- The tdd skill works well with Phoenix for test-driven development
- Use the supermemory skill to maintain context across sessions
- Customize your skill to match your team's conventions
- Update the skill file when Claude generates something you have to correct
- Negative rules ("do not use X") are often as valuable as positive ones

By investing time in creating a well-crafted Phoenix skill, you accelerate development velocity while maintaining code quality standards across your team.

---


**Try it:** Paste your error into our [Error Diagnostic](/diagnose/) for an instant fix.
---

<div class="mastery-cta">

This site was built by 5 autonomous agents running in tmux while I was in Bali. 2,500 articles. Zero manual work. 100% quality gate pass rate.

The orchestration configs, sprint templates, and quality gates that made that possible are in the Zovo Lifetime bundle. Along with 16 CLAUDE.md templates and 80 tested prompts.

**[See how the pipeline works →](https://zovo.one/lifetime?utm_source=ccg&utm_medium=cta-skills&utm_campaign=claude-md-example-for-elixir-phoenix-application)**

$99 once. I'm a solo dev in Da Nang. This is how I scale.

</div>

Related Reading

- [Claude Skill .md Format: Complete Specification Guide](/claude-skill-md-format-complete-specification-guide/). Reference the full skill file specification when authoring your Phoenix-specific skill
- [How to Write a Skill .md File for Claude Code](/how-to-write-a-skill-md-file-for-claude-code/). Step-by-step guidance for writing skill bodies that teach Claude framework conventions
- [Claude TDD Skill: Test-Driven Development Workflow](/claude-tdd-skill-test-driven-development-workflow/). Combine the tdd skill with your Phoenix skill for ExUnit test-first development
- [Claude Skills Getting Started Hub](/getting-started-hub/). Learn skill loading and invocation patterns before building your custom Phoenix skill

Built by theluckystrike. More at [zovo.one](https://zovo.one)


**Find the right skill →** Browse 155+ skills in our [Skill Finder](/skill-finder/).

