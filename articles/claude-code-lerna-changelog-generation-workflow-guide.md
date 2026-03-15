---

layout: default
title: "Claude Code Lerna Changelog Generation Workflow Guide"
description: "Learn how to automate changelog generation in Lerna monorepos using Claude Code. Set up intelligent commit parsing, conventional commits integration."
date: 2026-03-14
author: "Claude Skills Guide"
categories: [guides]
tags: [claude-code, claude-skills]
permalink: /claude-code-lerna-changelog-generation-workflow-guide/
reviewed: true
score: 7
---


{% raw %}
# Claude Code Lerna Changelog Generation Workflow Guide

Managing changelogs across a Lerna monorepo can quickly become a tedious task as your project grows. With multiple packages, each following different versioning schemes, manually tracking changes and generating meaningful release notes is error-prone and time-consuming. This guide shows you how to use Claude Code to automate and intelligentize your changelog generation workflow.

## Understanding the Lerna Changelog Challenge

Lerna monorepos present unique challenges for changelog management. Each package in your monorepo may have its own release cycle, version numbers, and change patterns. When you run `lerna publish` or `lerna version`, you need changelogs that accurately reflect what changed in each package—not just a flat list of all commits.

Claude Code can help by:
- Parsing commit messages to categorize changes (feat, fix, docs, etc.)
- Grouping changes by package
- Generating human-readable summaries
- Integrating with conventional commits standards

## Setting Up Your Changelog Generation Skill

First, create a dedicated Claude skill for changelog operations. This skill will encapsulate the logic for parsing, grouping, and formatting your monorepo changes.

```yaml
---
name: lerna-changelog
description: Generate and manage changelogs in Lerna monorepos
  - Bash
  - Read
  - Write
  - Glob
---
```

This skill restricts tool access to only what's necessary—reading your repository structure, executing git and Lerna commands, and writing output files.

## Parsing Commits with Claude

The core of intelligent changelog generation is commit parsing. Claude can analyze your git history and categorize changes based on conventional commit format:

```javascript
// analyze-commits.js
const { execSync } = require('child_process');

function getCommitsSince(tag) {
  const range = tag ? `${tag}..HEAD` : '--all';
  const output = execSync(`git log ${range} --pretty=format:"%s|%h|%an|%ae"`, {
    encoding: 'utf-8'
  });
  
  return output.trim().split('\n').map(line => {
    const [message, hash, author, email] = line.split('|');
    const [type, scope, ...rest] = message.replace(/^(\w+)(\(.+\))?:\s*/, '$1$2|').split('|');
    
    return {
      hash,
      message,
      type: type || 'other',
      scope: scope?.replace(/[()]/g, ''),
      author,
      email
    };
  });
}

module.exports = { getCommitsSince };
```

This script parses commits into structured data that Claude can then organize into meaningful changelog entries.

## Integrating with Lerna's Versioning

Claude can read Lerna's package metadata to understand which packages changed:

```bash
# Get changed packages since last release
lerna changed --since=last-release --json
```

Combine this with commit analysis to generate package-specific changelogs:

```javascript
async function generatePackageChangelogs() {
  const lernaJson = JSON.parse(await readFile('lerna.json'));
  const packages = await glob('packages/*/package.json');
  
  for (const pkg of packages) {
    const pkgData = JSON.parse(await readFile(pkg));
    const commits = await getCommitsForPackage(pkgData.name);
    
    if (commits.length > 0) {
      const changelog = formatChangelog(commits, pkgData.name);
      await writeFile(
        `packages/${pkgData.name}/CHANGELOG.md`,
        changelog,
        { append: true }
      );
    }
  }
}
```

This approach ensures each package maintains its own accurate changelog.

## Building the Changelog Generation Workflow

Here's how to orchestrate the full workflow with Claude:

1. **Detect Changes**: Run `lerna changed` to find packages with updates
2. **Fetch Commits**: Get commits for each changed package
3. **Categorize**: Parse commit types using conventional commit patterns
4. **Format**: Generate Markdown with proper headings and sections
5. **Update Files**: Append or overwrite package changelogs

```yaml
## Changelog Generation Workflow

### Detect Changed Packages
Execute lerna changed to identify which packages have updates since the last release.

### Analyze Commit History
For each changed package:
- Fetch commits touching that package's directory
- Parse conventional commit format (type, scope, description)
- Group by type: Features, Bug Fixes, Breaking Changes, etc.

### Generate Changelog Entries
Create well-formatted Markdown entries:
- Use semantic headings
- Include commit hash references
- Link to issues and PRs when available

### Update Changelog Files
Automatically append new entries to each package's CHANGELOG.md
```

## Conventional Commits Integration

For best results, enforce conventional commits in your workflow. This standard formats commit messages as:

```
<type>(<scope>): <description>

[optional body]

[optional footer]
```

Common types include:
- `feat`: New features
- `fix`: Bug fixes
- `docs`: Documentation changes
- `style`: Code style changes
- `refactor`: Code refactoring
- `test`: Test updates
- `chore`: Maintenance tasks

When your team follows this convention, Claude can automatically generate well-organized changelogs with proper categorization.

## Actionable Tips for Better Changelogs

### 1. Automate Version Tagging

Pair changelog generation with Lerna's version command:

```bash
lerna version --conventional-commits --changelog
```

This automatically updates versions and generates changelogs based on conventional commits.

### 2. Include Context in Commits

Encourage detailed commit messages that include:
- What changed and why
- Related issue numbers
- Breaking change notices

### 3. Review Before Publishing

Generate changelogs as part of your PR process so reviewers can verify completeness:

```bash
# Preview changelog without publishing
claude --print "/lerna-changelog" --preview
```

### 4. Handle Monorepo Dependencies

When packages depend on each other, reference those relationships in changelogs:

```javascript
const dependencies = require('./package.json').dependencies;

function getDeprecationNotices(pkgName) {
  return Object.entries(dependencies).map(([dep, version]) => {
    if (isDeprecated(dep)) {
      return `**Note:** This package uses \`${dep}\` which is deprecated.`;
    }
    return null;
  }).filter(Boolean);
}
```

## Advanced: Multi-Language Monorepo Support

If your Lerna monorepo contains packages in different languages (TypeScript, Python, Rust), adapt your commit parsing:

```javascript
function detectLanguageFromPath(path) {
  if (path.endsWith('.ts') || path.endsWith('.tsx')) return 'typescript';
  if (path.endsWith('.py')) return 'python';
  if (path.endsWith('.rs')) return 'rust';
  return 'unknown';
}

function getCommitsForPackage(pkgPath) {
  // Get commits that touched files in this package
  const output = execSync(
    `git log --all --format="%H %s" -- ${pkgPath}`,
    { encoding: 'utf-8' }
  );
  return parseCommitLog(output);
}
```

This ensures accurate changelog generation regardless of your monorepo's composition.

## Conclusion

Automating changelog generation in Lerna monorepos with Claude Code eliminates manual tracking and ensures consistent, comprehensive release notes. By combining conventional commits, Lerna's package detection, and Claude's natural language processing, you create a reproducible workflow that scales with your project.

Start by setting up the basic commit parsing, then gradually add features like dependency tracking, multi-language support, and preview workflows. Your future self—and your users—will thank you for the clear, organized changelogs.
{% endraw %}

## Related Reading

- [Claude Code for Beginners: Complete Getting Started Guide](/claude-skills-guide/claude-code-for-beginners-complete-getting-started-2026/)
- [Best Claude Skills for Developers in 2026](/claude-skills-guide/best-claude-skills-for-developers-2026/)
- [Claude Skills Guides Hub](/claude-skills-guide/guides-hub/)

