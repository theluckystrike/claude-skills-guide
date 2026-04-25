---
layout: default
title: "Claude Flow (2026)"
description: "Claude Flow orchestrates multiple Claude Code agents as YAML-defined pipelines. Sequential chains, parallel execution, and conditional branching."
permalink: /claude-flow-tool-guide/
date: 2026-04-20
last_tested: "2026-04-24"
---

# Claude Flow: Multi-Agent Orchestration Tool (2026)

Claude Flow is a community-built orchestration tool that coordinates multiple Claude Code agents in structured workflows. Instead of manually launching agents and passing outputs between them, Claude Flow lets you define pipelines as YAML configurations and execute them with a single command.

## What Problem Does Claude Flow Solve?

Running multiple Claude Code agents manually is tedious. You launch one agent, wait for it to finish, copy its output, paste it into the next agent's prompt, and repeat. For a four-agent pipeline, this means babysitting the process for the entire duration.

Claude Flow automates this. You define the pipeline once, and it handles:

- Launching agents in the right order
- Passing outputs from one agent to the next
- Running independent agents in parallel
- Stopping the pipeline on failure (or continuing, depending on configuration)
- Collecting results from all agents into a single report

## Installation

Claude Flow is available on npm:

```bash
npm install -g claude-flow
```

Or use it without installing:

```bash
npx claude-flow run pipeline.yaml
```

Requires:
- Node.js 18 or later
- Claude Code CLI installed and authenticated
- An active Anthropic API key or Claude Max subscription

Verify the installation:

```bash
claude-flow --version
```

## Core Concepts

### Pipelines

A pipeline is a YAML file defining a sequence of agents and how they connect. Each agent has a name, a prompt, and optional configuration.

### Agents (Steps)

Each step in the pipeline is a Claude Code invocation. Steps can run sequentially or in parallel.

### Context Passing

Outputs from one step are automatically available to subsequent steps. Claude Flow injects previous results into the next agent's prompt.

### Conditions

Steps can include conditions that determine whether they run based on previous outputs.

## Example: Code Review Pipeline

This pipeline runs four agents in a structured review workflow:

```yaml
# pipeline.yaml
name: code-review-pipeline
description: Automated code review with security, style, tests, and summary

steps:
  - name: security-scan
    prompt: |
      Scan all files in ./src/ for security vulnerabilities.
      Check for: SQL injection, XSS, hardcoded secrets, insecure dependencies.
      Output a list of findings with file paths and line numbers.
    model: claude-opus-4-20250514
    max_turns: 15
    tools:
      - read_file
      - bash
      - grep

  - name: style-check
    prompt: |
      Check all files in ./src/ for code style issues.
      Verify consistent naming, proper error handling, and documentation.
      Output a list of style violations.
    model: claude-sonnet-4-20250514
    max_turns: 10
    parallel_with: security-scan  # runs at the same time as security-scan
    tools:
      - read_file
      - bash

  - name: test-coverage
    prompt: |
      Run the test suite and analyze coverage.
      Identify files with less than 80% coverage.
      List untested functions and edge cases.
    model: claude-sonnet-4-20250514
    max_turns: 12
    parallel_with: security-scan  # also runs in parallel
    tools:
      - bash
      - read_file

  - name: summarize
    prompt: |
      Combine the findings from the security scan, style check, and test coverage analysis.
      Write a single review-report.md with:
      - Critical issues (security findings)
      - Style improvements
      - Coverage gaps
      - Overall assessment and priority ranking
    model: claude-sonnet-4-20250514
    max_turns: 8
    depends_on:
      - security-scan
      - style-check
      - test-coverage
    tools:
      - write_file
```

Run it:

```bash
claude-flow run pipeline.yaml
```

This launches three agents in parallel (security, style, tests), waits for all three to finish, then launches the summary agent with their combined outputs.

## Key Features

### Sequential Chains

Steps run one after another by default:

```yaml
steps:
  - name: analyze
    prompt: "Analyze the codebase architecture"
  - name: plan
    prompt: "Based on the analysis, create a refactoring plan"
  - name: implement
    prompt: "Implement the refactoring plan"
```

Each step receives the output of all previous steps.

### Parallel Execution

Independent steps can run simultaneously:

```yaml
steps:
  - name: frontend-review
    prompt: "Review ./frontend/ for issues"
  - name: backend-review
    prompt: "Review ./backend/ for issues"
    parallel_with: frontend-review
  - name: merge-results
    prompt: "Combine frontend and backend review findings"
    depends_on:
      - frontend-review
      - backend-review
```

Parallel execution cuts wall-clock time significantly. Two 5-minute agents running in parallel take 5 minutes total instead of 10.

### Conditional Branching

Steps can run conditionally based on previous outputs:

```yaml
steps:
  - name: check-tests
    prompt: "Run the test suite and report pass/fail status"
  - name: fix-tests
    prompt: "Fix the failing tests"
    condition: "check-tests.output contains 'FAIL'"
  - name: deploy
    prompt: "Deploy to staging"
    condition: "check-tests.output contains 'ALL PASSED'"
```

### Shared Context

All steps share a working directory. Files created by one agent are available to subsequent agents:

```yaml
steps:
  - name: generate
    prompt: "Generate a REST API in ./api.py"
  - name: test
    prompt: "Write tests for ./api.py and run them"
  - name: document
    prompt: "Write API documentation based on ./api.py"
```

### Output Routing

Direct specific outputs to files or other destinations:

```yaml
steps:
  - name: review
    prompt: "Review the codebase"
    output:
      file: review-results.md
      format: markdown
```

## Configuration Reference

### Pipeline-Level Options

```yaml
name: pipeline-name          # required
description: "What this pipeline does"
working_directory: ./src     # default: current directory
fail_fast: true              # stop on first failure (default: true)
timeout: 3600                # pipeline timeout in seconds
```

### Step-Level Options

```yaml
- name: step-name            # required, unique identifier
  prompt: "What to do"       # required
  model: claude-sonnet-4-20250514  # default: account default
  max_turns: 15              # default: 25
  tools:                     # default: all available
    - bash
    - read_file
    - write_file
  parallel_with: other-step  # run in parallel with named step
  depends_on:                # wait for these steps first
    - step-a
    - step-b
  condition: "expression"    # conditional execution
  timeout: 600               # step timeout in seconds
  retry: 2                   # retry count on failure
```

---

*Need the complete toolkit? [The Claude Code Playbook](https://zovo.one/pricing) includes 200 production-ready templates, decision frameworks, and team setup guides for every Claude Code workflow.*

## Comparison with Alternatives

| Feature | Claude Flow | Manual Scripts | Claude Task Master | SuperClaude |
|---------|------------|---------------|-------------------|-------------|
| Pipeline definition | YAML | Bash/Python | JSON tasks | CLAUDE.md rules |
| Parallel execution | Built-in | Manual (tmux) | Sequential | Manual |
| Conditional logic | YAML conditions | Script logic | Limited | None |
| Setup complexity | Low | High | Medium | Low |
| Customization | Medium | Full | Medium | Low |
| Best for | Repeatable pipelines | One-off workflows | Task decomposition | Daily dev work |

**Use Claude Flow** when you have repeatable multi-agent workflows that benefit from structured orchestration.

**Use manual scripts** when your workflow is unique or requires custom logic that YAML cannot express. See our [multi-agent architecture guide](/claude-code-multi-agent-architecture-guide-2026/) for scripting patterns.

**Use Claude Task Master** when your focus is task decomposition rather than agent orchestration.

**Use simpler approaches** for single-agent tasks or when the overhead of pipeline definition is not justified.

## Limitations

- **YAML expressiveness**: complex branching logic is awkward in YAML. For intricate control flow, consider Python scripts instead.
- **Error context**: when a step fails, the error message may not fully explain why. Check individual agent logs.
- **Token cost**: each step is a separate Claude Code session, so shared context is re-processed. Long pipelines can be expensive.
- **Community tool**: Claude Flow is not maintained by Anthropic. Updates depend on community contributors.
- **Version compatibility**: major Claude Code updates may temporarily break Claude Flow until it is updated.

## When to Use Simpler Approaches

Claude Flow adds value for repeatable, multi-step workflows. It adds overhead for simple tasks. Consider alternatives when:

- Your workflow has fewer than 3 steps (just run agents manually)
- Steps do not depend on each other (launch parallel agents yourself)
- You need real-time interaction during the workflow (use Claude Code directly)
- Your workflow changes every time (scripts are more flexible)

For cost implications of multi-agent workflows, see our [multi-agent cost architecture guide](/multi-agent-claude-fleet-cost-architecture/).

## Frequently Asked Questions

**Is Claude Flow an Anthropic product?**
No. Claude Flow is a community-built open-source tool. It uses the Claude Code CLI under the hood but is not officially maintained by Anthropic.

**Does it work with Claude Max?**
Yes. Claude Flow launches Claude Code sessions, which work with both Claude Max subscriptions and API-based billing.

**Can I mix models in a pipeline?**
Yes. Each step can specify a different model. Use Opus for critical reasoning steps and Haiku for simple checks.

**How does it handle failures?**
By default, `fail_fast: true` stops the pipeline on the first failure. Set it to `false` to continue running remaining steps.

**What is the maximum number of parallel agents?**
There is no hard limit in Claude Flow itself, but Anthropic API rate limits apply. Most accounts can run 3-5 parallel agents without hitting rate limits.

**Can I use custom tools?**
Claude Flow passes the tools configuration to Claude Code. Any tool available in Claude Code is available in Claude Flow steps.

### Can I use Claude Flow with the Claude Agent SDK?

Claude Flow orchestrates Claude Code CLI sessions. The Agent SDK is a separate programmatic interface. They solve similar problems differently. Use Claude Flow for YAML-defined pipelines and the Agent SDK for code-defined agent workflows.

### Does Claude Flow support environment variables in YAML?

Yes. You can reference environment variables in your pipeline YAML using standard shell variable syntax. They are expanded at runtime when Claude Flow launches each step.

### Can I run Claude Flow on a CI/CD server?

Yes. Install Claude Flow and Claude Code on the CI server, set the ANTHROPIC_API_KEY environment variable, and run claude-flow run pipeline.yaml as a CI step. Add appropriate timeouts.

### How do I debug a failing pipeline step?

Check the individual agent log output for the failing step. Run the step's prompt manually with Claude Code to reproduce the issue. Set fail_fast to false to see if subsequent steps succeed independently.

## Related Guides

- [Multi-agent architecture patterns](/claude-code-multi-agent-architecture-guide-2026/) — design patterns for agent coordination
- [Subagent communication](/claude-code-multi-agent-subagent-communication-guide/) — how agents share context
- [Parallel subagents best practices](/parallel-subagents-claude-code-best-practices-2026/) — optimization techniques
- [Multi-agent error recovery](/claude-code-multi-agent-error-recovery-strategies/) — handling failures gracefully
- [Token budgeting for multi-agent](/multi-agent-token-budgeting-allocate-subagents/) — cost control strategies
- [Cost-efficient multi-agent workflows](/cost-efficient-multi-agent-coding-workflows/) — minimize spend
- [How to build a Claude Code agent](/how-to-build-claude-code-agent-2026/) — foundational agent-building guide
- [The Claude Code Playbook](/playbook/) — comprehensive Claude Code reference
- [Claude Agent SDK guide](/claude-agent-sdk-complete-guide/) — Build custom agents with the Agent SDK
- [sequential thinking in Claude Code](/sequential-thinking-claude-code-guide/) — Use thinking for complex orchestration steps
- [Claude Code hooks](/claude-code-hooks-complete-guide/) — hook into agent tool execution
- [Super Claude Code framework](/super-claude-code-framework-guide/) — structured prompting for agents

{% raw %}
<script type="application/ld+json">
{
  "@context": "https://schema.org",
  "@type": "FAQPage",
  "mainEntity": [
    {"@type": "Question", "name": "Is Claude Flow an Anthropic product?", "acceptedAnswer": {"@type": "Answer", "text": "No. Claude Flow is a community-built open-source tool. It uses the Claude Code CLI under the hood but is not officially maintained by Anthropic."}},
    {"@type": "Question", "name": "Does it work with Claude Max?", "acceptedAnswer": {"@type": "Answer", "text": "Yes. Claude Flow launches Claude Code sessions, which work with both Claude Max subscriptions and API-based billing."}},
    {"@type": "Question", "name": "Can I mix models in a pipeline?", "acceptedAnswer": {"@type": "Answer", "text": "Yes. Each step can specify a different model. Use Opus for critical reasoning steps and Haiku for simple checks."}},
    {"@type": "Question", "name": "How does it handle failures?", "acceptedAnswer": {"@type": "Answer", "text": "By default, fail_fast: true stops the pipeline on the first failure. Set it to false to continue running remaining steps."}},
    {"@type": "Question", "name": "What is the maximum number of parallel agents?", "acceptedAnswer": {"@type": "Answer", "text": "There is no hard limit in Claude Flow itself, but Anthropic API rate limits apply. Most accounts can run 3-5 parallel agents without hitting rate limits."}},
    {"@type": "Question", "name": "Can I use custom tools?", "acceptedAnswer": {"@type": "Answer", "text": "Claude Flow passes the tools configuration to Claude Code. Any tool available in Claude Code is available in Claude Flow steps."}},
    {"@type": "Question", "name": "Can I use Claude Flow with the Claude Agent SDK?", "acceptedAnswer": {"@type": "Answer", "text": "Claude Flow orchestrates Claude Code CLI sessions. The Agent SDK is a separate programmatic interface. They solve similar problems differently."}},
    {"@type": "Question", "name": "Does Claude Flow support environment variables in YAML?", "acceptedAnswer": {"@type": "Answer", "text": "Yes. You can reference environment variables in your pipeline YAML using standard shell variable syntax. They are expanded at runtime."}},
    {"@type": "Question", "name": "Can I run Claude Flow on a CI/CD server?", "acceptedAnswer": {"@type": "Answer", "text": "Yes. Install Claude Flow and Claude Code on the CI server, set the ANTHROPIC_API_KEY environment variable, and run claude-flow run pipeline.yaml as a CI step."}},
    {"@type": "Question", "name": "How do I debug a failing pipeline step?", "acceptedAnswer": {"@type": "Answer", "text": "Check the individual agent log output for the failing step. Run the step's prompt manually with Claude Code to reproduce the issue."}}
  ]
}
</script>

{% endraw %}