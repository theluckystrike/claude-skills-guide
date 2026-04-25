---
title: "Claude Code Router: Model Routing Guide"
description: "Route tasks to the optimal Claude model automatically. Configure cost-aware model routing in Claude Code with Opus, Sonnet, and Haiku strategies."
permalink: /claude-code-router-guide/
last_tested: "2026-04-24"
---

# Claude Code Router: Model Routing Guide (2026)

Model routing is the practice of selecting the optimal Claude model for each task based on complexity, cost, and quality requirements. Claude Code supports both automatic and manual routing strategies. This guide covers every approach.

## What Is Model Routing?

Not every task needs the most powerful model. A simple file rename does not need Opus. A complex architecture decision should not be handled by Haiku. Model routing matches tasks to the right model, saving money without sacrificing quality.

Claude Code's model routing works at three levels:

1. **Built-in automatic routing** — Claude Code selects models internally for different operations
2. **Manual model selection** — you specify which model to use via CLI flags
3. **CLAUDE.md routing rules** — you define routing logic in your project configuration

## Built-In Routing: How Claude Code Selects Models

Claude Code uses different models for different internal operations:

| Operation | Model Used | Why |
|-----------|-----------|-----|
| Primary reasoning | Opus or Sonnet (user-selected) | Main task processing |
| Subagent tasks | Same as parent or configurable | Delegated work |
| Quick completions | Haiku | Tab completion, simple suggestions |
| File summarization | Haiku or Sonnet | Context compression |

The primary model — the one doing the heavy reasoning — is what you control directly. Claude Code handles the rest.

## Manual Model Selection

### CLI Flag

Specify the model when launching Claude Code:

```bash
# Use Opus for complex work
claude --model claude-opus-4-20250514

# Use Sonnet for general development
claude --model claude-sonnet-4-20250514

# Use Haiku for simple edits
claude --model claude-haiku-4-5-20251001
```

### In API Mode

When using Claude Code programmatically:

```bash
# Pipe a task to a specific model
echo "Fix the typo in README.md" | claude --model claude-haiku-4-5-20251001 -p

# Complex task with Opus
echo "Refactor the auth module to use JWT" | claude --model claude-opus-4-20250514 -p
```

### Model Aliases

Claude Code supports shorthand aliases:

```bash
claude --model opus     # resolves to claude-opus-4-20250514
claude --model sonnet   # resolves to claude-sonnet-4-20250514
claude --model haiku    # resolves to claude-haiku-4-5-20251001
```

## CLAUDE.md Routing Rules

You can embed routing guidance in your CLAUDE.md file so every team member uses the same strategy:

```markdown
## Model Routing

- Use Opus for: architecture decisions, security reviews, complex refactors
- Use Sonnet for: feature implementation, bug fixes, code generation
- Use Haiku for: formatting fixes, typo corrections, simple renames

When the user doesn't specify a model, default to Sonnet.
```

These rules are advisory — Claude Code reads them as part of its context, but the actual model used depends on the `--model` flag or account default.

For CLAUDE.md configuration patterns in detail, see our [CLAUDE.md best practices guide](/claude-code-claude-md-best-practices/).

## Smart Routing Strategies

### Strategy 1: Cost Optimization

Start with the cheapest model. Escalate only when the task fails or produces poor results.

```bash
# First attempt with Haiku
echo "Add input validation to the signup form" | claude --model haiku -p

# If output quality is insufficient, escalate
echo "Add input validation to the signup form" | claude --model sonnet -p
```

This works well for tasks with clear success criteria. If the Haiku output compiles and passes tests, you saved 80% versus Sonnet.

**Cost savings**: 60-80% compared to always using Sonnet.

### Strategy 2: Quality Optimization

Always use Opus. Ignore cost, maximize output quality.

```bash
claude --model opus
```

Best for: security audits, architecture reviews, production-critical code. When a mistake costs more than the API bill, use the best model.

**Tradeoff**: 5x the cost of Sonnet, but measurably better at complex reasoning and edge-case handling.

### Strategy 3: Balanced (Recommended for Most Teams)

Use Sonnet as default. Escalate to Opus for defined categories.

```markdown
## CLAUDE.md Routing (Balanced)

Default model: Sonnet

Escalate to Opus when:
- Designing new system architecture
- Reviewing security-sensitive code
- Debugging issues that have resisted multiple fix attempts
- Writing complex algorithms

Use Haiku when:
- Fixing typos or formatting
- Generating boilerplate
- Running simple grep-and-replace operations
```

This is the strategy most teams should start with. It provides good quality at reasonable cost.

## Multi-Model Workflows

The most powerful routing pattern uses different models for different stages of the same task.

### Opus Plans, Sonnet Implements, Haiku Reviews

```bash
# Step 1: Opus creates the plan
echo "Plan a refactor of the payment module to support multiple providers" \
  | claude --model opus -p > plan.md

# Step 2: Sonnet implements the plan
echo "Implement the plan in plan.md" \
  | claude --model sonnet -p

# Step 3: Haiku does a quick lint check
echo "Check all modified files for obvious issues" \
  | claude --model haiku -p
```

This mirrors how human teams work: senior architects plan, mid-level engineers implement, junior engineers handle review checklists.

For more on multi-agent workflows, see our [multi-agent architecture guide](/claude-code-multi-agent-architecture-guide-2026/).

### Parallel Multi-Model with Subagents

When using Claude Code's [subagent system](/claude-code-multi-agent-subagent-communication-guide/), each subagent can use a different model:

```markdown
## CLAUDE.md

When spawning subagents:
- Security scan subagent: use Opus
- Test generation subagent: use Sonnet
- Documentation update subagent: use Haiku
```

This lets you parallelize work across models, optimizing cost and quality simultaneously.

## Cost Comparison by Model

Current per-token pricing (as of April 2026):

| Model | Input (per 1M tokens) | Output (per 1M tokens) | Relative Cost |
|-------|----------------------|------------------------|---------------|
| Claude Opus 4 | $15.00 | $75.00 | 5x |
| Claude Sonnet 4 | $3.00 | $15.00 | 1x (baseline) |
| Claude Haiku 4.5 | $0.80 | $4.00 | 0.27x |

**Prompt caching** reduces input costs by 90% for cached content. This applies to all models and is particularly valuable for routing scenarios where the same system prompt is sent repeatedly.

### Real Cost Examples

| Task | Haiku Cost | Sonnet Cost | Opus Cost |
|------|-----------|-------------|-----------|
| Fix a typo | $0.005 | $0.02 | $0.10 |
| Implement a feature | $0.08 | $0.30 | $1.50 |
| Full codebase refactor | $0.50 | $2.00 | $10.00 |
| Architecture review | $0.15 | $0.60 | $3.00 |

Routing Haiku for simple tasks and Sonnet for the rest can cut your bill by 30-50% with no quality loss. See our [cost optimization guide](/claude-code-costs-too-much-reduce-spend-2026/) for additional strategies.

---

*Need the complete toolkit? [The Claude Code Playbook](https://zovo.one/pricing) includes 200 production-ready templates, decision frameworks, and team setup guides for every Claude Code workflow.*

## Router Configuration in Settings

Claude Code's settings file (`.claude/settings.json`) supports model preferences:

```json
{
  "model": "claude-sonnet-4-20250514",
  "preferences": {
    "defaultModel": "claude-sonnet-4-20250514"
  }
}
```

Organization-level settings can enforce model policies:

```json
{
  "permissions": {
    "allowedModels": [
      "claude-sonnet-4-20250514",
      "claude-haiku-4-5-20251001"
    ]
  }
}
```

This prevents developers from accidentally using Opus for routine tasks, enforcing cost controls at the org level.

## Routing Decision Flowchart

Use this quick reference to choose the right model for any task:

1. **Is the task trivial?** (typo fix, rename, formatting) -- Use Haiku
2. **Is the task standard development?** (feature implementation, bug fix, test writing) -- Use Sonnet
3. **Has Sonnet already failed on this task?** -- Escalate to Opus
4. **Does the task involve security, architecture, or complex multi-system reasoning?** -- Use Opus
5. **Are you unsure?** -- Start with Sonnet. Escalate if the output is insufficient.

This flowchart covers 95% of routing decisions. The remaining 5% are edge cases where testing both models on your specific workload is the best approach.

## Common Routing Mistakes

**Mistake: Using Opus for everything.**
Result: 5x higher costs with minimal quality improvement for routine tasks. Opus shines on hard problems — it does not meaningfully outperform Sonnet on straightforward implementations.

**Mistake: Using Haiku for complex tasks to save money.**
Result: lower-quality output that requires rework, often costing more total tokens than using Sonnet once. Haiku is for tasks with clear, simple requirements.

**Mistake: Never changing the default model.**
Result: paying Sonnet prices for tasks Haiku handles perfectly, or getting subpar results on tasks that warrant Opus. Spend 5 seconds choosing the model before each session.

**Mistake: Switching models mid-task by starting a new session.**
Result: loss of conversation context, duplicate file reads, and wasted tokens rebuilding state. If you realize mid-task that you need a different model, finish the current step first, then switch for the next phase.

## Frequently Asked Questions

**Does Claude Code automatically route to cheaper models?**
Not by default. Claude Code uses the model you specify (or your account default). You must configure routing manually via CLI flags, CLAUDE.md rules, or scripts.

**Can I switch models mid-session?**
Not within a single session. Each Claude Code session uses one primary model. To use a different model, start a new session with the `--model` flag.

**What happens if I use Haiku for a task that needs Opus?**
The task will still run, but the output may be lower quality — missed edge cases, simpler solutions, less thorough analysis. There is no automatic escalation.

**Is routing worth the complexity?**
For individual developers, simple manual selection is fine. For teams spending more than $500/month on Claude Code, routing strategies can cut costs by 30-50%.

**Can I route based on file type?**
Not natively. You can build this into scripts: use Opus for security-sensitive files, Sonnet for everything else.

**How does prompt caching interact with routing?**
Prompt caching works across all models. Cached inputs cost 90% less. This means the cost gap between models narrows for repeated operations on the same files.

### Does model routing affect prompt caching?

Prompt caching works within the same model. Switching models between requests means the cache from the previous model is not reused. For maximum cache benefit, batch requests by model.

### Can I set up automatic routing based on task complexity?

Not natively in Claude Code. You can build this into scripts that analyze the task description and select the model accordingly before passing it to Claude Code.

### Is there a cost difference between using the model alias and the full model ID?

No. The alias (like sonnet) resolves to the same model as the full ID (claude-sonnet-4-20250514) and is billed identically.

### How do I know if Sonnet is good enough or if I need Opus?

Start with Sonnet. If the output quality is insufficient — missed edge cases, incorrect logic, or shallow analysis — escalate to Opus for that specific task. Most daily development tasks do not need Opus.

## Claude Code Router: Configuration Summary

The Claude Code router is the system that determines which Claude model handles each request. Whether you use the built-in defaults, manual CLI flags, or CLAUDE.md routing rules, the router sits between your prompt and the model. Understanding how the Claude Code router works lets you optimize for cost, speed, and quality simultaneously.

Key configuration points for the Claude Code router:

1. **Default model** — set in `~/.claude/settings.json` under `"model"`, or pass `--model` at launch
2. **Subagent model** — configure which model subagents use (can differ from the primary model)
3. **Routing rules** — define in CLAUDE.md to route based on task type, file pattern, or complexity
4. **Cost guardrails** — combine routing with spending alerts to prevent budget overruns

The Claude Code router does not require any external dependencies or plugins. It is built into Claude Code and configurable through the standard settings and CLAUDE.md files. For OpenRouter-based model routing (accessing non-Anthropic models), see our [OpenRouter setup guide](/claude-code-openrouter-setup-guide/).

## Related Guides

- [Claude Code cost breakdown](/claude-code-cost-complete-guide/) — full pricing reference
- [Reduce Claude Code spend](/claude-code-costs-too-much-reduce-spend-2026/) — cost optimization tactics
- [Best cost-saving tools](/best-claude-code-cost-saving-tools-2026/) — third-party cost tools
- [Multi-agent architecture](/claude-code-multi-agent-architecture-guide-2026/) — multi-model agent patterns
- [API mode vs interactive](/claude-code-api-mode-vs-interactive-2026/) — programmatic model selection
- [Claude Code prompt engineering](/claude-code-prompt-engineering-tips-2026/) — get better results from any model
- [The Claude Code Playbook](/playbook/) — comprehensive configuration reference
- [Parallel subagents best practices](/parallel-subagents-claude-code-best-practices-2026/) — multi-model parallelism
- [Claude Sonnet 4.5 model guide](/claude-sonnet-4-5-20250929-model-guide/) — Sonnet 4.5 capabilities and features
- [Claude Sonnet 4 model guide](/claude-sonnet-4-20250514-model-guide/) — Sonnet 4 capabilities and features

{% raw %}
<script type="application/ld+json">
{
  "@context": "https://schema.org",
  "@type": "FAQPage",
  "mainEntity": [
    {"@type": "Question", "name": "Does Claude Code automatically route to cheaper models?", "acceptedAnswer": {"@type": "Answer", "text": "Not by default. Claude Code uses the model you specify or your account default. You must configure routing manually via CLI flags, CLAUDE.md rules, or scripts."}},
    {"@type": "Question", "name": "Can I switch models mid-session?", "acceptedAnswer": {"@type": "Answer", "text": "Not within a single session. Each Claude Code session uses one primary model. To use a different model, start a new session with the --model flag."}},
    {"@type": "Question", "name": "What happens if I use Haiku for a task that needs Opus?", "acceptedAnswer": {"@type": "Answer", "text": "The task will still run, but the output may be lower quality. There is no automatic escalation."}},
    {"@type": "Question", "name": "Is routing worth the complexity?", "acceptedAnswer": {"@type": "Answer", "text": "For individual developers, simple manual selection is fine. For teams spending more than $500/month, routing strategies can cut costs by 30-50%."}},
    {"@type": "Question", "name": "Can I route based on file type?", "acceptedAnswer": {"@type": "Answer", "text": "Not natively. You can build this into scripts: use Opus for security-sensitive files, Sonnet for everything else."}},
    {"@type": "Question", "name": "How does prompt caching interact with routing?", "acceptedAnswer": {"@type": "Answer", "text": "Prompt caching works across all models. Cached inputs cost 90% less. The cost gap between models narrows for repeated operations on the same files."}},
    {"@type": "Question", "name": "Does model routing affect prompt caching?", "acceptedAnswer": {"@type": "Answer", "text": "Prompt caching works within the same model. Switching models between requests means the cache from the previous model is not reused. Batch requests by model for maximum cache benefit."}},
    {"@type": "Question", "name": "Can I set up automatic routing based on task complexity?", "acceptedAnswer": {"@type": "Answer", "text": "Not natively in Claude Code. You can build this into scripts that analyze the task description and select the model accordingly."}},
    {"@type": "Question", "name": "Is there a cost difference between using the model alias and the full model ID?", "acceptedAnswer": {"@type": "Answer", "text": "No. The alias resolves to the same model as the full ID and is billed identically."}},
    {"@type": "Question", "name": "How do I know if Sonnet is good enough or if I need Opus?", "acceptedAnswer": {"@type": "Answer", "text": "Start with Sonnet. If the output quality is insufficient — missed edge cases, incorrect logic, or shallow analysis — escalate to Opus for that specific task."}}
  ]
}
</script>

{% endraw %}