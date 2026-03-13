---
layout: default
title: "Why Is My Claude Skill Not Showing Up? Fix Guide"
description: "Your Claude skill won't load? This fix guide covers the most common reasons skills fail to appear and how to resolve each issue quickly."
date: 2026-03-13
author: theluckystrike
---

# Why Is My Claude Skill Not Showing Up? Fix Guide

Claude skills extend the AI's capabilities with specialized workflows for tasks like frontend design, test-driven development, and document generation. When a skill fails to appear, the issue usually stems from a handful of common causes. This guide walks through each problem and provides concrete solutions you can apply immediately.

## Verify the Skill Is Properly Installed

The first step is confirming the skill actually exists in your Claude Code environment. Many users assume a skill is installed when it has not been added to the correct location.

Skills must be placed in the designated skills directory. For Claude Code, this is typically `~/claude-skills/` or the equivalent path in your project. Check that your skill file—usually a `.md` file containing the skill definition—exists in this directory:

```bash
# List all installed skills
ls -la ~/claude-skills/

# Search for a specific skill
ls ~/claude-skills/ | grep -i "skill-name"
```

If you installed a skill via a community repository, ensure you cloned the entire repository and not just a single file. Some skills depend on additional configuration files or helper scripts in adjacent directories.

## Check the Skill File Format

Claude skills require specific formatting to be recognized. A malformed skill definition will silently fail to load. Your skill file must start with the proper front matter and follow the expected structure.

A valid skill file looks like this:

```markdown
---
name: frontend-design
description: Generate UI components from descriptions
version: 1.0.0
---

# Frontend Design Skill

You are a frontend design assistant...
```

Common formatting mistakes include:

- Missing or incorrect front matter delimiters (`---` instead of `---`)
- Invalid YAML syntax in the front matter
- Non-UTF-8 characters in the file
- Incorrect file extension (must be `.md`)

If you edited the skill file manually, validate the YAML using a linter or online parser. Even a single extra space can prevent the skill from loading.

## Confirm Skill Naming and Invocation

The way you invoke a skill must match its registered name. Claude Code matches the skill name from the front matter, not the filename. If you try to invoke `/frontend-design` but the skill's `name` field is set to `ui-generator`, the invocation fails.

To check the registered name, open the skill file and locate the `name` field in the front matter:

```yaml
name: frontend-design  # This is what gets invoked
```

When you type `/frontend-design` in Claude Code, it searches for a skill with that exact name. Case sensitivity matters—`/Frontend-Design` will not work if the skill name is `frontend-design`.

## Reload or Restart Claude Code

Claude Code caches loaded skills at startup. If you add a new skill while Claude Code is running, it won't appear until you reload the skills or restart the application entirely.

Most installations support a reload command:

```bash
# Reload skills without full restart (if supported)
/reload-skills

# Otherwise, restart Claude Code
# On macOS: Quit and relaunch the app
# In CLI: Exit and restart the process
```

After reloading, verify the skill appears in the available skills list. Some versions of Claude Code provide a `/skills` or `/list-skills` command that displays all loaded skills.

## Check for Conflicting Skill Names

If you have multiple skills with identical or similar names, Claude Code may load only one or fail to load both. This commonly happens when testing community skills alongside custom skills you created.

Resolve conflicts by renaming one of the skills:

1. Open the skill file
2. Change the `name` field in the front matter to a unique identifier
3. Save and reload Claude Code

## Verify Dependencies Are Installed

Some skills depend on external tools or Python packages. The **pdf** skill, for instance, requires specific libraries to generate documents. The **tdd** skill may need testing frameworks installed in your project.

Check the skill's documentation or README for dependency requirements. Common dependencies include:

- Node.js packages (for JavaScript-based skills)
- Python packages (`uv pip install package-name`)
- System utilities (`ffmpeg`, `imagemagick`, etc.)

Install missing dependencies and verify they're accessible from your terminal:

```bash
# Check if a required command exists
which ffmpeg
which python3

# Check if a Python package is installed
python3 -c "import pdfkit; print('pdfkit installed')"
```

## Examine Error Logs

When a skill fails to load, Claude Code often writes diagnostic information to logs. These logs reveal the exact reason for the failure.

Access logs through:

- The application console or terminal output
- Log files in `~/.claude/logs/` or similar directories
- The `--verbose` flag when launching Claude Code

Common error messages and their meanings:

- **"Skill not found"**: The skill file doesn't exist or isn't in the correct directory
- **"Invalid skill format"**: The skill file has syntax errors in front matter or content
- **"Missing dependency"**: A required tool or package isn't installed
- **"Permission denied"**: The skill file isn't readable by your user account

## Skill-Specific Troubleshooting Examples

### frontend-design Skill

If the **frontend-design** skill doesn't appear, verify your project has the necessary directory structure:

```bash
mkdir -p ~/claude-skills/frontend-design
# Ensure the skill.md file is inside this directory
```

### pdf Skill

The **pdf** skill requires wkhtmltopdf or similar tools. Install them via:

```bash
# macOS
brew install wkhtmltopdf

# Ubuntu/Debian
sudo apt-get install wkhtmltopdf
```

### tdd Skill

For the **tdd** skill, ensure your project contains a test directory and testing framework configuration:

```bash
# Check for test framework
ls -la | grep -E "jest|vitest|pytest"
```

### supermemory Skill

The **supermemory** skill may require API keys or authentication tokens. Check that your environment variables are set correctly:

```bash
# Verify environment variables
echo $SUPERMEMORY_API_KEY
```

## Final Checklist

When your Claude skill still won't show up after trying these fixes, run through this checklist:

1. Skill file exists in `~/claude-skills/` or project skills directory
2. File has valid front matter with correct YAML syntax
3. Skill name in front matter matches your invocation
4. No duplicate skill names exist
5. All dependencies are installed and accessible
6. Claude Code has been restarted since adding the skill
7. No error messages in logs related to the skill

Most skill visibility issues resolve after checking these items. If a skill still won't load, the problem likely lies in the skill definition itself—review the skill author's documentation for specific requirements.

---

Built by theluckystrike — More at [zovo.one](https://zovo.one)
