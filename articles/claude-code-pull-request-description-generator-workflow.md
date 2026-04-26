---

layout: default
title: "Claude Code Pull Request Description (2026)"
description: "Learn how to build an automated workflow that generates comprehensive pull request descriptions using Claude Code, saving time and ensuring consistent."
date: 2026-03-14
last_modified_at: 2026-04-17
author: "Claude Skills Guide"
permalink: /claude-code-pull-request-description-generator-workflow/
categories: [guides]
reviewed: true
score: 7
tags: [claude-code, claude-skills]
render_with_liquid: false
geo_optimized: true
---

{% raw %}
Pull request descriptions are critical for effective code reviews, but writing them manually is time-consuming and often inconsistent. This guide shows you how to build an automated pull request description generator using Claude Code that analyzes your changes and generates comprehensive, well-structured descriptions automatically.

Why Automate PR Descriptions?

Manual PR descriptions often suffer from several problems: they're incomplete, inconsistently formatted, or missing key information like test impacts and breaking changes. An automated workflow solves these issues by:

- Consistency: Every PR gets a uniform structure
- Time savings: Developers focus on code, not documentation
- Completeness: No more forgetting to mention dependencies or test impacts
- Review efficiency: Reviewers get all the context they need upfront

The time cost adds up faster than most teams realize. A developer opening three PRs per week and spending eight minutes each writing descriptions loses roughly two full hours per month. time that compounds across an entire engineering team. For a ten-person team, that is twenty hours per month spent on mechanical description writing instead of actual engineering work.

Beyond time, there is a quality consistency problem. The same developer writes dramatically different PR descriptions on Monday morning versus Friday afternoon. Junior engineers tend to under-describe their changes, while some senior engineers over-explain implementation details while omitting the business reason for the change. A generator trained on your team's best examples produces reliable, uniform output regardless of who opens the PR or when.

## Manual vs. Automated PR Descriptions: A Comparison

| Aspect | Manual | Claude Code Automated |
|--------|--------|-----------------------|
| Time per PR | 5–15 minutes | Under 30 seconds |
| Consistency | Varies by developer | Uniform template every time |
| Breaking change detection | Relies on developer memory | Scans diff automatically |
| Test impact section | Often missing | Generated from file patterns |
| Ticket references | Frequently forgotten | Extracted from branch name |
| Coverage on Friday afternoon | Notoriously weak | Same as Monday morning |
| Onboarding curve for new hires | Must learn team conventions | Embedded in the generator |

## Setting Up the PR Description Generator

The foundation of this workflow is a Claude Code skill that analyzes your git changes and generates structured descriptions. Create a new skill for this purpose:

```bash
Create a skill file: ~/.claude/skills/pr-description-generator.md
```

This creates a skill scaffold. Now you'll configure it to extract the right information from your codebase.

## Core Components of the Generator

Your PR description generator needs several key components working together:

1. Git Diff Analysis
The generator must first understand what changed. Use git commands to extract the necessary information:

```bash
Get the list of changed files
git diff --name-only HEAD~1 HEAD

Get detailed diff for each file
git diff HEAD~1 HEAD

Get commit messages for context
git log --oneline -10
```

For branches with multiple commits against a base branch, you need a slightly different approach that compares the full feature branch against main rather than just the last commit:

```bash
Find the merge base between current branch and main
MERGE_BASE=$(git merge-base HEAD origin/main)

Get all changed files since branching from main
git diff --name-only $MERGE_BASE HEAD

Get the full diff for Claude to analyze
git diff $MERGE_BASE HEAD

Get all commit messages on this branch
git log $MERGE_BASE..HEAD --oneline
```

Using the merge base is important. Without it, `HEAD~1` only shows the last commit, and a feature branch with ten commits would produce an incomplete description covering only the most recent change.

2. File Change Classification
Not all changes are equal. Your generator should categorize changes:

- New files: Feature additions, new components
- Modified files: Bug fixes, refactoring, optimizations
- Deleted files: Deprecations, cleanup
- Config changes: Environment, build configuration

A practical classification script checks each file path against known patterns:

```bash
classify_file() {
 local file="$1"
 case "$file" in
 src/components/*) echo "UI Component" ;;
 src/api/*|src/services/*) echo "API/Service Layer" ;;
 src/utils/*|src/helpers/*) echo "Utility" ;;
 test/|__tests__/|*.test.*|*.spec.*) echo "Test" ;;
 docs/|*.md) echo "Documentation" ;;
 .github/|*.yml|*.yaml) echo "CI/Config" ;;
 migrations/|*.sql) echo "Database Migration" ;;
 *) echo "Other" ;;
 esac
}
```

3. Impact Analysis
A good PR description explains the impact of changes. The generator should identify:

- Which tests is affected
- Whether documentation needs updates
- If there are breaking changes
- Performance implications

Breaking change detection is particularly valuable. The following patterns in a diff are strong indicators of breaking changes that reviewers need to know about upfront:

```bash
Heuristics for breaking change detection
detect_breaking_changes() {
 local diff="$1"
 local breaking=""

 # Removed exports or public API symbols
 if echo "$diff" | grep -q "^-.*export "; then
 breaking="$breaking\n- Public exports removed or renamed"
 fi

 # Changed function signatures
 if echo "$diff" | grep -qE "^-.*\(.*\).*\{"; then
 breaking="$breaking\n- Function signatures may have changed"
 fi

 # Database migrations
 if echo "$diff" | grep -q "migrations/"; then
 breaking="$breaking\n- Contains database migration (requires coordinated deploy)"
 fi

 # Environment variable changes
 if echo "$diff" | grep -qE "process\.env\.|\.env\.example"; then
 breaking="$breaking\n- New or changed environment variables required"
 fi

 echo "$breaking"
}
```

## Implementing the Workflow

Here's a practical implementation using a Claude Code skill:

## Step 1: Create the Analysis Script

```bash
#!/bin/bash
pr-analyze.sh - Analyze git changes for PR description

BRANCH=$(git branch --show-current)
BASE_BRANCH="main"

echo "## Changes Summary"
echo ""
git diff --stat $BASE_BRANCH...$BRANCH

echo ""
echo "## Files Changed"
echo "```"
git diff --name-only $BASE_BRANCH...$BRANCH
echo "```"

echo ""
echo "## Recent Commits"
git log $BASE_BRANCH...$BRANCH --oneline
```

For teams using a Jira or Linear ticket naming convention like `feature/PROJ-123-add-login`, you can automatically extract the ticket number from the branch name and include it in the description:

```bash
Extract ticket reference from branch name
BRANCH=$(git branch --show-current)
TICKET=$(echo "$BRANCH" | grep -oE '[A-Z]+-[0-9]+' | head -1)

if [ -n "$TICKET" ]; then
 echo "

**Find the right skill →** Browse 155+ skills in our [Skill Finder](/skill-finder/).

## Related Ticket"
 echo "[$TICKET](https://your-tracker.com/issues/$TICKET)"
fi
```

## Step 2: Build the Claude Skill

Create `skill.ts` with the main logic:

```typescript
import { Git } from './git';
import { Analyzer } from './analyzer';

export const skill = {
 name: 'pr-description-generator',
 description: 'Generate comprehensive pull request descriptions',

 async run(context: SkillContext) {
 const git = new Git();
 const analyzer = new Analyzer();

 // Get changes
 const changes = await git.getChanges();
 const diff = await git.getDiff();
 const commits = await git.getCommits();

 // Analyze the changes
 const analysis = analyzer.analyze({ changes, diff, commits });

 // Generate description
 const description = this.generateDescription(analysis);

 return { description };
 },

 generateDescription(analysis: AnalysisResult): string {
 return `
Summary
${analysis.summary}

Changes Made
${analysis.changes.map(c => `- ${c.file}: ${c.description}`).join('\n')}

Testing
${analysis.testImpact}

Breaking Changes
${analysis.breakingChanges || 'None'}

Additional Notes
${analysis.additionalNotes}
`.trim();
 }
};
```

For teams that want a richer output, extend the `generateDescription` method to include a checklist section that reviewers can check off as they validate the PR:

```typescript
generateChecklist(analysis: AnalysisResult): string {
 const items: string[] = [];

 if (analysis.hasNewTests) {
 items.push('- [x] New tests added');
 } else {
 items.push('- [ ] Tests not added. explain why in Additional Notes');
 }

 if (analysis.hasMigration) {
 items.push('- [ ] Migration tested locally');
 items.push('- [ ] Rollback plan documented');
 }

 if (analysis.hasDocChanges) {
 items.push('- [x] Documentation updated');
 }

 if (analysis.hasEnvVarChanges) {
 items.push('- [ ] New env vars added to .env.example and deployment secrets');
 }

 items.push('- [ ] Self-reviewed diff before opening PR');

 return items.join('\n');
}
```

## Step 3: Configure the Workflow

Add a configuration file to customize the generator behavior:

```yaml
pr-description-config.yaml
include:
 - fileList: true
 - diffStats: true
 - commitHistory: true
 - testImpact: true

categorize:
 patterns:
 - { pattern: "src/", category: "Source Code" }
 - { pattern: "test/", category: "Tests" }
 - { pattern: "docs/", category: "Documentation" }
 - { pattern: "*.config.*", category: "Configuration" }

templates:
 summary: "This PR {verb} {impact} in {scope}"
 breakingChanges: "WARNING: This contains breaking changes"
```

The `categorize.patterns` list is where you adapt the generator to your project layout. A Django monorepo might use `apps/*/models.py` for database-affecting changes, while a Next.js app would tag `app//page.tsx` files as user-facing route changes.

## Using the Generator in Your Workflow

Once configured, using the generator is straightforward:

## Manual Generation

```bash
claude --print "/pr-description-generator"
```

This outputs a generated description that you can copy and paste into your PR.

A more practical invocation pipes the output directly into the GitHub CLI to create the PR in one shot:

```bash
Generate description and open PR using GitHub CLI
DESCRIPTION=$(claude --print "/pr-description-generator")
gh pr create \
 --title "$(git branch --show-current | sed 's/-/ /g')" \
 --body "$DESCRIPTION" \
 --draft
```

Using `--draft` by default is a good habit. it lets you review the generated description before marking the PR ready for review, giving you a chance to add human context.

## Pre-Push Automation

Integrate the generator into your development workflow by adding it to your pre-push hook:

```bash
.git/hooks/pre-push
#!/bin/bash

while read local_ref local_sha remote_ref remote_sha; do
 if [ "$remote_ref" = "refs/heads/main" ]; then
 echo "Generating PR description..."
 claude /pr-description-generator > .github/PR_DESCRIPTION.md
 fi
done
```

For feature branches specifically (skipping pushes to main and develop), add a branch filter:

```bash
.git/hooks/pre-push
#!/bin/bash

while read local_ref local_sha remote_ref remote_sha; do
 BRANCH_NAME=$(echo "$remote_ref" | sed 's|refs/heads/||')

 # Only generate descriptions for feature branches
 if [[ "$BRANCH_NAME" == feature/* ]] || [[ "$BRANCH_NAME" == fix/* ]]; then
 echo "Generating PR description for $BRANCH_NAME..."
 claude --print "/pr-description-generator" > /tmp/pr_description_generated.md
 echo "Description saved to /tmp/pr_description_generated.md"
 echo "Use: gh pr create --body-file /tmp/pr_description_generated.md"
 fi
done
```

## CI Integration

For automated PR description generation on GitHub Actions:

```yaml
name: Generate PR Description
on: [pull_request]

jobs:
 describe:
 runs-on: ubuntu-latest
 steps:
 - uses: actions/checkout@v4
 with:
 ref: ${{ github.head_ref }}

 - name: Generate Description
 run: |
 claude /pr-description-generator > pr_description.md

 - name: Comment PR
 uses: actions/github-script@v7
 with:
 script: |
 const fs = require('fs');
 const description = fs.readFileSync('pr_description.md', 'utf8');
 await github.rest.issues.createComment({
 issue_number: context.issue.number,
 body: '## Auto-generated PR Description\n' + description
 });
```

If you only want to generate the description once (not on every push to the PR), add a check to skip runs where a description already exists:

```yaml
 - name: Check if description already exists
 id: check_desc
 uses: actions/github-script@v7
 with:
 script: |
 const pr = await github.rest.pulls.get({
 owner: context.repo.owner,
 repo: context.repo.repo,
 pull_number: context.issue.number
 });
 // Skip if PR already has a non-empty description
 core.setOutput('has_description', pr.data.body && pr.data.body.length > 50 ? 'true' : 'false');

 - name: Generate Description
 if: steps.check_desc.outputs.has_description == 'false'
 run: |
 claude /pr-description-generator > pr_description.md
```

## Structuring the Generated Output

The raw output from the generator is useful, but structuring it for GitHub's markdown renderer makes it much more scannable for reviewers. A well-structured PR description follows this pattern:

```markdown
What this PR does
One to three sentence plain-language summary. Focus on the user-visible or
system-visible outcome, not the implementation details.

Why this change is needed
Link to the problem: ticket number, bug report, or brief context.

Changes by area
API Layer
- Added `/api/v2/users/preferences` endpoint
- Deprecated `/api/v1/user-settings` (still functional, removed in v3)

Database
- Migration `0042_add_user_preferences_table.sql` adds new table
- No changes to existing tables

Frontend
- New `<UserPreferences>` component in `src/components/settings/`
- Updated `SettingsPage` to render the new component

Testing
- Unit tests added for the new endpoint (`src/api/__tests__/preferences.test.ts`)
- E2E test updated in `cypress/e2e/settings.cy.ts`
- Manual testing: Chrome 123, Firefox 124, Safari 17

Breaking changes
None. The deprecated endpoint still works.

Deployment notes
Run migration before deploying the new code. The migration is additive only.

Reviewer checklist
- [ ] Logic in `UserPreferencesController` makes sense
- [ ] Migration is safe to run on production data
- [ ] API response shape matches the frontend expectations
```

Claude Code can generate all of this structure automatically when the skill prompt instructs it to follow the template. The key is providing the template in the skill configuration so the model outputs exactly the sections your team expects.

## Best Practices and Tips

## Review Generated Descriptions

Always review the generated description before submitting. The generator captures technical details, but you should add context about business logic, user impact, and any manual testing performed.

A useful habit is to run the generator, read the output critically, and ask yourself two questions: "Would a reviewer who wrote none of this code understand what problem this solves?" and "Is there anything I know about this change that the diff alone cannot communicate?" The answers to those questions are what you add manually before marking the PR ready.

## Customize for Your Team

Every team has different requirements. Adjust the generator to include:

- Ticket references: Link to project management tools
- Screenshots: For UI changes, auto-attach screenshots
- Deployment notes: For infrastructure changes
- Migration guides: For database or API changes

For screenshot automation, you can extend the pre-push hook to use Playwright to capture before/after screenshots of routes touched by the PR:

```bash
Capture screenshots of changed routes
CHANGED_ROUTES=$(git diff --name-only HEAD~1 | grep 'pages/' | sed 's/pages\//\//;s/\.tsx$//')

for route in $CHANGED_ROUTES; do
 npx playwright screenshot "http://localhost:3000$route" "screenshots/pr-$route.png"
done
```

These screenshots can then be referenced in the auto-generated description, giving reviewers visual context without any manual effort.

## Maintain the Generator

As your codebase evolves, update the generator to recognize new patterns. Keep the categorization rules current with your project structure.

Track the quality of generated descriptions over time by adding a simple feedback mechanism. a thumbs-up or thumbs-down reaction on the auto-generated comment. Over several sprints, low scores point to areas where the generator's patterns need updating, while high scores confirm the generator is working well for those change types.

## Handling Large Diffs

Very large PRs. those touching hundreds of files. can produce diffs too large for a single Claude context window. The generator should detect this and switch to a summarization strategy:

```typescript
async function generateWithLargeDiffHandling(diff: string): Promise<string> {
 const TOKEN_LIMIT = 50000; // conservative estimate

 if (diff.length > TOKEN_LIMIT) {
 // Summarize by file, not full diff content
 const fileSummaries = await Promise.all(
 changedFiles.map(file => summarizeFileDiff(file))
 );
 return generateDescriptionFromSummaries(fileSummaries);
 }

 return generateDescriptionFromFullDiff(diff);
}
```

When the diff is chunked this way, the description will be somewhat less precise for individual line changes, but will still accurately describe what areas of the codebase changed and why, which is the most valuable part of a PR description for reviewers.

## Conclusion

Automating pull request descriptions with Claude Code improves consistency, saves time, and ensures reviewers always have the context they need. Start with the basic workflow shown here, then customize it to match your team's specific needs and conventions.

The key is to balance automation with human oversight. let Claude handle the mechanical aspects of description writing while you focus on adding the nuanced context that only a human developer can provide. Over time, the generator becomes a mirror of your team's conventions: the sections it produces, the language it uses, and the checklists it includes all reflect how your team thinks about code review quality. That institutional knowledge, encoded in the generator config, persists even as team members come and go.


---


**Try it:** Estimate your monthly spend with our [Cost Calculator](/calculator/).
---

<div class="mastery-cta">

I'm a solo developer in Vietnam. 50K Chrome extension users. $500K+ on Upwork. 5 Claude Max subscriptions running agent fleets in parallel.

These are my actual CLAUDE.md templates, orchestration configs, and prompts. Not a course. Not theory. The files I copy into every project before I write a line of code.

**[See what's inside →](https://zovo.one/lifetime?utm_source=ccg&utm_medium=cta-default&utm_campaign=claude-code-pull-request-description-generator-workflow)**

$99 once. Free forever. 47/500 founding spots left.

</div>

Related Reading

- [Claude Code Automated Pull Request Review Workflow Guide](/claude-code-automated-pull-request-review-workflow-guide/)
- [Claude Code for Fork and Pull Request Workflow Guide](/claude-code-for-fork-and-pull-request-workflow-guide/)
- [Claude Code for Pull Request Review Workflow Guide](/claude-code-for-pull-request-review-workflow-guide/)

Built by theluckystrike. More at [zovo.one](https://zovo.one)
{% endraw %}


