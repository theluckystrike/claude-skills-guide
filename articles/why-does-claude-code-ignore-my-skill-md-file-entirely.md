---
layout: post
title: "Why Does Claude Code Ignore My Skill MD File Entirely"
description: "Troubleshooting guide for when Claude Code fails to load your skill MD file. Learn the common causes and fixes for skills that get completely ignored."
date: 2026-03-14
author: "Claude Skills Guide"
reviewed: true
score: 8
categories: [tutorials]
tags: [claude-code, claude-skills]
---

# Why Does Claude Code Ignore My Skill MD File Entirely

You've created a skill file, placed it in the correct directory, but Claude Code simply refuses to acknowledge it. No errors, no warnings—just silence. Your skill exists, but it might as well be invisible. This behavior frustrates many developers and power users who expect some feedback when something goes wrong. Understanding why this happens helps you diagnose and fix the issue quickly.

## The Silent Failure Problem

Unlike other errors that produce visible feedback, a completely ignored skill file provides no indication something is wrong. Claude Code processes skill files during startup and when refreshing skills, but it skips files that fail to meet certain requirements without notifying you. This design choice keeps the loading process clean but creates a debugging challenge.

Several factors can cause this silent failure. The issue typically stems from file location, naming conventions, front matter problems, or syntax errors in your skill definition. Each cause requires a different troubleshooting approach.

## File Location and Directory Structure

Claude Code expects skill files in specific locations. The most common locations are the global skills directory, project-specific `.claude/skills` folder, or a custom directory specified in your configuration. Placing your skill file anywhere else results in immediate ignorance.

Check your skill file location first. The global skills directory varies by operating system. On macOS, it typically resides at `~/Library/Application Support/Claude/skills/`. On Linux, look in `~/.config/Claude/skills/`. Windows users find it at `%APPDATA%\Claude\skills\`.

If you're working on project-specific skills, the file must live inside `.claude/skills/` at your project root. Creating a subdirectory within this folder works, but the file must have the `.md` extension and follow naming conventions.

## Naming Convention Requirements

The skill filename matters more than most developers realize. Claude Code uses the filename as part of the skill identifier, and certain characters cause parsing failures. Avoid spaces, special characters, and overly long filenames.

Valid filenames follow patterns like `pdf-helper.md`, `tdd-workflow.md`, or `frontend-design-assist.md`. Invalid examples include `My Skill.md` (spaces), `test@skill.md` (special characters), and `this-is-a-very-long-skill-name-that-exceeds-reasonable-length-limits.md` (excessive length).

The filename also determines how you invoke the skill. If you name your file `supermemory.md`, you invoke it with phrases containing "supermemory". Inconsistent naming between the file and your intended invocation phrase confuses the auto-invocation system.

## Front Matter Parsing Issues

The YAML front matter at the top of your skill file must be valid YAML. Even minor formatting errors cause Claude Code to skip the entire file. Common front matter problems include incorrect indentation, missing colons after keys, or invalid characters in values.

A proper front matter block looks like this:

```yaml
---
name: pdf-processor
description: "Extract and process text from PDF documents"
version: "1.0.0"
author: "your-username"
tags: [pdf, document-processing, extraction]
---
```

Common mistakes include using tabs instead of spaces for indentation, forgetting quotation marks around strings containing special characters, or leaving a trailing colon without a value. YAML is unforgiving—every key must have a value, and every value must be properly formatted.

If your front matter contains a list, use the correct YAML list syntax with brackets or dashes:

```yaml
# Correct list syntax
tags: [pdf, extraction, processing]

# Also correct
tags:
  - pdf
  - extraction
  - processing
```

## Content Structure Problems

Beyond front matter, the body of your skill file must contain recognizable content. An empty skill file or one with only front matter gets ignored. Claude Code expects meaningful content that defines the skill's purpose and behavior.

The content should include a clear description of what the skill does, example use cases, and implementation details. Skills that consist only of headings or very short content may be ignored as无效.

For skills like `frontend-design`, `tdd`, or `xlsx`, the content must clearly explain the domain and provide actionable guidance. A skill named `tdd` that doesn't explain test-driven development principles or provide test templates will likely be skipped.

## Encoding and Character Issues

File encoding causes more problems than developers expect. Claude Code expects UTF-8 encoded files. Files saved with other encodings, particularly those with special characters or non-Latin scripts, may fail to parse correctly.

Always save your skill files with UTF-8 encoding. Most modern text editors default to UTF-8, but always verify. Files with BOM (Byte Order Mark) characters at the beginning can also cause parsing failures.

## Cache and Refresh Problems

Sometimes the issue isn't with your skill file but with Claude Code's caching system. After creating or modifying a skill file, Claude Code may need a explicit refresh to detect the changes. Simply starting a new session doesn't always trigger a full skill scan.

Use the appropriate command to refresh skills. The exact command varies by Claude Code version, but it typically involves invoking a skill reload or restart command. Check your Claude Code version's documentation for the specific command.

## Verification and Testing

To verify your skill file is correctly formatted, try loading it with a YAML parser separately. This isolates YAML syntax errors from the broader skill loading process:

```bash
# Using Python to validate YAML
python3 -c "import yaml; yaml.safe_load(open('your-skill.md'))"
```

If the YAML parses successfully, the issue likely lies elsewhere. Check the file permissions—Claude Code must have read access to the skill file. On systems with strict file permissions, the file might exist but remain inaccessible.

## The Fix Checklist

When Claude Code ignores your skill file entirely, work through this checklist:

1. Verify the file location matches Claude Code's expected directories
2. Confirm the filename uses only lowercase letters, numbers, and hyphens
3. Validate the YAML front matter with a parser
4. Ensure the file contains substantial content beyond front matter
5. Check the file encoding is UTF-8 without BOM
6. Refresh or restart Claude Code after making changes
7. Verify file permissions allow reading

For specific skills like `pdf` manipulation, `docx` document handling, or `pptx` presentation creation, double-check that your skill name matches the domain you want to target. A skill named `pdf` that actually handles word processing confuses the system.

## Moving Forward

Once your skill loads correctly, you'll see it recognized in Claude Code's skill list or receive confirmation through its auto-invocation system. If problems persist after checking all these items, consider whether your Claude Code version supports the features you're using. Some skill features require specific versions.

Building reliable skills takes iteration. Start with a minimal working skill, verify it loads, then incrementally add features. This approach isolates problems as they occur rather than debugging a complex file that fails silently.

Built by theluckystrike — More at [zovo.one](https://zovo.one)
