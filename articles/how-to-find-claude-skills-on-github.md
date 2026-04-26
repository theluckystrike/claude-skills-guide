---
layout: default
title: "Find Claude Skills on GitHub: Directory (2026)"
description: "Find Claude Code skills on GitHub with advanced search queries. Curated repos, install commands, and community skill directories. Updated 2026."
date: 2026-03-14
last_modified_at: 2026-04-17
last_tested: "2026-04-21"
categories: [guides]
tags: [claude-code, claude-skills, github, discovery, community]
author: "Claude Skills Guide"
reviewed: true
score: 7
permalink: /how-to-find-claude-skills-on-github/
geo_optimized: true
---

# How to Find Claude Skills on GitHub: A Practical Guide

[Finding high-quality Claude Code skills on GitHub requires knowing where to look](/best-claude-code-skills-to-install-first-2026/) and how to evaluate what you find. This guide covers practical methods for discovering skills, evaluating their quality, and installing them into your workflow.

## Understanding the Claude Skills Repository Structure

Claude Code skills are markdown files with a specific format. When developers share skills on GitHub, they typically organize them in one of several ways:

- Single-file repositories: A single `.md` file containing the skill
- Multi-file collections: A repository with multiple skill files in a `skills/` or `articles/` directory
- Integrated projects: Skills embedded within larger Claude Code projects or templates

[The skill file follows the `skill.md` specification](/claude-skill-md-format-complete-specification-guide/), with YAML front matter defining metadata and the body containing instructions that Claude Code uses when the skill is active.

Understanding how repositories are structured saves time during discovery. A single-file repo is the quickest to evaluate. open the file, read the front matter, and decide. Collections require more digging but often yield multiple useful skills from a single trusted source. Integrated projects are worth bookmarking even if you only want one skill out of many, since the surrounding code often demonstrates how the skill is meant to be used in practice.

## Using GitHub Search Effectively

The most direct way to find Claude skills is through GitHub's search functionality. Here are proven search queries:

## Basic Search Queries

To find repositories containing Claude skills, try these searches:

```
claude-skill language:md
ls ~/.claude/skills/*.md
"/claude-skills" in:path
```

## Finding Skill Collections

Search for repositories explicitly organized as skill collections:

```
claude-skills-guide topic:claude-skills
claude-code-skills topic:claude-code
```

## Finding Skills by Use Case

Search for specific skill types:

```
filename:skill.md python
filename:skill.md tdd
filename:skill.md frontend
```

The `filename:` search operator is particularly useful because it targets skill files specifically, filtering out general mentions.

## Code Search for Skill Front Matter

You can also search the code index directly for the YAML front matter pattern that identifies skill files:

```
"name:" "description:" path:*.md claude-skill
```

This targets files that look structurally like skills rather than just documentation that mentions skills. Pair it with `pushed:>2025-01-01` to filter for recently maintained repositories.

## Evaluating Skill Quality

Before installing any skill, assess its quality using these criteria:

## Code Review Checklist

1. Check the last commit date: Active maintenance matters. Skills that haven't been updated in over six months may have compatibility issues with current Claude Code versions.

2. Examine the skill structure: A well-formed skill includes clear front matter and organized instruction sections:

```yaml
---
name: tdd-workflow
description: Test-driven development guidance for Claude Code
---
```

3. Review issue tracker: Look for reported problems or feature requests that indicate community engagement.

4. Check star count and forks: While not definitive, these metrics suggest community trust and active development.

## Red Flags to Avoid

- Skills without any documentation or README
- Repositories with no recent activity
- Skills that request excessive permissions
- Unverified or copied skills from unknown sources

## Quality Comparison: What Good vs. Poor Skills Look Like

| Attribute | High-Quality Skill | Low-Quality Skill |
|---|---|---|
| Front matter | Complete with name, description, version | Missing or incomplete |
| Instructions | Step-by-step with examples | Vague directives only |
| Last commit | Within past 3 months | Over a year old |
| README | Installation steps + usage examples | None or placeholder |
| Issues/PRs | Active discussion, bugs addressed | None or all stale |
| License | Clear open-source license | No license file |

A skill can have zero stars and still be excellent. many highly specific skills are maintained by solo developers for their own use and shared without promotion. The code quality and recency of commits matter more than vanity metrics.

## Installing Skills from GitHub

Once you find a skill you want to use, installation involves copying the skill file to your local skills directory.

## Finding Your Skills Directory

Claude Code stores skills in your home directory:

```bash
Check your skills directory
ls -la ~/.claude/skills/

Or create it if it doesn't exist
mkdir -p ~/.claude/skills/
```

## Manual Installation

Clone a repository and copy the skill file:

```bash
Clone the repository
git clone git@github.com:username/claude-skills-repo.git

Copy the skill file
cp claude-skills-repo/skills/my-skill.md ~/.claude/skills/my-skill.md

Verify installation
ls ~/.claude/skills/ | grep my-skill
```

## Batch Installation from a Collection

If a repository contains multiple useful skills, copy them all at once:

```bash
Clone the collection
git clone git@github.com:username/skill-collection.git /tmp/skill-collection

Preview what you are about to install
ls /tmp/skill-collection/skills/

Copy only the ones you want
cp /tmp/skill-collection/skills/python-tdd.md ~/.claude/skills/
cp /tmp/skill-collection/skills/code-review.md ~/.claude/skills/

Or copy everything from the directory
cp /tmp/skill-collection/skills/*.md ~/.claude/skills/
```

After a batch install, open a few of the files to confirm they contain valid front matter and instructions before invoking them in a project.

## Using Git Submodules

For better version control, add skills as submodules:

```bash
cd ~/.claude/skills/
git submodule add git@github.com:username/skill-repo.git my-skill
```

This approach lets you update skills with `git submodule update` and track changes.

## Script-Based Installation with Validation

If you manage many skills across machines, a simple install script avoids copy-paste errors:

```bash
#!/bin/bash
install-skills.sh. pull and validate skills from GitHub

SKILLS_DIR="$HOME/.claude/skills"
REPO_URL="$1"

if [ -z "$REPO_URL" ]; then
 echo "Usage: ./install-skills.sh <github-url>"
 exit 1
fi

REPO_NAME=$(basename "$REPO_URL" .git)
TEMP_DIR=$(mktemp -d)

git clone "$REPO_URL" "$TEMP_DIR/$REPO_NAME"

Validate each skill file has name field in front matter
for f in "$TEMP_DIR/$REPO_NAME/skills/"*.md; do
 if grep -q "^name:" "$f"; then
 cp "$f" "$SKILLS_DIR/"
 echo "Installed: $(basename $f)"
 else
 echo "Skipped (invalid front matter): $(basename $f)"
 fi
done

rm -rf "$TEMP_DIR"
```

Run it with any skill repository URL and it installs only files that pass a basic structural check.

## Community Resources and Curated Lists

Beyond direct GitHub search, several community resources aggregate quality skills:

## GitHub Topics to Follow

- `claude-code`
- `claude-skills`
- `claude-code-skills`

Watch these topics to get notified when new repositories are added. Click the Watch button on any topic page to receive email digests.

## Official and Verified Sources

Anthropic maintains documentation and examples, though community skills extend far beyond official offerings. The skill format specification is open, allowing anyone to create and share skills.

## Repository Discovery Strategy

Build a systematic approach to finding skills:

1. Search weekly: New skills appear regularly. Set aside time to browse new repositories.

2. Save searches: GitHub allows saving searches with notifications for new results.

3. Follow maintainers: Once you find quality skills, follow their creators for related discoveries.

4. Browse dependents: On any popular skill repository, click "Used by" to find projects that depend on it. often those projects contain skills of their own.

## Using GitHub's Explore and Trending Pages

GitHub Trending shows repositories gaining stars quickly in a given time window. Filter by language (Markdown) and check the trending page daily during active periods when new Claude Code features ship. Skill repositories often see spikes in activity immediately after major Claude Code releases.

## Advanced Search Techniques

## Combining Search Operators

Refine your searches with multiple operators:

```bash
Find skills with more than 10 stars
claude-skill stars:>10

Find recently updated skills
claude-code-skills pushed:>2025-12-01

Search within specific organizations
org:anthropic claude-skill
```

## Filtering by Language

If you're looking for skills that work with specific programming languages:

```bash
Python-related skills
filename:skill.md python

JavaScript/TypeScript skills
filename:skill.md javascript OR filename:skill.md typescript
```

## Searching Commit Messages

Developers often document skill changes in commit messages. Searching commit history can surface repositories that are actively improving their skills:

```bash
In GitHub's code search, look for recent meaningful commits
"update skill" "claude-code" in:commit
"add skill" "claude" in:commit pushed:>2025-06-01
```

## Using the GitHub REST API for Bulk Discovery

Automate skill discovery with the GitHub search API:

```bash
Search repositories via API and extract clone URLs
curl -s "https://api.github.com/search/repositories?q=claude-skills+topic:claude-code&sort=updated" \
 | jq '.items[] | {name: .name, url: .clone_url, stars: .stargazers_count, updated: .updated_at}'
```

This returns structured JSON you can pipe into your install script, enabling fully automated skill discovery and installation pipelines.

## Organizing Your Local Skill Collection

After installing multiple skills, organize them for easy access:

## Directory Structure

```bash
~/.claude/skills/
 tdd/
 python-tdd.md
 javascript-tdd.md
 code-review/
 automated-review.md
 frontend/
 react-components.md
 vue-generators.md
```

## Naming Conventions

Use descriptive, searchable names:

- Good: `python-fastapi-api-creation.md`
- Avoid: `my-skill.md` or `fastapi.md`

## Maintaining a Local Skills Registry

As your collection grows, keep a simple registry file that tracks where each skill came from:

```yaml
~/.claude/skills/registry.yaml
skills:
 - name: python-tdd
 file: tdd/python-tdd.md
 source: https://github.com/username/skill-repo
 installed: 2026-02-10
 version: main@a3f9c12
 - name: automated-review
 file: code-review/automated-review.md
 source: https://github.com/anotheruser/review-skills
 installed: 2026-01-28
 version: v1.2.0
```

This registry makes it easy to check for updates, audit your installed skills, and reproduce your setup on a new machine.

## Staying Updated

Skills evolve with Claude Code updates. Maintain your collection:

```bash
Update all submodules
cd ~/.claude/skills/
git submodule foreach git pull origin main

Or update individual skills
cd ~/.claude/skills/my-skill
git pull
```

Set a monthly reminder to review your skills directory. Remove skills you no longer use and check release notes for skills that have been significantly updated. a behavioral change in a skill you rely on daily can affect dozens of projects.

## Summary

Finding Claude skills on GitHub requires combining effective search techniques with quality evaluation. Use GitHub's search operators to narrow results, assess skill maintenance and structure before installation, and organize your local collection for maximum utility. Automate installation with scripts when managing large collections, and maintain a registry to track provenance and version information. The community ecosystem continues growing, with new skills appearing regularly that extend Claude Code's capabilities across virtually every development domain.

---

---

<div class="mastery-cta">

This site was built by 5 autonomous agents running in tmux while I was in Bali. 2,500 articles. Zero manual work. 100% quality gate pass rate.

The orchestration configs, sprint templates, and quality gates that made that possible are in the Zovo Lifetime bundle. Along with 16 CLAUDE.md templates and 80 tested prompts.

**[See how the pipeline works →](https://zovo.one/lifetime?utm_source=ccg&utm_medium=cta-skills&utm_campaign=how-to-find-claude-skills-on-github)**

$99 once. I'm a solo dev in Da Nang. This is how I scale.

</div>

Related Reading

- [Best Claude Code Skills to Install First (2026)](/best-claude-code-skills-to-install-first-2026/)
- [Claude Skill .md Format: Complete Specification Guide](/claude-skill-md-format-complete-specification-guide/)
- [How to Combine Multiple Claude Skills in One Project](/how-to-combine-multiple-claude-skills-in-one-project/)
- [Getting Started Hub](/getting-started-hub/)

Built by theluckystrike. More at [zovo.one](https://zovo.one)


