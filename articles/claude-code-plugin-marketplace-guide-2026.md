---
title: "Claude Code Plugin Marketplace Guide"
description: "Navigate the Claude Code plugin ecosystem with this guide to finding, evaluating, and installing skills, hooks, and MCP integrations."
permalink: /claude-code-plugin-marketplace-guide-2026/
last_tested: "2026-04-22"
render_with_liquid: false
---

# Claude Code Plugin Marketplace Guide (2026)

There is no official Claude Code plugin marketplace. Instead, the ecosystem is distributed across GitHub repositories, curated lists, and community directories. This guide shows you where to find plugins, how to evaluate them, and how to install them safely.

## Where Plugins Live

Unlike VS Code's centralized marketplace, Claude Code's plugin ecosystem is decentralized. Plugins exist as:

- **CLAUDE.md files** — behavioral instructions you drop into your project
- **Skills** — reusable task-specific instructions
- **Hooks** — event-triggered scripts in `.claude/settings.json`
- **MCP servers** — external service connections
- **Agent templates** — pre-configured behavioral profiles

Each type lives in different repositories and installs differently.

## The Major Plugin Directories

### 1. awesome-claude-code (40K+ stars)
**URL:** [github.com/hesreallyhim/awesome-claude-code](https://github.com/hesreallyhim/awesome-claude-code)
**Also at:** awesomeclaude.ai

The master curated index. This is the closest thing to a marketplace the ecosystem has. It categorizes plugins by type (skills, hooks, slash commands, agent orchestrators) and links to their source repositories. Start here when searching for anything.

### 2. claude-code-templates (25K+ stars)
**URL:** [github.com/davila7/claude-code-templates](https://github.com/davila7/claude-code-templates)
**Web UI:** aitmpl.com

The largest single collection: 600+ agents, 200+ commands, 55+ MCPs, 60+ settings, and 39+ hooks. Install via CLI:

```bash
npx claude-code-templates@latest
```

The interactive menu lets you browse by category and install directly into your project.

### 3. awesome-claude-code-toolkit (1.4K stars)
**URL:** [github.com/rohitg00/awesome-claude-code-toolkit](https://github.com/rohitg00/awesome-claude-code-toolkit)

A second curated index with 135 agents, 35 skills, 42 commands, and 176+ plugins. Good for finding tools the main awesome list might miss.

### 4. awesome-mcp-servers (85K+ stars)
**URL:** [github.com/punkpeye/awesome-mcp-servers](https://github.com/punkpeye/awesome-mcp-servers)

Specifically for MCP server plugins. 200+ servers across 30+ categories including databases, cloud providers, development tools, and communication platforms.

## How to Evaluate a Plugin

Before installing any community plugin, check:

### Security
- Read the source code (most are small enough to review in 10 minutes)
- Check if it runs shell commands or accesses the network
- Look for hardcoded URLs or data collection
- Verify the license permits your use case

### Quality
- **Stars and forks:** More signal, but not definitive
- **Last commit date:** Stale repos may not work with current Claude Code
- **Issue tracker:** Are bugs being addressed?
- **Tests:** Does the repo have test coverage?

### Compatibility
- Check the Claude Code version the plugin was tested against
- Look for a `last_tested` or compatibility section
- Test in a non-production project first

## Installation Methods

### Method 1: CLAUDE.md Drop-In
For behavioral plugins like [andrej-karpathy-skills](https://github.com/forrestchang/andrej-karpathy-skills):

```bash
curl -o CLAUDE.md https://raw.githubusercontent.com/forrestchang/andrej-karpathy-skills/main/CLAUDE.md
```

Or clone as a plugin directory:

```bash
git clone https://github.com/forrestchang/andrej-karpathy-skills.git .claude-plugin
```

### Method 2: CLI Tool Installation
For frameworks like [SuperClaude](https://github.com/SuperClaude-Org/SuperClaude_Framework):

```bash
pipx install superclaude
superclaude install
```

Or [claude-code-templates](https://github.com/davila7/claude-code-templates):

```bash
npx claude-code-templates@latest
```

### Method 3: Manual Configuration
For hooks and MCP servers, add entries to `.claude/settings.json`:

```json
{
  "mcpServers": {
    "server-name": {
      "command": "npx",
      "args": ["-y", "@mcp/server-name"]
    }
  }
}
```

### Method 4: npm Global Install
For standalone tools like [claude-task-master](https://github.com/eyaltoledano/claude-task-master):

```bash
npm install -g task-master-ai
task-master init
```

Or [ccusage](https://github.com/ryoppippi/ccusage):

```bash
npx ccusage
```

## Plugin Categories

### Productivity
- Task management: claude-task-master
- Templates: claude-code-templates
- Workflow automation: SuperClaude Framework

### Code Quality
- Behavioral guidelines: andrej-karpathy-skills
- Type enforcement: available via claude-code-templates
- Linter integration: available via hooks

### Knowledge
- Offline docs: claude-code-docs
- System prompt reference: claude-code-system-prompts
- Visual guides: claude-howto

### Monitoring
- Cost tracking: ccusage
- Security auditing: see claude-code-ultimate-guide

## Building Your Plugin Stack

Start minimal and add based on pain points:

1. **Week 1:** Install andrej-karpathy-skills CLAUDE.md template
2. **Week 2:** Add project-specific rules based on issues you encounter
3. **Week 3:** Install ccusage for cost monitoring
4. **Week 4:** Evaluate SuperClaude or claude-code-templates for workflow automation
5. **Ongoing:** Add MCP servers as integration needs arise

## FAQ

### Can plugins conflict with each other?
Yes. Two plugins that define contradictory CLAUDE.md rules will confuse Claude Code. Review combined instructions for consistency.

### Do plugins slow down Claude Code?
CLAUDE.md instructions add to the context window, consuming tokens. Keep your combined plugin instructions under 2,000 words to avoid significant overhead. Hooks add latency per tool use but do not consume tokens.

### How do I uninstall a plugin?
Remove the relevant section from CLAUDE.md, delete entries from `.claude/settings.json`, or uninstall the global npm package. There is no universal uninstall command.

### Are there paid plugins?
The ecosystem is currently open source. Some repos accept sponsorships but all functionality is free.

### How do I report a broken plugin?
File an issue on the plugin's GitHub repository. Include your Claude Code version, the error message, and steps to reproduce.

For more on specific plugin types, see our [skills vs hooks vs commands comparison](/claude-code-skills-vs-hooks-vs-commands-2026/). For MCP server setup, read the [MCP setup guide](/mcp-servers-claude-code-complete-setup-2026/). For building your own plugins, see our [skill building guide](/how-to-build-your-own-claude-code-skill-2026/).

## See Also

- [Plugin Load Failure Error — Fix (2026)](/claude-code-plugin-load-failure-fix-2026/)
