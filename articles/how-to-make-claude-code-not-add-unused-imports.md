---
layout: default
title: "How To Make Claude Code Not Add (2026)"
description: "Practical techniques to prevent Claude Code from adding unused imports, including CLAUDE.md settings, custom skills, and project configuration."
date: 2026-03-14
last_modified_at: 2026-04-17
categories: [guides]
tags: [claude-code, claude-skills, import-management, code-quality]
author: "Claude Skills Guide"
reviewed: true
score: 7
permalink: /how-to-make-claude-code-not-add-unused-imports/
geo_optimized: true
---
One of the most common frustrations developers face when working with Claude Code is the AI assistant's tendency to add unused imports while coding. Whether you're working in Python, JavaScript, TypeScript, or other languages, unused imports clutter your codebase and can trigger linter warnings or build failures. This guide covers practical techniques to prevent Claude Code from adding unnecessary imports.

## Understanding Why Claude Adds Unused Imports

Before diving into solutions, it's helpful to understand why Claude Code adds unused imports in the first place. Claude operates proactively, it anticipates potential needs and adds imports "just in case." While this behavior stems from a helpful intent, it often leads to:

- Over-importing: Adding imports for functions or modules that end up unused
- Import bloat: Accumulating imports as Claude modifies code across sessions
- Linter errors: Triggering tools like ESLint, flake8, or TypeScript compiler warnings

The good news is that you can configure Claude Code to be more conservative about imports through several mechanisms.

## Use CLAUDE.md for Project-Wide Import Guidance

The most effective way to control import behavior is through a CLAUDE.md file in your project root. This file provides persistent instructions that Claude follows across all interactions.

Create or update your CLAUDE.md with explicit import guidelines:

```markdown
Project Import Guidelines

Import Rules
- Never add imports "just in case" - only add imports when actively used in the current code change
- Remove unused imports before completing a code change
- When modifying existing code, verify if imports are actually needed before keeping them
- Prefer importing specific items over entire modules when possible

Before Adding Any Import
1. Check if the import already exists in the file
2. Verify the import is actually used in the code you're writing
3. Remove any imports that become unused after refactoring
```

This approach works because Claude reads CLAUDE.md at the start of each session and incorporates its guidelines into its reasoning. The instructions are specific enough to significantly reduce unused import additions.

## Configure Claude Code Settings Globally

For settings that apply across all your projects, you can configure Claude Code's global settings. The `~/.claude/settings.json` file controls session-wide behavior:

```json
{
 "imports": {
 "autoAdd": false,
 "verifyUsage": true,
 "lintCheck": true
 },
 "codeGeneration": {
 "conservativeMode": true
 }
}
```

The `conservativeMode` setting encourages Claude to be more cautious about adding code, including imports. While not all settings are officially documented, users have reported success with this configuration approach.

## Create a Custom Skill for Import Management

For more granular control, create a custom Claude skill focused on import best practices. This is particularly useful if you work on multiple projects with different import requirements.

Create a file at `~/.claude/skills/import-discipline/skill.md`:

```markdown
---
name: import-discipline
description: Ensure strict import discipline - no unused imports
---

Import Discipline Skill

You must follow these import rules for every code change:

Adding Imports
- ONLY add imports when the imported symbol is actively used in the code being written
- If you're unsure whether an import is needed, DON'T add it
- Ask the user before adding non-obvious imports

Removing Unused Imports
- Before marking a task complete, scan for and remove any unused imports
- Run the linter/formatter to check for import issues
- In Python: use isort --check and flake8 to verify
- In JavaScript/TypeScript: use ESLint to verify
- In Go: use go fmt and go vet to verify

Verification Steps
After any code change involving imports:
1. Check if any imports are now unused
2. Run the project's linter to confirm no import warnings
3. If the project has a type checker, verify it passes
```

To use this skill, invoke it explicitly in your conversations:

```
@import-discipline Please help me write this function while maintaining import discipline
```

## Use Pre-Commit Hooks as a Safety Net

Even with Claude configured correctly, a safety net of pre-commit hooks provides peace of mind. Configure your project's pre-commit to catch unused imports:

For Python projects, add to `.pre-commit-config.yaml`:

```yaml
repos:
 - repo: https://github.com/pycqa/isort
 rev: 5.13.2
 hooks:
 - id: isort
 args: ["--check-only", "--diff"]

 - repo: https://github.com/pycqa/flake8
 rev: 7.0.0
 hooks:
 - id: flake8
 args: ["--select=F401"] # F401 = unused imports
```

For JavaScript/TypeScript projects:

```yaml
repos:
 - repo: https://github.com/sindresorhus/eslint-dates
 rev: main
 hooks:
 - id: eslint
 args: ["--fix", "--max-warnings=0"]
```

These hooks will fail the commit if Claude accidentally adds unused imports, ensuring they never reach your main branch.

## Provide Contextual Guidance in Each Session

For one-off projects or when you need temporary import restrictions, provide explicit instructions in your initial prompt:

```
Please help me with this coding task. Important: Do NOT add any imports unless they are actively used in the code you write. After completing the code, verify there are no unused imports by checking with [linter command]. Don't ask me to confirm - just do this automatically.
```

This approach gives you session-specific control without modifying persistent configuration files.

## Practical Example: Python Refactoring Session

Here's how these techniques work together in practice:

1. CLAUDE.md contains your import guidelines
2. You invoke `@import-discipline` for focused tasks
3. Before completing, Claude runs `flake8 --select=F401`
4. Pre-commit hooks catch anything missed

When refactoring a Python file, Claude will:
- Read the existing imports
- Only add new imports when actively calling the function/class
- Remove imports that become unused after refactoring
- Verify with flake8 before considering the task complete

## Conclusion

Preventing Claude Code from adding unused imports requires a multi-layered approach. Start with a well-crafted CLAUDE.md file for project-wide guidance, create a dedicated import-discipline skill for explicit control, and maintain pre-commit hooks as your safety net. Combined, these techniques ensure your codebase remains clean and import-free.

Remember: Claude responds well to explicit instructions. The more clearly you communicate your import preferences, the better Claude Code will follow them. Start with these configurations and adjust based on your specific project needs.

---


**Try it:** Paste your error into our [Error Diagnostic](/diagnose/) for an instant fix.
---

<div class="mastery-cta">

I'm a solo developer in Vietnam. 50K Chrome extension users. $500K+ on Upwork. 5 Claude Max subscriptions running agent fleets in parallel.

These are my actual CLAUDE.md templates, orchestration configs, and prompts. Not a course. Not theory. The files I copy into every project before I write a line of code.

**[See what's inside →](https://zovo.one/lifetime?utm_source=ccg&utm_medium=cta-default&utm_campaign=how-to-make-claude-code-not-add-unused-imports)**

$99 once. Free forever. 47/500 founding spots left.

</div>

Related Reading

- [How to Make Claude Code Handle Edge Cases Properly](/how-to-make-claude-code-handle-edge-cases-properly/)
- [How to Make Claude Code Respect My ESLint Config](/how-to-make-claude-code-respect-my-eslint-config/)
- [Best Way to Use Claude Code for Large File Refactoring](/best-way-to-use-claude-code-for-large-file-refactoring/)

Built by theluckystrike. More at [zovo.one](https://zovo.one)


**Find the right skill →** Browse 155+ skills in our [Skill Finder](/skill-finder/).

