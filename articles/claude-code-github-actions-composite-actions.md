---
layout: default
title: "Claude Code GitHub Actions Composite (2026)"
description: "Learn to build reusable GitHub Actions composite actions that integrate Claude Code automation into your CI/CD pipelines."
date: 2026-03-14
last_modified_at: 2026-04-17
categories: [tutorials]
tags: [claude-code, claude-skills, github-actions, composite-actions, cicd]
author: "Claude Skills Guide"
reviewed: true
score: 7
permalink: /claude-code-github-actions-composite-actions/
render_with_liquid: false
geo_optimized: true
---

{% raw %}
[GitHub Actions composite actions let you package multiple workflow steps into a single, reusable action](/best-claude-code-skills-to-install-first-2026/) When you combine composite actions with Claude Code, you create reusable automation building blocks that can run AI-powered tasks across different repositories. This guide shows you how to build composite actions that invoke Claude skills for code review, documentation generation, and test automation.

## Why Composite Actions Matter for Claude Integration

Standard GitHub Actions workflows often repeat the same Claude invocation steps across multiple repositories. You might need to run a `tdd` skill to analyze test coverage on every pull request, [use `pdf` skill to generate formatted reports](/best-claude-code-skills-to-install-first-2026/) reports, or invoke `frontend-design` skill to check accessibility. Composite actions eliminate this duplication by letting you define the Claude invocation once and reuse it anywhere.

Composite actions also solve the parameterization challenge. Different projects may need different Claude models, different skill configurations, or different file filters. A well-designed composite action accepts these as inputs, making your automation portable across teams and repositories.

Without composite actions, you end up copy-pasting YAML blocks between repositories. When the Claude CLI changes an argument name or you want to upgrade the model version, you must find and edit every copy. With a composite action stored in a shared repository, one change propagates everywhere that action is referenced.

There is also a readability benefit. A workflow that calls `./.github/actions/claude-review` is far easier to understand at a glance than one containing fifteen steps of environment setup, CLI installation, and output parsing. Composite actions push the complexity behind a clean interface.

## Composite Actions vs. Other Reuse Patterns

Before building a composite action, it helps to understand where it fits relative to other GitHub Actions reuse mechanisms:

| Pattern | When to Use | Shared State |
|---|---|---|
| Composite action | Package multiple steps into one callable unit | Shares the same job runner |
| Reusable workflow | Orchestrate entire jobs from a central definition | Runs in its own job context |
| JavaScript action | Need full Node.js logic or platform independence | Isolated execution |
| Docker container action | Need a specific runtime environment | Isolated execution |

For Claude Code integration, composite actions are usually the right choice. They run in the same job as the caller (so they have access to the checked-out repository), they require no containerization, and they support the simple input/output interface that Claude invocations need.

## Creating a Basic Claude Composite Action

A composite action lives in `.github/actions/claude-action/action.yml`. The structure requires a `name`, `description`, `inputs`, and a `runs` section using `runs.using: composite`. Here is a minimal action that installs Claude Code and runs a review:

```yaml
name: 'Claude Code Review'
description: 'Runs Claude Code analysis on changed files'

inputs:
 api-key:
 description: 'Anthropic API key'
 required: true
 model:
 description: 'Claude model to use'
 required: false
 default: 'claude-opus-4-6'
 prompt:
 description: 'Review prompt to pass to Claude'
 required: false
 default: 'Review this code for correctness, security issues, and style problems.'

runs:
 using: 'composite'
 steps:
 - name: Set up Node.js
 uses: actions/setup-node@v4
 with:
 node-version: '20'

 - name: Install Claude Code
 shell: bash
 run: npm install -g @anthropic-ai/claude-code

 - name: Run Claude review
 shell: bash
 env:
 ANTHROPIC_API_KEY: ${{ inputs.api-key }}
 CLAUDE_MODEL: ${{ inputs.model }}
 run: |
 claude --model "$CLAUDE_MODEL" --print "${{ inputs.prompt }}"
```

This action sets up Node.js, installs Claude Code globally, and runs an analysis command. You can now invoke it from any workflow without repeating the setup steps.

Calling this action from a workflow looks like this:

```yaml
jobs:
 review:
 runs-on: ubuntu-latest
 steps:
 - uses: actions/checkout@v4
 - uses: ./.github/actions/claude-review
 with:
 api-key: ${{ secrets.ANTHROPIC_API_KEY }}
 prompt: 'Check for any security vulnerabilities in the changed files.'
```

## Passing Context with GitHub Context

Composite actions have access to GitHub context through `${{ github }}` and `${{ steps }}` variables. This enables powerful patterns where Claude analyzes specific files from a pull request:

```yaml
name: 'Claude PR Analysis'
description: 'Analyzes pull request changes with Claude'

inputs:
 api-key:
 description: 'Anthropic API key'
 required: true
 base-ref:
 description: 'Base branch ref for diff comparison'
 required: false
 default: 'main'

runs:
 using: 'composite'
 steps:
 - name: Install Claude Code
 shell: bash
 run: npm install -g @anthropic-ai/claude-code

 - name: Get changed files
 id: changed-files
 shell: bash
 run: |
 git fetch origin ${{ inputs.base-ref }}
 CHANGED=$(git diff --name-only origin/${{ inputs.base-ref }}...HEAD | tr '\n' ' ')
 echo "files=$CHANGED" >> $GITHUB_OUTPUT

 - name: Run Claude analysis on changed files
 shell: bash
 env:
 ANTHROPIC_API_KEY: ${{ inputs.api-key }}
 run: |
 FILES="${{ steps.changed-files.outputs.files }}"
 if [ -z "$FILES" ]; then
 echo "No changed files detected."
 exit 0
 fi
 claude --print "Review these changed files for issues: $FILES. Read each file and provide a summary of concerns."
```

The composite action captures the changed files between base and head commits, then passes them to Claude for review. This pattern works with any Claude skill you have installed.

You can extend this pattern to filter by file type before passing to Claude. For example, if you only want to review TypeScript files:

```yaml
 - name: Get changed TypeScript files
 id: changed-ts
 shell: bash
 run: |
 git fetch origin ${{ inputs.base-ref }}
 CHANGED=$(git diff --name-only origin/${{ inputs.base-ref }}...HEAD \
 | grep -E '\.(ts|tsx)$' | tr '\n' ' ')
 echo "files=$CHANGED" >> $GITHUB_OUTPUT
```

Filtering before passing to Claude keeps the context window focused and reduces API costs on large pull requests.

## Combining Multiple Claude Skills

A sophisticated composite action can invoke multiple Claude skills in sequence. For example, You should run both `tdd` and `pdf` skills together:

```yaml
name: 'Claude TDD Report'
description: 'Runs TDD analysis and generates a summary report'

inputs:
 api-key:
 description: 'Anthropic API key'
 required: true
 output-file:
 description: 'Path to write the report'
 required: false
 default: 'claude-tdd-report.md'

runs:
 using: 'composite'
 steps:
 - name: Install Claude Code
 shell: bash
 run: npm install -g @anthropic-ai/claude-code

 - name: Run TDD skill analysis
 shell: bash
 env:
 ANTHROPIC_API_KEY: ${{ inputs.api-key }}
 run: |
 claude --print "/tdd Analyze the test coverage for recently changed files. \
 Identify untested code paths and suggest missing test cases." \
 > tdd-raw-output.txt

 - name: Generate markdown report
 shell: bash
 env:
 ANTHROPIC_API_KEY: ${{ inputs.api-key }}
 run: |
 ANALYSIS=$(cat tdd-raw-output.txt)
 claude --print "Format this TDD analysis as a clean markdown report with \
 sections for Coverage Summary, Missing Tests, and Recommendations: $ANALYSIS" \
 > ${{ inputs.output-file }}

 - name: Upload report as artifact
 uses: actions/upload-artifact@v4
 with:
 name: claude-tdd-report
 path: ${{ inputs.output-file }}
```

This composite action chains two Claude invocations. The first analyzes test coverage using TDD patterns, and the second generates a formatted markdown report. Splitting the work into two Claude calls means each call has a clear, bounded task, one for analysis, one for formatting, which tends to produce more reliable results than a single large prompt trying to do both at once.

## Using Outputs for Pipeline Integration

Composite actions can output results that downstream steps consume. This matters when you want Claude's analysis to gate deployments or when you need to pass findings to other tools:

```yaml
outputs:
 review-result:
 description: 'Claude review result'
 value: ${{ steps.review.outputs.result }}
 review-passed:
 description: 'Whether review passed (true/false)'
 value: ${{ steps.parse.outputs.passed }}

runs:
 using: 'composite'
 steps:
 - name: Install Claude Code
 shell: bash
 run: npm install -g @anthropic-ai/claude-code

 - name: Run Claude review
 id: review
 shell: bash
 env:
 ANTHROPIC_API_KEY: ${{ inputs.api-key }}
 run: |
 RESULT=$(claude --print "Review this code. Respond with exactly one word: PASS or FAIL, \
 followed by a newline and your reasoning.")
 echo "result=$RESULT" >> $GITHUB_OUTPUT

 - name: Parse result
 id: parse
 shell: bash
 run: |
 RESULT="${{ steps.review.outputs.result }}"
 if echo "$RESULT" | grep -q "^PASS"; then
 echo "passed=true" >> $GITHUB_OUTPUT
 else
 echo "passed=false" >> $GITHUB_OUTPUT
 fi
```

Workflows can then use `${{ steps.action.outputs.review-result }}` to make decisions:

```yaml
jobs:
 claude-review:
 runs-on: ubuntu-latest
 outputs:
 review-result: ${{ steps.review.outputs.review-result }}
 review-passed: ${{ steps.review.outputs.review-passed }}
 steps:
 - uses: actions/checkout@v4
 - uses: ./.github/actions/claude-review
 id: review
 with:
 api-key: ${{ secrets.ANTHROPIC_API_KEY }}

 deploy:
 needs: claude-review
 if: needs.claude-review.outputs.review-passed == 'true'
 runs-on: ubuntu-latest
 steps:
 - run: echo "Deploying..."
```

This gating pattern ensures Claude approval before deployment proceeds.

One important design consideration: Claude's natural language output can be non-deterministic. If you are using outputs to drive boolean gate logic, write your prompt very precisely and add a parsing step that normalizes the response. Asking Claude to respond with "PASS" or "FAIL" as the first word makes parsing reliable. Asking Claude to "summarize whether the code is good or bad" will produce prose that is hard to parse reliably.

## Caching Claude Code Installation

If your composite action is called frequently, the `npm install -g @anthropic-ai/claude-code` step adds time to every run. You can cache it using the actions/cache action:

```yaml
 - name: Cache Claude Code installation
 uses: actions/cache@v4
 id: cache-claude
 with:
 path: ~/.npm-global
 key: claude-code-${{ runner.os }}-${{ hashFiles('/package-lock.json') }}

 - name: Install Claude Code
 if: steps.cache-claude.outputs.cache-hit != 'true'
 shell: bash
 run: |
 npm config set prefix ~/.npm-global
 npm install -g @anthropic-ai/claude-code

 - name: Add Claude to PATH
 shell: bash
 run: echo "$HOME/.npm-global/bin" >> $GITHUB_PATH
```

This pattern checks the cache before installing, reducing installation time from roughly 30 seconds to under 2 seconds on cache hits.

## Handling Authentication Securely

Composite actions should never hardcode API keys. Instead, use GitHub secrets and pass them as masked inputs:

```yaml
inputs:
 api-key:
 description: 'Anthropic API key from secrets'
 required: true
```

Workflows pass the secret like this:

```yaml
- uses: ./.github/actions/claude-review
 with:
 api-key: ${{ secrets.ANTHROPIC_API_KEY }}
```

For organizations with multiple repositories, consider using GitHub's organization-level secrets so you update the key in one place.

You can also configure repository environments with specific secrets for staging vs. production keys:

```yaml
jobs:
 review:
 environment: production
 steps:
 - uses: ./.github/actions/claude-review
 with:
 api-key: ${{ secrets.PROD_ANTHROPIC_API_KEY }}
```

Environment-scoped secrets let you use a restricted API key for pull request reviews and a separate key for production deployments, following the principle of least privilege.

## Publishing and Versioning Composite Actions

When your composite action is mature enough to share across multiple repositories, move it to its own dedicated repository. The standard pattern is:

```
your-org/claude-actions
 .github/
 actions/
 claude-review/
 action.yml
 claude-tdd-report/
 action.yml
 claude-pr-summary/
 action.yml
```

Other repositories reference it with a tag:

```yaml
- uses: your-org/claude-actions/.github/actions/claude-review@v1.2.0
 with:
 api-key: ${{ secrets.ANTHROPIC_API_KEY }}
```

Tag your action releases with semantic versioning. When you make breaking changes to inputs or outputs, increment the major version. This lets consumers pin to a major version (`@v1`) and get patch updates automatically, or pin to an exact tag (`@v1.2.0`) for full control.

## Best Practices for Claude Composite Actions

Keep composite actions focused on a single responsibility. Rather than building one massive action that does everything, create small, composable actions that chain together. This makes debugging easier and lets teams mix and match capabilities.

Always specify the Claude model explicitly in your action inputs rather than relying on defaults. Models change, and explicit versions ensure reproducible behavior across runs.

Test your composite actions locally before publishing. You can run the action steps manually on your machine using the same commands, verifying the Claude invocation works before automating in CI.

Document the expected inputs and outputs clearly in your action.yml. Other developers will need to know what environment variables Claude receives and what format the outputs use.

Add a timeout to Claude invocations to prevent runaway jobs. GitHub Actions jobs have a default timeout of 360 minutes, but a Claude invocation that enters an unexpected loop could consume that entire window. Set an explicit timeout:

```yaml
 - name: Run Claude analysis
 shell: bash
 timeout-minutes: 5
 env:
 ANTHROPIC_API_KEY: ${{ inputs.api-key }}
 run: |
 claude --print "Analyze the changed files."
```

Finally, log intermediate results for debugging. When a composite action fails, you need enough information in the logs to understand what Claude received and what it returned. Writing the raw output to a file and uploading it as an artifact makes post-failure debugging much faster.

## Summary

Composite actions provide the building blocks for reusable Claude Code automation in GitHub. By packaging Claude skill invocations into versioned actions, you create portable automation that works across repositories. The patterns in this guide, context passing, output handling, secure authentication, installation caching, skill chaining, and versioned publishing, form a foundation you can extend with specific skills like `supermemory` for persistent context or custom skills tailored to your codebase.

The key principle is to invest in the composite action once and reuse it everywhere. Every minute spent designing clean inputs, outputs, and error handling pays back when the action runs hundreds of times across dozens of repositories.

---


**Try it:** Paste your error into our [Error Diagnostic](/diagnose/) for an instant fix.
---

<div class="mastery-cta">

This took me 3 hours to figure out. I put it in a CLAUDE.md so I'd never figure it out again. Now Claude gets it right on the first try, every project.

16 framework templates. Next.js, FastAPI, Laravel, Rails, Go, Rust, Terraform, and 9 more. Each one 300+ lines of "here's exactly how this stack works." Copy into your project. Done.

**[See the templates →](https://zovo.one/lifetime?utm_source=ccg&utm_medium=cta-deploy&utm_campaign=claude-code-github-actions-composite-actions)**

$99 once. Yours forever. I keep adding templates monthly.

</div>

Related Reading

- [Claude Code GitHub Actions Approval Workflows](/claude-code-github-actions-approval-workflows/)
- [Claude Code GitHub Actions Matrix Builds Guide](/claude-code-github-actions-matrix-builds-guide/)
- [Automated Testing Pipeline with Claude TDD Skill 2026](/claude-tdd-skill-test-driven-development-workflow/)
- [Workflows Hub](/workflows/)

Built by theluckystrike. More at [zovo.one](https://zovo.one)
{% endraw %}


**Find the right skill →** Browse 155+ skills in our [Skill Finder](/skill-finder/).

