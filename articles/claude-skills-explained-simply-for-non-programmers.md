---
layout: post
title: "Claude Skills Explained for Non-Programmers"
description: "What Claude Code skills actually are, how to use them with slash commands, and which built-in skills are worth knowing first."
date: 2026-03-13
categories: [getting-started, claude-skills]
tags: [claude-code, claude-skills, beginners, slash-commands]
author: "Claude Skills Guide"
reviewed: true
score: 8
---

# Claude Skills Explained for Non-Programmers

If you use Claude Code and have heard about "skills" but are not sure what they actually are, this guide gives you a clear picture — no programming background required.

## What Claude Skills Actually Are

A Claude skill is a plain text file stored on your computer. That is it. There is no special software to install, no packages to download, and no APIs to configure. Each skill lives as a `.md` file in a folder called `~/.claude/skills/` on your machine.

The file contains instructions written in plain English (and some structured formatting) that tell Claude Code how to approach a specific type of task. When you invoke a skill, Claude reads those instructions and applies them to your request.

## How You Use a Skill

Skills are invoked using a slash command in Claude Code. If you want to use the PDF skill, you type `/pdf` in Claude Code. That is the entire invocation — a forward slash followed by the skill name.

Here is what invoking looks like for the built-in skills:

- `/pdf` — activates the PDF skill for document tasks
- `/xlsx` — activates the spreadsheet skill
- `/tdd` — activates the test-driven development skill
- `/supermemory` — activates the persistent context skill
- `/frontend-design` — activates the UI design skill
- `/docx` — activates the Word document skill
- `/pptx` — activates the presentation skill
- `/canvas-design` — activates the visual canvas skill
- `/webapp-testing` — activates the web app testing skill

There is no marketplace to browse, no CLI subcommand to run, and no background process managing which skill is active. You type the slash command, Claude reads the skill file, and your conversation proceeds with that context loaded.

## What Each Built-in Skill Does

### /pdf — Document Handling

Use `/pdf` when you need to work with PDF files. Claude can help you extract text, summarize content, fill out forms, or understand what a document contains. You provide the file path or paste the content, and Claude applies the skill's guidance to your task.

### /xlsx — Spreadsheet Work

Use `/xlsx` when you need to create, read, or modify Excel spreadsheets. Claude can help you write the code or commands needed to generate reports, process data, and format columns. The skill provides structured guidance for working with spreadsheet files.

### /tdd — Test-Driven Development

Use `/tdd` when you want to write software tests before writing the actual code. This skill guides Claude to help you think through edge cases, write test structures, and follow the red-green-refactor development cycle.

### /supermemory — Persistent Notes

Use `/supermemory` when you want Claude to help you store and retrieve notes across sessions. This skill provides a pattern for saving context that would otherwise be lost when a conversation ends.

### /frontend-design — User Interfaces

Use `/frontend-design` when you are building web pages or application interfaces. The skill loads guidance for creating responsive layouts, accessible HTML, and clean CSS.

## Skills Are Not Python Packages or npm Modules

A common point of confusion: skills are not installed with `pip install` or `npm install`. They are not Python libraries or JavaScript packages. They are text files. If you see code examples suggesting `from claude_skills import pdf` or `require('claude-skills/pdf')`, that is incorrect.

You also cannot manage skills through Claude's command line with commands like `claude skill install` or `claude skills list`. Skills are simply files you can add, edit, or delete directly in the `~/.claude/skills/` folder.

## Getting Started

If you are new to Claude skills, start with one that matches a task you do regularly. If you work with PDFs often, try `/pdf`. If you build web pages, try `/frontend-design`.

Type the slash command at the start of a Claude Code session, describe your task, and Claude will apply the skill's guidance to help you. The learning curve is minimal because the interface is just a slash command.

---

## Related Reading

- [How to Write a Skill .md File for Claude Code](/claude-skills-guide/articles/how-to-write-a-skill-md-file-for-claude-code/) — Create your own custom skills
- [Claude Skills vs Prompts: Which Is Better?](/claude-skills-guide/articles/claude-skills-vs-prompts-which-is-better/) — When to use skills vs plain prompts
- [Claude Skills Auto Invocation: How It Works](/claude-skills-guide/articles/claude-skills-auto-invocation-how-it-works/) — How skills activate in context


Built by theluckystrike — More at [zovo.one](https://zovo.one)
