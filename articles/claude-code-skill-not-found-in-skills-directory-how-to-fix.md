---
layout: default
title: "Claude Code Skill Not Found in Skills Directory — How to F"
description: "Encountering 'skill not found' in Claude Code? This guide covers the exact steps to diagnose and resolve skill directory issues with practical solutions."
date: 2026-03-14
categories: [troubleshooting]
tags: [claude-code, claude-skills, troubleshooting, error-fix]
author: "Claude Skills Guide"
reviewed: true
score: 10
---

# Claude Code Skill Not Found in Skills Directory — How to Fix

You've just installed a new Claude Code skill—perhaps the **pdf** skill for document processing, the **tdd** skill for test-driven development, or the **frontend-design** skill for UI prototyping. You type `/skill-name` expecting it to work, but instead you see an error message indicating the skill wasn't found in the [skills directory](/claude-skills-guide/articles/claude-skill-md-format-complete-specification-guide/). This happens more often than you'd think, and the fix is usually straightforward.

## Understanding the "Skill Not Found" Error

When Claude Code cannot locate a skill you've referenced, it reports that the skill directory cannot be found. This isn't a bug in Claude Code itself—it's almost always a configuration or placement issue. Skills in Claude Code are Markdown files that live in a specific directory, and Claude needs to know where to look.

Before diving into fixes, verify what directory Claude Code is actually using for skills. The default location is `~/.claude/skills/`, but custom configurations can point elsewhere. If you've modified your Claude configuration or are using a project-specific skills setup, the path may differ from the standard location.

## Common Causes and Their Solutions

### Cause 1: Skills Installed in the Wrong Location

The most frequent reason for the "skill not found" error is simple: the [skill file](/claude-skills-guide/articles/claude-skill-metadata-header-vs-full-body-loading/) ended up in the wrong directory. Claude Code expects skills to be in `~/.claude/skills/` as individual Markdown files with the `.md` extension.

**How to check and fix:**

```bash
# List your current skills directory
ls ~/.claude/skills/

# If empty or missing, create it
mkdir -p ~/.claude/skills/

# Move your skill file to the correct location
mv /path/to/your-skill.md ~/.claude/skills/your-skill.md
```

For example, if you downloaded the **xlsx** skill for spreadsheet manipulation, ensure the file exists as `~/.claude/skills/xlsx.md` and not in a subdirectory like `~/.claude/skills/xlsx/xlsx.md`.

### Cause 2: Incorrect Filename or Invocation Name

Skill invocation depends on the filename without its extension. If your skill file is named `my-custom-skill.md`, you invoke it as `/my-custom-skill`, not `/my custom skill` or `/my-custom-skill.md`.

**Common mistakes:**

- Adding spaces in the invocation command
- Including the `.md` extension when invoking the skill
- Using a different case than the filename (Linux filenames are case-sensitive)

**Example of correct invocation:**

```
/pdf extract tables from report.pdf
/tdd generate unit tests for auth.py
/frontend-design create landing page mockup
/supermemory search meeting notes about Q4
```

### Cause 3: Missing Skill File Extension

Every skill must be a Markdown file with the `.md` extension. If you've renamed a file or saved it as plain text, Claude Code won't recognize it. Verify the file has the correct extension:

```bash
# Check if the file exists with correct extension
ls -la ~/.claude/skills/*.md

# If you have a file without .md extension, rename it
mv ~/.claude/skills/xlsx ~/.claude/skills/xlsx.md
```

### Cause 4: Empty or Corrupted Skill File

A skill file must contain at least some content to be recognized. If you created an empty file or the download was corrupted, Claude Code may still find the file but fail to load it properly.

**Verification steps:**

```bash
# Check file has content
wc -l ~/.claude/skills/skill-name.md

# View first few lines
head -n 10 ~/.claude/skills/skill-name.md
```

A valid skill file should have meaningful content. If you downloaded the skill from a community repository, try re-downloading it.

### Cause 5: Syntax Errors in Skill Definition

Skills use YAML front matter for metadata. If this section is malformed, Claude Code may fail to parse the skill correctly. A properly formatted skill file starts with:

```yaml
---
name: pdf
description: "Work with PDF documents"
---
```

Common YAML errors include:
- Missing colons after keys
- Improper indentation
- Unquoted strings with special characters

Use a YAML validator to check your skill's front matter if you suspect syntax issues.

### Cause 6: Claude Code Using a Custom Skills Path

Some users configure Claude Code to use a different skills directory via environment variables or configuration files. This is common in enterprise setups or when managing project-specific skills.

**Check for custom configuration:**

```bash
# Check environment variables
echo $CLAUDE_SKILLS_PATH

# Check Claude config file
cat ~/.claude/settings.json | grep -i skill
```

If a custom path is set, either update it or move your skills to the configured location.

## Skills That Commonly Cause This Issue

Certain skills are more prone to installation issues because of their complexity or because users frequently download them from different sources:

- **pdf** — Requires additional dependencies for some operations
- **tdd** — Needs proper test framework configuration
- **xlsx** — Depends on spreadsheet libraries
- **frontend-design** — May require design tool integrations
- **supermemory** — Often needs API key configuration

When installing these skills, pay extra attention to any README or setup instructions that come with them.

## Quick Diagnostic Checklist

When you encounter the "skill not found" error, work through this checklist:

1. **Verify the skills directory exists** — `ls ~/.claude/skills/`
2. **Check the file exists with correct name** — `ls ~/.claude/skills/skill-name.md`
3. **Confirm the invocation matches the filename** — no extensions, no spaces
4. **Validate the file has content** — `wc -l ~/.claude/skills/skill-name.md`
5. **Check YAML front matter** — ensure proper formatting
6. **Restart Claude Code** — sometimes a fresh session resolves caching issues
7. **Try absolute path invocation** — some setups require full paths

## What If Nothing Works?

If you've exhausted these solutions, consider these additional steps:

- **Check Claude Code version** — older versions had limited skills support: `claude --version`
- **Review Claude's logs** — error messages there may reveal the actual issue
- **Test with a minimal skill** — create a simple test skill to verify the system works
- **Reinstall Claude Code** — corruption in the installation can cause unexpected behavior

## Prevention Going Forward

To avoid skill directory issues in the future:

- Always verify the skills directory after installing new skills
- Keep skills organized in the default location unless you have a specific reason not to
- Back up your skills folder regularly if you've invested time in custom configurations
- Use version control for your skills if you modify them extensively

The "skill not found" error is almost always a path or naming issue that takes minutes to resolve. Once your skills are properly placed in `~/.claude/skills/` with correct filenames, they'll work reliably across all your Claude Code sessions.

## Related Reading

- [Why Is My Claude Skill Not Showing Up: Fix Guide](/claude-skills-guide/articles/why-is-my-claude-skill-not-showing-up-fix-guide/) — Address skill visibility issues beyond directory placement problems
- [Why Does Claude Code Ignore My Skill MD File Entirely](/claude-skills-guide/articles/why-does-claude-code-ignore-my-skill-md-file-entirely/) — Diagnose cases where skills are found but silently ignored by Claude Code
- [Claude Code Skill Permission Denied Error Fix 2026](/claude-skills-guide/articles/claude-code-skill-permission-denied-error-fix-2026/) — Resolve file permission issues that prevent skill files from loading
- [Claude Skills Hub](/claude-skills-guide/troubleshooting-hub/) — Find solutions for common Claude skill installation and discovery problems

Built by theluckystrike — More at [zovo.one](https://zovo.one)
