---
layout: default
title: "Claude Code for Beginners: Complete Starter Guide 2026"
description: "A step-by-step beginner guide to Claude Code in 2026 — installation, first session, understanding skills, and building your first AI-assisted workflow."
date: 2026-03-13
author: theluckystrike
---

# Claude Code for Beginners: Complete Getting Started Guide 2026

Claude Code is Anthropic's command-line tool that brings Claude directly into your development workflow. Instead of switching to a browser to ask Claude questions, you work with Claude right in your terminal, and Claude can read your files, write code, and run commands. This guide walks you through getting started from zero.

## What You Need Before Starting

- A computer running macOS, Linux, or Windows (via WSL)
- Node.js installed (version 18 or later) — check with `node --version`
- An Anthropic account at console.anthropic.com
- Basic comfort with using a terminal

You do not need to know Python, be a senior developer, or understand how AI models work. If you can navigate a terminal and open files, you're ready.

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

Claude Code needs your Anthropic API key to work. Get one at console.anthropic.com — go to "API Keys" and create a new key.

Then run:

```bash
claude auth
```

You'll be prompted to paste your API key. It gets stored securely in your system's keychain — you only need to do this once.

## Step 3: Start Your First Session

Navigate to a project folder you're working on (or create a new one for practice):

```bash
mkdir my-first-claude-project
cd my-first-claude-project
claude
```

Claude Code starts up and gives you a prompt. You're now in an interactive session. Type a message just like you would in any chat interface.

Try asking something simple:

```
> Create a JavaScript function that takes a list of numbers and returns their average.
```

Claude will write the function in the terminal. You can then ask it to save it to a file:

```
> Save that to a file called math-utils.js
```

Claude will write the file to your current directory. Check it with `ls` or open it in your editor.

## Step 4: Understand What Claude Code Can Do

Claude Code is different from regular Claude (the website) because it has **tools** — abilities to take action on your computer. By default it can:

- **Read files** in your project folder
- **Write files** and create new files
- **Run bash commands** like `npm install` or `git commit`
- **Search the web** for documentation or answers
- **Fetch web pages** like API documentation

When Claude needs to use one of these tools, it will tell you what it's doing. For example:

```
I'll write this to math-utils.js

[Writing file: math-utils.js]
Done. The file has been created with the average function.
```

You can also ask Claude to explain what it's doing or to check before taking actions if you prefer more control.

## Step 5: Try a Real Task

Let's try something practical. In your project folder, create a simple project:

```bash
npm init -y
```

Then open Claude Code:

```bash
claude
```

Ask Claude to build something:

```
> Build a simple command-line tool that takes a CSV file path as input and 
  prints a summary of the data (number of rows, column names, and a sample 
  of the first 5 rows).
```

Watch what Claude does. It will:
1. Think through the problem
2. Write the code
3. Potentially run `npm install` if it needs a CSV parsing library
4. Test the code
5. Show you the result

This is the core loop: you describe what you want, Claude builds it.

## Step 6: Use Skills

Skills are pre-configured "modes" that make Claude especially good at specific tasks. Instead of Claude being a generalist, a skill makes it a specialist.

Check what skills are available:

```
/skills list
```

You'll likely see skills like `tdd`, `frontend-design`, `pdf`, `docx`, and `supermemory` if they're installed.

### Using a Skill Manually

To use the `tdd` skill (test-driven development), type:

```
/tdd Write tests for my math-utils.js file
```

Claude will now operate in TDD mode — it'll write tests first, then implementation.

### Skills That Trigger Automatically

Some skills are set up to trigger automatically based on what you type. For example, if you have a `pdf` skill installed and you type:

```
> Convert report.md to a PDF
```

The `pdf` skill might activate automatically. You'll see a notification in Claude Code showing which skill is running.

## Step 7: Set Up CLAUDE.md

The `CLAUDE.md` file is like a briefing document that Claude reads at the start of every session. Put information about your project there so Claude doesn't need you to explain it every time.

Create one in your project root:

```
> Create a CLAUDE.md file for this project with the project structure and key conventions
```

Claude will generate a draft. Review it and add any important details like:
- What the project does
- Technologies you're using (React, PostgreSQL, etc.)
- Coding conventions (tabs vs spaces, file naming)
- How to run tests
- Any important constraints

## Step 8: Common Beginner Commands

Here are the commands you'll use most often when starting out:

| Command | What it does |
|---------|--------------|
| `claude` | Start a session in the current directory |
| `/help` | Show available commands |
| `/skills list` | Show available skills |
| `/exit` | End the session |
| `/clear` | Clear conversation history (fresh start) |
| `/session log` | Show what Claude did this session |

Within the conversation, you don't need any special syntax. Just type what you want, like texting a very capable developer colleague.

## Common Beginner Mistakes

**Trying to do too much in one message**: Break large requests into steps. "Build me a full e-commerce site" will not go well. "Build a product listing page that shows items from a JSON file" is a good start.

**Not reviewing what Claude writes**: Claude is good but not perfect. Always read the code it writes, especially before running it or committing it to git.

**Forgetting to set up CLAUDE.md**: Without it, Claude has to rediscover your project every session. Spending 10 minutes on CLAUDE.md saves hours over time.

**Running Claude Code in the wrong directory**: Claude can only read files in your current directory and subdirectories. Make sure you're in your project root when starting a session.

**Interrupting Claude mid-task**: If Claude is running a long task and you interrupt it (Ctrl+C), it may leave files in a partial state. Let tasks complete or use `/stop` to halt gracefully.

## What to Try Next

Once you're comfortable with the basics:

1. **Install the supermemory skill** — it gives Claude memory across sessions so it remembers your project details
2. **Set up the tdd skill** — great for adding tests to existing code
3. **Try the frontend-design skill** — builds React components that match your design system
4. **Read the hooks guide** — learn to control what Claude can and can't do

Claude Code's power grows as you learn to structure tasks well and customize it for your workflow. Start simple, then layer in more capabilities.

---

## Related Reading

- [Best Claude Skills for Developers in 2026](/claude-skills-guide/articles/best-claude-skills-for-developers-2026/) — The natural next step: an in-depth look at the most impactful skills to install once you have Claude Code running
- [Skill .md File Format Explained With Examples](/claude-skills-guide/articles/skill-md-file-format-explained-with-examples/) — When you're ready to write your own skills, this guide explains the exact format and fields
- [Claude Skills Auto-Invocation: How It Works](/claude-skills-guide/articles/claude-skills-auto-invocation-how-it-works/) — Understanding when Claude activates skills automatically helps you get more value from your setup as you grow beyond the basics

Built by theluckystrike — More at [zovo.one](https://zovo.one)
