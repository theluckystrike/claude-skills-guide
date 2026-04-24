---
title: "Create Custom Slash Commands for Claude (2026)"
description: "Build custom slash commands for Claude Code using markdown files in .claude/commands/. Step-by-step with argument handling and practical examples."
permalink: /how-to-create-custom-slash-command-claude-2026/
last_tested: "2026-04-22"
render_with_liquid: false
---

# How to Create Custom Slash Commands for Claude Code (2026)

Custom slash commands let you define reusable prompts and workflows that you trigger with a single `/command` in Claude Code. Here is how to create them from scratch.

## Prerequisites

- Claude Code installed
- A project directory
- Text editor

## Step 1: Create the Commands Directory

```bash
mkdir -p /path/to/your/project/.claude/commands
```

Claude Code looks for command files in `.claude/commands/` relative to your project root.

## Step 2: Create a Simple Command

Create a markdown file for your command. The filename (without extension) becomes the command name.

Example: a code review command.

Create `.claude/commands/review.md`:

```markdown
Review the code in the current file for:

1. Logic errors and edge cases
2. Performance issues
3. Security vulnerabilities
4. Code style consistency

For each issue found, specify:
- File and line number
- Severity (critical, warning, info)
- Suggested fix

If no issues are found, confirm the code looks good.
```

This creates the `/review` command. When you type `/review` in Claude Code, it sends this prompt.

## Step 3: Add Argument Support

Commands can accept arguments using the `$ARGUMENTS` placeholder.

Create `.claude/commands/explain.md`:

```markdown
Explain the following concept in the context of this codebase:

$ARGUMENTS

Include:
- What it does
- Where it appears in the code
- Why it was implemented this way
- Any potential improvements
```

Usage in Claude Code:
```
/explain the authentication middleware
```

The text after `/explain` replaces `$ARGUMENTS`.

## Step 4: Create a Multi-Step Command

Commands can include multi-step workflows.

Create `.claude/commands/fix-and-test.md`:

```markdown
For the issue described below:

$ARGUMENTS

Follow these steps:
1. Identify the root cause by reading relevant source files
2. Implement the fix with minimal changes
3. Add or update tests that cover the fix
4. Run the test suite to verify nothing is broken
5. Summarize what was changed and why
```

## Step 5: Test Your Commands

Start Claude Code in your project:

```bash
claude
```

Type `/` and you should see your custom commands listed alongside built-in ones. Run each command to verify it works as expected:

```
/review
/explain the database connection pooling
/fix-and-test the login timeout error
```

## Advanced: Project vs User Commands

**Project commands** (`.claude/commands/` in your project) are available only in that project and can be committed to version control for team sharing.

**User commands** (`~/.claude/commands/`) are available across all projects for personal productivity commands.

## Practical Command Examples

**Quick test runner**:
`.claude/commands/test-this.md`:
```markdown
Run the tests related to the file I am currently working on. If tests fail, analyze the failure and suggest a fix. Do not fix automatically — explain first.
```

**Documentation generator**:
`.claude/commands/doc.md`:
```markdown
Generate documentation for:

$ARGUMENTS

Include: function signatures, parameter descriptions, return values, usage examples, and edge cases. Format as JSDoc/docstring comments in the source file.
```

**Security audit**:
`.claude/commands/security.md`:
```markdown
Audit the current project for security issues. Check for:
- Hardcoded secrets or API keys
- SQL injection vulnerabilities
- XSS attack vectors
- Insecure dependencies
- Missing input validation

Report findings with severity levels and remediation steps.
```

## Building a Command Library

Over time, you will accumulate commands for your most common tasks. Organize them effectively:

**Naming conventions**: Use consistent prefixes: `review-*.md` for review commands, `gen-*.md` for generation commands, `check-*.md` for validation commands. This groups related commands in the `/` autocomplete menu.

**Documentation inside commands**: Add a comment at the top of each command file explaining what it does and how to use it. This helps teammates who discover the command:

```markdown
<!-- /deploy-staging: Deploys the current branch to staging. No arguments needed. -->
Run the staging deployment for this project:
1. Run the test suite first
2. Build the project
3. Deploy to the staging environment
4. Run smoke tests against staging
5. Report the staging URL
```

**Version control**: Commit your `.claude/commands/` directory to git. This shares commands with your team and tracks changes over time.

## Common Command Patterns

Here are patterns that work well across many projects:

**The diagnostic command** — Checks project health:
```markdown
Run a diagnostic check on this project:
1. Check that all dependencies are installed
2. Verify the database connection
3. Run the linter
4. Run the test suite
5. Check for environment variable issues
Report results as PASS/FAIL for each check.
```

**The onboarding command** — Helps new developers:
```markdown
Explain this project to a new developer:
1. What the project does (one paragraph)
2. Tech stack and key dependencies
3. How to run it locally
4. Important files and directories
5. Common development tasks
Base this on the actual codebase, not assumptions.
```

**The release notes command** — Generates changelogs:
```markdown
Generate release notes for the changes since the last git tag:
$ARGUMENTS

Format:
- Group by: Features, Bug Fixes, Breaking Changes
- Each entry: brief description + PR/commit reference
- Tone: professional, user-facing
```

## Troubleshooting

**Command not appearing**: Verify the file is in `.claude/commands/` (not `.claude/command/` or other typos). The file must have a `.md` extension. Restart Claude Code after adding new commands.

**Arguments not working**: Use `$ARGUMENTS` exactly (uppercase, with dollar sign). Claude Code replaces this placeholder with everything typed after the command name. If no arguments are provided, `$ARGUMENTS` is replaced with an empty string.

**Command produces poor results**: Refine the prompt in the markdown file. Be specific about output format, steps to follow, and what to include or exclude. Test with different inputs and iterate on the wording.

**Too many commands clutter the menu**: Organize with prefixes (review-, gen-, check-) or consolidate related commands into one command with argument-based branching.

## Next Steps

- Browse [Claude Code Templates](/how-to-install-claude-code-templates-cli-2026/) for pre-built commands
- Add [hooks](/understanding-claude-code-hooks-system-complete-guide/) that trigger alongside your commands
- Check the [skills directory](/claude-skills-directory-where-to-find-skills/) for community-shared commands
- Read [CLAUDE.md best practices](/claude-md-best-practices-10-templates-compared-2026/) for complementary configuration
