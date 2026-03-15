---

layout: default
title: "Claude Code for Version Bump Workflow Tutorial Guide"
description: "Learn how to create a Claude skill that automates version bumping in your projects. This tutorial covers semantic versioning, file updates, and Git."
date: 2026-03-15
author: "Claude Skills Guide"
permalink: /claude-code-for-version-bump-workflow-tutorial-guide/
categories: [tutorials, guides]
tags: [claude-code, claude-skills]
reviewed: true
score: 8
---


{% raw %}
# Claude Code for Version Bump Workflow Tutorial Guide

Version management is one of those repetitive tasks that every developer faces but few enjoy. Whether you're releasing a new npm package, updating a Python library, or managing a multi-module Java project, manually bumping version numbers across multiple files is error-prone and time-consuming. In this guide, I'll show you how to create a Claude skill that automates the entire version bump workflow, making releases as simple as asking Claude to "bump the version to 2.1.0."

## Understanding Semantic Versioning

Before diving into the implementation, let's establish a clear version bumping strategy. Semantic versioning (SemVer) provides a predictable framework: MAJOR.MINOR.PATCH. Each component serves a specific purpose:

- **MAJOR** (X.0.0): Breaking changes that are incompatible with previous versions
- **MINOR** (1.x.0): New functionality that maintains backward compatibility
- **PATCH** (1.1.x): Bug fixes that don't affect the API

Your version bump skill needs to understand these distinctions and apply the appropriate increment based on the type of change being released.

## Creating the Version Bump Skill

The first step is creating a dedicated skill file that Claude can invoke. Here's a complete implementation:

```yaml
---
name: version-bump
description: "Bump project version using semantic versioning. Supports major, minor, and patch updates across multiple files."
version: 1.0.0
tools: [read_file, write_file, bash, git]
---

# Version Bump Skill

You help developers increment version numbers across their project files using semantic versioning.

## Available Actions

When asked to bump a version, determine the type of update:

1. **Major bump** - For breaking changes: `{{version}}+1.0.0` (e.g., 1.2.3 → 2.0.0)
2. **Minor bump** - For new features: `{{version}}+0.1.0` (e.g., 1.2.3 → 1.3.0)
3. **Patch bump** - For bug fixes: `{{version}}+0.0.1` (e.g., 1.2.3 → 1.2.4)
4. **Specific version** - Set exact version: `{{version}}=X.Y.Z`

## Files to Update

Common version file locations:
- `package.json` - npm/Node.js projects (version field)
- `pyproject.toml` - Python projects (version in [project] section)
- `setup.py` - Python projects (version parameter)
- `__init__.py` - Python package __version__ variable
- `VERSION` or `version.txt` - Simple text files
- `gradle.properties` - Android/Gradle projects
- `pom.xml` - Maven/Java projects

## Workflow

1. **Detect current version** - Read from primary version file
2. **Calculate new version** - Apply the requested increment
3. **Update all version files** - Find and replace in all relevant files
4. **Create git commit** - Commit with conventional commit message
5. **Tag the release** - Create version tag (e.g., v2.1.0)

## Important Notes

- Always confirm the new version before making changes
- Use --dry-run flag first to preview changes
- Include CHANGELOG.md updates when applicable
- Follow conventional commits: `feat: add new login` or `fix: resolve auth bug`
```

This skill definition provides Claude with clear instructions on how to handle version bumps.

## Implementing the Version Detection Logic

Now you need a helper script that Claude can call to detect and parse versions from different file formats. Create a Python script called `version_bump.py`:

```python
#!/usr/bin/env python3
"""Version bump utility for automated version management."""

import json
import re
import sys
from pathlib import Path

def parse_version(version_string):
    """Parse a semantic version string into components."""
    match = re.match(r'(\d+)\.(\d+)\.(\d+)', version_string.strip())
    if not match:
        raise ValueError(f"Invalid version format: {version_string}")
    return tuple(map(int, match.groups()))

def bump_version(version, bump_type):
    """Bump version based on type: major, minor, or patch."""
    major, minor, patch = parse_version(version)
    
    if bump_type == 'major':
        return f"{major + 1}.0.0"
    elif bump_type == 'minor':
        return f"{major}.{minor + 1}.0"
    elif bump_type == 'patch':
        return f"{major}.{minor}.{patch + 1}"
    else:
        raise ValueError(f"Unknown bump type: {bump_type}")

def update_package_json(file_path, new_version):
    """Update version in package.json."""
    with open(file_path, 'r') as f:
        data = json.load(f)
    
    old_version = data.get('version', '0.0.0')
    data['version'] = new_version
    
    with open(file_path, 'w') as f:
        json.dump(data, f, indent=2)
    
    return old_version, new_version

def update_version_file(file_path, new_version):
    """Update simple version text file."""
    with open(file_path, 'r') as f:
        content = f.read()
    
    old_version = re.search(r'(\d+\.\d+\.\d+)', content).group(1)
    new_content = re.sub(r'\d+\.\d+\.\d+', new_version, content)
    
    with open(file_path, 'w') as f:
        f.write(new_content)
    
    return old_version, new_version

if __name__ == '__main__':
    # Example usage
    if len(sys.argv) > 2:
        version = sys.argv[1]
        bump_type = sys.argv[2]
        new_version = bump_version(version, bump_type)
        print(new_version)
```

Make this script executable and place it in your project or a shared tools directory.

## Practical Usage Examples

Here's how the version bump skill works in practice:

### Example 1: Minor Version Bump

```bash
# Ask Claude to bump the minor version
> Bump the version for a new feature release
```

Claude will:
1. Detect the current version (e.g., 1.2.3)
2. Calculate the new version (1.3.0)
3. Update package.json, pyproject.toml, and other version files
4. Run: `git add -A && git commit -m "feat: release v1.3.0"`
5. Create tag: `git tag v1.3.0`

### Example 2: Specific Version Set

```bash
# Request a specific version
> Set version to 3.0.0-beta.1
```

This is useful for prereleases or when coordinating version numbers across multiple projects.

### Example 3: Preview Before Applying

```bash
# Preview changes without applying
> Show me what a patch bump would look like
```

Claude will display the proposed changes without modifying any files.

## Best Practices for Version Bump Workflows

### 1. Always Use Dry-Run Mode

Before making any changes, preview what will happen:

```bash
> What files would be modified for a major version bump?
```

### 2. Maintain a CHANGELOG

Include automatic CHANGELOG generation in your workflow:

```yaml
## Add to skill definition

### CHANGELOG Updates

After bumping version, offer to:
1. Generate changelog entries from git commits since last release
2. Update release date in CHANGELOG.md
3. Create GitHub release notes
```

### 3. Coordinate Across Multiple Packages

For monorepos or multi-package projects, update all related packages:

```bash
> Bump all packages to 2.0.0
```

### 4. Integrate with CI/CD

Add version bump to your release pipeline:

```yaml
# .github/workflows/release.yml
name: Release
on:
  push:
    tags:
      - 'v*'

jobs:
  release:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Bump version
        run: |
          git tag -d ${{ github.ref_name }} || true
          npm version patch
          git push origin --tags
```

## Troubleshooting Common Issues

### Version Not Found

If Claude can't find the version, provide explicit guidance:

```bash
> The version is in src/__init__.py as __version__ = "1.0.0"
```

### Merge Conflicts in Version Files

Always resolve conflicts manually:

```bash
> Show me the conflicting version files so I can resolve manually
```

### Wrong Version Bump Type

Mistakes happen. To revert:

```bash
> Revert the last version bump and try again as a patch release
```

Then: `git revert HEAD && git tag -d v1.2.4`

## Conclusion

Automating version bumps with Claude Code transforms a tedious manual process into a simple conversation. By creating a well-designed skill with clear instructions, proper tool access, and helper scripts, you can eliminate version management errors and make releases feel effortless. Start with the basic implementation shown here, then customize it to match your project's specific needs and conventions.

The key is to treat version bumping not as a chore, but as another opportunity to let Claude handle the repetitive details while you focus on writing code.
{% endraw %}

## Related Reading

- [Claude Code for Beginners: Complete Getting Started Guide](/claude-skills-guide/claude-code-for-beginners-complete-getting-started-2026/)
- [Best Claude Skills for Developers in 2026](/claude-skills-guide/best-claude-skills-for-developers-2026/)
- [Claude Skills Guides Hub](/claude-skills-guide/guides-hub/)

