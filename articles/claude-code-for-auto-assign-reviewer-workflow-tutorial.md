---

layout: default
title: "Claude Code for Auto Assign Reviewer (2026)"
description: "Learn how to automate your pull request reviewer assignment process using Claude Code. This tutorial covers practical workflows, code examples, and."
date: 2026-03-15
last_modified_at: 2026-04-17
author: "Claude Skills Guide"
permalink: /claude-code-for-auto-assign-reviewer-workflow-tutorial/
categories: [tutorials]
tags: [claude-code, claude-skills]
reviewed: true
score: 8
render_with_liquid: false
geo_optimized: true
---

{% raw %}
Manual PR reviewer assignment is time-consuming and often inconsistent. Teams waste valuable developer hours playing the assignment game, and new team members have no visibility into who should review what. This tutorial shows you how to build an automated reviewer assignment system using Claude Code that scales with your team and enforces consistent review policies.

## Understanding the Auto-Assign Reviewer Problem

Before diving into code, let's identify what makes reviewer assignment challenging. Every development team faces these common problems:

- Round-robin becomes uneven: Some developers get overwhelmed while others coast
- Knowledge silos: Certain files only "belong" to specific people
- Availability blindness: No visibility into who's on vacation, overloaded, or unavailable
- Context switching costs: Assigning reviewers takes time away from actual code work
- Author bias: Developers instinctively pick friends or familiar names rather than the best-suited reviewer
- CODEOWNERS gaps: Teams with CODEOWNERS files often forget to update them, leaving stale mappings

An automated system solves these by applying consistent rules, considering real-time availability, and distributing load evenly across your team. The goal is not to remove human judgment entirely, but to remove the mental overhead of routine assignments so engineers can focus on actual code review quality.

## Comparing Manual vs Automated Assignment

| Factor | Manual Assignment | Automated Assignment |
|---|---|---|
| Consistency | Varies by author | Rule-based, consistent |
| Speed | 1-5 minutes per PR | Seconds |
| Load distribution | Often uneven | Tracked and balanced |
| Expertise matching | Memory-dependent | Pattern-based |
| Availability awareness | None by default | Configurable |
| Onboarding friction | High for new authors | Low, self-service |

Most teams that adopt automated assignment report faster time-to-first-review and fewer cases of PRs sitting unreviewed for days because the author forgot to assign someone.

## Setting Up Your Claude Code Skill

The foundation of your auto-assign workflow is a custom Claude Code skill. Create a new skill file in your project's `.claude/` directory:

```bash
mkdir -p .claude
touch .claude/auto-assign-reviewer.md
```

This skill will handle the logic for selecting and assigning reviewers based on multiple factors. The `.claude/` directory is where Claude Code looks for project-specific skill definitions. any markdown file placed here becomes an invokable skill when you run Claude Code from that repository.

Before writing the skill logic, you also need to decide on your data source for reviewer state. Three common approaches are:

1. Static config file. A JSON file committed to the repo listing team members and their areas
2. GitHub Teams API. Pull reviewer pools dynamically from org teams
3. Hybrid. Static expertise mapping + live load check via GitHub API

This tutorial covers the hybrid approach, which gives you the best balance of flexibility and accuracy.

## Building the Reviewer Selection Logic

Your auto-assign skill needs a structured approach. Here's a practical implementation that handles expertise matching and load balancing:

```javascript
// auto-assign-reviewer.js - Core assignment logic
const AVAILABLE_REVIEWERS = [
 { name: 'alice', expertise: ['backend', 'api'], load: 2 },
 { name: 'bob', expertise: ['frontend', 'ui'], load: 1 },
 { name: 'charlie', expertise: ['security', 'devops'], load: 3 },
 { name: 'diana', expertise: ['database', 'backend'], load: 2 }
];

function selectReviewer(changes, reviewers, currentLoad) {
 // Priority: lowest load first
 const available = reviewers.filter(r => r.load < currentLoad.maxLoad);

 // Match expertise to changed files
 const scored = available.map(reviewer => {
 let score = 0;
 changes.files.forEach(file => {
 if (reviewer.expertise.some(e => file.includes(e))) {
 score += 2;
 }
 });
 // Prefer less loaded reviewer
 score += (currentLoad.maxLoad - reviewer.load);
 return { reviewer, score };
 });

 return scored.sort((a, b) => b.score - a.score)[0].reviewer;
}
```

This basic algorithm considers two key factors: current workload and file expertise matching. The scoring system is intentionally simple. expertise matches are worth two points each, and having a lighter workload contributes additional points. You can tune these weights as you learn more about your team's patterns.

## Fetching Live Review Load from GitHub

Rather than maintaining load counts manually, pull them from the GitHub API at runtime:

```javascript
async function getReviewerLoad(owner, repo, reviewerLogin) {
 const response = await fetch(
 `https://api.github.com/repos/${owner}/${repo}/pulls?state=open`,
 {
 headers: {
 'Authorization': `Bearer ${process.env.GITHUB_TOKEN}`,
 'Accept': 'application/vnd.github.v3+json'
 }
 }
 );

 const pulls = await response.json();

 // Count PRs where this reviewer is already requested
 const load = pulls.filter(pr =>
 pr.requested_reviewers.some(r => r.login === reviewerLogin)
 ).length;

 return load;
}
```

Call this for each candidate before scoring. This keeps your load data accurate without any manual tracking.

## Integrating with GitHub's API

To actually assign reviewers automatically, you need to interact with GitHub's API. Here's how to wire this into your Claude Code skill:

```javascript
async function assignReviewer(owner, repo, prNumber, reviewer) {
 const response = await fetch(
 `https://api.github.com/repos/${owner}/${repo}/pulls/${prNumber}/requested_reviewers`,
 {
 method: 'POST',
 headers: {
 'Authorization': `Bearer ${process.env.GITHUB_TOKEN}`,
 'Accept': 'application/vnd.github.v3+json'
 },
 body: JSON.stringify({ reviewers: [reviewer.name] })
 }
 );

 return response.ok;
}
```

This function makes the actual API call to request a reviewer on your pull request. You can extend it to handle team review requests as well:

```javascript
async function assignTeamReviewer(owner, repo, prNumber, teamSlug) {
 const response = await fetch(
 `https://api.github.com/repos/${owner}/${repo}/pulls/${prNumber}/requested_reviewers`,
 {
 method: 'POST',
 headers: {
 'Authorization': `Bearer ${process.env.GITHUB_TOKEN}`,
 'Accept': 'application/vnd.github.v3+json'
 },
 body: JSON.stringify({
 reviewers: [],
 team_reviewers: [teamSlug]
 })
 }
 );

 if (!response.ok) {
 const error = await response.json();
 throw new Error(`Failed to assign team: ${error.message}`);
 }

 return true;
}
```

Always add error handling around these API calls. GitHub's API returns 422 errors when you try to assign the PR author as a reviewer, or when a requested user doesn't have write access to the repo. Your skill should catch these and fall back gracefully to the next candidate.

## Respecting the CODEOWNERS File

Many teams use a CODEOWNERS file to mandate who must review changes to critical paths. Your auto-assign skill should read and respect this file before doing any other selection:

```javascript
function parseCodeowners(content) {
 const rules = [];

 for (const line of content.split('\n')) {
 const trimmed = line.trim();
 if (!trimmed || trimmed.startsWith('#')) continue;

 const [pattern, ...owners] = trimmed.split(/\s+/);
 rules.push({ pattern, owners });
 }

 // Return in reverse order. last matching rule wins
 return rules.reverse();
}

function getRequiredReviewers(filepath, rules) {
 for (const rule of rules) {
 if (minimatch(filepath, rule.pattern)) {
 return rule.owners.map(o => o.replace(/^@/, ''));
 }
 }
 return [];
}
```

When a PR touches files covered by CODEOWNERS, add those owners as mandatory reviewers first, then use the load-balanced selection for any additional reviewers your policy requires.

## Creating the Claude Code Skill Definition

Now wrap this logic in a proper Claude Code skill file that Claude Code will invoke:

```markdown
---
name: Auto Assign Reviewer
description: Automatically assign appropriate reviewers to pull requests based on expertise and availability
---

Auto Assign Reviewer Skill

This skill helps you automatically assign reviewers to pull requests.

Usage

Run this skill and provide the PR number and repository context. Claude Code
will analyze changed files, check reviewer availability, and assign the best
match.

Configuration

Set these environment variables:
- GITHUB_TOKEN: GitHub personal access token with repo scope
- MAX_REVIEW_LOAD: Maximum concurrent reviews per person (default: 3)
- REVIEWER_CONFIG: Path to JSON file with team expertise mapping

How It Works

1. Reads CODEOWNERS for mandatory reviewer requirements
2. Analyzes changed files in the PR
3. Matches file patterns to reviewer expertise
4. Checks current review load for each candidate via GitHub API
5. Selects the best match considering all factors
6. Assigns via GitHub API with fallback handling
```

## Automating with GitHub Actions

For true automation, trigger your reviewer assignment automatically when PRs are created or updated:

```yaml
.github/workflows/auto-assign-reviewer.yml
name: Auto Assign Reviewer

on:
 pull_request:
 types: [opened, synchronize, reopened]

jobs:
 assign-reviewer:
 runs-on: ubuntu-latest
 permissions:
 pull-requests: write
 contents: read
 steps:
 - uses: actions/checkout@v4
 with:
 fetch-depth: 0

 - name: Get changed files
 id: files
 run: |
 CHANGED=$(git diff --name-only origin/${{ github.base_ref }}...HEAD | tr '\n' ',')
 echo "list=$CHANGED" >> $GITHUB_OUTPUT

 - name: Setup Node
 uses: actions/setup-node@v4
 with:
 node-version: '20'

 - name: Install Claude Code
 run: npm install -g @anthropic/claude-code

 - name: Run auto-assign skill
 env:
 GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
 ANTHROPIC_API_KEY: ${{ secrets.ANTHROPIC_API_KEY }}
 PR_NUMBER: ${{ github.event.pull_request.number }}
 CHANGED_FILES: ${{ steps.files.outputs.list }}
 REPO_OWNER: ${{ github.repository_owner }}
 REPO_NAME: ${{ github.event.repository.name }}
 run: |
 claude /auto-assign-reviewer
```

This workflow runs on every PR event and automatically invokes Claude Code to assign reviewers. The `permissions` block is important. without `pull-requests: write`, the workflow can read PR data but cannot assign reviewers.

## Preventing Double-Assignment on Synchronize Events

When a PR is updated (synchronize event), you don't want to reassign reviewers who are already in the middle of reviewing. Add a guard in your script:

```javascript
async function getExistingReviewers(owner, repo, prNumber) {
 const response = await fetch(
 `https://api.github.com/repos/${owner}/${repo}/pulls/${prNumber}`,
 {
 headers: {
 'Authorization': `Bearer ${process.env.GITHUB_TOKEN}`,
 'Accept': 'application/vnd.github.v3+json'
 }
 }
 );

 const pr = await response.json();
 return pr.requested_reviewers.map(r => r.login);
}

async function run() {
 const existing = await getExistingReviewers(owner, repo, prNumber);

 if (existing.length > 0) {
 console.log('Reviewers already assigned, skipping.');
 process.exit(0);
 }

 // Proceed with selection and assignment
}
```

## Advanced: Round-Robin with Expertise Fallback

A more sophisticated approach combines multiple strategies to handle varied situations:

```javascript
function advancedSelect(changes, reviewers, config) {
 const { strategy, exclude, maxLoad } = config;

 let candidates = reviewers
 .filter(r => !exclude.includes(r.name))
 .filter(r => r.load < maxLoad);

 if (strategy === 'expertise-first') {
 return matchByExpertise(changes, candidates);
 } else if (strategy === 'round-robin') {
 return selectRoundRobin(candidates, reviewers);
 } else {
 // Hybrid: try expertise, fallback to round-robin
 const expertMatch = matchByExpertise(changes, candidates);
 return expertMatch || selectRoundRobin(candidates, reviewers);
 }
}

function selectRoundRobin(candidates, allReviewers) {
 // Sort by review count ascending. most underloaded reviewer goes first
 return candidates.sort((a, b) => a.load - b.load)[0];
}

function matchByExpertise(changes, candidates) {
 const topFiles = changes.files.slice(0, 10);

 const matched = candidates.filter(r =>
 topFiles.some(file =>
 r.expertise.some(area => file.toLowerCase().includes(area))
 )
 );

 if (matched.length === 0) return null;

 // Among expertise matches, prefer the least loaded
 return matched.sort((a, b) => a.load - b.load)[0];
}
```

This lets you configure different strategies per repository or per branch. For example, security-sensitive branches might always use `expertise-first`, while feature branches default to the hybrid strategy.

## Strategy Comparison Table

| Strategy | Best For | Risk |
|---|---|---|
| Round-robin only | Equal-skill teams | May assign non-expert to critical code |
| Expertise-first only | Specialized teams | Can overload top experts |
| Hybrid | Most teams | Requires well-maintained expertise data |
| CODEOWNERS-only | Compliance-heavy projects | Can cause bottlenecks when owners are busy |

## Adding an Availability Window System

The most mature auto-assign implementations support reviewer availability flags. This prevents routing reviews to someone on vacation:

```javascript
// reviewer-config.json
{
 "reviewers": [
 {
 "login": "alice",
 "expertise": ["backend", "api"],
 "unavailable_until": null
 },
 {
 "login": "bob",
 "expertise": ["frontend", "ui"],
 "unavailable_until": "2026-04-01"
 }
 ]
}
```

```javascript
function filterAvailable(reviewers) {
 const today = new Date().toISOString().split('T')[0];

 return reviewers.filter(r => {
 if (!r.unavailable_until) return true;
 return r.unavailable_until < today;
 });
}
```

You can update the config file as a simple "out of office" mechanism, or integrate with your calendar system for fully automatic availability detection.

## Best Practices for Implementation

When deploying your auto-assign system, keep these recommendations in mind:

1. Start with a dry-run mode: Before enabling automatic assignment, add a `DRY_RUN=true` flag that logs the selected reviewer without making the API call. This lets you validate the logic against real PRs for a week before going live.

2. Add exclusion windows: Build a simple JSON config where reviewers can mark themselves unavailable. A one-line change to a config file is much faster than chasing someone to re-assign a PR.

3. Monitor and adjust: Track assignment distribution in a simple spreadsheet or dashboard. Look for patterns. if one engineer is consistently getting assignments despite having high load, your scoring weights may need tuning.

4. Provide feedback loops: Create a GitHub issue label like `wrong-reviewer` that anyone can apply to a PR. Review these weekly to identify gaps in your expertise mapping.

5. Handle code owner requirements: Always check the CODEOWNERS file first. Mandatory reviewers are non-negotiable, and the auto-assign skill should layer on top of them rather than replace them.

6. Test with edge cases: Write unit tests for scenarios like "all reviewers at max load," "no expertise match found," and "author is the only expert for a file."

7. Document your config: Add a comment header to your reviewer config file explaining how to update it. Without documentation, team members won't know they can add themselves as experts for new areas.

## Measuring Success

Once your system is live, track these metrics to quantify the improvement:

- Time to first review: Average hours between PR open and first review request accepted
- Review distribution entropy: How evenly distributed are reviews across the team (higher = better)
- Manual re-assignments: Count of times humans override the automated assignment
- Reviewer acceptance rate: How often the assigned reviewer completes the review vs. passes

A well-tuned system should reduce time to first review by 30-60% for most teams, simply by eliminating the "who should I ask?" decision from the PR author's workflow.

## Reading CODEOWNERS for Required Reviewers

Most mature repositories use a `CODEOWNERS` file to designate required reviewers for specific paths. Your auto-assign system should respect these requirements rather than bypassing them, overriding code owners creates friction with your security and compliance workflows.

Integrate CODEOWNERS parsing into your selection logic:

```javascript
const fs = require('fs');
const path = require('path');
const { minimatch } = require('minimatch');

function parseCodeOwners(repoRoot) {
 const codeownersPath = path.join(repoRoot, '.github', 'CODEOWNERS');
 if (!fs.existsSync(codeownersPath)) return [];

 const lines = fs.readFileSync(codeownersPath, 'utf8').split('\n');
 return lines
 .filter(line => line.trim() && !line.startsWith('#'))
 .map(line => {
 const parts = line.trim().split(/\s+/);
 return {
 pattern: parts[0],
 owners: parts.slice(1).map(o => o.replace('@', ''))
 };
 });
}

function getRequiredOwners(changedFiles, codeownersRules) {
 const required = new Set();

 changedFiles.forEach(file => {
 // CODEOWNERS rules are applied in reverse order (last match wins)
 const reversed = [...codeownersRules].reverse();
 for (const rule of reversed) {
 if (minimatch(file, rule.pattern, { matchBase: true })) {
 rule.owners.forEach(owner => required.add(owner));
 break;
 }
 }
 });

 return Array.from(required);
}

// Updated selection function that respects code owners
function selectReviewers(changes, reviewers, config) {
 const rules = parseCodeOwners(config.repoRoot);
 const requiredOwners = getRequiredOwners(changes.files, rules);

 // Always include required owners first
 const selected = new Set(requiredOwners.filter(o => reviewers.find(r => r.name === o)));

 // Add additional reviewers up to config.maxReviewers
 if (selected.size < config.maxReviewers) {
 const additional = advancedSelect(changes, reviewers, {
 ...config,
 exclude: [...selected] // Don't double-assign code owners
 });
 selected.add(additional.name);
 }

 return Array.from(selected);
}
```

This ensures code owners are always notified for their sections while still distributing load for files that don't have required reviewers.

## Handling PR Size and Complexity

Large pull requests are harder to review thoroughly regardless of who reviews them. Your auto-assign system can factor in PR size and nudge authors toward splitting large changes before assigning reviewers.

Add a size classification step:

```javascript
function classifyPRSize(changes) {
 const totalLines = changes.additions + changes.deletions;
 const fileCount = changes.files.length;

 if (totalLines > 500 || fileCount > 20) return 'large';
 if (totalLines > 150 || fileCount > 8) return 'medium';
 return 'small';
}

async function handleAssignment(pr, changes, reviewers, config) {
 const size = classifyPRSize(changes);

 if (size === 'large') {
 // Add a comment suggesting the PR be split
 await addPRComment(pr, `
> Large PR detected (${changes.additions + changes.deletions} lines across ${changes.files.length} files)
>
> Consider splitting this into smaller, focused PRs for easier review.
> Assigning reviewers now, but small PRs receive faster and more thorough reviews.
 `);
 // For large PRs, assign 2 reviewers
 config.maxReviewers = 2;
 }

 const assigned = selectReviewers(changes, reviewers, config);
 await assignReviewers(pr, assigned);
 return { assigned, size };
}
```

This gives authors actionable feedback while still unblocking them. the assignment happens immediately, but the size signal encourages better PR hygiene over time.

## Wrapping Up

Automating reviewer assignment with Claude Code transforms a tedious manual task into a consistent, efficient process. Start simple with basic load balancing, then add sophistication as your team learns the patterns.

The key is maintaining the right balance: enough automation to save time, enough flexibility to handle edge cases. Your Claude Code skill can evolve with your team's needs, making reviewer assignment one less thing to worry about in your daily workflow.

By combining CODEOWNERS respect, live load checking, expertise matching, and availability windows, you end up with a system that most teams can run for months without manual intervention. The real payoff is not just saving five minutes per PR. it is the elimination of the invisible cost of interrupted flow when an engineer has to stop and think about reviewer politics instead of writing code.



---


**Try it:** Paste your error into our [Error Diagnostic](/diagnose/) for an instant fix.
---

<div class="mastery-cta">

I'm a solo developer in Vietnam. 50K Chrome extension users. $500K+ on Upwork. 5 Claude Max subscriptions running agent fleets in parallel.

These are my actual CLAUDE.md templates, orchestration configs, and prompts. Not a course. Not theory. The files I copy into every project before I write a line of code.

**[See what's inside →](https://zovo.one/lifetime?utm_source=ccg&utm_medium=cta-default&utm_campaign=claude-code-for-auto-assign-reviewer-workflow-tutorial)**

$99 once. Free forever. 47/500 founding spots left.

</div>

Related Reading

- [Claude Code Algolia GeoSearch Filtering Workflow Tutorial](/claude-code-algolia-geosearch-filtering-workflow-tutorial/)
- [Claude Code CloudFormation Template Generation Workflow Guid](/claude-code-cloudformation-template-generation-workflow-guid/)
- [Claude Code Container Debugging: Docker Logs Workflow Guide](/claude-code-container-debugging-docker-logs-workflow-guide/)

Built by theluckystrike. More at [zovo.one](https://zovo.one)
{% endraw %}


