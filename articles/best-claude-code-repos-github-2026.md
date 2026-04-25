---
layout: default
title: "Best Claude Code Repos on GitHub (2026)"
description: "Ranked list of the 14 best Claude Code repositories on GitHub in 2026 with star counts, install commands, and honest evaluations."
permalink: /best-claude-code-repos-github-2026/
date: 2026-04-20
last_tested: "2026-04-22"
---

# Best Claude Code Repos on GitHub (2026)

The Claude Code ecosystem spans 14 major repositories with a combined 400K+ GitHub stars. This ranked list evaluates each one on practical value, maintenance quality, and community trust.

## Ranking Criteria

Each repo is scored on:
- **Practical value:** Does it solve a real problem?
- **Maintenance:** Is it actively updated?
- **Documentation:** Can you get started without digging through issues?
- **Community:** Stars, forks, and contributor activity

## 1. awesome-mcp-servers (~85K stars)

**Repository:** [github.com/punkpeye/awesome-mcp-servers](https://github.com/punkpeye/awesome-mcp-servers)

**What:** Curated index of 200+ MCP servers across 30+ categories. The definitive directory for finding integrations between Claude Code and external services.

**Why it is first:** MCP servers are the most powerful extension point in Claude Code. This repo is how you find them. Every Claude Code user who wants integrations needs this.

**Install:** Browse the README and install individual servers per their documentation.

**Pros:** Massive coverage, well-organized categories, regular updates.
**Cons:** Quality varies per server. No automated compatibility testing.
**Limitation:** An index, not a tool. You still need to evaluate and install individual servers.

## 2. andrej-karpathy-skills (~72K stars)

**Repository:** [github.com/forrestchang/andrej-karpathy-skills](https://github.com/forrestchang/andrej-karpathy-skills)

**What:** CLAUDE.md behavioral template with four principles: Don't Assume, Don't Hide Confusion, Surface Tradeoffs, Goal-Driven Execution.

**Why it ranks high:** The simplest tool with the highest impact. One file changes Claude Code behavior across every task. The 72K stars reflect universal applicability.

**Install:**
```bash
curl -o CLAUDE.md https://raw.githubusercontent.com/forrestchang/andrej-karpathy-skills/main/CLAUDE.md
```

**Pros:** Minimal, universal, zero maintenance.
**Cons:** No project-specific config. Behavioral only (no enforcement).
**Limitation:** A starting point, not a complete solution.

## 3. awesome-llm-apps (~107K stars)

**Repository:** [github.com/Shubhamsaboo/awesome-llm-apps](https://github.com/Shubhamsaboo/awesome-llm-apps)

**What:** 100+ runnable agent and RAG templates under Apache-2.0. Not Claude Code-specific but many templates work with Claude.

**Why it ranks here:** The largest collection of practical AI application examples. Useful for learning patterns you can apply in Claude Code workflows.

**Install:** Clone individual examples and follow their READMEs.

**Pros:** 107K stars, Apache-2.0 license, runnable examples, broad coverage.
**Cons:** Not Claude Code-specific. Some examples may need model adaptation.
**Limitation:** A learning resource, not a Claude Code extension.

## 4. awesome-claude-code (~40K stars)

**Repository:** [github.com/hesreallyhim/awesome-claude-code](https://github.com/hesreallyhim/awesome-claude-code)

**What:** Master curated index of skills, hooks, slash commands, agent orchestrators, and plugins. Also at awesomeclaude.ai.

**Why it ranks here:** The closest thing to a marketplace the ecosystem has. If you need to find a Claude Code tool, start here.

**Install:** Browse and install individual tools from the index.

**Pros:** Most comprehensive Claude Code-specific directory. Regular updates.
**Cons:** Index quality depends on submission process. Some entries may be stale.
**Limitation:** Curation, not creation. You still need to evaluate each tool.

## 5. claude-howto (~28K stars)

**Repository:** [github.com/luongnv89/claude-howto](https://github.com/luongnv89/claude-howto)

**What:** Visual guide with Mermaid diagrams and copy-paste templates for Claude Code workflows.

**Install:** Clone or read online. Copy templates into your project.

**Pros:** Visual learning approach. Good for team onboarding. Covers session management, multi-agent, debugging.
**Cons:** Mermaid diagrams do not render in CLAUDE.md. More guide than tool.
**Limitation:** Reference material, not automation.

## 6. claude-task-master (~27K stars)

**Repository:** [github.com/eyaltoledano/claude-task-master](https://github.com/eyaltoledano/claude-task-master)

**What:** AI-powered task management. Parses PRDs into structured task lists with dependencies. MCP integration.

**Install:**
```bash
npm install -g task-master-ai && task-master init
```

**Pros:** Bridges requirements and implementation. MCP integration. Dependency ordering.
**Cons:** Requires well-written PRDs. npm global install.
**Limitation:** Task quality mirrors requirement quality.

## 7. claude-code-templates (~25K stars)

**Repository:** [github.com/davila7/claude-code-templates](https://github.com/davila7/claude-code-templates)

**What:** CLI with 600+ agents, 200+ commands, 55+ MCPs, 60+ settings, 39+ hooks.

**Install:**
```bash
npx claude-code-templates@latest
```

**Pros:** Largest single collection. Interactive menu. Web UI at aitmpl.com.
**Cons:** Variable quality. Some templates are generic.
**Limitation:** Quantity over quality in some areas.

## 8. SuperClaude Framework (~22K stars)

**Repository:** [github.com/SuperClaude-Org/SuperClaude_Framework](https://github.com/SuperClaude-Org/SuperClaude_Framework)

**What:** 30 slash commands, 16 agents, 7 behavioral modes. Full framework.

**Install:**
```bash
pipx install superclaude && superclaude install
```

**Pros:** Most feature-rich option. Structured workflows. Multiple agent types.
**Cons:** Heaviest footprint. Learning curve. May override your config.
**Limitation:** Complexity is the cost of features.

## 9. ccusage (~13K stars)

**Repository:** [github.com/ryoppippi/ccusage](https://github.com/ryoppippi/ccusage)

**What:** CLI for session cost tracking. Parses ~/.claude/projects/ JSONL.

**Install:**
```bash
npx ccusage
```

**Pros:** Instant cost visibility. Per-project breakdown. JSON export.
**Cons:** Individual-only. No team dashboard. No budget alerts.
**Limitation:** Retrospective (shows what you spent, not how to spend less).

## 10. claude-code-system-prompts (~9K stars)

**Repository:** [github.com/Piebald-AI/claude-code-system-prompts](https://github.com/Piebald-AI/claude-code-system-prompts)

**What:** Extracted system prompts, 24 built-in tool descriptions, sub-agent prompts.

**Pros:** Shows Claude Code internals. Helps write CLAUDE.md that complements built-in behavior.
**Cons:** System prompts change with updates. Reference only.
**Limitation:** For understanding, not for direct use.

## 11. claude-code-ultimate-guide (~4K stars)

**Repository:** [github.com/FlorianBruniaux/claude-code-ultimate-guide](https://github.com/FlorianBruniaux/claude-code-ultimate-guide)

**What:** 22K+ lines, 271 quiz questions, threat modeling.

**Pros:** Most thorough learning resource. Security focus. Self-assessment quizzes.
**Cons:** Too long to use as CLAUDE.md. Reference guide.
**Limitation:** Learning resource, not a tool.

## 12. awesome-claude-code-toolkit (~1.4K stars)

**Repository:** [github.com/rohitg00/awesome-claude-code-toolkit](https://github.com/rohitg00/awesome-claude-code-toolkit)

**What:** 135 agents, 35 skills, 42 commands, 176+ plugins.

**Pros:** Fills gaps the main awesome list misses. Well-categorized.
**Cons:** Smaller community. Some overlap with other lists.
**Limitation:** Second-tier index (check awesome-claude-code first).

## 13. claude-code-my-workflow (~963 stars)

**Repository:** [github.com/pedrohcgs/claude-code-my-workflow](https://github.com/pedrohcgs/claude-code-my-workflow)

**What:** Academic LaTeX/R workflow with 28 skills and 14 agents.

**Pros:** Best example of domain-specific customization. Pattern for other domains.
**Cons:** Academic-only. Small community.
**Limitation:** Not usable outside academia without adaptation.

## 14. claude-code-docs (~832 stars)

**Repository:** [github.com/ericbuess/claude-code-docs](https://github.com/ericbuess/claude-code-docs)

**What:** Offline docs mirror with auto-update hook.

**Pros:** Works offline. Auto-updates. Useful for air-gapped environments.
**Cons:** Smallest community. Niche use case.
**Limitation:** Only needed if you work offline.

## Quick Start Recommendation

1. Star [awesome-claude-code](https://github.com/hesreallyhim/awesome-claude-code) for discovery
2. Install [andrej-karpathy-skills](https://github.com/forrestchang/andrej-karpathy-skills) for behavior
3. Run [ccusage](https://github.com/ryoppippi/ccusage) for cost tracking
4. Browse [awesome-mcp-servers](https://github.com/punkpeye/awesome-mcp-servers) for integrations
5. Evaluate [claude-task-master](https://github.com/eyaltoledano/claude-task-master) for task management

For the full ecosystem map, see our [tools overview](/claude-code-ecosystem-complete-map-2026/). For comparing plugin types, read the [skills vs hooks vs commands guide](/claude-code-skills-vs-hooks-vs-commands-2026/). For CLAUDE.md setup, see the [CLAUDE.md best practices guide](/claude-md-best-practices-10-templates-compared-2026/).
