---
title: "Awesome Claude Code (2026)"
description: "Navigate the awesome-claude-code repo — 40K stars of curated skills, hooks, slash-commands, agent orchestrators, and plugins for Claude Code developers."
permalink: /awesome-claude-code-master-index-guide-2026/
last_tested: "2026-04-22"
---

# Awesome Claude Code: Master Resource Index (2026)

The `awesome-claude-code` repository by hesreallyhim is the central hub for Claude Code extensions. At 40K+ stars, it catalogs skills, hooks, slash-commands, agent orchestrators, and plugins — all vetted by the community. Also available at awesomeclaude.ai for browsable access.

## What It Is

A curated, categorized index of everything built on top of Claude Code. Unlike a search engine trawl, every entry is reviewed for quality, maintenance status, and compatibility with the current Claude Code release. Categories span:

- **Skills & Behavioral Profiles** (CLAUDE.md files)
- **Hooks** (pre/post execution scripts)
- **Slash Commands** (custom /commands)
- **Agent Orchestrators** (multi-agent coordination)
- **MCP Integrations** (Model Context Protocol servers)
- **Plugins & Extensions** (full feature packages)

The repo follows the "awesome list" format popularized across GitHub — a single README.md with categorized links, brief descriptions, and star counts.

## Why It Matters

The Claude Code ecosystem crossed 500+ community projects in early 2026. Finding the right tool without a curated index means sifting through GitHub search results of varying quality. This repo solves discovery — it's the first place to check before building something custom.

The maintainers reject submissions that duplicate existing functionality without clear improvement, which keeps signal-to-noise high.

## Installation

There's nothing to install. Bookmark the repo and reference it when you need a tool:

```bash
# Browse the raw list
open https://github.com/hesreallyhim/awesome-claude-code

# Or the web interface
open https://awesomeclaude.ai
```

For offline access:

```bash
git clone https://github.com/hesreallyhim/awesome-claude-code.git ~/references/awesome-claude-code
```

## Key Features

1. **Category Hierarchy** — Resources grouped by type (skills, hooks, commands, agents, MCPs) with sub-categories for specific domains.

2. **Quality Gate** — Every entry passes a review process. Dead repos, unmaintained projects, and low-quality submissions get filtered out.

3. **Star Count Tracking** — Entries include GitHub star counts, updated periodically, so you can gauge community adoption.

4. **Compatibility Tags** — Projects tagged with the Claude Code versions they support, reducing "will this break my setup" guesswork.

5. **Web Interface** — awesomeclaude.ai provides search, filtering, and sorting that the raw README can't match.

6. **Contribution Pipeline** — Clear PR template for submissions, with automated checks for broken links and duplicate entries.

7. **Cross-References** — Related projects link to each other, so discovering one tool surfaces its ecosystem.

8. **Weekly Digest** — The repo's Discussions tab highlights new additions weekly.

## Real Usage Example

Say you need a cost-tracking solution. Instead of searching GitHub:

1. Navigate to the **CLI Tools** section
2. Find [ccusage](/ccusage-claude-code-cost-tracking-guide-2026/) — "CLI for session cost tracking, parses JSONL logs"
3. Check the star count (13K+) and last-updated date

For more on this topic, see [Claude Code for Hoppscotch](/claude-code-for-hoppscotch-workflow-guide/).

For more on this topic, see [Claude Code for Automotive ECU AUTOSAR](/claude-code-automotive-ecu-autosar-2026/).


For more on this topic, see [Claude Code for PocketBase](/claude-code-for-pocketbase-workflow-guide/).


4. Click through to the repo and install

Or you want behavioral guidelines:

1. Navigate to **Skills & CLAUDE.md**
2. Find [andrej-karpathy-skills](/karpathy-claude-code-skills-complete-guide-2026/) — "4 core principles from Karpathy"
3. Evaluate alongside alternatives in the same section

### Using the Web Interface for Filtering

awesomeclaude.ai adds filters the README can't provide:

- **Sort by stars** — find the most-adopted tools first
- **Filter by category** — narrow to just MCP servers, or just hooks
- **Search by keyword** — "cost tracking" or "monorepo" or "testing"
- **Filter by last update** — hide projects not updated in 6+ months

## When To Use

- **Starting a new Claude Code setup** — browse categories to build your initial toolkit
- **Before building a custom tool** — check if someone already built it
- **Evaluating ecosystem health** — star counts and update frequency signal whether a project is production-ready
- **Team onboarding** — share the link as a "Claude Code extension starter kit"
- **Finding MCP servers** — the MCP section cross-references [awesome-mcp-servers](/awesome-mcp-servers-directory-guide-2026/) for the full 200+ list

## When NOT To Use

- **Looking for official Anthropic tooling** — this is community-maintained, not an Anthropic product
- **Need guaranteed stability** — community projects vary in maintenance commitment
- **Enterprise compliance requirements** — you'll need to audit each project individually; the awesome list doesn't vet for security

## FAQ

### How do I submit my project?

Open a PR following the contribution template in CONTRIBUTING.md. Include: project name, one-line description, GitHub URL, and the category it belongs in. The maintainers review weekly.

### How current is the list?

The main README is updated multiple times per week. Star counts refresh less frequently — usually monthly. The awesomeclaude.ai site pulls live data from the GitHub API.

### Are all listed projects free?

The vast majority are open-source. A few entries link to commercial tools with free tiers. The listing notes licensing where applicable.

### How does this compare to awesome-claude-code-toolkit?

The [toolkit repo](/awesome-claude-code-toolkit-135-agents-2026/) focuses specifically on agents, skills, and plugins with deeper categorization. `awesome-claude-code` is broader, covering the full ecosystem including learning resources, articles, and workflow guides alongside tools.

## Our Take

**8/10.** The definitive starting point for Claude Code ecosystem discovery. Loses two points because the raw README gets unwieldy at 500+ entries — the web interface at awesomeclaude.ai compensates, but many developers never discover it. The quality gate is genuinely useful; I've never clicked through to a dead or broken project.

## Related Resources

- [Claude Skills Directory](/claude-skills-directory-where-to-find-skills/) — where to find and install skills
- [Claude Code Best Practices](/karpathy-skills-vs-claude-code-best-practices-2026/) — patterns that complement these tools
- [Claude Code Hooks Explained](/understanding-claude-code-hooks-system-complete-guide/) — deep dive on one of the listed categories

## See Also

- [Awesome Claude Code vs Docs Mirror (2026)](/awesome-claude-code-vs-claude-code-docs-2026/)
