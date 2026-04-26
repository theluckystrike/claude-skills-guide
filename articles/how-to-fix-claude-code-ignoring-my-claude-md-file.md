---
layout: default
title: "Fix How To Fix Claude Code Ignoring My (2026)"
description: "Is Claude Code ignoring your custom claude.md skill file? Learn the common reasons why skills aren't loading and how to fix them with practical solutions."
date: 2026-03-14
last_modified_at: 2026-04-17
categories: [troubleshooting]
tags: [claude-code, claude-skills, troubleshooting, claude-md]
author: "Claude Skills Guide"
reviewed: true
score: 7
permalink: /how-to-fix-claude-code-ignoring-my-claude-md-file/
geo_optimized: true
---
You've created a custom skill file, named `claude.md` or something like `my-custom-skill.md`, but Claude Code doesn't seem to recognize it. You're not alone. This is one of the most common issues users face when working with Claude Code skills. The good news is that it's usually easy to fix once you understand how Claude Code discovers and loads skill files.

## Understanding How Claude Code Loads Skills

Before diving into fixes, it's helpful to understand how Claude Code actually finds and loads your skill files. Claude Code looks for skill files in specific locations within your project:

1. Project-level skills: Located in `.claude/skills/` directory at the root of your project
2. Global skills: Located in `~/.claude/skills/` for skills available across all projects
3. Skills referenced in `.claude/settings.yml`: Can reference additional skill paths

Claude Code uses the filename (without the extension) as the skill name. When you invoke a skill, it searches for a matching file in these locations.

## Common Reasons Why Your Skill File Is Being Ignored

1. Wrong File Location

The most common issue is placing your skill file in the wrong directory. Claude Code specifically looks for skills in the `.claude/skills/` folder, not in the root directory or other locations.

Problem:
```
my-project/
 claude.md Wrong location
 README.md
```

Solution:
```
my-project/
 .claude/
 skills/
 claude.md Correct location
 README.md
```

2. Missing Front Matter

Every skill file needs proper YAML front matter to be recognized by Claude Code. Without it, the file won't be registered as a skill.

Problem:
```markdown
My Custom Skill

This skill helps with...
```

Solution:
```markdown
---
name: my-custom-skill
description: A helpful skill for specific tasks
---

My Custom Skill

This skill helps with...
```

3. Invalid Front Matter Format

Even if you have front matter, syntax errors can prevent Claude Code from parsing it correctly. Make sure your YAML is properly formatted.

Problem:
```markdown
---
name: my skill
description: A skill with spaces in name
---
```

Solution:
```markdown
---
name: my-skill
description: A skill with dashes instead of spaces
---
```

4. Incorrect File Extension

Claude Code expects skill files to have the `.md` extension. Files with other extensions or no extension won't be recognized.

Problem:
```
.claude/skills/
 claude.txt Wrong extension
 myskill No extension
```

Solution:
```
.claude/skills/
 claude.md Correct
 my-skill.md Correct
```

5. Not Invoking the Skill Correctly

Sometimes the skill is loaded but you're not invoking it properly. Claude Code skills are invoked using the `/` command or by mentioning the skill name.

How to invoke your skill:
- Type `/skill-name` to invoke a specific skill
- Or naturally mention "use the [skill name] skill" in your conversation

6. Cached State Issues

Claude Code may have a cached state that doesn't reflect your new skill. Restarting Claude Code or the VS Code extension can help.

Solution:
- Reload VS Code window (Cmd+Shift+P → "Reload Window")
- Or restart the Claude Code process entirely

## Verifying Your Skill Is Loaded

To check if your skill is properly recognized, you can:

1. Use the skills command: Type `/skills` to see a list of all available skills
2. Check the skills directory: Make sure your file appears in the expected location
3. Review the skill list: Claude Code should display your skill in the skills panel

## Best Practices for Skill Files

To ensure your skills work reliably, follow these best practices:

1. Use descriptive names: Name your skill files descriptively (e.g., `code-review.md` instead of `cr.md`)
2. Add clear front matter: Include `name`, `description`, and optionally `commands` fields
3. Keep skills focused: Each skill should handle one specific type of task
4. Test incrementally: Add content gradually and test each change

## Creating a Working Skill File

Here's a complete example of a properly configured skill file:

```markdown
---
name: code-review
description: Performs a quick code review with suggestions for improvement
---

Code Review Skill

This skill helps you review code quickly.

Usage

When you want a code review, say "/review" or ask me to use the code review skill on your current file.

I'll analyze:
- Code quality and potential bugs
- Security concerns
- Performance issues
- Style inconsistencies
```

## Encoding and YAML Front Matter Issues

Claude Code expects UTF-8 encoded Markdown files. If your `.md` file contains special characters, non-standard quotes (curly quotes from word processors), or hidden formatting, the parser may fail silently. Always create skill files in a plain text editor and save as UTF-8.

YAML front matter can also interfere with instruction parsing. While some skills include front matter for organizational purposes, Claude Code reads content after the closing `---` delimiter. Ensure your core instructions appear after the front matter, and keep front matter minimal, only `name` and `description` are recognized fields.

## Advanced Troubleshooting

If your skill still isn't working after checking the basics:

1. Check file permissions: Make sure the skill file is readable
2. Verify no hidden characters: Sometimes copy-pasting can introduce hidden characters
3. Try a minimal skill: Create the simplest possible skill to test if skills work at all
4. Check for conflicting names: Another skill with the same name might take precedence

## Conclusion

Claude Code ignoring your claude.md file is usually caused by simple issues like wrong file location, missing front matter, or incorrect file extensions. By ensuring your skill file is in the right place (`.claude/skills/`), has proper YAML front matter, and uses the `.md` extension, you should be able to get your custom skills recognized and working.

Remember: Claude Code skills are powerful tools for customizing your AI assistant. Take the time to set them up correctly, and they'll serve you well in your development workflow.

---


**Try it:** Paste your error into our [Error Diagnostic](/diagnose/) for an instant fix.
---

<div class="mastery-cta">

This site was built by 5 autonomous agents running in tmux while I was in Bali. 2,500 articles. Zero manual work. 100% quality gate pass rate.

The orchestration configs, sprint templates, and quality gates that made that possible are in the Zovo Lifetime bundle. Along with 16 CLAUDE.md templates and 80 tested prompts.

**[See how the pipeline works →](https://zovo.one/lifetime?utm_source=ccg&utm_medium=cta-skills&utm_campaign=how-to-fix-claude-code-ignoring-my-claude-md-file)**

$99 once. I'm a solo dev in Da Nang. This is how I scale.

</div>

Related Reading

- [Claude Code for Beginners: Complete Getting Started Guide](/claude-code-for-beginners-complete-getting-started-2026/)
- [Claude Code Not Working After Update: How to Fix](/claude-code-not-working-after-update-how-to-fix/)
- [Claude Code Troubleshooting Hub](/troubleshooting-hub/)
- [Claude Code Keeps Switching to Wrong File Context](/claude-code-keeps-switching-to-wrong-file-context/)

Built by theluckystrike. More at [zovo.one](https://zovo.one)


