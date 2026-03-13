---
layout: post
title: "How to Create a Private Claude Skill Not on GitHub"
description: "Learn how to create and use private Claude Code skills that stay local on your machine without publishing to GitHub. Step-by-step guide with practical e..."
date: 2026-03-14
author: "Claude Skills Guide"
reviewed: true
score: 4
---

# How to Create a Private Claude Skill Not on GitHub

Private Claude skills let you build custom workflows that stay completely local. Whether you're working with proprietary code, sensitive business logic, or just want to experiment without sharing your work publicly, keeping skills off GitHub is straightforward. This guide walks you through creating private skills that Claude Code can still discover and use.

## Understanding Private vs Public Skills

Claude Code skills live in a designated skills directory, typically `~/.claude/skills/` on Linux and macOS, or `%USERPROFILE%\.claude\skills\` on Windows. When you install a skill from GitHub using `cp skill.md ~/.claude/skills/`, it clones the repository into this folder. However, you can create skills manually in this directory without any GitHub involvement.

Public skills like `frontend-design`, `pdf`, `tdd`, and `supermemory` get shared because developers want community contributions and widespread usage. Private skills serve different purposes: internal company workflows, personal automation scripts, or experimental features you aren't ready to publish.

The key difference is simply where the skill file lives. Public skills have remote repositories. Private skills exist only in your local skills directory.

## Setting Up Your Local Skills Directory

Before creating your first private skill, ensure your skills directory exists and Claude Code can find it. The default location works for most users, but you can customize this in your Claude Code settings.

Create the directory structure:

```bash
mkdir -p ~/.claude/skills
```

Each skill gets its own subdirectory containing the main skill file (typically named after the directory). For example, a skill called `company-workflow` would have its files in `~/.claude/skills/company-workflow/`.

## Creating Your First Private Skill

A private skill follows the same format as public skills. You need a `skill.md` file with proper front matter and content. Let's create a practical example: a skill that formats API responses consistently.

Create the directory and file:

```bash
mkdir -p ~/.claude/skills/api-formatter
touch ~/.claude/skills/api-formatter/skill.md
```

Now add the skill content:

```markdown
---
name: api-formatter
description: "Format and validate JSON API responses with consistent indentation and structure"
version: 1.0.0
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
```

## Making Skills Auto-Invoke

Claude Code uses keyword matching to determine when to activate a skill. The `description` field and content keywords determine triggering. For private skills, you control exactly what keywords trigger your workflows.

Add specific phrases to your skill content that match your typical usage patterns. If you always say "format this API response" or "clean up this JSON", include those exact phrases in your skill documentation.

## Organizing Multiple Private Skills

As you create more private skills, organize them logically. A common pattern groups skills by domain:

```
~/.claude/skills/
├── api-formatter/
├── database-scripts/
├── deployment-helpers/
├── company-internal/
│   ├── expense-approver/
│   ├── time-tracker/
│   └── client-reports/
└── experimental/
    ├── ai-prompt-tester/
    └── code-explainer/
```

This structure keeps related skills together and makes it easy to find what you need.

## Sharing Private Skills Within a Team

Even without GitHub, teams can share private skills. Several approaches work:

**Direct file sharing**: Zip your skill directories and share through secure channels. Recipients unzip into their skills folder.

**Private git repositories**: Use GitHub or GitLab's private repositories. Team members clone using SSH keys or deploy tokens. The skill still installs via `cp skill.md ~/.claude/skills/`, but the repository remains private.

**Network file systems**: If your team shares a network drive or uses tools like Syncthing, skills can live on shared storage that multiple machines access.

**Custom sync scripts**: Write simple scripts that pull from any source—internal servers, S3 buckets, or encrypted archives. This gives you complete control over distribution.

## Maintaining Private Skills

Private skills need the same maintenance as public ones. Update them when:

- Claude Code releases new features or changes skill loading
- Your workflows evolve and need new capabilities
- You discover bugs in your automation logic
- Dependencies change (for skills using external tools)

Keep a changelog within each skill directory:

```
~/.claude/skills/api-formatter/
├── CHANGELOG.md
└── skill.md
```

Document what each version adds or changes. This matters more for private skills since you don't have commit history to reference.

## Troubleshooting Private Skills

If Claude Code doesn't discover your private skill, check these common issues:

**Directory naming**: The skill name comes from the folder name. `~/.claude/skills/my-skill/` creates a skill called "my-skill".

**File location**: The primary file must be `skill.md` in the skill's root directory. Subdirectory files work differently.

**Front matter**: Verify YAML syntax in your front matter. Missing colons or incorrect indentation breaks parsing.

**Character encoding**: Use UTF-8 encoding. Special characters in descriptions sometimes cause issues.

Run `claude skill list` to see all installed skills and verify yours appears.

## Using Private Skills with Official Skills

Private skills integrate reliably with public skills from the registry. You might combine:

- A private `company-auth` skill for your organization's authentication flows
- The public `pdf` skill for generating invoices
- A private `billing-reports` skill that uses both

Claude Code loads all skills regardless of origin, and you use them together naturally.

---

Building private skills keeps your custom workflows secure and under your control. Start with simple automations, then expand as you discover more opportunities for Claude Code to assist your development workflow.

Built by theluckystrike — More at [zovo.one](https://zovo.one)
