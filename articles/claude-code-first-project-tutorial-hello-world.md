---
layout: default
title: "Claude Code First Project Tutorial (2026)"
description: "Create your first Claude Code project with this step-by-step hello world tutorial. Code examples for developers getting started with Claude Code."
date: 2026-03-14
last_modified_at: 2026-04-17
categories: [getting-started]
tags: [claude-code, claude-skills, hello-world, getting-started, tutorial]
author: "Claude Skills Guide"
reviewed: true
score: 7
permalink: /claude-code-first-project-tutorial-hello-world/
geo_optimized: true
---

# Claude Code First Project Tutorial. Hello World

Getting started with Claude Code takes less than ten minutes. This tutorial walks you through creating your first project from scratch, configuring Claude Code for your development environment, and running a simple hello world task to verify everything works. See the [getting started hub](/getting-started-hub/) for more beginner resources.

## Prerequisites

[Before you begin, ensure you have the prerequisites installed](/best-claude-code-skills-to-install-first-2026/)

- Node.js 18+ installed on your machine
- A Claude Code account with API access
- Terminal access with your preferred shell

[Check your Node.js version before starting](/claude-skill-md-format-complete-specification-guide/)

```bash
node --version
```

If you see a version number below 18, upgrade Node.js first. Claude Code requires at least version 18 for its runtime environment.

On macOS, the easiest way to manage Node.js versions is with `nvm` (Node Version Manager). If you do not have it:

```bash
Install nvm
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash

Reload your shell profile, then install and use Node 20
nvm install 20
nvm use 20
nvm alias default 20
```

On Linux the same `nvm` steps apply. On Windows, use the official Node.js installer from nodejs.org or install WSL (Windows Subsystem for Linux) and follow the Linux path. Claude Code works best in a Unix-like shell environment.

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

If the `claude` command is not found after installation, your npm global binary path is probably missing from your `PATH`. Check where npm installs global binaries:

```bash
npm config get prefix
```

Then add `<prefix>/bin` to your `PATH` in your shell profile. For example, if the prefix is `/usr/local`:

```bash
In ~/.zshrc or ~/.bashrc
export PATH="/usr/local/bin:$PATH"
```

Restart your terminal and `claude --version` should resolve.

## Configuring Your API Key

Claude Code requires authentication via an API key from Anthropic. If you do not have an API key yet, obtain one from the Anthropic console. Set the environment variable before running Claude:

```bash
export ANTHROPIC_API_KEY="your-api-key-here"
```

Add this line to your shell profile (`~/.bashrc`, `~/.zshrc`, or equivalent) to avoid re-entering the key on each session.

For a cleaner setup, use a `.env` file at the project level and load it with a tool like `direnv`, which automatically exports variables when you enter the directory:

```bash
Install direnv (macOS)
brew install direnv

Add to your shell profile
eval "$(direnv hook zsh)" # or bash

In your project directory
echo 'export ANTHROPIC_API_KEY="your-api-key-here"' > .env
echo '.env' >> .gitignore # Critical: never commit your API key
direnv allow
```

After this, every time you `cd` into the project directory, your API key is available automatically. This is safer than setting it globally and avoids accidentally using a development key in production contexts.

Claude Code also supports the key being set via a `claude auth` command if you prefer not to manage the environment variable manually. check `claude --help` for current authentication options in your installed version.

## Creating Your First Project

[Create a new directory for your hello world project](/claude-code-project-initialization-best-practices/):

```bash
mkdir claude-hello-world && cd claude-hello-world
```

Initialize a basic project structure. For a JavaScript project, create a `package.json`:

```bash
npm init -y
```

Your project directory should now contain a `package.json` file. This simple setup demonstrates the core workflow: create a project, then use Claude Code to assist with development tasks.

It is worth understanding what `npm init -y` creates before you start modifying it. The `package.json` holds your project name, version, scripts, and dependencies. Claude Code reads this file to understand what kind of project it is working with, which helps it generate appropriate code. If your project were TypeScript instead of plain JavaScript, you would also want a `tsconfig.json`, and Claude Code can generate that for you too:

```bash
claude "Create a tsconfig.json for a Node.js TypeScript project targeting ES2022 with strict mode enabled"
```

Claude Code will produce a sensible configuration and explain the key settings. That pattern. asking Claude Code to generate configuration files with a plain-language description of what you need. is one of the fastest ways to bootstrap a new project correctly.

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

Claude Code shows you what it plans to do before making changes. You will see a diff or a description of the file it intends to create, and you can approve or reject the action. This approval workflow is intentional. it keeps you in control of your codebase. For simple tasks you will approve quickly; for larger changes you will want to review the diff before accepting.

You can also run Claude Code in a non-interactive mode for scripting by passing the `--yes` flag to auto-approve all actions, but for a first project it is worth going through the approval flow manually a few times to understand what Claude Code is actually doing.

## Understanding Claude Code Sessions

Claude Code operates within interactive sessions. Each session maintains context across multiple commands, allowing Claude to understand your project structure and development goals. Start an interactive session within your project directory:

```bash
claude
```

[Within a session, you can issue follow-up requests](/how-to-write-effective-prompts-for-claude-code/):

```
Add a function that takes a name parameter and returns a personalized greeting
```

Claude Code reads your existing files, understands the context, and generates appropriate code modifications. This contextual awareness distinguishes Claude Code from standalone code generators.

Sessions are powerful because Claude Code builds up a mental model of your project as you work. Early in the session, Claude Code reads your files to understand the structure. As the session progresses, it tracks changes it has made and uses that context to keep subsequent changes consistent. If you create a utility function in one file, Claude Code knows about it when you ask it to use that function elsewhere. you do not have to explain it again.

Session context does have limits. Very long sessions with many file changes can cause Claude Code to lose track of earlier context. For large projects, it is a good habit to start a fresh session when switching between distinct areas of the codebase, or to give Claude Code a brief recap: "We've been working on the auth module. Now let's move to the user profile endpoints."

You can also give Claude Code a `CLAUDE.md` file at the root of your project containing persistent instructions it should follow throughout every session. things like your code style preferences, testing requirements, or project-specific conventions. This is the fastest way to make Claude Code behave consistently across multiple work sessions.

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

Let's extend this further into something that demonstrates real-world Claude Code usage. Ask Claude Code to create a test file for the greeting module:

```
Create a test file for greeting.js using Node's built-in test runner
```

Claude Code generates:

```javascript
// greeting.test.js
const { test } = require('node:test');
const assert = require('node:assert');
const { greet } = require('./greeting');

test('greet returns personalized greeting', () => {
 assert.strictEqual(greet('Alice'), 'Hello, Alice!');
});

test('greet uses World as default when no name provided', () => {
 assert.strictEqual(greet(), 'Hello, World!');
});

test('greet handles empty string', () => {
 assert.strictEqual(greet(''), 'Hello, !');
});
```

Run the tests with:

```bash
node --test greeting.test.js
```

Now ask Claude Code to add a validation check to `greet` that throws if the name is not a string. Claude Code will update both the implementation and the test file to cover the new behavior, keeping them in sync. which is something most standalone code generators cannot do because they lack the session context to know the test file exists.

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
Review review-me.js for bugs and improvements
```

Claude Code identifies the off-by-one error in the loop condition (`i <= prices.length` should be `i < prices.length`) and suggests a cleaner implementation using `reduce()`. This demonstrates the practical value of using Claude Code as a review partner during development.

For a real project, the code review workflow becomes even more valuable. You can ask Claude Code to review a specific function, a whole file, or a git diff of changes you are about to commit:

```bash
Review staged changes before committing
git diff --cached | claude "Review these changes for bugs, security issues, and style problems"
```

Claude Code is thorough about edge cases that are easy to miss in self-review. Common catches include: missing null checks on function arguments, async functions that catch errors silently without re-throwing or logging, SQL queries that concatenate user input instead of using parameterized queries, and resource leaks where file handles or database connections are not closed in error paths.

Think of this as a lightweight code review from a collaborator who has read every file in your project and has time for thorough feedback on every change. The quality of the review improves the more context Claude Code has. make sure it has read the relevant files before asking for a review.

## Scripting and Automation

For repetitive tasks, create Claude Code scripts that automate common workflows. You can pair this with [Claude Code skills](/claude-skill-md-format-complete-specification-guide/) to make recurring automations repeatable. A simple script might look like:

```bash
#!/bin/bash
run-tests.sh
claude "Run the test suite and summarize any failures"
```

Make it executable and run it:

```bash
chmod +x run-tests.sh
./run-tests.sh
```

This approach integrates Claude Code into your existing development workflow without requiring manual intervention for routine tasks.

More sophisticated automation uses Claude Code's `--print` flag to capture its output and pipe it into other tools. For example, a pre-commit script that asks Claude Code to summarize what changed:

```bash
#!/bin/bash
.git/hooks/post-commit
SUMMARY=$(git diff HEAD~1 HEAD | claude --print "Summarize these changes in one sentence for a changelog entry")
echo "$SUMMARY" >> CHANGELOG.md
git add CHANGELOG.md
git commit --amend --no-edit
```

Or a script that generates a PR description from a branch diff:

```bash
#!/bin/bash
generate-pr-description.sh
BASE_BRANCH=${1:-main}
git diff "$BASE_BRANCH"...HEAD | claude --print "Write a clear pull request description summarizing these changes, including what was changed and why"
```

Claude Code also supports reading from stdin, which makes it composable with standard Unix tooling. The combination of natural language prompting and Unix pipes gives you a flexible automation toolkit that can handle tasks a traditional bash script would struggle with.

## Next Steps

- [dangerously skip permissions guide](/claude-code-dangerously-skip-permissions-guide/) — Complete guide to [--dangerously-skip-permissions flag](/claude-dangerously-skip-permissions-flag/) and safer alternatives
With your first project complete, explore more advanced capabilities:

- Multi-file generation: Ask Claude Code to scaffold entire features with multiple related files
- Debugging assistance: Paste error messages and let Claude Code trace through stack traces
- Documentation generation: Request docstrings and README updates
- Refactoring: Describe structural changes and let Claude Code implement them

The hello world project you created demonstrates the fundamentals. From here, integrate Claude Code into your actual development workflow, using it for code generation, review, debugging, and documentation tasks as they arise.

A practical way to deepen your Claude Code skills is to pick one recurring problem in your current project. maybe it is writing boilerplate for new API endpoints, or keeping test files in sync with implementation changes. and spend a week using Claude Code for that specific task. Repetition with a focused use case builds intuition for how to prompt effectively and where Claude Code saves the most time versus where it still needs human guidance.

The developers who get the most out of Claude Code treat it as a collaborative partner rather than an autocomplete tool. That means reviewing what it produces, correcting mistakes, and giving it feedback within the session. The more precisely you describe what you want and why, the more accurately Claude Code delivers it.

---

---

<div class="mastery-cta">

I'm a solo developer in Vietnam. 50K Chrome extension users. $500K+ on Upwork. 5 Claude Max subscriptions running agent fleets in parallel.

These are my actual CLAUDE.md templates, orchestration configs, and prompts. Not a course. Not theory. The files I copy into every project before I write a line of code.

**[See what's inside →](https://zovo.one/lifetime?utm_source=ccg&utm_medium=cta-default&utm_campaign=claude-code-first-project-tutorial-hello-world)**

$99 once. Free forever. 47/500 founding spots left.

</div>

Related Reading

- [Claude Code for Beginners: Complete Getting Started 2026](/claude-code-for-beginners-complete-getting-started-2026/)
- [Best Way to Scope Tasks for Claude Code Success](/best-way-to-scope-tasks-for-claude-code-success/)
- [How to Write Effective Prompts for Claude Code](/how-to-write-effective-prompts-for-claude-code/)
- [Getting Started Hub](/getting-started-hub/)

Built by theluckystrike. More at [zovo.one](https://zovo.one)



**Get started →** Generate your project setup with our [Project Starter](/starter/).

## See Also

**Configure permissions →** Build your settings with our [Permission Configurator](/permissions/).

**Try it:** Paste your error into our [Error Diagnostic](/diagnose/) for an instant fix.

- [Claude Code .env File Not Loaded — Fix (2026)](/claude-code-env-file-not-loaded-project-scope-fix/)
