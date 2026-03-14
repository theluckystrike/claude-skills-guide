---
layout: default
title: "How to Share Claude Skills with Your Team"
description: "Share Claude Code skill files across your development team: Git repository approach, documentation standards, naming conventions, and update distribution."
date: 2026-03-13
categories: [guides]
tags: [claude-code, claude-skills, team, collaboration]
author: "Claude Skills Guide"
reviewed: true
score: 9
permalink: /how-to-share-claude-skills-with-your-team/
---

# How to Share Claude Skills with Your Team

[Claude Code skills are `.md` files in `~/.claude/skills/`](/claude-skills-guide/claude-skill-md-format-complete-specification-guide/). Sharing them across a team means distributing those files consistently. Here are practical approaches that work.

## The Git Repository Approach

Store your team's skills in a shared Git repository. Each developer clones it and symlinks or copies the files to their local skills directory.

```bash
# Clone the team skills repo
git clone git@github.com:yourorg/claude-skills.git ~/team-claude-skills

# Copy skills to local directory
mkdir -p ~/.claude/skills
cp ~/team-claude-skills/*.md ~/.claude/skills/

# Or symlink for automatic updates
ln -s ~/team-claude-skills/*.md ~/.claude/skills/
```

When someone improves a skill, they commit the `.md` file, open a PR, and after merge, everyone runs `git pull` to get the update.

## Setting Up the Skills Repository

Structure the repo simply:

```
claude-skills/
├── README.md          # How to install and use
├── api-docs.md        # Team's API documentation skill
├── deploy-check.md    # Pre-deployment checklist skill
├── tdd-team.md        # TDD conventions for your stack
└── pr-review.md       # Code review standards skill
```

The README should cover three things: how to install the skills, what each one does, and who to contact when something is wrong.

## Required Metadata for Every Shared Skill

Every skill in the shared repo should have consistent front matter:

```markdown
---
name: api-docs
description: "Generate API documentation following our OpenAPI 3.1 conventions"
author: "backend-team"
---

# API Docs Skill

This skill generates API documentation in our standard format...
```

The `version` field matters — when you update a skill, bump the version so developers know they have an outdated copy.

## Automating Distribution

[A GitHub Actions workflow can notify the team when skills are updated](/claude-skills-guide/claude-skills-with-github-actions-ci-cd-pipeline/):

```yaml
# .github/workflows/skill-sync.yml
name: Skill Update Notification
on:
  push:
    branches: [main]
    paths: ['*.md']

jobs:
  notify:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: List changed skills
        run: |
          echo "Updated skills:"
          git diff --name-only HEAD~1 HEAD -- '*.md'
```

Combine with a Slack notification action to alert the team automatically.

## Keeping Skills Updated

Team members should pull updates regularly:

```bash
# Pull latest skills
cd ~/team-claude-skills && git pull
cp *.md ~/.claude/skills/
```

A short alias makes this fast:

```bash
# Add to ~/.zshrc or ~/.bashrc
alias skills-update="cd ~/team-claude-skills && git pull && cp *.md ~/.claude/skills/ && echo 'Skills updated'"
```

## Naming Conventions

Use descriptive, consistent names that reflect the skill's purpose:

- `pdf-invoice` — not just `pdf`
- `tdd-python` — if you have Python-specific TDD conventions
- `review-security` — for security-focused code review

Avoid generic names that conflict with official skills. If you have a custom PDF workflow, name it `pdf-internal` rather than `pdf`.

## Documentation Standards

Before adding a skill to the shared repo, it should include:

1. **A clear description** in the front matter (one sentence)
2. **When to use it** — explicit trigger conditions
3. **2-3 example invocations** with expected output format
4. **Known limitations** — what the skill doesn't handle

Skills with good documentation get used. Skills with vague descriptions sit unused.

## Measuring Adoption

Ask developers which skills they actually use in team retrospectives. Remove or simplify skills that nobody invokes — a smaller, well-maintained skill set beats a large, confusing one.

---

## Related Reading

- [How to Contribute Claude Skills to Open Source](/claude-skills-guide/how-to-contribute-claude-skills-to-open-source/) — Full contribution walkthrough
- [Skill MD File Format Explained With Examples](/claude-skills-guide/skill-md-file-format-explained-with-examples/) — Format your skill correctly before submitting
- [Claude Skills Auto Invocation: How It Works](/claude-skills-guide/claude-skills-auto-invocation-how-it-works/) — How skills activate automatically


---

*Built by theluckystrike — More at [zovo.one](https://zovo.one)*
