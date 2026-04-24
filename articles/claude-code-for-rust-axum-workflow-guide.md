---
layout: default
title: "Claude Code for Rust Axum"
description: "Build async web APIs with Axum and Claude Code. Tested setup with copy-paste CLAUDE.md config."
date: 2026-04-18
permalink: /claude-code-for-rust-axum-workflow-guide/
render_with_liquid: false
categories: [workflow, niche-tools]
tags: [claude-code, axum, workflow]
---

## The Setup

You are building a web API with Axum, the ergonomic Rust web framework built on Tokio and Tower. Axum uses extractors for type-safe request handling and the Tower middleware ecosystem. Claude Code can write Axum handlers, but it generates Actix-web or Rocket syntax and misunderstands Axum's extractor-based design.

## What Claude Code Gets Wrong By Default

1. **Uses Actix-web handler signatures.** Claude writes `async fn handler(req: HttpRequest) -> HttpResponse`. Axum uses extractors: `async fn handler(Json(body): Json<CreateUser>) -> impl IntoResponse`.

2. **Creates Rocket-style route attributes.** Claude writes `#[get("/users/<id>")]`. Axum uses a router builder: `Router::new().route("/users/:id", get(handler))` — no procedural macros on handlers.

3. **Misses shared state with extractors.** Claude passes database pools through function arguments. Axum uses `State(pool): State<Pool>` extractor to access shared state from the router.

4. **Uses `actix_web::web::Json` or manual deserialization.** Claude writes manual serde deserialization. Axum's `Json<T>` extractor automatically deserializes and validates request bodies, returning proper error responses.

## The CLAUDE.md Configuration

```
# Axum Web API Project

## Framework
- Web: Axum (Tokio-based, extractor pattern)
- Async: Tokio runtime
- Middleware: Tower ecosystem
- Serialization: Serde (serde, serde_json)

## Axum Rules
- Handlers: async fn(extractors) -> impl IntoResponse
- Extractors: Json<T>, Path<T>, Query<T>, State<T>
- Router: Router::new().route("/path", get(handler).post(other))
- State: Router::new().with_state(app_state)
- Error handling: custom error type implementing IntoResponse
- Middleware: tower layers (cors, timeout, compression)
- No macros on handlers — plain async functions

## Conventions
- Routes in src/routes/ directory (mod.rs per domain)
- Handlers return Result<Json<T>, AppError>
- Shared state in src/state.rs (AppState struct)
- Error type in src/error.rs implementing IntoResponse
- Middleware layers added to router or route groups
- Database pool in AppState, accessed via State extractor
- Use #[derive(Deserialize)] for request types
- Use #[derive(Serialize)] for response types
```

## Workflow Example

You want to create CRUD endpoints with error handling. Prompt Claude Code:

"Create Axum CRUD handlers for a users resource with proper error handling. Include extractors for JSON body parsing, path parameters, and shared database state. Return appropriate HTTP status codes for success and error cases."

Claude Code should write handlers like `async fn create_user(State(db): State<DbPool>, Json(body): Json<CreateUser>) -> Result<(StatusCode, Json<User>), AppError>`, implement the `AppError` type with `IntoResponse`, and build the router with `.route("/users", post(create_user).get(list_users))`.

## Common Pitfalls

1. **Extractor ordering matters.** Claude puts `Json<T>` before `State<T>` without realizing that `Json` consumes the request body. In Axum, extractors that consume the body must come last in the function signature.

2. **Missing `#[derive(Clone)]` on state.** Claude defines `AppState` without Clone. Axum requires state to be `Clone + Send + Sync + 'static`. Use `Arc<AppState>` or derive `Clone` on the state struct.

3. **Forgetting to handle extractor errors.** Claude uses `Json<T>` but does not customize the rejection response. When deserialization fails, Axum returns a generic 422. Implement a custom rejection handler with `#[derive(Debug)]` on your error type for better error messages.

## Related Guides

- [Building a REST API with Claude Code Tutorial](/building-a-rest-api-with-claude-code-tutorial/)
- [Using Claude Code to Learn New Programming Languages](/using-claude-code-to-learn-new-programming-languages/)
- [Best AI Tools for Backend Development 2026](/best-ai-tools-for-backend-development-2026/)

## Related Articles

- [Claude Code For Zksync Era — Complete Developer Guide](/claude-code-for-zksync-era-workflow-guide/)
- [Claude Code for ctags Configuration Workflow Tutorial](/claude-code-for-ctags-configuration-workflow-tutorial/)
- [Claude Code for WASI Workflow Tutorial Guide](/claude-code-for-wasi-workflow-tutorial-guide/)
- [Claude Code for Appsmith Dashboard Workflow Guide](/claude-code-for-appsmith-dashboard-workflow-guide/)
- [Claude Code for Domain Events Workflow Guide](/claude-code-for-domain-events-workflow-guide/)
- [Claude Code for Distributed Tracing Workflow Tutorial](/claude-code-for-distributed-tracing-workflow-tutorial/)
- [Claude Code for Symbol Search Workflow Tutorial Guide](/claude-code-for-symbol-search-workflow-tutorial-guide/)
- [Claude Code Qwik City Routing SSR — Complete Developer Guide](/claude-code-qwik-city-routing-ssr-workflow-tutorial/)
