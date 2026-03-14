---
layout: default
title: "Claude Code GitHub Actions Composite Actions"
description: "Learn to build reusable GitHub Actions composite actions that integrate Claude Code automation into your CI/CD pipelines."
date: 2026-03-14
categories: [tutorials]
tags: [claude-code, claude-skills, github-actions, composite-actions, cicd]
author: "Claude Skills Guide"
reviewed: true
score: 7
---
{% raw %}

# Claude Code GitHub Actions Composite Actions

GitHub Actions composite actions let you package multiple workflow steps into a single, reusable action. When you combine composite actions with Claude Code, you create reusable automation building blocks that can run AI-powered tasks across different repositories. This guide shows you how to build composite actions that invoke Claude skills for code review, documentation generation, and test automation.

## Why Composite Actions Matter for Claude Integration

Standard GitHub Actions workflows often repeat the same Claude invocation steps across multiple repositories. You might need to run a `tdd` skill to analyze test coverage on every pull request, use `pdf` skill to generate reports, or invoke `frontend-design` skill to check accessibility. Composite actions eliminate this duplication by letting you define the Claude invocation once and reuse it anywhere.

Composite actions also solve the parameterization challenge. Different projects may need different Claude models, different skill configurations, or different file filters. A well-designed composite action accepts these as inputs, making your automation portable across teams and repositories.

## Creating a Basic Claude Composite Action

A composite action lives in `.github/actions/claude-action/action.yml`. The key component is the `runs` section using `composite`:

```yaml
name: 'Claude Code Review'
description: 'Runs Claude Code analysis on changed files'
inputs:
  api-key:
    description: 'Anthropic API key'
    required: true
  model:
    description: 'Claude model to use'
    default: 'claude-sonnet-4-20250514'
  files:
    description: 'Files to analyze'
    required: true
runs:
  using: 'composite'
  steps:
    - name: Set up Node.js
      uses: actions/setup-node@v4
      with:
        node-version: '20'
    
    - name: Install Claude CLI
      shell: bash
      run: |
        npm install -g @anthropic-ai/claude-code
    
    - name: Run Claude analysis
      shell: bash
      env:
        ANTHROPIC_API_KEY: ${{ inputs.api-key }}
        CLAUDE_MODEL: ${{ inputs.model }}
      run: |
        claude -p "Analyze these files for code quality issues: ${{ inputs.files }}"
```

This action sets up Node.js, installs Claude Code globally, and runs an analysis command. You can now invoke it from any workflow without repeating the setup steps.

## Passing Context with GitHub Context

Composite actions have access to GitHub context through `${{ github }}` and `${{ steps }}` variables. This enables powerful patterns where Claude analyzes specific files from a pull request:

```yaml
name: 'Claude PR Analysis'
description: 'Analyzes pull request changes with Claude'
inputs:
  api-key:
    description: 'Anthropic API key'
    required: true
runs:
  using: 'composite'
  steps:
    - name: Get changed files
      id: files
      shell: bash
      run: |
        echo "files=$(git diff --name-only ${{ github.event.pull_request.base.sha }} ${{ github.event.pull_request.head.sha }} | tr '\n' ' ')" >> $GITHUB_OUTPUT
    
    - name: Run Claude review
      shell: bash
      env:
        ANTHROPIC_API_KEY: ${{ inputs.api-key }}
      run: |
        claude -p "Review these pull request changes for bugs and improvements: ${{ steps.files.outputs.files }}"
```

The composite action captures the changed files between base and head commits, then passes them to Claude for review. This pattern works with any Claude skill you have installed.

## Combining Multiple Claude Skills

A sophisticated composite action can invoke multiple Claude skills in sequence. For example, you might want to run both `tdd` and `pdf` skills together:

```yaml
name: 'Claude TDD Report'
description: 'Runs TDD analysis and generates PDF report'
inputs:
  api-key:
    description: 'Anthropic API key'
    required: true
  test-dir:
    description: 'Test directory path'
    default: 'tests'
runs:
  using: 'composite'
  steps:
    - name: Run TDD analysis
      shell: bash
      env:
        ANTHROPIC_API_KEY: ${{ inputs.api-key }}
      run: |
        claude -p "Analyze test coverage in ${{ inputs.test-dir }} and suggest improvements"
    
    - name: Generate PDF report
      shell: bash
      env:
        ANTHROPIC_API_KEY: ${{ inputs.api-key }}
      run: |
        claude -p "Create a test coverage summary in markdown, then use the pdf skill to generate a report"
```

This composite action chains two Claude invocations. The first analyzes test coverage using TDD patterns, and the second generates a PDF report using the pdf skill.

## Using Outputs for Pipeline Integration

Composite actions can output results that downstream steps consume. This matters when you want Claude's analysis to gate deployments or when you need to pass findings to other tools:

```yaml
outputs:
  review-result:
    description: 'Claude review result'
    value: ${{ steps.review.outputs.result }}
runs:
  using: 'composite'
  steps:
    - name: Run Claude review
      id: review
      shell: bash
      env:
        ANTHROPIC_API_KEY: ${{ inputs.api-key }}
      run: |
        RESULT=$(claude -p "Analyze this code and return PASS or FAIL")
        echo "result=$RESULT" >> $GITHUB_OUTPUT
```

Workflows can then use `${{ steps.action.outputs.review-result }}` to make decisions:

```yaml
jobs:
  claude-review:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: ./.github/actions/claude-review
        id: review
        with:
          api-key: ${{ secrets.ANTHROPIC_API_KEY }}
  
  deploy:
    needs: claude-review
    if: needs.claude-review.outputs.review-result == 'PASS'
    runs-on: ubuntu-latest
    steps:
      - run: echo "Deploying..."
```

This gating pattern ensures Claude approval before deployment proceeds.

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

## Best Practices for Claude Composite Actions

Keep composite actions focused on a single responsibility. Rather than building one massive action that does everything, create small, composable actions that chain together. This makes debugging easier and lets teams mix and match capabilities.

Always specify the Claude model explicitly in your action inputs rather than relying on defaults. Models change, and explicit versions ensure reproducible behavior across runs.

Test your composite actions locally before publishing. You can run the action steps manually on your machine using the same commands, verifying the Claude invocation works before automating in CI.

Document the expected inputs and outputs clearly in your action.yml. Other developers will need to know what environment variables Claude receives and what format the outputs use.

## Summary

Composite actions provide the building blocks for reusable Claude Code automation in GitHub. By packaging Claude skill invocations into versioned actions, you create portable automation that works across repositories. The patterns in this guide — context passing, output handling, secure authentication, and skill chaining — form a foundation you can extend with specific skills like `supermemory` for persistent context or custom skills tailored to your codebase.

Built by theluckystrike — More at [zovo.one](https://zovo.one)
{% endraw %}
