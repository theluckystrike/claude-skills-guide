---
layout: default
title: "Claude Code WireMock API Mocking Guide"
description: "Learn how to use WireMock with Claude Code to mock APIs for testing. Practical examples for developers integrating HTTP stubbing in their workflow."
date: 2026-03-14
categories: [guides]
tags: [claude-code, wiremock, api-mocking, testing, http-mocking]
author: theluckystrike
reviewed: true
score: 8
permalink: /claude-code-wiremock-api-mocking-guide/
---


# Claude Code WireMock API Mocking Guide

API mocking is an essential skill for developers building integrations, testing edge cases, and working in environments where external services are unavailable or rate-limited. WireMock provides a flexible HTTP mock server that works smoothly within Claude Code workflows, enabling you to stub responses, simulate delays, and verify request patterns without relying on live endpoints.

This guide shows you how to set up WireMock, integrate it with Claude Code, and apply practical patterns for testing your applications.

## What WireMock Offers

WireMock is an HTTP mock server written in Java that lets you create stubs and mocks for REST APIs, SOAP services, and other HTTP endpoints. It runs as a standalone process or embedded library, exposing a RESTful API for configuration. Key capabilities include:

- **Request matching** — Route incoming requests based on URL patterns, headers, query parameters, or body content
- **Response templating** — Generate dynamic responses using variables and transformers
- **Stateful behavior** — Simulate scenarios like authentication flows or multi-step processes
- **Recording and playback** — Capture live traffic and replay it as mocks

For Claude Code users, WireMock becomes especially powerful when combined with bash scripting and file operations, allowing you to programmatically control your mock server from within your development workflow.

## Setting Up WireMock

The quickest way to start is using the standalone JAR. Run these commands in your Claude Code terminal:

```bash
# Download WireMock
curl -L -o wiremock.jar https://repo1.maven.org/maven2/org/wiremock/wiremock-standalone/3.3.1/wiremock-standalone-3.3.1.jar

# Start WireMock on port 8080
java -jar wiremock.jar --port 8080
```

WireMock now listens on `http://localhost:8080`. The admin interface is available at `http://localhost:8080/__admin/`.

## Creating Stubs with Claude Code

You can create stubs by posting JSON to WireMock's admin API. This example demonstrates mocking a fictional payment service:

```bash
# Create a stub for successful payment response
curl -X POST http://localhost:8080/__admin/mappings \
  -H "Content-Type: application/json" \
  -d '{
    "request": {
      "method": "POST",
      "urlPath": "/api/v1/payments",
      "bodyPatterns": [
        {"matchesJsonPath": "$.amount"}
      ]
    },
    "response": {
      "status": 200,
      "jsonBody": {
        "transactionId": "txn_abc123",
        "status": "completed",
        "amount": 99.00
      },
      "headers": {
        "Content-Type": "application/json"
      }
    }
  }'
```

This stub matches POST requests to `/api/v1/payments` containing an amount field and returns a successful transaction response. The advantage here is that your tests can run against predictable, controlled responses rather than hitting a real payment processor.

## Using WireMock with Test-Driven Development

When practicing TDD, you define the expected behavior of external APIs before implementing the integration. WireMock serves as that contract. Consider a scenario where your application fetches user data:

```bash
# Stub user API with specific response
curl -X POST http://localhost:8080/__admin/mappings \
  -H "Content-Type: application/json" \
  -d '{
    "request": {
      "method": "GET",
      "urlPath": "/users/42"
    },
    "response": {
      "status": 200,
      "jsonBody": {
        "id": 42,
        "name": "Alex Chen",
        "email": "alex@example.com",
        "subscription": "pro"
      },
      "headers": {
        "Content-Type": "application/json"
      }
    }
  }'
```

Your code makes the HTTP call, receives this mocked response, and you can assert against the expected data structure. If the API contract changes, update the stub and watch your tests reflect the new contract.

The **tdd** skill provides structured guidance for test-driven development workflows. Pairing TDD with WireMock ensures your mocks accurately represent the contracts your code depends on.

## Simulating Error Conditions

Testing success paths is only half the battle. You need to verify your application handles failures gracefully. WireMock makes this straightforward:

```bash
# Stub a 500 Internal Server Error
curl -X POST http://localhost:8080/__admin/mappings \
  -H "Content-Type: application/json" \
  -d '{
    "request": {
      "method": "GET",
      "urlPath": "/api/health"
    },
    "response": {
      "status": 500,
      "jsonBody": {
        "error": "Internal Server Error",
        "timestamp": "2026-03-14T10:30:00Z"
      }
    }
  }'

# Stub a connection timeout scenario
curl -X POST http://localhost:8080/__admin/mappings \
  -H "Content-Type: application/json" \
  -d '{
    "request": {
      "method": "GET",
      "urlPath": "/api/slow-endpoint"
    },
    "response": {
      "status": 200,
      "fixedDelay": 30000,
      "jsonBody": {"result": "finally"}
    }
  }'
```

These stubs let you test error handling, retry logic, and timeout configurations in your application without needing cooperation from external services.

## Verifying Request History

WireMock records all requests it receives, enabling you to verify that your application actually called the expected endpoints:

```bash
# View recent requests
curl http://localhost:8080/__admin/requests

# Check for a specific request pattern
curl "http://localhost:8080/__admin/requests?url=/api/webhooks"
```

This is invaluable for debugging. If your tests fail, you can inspect exactly what your application sent to the mock server, helping you identify mismatches between expected and actual payloads.

## Advanced: Response Templating

WireMock supports Handlebars-based templating for dynamic responses:

```bash
curl -X POST http://localhost:8080/__admin/mappings \
  -H "Content-Type: application/json" \
  -d '{
    "request": {
      "method": "GET",
      "urlPath": "/api/users"
    },
    "response": {
      "status": 200,
      "body": "{{jsonPath request.body '$.id'}}",
      "headers": {
        "Content-Type": "application/json",
        "X-Request-Id": "{{randomValue length=8}}"
      }
    }
  }'
```

Templates let you echo back request data, generate unique identifiers, and create context-aware responses that mimic real API behavior more closely.

## Integration Tips

When combining WireMock with Claude Code, consider these patterns:

- **Scripted setup** — Store your stub configurations as JSON files in your project and load them via bash scripts during test setup
- **Containerization** — Use Docker to run WireMock in CI pipelines for consistent environments
- **Proxy mode** — Configure WireMock as a proxy to record traffic from live services and create stubs from real data

The **pdf** skill can generate documentation for your API contracts, while **frontend-design** skills help if you're building a dashboard to manage mock configurations visually.

## Stopping WireMock

When you're done testing, stop the server:

```bash
# Find and kill the WireMock process
pkill -f wiremock-standalone
```

Or press `Ctrl+C` in the terminal where it runs.

## Summary

WireMock transforms how you test HTTP-dependent code. By running a local mock server, you gain control over external dependencies, test edge cases including errors and timeouts, and verify that your application sends the right requests. Combined with Claude Code's bash execution and file handling capabilities, you can automate stub creation, integrate mocks into your test suite, and build reliable, maintainable integrations.


## Related Reading

- [What Is the Best Claude Skill for REST API Development?](/claude-skills-guide/what-is-the-best-claude-skill-for-rest-api-development/)
- [Claude Code Tutorials Hub](/claude-skills-guide/tutorials-hub/)
- [Best Claude Skills for Developers in 2026](/claude-skills-guide/best-claude-skills-for-developers-2026/)
- [Claude Code Guides Hub](/claude-skills-guide/guides-hub/)

Built by theluckystrike — More at [zovo.one](https://zovo.one)
