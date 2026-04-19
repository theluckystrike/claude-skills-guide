---

layout: default
title: "Claude Code MCP Server Incident Response Guide"
description: "A practical guide to troubleshooting and resolving MCP server issues in Claude Code. Includes diagnostic commands, log analysis, and recovery procedures."
date: 2026-03-14
last_modified_at: 2026-04-17
author: "Claude Skills Guide"
categories: [tutorials]
tags: [claude-code, mcp-server, troubleshooting, incident-response, debugging, claude-skills]
permalink: /claude-code-mcp-server-incident-response-guide/
reviewed: true
score: 7
geo_optimized: true
---

When your MCP server stops responding or throws errors during a Claude Code session, productivity comes to a halt. This guide provides a systematic approach to diagnosing, troubleshooting, and recovering from MCP server incidents using practical commands and recovery procedures. Whether you are running a single local filesystem server or a multi-server production setup, the same structured process applies.

## Understanding MCP Server Architecture

Before troubleshooting, it helps to understand how MCP servers fit into Claude Code's runtime. Claude Code launches MCP servers as child processes and communicates with them over standard input/output (stdio) or a local TCP socket, depending on the server's transport type. Each server registers a set of tools that Claude can invoke during a session.

This architecture has several failure points:

- The server process fails to start (bad executable, missing dependencies)
- The server starts but fails the handshake with Claude Code
- The server is running but becomes unresponsive mid-session
- A tool call fails because the server's underlying service is unavailable

Knowing which failure point you are dealing with determines which recovery path to take.

## Identifying MCP Server Failures

MCP (Model Context Protocol) servers extend Claude Code's capabilities by connecting to external tools and services. Common failure indicators include:

- Server timeout errors after startup
- Authentication failures when connecting to services
- Tool call failures with "server not available" messages
- Unexpected disconnections during active sessions
- Tools appearing greyed out or missing from the tool list

Before diving into fixes, verify that the issue is indeed MCP-related. Run this command in your terminal:

```bash
claude --verbose
```

Look for error messages containing "MCP" or the specific server name. The verbose output shows connection attempts and helps narrow down whether the failure occurs at startup or during runtime.

## Reading Verbose Output

The verbose output is dense but structured. Focus on these sections:

```
[MCP] Starting server: server-filesystem
[MCP] server-filesystem: spawn error: ENOENT
```

`ENOENT` means the executable was not found, usually a missing Node.js package or wrong path in your configuration. Contrast this with:

```
[MCP] server-filesystem: connected
[MCP] server-filesystem: tool call failed: EACCES /var/protected-dir
```

Here the server started fine but the tool call was refused by the OS due to permissions. Two very different problems, two very different fixes.

## Initial Diagnostic Steps

## Check Server Status

The first step is verifying which MCP servers are currently registered and their status. Claude Code stores server configurations in your user directory. Check the configuration file:

```bash
cat ~/.claude/settings.json | grep -A 5 "mcp"
```

This reveals your active MCP server configurations. If servers appear missing from the output, the configuration may have been corrupted or overwritten.

For a cleaner view of the mcpServers block specifically, use Python's built-in JSON tool:

```bash
python3 -c "import json,sys; d=json.load(open('$HOME/.claude/settings.json')); print(json.dumps(d.get('mcpServers',{}), indent=2))"
```

This prints just the MCP server entries with proper formatting, making it easy to spot missing or malformed entries.

## Review Server Logs

MCP servers typically write logs to standard error output. When starting Claude Code, capture stderr to a file for analysis:

```bash
claude 2> mcp-debug.log
```

Search the log for error patterns:

```bash
grep -i "error\|exception\|timeout" mcp-debug.log
```

Most MCP servers follow predictable error patterns. Connection timeouts usually indicate network issues or server unavailability, while authentication errors point to credential problems.

## Test the Server in Isolation

Before assuming Claude Code is the problem, run the MCP server directly to confirm it starts successfully:

```bash
Test filesystem server in isolation
npx @modelcontextprotocol/server-filesystem ~/projects

Test a custom server
node /path/to/my-mcp-server/index.js
```

If the server prints a ready message or stays running without error, the server itself is fine and the issue is in how Claude Code is launching it (path, arguments, or environment variables). If it crashes immediately, you have a server-level problem to fix first.

## Common Incident Types and Solutions

## Connection Timeout Issues

If an MCP server fails to connect within the expected timeout window, the server is unreachable or overloaded. For instance, if you're using the filesystem MCP server and it times out, try restarting it:

```bash
Kill existing server process
pkill -f "mcp-server-filesystem"

Restart with explicit path
npx @modelcontextprotocol/server-filesystem /your/project/path
```

The `tdd` skill and `pdf` skill both rely on MCP servers for file operations. When these fail, your testing and documentation workflows stall.

If the server consistently times out only on large directories, add a path scope restriction to reduce the amount of filesystem indexing on startup:

```json
{
 "mcpServers": {
 "filesystem": {
 "command": "npx",
 "args": [
 "@modelcontextprotocol/server-filesystem",
 "/Users/you/projects/specific-repo"
 ]
 }
 }
}
```

Scoping to a single repo rather than your entire home directory significantly reduces startup time.

## Authentication Failures

Many MCP servers require API keys or tokens. If authentication fails, check your environment variables:

```bash
echo $OPENAI_API_KEY
echo $ANTHROPIC_API_KEY
```

For servers requiring OAuth or API tokens, ensure credentials are set before starting Claude Code. Create a startup script that exports necessary variables:

```bash
#!/bin/bash
export GITHUB_TOKEN="your-token-here"
export NOTION_API_KEY="your-key-here"
claude "$@"
```

A common mistake is setting environment variables in `.bashrc` or `.zshrc` but launching Claude Code from a GUI application that does not source those files. Using a wrapper script eliminates this ambiguity.

For the GitHub MCP server specifically, check that your token has the right scopes. A fine-grained personal access token that lacks `repo` scope will authenticate successfully but fail when trying to read private repositories, producing a confusing partial-failure state.

## Server Process Crashes

When an MCP server process crashes unexpectedly, it often leaves orphaned processes. Clean up before restarting:

```bash
List all node processes related to MCP
ps aux | grep mcp

Kill specific server
kill -9 $(ps aux | grep "server-name" | grep -v grep | awk '{print $2}')
```

The `frontend-design` skill and other visual tools depend on stable MCP server processes. Crashes here affect design iteration workflows.

For Node.js-based MCP servers that crash on out-of-memory errors, increase the heap size:

```json
{
 "mcpServers": {
 "my-server": {
 "command": "node",
 "args": ["--max-old-space-size=512", "/path/to/server.js"]
 }
 }
}
```

## Version Incompatibilities

MCP server packages update independently of Claude Code. A mismatch between the MCP protocol version that Claude Code expects and the version a server implements can cause silent failures where the server starts but tools never appear. Check the server package version:

```bash
npm list -g @modelcontextprotocol/server-filesystem
```

If the installed version is significantly older than what Claude Code currently ships with, update it:

```bash
npm update -g @modelcontextprotocol/server-filesystem
```

For project-local servers, update `package.json` and run `npm install`.

## Advanced Recovery Procedures

## Configuration Reset

If diagnostics reveal configuration corruption, reset the MCP settings:

```bash
Backup current config
cp ~/.claude/settings.json ~/.claude/settings.json.backup

Remove MCP section (Claude will recreate on next startup)
Edit settings.json and remove mcpServers object
```

After resetting, restart Claude Code with verbose logging to capture the fresh configuration process.

A targeted reset that preserves other settings is safer than deleting the entire file. Open `~/.claude/settings.json` in your editor, remove only the `mcpServers` key, save, then restart Claude Code. The MCP servers will be gone from the session but all other settings remain intact.

## Skill Dependency Verification

Some skills depend on specific MCP servers. The `supermemory` skill requires memory server connectivity, while database skills need their respective MCP servers running. Verify skill requirements:

```bash
List available skills
ls ~/.claude/skills/

Check skill dependencies
cat ~/.claude/skills/skill-name.md | grep -i "requires\|mcp"
```

When troubleshooting, disable non-essential skills temporarily to isolate the problematic server. Re-enable them one at a time after recovery.

## Port Conflicts

MCP servers bind to specific ports. Port conflicts cause immediate startup failures. Check for existing listeners:

```bash
lsof -i :port-number
```

Common MCP ports include 3000, 8080, and 5432. If another process occupies the required port, either terminate that process or reconfigure the MCP server to use a different port.

To find which process is holding the port and terminate it safely:

```bash
Find the PID occupying port 3000
lsof -ti :3000

Kill it
kill $(lsof -ti :3000)
```

If the conflicting process is a development server you need to keep running, reconfigure the MCP server to use an alternate port by passing it as an argument or environment variable, check the server's documentation for the right flag.

## Rebuilding a Corrupted Node Modules Tree

For locally cloned MCP servers, a corrupted or incomplete `node_modules` directory is a frequent culprit. The server may start and immediately crash with a module-not-found error:

```bash
cd /path/to/mcp-server
rm -rf node_modules package-lock.json
npm install
```

After reinstalling, confirm the server starts cleanly in isolation before adding it back to Claude Code.

## Incident Response Decision Tree

Use this flow when an MCP server is not working:

```
1. Run: claude --verbose
 |
 +-- Server does not appear in output?
 | --> Check ~/.claude/settings.json for mcpServers entry
 |
 +-- Server appears, "spawn error: ENOENT"?
 | --> Fix command path in settings.json
 |
 +-- Server appears, "timeout during handshake"?
 | --> Run server in isolation to confirm it starts
 | --> Check for port conflict with: lsof -i :PORT
 |
 +-- Server connected, tool calls fail?
 --> Check authentication credentials
 --> Check permission/scope of API tokens
 --> Check server logs for specific error messages
```

Working through this tree systematically prevents you from spending time on authentication issues when the real problem is a missing executable, or vice versa.

## Prevention Strategies

## Health Check Scripts

Implement a startup health check that verifies MCP server availability before launching Claude Code:

```bash
#!/bin/bash
mcp-healthcheck.sh

for server in "server-filesystem" "server-github" "server-brave-search"; do
 if ! pgrep -f "$server" > /dev/null; then
 echo "Warning: $server not running"
 fi
done
```

Run this script before starting Claude Code sessions that require specific MCP functionality.

An enhanced version that also tests network connectivity before checking processes:

```bash
#!/bin/bash
mcp-healthcheck-full.sh

echo "=== MCP Health Check ==="

Check network connectivity (required for remote MCP servers)
if ! curl -s --max-time 3 https://api.github.com/zen > /dev/null; then
 echo "WARNING: GitHub API unreachable. github MCP server will fail auth checks."
fi

Check required environment variables
for var in GITHUB_TOKEN NOTION_API_KEY; do
 if [ -z "${!var}" ]; then
 echo "WARNING: $var is not set. Dependent MCP servers will fail authentication."
 fi
done

Check server processes
for server in "server-filesystem" "server-github" "server-brave-search"; do
 if pgrep -f "$server" > /dev/null; then
 echo "OK: $server is running"
 else
 echo "NOT RUNNING: $server"
 fi
done

echo "=== End Health Check ==="
```

## Configuration Versioning

Track MCP configuration changes in git. Add your settings to version control:

```bash
cd ~/.claude
git init
git add settings.json
git commit -m "MCP configuration baseline"
```

This enables quick rollback if a configuration change introduces problems.

A practical convention is to tag working configurations so you can roll back with a single command:

```bash
git tag stable-mcp-config-2026-03
Later, to restore:
git checkout stable-mcp-config-2026-03 -- settings.json
```

## Monitoring and Alerts

For teams running MCP servers in production environments, implement monitoring. The `algorithmic-art` skill and similar creative tools benefit from uptime monitoring when integrated into production pipelines.

A simple cron-based monitor that alerts you when a server process disappears:

```bash
Add to crontab: crontab -e
*/5 * * * * pgrep -f "server-filesystem" > /dev/null || osascript -e 'display notification "MCP filesystem server is down" with title "Claude Code Alert"'
```

For Linux environments, replace the `osascript` line with a desktop notification command or a webhook call to your team's alert channel.

## Documenting Your MCP Setup for the Team

When multiple developers use Claude Code with shared MCP server configurations, undocumented setups cause repeated incident response cycles. Maintain a short setup document that includes:

- Which MCP servers are in use and their purpose
- Required environment variables for each server
- Known issues and their standard fixes
- The version of each server package that is currently confirmed working

This is particularly important for teams where one person set up the MCP configuration and others are expected to replicate it. The health check script above makes an excellent addition to the project's `scripts/` directory so it is automatically available to every developer who clones the repo.

## Summary

MCP server incidents disrupt Claude Code workflows but follow recognizable patterns. Start with verbose logging to identify the failure type, then apply the appropriate recovery procedure. Connection issues yield to restart and network checks, while authentication problems require credential verification. Version mismatches require package updates. For complex issues, configuration reset combined with health check scripts provides a reliable recovery path.

Regular maintenance, including configuration versioning, health checks, and monitoring, prevents incidents before they impact productivity. Keep your MCP servers running smoothly and maintain uninterrupted development sessions. The investment in a solid diagnostic process pays off quickly: once you have resolved a particular failure type once and documented the fix, you can recover from the same incident in under two minutes on every future occurrence.

---

---

<div class="mastery-cta">

I hit this exact error six months ago. Then I wrote a CLAUDE.md that tells Claude my stack, my conventions, and my error handling patterns. Haven't seen it since.

I run 5 Claude Max subs, 16 Chrome extensions serving 50K users, and bill $500K+ on Upwork. These CLAUDE.md templates are what I actually use. Not theory — production configs.

**[Grab the templates — $99 once, free forever →](https://zovo.one/lifetime?utm_source=ccg&utm_medium=cta-mcp&utm_campaign=claude-code-mcp-server-incident-response-guide)**

47/500 founding spots. Price goes up when they're gone.

</div>

Related Reading

- [Claude Code MCP Server Setup: Complete Guide 2026](/building-your-first-mcp-tool-integration-guide-2026/)
- [MCP Servers vs Claude Skills: What's the Difference?](/mcp-servers-vs-claude-skills-what-is-the-difference/)
- [Claude Code Permissions Model Security Guide 2026](/claude-code-permissions-model-security-guide-2026/)
- [Claude SuperMemory Skill: Persistent Context Explained](/claude-supermemory-skill-persistent-context-explained/)
- [Advanced Claude Skills Hub](/advanced-hub/)
- [Claude Code GitHub Actions MCP Setup](/claude-code-github-actions-mcp/)
- [Claude Code GCP MCP Server Setup](/claude-code-gcp-mcp/)
- [Claude Code Azure DevOps MCP Setup](/claude-code-azure-devops-mcp/)
- [Claude Code FastAPI MCP Server Guide](/claude-code-fastapi-mcp/)
- [Claude Code Firebase MCP Integration](/claude-code-firebase-mcp/)
- [Claude Code Flutter MCP Server Guide](/claude-code-flutter-mcp/)
- [Claude Code Azure MCP Server Guide](/claude-code-azure-mcp/)
- [Kubernetes MCP Server Cluster Management Guide](/kubernetes-mcp-server-cluster-management-guide/)

Built by theluckystrike. More at [zovo.one](https://zovo.one)


