---
title: "Claude Code Docs Offline Mirror Guide (2026)"
description: "Set up claude-code-docs for offline documentation access with auto-update hooks — never lose docs access when the network drops."
permalink: /claude-code-docs-offline-mirror-guide-2026/
last_tested: "2026-04-22"
render_with_liquid: false
---

# Claude Code Docs Offline Mirror Guide (2026)

The `claude-code-docs` repository by Eric Buess (832+ stars) mirrors Claude Code's official documentation for offline access. An auto-update hook keeps the local copy fresh. Install it once, and Claude Code can reference docs even when you're on a plane or behind a restrictive firewall.

## What It Is

A local mirror of Claude Code's documentation — the same content available at docs.anthropic.com — stored as Markdown files on your machine. The repo includes an install script that:

1. Clones the docs to a local directory
2. Sets up a Claude Code hook that checks for doc updates on session start
3. Configures CLAUDE.md to reference the local docs path

Claude Code can then read documentation files directly using its file-reading tools, without making network requests.

## Why It Matters

Claude Code's knowledge cutoff means it sometimes references outdated syntax or deprecated features. The official docs always reflect the current release, but accessing them requires web fetch calls that can fail, timeout, or get rate-limited.

A local mirror eliminates all network dependencies for documentation access. It's also faster — reading a local file takes milliseconds vs. seconds for a web request.

For teams operating in restricted network environments (government, healthcare, financial services), local docs may be the only way to give Claude Code access to its own documentation.

## Installation

### One-Line Install

```bash
curl -fsSL https://raw.githubusercontent.com/ericbuess/claude-code-docs/main/install.sh | bash
```

This script:
- Clones the docs to `~/.claude/docs/claude-code/`
- Creates an auto-update hook in `~/.claude/hooks/`
- Adds a doc reference to `~/.claude/CLAUDE.md`

### Manual Install

```bash
# Clone the docs
git clone https://github.com/ericbuess/claude-code-docs.git ~/.claude/docs/claude-code

# Add to your CLAUDE.md
echo "## Documentation Reference
Local Claude Code docs available at ~/.claude/docs/claude-code/
Read these files for current API syntax and feature documentation." >> ~/.claude/CLAUDE.md
```

### Set Up Auto-Update Hook

Create `~/.claude/hooks/update-docs.sh`:

```bash
#!/bin/bash
cd ~/.claude/docs/claude-code && git pull --quiet 2>/dev/null || true
```

Register it as a session-start hook in `.claude/settings.json`:

```json
{
  "hooks": {
    "session_start": ["~/.claude/hooks/update-docs.sh"]
  }
}
```

## Key Features

1. **Full Doc Mirror** — every page from the official Claude Code documentation, converted to Markdown for easy reading.

2. **Auto-Update Hook** — pulls the latest docs on session start. If the network is unavailable, it silently uses the cached version.

3. **Offline-First** — works without any network access after initial install. The git pull in the hook is non-blocking and failure-tolerant.

4. **Fast Access** — Claude Code reads local files in milliseconds. No web fetch latency, no rate limits, no timeouts.

5. **Version History** — since it's a git repo, you can check out older doc versions to see how features evolved.

6. **Search-Friendly** — Claude Code can grep the local docs directory to find relevant sections, which is faster and more reliable than web search.

## Real Usage Example

### Referencing Docs in a Session

```
You: How do I configure MCP servers in Claude Code?

Claude Code: [reads ~/.claude/docs/claude-code/mcp-configuration.md]

Based on the current documentation, MCP servers are configured in
.claude/settings.json under the "mcpServers" key. Each server needs:

- "command": the binary to run
- "args": command-line arguments (optional)
- "env": environment variables (optional)
- "cwd": working directory (optional)

Example:
{
  "mcpServers": {
    "my-server": {
      "command": "npx",
      "args": ["-y", "my-mcp-server"],
      "env": { "API_KEY": "..." }
    }
  }
}
```

### Searching Docs Programmatically

```
You: Search the local docs for information about hooks

Claude Code: [greps ~/.claude/docs/claude-code/ for "hooks"]

Found 3 relevant files:
- hooks-overview.md — lifecycle hooks (session_start, pre_tool, post_tool)
- hooks-examples.md — 12 example hook scripts
- hooks-api.md — hook parameters and return values
```

## When To Use

- **Restricted network environments** — corporate firewalls, air-gapped systems, government agencies
- **Travel and offline work** — planes, trains, areas with poor connectivity
- **Faster doc access** — local reads are 10-100x faster than web fetches
- **Consistent documentation** — the version on disk doesn't change mid-session from a docs deployment

## When NOT To Use

- **Always-online environments** — if network access is reliable, Claude Code's web fetch works fine for occasional doc lookups
- **Disk-constrained systems** — the full doc mirror is ~50MB; not an issue for most machines but worth noting
- **Rapidly changing doc sections** — if Anthropic pushes doc updates hourly during a major release, the hook's session-start pull might lag behind

## FAQ

### How often does the mirror update?

The auto-update hook runs on every Claude Code session start. If you start 5 sessions a day, it checks for updates 5 times. The git pull is incremental and takes under a second.

### Does this include API documentation?

It mirrors Claude Code CLI documentation, not the Claude API reference. For API docs, check the Anthropic developer documentation separately.

### Can I add my own docs to the same directory?

Yes. Create a `custom/` subdirectory in `~/.claude/docs/` for your own documentation. Reference it in your CLAUDE.md alongside the official docs.

### What if the upstream repo goes away?

Your local clone persists regardless. You lose future updates but keep the current version. Fork the repo for extra safety.

## Our Take

**7/10.** A niche but valuable tool for specific use cases. If you work offline regularly or operate in restricted environments, this is essential. For developers with reliable internet, the benefit is marginal — web fetches work fine most of the time. The auto-update hook is a nice touch that keeps maintenance near zero. Pairs well with [CLAUDE.md best practices](/claude-md-file-best-practices-guide/) for referencing the local docs in your project configuration.

## Related Resources

- [Claude Code Best Practices](/claude-code-best-practices-2026/) — optimizing Claude Code's knowledge access
- [Claude Code Hooks Explained](/claude-code-hooks-explained/) — how the auto-update hook works
- [Claude Skills Directory](/claude-skills-directory-where-to-find-skills/) — other tools for enhancing Claude Code
