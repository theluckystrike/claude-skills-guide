---
layout: default
title: "Awesome Claude Code Toolkit: 135 Agents (2026)"
description: "Explore the awesome-claude-code-toolkit — 135 agents, 35 skills, 42 commands, 176+ plugins, and 20 hooks curated for Claude Code developers."
permalink: /awesome-claude-code-toolkit-135-agents-2026/
date: 2026-04-20
last_tested: "2026-04-22"
---

# Awesome Claude Code Toolkit: 135 Agents (2026)

The `awesome-claude-code-toolkit` repository by Rohit Ghumare (1.4K+ stars) is a specialized catalog of Claude Code agents, skills, commands, plugins, and hooks. It tracks 135 agents, 35 skills (plus 400K+ via SkillKit integration), 42 commands, 176+ plugins, and 20 hooks — all with compatibility notes and install instructions.

## What It Is

A curated index that goes deeper than general-purpose awesome lists. Where [awesome-claude-code](/awesome-claude-code-master-index-guide-2026/) catalogs the full ecosystem, this toolkit focuses specifically on actionable components you install into Claude Code:

- **135 Agents** — pre-configured behavioral profiles for specialized roles
- **35 Core Skills** — standalone CLAUDE.md rule packages
- **400K+ SkillKit Skills** — integration with the SkillKit marketplace
- **42 Commands** — custom slash commands for `.claude/commands/`
- **176+ Plugins** — full feature packages combining skills, commands, and hooks
- **20 Hooks** — lifecycle scripts for session start, pre/post tool execution

Each entry includes install method, compatibility version, description, and a link to the source repo.

## Why It Matters

Finding Claude Code components is scattered across GitHub, npm, and community forums. This toolkit consolidates them into one searchable, categorized list. The focus on install-ready components (not tutorials or articles) means every entry is something you can use immediately.

The SkillKit integration is notable — it bridges the gap between the 35 manually curated skills and the 400K+ skills available in the SkillKit marketplace, with quality ratings to help you filter.

## Installation

The toolkit itself is a reference list. Browse it on GitHub:

```bash
open https://github.com/rohitg00/awesome-claude-code-toolkit
```

To install listed components, follow each entry's install instructions. Common patterns:

```bash
# Agent (CLAUDE.md behavioral profile)
curl -o .claude/agents/security-auditor.md \
  https://raw.githubusercontent.com/example/agents/security-auditor.md

# Command (slash command)
curl -o .claude/commands/review.md \
  https://raw.githubusercontent.com/example/commands/review.md

# Hook (lifecycle script)
curl -o .claude/hooks/pre-commit-lint.sh \
  https://raw.githubusercontent.com/example/hooks/pre-commit-lint.sh
chmod +x .claude/hooks/pre-commit-lint.sh
```

## Key Features

1. **135 Categorized Agents** — agents grouped by role: code reviewer, test writer, documentation generator, security auditor, DevOps engineer, database architect, API designer, and more.

2. **Quality Tiers** — entries rated by community usage and maintenance status. Top-tier agents have 1K+ installs and active maintenance.

3. **SkillKit Bridge** — connects to the SkillKit marketplace for 400K+ additional skills. Quality ratings help filter the signal from the noise.

4. **Install Commands** — every entry includes the exact command to install. No hunting through READMEs.

5. **Compatibility Matrix** — entries tagged with supported Claude Code versions. Avoid installing plugins that require features your version lacks.

6. **Plugin Bundles** — the 176+ plugins are pre-assembled combinations of skills, commands, and hooks that work together. Install one plugin, get a coherent toolset.

For more on this topic, see [Claude Code for StyleX Meta](/claude-code-for-stylex-meta-workflow-guide/).

For more on this topic, see [Claude Code for AeroSpace Tiling](/claude-code-for-aerospace-tiling-workflow-guide/).


For more on this topic, see [Claude Code for Particle Physics ROOT](/claude-code-particle-physics-root-2026/).



7. **Hook Library** — 20 curated hooks for common needs: linting, testing, logging, cost tracking, and documentation generation.

8. **Weekly Updates** — the maintainer adds new entries multiple times per week as the ecosystem grows.

## Real Usage Example

### Finding and Installing an Agent

Need a code review agent? Browse the Agents category:

```
Category: Code Review
  1. strict-reviewer (★★★★★) — 5-severity scale, OWASP-aware
  2. gentle-reviewer (★★★★☆) — educational tone, suggestions not demands
  3. perf-reviewer (★★★★☆) — performance-focused, benchmarks included
  4. security-reviewer (★★★★★) — OWASP Top 10, CVE checks, secret scanning
```

Install `strict-reviewer`:

```bash
mkdir -p .claude/agents
curl -o .claude/agents/strict-reviewer.md \
  https://raw.githubusercontent.com/example/strict-reviewer.md
```

Reference it in CLAUDE.md:

```markdown
# Code Review Mode
When reviewing code, follow the behavioral rules in .claude/agents/strict-reviewer.md
```

### Installing a Plugin Bundle

The "full-stack-quality" plugin bundles a reviewer agent, test-writer command, and lint hook:

```bash
npx claude-toolkit install full-stack-quality
```

This creates:
- `.claude/agents/quality-reviewer.md`
- `.claude/commands/write-tests.md`
- `.claude/hooks/pre-commit-lint.sh`
- Updates `.claude/settings.json` with hook registrations

### Browsing via SkillKit

```bash
# Search SkillKit marketplace through the toolkit
npx claude-toolkit search "react testing"

Results:
  1. react-test-agent (4.8★, 12K installs) — generates RTL tests
  2. react-e2e-agent (4.5★, 8K installs) — Playwright test generation
  3. react-snapshot-agent (4.2★, 3K installs) — snapshot test management
```

## When To Use

- **Building a Claude Code toolkit** — browse and install components à la carte
- **Evaluating agent quality** — the rating system helps you pick the best option
- **Discovering hooks** — the 20 curated hooks cover the most common automation needs
- **SkillKit exploration** — the bridge to 400K+ skills saves you from browsing the marketplace cold
- **Team standardization** — agree on which agents, commands, and hooks to use across projects

## When NOT To Use

- **Looking for tutorials** — this is a component catalog, not a learning resource; use [claude-howto](/claude-howto-visual-guide-2026/) instead
- **Need a framework** — for structured workflows with modes and orchestration, use [SuperClaude](/superclaude-framework-guide-2026/)
- **Minimal setups** — if you need 2-3 rules, hand-write them in CLAUDE.md

## FAQ

### How are quality ratings determined?

Install count, GitHub stars, maintenance frequency, and community reviews. The maintainer also manually tests top-rated entries.

### Can I submit my own agent/plugin?

Yes. Open a PR with the component metadata (name, description, install URL, category, compatibility). The maintainer reviews within a week.

### Do plugins auto-update?

No. Installed components are local files. Re-install to get updates, or use a hook that checks for new versions on session start.

### What's the difference between an agent and a skill?

Agents are behavioral profiles (how Claude Code should act). Skills are rule sets (what Claude Code should and shouldn't do). In practice, the line is blurry — many entries function as both.

## Our Take

**7/10.** Solid catalog for Claude Code component discovery. The 135 agents and 176 plugins are well-organized, and the SkillKit bridge is genuinely useful. Loses points for lower star count (1.4K vs. 40K for awesome-claude-code), which means the community validation is thinner. Some entries feel like padding — minor variations of the same agent template. Best used alongside the [main awesome list](/awesome-claude-code-master-index-guide-2026/) for a complete picture.

## Related Resources

- [Claude Skills Directory](/claude-skills-directory-where-to-find-skills/) — where to find and install skills
- [Claude Code Hooks Explained](/understanding-claude-code-hooks-system-complete-guide/) — understanding the hook components
- [CLAUDE.md Best Practices](/claude-md-best-practices-10-templates-compared-2026/) — integrating agents and skills into your config

## See Also

- [Install Awesome Claude Code Toolkit (2026)](/how-to-install-awesome-claude-code-toolkit-2026/)
- [Awesome Claude Code vs Docs Mirror (2026)](/awesome-claude-code-vs-claude-code-docs-2026/)
