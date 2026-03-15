---
layout: default
title: "Claude Code for Version Bump Workflow Tutorial Guide"
description: "Learn how to automate version bumping in your projects using Claude Code. This tutorial covers creating skills, workflow patterns, and best practices for semantic versioning."
date: 2026-03-15
author: Claude Skills Guide
permalink: /claude-code-for-version-bump-workflow-tutorial-guide/
categories: [guides]
tags: [claude-code, claude-skills]
---

{% raw %}
# Claude Code for Version Bump Workflow Tutorial Guide

Version management is a critical aspect of software development, yet it's often handled manually—leading to inconsistencies, forgotten updates, and release confusion. This guide shows you how to leverage Claude Code to automate version bumping workflows, ensuring consistent versioning across your projects with minimal effort.

## Why Automate Version Bumping?

Manual version updates are error-prone. Developers frequently forget to bump versions, use inconsistent formats, or skip updating dependency files. Automating this process with Claude Code provides:

- **Consistency**: Every version change follows your defined rules
- **Auditability**: Version changes are tracked and documented
- **Speed**: Instant updates across all version files
- **Reliability**: Eliminates human error in version management

## Understanding Semantic Versioning Basics

Before diving into automation, ensure you understand semantic versioning (SemVer). The format is `MAJOR.MINOR.PATCH`:

- **MAJOR**: Incompatible API changes
- **MINOR**: New functionality (backward-compatible)
- **PATCH**: Bug fixes (backward-compatible)

Claude Code can handle all three increment types based on your commit messages or explicit commands.

## Creating a Version Bump Skill

The foundation of automated version bumping is a well-designed Claude Skill. Here's how to create one:

### Skill Structure

Create a file named `version-bump-skill.md` in your skills directory:

```markdown
---
name: version-bump
description: Automate version bumping following semantic versioning
version: 1.0.0
tools: [read_file, write_file, bash]
---

# Version Bump Skill

This skill helps you increment version numbers in your project files.

## Available Actions

When you need to bump a version:

1. **PATCH bump**: For bug fixes - use command "bump patch" or "fix"
2. **MINOR bump**: For new features - use command "bump minor" or "feature"
3. **MAJOR bump**: For breaking changes - use command "bump major" or "breaking"

## Version File Locations

Common version file locations this skill handles:
- package.json (npm projects)
- pyproject.toml (Python projects)
- version.dart (Dart/Flutter)
- __version__ variable (Python modules)
- Cargo.toml (Rust projects)

## Process

When asked to bump version:

1. First, detect the project type and find version files
2. Read current version from appropriate files
3. Determine increment type from context
4. Calculate new version number
5. Update all version references
6. Create appropriate git commit and tag
```

This skill provides the foundation. Now let's explore advanced workflow patterns.

## Advanced Workflow Patterns

### Pattern 1: Interactive Version Bumping

For teams preferring interactive workflows:

```python
def interactive_bump():
    """Prompt user for version bump type"""
    print("Select version bump type:")
    print("1. PATCH (bug fix)")
    print("2. MINOR (new feature)")
    print("3. MAJOR (breaking change)")
    
    choice = input("Enter choice (1-3): ")
    bump_type = {1: "patch", 2: "minor", 3: "major"}[choice]
    return bump_type
```

Call this from your Claude Skill when you need user confirmation before making changes.

### Pattern 2: Commit Message Driven Bumping

Automate version bumps based on conventional commits:

```bash
# Analyze last commit for bump type
last_commit=$(git log -1 --pretty=%B)

if echo "$last_commit" | grep -q "^feat:"; then
    bump_type="minor"
elif echo "$last_commit" | grep -q "^fix:"; then
    bump_type="patch"
elif echo "$last_commit" | grep -q "^BREAKING CHANGE:"; then
    bump_type="major"
fi
```

This pattern works excellently in CI/CD pipelines where Claude Code runs after commits.

### Pattern 3: Multi-File Version Synchronization

Many projects have version information in multiple places:

```json
// package.json
{
  "version": "1.2.0",
  "dependencies": {
    "shared-lib": "^1.2.0"
  }
}

// pyproject.toml
[project]
version = "1.2.0"

# docs/conf.py
version = "1.2"
release = "1.2.0"
```

Your skill should update all these locations consistently:

```python
def update_all_versions(new_version):
    """Update version across all project files"""
    files_to_update = [
        "package.json",
        "pyproject.toml", 
        "docs/conf.py",
        "VERSION.txt"
    ]
    
    for file_path in files_to_update:
        if os.path.exists(file_path):
            update_version_in_file(file_path, new_version)
```

## Practical Examples

### Example 1: NPM Project Version Bump

For a Node.js project, create a skill that handles package.json:

```bash
# Read current version
current_version=$(node -p "require('./package.json').version")

# Use standard-version or manual bump
npm version patch -m "Bump version to %s"
```

### Example 2: Python Project Version Bump

For Python projects using setuptools:

```python
# Update version in pyproject.toml
import re

def bump_version(version_file, bump_type):
    with open(version_file, 'r') as f:
        content = f.read()
    
    # Extract current version
    match = re.search(r'version = "(\d+)\.(\d+)\.(\d+)"', content)
    major, minor, patch = map(int, match.groups())
    
    # Increment based on type
    if bump_type == 'major':
        major += 1
        minor = patch = 0
    elif bump_type == 'minor':
        minor += 1
        patch = 0
    else:
        patch += 1
    
    new_version = f"{major}.{minor}.{patch}"
    
    # Replace version
    content = re.sub(
        r'version = "\d+\.\d+\.\d+"',
        f'version = "{new_version}"',
        content
    )
    
    with open(version_file, 'w') as f:
        f.write(content)
    
    return new_version
```

### Example 3: Git Tag Integration

Always create tags with version bumps:

```bash
# After version update
git add -A
git commit -m "Bump version to ${NEW_VERSION}"
git tag -a "v${NEW_VERSION}" -m "Release version ${NEW_VERSION}"
git push origin main --tags
```

## Best Practices for Version Bump Workflows

### 1. Always Use Semantic Versioning

Stick to SemVer strictly. It communicates breaking changes clearly and integrates with dependency managers.

### 2. Include Version in Commit Messages

Make version changes visible in git history:

```bash
git commit -m "Bump version: 1.0.0 → 1.1.0"
```

### 3. Update Dependencies Concurrently

When bumping major versions, check and update dependent packages:

```bash
# Check for outdated dependencies
npm outdated

# Update within compatibility bounds
npm update
```

### 4. Test After Version Bumps

Always run tests after version changes:

```bash
npm version patch && npm test
```

### 5. Document Version Changes

Maintain a CHANGELOG that Claude Code can auto-update:

```markdown
## [1.1.0] - 2026-03-15

### Added
- New feature description

### Changed
- Updated dependencies
```

## Integrating with CI/CD

The real power of Claude Code version bumping emerges in CI/CD pipelines:

```yaml
# Example GitHub Actions workflow
name: Version Bump

on:
  push:
    branches: [main]

jobs:
  bump-version:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Run Claude Code version bump
        run: |
          claude --prompt "Bump version based on recent commits"
      - name: Push changes
        run: |
          git push origin main --tags
```

## Conclusion

Automating version bumping with Claude Code transforms a tedious manual task into a reliable, consistent process. Start with the basic skill structure, then expand to handle multi-file updates, commit-driven bumping, and CI/CD integration. Your team will benefit from consistent versioning, better changelog accuracy, and fewer "forgot to bump version" moments.

The key is starting simple—create your initial version bump skill, test it thoroughly, then gradually add complexity as your workflow matures.
{% endraw %}
