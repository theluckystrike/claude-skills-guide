---
layout: default
title: "Claude Code for Beginners: Getting Started 2026"
description: "Step-by-step beginner guide to Claude Code: installation, first session, skills, CLAUDE.md setup, and practical tips for your first AI-assisted workflow."
date: 2026-03-13
categories: [tutorials]
tags: [claude-code, claude-skills, beginners, tutorial, getting-started]
author: "Claude Skills Guide"
reviewed: true
score: 9
---

# Claude Code for Beginners: Getting Started in 2026

Claude Code is Anthropic's command-line tool that brings Claude directly into your development workflow. Instead of switching to a browser to ask Claude questions, you work with Claude in your terminal, and Claude can read your files, write code, and run commands. This guide walks you through getting started from zero.

## What You Need Before Starting

- A computer running macOS, Linux, or Windows (via WSL)
- Node.js installed (version 18 or later) — check with `node --version`
- An Anthropic account at console.anthropic.com
- Basic comfort using a terminal

You do not need to be a senior developer or understand how AI models work. If you can navigate a terminal and open files, you are ready.

## Step 1: Install Claude Code

Claude Code installs via npm. Open your terminal and run:

```bash
npm install -g @anthropic-ai/claude-code
```

Verify the installation:

```bash
claude --version
```

You should see a version number. If you see "command not found", restart your terminal.

## Step 2: Authenticate

Claude Code needs your Anthropic API key to work. Get one at console.anthropic.com under "API Keys".

Then run:

```bash
claude auth
```

You will be prompted to paste your API key. It gets stored securely — you only need to do this once.

## Step 3: Start Your First Session

Navigate to a project folder you are working on (or create a new one for practice):

```bash
mkdir my-first-claude-project
cd my-first-claude-project
claude
```

Claude Code starts and gives you a prompt. You are now in an interactive session. Type a message:

```
> Create a JavaScript function that takes a list of numbers and returns their average.
```

Claude will write the function. Ask it to save to a file:

```
> Save that to a file called math-utils.js
```

Claude will write the file to your current directory.

## Step 4: Understand What Claude Code Can Do

Claude Code has **tools** — abilities to take action on your computer. By default it can:

- **Read files** in your project folder
- **Write files** and create new files
- **Run bash commands** like `npm install` or `git commit`
- **Search the web** for documentation or answers

When Claude uses a tool, it tells you what it is doing:

```
I'll write this to math-utils.js

[Writing file: math-utils.js]
Done. The file has been created with the average function.
```

## Step 5: Try a Real Task

Create a simple Node.js project:

```bash
npm init -y
claude
```

Ask Claude to build something:

```
> Build a command-line tool that takes a CSV file path as input and prints
  a summary: number of rows, column names, and the first 5 rows.
```

Watch what Claude does. It will think through the problem, write the code, install any needed packages, test it, and show you the result. This is the core loop: describe what you want, Claude builds it.

## Step 6: Use Skills

Skills are pre-configured modes that make Claude especially good at specific tasks. A skill is a Markdown file stored in `~/.claude/skills/`. You invoke skills with a `/skill-name` slash command at the start of your message.

Built-in skills you can use right away:

| Command | What it does |
|---|---|
| `/tdd` | Test-driven development — write tests first |
| `/pdf` | Process and generate PDF documents |
| `/docx` | Create and edit Word documents |
| `/frontend-design` | Generate UI components |
| `/supermemory` | Store context that persists between sessions |
| `/canvas-design` | Create visual assets |

To use the `tdd` skill:

```
/tdd Write tests for my math-utils.js file
```

To remember something about your project across sessions:

```
/supermemory Remember that this project uses ES modules (import/export), not CommonJS
```

In future sessions, retrieve it:

```
/supermemory What are the module conventions for this project?
```

## Step 7: Set Up CLAUDE.md

The `CLAUDE.md` file is a project briefing document that Claude reads at the start of every session. Put information about your project there so Claude does not need you to explain it every time.

Create one:

```
> Create a CLAUDE.md file for this project with the project structure and key conventions
```

Claude will generate a draft. Review it and add:
- What the project does
- Technologies you are using
- Coding conventions (tabs vs spaces, file naming)
- How to run tests
- Any important constraints

## Common Beginner Mistakes

**Trying to do too much in one message**: Break large requests into steps. "Build me a full e-commerce site" will not go well. "Build a product listing page that shows items from a JSON file" is a good start.

**Not reviewing what Claude writes**: Claude is good but not perfect. Always read the code it writes before running or committing it.

**Forgetting to set up CLAUDE.md**: Without it, Claude has to rediscover your project every session. Spending 10 minutes on CLAUDE.md saves hours over time.

**Running Claude Code in the wrong directory**: Claude can only read files in your current directory and subdirectories. Start sessions from your project root.

## What to Try Next

Once you are comfortable with the basics:

1. **Use [`/supermemory`](/claude-skills-guide/claude-skills-token-optimization-reduce-api-costs/)** — persistent memory across sessions
2. **Use [`/tdd`](/claude-skills-guide/best-claude-skills-for-developers-2026/)** — add tests to existing code
3. **Try [`/frontend-design`](/claude-skills-guide/best-claude-code-skills-for-frontend-development/)** — builds UI components that match your design system
4. **Read the hooks guide** — learn to control what Claude can do via shell hooks in `.claude/settings.json`

Claude Code's power grows as you learn to structure tasks well and customize it for your workflow. Start simple, then layer in more capabilities.

---

## Related Reading

- [Best Claude Skills for Developers in 2026](/claude-skills-guide/best-claude-skills-for-developers-2026/) — The natural next step: an in-depth look at the most impactful skills to install once you have Claude Code running
- [Skill .md File Format Explained With Examples](/claude-skills-guide/skill-md-file-format-explained-with-examples/) — When you're ready to write your own skills, this guide explains the exact format and fields
- [Claude Skills Auto-Invocation: How It Works](/claude-skills-guide/claude-skills-auto-invocation-how-it-works/) — Understanding when Claude activates skills automatically helps you get more value from your setup as you grow beyond the basics

Built by theluckystrike — More at [zovo.one](https://zovo.one)
