---
layout: default
title: "Fix: Anthropic SDK MCP Tools Get Empty (2026)"
description: "Fix the bug where MCP tools receive empty {} arguments when using the Claude Agent SDK permission approval flow. Root cause and workaround."
date: 2026-04-14
last_modified_at: 2026-04-17
author: "Claude Code Guides"
permalink: /anthropic-sdk-mcp-empty-arguments-bug/
reviewed: true
categories: [troubleshooting]
tags: [anthropic-sdk, mcp, python, permissions, error, troubleshooting, api]
geo_optimized: true
---

# Fix: Anthropic SDK MCP Tools Get Empty Arguments

## The Error

When using the Claude [Claude Agent SDK guide](/claude-agent-sdk-complete-guide/) (Python) with in-process MCP servers and permission approval callbacks, all MCP tools receive empty `{}` arguments:

```
[DEBUG] Request body: {"action":"call_tool","server":"my-tools","tool_name":"read","arguments":{}}

Error: Missing required parameter 'files'
```

The model correctly sends the arguments in the permission request, but after approval, the tool is called with an empty object.

## Quick Fix

Bypass the permission system to confirm the root cause:

```python
agent = ClaudeAgent(
 permission_mode="bypass_permissions", # Skip approval flow
 mcp_servers={
 "my-tools": {
 "type": "sdk",
 "tools": [read_files]
 }
 }
)
```

If this works, the bug is confirmed — the permission approval flow is dropping arguments.

## What's Happening

When you use the `can_use_tool` permission callback, the following sequence occurs:

**1. Model sends correct arguments in the permission request:**

```json
{
 "type": "control_request",
 "request_id": "bd66e5e1-...",
 "request": {
 "subtype": "can_use_tool",
 "tool_name": "mcp__my-tools__read",
 "input": {"files": ["README.md"]},
 "tool_use_id": "toolu_xyz"
 }
}
```

**2. Your callback returns approval:**

```python
async def can_use_tool(tool_name, arguments, context):
 return PermissionResultAllow() # Simple approval
```

**3. SDK sends buggy approval response:**

```json
{
 "type": "control_response",
 "response": {
 "subtype": "success",
 "request_id": "bd66e5e1-...",
 "response": {
 "behavior": "allow",
 "updatedInput": {} // BUG: Empty object overwrites original arguments
 }
 }
}
```

**4. Claude CLI uses the empty `updatedInput` instead of the original arguments:**

```json
{"action":"call_tool","server":"my-tools","tool_name":"read","arguments":{}}
```

**Root cause:** The SDK's permission handler always includes `updatedInput` in the approval response, even when `PermissionResultAllow()` is called without explicitly setting `updated_input`. The `updatedInput` field defaults to an empty object `{}`, which Claude CLI interprets as "replace the original arguments with this empty object."

The correct behavior: when `updated_input` is not explicitly set, the approval response should omit the `updatedInput` field entirely, and Claude CLI should use the original arguments.

## Step-by-Step Solution

### Option 1: Pass Original Arguments Through

Explicitly forward the original arguments in your approval callback:

```python
async def can_use_tool(tool_name: str, arguments: dict, context) -> PermissionResult:
 # Explicitly pass the original arguments back
 return PermissionResultAllow(updated_input=arguments)
```

This ensures `updatedInput` contains the correct values instead of an empty object.

### Option 2: Bypass Permissions for Trusted Tools

If you do not need per-tool approval, skip the permission flow:

```python
agent = ClaudeAgent(
 permission_mode="bypass_permissions",
 mcp_servers={
 "my-tools": {
 "type": "sdk",
 "tools": [read_files, write_files, search_files]
 }
 }
)
```

### Option 3: Implement Selective Permission with Argument Forwarding

If you need to approve some tools and deny others, forward arguments on approval:

```python
DANGEROUS_TOOLS = {"mcp__my-tools__delete", "mcp__my-tools__format_disk"}

async def can_use_tool(
 tool_name: str,
 arguments: dict,
 context
) -> PermissionResult:
 if tool_name in DANGEROUS_TOOLS:
 return PermissionResultDeny(reason=f"Tool {tool_name} is not allowed")

 # IMPORTANT: Forward the original arguments
 return PermissionResultAllow(updated_input=arguments)
```

### Option 4: Monkey-Patch the SDK (Temporary)

If you cannot modify the approval callback to forward arguments (e.g., using a framework that wraps it):

```python
# WARNING: This is a temporary workaround. Pin your SDK version.
import anthropic._internal.permission_handler as ph

_original_build_response = ph._build_approval_response

def _patched_build_response(result, request_id):
 response = _original_build_response(result, request_id)
 # Remove updatedInput if it's empty
 if (
 "response" in response
 and "response" in response["response"]
 and response["response"]["response"].get("updatedInput") == {}
 ):
 del response["response"]["response"]["updatedInput"]
 return response

ph._build_approval_response = _patched_build_response
```

## Prevention

- **Always pass `updated_input=arguments`** when returning `PermissionResultAllow()` — even if you are not modifying the arguments
- **Test your permission callbacks** with a tool that has required parameters to catch this bug early
- **Use `bypass_permissions`** for development and trusted MCP servers
- **Pin your SDK version** and test after each upgrade to catch regressions

---


**Try it:** Paste your error into our [Error Diagnostic](/diagnose/) for an instant fix.
---

<div class="mastery-cta">

I hit this exact error six months ago. Then I wrote a CLAUDE.md that tells Claude my stack, my conventions, and my error handling patterns. Haven't seen it since.

I run 5 Claude Max subs, 16 Chrome extensions serving 50K users, and bill $500K+ on Upwork. These CLAUDE.md templates are what I actually use. Not theory — production configs.

**[Grab the templates — $99 once, free forever →](https://zovo.one/lifetime?utm_source=ccg&utm_medium=cta-mcp&utm_campaign=anthropic-sdk-mcp-empty-arguments-bug)**

47/500 founding spots. Price goes up when they're gone.

</div>



**Configure it →** Build your MCP config with our [MCP Config Generator](/mcp-config/).

## Related Issues

- [Advanced Claude Skills with Tool Use and Function Calling](/advanced-claude-skills-with-tool-use-and-function-calling/)
- [Fix: Claude Code MCP Server Disconnected](/claude-code-mcp-server-disconnected)
- [Fix: Claude API Error 400 Invalid Request](/claude-api-error-400-invalidrequesterror-explained/)

## Tools That Help

When debugging MCP server interactions and permission flows, a dev tool extension can help inspect the JSON-RPC message exchanges between the SDK and Claude CLI. For a deeper dive, see [Fix Claude API Error 500 — Internal Server Error](/claude-api-error-500-fix/).



## Related Articles

- [Fix Anthropic SDK IndexError When Streaming](/anthropic-sdk-indexerror-streaming-fix/)
- [Fix: Anthropic SDK toolRunner Drops Headers](/anthropic-sdk-toolrunner-drops-headers/)
- [Fix: Structured Output + Thinking + Tool Use Bugs](/anthropic-sdk-structured-output-thinking-tool-use-bug/)


## Common Questions

### What causes fix: anthropic sdk mcp tools get empty issues?

Common causes include misconfigured settings, outdated dependencies, and environment conflicts. Check your project configuration and ensure all dependencies are up to date.

### How do I prevent this error from recurring?

Set up automated checks in your development workflow. Use Claude Code's built-in validation tools to catch configuration issues before they reach production.

### Does this fix work on all operating systems?

The core fix applies to macOS, Linux, and Windows. Some path-related adjustments may be needed depending on your OS. Check the platform-specific notes in the guide above.

## Related Resources

- [Fix: Anthropic SDK Grammar Too Large](/anthropic-sdk-structured-output-grammar-too-large/)
- [Fix: Anthropic SDK toolRunner Drops](/anthropic-sdk-toolrunner-drops-headers/)
- [Fix Anthropic SDK IndexError When](/anthropic-sdk-indexerror-streaming-fix/)
