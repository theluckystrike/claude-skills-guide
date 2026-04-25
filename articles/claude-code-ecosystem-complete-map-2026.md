---
layout: default
title: "Claude Code Ecosystem: Tools Map (2026)"
description: "Map of the Claude Code ecosystem in 2026 covering skills, hooks, MCP servers, agent frameworks, and community tools across 14 key repos."
permalink: /claude-code-ecosystem-complete-map-2026/
date: 2026-04-20
last_tested: "2026-04-22"
---

# Claude Code Ecosystem: Complete Tools Map (2026)

The Claude Code ecosystem has grown from a single CLI tool to a network of 14+ major repositories, hundreds of plugins, and thousands of community contributions. This map organizes every major component so you can find what you need without sifting through GitHub trending pages.

## The Ecosystem at a Glance

The Claude Code ecosystem organizes into six layers:

1. **Core CLI** — Claude Code itself (Anthropic)
2. **Configuration** — CLAUDE.md files, settings, and system prompts
3. **Extensions** — Skills, hooks, slash commands, and plugins
4. **Infrastructure** — MCP servers, agent orchestrators, task managers
5. **Knowledge** — Documentation, guides, and learning resources
6. **Monitoring** — Cost tracking, usage analytics, and security tools

Each layer builds on the ones below it. You cannot use skills (Layer 3) effectively without proper configuration (Layer 2), and you cannot configure well without understanding the core CLI (Layer 1).

## Layer 1: Core CLI

Claude Code is Anthropic's official terminal-based coding assistant. It reads your project files, runs commands, and generates code changes. The CLI supports:

- Interactive mode (conversation in terminal)
- API mode (headless, for CI/CD pipelines)
- Multi-agent orchestration (spawning sub-agents)
- Tool use (file read/write, bash, web search, MCP)

The [claude-code-system-prompts](https://github.com/Piebald-AI/claude-code-system-prompts) repo (9K+ stars) documents all 24 built-in tool descriptions and the complete system prompt. This is the reference for understanding what Claude Code can do natively.

## Layer 2: Configuration

Configuration happens at three levels:

### Project Level: CLAUDE.md
The `CLAUDE.md` file in your project root defines architecture, conventions, and behavioral rules. The [andrej-karpathy-skills](https://github.com/forrestchang/andrej-karpathy-skills) repo (72K+ stars) provides the gold standard template built on four principles: Don't Assume, Don't Hide Confusion, Surface Tradeoffs, and Goal-Driven Execution.

For 10 different CLAUDE.md templates compared, see our [CLAUDE.md templates comparison](/claude-md-best-practices-10-templates-compared-2026/).

### User Level: ~/.claude/settings.json
User-wide settings control permissions, hooks, and MCP server connections. The [claude-code-ultimate-guide](https://github.com/FlorianBruniaux/claude-code-ultimate-guide) (4K+ stars, 22K+ lines) documents every available setting with examples.

### Organization Level: Enterprise Config
Team-wide settings distributed via organization policies. See our [enterprise setup guide](/claude-code-enterprise-setup-guide-2026/) for details.

The hierarchy flows: Organization > User > Project. For the full breakdown, see our [configuration hierarchy article](/claude-code-configuration-hierarchy-explained-2026/).

## Layer 3: Extensions

### Skills
Reusable behavioral instructions that modify how Claude Code operates. The [awesome-claude-code-toolkit](https://github.com/rohitg00/awesome-claude-code-toolkit) (1.4K stars) catalogs 135 agents and 35 skills. The [claude-code-my-workflow](https://github.com/pedrohcgs/claude-code-my-workflow) (963 stars) demonstrates domain-specific skills for academic workflows.

### Hooks
Event-driven scripts that run before or after Claude Code actions. Hooks can validate output, run linters, update documentation, and enforce policies. The [claude-code-docs](https://github.com/ericbuess/claude-code-docs) repo uses hooks for auto-updating offline documentation.

For the difference between skills, hooks, and commands, see our [comparison article](/claude-code-skills-vs-hooks-vs-commands-2026/).

### Slash Commands
Interactive shortcuts invoked with `/`. The [SuperClaude Framework](https://github.com/SuperClaude-Org/SuperClaude_Framework) (22K+ stars) provides 30 slash commands covering project management (`/sc:pm`), implementation (`/sc:implement`), testing (`/sc:test`), and more.

### Agent Templates
Pre-configured agent behaviors for specific tasks. The [claude-code-templates](https://github.com/davila7/claude-code-templates) (25K+ stars) offers 600+ agents, 200+ commands, and 55+ MCP configurations accessible via:

```bash
npx claude-code-templates@latest
```

## Layer 4: Infrastructure

### MCP Servers
The Model Context Protocol allows Claude Code to connect to external services. The [awesome-mcp-servers](https://github.com/punkpeye/awesome-mcp-servers) repo (85K+ stars) indexes 200+ servers across 30+ categories: databases, APIs, file systems, cloud services, and development tools.

For setup instructions, see our [MCP servers setup guide](/mcp-servers-claude-code-complete-setup-2026/).

### Task Management
The [claude-task-master](https://github.com/eyaltoledano/claude-task-master) (27K+ stars) parses PRDs into structured task lists with dependencies, priorities, and MCP integration:

```bash
npm install -g task-master-ai
task-master init
```

### Multi-Agent Orchestration
Claude Code supports spawning sub-agents for parallel work. The [awesome-claude-code](https://github.com/hesreallyhim/awesome-claude-code) (40K+ stars) curates orchestration patterns and multi-agent setups. See our [multi-agent architecture guide](/claude-code-multi-agent-architecture-guide-2026/).

## Layer 5: Knowledge

### Documentation
- [claude-code-docs](https://github.com/ericbuess/claude-code-docs) (832 stars) — Offline docs mirror with auto-update
- [claude-howto](https://github.com/luongnv89/claude-howto) (28K+ stars) — Visual guide with Mermaid diagrams
- [claude-code-ultimate-guide](https://github.com/FlorianBruniaux/claude-code-ultimate-guide) (4K+ stars) — 22K+ lines with 271 quiz questions

### Application Patterns
- [awesome-llm-apps](https://github.com/Shubhamsaboo/awesome-llm-apps) (107K+ stars) — 100+ runnable agent and RAG templates, Apache-2.0

## Layer 6: Monitoring

### Cost Tracking
The [ccusage](https://github.com/ryoppippi/ccusage) tool (13K+ stars) parses your local session logs to show per-project cost breakdowns:

```bash
npx ccusage
```

It reads `~/.claude/projects/` JSONL files and provides session-level token and cost analysis.

### Security
The [claude-code-ultimate-guide](https://github.com/FlorianBruniaux/claude-code-ultimate-guide) includes threat modeling for Claude Code workflows. See our [security threat model guide](/claude-code-security-threat-model-2026/) for practical application.

## How to Navigate This Ecosystem

**New to Claude Code?** Start with Layer 2: create a CLAUDE.md using the [Karpathy template](https://github.com/forrestchang/andrej-karpathy-skills).

**Want more productivity?** Move to Layer 3: install [SuperClaude](https://github.com/SuperClaude-Org/SuperClaude_Framework) for slash commands or browse [claude-code-templates](https://github.com/davila7/claude-code-templates).

**Building integrations?** Explore Layer 4: connect [MCP servers](https://github.com/punkpeye/awesome-mcp-servers) and set up [task management](https://github.com/eyaltoledano/claude-task-master).

**Optimizing costs?** Use Layer 6: install [ccusage](https://github.com/ryoppippi/ccusage) for spend tracking.

## FAQ

### How many tools are in the ecosystem?
Across the 14 major repos, there are 600+ agent templates, 200+ MCP servers, 135+ cataloged agents, 30+ slash commands, and dozens of skills and hooks.

### Are these tools officially supported by Anthropic?
No. These are community-built tools. Anthropic maintains only the core Claude Code CLI. Community tools may break with CLI updates.

### Which repo should I install first?
Start with [andrej-karpathy-skills](https://github.com/forrestchang/andrej-karpathy-skills) for your CLAUDE.md, then [claude-code-templates](https://github.com/davila7/claude-code-templates) for agent configurations.

### How do I keep track of ecosystem updates?
The [awesome-claude-code](https://github.com/hesreallyhim/awesome-claude-code) repo is the master index. Star it and check weekly for new additions.

### Is there a cost to using community tools?
The tools themselves are free and open source. Your Claude Code API usage still incurs normal Anthropic charges.

For the full guide to finding and evaluating ecosystem tools, see our [open source landscape overview](/claude-code-open-source-landscape-2026/). For contribution guidelines, read our [community contributions guide](/claude-code-community-contributions-guide-2026/).
