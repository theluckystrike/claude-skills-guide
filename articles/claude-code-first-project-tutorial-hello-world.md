---
layout: default
title: "Claude Code First Project Tutorial: Hello World"
description: "Create your first Claude Code project with this step-by-step hello world tutorial. Code examples for developers getting started with Claude Code."
date: 2026-03-14
categories: [getting-started]
tags: [claude-code, claude-skills, hello-world, getting-started, tutorial]
author: "Claude Skills Guide"
reviewed: true
score: 7
---

# Claude Code First Project Tutorial — Hello World

Getting started with Claude Code takes less than ten minutes. This tutorial walks you through creating your first project from scratch, configuring Claude Code for your development environment, and running a simple hello world task to verify everything works. See the [getting started hub](/claude-skills-guide/getting-started-hub/) for more beginner resources.

## Prerequisites

[Before you begin, ensure you have the prerequisites installed](/claude-skills-guide/best-claude-code-skills-to-install-first-2026/)

- **Node.js 18+** installed on your machine
- **A Claude Code account** with API access
- **Terminal access** with your preferred shell

[Check your Node.js version before starting](/claude-skills-guide/claude-skill-md-format-complete-specification-guide/)

```bash
node --version
```

If you see a version number below 18, upgrade Node.js first. Claude Code requires at least version 18 for its runtime environment.

## Installing Claude Code

The installation process varies slightly depending on your operating system. On macOS and Linux, use npm:

```bash
npm install -g @anthropic-ai/claude-code
```

On Windows, use PowerShell or the Windows Subsystem for Linux. After installation, verify Claude Code is available:

```bash
claude --version
```

You should see output displaying the version number, confirming the CLI is accessible from any terminal session.

## Configuring Your API Key

Claude Code requires authentication via an API key from Anthropic. If you do not have an API key yet, obtain one from the Anthropic console. Set the environment variable before running Claude:

```bash
export ANTHROPIC_API_KEY="your-api-key-here"
```

Add this line to your shell profile (`~/.bashrc`, `~/.zshrc`, or equivalent) to avoid re-entering the key on each session.

## Creating Your First Project

[Create a new directory for your hello world project](/claude-skills-guide/claude-code-project-initialization-best-practices/):

```bash
mkdir claude-hello-world && cd claude-hello-world
```

Initialize a basic project structure. For a JavaScript project, create a `package.json`:

```bash
npm init -y
```

Your project directory should now contain a `package.json` file. This simple setup demonstrates the core workflow: create a project, then use Claude Code to assist with development tasks.

## Running Your First Claude Code Command

Now invoke Claude Code to assist with a basic task. The CLI uses natural language prompts rather than strict command flags:

```bash
claude "Create a simple hello.js file that prints 'Hello from Claude Code' to the console"
```

Claude Code responds by generating the requested file. You should see a new `hello.js` in your project:

```javascript
console.log("Hello from Claude Code");
```

Run the file to verify:

```bash
node hello.js
```

Output displays the expected message. Your first Claude Code task completed successfully.

## Understanding Claude Code Sessions

Claude Code operates within interactive sessions. Each session maintains context across multiple commands, allowing Claude to understand your project structure and development goals. Start an interactive session within your project directory:

```bash
claude
```

[Within a session, you can issue follow-up requests](/claude-skills-guide/how-to-write-effective-prompts-for-claude-code/):

```
Add a function that takes a name parameter and returns a personalized greeting
```

Claude Code reads your existing files, understands the context, and generates appropriate code modifications. This contextual awareness distinguishes Claude Code from standalone code generators.

## Working with Project Files

Claude Code excels at understanding and modifying existing codebases. Create a more complex example to test this capability:

```bash
claude "Create a greeting.js module that exports a greet function accepting a name parameter"
```

This generates:

```javascript
// greeting.js
function greet(name) {
  return `Hello, ${name}!`;
}

module.exports = { greet };
```

Now ask Claude Code to extend this module:

```
Add a default parameter for when no name is provided
```

Claude Code modifies the function:

```javascript
function greet(name = "World") {
  return `Hello, ${name}!`;
}
```

The modification preserves your existing code while adding the requested feature.

## Using Claude Code for Code Review

Beyond generating code, Claude Code helps review existing implementations. Create a file with intentional issues:

```javascript
// review-me.js
function calculateTotal(prices) {
  let total = 0;
  for (let i = 0; i <= prices.length; i++) {
    total += prices[i];
  }
  return total;
}
```

Ask Claude Code to review it:

```
/review review-me.js for bugs and improvements
```

Claude Code identifies the off-by-one error in the loop condition and suggests a cleaner implementation using `reduce()`. This demonstrates the practical value of using Claude Code as a review partner during development.

## Scripting and Automation

For repetitive tasks, create Claude Code scripts that automate common workflows. You can pair this with [Claude Code skills](/claude-skills-guide/claude-skill-md-format-complete-specification-guide/) to make recurring automations repeatable. A simple script might look like:

```bash
#!/bin/bash
# run-tests.sh
claude "Run the test suite and summarize any failures"
```

Make it executable and run it:

```bash
chmod +x run-tests.sh
./run-tests.sh
```

This approach integrates Claude Code into your existing development workflow without requiring manual intervention for routine tasks.

## Next Steps

With your first project complete, explore more advanced capabilities:

- **Multi-file generation**: Ask Claude Code to scaffold entire features with multiple related files
- **Debugging assistance**: Paste error messages and let Claude Code trace through stack traces
- **Documentation generation**: Request docstrings and README updates
- **Refactoring**: Describe structural changes and let Claude Code implement them

The hello world project you created demonstrates the fundamentals. From here, integrate Claude Code into your actual development workflow, using it for code generation, review, debugging, and documentation tasks as they arise.

## Related Reading

- [Claude Code for Beginners: Complete Getting Started 2026](/claude-skills-guide/claude-code-for-beginners-complete-getting-started-2026/)
- [Best Way to Scope Tasks for Claude Code Success](/claude-skills-guide/best-way-to-scope-tasks-for-claude-code-success/)
- [How to Write Effective Prompts for Claude Code](/claude-skills-guide/how-to-write-effective-prompts-for-claude-code/)
- [Getting Started Hub](/claude-skills-guide/getting-started-hub/)

Built by theluckystrike — More at [zovo.one](https://zovo.one)
