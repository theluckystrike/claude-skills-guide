---
layout: default
title: "Share and Reuse CLAUDE.md Patterns (2026)"
description: "Techniques for sharing CLAUDE.md instructions across repositories: imports, symlinks, managed policies, and the --add-dir flag."
permalink: /share-reuse-claude-md-across-teams/
date: 2026-04-20
categories: [claude-md, workflow]
tags: [claude-md, sharing, reuse, cross-project, teams, claude-code]
last_updated: 2026-04-19
---

## The Duplication Problem

When your organization runs 10 microservices, each with its own CLAUDE.md, you end up copying the same coding standards into every repository. One team updates their error handling rules, another does not. Six months later, each repo follows slightly different conventions. Claude generates different patterns depending on which repo you are working in. Learn more in [Migrate CLAUDE.md Between Projects — Portable Patterns (2026)](/migrating-claude-md-between-projects/).

The fix is sharing CLAUDE.md content across projects without copy-paste. Claude Code supports several mechanisms for this.

## Method 1: @path Imports from Shared Locations

Import instructions from your home directory into any project's CLAUDE.md:

```markdown
# CLAUDE.md in any project

## Project-specific rules
- Framework: Express 5
- Database: MongoDB

## Shared organization standards
@~/.claude/org-standards.md
@~/.claude/security-rules.md
@~/.claude/code-review-checklist.md
```

The `@~/.claude/org-standards.md` import pulls content from your home directory. Every project that includes this import line gets the same standards. Update the shared file once, and all projects pick up the change.

Imports resolve relative to the file containing the `@` reference. Maximum import depth is 5 hops for recursive imports. The first time you import from a location outside the project, Claude shows an approval dialog.

## Method 2: Symlinks for Cross-Project Rules

Symlink shared rules files into your project's `.claude/rules/` directory:

```bash
# Create a shared rules repository
mkdir -p ~/org-claude-rules/rules/

# Symlink into each project
ln -s ~/org-claude-rules/rules/security.md .claude/rules/security.md
ln -s ~/org-claude-rules/rules/testing.md .claude/rules/testing.md
ln -s ~/org-claude-rules/rules/api-design.md .claude/rules/api-design.md
```

Claude Code follows symlinks when discovering files in `.claude/rules/`. The linked files load exactly as if they were in the project directory. Changes to the source file propagate to all linked projects immediately.

This works well for small teams on shared machines. For distributed teams, the shared rules should live in a git repository that each developer clones to a consistent path.

## Method 3: --add-dir for Multi-Project Access

The `--add-dir` flag grants Claude access to additional directories. To load CLAUDE.md from those directories, set the environment variable:

```bash
export CLAUDE_CODE_ADDITIONAL_DIRECTORIES_CLAUDE_MD=1
claude --add-dir ~/shared-standards/
```

With this configuration, Claude loads CLAUDE.md, `.claude/CLAUDE.md`, `.claude/rules/*.md`, and CLAUDE.local.md from the added directory. This is useful when your shared standards live in a dedicated repository.

Without the environment variable, `--add-dir` grants file access but does not load instruction files from the added directory.

## Method 4: Managed CLAUDE.md for Organizations

For enterprise deployments, managed CLAUDE.md ensures consistent policies across all developers in the organization:

```markdown
# macOS: /Library/Application Support/ClaudeCode/CLAUDE.md
# Linux: /etc/claude-code/CLAUDE.md
# Windows: C:\Program Files\ClaudeCode\CLAUDE.md

## Organization Policy
- All code must follow our style guide
- No dependencies without security review
- Logging must use the corporate logging format
- Data handling must comply with our privacy policy
```

Managed CLAUDE.md files cannot be excluded by individual developers through `claudeMdExcludes`. They deploy through MDM, Group Policy, Ansible, or similar tools. Use this for non-negotiable organizational policies.

## Method 5: Shared Git Repository

For teams that want version-controlled shared standards with review:

```bash
# Create the shared standards repo
mkdir org-claude-standards && cd org-claude-standards
git init

# Structure
# org-standards.md       — universal rules
# security-rules.md      — security team owned
# api-conventions.md     — platform team owned
# testing-standards.md   — QA team owned
```

Each project imports from a cloned copy:

```markdown
# CLAUDE.md in any project
@../org-claude-standards/org-standards.md
@../org-claude-standards/security-rules.md
```

Changes to the shared repo go through pull requests, giving specialized teams (security, platform, QA) ownership over their rules.

## Choosing the Right Method

| Method | Best for | Limitations |
|---|---|---|
| @path imports | Small teams, consistent paths | Requires files at same path on each machine |
| Symlinks | Shared machines, monorepos | Does not work across different machines |
| --add-dir | Multi-repo workspaces | Requires env var and flag on every session |
| Managed CLAUDE.md | Enterprise, compliance | Requires admin deployment (MDM/GPO) |
| Shared git repo | Distributed teams | Requires each dev to clone and update |

## Maintaining Shared Standards

Whichever sharing method you choose, establish an update process:

1. **Ownership**: Assign a team or individual as the owner of each shared file. Security rules are owned by the security team. Testing standards by the QA lead.
2. **Review process**: Changes to shared standards go through pull requests with owner approval.
3. **Communication**: When shared rules change, notify affected teams. A Slack message or email with the diff prevents surprises.
4. **Versioning**: Tag releases of your shared standards. Teams can pin to a version and upgrade when ready rather than being forced onto the latest.

Without a maintenance process, shared standards drift into inconsistency -- the same problem they were meant to solve.

## Combining Methods

In practice, most organizations use more than one sharing method. A common combination:

- Managed CLAUDE.md for non-negotiable security and compliance policies
- Shared git repository for team-level coding standards
- @path imports for language-specific templates
- CLAUDE.local.md for personal preferences

Each layer handles a different scope and governance level. The key principle: any standard that requires compliance should use managed CLAUDE.md or committed project files, never personal imports that developers might skip.

For monorepo-specific patterns like `claudeMdExcludes`, see the [team collaboration guide](/claude-md-team-collaboration-best-practices/). For the technical details of the import system, see the [CLAUDE.md complete guide](/claude-md-file-complete-guide-what-it-does/). For deciding what content goes in shared versus personal files, see the [team vs personal CLAUDE.md guide](/team-claude-md-vs-personal-claude-md/).

**Try it:** Build your own with our [CLAUDE.md Generator](/generator/).
