---
title: "Daily Token Limit Exceeded Error — Fix"
permalink: /claude-code-rate-limit-tokens-per-day-fix-2026/
description: "Fix 'daily token limit exceeded' error. Monitor usage, reduce token consumption, or upgrade plan for higher daily limits."
last_tested: "2026-04-22"
render_with_liquid: false
---

## The Error

```
Error 429: You have exceeded your daily token limit of 1,000,000 input tokens. Limit resets at 00:00 UTC. Current usage: 1,000,247 tokens.
```

This error occurs when you hit your plan's daily token ceiling. Unlike per-minute rate limits, this is a hard daily cap that only resets at midnight UTC.

## The Fix

1. Check your current usage and limits:

```bash
curl -s https://api.anthropic.com/v1/usage \
  -H "x-api-key: $ANTHROPIC_API_KEY" \
  -H "anthropic-version: 2023-06-01" | python3 -m json.tool
```

2. Reduce token consumption immediately:

```bash
# Use compact mode in Claude Code to reduce context
claude /compact

# Switch to a smaller model for routine tasks
claude config set model claude-haiku-3-20250310
```

3. Check when your limit resets:

```bash
python3 -c "
from datetime import datetime, timezone
now = datetime.now(timezone.utc)
reset = now.replace(hour=0, minute=0, second=0)
if reset < now:
    from datetime import timedelta
    reset += timedelta(days=1)
hours_left = (reset - now).seconds // 3600
print(f'Resets in {hours_left} hours at 00:00 UTC')
"
```

## Why This Happens

Anthropic enforces daily token limits per organization to prevent runaway costs and ensure fair usage. Build tier accounts have lower daily limits than Scale tier. Agentic workflows that loop many times can burn through daily limits quickly, especially when sending large codebases as context.

## If That Doesn't Work

- Request a limit increase through the Anthropic Console.
- Split work across multiple API keys if you have multiple organizations.
- Use prompt caching to reduce input token consumption by up to 90%.

## Prevention

Add this to your `CLAUDE.md`:

```markdown
# Token Budget
- Monitor daily token usage. Stay under 80% of daily limit.
- Use /compact regularly to reduce conversation context size.
- Enable prompt caching for repeated large contexts.
- Use Haiku for simple tasks, reserve Sonnet/Opus for complex work.
```

## See Also

- [Anthropic Rate Limit Tokens Per Minute — Fix (2026)](/claude-code-anthropic-rate-limit-tokens-per-minute-fix-2026/)
