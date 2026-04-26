---
layout: default
title: "Fix Claude Code Skill Not Found Error (2026)"
description: "Fix the tool not found error in Claude Code skills. Resolve skill file loading errors, name mismatches, and sandbox restrictions with exact steps."
date: 2026-03-13
last_modified_at: 2026-04-17
categories: [troubleshooting]
tags: [claude-code, claude-skills, troubleshooting, tools]
author: "Claude Skills Guide"
reviewed: true
score: 8
permalink: /claude-code-skill-tool-not-found-error-solution/
last_tested: "2026-04-21"
geo_optimized: true
---
# Claude Code Skill Tool Not Found Error Solution

The tool not found error in Claude Code skills typically means Claude cannot find the skill file itself. Skills are plain Markdown files. they do not declare tools in front matter, and there is no `tools:` configuration field. This guide covers how to fix skill file loading errors.

## Understanding "Not Found" Errors

Skill file not found:
```
Error: Skill 'tdd' not found
Unknown skill: /tdd
```
Claude looked for `tdd.md` in the skills directories and did not find it. The fix is to ensure the file exists in `~/.claude/skills/`.

If Claude mentions a tool is unavailable during a skill session, that is a session-level permissions issue, not a skill configuration issue. Skills cannot declare or restrict which tools Claude uses.

## Fixing Type 1: Skill File Not Found

## Step 1: Verify the file exists

```bash
Check global skills
ls ~/.claude/skills/

Check project-local skills
ls .claude/skills/ 2>/dev/null
```

## Step 2: Confirm the filename matches

Skill names are case-sensitive. `/tdd` maps to `tdd.md`, not `TDD.md` or `Tdd.md`.

```bash
ls ~/.claude/skills/ | grep -i tdd
Must output exactly: tdd.md
```

## Step 3: Install the missing skill

If the file is absent, place it in the correct directory:

```bash
Install a skill globally
cp ~/downloads/tdd.md ~/.claude/skills/tdd.md
chmod 644 ~/.claude/skills/tdd.md
```

## Step 4: Check for a custom skills directory

Your `settings.json` may redirect skill loading:

```bash
cat ~/.claude/settings.json | python3 -m json.tool | grep -A2 skill
```

If `skillsDir` is set, skills must live in that path, not `~/.claude/skills/`.

## Tool Access Issues During Skill Sessions

Skills do not configure which tools Claude can use. If Claude cannot use a specific tool (like `WebSearch` or `Bash`) during a skill session, check:

1. Session permissions. In your Claude Code session, type `What tools do you have available?` to see the current tool list
2. Network access. `WebSearch` requires network access. If your environment is offline, this tool is unavailable regardless of which skill is active
3. Claude Code settings. Tool availability is controlled by `~/.claude/settings.json`, not skill files

## Permission restrictions that surface as "not found"

Claude Code's permissions system controls what tools can access. If a tool requires permissions that haven't been granted, it may surface as "not found" rather than explicitly stating a permission error. This is especially relevant for tools that access files, run shell commands, or interact with network resources. Check `~/.claude/settings.json` and verify the necessary permission flags are set.

## MCP Server Configuration Issues

MCP servers extend Claude Code's capabilities by providing additional tools and integrations. When an MCP server is not properly configured or is not running, any tools it provides will trigger a "not found" error.

Diagnose MCP server issues:

1. Verify the MCP server process is running
2. Check that all server paths in your configuration files are correct and that the server binaries are executable
3. Review server logs for connection errors or authentication failures
4. If you recently updated Claude Code or an MCP server, check for version compatibility. rolling back to a previous version is necessary if a recent update introduced breaking changes

External tool dependencies (pdf, docx skills)

The [`pdf` skill](/best-claude-skills-for-data-analysis/), `docx` skill, and similar document-processing skills require external binaries. These are separate from Claude Code's built-in tools.

For the `pdf` skill:
```bash
Check if pdftotext is available
which pdftotext || brew install poppler # macOS
which pdftotext || apt install poppler-utils # Debian/Ubuntu
```

For the `docx` skill:
```bash
which pandoc || brew install pandoc
which pandoc || apt install pandoc
```

When the external binary is missing, the skill loads but the tool call fails with a "command not found" error that surfaces as a tool error.

The `supermemory` Skill: Storage Issues

The [`supermemory` skill](/claude-skills-token-optimization-reduce-api-costs/) writes session memory to disk. If the storage path is on a read-only filesystem, writes fail. Fix this by explicitly directing the skill to a writable path:

```
/supermemory
Save memory to ~/notes/project-memory.md
```

Or set the environment variable:
```bash
export CLAUDE_MEMORY_PATH="$HOME/.claude-memory"
mkdir -p ~/.claude-memory
```

The `frontend-design` Skill: Missing Linter Tools

The [`frontend-design` skill](/best-claude-code-skills-for-frontend-development/) optionally calls ESLint and Prettier for output validation. If these are not installed in your project, the validation step produces a tool-not-found error.

```bash
Install project-local (preferred)
npm install --save-dev eslint prettier

Or install globally
npm install -g eslint prettier
```

## Diagnostic Command

Run this to check all skills and verify their front matter parses correctly:

```bash
python3 << 'EOF'
import yaml, os, glob

for path in glob.glob(os.path.expanduser('~/.claude/skills/*.md')):
 content = open(path).read()
 parts = content.split('---')
 if len(parts) < 3:
 print(f'NO FRONT MATTER: {os.path.basename(path)}')
 continue
 try:
 data = yaml.safe_load(parts[1])
 name = os.path.basename(path)
 desc = data.get('description', '(no description)')
 print(f'{name}: description={desc!r}')
 except Exception as e:
 print(f'PARSE ERROR {os.path.basename(path)}: {e}')
EOF
```

## Minimum Working Skill File

If you want to rule out a tool declaration issue entirely, strip the skill to minimum:

```markdown
---
description: "A minimal test skill for debugging"
---

Test Skill

This is a minimal skill. Claude will use default tool access.
```

If the stripped skill works but the original does not, a tool declaration in the original is causing the error.

## Advanced Troubleshooting Techniques

When basic troubleshooting does not resolve the issue:

- Enable debug logging in Claude Code to get more detailed error messages that reveal underlying issues not visible in standard output
- Isolate the problem by temporarily disabling other skills and MCP servers to determine whether a conflict between components is causing the error
- Community resources. The Claude Code community forums and GitHub issues pages are useful for persistent problems. When posting for help, include your exact error messages, Claude Code version, and a description of your skill/MCP setup

## Prevention

- Keep skills and MCP servers updated. developers regularly release compatibility fixes
- Document your skill configuration: which skills provide which tools, and what permissions each requires
- Test new skills in a development environment before using them in production
- Use version control for your skill configuration files so you can roll back if a change introduces problems

## Summary

- Skill file not found: check `~/.claude/skills/`, verify filename case, confirm no custom `skillsDir`
- Tool not found within skill: check YAML `tools` list for case mismatches, verify the tool is available in your session type, install external binaries for `pdf`/`docx` skills
- When in doubt: strip the skill to minimum front matter and add declarations back one by one

---


**Try it:** Paste your error into our [Error Diagnostic](/diagnose/) for an instant fix.
---

<div class="mastery-cta">

This site was built by 5 autonomous agents running in tmux while I was in Bali. 2,500 articles. Zero manual work. 100% quality gate pass rate.

The orchestration configs, sprint templates, and quality gates that made that possible are in the Zovo Lifetime bundle. Along with 16 CLAUDE.md templates and 80 tested prompts.

**[See how the pipeline works →](https://zovo.one/lifetime?utm_source=ccg&utm_medium=cta-skills&utm_campaign=claude-code-skill-tool-not-found-error-solution)**

$99 once. I'm a solo dev in Da Nang. This is how I scale.

</div>

Related Reading

- [Skill .md File Format Explained With Examples](/claude-skill-md-format-complete-specification-guide/). The authoritative reference for the `tools` field and all other YAML front matter fields in skill files
- [How to Write a Skill .md File for Claude Code](/how-to-write-a-skill-md-file-for-claude-code/). A hands-on walkthrough for writing skill files that correctly declare their tool dependencies
- [Claude Skills Token Optimization: Reduce API Costs](/claude-skills-token-optimization-reduce-api-costs/). How skill design affects token consumption and API costs

Built by theluckystrike. More at [zovo.one](https://zovo.one)


**Find the right skill →** Browse 155+ skills in our [Skill Finder](/skill-finder/).

