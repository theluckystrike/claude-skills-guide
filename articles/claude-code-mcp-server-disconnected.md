---
layout: default
title: "Fix: MCP Server Disconnected Error"
description: "Fix the 'MCP server disconnected' error in Claude Code caused by progress token handling in stdio transport. Root cause and workaround."
date: 2026-04-15
last_modified_at: 2026-04-17
author: "Claude Code Guides"
permalink: /claude-code-mcp-server-disconnected/
reviewed: true
score: 8
categories: [troubleshooting]
tags: [claude-code, mcp, server, disconnected, stdio, progress-token]
geo_optimized: true
---

# Fix: Claude Code MCP Server Disconnected Error

## The Error

Your MCP server tool call completes successfully, but Claude Code immediately tears down the stdio transport and respawns the server:

```
Closing transport (stdio transport error: Error)
```

From the MCP logs (found at `~/Library/Caches/claude-cli-nodejs/-Users-{username}/mcp-logs-{server-name}/`):

```json
{"debug":"Calling MCP tool: my_tool_name","timestamp":"2026-04-14T05:41:34.761Z"}
{"debug":"STDIO connection dropped after 139s uptime","timestamp":"2026-04-14T05:41:34.880Z"}
{"debug":"Connection error: Received a progress notification for an unknown token: {\"method\":\"notifications/progress\",\"params\":{\"progress\":1,\"total\":1,\"message\":\"Completed\",\"progressToken\":5}}","timestamp":"2026-04-14T05:41:34.880Z"}
{"debug":"Closing transport (stdio transport error: Error)"}
{"debug":"Tool 'my_tool_name' completed successfully in 119ms"}
{"debug":"Starting connection with timeout of 30000ms"}
```

The tool call succeeded, but the transport was torn down anyway. If another tool call was in-flight, it fails with "MCP server disconnected."

## Quick Fix

If you control the MCP server: stop emitting terminal progress notifications after dispatching the tool response.

```
# BEFORE (causes the bug):
1. Process the request
2. Send the tool response
3. Send progress notification (progress=1, total=1) <-- races the response

# AFTER (fix):
1. Process the request
2. Send the tool response
3. Do NOT send terminal progress after response
```

## What Causes This

The MCP protocol allows servers to emit `notifications/progress` messages during long-running operations. These notifications include a `progressToken` that matches the client's in-flight request.

Here is the race condition:

1. Claude Code sends a tool call request with a `_meta.progressToken`
2. The MCP server processes the request and sends back the result
3. Claude Code receives the result and removes the `progressToken` from its in-flight request map
4. The MCP server sends a terminal progress notification (`progress == total`) for the same token
5. The notification arrives after the token has been removed from the map
6. Claude Code treats the unknown-token notification as a **fatal stdio transport error**
7. The entire transport is torn down and the server process is respawned

The MCP spec's progress notifications section does not specify what a client should do when receiving a progress notification for an unknown token. Most MCP SDK implementations drop it with a debug log. Claude Code's implementation treats it as transport corruption.

## Full Solution

### For MCP Server Authors

Remove terminal progress notifications that fire after the response. Only send progress notifications **before** the tool response:

```typescript
// Send progress BEFORE the result, not after
async function handleToolCall(request: any) {
 const progressToken = request._meta?.progressToken;

 // Progress notification during work (before response)
 if (progressToken) {
 await sendProgress(progressToken, 0.5, 1.0);
 }

 const result = await doExpensiveWork(request.params);

 // Return the result - do NOT send progress=1/total=1 after this
 return { type: "text", text: JSON.stringify(result) };
}
```

### For MCP Server Users (Cannot Modify Server)

**Option 1: Wrap the server with a stdio proxy that filters progress**

```bash
#!/bin/bash
# mcp-progress-filter.sh
# Sits between Claude Code and the MCP server, filtering late progress

REAL_SERVER="$@"

$REAL_SERVER | while IFS= read -r line; do
 # Pass through everything except progress notifications
 if echo "$line" | grep -q '"notifications/progress"'; then
 echo "$line" >> /tmp/mcp-filtered-progress.log
 else
 echo "$line"
 fi
done
```

Configure Claude Code to use the wrapper:

```json
{
 "mcpServers": {
 "my-server": {
 "command": "/path/to/mcp-progress-filter.sh",
 "args": ["python", "-m", "my_mcp_server"]
 }
 }
}
```

**Option 2: Accept the reconnection delay**

If the server reconnects automatically (Claude Code does respawn it), the main impact is latency. The 30-second reconnection timeout is acceptable for non-critical use cases.

### Check Your MCP Logs

The logs that confirm this issue are at:

```bash
# macOS
ls ~/Library/Caches/claude-cli-nodejs/-Users-$(whoami)/mcp-logs-*/
```

Look for entries matching:

```
"Connection error: Received a progress notification for an unknown token"
```

## Prevention

- When authoring MCP servers, only send progress notifications **before** the tool response, never after
- If your server must send a terminal progress notification, send it **before** the JSON-RPC response in the same write batch
- Test your MCP server with Claude Code specifically, not just generic MCP clients, since Claude Code has stricter transport error handling

---

---

<div class="mastery-cta">

I hit this exact error six months ago. Then I wrote a CLAUDE.md that tells Claude my stack, my conventions, and my error handling patterns. Haven't seen it since.

I run 5 Claude Max subs, 16 Chrome extensions serving 50K users, and bill $500K+ on Upwork. These CLAUDE.md templates are what I actually use. Not theory — production configs.

**[Grab the templates — $99 once, free forever →](https://zovo.one/lifetime?utm_source=ccg&utm_medium=cta-mcp&utm_campaign=claude-code-mcp-server-disconnected)**

47/500 founding spots. Price goes up when they're gone.

</div>

## Related Guides

- [Claude Code MCP Server Setup](/claude-code-mcp-server-setup/)
- [Anthropic SDK MCP Empty Arguments Bug](/anthropic-sdk-mcp-empty-arguments-bug/)
- [AWS MCP Server Cloud Automation with Claude Code](/aws-mcp-server-cloud-automation-with-claude-code/)
- [Apache Kafka MCP Server Event Streaming Guide](/apache-kafka-mcp-server-event-streaming-guide/)



## Related Articles

- [Connect Claude Code to Remote MCP Servers](/claude-code-mcp-remote-http-server-setup/)
- [Claude Code Supabase MCP Setup Guide](/claude-code-supabase-mcp-setup/)
- [Claude Code Cloudflare MCP Server Setup](/claude-code-cloudflare-mcp/)
- [Claude Code GitHub Actions MCP Setup](/claude-code-github-actions-mcp/)
- [Claude Code GCP MCP Server Setup](/claude-code-gcp-mcp/)
- [Claude Code Azure DevOps MCP Setup](/claude-code-azure-devops-mcp/)
- [Claude Code AWS MCP Server Setup Guide](/claude-code-aws-mcp-server/)
- [Claude Code FastAPI MCP Server Guide](/claude-code-fastapi-mcp/)
