---
layout: default
title: "Claude Code for Promptfoo"
description: "Evaluate LLM prompts systematically with Promptfoo and Claude Code. Tested setup with copy-paste CLAUDE.md config."
date: 2026-04-18
permalink: /claude-code-for-promptfoo-llm-eval-workflow-guide/
render_with_liquid: false
categories: [workflow, niche-tools]
tags: [claude-code, promptfoo, workflow]
---

## The Setup

You are using Promptfoo for systematic LLM prompt evaluation — testing prompts against multiple models with assertion-based grading. Promptfoo helps you catch prompt regressions, compare model performance, and document prompt quality. Claude Code can write Promptfoo configurations, but it creates one-off scripts instead of structured evaluation configs.

## What Claude Code Gets Wrong By Default

1. **Tests prompts manually with one-off scripts.** Claude writes Node.js scripts that call the API and print results. Promptfoo provides a structured YAML config with test cases, assertions, and comparison views.

2. **Evaluates against a single model.** Claude tests with one provider. Promptfoo runs the same prompts against multiple models simultaneously for side-by-side comparison.

3. **Skips assertion-based grading.** Claude visually inspects output. Promptfoo supports assertions: `contains`, `icontains`, `javascript`, `llm-rubric`, `similar` for automated quality checks.

4. **Does not track prompt versions.** Claude overwrites prompts without versioning. Promptfoo evaluations are reproducible — the YAML config serves as version-controlled prompt documentation.

## The CLAUDE.md Configuration

```
{% raw %}
# Promptfoo LLM Evaluation

## Eval Framework
- Tool: Promptfoo (prompt testing and evaluation)
- Config: promptfooconfig.yaml at project root
- CLI: npx promptfoo eval, npx promptfoo view

## Promptfoo Rules
- Config in promptfooconfig.yaml (YAML format)
- Providers: list of models to test against
- Prompts: template strings with {{variable}} placeholders
- Tests: array of test cases with vars and assertions
- Assertions: contains, icontains, javascript, llm-rubric, similar
- Run: npx promptfoo eval (executes all tests)
- View: npx promptfoo view (opens comparison UI)
- Cache: results cached by default for reproducibility

## Conventions
- promptfooconfig.yaml committed to version control
- Test cases cover edge cases and expected behaviors
- Use llm-rubric for subjective quality evaluation
- Compare models: claude, gpt-4, llama in providers list
- Variable datasets for comprehensive testing
- Share results with npx promptfoo share
- CI integration: npx promptfoo eval --no-cache in pipeline
{% endraw %}
```

## Workflow Example

You want to evaluate a customer support prompt across models. Prompt Claude Code:

"Create a Promptfoo config that tests a customer support agent prompt across Claude, GPT-4, and Llama. Include 5 test cases covering complaint handling, refund requests, and technical support. Add assertions for tone (polite), accuracy (mentions policy), and response length."

Claude Code should create `promptfooconfig.yaml` with three providers, the system prompt as a template, five test cases with `vars` for different customer messages, and assertions using `contains` for policy references, `javascript` for length checks, and `llm-rubric` for tone evaluation.

## Common Pitfalls

{% raw %}1. **Missing variable syntax in prompts.** Claude uses `${variable}` JavaScript template literals. Promptfoo uses `{{variable}}` Mustache-style syntax in prompt templates. Wrong syntax means variables are not substituted and tests pass with empty values.{% endraw %}

2. **Over-relying on exact match assertions.** Claude uses `equals` assertions for LLM output. LLM responses vary between runs. Use `contains`, `icontains`, or `similar` for fuzzy matching, and `llm-rubric` for semantic evaluation.

3. **Cache confusion during development.** Claude modifies prompts but gets old results. Promptfoo caches by default. Use `npx promptfoo eval --no-cache` when iterating on prompts, or clear cache with `npx promptfoo cache clear`.

## Related Guides

- [Claude Code for AI Agent Tool Calling](/claude-code-for-ai-agent-tool-calling-implementation/)
- [Building Production AI Agents with Claude Skills 2026](/building-production-ai-agents-with-claude-skills-2026/)
- [Claude Code for Embedding Pipeline Workflow](/claude-code-for-embedding-pipeline-workflow/)

## Related Articles

- [Claude Code for Hygen Code Generation Workflow](/claude-code-for-hygen-code-generation-workflow/)
- [Claude Code for Translation Key Extraction Workflow](/claude-code-for-translation-key-extraction-workflow/)
- [Claude Code Portuguese Developer Coding Workflow Setup](/claude-code-portuguese-developer-coding-workflow-setup/)
- [Claude Code for Production Profiling Workflow Guide](/claude-code-for-production-profiling-workflow-guide/)
- [Claude Code for Configure8 Portal Workflow Guide](/claude-code-for-configure8-portal-workflow-guide/)
- [Claude Code for Gymnasium Workflow Tutorial](/claude-code-for-gymnasium-workflow-tutorial/)
- [Claude Code Solo SaaS Builder Launch Checklist Workflow](/claude-code-solo-saas-builder-launch-checklist-workflow/)
- [How to Use Anvil Local Fork (2026)](/claude-code-for-anvil-local-fork-workflow/)
