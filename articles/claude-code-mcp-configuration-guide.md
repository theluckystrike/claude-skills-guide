---
title: "Claude Code MCP Configuration"
description: "Complete guide to configuring MCP servers in Claude Code. Settings.json schema, scope precedence, CLI commands, 5 server examples, and troubleshooting."
permalink: /claude-code-mcp-configuration-guide/
last_tested: "2026-04-24"
render_with_liquid: false
---

# Claude Code MCP Configuration: Full Setup (2026)

MCP (Model Context Protocol) extends Claude Code with external capabilities — databases, APIs, filesystems, and any tool that speaks the MCP protocol. This guide covers every aspect of MCP configuration in Claude Code: where settings live, the complete JSON schema, CLI commands, real server examples, security considerations, and troubleshooting.

## What MCP Is

Model Context Protocol is an open standard that lets AI assistants communicate with external tools through a structured JSON-RPC interface. When you configure an MCP server in Claude Code, you are telling Claude Code to launch a process that provides additional tools.

For example, a PostgreSQL MCP server gives Claude Code the ability to run SQL queries. A GitHub MCP server lets Claude Code create pull requests. A filesystem server provides controlled file access beyond the working directory.

Each MCP server:
- Runs as a separate process alongside Claude Code
- Communicates via stdio (standard input/output)
- Exposes one or more tools with defined input/output schemas
- Is sandboxed — it only accesses what its configuration allows

## Configuration File Locations

Claude Code reads MCP configuration from two locations, with a clear precedence hierarchy.

### User-Level Configuration

```
~/.claude/settings.json
```

This file applies to every Claude Code session on your machine, regardless of which project directory you are in. Use it for servers you want available everywhere.

### Project-Level Configuration

```
<project-root>/.claude/settings.json
```

This file applies only when Claude Code runs inside that specific project directory. It is ideal for project-specific tools and for team configurations that you commit to version control.

### Precedence Rules

When a server name exists in both files, the project-level configuration wins. Specifically:

1. Claude Code loads `~/.claude/settings.json` first
2. Claude Code loads `.claude/settings.json` (project-level) second
3. Project-level entries override user-level entries with the same name
4. Entries that exist only at user level remain available
5. Entries that exist only at project level are added

This means your team can define shared servers in the project config while you keep personal servers in your user config.

## Adding MCP Servers

### Method 1: CLI Commands

The `claude mcp add` command modifies the appropriate settings.json file for you.

**Add at project scope (default):**

```bash
claude mcp add filesystem -- npx -y @modelcontextprotocol/server-filesystem /Users/you/projects
```

**Add at user scope (global):**

```bash
claude mcp add github --scope user -- npx -y @anthropic/mcp-server-github
```

**Add with environment variables:**

```bash
claude mcp add slack -e SLACK_TOKEN=xoxb-your-token -- npx -y @anthropic/mcp-server-slack
```

**Verify your configuration:**

```bash
claude mcp list
```

See the [claude mcp list command reference](/claude-mcp-list-command-guide/) for full CLI details.

### Method 2: Manual JSON Editing

Open the settings file directly and add server entries.

**User-level:**

```bash
nano ~/.claude/settings.json
```

**Project-level:**

```bash
mkdir -p .claude
nano .claude/settings.json
```

## Complete settings.json MCP Schema

The `mcpServers` key in settings.json contains all MCP server definitions:

```json
{
  "mcpServers": {
    "server-name": {
      "command": "npx",
      "args": ["-y", "package-name"],
      "env": {
        "KEY": "value"
      }
    },
    "another-server": {
      "command": "python3",
      "args": ["-m", "my_mcp_server"],
      "env": {
        "DATABASE_URL": "postgresql://localhost/mydb",
        "LOG_LEVEL": "info"
      }
    }
  }
}
```

### Field Reference

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `command` | string | Yes | The executable to launch (`npx`, `node`, `python3`, `docker`, or an absolute path) |
| `args` | string[] | No | Array of arguments passed to the command |
| `env` | object | No | Key-value pairs of environment variables for the server process |

### How the Server Starts

When Claude Code initializes, it runs each configured MCP server as a child process:

```
[command] [args[0]] [args[1]] [args[2]] ...
```

With the environment variables from `env` added to the process environment. The server must communicate via JSON-RPC over stdin/stdout.

## Five Common MCP Server Configurations

<div id="mcp-cfg-gen" style="background:#1a1a2e;border:1px solid #2a2a3a;border-radius:8px;padding:20px;margin:24px 0;font-family:system-ui,-apple-system,sans-serif;">
<h3 style="color:#6ee7b7;margin:0 0 12px 0;font-size:18px;">MCP Config Generator</h3>
<p style="color:#94a3b8;margin:0 0 16px 0;font-size:14px;">Select servers to generate a complete settings.json configuration.</p>
<div style="display:grid;gap:8px;margin-bottom:16px;">
<label style="display:flex;align-items:center;gap:8px;color:#e2e8f0;font-size:14px;cursor:pointer;"><input type="checkbox" class="mcg-cb" data-name="filesystem" data-cmd="npx" data-args='["-y","@modelcontextprotocol/server-filesystem","/path/to/dir"]'> Filesystem (local directory access)</label>
<label style="display:flex;align-items:center;gap:8px;color:#e2e8f0;font-size:14px;cursor:pointer;"><input type="checkbox" class="mcg-cb" data-name="github" data-cmd="npx" data-args='["-y","@anthropic/mcp-server-github"]' data-env='{"GITHUB_TOKEN":"ghp_YOUR_TOKEN"}'> GitHub (repos, issues, PRs)</label>
<label style="display:flex;align-items:center;gap:8px;color:#e2e8f0;font-size:14px;cursor:pointer;"><input type="checkbox" class="mcg-cb" data-name="postgres" data-cmd="npx" data-args='["-y","@anthropic/mcp-server-postgres","postgresql://localhost:5432/mydb"]'> PostgreSQL (database queries)</label>
<label style="display:flex;align-items:center;gap:8px;color:#e2e8f0;font-size:14px;cursor:pointer;"><input type="checkbox" class="mcg-cb" data-name="slack" data-cmd="npx" data-args='["-y","@anthropic/mcp-server-slack"]' data-env='{"SLACK_BOT_TOKEN":"xoxb-YOUR_TOKEN","SLACK_TEAM_ID":"T01234567"}'> Slack (messaging)</label>
<label style="display:flex;align-items:center;gap:8px;color:#e2e8f0;font-size:14px;cursor:pointer;"><input type="checkbox" class="mcg-cb" data-name="brave-search" data-cmd="npx" data-args='["-y","@anthropic/mcp-server-brave-search"]' data-env='{"BRAVE_API_KEY":"BSA_YOUR_KEY"}'> Brave Search (web search)</label>
<label style="display:flex;align-items:center;gap:8px;color:#e2e8f0;font-size:14px;cursor:pointer;"><input type="checkbox" class="mcg-cb" data-name="memory" data-cmd="npx" data-args='["-y","@anthropic/mcp-server-memory"]'> Memory (persistent KV store)</label>
</div>
<pre id="mcg-out" style="background:#0f172a;padding:16px;border-radius:6px;color:#4ade80;font-size:13px;overflow-x:auto;white-space:pre;margin:0 0 12px 0;min-height:60px;">// Select servers above to generate settings.json</pre>
<button onclick="navigator.clipboard.writeText(document.getElementById('mcg-out').textContent).then(function(){var b=this;b.textContent='Copied!';setTimeout(function(){b.textContent='Copy to Clipboard'},2000)}.bind(this))" style="padding:8px 20px;background:#6ee7b7;color:#0f172a;border:none;border-radius:6px;font-weight:600;cursor:pointer;font-size:14px;">Copy to Clipboard</button>
</div>
<script>
document.querySelectorAll('.mcg-cb').forEach(function(cb){cb.addEventListener('change',function(){var servers={};document.querySelectorAll('.mcg-cb:checked').forEach(function(c){var entry={command:c.getAttribute('data-cmd'),args:JSON.parse(c.getAttribute('data-args'))};var envStr=c.getAttribute('data-env');if(envStr)entry.env=JSON.parse(envStr);servers[c.getAttribute('data-name')]=entry;});var out=Object.keys(servers).length>0?JSON.stringify({mcpServers:servers},null,2):'// Select servers above to generate settings.json';document.getElementById('mcg-out').textContent=out;});});
</script>

### 1. Filesystem Server

Gives Claude Code access to directories outside the project root:

```json
{
  "mcpServers": {
    "filesystem": {
      "command": "npx",
      "args": [
        "-y",
        "@modelcontextprotocol/server-filesystem",
        "/Users/you/Documents",
        "/Users/you/Downloads"
      ]
    }
  }
}
```

Each path argument defines an allowed directory. Claude Code can read and write files within these directories through the MCP server's tools.

### 2. GitHub Server

Provides tools for GitHub operations — repositories, issues, pull requests, and code search:

```json
{
  "mcpServers": {
    "github": {
      "command": "npx",
      "args": ["-y", "@anthropic/mcp-server-github"],
      "env": {
        "GITHUB_TOKEN": "ghp_your_personal_access_token"
      }
    }
  }
}
```

Token scopes needed: `repo`, `read:org` (for organization repos), `issues`, `pull_requests`.

### 3. PostgreSQL Server

Connects Claude Code to a PostgreSQL database for querying and schema inspection:

```json
{
  "mcpServers": {
    "postgres": {
      "command": "npx",
      "args": [
        "-y",
        "@anthropic/mcp-server-postgres",
        "postgresql://username:password@localhost:5432/dbname"
      ]
    }
  }
}
```

The connection string is passed as an argument. For security, consider using environment variables:

```json
{
  "mcpServers": {
    "postgres": {
      "command": "npx",
      "args": ["-y", "@anthropic/mcp-server-postgres"],
      "env": {
        "DATABASE_URL": "postgresql://username:password@localhost:5432/dbname"
      }
    }
  }
}
```

### 4. Slack Server

Enables Claude Code to read and send Slack messages:

```json
{
  "mcpServers": {
    "slack": {
      "command": "npx",
      "args": ["-y", "@anthropic/mcp-server-slack"],
      "env": {
        "SLACK_BOT_TOKEN": "xoxb-your-bot-token",
        "SLACK_TEAM_ID": "T01234567"
      }
    }
  }
}
```

### 5. Custom MCP Server

For a server you built yourself:

```json
{
  "mcpServers": {
    "my-custom-tools": {
      "command": "node",
      "args": ["/Users/you/mcp-servers/my-tools/dist/index.js"],
      "env": {
        "CONFIG_PATH": "/Users/you/.config/my-tools/config.json",
        "DEBUG": "true"
      }
    }
  }
}
```

For Python-based custom servers:

```json
{
  "mcpServers": {
    "my-python-tools": {
      "command": "python3",
      "args": ["-m", "my_mcp_server"],
      "env": {
        "PYTHONPATH": "/Users/you/mcp-servers/my-python-tools"
      }
    }
  }
}
```

## Troubleshooting MCP Configuration

### Connection Refused

**Symptom:** Server appears in `claude mcp list` but tools are unavailable.

**Causes and fixes:**

1. **Package not installed:** Run the npx command manually to verify:
   ```bash
   npx -y @modelcontextprotocol/server-filesystem --help
   ```

2. **Node.js not found:** Ensure `npx` is in your PATH:
   ```bash
   which npx
   ```

3. **Port conflicts:** If the server uses a network port, check for conflicts:
   ```bash
   lsof -i :PORT_NUMBER
   ```

See the [MCP connection refused fix](/claude-code-mcp-server-connection-refused-fix/) for a comprehensive troubleshooting walkthrough.

### Timeout During Startup

**Symptom:** Claude Code hangs or shows a timeout error when starting.

**Causes and fixes:**

1. **Slow package download:** The first time `npx -y` runs, it downloads the package. On slow connections, this can exceed the timeout. Pre-install the package:
   ```bash
   npm install -g @modelcontextprotocol/server-filesystem
   ```
   Then use the global path instead of npx.

2. **Server crashes on startup:** Run the server command directly to see error output:
   ```bash
   npx -y @anthropic/mcp-server-postgres postgresql://localhost/mydb
   ```

See the [MCP stdio timeout fix](/claude-code-mcp-server-stdio-timeout-fix-2026/) for timeout-specific solutions.

---

*This configuration is one of 200 production-ready templates in [The Claude Code Playbook](https://zovo.one/pricing). Permission configs, model selection rules, MCP setups — all tested and ready to copy.*

### Authentication Failures

**Symptom:** Server connects but API calls fail with 401/403 errors.

**Causes and fixes:**

1. **Missing or expired token:** Verify your token is valid:
   ```bash
   curl -H "Authorization: token YOUR_GITHUB_TOKEN" https://api.github.com/user
   ```

2. **Wrong env variable name:** Check the server's documentation for the exact environment variable name it expects.

3. **Token scope too narrow:** GitHub tokens need specific scopes. Regenerate with the required permissions.

### Server Not Appearing in List

Run these checks in order:

```bash
# 1. Check JSON validity
python3 -m json.tool ~/.claude/settings.json
python3 -m json.tool .claude/settings.json

# 2. Verify the file exists in the expected location
ls -la ~/.claude/settings.json
ls -la .claude/settings.json

# 3. List all configured servers
claude mcp list

# 4. Reset MCP state
claude mcp reset
```

## Security Considerations

### MCP Server Permissions

Each MCP server runs with the permissions of your user account. A malicious server can:
- Read files on your system
- Execute arbitrary commands
- Access network resources
- Exfiltrate data

**Mitigations:**
- Only install MCP servers from trusted sources
- Review the server's source code before installation
- Use project-level configuration to limit server availability
- Set the `env` field to provide only the minimum required credentials

### Tool Allow and Deny Lists

Claude Code supports configuring which MCP tools are allowed or blocked. This adds a layer of control beyond what the server itself provides. See the [MCP tool allow/deny list guide](/claude-code-mcp-tool-allow-and-deny-lists/) for configuration details.

### Sandboxing

MCP servers run as child processes of Claude Code. They inherit your user's permissions. For stronger isolation:
- Run servers in Docker containers
- Use a restricted service account
- Limit filesystem access to specific directories

See the [MCP server sandbox isolation guide](/mcp-server-sandbox-isolation-security-guide/) for advanced patterns.

### Credential Management

Never hardcode credentials directly in `settings.json` if the file is committed to version control. Options:

1. **Use environment variables at the shell level** and reference them:
   ```bash
   export GITHUB_TOKEN=ghp_your_token
   ```
   Then in settings.json, the server reads from the process environment.

2. **Use `.claude/settings.local.json`** (gitignored) for sensitive values.

3. **Use a secrets manager** and inject values at runtime.

See the [MCP credential management guide](/mcp-credential-management-and-secrets-handling/) for comprehensive strategies.

## Verifying MCP Server Configuration

After configuring servers, verify the setup works end to end.

### Step 1: Check the Configuration

```bash
claude mcp list
```

All configured servers should appear with correct names and scopes.

### Step 2: Start Claude Code

```bash
claude
```

Watch the startup output. MCP servers are initialized during startup, and you should see connection confirmations.

### Step 3: Test a Tool

Ask Claude to use a tool from one of your configured servers:

```
List the files in /Users/you/Documents using the filesystem MCP server
```

If the tool works, your configuration is correct.

### Step 4: Check for Errors

If a server fails to connect, Claude Code will display a warning. Check the server's stderr output by running its command manually in a terminal.

## Frequently Asked Questions

### Can I use the same settings.json for Claude Code and Claude Desktop?

No. Claude Code uses `.claude/settings.json` (in the project root or home directory), while Claude Desktop uses `claude_desktop_config.json` in the OS-specific application data directory. They are separate files with the same `mcpServers` schema. See the [claude_desktop_config.json guide](/claude-desktop-config-json-guide/) for the Desktop configuration.

### How many MCP servers can I configure?

There is no hard limit. Practically, each server is a running process that consumes memory, and each server's tools are added to Claude's context, consuming tokens. More than 10 concurrent servers may affect performance. See [managing excessive MCP context](/claude-code-mcp-tools-excessive-context-fix/) for optimization.

### Can I configure remote MCP servers?

The standard configuration supports local stdio-based servers. For remote servers, you need an MCP server that supports HTTP/SSE transport. See the [remote MCP server setup guide](/claude-code-mcp-remote-http-server-setup/).

### Do MCP servers persist across sessions?

The configuration persists (it is a file on disk). Servers are started fresh when Claude Code starts and stopped when Claude Code exits. They do not run as background daemons.

### Can I share project MCP configuration with my team?

Yes. Commit `.claude/settings.json` to your repository. Team members will automatically get the same MCP server configuration when they clone the project. Ensure no secrets are hardcoded in the file.

### What MCP protocol version does Claude Code support?

Claude Code supports the current MCP specification. Servers built with the official MCP SDK are compatible. Check the [MCP specification](https://spec.modelcontextprotocol.io/) for protocol details.

## Related Guides

- [Claude MCP List Command Reference](/claude-mcp-list-command-guide/) — full CLI command details
- [How to Add an MCP Server](/how-to-add-mcp-server-claude-code-2026/) — step-by-step walkthrough
- [Best MCP Servers for Claude Code](/best-mcp-servers-for-claude-code-2026/) — curated recommendations
- [MCP Servers Complete Setup](/mcp-servers-claude-code-complete-setup-2026/) — end-to-end guide
- [MCP Server Connection Refused Fix](/claude-code-mcp-server-connection-refused-fix/) — troubleshooting
- [Awesome MCP Servers Directory](/awesome-mcp-servers-directory-guide-2026/) — find servers to install
- [claude_desktop_config.json Guide](/claude-desktop-config-json-guide/) — Desktop app configuration
- [Configuration Hierarchy Explained](/claude-code-configuration-hierarchy-explained-2026/) — settings precedence
- [The Claude Code Playbook](/playbook/) — comprehensive workflow reference
- [Sequential Thinking in Claude Code](/sequential-thinking-claude-code-guide/) — structured problem solving with MCP
- [Claude Code + Supabase MCP](/claude-code-mcp-supabase-setup-guide/) — Supabase database through MCP

### Can I use environment variables from my shell in the env field?

No. The env field in settings.json accepts literal string values only. Shell variable expansion does not occur. You must hardcode the value or use a secrets management approach.

### Do MCP servers slow down Claude Code startup?

Each server adds startup time as it initializes. With npx, the first run downloads the package which can take several seconds. Pre-install packages globally to reduce startup delay.

### Can I use MCP servers with Claude Code in API mode?

Yes. MCP servers work in both interactive mode and API mode (claude -p). The servers are initialized at startup regardless of the execution mode.

### What happens if two MCP servers provide tools with the same name?

Claude Code will see both tools and may use either one. To avoid confusion, ensure server tools have unique names or only enable one server that provides a particular capability.

<script type="application/ld+json">
{
  "@context": "https://schema.org",
  "@type": "FAQPage",
  "mainEntity": [
    {"@type": "Question", "name": "Can I use the same settings.json for Claude Code and Claude Desktop?", "acceptedAnswer": {"@type": "Answer", "text": "No. Claude Code uses .claude/settings.json while Claude Desktop uses claude_desktop_config.json in the OS-specific app data directory. They are separate files with the same mcpServers schema."}},
    {"@type": "Question", "name": "How many MCP servers can I configure?", "acceptedAnswer": {"@type": "Answer", "text": "There is no hard limit. Practically, each server is a running process that consumes memory, and each server's tools consume tokens. More than 10 concurrent servers may affect performance."}},
    {"@type": "Question", "name": "Can I configure remote MCP servers?", "acceptedAnswer": {"@type": "Answer", "text": "The standard configuration supports local stdio-based servers. For remote servers, you need an MCP server that supports HTTP/SSE transport."}},
    {"@type": "Question", "name": "Do MCP servers persist across sessions?", "acceptedAnswer": {"@type": "Answer", "text": "The configuration persists as a file on disk. Servers are started fresh when Claude Code starts and stopped when Claude Code exits. They do not run as background daemons."}},
    {"@type": "Question", "name": "Can I share project MCP configuration with my team?", "acceptedAnswer": {"@type": "Answer", "text": "Yes. Commit .claude/settings.json to your repository. Team members will automatically get the same MCP server configuration. Ensure no secrets are hardcoded."}},
    {"@type": "Question", "name": "What MCP protocol version does Claude Code support?", "acceptedAnswer": {"@type": "Answer", "text": "Claude Code supports the current MCP specification. Servers built with the official MCP SDK are compatible."}},
    {"@type": "Question", "name": "Can I use environment variables from my shell in the env field?", "acceptedAnswer": {"@type": "Answer", "text": "No. The env field in settings.json accepts literal string values only. Shell variable expansion does not occur. You must hardcode the value or use a secrets management approach."}},
    {"@type": "Question", "name": "Do MCP servers slow down Claude Code startup?", "acceptedAnswer": {"@type": "Answer", "text": "Each server adds startup time as it initializes. With npx, the first run downloads the package which can take several seconds. Pre-install packages globally to reduce startup delay."}},
    {"@type": "Question", "name": "Can I use MCP servers with Claude Code in API mode?", "acceptedAnswer": {"@type": "Answer", "text": "Yes. MCP servers work in both interactive mode and API mode. The servers are initialized at startup regardless of the execution mode."}},
    {"@type": "Question", "name": "What happens if two MCP servers provide tools with the same name?", "acceptedAnswer": {"@type": "Answer", "text": "Claude Code will see both tools and may use either one. To avoid confusion, ensure server tools have unique names or only enable one server that provides a particular capability."}}
  ]
}
</script>
