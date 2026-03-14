---
layout: default
title: "Claude Code Ignores .md Instructions Fix"
description: "Resolve when Claude Code ignores skill.md instructions: front matter vs body loading, auto-invocation triggers, prompt conflicts, and configuration fixes."
date: 2026-03-14
categories: [troubleshooting]
tags: [claude-code, claude-skills, debugging, skill-md]
author: "Claude Skills Guide"
reviewed: true
score: 8
---

# Claude Code Ignores .md Instructions Fix

Your [skill.md file](/claude-skills-guide/claude-skill-md-format-complete-specification-guide/) sits in the correct directory, the YAML front matter looks valid, yet Claude Code behaves as if the instructions don't exist. This happens more often than you'd think, and the root causes aren't always obvious. Here's how to diagnose and fix it.

## Why Your Instructions Get Ignored

Claude Code loads skill instructions through two mechanisms, and understanding the difference matters. The **front matter** (the YAML block at the top) loads into the system prompt automatically for every conversation. The **body content** only loads when the skill auto-invokes or gets manually triggered.

If you've put critical instructions only in the body and your skill isn't auto-invoking, Claude Code never sees them. This is the most common reason developers feel their instructions are being ignored.

### Front Matter Loading Behavior

The YAML front matter loads for every session when the skill is registered. This includes fields like `name`, `description`, and any custom fields you define. The description field is particularly important because Claude Code uses it for skill selection during auto-invocation.

```
---
name: pdf-processor
description: Extract tables and text from PDF files for analysis
version: 1.0.0
---
```

When this skill loads, the description becomes part of the context that Claude Code uses to decide whether to activate it. If your description is vague or missing, the skill may never trigger automatically.

### Body Content Loading Behavior

The Markdown body only loads under specific conditions:

1. **Auto-invocation**: When Claude Code detects a match with your skill's triggers
2. **Manual invocation**: When you explicitly invoke the skill with `/skill name` or through the skills menu
3. **Conversation context**: When the current task aligns with the skill's defined purpose

Placing instructions in the body that are essential for skill behavior won't work if the skill isn't activating. This is where most confusion occurs.

## Fix 1: Verify Auto-Invocation Is Working

The `description` field in your front matter drives auto-invocation. If Claude Code isn't recognizing when to use your skill, the description probably doesn't match your actual use case.

A vague description like "Helps with development tasks" won't trigger for specific workflows. Instead, be explicit:

```
description: "Generate spreadsheet reports with formulas, charts, and conditional formatting using xlsx skill patterns"
```

This directly mentions the xlsx skill and the specific use case, making auto-invocation more reliable.

To test whether auto-invocation works, start a conversation that should match your skill's purpose. Watch for Claude Code's skill indicator in the conversation header. If nothing appears, your description needs adjustment.

## Fix 2: Move Critical Instructions to Front Matter

For instructions that must always apply, put them in the YAML front matter using custom fields that you reference in your prompts:

```
---
name: frontend-designer
description: Create responsive UI components and layouts
always-enforce: "Use semantic HTML, implement WCAG 2.1 AA accessibility standards, use CSS custom properties for theming"
---
```

Then reference this in your body content or prompts as needed. The front matter approach works because it loads with the system prompt for every session.

## Fix 3: Check for Competing Instructions

When you use multiple skills together, their instructions can conflict. The tdd skill might enforce strict test-first development while another skill prefers implementation-first workflows. Claude Code resolves these conflicts based on the most recently loaded instruction context.

To diagnose conflicts, temporarily disable other skills:

```bash
# Rename skill files to disable them
mv ~/.claude/skills/skill-a.md ~/.claude/skills/skill-a.md.disabled
```

Test your target skill in isolation. If it works, re-enable skills one at a time to find the conflict. Common conflict patterns include:

- Different output format expectations (JSON vs Markdown)
- Conflicting file structure requirements
- Opposing code style preferences

## Fix 4: Skill Not Triggering Automatically

If your skill only works when manually invoked but never auto-activates, the problem is in the matching logic. Claude Code uses fuzzy matching against your description field.

A practical test: explicitly tell Claude Code to use your skill:

```
Use the pdf skill to extract all tables from this document.
```

If this works but the skill doesn't auto-invoke for appropriate tasks, your description is the culprit. Make it more specific and include the exact trigger phrases users would type.

For skills like supermemory that maintain persistent context, ensure your description mentions "memory", "context", or "remember" if that's the use case you want covered.

## Fix 5: YAML Syntax Errors

A single syntax error in your front matter can cause the entire file to fail loading. Claude Code silently falls back to default behavior, making it appear as though instructions are ignored.

Common YAML issues:

```yaml
# Wrong: missing quotes around special characters
description: Use "quoted" strings properly

# Correct: escape or use single quotes
description: Use "quoted" strings properly
```

Run your YAML through a validator before saving. Even trailing whitespace can cause problems.

## Fix 6: File Location and Naming

Skills must live in the correct directory structure:

```
~/.claude/skills/
├── skill-name.md
└── (optional) skill-name/
    └── (additional files if needed)
```

Some developers accidentally place skills in subdirectories without updating their invocation commands. If you moved a skill to a nested folder, update how you reference it.

## Fix 7: Context Window Limitations

When your skill body is extremely long, Claude Code may truncate or skip portions during processing. If you have extensive instruction sets, consider:

- Breaking into multiple focused skills
- Using the skill's body for primary workflow and front matter for absolute requirements
- Referencing external documentation for detailed patterns rather than embedding everything

The frontend-design skill demonstrates good practice by keeping primary instructions in the file body but referencing external component libraries for detailed API documentation.

## Summary

When Claude Code ignores your skill.md instructions, check these in order:

1. **Description field** — Is it specific enough for auto-invocation?
2. **Front matter vs body** — Are essential instructions in the right place?
3. **Multiple skills** — Is there a conflict with other loaded skills?
4. **YAML validity** — Does the front matter parse without errors?
5. **File location** — Is the skill in the correct directory?
6. **Context limits** — Is your content getting truncated?

Most cases resolve by moving critical instructions to front matter and making the description more specific. The tdd skill, for example, succeeds because its description explicitly mentions "test-driven development" and "write tests first" — clear triggers that match how users ask for help.

## Related Reading

- [Claude Skill MD Format: Complete Specification Guide](/claude-skills-guide/claude-skill-md-format-complete-specification-guide/) — Master the correct structure for skill files that Claude Code loads reliably
- [Claude Skill YAML Front Matter Parsing Error Fix](/claude-skills-guide/claude-skill-yaml-front-matter-parsing-error-fix/) — Fix YAML syntax issues that prevent instructions from being parsed
- [Why Does Claude Code Reject My Skill Instruction Block](/claude-skills-guide/why-does-claude-code-reject-my-skill-instruction-block/) — Diagnose instruction block rejections that cause ignored skill files
- [Claude Skills Troubleshooting Hub](/claude-skills-guide/troubleshooting-hub/) — Find solutions for skill loading and instruction parsing problems

Built by theluckystrike — More at [zovo.one](https://zovo.one)
