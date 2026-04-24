---

layout: default
title: "Claude Code Conventional Commits"
description: "Learn how to enforce Conventional Commits in your Claude Code workflow with commit hooks, CI validation, and skill-based automation for consistent."
date: 2026-03-14
last_modified_at: 2026-04-17
author: Claude Skills Guide
permalink: /claude-code-conventional-commits-enforcement-workflow/
categories: [guides]
tags: [claude-code, claude-skills]
reviewed: true
score: 7
render_with_liquid: false
geo_optimized: true
---

{% raw %}
Claude Code Conventional Commits Enforcement Workflow

Maintaining consistent commit messages is crucial for automated versioning, changelog generation, and readable project history. Conventional Commits provides a standardized format that enables these benefits, but enforcement requires proper tooling. This guide covers the tooling layer: Git hooks with Husky and commitlint, a structured Claude Code skill for message generation, automated version bumps, and CI/CD pipeline validation.

If you are new to Conventional Commits or want interactive workflows for crafting messages day-to-day, see the companion guide: [Claude Code for Conventional Commits Workflow Guide](/claude-code-for-conventional-commits-workflow-guide/).

## What Are Conventional Commits and Why Enforce Them

The [Conventional Commits specification](https://www.conventionalcommits.org/) defines a lightweight structure for commit messages:

```
<type>(<optional scope>): <description>

[optional body]

[optional footer(s)]
```

The `type` field signals the nature of the change. The ecosystem has converged on these standard types:

| Type | Purpose | Version Impact |
|---|---|---|
| `feat` | New feature or user-visible behavior | Bumps MINOR |
| `fix` | Bug fix | Bumps PATCH |
| `docs` | Documentation only | No bump |
| `style` | Formatting, whitespace, no logic change | No bump |
| `refactor` | Code restructuring, no behavior change | No bump |
| `test` | Adding or updating tests | No bump |
| `chore` | Tooling, dependencies, config | No bump |
| `perf` | Performance improvement | Bumps PATCH |
| `ci` | CI/CD configuration | No bump |
| `build` | Build system changes | No bump |
| `revert` | Reverts a previous commit | Varies |

A `BREAKING CHANGE:` footer on any commit type triggers a MAJOR version bump regardless of the type prefix. You can also use the `!` shorthand: `feat!: remove deprecated API`.

Without a consistent format, tools like `standard-version`, `release-please`, and `semantic-release` cannot automatically determine the correct next version number or generate meaningful changelogs. Enforcement is not about bureaucracy, it is about making automation reliable.

## Setting Up Commit Message Validation with Husky

The most effective way to enforce Conventional Commits is through Git hooks that validate messages before they're committed. Combine Husky with commitlint for a solid setup.

First, install the required dependencies:

```bash
npm install --save-dev husky @commitlint/cli @commitlint/config-conventional
```

Initialize Husky in your project:

```bash
npx husky init
```

This creates a `.husky` directory with a pre-commit hook. Now create the commit-msg hook:

```bash
echo 'npx --no -- commitlint --edit ${1}' > .husky/commit-msg
```

Create your commitlint configuration in `commitlint.config.js`:

```javascript
module.exports = {
 extends: ['@commitlint/config-conventional'],
 rules: {
 'type-enum': [
 2,
 'always',
 ['feat', 'fix', 'docs', 'style', 'refactor', 'test', 'chore', 'perf', 'ci', 'build', 'revert']
 ],
 'subject-case': [2, 'always', 'lower-case'],
 'type-case': [2, 'always', 'lower-case']
 }
};
```

Now when developers run `git commit`, Husky intercepts the commit and validates the message against your rules. If the message doesn't conform, the commit is rejected with helpful error messages.

## Understanding commitlint Rule Severity

Each rule takes a severity level as its first array element:

| Level | Constant | Behavior |
|---|---|---|
| `0` | `disabled` | Rule is ignored |
| `1` | `warn` | Prints warning, commit proceeds |
| `2` | `error` | Prints error, commit is blocked |

During initial rollout You should start with severity `1` (warn) on some rules to avoid immediately blocking your team. Ratchet up to `2` (error) as the team develops muscle memory:

```javascript
module.exports = {
 extends: ['@commitlint/config-conventional'],
 rules: {
 // Enforce strictly
 'type-enum': [2, 'always', ['feat', 'fix', 'docs', 'style', 'refactor', 'test', 'chore', 'perf', 'ci', 'build', 'revert']],
 'type-case': [2, 'always', 'lower-case'],
 // Warn only during transition
 'subject-case': [1, 'always', 'lower-case'],
 'body-max-line-length': [1, 'always', 100],
 // Disabled for now
 'scope-enum': [0]
 }
};
```

## Scopes Enforcement

Once your team is comfortable with types, add scope validation. Scopes make changelogs much more readable by grouping changes by subsystem:

```javascript
module.exports = {
 extends: ['@commitlint/config-conventional'],
 rules: {
 'type-enum': [2, 'always', ['feat', 'fix', 'docs', 'style', 'refactor', 'test', 'chore', 'perf', 'ci', 'build', 'revert']],
 'scope-enum': [
 2,
 'always',
 ['auth', 'api', 'ui', 'db', 'infra', 'config', 'deps', 'core']
 ],
 'scope-empty': [1, 'never'] // Warn when scope is omitted
 }
};
```

A scoped commit looks like `feat(auth): add OAuth2 PKCE flow`. With this rule in place, an unrecognized scope like `feat(authentication):` would be blocked and the developer prompted to use `auth` instead.

## Making Husky Play Nicely with CI

Husky should only run on developer machines, not in CI. Prevent accidental Husky installation in CI environments by adding a `prepare` guard:

```json
{
 "scripts": {
 "prepare": "is-ci || husky"
 }
}
```

Install `is-ci`:

```bash
npm install --save-dev is-ci
```

This skips Husky setup in CI environments where the `CI` environment variable is set, which is true by default on GitHub Actions, GitLab CI, CircleCI, and most other platforms.

## Creating a Claude Code Skill for Commit Assistance

Building a Claude Code skill that helps generate Conventional Commits improves developer experience while maintaining standards. Create a skill file at `skills/conventional-commit-skill.md`:

```markdown
---
name: conventional-commit
description: Generate Conventional Commits formatted messages with interactive prompts
---

Conventional Commit Generator

You help generate properly formatted Conventional Commits messages.

Step 1: Determine Change Type

Ask the developer about the nature of their changes:
- feat: New feature or functionality
- fix: Bug fix or error correction
- docs: Documentation changes only
- style: Code style changes (formatting, semicolons)
- refactor: Code refactoring without feature changes
- test: Adding or updating tests
- chore: Maintenance tasks, dependencies, tooling
- perf: Performance improvements
- ci: CI/CD configuration changes
- build: Build system or dependency changes

Step 2: Identify Scope

Ask what area of the project is affected (e.g., auth, api, ui, database). If unclear, use the primary file or module changed.

Step 3: Draft Description

The description should:
- Be under 72 characters
- Use imperative mood (add, fix, update, not added, fixed, updated)
- Start with a verb
- Not include the scope or type

Step 4: Check for Breaking Changes

Ask if this change includes breaking changes. If so, include `BREAKING CHANGE:` in the footer with an explanation.

Output Format

Generate the commit message in this format:
```
<type>(<scope>): <description>

[optional body explaining what and why]

BREAKING CHANGE: [if applicable]
```

After generating, show the developer the result and offer to run `git commit -m "..."` with the formatted message.
```

This skill provides an interactive workflow where Claude prompts developers through the commit message creation process, ensuring all required elements are present and properly formatted.

## Extending the Skill with Git Context

A more powerful version of this skill reads the actual staged diff before prompting the developer. This lets Claude suggest a commit message based on the real changes rather than asking the developer to describe them:

```markdown
---
name: conventional-commit
description: Generate Conventional Commits messages from staged changes
---

Conventional Commit Generator

Initialization

Before asking any questions, run `git diff --cached --stat` to see which
files are staged. Then run `git diff --cached` to read the actual changes.

Analyze the diff and form a draft commit message. Present the draft to the
developer before asking clarifying questions.

Draft Generation Rules

- Choose type based on the nature of the diff:
 - New files with feature logic → `feat`
 - Modified files fixing a bug → `fix`
 - Only `*.md`, `*.txt`, or comment changes → `docs`
 - Only whitespace or formatting changes → `style`
 - Tests added or modified → `test`
 - `package.json`, CI config, tooling → `chore`
- Derive scope from the most frequently changed directory or module name
- Write description in imperative mood, under 72 characters
- If the diff touches a public interface or removes exports, flag as potential BREAKING CHANGE

Confirmation Flow

1. Show the draft: `feat(auth): add refresh token rotation`
2. Ask: "Does this look right, or should we adjust the type, scope, or description?"
3. If breaking change suspected, ask: "Does this change any public API or behavior that callers depend on?"
4. Finalize and offer to run `git commit`
```

This approach is significantly faster than starting from scratch and tends to produce more accurate messages because Claude is working from ground truth rather than developer memory.

## Batch Commit Skill for Multi-Change Commits

Sometimes a PR accumulates several logical changes across many files. A batch variant helps developers split a large change into atomic commits:

```markdown
---
name: split-commits
description: Analyze staged changes and suggest how to split them into atomic Conventional Commits
---

Commit Splitter

Run `git diff --cached` and analyze the staged changes.

Group the changes into logical units:
- Each unit should represent one coherent intent
- Changes to the same subsystem belong together
- Test files belong with the code they test
- Config changes are separate unless they are required by a feature change

For each group:
1. Suggest which files to stage: `git add <files>`
2. Draft a Conventional Commit message for just those files
3. Show the full sequence of commits needed

Present the full plan before executing anything. Ask for approval before
running any `git add` or `git commit` commands.
```

## Automating Version Bumps with Conventional Commits

One of the strongest benefits of Conventional Commits is automated version management. Tools like standard-version or release-please can automatically determine the next version number based on your commit history.

Install standard-version for automatic versioning:

```bash
npm install --save-dev standard-version
```

Add release scripts to your `package.json`:

```json
{
 "scripts": {
 "release": "standard-version",
 "release:minor": "standard-version --release-as minor",
 "release:major": "standard-version --release-as major"
 }
}
```

When you run `npm run release`, standard-version:
1. Analyzes commits since the last tag
2. Determines version bump based on Conventional Commit types
3. Updates CHANGELOG.md with all changes
4. Creates a new version tag

Feature commits (`feat:`) trigger minor version bumps, while fix commits (`fix:`) trigger patch bumps. Include `BREAKING CHANGE:` in any commit to trigger a major version bump.

## Comparing Versioning Tools

Three tools dominate the automated versioning space. Here is how they compare:

| Feature | standard-version | semantic-release | release-please |
|---|---|---|---|
| Runs locally | Yes | No (CI only) | Yes (CLI) |
| Creates GitHub releases | No (manual push) | Yes | Yes |
| Handles monorepos | Limited | With plugins | Yes |
| Requires CI secrets | No | Yes (NPM token etc.) | Yes (GitHub token) |
| Changelog format | Keep a Changelog | Customizable | Keep a Changelog |
| Maintenance status | Deprecated | Active | Active (Google) |
| Recommended for | Simple projects | npm publishing | GitHub-centric projects |

`standard-version` is technically deprecated in favor of `changelogen` or direct use of `release-please`, but it remains widely used and fully functional. For new projects, prefer `release-please` if you are on GitHub or `semantic-release` if you need to publish to npm automatically.

## Configuring release-please

For GitHub-hosted projects, release-please offers a tighter integration. Create a configuration file at `release-please-config.json`:

```json
{
 "release-type": "node",
 "include-component-in-tag": false,
 "changelog-sections": [
 {"type": "feat", "section": "Features"},
 {"type": "fix", "section": "Bug Fixes"},
 {"type": "perf", "section": "Performance"},
 {"type": "revert", "section": "Reverts"},
 {"type": "docs", "section": "Documentation"},
 {"type": "chore", "section": "Miscellaneous"},
 {"type": "refactor", "section": "Code Refactoring", "hidden": false},
 {"type": "test", "hidden": true},
 {"type": "build", "hidden": true},
 {"type": "ci", "hidden": true}
 ]
}
```

Add the GitHub Actions workflow at `.github/workflows/release-please.yml`:

```yaml
name: Release Please

on:
 push:
 branches:
 - main

permissions:
 contents: write
 pull-requests: write

jobs:
 release-please:
 runs-on: ubuntu-latest
 steps:
 - uses: google-github-actions/release-please-action@v4
 with:
 token: ${{ secrets.GITHUB_TOKEN }}
 release-type: node
```

When commits land on `main`, release-please opens or updates a "Release PR" that shows the pending changelog and proposed version bump. Merging that PR creates the tag and GitHub release automatically.

## CI/CD Pipeline Enforcement

Validation in local Git hooks can be bypassed by developers. Ensure consistent enforcement by adding validation in your CI pipeline.

For GitHub Actions, create `.github/workflows/commitlint.yml`:

```yaml
name: Commitlint

on:
 push:
 branches: [main]
 pull_request:
 branches: [main]

jobs:
 commitlint:
 runs-on: ubuntu-latest
 steps:
 - uses: actions/checkout@v4
 with:
 fetch-depth: 0

 - uses: actions/setup-node@v4
 with:
 node-version: '20'

 - name: Install dependencies
 run: npm ci

 - name: Validate current commit (last commit) with commitlint
 run: npx --no -- commitlint --last

 - name: Validate PR commits with commitlint
 run: npx --no -- commitlint --from ${{ github.event.pull_request.base.sha }} --to ${{ github.event.pull_request.head.sha }}
```

This workflow runs on every push to main and every PR, ensuring no non-conforming commits enter your main branch.

Why `fetch-depth: 0` Matters

The `fetch-depth: 0` option is critical. By default, `actions/checkout` performs a shallow clone with only the latest commit. commitlint needs access to the full commit range from the PR base to the head to validate all commits in the PR, not just the last one. Without `fetch-depth: 0`, the `--from ... --to ...` range validation will fail with a "fatal: ambiguous argument" error.

## GitLab CI Equivalent

For GitLab-hosted projects, the equivalent pipeline stage in `.gitlab-ci.yml`:

```yaml
commitlint:
 image: node:20-alpine
 stage: validate
 before_script:
 - npm ci
 script:
 - npx --no -- commitlint --from $CI_MERGE_REQUEST_DIFF_BASE_SHA --to $CI_COMMIT_SHA
 rules:
 - if: $CI_PIPELINE_SOURCE == "merge_request_event"
 - if: $CI_COMMIT_BRANCH == $CI_DEFAULT_BRANCH
```

## Handling Merge Commits and Squash Strategies

If your repository uses squash merging, the squashed commit message must itself conform to Conventional Commits. GitHub's squash merge default uses the PR title as the commit message, which is often not formatted correctly.

Two approaches:

Option 1: Enforce PR title format. Add a GitHub Actions workflow that validates the PR title using commitlint. Install the `@commitlint/config-conventional` rules and validate `${{ github.event.pull_request.title }}` directly.

Option 2: Use merge commits. Disable squash merging and require that all commits in a PR individually conform. This is more work for developers but gives you granular history.

Most teams prefer Option 1 because it is lower friction: developers write commits however they want locally, and only the final squashed message (derived from the PR title) needs to conform.

A PR title validation workflow:

```yaml
name: PR Title Lint

on:
 pull_request:
 types: [opened, edited, synchronize]

jobs:
 lint-pr-title:
 runs-on: ubuntu-latest
 steps:
 - uses: amannn/action-semantic-pull-request@v5
 env:
 GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
 with:
 types: |
 feat
 fix
 docs
 style
 refactor
 test
 chore
 perf
 ci
 build
 revert
 requireScope: false
```

## Best Practices for Implementation

Start with lenient rules and tighten them gradually as your team adapts. Initially, focus on enforcing the type field and basic format. Add scope requirements and body validation in subsequent phases.

Always provide helpful error messages when commits are rejected. The commitlint output should clearly explain what's wrong and how to fix it. Your Claude Code skill should reinforce these explanations with examples.

Consider enabling commit message suggestions in your IDE or Git client. Many developers find it easier to modify an AI-suggested message than to write from scratch.

Finally, document your commit conventions in CONTRIBUTING.md. New team members need clear guidance on your standards and the tooling that enforces them.

## Rollout Phasing for Teams

A phased rollout reduces friction and builds buy-in:

| Phase | Duration | Actions |
|---|---|---|
| Awareness | 1-2 weeks | Share the spec, run workshops, add CONTRIBUTING.md |
| Soft enforcement | 2-4 weeks | Deploy Husky with severity 1 (warn only), no CI block |
| Local enforcement | 2-4 weeks | Upgrade to severity 2 (error), commits blocked locally |
| CI enforcement | Ongoing | Add commitlint to CI, PR title validation, release automation |

Skipping the awareness phase is the most common mistake. If developers don't understand why the format matters, they will resent the tooling that enforces it. A 30-minute walkthrough of how commits feed into the automated changelog is usually enough to earn buy-in.

## Providing Good Error Messages

The default commitlint error output is functional but terse. You can configure a custom prompt in your `commitlint.config.js` to make failures more actionable:

```javascript
module.exports = {
 extends: ['@commitlint/config-conventional'],
 rules: {
 'type-enum': [2, 'always', ['feat', 'fix', 'docs', 'style', 'refactor', 'test', 'chore', 'perf', 'ci', 'build', 'revert']],
 },
 prompt: {
 messages: {
 type: 'Select the type of change you are committing:',
 scope: 'Denote the scope of this change (optional):',
 subject: 'Write a short, imperative tense description (max 72 chars):',
 body: 'Provide a longer description (optional, press enter to skip):',
 breaking: 'List any BREAKING CHANGES (optional):',
 footer: 'List any issues this commit closes (optional):'
 },
 questions: {
 type: {
 description: 'Select the type of change:',
 enum: {
 feat: { description: 'A new feature', title: 'Features', emoji: '' },
 fix: { description: 'A bug fix', title: 'Bug Fixes', emoji: '' },
 docs: { description: 'Documentation only', title: 'Documentation', emoji: '' },
 chore: { description: 'Tooling and maintenance', title: 'Chores', emoji: '' }
 }
 }
 }
 }
};
```

With the `@commitlint/prompt-cli` package, developers can run `npx commit` to get an interactive guided prompt rather than writing the message freehand.

## Conclusion

Enforcing Conventional Commits through Claude Code skills, Git hooks, and CI pipelines creates a solid system that improves project maintainability. The initial setup investment pays dividends through automated versioning, meaningful changelogs, and consistent commit history. Start with local validation, add Claude-assisted message generation, then extend enforcement to your CI pipeline for comprehensive coverage.

The real payoff emerges over months of accumulated history: a release process where `npm run release` generates a correct version bump and a fully populated changelog with zero manual effort, and a repository where any developer can understand the shape of the last six months of work at a glance. That is the compounding return on the enforcement infrastructure you build today.


---

---

<div class="mastery-cta">

I'm a solo developer in Vietnam. 50K Chrome extension users. $500K+ on Upwork. 5 Claude Max subscriptions running agent fleets in parallel.

These are my actual CLAUDE.md templates, orchestration configs, and prompts. Not a course. Not theory. The files I copy into every project before I write a line of code.

**[See what's inside →](https://zovo.one/lifetime?utm_source=ccg&utm_medium=cta-default&utm_campaign=claude-code-conventional-commits-enforcement-workflow)**

$99 once. Free forever. 47/500 founding spots left.

</div>

Related Reading

- [Claude Code for Conventional Commits Workflow Guide](/claude-code-for-conventional-commits-workflow-guide/)
- [Claude Code Team Coding Standards Enforcement Workflow](/claude-code-team-coding-standards-enforcement-workflow/)
- [AI Assisted Architecture Design Workflow Guide](/ai-assisted-architecture-design-workflow-guide/)

Built by theluckystrike. More at [zovo.one](https://zovo.one)
{% endraw %}


