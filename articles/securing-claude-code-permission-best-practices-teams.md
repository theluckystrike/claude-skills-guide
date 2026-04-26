---
layout: default
title: "Securing Claude Code: Permission Best Practices for Teams (2026)"
description: "Team security for Claude Code: shared settings.json, CI/CD permissions, audit logging, blocking dangerous commands, and per-project overrides for safe collaboration."
date: 2026-04-26
author: "Claude Skills Guide"
permalink: /securing-claude-code-permission-best-practices-teams/
reviewed: true
categories: [configuration]
tags: [claude, claude-code, permissions, security, teams]
---

# Securing Claude Code: Permission Best Practices for Teams

When one developer uses Claude Code, permissions are a personal preference. When a team of five uses it, permissions become a security requirement. A single misconfigured settings.json can let Claude Code run destructive commands on shared infrastructure. This guide covers how to enforce consistent permissions across a team -- from shared configuration to audit logging. Use the [Permissions Configurator](/permissions/) to generate team-wide settings.

## Shared settings.json: The Team Standard

Commit a `.claude/settings.json` to your repository. Every team member inherits it automatically.

```json
// .claude/settings.json (committed to repo)
{
  "permissions": {
    "allow": [
      "Read",
      "Glob",
      "Grep",
      "Edit",
      "Write",
      "Bash(npm test)",
      "Bash(npm run lint)",
      "Bash(npm run typecheck)",
      "Bash(npx prisma generate)",
      "Bash(git diff *)",
      "Bash(git status)",
      "Bash(git log *)"
    ],
    "deny": [
      "Bash(rm -rf *)",
      "Bash(git push --force *)",
      "Bash(git reset --hard *)",
      "Bash(git checkout -- .)",
      "Bash(DROP *)",
      "Bash(DELETE FROM *)",
      "Bash(sudo *)",
      "Bash(curl * | bash)",
      "Bash(npx * --dangerously*)",
      "Bash(chmod 777 *)"
    ]
  }
}
```

**Key principle:** The project-level `.claude/settings.json` applies to everyone who clones the repo. Individual developers can add to their personal `~/.claude/settings.json`, but the project-level deny list always takes precedence.

## Per-Project Permission Overrides

Different repositories need different permissions. A frontend app does not need database access. A DevOps repo does not need npm.

```json
// Frontend project: .claude/settings.json
{
  "permissions": {
    "allow": [
      "Read", "Edit", "Write", "Glob", "Grep",
      "Bash(npm test)", "Bash(npm run build)",
      "Bash(npx next lint)"
    ],
    "deny": [
      "Bash(docker *)", "Bash(kubectl *)",
      "Bash(psql *)", "Bash(mysql *)"
    ]
  }
}
```

```json
// Backend/infrastructure project: .claude/settings.json
{
  "permissions": {
    "allow": [
      "Read", "Edit", "Write", "Glob", "Grep",
      "Bash(go test ./...)", "Bash(go build ./...)",
      "Bash(docker build *)", "Bash(docker compose up -d)"
    ],
    "deny": [
      "Bash(docker push *)",
      "Bash(kubectl apply *)",
      "Bash(terraform apply *)"
    ]
  }
}
```

## CI/CD Permission Strategy

CI/CD pipelines need autonomy but within strict boundaries. Use `--allowedTools` instead of `--dangerously-skip-permissions` when possible:

```yaml
# GitHub Actions: Controlled autonomy
name: Claude Code PR Review
on: pull_request

jobs:
  review:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Claude Code Review
        run: |
          claude --print \
            --allowedTools "Read,Glob,Grep,Bash(npm test)" \
            "Review this PR for bugs, security issues, and
             test coverage gaps. Run the test suite."
        env:
          ANTHROPIC_API_KEY: ${{ secrets.CLAUDE_CI_KEY }}
```

The `--allowedTools` flag restricts Claude Code to only the listed tools. It can read files and run tests, but cannot edit code, install packages, or run arbitrary commands.

```bash
# Tool allowlist for common CI tasks:

# Code review (read-only):
--allowedTools "Read,Glob,Grep"

# Review + test execution:
--allowedTools "Read,Glob,Grep,Bash(npm test),Bash(npm run lint)"

# Automated fixes (careful):
--allowedTools "Read,Glob,Grep,Edit,Bash(npm test),Bash(npm run lint)"
```

## Blocking Dangerous Commands

The deny list should cover every destructive pattern your team might encounter:

```json
{
  "permissions": {
    "deny": [
      "Bash(rm -rf *)",
      "Bash(git push --force *)",
      "Bash(git reset --hard *)",
      "Bash(git clean -fd *)",
      "Bash(git checkout -- .)",
      "Bash(DROP TABLE *)",
      "Bash(DROP DATABASE *)",
      "Bash(DELETE FROM * WHERE 1=1)",
      "Bash(TRUNCATE *)",
      "Bash(sudo *)",
      "Bash(chmod 777 *)",
      "Bash(curl * | bash)",
      "Bash(wget * | sh)",
      "Bash(eval *)",
      "Bash(env | grep *KEY*)",
      "Bash(cat ~/.ssh/*)",
      "Bash(cat .env*)",
      "Bash(echo $ANTHROPIC_API_KEY)",
      "Bash(npx * --dangerously*)"
    ]
  }
}
```

This deny list blocks file deletion, git history destruction, database drops, privilege escalation, and credential exposure. Update it as your team discovers new patterns to block.

## Onboarding New Developers

New team members should start with tighter permissions:

```bash
# Week 1-2: Default mode (prompted for everything)
# The new developer sees every action Claude Code takes
# and learns what's safe vs risky.

# Week 3-4: Project allowlist (standard team config)
# Switch to the shared settings.json committed to the repo.

# After onboarding: Personal additions
# Developer adds their own trusted tools to
# ~/.claude/settings.json (does not override project deny list)
```

Include the permission setup in your onboarding documentation:

```bash
# Onboarding checklist:
# 1. Clone repo (inherits .claude/settings.json)
# 2. Run Claude Code in Default mode for first week
# 3. Review the team deny list and understand why each entry exists
# 4. After approval, add personal ~/.claude/settings.json preferences
```

## Audit Logging

Track what Claude Code does across the team:

```bash
# Claude Code stores session history locally
# Location: ~/.claude/projects/<project-hash>/sessions/

# For team visibility, use git to track changes:
# Claude Code's edits show up in git blame and git log
git log --author="$(git config user.name)" --oneline --since="1 week ago"

# For CI/CD, capture output:
claude --print --output-format json \
  "Review src/auth/" 2>&1 | tee claude-review-$(date +%s).json
```

## Try It Yourself

The [Permissions Configurator](/permissions/) generates team-ready settings.json files. Select your project type, team size, and security requirements. It outputs both the project-level and recommended personal settings, plus a deny list tailored to your stack.

## Frequently Asked Questions

<details>
<summary>Can individual developers override the project deny list?</summary>
No. The project-level deny list in .claude/settings.json always takes precedence. Individual developers can add their own allow entries in ~/.claude/settings.json for tools not covered by the project config, but they cannot un-deny something the project blocks. This ensures team-wide security standards are enforced regardless of personal preferences.
</details>

<details>
<summary>How do I enforce settings.json across all team members?</summary>
Commit .claude/settings.json to the repository. Every developer who clones the repo automatically inherits it. Add a CI check that validates the settings file has not been weakened (e.g., deny list items removed). Use the <a href="/permissions/">Permissions Configurator</a> to generate the initial config and update it as a team.
</details>

<details>
<summary>Should interns have different permissions than senior developers?</summary>
Yes. Interns should start in Default mode (prompted for everything) for at least their first month. This teaches them what Claude Code does and helps them develop judgment about which operations are safe. After the learning period, they can move to the standard team Allowlist. The <a href="/starter/">Project Starter</a> includes onboarding permission presets.
</details>

<details>
<summary>What if a denied command is needed for a legitimate task?</summary>
A team lead should evaluate the request, run the command manually if it is a one-off, or update the team settings.json if the deny rule is too broad. Document the change in a PR so the team can review the security implications. Never remove deny rules without team consensus.
</details>

<script type="application/ld+json">
{
  "@context": "https://schema.org",
  "@type": "FAQPage",
  "mainEntity": [
    {
      "@type": "Question",
      "name": "Can individual developers override the Claude Code project deny list?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "No. The project-level deny list in .claude/settings.json always takes precedence. Individual developers can add their own allow entries but cannot un-deny something the project blocks."
      }
    },
    {
      "@type": "Question",
      "name": "How do I enforce Claude Code settings.json across all team members?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "Commit .claude/settings.json to the repository. Every developer who clones the repo automatically inherits it. Add a CI check that validates the settings file has not been weakened."
      }
    },
    {
      "@type": "Question",
      "name": "Should interns have different Claude Code permissions than senior developers?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "Yes. Interns should start in Default mode for at least their first month to learn what operations are safe. After the learning period, they can move to the standard team Allowlist."
      }
    },
    {
      "@type": "Question",
      "name": "What if a denied Claude Code command is needed for a legitimate task?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "A team lead should evaluate the request, run the command manually if it is a one-off, or update the team settings.json with a PR so the team can review the security implications."
      }
    }
  ]
}
</script>

## Related Guides

- [Permissions Configurator](/permissions/) -- Generate team-ready permission configs
- [Configuration Guide](/configuration/) -- Full settings.json reference
- [CLAUDE.md Generator](/generator/) -- Create team-standard CLAUDE.md files
- [Best Practices](/best-practices/) -- General security and workflow guidelines
- [Project Starter](/starter/) -- Include permissions in project initialization
