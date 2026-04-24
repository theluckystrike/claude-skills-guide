---
layout: default
title: "Claude Code for Python Reflex"
description: "Build full-stack web apps in Python with Reflex and Claude Code. Tested setup with copy-paste CLAUDE.md config."
date: 2026-04-18
permalink: /claude-code-for-python-reflex-workflow-guide/
render_with_liquid: false
categories: [workflow, niche-tools]
tags: [claude-code, reflex, workflow]
---

## The Setup

You are building full-stack web applications in pure Python with Reflex (formerly Pynecone). Reflex compiles Python code to a React frontend and FastAPI backend, letting you write both UI and logic in Python without JavaScript. Claude Code can create web apps, but it generates separate Python backend + React frontend instead of Reflex's unified Python approach.

## What Claude Code Gets Wrong By Default

1. **Creates Flask/FastAPI + React projects.** Claude generates a Python API and a React frontend as separate projects. Reflex combines both — you write Python that compiles to React components automatically.

2. **Uses HTML/JSX for UI.** Claude writes `<div className="container">` in React files. Reflex uses Python function calls: `rx.box(rx.text("Hello"), class_name="container")` — no HTML or JSX.

3. **Manages state with Redux or React hooks.** Claude creates a Redux store or uses useState. Reflex has its own state management: `class State(rx.State)` with Python attributes that automatically sync between frontend and backend.

4. **Creates REST API endpoints for data.** Claude writes `/api/data` endpoints with fetch calls. Reflex state methods are callable from the frontend directly — `State.load_data` becomes a button click handler without API routes.

## The CLAUDE.md Configuration

```
# Reflex Project

## Framework
- Framework: Reflex (full-stack Python web framework)
- Frontend: Python compiled to React
- Backend: Built-in FastAPI server
- State: rx.State class with reactive attributes

## Reflex Rules
- Components: rx.box, rx.text, rx.button, etc.
- State: class State(rx.State) with vars and methods
- Events: on_click=State.method_name for handlers
- Styling: rx.box(style={"color": "red"}) or Tailwind
- Routing: app.add_page(component, route="/path")
- Database: built-in SQLModel integration
- Deploy: reflex deploy or self-host

## Conventions
- State class per page or feature
- Computed vars: @rx.var for derived state
- Event handlers: methods on State class
- Components: pure functions returning rx elements
- Use rx.cond for conditional rendering
- Use rx.foreach for list rendering
- Database models: class User(rx.Model)
```

## Workflow Example

You want to build a dashboard with real-time data updates. Prompt Claude Code:

"Create a Reflex dashboard with a data table showing recent orders, a search input that filters orders, and a refresh button. Use Reflex state for the orders list and search query. Add a computed var for filtered orders and style with Tailwind."

Claude Code should create a `DashboardState(rx.State)` with `orders`, `search_query`, and a `@rx.var` computed `filtered_orders`, event handlers for `set_search` and `refresh_data`, and a component function using `rx.table`, `rx.input`, and `rx.button` with Tailwind styling.

## Common Pitfalls

1. **Using async/await incorrectly in event handlers.** Claude writes `async def load_data(self)` without understanding Reflex's async model. Reflex event handlers can be async, but long-running operations should use `yield` to update the UI progressively.

2. **Direct state mutation from components.** Claude tries to modify state variables outside of event handlers. Reflex state can only be modified inside State class methods — component functions are pure and cannot change state.

3. **Heavy computation blocking the UI.** Claude puts intensive processing in an event handler. Reflex runs handlers server-side — long computations block the user's session. Use background tasks with `@rx.background` for heavy operations.

## Related Guides

- [Best AI Tools for Frontend Development 2026](/best-ai-tools-for-frontend-development-2026/)
- [Best AI Tools for Backend Development 2026](/best-ai-tools-for-backend-development-2026/)
- [Best Way to Set Up Claude Code for New Project](/best-way-to-set-up-claude-code-for-new-project/)

## Related Articles

- [Claude Code for Plotly Dash Python Workflow](/claude-code-for-plotly-dash-python-workflow/)
- [Python Virtualenv Not Activated Fix](/claude-code-python-virtualenv-not-activated-fix-2026/)
