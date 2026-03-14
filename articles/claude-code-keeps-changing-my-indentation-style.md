---
layout: default
title: "Claude Code Keeps Changing My Indentation Style"
description: "Learn how to control indentation preferences in Claude Code, configure your preferred style, and prevent unwanted formatting changes when Claude edits your code."
date: 2026-03-14
author: theluckystrike
categories: [troubleshooting]
tags: [claude-code, indentation, formatting, code-style, configuration]
permalink: /claude-code-keeps-changing-my-indentation-style/
---

# Claude Code Keeps Changing My Indentation Style

If you've ever noticed Claude Code rewriting your carefully formatted code with different indentation—switching tabs to spaces, adding extra indentation to nested blocks, or reformatting your entire file—you're not alone. This is one of the most common friction points developers encounter when working with AI coding assistants. The good news is that Claude Code offers several ways to control this behavior and keep your code looking exactly how you want it.

## Why Claude Changes Indentation

Before diving into solutions, it helps to understand why Claude Code modifies indentation in the first place. Claude's primary goal is to produce correct, functional code. When it generates or edits code, it follows patterns it has learned from training data, which often reflect common conventions in the programming community. These conventions can differ from your personal or project-specific preferences in several ways:

**Tab vs. Space Preferences**: Different programming communities have strong opinions about tabs versus spaces. Python developers often prefer 4 spaces (per PEP 8), while JavaScript projects frequently use 2 spaces. Some developers prefer tabs for accessibility. Claude may default to one style over another based on the language it's working with.

**Nested Block Indentation**: When Claude writes code for loops, conditionals, or functions, it applies its own judgment about how much to indent each level. If you're used to 4-space indentation but Claude uses 2 spaces (or vice versa), the mismatch becomes immediately visible.

**Automatic Formatting**: Claude sometimes reformats entire files to make them "cleaner" or more consistent. This can happen even when you only asked it to make a small change, especially if the existing code has inconsistent formatting.

## Controlling Indentation with .claude/settings.json

The most direct way to control indentation behavior is through Claude Code's settings file. Create or edit the file at `.claude/settings.json` in your project root. This file lets you specify indentation preferences that Claude will respect.

Here's how to configure your preferred indentation style:

```json
{
  "preferences": {
    "indentType": "space",
    "indentSize": 4,
    "tabSize": 4
  }
}
```

This configuration tells Claude Code to use spaces (not tabs) with a width of 4 characters per indentation level. You can adjust these values to match your project's style guide or personal preference.

If you prefer tabs:

```json
{
  "preferences": {
    "indentType": "tab",
    "indentSize": 1,
    "tabSize": 4
  }
}
```

The `indentSize` for tabs determines how wide a tab appears in visual rendering, while `tabSize` tells Claude how many spaces to count when calculating alignment.

## Project-Specific Configuration with EditorConfig

Many projects use EditorConfig files to maintain consistent coding styles across different editors and contributors. Claude Code respects `.editorconfig` files in your project, making this an excellent way to enforce indentation rules team-wide.

Create an `.editorconfig` file in your project root:

```ini
root = true

[*]
indent_style = space
indent_size = 2
end_of_line = lf
charset = utf-8
trim_trailing_whitespace = true
insert_final_newline = true

[*.py]
indent_size = 4

[*.yaml]
indent_size = 2
```

This example sets a default of 2-space indentation but overrides it to 4 spaces for Python files and 2 spaces for YAML. Claude Code reads these settings and applies them appropriately when working with different file types.

## Using Skills to Enforce Indentation Rules

Claude Code skills provide another powerful mechanism for controlling indentation behavior. You can create a custom skill that explicitly instructs Claude to maintain your preferred indentation style.

Create a file at `CLAUDE.md` in your project root (or in `.claude/skills/`):

```markdown
---
name: preserve-indentation
description: Preserves your project's indentation style exactly as defined
---

# Indentation Preservation

When editing or generating code, always preserve the existing indentation style of the file you're working on. 

- If the file uses tabs, use tabs
- If the file uses spaces, match the number of spaces already used
- Never reformat entire files unless explicitly asked
- When making small edits, only reformat the changed portions if necessary
- Match the project's existing code style, not a different convention
```

This skill will be automatically loaded when Claude works on your project, and it provides clear guidance about respecting your indentation preferences.

## Explicit Instructions in Conversations

Sometimes you just need to tell Claude directly what you want. In your conversation, be explicit about indentation requirements:

> "Please write this function using 4-space indentation, not 2 spaces."

> "Don't change the indentation style—just add the missing validation logic."

> "Use tabs for this file, not spaces."

Claude responds well to specific, direct instructions about formatting preferences. If you find yourself repeatedly asking for the same adjustment, consider adding it to your project's CLAUDE.md file or creating a persistent skill.

## Handling Existing Code with Different Styles

When working on legacy projects or code from other contributors, you may encounter files with inconsistent or different indentation. Rather than reformatting the entire file (which creates large, hard-to-review diffs), consider these approaches:

**Incremental Consistency**: When you make changes to a specific section, match the existing indentation of that section. Over time, as different parts of the file get updated, they naturally become more consistent.

**Pre-Commit Formatting**: Use automated formatters like Prettier, Black, or ESLint to handle formatting separately from code changes. This way, you can make your functional changes without worrying about style, and let the formatter handle indentation consistency.

**Explicit Refactoring**: If you genuinely need to reformat a file for maintainability, make that a separate, explicit task. Tell Claude: "I want to reformat this entire file to use 4-space indentation. Please do that as a separate change."

## Troubleshooting Persistent Indentation Issues

If you've configured settings but Claude still changes indentation, check a few common causes:

**Conflicting Configurations**: Make sure you don't have conflicting settings in multiple places. Claude checks `.claude/settings.json`, `.editorconfig`, and CLAUDE.md. If these contradict each other, the behavior may be unpredictable.

**Session-Level Settings**: Some Claude Code sessions may have session-specific settings that override project defaults. Starting a fresh session can help determine if the issue is session-specific.

**File-Type Specificity**: Some settings apply only to certain file types. Double-check that your configuration covers the language you're working with.

## Conclusion

Claude Code's indentation behavior is controllable through project settings, EditorConfig files, custom skills, and explicit conversation instructions. The key is finding the approach that fits your workflow—whether that's setting project-wide defaults that all contributors share or maintaining personal preferences in your user configuration.

By configuring your indentation preferences once and referencing them consistently, you can focus on writing code rather than constantly fixing formatting. Claude Code is designed to be helpful, and that includes respecting the code style you've carefully established for your projects.
