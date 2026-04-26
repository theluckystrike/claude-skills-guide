---
layout: default
title: "Claude Code Open Source Landscape (2026)"
description: "Overview of the Claude Code open source landscape in 2026 with 14 major repos, contribution trends, and ecosystem growth patterns."
permalink: /claude-code-open-source-landscape-2026/
date: 2026-04-20
last_tested: "2026-04-22"
---

# Claude Code Open Source Landscape (2026)

The Claude Code open source ecosystem has grown from a few hobby projects to a network with over 400K combined GitHub stars. This landscape overview maps the major repositories, their relationships, growth trajectories, and the gaps that still exist.

## The Numbers

| Repository | Stars | Category | License |
|-----------|-------|----------|---------|
| awesome-llm-apps | ~107K | App templates | Apache-2.0 |
| awesome-mcp-servers | ~85K | MCP index | Various |
| andrej-karpathy-skills | ~72K | CLAUDE.md template | MIT |
| awesome-claude-code | ~40K | Master index | MIT |
| claude-howto | ~28K | Documentation | MIT |
| claude-task-master | ~27K | Task management | MIT |
| claude-code-templates | ~25K | Agent templates | MIT |
| SuperClaude Framework | ~22K | Agent framework | MIT |
| ccusage | ~13K | Cost tracking | MIT |
| claude-code-system-prompts | ~9K | System prompts | MIT |
| claude-code-ultimate-guide | ~4K | Documentation | MIT |
| awesome-claude-code-toolkit | ~1.4K | Plugin index | MIT |
| claude-code-my-workflow | ~963 | Academic workflow | MIT |
| claude-code-docs | ~832 | Offline docs | MIT |

**Total:** 14 major repositories, 400K+ combined stars.

## Ecosystem Categories

### Curated Indexes (3 repos, ~127K stars)
The index repositories — [awesome-claude-code](https://github.com/hesreallyhim/awesome-claude-code), [awesome-mcp-servers](https://github.com/punkpeye/awesome-mcp-servers), and [awesome-claude-code-toolkit](https://github.com/rohitg00/awesome-claude-code-toolkit) — serve as discovery layers. They do not provide tools themselves but organize and categorize the ecosystem.

### Configuration & Behavioral (3 repos, ~106K stars)
[andrej-karpathy-skills](https://github.com/forrestchang/andrej-karpathy-skills), [claude-code-templates](https://github.com/davila7/claude-code-templates), and [SuperClaude Framework](https://github.com/SuperClaude-Org/SuperClaude_Framework) define how Claude Code behaves. These range from a single CLAUDE.md file (Karpathy) to a full framework with 30 commands and 16 agents (SuperClaude).

### Infrastructure (1 repo, ~27K stars)
[claude-task-master](https://github.com/eyaltoledano/claude-task-master) is the only major standalone tool. It provides structured task management with PRD parsing, dependency ordering, and MCP integration. This category has the most room for growth.

### Documentation (4 repos, ~42K stars)
[claude-howto](https://github.com/luongnv89/claude-howto), [claude-code-ultimate-guide](https://github.com/FlorianBruniaux/claude-code-ultimate-guide), [claude-code-docs](https://github.com/ericbuess/claude-code-docs), and [claude-code-system-prompts](https://github.com/Piebald-AI/claude-code-system-prompts) cover learning, reference, and internals.

### Monitoring (1 repo, ~13K stars)
[ccusage](https://github.com/ryoppippi/ccusage) is the primary cost tracking tool. It parses local JSONL session logs. There is opportunity for dashboards, team-level tracking, and anomaly detection.

### Application Templates (1 repo, ~107K stars)
[awesome-llm-apps](https://github.com/Shubhamsaboo/awesome-llm-apps) provides 100+ runnable agent and RAG templates. While not Claude Code-specific, many templates work with Claude Code.

### Domain-Specific (1 repo, ~963 stars)
[claude-code-my-workflow](https://github.com/pedrohcgs/claude-code-my-workflow) represents the first wave of domain-specific Claude Code configurations. Its academic focus (LaTeX, R, Stata) shows the template for other domains: legal, medical, financial, etc.

## Growth Patterns

### What is Growing Fast
- **MCP servers:** New servers added weekly as developers connect Claude Code to more services
- **Agent templates:** The template libraries expand continuously as new use cases emerge
- **CLAUDE.md patterns:** Teams share what works, creating a growing knowledge base

### What is Stable
- **Core behavioral frameworks:** Karpathy skills and SuperClaude have found their form
- **Documentation:** The major guides are comprehensive and receive incremental updates

### What is Missing
- **Testing tools:** No dedicated Claude Code output testing framework exists
- **Team dashboards:** ccusage is individual-only; team-level visibility is missing
- **Plugin manager:** No tool manages installing, updating, and removing ecosystem packages
- **Quality verification:** No automated way to verify community skills work as advertised
- **IDE integration:** The ecosystem is terminal-first; IDE plugin wrappers are rare

## Relationship Map

```
awesome-claude-code (master index)
├── Links to → claude-code-templates (agent library)
├── Links to → SuperClaude Framework (command framework)
├── Links to → awesome-mcp-servers (MCP index)
├── Links to → ccusage (monitoring)
└── Links to → claude-code-docs (documentation)

claude-code-templates
├── Includes → 55+ MCP configurations (references awesome-mcp-servers)
├── Includes → 39+ hook recipes
└── Includes → 600+ agent definitions

SuperClaude Framework
├── Uses → CLAUDE.md patterns (similar to andrej-karpathy-skills)
└── Provides → 30 slash commands

claude-task-master
├── Integrates → MCP protocol
└── Outputs → Structured tasks for Claude Code sessions
```

## Contributing Opportunities

### High Impact, Low Effort
- Add a new tool to awesome-claude-code (PR, ~10 minutes)
- Share a CLAUDE.md template for your framework
- Write a hook recipe for a common task

### Medium Impact, Medium Effort
- Build an MCP server for a service not yet covered
- Create a domain-specific workflow (like claude-code-my-workflow for your field)
- Add quiz questions to claude-code-ultimate-guide

### High Impact, High Effort
- Build a team-level cost dashboard
- Create a Claude Code plugin manager
- Build a skill testing framework

See our [contribution guide](/claude-code-community-contributions-guide-2026/) for submission details.



**Configure it →** Build your MCP config with our [MCP Config Generator](/mcp-config/).

## FAQ

**Try it:** Browse 155+ skills in our [Skill Finder](/skill-finder/).

### Is the ecosystem slowing down or speeding up?
Accelerating. MCP server creation is the fastest-growing category, driven by the protocol's adoption across multiple AI tools.

### Which repo should I watch for trends?
[awesome-claude-code](https://github.com/hesreallyhim/awesome-claude-code) — it curates everything else. Star it and check weekly.

### Are there forks or competing ecosystems?
Not yet. The ecosystem is collaborative. Repos link to each other rather than competing. This may change as commercial interests grow.

### How does this compare to other AI tool ecosystems?
Claude Code's open source ecosystem is larger by star count than GitHub Copilot's community tools but smaller than the VS Code extension marketplace overall. The decentralized nature means faster innovation but less consistency.

For the ecosystem architecture, see the [tools map](/claude-code-ecosystem-complete-map-2026/). For plugin evaluation, read the [marketplace guide](/claude-code-plugin-marketplace-guide-2026/). For building your own tools, see the [skill building guide](/how-to-build-your-own-claude-code-skill-2026/).
