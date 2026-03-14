---
layout: default
title: "Claude Skills with GitHub Actions CI/CD Pipeline 2026"
description: "Integrate Claude Code into GitHub Actions CI/CD to automate code review, TDD analysis, and report generation using the Anthropic API."
date: 2026-03-13
categories: [workflows]
tags: [claude-code, claude-skills, github-actions, cicd, tdd, automation]
author: "Claude Skills Guide"
reviewed: true
score: 8
permalink: /claude-skills-with-github-actions-ci-cd-pipeline/
---
{% raw %}



# Claude Skills with GitHub Actions CI/CD Pipeline

[Integrating Claude Code with a GitHub Actions CI/CD pipeline](/claude-skills-guide/claude-code-github-actions-workflow-matrix-strategy-guide/) gives development teams an automated assistant that participates directly in their build, test, and deployment workflows. This guide covers practical patterns for wiring Claude intelligence into your existing pipelines — from triggering AI-powered code review on pull requests to generating PDF reports from test results.

## Why Combine Claude with GitHub Actions

GitHub Actions handles orchestration. Claude handles intelligence. Together they let you run contextual, AI-powered steps at any point in your delivery pipeline without maintaining a separate AI service.

Common use cases include:

- [Automated code review comments on PRs](/claude-skills-guide/what-is-the-best-claude-skill-for-automated-code-review/) analyzing test coverage
- PDF report generation from test results
- Accessibility and design checks on front-end PRs
- Security analysis of infrastructure diffs before deployment

## Prerequisites

- A GitHub repository with Actions enabled
- Claude API key (store as `ANTHROPIC_API_KEY` in repo secrets)
- Node.js 20+ in your runner environment

## Step 1: Store Your API Key

In your GitHub repository, go to **Settings > Secrets and variables > Actions** and add:

```
ANTHROPIC_API_KEY=your_api_key_here
```

[Never hardcode credentials in your workflow files](/claude-skills-guide/claude-code-permissions-model-security-guide-2026/).

## Step 2: Call Claude via the Anthropic API

The correct way to call Claude in CI is via the Anthropic API directly using `curl` or the Node.js SDK. Claude Code's interactive CLI (`claude`) is for interactive sessions, not headless CI automation.

Create a review script at `scripts/claude-review.js`:

```javascript
const Anthropic = require('@anthropic-ai/sdk');

const client = new Anthropic({ apiKey: process.env.ANTHROPIC_API_KEY });

async function reviewDiff(diff) {
  const message = await client.messages.create({
    model: 'claude-opus-4-6',
    max_tokens: 2048,
    system: `You are a TDD-focused code reviewer. Analyze the diff for:
1. Functions or branches with no test coverage
2. Potential regressions in existing tests
3. Missing error handling
4. Concrete test suggestions for uncovered paths

Output a structured review with these sections.`,
    messages: [{
      role: 'user',
      content: \`Review this diff for test coverage and quality:\n\n\${diff}\`
    }]
  });
  return message.content[0].text;
}

async function main() {
  const diff = require('fs').readFileSync('/tmp/pr_diff.txt', 'utf8');
  const review = await reviewDiff(diff);
  require('fs').writeFileSync('/tmp/review_summary.md', review);
  console.log('Review written to /tmp/review_summary.md');
}

main().catch(err => { console.error(err); process.exit(1); });
```

## Step 3: Create the Workflow File

Create `.github/workflows/claude-review.yml`:

```yaml
name: Claude AI Code Review

on:
  pull_request:
    types: [opened, synchronize]

jobs:
  claude-review:
    runs-on: ubuntu-latest
    permissions:
      pull-requests: write
      contents: read

    steps:
      - name: Checkout code
        uses: actions/checkout@v4
        with:
          fetch-depth: 0

      - name: Set up Node.js
        uses: actions/setup-node@v4
        with:
          node-version: '20'

      - name: Install Anthropic SDK
        run: npm install @anthropic-ai/sdk

      - name: Get PR diff
        run: |
          git diff origin/main...HEAD > /tmp/pr_diff.txt
          echo "Diff size: $(wc -c < /tmp/pr_diff.txt) bytes"

      - name: Run Claude review
        env:
          ANTHROPIC_API_KEY: ${{ secrets.ANTHROPIC_API_KEY }}
        run: node scripts/claude-review.js

      - name: Post review comment
        uses: actions/github-script@v7
        with:
          script: |
            const fs = require('fs');
            const summary = fs.readFileSync('/tmp/review_summary.md', 'utf8');
            await github.rest.issues.createComment({
              issue_number: context.issue.number,
              owner: context.repo.owner,
              repo: context.repo.repo,
              body: \`## Claude AI Review\n\n\${summary}\`
            });
```

## Step 4: Add a Deployment Gate

Use Claude to validate infrastructure changes before deployment. Add this job after your test suite passes:

```yaml
  claude-infra-check:
    runs-on: ubuntu-latest
    needs: [test]
    if: github.ref == 'refs/heads/main'

    steps:
      - uses: actions/checkout@v4

      - name: Set up Node.js
        uses: actions/setup-node@v4
        with:
          node-version: '20'

      - name: Install Anthropic SDK
        run: npm install @anthropic-ai/sdk

      - name: Validate IaC changes
        env:
          ANTHROPIC_API_KEY: ${{ secrets.ANTHROPIC_API_KEY }}
        run: |
          git diff HEAD~1 -- '*.tf' '*.yaml' 'docker-compose*' > /tmp/infra_diff.txt
          if [ -s /tmp/infra_diff.txt ]; then
            node -e "
              const Anthropic = require('@anthropic-ai/sdk');
              const fs = require('fs');
              const client = new Anthropic();
              async function check() {
                const diff = fs.readFileSync('/tmp/infra_diff.txt', 'utf8');
                const msg = await client.messages.create({
                  model: 'claude-opus-4-6',
                  max_tokens: 512,
                  messages: [{ role: 'user', content: 'Review this infrastructure diff for security misconfigurations, overly permissive IAM policies, or exposed ports. Output PASS or FAIL with one-line reasoning.\n\n' + diff }]
                });
                const result = msg.content[0].text;
                console.log(result);
                fs.writeFileSync('/tmp/infra_result.txt', result);
                if (!result.startsWith('PASS')) process.exit(1);
              }
              check().catch(e => { console.error(e); process.exit(1); });
            "
          fi
```

## Step 5: Generate PDF Reports for Stakeholders

After a successful release, use the Anthropic API to generate a release summary, then convert it to PDF:

```yaml
      - name: Generate release summary
        env:
          ANTHROPIC_API_KEY: ${{ secrets.ANTHROPIC_API_KEY }}
        run: |
          node -e "
            const Anthropic = require('@anthropic-ai/sdk');
            const fs = require('fs');
            const client = new Anthropic();
            async function summarize() {
              const changelog = fs.readFileSync('CHANGELOG.md', 'utf8');
              const msg = await client.messages.create({
                model: 'claude-opus-4-6',
                max_tokens: 1024,
                messages: [{ role: 'user', content: 'Write a stakeholder-friendly release summary from this changelog:\n\n' + changelog }]
              });
              fs.writeFileSync('/tmp/release_summary.md', msg.content[0].text);
            }
            summarize();
          "

      - name: Upload release summary
        uses: actions/upload-artifact@v4
        with:
          name: release-summary
          path: /tmp/release_summary.md
```

## Caching Node Modules Between Runs

Cache the Anthropic SDK installation to reduce workflow time:

```yaml
      - name: Cache node modules
        uses: actions/cache@v4
        with:
          path: node_modules
          key: ${{ runner.os }}-anthropic-sdk-v1
```

## Handling Rate Limits

[Claude API calls in CI can hit rate limits](/claude-skills-guide/claude-code-skill-timeout-error-how-to-increase-the-limit/) if many PRs open simultaneously. Implement retry logic in your Node.js scripts:

```javascript
async function callClaudeWithRetry(params, maxRetries = 3) {
  for (let attempt = 0; attempt <= maxRetries; attempt++) {
    try {
      return await client.messages.create(params);
    } catch (err) {
      if (err.status === 429 && attempt < maxRetries) {
        const delay = Math.pow(2, attempt) * 10000;
        console.warn(`Rate limited. Waiting ${delay}ms...`);
        await new Promise(r => setTimeout(r, delay));
        continue;
      }
      throw err;
    }
  }
}
```

## Security Considerations

- Always use `ANTHROPIC_API_KEY` from GitHub Secrets, never hardcoded
- Set `permissions` on jobs to the minimum required
- Review AI-generated comments before enabling auto-merge gates based on them
- Use branch protection rules to require the `claude-review` job to pass before merging

## Conclusion

Wiring Claude intelligence into GitHub Actions CI/CD [bridges the gap between automated testing](/claude-skills-guide/integrations-hub/). The key is calling the Anthropic API directly via the SDK in Node.js scripts rather than attempting to use Claude Code's interactive CLI in headless environments. Start with the PR review workflow and expand to deployment gates once you trust the output quality.

---

## Related Reading

- [Best Claude Skills for DevOps and Deployment](/claude-skills-guide/best-claude-skills-for-devops-and-deployment/) — Skills that integrate with CI/CD workflows
- [Best Claude Skills for Developers in 2026](/claude-skills-guide/best-claude-skills-for-developers-2026/) — Full developer skill stack
- [Claude Skills Token Optimization: Reduce API Costs](/claude-skills-guide/claude-skills-token-optimization-reduce-api-costs/) — Keep CI/CD API costs under control

Built by theluckystrike — More at [zovo.one](https://zovo.one)
{% endraw %}
