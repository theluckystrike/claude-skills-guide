---
title: "Claude Skills Code Review Workflow"
description: "Build a SKILL.md that reviews PRs with structured output, severity levels, and subagent isolation using context fork and the Explore agent."
permalink: /claude-skills-code-review-workflow/
categories: [skills, 2026]
tags: [claude-code, claude-skills, code-review, pull-requests, subagents]
last_updated: 2026-04-19
---

## The Specific Situation

Your team reviews 15 pull requests per week. Each review takes 20-30 minutes of manual reading. You want Claude to do a first pass -- checking for security issues, convention violations, and missing tests -- before a human reviews. The skill should produce a structured report with severity levels and specific file:line references. It should run in isolation so it does not pollute the main conversation context.

## Technical Foundation

Skills with `context: fork` run in an isolated subagent. The skill content becomes the prompt for the subagent, which gets its own context window. Results are summarized and returned to the main conversation. This is ideal for code review: the subagent reads the diff, analyzes it, and returns a report without flooding your session with hundreds of lines of diff output.

The `agent: Explore` option gives the subagent read-only tools, preventing accidental modifications. Dynamic context injection with `!`command`` runs shell commands before the subagent sees the content, injecting the PR diff directly into the prompt.

## The Working SKILL.md

```yaml
---
name: review-pr
description: >
  Review the current pull request for quality, security, and
  conventions. Use when the user says "review this PR",
  "check the pull request", or "PR review".
disable-model-invocation: true
context: fork
agent: Explore
allowed-tools: Bash(gh *) Read Grep Glob
---

## Pull Request Context

- PR title and description: !`gh pr view --json title,body --jq '"\(.title)\n\n\(.body)"'`
- Changed files: !`gh pr diff --name-only`
- Full diff: !`gh pr diff`

## Review Instructions

Perform a structured code review of the pull request above.

### Check Categories

1. **Correctness**
   - Logic errors, off-by-one mistakes, null/undefined handling
   - Incorrect API usage or wrong parameter types
   - Race conditions or state management issues

2. **Security**
   - Hardcoded credentials, API keys, or tokens
   - Unvalidated user input reaching database queries
   - Missing authentication or authorization checks
   - Sensitive data in logs or error messages

3. **Conventions**
   - File naming and placement per project structure
   - Import ordering and grouping
   - Error handling patterns
   - Naming consistency

4. **Test Coverage**
   - New code paths without corresponding tests
   - Edge cases not covered by tests
   - Test assertions that do not verify meaningful behavior

### Output Format

```
## PR Review: [title]

### Summary
[2-3 sentence overview of the changes]

### Findings

#### BLOCK (must fix before merge)
- [file:line] [description]
  Fix: [specific suggested change]

#### WARN (should fix)
- [file:line] [description]
  Fix: [specific suggested change]

#### NOTE (consider)
- [file:line] [description]

### Verdict: APPROVE / CHANGES_REQUESTED / BLOCK
[1 sentence justification]
```

### Rules
- Reference specific file names and line numbers from the diff
- Every BLOCK finding must include a concrete fix suggestion
- If no issues found, say APPROVE with a note about what was checked
- Never approve if any security issue is found (use BLOCK)
```

## How the Subagent Pattern Works

When you invoke `/review-pr`:

1. Claude Code creates a forked context (new context window)
2. The `!`command`` blocks execute first, injecting PR data
3. The Explore subagent receives the rendered skill content as its prompt
4. The subagent reads the diff, analyzes changed files, and generates the review
5. Results are summarized and returned to your main session
6. The subagent context is discarded

This means the full PR diff never enters your main context window. Your conversation stays clean while the subagent does the heavy analysis work.

## Common Problems and Fixes

**gh CLI not authenticated**: The skill uses `gh pr diff` and `gh pr view`. Ensure `gh auth status` shows an authenticated session. Claude cannot authenticate on your behalf.

**Review misses files**: The `!`gh pr diff`` output may be very large. For PRs with 50+ changed files, the diff may exceed the subagent's context window. Add `| head -2000` to limit the diff size, or review files in batches.

**Subagent returns empty output**: `context: fork` requires explicit task instructions. If the body only contains guidelines without a clear task ("review this diff"), the subagent may produce nothing. The "Review Instructions" section above provides the explicit task.

**Review does not match project conventions**: The subagent loads CLAUDE.md alongside the skill content. Add your coding conventions to the project CLAUDE.md so the review references them.

## Production Gotchas

The Explore agent type has read-only tools. It cannot modify files, commit code, or push changes. This is a safety feature for code review -- you want analysis, not action. If you need the reviewer to also apply fixes, use `agent: general-purpose` instead, but be cautious about automated modifications.

Dynamic context injection (`!`command``) runs before Claude sees the skill. If the command fails (e.g., not on a PR branch), the output is the error message, which Claude then tries to interpret. Add error handling in the commands: `gh pr diff 2>/dev/null || echo "No PR found on current branch"`.

The `/simplify` bundled skill already performs a form of code review (three parallel review agents). Consider whether the built-in skill meets your needs before building a custom review skill. The advantage of a custom skill is project-specific review criteria.

## Checklist

- [ ] `context: fork` and `agent: Explore` set in frontmatter
- [ ] `disable-model-invocation: true` to prevent accidental triggers
- [ ] Dynamic context injection commands tested manually first
- [ ] Review output format includes file:line references
- [ ] Error handling for cases where no PR exists on current branch

## Related Guides

- [How to Share Claude Skills with Your Team](/how-to-share-claude-skills-with-team/)
- [Team SKILL.md Conventions Style Guide](/team-skill-md-conventions-style-guide/)
- [Claude Skills CI/CD Patterns](/claude-skills-ci-cd-patterns/)
