---
layout: default
title: "Claude Skills Directory: Where to Find Skills 2026"
description: "Where to find Claude Code skills: built-in skills, community GitHub repositories, skill file locations, and how to install new skills locally."
date: 2026-03-13
categories: [guides]
tags: [claude-code, claude-skills, directory, installation]
author: "Claude Skills Guide"
reviewed: true
score: 9
---

# Claude Skills Directory: Where to Find Skills

Claude Code skills are `.md` files stored locally at `~/.claude/skills/`. When you invoke `/skill-name`, Claude Code reads that file and gains specialized context for the task. Here's where to find skills and how to install them.

## Built-in Skills

Claude Code ships with a set of official skills that cover common development tasks. These are available by default and don't require manual installation. The primary built-in skills include:

- [**pdf**](/claude-skills-guide/articles/best-claude-skills-for-data-analysis/) — document text extraction, merging, form filling
- **docx** — Word document creation and manipulation
- **pptx** — PowerPoint presentation generation
- **xlsx** — spreadsheet operations with formula support
- [**tdd**](/claude-skills-guide/articles/best-claude-skills-for-developers-2026/) — test-driven development guidance
- **frontend-design** — UI component generation for React, Vue, Svelte
- **canvas-design** — visual asset generation
- [**supermemory**](/claude-skills-guide/articles/claude-skills-token-optimization-reduce-api-costs/) — persistent knowledge base across sessions

To see which skills are available in your session, check your `~/.claude/skills/` directory:

```bash
ls ~/.claude/skills/
```

To load a skill's full guidance, invoke it with a slash command:

```
/pdf
/tdd
/supermemory
```

## Community Skills

The community maintains additional skills in public GitHub repositories. The best place to find community Claude Code skills:

- Search GitHub for `claude-code skills site:github.com`
- Browse the [claude-code community discussions](https://github.com/anthropics/claude-code/discussions)
- Check the [awesome-claude-code](https://github.com/hesreallyhim/awesome-claude-code) community list

Community skills are `.md` files you clone or download and place in `~/.claude/skills/`.

## Installing a Community Skill

```bash
# Example: installing a skill from a GitHub repo
curl -o ~/.claude/skills/my-skill.md \
  https://raw.githubusercontent.com/username/claude-skills/main/my-skill.md

# Or clone a skills collection
git clone https://github.com/username/claude-skills.git /tmp/claude-skills
cp /tmp/claude-skills/*.md ~/.claude/skills/
```

After installing, restart your Claude Code session and invoke the skill with `/skill-name`.

## Finding Skills by Use Case

| Need | Skill |
|------|-------|
| Extract text from PDFs | `/pdf` |
| Generate Word documents | `/docx` |
| Create presentations | `/pptx` |
| Spreadsheet automation | `/xlsx` |
| TDD workflows | `/tdd` |
| React/Vue component generation | `/frontend-design` |
| Generate icons and graphics | `/canvas-design` |
| Persistent cross-session memory | `/supermemory` |
| Browser automation testing | `/webapp-testing` |
| Build custom MCP servers | `/skill-creator` |

## Evaluating Community Skills

Before adding a community skill:

1. Read the skill file — it's just Markdown, so you can review exactly what instructions it gives Claude
2. Check the repository's maintenance activity
3. Look for clear usage examples in the README
4. Test in a non-critical session first

Official skills from Anthropic are tested and maintained. Community skills vary in quality — reading the `.md` file directly is the fastest way to evaluate one.

## Keeping Skills Updated

For official skills, update Claude Code:

```bash
npm update -g @anthropic-ai/claude-code
```

For community skills stored as Git repos, pull updates periodically:

```bash
git -C /path/to/skills-repo pull
cp /path/to/skills-repo/*.md ~/.claude/skills/
```

---

## Related Reading

- [Best Claude Skills for Developers in 2026](/claude-skills-guide/articles/best-claude-skills-for-developers-2026/) — Top skills every developer should know
- [Claude Skills vs Prompts: Which Is Better?](/claude-skills-guide/articles/claude-skills-vs-prompts-which-is-better/) — Decide when skills beat plain prompts
- [Claude Skills Auto Invocation: How It Works](/claude-skills-guide/articles/claude-skills-auto-invocation-how-it-works/) — How skills activate automatically


---

*Built by theluckystrike — More at [zovo.one](https://zovo.one)*
