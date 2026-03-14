---
layout: default
title: "Claude Skill Not Showing Up? Fix Guide"
description: "Skill won't load in Claude Code? This guide covers the most common reasons skills fail to appear and how to resolve each issue quickly."
date: 2026-03-13
categories: [troubleshooting]
tags: [claude-code, claude-skills, troubleshooting, debug]
author: "Claude Skills Guide"
reviewed: true
score: 8
permalink: /why-is-my-claude-skill-not-showing-up-fix-guide/
---

[When a Claude Code skill fails to appear or respond to its slash command, the issue usually comes from a handful of common causes](/claude-skills-guide/claude-skill-md-format-complete-specification-guide/)

## 1. Verify the Skill Is in the Right Directory

Skills must be placed in `~/.claude/skills/`:

```bash
ls -la ~/.claude/skills/
ls ~/.claude/skills/ | grep -i "skill-name"
```

## 2. Check the Skill File Format

Skills are plain `.md` files with YAML front matter:

```markdown
---
name: frontend-design
description: Generate UI components from descriptions
---

# Frontend Design Skill
```

Common mistakes: missing `---` delimiters, invalid YAML, non-UTF-8 characters.

## 3. Confirm the Skill Name and Invocation

The slash command must match the `name` field in the skill's front matter (not the filename):

```yaml
name: frontend-design  # You type /frontend-design to invoke this
```

## 4. Restart Claude Code

Claude Code reads the skills directory at startup. Start a fresh session after adding skills:

```bash
claude
```

## 5. Check for Conflicting Skill Names

If two skill files have the same `name` field, rename one and restart.

## 6. Understand Built-in Skills

The built-in [skills](/claude-skills-guide/skill-md-file-format-explained-with-examples/) — `/pdf`, `/tdd`, `/docx`, `/xlsx`, `/pptx`, `/frontend-design`, `/canvas-design`, `/supermemory`, `/webapp-testing`, `/skill-creator` — do not require external API keys or additional installations.

## 7. Check Permissions

```bash
claude --verbose
chmod 644 ~/.claude/skills/your-skill.md
```

## 8. Validate the YAML Front Matter

Invalid YAML in the front matter prevents the skill from loading entirely. Common YAML mistakes that are hard to spot:

```yaml
# WRONG — unquoted colon in description
description: Generates components: buttons, forms, modals

# CORRECT — quote descriptions containing colons
description: "Generates components: buttons, forms, modals"
```

Tabs in YAML indentation also cause silent failures. Use spaces only.

## 9. Check for Non-UTF-8 Characters

If you copied skill content from a PDF or a rich text editor, invisible non-UTF-8 characters (smart quotes, em-dashes, zero-width spaces) can silently break YAML parsing. Open the file in a plain text editor and verify there are no unusual characters in the front matter block.

## When Nothing Works

If all the above checks pass and the skill still won't appear, try creating a minimal skill from scratch to isolate the issue:

```markdown
---
name: test-skill
description: A minimal test skill
---

You are a test assistant. When invoked, reply: "test skill is working."
```

Save this as `~/.claude/skills/test-skill.md`, start a fresh Claude Code session, and type `/test-skill`. If this works, the issue is in your original skill file's content or formatting. If this doesn't work either, the issue is with the directory setup or Claude Code installation itself.

## Final Checklist

1. Skill file exists in `~/.claude/skills/` (not a custom directory like `~/my-skills/`)
2. File has `.md` extension with valid YAML front matter
3. The `name` field matches what you type after `/`
4. No duplicate skill names
5. No YAML syntax errors (colons, tabs, invalid characters)
6. Fresh session started after adding the skill
7. Test with a minimal skill if all else fails

---

## Related Reading

- [Best Claude Code Skills for Frontend Development](/claude-skills-guide/best-claude-code-skills-for-frontend-development/)
- [Best Claude Skills for Developers in 2026](/claude-skills-guide/best-claude-skills-for-developers-2026/)
- [Claude Skills Auto Invocation: How It Works](/claude-skills-guide/claude-skills-auto-invocation-how-it-works/)

Built by theluckystrike — More at [zovo.one](https://zovo.one)
