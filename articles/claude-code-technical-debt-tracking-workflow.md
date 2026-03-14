---

layout: default
title: "Claude Code Technical Debt Tracking Workflow"
description: "A practical workflow for identifying, tracking, and managing technical debt using Claude Code skills and automation tools."
date: 2026-03-14
author: "Claude Skills Guide"
permalink: /claude-code-technical-debt-tracking-workflow/
categories: [guides]
tags: [claude-code, claude-skills]
reviewed: true
score: 7
---


# Claude Code Technical Debt Tracking Workflow

Technical debt accumulates in every codebase. Without a systematic approach, it quietly slows down development, introduces bugs, and makes refactoring increasingly expensive. A Claude Code technical debt tracking workflow helps you identify debt early, document it properly, and systematically address it before it derails your project.

This guide shows you how to build an automated workflow that integrates with your existing development process.

## Setting Up Debt Discovery with Claude Code

The first step involves scanning your codebase for common debt patterns. You can invoke Claude Code with specific prompts to identify areas needing attention. A typical discovery session uses the analyze or inspect patterns.

```bash
# Ask Claude to identify code smells and debt patterns
"Analyze the src/ directory for: duplicate code blocks, functions over 50 lines, missing error handling, TODO comments older than 30 days, and unused exports"
```

This approach works well for JavaScript and TypeScript projects. For Python codebases, extend the prompt to include PEP 8 violations and missing type hints. Claude Code can examine multiple files in a session, making it effective for both small modules and larger packages.

## Categorizing and Prioritizing Debt Items

Once you identify debt, organizing it into categories helps with prioritization. Create a structured format that Claude Code can parse and export. A markdown-based tracking system works well with skills like supermemory for persistent storage.

```markdown
## Technical Debt Registry

### Priority: High
- [ ] TD-001: Authentication middleware missing timeout handling (api/auth/)
- [ ] TD-002: Database queries in controllers instead of repository layer (features/users/)

### Priority: Medium
- [ ] TD-003: Component library has inconsistent prop types (components/)
- [ ] TD-004: Missing test coverage on payment module (services/payment/)

### Priority: Low
- [ ] TD-005: Outdated dependencies in package.json
- [ ] TD-006: Documentation comments missing on utility functions
```

You can automate this categorization using a custom skill. Define patterns for each priority level based on business impact, frequency of changes, and risk surface area.

## Automating Debt Detection in CI/CD

Static analysis tools catch many debt patterns automatically. Integrate these checks into your CI pipeline using GitHub Actions or similar platforms.

```yaml
# .github/workflows/debt-check.yml
name: Technical Debt Check
on: [pull_request]

jobs:
  debt-scan:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Run debt detection
        run: |
          npx eslint --max-warnings 0 src/ || true
          npx complexity-report src/ --threshold 15 || true
      - name: Comment results
        uses: actions/github-script@v7
        with:
          script: |
            // Post debt summary as PR comment
```

For projects with existing test infrastructure, the tdd skill helps convert debt items into test cases. Each debt item becomes a failing test that validates the fix. This approach ensures you actually address the debt rather than just documenting it.

## Tracking Debt with External Tools

For teams using project management software, sync debt items to tools like Linear, Jira, or Notion. The linear-mcp-server and jira-mcp-server skills provide direct integration.

```bash
# Create debt ticket in Linear via MCP
"Create a priority:high issue in Linear titled 'TD-001: Add timeout to auth middleware' with label 'technical-debt' and estimate 3 points"
```

The notepad-mcp-server works for simpler tracking needs. You can maintain a single source of truth that both humans and automated tools reference.

## Visualizing Debt Over Time

Technical debt becomes more manageable when you can see trends. The xlsx skill generates reports tracking debt counts, age, and resolution velocity.

```python
# Generate debt trend report using xlsx skill
# This creates a spreadsheet with:
# - Sheet 1: Debt items by category and priority
# - Sheet 2: Monthly resolution rate
# - Sheet 3: Impact analysis by module
```

For visual dashboards, export data to tools like Grafana or Datadog. The datadog-mcp-server skill helps you push metrics to these platforms automatically.

## Creating a Debt Review Cadence

Sustainable debt management requires regular attention. Establish a weekly or bi-weekly review where your team examines new debt items and triages existing ones. Claude Code can prepare these reviews automatically.

```bash
# Generate weekly debt summary
"Summarize the technical debt items added this week, show their priorities, and suggest which ones to tackle based on upcoming sprint priorities"
```

The claude-md skill helps format these summaries according to your team's conventions. Consistent formatting makes information easier to scan and act upon.

## Integrating Debt Tracking into Daily Workflow

The most effective approach weaves debt awareness into normal development. When Claude Code helps with code reviews or feature development, it can flag debt it encounters.

```bash
# In a code review context
"Review this PR for both functionality and code quality issues. Note any technical debt introduced or resolved"
```

The claude-code-review skill, when properly configured, checks for debt patterns during every review. This real-time feedback prevents debt from accumulating unnoticed.

## Automating Documentation Generation

Documentation debt often gets overlooked. Use the pdf and docx skills to generate debt reports in formats suitable for stakeholder review.

```bash
# Export current debt status to PDF report
"Create a PDF report of our current technical debt status, organized by module and priority, suitable for executive review"
```

This automation transforms technical metrics into business-readable documents.

## Building a Debt Reduction Workflow

The ultimate goal is reducing debt systematically. Create a pipeline that converts debt items into actionable tasks.

1. **Discovery**: Claude Code scans codebase during daily sessions
2. **Documentation**: Debt items recorded in tracking system
3. **Prioritization**: Weekly review categorizes and orders items
4. **Implementation**: Debt fixed during dedicated sprints or alongside feature work
5. **Verification**: Tests validate fixes and prevent regression

The automation slack-gif-creator skill helps create visual summaries of this workflow for team documentation or onboarding new members.

## Measuring Progress

Track your debt reduction over time using concrete metrics. Key measurements include:

- Total debt items by priority
- Average age of unresolved debt
- Debt resolution velocity (items closed per sprint)
- Code coverage improvements in refactored modules
- Static analysis warning counts

Claude Code can generate these metrics on demand using the analyze prompt with specific output formats.

## Conclusion

A Claude Code technical debt tracking workflow combines automated detection, structured documentation, and regular review cycles. By integrating debt awareness into daily development, you prevent accumulation and maintain codebase health over time.

The skills referenced here—supermemory, tdd, linear-mcp-server, jira-mcp-server, xlsx, pdf, and others—each contribute to different parts of this workflow. Start with simple debt detection, then gradually add tracking and visualization as your process matures.

## Related Reading

- [Claude Code Cyclomatic Complexity Reduction](/claude-skills-guide/claude-code-cyclomatic-complexity-reduction/) — Complexity metrics are a core debt indicator
- [Claude Code Output Quality How to Improve Results](/claude-skills-guide/claude-code-output-quality-how-to-improve-results/) — Debt tracking leads to quality improvements
- [Claude TDD Skill: Test-Driven Development Workflow](/claude-skills-guide/claude-tdd-skill-test-driven-development-workflow/) — TDD prevents future technical debt accumulation
- [Advanced Claude Skills Hub](/claude-skills-guide/advanced-hub/) — Advanced code quality strategies

Built by theluckystrike — More at [zovo.one](https://zovo.one)
