---
layout: default
title: "Claude Code Developer Portal Setup Guide"
description: "A practical guide to setting up Claude Code developer portals. Configure skills, customize workflows, and build your personalized AI development environment."
date: 2026-03-14
categories: [guides]
author: theluckystrike
permalink: /claude-code-developer-portal-setup-guide/
---

# Claude Code Developer Portal Setup Guide

Developer portals in Claude Code serve as centralized hubs for managing skills, templates, and automation workflows. This guide walks through the process of setting up a functional developer portal tailored to your development needs.

## Understanding Claude Code Skills Architecture

Claude Code uses a skill-based system stored in `~/.claude/skills/`. Each skill is a Markdown file containing instructions that Claude loads when you invoke it. The directory structure looks like this:

```
~/.claude/
├── skills/
│   ├── _index.md
│   ├── frontend-design.md
│   ├── pdf.md
│   ├── tdd.md
│   └── supermemory.md
└── settings.json
```

The `_index.md` file acts as a skill registry, listing all available skills and their descriptions. This is what Claude reads when you press Tab to see available skills.

## Setting Up Your Skill Directory

Start by creating the skills directory if it does not exist:

```bash
mkdir -p ~/.claude/skills
```

Each skill file follows a specific format. Here is a basic template for creating a custom skill:

```markdown
---
name: my-custom-skill
description: A brief description of what this skill does
---

# My Custom Skill

Your skill instructions go here. When you invoke this skill with /my-custom-skill, Claude will follow these guidelines.
```

The front matter defines the skill name and description, while the Markdown content provides the actual instructions Claude will follow.

## Configuring the Skills Index

The `_index.md` file is crucial for organizing your skills. Each skill should be listed with a brief description:

```markdown
---
layout: skills-index
title: Developer Skills
---

## Available Skills

### Development Skills
- **tdd** — Test-driven development workflow
- **frontend-design** — UI/UX and frontend guidance
- **pdf** — PDF manipulation and generation
- **xlsx** — Spreadsheet operations
- **pptx** — Presentation creation

### Productivity Skills
- **supermemory** — Memory and context management
- **webapp-testing** — Browser testing with Playwright
- **mcp-builder** — MCP server creation
```

This index enables Tab completion in Claude Code, making skills discoverable during your sessions.

## Creating a Developer Portal Structure

A well-organized developer portal separates skills by domain. Here is a recommended structure:

```
developer-portal/
├── skills/
│   ├── development/
│   │   ├── tdd.md
│   │   ├── frontend-design.md
│   │   └── code-review.md
│   ├── automation/
│   │   ├── mcp-builder.md
│   │   └── webapp-testing.md
│   └── content/
│       ├── pdf.md
│       ├── docx.md
│       └── pptx.md
└── templates/
    ├── readme-template.md
    └── pr-template.md
```

## Integrating Skills with Your Workflow

Skills become powerful when integrated into your daily workflow. The **tdd** skill, for example, transforms how you approach coding tasks. Invoke it with `/tdd` and describe your implementation goal. The skill guides Claude to generate tests first, then implement against those tests.

The **frontend-design** skill helps with UI components. When working on a new interface element, invoke `/frontend-design` and provide details about your design requirements. The skill offers guidance on layout, accessibility, and responsive patterns.

For documentation workflows, the **pdf** and **docx** skills enable programmatic document generation. Create a skill that defines your documentation standards:

```markdown
---
name: docs-generator
description: Generate project documentation from templates
---

# Documentation Generator Skill

When invoked, follow these guidelines:

1. Check for existing documentation structure
2. Use the pdf skill for PDF outputs
3. Apply consistent formatting
4. Include code examples where appropriate
5. Generate a table of contents
```

## Automating Portal Tasks

You can combine skills with shell commands for automation. Create a script that updates your portal skills from a git repository:

```bash
#!/bin/bash
# Update developer portal skills

SKILLS_DIR="$HOME/.claude/skills"
PORTAL_REPO="git@github.com:your-org/claude-skills.git"

if [ -d "$PORTAL_REPO" ]; then
    cd "$PORTAL_REPO"
    git pull origin main
    cp -r skills/* "$SKILLS_DIR/"
    echo "Skills updated successfully"
else
    git clone "$PORTAL_REPO" /tmp/claude-skills
    cp -r /tmp/claude-skills/skills/* "$SKILLS_DIR/"
    echo "Skills cloned and installed"
fi
```

Schedule this with cron or run it manually before starting your development sessions.

## Testing Your Setup

After configuring your developer portal, verify everything works:

1. Open Claude Code
2. Press Tab to see your skill list
3. Invoke each skill with its command
4. Confirm the skills load correctly

You can also check skill loading with:

```bash
ls -la ~/.claude/skills/
cat ~/.claude/skills/_index.md
```

## Extending Your Portal

Once your basic portal is running, extend it with specialized skills. The **mcp-builder** skill helps you create Model Context Protocol servers for external service integration. The **webapp-testing** skill enables automated browser testing directly from Claude Code.

For team environments, consider sharing skill configurations through a dotfiles repository or internal wiki. This ensures consistent development experiences across your organization.

---


## Related Reading

- [Claude Code MCP Server Setup Complete Guide 2026](/claude-skills-guide/claude-code-mcp-server-setup-complete-guide-2026/)
- [Claude Code Local Development Setup Guide](/claude-skills-guide/claude-code-local-development-setup-guide/)
- [Best Way to Set Up Claude Code for a New Project](/claude-skills-guide/best-way-to-set-up-claude-code-for-new-project/)
- [Claude Skills Guides Hub](/claude-skills-guide/guides-hub/)

Built by theluckystrike — More at [zovo.one](https://zovo.one)
