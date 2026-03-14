---
layout: default
title: "Claude Code Getting Started: Complete Beginner Guide"
description: "Everything you need to get started with Claude Code: installation, your first skill, understanding the interface, and essential workflows."
date: 2026-03-14
categories: [getting-started]
tags: [claude-skills, getting-started, claude-code, beginners, installation]
is_pillar: true
author: "Claude Skills Guide"
reviewed: true
score: 8
permalink: /getting-started-hub/
---

# Claude Code Getting Started: Complete Beginner Guide

Claude Code is Anthropic's command-line AI coding tool — a terminal-native assistant that reads your files, writes code, runs commands, and works through development problems alongside you. This hub is the single starting point for every beginner. It covers what Claude Code is, how to install it, what skills are, how to run your first session, and links to every getting-started article in the library.

## Table of Contents

1. [What Is Claude Code](#what-is-claude-code)
2. [Installation Guide](#installation-guide)
3. [Understanding Skills](#understanding-skills)
4. [Your First Session](#your-first-session)
5. [Essential Skills for Beginners](#essential-skills-for-beginners)
6. [Understanding Auto-Invocation](#understanding-auto-invocation)
7. [Security and Permissions](#security-and-permissions)
8. [Quick Reference Table](#quick-reference-table)
9. [Complete Article Index](#complete-article-index)

---

## What Is Claude Code

Claude Code is not a chatbot. It is Anthropic's AI coding assistant that runs in your terminal, directly inside your project. You launch it with `claude`, and it immediately has access to your file tree, your shell, and your development environment. It can read any file you give it permission to see, write and modify files, execute shell commands, and check their output — all within one interactive session.

The key distinction from web-based AI tools is integration. When you describe a change in Claude Code, Claude does not hand you a snippet to paste somewhere. It reads the actual file, makes the actual change, runs your test suite to confirm nothing broke, and reports back. The full loop — read, plan, write, verify — happens without you leaving the terminal.

What makes Claude Code genuinely different from other AI coding tools is the **skills system**. Skills are Markdown files that extend Claude's default behavior with domain-specific expertise. Instead of being a general assistant, Claude becomes a specialist for the exact task at hand: enforcing test-driven development, processing spreadsheets, generating design-system-compliant components, or maintaining session memory across days of work. Skills are composable, versioned, and shareable.

Claude Code works on macOS, Linux, and Windows (through WSL). It supports any editor, any stack, and any build system. There is no IDE plugin to install, no browser tab to switch to.

**Start here:** [What Is Claude Code and Why Developers Love It in 2026](/claude-skills-guide/what-is-claude-code-and-why-developers-love-it-2026/) — [Claude Skills Explained Simply for Non-Programmers](/claude-skills-guide/claude-skills-explained-simply-for-non-programmers/) — [Is Claude Code Worth It? An Honest Beginner Review 2026](/claude-skills-guide/is-claude-code-worth-it-honest-beginner-review-2026/)

---

## Installation Guide

Getting Claude Code running takes about five minutes. You need Node.js 18 or later, an Anthropic API key, and access to a terminal.

**Step 1 — Install via npm:**

```bash
npm install -g @anthropic-ai/claude-code
```

Verify the installation succeeded:

```bash
claude --version
```

If you see "command not found" after installing, close and reopen your terminal. On some systems you may need to add your global npm bin directory to your PATH.

**Step 2 — Authenticate:**

Get an API key from [console.anthropic.com](https://console.anthropic.com) under "API Keys", then run:

```bash
claude auth
```

Paste your key when prompted. The key is stored locally — you authenticate once and it persists.

**Step 3 — Navigate to a project:**

```bash
cd ~/your-project
claude
```

Claude Code opens an interactive session scoped to that directory. Claude can see everything inside the directory and its subdirectories.

**Platform-specific setup:** If you are on Windows, run Claude Code inside WSL2. See [Claude Code Skills in WSL2: A Practical Setup Guide](/claude-skills-guide/claude-code-skills-in-wsl2-windows-subsystem-linux-guide/) for a complete walkthrough. Docker users can also run Claude Code containerized — see [Claude Code with Docker: Container Setup Guide](/claude-skills-guide/claude-code-with-docker-container-skill-setup-guide/).

**Keeping skills in sync across machines:** [Claude Code Dotfiles Management and Skill Sync Workflow](/claude-skills-guide/claude-code-dotfiles-management-and-skill-sync-workflow/) covers how to keep your skill files in a dotfiles repo so they follow you everywhere.

**More installation and setup guides:**
- [Claude Code for Beginners: Getting Started 2026](/claude-skills-guide/claude-code-for-beginners-complete-getting-started-2026/)
- [Claude Code 2026: Skills and Hooks Feature Roundup](/claude-skills-guide/claude-code-2026-new-features-skills-and-hooks-roundup/)
- [Claude 4 Skills: New Features and Improvements Guide](/claude-skills-guide/claude-4-skills-improvements-and-new-features/)

---

## Understanding Skills

Skills are the feature that separates Claude Code from every other AI coding tool. A skill is a plain Markdown file stored in `~/.claude/skills/`. It has two parts: a YAML front matter block at the top that holds metadata, and a Markdown body below that contains the actual instructions Claude follows when the skill is active.

Here is a minimal skill file:

```yaml
---
name: my-skill
description: "What this skill does in one sentence"
---

You are a specialist for this type of work.

When invoked, always:
1. Do the first thing
2. Do the second thing
3. Report results clearly
```

The `name` field is how you invoke the skill manually: `/my-skill`. The `description` field is used by Claude to understand when a skill is relevant and when to activate it automatically.

Claude Code ships with a set of official built-in skills covering the most common workflows: `pdf` for document processing, `tdd` for test-driven development, `xlsx` for spreadsheet automation, `docx` for Word documents, `pptx` for presentations, `frontend-design` for UI components, and `supermemory` for persistent context across sessions.

Beyond official skills, there is a growing ecosystem of community-built skills for specific stacks, workflows, and domains. You can download them manually or contribute your own.

**Key things to understand about skills:**

Skills are loaded lazily. Claude reads the metadata header of every skill file at startup, but loads the full body only when a skill is invoked. This keeps sessions fast even when you have dozens of skills installed.

Skills are composable. You can combine two skills in a single session — the `tdd` skill and the `pdf` skill can both be active at once if your task involves generating a test report as a PDF.

Skills are scoped. A skill's instructions apply only while the skill is active in the current session. Different projects can use different skill configurations.

**Go deeper:**
- [Skill MD File Format Explained With Examples Guide](/claude-skills-guide/skill-md-file-format-explained-with-examples/)
- [Claude Skill .md File Format: Full Specification Guide](/claude-skills-guide/claude-skill-md-format-complete-specification-guide/)
- [How to Write a Skill MD File for Claude Code](/claude-skills-guide/how-to-write-a-skill-md-file-for-claude-code/)
- [Claude Skills Directory: Where to Find Skills 2026](/claude-skills-guide/claude-skills-directory-where-to-find-skills/)
- [Best Claude Code Skills to Install First in 2026](/claude-skills-guide/best-claude-code-skills-to-install-first-2026/)
- [Optimal Skill File Size and Complexity Guidelines](/claude-skills-guide/optimal-skill-file-size-and-complexity-guidelines/)
- [Claude Skill Lazy Loading: Token Savings Explained](/claude-skills-guide/claude-skill-lazy-loading-token-savings-explained-deep-dive/)

---

## Your First Session

Once Claude Code is installed and authenticated, here is a practical walkthrough for your first real session.

**Open Claude Code in your project:**

```bash
cd ~/your-project
claude
```

Claude confirms the project directory it has scoped to and is ready for input.

**Try a simple exploration task first:**

Ask Claude to describe the project structure:

```
Summarize this codebase: what it does, the main entry points, and any areas that look like they need attention.
```

Claude reads your files and responds with a structured summary. This is a good way to verify it has access to your code and that the session is working.

**Make a concrete change:**

Ask for something specific:

```
Add input validation to the user registration endpoint. Check that email is a valid format and password is at least 8 characters. Return a 400 with a descriptive error message if validation fails.
```

Claude reads the relevant file, writes the validation logic, and may run your test suite to confirm the change does not break existing tests.

**Invoke your first skill:**

Load the TDD skill and ask for tests:

```
/tdd write unit tests for the validation logic you just added
```

Claude generates test cases covering the happy path, invalid email format, and short password edge cases — following test-driven development conventions enforced by the skill.

**End the session:**

Type `/exit` or press Ctrl+C.

**Tutorials for your first session:**
- [Claude Code for Beginners: Getting Started 2026](/claude-skills-guide/claude-code-for-beginners-complete-getting-started-2026/)
- [Full Stack Web App with Claude Skills Step-by-Step](/claude-skills-guide/full-stack-web-app-with-claude-skills-step-by-step/)
- [How to Build a SaaS MVP with Claude Code Skills Guide](/claude-skills-guide/how-to-build-saas-mvp-with-claude-code-skills-guide/)
- [Build a Personal AI Assistant with Claude Skills Guide](/claude-skills-guide/build-personal-ai-assistant-with-claude-skills-guide/)

---

## Essential Skills for Beginners

These are the skills worth understanding first. Each covers a common development workflow and demonstrates how skills change what Claude Code can do.

### PDF Skill

The `pdf` skill is the best demonstration of what a skill actually does. Without it, Claude can discuss PDF content you paste into the chat. With it, Claude becomes a full document processing engine — extracting tables, reading multi-column layouts, filling forms, and generating new PDF documents from structured data.

Invoke it explicitly:

```
/pdf extract all tables from Q3-financial-report.pdf as markdown
```

```
/pdf merge invoices/*.pdf into one document ordered by date
```

The pdf skill handles scanned documents (with OCR), form fields, and multi-page layouts. For developers processing contracts, reports, or specifications in bulk, it replaces entire manual workflows.

**Read more:** [Best Claude Code Skills to Install First in 2026](/claude-skills-guide/best-claude-code-skills-to-install-first-2026/)

### TDD Skill

The `tdd` skill enforces test-driven development: write a failing test first, write the minimum implementation to pass it, refactor. It works with pytest, Jest, Vitest, and Bun Test.

```
/tdd write pytest tests for the authentication module
```

```
/tdd given this failing Jest test, implement UserService.authenticate() to make it pass
```

The skill does not just generate tests — it helps you think through edge cases you would miss on your own: expired sessions, concurrent logins, malformed inputs. For any developer building anything that needs to work reliably, TDD skill is the one to add first.

**Read more:** [Claude TDD Skill: Test-Driven Development Guide (2026)](/claude-skills-guide/claude-tdd-skill-test-driven-development-workflow/) — [Automated Testing Pipeline with Claude TDD Skill (2026)](/claude-skills-guide/automated-testing-pipeline-with-claude-tdd-skill-2026/)

### Frontend Design Skill

The `frontend-design` skill specializes in building UI components that match a design system. It understands responsive layout, accessibility requirements (ARIA attributes, semantic HTML), and CSS design tokens. It works with React, Vue, Svelte, and vanilla JavaScript.

```
/frontend-design create a responsive navigation header with logo and mobile hamburger menu, following the design tokens in src/styles/tokens.css
```

The skill does not just generate generic markup — it reads your actual design tokens and applies them, keeping output consistent with your existing system.

**Read more:** [Claude Frontend Design Skill Review and Tutorial](/claude-skills-guide/claude-frontend-design-skill-review-and-tutorial/) — [Best Claude Code Skills for Frontend Development](/claude-skills-guide/best-claude-code-skills-for-frontend-development/)

### XLSX Skill

The `xlsx` skill automates spreadsheet work: reading data from Excel files, generating new sheets, building formulas, and transforming data between formats.

```
/xlsx read sales-data.xlsx and generate a pivot table by region and product category
```

```
/xlsx create an expense report template with SUM formulas and conditional formatting for over-budget rows
```

For developers or analysts who spend time manually working with spreadsheets, the xlsx skill eliminates the most repetitive parts of that work.

**Read more:** [Claude /xlsx Skill: Spreadsheet Automation Guide](/claude-skills-guide/claude-xlsx-skill-spreadsheet-automation-tutorial/)

### SuperMemory Skill

The `supermemory` skill gives Claude persistent memory across sessions. By default, Claude Code starts fresh each session with no recollection of previous work. SuperMemory writes structured notes to disk and reloads them at session start, giving Claude context about your project, your preferences, and previous decisions.

```
/supermemory remember that we use the repository pattern in the services layer and all error handling goes through the ErrorService class
```

On your next session, Claude already knows this. You spend less time re-explaining context and more time building.

**Read more:** [Claude SuperMemory Skill: Persistent Context Guide 2026](/claude-skills-guide/claude-supermemory-skill-persistent-context-explained/)

**More essential skill guides:**
- [Best Claude Skills for Developers in 2026](/claude-skills-guide/best-claude-skills-for-developers-2026/)
- [Best Claude Skills for Data Analysis in 2026](/claude-skills-guide/best-claude-skills-for-data-analysis/)
- [Best Claude Skills for DevOps and Deployment](/claude-skills-guide/best-claude-skills-for-devops-and-deployment/)
- [Best Claude Skills for Writing and Content Creation](/claude-skills-guide/best-claude-skills-for-writing-and-content-creation/)
- [Best Claude Skills for Solo Developers and Freelancers](/claude-skills-guide/best-claude-skills-for-solo-developers-and-freelancers/)
- [Claude Code Skills for Backend Developers: Node.js and Python](/claude-skills-guide/claude-code-skills-for-backend-developers-node-and-python/)

---

## Understanding Auto-Invocation

Claude Code skills can be invoked in two ways: explicitly with a slash command (`/skill-name`), or automatically when Claude detects that the context matches a skill's trigger conditions.

Auto-invocation is controlled by the `triggers` block in a skill's front matter. When you send a message, Claude checks whether any installed skill has a trigger phrase that matches what you are asking. If there is a match, Claude loads that skill's body and applies its instructions without you typing anything extra.

For example, a skill whose description mentions PDF extraction will activate automatically when you ask "can you read this PDF file and pull out the invoice totals?" You never type `/pdf`. Claude detects the match and loads the skill.

Auto-invocation keeps sessions fast for common tasks. For less common skills, or when you want precision control over which skill is active, explicit invocation with the slash command is more reliable.

**Important:** auto-invocation only works when the skill is installed in `~/.claude/skills/`. If a skill is not installed, no trigger matching happens for it.

**When auto-invocation fails:** there are several common reasons a skill does not fire automatically — trigger phrases that are too narrow, competing triggers across multiple skills, or context that does not strongly match. The troubleshooting guides below cover each failure mode.

**Auto-invocation guides:**
- [Claude Skills Auto Invocation: How It Works](/claude-skills-guide/claude-skills-auto-invocation-how-it-works/)
- [How Claude Skills Auto Invocation Works](/claude-skills-guide/how-claude-skills-auto-invocation-actually-works-deep-dive/)
- [Claude Skill Not Triggering: Troubleshoot Guide (2026)](/claude-skills-guide/claude-skill-not-triggering-automatically-troubleshoot/)
- [Why Does Claude Skill Auto Invocation Fail Intermittently?](/claude-skills-guide/why-does-claude-skill-auto-invocation-fail-intermittently/)
- [How Do I Know Which Claude Skill Is Currently Active?](/claude-skills-guide/how-do-i-know-which-claude-skill-is-currently-active/)
- [Claude Skill Not Showing Up? Fix Guide](/claude-skills-guide/why-is-my-claude-skill-not-showing-up-fix-guide/)

---

## Security and Permissions

Claude Code is an agentic tool. It can read files, execute shell commands, write code, and make network requests. Understanding the permissions model is important before using it on real projects.

**The layered architecture:**

Claude Code permissions work in layers:

```
Session-level settings
  └── Skill-level overrides
        └── Hook-level enforcement
              └── Tool-level capabilities
```

Each layer can only restrict — never expand — the permissions of the layer above it. A skill cannot grant itself access to tools the session has disabled.

**Default tool access:** By default, all built-in tools are available — `Read`, `Write`, `Bash`, `WebFetch`, `WebSearch`, and `Glob`. This is intentional for usability. You restrict access via `.claude/settings.json`.

**Restricting tool access:**

```json
{
  "permissions": {
    "allow": ["Read(**)", "Glob(**)", "Bash(git *)"],
    "deny": ["WebFetch(*)", "WebSearch(*)"]
  }
}
```

This configuration allows Claude to read files and run git commands only, with no network access.

**Hooks for enforcement:** Claude Code's hooks system lets you intercept any tool call before it executes. You can log, inspect, modify, or block any action — giving you audit logs and hard guardrails without having to trust Claude's judgment entirely.

**Common permission errors and fixes:**
- [Claude Code Permissions Model and Security Guide](/claude-skills-guide/claude-code-permissions-model-security-guide-2026/)
- [Claude Code Skill Permission Denied Error Fix 2026](/claude-skills-guide/claude-code-skill-permission-denied-error-fix-2026/)
- [Claude Code Permission Denied When Executing Skill Commands](/claude-skills-guide/claude-code-permission-denied-when-executing-skill-commands/)
- [Claude Code Skill Permission Scope Error: Fix Guide](/claude-skills-guide/claude-code-skill-permission-scope-error-explained/)
- [How Do I Limit What a Claude Skill Can Access on Disk](/claude-skills-guide/how-do-i-limit-what-a-claude-skill-can-access-on-disk/)
- [Claude Skills Access Control and Permissions Enterprise Guide](/claude-skills-guide/claude-skills-access-control-and-permissions-enterprise/)
- [Claude Skills Governance Security Audit Checklist](/claude-skills-guide/claude-skills-governance-security-audit-checklist/)

---

## Quick Reference Table

| Topic | Article | Difficulty |
|-------|---------|------------|
| What Claude Code is | [What Is Claude Code and Why Developers Love It](/claude-skills-guide/what-is-claude-code-and-why-developers-love-it-2026/) | Beginner |
| Plain-language skills intro | [Claude Skills Explained Simply for Non-Programmers](/claude-skills-guide/claude-skills-explained-simply-for-non-programmers/) | Beginner |
| Full beginner walkthrough | [Claude Code for Beginners: Getting Started 2026](/claude-skills-guide/claude-code-for-beginners-complete-getting-started-2026/) | Beginner |
| Honest pros/cons review | [Is Claude Code Worth It? An Honest Beginner Review](/claude-skills-guide/is-claude-code-worth-it-honest-beginner-review-2026/) | Beginner |
| Skills to install first | [Best Claude Code Skills to Install First in 2026](/claude-skills-guide/best-claude-code-skills-to-install-first-2026/) | Beginner |
| Where to find skills | [Claude Skills Directory: Where to Find Skills](/claude-skills-guide/claude-skills-directory-where-to-find-skills/) | Beginner |
| Skill file format | [Skill MD File Format Explained With Examples](/claude-skills-guide/skill-md-file-format-explained-with-examples/) | Intermediate |
| Write your first skill | [How to Write a Skill MD File for Claude Code](/claude-skills-guide/how-to-write-a-skill-md-file-for-claude-code/) | Intermediate |
| Full skill specification | [Claude Skill .md File Format: Full Specification Guide](/claude-skills-guide/claude-skill-md-format-complete-specification-guide/) | Intermediate |
| Auto-invocation explained | [Claude Skills Auto Invocation: How It Works](/claude-skills-guide/claude-skills-auto-invocation-how-it-works/) | Intermediate |
| Auto-invocation internals | [How Claude Skills Auto Invocation Works (Deep Dive)](/claude-skills-guide/how-claude-skills-auto-invocation-actually-works-deep-dive/) | Intermediate |
| Permissions and security | [Claude Code Permissions Model and Security Guide](/claude-skills-guide/claude-code-permissions-model-security-guide-2026/) | Intermediate |
| TDD skill guide | [Claude TDD Skill: Test-Driven Development Guide](/claude-skills-guide/claude-tdd-skill-test-driven-development-workflow/) | Intermediate |
| Frontend design skill | [Claude Frontend Design Skill Review and Tutorial](/claude-skills-guide/claude-frontend-design-skill-review-and-tutorial/) | Intermediate |
| Spreadsheet automation | [Claude /xlsx Skill: Spreadsheet Automation Guide](/claude-skills-guide/claude-xlsx-skill-spreadsheet-automation-tutorial/) | Intermediate |
| Persistent memory | [Claude SuperMemory Skill: Persistent Context Guide](/claude-skills-guide/claude-supermemory-skill-persistent-context-explained/) | Intermediate |
| Skill not triggering | [Claude Skill Not Triggering: Troubleshoot Guide](/claude-skills-guide/claude-skill-not-triggering-automatically-troubleshoot/) | Intermediate |
| YAML parsing errors | [Claude Skill YAML Front Matter Parsing Error Fix](/claude-skills-guide/claude-skill-yaml-front-matter-parsing-error-fix/) | Intermediate |
| Token optimization | [Claude Skills Token Optimization: Reduce API Costs](/claude-skills-guide/claude-skills-token-optimization-reduce-api-costs/) | Intermediate |
| Sharing skills with a team | [How to Share Claude Skills with Your Team](/claude-skills-guide/how-to-share-claude-skills-with-your-team/) | Intermediate |
| WSL2 setup | [Claude Code Skills in WSL2: A Practical Setup Guide](/claude-skills-guide/claude-code-skills-in-wsl2-windows-subsystem-linux-guide/) | Intermediate |
| Docker integration | [Claude Code with Docker: Container Setup Guide](/claude-skills-guide/claude-code-with-docker-container-skill-setup-guide/) | Intermediate |
| Context window management | [Claude Skills Context Window Management Best Practices](/claude-skills-guide/claude-skills-context-window-management-best-practices/) | Intermediate |
| Skill versioning | [Claude Skill Versioning: Semver Best Practices](/claude-skills-guide/claude-skill-versioning-semver-best-practices/) | Advanced |
| Enterprise skill structure | [Structuring Claude Skills for Large Enterprise Codebases](/claude-skills-guide/structuring-claude-skills-for-large-enterprise-codebases/) | Advanced |
| Multi-agent error recovery | [Claude Code Multi-Agent Error Recovery Strategies](/claude-skills-guide/claude-code-multi-agent-error-recovery-strategies/) | Advanced |
| Production AI agents | [Building Production AI Agents with Claude Skills in 2026](/claude-skills-guide/building-production-ai-agents-with-claude-skills-2026/) | Advanced |

---

## Complete Article Index

The articles below cover every getting-started topic in the library, organized by sub-topic. Use this as a complete map for any question about Claude Code fundamentals.

### What Is Claude Code

Articles explaining the platform, its purpose, and why developers choose it.

- [What Is Claude Code and Why Developers Love It in 2026](/claude-skills-guide/what-is-claude-code-and-why-developers-love-it-2026/)
- [Claude Skills Explained Simply for Non-Programmers 2026](/claude-skills-guide/claude-skills-explained-simply-for-non-programmers/)
- [Claude Code for Beginners: Getting Started 2026](/claude-skills-guide/claude-code-for-beginners-complete-getting-started-2026/)
- [Is Claude Code Worth It? An Honest Beginner Review 2026](/claude-skills-guide/is-claude-code-worth-it-honest-beginner-review-2026/)
- [Claude Code 2026: Skills and Hooks Feature Roundup](/claude-skills-guide/claude-code-2026-new-features-skills-and-hooks-roundup/)
- [Claude 4 Skills: New Features and Improvements Guide](/claude-skills-guide/claude-4-skills-improvements-and-new-features/)
- [Can You Use Claude Skills Without a Claude Max Subscription?](/claude-skills-guide/can-you-use-claude-skills-without-a-claude-max-subscription/)
- [AI Agent Skills Standardization Efforts 2026](/claude-skills-guide/ai-agent-skills-standardization-efforts-2026/)
- [The Future of AI Agent Skills Beyond Claude Code in 2026](/claude-skills-guide/future-of-ai-agent-skills-beyond-claude-code-2026/)
- [Claude Code Skills Roadmap 2026: What Is Coming](/claude-skills-guide/claude-code-skills-roadmap-2026-what-is-coming/)
- [Will Claude Skills Replace Traditional IDE Plugins?](/claude-skills-guide/will-claude-skills-replace-traditional-ide-plugins/)
- [Will Claude Skills Support Voice Interfaces in 2026?](/claude-skills-guide/will-claude-skills-support-voice-interfaces-2026/)
- [Claude Skills Ecosystem: Predictions for the Next 12 Months](/claude-skills-guide/claude-skills-ecosystem-predictions-next-12-months/)
- [Open Source Claude Skills Ecosystem Outlook 2026](/claude-skills-guide/open-source-claude-skills-ecosystem-outlook-2026/)

### Installation and Environment Setup

Getting Claude Code running on different platforms and configurations.

- [Claude Code Skills in WSL2: A Practical Setup Guide](/claude-skills-guide/claude-code-skills-in-wsl2-windows-subsystem-linux-guide/)
- [Claude Code with Docker: Container Setup Guide](/claude-skills-guide/claude-code-with-docker-container-skill-setup-guide/)
- [Claude Code Dotfiles Management and Skill Sync Workflow](/claude-skills-guide/claude-code-dotfiles-management-and-skill-sync-workflow/)
- [Claude Code Worktrees and Skills Isolation Guide](/claude-skills-guide/claude-code-worktrees-and-skills-isolation-explained/)
- [How Do I Use Claude Skills in an Air-Gapped Environment](/claude-skills-guide/how-do-i-use-claude-skills-in-an-air-gapped-environment/)
- [Claude Code LM Studio Local Model Skill Integration Guide](/claude-skills-guide/claude-code-lm-studio-local-model-skill-integration-guide/)
- [Claude Skills with Local LLM Ollama Self-Hosted Guide](/claude-skills-guide/claude-skills-with-local-llm-ollama-self-hosted-guide/)
- [How Do I Set Environment Variables for a Claude Skill](/claude-skills-guide/how-do-i-set-environment-variables-for-a-claude-skill/)
- [Claude Code Container Debugging: Docker Logs Workflow Guide](/claude-skills-guide/claude-code-container-debugging-docker-logs-workflow-guide/)

### Skill File Format and Structure

Understanding and writing skill.md files from first principles.

- [Skill MD File Format Explained With Examples Guide](/claude-skills-guide/skill-md-file-format-explained-with-examples/)
- [Claude Skill .md File Format: Full Specification Guide](/claude-skills-guide/claude-skill-md-format-complete-specification-guide/)
- [How to Write a Skill MD File for Claude Code](/claude-skills-guide/how-to-write-a-skill-md-file-for-claude-code/)
- [Optimal Skill File Size and Complexity Guidelines](/claude-skills-guide/optimal-skill-file-size-and-complexity-guidelines/)
- [What Is the Best File Structure for a Complex Claude Skill](/claude-skills-guide/what-is-the-best-file-structure-for-a-complex-claude-skill/)
- [What Is the Best Way to Name Claude Skill Files Consistently](/claude-skills-guide/what-is-the-best-way-to-name-claude-skill-files-consistently/)
- [When to Split One Claude Skill Into Multiple Files](/claude-skills-guide/when-to-split-one-claude-skill-into-multiple-files/)
- [Claude Skill Dependency Injection Patterns](/claude-skills-guide/claude-skill-dependency-injection-patterns/)
- [Claude Skill Inheritance and Composition Patterns](/claude-skills-guide/claude-skill-inheritance-and-composition-patterns/)
- [Claude Skill State Machine Design Patterns](/claude-skills-guide/claude-skill-state-machine-design-patterns/)
- [Claude Skill Versioning: Semver Best Practices](/claude-skills-guide/claude-skill-versioning-semver-best-practices/)
- [How to Optimize Claude Skill Prompts for Accuracy](/claude-skills-guide/how-to-optimize-claude-skill-prompts-for-accuracy/)
- [Claude Skill Prompt Compression Techniques](/claude-skills-guide/claude-skill-prompt-compression-techniques/)
- [Advanced Claude Skills: Tool Use Patterns 2026](/claude-skills-guide/advanced-claude-skills-with-tool-use-and-function-calling/)
- [Extended Thinking + Claude Skills: Integration Guide](/claude-skills-guide/claude-code-extended-thinking-skills-integration-guide/)

### Discovering and Managing Skills

Finding, installing, and organizing skills across projects.

- [Claude Skills Directory: Where to Find Skills 2026](/claude-skills-guide/claude-skills-directory-where-to-find-skills/)
- [Best Claude Code Skills to Install First in 2026](/claude-skills-guide/best-claude-code-skills-to-install-first-2026/)
- [How to Contribute Claude Skills to Open Source](/claude-skills-guide/how-to-contribute-claude-skills-to-open-source/)
- [Claude Skills for Publishers: A Practical Guide](/claude-skills-guide/claude-skills-marketplace-skillsmp-guide-for-publishers/)
- [How Do I Share Claude Skills Across Multiple Projects](/claude-skills-guide/how-do-i-share-claude-skills-across-multiple-projects/)
- [How to Share Claude Skills with Your Team](/claude-skills-guide/how-to-share-claude-skills-with-your-team/)
- [How Do I Make a Claude Skill Available Organization Wide](/claude-skills-guide/how-do-i-make-a-claude-skill-available-organization-wide/)
- [Shared Claude Skills Across Monorepo Multiple Packages](/claude-skills-guide/shared-claude-skills-across-monorepo-multiple-packages/)
- [What Is the Best Way to Organize Claude Skills in a Monorepo](/claude-skills-guide/what-is-the-best-way-to-organize-claude-skills-in-a-monorepo/)
- [Structuring Claude Skills for Large Enterprise Codebases](/claude-skills-guide/structuring-claude-skills-for-large-enterprise-codebases/)
- [Claude Skills Change Management: Rolling Out to Teams](/claude-skills-guide/claude-skills-change-management-rolling-out-to-teams/)
- [Claude Skills Onboarding for New Engineering Team Members](/claude-skills-guide/claude-skills-onboarding-new-engineering-team-members/)
- [How Do I Test a Claude Skill Before Deploying to Team](/claude-skills-guide/how-do-i-test-a-claude-skill-before-deploying-to-team/)

### Auto-Invocation

How auto-invocation works, how to configure it, and how to fix it when it does not.

- [Claude Skills Auto Invocation: How It Works](/claude-skills-guide/claude-skills-auto-invocation-how-it-works/)
- [How Claude Skills Auto Invocation Works](/claude-skills-guide/how-claude-skills-auto-invocation-actually-works-deep-dive/)
- [Claude Skill Not Triggering: Troubleshoot Guide (2026)](/claude-skills-guide/claude-skill-not-triggering-automatically-troubleshoot/)
- [Why Does Claude Skill Auto Invocation Fail Intermittently?](/claude-skills-guide/why-does-claude-skill-auto-invocation-fail-intermittently/)
- [How Do I Know Which Claude Skill Is Currently Active?](/claude-skills-guide/how-do-i-know-which-claude-skill-is-currently-active/)
- [How Do I Combine Two Claude Skills in One Workflow](/claude-skills-guide/how-do-i-combine-two-claude-skills-in-one-workflow/)

### Security and Permissions

Understanding and configuring Claude Code's permission model.

- [Claude Code Permissions Model and Security Guide](/claude-skills-guide/claude-code-permissions-model-security-guide-2026/)
- [Claude Code Skill Permission Denied Error Fix 2026](/claude-skills-guide/claude-code-skill-permission-denied-error-fix-2026/)
- [Claude Code Permission Denied When Executing Skill Commands](/claude-skills-guide/claude-code-permission-denied-when-executing-skill-commands/)
- [Claude Code Skill Permission Scope Error: Fix Guide](/claude-skills-guide/claude-code-skill-permission-scope-error-explained/)
- [How Do I Limit What a Claude Skill Can Access on Disk](/claude-skills-guide/how-do-i-limit-what-a-claude-skill-can-access-on-disk/)
- [Claude Skills Access Control and Permissions Enterprise Guide](/claude-skills-guide/claude-skills-access-control-and-permissions-enterprise/)
- [Claude Skills Governance Security Audit Checklist](/claude-skills-guide/claude-skills-governance-security-audit-checklist/)
- [Claude Skills for Enterprise Security & Compliance Guide](/claude-skills-guide/claude-skills-for-enterprise-security-compliance-guide/)
- [Claude Skills Compliance SOC2 ISO27001 Guide](/claude-skills-guide/claude-skills-compliance-soc2-iso27001-guide/)
- [Claude Skills Disaster Recovery and Backup Strategies](/claude-skills-guide/claude-skills-disaster-recovery-and-backup-strategies/)

### Troubleshooting Errors

Fixing the most common errors you will encounter with Claude Code skills.

- [Claude Skill Not Showing Up? Fix Guide](/claude-skills-guide/why-is-my-claude-skill-not-showing-up-fix-guide/)
- [Claude Code Crashes When Loading Skill: Debug Guide](/claude-skills-guide/claude-code-crashes-when-loading-skill-debug-steps/)
- [Claude Skill YAML Front Matter Parsing Error Fix](/claude-skills-guide/claude-skill-yaml-front-matter-parsing-error-fix/)
- [Claude Code Skill Invalid YAML Syntax Error How to Debug](/claude-skills-guide/claude-code-skill-invalid-yaml-syntax-error-how-to-debug/)
- [Claude Code Skills Context Window Exceeded Error Fix](/claude-skills-guide/claude-code-skills-context-window-exceeded-error-fix/)
- [Claude Code Context Window Exceeded After Loading Skill Fix](/claude-skills-guide/claude-code-context-window-exceeded-after-loading-skill-fix/)
- [Fix Claude Code Skill Tool Not Found Error (2026)](/claude-skills-guide/claude-code-skill-tool-not-found-error-solution/)
- [Claude Code Skill Not Found in Skills Directory — How to Fix](/claude-skills-guide/claude-code-skill-not-found-in-skills-directory-how-to-fix/)
- [Claude Code Skill Exceeded Maximum Output Length Error Fix](/claude-skills-guide/claude-code-skill-exceeded-maximum-output-length-error-fix/)
- [Claude Code Skill Memory Limit Exceeded Process Killed Fix](/claude-skills-guide/claude-code-skill-memory-limit-exceeded-process-killed-fix/)
- [Claude Code Skill Timeout Error: How to Increase the Limit](/claude-skills-guide/claude-code-skill-timeout-error-how-to-increase-the-limit/)
- [Claude Code Skill Circular Dependency Detected Error Fix](/claude-skills-guide/claude-code-skill-circular-dependency-detected-error-fix/)
- [Claude Code Skill Conflicts with MCP Server Resolution Guide](/claude-skills-guide/claude-code-skill-conflicts-with-mcp-server-resolution-guide/)
- [Claude Code Skill Output Formatting: Fix Guide](/claude-skills-guide/claude-code-skill-output-formatting-broken-fix/)
- [Claude Skill Not Saving State Between Sessions Fix](/claude-skills-guide/claude-skill-not-saving-state-between-sessions-fix/)
- [How to Fix Claude Skill Infinite Loop Issues](/claude-skills-guide/how-to-fix-claude-skill-infinite-loop-issue/)
- [How Do I Debug a Claude Skill That Silently Fails](/claude-skills-guide/how-do-i-debug-a-claude-skill-that-silently-fails/)
- [Why Does Claude Code Ignore My Skill MD File Entirely](/claude-skills-guide/why-does-claude-code-ignore-my-skill-md-file-entirely/)
- [Why Does Claude Code Not Recognize My Custom Skill Name?](/claude-skills-guide/why-does-claude-code-not-recognize-my-custom-skill-name/)
- [Why Does Claude Code Reject My Skill Instruction Block](/claude-skills-guide/why-does-claude-code-reject-my-skill-instruction-block/)
- [Why Does Claude Code Skill Take So Long to Initialize?](/claude-skills-guide/why-does-claude-code-skill-take-so-long-to-initialize/)
- [Why Does Claude Skill Produce Different Output Each Run](/claude-skills-guide/why-does-claude-skill-produce-different-output-each-run/)
- [Why Does My Claude Skill Work Locally But Fail in CI?](/claude-skills-guide/why-does-my-claude-skill-work-locally-but-fail-in-ci/)
- [Claude Skills Slow Performance: Speed Up Guide](/claude-skills-guide/claude-skills-slow-performance-speed-up-guide/)
- [How Do I Rollback a Bad Claude Skill Update Safely](/claude-skills-guide/how-do-i-rollback-a-bad-claude-skill-update-safely/)

### Performance, Tokens, and Optimization

Making Claude Code faster and more cost-efficient.

- [Claude Skills Token Optimization: Reduce API Costs Guide](/claude-skills-guide/claude-skills-token-optimization-reduce-api-costs/)
- [Claude Skill Lazy Loading: Token Savings Explained](/claude-skills-guide/claude-skill-lazy-loading-token-savings-explained-deep-dive/)
- [Claude Skill Token Usage Profiling and Optimization](/claude-skills-guide/claude-skill-token-usage-profiling-and-optimization/)
- [Claude Skill Prompt Compression Techniques](/claude-skills-guide/claude-skill-prompt-compression-techniques/)
- [Claude Skills Context Window Management Best Practices](/claude-skills-guide/claude-skills-context-window-management-best-practices/)
- [Claude Code Response Latency Optimization with Skills](/claude-skills-guide/claude-code-response-latency-optimization-with-skills/)
- [Claude Code Skill Output Streaming Optimization](/claude-skills-guide/claude-code-skill-output-streaming-optimization/)
- [Caching Strategies for Claude Code Skill Outputs](/claude-skills-guide/caching-strategies-for-claude-code-skill-outputs/)
- [Rate Limit Management for Skill-Intensive Claude Code Workflows](/claude-skills-guide/rate-limit-management-claude-code-skill-intensive-workflows/)
- [Benchmarking Claude Code Skills Performance Guide](/claude-skills-guide/benchmarking-claude-code-skills-performance-guide/)
- [Measuring Claude Code Skill Efficiency Metrics](/claude-skills-guide/measuring-claude-code-skill-efficiency-metrics/)
- [How Do I See Claude Skill Usage and Token Costs Breakdown](/claude-skills-guide/how-do-i-see-claude-skill-usage-and-token-costs-breakdown/)

### Memory and Context

Persistent memory, session state, and context architecture.

- [Claude SuperMemory Skill: Persistent Context Guide 2026](/claude-skills-guide/claude-supermemory-skill-persistent-context-explained/)
- [Claude Skills Memory and Context Architecture Guide](/claude-skills-guide/claude-skills-memory-and-context-architecture-explained/)
- [Claude Skill Not Saving State Between Sessions Fix](/claude-skills-guide/claude-skill-not-saving-state-between-sessions-fix/)
- [Building Stateful Agents with Claude Skills Guide](/claude-skills-guide/building-stateful-agents-with-claude-skills-guide/)

### Skills by Developer Role

Role-specific skill recommendations and configurations.

- [Best Claude Skills for Developers in 2026](/claude-skills-guide/best-claude-skills-for-developers-2026/)
- [Claude Code Skills for Backend Developers: Node.js and Python](/claude-skills-guide/claude-code-skills-for-backend-developers-node-and-python/)
- [Best Claude Code Skills for Frontend Development](/claude-skills-guide/best-claude-code-skills-for-frontend-development/)
- [Best Claude Skills for DevOps and Deployment](/claude-skills-guide/best-claude-skills-for-devops-and-deployment/)
- [Best Claude Skills for Data Analysis in 2026](/claude-skills-guide/best-claude-skills-for-data-analysis/)
- [Claude Code Skills for Data Engineers Automating Pipelines](/claude-skills-guide/claude-code-skills-for-data-engineers-automating-pipelines/)
- [Claude Code Skills for QA Engineers Automating Test Suites](/claude-skills-guide/claude-code-skills-for-qa-engineers-automating-test-suites/)
- [Claude Code Skills for Security Engineers and Pentesters](/claude-skills-guide/claude-code-skills-for-security-engineers-and-pentesters/)
- [Claude Code Skills for Enterprise Architects Governance](/claude-skills-guide/claude-code-skills-for-enterprise-architects-governance/)
- [Claude Code Skills for Product Engineers Building Full Stack](/claude-skills-guide/claude-code-skills-for-product-engineers-building-full-stack/)
- [Best Claude Skills for Solo Developers and Freelancers](/claude-skills-guide/best-claude-skills-for-solo-developers-and-freelancers/)
- [Claude Skills for Startup Founders and Solopreneurs 2026](/claude-skills-guide/claude-skills-for-startup-founders-and-solopreneurs/)
- [Best Claude Skills for Writing and Content Creation](/claude-skills-guide/best-claude-skills-for-writing-and-content-creation/)

### Skills by Technology Stack

Stack-specific skill guides for common platforms and languages.

- [Claude TDD Skill: Test-Driven Development Guide (2026)](/claude-skills-guide/claude-tdd-skill-test-driven-development-workflow/)
- [Automated Testing Pipeline with Claude TDD Skill (2026)](/claude-skills-guide/automated-testing-pipeline-with-claude-tdd-skill-2026/)
- [Claude Code Pytest Fixtures Parametrize Workflow Tutorial 2026](/claude-skills-guide/claude-code-pytest-fixtures-parametrize-workflow-tutorial-20/)
- [Claude Frontend Design Skill Review and Tutorial](/claude-skills-guide/claude-frontend-design-skill-review-and-tutorial/)
- [Claude /xlsx Skill: Spreadsheet Automation Guide](/claude-skills-guide/claude-xlsx-skill-spreadsheet-automation-tutorial/)
- [Claude Skills for Financial Modeling: Excel Alternative](/claude-skills-guide/claude-skills-for-financial-modeling-excel-alternative/)
- [Claude Code Express Middleware Error Handling Patterns Guide](/claude-skills-guide/claude-code-express-middleware-error-handling-patterns-guide/)
- [Claude Code Skills for Terraform IaC: Complete Guide](/claude-skills-guide/claude-code-skills-for-infrastructure-as-code-terraform/)
- [Claude Code Skills for Kubernetes Operator Development](/claude-skills-guide/claude-code-skills-for-kubernetes-operator-development/)
- [Claude Skills for GraphQL Schema Design and Testing](/claude-skills-guide/claude-skills-for-graphql-schema-design-and-testing/)
- [Claude Skills for Data Science and Jupyter: 2026 Guide](/claude-skills-guide/claude-skills-for-data-science-and-jupyter-notebooks/)
- [Claude Code Skills for Scientific Python: NumPy and SciPy](/claude-skills-guide/claude-code-skills-for-scientific-python-numpy-scipy/)
- [Claude Skills for WebSocket Realtime App Development](/claude-skills-guide/claude-skills-for-websocket-realtime-app-development/)
- [Claude Skills for Solidity Smart Contract Development](/claude-skills-guide/claude-skills-for-solidity-smart-contract-development/)
- [Claude Code Skills for Hardware Description Language VHDL](/claude-skills-guide/claude-code-skills-for-hardware-description-language-vhdl/)
- [Claude Skills for Embedded Systems, IoT, and Firmware Development](/claude-skills-guide/claude-skills-for-embedded-systems-iot-firmware/)
- [Claude Skills for Robotics ROS2 Development Workflow](/claude-skills-guide/claude-skills-for-robotics-ros2-development-workflow/)
- [Claude Skills for Computational Biology and Bioinformatics](/claude-skills-guide/claude-skills-for-computational-biology-bioinformatics/)
- [Claude Skills for Unity Game Development Workflow](/claude-skills-guide/claude-skills-for-unity-game-development-workflow/)
- [Claude Skills for Unreal Engine C++ Development](/claude-skills-guide/claude-skills-for-unreal-engine-c-development/)
- [Accessible Forms with Claude Code: Error Handling Guide](/claude-skills-guide/claude-code-accessible-forms-validation-error-handling-guide/)
- [Fix Color Contrast and Accessibility with Claude Code](/claude-skills-guide/claude-code-color-contrast-accessibility-fix-workflow/)
- [Claude Skills for Accessibility Testing WCAG A11y](/claude-skills-guide/claude-skills-for-accessibility-testing-wcag-a11y/)
- [Claude Code Sentry Error Tracking Source Maps Workflow](/claude-skills-guide/claude-code-sentry-error-tracking-source-maps-workflow/)
- [Claude Code Multi-Agent Error Recovery Strategies](/claude-skills-guide/claude-code-multi-agent-error-recovery-strategies/)

### Integrations and Automation

Connecting Claude Code skills to external services and workflows.

- [How to Use Claude Skills with n8n Automation Workflows](/claude-skills-guide/how-to-use-claude-skills-with-n8n-automation-workflows/)
- [Claude Code Skills + Zapier: Step-by-Step](/claude-skills-guide/claude-code-skills-zapier-integration-step-by-step/)
- [Claude Skills with GitHub Actions CI/CD Pipeline 2026](/claude-skills-guide/claude-skills-with-github-actions-ci-cd-pipeline/)
- [Claude Skills + AWS Lambda: Serverless Guide](/claude-skills-guide/claude-skills-aws-lambda-serverless-integration/)
- [Claude Skills with Slack Bot Integration Tutorial](/claude-skills-guide/claude-skills-with-slack-bot-integration-tutorial/)
- [Claude Skills with Supabase: Practical Workflows](/claude-skills-guide/claude-skills-with-supabase-database-integration/)
- [Claude Skills + Vercel Deployment Automation Guide](/claude-skills-guide/claude-skills-with-vercel-deployment-automation/)
- [Claude Skills with Linear Project Management Tutorial](/claude-skills-guide/claude-skills-with-linear-project-management-tutorial/)
- [How to Integrate Claude Skills with Notion API Guide](/claude-skills-guide/how-to-integrate-claude-skills-with-notion-api-guide/)
- [How to Connect Claude Skills to External APIs Guide](/claude-skills-guide/how-to-connect-claude-skills-to-external-apis-guide/)
- [Can Claude Code Skills Call External APIs Automatically?](/claude-skills-guide/can-claude-code-skills-call-external-apis-automatically/)
- [Can Claude Code Skills Work Alongside Other AI Models?](/claude-skills-guide/can-claude-code-skills-work-alongside-other-ai-models/)
- [Can Claude Skills Generate Images or Handle Multimedia Files?](/claude-skills-guide/can-claude-skills-generate-images-or-handle-multimedia-files/)

### Automation Workflows

Complete workflow automation guides using Claude Code skills.

- [Automated Code Documentation Workflow with Claude Skills](/claude-skills-guide/automated-code-documentation-workflow-with-claude-skills/)
- [Best Claude Skills for Code Review Automation](/claude-skills-guide/best-claude-skills-for-code-review-automation/)
- [How to Automate Code Reviews with Claude Skills](/claude-skills-guide/how-to-automate-code-reviews-with-claude-skills/)
- [How to Automate Pull Request Review with Claude Skills](/claude-skills-guide/how-to-automate-pull-request-review-with-claude-skill/)
- [Automated GitHub Issue Triage with Claude Skills Guide](/claude-skills-guide/claude-skills-for-automated-github-issue-triage/)
- [Claude Skills Automated Dependency Update Workflow](/claude-skills-guide/claude-skills-automated-dependency-update-workflow/)
- [Claude Skills Daily Standup Automation Workflow](/claude-skills-guide/claude-skills-daily-standup-automation-workflow/)
- [Claude Skills Email Drafting Automation Workflow](/claude-skills-guide/claude-skills-email-drafting-automation-workflow/)
- [Automated Blog Workflow with Claude Skills](/claude-skills-guide/claude-skills-automated-blog-post-workflow-tutorial/)
- [Claude Skills Automated Social Media Content Workflow](/claude-skills-guide/claude-skills-automated-social-media-content-workflow/)
- [Claude Skills: Competitive Analysis Automation Guide](/claude-skills-guide/claude-skills-competitive-analysis-automation-workflow/)
- [How to Automate Client Reports with Claude Skills](/claude-skills-guide/how-to-automate-client-reports-with-claude-skills/)
- [Claude Skills for SEO Content Generation: 2026 Guide](/claude-skills-guide/claude-skills-for-seo-content-generation-workflow/)
- [Claude Skills for Localization i18n Workflow Automation](/claude-skills-guide/claude-skills-for-localization-i18n-workflow-automation/)
- [Claude Code Batch Processing with Skills Guide](/claude-skills-guide/claude-code-batch-processing-with-skills-guide/)

### Building Projects with Claude Code

Step-by-step project guides that demonstrate skills in action.

- [Full Stack Web App with Claude Skills Step-by-Step](/claude-skills-guide/full-stack-web-app-with-claude-skills-step-by-step/)
- [How to Build a SaaS MVP with Claude Code Skills Guide](/claude-skills-guide/how-to-build-saas-mvp-with-claude-code-skills-guide/)
- [Build a Personal AI Assistant with Claude Skills Guide](/claude-skills-guide/build-personal-ai-assistant-with-claude-skills-guide/)
- [Building Production AI Agents with Claude Skills in 2026](/claude-skills-guide/building-production-ai-agents-with-claude-skills-2026/)
- [Building Stateful Agents with Claude Skills Guide](/claude-skills-guide/building-stateful-agents-with-claude-skills-guide/)
- [Claude Agent Sandbox Skill: Complete Guide (2026)](/claude-skills-guide/claude-agent-sandbox-skill-isolated-environments/)
- [Claude Code Multi-Agent Error Recovery Strategies](/claude-skills-guide/claude-code-multi-agent-error-recovery-strategies/)

### "What Is the Best Skill for..." Questions

Answers to specific skill selection questions.

- [What Is the Best Claude Skill for Automated Code Review](/claude-skills-guide/what-is-the-best-claude-skill-for-automated-code-review/)
- [What Is the Best Claude Skill for Generating Documentation](/claude-skills-guide/what-is-the-best-claude-skill-for-generating-documentation/)
- [What Is the Best Claude Skill for Python Data Workflows](/claude-skills-guide/what-is-the-best-claude-skill-for-python-data-workflows/)
- [What Is the Best Claude Skill for REST API Development](/claude-skills-guide/what-is-the-best-claude-skill-for-rest-api-development/)

### "How Do I..." Practical Questions

Concise answers to common operational questions.

- [How Do I Combine Two Claude Skills in One Workflow](/claude-skills-guide/how-do-i-combine-two-claude-skills-in-one-workflow/)
- [How Do I Debug a Claude Skill That Silently Fails](/claude-skills-guide/how-do-i-debug-a-claude-skill-that-silently-fails/)
- [How Do I Know Which Claude Skill Is Currently Active?](/claude-skills-guide/how-do-i-know-which-claude-skill-is-currently-active/)
- [How Do I Limit What a Claude Skill Can Access on Disk](/claude-skills-guide/how-do-i-limit-what-a-claude-skill-can-access-on-disk/)
- [How Do I Make a Claude Skill Available Organization Wide](/claude-skills-guide/how-do-i-make-a-claude-skill-available-organization-wide/)
- [How Do I Rollback a Bad Claude Skill Update Safely](/claude-skills-guide/how-do-i-rollback-a-bad-claude-skill-update-safely/)
- [How Do I See Claude Skill Usage and Token Costs Breakdown](/claude-skills-guide/how-do-i-see-claude-skill-usage-and-token-costs-breakdown/)
- [How Do I Set Environment Variables for a Claude Skill](/claude-skills-guide/how-do-i-set-environment-variables-for-a-claude-skill/)
- [How Do I Share Claude Skills Across Multiple Projects](/claude-skills-guide/how-do-i-share-claude-skills-across-multiple-projects/)
- [How Do I Test a Claude Skill Before Deploying to Team](/claude-skills-guide/how-do-i-test-a-claude-skill-before-deploying-to-team/)
- [How Do I Use Claude Skills in an Air-Gapped Environment](/claude-skills-guide/how-do-i-use-claude-skills-in-an-air-gapped-environment/)

### "Why Does..." Diagnostic Questions

Explaining unexpected Claude Code behavior.

- [Why Does Claude Code Ignore My Skill MD File Entirely](/claude-skills-guide/why-does-claude-code-ignore-my-skill-md-file-entirely/)
- [Why Does Claude Code Not Recognize My Custom Skill Name?](/claude-skills-guide/why-does-claude-code-not-recognize-my-custom-skill-name/)
- [Why Does Claude Code Reject My Skill Instruction Block](/claude-skills-guide/why-does-claude-code-reject-my-skill-instruction-block/)
- [Why Does Claude Code Skill Take So Long to Initialize?](/claude-skills-guide/why-does-claude-code-skill-take-so-long-to-initialize/)
- [Why Does Claude Skill Auto Invocation Fail Intermittently?](/claude-skills-guide/why-does-claude-skill-auto-invocation-fail-intermittently/)
- [Why Does Claude Skill Produce Different Output Each Run](/claude-skills-guide/why-does-claude-skill-produce-different-output-each-run/)
- [Why Does My Claude Skill Work Locally But Fail in CI?](/claude-skills-guide/why-does-my-claude-skill-work-locally-but-fail-in-ci/)

### Industry and Domain-Specific Skills

Guides for specific industries and regulated domains.

- [Claude Skills for Regulated Industries: Fintech & Healthcare Development](/claude-skills-guide/claude-skills-for-regulated-industries-fintech-healthcare/)
- [Claude Skills for Enterprise Security & Compliance Guide](/claude-skills-guide/claude-skills-for-enterprise-security-compliance-guide/)
- [Claude Skills Compliance SOC2 ISO27001 Guide](/claude-skills-guide/claude-skills-compliance-soc2-iso27001-guide/)

---

## Where to Go Next

Once you have the basics down, the rest of the library is organized by topic:

- **[Workflows Hub](/claude-skills-guide/workflows-hub/)** — repeatable, automated workflows once you have skills running
- **[Advanced Hub](/claude-skills-guide/advanced-hub/)** — multi-agent systems, hooks architecture, and production patterns
- **[Integrations Hub](/claude-skills-guide/integrations-hub/)** — connecting Claude Code to your existing tools and services
- **[Comparisons Hub](/claude-skills-guide/comparisons-hub/)** — Claude Code vs GitHub Copilot, Cursor, Devin, and other AI coding tools

---

## Related Reading

- [Claude Code for Beginners: Getting Started 2026](/claude-skills-guide/claude-code-for-beginners-complete-getting-started-2026/) — hands-on beginner tutorial to complement this hub
- [Claude Skills Directory: Where to Find Skills 2026](/claude-skills-guide/claude-skills-directory-where-to-find-skills/) — discover community and official skills to install first
- [Best Claude Code Skills to Install First in 2026](/claude-skills-guide/best-claude-code-skills-to-install-first-2026/) — curated list of the highest-value skills for new users
- [Claude Skills Auto Invocation: How It Works](/claude-skills-guide/claude-skills-auto-invocation-how-it-works/) — understand how skills activate automatically in your sessions

*Built by theluckystrike — More at [zovo.one](https://zovo.one)*
