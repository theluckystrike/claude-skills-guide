---
title: "Environment Variables for Claude Code Cost Control"
description: "Control Claude Code costs with environment variables including model selection, turn limits, and token budgets that prevent runaway spending."
permalink: /environment-variables-claude-code-cost-control/
date: 2026-04-22
last_tested: "2026-04-22"
render_with_liquid: false
---

# Environment Variables for Claude Code Cost Control

## What It Does

Environment variables provide session-level cost controls for Claude Code that take effect before the first token is spent. Unlike CLAUDE.md rules (which Claude interprets) or settings.json (which controls permissions), environment variables are enforced by the Claude Code runtime itself. Setting `CLAUDE_MODEL` to Sonnet 4.6 instead of Opus 4.6 immediately cuts per-token costs by 80%. Setting `CLAUDE_CODE_MAX_TURNS` prevents runaway sessions that can burn $10-30 in a single incident.

## Installation / Setup

Add cost control variables to the shell profile:

```bash
# Add to ~/.zshrc or ~/.bashrc

# Model selection: default to cheaper model
export CLAUDE_MODEL="claude-sonnet-4-6"

# Turn limit: prevent runaway sessions
export CLAUDE_CODE_MAX_TURNS=25

# Budget cap: hard token limit per session
export CLAUDE_CODE_BUDGET_TOKENS=500000
```

```bash
# Apply changes
source ~/.zshrc
```

## Configuration for Cost Optimization

### Model Selection Variables

```bash
# Sonnet 4.6: $3/$15 per MTok (input/output) -- best for routine work
export CLAUDE_MODEL="claude-sonnet-4-6"

# Opus 4.6: $15/$75 per MTok -- use only for complex architecture tasks
# export CLAUDE_MODEL="claude-opus-4-6"

# Haiku 4.5: $0.80/$4 per MTok -- use for simple tasks, rapid iteration
# export CLAUDE_MODEL="claude-haiku-4-5"

# Per-session override (does not change default)
claude --model claude-opus-4-6 "Design the authentication architecture"
```

**Cost impact of model selection:**

| Model | 100K Input + 30K Output Session | 500K Input + 150K Output Session |
|-------|-------------------------------|----------------------------------|
| Haiku 4.5 | $0.20 | $0.98 |
| Sonnet 4.6 | $0.75 | $3.75 |
| Opus 4.6 | $3.75 | $18.75 |

Defaulting to Sonnet and selectively using Opus saves 80% on the 70-80% of tasks that do not require Opus-level reasoning.

### Session Limit Variables

```bash
# Maximum turns per session (1 turn = 1 user message + 1 assistant response cycle)
export CLAUDE_CODE_MAX_TURNS=25

# Without this limit, a retry loop can run 50+ turns
# At 15K tokens per turn, that is 750K+ tokens ($2.25 Sonnet, $11.25 Opus)
# With the limit: max 25 turns x 15K = 375K tokens ($1.13 Sonnet, $5.63 Opus)
# Savings per incident: $1.12 Sonnet, $5.62 Opus
```

### API Key Management

```bash
# Use separate API keys for different cost centers
export ANTHROPIC_API_KEY="sk-ant-team-key"  # team budget
# Override per session for personal exploration:
ANTHROPIC_API_KEY="sk-ant-personal-key" claude "explore this codebase"
```

Separate API keys enable per-team or per-project cost tracking on the Anthropic dashboard.

## Usage Examples

### Basic Usage

```bash
# Daily development: Sonnet with turn limit
export CLAUDE_MODEL="claude-sonnet-4-6"
export CLAUDE_CODE_MAX_TURNS=25
claude "Fix the failing test in auth.test.ts"
```

### Advanced: Context-Specific Variable Profiles

```bash
# Create aliases for different cost profiles
# ~/.zshrc

# Routine development (cheapest)
alias claude-dev='CLAUDE_MODEL="claude-sonnet-4-6" CLAUDE_CODE_MAX_TURNS=20 claude'

# Architecture work (premium)
alias claude-arch='CLAUDE_MODEL="claude-opus-4-6" CLAUDE_CODE_MAX_TURNS=30 claude'

# Quick fix (fastest, cheapest)
alias claude-quick='CLAUDE_MODEL="claude-haiku-4-5" CLAUDE_CODE_MAX_TURNS=10 claude'

# Usage:
claude-dev "Add input validation to the user endpoint"
claude-arch "Design the event sourcing module"
claude-quick "Rename the variable on line 42"
```

**Monthly impact with profile-based routing:**
- 60% of tasks use claude-dev (Sonnet): 60 x $0.75 = $45
- 10% use claude-arch (Opus): 10 x $3.75 = $37.50
- 30% use claude-quick (Haiku): 30 x $0.20 = $6
- **Total: $88.50/month vs all-Opus $375/month = 76% savings**

## Token Usage Measurements

| Variable | Token Impact | Monthly Savings (Sonnet, solo) |
|----------|-------------|-------------------------------|
| CLAUDE_MODEL=sonnet (vs opus) | 80% cost reduction | $150-300 |
| MAX_TURNS=25 | Caps worst-case sessions | $10-50 (incident prevention) |
| BUDGET_TOKENS=500K | Hard ceiling per session | $5-25 (incident prevention) |
| Profile routing (dev/arch/quick) | 40-60% average reduction | $50-100 |

## Comparison with Alternatives

| Control Method | Enforcement | Scope | Token Cost |
|---------------|-------------|-------|------------|
| Environment variables | Hard (runtime) | Session-wide | 0 |
| CLAUDE.md rules | Soft (agent) | Project-wide | 200-500/session |
| settings.json | Hard (tool-level) | Project-wide | 0 |
| /compact manual | Manual (user) | Per action | 0 |

Environment variables are the only zero-cost, runtime-enforced, session-wide control mechanism. They complement but do not replace CLAUDE.md rules and settings.json.

## Troubleshooting

**Model override not taking effect:** Check for conflicting environment variables. Run `echo $CLAUDE_MODEL` to verify. Ensure the shell profile was sourced after adding the variable.

**MAX_TURNS too low for complex tasks:** Increase to 30-40 for known complex tasks using the per-session override: `CLAUDE_CODE_MAX_TURNS=40 claude "complex task"`. Avoid setting the global default above 30.

**BUDGET_TOKENS cutting off mid-task:** The budget cap is a hard stop. Set it above the expected maximum (500K covers 95% of tasks) and use MAX_TURNS as the softer limit. If a task consistently hits the budget, the task itself needs decomposition.

## Environment Variable Quick Reference

| Variable | Purpose | Recommended Value | Savings Impact |
|----------|---------|-------------------|----------------|
| CLAUDE_MODEL | Default model | claude-sonnet-4-6 | 80% vs Opus |
| CLAUDE_CODE_MAX_TURNS | Session turn limit | 25 | Prevents $10-50 incidents |
| CLAUDE_CODE_BUDGET_TOKENS | Session token cap | 500000 | Hard ceiling |
| ANTHROPIC_API_KEY | API authentication | Per-team keys | Enables cost attribution |

## Project-Specific Environment Variables

Use `.envrc` (with direnv) or `.env` files to set project-specific Claude Code configuration:

```bash
# .envrc (loaded automatically by direnv when entering directory)
export CLAUDE_MODEL="claude-sonnet-4-6"
export CLAUDE_CODE_MAX_TURNS=25
export CLAUDE_CODE_BUDGET_TOKENS=500000
```

```bash
# Install and configure direnv
brew install direnv
echo 'eval "$(direnv hook zsh)"' >> ~/.zshrc
source ~/.zshrc

# Allow the project's .envrc
direnv allow .
```

This approach allows different projects to have different cost profiles:

```bash
# Small utility project: tight budget
# .envrc
export CLAUDE_CODE_MAX_TURNS=15
export CLAUDE_CODE_BUDGET_TOKENS=200000

# Large enterprise project: more headroom
# .envrc
export CLAUDE_CODE_MAX_TURNS=30
export CLAUDE_CODE_BUDGET_TOKENS=800000
```

## Debugging Environment Variable Issues

```bash
# Verify all Claude Code environment variables
env | grep -i claude
env | grep -i anthropic

# Expected output:
# CLAUDE_MODEL=claude-sonnet-4-6
# CLAUDE_CODE_MAX_TURNS=25
# CLAUDE_CODE_BUDGET_TOKENS=500000
# ANTHROPIC_API_KEY=sk-ant-...

# If variables are not set, check:
# 1. Shell profile loaded? source ~/.zshrc
# 2. direnv allowed? direnv allow .
# 3. Conflicting .env files? check project root
```

## Combining Environment Variables with Other Controls

The complete cost control stack, ordered from most to least enforced:

```
1. Environment variables (runtime-enforced, session-wide)
   - Model selection: cannot be overridden by agent
   - Turn limits: hard stop at limit
   - Token budgets: hard stop at budget

2. .claude/settings.json (tool-level enforcement)
   - Command permissions: deny rules cannot be bypassed
   - MCP server configuration: controls available tools

3. .claudeignore (file-level enforcement)
   - File exclusions: excluded files are invisible to agent

4. CLAUDE.md (agent-level guidance, soft enforcement)
   - Behavioral rules: agent tries to follow but may deviate
   - File budgets: advisory, not enforced
   - Retry limits: advisory, not enforced
```

For maximum cost control, implement all four layers. Each layer catches issues that slip through the layers above it:
- Environment variables catch runaway sessions
- Settings.json catches destructive commands
- .claudeignore catches unnecessary file access
- CLAUDE.md catches behavioral inefficiencies

When all four layers are active, the combined effect is multiplicative: environment variables prevent the worst 5% of sessions, settings.json prevents destructive actions, .claudeignore reduces the search space by 80%, and CLAUDE.md guides behavior for the remaining 20%. No single layer is sufficient alone, but together they form a comprehensive cost control stack that requires minimal ongoing maintenance.

## Related Guides

- [Claude Code .claude/settings.json: Cost-Saving Configuration](/claude-code-settings-json-cost-saving-configuration/) -- project-level permissions
- [Claude Code Sonnet vs Opus: Cost Per Task](/claude-code-sonnet-vs-opus-cost-per-task/) -- model selection guidance
- [Cost Optimization Hub](/cost-optimization/) -- all cost optimization guides

- [Claude Code cost guide](/claude-code-cost-complete-guide/) — Complete guide to Claude Code costs, pricing, and optimization
