---
layout: default
title: "Why Does Claude Code Not Recognize My Custom Skill Name?"
description: "Troubleshooting guide for custom skill registration issues in Claude Code. Learn why your skill won't load and how to fix skill name recognition problems."
date: 2026-03-14
categories: [troubleshooting]
tags: [claude-code, claude-skills, troubleshooting, skill-registration]
author: "Claude Skills Guide"
reviewed: true
score: 9
---

# Why Does Claude Code Not Recognize My Custom Skill Name?

You've created a custom skill, placed it in the right directory, but when you try to invoke it with `/skill-name`, Claude Code gives you that confused response. Your skill isn't loading. This is a common issue with several potential causes. Let's walk through why this happens and how to fix it.

## Where Claude Looks for Skills

Claude Code searches for skills in specific locations depending on your setup. The most common locations are:

- `~/.claude/skills/` (user-level skills, macOS/Linux)
- `./skills/` (project-level skills)

If your skill file isn't in one of these locations, Claude simply won't find it. The skill must also be in a directory that Claude is configured to scan.

## File Naming Matters

The skill filename directly determines the skill name Claude recognizes. If your file is named `my-custom-skill.md`, you invoke it with `/my-custom-skill`. However, there are nuances:

- **Spaces in filenames**: Claude converts spaces to hyphens. A file named `frontend design skill.md` becomes `/frontend-design-skill`.
- **Case sensitivity**: While some systems are case-insensitive, it's safest to use lowercase for skill names.
- **File extension**: Only `.md` files are recognized as skills. `.txt`, `.markdown`, or other extensions won't work.

## The YAML Front Matter Requirement

Every skill file must begin with valid YAML front matter. This metadata tells Claude Code how to handle your skill. Without it, the skill won't load:

```yaml
---
name: frontend-design
description: Helps with frontend design decisions and code generation
---
```

If your front matter is malformed—missing dashes, incorrect indentation, or invalid YAML—Claude skips the entire file. Common mistakes include:

- Using tabs instead of spaces for indentation
- Leaving colons without values
- Including unsupported characters in the metadata

## Directory Structure Problems

Claude expects a flat directory structure or a specific organizational pattern. Common issues include:

**Nested directories**: If you place your skill in `~/.claude/skills/categories/frontend-design.md`, you might expect to invoke it as `/categories/frontend-design`. Instead, Claude flattens the structure or ignores nested files entirely.

**Wrong parent directory**: Skills must be in the root of the skills directory, not in subfolders (unless your specific setup uses a different configuration).

## Skill Name Conflicts

Sometimes your skill exists but gets overshadowed by a built-in skill or another custom skill with the same name. Built-in skills like `pdf`, `pptx`, `docx`, `xlsx`, [`tdd`](/claude-skills-guide/claude-tdd-skill-test-driven-development-workflow/), and `supermemory` take precedence. If you create a skill named `pdf` expecting it to override the built-in, you may encounter unexpected behavior.

To check for conflicts, list all available skills in your directory:

```bash
ls -la ~/.claude/skills/
```

If you see duplicate names, rename one of them.

## Cache and Refresh Issues

Claude Code caches skill metadata. After creating a new skill or making changes, you may need to restart your Claude session or explicitly trigger a refresh. The exact refresh mechanism depends on your interface:

- **CLI users**: Restart the Claude process
- **VS Code extension**: Reload the window
- **Desktop app**: Quit and relaunch

Simply editing the skill file isn't always enough—Claude needs to re-scan the directory.

## Checking for Syntax Errors in Your Skill

Even if the skill loads, syntax errors in the skill body can prevent proper execution. A skill file is essentially a system prompt, so any confusing instructions or broken formatting can cause Claude to ignore or misinterpret the skill.

Validate your skill by:

1. Keeping the description clear and concise
2. Avoiding nested bullet points that break YAML parsing
3. Using consistent formatting throughout

## Example: Fixing a Skill That Won't Load

Let's say you created `~/.claude/skills/frontend-design.md` but `/frontend-design` doesn't work. Here's how to troubleshoot:

1. **Check the file exists**: `ls ~/.claude/skills/frontend-design.md`
2. **Verify front matter**: Open the file and ensure it starts with `---` and ends with `---`
3. **Test the name**: Try invoking with the exact filename minus extension
4. **Restart Claude**: Close and reopen your session

A working skill file looks like this:

```yaml
---
name: frontend-design
description: Assists with React components, CSS styling, and design patterns
---
# Frontend Design Skill

You are a frontend design expert. When asked about UI components:

1. Suggest modern CSS solutions before frameworks
2. Recommend accessible HTML patterns
3. Provide working code examples

Always consider performance and browser compatibility.
```

## Special Characters and Encoding

Avoid special characters in skill names. Stick to alphanumeric characters and hyphens. Characters like underscores, ampersands, or parentheses can cause recognition issues in certain environments.

## Conclusion

If Claude Code doesn't recognize your custom skill name, systematically check: file location, filename format, front matter validity, directory structure, and potential name conflicts. Most issues stem from these common pitfalls rather than complex configuration problems.

With your skill properly configured, you can invoke it with `/skill-name` and Claude will respond with your custom guidance. Skills like `frontend-design`, `pdf`, `tdd`, and `supermemory` demonstrate how powerful well-registered skills can be for specialized tasks.

---

## Related Reading

- [Why Is My Claude Skill Not Showing Up: Fix Guide](/claude-skills-guide/why-is-my-claude-skill-not-showing-up-fix-guide/) — If the skill isn't recognized even after registration, this guide addresses the skill list display issues
- [Claude Skill MD Format: Complete Specification Guide](/claude-skills-guide/claude-skill-md-format-complete-specification-guide/) — Ensure your skill name and metadata follow the correct format to guarantee recognition by Claude Code
- [How Do I Debug a Claude Skill That Silently Fails](/claude-skills-guide/how-do-i-debug-a-claude-skill-that-silently-fails/) — Use these debugging techniques when your skill is recognized but not behaving as expected
- [Claude Skills: Getting Started Hub](/claude-skills-guide/getting-started-hub/) — Explore skill registration, naming conventions, and troubleshooting patterns across the Claude ecosystem

Built by theluckystrike — More at [zovo.one](https://zovo.one)
