---
title: "SuperClaude vs Claude Code Templates (2026)"
description: "SuperClaude offers 30 slash commands and 16 agents as a framework. Claude Code Templates provides 600+ installable configs via CLI. Full comparison."
permalink: /superclaude-vs-claude-code-templates-2026/
last_tested: "2026-04-22"
render_with_liquid: false
---

# SuperClaude vs Claude Code Templates (2026)

SuperClaude is a framework you live inside. Claude Code Templates is a library you pull from. Both aim to make Claude Code more powerful, but the architectural difference changes everything about how you use them.

## Quick Verdict

**SuperClaude** is for developers who want an opinionated, all-in-one framework with modes and agents built in. **Claude Code Templates** is for developers who want to pick individual components and assemble their own setup. Framework vs library — the classic tradeoff.

## Feature Comparison

| Feature | SuperClaude | Claude Code Templates |
|---|---|---|
| GitHub Stars | ~22K | ~25K |
| Install | `pipx install superclaude` | `npx claude-code-templates@latest` |
| Slash Commands | 30 built-in | 200+ installable |
| Agents | 16 built-in | 600+ installable |
| Behavioral Modes | 7 switchable modes | Per-template behavior |
| MCP Support | Built-in for core MCPs | 55+ MCP configs |
| Hook Templates | Included | 39+ installable |
| Settings Presets | Part of modes | 60+ standalone |
| Web UI | None | aitmpl.com |
| Customization | YAML config | Edit installed files |
| Uninstall | `superclaude uninstall` | Delete files manually |

## Architecture and Philosophy

SuperClaude installs as a system-level framework. Once active, it provides 30 slash commands (`/architect`, `/debug`, `/review`, `/deploy`, etc.) and 16 specialized agents. The 7 behavioral modes — careful, fast, teaching, pair, autonomous, review, and planning — change Claude's personality mid-session. Everything is integrated: commands know about agents, agents respect the active mode, and modes configure the prompts.

Claude Code Templates is a CLI that drops files into your project. Run it, pick what you want, and it copies the configuration. Each template is independent — an agent template does not know about a hook template unless you wire them together. The 600+ agents are not a framework; they are a catalog of individual configurations.

This architectural difference drives most of the tradeoffs below.

## Getting Started Speed

SuperClaude installs in one command and immediately gives you 30 commands. Time to productivity: 5 minutes including reading the quick-start guide.

```bash
pipx install superclaude
superclaude install
```

Claude Code Templates installs in one command but then requires you to browse and select templates. Time to productivity: 10-20 minutes for a basic setup, longer if you explore the full catalog.

```bash
npx claude-code-templates@latest
# Interactive menu: select category → browse → install
```

## Flexibility vs Coherence

SuperClaude's integrated design means everything works together. The `/review` command in "careful" mode produces different output than in "fast" mode. Agents inherit behavioral settings from the active mode. This coherence is valuable — you do not need to manually wire things together.

The cost is flexibility. You cannot easily swap out SuperClaude's review agent for a different one. You cannot mix modes from SuperClaude with agents from another framework. You are inside the framework or you are not.

Claude Code Templates gives you total flexibility. Install a review agent from one contributor, a deployment hook from another, and a custom settings preset from a third. They are just files — you can edit them, combine them, or replace them individually.

The cost is coherence. Nothing is pre-wired. You might install an agent that conflicts with a hook. You might have settings that override each other. The assembly is your responsibility.

For developers who use [custom skills](/claude-skills-directory-where-to-find-skills/), Templates integrates more naturally because each component is independent.

## Update and Maintenance

SuperClaude updates atomically. Run `superclaude update` and you get the latest version of everything. Breaking changes are documented in release notes. Rollback is straightforward.

Templates updates are per-template. There is no `update-all` command. You re-run the CLI and re-install individual templates to get updates. This means you can update one component without touching others, but it also means keeping track of what needs updating.

## Team Workflows

SuperClaude works well for teams that want standardized tooling. Everyone installs the same framework and gets the same commands. Mode selection can be project-specific or team-wide.

Templates works well for teams that want curated tooling. A tech lead can select specific templates, commit them to the repo, and every developer gets the approved set without installing the CLI.

For [building team playbooks](/the-claude-code-playbook/), Templates gives you more granular control over exactly which tools your team uses.

## When To Use Each

**Choose SuperClaude when:**
- You want a complete, integrated framework
- You value coherent modes and agent behaviors
- You prefer convention over configuration
- You want everything working in 5 minutes

**Choose Claude Code Templates when:**
- You want to pick individual components
- You need maximum flexibility and customization
- You want to commit specific templates to your repo
- You want to browse options via web UI before installing

## Final Recommendation

If you like frameworks that make decisions for you (Rails, Next.js), you will like SuperClaude. If you prefer libraries that let you compose your own solution (Express, Fastify), you will prefer Claude Code Templates. Neither is wrong — the choice depends on whether you value coherence or flexibility more. Start with whichever matches your temperament and switch if it does not fit.
