---
layout: default
title: "How to Install Claude Code Skills: Complete Guide (2026)"
description: "Step-by-step guide to installing Claude Code skills: /install command, manual CLAUDE.md addition, skill file locations, verification, and troubleshooting."
date: 2026-04-26
author: "Claude Skills Guide"
permalink: /how-to-install-claude-code-skills-guide/
reviewed: true
categories: [skills]
tags: [claude, claude-code, skills, installation, setup, configuration]
---

# How to Install Claude Code Skills: Complete Guide

Skills give Claude Code project-specific knowledge and repeatable workflows. Installing them correctly is the difference between a skill that works every session and one that silently fails because it is in the wrong file or format. This guide covers every installation method -- the `/install` command, manual CLAUDE.md integration, skill file directories, team sharing, and troubleshooting when installs fail. Find the right skill for your project with the [Skill Finder](/skill-finder/).

## Method 1: The /install Command

The fastest way to install a skill. Run this inside an active Claude Code session:

```
/install skill-name
```

Claude Code fetches the skill definition and adds it to your project's CLAUDE.md file. The skill takes effect immediately in the current session and persists for future sessions.

**Example: installing the test-writer skill:**

```
/install test-writer
```

After installation, verify it loaded:

```
/skills
```

This lists all active skills with their source (built-in, installed, or project-level).

### What /install Actually Does

Behind the scenes, `/install` performs three steps:

1. **Fetches** the skill definition from the skill registry
2. **Appends** the skill instructions to your project-level CLAUDE.md
3. **Reloads** the system prompt so the skill takes effect immediately

The skill text is added as a markdown section in your CLAUDE.md:

```markdown
<!-- Skill: test-writer -->
## Test Writing

When asked to write tests:
- Use the project's existing test framework (detect from package.json)
- Include edge cases: null inputs, empty arrays, boundary values
- Mock external dependencies
- Follow the existing test file naming convention
<!-- End Skill: test-writer -->
```

## Method 2: Manual CLAUDE.md Addition

For custom skills or when you want full control over the skill text, add it directly to your CLAUDE.md file.

**Step 1: Open your CLAUDE.md**

```bash
# Project-level (recommended)
vim CLAUDE.md

# User-level (applies to all projects)
vim ~/.claude/CLAUDE.md
```

**Step 2: Add the skill section**

```markdown
## Custom Code Review Rules

When reviewing code:
- Flag any function longer than 50 lines
- Require error handling for all async operations
- Check for hardcoded secrets (API keys, passwords, tokens)
- Verify that all public functions have JSDoc comments
- Ensure imports are sorted alphabetically
```

**Step 3: Verify the skill loaded**

Start a new Claude Code session or run `/refresh` to reload the configuration:

```
/refresh
```

Then test the skill:

```
Review src/auth/login.ts using the code review rules
```

## Method 3: Skill File Directory

For complex skills that are too large for CLAUDE.md, or for team-shared skill collections, use the skill file directory:

```bash
# Create the skills directory
mkdir -p .claude/skills/

# Add a skill file
cat > .claude/skills/security-review.md << 'EOF'
# Security Review Skill

When performing security reviews:

## Authentication Checks
- Verify password hashing uses bcrypt with cost factor >= 12
- Check for timing-safe comparison in auth flows
- Ensure session tokens have expiration

## Input Validation
- All user input must be validated with Zod or joi
- SQL queries must use parameterized statements
- HTML output must be sanitized against XSS

## Secrets Management
- No hardcoded API keys, tokens, or passwords
- Environment variables for all secrets
- .env files in .gitignore
EOF
```

Claude Code automatically loads all `.md` files from `.claude/skills/` at session start. This method keeps your CLAUDE.md clean while supporting large, detailed skill definitions.

## Skill Locations and Priority

Claude Code loads skills from multiple locations with a defined priority order:

| Priority | Location | Scope |
|----------|----------|-------|
| 1 (highest) | `./CLAUDE.md` | Current project |
| 2 | `./.claude/skills/*.md` | Current project |
| 3 | `~/.claude/CLAUDE.md` | All projects (user) |
| 4 | `~/.claude/skills/*.md` | All projects (user) |

If two skills conflict (e.g., one says "use tabs" and another says "use spaces"), the higher-priority location wins. Project-level skills always override user-level skills.

## Team Sharing

Skills in your project directory (CLAUDE.md and `.claude/skills/`) are committed to git and shared with your team. This ensures every developer gets the same Claude Code behavior.

```bash
# Commit skills to share with team
git add CLAUDE.md .claude/skills/
git commit -m "Add team code review and testing skills"
git push
```

Team members get the skills automatically when they pull. No manual installation required.

**Important:** Do not commit personal preferences (model choice, API keys) in project-level files. Keep those in `~/.claude/CLAUDE.md`.

## Verifying Skill Installation

After installing a skill, verify it is active and working:

### Check the Skill List

```
/skills
```

Expected output shows each skill with its source:

```
Active Skills:
  test-writer (installed via /install)
  code-reviewer (project CLAUDE.md)
  security-review (.claude/skills/security-review.md)
```

### Test the Skill

Give Claude Code a task that should trigger the skill. If the skill is a test writer, ask it to write a test and verify it follows the skill's conventions.

### Check Token Impact

Skills consume context tokens. Check how much each skill costs:

```bash
# Count tokens in your CLAUDE.md
wc -w CLAUDE.md
# Rough estimate: 1 word ≈ 1.3 tokens
```

A 500-word skill adds ~650 tokens per message. At $3/MTok (Sonnet input), that is $0.002 per message or $0.40/day at 200 messages.

## Troubleshooting Failed Installs

### Skill Not Found

```
Error: Skill "xyz" not found in registry
```

The skill name is case-sensitive. Check the [Skill Finder](/skill-finder/) for the exact name. If the skill is community-made, it may have been removed.

### Skill Installed but Not Working

Common causes:
1. **CLAUDE.md too large:** If your CLAUDE.md exceeds the system prompt limit, skills at the bottom may be truncated. Move critical skills to the top.
2. **Conflicting skills:** Two skills with contradictory instructions cause unpredictable behavior. Remove one.
3. **Wrong scope:** A user-level skill may be overridden by a project-level instruction.

```bash
# Check CLAUDE.md size
wc -c CLAUDE.md
# If over 15,000 characters, trim non-essential content
```

### Permission Errors During Install

```
Error: Cannot write to CLAUDE.md
```

Fix file permissions:

```bash
chmod 644 CLAUDE.md
# Or create it if it does not exist:
touch CLAUDE.md && chmod 644 CLAUDE.md
```

### Skill Creates Configuration Conflicts

If a skill's instructions conflict with your [project configuration](/configuration/), the configuration takes precedence. Edit the skill text to align with your project setup.

## Try It Yourself

Find the right skills for your tech stack and workflow. The **[Skill Finder](/skill-finder/)** lets you search 150+ skills by category, framework, and use case. Each listing includes the install command, description, and token cost.

**[Try the Skill Finder -->](/skill-finder/)**

## Common Questions

<details><summary>Can I install skills from a URL or GitHub repo?</summary>
Not directly with <code>/install</code>, which uses the built-in registry. For custom skills, copy the markdown content into your CLAUDE.md or <code>.claude/skills/</code> directory manually. You can automate this with a shell script that fetches from your repo.
</details>

<details><summary>Do skills persist across sessions?</summary>
Yes. Skills installed via <code>/install</code> are written to your CLAUDE.md file, which persists on disk. Skills in <code>.claude/skills/</code> also persist. The only way to lose a skill is to delete its file or remove its section from CLAUDE.md.
</details>

<details><summary>How do I update an installed skill?</summary>
Run <code>/install skill-name</code> again. If the registry has an updated version, it replaces the old text. For manually added skills, edit the markdown directly. There is no automatic update mechanism.
</details>

<details><summary>What is the maximum number of skills I can install?</summary>
There is no hard limit on the number of skills. The practical limit is your context window -- each skill consumes tokens from the available context. Keep total skill text under 4,000 tokens (roughly 3,000 words) for optimal performance.
</details>

<script type="application/ld+json">
{"@context":"https://schema.org","@type":"FAQPage","mainEntity":[
{"@type":"Question","name":"Can I install skills from a URL or GitHub repo?","acceptedAnswer":{"@type":"Answer","text":"Not directly with /install. For custom skills, copy the markdown content into your CLAUDE.md or .claude/skills/ directory manually."}},
{"@type":"Question","name":"Do skills persist across sessions?","acceptedAnswer":{"@type":"Answer","text":"Yes. Skills installed via /install are written to CLAUDE.md. Skills in .claude/skills/ also persist. The only way to lose a skill is to delete its file."}},
{"@type":"Question","name":"How do I update an installed skill?","acceptedAnswer":{"@type":"Answer","text":"Run /install skill-name again. For manually added skills, edit the markdown directly. There is no automatic update mechanism."}},
{"@type":"Question","name":"What is the maximum number of skills I can install?","acceptedAnswer":{"@type":"Answer","text":"No hard limit. The practical limit is context window size. Keep total skill text under 4,000 tokens for optimal performance."}}
]}
</script>



**Fix it instantly →** Paste your error into our [Error Diagnostic Tool](/diagnose/) for step-by-step resolution.

## Related Guides

**Estimate tokens →** Calculate your usage with our [Token Estimator](/token-estimator/).

- [Best Claude Code Skills Ranked](/best-claude-code-skills-2026-ranked/)
- [Building Custom Skills Tutorial](/building-custom-claude-code-skill-tutorial/)
- [Configuration Guide](/configuration/)
- [Getting Started Guide](/starter/)
- [Skill Finder](/skill-finder/) -- browse and install skills
