---
layout: default
title: "Should .claude Be in .gitignore? (2026)"
description: "Add .claude to .gitignore to protect API keys and session data. Also covers node_modules, .env, and OS files for a clean Claude Code project setup."
date: 2026-04-19
last_modified_at: 2026-04-19
last_tested: "2026-04-21"
categories: [guides]
tags: [claude-code, gitignore, best-practices, version-control, claude-skills]
author: "Claude Skills Guide"
reviewed: true
score: 8
permalink: /claude-code-gitignore-best-practices/
geo_optimized: true
---

# Claude Code Gitignore Best Practices

Getting gitignore right in practice means solving merge conflict resolution patterns and branch strategy management. The Claude Code patterns in this gitignore guide were developed from real project requirements.

When working with Claude Code and its skills ecosystem, proper `.gitignore` configuration prevents accidentally committing sensitive data, skill cache files, and project artifacts that should stay local. This guide covers essential gitignore patterns for Claude Code projects. For a broader introduction to project setup, see [Claude Code for beginners: getting started 2026](/claude-code-for-beginners-complete-getting-started-2026/).

## Why Gitignore Matters for Claude Code

Claude Code stores skill data, conversation history, and working files in specific directories within your project. Without proper exclusions, you risk committing:

- Skill invocation logs and cached responses
- Generated code and temporary files
- API keys and credentials used by skills
- Build artifacts from skill-powered workflows

## Essential Claude Code Gitignore Patterns

Add these patterns to your project's `.gitignore` to keep your repository clean and secure:

```
Claude Code directories
.claude/
.claude/settings.json
.claude/settings.local.json

Claude Code skills cache and logs
.claude/skills/.cache/
.claude/skills/*.log
.claude/skills/state/
.claude/skills/tmp/

Claude Code conversation and session data
.claude/conversations/
.claude/sessions/
.claude/checkpoints/

Skill-specific exclusions
*.skill-backup
skill-state.json
conversation-history/
.claude-history

Generated artifacts
dist/
build/
*.generated.*
*.tmp

Environment files
.env
.env.local
.env.*.local

Node and Python dependencies
node_modules/
venv/
.venv/
__pycache__/
*.pyc

IDE and editor files
.vscode/
.idea/
*.swp
*.swo
*~

OS files
.DS_Store
Thumbs.db
```

A few patterns deserve special attention. The `.claude/settings.local.json` file is where Claude Code stores per-machine overrides. things like local MCP server paths or workspace-specific tool permissions that differ from developer to developer. The `.claude/conversations/` and `.claude/sessions/` directories accumulate quickly when you use Claude Code heavily; they are safe to regenerate and add significant size to a repository if left unignored.

If you want to commit your shared Claude Code settings (useful for team alignment on which skills are enabled), you can selectively un-ignore the base settings file while keeping local overrides excluded:

```
Commit base settings but not local overrides
!.claude/settings.json
.claude/settings.local.json
```

This pattern lets your team share a baseline configuration through source control without clobbering each developer's local preferences.

## Skill-Specific Gitignore Recommendations

## For Projects Using the pdf Skill

If you're processing documents with the `pdf` skill, exclude output directories. The [best Claude Code skills to install first in 2026](/best-claude-code-skills-to-install-first-2026/) guide covers which skills generate the most filesystem output worth excluding:

```
PDF processing outputs
pdf-output/
processed-docs/
extracted-data/
```

## For Projects Using the tdd Skill

When running test-driven development:

```
Test outputs
test-results/
coverage/
.nyc_output/
```

## For Projects Using the xlsx and docx Skills

Spreadsheet and document automation generates temporary files:

```
Office document processing
excel-temp/
docx-cache/
```

## Global vs Project-Level Gitignore

Git supports two tiers of ignore rules, and understanding the difference is important for Claude Code workflows.

Project-level `.gitignore` lives in your repository root and is committed to source control. Every developer who clones the repo gets these rules automatically. Use it for patterns that are true for everyone. things like `node_modules/`, `dist/`, and skill output directories that your project always generates.

Global gitignore lives on your machine and applies to every repository you touch, without being committed anywhere. This is the right place for patterns that are specific to your environment. your editor's scratch files, OS metadata, and Claude Code's local data directories.

Set up a global gitignore file once and it covers all your repositories:

```bash
git config --global core.excludesFile ~/.gitignore_global
```

Then populate `~/.gitignore_global` with machine-specific patterns:

```
Claude Code local data (all projects)
.claude/conversations/
.claude/sessions/
.claude/checkpoints/
.claude/settings.local.json
.claude-history

macOS
.DS_Store
.AppleDouble
.LSOverride

Windows
Thumbs.db
ehthumbs.db
Desktop.ini

JetBrains IDEs
.idea/
*.iml

VS Code workspace settings
.vscode/settings.json
.vscode/*.code-workspace

Vim / Emacs swap and backup files
*.swp
*.swo
*~
\#*\#
```

The rule of thumb: if a pattern applies to your personal development environment rather than the project itself, it belongs in the global gitignore, not in the project's `.gitignore`. This keeps project-level ignore files focused and readable for other contributors.

When team settings need sharing, keep `.claude/settings.json` (the base config) in the project `.gitignore` as an explicit exception:

```
Ignore most of .claude/ but share the base settings
.claude/
!.claude/settings.json
```

This approach is common on teams that want all developers running the same skill set without enforcing local machine paths or personal preferences.

## Verifying Your Gitignore

Before committing, check what will be tracked:

```bash
See what's being tracked
git status

Check what would be added
git add --dry-run .

Verify gitignore is working
git check-ignore -v filename
```

## Common Mistakes to Avoid

## Ignoring Lock Files

One of the most damaging gitignore mistakes is accidentally excluding lock files. Lock files (`package-lock.json`, `yarn.lock`, `poetry.lock`, `Gemfile.lock`) record the exact dependency versions your project used when it last worked. They should almost always be committed.

The problem typically happens when a developer adds an overly broad pattern like `*.lock` intending to exclude database lock files or editor lock files, but accidentally catches package manager lock files at the same time. Always be explicit:

```
Safe: exclude only specific lock-like files
*.swp
*.swo

Dangerous: excludes package-lock.json and yarn.lock too
*.lock
```

## Over-Ignoring Source Directories

Adding `src/` or `lib/` to `.gitignore` by mistake wipes your source code from tracking. This usually happens when someone copies a gitignore template from a different project type. Always review templates before applying them. a Node.js template might safely ignore `lib/` (where TypeScript compiles to), but in a Python project `lib/` is where your actual source lives.

Committing `.claude/settings.json` with Embedded Credentials

Claude Code settings files can accumulate API keys, MCP server URLs with embedded tokens, and file paths that expose your directory structure. Even if a key is rotated, its presence in git history creates a security audit trail problem. If you have already committed sensitive data, use `git filter-repo` or `BFG Repo Cleaner` to scrub history. simply deleting the file in a new commit is not enough.

## Forgetting Already-Tracked Files

Adding a pattern to `.gitignore` does not automatically un-track files that are already in the repository. If you accidentally committed `.claude/settings.json` and then added it to `.gitignore`, git will keep tracking it. You must explicitly remove it from tracking:

```bash
git rm --cached .claude/settings.json
git commit -m "stop tracking claude settings"
```

The `--cached` flag removes the file from git's index without deleting it from your working directory.

## Duplicate and Conflicting Patterns

Gitignore files read top to bottom, and negation patterns (`!pattern`) only un-ignore something that was ignored by an earlier rule. A common mistake is placing a negation before the rule it is meant to override:

```
Broken. negation comes before the ignore rule, so it has no effect
!.claude/settings.json
.claude/

Correct. negate after the broader ignore
.claude/
!.claude/settings.json
```

## Gitignore Templates for Different Project Types

Claude Code is used across a wide variety of project structures. Here are focused gitignore examples for the most common setups.

## Node.js / TypeScript Projects

```
Claude Code
.claude/
!.claude/settings.json
.claude/settings.local.json
.claude/skills/.cache/
.claude/skills/*.log

Dependencies
node_modules/

Build output
dist/
build/
.next/
.nuxt/
out/

Environment
.env
.env.local
.env.*.local

Logs
logs/
*.log
npm-debug.log*
yarn-debug.log*

Test coverage
coverage/
.nyc_output/

Lock files. DO NOT IGNORE
package-lock.json and yarn.lock should be committed
```

## Python Projects

```
Claude Code
.claude/
!.claude/settings.json
.claude/settings.local.json
.claude/skills/.cache/

Virtual environments
venv/
.venv/
env/
.env/

Byte-compiled files
__pycache__/
*.py[cod]
*.pyo
*.pyd

Distribution and packaging
dist/
build/
*.egg-info/
*.egg

Test coverage
.coverage
htmlcov/
.pytest_cache/

Environment variables
.env
.env.local

Jupyter notebooks. optional, include if notebooks are source
.ipynb_checkpoints/
```

## Jekyll / Static Site Projects

If you use Claude Code to generate or edit content for a Jekyll site (as this very guide does), your gitignore needs to account for both Jekyll's build output and Claude Code's working files:

```
Claude Code
.claude/
!.claude/settings.json
.claude/settings.local.json
.claude/skills/.cache/

Jekyll build output
_site/
.sass-cache/
.jekyll-cache/
.jekyll-metadata

Bundler
vendor/
.bundle/

Environment
.env

OS
.DS_Store
```

Note that `_site/` is always safe to gitignore for Jekyll projects. GitHub Pages rebuilds it on every push, so committing it adds churn without value.

## Integrating with Claude Skills Workflow

When using skills like `docx` for documentation or `xlsx` for data analysis, ensure your workflow generates to excluded directories. The [Claude xlsx skill spreadsheet automation tutorial](/claude-xlsx-skill-spreadsheet-automation-tutorial/) shows how to configure output paths to keep generated files out of source control. Configure skill output paths in your project structure:

```
project/
 src/
 .gitignore # Exclude output directories
 output/ # Skill-generated content (gitignored)
 reports/
 exports/
```

## Best Practices Summary

- Add Claude Code specific patterns to every project `.gitignore`
- Use a global gitignore for system-level exclusions
- Regularly audit your gitignore as you add new skills
- Never commit `.env` files or API credentials
- Keep skill cache and output directories excluded

Proper gitignore configuration is foundational to maintain clean repositories when working with Claude Code's powerful skill ecosystem. These patterns ensure your focus stays on code and content, not generated artifacts.

---

---



---

*Last verified: April 2026. If this approach no longer works, check [Mendeley Chrome Extension — Honest Review 2026](/mendeley-chrome-extension-review/) for updated steps.*

<div class="mastery-cta">

This site was built by 5 autonomous agents running in tmux while I was in Bali. 2,500 articles. Zero manual work. 100% quality gate pass rate.

The orchestration configs, sprint templates, and quality gates that made that possible are in the Zovo Lifetime bundle. Along with 16 CLAUDE.md templates and 80 tested prompts.

**[See how the pipeline works →](https://zovo.one/lifetime?utm_source=ccg&utm_medium=cta-skills&utm_campaign=claude-code-gitignore-best-practices)**

$99 once. I'm a solo dev in Da Nang. This is how I scale.

</div>

Related Reading


- [Configuration Reference](/configuration/). Complete Claude Code settings and configuration guide
- [Best Claude Code Skills to Install First in 2026](/best-claude-code-skills-to-install-first-2026/). Know which skills generate the most filesystem output so you can plan your gitignore patterns ahead of time
- [Claude MD Best Practices for Large Codebases](/claude-md-best-practices-for-large-codebases/). Learn how CLAUDE.md and project configuration files relate to what should and should not be committed
- [Claude Code for End-of-Day Commit Workflow](/claude-code-for-end-of-day-commit-workflow/). Build a daily commit habit that works cleanly with the gitignore patterns described here
- [Claude Skills Getting Started Hub](/getting-started-hub/). Start with foundational Claude Code setup including version control hygiene

Built by theluckystrike. More at [zovo.one](https://zovo.one)



**Get started →** Generate your project setup with our [Project Starter](/starter/).

## See Also

**Configure MCP →** Build your server config with our [MCP Config Generator](/mcp-config/).

**Try it:** Paste your error into our [Error Diagnostic](/diagnose/) for an instant fix.

- [.gitignore Not Respected by Claude Fix](/claude-code-gitignore-not-respected-fix-2026/)
