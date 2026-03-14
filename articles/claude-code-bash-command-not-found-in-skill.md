---
layout: default
title: "Claude Code Bash Command Not Found in Skill."
description: "Fix 'command not found' errors when using bash in Claude Code skills. Learn why skills fail to execute shell commands and how to resolve path."
date: 2026-03-14
categories: [troubleshooting]
tags: [claude-code, claude-skills, bash, troubleshooting, errors]
author: theluckystrike
reviewed: false
score: 0
permalink: /claude-code-bash-command-not-found-in-skill/
---
{% raw %}



# Claude Code Bash Command Not Found in Skill: Troubleshooting Guide

If you've encountered a "command not found" error when using bash within a Claude Code skill, you're not alone. This is one of the most common issues skill authors face when their carefully crafted skill fails to execute shell commands. In this guide, we'll explore why this happens and how to fix it.

## Understanding the Problem

When you create a Claude Code skill that uses the `Bash` tool, you might expect it to have access to the same shell environment you have in your terminal. However, skills operate in a slightly different context that can lead to unexpected "command not found" errors. Let's break down the common causes and solutions.

## Common Causes of Command Not Found Errors

### 1. The Bash Tool Is Not Declared in Skill Front Matter

The most frequent cause of command failures is simply forgetting to declare the `Bash` tool in your skill's front matter. Without this declaration, Claude Code won't allow the skill to execute any shell commands.

```yaml
---
name: my-skill
description: A skill that runs shell commands
tools:
  - Read
  - Write
  - Bash
---

Your skill description and instructions go here.
```

If you omit `Bash` from the tools list, Claude will either fail silently or report that the command cannot be executed. Always verify your front matter includes all tools your skill needs.

### 2. Path Variables Not Available in Skill Context

Even when the `Bash` tool is available, your skill may not have access to the same PATH environment variable that your terminal uses. This is particularly common on macOS where the shell profile (`~/.zshrc`) sets up paths that may not be inherited by Claude Code's subprocess environment.

**The Fix:** Always use absolute paths or explicitly set PATH in your skill instructions:

```
When running commands, use absolute paths. For example:
- Instead of: npm install
- Use: /usr/local/bin/npm install

Or set PATH explicitly at the start of your skill:

First, run: export PATH="/usr/local/bin:/usr/bin:/bin:$PATH"
```

### 3. Shell-Specific Commands Not Available

Some commands are shell-specific. For example, bash built-ins like `source` (for sourcing files) or certain zsh-specific commands won't work in all environments. Claude Code typically uses `/bin/sh` or `bash` as the default shell, which may differ from your interactive shell.

**Solution:** Use POSIX-compliant commands or explicitly invoke the correct shell:

```bash
# Instead of: source ~/.bashrc
# Use: . ~/.bashrc  (POSIX-compatible)

# Or explicitly use bash:
bash -c 'source ~/.bashrc && your-command'
```

### 4. Environment Variables Not Set

Skills don't automatically inherit environment variables from your shell profile. Variables like `NVM_DIR`, `RVM_PATH`, or custom PATH additions from your `.zshrc` or `.bashrc` won't be available unless explicitly set.

**How to handle this:**

```
Before running any Node.js commands, ensure nvm is loaded:
Run: export NVM_DIR="$HOME/.nvm" && [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

Then you can use: nvm use default
```

### 5. Skills Running in Different Working Directory

Your skill might be executing commands from a different working directory than expected. This can cause issues if your commands rely on relative paths or project-specific tooling.

**Solution:** Always verify and set your working directory explicitly:

```
Before running any commands, first check your current directory:
Run: pwd

If not in the project root, navigate there:
Run: cd /path/to/your/project
```

## Practical Examples

### Example 1: Creating a Node.js Build Skill

Here's a properly configured skill that runs Node.js build commands:

```yaml
---
name: node-build
description: Builds Node.js projects
tools:
  - Read
  - Bash
---

This skill builds Node.js projects reliably.

1. First, navigate to the project directory: cd /your/project/path
2. Ensure Node.js is available: /usr/local/bin/node --version
   (or use the full path to your node installation)
3. Install dependencies: /usr/local/bin/npm install
4. Run the build: /usr/local/bin/npm run build

Always use absolute paths to node and npm to avoid PATH issues.
```

### Example 2: Python Virtual Environment Skill

```yaml
---
name: python-run
description: Runs Python scripts in virtual environment
tools:
  - Read
  - Write
  - Bash
---

This skill activates a Python virtual environment and runs scripts.

1. Navigate to your project: cd /path/to/project
2. Activate the virtual environment: source venv/bin/activate
3. Verify Python: python3 --version
4. Run your script: python3 your_script.py

If the virtual environment doesn't exist, create it:
- python3 -m venv venv
- source venv/bin/activate
- pip install -r requirements.txt
```

### Example 3: Docker Commands in Skills

```yaml
---
name: docker-manager
description: Manages Docker containers
tools:
  - Read
  - Bash
---

This skill helps manage Docker containers.

1. Verify Docker is available: /usr/local/bin/docker --version
2. List running containers: /usr/local/bin/docker ps
3. Build images: /usr/local/bin/docker build -t your-image:latest .

Always use absolute paths to Docker and related tools.
```

## Debugging Tips

When you encounter command not found errors, follow this diagnostic process:

1. **Check the skill's tools declaration** - Verify `Bash` is listed in the front matter
2. **Test with absolute paths** - Replace `command` with `/full/path/to/command`
3. **Print your PATH** - Run `echo $PATH` in the skill to see what's available
4. **Check the current directory** - Run `pwd` to confirm your location
5. **Test environment variables** - Run `env` to see available environment variables

## Best Practices for Reliable Shell Execution

To minimize command not found errors in your skills:

- **Always use absolute paths** for executables
- **Declare all required tools** in the front matter
- **Set up the environment explicitly** at the start of your skill
- **Include PATH setup commands** if your tooling requires specific paths
- **Test your skill** after writing it to ensure commands execute correctly

## Summary

The "command not found" error in Claude Code skills typically stems from three root causes: missing tool declarations in front matter, unavailable PATH variables, and missing environment configurations. By using absolute paths, declaring the Bash tool, and setting up your environment explicitly within the skill, you can create reliable skills that execute shell commands consistently.

Remember: skills run in a constrained environment that doesn't automatically inherit your shell's configuration. Always explicitly set up the environment your commands need, and use absolute paths whenever possible.

---

## Related Reading

- [Advanced Claude Skills with Tool Use and Function Calling](/claude-skills-guide/advanced-claude-skills-with-tool-use-and-function-calling/) — Master tool configuration in skills
- [Best Claude Code Skills for Developers in 2026](/claude-skills-guide/best-claude-skills-for-developers-2026/) — Essential skills for development workflows
- [Claude Skill MD Format Complete Specification Guide](/claude-skills-guide/claude-skill-md-format-complete-specification-guide/) — Complete skill authoring reference

Built by theluckystrike — More at [zovo.one](https://zovo.one)
{% endraw %}