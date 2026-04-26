---
layout: default
title: "Install Claude Code Skills (2026)"
description: "Step-by-step guide to installing Claude Code skills in 2026. CLAUDE.md skills, directory skills, MCP-based skills, and troubleshooting."
permalink: /how-to-install-claude-code-skills-2026/
date: 2026-04-26
---

# How to Install Claude Code Skills (2026)

Claude Code skills enhance Claude's behavior for specific tasks, but the installation process can be confusing because there are multiple skill types. This guide covers every method, from the simplest (copying a file) to the most advanced (MCP server-based skills).

Looking for skills to install? Browse the [Skill Finder](/skill-finder/) to find skills by category and get install commands.

## Method 1: CLAUDE.md Skills (Simplest)

CLAUDE.md skills are instructions written directly in your project's `CLAUDE.md` file. They are the simplest type of skill because they require no tooling, no configuration, and no dependencies.

### Installation Steps

1. **Create or open your CLAUDE.md file:**
```bash
# In your project root
touch CLAUDE.md
```

2. **Add skill instructions:**
```markdown
# Project Skills

## Code Review Skill
When reviewing code, always check for:
- Missing error handling on async operations
- Hardcoded values that should be environment variables
- Functions longer than 50 lines
- Missing TypeScript types on function parameters

## Commit Message Skill
Format all commit messages as:
- type(scope): description
- Types: feat, fix, refactor, test, docs, chore
- Keep first line under 72 characters
```

3. **Verify it works:**
```bash
claude "Review the last commit"
# Claude should follow the code review skill instructions
```

### When to Use This Method
- Team conventions you want enforced
- Simple behavioral rules (naming, formatting, review criteria)
- Project-specific context (architecture decisions, tech stack details)

## Method 2: Skill Files in .claude/skills/

For more complex skills that you want to share across projects or toggle on/off:

### Installation Steps

1. **Create the skills directory:**
```bash
mkdir -p .claude/skills/
```

2. **Add a skill file:**
```bash
cat > .claude/skills/test-generator.md << 'EOF'
# Test Generator Skill

When generating tests:
- Use the project's existing test framework (detect from package.json or imports)
- Follow AAA pattern: Arrange, Act, Assert
- Test edge cases: null, undefined, empty string, boundary values
- Name tests: "should [expected behavior] when [condition]"
- Mock external dependencies, never make real API calls in tests
- Aim for one assertion per test when practical
EOF
```

3. **Verify the skill is loaded:**
```bash
claude "List the skills you have loaded"
```

### Managing Multiple Skills

```bash
# List installed skills
ls .claude/skills/

# Temporarily disable a skill (rename to .disabled)
mv .claude/skills/test-generator.md .claude/skills/test-generator.md.disabled

# Re-enable
mv .claude/skills/test-generator.md.disabled .claude/skills/test-generator.md
```

## Method 3: Remote Skills (URL-Based)

Some skills are hosted on GitHub and can be referenced by URL in your CLAUDE.md:

### Installation Steps

1. **Add to CLAUDE.md:**
```markdown
# Skills

Follow the instructions at:
https://raw.githubusercontent.com/user/repo/main/CLAUDE.md
```

2. **Or download locally for offline use:**
```bash
curl -o .claude/skills/karpathy.md \
  https://raw.githubusercontent.com/forrestchang/andrej-karpathy-skills/main/CLAUDE.md
```

### When to Use This Method
- Community skills with active maintenance
- Skills you want to update automatically (URL reference)
- Skills you want to pin to a specific version (local download)

## Method 4: MCP Server-Based Skills

MCP (Model Context Protocol) servers provide tools and context to Claude Code. Some skills are implemented as MCP servers that run alongside Claude Code.

### Installation Steps

1. **Configure the MCP server in `.claude/mcp.json`:**
```json
{
  "servers": {
    "my-skill-server": {
      "command": "npx",
      "args": ["-y", "@my-org/skill-server"],
      "env": {
        "API_KEY": "your-key-here"
      }
    }
  }
}
```

2. **Restart Claude Code** to pick up the new MCP server configuration.

3. **Verify the connection:**
```bash
claude "What MCP servers are connected?"
```

### When to Use This Method
- Skills that need to run code (API calls, database queries, file processing)
- Skills that provide real-time data (monitoring, analytics, search)
- Skills that integrate with external services (Jira, GitHub, Slack)

## Method 5: Global Skills (User-Level)

Skills that should apply to all your projects go in your user-level configuration:

### Installation Steps

1. **Create the global skills directory:**
```bash
mkdir -p ~/.claude/skills/
```

2. **Add global skills:**
```bash
cat > ~/.claude/skills/personal-conventions.md << 'EOF'
# Personal Coding Conventions

- Always use early returns instead of nested if/else
- Prefer const over let
- Use descriptive variable names (no single letters except loop counters)
- Add TODO comments with your initials: // TODO(username): description
EOF
```

Global skills load for every project but can be overridden by project-level skills.

## Troubleshooting Installation Issues

### Skills Not Loading

1. **Check file location:** Skills must be in `.claude/skills/` (project-level) or `~/.claude/skills/` (user-level).
2. **Check file extension:** Use `.md` for markdown skills.
3. **Check for JSON errors:** If using JSON config, validate with `python -m json.tool`.
4. **Restart Claude Code:** Some changes require a fresh session.

See our detailed [skills not showing up fix](/fix-claude-code-skills-not-showing-up/) for more troubleshooting.

### Skills Conflicting

If two skills give contradictory instructions, the more specific one wins:
- Project-level skills override global skills
- Later instructions in CLAUDE.md override earlier ones
- Explicit instructions override implicit conventions

### Skills Causing Crashes

If Claude Code crashes after installing a skill:
1. Disable the skill (rename to `.disabled`)
2. Restart Claude Code
3. Check the skill for very large content (keep under 10KB per skill file)
4. See our [skill crash debug guide](/claude-code-crashes-when-loading-skill-debug-steps/)

## Try It Yourself

Not sure which skills to install? The [Skill Finder](/skill-finder/) shows you the most popular skills for your programming language and framework. Each listing includes one-click install commands and compatibility information.

[Open Skill Finder](/skill-finder/){: .btn .btn-primary }

## FAQ

<script type="application/ld+json">
{
  "@context": "https://schema.org",
  "@type": "FAQPage",
  "mainEntity": [
    {
      "@type": "Question",
      "name": "How do I install a Claude Code skill?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "The simplest method is adding instructions to your CLAUDE.md file. For reusable skills, create markdown files in .claude/skills/. For tool-based skills, configure MCP servers in .claude/mcp.json."
      }
    },
    {
      "@type": "Question",
      "name": "Where are Claude Code skills stored?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "Project skills are in .claude/skills/ within your project directory. Global skills are in ~/.claude/skills/ in your home directory. CLAUDE.md skills are in the project root."
      }
    },
    {
      "@type": "Question",
      "name": "Can I use multiple Claude Code skills at the same time?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "Yes. Claude Code loads all skills from CLAUDE.md and the skills directories. Keep total skill count under 10 to avoid excessive token usage. Disable unused skills by renaming files."
      }
    },
    {
      "@type": "Question",
      "name": "Do Claude Code skills cost extra tokens?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "Yes. Each skill's instructions are sent as context with every message, consuming input tokens. A 1KB skill adds roughly 250 tokens per message. Keep skills concise to minimize overhead."
      }
    }
  ]
}
</script>

### How do I install a Claude Code skill?
The simplest method is adding instructions to your `CLAUDE.md` file. For reusable skills, create markdown files in `.claude/skills/`. For tool-based skills, configure MCP servers in `.claude/mcp.json`.

### Where are Claude Code skills stored?
Project skills are in `.claude/skills/` within your project directory. Global skills are in `~/.claude/skills/` in your home directory. CLAUDE.md skills are in the project root.

### Can I use multiple Claude Code skills at the same time?
Yes. Claude Code loads all skills from CLAUDE.md and the skills directories. Keep total skill count under 10 to avoid excessive token usage. Disable unused skills by renaming files.

### Do Claude Code skills cost extra tokens?
Yes. Each skill's instructions are sent as context with every message, consuming input tokens. A 1KB skill adds roughly 250 tokens per message. Keep skills concise to minimize overhead.

## Related Guides

- [Top Claude Code Skills Ranked](/top-claude-code-skills-ranked-2026/) — Best skills to install
- [Best Skills to Install First](/best-claude-code-skills-to-install-first-2026/) — Starter recommendations
- [Building Your Own Claude Code Skill](/building-your-own-claude-code-skill-2026/) — Create custom skills
- [Fix Skills Not Showing Up](/fix-claude-code-skills-not-showing-up/) — Troubleshoot installation
- [Skills Crash Debug Steps](/claude-code-crashes-when-loading-skill-debug-steps/) — Fix skill-related crashes
- [Skill Finder](/skill-finder/) — Browse and install community skills
