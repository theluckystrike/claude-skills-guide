---
layout: post
title: "Antigravity Skills vs Claude Native Skills: Key Differences"
description: "Practical comparison of community Antigravity skills versus native Claude skills. Learn when to use each type and how to install skills from ~/.claude/skills/."
date: 2026-03-13
categories: [comparisons, guides]
tags: [claude-code, claude-skills, antigravity, native-skills]
author: "Claude Skills Guide"
reviewed: true
score: 6
---

# Antigravity Skills vs Claude Native Skills: What's the Difference?

When you start using Claude Code, you'll encounter two categories of skills: native skills that ship with Claude and community-built skills distributed through the Antigravity registry. Understanding the difference helps you build a more productive workflow.

## How Claude Skills Actually Work

Skills are Markdown files stored in `~/.claude/skills/`. When you invoke `/skill-name` in a Claude Code session, Claude loads the corresponding file and uses its instructions to guide behavior. There is no package manager, no `claude skills install` CLI command, and no Python import API — skills are plain `.md` files that you place in the skills directory.

To use any skill, invoke it by name:

```
/pdf extract tables from Q3-report.pdf
```

```
/tdd write tests for the auth module using pytest
```

```
/supermemory store: this project uses pnpm workspaces and ESLint Airbnb config
```

## What Are Claude Native Skills?

Native skills ship pre-installed in `~/.claude/skills/` as part of the standard Claude Code distribution. They cover the tasks most developers encounter daily: document processing, test-driven development, spreadsheet automation, memory management, and frontend verification.

The core native skills include:

- **pdf** — Extract text, tables, and forms from PDF files
- **xlsx** — Create and edit spreadsheets with formula support
- **tdd** — Guide test-first development and generate test cases
- **frontend-design** — Generate and verify UI component implementations
- **supermemory** — Persist context and decisions across sessions

Native skills receive updates through Claude Code's release cycle. When Anthropic improves the `tdd` skill, you get the improvement automatically.

## What Are Antigravity Skills?

Antigravity skills are community-created `.md` files distributed through the Antigravity registry. Developers publish skills to extend Claude's capabilities beyond the native set. To install one, you download the `.md` file to `~/.claude/skills/`:

```bash
# Download an Antigravity skill
curl -o ~/.claude/skills/pptx.md https://antigravity.dev/skills/pptx.md
```

Once in place, invoke it like any other skill:

```
/pptx create a slide deck from this outline: [paste outline]
```

Community skills fill gaps in the native offering. Popular Antigravity skills handle presentation generation (`pptx`), Word document creation (`docx`), web app testing (`webapp-testing`), and algorithmic art (`algorithmic-art`).

## Key Differences

### Maintenance and Updates

Native skills update automatically with Claude Code. Antigravity skills depend on their individual maintainers — some receive regular updates, others go unmaintained. Before relying on a community skill for production work, check when it was last updated.

### Stability

Anthropic tests native skills before release. Community skills vary in quality. Test an Antigravity skill in a low-stakes context before integrating it into a critical workflow.

### Installation

Native skills require no setup — they're available immediately. Antigravity skills require manually copying the `.md` file to `~/.claude/skills/`, then verifying the invocation works as expected.

## When to Use Each Type

Use native skills as your foundation. The `pdf`, `xlsx`, `tdd`, `frontend-design`, and `supermemory` skills handle most common development tasks reliably.

Turn to Antigravity skills when you need specialized capabilities the native set doesn't cover. If you're generating presentations, `/pptx` from the community may offer features tailored to that specific task. For browser-based testing, `/webapp-testing` provides Playwright integration that complements native options.

## Practical Workflows Using Both

### Documentation Pipeline

```
/pdf extract all section headings from spec.pdf
```
Then:
```
/docx create a requirements doc from these headings: [paste output]
```

Using the native `pdf` skill for extraction and an Antigravity `docx` skill for document generation gives you the stability of native tools with the flexibility of community extensions.

### Test Coverage Workflow

```
/tdd write unit tests for UserService.authenticate() using Jest
```
Then:
```
/webapp-testing verify the login flow on http://localhost:3000 using Playwright
```

The native `tdd` skill handles unit tests; the Antigravity `webapp-testing` skill covers browser-level integration. Both are invoked the same way — the only difference is where the `.md` file came from.

## Making the Right Choice

Neither type is universally better. Native skills offer stability and deep integration. Community skills offer flexibility and specialized functionality. Most productive setups combine both: native skills for daily tasks, carefully selected Antigravity skills for specific needs.

When evaluating a community skill, read the `.md` file itself before using it. Since skills are plain Markdown, you can see exactly what instructions they give Claude — which is the most direct way to assess quality.

---

## Related Reading

- [Official vs Community Claude Skills: Which Should You Use?](/claude-skills-guide/articles/anthropic-official-skills-vs-community-skills-comparison/) — Another key Claude comparison
- [Claude Skills vs Prompts: Which Is Better?](/claude-skills-guide/articles/claude-skills-vs-prompts-which-is-better/) — Skills vs plain prompts decision guide
- [Claude Skills Auto Invocation: How It Works](/claude-skills-guide/articles/claude-skills-auto-invocation-how-it-works/) — How skills activate automatically


---

*Built by theluckystrike — More at [zovo.one](https://zovo.one)*
