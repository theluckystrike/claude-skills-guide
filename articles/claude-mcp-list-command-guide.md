---
title: "Claude MCP List Command: Full Reference (2026)"
description: "Complete reference for claude mcp list and all MCP CLI commands. Syntax, output format, scope options, config locations, and troubleshooting."
permalink: /claude-mcp-list-command-guide/
last_tested: "2026-04-24"
render_with_liquid: false
---

# Claude MCP List Command: Full Reference (2026)

The `claude mcp list` command shows every MCP server configured for your current Claude Code session. It is the fastest way to verify which servers are available, check their status, and confirm scope. This reference covers the full MCP CLI surface area — every subcommand, flag, and output field.

## What `claude mcp list` Does

When you run `claude mcp list`, Claude Code reads your configuration files and displays every registered MCP server along with its scope, command, and arguments. The output tells you exactly what Claude Code will attempt to connect to when you start a session.

```bash
claude mcp list
```

Sample output:

```
- filesystem (user): npx -y @modelcontextprotocol/server-filesystem /Users/you/projects
- github (project): npx -y @anthropic/mcp-server-github
- postgres (user): npx -y @anthropic/mcp-server-postgres postgresql://localhost:5432/mydb
```

Each line includes:
- **Server name** — the identifier you assigned when adding the server
- **Scope** — `user` (global) or `project` (local to repository)
- **Command and arguments** — the exact process Claude Code will launch

## Complete MCP CLI Command Reference

Claude Code provides five MCP subcommands. Here is every one of them with full syntax.

### `claude mcp list` — List All Servers

```bash
claude mcp list
```

Lists all configured MCP servers from both user-level and project-level configuration files. No flags required. The output includes servers from every scope, clearly labeled.

If no servers are configured, the output is empty.

### `claude mcp add` — Add a New Server

Basic syntax for adding a project-scoped server:

```bash
claude mcp add <name> -- <command> [args...]
```

Add a user-scoped (global) server:

```bash
claude mcp add <name> --scope user -- <command> [args...]
```

Add with environment variables:

```bash
claude mcp add <name> -e KEY=value -e ANOTHER_KEY=value -- <command> [args...]
```

The double dash (`--`) separates Claude Code flags from the server command. Everything after `--` is passed directly to the MCP server process.

**Examples:**

```bash
# Add a filesystem server at project scope
claude mcp add filesystem -- npx -y @modelcontextprotocol/server-filesystem /Users/you/projects

# Add GitHub server globally
claude mcp add github --scope user -- npx -y @anthropic/mcp-server-github

# Add Postgres with connection string
claude mcp add postgres -- npx -y @anthropic/mcp-server-postgres postgresql://localhost:5432/mydb

# Add a server with API keys as environment variables
claude mcp add slack -e SLACK_TOKEN=xoxb-your-token -- npx -y @anthropic/mcp-server-slack
```

### `claude mcp remove` — Remove a Server

```bash
claude mcp remove <name>
```

Removes the named server from the configuration file where it is defined. If the server exists in both user and project scope, you may need to specify scope:

```bash
claude mcp remove <name> --scope user
claude mcp remove <name> --scope project
```

After removal, run `claude mcp list` to confirm the server no longer appears.

### `claude mcp serve` — Start Claude Code as an MCP Server

```bash
claude mcp serve
```

This command starts Claude Code itself as an MCP server, allowing other MCP clients to connect to it. This is useful for:

- Connecting Claude Code to Claude Desktop
- Chaining Claude Code as a tool within another agent
- Building multi-agent pipelines where Claude Code is one node

The server runs on stdio by default, communicating via JSON-RPC over standard input and output.

### `claude mcp reset` — Reset Server State

```bash
claude mcp reset
```

Resets the connection state for all MCP servers. Use this when a server is stuck in a disconnected state or after making configuration changes that are not being picked up.

## Scope Options Explained

MCP servers can be configured at two levels. The `--scope` flag controls which level is used.

### `--scope user` (Global)

Stored in `~/.claude/settings.json`. Available in every Claude Code session on your machine, regardless of which directory you are working in.

Best for:
- Personal productivity tools (GitHub, Slack, Brave Search)
- Database servers you use across multiple projects
- General-purpose utilities (filesystem, memory)

### `--scope project` (Local)

Stored in `.claude/settings.json` within your project directory. Only available when Claude Code runs inside that specific project.

Best for:
- Project-specific databases
- Custom MCP servers built for a particular codebase
- Shared team configurations (commit the file to version control)

**Precedence rule:** Project-scoped configuration overrides user-scoped configuration when a server with the same name exists in both.

## Where MCP Configuration Is Stored

All MCP server definitions live in JSON settings files.

**User-level configuration:**
```
~/.claude/settings.json
```

**Project-level configuration:**
```
<project-root>/.claude/settings.json
```

Both files share the same schema:

```json
{
  "mcpServers": {
    "server-name": {
      "command": "npx",
      "args": ["-y", "package-name"],
      "env": {
        "API_KEY": "your-key"
      }
    }
  }
}
```

You can edit these files manually instead of using the CLI. The CLI commands are convenience wrappers that modify these JSON files for you.

## Example: Adding a Filesystem MCP Server

The filesystem server gives Claude Code explicit read and write access to directories you specify. Here is the full process from installation to verification.

**Step 1 — Add the server:**

```bash
claude mcp add filesystem -- npx -y @modelcontextprotocol/server-filesystem /Users/you/documents
```

**Step 2 — Verify it appears:**

```bash
claude mcp list
```

Expected output:

```
- filesystem (project): npx -y @modelcontextprotocol/server-filesystem /Users/you/documents
```

**Step 3 — Start Claude Code and confirm connection:**

```bash
claude
```

When Claude Code starts, it will initialize the filesystem MCP server. You should see the server tools become available. You can ask Claude to list files in the allowed directory to verify.

## Example: Adding a Database MCP Server

Database MCP servers let Claude Code query and inspect your database schema directly.

**PostgreSQL:**

```bash
claude mcp add postgres --scope user -- npx -y @anthropic/mcp-server-postgres postgresql://localhost:5432/mydb
```

**SQLite:**

```bash
claude mcp add sqlite -- npx -y @anthropic/mcp-server-sqlite /path/to/database.db
```

**Verify both are listed:**

```bash
claude mcp list
```

```
- postgres (user): npx -y @anthropic/mcp-server-postgres postgresql://localhost:5432/mydb
- sqlite (project): npx -y @anthropic/mcp-server-sqlite /path/to/database.db
```

## Troubleshooting: MCP Server Not Showing in List

If you added a server but it does not appear in `claude mcp list`, check these causes in order.

### 1. Wrong Scope

You may have added the server at user scope but are checking from a project that overrides it, or vice versa. Inspect both files:

```bash
cat ~/.claude/settings.json
cat .claude/settings.json
```

### 2. JSON Syntax Error

A malformed JSON file silently fails. Validate the file:

```bash
python3 -m json.tool ~/.claude/settings.json
python3 -m json.tool .claude/settings.json
```

Common JSON mistakes:
- Trailing commas after the last item in an object or array
- Missing quotes around keys or values
- Single quotes instead of double quotes

### 3. Server Name Collision

If both the user and project config define a server with the same name, only the project version appears. Rename one if you need both.

### 4. Outdated Session

Claude Code reads configuration at startup. If you added a server after starting a session, restart Claude Code or run:

```bash
claude mcp reset
```

### 5. Command Not Found

The server binary or npx package might not be installed. Test the command directly:

```bash
npx -y @modelcontextprotocol/server-filesystem --help
```

If this fails, the server will not start and may not appear as available. See the [MCP connection refused fix](/claude-code-mcp-server-connection-refused-fix/) for deeper troubleshooting.

## Comparing MCP CLI vs Manual Configuration

| Action | CLI Command | Manual Edit |
|--------|-------------|-------------|
| Add server | `claude mcp add name -- cmd` | Edit `settings.json`, add to `mcpServers` |
| Remove server | `claude mcp remove name` | Edit `settings.json`, delete the entry |
| List servers | `claude mcp list` | `cat settings.json` and read `mcpServers` |
| Change scope | Re-add with `--scope` flag | Move the entry between config files |

The CLI is faster for quick changes. Manual editing is better when configuring multiple servers at once or when you need to set complex environment variables.

## Frequently Asked Questions

### Does `claude mcp list` show servers from both scopes?

Yes. The output includes servers from both `~/.claude/settings.json` (user scope) and `.claude/settings.json` (project scope), with scope labels next to each entry.

### Can I have the same server name in both scopes?

Technically yes, but the project-scoped version takes precedence. The user-scoped version will be hidden for that project.

### How do I see which tools a server provides?

Start Claude Code and ask it to list available MCP tools, or check the server's documentation. The `claude mcp list` command shows servers, not individual tools.

### Can I add an MCP server that uses Docker?

Yes. Pass the Docker command after the double dash:

```bash
claude mcp add my-server -- docker run -i my-mcp-server:latest
```

The server must communicate via stdio (stdin/stdout).

### What happens if an MCP server crashes after startup?

Claude Code will show a disconnection warning. The server will not be available until you restart Claude Code or run `claude mcp reset`.

### Can I temporarily disable a server without removing it?

There is no built-in disable flag. The simplest approach is to comment out the server in the JSON config file or temporarily remove it with `claude mcp remove` and re-add it later. See the [MCP configuration hierarchy guide](/claude-code-configuration-hierarchy-explained-2026/) for details on how config files are loaded.

### How many MCP servers can I run simultaneously?

There is no hard limit, but each server is a running process. Performance may degrade with more than 10 concurrent servers due to memory overhead and tool list size affecting Claude's context window. See [managing MCP tool context overhead](/claude-code-mcp-tools-excessive-context-fix/) for optimization tips.

### Does `claude mcp list` work without an internet connection?

Yes. The command reads local configuration files only. It does not contact any remote service.

## Related Guides

- [How to Add an MCP Server to Claude Code](/how-to-add-mcp-server-claude-code-2026/) — step-by-step installation walkthrough
- [Best MCP Servers for Claude Code](/best-mcp-servers-for-claude-code-2026/) — curated list of high-value servers
- [MCP Servers Complete Setup Guide](/mcp-servers-claude-code-complete-setup-2026/) — end-to-end configuration from scratch
- [MCP Server Connection Refused Fix](/claude-code-mcp-server-connection-refused-fix/) — troubleshoot servers that fail to start
- [Awesome MCP Servers Directory](/awesome-mcp-servers-directory-guide-2026/) — community directory of available servers
- [The Claude Code Playbook](/the-claude-code-playbook/) — comprehensive workflow reference
- [Claude Code Best Practices](/claude-code-claude-md-best-practices/) — optimize your Claude Code setup
- [Configuration Hierarchy Explained](/claude-code-configuration-hierarchy-explained-2026/) — how user, project, and system configs interact
- [Claude Code MCP Configuration Guide](/claude-code-mcp-configuration-guide/) — full MCP setup reference
