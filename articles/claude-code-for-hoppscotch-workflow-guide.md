---
layout: default
title: "Claude Code for Hoppscotch"
description: "Test APIs with Hoppscotch and Claude Code together. Tested setup with copy-paste CLAUDE.md config."
date: 2026-04-18
permalink: /claude-code-for-hoppscotch-workflow-guide/
render_with_liquid: false
categories: [workflow, niche-tools]
tags: [claude-code, hoppscotch, workflow]
---

## The Setup

You are using Hoppscotch as your API testing platform — the open-source Postman alternative. Claude Code can generate API requests, collections, and test scripts for Hoppscotch, but it formats output for Postman or cURL instead of Hoppscotch's collection format and misses Hoppscotch-specific features like environments and pre-request scripts.

## What Claude Code Gets Wrong By Default

1. **Generates Postman collection JSON format.** Claude exports API collections in Postman's `v2.1` format. Hoppscotch uses its own JSON format for collections and cannot directly import Postman files without conversion.

2. **Uses Postman's `pm.*` scripting API.** Claude writes pre-request and test scripts with `pm.environment.set()` and `pm.response.json()`. Hoppscotch uses a different scripting API with `pw.*` functions.

{% raw %}3. **Ignores Hoppscotch's environment variable syntax.** Claude uses `{{variable}}` which looks correct but Hoppscotch processes variables differently in headers vs body. Claude does not distinguish between these contexts.{% endraw %}

4. **Creates separate cURL commands instead of collections.** Claude generates individual cURL commands for testing. Hoppscotch organizes requests into collections with shared auth, environments, and test flows.

## The CLAUDE.md Configuration

```
{% raw %}
# Hoppscotch API Testing

## Tool
- API Client: Hoppscotch (self-hosted or hoppscotch.io)
- Collections: JSON format in .hoppscotch/ directory
- CLI: @hoppscotch/cli for CI/CD API testing
- Environments: dev, staging, prod variable sets

## Hoppscotch Rules
- Use Hoppscotch collection format, NOT Postman format
- Pre-request scripts use pw.* API (pw.env.set, pw.env.get)
- Test scripts use pw.expect() assertions
- Variables use <<variable>> in some contexts
- Auth tokens stored in environment variables, not hardcoded
- Collections exported as JSON for version control

## Conventions
- Collections in .hoppscotch/collections/ directory
- Environments in .hoppscotch/environments/ directory
- Base URL in environment variable: {{baseUrl}}
- Auth token in environment: {{authToken}}
- Run CI tests: hopp test -e environment.json collection.json
- One collection per API domain (users, projects, billing)
{% endraw %}
```

## Workflow Example

You want to create API tests for a new endpoint. Prompt Claude Code:

"Create a Hoppscotch collection for the /api/projects CRUD endpoints. Include environment variables for the base URL and auth token, add pre-request scripts to set the auth header, and write test assertions for status codes and response shapes."

Claude Code should produce a Hoppscotch-format JSON collection with GET, POST, PUT, DELETE requests, environment files with `baseUrl` and `authToken` variables, pre-request scripts using `pw.env.get("authToken")` to set the Authorization header, and test scripts using `pw.expect()` assertions.

## Common Pitfalls

1. **CLI collection format mismatch.** Claude generates collection JSON that works in the Hoppscotch web UI but fails with `@hoppscotch/cli`. The CLI expects exported collection format — re-export from the UI or ensure the JSON matches the CLI schema.

2. **Environment variable scoping.** Claude sets variables in pre-request scripts expecting them to persist across requests. Hoppscotch environment variables set via `pw.env.set()` persist for the session but may not save to the environment file. Use global environments for persistent values.

3. **Self-hosted auth configuration.** Claude configures Hoppscotch requests against a self-hosted instance but forgets that self-hosted Hoppscotch may need CORS headers from your API. Add your Hoppscotch instance origin to the API's allowed origins list.

## Related Guides

- [Claude Code API Endpoint Testing Guide](/claude-code-api-endpoint-testing-guide/)
- [Claude Code API Contract Testing Guide](/claude-code-api-contract-testing-guide/)
- [Building a REST API with Claude Code Tutorial](/building-a-rest-api-with-claude-code-tutorial/)

## Related Articles

- [Claude Code for Workspace Indexing Workflow Tutorial](/claude-code-for-workspace-indexing-workflow-tutorial/)
- [Claude Code For Redwood JS — Complete Developer Guide](/claude-code-for-redwood-js-fullstack-workflow-guide/)
- [Claude Code Enterprise Disaster Recovery Workflow Planning](/claude-code-enterprise-disaster-recovery-workflow-planning/)
- [Claude Code For Jmh Benchmark — Complete Developer Guide](/claude-code-for-jmh-benchmark-workflow-tutorial-guide/)
- [Claude Code Workflow for Turkish Developer Teams](/claude-code-workflow-for-turkish-developer-teams/)
- [Claude Code Git Lfs Large Files — Complete Developer Guide](/claude-code-git-lfs-large-files-workflow/)
- [Claude Code for Astro Integrations Workflow Guide](/claude-code-for-astro-integrations-workflow-guide/)
- [Claude Code for ARIA Live Regions Workflow Guide](/claude-code-for-aria-live-regions-workflow-guide/)
