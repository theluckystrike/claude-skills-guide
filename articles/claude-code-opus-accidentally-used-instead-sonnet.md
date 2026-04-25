---
title: "Claude Code Opus Used Instead of Sonnet"
description: "Accidentally running Claude Code on Opus 4.6 costs 5x more than Sonnet 4.6. Detect the mistake, set model defaults, and prevent it from recurring."
permalink: /claude-code-opus-accidentally-used-instead-sonnet/
date: 2026-04-22
last_tested: "2026-04-22"
---

# Claude Code Opus accidentally used instead of Sonnet -- cost recovery

## The Problem

Claude Code ran on Opus 4.6 ($15/$75 per MTok) instead of Sonnet 4.6 ($3/$15 per MTok), resulting in a 5x cost multiplier. A typical 60K-token session that costs $0.36 on Sonnet cost $1.80 on Opus. A heavy session of 200K tokens: $1.20 on Sonnet versus $6.00 on Opus. If the mistake persisted for a full day of 5-10 sessions, the extra cost ranges from $7-$50 in a single day.

## Quick Fix (2 Minutes)

1. **Switch model immediately**:
   ```bash
   claude --model sonnet -p "your prompt"
   ```

2. **Create a shell alias** to prevent recurrence:
   ```bash
   # Add to ~/.zshrc or ~/.bashrc
   alias claude='claude --model sonnet'
   ```

3. **Verify current model** before expensive tasks:
   ```bash
   # Check which model is active at session start
   # The model name appears in the Claude Code startup header
   ```

## Why This Happens

Three common causes:

**1. Model switched for a previous task and not reverted.** A developer uses Opus for a complex architecture task, then forgets to switch back for routine work. Every subsequent session runs at 5x cost.

**2. Environment variable override.** The `ANTHROPIC_MODEL` or similar environment variable is set to an Opus model ID, overriding the default for all sessions.

**3. Configuration file setting.** A global or project settings file specifies Opus as the default model.

The cost impact is immediate and significant:

| Session Type | Sonnet 4.6 Cost | Opus 4.6 Cost | Overspend |
|-------------|----------------|---------------|-----------|
| Quick fix (20K tokens) | $0.12 | $0.60 | $0.48 |
| Bug fix (60K tokens) | $0.36 | $1.80 | $1.44 |
| Feature implementation (120K tokens) | $0.72 | $3.60 | $2.88 |
| Large refactor (200K tokens) | $1.20 | $6.00 | $4.80 |
| Full day (5 sessions, 500K total) | $3.00 | $15.00 | $12.00 |

## The Full Fix

### Step 1: Diagnose

Determine how long Opus has been active and the total overspend:

```bash
# Check recent session costs
ccusage --sort cost --limit 10

# Look for sessions with unusually high costs
# A 60K-token session costing $1.80+ is a strong Opus indicator
# (Same session on Sonnet would cost ~$0.36)
```

Check for model configuration overrides:

```bash
# Check environment variables
env | grep -i model
env | grep -i anthropic
env | grep -i claude

# Check global settings
cat ~/.claude/settings.json 2>/dev/null | grep -i model

# Check project settings
cat .claude/settings.json 2>/dev/null | grep -i model
```

### Step 2: Fix

```bash
# Remove any model overrides from environment
unset ANTHROPIC_MODEL

# Set explicit model in shell profile
echo 'alias claude="claude --model sonnet"' >> ~/.zshrc
source ~/.zshrc

# Verify the fix
claude --model sonnet -p "What model are you?" --max-turns 3
```

### Step 3: Prevent

```bash
# Add model guard to shell profile
# ~/.zshrc

# Always default to Sonnet
alias claude='claude --model sonnet'

# Explicit Opus alias for intentional use (named to make it obvious)
alias claude-opus='claude --model opus'

# Print a reminder when using Opus
claude-opus() {
  echo "WARNING: Using Opus 4.6 ($15/$75 per MTok) -- 5x Sonnet cost"
  echo "Press Ctrl+C within 3 seconds to cancel..."
  sleep 3
  command claude --model opus "$@"
}
```

## When Opus Is Actually Worth It

Not every Opus session is a mistake. Some tasks genuinely benefit from Opus 4.6's superior reasoning, and spending 5x on tokens is justified by the quality improvement:

**Justified Opus use cases:**
- Multi-system architecture design across 10+ files
- Complex debugging where Sonnet failed after 2-3 attempts (the retry cost on Sonnet may exceed one Opus session)
- Security audits requiring deep reasoning about attack vectors
- Performance optimization requiring understanding of complex algorithmic tradeoffs

**Never justified for Opus:**
- Simple edits (typo fixes, config changes)
- Code reviews (reading comprehension, not deep reasoning)
- Documentation generation
- Test writing for straightforward functions

A useful rule of thumb: if the task would take a senior developer less than 15 minutes, Sonnet handles it fine. If it would take a senior developer an hour or more of deep thought, Opus may be worth the 5x premium.

```bash
# Decision helper: check task complexity before choosing model
# Quick tasks: always Sonnet
claude --model sonnet -p "Add error handling to the getUser function"

# Complex tasks: evaluate whether Opus is justified
# Sonnet attempt first, Opus only if Sonnet fails
claude --model sonnet --max-turns 15 -p "Debug the race condition in the payment processing pipeline"
# If this fails after 15 turns, then:
claude --model opus --max-turns 20 -p "Debug the race condition in the payment processing pipeline. Previous Sonnet attempt identified the issue is in src/services/payment.ts but could not determine root cause."
```

## Cost Recovery

The overspent tokens cannot be refunded, but the financial impact can be quantified and future waste prevented:

```text
Calculate overspend:
  Total Opus spend (from ccusage): $___
  Same tokens on Sonnet: Opus_spend / 5 = $___
  Overspend: Opus_spend x 0.8 = $___

Example:
  Opus sessions total: $25.00
  Same on Sonnet: $5.00
  Overspend: $20.00
```

Prevention saves: if the default was Opus for 1 week at moderate usage (500K tokens/day), the overspend is approximately $48.00. Fixing the alias takes 2 minutes and prevents all future incidents.

## Prevention Rules for CLAUDE.md

```markdown
## Model Selection
- Default model: Sonnet 4.6 (--model sonnet) for all standard tasks
- Opus 4.6: use ONLY for complex architecture decisions or multi-system debugging
- Before starting any Opus session, verify the task justifies 5x cost
- Check model in session header before proceeding with expensive tasks
- If session cost exceeds expectations, check model immediately
```

### Team-Wide Model Governance

For teams, accidental Opus usage by one developer can blow the monthly budget. Implement governance:

```bash
# scripts/model-policy-check.sh
# Run in CI or as a pre-commit hook to verify model configuration
set -uo pipefail

echo "=== Model Policy Check ==="

# Check for Opus references in shell configs
for file in ~/.zshrc ~/.bashrc ~/.zprofile; do
  if [ -f "$file" ] && grep -qi "opus" "$file"; then
    echo "WARN: $file contains 'opus' reference -- verify it includes explicit --model flag"
  fi
done

# Check project settings for model specification
if [ -f ".claude/settings.json" ] && grep -qi "opus" ".claude/settings.json"; then
  echo "WARN: Project settings reference Opus -- verify this is intentional"
fi

# Check environment variables
if [ -n "${ANTHROPIC_MODEL:-}" ] && echo "$ANTHROPIC_MODEL" | grep -qi "opus"; then
  echo "ALERT: ANTHROPIC_MODEL is set to an Opus model: $ANTHROPIC_MODEL"
  echo "This overrides all session-level --model flags"
fi

echo ""
echo "Recommendation: alias claude='claude --model sonnet' in all developer shell profiles"
```

Add this check to the team onboarding process. A single developer accidentally using Opus for a full day can cost $50+ in API charges ($40 more than the same usage on Sonnet). Team-wide aliases and environment variable auditing prevent this. The 2-minute effort to set up the alias is the highest-ROI cost prevention measure available -- it eliminates the most common cause of $20+ sessions.

## Related Guides

- [Why Did Claude Code Cost $20 for One Session?](/why-claude-code-cost-20-one-session-debugging/) -- comprehensive session cost debugging
- [Claude Code Sonnet vs Haiku: When Cheaper Is Actually Better](/claude-code-sonnet-vs-haiku-cheaper-actually-better/) -- model selection optimization
- [Cost Optimization Hub](/cost-optimization/) -- all cost control techniques

## See Also

- [Stop Claude Code Rewriting Entire Files (2026)](/claude-code-rewrites-instead-of-editing-fix-2026/)
