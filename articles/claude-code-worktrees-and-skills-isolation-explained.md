---
layout: default
title: "Claude Code Worktrees and Skills (2026)"
description: "Claude Code Worktrees and Skills — practical guide with working examples, tested configurations, and tips for developer workflows."
date: 2026-03-13
last_modified_at: 2026-04-17
categories: [advanced]
tags: [claude-code, claude-skills, worktrees, git, isolation, parallel-work]
author: "Claude Skills Guide"
reviewed: true
score: 8
permalink: /claude-code-worktrees-and-skills-isolation-explained/
geo_optimized: true
---

# Claude Code Worktrees and Skills Isolation

Claude Code's worktree feature lets you run agents in isolated git worktrees. separate working directories checked out from the same repository. so parallel work does not interfere with your main branch. Understanding how this interacts with skills is essential for multi-agent and parallel-workflow setups.

What Is a Worktree?

A git worktree is an additional working directory associated with the same git repository. Unlike cloning, which creates a full copy of the repository, a worktree shares the same `.git` object store with the main repository but has its own checked-out files and branch.

```bash
Create a worktree manually
git worktree add .claude/worktrees/feature-auth feature/auth-system

Claude Code creates this for you with:
/worktree feature-auth
```

The resulting directory structure:
```
myproject/ <- main worktree (your working directory)
 .git/
 .claude/
 worktrees/
 feature-auth/ <- Claude's isolated worktree
 .git <- file pointing back to main .git
 src/
 ...
```

## How Claude Code Uses Worktrees

When you invoke `/worktree {name}` in Claude Code, it:

1. Creates a new worktree at `.claude/worktrees/{name}`
2. Checks out a new branch named after the worktree
3. Starts a Claude Code session with that worktree as the project root
4. Any file operations in that session are scoped to the worktree directory

The key isolation benefit: Claude can modify files freely in the worktree without affecting your main branch or any other worktree.

## What Gets Isolated

Isolated per worktree:
- All files in the working tree (source code, config files, etc.)
- The git branch and staging area
- The Claude Code session and conversation history
- Tool call history for that session

Shared across worktrees:
- The git object store (commits, trees, blobs)
- Git hooks (`.git/hooks/`)
- The underlying git history

Partially shared:
- `.claude/skills/`. skill files are read from the project root `.claude/skills/`, not from the worktree
- `.claude/settings.json`. session settings come from the main project, not the worktree
- MCP servers. registered globally, not per-worktree

## Skills and Worktrees: The Critical Detail

Skills are read from `.claude/skills/` relative to the main project root, not from the worktree. This means:

1. All worktrees share the same set of skills
2. Changes to skills affect all worktrees immediately (since they read from the same path)
3. A skill cannot be scoped to a specific worktree through normal placement

This is by design. you do not want different worktrees running different versions of your [`/tdd` skill](/best-claude-skills-for-developers-2026/). It creates consistency across parallel workstreams.

## Skills and Relative File References

When a skill's instructions reference project files, Claude resolves those paths relative to the current working directory at invocation time. which in a worktree session is the worktree directory. This means Claude naturally reads the worktree's version of the files.

To make this explicit, write skill instructions that reference files using relative paths:

```
When writing tests, first read src/test-utils/setup.ts for the test helper patterns,
and docs/testing-guide.md for project testing conventions.
```

`context_files` is not a valid skill front matter field. do not add it to your `.md` skill files. Use prose instructions in the skill body instead.

When Claude is working in a worktree branch for a feature, it reads that branch's version of the referenced files automatically.

## Designing Skills for Worktree Use

Skills that will be used in worktrees need to be explicit about which directory they are operating in.

## Avoid Hardcoded Absolute Paths

Bad:
```
Write test files to /Users/dev/myapp/src/tests/
```

Good:
```
Write test files to the appropriate __tests__ directory relative to the source file.
Use the project root as the base: {project_root}/src/
```

The `{project_root}` template variable resolves to the current worktree's root, not the main project root.

## State Files and Worktrees

If your skill uses state files, write them to the worktree directory:

```
Write state files to .claude/state/ within the current project root.
In a worktree, this will be {project_root}/.claude/state/. keeping state isolated per worktree.
```

Each worktree has its own `.claude/state/` directory, so task state does not bleed across parallel workstreams.

## Parallel Skill Execution via Worktrees

The most powerful use of worktrees is running the same skill across multiple branches in parallel. You can set this up with a shell script that creates worktrees for each feature branch and then runs Claude Code in print mode in each:

```bash
#!/bin/bash
Prepare parallel worktrees for feature branches

FEATURES=("auth-system" "payment-flow" "user-profile")

for FEATURE in "${FEATURES[@]}"; do
 # Create worktree from feature branch
 git worktree add ".claude/worktrees/${FEATURE}" "feature/${FEATURE}" 2>/dev/null || true
 mkdir -p ".claude/worktrees/${FEATURE}/.claude/results"
 echo "Worktree ready: .claude/worktrees/${FEATURE}"
done
```

Then run Claude Code in each worktree. Since Claude Code is interactive, you would open each worktree as a separate Claude Code session and invoke the `/tdd` skill there. The [`supermemory` skill](/claude-skills-token-optimization-reduce-api-costs/) can preserve context across these parallel sessions.

## Worktree Cleanup

Worktrees accumulate. Build cleanup into your workflow:

```bash
List all Claude worktrees
git worktree list | grep ".claude/worktrees"

Remove a specific worktree after work is merged
git worktree remove .claude/worktrees/feature-auth

Remove all worktrees whose branches have been merged to main
git worktree list --porcelain | grep "worktree" | awk '{print $2}' | \
 grep ".claude/worktrees" | while read wt; do
 branch=$(git -C "$wt" branch --show-current)
 if git merge-base --is-ancestor "$branch" main; then
 echo "Removing merged worktree: $wt"
 git worktree remove "$wt"
 fi
 done
```

## The WorktreeCreate Hook

Claude Code has a `WorktreeCreate` hook that fires when a new worktree is created via `/worktree`. Use it to initialize the worktree environment:

```json
{
 "hooks": {
 "WorktreeCreate": [
 {
 "matcher": {},
 "command": ".claude/hooks/init-worktree.sh"
 }
 ]
 }
}
```

The init script receives the worktree path via `$WORKTREE_PATH`:

```bash
#!/bin/bash
.claude/hooks/init-worktree.sh
cd "$WORKTREE_PATH"

Create necessary directories
mkdir -p .claude/state
mkdir -p .claude/results

Install dependencies if needed
if [ -f "package.json" ]; then
 npm install --silent
fi

echo "Worktree initialized: $WORKTREE_PATH"
```

## Skills That Should Not Run in Worktrees

Some skills are not safe to run in worktrees because they affect shared state:

- Skills that modify `~/.claude/` global config: These affect all sessions, not just the worktree.
- Skills that write to the main `.git/` directory directly: Could corrupt the shared git store.
- Skills that manage git remotes or push to origin: Should typically be done from the main worktree.

Add a guard to such skills:

```
Safety check:
Before starting, verify you are not running in a worktree:
bash("git rev-parse --git-common-dir")

If the output is ".git" (same as current directory), you are in the main worktree.
If the output is a different path, you are in a worktree. For this skill, that is
unexpected. warn the user and stop.
```

---

---

<div class="mastery-cta">

This site was built by 5 autonomous agents running in tmux while I was in Bali. 2,500 articles. Zero manual work. 100% quality gate pass rate.

The orchestration configs, sprint templates, and quality gates that made that possible are in the Zovo Lifetime bundle. Along with 16 CLAUDE.md templates and 80 tested prompts.

**[See how the pipeline works →](https://zovo.one/lifetime?utm_source=ccg&utm_medium=cta-skills&utm_campaign=claude-code-worktrees-and-skills-isolation-explained)**

$99 once. I'm a solo dev in Da Nang. This is how I scale.

</div>

Related Reading

- [Best Claude Skills for Developers in 2026](/best-claude-skills-for-developers-2026/). Top skills every developer should know
- [Claude Skills Auto Invocation: How It Works](/claude-skills-auto-invocation-how-it-works/). How skills activate automatically
- [Building Stateful Agents with Claude Skills](/building-stateful-agents-with-claude-skills-guide/). State management patterns for long-running agent tasks

Built by theluckystrike. More at [zovo.one](https://zovo.one)




## Frequently Asked Questions

### Do I need a paid Anthropic plan to use this?

Claude Code works with any Anthropic API plan, including the free tier. However, the free tier has lower rate limits (requests per minute and tokens per minute) that may slow down multi-step workflows. For professional use, the Build or Scale plan provides higher limits and priority access during peak hours.

### How does this affect token usage and cost?

The token cost depends on the size of your prompts and Claude's responses. Typical development tasks consume 10K-50K tokens per interaction. Using a CLAUDE.md file and skills reduces exploration tokens by 50-80%, which directly lowers costs. Monitor your usage at console.anthropic.com/settings/billing.

### Can I customize this for my specific project?

Yes. All Claude Code behavior can be customized through CLAUDE.md (project rules), `.claude/settings.json` (permissions), and `.claude/skills/` (domain knowledge). The most impactful customization is adding your project's specific patterns, conventions, and common commands to CLAUDE.md so Claude Code follows your standards from the start.

### What happens when Claude Code makes a mistake?

Claude Code creates files and edits through standard filesystem operations, so all changes are visible in `git diff`. If a change is wrong, revert it with `git checkout -- <file>` for a single file or `git stash` for all changes. Claude Code does not make irreversible changes unless you explicitly allow destructive commands in settings.json.


## Related Guides

- [Claude Skills Automated Social Media](/claude-skills-automated-social-media-content-workflow/)
- [Skills vs Hooks vs Commands in Claude](/claude-code-skills-vs-hooks-vs-commands-2026/)
- [Claude Skills for SEO Content Generation Guide](/claude-skills-for-seo-content-generation/)
- [Claude Skills With Local LLM](/claude-skills-with-local-llm-ollama-self-hosted-guide/)

<script type="application/ld+json">
{
  "@context": "https://schema.org",
  "@type": "FAQPage",
  "mainEntity": [
    {
      "@type": "Question",
      "name": "Do I need a paid Anthropic plan to use this?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "Claude Code works with any Anthropic API plan, including the free tier. However, the free tier has lower rate limits (requests per minute and tokens per minute) that may slow down multi-step workflows."
      }
    },
    {
      "@type": "Question",
      "name": "How does this affect token usage and cost?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "The token cost depends on the size of your prompts and Claude's responses. Typical development tasks consume 10K-50K tokens per interaction. Using a CLAUDE.md file and skills reduces exploration tokens by 50-80%, which directly lowers costs."
      }
    },
    {
      "@type": "Question",
      "name": "Can I customize this for my specific project?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "Yes. All Claude Code behavior can be customized through CLAUDE.md (project rules), .claude/settings.json (permissions), and .claude/skills/ (domain knowledge). The most impactful customization is adding your project's specific patterns, conventions, and common commands to CLAUDE.md so Claude Code..."
      }
    },
    {
      "@type": "Question",
      "name": "What happens when Claude Code makes a mistake?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "Claude Code creates files and edits through standard filesystem operations, so all changes are visible in git diff. If a change is wrong, revert it with git checkout -- <file> for a single file or git stash for all changes."
      }
    }
  ]
}
</script>
