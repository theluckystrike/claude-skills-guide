---
layout: default
title: "How to Create a Private Claude Skill Not on GitHub"
description: "Learn how to create and use private Claude Code skills that stay local on your machine without publishing to GitHub. Step-by-step guide with practical e..."
date: 2026-03-14
author: "Claude Skills Guide"
categories: [guides]
tags: [claude-code, claude-skills, private-skills, local-skills, how-to]
reviewed: true
score: 7
permalink: /how-do-i-create-a-private-claude-skill-not-on-github/
---

# How to Create a Private Claude Skill Not on GitHub

Private Claude skills let you build custom workflows that stay completely local. Whether you're working with proprietary code, sensitive business logic, or just want to experiment without sharing your work publicly, keeping skills off GitHub is straightforward. This guide walks you through creating private skills that Claude Code can still discover and use. For best practices on the `.md` format these skills use, see the [Claude skill .md file format specification guide](/claude-skills-guide/claude-skill-md-format-complete-specification-guide/).

## Understanding Private vs Public Skills

Claude Code skills live in a designated skills directory, typically `~/.claude/skills/` on Linux and macOS, or `%USERPROFILE%\.claude\skills\` on Windows. When you install a skill from GitHub using `cp skill.md ~/.claude/skills/`, it clones the repository into this folder. However, you can create skills manually in this directory without any GitHub involvement.

[Public skills like frontend-design, pdf, tdd, and supermemory get shared because developers want community contributions](/claude-skills-guide/best-claude-code-skills-to-install-first-2026/) and widespread usage. Private skills serve different purposes: internal company workflows, personal automation scripts, or experimental features you aren't ready to publish.

The key difference is simply where the skill file lives. Public skills have remote repositories. Private skills exist only in your local skills directory.

## Setting Up Your Local Skills Directory

Before creating your first private skill, ensure your skills directory exists and Claude Code can find it. The default location works for most users, but you can customize this in your Claude Code settings.

Create the directory structure:

```bash
mkdir -p ~/.claude/skills
```

Each skill is a single `.md` file placed directly in `~/.claude/skills/`. For example, a skill called `company-workflow` lives at `~/.claude/skills/company-workflow.md`.

## Creating Your First Private Skill

A private skill follows the same format as public skills. You need a `skill.md` file with proper front matter and content. Let's create a practical example: a skill that formats API responses consistently.

Create the directory and file:

```bash
mkdir -p ~/.claude/skills
touch ~/.claude/skills/api-formatter.md
```

Now add the skill content:

Place this content in `~/.claude/skills/api-formatter.md`:

```markdown
---
name: api-formatter
description: "Format and validate JSON API responses with consistent indentation and structure"
author: your-username
---

# API Response Formatter Skill

This skill formats JSON responses from APIs into consistent, readable output. Use it when working with REST APIs or GraphQL endpoints.

## Usage

When the user mentions formatting API responses or cleaning up JSON output, this skill activates automatically.

## Formatting Rules

- Use 2-space indentation for nested structures
- Sort keys alphabetically within each object level
- Remove trailing commas
- Escape special characters properly
- Add syntax highlighting markers for supported editors

## Example Input

```json
{"users":[{"id":1,"name":"Alice","email":"alice@example.com"},{"id":2,"name":"Bob","email":"bob@example.com"}]}
```

## Expected Output

```json
{
  "users": [
    {
      "id": 1,
      "name": "Alice",
      "email": "alice@example.com"
    },
    {
      "id": 2,
      "name": "Bob",
      "email": "bob@example.com"
    }
  ]
}
```

## Integration with Other Skills

This skill works well alongside `pdf` for generating API documentation, or with `tdd` for creating test fixtures from real API responses.

## Making Skills Auto-Invoke

Claude Code uses keyword matching to determine when to activate a skill. The `description` field and content keywords determine triggering. For private skills, you control exactly what keywords trigger your workflows.

Add specific phrases to your skill content that match your typical usage patterns. If you always say "format this API response" or "clean up this JSON", include those exact phrases in your skill documentation.

## Organizing Multiple Private Skills

As you create more private skills, organize them logically. A common pattern groups skills by domain:

```
~/.claude/skills/
├── api-formatter.md
├── database-scripts.md
├── deployment-helpers.md
├── company-expense-approver.md
├── company-time-tracker.md
├── company-client-reports.md
├── experimental-prompt-tester.md
└── experimental-code-explainer.md
```

This structure keeps related skills together and makes it easy to find what you need.

## Sharing Private Skills Within a Team

Even without GitHub, teams can share private skills. Several approaches work:

**Direct file sharing**: Zip your skill directories and share through secure channels. Recipients unzip into their skills folder.

**Private git repositories**: Use GitHub or GitLab's private repositories. Team members clone using SSH keys or deploy tokens. Team members can copy the `.md` file into their `~/.claude/skills/` directory, and the skill remains private.

**Network file systems**: If your team shares a network drive or uses tools like Syncthing, skills can live on shared storage that multiple machines access.

**Custom sync scripts**: Write simple scripts that pull from any source—internal servers, S3 buckets, or encrypted archives. This gives you complete control over distribution.

## Maintaining Private Skills

Private skills need the same maintenance as public ones. Update them when:

- Claude Code releases new features or changes skill loading
- Your workflows evolve and need new capabilities
- You discover bugs in your automation logic
- Dependencies change (for skills using external tools)

Keep a changelog within each skill directory:

Keep a changelog in a comment at the top of the skill file, or maintain a separate log alongside your skills directory.

Document what each version adds or changes. This matters more for private skills since you don't have commit history to reference.

## Troubleshooting Private Skills

If Claude Code doesn't discover your private skill, check these common issues:

**Directory naming**: The skill name comes from the folder name. `~/.claude/skills/my-skill/` creates a skill called "my-skill".

**File location**: The primary file must be `skill.md` in the skill's root directory. Subdirectory files work differently.

**Front matter**: Verify YAML syntax in your front matter. Missing colons or incorrect indentation breaks parsing.

**Character encoding**: Use UTF-8 encoding. Special characters in descriptions sometimes cause issues.

Run `ls ~/.claude/skills/` to see all installed skills and verify yours appears.

## Using Private Skills with Official Skills

Private skills integrate reliably with built-in Claude Code skills. You might combine:

- A private `company-auth` skill for your organization's authentication flows
- The public `pdf` skill for generating invoices
- A private `billing-reports` skill that uses both

Claude Code loads all skills regardless of origin, and you use them together naturally.

---

Building private skills keeps your custom workflows secure and under your control. Start with simple automations, then expand as you discover more opportunities for Claude Code to assist your development workflow.

## Related Reading

- [Claude Skill MD Format: Complete Specification Guide](/claude-skills-guide/claude-skill-md-format-complete-specification-guide/) — Master the full skill file format before creating your private skills
- [How to Write a Skill MD File for Claude Code](/claude-skills-guide/how-to-write-a-skill-md-file-for-claude-code/) — Learn the basics of authoring skill files before keeping them private
- [How Do I Use Claude Skills in an Air-Gapped Environment](/claude-skills-guide/how-do-i-use-claude-skills-in-an-air-gapped-environment/) — Extend private skill setups to fully offline secure environments
- [Claude Skills Hub](/claude-skills-guide/getting-started-hub/) — Explore foundational skill creation and distribution approaches

Built by theluckystrike — More at [zovo.one](https://zovo.one)
