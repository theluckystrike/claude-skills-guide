---
layout: default
title: "MCP Troubleshooting Common Errors (2026)"
description: "Fix the top 10 MCP errors in Claude Code: connection failures, auth errors, timeout issues, and server crashes. Step-by-step solutions."
date: 2026-04-26
permalink: /mcp-troubleshooting-common-errors-2026/
categories: [guides, claude-code]
tags: [MCP, troubleshooting, errors, debugging, fixes]
last_modified_at: 2026-04-26
---

# MCP Troubleshooting Common Errors (2026)

MCP servers fail silently. Claude Code starts normally, but the server is not connected, tools are missing, or queries return cryptic errors. This guide covers the 10 most common MCP errors with step-by-step fixes for each. Many errors can be avoided entirely by using the [MCP Config Generator](/mcp-config/) to create valid configurations.

## Error 1: Server Not Appearing in Claude Code

**Symptom:** You added a server to mcp.json but Claude does not list it as connected.

**Causes and Fixes:**

**Invalid JSON.** The most common cause. Validate your mcp.json:

```bash
cat .claude/mcp.json | python3 -m json.tool
```

If this prints an error, fix the JSON syntax. Common issues: trailing commas, missing quotes, unescaped characters.

**Wrong file location.** Verify the file is at `.claude/mcp.json` relative to your project root, not `claude/mcp.json` or `.claude/config.json`.

**Session not restarted.** MCP servers are loaded at session start. After editing mcp.json, start a new Claude Code session.

**Command not found.** If `npx` is not in PATH (common with nvm), use the full path:

```json
"command": "/Users/you/.nvm/versions/node/v20.11.0/bin/npx"
```

## Error 2: ECONNREFUSED — Connection Refused

**Symptom:** `Error: connect ECONNREFUSED 127.0.0.1:PORT`

**The server process failed to start.** Run the command manually to see the error:

```bash
npx -y @modelcontextprotocol/server-postgres "postgresql://user:pass@localhost:5432/db"
```

Common causes:
- **Database not running.** Start PostgreSQL/MySQL/Redis first.
- **Wrong port.** Verify the database is listening on the expected port.
- **Firewall blocking.** macOS firewall may block Node.js connections. Check System Settings > Network > Firewall.

## Error 3: Authentication Failed

**Symptom:** `Error: password authentication failed for user "..."` or `401 Unauthorized`

**For database servers:**
- Verify credentials by connecting manually: `psql postgresql://user:pass@localhost:5432/db`
- Check that the user exists and has the correct password
- Verify the user has permissions on the target database

**For API-based servers (GitHub, Brave Search):**
- Check that the API key or token is valid and not expired
- Verify environment variables are set correctly: `echo $GITHUB_TOKEN`
- GitHub tokens need the correct scopes (repo, read:org for full access)
- Regenerate expired tokens in the service's dashboard

## Error 4: Environment Variables Not Resolving

**Symptom:** Server starts but fails with empty or literal `${VAR_NAME}` values.

**Fix 1: Verify the variable is exported.**
```bash
echo $GITHUB_TOKEN  # Should print the value, not empty
```

If empty, add to your shell profile (~/.zshrc or ~/.bashrc):
```bash
export GITHUB_TOKEN="ghp_xxxxxxxxxxxx"
```

Then restart your terminal and Claude Code.

**Fix 2: Check variable syntax.** Both formats work:
```json
"env": { "KEY": "${GITHUB_TOKEN}" }
"env": { "KEY": "$GITHUB_TOKEN" }
```

Do not use quotes around the variable reference within the value string if the value is only the variable.

## Error 5: Server Crashes on Startup

**Symptom:** Server appears briefly then disappears. No tools available.

**Debug by running manually:**
```bash
npx -y @modelcontextprotocol/server-filesystem /path/to/dir 2>&1
```

Common causes:

**Node.js version mismatch.** Some MCP servers require Node 18+:
```bash
node --version  # Must be 18.0.0 or higher
```

**Missing native dependencies.** Some servers require build tools:
```bash
# macOS
xcode-select --install

# Install build tools
npm install -g node-gyp
```

**Path does not exist.** Filesystem servers crash if the specified directory does not exist:
```bash
ls -la /path/specified/in/config  # Must exist
```

## Error 6: MCP Timeout — Server Not Responding

**Symptom:** `Error: MCP server timed out` or queries hang indefinitely.

**The server started but is unresponsive.** Causes:

**Large dataset query.** If you asked Claude to query a table with millions of rows without a LIMIT clause, the query takes too long. Always include LIMIT in exploratory queries.

**Network issues.** For remote databases, check connectivity:
```bash
curl -v telnet://remote-host:5432  # Test TCP connection
```

**Server resource exhaustion.** Check if the MCP server process is consuming excessive memory:
```bash
ps aux | grep mcp
```

Kill and restart Claude Code if needed.

## Error 7: Tool Name Conflicts

**Symptom:** Claude calls the wrong server's tool, or gets confused about which tool to use.

This happens when two servers expose tools with the same name. Claude's MCP tools follow the pattern `mcp__servername__toolname`. If two servers have a `query` tool, they become `mcp__server1__query` and `mcp__server2__query`.

**Fix:** Use descriptive server names:
```json
{
  "mcpServers": {
    "postgres-users": { ... },
    "postgres-analytics": { ... }
  }
}
```

Then Claude can distinguish between `mcp__postgres-users__query` and `mcp__postgres-analytics__query`.

## Error 8: Permission Denied

**Symptom:** `Error: EACCES: permission denied` when reading files or accessing directories.

**Fix:** Verify the path in your MCP config is readable by your user:
```bash
ls -la /path/in/config  # Check permissions
```

On macOS, also check Full Disk Access in System Settings > Privacy & Security if the MCP server needs to access protected directories.

## Error 9: Package Not Found

**Symptom:** `Error: Could not find package @modelcontextprotocol/server-xxx`

**Wrong package name.** Check the official MCP server list. Common mistakes:
- `server-postgresql` (wrong) vs `server-postgres` (correct)
- `server-file-system` (wrong) vs `server-filesystem` (correct)

**npm registry issue.** Clear the npx cache:
```bash
npx clear-npx-cache
```

**Private registry configured.** If your .npmrc points to a private registry, it may not have MCP packages:
```bash
npm config get registry  # Should be https://registry.npmjs.org/
```

## Error 10: Incompatible MCP Protocol Version

**Symptom:** `Error: Incompatible MCP protocol version` or server connects but tools do not work correctly.

**Fix:** Update Claude Code to the latest version:
```bash
npm update -g @anthropic-ai/claude-code
```

Also update the MCP server:
```json
"args": ["-y", "@modelcontextprotocol/server-github@latest"]
```

The `@latest` tag forces npx to download the newest version rather than using a cached old one.

## Try It Yourself

Most MCP errors come from configuration mistakes: wrong package names, invalid JSON, or misconfigured credentials. The [MCP Config Generator](/mcp-config/) eliminates these issues by generating validated configuration files with correct package names, proper argument formatting, and environment variable handling. If you are spending time debugging MCP setup, start fresh with a generated config.

## Diagnostic Checklist

When any MCP server fails, run through this checklist:

1. Is mcp.json valid JSON? (`python3 -m json.tool`)
2. Is the file in the right location? (`.claude/mcp.json`)
3. Did you restart Claude Code after editing?
4. Can you run the server command manually in terminal?
5. Are environment variables exported and non-empty?
6. Is the target service (database, API) running and accessible?
7. Is Node.js version 18 or higher?
8. Is the package name correct? (check npm registry)

If all eight checks pass and the server still fails, check the MCP server's GitHub issues for known bugs.



**Fix it instantly →** Paste your error into our [Error Diagnostic Tool](/diagnose/) for step-by-step resolution.

## Related Guides

- [MCP Server Setup Complete Guide](/mcp-server-setup-complete-guide-2026/) — Proper setup from the start
- [MCP Config JSON Explained](/mcp-config-json-explained-2026/) — Understand every config field
- [Claude Code ECONNREFUSED MCP Fix](/claude-code-econnrefused-mcp-fix/) — Deep dive on connection errors
- [MCP Empty Arguments Bug](/anthropic-sdk-mcp-empty-arguments-bug/) — Known MCP bug and fix
- [Claude Code MCP Server Setup](/claude-code-mcp-server-setup/) — Alternative setup guide
- [MCP Config Generator](/mcp-config/) — Generate error-free configs

## Frequently Asked Questions

### How do I see MCP server logs for debugging?
Run the server command manually in a separate terminal to see stdout and stderr output. MCP servers write diagnostic information to stderr which is hidden when launched by Claude Code.

### Can a broken MCP server crash Claude Code?
No. Claude Code isolates MCP servers in separate processes. If a server crashes, Claude Code continues without that server. Other servers remain functional.

### Why does my MCP server work in terminal but not in Claude Code?
PATH differences. Your terminal may have different PATH than the environment Claude Code launches processes in. Use absolute paths for the command field or ensure your PATH is set in your shell profile not just the current session.

### How often should I update MCP servers?
Check for updates monthly. MCP is a rapidly evolving protocol and servers frequently receive bug fixes and new features. Use the latest tag in npx to always get the newest version.

<script type="application/ld+json">
{
  "@context": "https://schema.org",
  "@type": "FAQPage",
  "mainEntity": [
    {
      "@type": "Question",
      "name": "How do I see MCP server logs for debugging?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "Run the server command manually in a separate terminal to see stdout and stderr output. MCP servers write diagnostics to stderr which is hidden when launched by Claude Code."
      }
    },
    {
      "@type": "Question",
      "name": "Can a broken MCP server crash Claude Code?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "No. Claude Code isolates MCP servers in separate processes. If a server crashes Claude Code continues without it. Other servers remain functional."
      }
    },
    {
      "@type": "Question",
      "name": "Why does my MCP server work in terminal but not in Claude Code?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "PATH differences. Your terminal may have different PATH than Claude Code's launch environment. Use absolute paths for the command field or set PATH in your shell profile."
      }
    },
    {
      "@type": "Question",
      "name": "How often should I update MCP servers?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "Check monthly. MCP is rapidly evolving with frequent bug fixes and features. Use the latest tag in npx to always get the newest version."
      }
    }
  ]
}
</script>
