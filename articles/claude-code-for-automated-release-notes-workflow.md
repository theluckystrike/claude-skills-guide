---
layout: default
title: "Claude Code for Automated Release Notes Workflow"
description: "Build an automated release notes workflow using Claude Code skills. Generate changelogs from git commits, integrate with GitHub releases, and streamline your deployment pipeline."
date: 2026-03-15
categories: [guides]
tags: [claude-code, claude-skills]
author: "Claude Skills Guide"
permalink: /claude-code-for-automated-release-notes-workflow/
---

{% raw %}
# Claude Code for Automated Release Notes Workflow

Manual release notes are time-consuming and error-prone. Developers often delay creating them, leading to incomplete documentation and confused users. Automating this process with Claude Code skills transforms how teams handle releases—generating consistent, informative changelogs from your existing git history while you focus on writing code.

This guide shows you how to build a complete automated release notes workflow using Claude Code skills that integrate with your existing development pipeline.

## Understanding the Release Notes Pipeline

Before diving into code, let's understand what an automated release notes workflow needs to accomplish:

1. **Collect changes** from git commits, PRs, or conventional commits
2. **Categorize changes** into features, bug fixes, breaking changes
3. **Format the output** in a readable, consistent style
4. **Publish** to GitHub releases, CHANGELOG.md, or notifications

Claude Code skills excel at this because they can execute bash commands, read file contents, and format output—all essential operations for generating release notes.

## Creating the Release Notes Skill

Start by creating a skill file at `~/.claude/skills/generate-release-notes/skill.md`:

```markdown
---
name: Generate Release Notes
description: Generate automated release notes from git commits and conventional commits
version: 1.0.0
tools: [bash, read_file, write_file]
---

# Generate Release Notes Skill

You generate release notes from git commit history using conventional commit format.

## Available Variables

- `since_tag`: The git tag to compare from (default: last tag)
- `output_format`: Output format - markdown, github, or json
- `include_files`: List of files to include in the release notes

## Commands

### Generate Changelog

Run the following to generate release notes:

1. Get commits since last tag:
   ```bash
   git log $(git describe --tags --abbrev=0)..HEAD --pretty=format:"%s|%h|%an|%ad" --date=short
   ```

2. Parse conventional commits and categorize:
   - `feat:` → Features
   - `fix:` → Bug Fixes
   - `docs:` → Documentation
   - `BREAKING CHANGE:` → Breaking Changes

3. Format output based on `output_format` variable

## Output Format

Generate release notes with:
- Version number and date
- Total changes count
- Categorized changes list
- Contributors list
- Links to compare views
```

This skill uses git commands to extract commit information. Now let's build the actual automation script.

## Building the Release Notes Generator Script

Create a helper script at `~/.claude/scripts/generate-release-notes.sh`:

```bash
#!/bin/bash

# Generate Release Notes Script
# Usage: ./generate-release-notes.sh [version] [since_tag]

VERSION="${1:-$(date +%Y.%m.%d)}"
SINCE_TAG="${2:-$(git describe --tags --abbrev=0 2>/dev/null || echo "v0.0.0")}"

echo "Generating release notes for version $VERSION (since $SINCE_TAG)..."

# Get commits with conventional format
COMMITS=$(git log "$SINCE_TAG..HEAD" --pretty=format:"%s|%h|%an|%ae" 2>/dev/null)

# Initialize categories
FEATURES=()
BUGFIXES=()
DOCS=()
BREAKING=()
OTHER=()

# Parse and categorize commits
while IFS='|' read -r msg hash author email; do
  case "$msg" in
    feat:*)
      FEATURES+=("- $msg ($hash)")
      ;;
    fix:*)
      BUGFIXES+=("- $msg ($hash)")
      ;;
    docs:*)
      DOCS+=("- $msg ($hash)")
      ;;
    BREAKING\ CHANGE:*)
      BREAKING+=("- $msg ($hash)")
      ;;
    *)
      OTHER+=("- $msg ($hash)")
      ;;
  esac
done <<< "$COMMITS"

# Generate markdown output
cat << EOF
# Release Notes - Version $VERSION

**Release Date:** $(date +%Y-%m-%d)

EOF

# Output breaking changes first (most important)
if [ ${#BREAKING[@]} -gt 0 ]; then
  echo "## 🚨 Breaking Changes"
  echo ""
  for item in "${BREAKING[@]}"; do
    echo "$item"
  done
  echo ""
fi

# Output features
if [ ${#FEATURES[@]} -gt 0 ]; then
  echo "## ✨ New Features"
  echo ""
  for item in "${FEATURES[@]}"; do
    echo "$item"
  done
  echo ""
fi

# Output bug fixes
if [ ${#BUGFIXES[@]} -gt 0 ]; then
  echo "## 🐛 Bug Fixes"
  echo ""
  for item in "${BUGFIXES[@]}"; do
    echo "$item"
  done
  echo ""
fi

echo "Generated $(git rev-list "$SINCE_TAG..HEAD" --count) changes"
```

Make it executable and add it to your workflow:

```bash
chmod +x ~/.claude/scripts/generate-release-notes.sh
```

## Integrating with GitHub Actions

Automate release notes as part of your CI/CD pipeline. Create `.github/workflows/release.yml`:

```yaml
name: Generate Release Notes

on:
  push:
    tags:
      - 'v*'

jobs:
  release:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
        with:
          fetch-depth: 0

      - name: Generate Release Notes
        id: release-notes
        run: |
          chmod +x ~/.claude/scripts/generate-release-notes.sh
          NOTES=$(~/.claude/scripts/generate-release-notes.sh ${{ github.ref_name }})
          echo "notes<<EOF" >> $GITHUB_OUTPUT
          echo "$NOTES" >> $GITHUB_OUTPUT
          echo "EOF" >> $GITHUB_OUTPUT

      - name: Create GitHub Release
        uses: actions/create-release@v1
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
        with:
          tag_name: ${{ github.ref_name }}
          release_name: Release ${{ github.ref_name }}
          body: ${{ steps.release-notes.outputs.notes }}
          draft: false
```

This workflow triggers on tag pushes, generates release notes automatically, and publishes them to GitHub.

## Using Claude Code Interactively

You can also generate release notes interactively during development. Invoke the skill:

```
/generate-release-notes --version 2.1.0 --since-tag v2.0.0
```

Claude will execute the git commands, parse the commits, and present formatted release notes that you can edit before publishing.

## Advanced: AI-Enhanced Release Notes

For more intelligent release notes, enhance your skill to use Claude's language capabilities:

```python
# Process commits with AI summarization
import subprocess
import anthropic

# Get raw commits
result = subprocess.run(
    ["git", "log", f"{since_tag}..HEAD", "--pretty=format:%s%n%b"],
    capture_output=True, text=True
)
commits = result.stdout

# Use Claude to summarize and enhance
client = anthropic.Anthropic()
response = client.messages.create(
    model="claude-3-sonnet-20240229",
    max_tokens=1000,
    system="You are a technical writer. Summarize these git commits into user-friendly release notes.",
    messages=[{"role": "user", "content": commits}]
)

enhanced_notes = response.content[0].text
```

This approach converts technical commit messages into readable descriptions suitable for end users.

## Best Practices for Automated Release Notes

1. **Use conventional commits** - Train your team to use `feat:`, `fix:`, `docs:` prefixes for machine-parseable commits

2. **Version consistently** - Follow semantic versioning and tag releases consistently

3. **Review before publishing** - Always review generated notes before public release

4. **Include context** - Add manual sections for significant changes that need explanation

5. **Test the pipeline** - Run your release notes generation before actual releases to catch issues

## Wrapping Up

Automated release notes with Claude Code eliminate manual documentation overhead while ensuring consistency. By combining git history parsing, conventional commits, and CI/CD integration, you create a self-sustaining documentation pipeline.

Start with the basic skill and script, then enhance as your team grows comfortable with the workflow. The investment pays dividends in time saved and documentation quality improved.

---

*Want more Claude Code automation tips? Explore our guides on CI/CD integration and skill development.*
{% endraw %}
