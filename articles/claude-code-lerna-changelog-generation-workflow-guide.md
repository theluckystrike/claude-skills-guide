---

layout: default
title: "Claude Code Lerna Changelog Generation Workflow Guide"
description: "Learn how to automate changelog generation in Lerna monorepos using Claude Code. Set up intelligent commit parsing, conventional commits integration."
date: 2026-03-14
last_modified_at: 2026-04-17
author: "Claude Skills Guide"
categories: [guides]
tags: [claude-code, claude-skills]
permalink: /claude-code-lerna-changelog-generation-workflow-guide/
reviewed: true
score: 7
render_with_liquid: false
geo_optimized: true
---

{% raw %}
Claude Code Lerna Changelog Generation Workflow Guide

Managing changelogs across a Lerna monorepo can quickly become a tedious task as your project grows. With multiple packages, each following different versioning schemes, manually tracking changes and generating meaningful release notes is error-prone and time-consuming. This guide shows you how to use Claude Code to automate and intelligentize your changelog generation workflow.

## Understanding the Lerna Changelog Challenge

Lerna monorepos present unique challenges for changelog management. Each package in your monorepo may have its own release cycle, version numbers, and change patterns. When you run `lerna publish` or `lerna version`, you need changelogs that accurately reflect what changed in each package, not just a flat list of all commits.

The core problem is attribution: a single git repository contains commits that touch many packages simultaneously. A refactor that spans `@myorg/ui`, `@myorg/core`, and `@myorg/api` produces commits that belong in all three changelogs, but not necessarily with the same wording. Automated tools that operate on raw commit messages often generate noisy or redundant changelogs. Claude Code adds an intelligence layer that categorizes, deduplicates, and rewrites entries into clean, human-readable prose.

Claude Code can help by:
- Parsing commit messages to categorize changes (feat, fix, docs, etc.)
- Grouping changes by package
- Generating human-readable summaries
- Integrating with conventional commits standards
- Detecting cross-package dependency changes that warrant coordinated release notes

## Why Manual Changelog Management Fails at Scale

Consider a monorepo with 12 packages releasing monthly. Each release cycle involves:

| Task | Manual Time | Automated Time |
|------|-------------|----------------|
| Identify which packages changed | 15 min | 30 sec (`lerna changed`) |
| Collect commits per package | 30 min | 1 min (git log + path filter) |
| Categorize by type (feat/fix/etc.) | 20 min | Automatic (conventional commits) |
| Write human-readable summaries | 45 min | 2 min (Claude Code) |
| Cross-reference related packages | 20 min | 5 min (dependency graph) |
| Format and insert into CHANGELOG.md | 15 min | 30 sec (script) |
| Total | ~2.5 hours | ~10 minutes |

At twelve packages, the manual approach consumes a full afternoon before every release. The automated approach reduces it to a brief review step.

## Setting Up Your Changelog Generation Skill

First, create a dedicated Claude skill for changelog operations. This skill will encapsulate the logic for parsing, grouping, and formatting your monorepo changes.

```yaml
---
name: lerna-changelog
description: Generate and manage changelogs in Lerna monorepos
---
```

This skill restricts tool access to only what's necessary, reading your repository structure, executing git and Lerna commands, and writing output files.

## Project Prerequisites

Before the workflow runs reliably, your repository needs a few structural requirements:

```bash
Confirm Lerna is installed and configured
npx lerna --version

Confirm your lerna.json has version config
cat lerna.json
```

A minimal `lerna.json` for changelog automation:

```json
{
 "version": "independent",
 "npmClient": "npm",
 "packages": ["packages/*"],
 "command": {
 "version": {
 "conventionalCommits": true,
 "changelogPreset": "conventional-changelog-angular"
 }
 }
}
```

Setting `"version": "independent"` is important. It means each package gets its own version number and its own changelog entries, rather than all packages bumping together.

## Installing Required Dependencies

```bash
Core Lerna
npm install --save-dev lerna

Conventional commits tooling
npm install --save-dev @commitlint/config-conventional @commitlint/cli husky

Changelog preset
npm install --save-dev conventional-changelog-angular

If you want programmatic access
npm install --save-dev conventional-changelog-core
```

Set up commit linting so every commit in the project follows the expected format:

```bash
commitlint.config.js
module.exports = { extends: ['@commitlint/config-conventional'] };

.husky/commit-msg
npx --no -- commitlint --edit "$1"
```

With this in place, commits that don't follow the `type(scope): description` format are rejected at the commit stage, before they pollute your history.

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

## Attributing Commits to Packages

Raw commit parsing gives you a flat list. The next step is mapping each commit to the packages it actually touched. Git's `--` path filter is the most reliable approach:

```javascript
// package-commits.js
const { execSync } = require('child_process');
const path = require('path');

function getChangedFilesForCommit(hash) {
 const output = execSync(`git diff-tree --no-commit-id -r --name-only ${hash}`, {
 encoding: 'utf-8'
 });
 return output.trim().split('\n');
}

function attributeCommitToPackages(commit, packagePaths) {
 const changedFiles = getChangedFilesForCommit(commit.hash);
 const touchedPackages = new Set();

 for (const file of changedFiles) {
 for (const [pkgName, pkgPath] of Object.entries(packagePaths)) {
 if (file.startsWith(pkgPath + '/')) {
 touchedPackages.add(pkgName);
 }
 }
 }

 return Array.from(touchedPackages);
}

function buildPackageCommitMap(commits, packagePaths) {
 const map = {};

 for (const commit of commits) {
 const packages = attributeCommitToPackages(commit, packagePaths);

 for (const pkg of packages) {
 if (!map[pkg]) map[pkg] = [];
 map[pkg].push(commit);
 }
 }

 return map;
}

module.exports = { buildPackageCommitMap, attributeCommitToPackages };
```

This produces a map keyed by package name, each containing only the commits that touched files within that package's directory. Commits that span multiple packages appear in each relevant package's list.

## Handling Scope vs. Path Attribution

Conventional commits support an optional scope field: `feat(auth): add OAuth2 support`. When developers use scopes that match package names, you can use scope-based attribution instead of (or alongside) path-based attribution:

```javascript
function attributeByScope(commits, packageNames) {
 const map = {};

 for (const commit of commits) {
 // Scope attribution: "feat(core): ..." goes to @myorg/core
 if (commit.scope) {
 const matchingPkg = packageNames.find(
 name => name === commit.scope || name.endsWith(`/${commit.scope}`)
 );
 if (matchingPkg) {
 if (!map[matchingPkg]) map[matchingPkg] = [];
 map[matchingPkg].push({ ...commit, attributionMethod: 'scope' });
 continue;
 }
 }

 // Fall back to path-based attribution
 // (handled by attributeCommitToPackages)
 }

 return map;
}
```

A good practice is to prefer scope attribution when the scope is present and matches a known package, and fall back to path analysis otherwise.

## Integrating with Lerna's Versioning

Claude can read Lerna's package metadata to understand which packages changed:

```bash
Get changed packages since last release
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

## Reading the Lerna Dependency Graph

In a monorepo, packages depend on each other. When `@myorg/core` bumps a major version, every package that depends on it should mention the upstream change in its own changelog. Claude Code can read the dependency graph:

```javascript
const { execSync } = require('child_process');

function getLernaDependencyGraph() {
 const output = execSync('lerna list --graph --json', { encoding: 'utf-8' });
 return JSON.parse(output);
}

function getAffectedByUpstream(pkgName, graph) {
 // Find all packages that list pkgName as a dependency
 const affected = [];

 for (const [name, deps] of Object.entries(graph)) {
 if (deps.includes(pkgName) && name !== pkgName) {
 affected.push(name);
 }
 }

 return affected;
}
```

With this information, Claude Code can append a note to downstream changelogs:

```markdown
Dependencies

- Updated dependency on `@myorg/core` to `^3.0.0` (breaking change in upstream)
```

This kind of cross-package transparency is something purely mechanical tools miss entirely.

## Building the Changelog Generation Workflow

Here's how to orchestrate the full workflow with Claude:

1. Detect Changes: Run `lerna changed` to find packages with updates
2. Fetch Commits: Get commits for each changed package
3. Categorize: Parse commit types using conventional commit patterns
4. Format: Generate Markdown with proper headings and sections
5. Update Files: Append or overwrite package changelogs

```yaml
Changelog Generation Workflow

Detect Changed Packages
Execute lerna changed to identify which packages have updates since the last release.

Analyze Commit History
For each changed package:
- Fetch commits touching that package's directory
- Parse conventional commit format (type, scope, description)
- Group by type: Features, Bug Fixes, Breaking Changes, etc.

Generate Changelog Entries
Create well-formatted Markdown entries:
- Use semantic headings
- Include commit hash references
- Link to issues and PRs when available

Update Changelog Files
Automatically append new entries to each package's CHANGELOG.md
```

## The Complete Orchestration Script

Here is a production-ready orchestration script that ties all the pieces together:

```javascript
// scripts/generate-changelogs.js
const { execSync } = require('child_process');
const fs = require('fs');
const path = require('path');

const PACKAGES_DIR = path.resolve(__dirname, '../packages');

async function main() {
 // Step 1: Find changed packages
 let changedPackages;
 try {
 const output = execSync('npx lerna changed --json', { encoding: 'utf-8' });
 changedPackages = JSON.parse(output);
 } catch {
 console.log('No packages have changed since last release.');
 return;
 }

 console.log(`Found ${changedPackages.length} changed packages.`);

 // Step 2: For each changed package, generate changelog
 for (const pkg of changedPackages) {
 const pkgDir = pkg.location;
 const lastTag = getLastTagForPackage(pkg.name);
 const commits = getCommitsForDirectory(pkgDir, lastTag);

 if (commits.length === 0) {
 console.log(` ${pkg.name}: no commits found, skipping.`);
 continue;
 }

 const categorized = categorizeCommits(commits);
 const entry = formatChangelogEntry(pkg.version, categorized);
 prependToChangelog(path.join(pkgDir, 'CHANGELOG.md'), entry);

 console.log(` ${pkg.name}: wrote ${commits.length} entries.`);
 }
}

function getLastTagForPackage(pkgName) {
 try {
 return execSync(`git describe --tags --abbrev=0 --match="${pkgName}@*"`, {
 encoding: 'utf-8'
 }).trim();
 } catch {
 return null; // No prior tag; include all commits
 }
}

function getCommitsForDirectory(dir, since) {
 const range = since ? `${since}..HEAD` : 'HEAD';
 const relDir = path.relative(process.cwd(), dir);
 const output = execSync(
 `git log ${range} --pretty=format:"%H|%s|%an" -- ${relDir}`,
 { encoding: 'utf-8' }
 );

 if (!output.trim()) return [];

 return output.trim().split('\n').map(line => {
 const [hash, subject, author] = line.split('|');
 const match = subject.match(/^(\w+)(?:\(([^)]+)\))?(!)?:\s+(.+)/);
 return {
 hash: hash.slice(0, 8),
 type: match ? match[1] : 'other',
 scope: match ? match[2] : null,
 breaking: match ? !!match[3] : false,
 description: match ? match[4] : subject,
 author
 };
 });
}

function categorizeCommits(commits) {
 const categories = {
 breaking: [],
 feat: [],
 fix: [],
 perf: [],
 docs: [],
 refactor: [],
 test: [],
 chore: [],
 other: []
 };

 for (const commit of commits) {
 if (commit.breaking) {
 categories.breaking.push(commit);
 } else if (categories[commit.type]) {
 categories[commit.type].push(commit);
 } else {
 categories.other.push(commit);
 }
 }

 return categories;
}

function formatChangelogEntry(version, categorized) {
 const date = new Date().toISOString().split('T')[0];
 const lines = [`\n## ${version} (${date})\n`];

 const sections = [
 ['BREAKING CHANGES', categorized.breaking],
 ['Features', categorized.feat],
 ['Bug Fixes', categorized.fix],
 ['Performance', categorized.perf],
 ['Documentation', categorized.docs],
 ['Refactoring', categorized.refactor],
 ['Tests', categorized.test],
 ['Maintenance', categorized.chore],
 ['Other', categorized.other]
 ];

 for (const [heading, commits] of sections) {
 if (commits.length === 0) continue;
 lines.push(`### ${heading}\n`);
 for (const c of commits) {
 const scope = c.scope ? `${c.scope}: ` : '';
 lines.push(`- ${scope}${c.description} ([${c.hash}])`);
 }
 lines.push('');
 }

 return lines.join('\n');
}

function prependToChangelog(filePath, content) {
 const existing = fs.existsSync(filePath) ? fs.readFileSync(filePath, 'utf-8') : '# Changelog\n';
 const header = existing.startsWith('# Changelog') ? existing : `# Changelog\n\n${existing}`;
 const insertPoint = header.indexOf('\n## ');
 const newContent = insertPoint === -1
 ? header + content
 : header.slice(0, insertPoint) + content + header.slice(insertPoint);
 fs.writeFileSync(filePath, newContent);
}

main().catch(console.error);
```

Wire this into your `package.json` scripts:

```json
{
 "scripts": {
 "changelog": "node scripts/generate-changelogs.js",
 "release": "npm run changelog && lerna version --no-changelog && git push --follow-tags"
 }
}
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

## Commit Type Decision Guide

Developers often debate which type to use. This table clarifies the intent:

| Type | When to Use | Example |
|------|-------------|---------|
| `feat` | Any new capability exposed to consumers | `feat(auth): add passwordless login` |
| `fix` | Correcting a defect that caused wrong behavior | `fix(cart): prevent negative item quantities` |
| `perf` | Optimization with no behavior change | `perf(search): add database index on email column` |
| `refactor` | Code restructuring with no behavior change | `refactor(payments): extract StripeClient class` |
| `docs` | Documentation, comments, README only | `docs(api): document rate limiting headers` |
| `test` | Adding or correcting tests only | `test(auth): add edge cases for token expiry` |
| `style` | Formatting, whitespace, semicolons | `style: apply prettier to all files` |
| `chore` | Tooling, dependencies, CI config | `chore(deps): upgrade eslint to v9` |
| `build` | Build system changes | `build: switch from webpack to vite` |
| `ci` | CI/CD pipeline changes | `ci: add staging environment deploy step` |

A common mistake is using `chore` for everything non-feature. Keeping types accurate means users reading your changelogs get honest signal about what changed.

## Enforcing Conventional Commits With Commitlint

```javascript
// commitlint.config.js
module.exports = {
 extends: ['@commitlint/config-conventional'],
 rules: {
 // Allow scopes that match your package names
 'scope-enum': [
 2,
 'always',
 ['core', 'ui', 'api', 'auth', 'payments', 'notifications', 'docs']
 ],
 // Subject must not end with a period
 'subject-full-stop': [2, 'never', '.'],
 // Subject must be lowercase
 'subject-case': [2, 'never', ['sentence-case', 'start-case', 'pascal-case', 'upper-case']],
 // Body must be present for breaking changes
 'body-max-line-length': [1, 'always', 100]
 }
};
```

The `scope-enum` rule is particularly valuable in monorepos: it forces developers to declare which package their commit targets, giving you clean scope-based attribution for free.

## Actionable Tips for Better Changelogs

1. Automate Version Tagging

Pair changelog generation with Lerna's version command:

```bash
lerna version --conventional-commits --changelog
```

This automatically updates versions and generates changelogs based on conventional commits.

2. Include Context in Commits

Encourage detailed commit messages that include:
- What changed and why
- Related issue numbers
- Breaking change notices

A commit with a body gives Claude Code much more to work with:

```
feat(checkout): add Apple Pay support

Adds Apple Pay as a checkout option on Safari browsers.
Requires APPLE_PAY_MERCHANT_ID to be set in environment config.

The payment flow now checks for Apple Pay availability via
window.ApplePaySession before rendering the button.

Closes #412
BREAKING CHANGE: PaymentMethod enum adds 'apple_pay' value;
consumers must handle the new variant.
```

Versus a bare `feat(checkout): add Apple Pay support`. the former produces a rich changelog entry; the latter produces a one-liner.

3. Review Before Publishing

Generate changelogs as part of your PR process so reviewers can verify completeness:

```bash
Preview changelog without publishing
claude --print "/lerna-changelog" --preview
```

4. Handle Monorepo Dependencies

When packages depend on each other, reference those relationships in changelogs:

```javascript
const dependencies = require('./package.json').dependencies;

function getDeprecationNotices(pkgName) {
 return Object.entries(dependencies).map(([dep, version]) => {
 if (isDeprecated(dep)) {
 return `Note: This package uses \`${dep}\` which is deprecated.`;
 }
 return null;
 }).filter(Boolean);
}
```

5. Tag Releases Consistently

The entire workflow depends on git tags being present and consistently named. Adopt a naming convention and never deviate:

```bash
For independent versioning (recommended)
Tags look like: @myorg/core@3.2.1
lerna version --conventional-commits

For fixed versioning
Tags look like: v1.5.0
lerna version --conventional-commits
```

If you have an older repository with inconsistent tag formats, normalize them before setting up the automated workflow:

```bash
List all existing tags
git tag -l | sort -V

Rename a tag (requires push force on the tag ref)
git tag new-name old-name
git tag -d old-name
git push origin :refs/tags/old-name
git push origin new-name
```

6. Add a Root-Level Summary Changelog

Individual package changelogs are ideal for package consumers, but your team often wants a single view of everything that shipped in a release. Generate a root `CHANGELOG.md` that aggregates entries:

```javascript
async function generateRootChangelog(version, packageChangelogs) {
 const date = new Date().toISOString().split('T')[0];
 const lines = [`## Release ${version} (${date})\n`];

 for (const [pkgName, entries] of Object.entries(packageChangelogs)) {
 if (entries.length === 0) continue;
 lines.push(`### ${pkgName}\n`);
 for (const entry of entries) {
 lines.push(`- ${entry.description}`);
 }
 lines.push('');
 }

 const existing = fs.existsSync('CHANGELOG.md')
 ? fs.readFileSync('CHANGELOG.md', 'utf-8')
 : '# Changelog\n';
 fs.writeFileSync('CHANGELOG.md', existing + '\n' + lines.join('\n'));
}
```

## Advanced: Multi-Language Monorepo Support

If your Lerna monorepo contains packages in different languages (TypeScript, Python, Rust), adapt your commit parsing:

```javascript
function detectLanguageFromPath(filePath) {
 if (filePath.endsWith('.ts') || filePath.endsWith('.tsx')) return 'typescript';
 if (filePath.endsWith('.py')) return 'python';
 if (filePath.endsWith('.rs')) return 'rust';
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

## Python Packages in a Node Monorepo

Some teams keep a Python SDK alongside Node packages in the same Lerna repo. The path-based attribution handles this naturally, but you may want language-specific formatting:

```javascript
function formatPythonChangelogEntry(version, commits) {
 // Python projects often use a different date format and style
 const date = new Date().toISOString().split('T')[0];
 const lines = [`${version} (${date})\n${'='.repeat(version.length + date.length + 3)}\n`];

 for (const commit of commits) {
 lines.push(`* ${commit.description}`);
 }

 return lines.join('\n');
}
```

## Rust Crates in a Node Monorepo

Rust crates follow semantic versioning strictly. When a Rust crate in your monorepo has a breaking change, flag it prominently:

```javascript
function formatRustChangelogEntry(version, commits) {
 const hasBreaking = commits.some(c => c.breaking);
 const header = hasBreaking
 ? `## ${version} - BREAKING CHANGES\n`
 : `## ${version}\n`;

 const lines = [header];
 // ... format entries
 return lines.join('\n');
}
```

## Integrating With CI/CD

The changelog workflow reaches its full value when automated in CI. Here is a GitHub Actions workflow that generates changelogs on every merge to main:

```yaml
.github/workflows/changelog.yml
name: Generate Changelogs

on:
 push:
 branches: [main]

jobs:
 changelog:
 runs-on: ubuntu-latest
 permissions:
 contents: write
 pull-requests: write

 steps:
 - uses: actions/checkout@v4
 with:
 fetch-depth: 0 # Full history required for git log
 token: ${{ secrets.GITHUB_TOKEN }}

 - uses: actions/setup-node@v4
 with:
 node-version: '20'

 - name: Install dependencies
 run: npm ci

 - name: Configure git
 run: |
 git config user.name "github-actions[bot]"
 git config user.email "github-actions[bot]@users.noreply.github.com"

 - name: Generate changelogs
 run: npm run changelog

 - name: Commit changelog updates
 run: |
 git add "packages/*/CHANGELOG.md" CHANGELOG.md
 git diff --cached --quiet || git commit -m "chore: update changelogs [skip ci]"
 git push
```

The `fetch-depth: 0` is critical, without the full git history, `git log` cannot look back past the shallow clone depth and your changelogs will be incomplete.

## Conclusion

Automating changelog generation in Lerna monorepos with Claude Code eliminates manual tracking and ensures consistent, comprehensive release notes. By combining conventional commits, Lerna's package detection, and Claude's natural language processing, you create a reproducible workflow that scales with your project.

Start by setting up the basic commit parsing, then gradually add features like dependency tracking, multi-language support, and preview workflows. Your future self, and your users, will thank you for the clear, organized changelogs.

The single biggest lever in this entire system is consistent conventional commits. Once every developer on your team writes structured commits with accurate types and scopes, the changelog pipeline becomes nearly automatic. The scripts handle the mechanics; Claude Code handles the judgment calls around categorization and human-readable summaries. Together, they reduce one of the most tedious release tasks to a ten-minute review.


---

---

<div class="mastery-cta">

I hit this exact error six months ago. Then I wrote a CLAUDE.md that tells Claude my stack, my conventions, and my error handling patterns. Haven't seen it since.

I run 5 Claude Max subs, 16 Chrome extensions serving 50K users, and bill $500K+ on Upwork. These CLAUDE.md templates are what I actually use. Not theory — production configs.

**[Grab the templates — $99 once, free forever →](https://zovo.one/lifetime?utm_source=ccg&utm_medium=cta-error&utm_campaign=claude-code-lerna-changelog-generation-workflow-guide)**

47/500 founding spots. Price goes up when they're gone.

</div>

Related Reading

- [Claude Code for PR Changelog Generation Workflow](/claude-code-for-pr-changelog-generation-workflow/)
- [Claude Code Astro Static Site Generation Workflow Guide](/claude-code-astro-static-site-generation-workflow-guide/)
- [Claude Code Automated Alt Text Generation Workflow](/claude-code-automated-alt-text-generation-workflow/)
- [Claude Code for Lerna Monorepo Workflow](/claude-code-for-lerna-monorepo-workflow/)

Built by theluckystrike. More at [zovo.one](https://zovo.one)
{% endraw %}


