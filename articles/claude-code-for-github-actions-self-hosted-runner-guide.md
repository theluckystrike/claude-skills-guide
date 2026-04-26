---

layout: default
title: "How to Use GitHub Actions Self-Hosted (2026)"
description: "Learn how to set up and configure Claude Code on GitHub Actions self-hosted runners for automated AI-assisted development workflows."
date: 2026-03-15
last_modified_at: 2026-04-17
author: "Claude Skills Guide"
permalink: /claude-code-for-github-actions-self-hosted-runner-guide/
categories: [guides]
tags: [claude-code, claude-skills]
reviewed: true
score: 7
render_with_liquid: false
geo_optimized: true
---

{% raw %}
Claude Code for GitHub Actions Self-Hosted Runner Guide

GitHub Actions provides powerful automation capabilities, but when you need more control over your build environment, persistent caching, or specialized tooling, self-hosted runners become essential. This guide shows you how to integrate Claude Code into your self-hosted runner infrastructure to enable AI-assisted development workflows directly within your CI/CD pipelines.

Why Use Claude Code on Self-Hosted Runners?

Self-hosted runners offer several advantages over GitHub-hosted runners:

- Persistent environments: Reuse installed dependencies and cached artifacts across runs
- Custom hardware: Use GPUs, larger RAM, or specialized hardware
- Cost efficiency: For large workloads, running your own infrastructure can be more economical
- Security and compliance: Keep sensitive code and data within your own network

When you add Claude Code to this mix, you gain AI-powered code review, automated refactoring, test generation, and documentation creation, all running within your controlled environment.

The combination is particularly valuable for teams that already self-host because the runner machine persists Claude Code's binary, model cache, and any skills between runs, eliminating cold-start installation overhead on every job.

## Comparing Hosted vs. Self-Hosted Runners for Claude Code

Before committing to self-hosted infrastructure, it helps to understand the practical trade-offs:

| Factor | GitHub-Hosted | Self-Hosted |
|--------|--------------|-------------|
| Setup time | None | 30–60 min initial |
| Claude Code install cost | Per-run download | One-time install |
| Environment persistence | None (ephemeral) | Full (filesystem persists) |
| API key management | GitHub Secrets | GitHub Secrets or env file |
| Network access | Public internet | Your VPC / private network |
| Monthly cost | Per-minute billing | Your hardware costs |
| Security surface | Shared runners | Fully controlled |
| Hardware customization | Predefined tiers | Anything you own |

For teams running more than a few hundred workflow minutes per month with Claude Code, self-hosted runners pay for themselves quickly, and the persistent environment makes multi-step workflows significantly faster.

## Setting Up Claude Code on Your Self-Hosted Runner

## Prerequisites

Before installing Claude Code, ensure your runner meets these requirements:

- Ubuntu 20.04 LTS or later (other Linux distributions may work but are less tested)
- At least 2GB RAM (4GB recommended for Claude Code)
- Node.js 18+ installed (Claude Code is distributed as an npm package)
- Git installed
- The GitHub Actions runner service already registered to your repository or organization

## Installation Steps

First, SSH into your self-hosted runner machine and install Claude Code via npm:

```bash
Install Node.js 20 LTS if not already present
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
sudo apt-get install -y nodejs

Install Claude Code globally
sudo npm install -g @anthropic-ai/claude-code

Verify installation
claude --version
```

Next, configure your Anthropic API key for the runner. The cleanest approach for a systemd-managed runner service is to add it to the service environment file:

```bash
Find the runner service override directory
sudo mkdir -p /etc/systemd/system/actions.runner.<org>.<repo>.service.d/

Create an environment override
sudo tee /etc/systemd/system/actions.runner.<org>.<repo>.service.d/env.conf > /dev/null <<EOF
[Service]
Environment="ANTHROPIC_API_KEY=your-api-key-here"
EOF

Reload and restart the runner service
sudo systemctl daemon-reload
sudo systemctl restart actions.runner.<org>.<repo>.service
```

This approach avoids storing the key in plaintext files that is readable by other processes on the machine.

## Registering the Runner with a Label

When you register the runner, add a descriptive label so workflows can target it specifically:

```bash
./config.sh \
 --url https://github.com/<org>/<repo> \
 --token <registration-token> \
 --name claude-runner-01 \
 --labels self-hosted,linux,x64,claude-code \
 --unattended
```

Using the `claude-code` label lets you route only AI-assisted jobs to this runner while other jobs use standard runners.

## Configuring GitHub Actions to Use Claude Code

Now you need to create workflows that invoke Claude Code on your self-hosted runners. The key is targeting the `self-hosted` label in your workflow.

## Basic Workflow Example

Create a new workflow file in your repository:

```yaml
name: AI Code Review with Claude

on:
 pull_request:
 branches: [main, develop]

jobs:
 claude-review:
 runs-on: [self-hosted, linux, claude-code]
 steps:
 - name: Checkout code
 uses: actions/checkout@v4
 with:
 fetch-depth: 0 # Full history so Claude can see diffs

 - name: Run Claude Code review
 run: |
 claude --print "Review the changes in this repository as a code review assistant. Focus on: 1. Potential bugs or logic errors, 2. Security vulnerabilities, 3. Code style inconsistencies, 4. Missing error handling. Provide a detailed report in markdown format."
 env:
 ANTHROPIC_API_KEY: ${{ secrets.CLAUDE_API_KEY }}
 GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
```

This workflow triggers on pull requests and uses Claude Code to review your code changes. The `fetch-depth: 0` option ensures Claude has access to the full commit history and can produce meaningful diff-aware reviews rather than just scanning the current state of files.

## Posting Review Comments Automatically

A more useful pattern is to capture Claude's output and post it as a PR comment:

```yaml
name: AI Code Review with Claude

on:
 pull_request:
 branches: [main, develop]

jobs:
 claude-review:
 runs-on: [self-hosted, linux, claude-code]
 permissions:
 pull-requests: write
 steps:
 - uses: actions/checkout@v4
 with:
 fetch-depth: 0

 - name: Generate Claude review
 id: review
 run: |
 REVIEW=$(claude --print "You are a code reviewer. Analyze the staged changes and produce a concise markdown review covering: correctness, security, readability, and test coverage. Be specific, quote line numbers where possible." 2>&1)
 # Escape for multiline output
 echo "review<<EOF" >> $GITHUB_OUTPUT
 echo "$REVIEW" >> $GITHUB_OUTPUT
 echo "EOF" >> $GITHUB_OUTPUT
 env:
 ANTHROPIC_API_KEY: ${{ secrets.CLAUDE_API_KEY }}

 - name: Post review as PR comment
 uses: actions/github-script@v7
 with:
 script: |
 github.rest.issues.createComment({
 issue_number: context.issue.number,
 owner: context.repo.owner,
 repo: context.repo.repo,
 body: `## Claude Code Review\n\n${{ steps.review.outputs.review }}`
 })
```

## Advanced: Using Claude Code Skills in CI/CD

You can use Claude Code skills for more specialized tasks. Here's how to use custom skills in your workflows:

```yaml
name: Claude Skill Execution

on:
 workflow_dispatch:
 inputs:
 skill_name:
 description: 'Skill to execute'
 required: true
 default: 'code-analyzer'
 target_path:
 description: 'Path to analyze'
 required: true
 default: '.'

jobs:
 execute-skill:
 runs-on: [self-hosted, linux, claude-code]
 steps:
 - uses: actions/checkout@v4

 - name: Copy skill file
 run: cp ./skills/${{ github.event.inputs.skill_name }}.md ./.claude/

 - name: Execute skill
 run: claude --print "Using the /${{ github.event.inputs.skill_name }} skill, analyze ${{ github.event.inputs.target_path }}"
 env:
 ANTHROPIC_API_KEY: ${{ secrets.CLAUDE_API_KEY }}
```

Skills stored in your repository's `skills/` directory become reusable building blocks. Teams often maintain a library of skills, one for security audits, one for migration analysis, one for generating test cases, and invoke them via `workflow_dispatch` whenever needed.

## Real-World Workflow Patterns

## Automated Test Generation on Merge

When a branch merges to main, have Claude generate tests for any new functions that lack coverage:

```yaml
name: Generate Missing Tests

on:
 push:
 branches: [main]

jobs:
 generate-tests:
 runs-on: [self-hosted, linux, claude-code]
 steps:
 - uses: actions/checkout@v4

 - name: Find untested functions
 run: |
 claude --print "Examine the Python files in src/. For any public function or method that has no corresponding test in tests/, write a pytest test case. Output only the test code, formatted as a complete test file at tests/test_generated.py." \
 > tests/test_generated.py
 env:
 ANTHROPIC_API_KEY: ${{ secrets.CLAUDE_API_KEY }}

 - name: Commit generated tests
 run: |
 git config user.name "Claude Code Bot"
 git config user.email "claude-bot@noreply"
 git add tests/test_generated.py
 git diff --cached --quiet || git commit -m "chore: add AI-generated test coverage"
 git push
 env:
 GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
```

## Scheduled Documentation Refresh

Keep README files and API docs in sync with the code on a weekly schedule:

```yaml
name: Refresh Documentation

on:
 schedule:
 - cron: '0 6 * * 1' # Every Monday at 6 AM UTC

jobs:
 refresh-docs:
 runs-on: [self-hosted, linux, claude-code]
 steps:
 - uses: actions/checkout@v4

 - name: Update API documentation
 run: |
 claude --print "Read the Python source files in src/api/. Update docs/api-reference.md to accurately reflect the current function signatures, parameters, return types, and any exceptions raised. Preserve the existing document structure." \
 > docs/api-reference.md
 env:
 ANTHROPIC_API_KEY: ${{ secrets.CLAUDE_API_KEY }}

 - name: Open PR with updated docs
 run: |
 BRANCH="docs/auto-refresh-$(date +%Y%m%d)"
 git checkout -b "$BRANCH"
 git add docs/
 git diff --cached --quiet || (
 git commit -m "docs: automated weekly refresh"
 git push origin "$BRANCH"
 gh pr create --title "docs: weekly automated refresh" --body "AI-generated documentation update" --base main
 )
 env:
 GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
 GH_TOKEN: ${{ secrets.GITHUB_TOKEN }}
```

## Best Practices for Running Claude Code on Self-Hosted Runners

1. Manage API Costs Effectively

Claude Code makes API calls that incur costs. Implement these strategies to manage expenses:

```yaml
jobs:
 claude-task:
 runs-on: [self-hosted, linux, claude-code]
 steps:
 - name: Cache Claude responses
 uses: actions/cache@v4
 with:
 path: .claude-cache
 key: claude-cache-${{ github.sha }}
 restore-keys: |
 claude-cache-

 - name: Run with budget limits
 run: |
 claude --max-turns 10 --print "${{ github.event.inputs.prompt }}"
 env:
 ANTHROPIC_API_KEY: ${{ secrets.CLAUDE_API_KEY }}
```

In addition to `--max-turns`, scope your prompts to only the files that changed in a given PR rather than the entire repository. Feeding Claude a 50,000-line codebase when it only needs to review a 200-line diff wastes tokens and increases latency. Use `git diff origin/main...HEAD -- '*.py'` to extract just the relevant diff.

2. Secure Your Credentials

Never expose sensitive data in workflow files. Use GitHub secrets:

```yaml
steps:
 - name: Claude Code with secure context
 run: |
 claude --print "You are working with sensitive data. Do not log any secrets. Task: ${{ github.event.inputs.task }}"
 env:
 ANTHROPIC_API_KEY: ${{ secrets.CLAUDE_API_KEY }}
 DATABASE_URL: ${{ secrets.DATABASE_URL }}
```

Also audit what Claude Code can access on the runner filesystem. If your runner has credentials mounted at `/etc/app-secrets/`, add a `.claudeignore` file at the repo root to prevent Claude from reading those paths:

```
.claudeignore
/etc/
/var/
*.pem
*.key
.env*
```

3. Handle Rate Limits

GitHub API rate limits apply to Claude Code when it interacts with GitHub. Use these mitigation strategies:

```yaml
steps:
 - name: Wait for rate limit reset if needed
 if: github.event_name == 'schedule'
 run: |
 # Check remaining API calls
 REMAINING=$(gh api rate_limit --jq '.resources.core.remaining')
 if [ "$REMAINING" -lt 50 ]; then
 echo "Rate limit low, waiting..."
 sleep 3600
 fi
 env:
 GH_TOKEN: ${{ secrets.GITHUB_TOKEN }}
```

For the Anthropic API specifically, if you have multiple workflows running in parallel on the same runner, they will share the same API key's rate limit. Use a concurrency group to serialize them:

```yaml
concurrency:
 group: claude-api-${{ github.repository }}
 cancel-in-progress: false
```

4. Set Up Proper Logging

Maintain audit trails for AI-assisted operations:

```yaml
steps:
 - name: Capture Claude output
 run: |
 claude --print "${{ github.event.inputs.prompt }}" 2>&1 | \
 tee claude-output.log

 - name: Upload logs
 uses: actions/upload-artifact@v4
 with:
 name: claude-logs
 path: claude-output.log
 retention-days: 30
```

Retaining logs for 30 days gives you an audit trail for any AI-generated code changes, useful when a reviewer later asks "why did this function change?" You can trace it back to the exact Claude invocation and prompt.

## Troubleshooting Common Issues

## Claude Code Not Found

If Claude Code isn't recognized, check your PATH:

```bash
echo $PATH
which claude
```

Add to PATH if needed. For the Actions runner service, PATH changes in `.bashrc` or `.profile` are not always picked up. Set PATH explicitly in the workflow step instead:

```yaml
- name: Run Claude Code
 run: |
 export PATH="$PATH:/usr/local/bin"
 claude --version
```

## Authentication Failures

If your API key is invalid or expired, the error will appear in the step output. Rotate the key in the Anthropic console, then update the GitHub Secret:

```bash
gh secret set CLAUDE_API_KEY --body "new-api-key-here" --repo <org>/<repo>
```

You do not need to restart the runner, GitHub Secrets are injected fresh at job start time.

## Memory Issues

If Claude Code crashes due to memory constraints, add a swap file:

```bash
sudo fallocate -l 2G /swapfile
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile

Make it persistent across reboots
echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab
```

## Workflow Taking Too Long

If Claude Code is timing out inside a job, the most common cause is an overly broad prompt operating on a large repository. Add `--max-turns 5` to limit recursive operations and scope the working directory:

```yaml
- name: Scoped analysis
 working-directory: src/payments/ # Limit Claude's view
 run: claude --max-turns 5 --print "Summarize the payment processing logic."
 env:
 ANTHROPIC_API_KEY: ${{ secrets.CLAUDE_API_KEY }}
```

## Conclusion

Integrating Claude Code with GitHub Actions self-hosted runners unlocks powerful AI-assisted development workflows while maintaining control over your infrastructure. Start with the basic workflow examples above, then customize them to match your team's needs. Remember to monitor API usage, secure your credentials, and implement proper logging for production deployments.

With proper configuration, Claude Code becomes a valuable team member, handling code reviews, generating documentation, and assisting with complex refactoring tasks, all executing securely within your own infrastructure. The persistent nature of self-hosted runners means you can cache skill files, build up institutional prompts in a `skills/` directory, and run longer multi-step workflows that would time out on ephemeral hosted runners.


---

---

<div class="mastery-cta">

This took me 3 hours to figure out. I put it in a CLAUDE.md so I'd never figure it out again. Now Claude gets it right on the first try, every project.

16 framework templates. Next.js, FastAPI, Laravel, Rails, Go, Rust, Terraform, and 9 more. Each one 300+ lines of "here's exactly how this stack works." Copy into your project. Done.

**[See the templates →](https://zovo.one/lifetime?utm_source=ccg&utm_medium=cta-deploy&utm_campaign=claude-code-for-github-actions-self-hosted-runner-guide)**

$99 once. Yours forever. I keep adding templates monthly.

</div>

Related Reading

- [Claude Code for Beginners: Complete Getting Started Guide](/claude-code-for-beginners-complete-getting-started-2026/)
- [Best Claude Skills for Developers in 2026](/best-claude-skills-for-developers-2026/)
- [Claude Skills Guides Hub](/guides-hub/)

Built by theluckystrike. More at [zovo.one](https://zovo.one)
{% endraw %}



**Find the right skill →** Browse 155+ skills in our [Skill Finder](/skill-finder/).

## See Also

**Quick setup →** Launch your project with our [Project Starter](/starter/).

**Try it:** Paste your error into our [Error Diagnostic](/diagnose/) for an instant fix.

- [Claude Code for Coolify — Workflow Guide](/claude-code-for-coolify-self-hosting-workflow-guide/)
- [Claude Code for GitHub CLI — Workflow Guide](/claude-code-for-github-cli-workflow-guide/)
