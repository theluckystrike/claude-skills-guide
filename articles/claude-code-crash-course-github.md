---
layout: default
title: "Claude Code Crash Course with GitHub"
description: "Complete crash course for using Claude Code with GitHub repos. Clone, branch, commit, PR — all through Claude Code in under 10 minutes."
date: 2026-04-17
last_modified_at: 2026-04-17
author: "Claude Skills Guide"
permalink: /claude-code-crash-course-github/
categories: [guides]
tags: [claude-code, claude-skills, github, getting-started]
reviewed: true
score: 7
geo_optimized: true
---

This crash course gets you productive with Claude Code and GitHub in under 10 minutes. You will learn to clone repos, make changes, create branches, commit, and open pull requests — all driven by Claude Code from your terminal.

## The Problem

You installed Claude Code and have a GitHub repository you want to work on, but you are not sure how to connect the two effectively. You want Claude Code to help with code changes while following proper Git/GitHub workflows — branches, commits, and PRs — without breaking anything.

## Quick Solution

**Step 1:** Clone your repo and enter the directory:

```bash
git clone https://github.com/your-username/your-repo.git
cd your-repo
```

**Step 2:** Create a CLAUDE.md file in the project root to orient Claude Code:

```bash
cat > CLAUDE.md << 'EOF'
# Project Context
- Language: TypeScript
- Framework: React
- Package manager: npm
- Test command: npm test
- Lint command: npm run lint

# Git Workflow
- Create feature branches from main
- Branch naming: feat/description, fix/description
- Commit messages: conventional commits (feat:, fix:, chore:)
- Always run tests before committing
EOF
```

**Step 3:** Launch Claude Code:

```bash
claude
```

**Step 4:** Ask Claude Code to make a change on a new branch:

```text
Create a new branch feat/add-loading-spinner, then add a loading spinner component to src/components/
```

**Step 5:** After Claude Code makes the changes, ask it to commit and push:

```text
Run the tests, commit with a conventional commit message, and push to origin
```

**Step 6:** Ask Claude Code to create a pull request:

```text
Create a PR to main with a descriptive title and summary
```

Claude Code will use the `gh` CLI (GitHub CLI) if installed, or guide you to create the PR manually.

## How It Works

Claude Code reads your CLAUDE.md file on startup to understand the project's conventions. When you ask it to work with Git, it executes real Git commands through its bash tool — `git checkout -b`, `git add`, `git commit`, `git push`. For GitHub-specific operations like creating PRs, it uses the `gh` CLI tool. Every command Claude Code runs is shown to you for approval before execution. CLAUDE.md acts as persistent instructions that shape how Claude Code interacts with your repo: which branch strategy to follow, what commit format to use, and what checks to run before committing.

## Common Issues

**`gh` CLI not installed.** If Claude Code cannot create PRs, install the GitHub CLI:

```bash
brew install gh
gh auth login
```

Follow the prompts to authenticate with your GitHub account.

**Claude Code commits to main instead of a branch.** If your CLAUDE.md does not specify branching rules, Claude Code may commit directly to main. Always include explicit Git workflow instructions in CLAUDE.md as shown in the Quick Solution.

**Large repos slow down Claude Code.** If your repo has hundreds of thousands of files, Claude Code spends too much time indexing. Add a `.claudeignore` file:

```text
node_modules/
dist/
.git/
*.min.js
vendor/
```

## Example CLAUDE.md Section

```markdown
# GitHub Workflow

## Branching
- Always work on feature branches, never commit to main directly
- Branch from: main
- Branch naming: feat/short-description, fix/short-description, chore/short-description
- Delete branches after merge

## Commits
- Use conventional commits: feat:, fix:, chore:, docs:, refactor:, test:
- Keep commits atomic — one logical change per commit
- Run `npm test` before every commit
- Run `npm run lint` before every commit

## Pull Requests
- Use gh CLI to create PRs: gh pr create
- PR title matches the primary commit message
- PR body includes: what changed, why, how to test
- Request review from: @team-lead

## Code Review
- Address all review comments before merging
- Use `gh pr review` to check PR status
```

## Best Practices

1. **Install the `gh` CLI before starting.** Claude Code integrates naturally with `gh` for creating PRs, checking CI status, and managing issues. Install it once and authenticate.

2. **Define your Git workflow in CLAUDE.md.** Be explicit about branch naming, commit format, and pre-commit checks. Claude Code follows these instructions consistently.

3. **Use `.claudeignore` for large repos.** Exclude build artifacts, dependencies, and generated files so Claude Code focuses on your actual source code.

4. **Review every command before approving.** Claude Code shows you the Git commands it plans to run. Read them before hitting enter. This is your safety net against accidental force pushes or wrong branches.

5. **Commit frequently.** Ask Claude Code to commit after each logical change rather than batching everything. Smaller commits are easier to review and revert if needed.

---

---

<div class="mastery-cta">

I'm a solo developer in Vietnam. 50K Chrome extension users. $500K+ on Upwork. 5 Claude Max subscriptions running agent fleets in parallel.

These are my actual CLAUDE.md templates, orchestration configs, and prompts. Not a course. Not theory. The files I copy into every project before I write a line of code.

**[See what's inside →](https://zovo.one/lifetime?utm_source=ccg&utm_medium=cta-default&utm_campaign=claude-code-crash-course-github)**

$99 once. Free forever. 47/500 founding spots left.

</div>

Related Reading

- [Best Way to Integrate Claude Code into Team Workflow](/best-way-to-integrate-claude-code-into-team-workflow/)
- [Claude Code MCP Server Setup](/claude-code-mcp-server-setup/)
- [Best Way to Use Claude Code for Debugging Sessions](/best-way-to-use-claude-code-for-debugging-sessions/)

Built by theluckystrike. More at [zovo.one](https://zovo.one)

## See Also

- [VS Code Extension Host Crash Fix](/claude-code-extension-host-crash-fix-2026/)
- [Apple Silicon Rosetta Crash Error — Fix (2026)](/claude-code-apple-silicon-rosetta-crash-fix-2026/)
