---
layout: post
title: "Claude Code for Beginners: Getting Started 2026"
description: "Step-by-step beginner guide to Claude Code in 2026: installation, first session, understanding skills, and building your first AI-assisted workflow."
date: 2026-03-13
categories: [getting-started, guides]
tags: [claude-code, beginners, installation, getting-started, claude-skills]
author: "Claude Skills Guide"
reviewed: true
score: 8
---

# Claude Code for Beginners: Getting Started 2026

Claude Code is Anthropic's command-line tool that brings Claude directly into your development workflow. Instead of switching to a browser to ask Claude questions, you work with Claude right in your terminal, and Claude can read your files, write code, and run commands. This guide walks you through getting started from zero.

## What You Need Before Starting

- A computer running macOS, Linux, or Windows (via WSL)
- Node.js installed (version 18 or later) -- check with `node --version`
- An Anthropic account at console.anthropic.com
- Basic comfort with using a terminal

You do not need to know Python, be a senior developer, or understand how AI models work. If you can navigate a terminal and open files, you are ready.

## Step 1: Install Claude Code

Claude Code installs via npm. Open your terminal and run:

```bash
npm install -g @anthropic-ai/claude-code
```

Verify the installation:

```bash
claude --version
```

You should see a version number. If you see "command not found", try restarting your terminal.

## Step 2: Authenticate

Claude Code needs your Anthropic API key to work. Get one at console.anthropic.com and go to "API Keys" to create a new key.

Then run:

```bash
claude auth
```

You will be prompted to paste your API key. It gets stored securely in your system's keychain.

## Step 3: Start Your First Session

Navigate to a project folder and start Claude Code:

```bash
mkdir my-first-claude-project
cd my-first-claude-project
claude
```

You are now in an interactive session. Type a message just like you would in any chat interface:

```
> Create a JavaScript function that takes a list of numbers and returns their average.
```

Claude will write the function. You can then ask it to save it:

```
> Save that to a file called math-utils.js
```

## Step 4: Understand What Claude Code Can Do

Claude Code has tools -- abilities to take action on your computer:

- **Read files** in your project folder
- **Write files** and create new files
- **Run bash commands** like `npm install` or `git commit`
- **Search the web** for documentation or answers
- **Fetch web pages** like API documentation

When Claude uses a tool, it tells you what it is doing.

## Step 5: Try a Real Task

In your project folder:

```bash
npm init -y
claude
```

Ask Claude to build something:

```
> Build a simple command-line tool that takes a CSV file path as input and
  prints a summary: number of rows, column names, and a sample of the first 5 rows.
```

Watch what Claude does: thinks through the problem, writes the code, installs any needed packages, tests it, and shows you the result. This is the core loop.

## Step 6: Use Skills

Skills are pre-configured modes stored as `.md` files in `~/.claude/skills/`. They are invoked using slash commands.

To use the `/tdd` skill (test-driven development):

```
/tdd Write tests for my math-utils.js file
```

Claude will now operate in TDD mode, writing tests before implementation.

### Available Built-in Skills

| Skill | What it does |
|-------|-------------|
| `/tdd` | Test-driven development workflow |
| `/pdf` | Read and create PDF files |
| `/docx` | Work with Word documents |
| `/pptx` | Work with PowerPoint files |
| `/xlsx` | Work with Excel spreadsheets |
| `/frontend-design` | Generate UI components |
| `/canvas-design` | Create graphics and images |
| `/supermemory` | Store and recall project context |
| `/webapp-testing` | Automated browser testing |

Invoke any skill by typing `/skill-name` followed by your request.

### Skills That Trigger Automatically

Skills can be configured to trigger automatically. If you have a `/pdf` skill installed and type "convert report.md to a PDF", the `/pdf` skill may activate on its own. You will see a notification showing which skill is running.

## Step 7: Set Up CLAUDE.md

The `CLAUDE.md` file is a briefing document that Claude reads at the start of every session. Put information about your project there so Claude does not need you to explain it every time:

```
> Create a CLAUDE.md file for this project with the project structure and key conventions
```

Add details like the tech stack, coding conventions, how to run tests, and any important constraints.

## Common Beginner Mistakes

**Trying to do too much in one message**: Break large requests into steps. "Build me a full e-commerce site" will not go well. "Build a product listing page that shows items from a JSON file" is a good start.

**Not reviewing what Claude writes**: Always read the code it writes before running it or committing to git.

**Forgetting to set up CLAUDE.md**: Without it, Claude has to rediscover your project every session. Spending 10 minutes on CLAUDE.md saves hours over time.

**Running Claude Code in the wrong directory**: Claude can only read files in your current directory and subdirectories. Always start from your project root.

## What to Try Next

1. **Use `/supermemory`** -- gives Claude memory across sessions
2. **Set up `/tdd`** -- great for adding tests to existing code
3. **Try `/frontend-design`** -- builds UI components that match your design system
4. **Read the hooks guide** -- learn to configure Claude's behavior via `~/.claude/settings.json`

---

## Related Reading

- [Best Claude Skills for Developers in 2026](/claude-skills-guide/articles/best-claude-skills-for-developers-2026/) -- Top skills every developer should know
- [How to Write a Skill .md File for Claude Code](/claude-skills-guide/articles/how-to-write-a-skill-md-file-for-claude-code/) -- Build your own custom skills
- [Claude Skills Auto Invocation: How It Works](/claude-skills-guide/articles/claude-skills-auto-invocation-how-it-works/) -- How skills activate automatically


Built by theluckystrike -- More at [zovo.one](https://zovo.one)
