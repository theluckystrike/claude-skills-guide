---
layout: default
title: "Build Your Own Claude Code Skill (2026)"
description: "Step-by-step guide to building a custom Claude Code skill with CLAUDE.md instructions, hooks, and slash command integration."
permalink: /how-to-build-your-own-claude-code-skill-2026/
date: 2026-04-20
last_tested: "2026-04-22"
---

# Build Your Own Claude Code Skill (2026)

A Claude Code skill is a reusable set of instructions that modifies how Claude Code behaves for specific tasks. Skills range from simple CLAUDE.md rules to full frameworks with hooks, commands, and agent profiles. This guide walks through building each type.

## What Is a Skill?

A skill is any persistent instruction set that Claude Code follows across sessions. Skills can be:

- **Behavioral rules** in CLAUDE.md (simplest)
- **Slash commands** that trigger specific workflows
- **Hook scripts** that run automatically on events
- **Agent profiles** that configure Claude Code for specialized tasks

The [awesome-claude-code-toolkit](https://github.com/rohitg00/awesome-claude-code-toolkit) catalogs 35 community-built skills, and the [claude-code-templates](https://github.com/davila7/claude-code-templates) library includes 600+ agent templates you can study as examples.

## Level 1: CLAUDE.md Skill (5 Minutes)

The simplest skill is a block of instructions in your CLAUDE.md file. Here is a "Code Reviewer" skill:

```markdown
## Skill: Code Reviewer
When asked to review code:
1. Check for security issues first (SQL injection, XSS, auth bypass)
2. Check for performance issues (N+1 queries, missing indexes, memory leaks)
3. Check for maintainability (naming, complexity, test coverage)
4. Format findings as:
   - CRITICAL: Must fix before merge
   - WARNING: Should fix, not blocking
   - SUGGESTION: Nice to have
5. Include line numbers for each finding
6. Suggest specific fixes, not just "this is bad"
```

### How to Install
Drop this into your project's `CLAUDE.md` or into `~/.claude/CLAUDE.md` for global availability.

### How to Use
Start a Claude Code session and say: "Review this file" or "Review the changes in this PR."

## Level 2: Slash Command Skill (15 Minutes)

Slash commands trigger specific workflows. They live in your `.claude/commands/` directory.

Create `.claude/commands/review.md`:

```markdown
Review the code changes in this project.

Steps:
1. Run `git diff HEAD~1` to see recent changes
2. For each changed file:
   - Read the file
   - Check for security issues
   - Check for performance issues
   - Check for style violations per CLAUDE.md
3. Output a structured review:

## Review: [filename]
### Security
- [findings or "No issues"]
### Performance
- [findings or "No issues"]
### Style
- [findings or "No issues"]
### Verdict: APPROVE / REQUEST CHANGES
```

### How to Install
Place the file in `.claude/commands/` (project-level) or `~/.claude/commands/` (user-level).

### How to Use
In a Claude Code session, type `/review` to invoke the command.

## Level 3: Hook-Based Skill (30 Minutes)

Hooks run scripts automatically when Claude Code performs actions. They are defined in `.claude/settings.json`.

Here is a skill that validates TypeScript types after every file write:

```json
{
  "hooks": {
    "post-tool-use": [
      {
        "tool": "write_file",
        "command": "npx tsc --noEmit 2>&1 | head -20"
      },
      {
        "tool": "edit_file",
        "command": "npx tsc --noEmit 2>&1 | head -20"
      }
    ]
  }
}
```

### More Hook Examples

**Auto-lint after writes:**
```json
{
  "hooks": {
    "post-tool-use": [{
      "tool": "write_file",
      "command": "npx eslint --fix $FILE && npx prettier --write $FILE"
    }]
  }
}
```

**Run tests after changes:**
```json
{
  "hooks": {
    "post-tool-use": [{
      "tool": "write_file",
      "command": "npx vitest run --reporter=verbose 2>&1 | tail -10"
    }]
  }
}
```

## Level 4: Agent Profile Skill (1 Hour)

An agent profile combines CLAUDE.md rules, commands, and hooks into a specialized persona. The [SuperClaude Framework](https://github.com/SuperClaude-Org/SuperClaude_Framework) (22K+ stars) provides 16 such profiles.

Here is a custom "Security Auditor" agent profile:

### CLAUDE.md Section
```markdown
## Agent: Security Auditor
You are operating in security audit mode. Your priorities:
1. Identify vulnerabilities in every piece of code you see
2. Check for OWASP Top 10 issues
3. Verify input validation on all boundaries
4. Check authentication and authorization logic
5. Flag any hardcoded secrets or credentials
6. Review dependency versions for known CVEs
```

### Command: `.claude/commands/audit.md`
```markdown
Perform a security audit of this project.

1. List all API endpoints and their authentication requirements
2. Check each endpoint for input validation
3. Review database queries for injection vulnerabilities
4. Check for hardcoded secrets (grep for API_KEY, SECRET, PASSWORD, TOKEN)
5. Run `npm audit` and report findings
6. Output a Security Report with severity ratings
```

### Hook: Auto-Security-Check
```json
{
  "hooks": {
    "post-tool-use": [{
      "tool": "write_file",
      "command": "grep -rn 'API_KEY\\|SECRET\\|PASSWORD\\|TOKEN' $FILE | grep -v '.env' | head -5"
    }]
  }
}
```

## Publishing Your Skill

Once your skill is tested, share it with the community:

1. Create a GitHub repository with your skill files
2. Include a README with installation instructions and examples
3. Test against the current Claude Code version
4. Submit a PR to [awesome-claude-code](https://github.com/hesreallyhim/awesome-claude-code) to get listed
5. Tag your repo with `claude-code-skill` for discoverability

## Skill Design Principles

The [andrej-karpathy-skills](https://github.com/forrestchang/andrej-karpathy-skills) repo (72K+ stars) distills skill design into four principles:

1. **Don't Assume** — Be explicit about what to do and what NOT to do
2. **Don't Hide Confusion** — Tell the skill user to ask when unclear
3. **Surface Tradeoffs** — Document limitations and alternatives
4. **Goal-Driven Execution** — Each skill should have one clear purpose

## FAQ

**Try it:** Browse 155+ skills in our [Skill Finder](/skill-finder/).

### How long should a skill be?
CLAUDE.md skills: 50-200 words. Commands: 100-500 words. Agent profiles: up to 1,000 words. Longer skills consume more context window.

### Can I combine multiple skills?
Yes. Put each skill in its own section of CLAUDE.md. Watch for contradictions between skills.

### Do skills persist across sessions?
CLAUDE.md and command files persist automatically. Session-specific instructions do not. Always put reusable rules in files.

### How do I test a skill?
Create a test project with known issues that the skill should catch. Run the skill and verify it catches them. The [claude-code-ultimate-guide](https://github.com/FlorianBruniaux/claude-code-ultimate-guide) has 271 quiz questions you can adapt as test cases.

### Can I use skills in API mode?
Yes. CLAUDE.md files are read in both interactive and API mode. Slash commands require interactive mode.

For more on skills architecture, see the [skills vs hooks vs commands comparison](/claude-code-skills-vs-hooks-vs-commands-2026/). Browse existing skills at the [skills directory](/claude-skills-directory-where-to-find-skills/). For hook configuration details, read the [hooks guide](/understanding-claude-code-hooks-system-complete-guide/).
