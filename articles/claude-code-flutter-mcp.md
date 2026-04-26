---
layout: default
title: "Claude Code Flutter MCP Server Guide (2026)"
description: "Build a custom MCP server for Flutter development with Claude Code to run tests, inspect widgets, and manage device builds from your terminal."
date: 2026-04-17
last_modified_at: 2026-04-17
author: "Claude Skills Guide"
permalink: /claude-code-flutter-mcp/
categories: [guides]
tags: [claude-code, claude-skills, flutter, mcp, dart, mobile]
reviewed: true
score: 7
geo_optimized: true
---

A custom MCP server for Flutter lets Claude Code run device builds, execute widget tests, and inspect your app's widget tree directly from the terminal. This guide shows you how to build a Flutter MCP server that bridges Claude Code with Flutter CLI tools and the Dart DevTools protocol.

## The Problem

Flutter development involves constant switching between the terminal for builds and tests, DevTools for widget inspection, and your editor for code changes. Claude Code can edit your Dart files, but without MCP it cannot trigger hot reloads, run specific test files, or check which devices are available. This breaks the flow of AI-assisted Flutter development.

## Quick Solution

1. Create `flutter_mcp.py` in your project root:

```python
from mcp.server.fastmcp import FastMCP
import subprocess

mcp = FastMCP("flutter-dev")

@mcp.tool()
def flutter_analyze() -> str:
    """Run dart analyze on the project."""
    result = subprocess.run(
        ["dart", "analyze", "--fatal-infos"],
        capture_output=True, text=True, timeout=60
    )
    return result.stdout + result.stderr

@mcp.tool()
def flutter_test(test_file: str = "") -> str:
    """Run Flutter tests. Optionally specify a test file."""
    cmd = ["flutter", "test", "--no-pub"]
    if test_file:
        cmd.append(test_file)
    result = subprocess.run(
        cmd, capture_output=True, text=True, timeout=120
    )
    return result.stdout + result.stderr

@mcp.tool()
def flutter_devices() -> str:
    """List available Flutter devices."""
    result = subprocess.run(
        ["flutter", "devices"],
        capture_output=True, text=True, timeout=30
    )
    return result.stdout

@mcp.tool()
def flutter_build(platform: str = "apk") -> str:
    """Build the Flutter app. Platform: apk, ios, web."""
    result = subprocess.run(
        ["flutter", "build", platform],
        capture_output=True, text=True, timeout=300
    )
    return result.stdout + result.stderr
```

2. Install the MCP SDK:

```bash
pip install mcp
```

3. Add to `.mcp.json`:

```json
{
  "mcpServers": {
    "flutter-dev": {
      "command": "python",
      "args": ["flutter_mcp.py"]
    }
  }
}
```

4. Launch Claude Code and ask it to run tests or analyze your project.

## How It Works

The MCP server wraps Flutter CLI commands as tools that Claude Code can invoke. When Claude needs to verify that a code change compiles, it calls `flutter_analyze`. When it needs to validate behavior, it calls `flutter_test` with the relevant test file.

Each tool runs a subprocess with a timeout to prevent hanging builds from blocking Claude. The output is captured and returned as text, which Claude parses to understand errors, warnings, and test results.

This approach works with CLAUDE.md project instructions to create a complete development loop. Claude reads your code, makes changes, runs analysis via MCP, reads the errors, fixes them, and runs tests to verify. All without manual intervention.

## Common Issues

**Flutter not found in subprocess PATH.** The MCP server subprocess may not inherit your shell PATH. Add the Flutter SDK path explicitly in `.mcp.json`:

```json
{
  "mcpServers": {
    "flutter-dev": {
      "command": "python",
      "args": ["flutter_mcp.py"],
      "env": {
        "PATH": "/Users/you/flutter/bin:/usr/local/bin:/usr/bin:/bin"
      }
    }
  }
}
```

**Build timeouts for large projects.** The default 120-second timeout may not be enough for release builds. Increase the `timeout` parameter in `subprocess.run` for the `flutter_build` tool, or set it to 600 seconds for production builds.

**Hot reload not accessible.** Hot reload requires an attached Flutter session. The MCP server cannot trigger hot reload on a running app directly. Instead, use `flutter_analyze` to check for errors and rely on the IDE or terminal for hot reload.

## Example CLAUDE.md Section

```markdown
# Flutter MCP Project

## Stack
- Flutter 3.24 stable, Dart 3.5
- State: flutter_bloc 8.x
- DI: get_it + injectable
- Testing: flutter_test + mockito

## MCP Tools
- flutter_analyze: Type check all Dart files
- flutter_test: Run unit/widget tests
- flutter_devices: List connected devices
- flutter_build: Build for target platform

## Workflow
1. Edit code
2. Run flutter_analyze via MCP
3. Fix any issues
4. Run flutter_test via MCP
5. All tests must pass before suggesting commit

## Rules
- Always run analyze before test
- Widget tests go in test/widgets/
- Unit tests go in test/unit/
- Integration tests go in integration_test/
- Never skip the analyze step
```

## Best Practices

- **Set appropriate timeouts** for each tool. Analysis should be fast (60s), tests moderate (120s), and builds generous (300s+).
- **Add a test-specific tool** that runs only the test file matching the modified source file. This keeps feedback loops tight instead of running the entire test suite.
- **Capture both stdout and stderr** since Flutter outputs errors to stderr and normal output to stdout. Missing stderr means Claude misses critical error information.
- **Keep the MCP server stateless** so each tool invocation is independent. Do not store Flutter process handles between calls.

---

---

<div class="mastery-cta">

I'm a solo developer in Vietnam. 50K Chrome extension users. $500K+ on Upwork. 5 Claude Max subscriptions running agent fleets in parallel.

These are my actual CLAUDE.md templates, orchestration configs, and prompts. Not a course. Not theory. The files I copy into every project before I write a line of code.

**[See what's inside →](https://zovo.one/lifetime?utm_source=ccg&utm_medium=cta-default&utm_campaign=claude-code-flutter-mcp)**

$99 once. Free forever. 47/500 founding spots left.

</div>

Related Reading

- [Claude Code MCP Server Setup](/claude-code-mcp-server-setup/)
- [Claude Code MCP Server Disconnected](/claude-code-mcp-server-disconnected/)
- [Claude Code ECONNREFUSED MCP Fix](/claude-code-econnrefused-mcp-fix/)

Built by theluckystrike. More at [zovo.one](https://zovo.one)
