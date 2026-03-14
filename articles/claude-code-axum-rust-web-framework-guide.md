---
layout: default
title: "Claude Code Axum Rust Web Framework Guide"
description: "Build modern web APIs with Axum and Rust using Claude Code. Practical examples, skill integration, and workflow tips for developers building."
date: 2026-03-14
categories: [tutorials]
tags: [claude-code, claude-skills, axum, rust, web-framework, api, backend]
author: theluckystrike
reviewed: true
score: 8
permalink: /claude-code-axum-rust-web-framework-guide/
---

# Claude Code Axum Rust Web Framework Guide

Axum has become the go-to web framework for Rust developers who want productivity without sacrificing performance. Built by the tokio team, Axum combines Express-inspired routing with Rust's legendary type safety. When you pair Axum with Claude Code, you get an AI-powered development partner that understands your Rust code, suggests idiomatic patterns, and accelerates your workflow from prototype to production.

## Why Axum for Modern Rust Development

Axum stands out in the Rust web ecosystem for several reasons. The framework leverages tower middleware, meaning you can mix and match authentication, logging, and rate-limiting components from the tower ecosystem. The extractor system makes request handling feel natural—extract what you need with type-safe parameters rather than wrestling with raw request objects.

When working with Claude Code on Axum projects, you'll find the AI assistant understands async patterns, tokio runtime integration, and the extractor-based request handling that defines Axum development. This means less time explaining context and more time iterating on your actual implementation.

## Setting Up Your Axum Project

Initialize your project and add the necessary dependencies:

```bash
cargo new axum-api-guide
cd axum-api-guide
cargo add axum tokio tower tower-http serde serde_json
```

Configure your Cargo.toml with appropriate versions:

```toml
[dependencies]
axum = "0.8"
tokio = { version = "1", features = ["full"] }
tower = "0.5"
tower-http = { version = "0.6", features = ["cors", "trace"] }
serde = { version = "1", features = ["derive"] }
serde_json = "1"
tracing = "0.1"
```

Your main.rs structure should look familiar to anyone who's built web services in other languages, but with Rust's characteristic safety:

```rust
use axum::{
    routing::get,
    Router,
};
use std::net::SocketAddr;

#[tokio::main]
async fn main() {
    let app = Router::new()
        .route("/", get(root_handler));

    let addr = SocketAddr::from(([127, 0, 0, 1], 3000));
    let listener = tokio::net::TcpListener::bind(addr).await.unwrap();
    
    println!("Server running at http://{}", addr);
    axum::serve(listener, app).await.unwrap();
}

async fn root_handler() -> &'static str {
    "Axum server is running!"
}
```

## Building REST Endpoints with Extractors

Axum's extractor system is where the framework truly shines. Instead of parsing request bodies manually, you define functions that receive exactly what they need:

```rust
use axum::{
    extract::{Path, Query, Json, State},
    response::IntoResponse,
};
use serde::{Deserialize, Serialize};
use std::sync::Arc;

// Shared application state
#[derive(Clone)]
struct AppState {
    db: Arc<ExampleDb>,
}

#[derive(Deserialize)]
struct Pagination {
    page: Option<usize>,
    limit: Option<usize>,
}

#[derive(Serialize)]
struct UserResponse {
    id: u64,
    name: String,
    email: String,
}

// Path and query parameter extraction
async fn get_user(
    Path(user_id): Path<u64>,
    State(state): State<AppState>,
) -> impl IntoResponse {
    // Query your database, return JSON response
    Json(UserResponse {
        id: user_id,
        name: "Alice".to_string(),
        email: "alice@example.com".to_string(),
    })
}

// List with pagination
async fn list_users(
    Query(pagination): Query<Pagination>,
    State(state): State<AppState>,
) -> impl IntoResponse {
    let page = pagination.page.unwrap_or(1);
    let limit = pagination.limit.unwrap_or(10);
    
    // Return paginated results
    Json(vec![UserResponse {
        id: 1,
        name: "Alice".to_string(),
        email: "alice@example.com".to_string(),
    }])
}
```

Claude Code excels at generating these extractor patterns correctly. Simply describe what data you need from incoming requests, and the AI assistant produces the proper type signatures and error handling.

## Integrating Claude Skills for Enhanced Development

Several Claude skills can accelerate your Axum development workflow. The tdd skill helps you write tests before implementing endpoints, ensuring your API contracts are well-defined from the start. When building user-facing endpoints, the frontend-design skill provides guidance on designing intuitive JSON response structures.

For documentation generation, consider using skills that automate OpenAPI specification creation from your route handlers. This keeps your API documentation synchronized with your code without manual maintenance.

The supermemory skill proves valuable when working across multiple Axum services—you can store context about your API design decisions, authentication strategies, and database schemas and retrieve them in future sessions.

## Adding Middleware and Error Handling

Middleware in Axum comes from the tower ecosystem, giving you proven building blocks:

```rust
use tower_http::cors::{CorsLayer, Any};
use tower_http::trace::TraceLayer;
use axum::middleware::AddExtension;

let cors = CorsLayer::new()
    .allow_origin(Any)
    .allow_methods(Any)
    .allow_headers(Any);

let app = Router::new()
    .route("/api/users", get(list_users))
    .route("/api/users/:id", get(get_user))
    .layer(cors)
    .layer(TraceLayer::new_for_http())
    .with_state(state);
```

Error handling follows Rust's Result pattern. Define your error types, implement From traits for automatic conversion, and Axum handles the rest:

```rust
use axum::{
    http::StatusCode,
    response::{Response, IntoResponse},
    Json,
};
use serde_json::json;

enum AppError {
    DatabaseError(String),
    NotFound(String),
    Unauthorized,
}

impl IntoResponse for AppError {
    fn into_response(self) -> Response {
        let (status, error_message) = match self {
            AppError::DatabaseError(msg) => (StatusCode::INTERNAL_SERVER_ERROR, msg),
            AppError::NotFound(msg) => (StatusCode::NOT_FOUND, msg),
            AppError::Unauthorized => (StatusCode::UNAUTHORIZED, "Unauthorized".to_string()),
        };
        
        let body = Json(json!({ "error": error_message }));
        (status, body).into_response()
    }
}
```

## Working with Claude Code Effectively

When developing Axum applications with Claude Code, structure your claude.md to include your project conventions. Define your error handling patterns, naming conventions for routes and handlers, and testing preferences:

```markdown
# Project Conventions

## Route Naming
- Use plural nouns: `/users`, `/orders`, `/products`
- Nested resources: `/users/:id/orders`

## Error Handling
- All errors implement IntoResponse
- Use AppError enum with From implementations

## Testing
- Unit tests for handlers
- Integration tests with TestClient
- Test each extractor combination
```

This context helps Claude Code generate code that matches your established patterns rather than starting fresh each time.

## Performance and Production Considerations

Axum runs on the tokio runtime, giving you non-blocking I/O by default. For production deployments, consider these optimizations:

Configure appropriate worker counts based on your CPU cores, enable connection keep-alive for clients making multiple requests, and use tower-http's compression middleware for response size reduction. The framework's minimal overhead means your Rust code—rather than the web layer—typically becomes the performance bottleneck.

Health check endpoints are straightforward to implement and essential for container orchestration:

```rust
async fn health_check() -> impl IntoResponse {
    Json(json!({ "status": "healthy" }))
}

let app = Router::new()
    .route("/health", get(health_check))
    // ... other routes
```

## Next Steps

With your Axum foundation in place, explore adding database integration with sqlx or your preferred ORM, implementing JWT authentication using tower-http's middleware capabilities, and setting up graceful shutdown handling for production deployments. Claude Code can guide you through each of these enhancements, generating working code based on your specific requirements.

The combination of Axum's ergonomic design and Claude Code's AI assistance makes Rust web development accessible without sacrificing the language's performance and safety guarantees. Start with simple endpoints, iterate rapidly, and scale confidently.


## Related Reading

- [Claude Code for Beginners: Complete Getting Started Guide](/claude-skills-guide/claude-code-for-beginners-complete-getting-started-2026/)
- [Best Claude Skills for Developers in 2026](/claude-skills-guide/best-claude-skills-for-developers-2026/)
- [Claude Skills Guides Hub](/claude-skills-guide/guides-hub/)

Built by theluckystrike — More at [zovo.one](https://zovo.one)
