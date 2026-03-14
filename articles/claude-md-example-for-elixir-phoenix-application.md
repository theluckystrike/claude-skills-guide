---
layout: default
title: "Claude MD Example for Elixir Phoenix Application"
description: "A practical guide to using Claude Code with Elixir Phoenix. Real skill examples, code snippets, and workflow patterns for Phoenix developers."
date: 2026-03-14
categories: [tutorials]
tags: [claude-code, elixir, phoenix, markdown, skill]
author: theluckystrike
permalink: /claude-md-example-for-elixir-phoenix-application/
---

# Claude MD Example for Elixir Phoenix Application

Elixir Phoenix applications benefit significantly from Claude Code's skill system. By creating custom `.md` files in your skills directory, you can teach Claude about Phoenix conventions, Ecto patterns, and LiveView components. This guide provides practical examples and real code snippets for integrating Claude into your Phoenix development workflow.

## Setting Up Claude Skills for Phoenix

The Claude skills system uses Markdown files stored in `~/.claude/skills/`. Each skill is a plain Markdown file that Claude loads when activated. For Phoenix development, you can create a dedicated skill that understands your codebase conventions.

Create a skill file at `~/.claude/skills/phoenix.md`:

```markdown
# Phoenix Development Skill

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

## Using the Phoenix Skill in Your Projects

Activate the skill in your Claude Code session by typing:

```
/phoenix
```

Then describe your task. For example, you might say:

> "Create a blog system with posts that have comments. Use LiveView for the comment form and Ecto for persistence."

Claude will generate the context, schema, migration, and LiveView components following Phoenix conventions.

## Real-World Example: User Authentication Context

Here is an example of what Claude generates when you ask for a complete authentication system:

```elixir
# lib/my_app/accounts.ex
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

This follows the PhoenixContext pattern perfectly, keeping Ecto calls behind the context boundary.

## Combining Skills for Better Results

You can activate multiple skills for complex tasks. For a Phoenix application with comprehensive testing, activate both the phoenix and tdd skills:

```
/phoenix
/tdd
```

The tdd skill guides Claude to write tests first, then implement the code. When working on a new Phoenix context, Claude will generate the schema, context functions, and corresponding tests in `test/my_app/accounts_test.exs`.

## Generating Documentation with the PDF Skill

When you need to document your Phoenix API, the pdf skill can help generate comprehensive documentation. Activate it alongside your phoenix skill:

```
/phoenix
/pdf
```

This combination is useful for creating API documentation that you can share with external consumers of your Phoenix JSON API.

## Managing Project Context with Super Memory

For ongoing Phoenix projects, the supermemory skill helps Claude remember your project structure and conventions across sessions:

```
/phoenix
/supermemory
```

This is particularly useful when working on larger Phoenix applications with multiple contexts and custom conventions. Claude will remember which patterns you prefer and apply them consistently.

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

## Key Takeaways

Creating a custom Claude skill for Phoenix development significantly improves the quality and consistency of generated code. The skill file acts as a set of instructions that Claude follows when working on your Elixir projects.

Remember these key points:

- Skills are plain Markdown files stored in `~/.claude/skills/`
- You can combine multiple skills for complex workflows
- The tdd skill works well with Phoenix for test-driven development
- Use the supermemory skill to maintain context across sessions
- Customize your skill to match your team's conventions

By investing time in creating a well-crafted Phoenix skill, you accelerate development velocity while maintaining code quality standards across your team.

Built by theluckystrike — More at [zovo.one](https://zovo.one)
