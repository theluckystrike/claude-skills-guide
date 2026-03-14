---
layout: default
title: "MCP Credential Management and Secrets Handling"
description: "A practical guide to managing credentials and secrets when building MCP servers, covering environment variables, OAuth flows, secret scanning, and secure patterns for Claude Code integrations."
date: 2026-03-14
categories: [guides]
tags: [mcp, security, credentials, secrets, claude-code, devops]
author: "Claude Skills Guide"
reviewed: true
score: 7
---

# MCP Credential Management and Secrets Handling

Building MCP servers that interact with databases, cloud services, and third-party APIs requires careful handling of credentials and secrets. Whether you're building a custom MCP server for AWS, connecting the `pdf` skill to process documents from a secure bucket, or wiring the `tdd` skill to your CI/CD pipeline — the way you manage secrets directly impacts security and reliability. This guide covers practical approaches to credential management for MCP servers, with code examples you can adapt immediately.

## Understanding the Threat Landscape

MCP servers run as long-lived processes that often maintain persistent connections to external services. This makes them attractive targets for attackers seeking API keys, database credentials, or OAuth tokens. The most common risks include credential leakage through logs, environment variable exposure, hardcoded secrets in source code, and improper token refresh handling.

When building MCP integrations, remember that credentials passed through tool calls may appear in Claude's context window. While Claude Code doesn't persist these in logs, the attack surface includes your server's environment, configuration files, and any third-party services your MCP server connects to.

## Environment Variables: The Foundation

The most straightforward approach for handling secrets in MCP servers is environment variables. Most cloud providers and API services support configuration through environment variables, making this pattern portable and compatible with containerized deployments.

```python
# mcp_server_example/server.py
import os
from mcp.server import Server
from mcp.types import Tool, TextContent

class SecureMCPServer:
    def __init__(self):
        self.api_key = os.environ.get("API_KEY")
        self.database_url = os.environ.get("DATABASE_URL")
        
        if not self.api_key:
            raise ValueError("API_KEY environment variable is required")
    
    async def call_api(self, endpoint: str) -> dict:
        headers = {"Authorization": f"Bearer {self.api_key}"}
        # Make authenticated request
        return {"status": "success"}
```

When deploying this server, you inject secrets at runtime rather than baking them into the image:

```bash
# Docker compose example
services:
  mcp-server:
    image: your-mcp-server:latest
    environment:
      - API_KEY=${API_KEY}
      - DATABASE_URL=${DATABASE_URL}
    secrets:
      - api_key
      - database_url

secrets:
  api_key:
    file: ./secrets/api_key.txt
  database_url:
    file: ./secrets/database_url.txt
```

This pattern works well with skills like `supermemory` that persist data to external stores. The key is ensuring your deployment pipeline never echoes or logs these environment variables.

## OAuth 2.0 for User-Authenticated Requests

Many MCP servers need to act on behalf of users, requiring OAuth flows rather than service-level credentials. For detailed patterns on implementing OAuth in MCP contexts, see the related guides on MCP authentication flows.

For web-based OAuth, your MCP server acts as a callback endpoint:

```python
from fastapi import FastAPI, Query
from mcp.server import Server

app = FastAPI()
server = Server("oauth-mcp-server")

# Store tokens securely per user session
user_tokens: dict[str, dict] = {}

@app.get("/oauth/callback")
async def oauth_callback(code: str, state: str):
    # Exchange code for tokens
    token_response = await exchange_code_for_token(code)
    
    # Store with encryption
    user_tokens[state] = {
        "access_token": encrypt(token_response["access_token"]),
        "refresh_token": encrypt(token_response["refresh_token"]),
        "expires_at": time.time() + token_response["expires_in"]
    }
    
    return {"status": "authorized"}

async def make_user_request(user_id: str, endpoint: str):
    token_data = user_tokens.get(user_id)
    if not token_data:
        raise ValueError("User not authenticated")
    
    # Check expiry and refresh if needed
    if time.time() > token_data["expires_at"]:
        await refresh_token(user_id)
    
    access_token = decrypt(token_data["access_token"])
    return await call_api(endpoint, access_token)
```

This approach is essential when building integrations that access user data from services like GitHub, Google Workspace, or Slack. The `slack-gif-creator` skill demonstrates this pattern when creating animations that require workspace authentication.

## Secret Scanning and Prevention

Automated detection of leaked secrets complements MCP-level prevention for defense in depth.

Never log or return credentials in tool responses:

```python
# BAD: Credentials in response
async def get_user_info(user_id: str) -> dict:
    user = await database.fetch("SELECT * FROM users WHERE id = ?", user_id)
    return {
        "user": user,
        "db_connection_string": os.environ.get("DATABASE_URL")  # LEAKED!
    }

# GOOD: Sanitized response
async def get_user_info(user_id: str) -> dict:
    user = await database.fetch("SELECT * FROM users WHERE id = ?", user_id)
    return {
        "user": user,
        "connection_status": "active"  # No sensitive data
    }
```

Implement request validation to prevent injection attacks that could extract secrets:

```python
from mcp.types import CallToolResult

async def handle_tool_call(tool_name: str, arguments: dict) -> CallToolResult:
    # Validate inputs before processing
    if tool_name == "query_database":
        sql = arguments.get("query", "")
        if "; DROP TABLE" in sql or "--" in sql:
            return CallToolResult(
                content=[TextContent(type="text", text="Invalid query")],
                isError=True
            )
    
    # Process legitimate request
    result = await process_request(tool_name, arguments)
    return result
```

## Working with Claude Code Skills

The `pdf` skill can process sensitive documents through your MCP server, while the `tdd` skill might run tests against APIs requiring authentication. Here's how to connect skills securely:

```markdown
<!-- In your skill .md file -->
# Secure API Tester

Run API integration tests using the MCP server.

When running tests:
- Use the API endpoint provided by the user
- Load the auth token from MCP_AUTH_TOKEN environment variable — never accept tokens as user input
- Report pass/fail status and any authentication errors clearly
```

The `frontend-design` skill can integrate with design APIs that require authentication, while `xlsx` might connect to spreadsheets containing sensitive data. In each case, ensure credentials flow through environment variables rather than appearing in skill prompts or tool arguments.

## Production Deployment Patterns

When deploying MCP servers to production, consider these patterns:

**External secrets services** work well for enterprise deployments:

```python
import boto3

async def get_secret(secret_name: str) -> str:
    client = boto3.client("secretsmanager")
    response = client.get_secret_value(SecretId=secret_name)
    return response["SecretString"]
```

**Rotation automation** ensures credentials don't become stale:

```python
class RotatingCredential:
    def __init__(self, secret_name: str, rotation_days: int = 90):
        self.secret_name = secret_name
        self.rotation_days = rotation_days
        self._credential = None
        self._last_rotated = None
    
    async def get(self) -> str:
        if self._needs_rotation():
            await self._rotate()
        return self._credential
    
    async def _rotate(self):
        # Generate new credential
        self._credential = await generate_new_credential()
        self._last_rotated = time.time()
        await store_rotated_credential(self.secret_name, self._credential)
    
    def _needs_rotation(self) -> bool:
        if not self._last_rotated:
            return True
        return (time.time() - self._last_rotated) > (self.rotation_days * 86400)
```

## Conclusion

Secure credential management in MCP servers requires layering environment variables for configuration, OAuth flows for user-authenticated requests, secret scanning for prevention, and production-grade patterns like external secrets services and automated rotation. Start with environment variables for simplicity, implement OAuth when user delegation is needed, and add secret scanning and rotation as your deployments scale. The `tdd` skill can validate your credential handling implementation through integration tests, while `supermemory` can help you document your security architecture.

Built by theluckystrike — More at [zovo.one](https://zovo.one)
