---
layout: default
title: "Fix GitHub MCP Auth Server Registration (2026)"
description: "Resolve the Claude Code GitHub MCP 'incompatible auth server does not support dynamic client registration' error with a step-by-step fix."
date: 2026-04-17
last_modified_at: 2026-04-17
author: "Claude Skills Guide"
permalink: /claude-code-github-mcp-error-incompatible-auth-server-does-not-support-dynamic-client-registration/
categories: [guides]
tags: [claude-code, claude-skills, mcp, github, authentication]
reviewed: true
score: 9
geo_optimized: true
---

When connecting Claude Code to GitHub via MCP, you may hit the error "incompatible auth server does not support dynamic client registration." This article explains why it happens and gives you a working fix in under five minutes.

## The Problem

You have configured the GitHub MCP server in Claude Code and attempted to authenticate. Instead of connecting, Claude Code throws: `incompatible auth server does not support dynamic client registration`. This happens because GitHub's OAuth implementation does not support the dynamic client registration flow that some MCP auth layers attempt by default.

## Quick Solution

**Step 1:** Generate a GitHub Personal Access Token. Go to [github.com/settings/tokens](https://github.com/settings/tokens) and click "Generate new token (classic)." Select scopes: `repo`, `read:org`, and `workflow`.

**Step 2:** Copy the token. It starts with `ghp_`.

**Step 3:** Configure the GitHub MCP server in your Claude Code settings file at `~/.claude/settings.json`:

```json
{
  "mcpServers": {
    "github": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-github"],
      "env": {
        "GITHUB_PERSONAL_ACCESS_TOKEN": "ghp_your_token_here"
      }
    }
  }
}
```

**Step 4:** Restart Claude Code:

```bash
claude --resume
```

**Step 5:** Verify the connection by asking Claude Code to list your repositories. If it returns results, the MCP server is working.

## How It Works

The MCP protocol supports multiple authentication methods. The GitHub MCP server (`@modelcontextprotocol/server-github`) can authenticate via OAuth or via a Personal Access Token (PAT). GitHub's OAuth server does not implement the dynamic client registration endpoint defined in RFC 7591, which is what the MCP auth layer tries first. By passing a PAT through the `GITHUB_PERSONAL_ACCESS_TOKEN` environment variable, you bypass the OAuth flow entirely. The MCP server uses the PAT directly for all GitHub API calls, avoiding the registration handshake that causes the error.

## Common Issues

**Token scope too narrow.** If Claude Code connects but cannot access private repos, your token is missing the `repo` scope. Generate a new token with the correct scopes and update `settings.json`.

**Token stored in project settings instead of global.** If you put the token in `.claude/settings.json` inside a project directory, it only works for that project. Place it in `~/.claude/settings.json` for global access, or use environment variables in your shell profile.

**npx cache serving stale version.** If you previously installed an older version of the GitHub MCP server, npx may serve it from cache. Clear it:

```bash
npx clear-npx-cache
```

Then restart Claude Code.

## Example CLAUDE.md Section

```markdown
# GitHub MCP Integration

## Setup
- GitHub MCP server configured in ~/.claude/settings.json
- Authentication: Personal Access Token (PAT) with repo, read:org, workflow scopes
- Server package: @modelcontextprotocol/server-github

## Usage Rules
- Use MCP github tools for all PR operations (create, review, merge)
- Use MCP github tools to read issues and create branches
- Never hardcode the PAT in project files — it lives in ~/.claude/settings.json env block
- For org repos, ensure the token has read:org scope

## Common Commands
- "List open PRs on this repo"
- "Create a PR from current branch to main"
- "Read issue #42 and summarize it"
```

## Best Practices

1. **Use fine-grained tokens when possible.** GitHub now supports fine-grained PATs that scope access to specific repositories. Use them instead of classic tokens for better security.

2. **Rotate tokens on a schedule.** Set an expiration date when creating the token. Add a calendar reminder to rotate it before expiry.

3. **Keep MCP server packages updated.** Run `npx @modelcontextprotocol/server-github@latest` periodically to pick up bug fixes and new features.

4. **Test the connection after any config change.** Ask Claude Code a simple GitHub question like "list my repos" to confirm the MCP server is responding.

5. **Use project-level settings for team repos.** If different projects need different tokens (e.g., org vs personal), use per-project `.claude/settings.json` instead of the global one.

---


**Try it:** Paste your error into our [Error Diagnostic](/diagnose/) for an instant fix.
---

<div class="mastery-cta">

I'm a solo developer in Vietnam. 50K Chrome extension users. $500K+ on Upwork. 5 Claude Max subscriptions running agent fleets in parallel.

These are my actual CLAUDE.md templates, orchestration configs, and prompts. Not a course. Not theory. The files I copy into every project before I write a line of code.

**[See what's inside →](https://zovo.one/lifetime?utm_source=ccg&utm_medium=cta-default&utm_campaign=claude-code-github-mcp-error-incompatible-auth-server-does-not-support-dynamic-client-registration)**

$99 once. Free forever. 47/500 founding spots left.

</div>

Related Reading

- [Claude Code MCP Server Setup](/claude-code-mcp-server-setup/)
- [Claude Code MCP Server Disconnected](/claude-code-mcp-server-disconnected/)
- [Claude Code ECONNREFUSED MCP Fix](/claude-code-econnrefused-mcp-fix/)

Built by theluckystrike. More at [zovo.one](https://zovo.one)


**Configure it →** Build your MCP config with our [MCP Config Generator](/mcp-config/).

