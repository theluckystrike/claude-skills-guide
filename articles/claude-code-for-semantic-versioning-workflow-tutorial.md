---

layout: default
title: "Claude Code for Semantic Versioning"
description: "Learn how to implement a complete semantic versioning workflow using Claude Code. This tutorial covers automated version bumps, commit analysis."
date: 2026-03-15
last_modified_at: 2026-04-17
author: "Claude Skills Guide"
permalink: /claude-code-for-semantic-versioning-workflow-tutorial/
categories: [tutorials]
tags: [claude-code, claude-skills]
reviewed: true
score: 8
render_with_liquid: false
geo_optimized: true
last_tested: "2026-04-22"
---

{% raw %}
Semantic versioning provides a standardized approach to communicating project changes, but manually tracking versions, analyzing commits, and generating releases consumes valuable development time. This comprehensive tutorial demonstrates how to build an automated semantic versioning workflow using Claude Code that handles version detection, changelog generation, and release tagging without manual intervention.

## Prerequisites and Setup

Before building your semantic versioning workflow, ensure your project has the necessary foundation. You'll need Node.js installed, a Git repository initialized, and Claude Code configured with access to file system operations and shell command execution.

Create a dedicated Claude Code skill for version management by establishing the skill directory structure:

```bash
mkdir -p claude-skills/semantic-version
mkdir -p claude-skills/semantic-version/lib
```

The skill will consist of three main components: a commit analyzer, a version calculator, and a release orchestrator. Each component handles a specific aspect of the versioning pipeline, enabling modular testing and easy customization.

## Building the Commit Analyzer

The commit analyzer examines your Git history to determine which version component requires incrementing. This skill component parses conventional commit messages and detects breaking changes that warrant a major version bump.

Create the analyzer module in `claude-skills/semantic-version/lib/analyzer.js`:

```javascript
// claude-skills/semantic-version/lib/analyzer.js

/
 * Analyzes commit messages to determine version impact
 * Following conventional commits specification
 */
function analyzeCommit(commitMessage) {
 const breakingMatch = commitMessage.match(/BREAKING CHANGE:/);
 const scopeMatch = commitMessage.match(/^(\w+)(\(.+\))?!?:/);
 
 let impact = 'patch';
 
 if (breakingMatch || (scopeMatch && scopeMatch[0].includes('!'))) {
 impact = 'major';
 } else if (scopeMatch && scopeMatch[1] === 'feat') {
 impact = 'minor';
 }
 
 return {
 message: commitMessage,
 impact,
 type: scopeMatch ? scopeMatch[1] : 'other',
 isBreaking: !!breakingMatch
 };
}

function analyzeCommits(commits) {
 let hasMajor = false;
 let hasMinor = false;
 let hasPatch = false;
 
 for (const commit of commits) {
 const analysis = analyzeCommit(commit.message);
 if (analysis.impact === 'major') hasMajor = true;
 else if (analysis.impact === 'minor') hasMinor = true;
 else if (analysis.impact === 'patch') hasPatch = true;
 }
 
 return {
 shouldBumpMajor: hasMajor,
 shouldBumpMinor: hasMinor && !hasMajor,
 shouldBumpPatch: hasPatch && !hasMinor && !hasMajor
 };
}

module.exports = { analyzeCommit, analyzeCommits };
```

This analyzer distinguishes between patch fixes, new features, and breaking changes. The logic prioritizes major versions when any breaking change exists, since semantic versioning mandates that major version increments supersede minor and patch changes.

## Creating the Version Calculator

The version calculator applies the analysis results to your current version string. It parses existing version numbers, applies the appropriate increment, and generates the new version along with appropriate git tags.

Implement the calculator in `claude-skills/semantic-version/lib/calculator.js`:

```javascript
// claude-skills/semantic-version/lib/calculator.js

/
 * Calculates new version based on impact analysis
 * Follows semver.org specification
 */
function parseVersion(versionString) {
 const match = versionString.match(/^(\d+)\.(\d+)\.(\d+)/);
 if (!match) {
 throw new Error(`Invalid version format: ${versionString}`);
 }
 return {
 major: parseInt(match[1], 10),
 minor: parseInt(match[2], 10),
 patch: parseInt(match[3], 10)
 };
}

function calculateNewVersion(currentVersion, analysis) {
 const version = parseVersion(currentVersion);
 
 if (analysis.shouldBumpMajor) {
 return `${version.major + 1}.0.0`;
 }
 if (analysis.shouldBumpMinor) {
 return `${version.major}.${version.minor + 1}.0`;
 }
 if (analysis.shouldBumpPatch) {
 return `${version.major}.${version.minor}.${version.patch + 1}`;
 }
 
 return currentVersion;
}

function getVersionFromPackageJson() {
 const fs = require('fs');
 const packageJson = JSON.parse(fs.readFileSync('package.json', 'utf8'));
 return packageJson.version;
}

module.exports = { parseVersion, calculateNewVersion, getVersionFromPackageJson };
```

The calculator maintains backward compatibility by returning the current version unchanged when no commits warrant an update. This prevents unnecessary version bumps during maintenance work or documentation changes.

## Orchestrating the Release Workflow

The main skill file coordinates the entire versioning process, from fetching commits to creating git tags and updating package files. This orchestrator serves as the entry point that Claude Code invokes.

Create the main skill file in `claude-skills/semantic-version/SKILL.md`:

```markdown
Semantic Versioning Skill

This skill automates semantic versioning based on conventional commits analysis.

When to Use

- Before creating releases
- After merging significant changes
- During release preparation

Actions

1. Fetch commits since last tag
2. Analyze commit messages for impact
3. Calculate new version number
4. Update version in package.json
5. Generate changelog entries
6. Create git tag
```

The corresponding implementation in `claude-skills/semantic-version/main.js`:

```javascript
// claude-skills/semantic-version/main.js
const { analyzeCommits } = require('./lib/analyzer');
const { calculateNewVersion, getVersionFromPackageJson } = require('./lib/calculator');
const { execSync } = require('child_process');

function executeVersionBump() {
 // Get current version
 const currentVersion = getVersionFromPackageJson();
 
 // Get commits since last tag
 const lastTag = execSync('git describe --tags --abbrev=0 2>/dev/null', { encoding: 'utf8' }).trim();
 const commits = execSync(`git log ${lastTag}..HEAD --pretty=format:"%s"`, { encoding: 'utf8' })
 .split('\n')
 .filter(Boolean);
 
 // Analyze commits
 const analysis = analyzeCommits(commits);
 
 // Calculate new version
 const newVersion = calculateNewVersion(currentVersion, analysis);
 
 if (newVersion === currentVersion) {
 console.log('No version bump needed');
 return;
 }
 
 console.log(`Bumping version from ${currentVersion} to ${newVersion}`);
 
 // Update package.json
 const fs = require('fs');
 const packageJson = JSON.parse(fs.readFileSync('package.json', 'utf8'));
 packageJson.version = newVersion;
 fs.writeFileSync('package.json', JSON.stringify(packageJson, null, 2));
 
 // Create git tag
 execSync(`git tag -a v${newVersion} -m "Release v${newVersion}"`);
 
 console.log(`Version ${newVersion} tagged successfully`);
}

module.exports = { executeVersionBump };
```

## Integrating with Claude Code

After creating the skill files, register them with Claude Code by adding the skill to your configuration:

```bash
Add to your CLAUDE.md or project-specific configuration
Available skills:
- semantic-version: Automated semantic versioning and release tagging
```

When you're ready to create a release, invoke the skill:

```
Bump the version using semantic-version skill
```

Claude Code will execute the versioning workflow, analyzing your commits and creating the appropriate release.

## CI/CD Integration

Automate version bumps in your CI pipeline with a GitHub Actions workflow:

```yaml
name: Semantic Release
on:
 push:
 branches: [main]
jobs:
 release:
 runs-on: ubuntu-latest
 steps:
 - uses: actions/checkout@v3
 with:
 fetch-depth: 0
 - uses: actions/setup-node@v4
 - run: npm ci
 - name: Run semantic versioning
 id: semantic-version
 run: node claude-skills/semantic-version/main.js
 - name: Create GitHub Release
 if: steps.semantic-version.outputs.new-version
 uses: actions/create-release@v1
 env:
 GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
```

## Changelog Generation

Extend the skill with a changelog generator that groups commits by type:

```javascript
function generateChangelog(commits, newVersion) {
 const groups = { feat: [], fix: [], docs: [], perf: [], refactor: [] };
 commits.forEach(c => {
 const type = c.message.split(':')[0].replace(/\(.+\)/, '');
 if (groups[type]) groups[type].push(c.message);
 });

 let changelog = `## ${newVersion}\n\n`;
 if (groups.feat.length) changelog += `### Features\n${groups.feat.map(m => `- ${m}`).join('\n')}\n\n`;
 if (groups.fix.length) changelog += `### Bug Fixes\n${groups.fix.map(m => `- ${m}`).join('\n')}\n\n`;
 return changelog;
}
```

## Best Practices for Versioning Workflows

Maintain consistency in your versioning workflow by following these proven practices. First, always use conventional commit messages, establish team conventions requiring `feat:`, `fix:`, and `BREAKING CHANGE:` prefixes for clear version impact detection. Second, automate the version bump in your CI pipeline. Third, use annotated tags over lightweight tags, they store metadata, author info, and message content that lightweight tags omit. Fourth, document versioning conventions in a CONTRIBUTING.md file for contributors. Fifth, test version calculations in isolation before applying changes to production repositories.

The tdd skill helps verify release-readiness, pdf and docx skills generate versioned release documentation, and supermemory tracks release history across sessions.

## Troubleshooting Common Issues

Several common issues can disrupt your versioning workflow. When commits aren't detected, verify that tags exist in your repository, first-time setup requires an initial tag like `v1.0.0` for the analyzer to calculate diffs. When version files aren't found, ensure package.json exists in your working directory or modify the skill to accept a custom path parameter.

If breaking changes aren't detected, confirm that `BREAKING CHANGE:` appears exactly as specified in the conventional commits standard. The analyzer performs exact matching, so variations won't trigger major version bumps.

## Conclusion

Automating semantic versioning with Claude Code eliminates manual version tracking while ensuring consistent, predictable releases. The modular skill architecture allows incremental improvements, start with basic commit analysis, then add changelog generation, GitHub release creation, or npm publishing as your workflow matures.

By implementing this tutorial's patterns, your team gains reliable version management that scales with project complexity while maintaining the flexibility to adapt to specific release requirements.



---

---

<div class="mastery-cta">

I'm a solo developer in Vietnam. 50K Chrome extension users. $500K+ on Upwork. 5 Claude Max subscriptions running agent fleets in parallel.

These are my actual CLAUDE.md templates, orchestration configs, and prompts. Not a course. Not theory. The files I copy into every project before I write a line of code.

**[See what's inside →](https://zovo.one/lifetime?utm_source=ccg&utm_medium=cta-default&utm_campaign=claude-code-for-semantic-versioning-workflow-tutorial)**

$99 once. Free forever. 47/500 founding spots left.

</div>

Related Reading

- [Claude Code for Semantic Code Search Workflow Tutorial](/claude-code-for-semantic-code-search-workflow-tutorial/)
- [Claude Code Algolia GeoSearch Filtering Workflow Tutorial](/claude-code-algolia-geosearch-filtering-workflow-tutorial/)
- [Claude Code CloudFormation Template Generation Workflow Guid](/claude-code-cloudformation-template-generation-workflow-guid/)
- [Claude Code Lerna Independent Versioning Workflow Tutorial](/claude-code-lerna-independent-versioning-workflow-tutorial/)

Built by theluckystrike. More at [zovo.one](https://zovo.one)
{% endraw %}


