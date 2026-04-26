---
layout: default
title: "Fix Skill Not Found in Claude Code (2026)"
description: "Fix 'skill not found' errors in Claude Code. Exact steps to configure your skills directory, file paths, and naming conventions. Tested 2026."
date: 2026-03-14
last_modified_at: 2026-04-17
last_tested: "2026-04-21"
categories: [troubleshooting]
tags: [claude-code, claude-skills, troubleshooting, error-fix]
author: "Claude Skills Guide"
reviewed: true
score: 10
permalink: /claude-code-skill-not-found-in-skills-directory-how-to-fix/
geo_optimized: true
---

# Claude Code Skill Not Found in Skills Directory. How to Fix

You've just installed a new Claude Code skill, the pdf skill for document processing, the tdd skill for test-driven development, or the frontend-design skill for UI prototyping. You type `/skill-name` expecting it to work, but instead you see an error message indicating the skill wasn't found in the [skills directory](/claude-skill-md-format-complete-specification-guide/). This happens more often than you'd think, and the fix is usually straightforward.

## Understanding the "Skill Not Found" Error

When Claude Code cannot locate a skill you've referenced, it reports that the skill directory cannot be found. This isn't a bug in Claude Code itself, it's almost always a configuration or placement issue. Skills in Claude Code are Markdown files that live in a specific directory, and Claude needs to know where to look.

Before diving into fixes, verify what directory Claude Code is actually using for skills. The default location is `~/.claude/skills/`, but custom configurations can point elsewhere. If you've modified your Claude configuration or are using a project-specific skills setup, the path may differ from the standard location.

## Common Causes and Their Solutions

## Cause 1: Skills Installed in the Wrong Location

The most frequent reason for the "skill not found" error is simple: the [skill file](/claude-skill-metadata-header-vs-full-body-loading/) ended up in the wrong directory. Claude Code expects skills to be in `~/.claude/skills/` as individual Markdown files with the `.md` extension.

How to check and fix:

```bash
List your current skills directory
ls ~/.claude/skills/

If empty or missing, create it
mkdir -p ~/.claude/skills/

Move your skill file to the correct location
mv /path/to/your-skill.md ~/.claude/skills/your-skill.md
```

For example, if you downloaded the xlsx skill for spreadsheet manipulation, ensure the file exists as `~/.claude/skills/xlsx.md` and not in a subdirectory like `~/.claude/skills/xlsx/xlsx.md`.

## Cause 2: Incorrect Filename or Invocation Name

Skill invocation depends on the filename without its extension. If your skill file is named `my-custom-skill.md`, you invoke it as `/my-custom-skill`, not `/my custom skill` or `/my-custom-skill.md`.

Common mistakes:

- Adding spaces in the invocation command
- Including the `.md` extension when invoking the skill
- Using a different case than the filename (Linux filenames are case-sensitive)

Example of correct invocation:

```
/pdf extract tables from report.pdf
/tdd generate unit tests for auth.py
/frontend-design create landing page mockup
/supermemory What do you have in the meeting notes about Q4?
```

## Cause 3: Missing Skill File Extension

Every skill must be a Markdown file with the `.md` extension. If you've renamed a file or saved it as plain text, Claude Code won't recognize it. Verify the file has the correct extension:

```bash
Check if the file exists with correct extension
ls -la ~/.claude/skills/*.md

If you have a file without .md extension, rename it
mv ~/.claude/skills/xlsx ~/.claude/skills/xlsx.md
```

## Cause 4: Empty or Corrupted Skill File

A skill file must contain at least some content to be recognized. If you created an empty file or the download was corrupted, Claude Code may still find the file but fail to load it properly.

Verification steps:

```bash
Check file has content
wc -l ~/.claude/skills/skill-name.md

View first few lines
head -n 10 ~/.claude/skills/skill-name.md
```

A valid skill file should have meaningful content. If you downloaded the skill from a community repository, try re-downloading it.

## Cause 5: Syntax Errors in Skill Definition

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
- Tabs instead of spaces for indentation

For example, colons inside description values cause silent parsing failures:

```yaml
WRONG. unquoted colon in description
description: Generates components: buttons, forms, modals

CORRECT. quote descriptions containing colons
description: "Generates components: buttons, forms, modals"
```

If you copied skill content from a PDF or a rich text editor, invisible non-UTF-8 characters (smart quotes, em-dashes, zero-width spaces) can silently break YAML parsing. Open the file in a plain text editor and verify there are no unusual characters in the front matter block.

Use a YAML validator to check your skill's front matter if you suspect syntax issues.

## Cause 6: Claude Code Using a Custom Skills Path

Some users configure Claude Code to use a different skills directory via environment variables or configuration files. This is common in enterprise setups or when managing project-specific skills.

Check for custom configuration:

```bash
Check environment variables
echo $CLAUDE_SKILLS_PATH

Check Claude config file
cat ~/.claude/settings.json | grep -i skill
```

If a custom path is set, either update it or move your skills to the configured location.

## Skills That Commonly Cause This Issue

Certain skills are more prone to installation issues because of their complexity or because users frequently download them from different sources:

- pdf. Requires additional dependencies for some operations
- tdd. Needs proper test framework configuration
- xlsx. Depends on spreadsheet libraries
- frontend-design. May require design tool integrations
- supermemory. Often needs API key configuration

When installing these skills, pay extra attention to any README or setup instructions that come with them.

## Note on Built-in Skills

The built-in skills. `/pdf`, `/tdd`, `/docx`, `/xlsx`, `/pptx`, `/frontend-design`, `/canvas-design`, `/supermemory`, `/webapp-testing`, `/skill-creator`. do not require external API keys or additional installations. If one of these built-in skills isn't responding, the issue is likely a Claude Code version problem rather than a directory placement issue.

## Quick Diagnostic Checklist

When you encounter the "skill not found" error, work through this checklist:

1. Verify the skills directory exists. `ls ~/.claude/skills/`
2. Check the file exists with correct name. `ls ~/.claude/skills/skill-name.md`
3. Confirm the invocation matches the filename. no extensions, no spaces
4. Validate the file has content. `wc -l ~/.claude/skills/skill-name.md`
5. Check YAML front matter. ensure proper formatting
6. Restart Claude Code. sometimes a fresh session resolves caching issues
7. Try absolute path invocation. some setups require full paths

What If Nothing Works?

If you've exhausted these solutions, consider these additional steps:

- Check Claude Code version. older versions had limited skills support: `claude --version`
- Review Claude's logs. error messages there may reveal the actual issue
- Test with a minimal skill. create a simple test skill to verify the system works
- Reinstall Claude Code. corruption in the installation can cause unexpected behavior

## Prevention Going Forward

To avoid skill directory issues in the future:

- Always verify the skills directory after installing new skills
- Keep skills organized in the default location unless you have a specific reason not to
- Back up your skills folder regularly if you've invested time in custom configurations
- Use version control for your skills if you modify them extensively

The "skill not found" error is almost always a path or naming issue that takes minutes to resolve. Once your skills are properly placed in `~/.claude/skills/` with correct filenames, they'll work reliably across all your Claude Code sessions.

---

---

<div class="mastery-cta">

This site was built by 5 autonomous agents running in tmux while I was in Bali. 2,500 articles. Zero manual work. 100% quality gate pass rate.

The orchestration configs, sprint templates, and quality gates that made that possible are in the Zovo Lifetime bundle. Along with 16 CLAUDE.md templates and 80 tested prompts.

**[See how the pipeline works →](https://zovo.one/lifetime?utm_source=ccg&utm_medium=cta-skills&utm_campaign=claude-code-skill-not-found-in-skills-directory-how-to-fix)**

$99 once. I'm a solo dev in Da Nang. This is how I scale.

</div>

Related Reading

- [Why Does Claude Code Ignore My Skill MD File Entirely](/why-does-claude-code-ignore-my-skill-md-file-entirely/). Diagnose cases where skills are found but silently ignored by Claude Code
- [Claude Code Skill Permission Denied Error Fix 2026](/claude-code-skill-permission-denied-error-fix-2026/). Resolve file permission issues that prevent skill files from loading
- [Claude Skills Hub](/troubleshooting-hub/). Find solutions for common Claude skill setup and discovery problems
- [Why Claude Code Wrong Directory (2026)](/why-is-claude-code-reading-the-wrong-directory-entirely/)
- [Why Is Claude Code Producing Code That — Developer Guide](/why-is-claude-code-producing-code-that-does-not-run/)
- [Fix Claude Code Uncaught Typeerror Is Not A — Quick Guide](/claude-code-uncaught-typeerror-is-not-a-function/)
- [Claude Code Not Recognizing TypeScript — Developer Guide](/claude-code-not-recognizing-typescript-path-aliases-tsconfig/)
- [Why Is Claude Code Changing Files I Did — Developer Guide](/why-is-claude-code-changing-files-i-did-not-mention/)
- [Fix Claude Md Not Being Read By Claude Code — Quick Guide](/claude-md-not-being-read-by-claude-code-fix/)
- [Fix Claude Code Not Generating Tests — Quick Guide (2026)](/claude-code-not-generating-tests-correctly-fix-guide/)
- [CLAUDE.md Not Loading in Claude Code — Fix Guide (2026)](/claude-md-not-loading-fix/)

Built by theluckystrike. More at [zovo.one](https://zovo.one)



---

## Frequently Asked Questions

### What is Understanding the "Skill Not Found" Error?

The "Skill Not Found" error occurs when Claude Code cannot locate a skill file you have referenced. It is almost always a configuration or file placement issue, not a Claude Code bug. Skills are Markdown files that live in a specific directory, defaulting to `~/.claude/skills/`. Custom configurations via environment variables (`$CLAUDE_SKILLS_PATH`) or `settings.json` can point to a different location. Verify which directory Claude Code is using before troubleshooting further.

### What are the common causes and their solutions?

The six common causes of "skill not found" errors are: skill files placed in the wrong directory (move to `~/.claude/skills/`), incorrect filename or invocation name (invoke without `.md` extension, no spaces, case-sensitive on Linux), missing `.md` file extension (rename plain text files), empty or corrupted skill files (re-download from source), YAML front matter syntax errors (unquoted colons, tab indentation), and custom skills path configuration overriding the default location (check `$CLAUDE_SKILLS_PATH` and `settings.json`).

### What is Cause 1: Skills Installed in the Wrong Location?

Skills installed in the wrong location is the most frequent cause of "skill not found" errors. Claude Code expects skills as individual Markdown files with `.md` extension in `~/.claude/skills/`. Verify with `ls ~/.claude/skills/`, create the directory if missing with `mkdir -p ~/.claude/skills/`, and move misplaced files with `mv /path/to/your-skill.md ~/.claude/skills/your-skill.md`. Ensure the file is not nested in a subdirectory like `~/.claude/skills/xlsx/xlsx.md` -- it must be directly in the skills folder.

### What is Cause 2: Incorrect Filename or Invocation Name?

Skill invocation depends on the filename without the `.md` extension. A file named `my-custom-skill.md` is invoked as `/my-custom-skill`, not `/my custom skill` or `/my-custom-skill.md`. Common mistakes include adding spaces in the invocation command, including the `.md` extension when invoking, and using different letter casing than the filename (Linux filenames are case-sensitive). Correct examples: `/pdf extract tables`, `/tdd generate unit tests`, `/frontend-design create landing page`.

### What is Cause 3: Missing Skill File Extension?

Every Claude Code skill must be a Markdown file with the `.md` extension. If the file was saved as plain text without an extension, Claude Code will not recognize it. Verify with `ls -la ~/.claude/skills/*.md` to list all properly named skill files. If you find a file without the `.md` extension, rename it with `mv ~/.claude/skills/xlsx ~/.claude/skills/xlsx.md`. Files downloaded from some sources may lose their extension during transfer, especially on Windows systems.

## See Also

- [Claude Code Notebook Kernel Not Found — Fix (2026)](/claude-code-notebook-kernel-not-found-fix-2026/)
- [Claude Code Skill Progressive Disclosure: Implementation Guide](/claude-code-skill-progressive-disclosure-implementation/)
