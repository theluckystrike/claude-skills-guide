---
title: "Fix Claude Rate Exceeded Error (2026)"
description: "Fix Claude rate exceeded errors across all 5 rate limit types. Includes retry code, token budgeting, and tier upgrade paths for the Anthropic API."
permalink: /claude-rate-exceeded-error-fix/
last_tested: "2026-04-24"
render_with_liquid: false
---

## The Error

```
Error 429: Rate Limit Exceeded
{
  "type": "error",
  "error": {
    "type": "rate_limit_error",
    "message": "Number of request tokens has exceeded your per-minute rate limit"
  }
}
```

A rate exceeded error means you have hit one of Anthropic's usage limits. Your API key is valid and the service is operational, but you have sent too many requests or too many tokens within a time window. This is the single most common error developers encounter when scaling Claude API usage.

<div id="err-match-429" style="background:#1a1a2e;border:1px solid #2a2a3a;border-radius:8px;padding:20px;margin:24px 0;font-family:system-ui,-apple-system,sans-serif;">
<h3 style="color:#6ee7b7;margin:0 0 12px 0;font-size:18px;">Error Pattern Matcher</h3>
<p style="color:#94a3b8;margin:0 0 12px 0;font-size:14px;">Paste your error message below to identify which rate limit you hit.</p>
<textarea id="err-input-429" placeholder="Paste your full error message here..." style="width:100%;min-height:80px;padding:12px;background:#0f172a;color:#e2e8f0;border:1px solid #334155;border-radius:6px;font-family:monospace;font-size:13px;resize:vertical;box-sizing:border-box;"></textarea>
<div id="err-out-429" style="margin-top:12px;display:none;background:#0f172a;padding:16px;border-radius:6px;color:#e2e8f0;font-size:14px;"></div>
</div>
<script>
document.getElementById('err-input-429').addEventListener('input',function(){var t=this.value.toLowerCase(),o=document.getElementById('err-out-429'),m=[];if(!t){o.style.display='none';return;}if(/429|rate.limit/i.test(t))m.push('<strong style="color:#6ee7b7;">429 Rate Limit Error</strong><br>You have exceeded your API rate limit. Check the <code>retry-after</code> header for exact wait time. Implement exponential backoff with jitter.');if(/request.tokens|per-minute rate/i.test(t))m.push('<strong style="color:#6ee7b7;">Tokens Per Minute (TPM) Limit</strong><br>Your input/output tokens exceeded the per-minute cap. Reduce prompt size, add delays between requests, or upgrade your tier.');if(/too many requests/i.test(t))m.push('<strong style="color:#6ee7b7;">Requests Per Minute (RPM) Limit</strong><br>Too many API calls in 60 seconds. Add a rate limiter: queue requests and space them at <code>60/RPM_LIMIT</code> second intervals.');if(/concurrent/i.test(t))m.push('<strong style="color:#6ee7b7;">Concurrent Request Limit</strong><br>Too many in-flight requests. Use a semaphore: <code>asyncio.Semaphore(5)</code> in Python or <code>p-limit</code> in TypeScript.');if(/daily|per.day/i.test(t))m.push('<strong style="color:#6ee7b7;">Daily Token Limit (TPD)</strong><br>You have exhausted your daily token budget. The window resets ~24 hours from your first request of the day. Track usage with a daily counter.');if(/spend|billing|monthly/i.test(t))m.push('<strong style="color:#6ee7b7;">Monthly Spend Limit</strong><br>Organization spending cap reached. Go to console.anthropic.com > Settings > Billing to increase your limit or wait for the next billing cycle.');if(/overloaded|529/i.test(t))m.push('<strong style="color:#6ee7b7;">529 Overloaded (Not Rate Limit)</strong><br>This is a server capacity issue, not your rate limit. All users are affected. Wait 30-60s, retry with longer backoff, or fall back to a smaller model.');if(/quota/i.test(t))m.push('<strong style="color:#6ee7b7;">Quota Exceeded</strong><br>Your usage tier quota is reached. Check your tier at console.anthropic.com. Spending more automatically upgrades your tier within 24 hours.');if(m.length===0)m.push('<span style="color:#94a3b8;">No specific rate limit pattern matched. Check the <code>anthropic-ratelimit-*</code> response headers to identify which limit you hit (RPM, TPM, or TPD).</span>');o.innerHTML=m.join('<hr style="border:none;border-top:1px solid #334155;margin:12px 0;">');o.style.display='block';});
</script>

## The 5 Types of Rate Limits

Anthropic enforces five distinct rate limits. Each has different triggers, different headers, and different solutions.

### 1. Requests Per Minute (RPM)

The simplest limit: too many API calls in a 60-second window, regardless of their size.

**How to detect it:**

```bash
# Check your current RPM allocation
curl -s -D - https://api.anthropic.com/v1/messages \
  -H "x-api-key: $ANTHROPIC_API_KEY" \
  -H "anthropic-version: 2023-06-01" \
  -H "content-type: application/json" \
  -d '{"model":"claude-sonnet-4-20250514","max_tokens":10,"messages":[{"role":"user","content":"test"}]}' \
  2>&1 | grep -i "anthropic-ratelimit-requests"
```

Look for these headers in the response:
- `anthropic-ratelimit-requests-limit` -- your RPM cap
- `anthropic-ratelimit-requests-remaining` -- requests left this window
- `anthropic-ratelimit-requests-reset` -- when the window resets (ISO 8601)

**Fix:** Add request queuing with a rate limiter:

```python
import time
import threading

class RateLimiter:
    def __init__(self, max_rpm: int):
        self.max_rpm = max_rpm
        self.tokens = max_rpm
        self.lock = threading.Lock()
        self.last_refill = time.monotonic()

    def acquire(self):
        while True:
            with self.lock:
                now = time.monotonic()
                elapsed = now - self.last_refill
                self.tokens = min(
                    self.max_rpm,
                    self.tokens + elapsed * (self.max_rpm / 60)
                )
                self.last_refill = now
                if self.tokens >= 1:
                    self.tokens -= 1
                    return
            time.sleep(0.1)

# Usage
limiter = RateLimiter(max_rpm=50)  # Adjust to your tier
for prompt in prompts:
    limiter.acquire()
    response = client.messages.create(
        model="claude-sonnet-4-20250514",
        max_tokens=1024,
        messages=[{"role": "user", "content": prompt}]
    )
```

### 2. Tokens Per Minute (TPM)

You have sent too many input or output tokens within a 60-second window. Large prompts burn through this limit fast.

**How to detect it:**

The error message will specifically mention tokens:
```
"Number of request tokens has exceeded your per-minute rate limit"
```

Response headers:
- `anthropic-ratelimit-tokens-limit`
- `anthropic-ratelimit-tokens-remaining`
- `anthropic-ratelimit-tokens-reset`

**Fix:** Estimate token usage before sending and throttle accordingly:

```python
import anthropic

client = anthropic.Anthropic()

def estimate_and_send(messages, model="claude-sonnet-4-20250514", max_tokens=1024):
    # Count input tokens first
    count = client.count_tokens(model=model, messages=messages)
    total_estimated = count.input_tokens + max_tokens

    print(f"Estimated total tokens: {total_estimated}")

    # If this would exceed your budget, wait or split
    if total_estimated > 40000:
        print("Large request — consider splitting")

    return client.messages.create(
        model=model,
        max_tokens=max_tokens,
        messages=messages
    )
```

### 3. Tokens Per Day (TPD)

A daily cap on total token usage. Once exhausted, all requests fail until the 24-hour window resets.

**How to detect it:**

```
"You have exceeded your daily token limit"
```

**Fix:** Implement daily usage tracking. See the detailed guide on [token-per-day limits](/claude-code-rate-limit-tokens-per-day-fix-2026/).

```python
import json
from pathlib import Path
from datetime import date

USAGE_FILE = Path("token_usage.json")

def track_usage(input_tokens: int, output_tokens: int):
    today = str(date.today())
    usage = json.loads(USAGE_FILE.read_text()) if USAGE_FILE.exists() else {}
    day_usage = usage.get(today, {"input": 0, "output": 0})
    day_usage["input"] += input_tokens
    day_usage["output"] += output_tokens
    usage[today] = day_usage
    USAGE_FILE.write_text(json.dumps(usage, indent=2))
    return day_usage

def check_budget(daily_limit: int = 1_000_000) -> bool:
    today = str(date.today())
    usage = json.loads(USAGE_FILE.read_text()) if USAGE_FILE.exists() else {}
    day_usage = usage.get(today, {"input": 0, "output": 0})
    total = day_usage["input"] + day_usage["output"]
    return total < daily_limit
```

### 4. Concurrent Requests

Too many in-flight requests at the same time. This limit prevents any single API key from monopolizing server resources.

**How to detect it:**

```
"Too many concurrent requests"
```

**Fix:** Use a semaphore to cap parallelism:

```python
import asyncio
import anthropic

MAX_CONCURRENT = 5  # Adjust to your tier

async def process_batch(prompts: list[str]):
    client = anthropic.AsyncAnthropic()
    semaphore = asyncio.Semaphore(MAX_CONCURRENT)

    async def send_one(prompt: str):
        async with semaphore:
            return await client.messages.create(
                model="claude-sonnet-4-20250514",
                max_tokens=1024,
                messages=[{"role": "user", "content": prompt}]
            )

    tasks = [send_one(p) for p in prompts]
    return await asyncio.gather(*tasks)
```

TypeScript equivalent:

```typescript
import Anthropic from "@anthropic-ai/sdk";
import pLimit from "p-limit";

const client = new Anthropic();
const limit = pLimit(5); // Max 5 concurrent

async function processBatch(prompts: string[]) {
  const tasks = prompts.map((prompt) =>
    limit(() =>
      client.messages.create({
        model: "claude-sonnet-4-20250514",
        max_tokens: 1024,
        messages: [{ role: "user", content: prompt }],
      })
    )
  );
  return Promise.all(tasks);
}
```

### 5. Monthly Spend Limits

Anthropic enforces per-organization spending caps. When reached, all API calls fail until the next billing cycle or until you request a limit increase.

**How to detect it:**

```
"Monthly spend limit reached"
```

**Fix:** Monitor spending in the Anthropic Console under Settings > Billing. Set up alerts at 50%, 75%, and 90% thresholds. Request a limit increase through the Console if your usage justifies it.

## Rate Limit Tiers

Anthropic's rate limits scale with your usage tier. As you spend more, your limits automatically increase.

| Tier | RPM | TPM (Input) | TPM (Output) | Requirement |
|------|-----|-------------|--------------|-------------|
| Free | 5 | 20,000 | 4,000 | Sign up |
| Build (Tier 1) | 50 | 40,000 | 8,000 | $5 spend |
| Build (Tier 2) | 1,000 | 80,000 | 16,000 | $40 spend |
| Build (Tier 3) | 2,000 | 160,000 | 32,000 | $200 spend |
| Build (Tier 4) | 4,000 | 400,000 | 80,000 | $1,000 spend |
| Scale | Custom | Custom | Custom | Contact sales |
| Enterprise | Custom | Custom | Custom | Annual contract |

These numbers are for `claude-sonnet-4-20250514`. Limits vary by model -- Haiku typically has higher RPM allowances, and Opus has lower ones.

Check your current tier:

```bash
# Your tier is visible in the Anthropic Console
# Direct API check: look at the rate limit headers from any successful response
curl -s -D - https://api.anthropic.com/v1/messages \
  -H "x-api-key: $ANTHROPIC_API_KEY" \
  -H "anthropic-version: 2023-06-01" \
  -H "content-type: application/json" \
  -d '{"model":"claude-sonnet-4-20250514","max_tokens":10,"messages":[{"role":"user","content":"test"}]}' \
  2>&1 | grep "anthropic-ratelimit"
```

## Rate Limit Tiers by Plan: Complete Reference

Anthropic enforces different rate limits depending on your subscription plan (Claude.ai) or your API spending tier. This table consolidates every known limit across all access methods.

### Claude.ai and Claude Code Subscription Plans

| Plan | Monthly Cost | Claude Code Access | Messages/Day (Estimate) | Throttle Behavior |
|------|-------------|-------------------|------------------------|-------------------|
| Free | $0 | No | ~30 messages | Hard cutoff, resets daily |
| Pro | $20 | Limited | ~100-150 messages | Soft throttle, slower responses after limit |
| Max 5x | $100 | Full (heavy) | ~500+ messages | 5x Pro rate, extended thinking included |
| Max 20x | $200 | Full (very heavy) | ~2,000+ messages | 20x Pro rate, priority during peak |
| Team | $30/user | Full (team) | ~150/user | Per-seat limits, admin controls |
| Enterprise | Custom | Full (managed) | Custom | SLA-backed, dedicated capacity |

Note: Claude.ai message limits are approximate and vary by model and message complexity. Anthropic does not publish exact per-message quotas for subscription plans.

### API Tier Limits (Detailed)

| Tier | Unlock Spend | RPM | Input TPM | Output TPM | Max Concurrent | Daily Token Cap |
|------|-------------|-----|-----------|------------|----------------|-----------------|
| Free | $0 | 5 | 20,000 | 4,000 | 1 | 300,000 |
| Tier 1 | $5 | 50 | 40,000 | 8,000 | 5 | 1,000,000 |
| Tier 2 | $40 | 1,000 | 80,000 | 16,000 | 10 | 2,500,000 |
| Tier 3 | $200 | 2,000 | 160,000 | 32,000 | 20 | 5,000,000 |
| Tier 4 | $1,000 | 4,000 | 400,000 | 80,000 | 50 | Unlimited |
| Scale | Contact sales | Custom | Custom | Custom | Custom | Custom |

These limits apply to `claude-sonnet-4-20250514`. Different models have different limits:

| Model | RPM Modifier | TPM Modifier |
|-------|-------------|-------------|
| Claude Opus 4 | 0.5x (half the RPM) | 0.5x |
| Claude Sonnet 4 | 1x (baseline) | 1x |
| Claude Haiku 4.5 | 2x (double the RPM) | 2x |

So if your tier allows 1,000 RPM for Sonnet, you get ~500 RPM for Opus and ~2,000 RPM for Haiku.

### How to Check Your Current Tier and Remaining Quota

**Method 1: Anthropic Console**
Log into [console.anthropic.com](https://console.anthropic.com), go to Settings > Plans. Your current tier and usage are displayed.

**Method 2: API Response Headers**
Every successful API response includes your current limits and remaining quota:

```bash
curl -s -D - https://api.anthropic.com/v1/messages \
  -H "x-api-key: $ANTHROPIC_API_KEY" \
  -H "anthropic-version: 2023-06-01" \
  -H "content-type: application/json" \
  -d '{"model":"claude-sonnet-4-20250514","max_tokens":5,"messages":[{"role":"user","content":"test"}]}' \
  2>&1 | grep "anthropic-ratelimit"
```

Output:
```
anthropic-ratelimit-requests-limit: 1000
anthropic-ratelimit-requests-remaining: 998
anthropic-ratelimit-requests-reset: 2026-04-24T15:01:00Z
anthropic-ratelimit-tokens-limit: 80000
anthropic-ratelimit-tokens-remaining: 79200
anthropic-ratelimit-tokens-reset: 2026-04-24T15:01:00Z
```

**Method 3: Programmatic Tier Detection**

```python
import anthropic

client = anthropic.Anthropic()
response = client.messages.create(
    model="claude-sonnet-4-20250514",
    max_tokens=5,
    messages=[{"role": "user", "content": "test"}]
)

headers = response._response.headers
rpm_limit = int(headers.get("anthropic-ratelimit-requests-limit", 0))

tier_map = {5: "Free", 50: "Tier 1", 1000: "Tier 2", 2000: "Tier 3", 4000: "Tier 4"}
current_tier = tier_map.get(rpm_limit, f"Custom ({rpm_limit} RPM)")
remaining_rpm = headers.get("anthropic-ratelimit-requests-remaining")
reset_time = headers.get("anthropic-ratelimit-requests-reset")

print(f"Current tier: {current_tier}")
print(f"RPM remaining: {remaining_rpm}")
print(f"Resets at: {reset_time}")
```

### When Rate Limits Reset

| Limit Type | Reset Window | Reset Behavior |
|-----------|-------------|----------------|
| RPM (Requests/Min) | 60 seconds | Rolling window from your first request in the period |
| TPM (Tokens/Min) | 60 seconds | Rolling window, input + output tokens combined |
| TPD (Tokens/Day) | ~24 hours | Resets approximately 24 hours from your first request of the day |
| Concurrent | Immediate | Frees up as soon as an in-flight request completes |
| Monthly Spend | Billing cycle | Resets on your billing renewal date |

The per-minute windows are rolling, not fixed. This means sending 50 requests at 2:00:00 PM does not guarantee 50 more requests at 2:01:00 PM. The window tracks the trailing 60 seconds continuously. Space requests evenly to avoid bursting against the limit.

## Rate Limit Response Headers

Every successful API response includes rate limit headers. Parse them to build proactive throttling:

```python
import anthropic

client = anthropic.Anthropic()

response = client.messages.create(
    model="claude-sonnet-4-20250514",
    max_tokens=100,
    messages=[{"role": "user", "content": "Hello"}]
)

# Access headers from the raw response
# The Python SDK exposes these on the response object
print(f"Requests remaining: {response._response.headers.get('anthropic-ratelimit-requests-remaining')}")
print(f"Tokens remaining: {response._response.headers.get('anthropic-ratelimit-tokens-remaining')}")
print(f"Resets at: {response._response.headers.get('anthropic-ratelimit-tokens-reset')}")
```

When a 429 response arrives, the `retry-after` header tells you exactly how many seconds to wait:

```python
import anthropic
import time

try:
    response = client.messages.create(
        model="claude-sonnet-4-20250514",
        max_tokens=1024,
        messages=[{"role": "user", "content": prompt}]
    )
except anthropic.RateLimitError as e:
    retry_after = int(e.response.headers.get("retry-after", 60))
    print(f"Rate limited. Waiting {retry_after} seconds.")
    time.sleep(retry_after)
```

## Exponential Backoff Implementation

The correct retry strategy for 429 errors uses exponential backoff with jitter and respects the `retry-after` header.

### Python

```python
import anthropic
import time
import random

def call_with_backoff(client, max_retries=8, **kwargs):
    for attempt in range(max_retries):
        try:
            return client.messages.create(**kwargs)
        except anthropic.RateLimitError as e:
            if attempt == max_retries - 1:
                raise

            # Prefer retry-after header if available
            retry_after = e.response.headers.get("retry-after")
            if retry_after:
                delay = int(retry_after)
            else:
                delay = min(
                    (2 ** attempt) + random.uniform(0, 1),
                    120  # Cap at 2 minutes
                )

            print(f"Rate limited (attempt {attempt + 1}), "
                  f"waiting {delay:.1f}s")
            time.sleep(delay)
    raise RuntimeError("Max retries exhausted")
```

### TypeScript

```typescript
import Anthropic from "@anthropic-ai/sdk";

async function callWithBackoff(
  client: Anthropic,
  params: Anthropic.MessageCreateParams,
  maxRetries = 8
): Promise<Anthropic.Message> {
  for (let attempt = 0; attempt < maxRetries; attempt++) {
    try {
      return await client.messages.create(params);
    } catch (err) {
      if (
        err instanceof Anthropic.RateLimitError &&
        attempt < maxRetries - 1
      ) {
        const retryAfter = err.headers?.get("retry-after");
        const delay = retryAfter
          ? parseInt(retryAfter, 10) * 1000
          : Math.min(Math.pow(2, attempt) * 1000 + Math.random() * 1000, 120000);

        console.log(
          `Rate limited (attempt ${attempt + 1}), waiting ${(delay / 1000).toFixed(1)}s`
        );
        await new Promise((r) => setTimeout(r, delay));
        continue;
      }
      throw err;
    }
  }
  throw new Error("Max retries exhausted");
}
```

## Token Budgeting Strategies

Proactive token management prevents rate limit errors entirely.

### Pre-flight Token Estimation

```python
import anthropic

client = anthropic.Anthropic()

def budget_aware_call(messages, max_tokens=1024, budget_remaining=40000):
    """Only send if we have budget remaining in this window."""
    count = client.count_tokens(
        model="claude-sonnet-4-20250514",
        messages=messages
    )
    estimated_total = count.input_tokens + max_tokens

    if estimated_total > budget_remaining:
        raise ValueError(
            f"Request needs ~{estimated_total} tokens, "
            f"but only {budget_remaining} remain in this window"
        )

    return client.messages.create(
        model="claude-sonnet-4-20250514",
        max_tokens=max_tokens,
        messages=messages
    )
```

### Sliding Window Token Tracker

```python
import time
from collections import deque

class TokenWindow:
    def __init__(self, tpm_limit: int, window_seconds: int = 60):
        self.tpm_limit = tpm_limit
        self.window = window_seconds
        self.usage = deque()  # (timestamp, tokens)

    def record(self, tokens: int):
        self.usage.append((time.monotonic(), tokens))
        self._prune()

    def available(self) -> int:
        self._prune()
        used = sum(t for _, t in self.usage)
        return max(0, self.tpm_limit - used)

    def _prune(self):
        cutoff = time.monotonic() - self.window
        while self.usage and self.usage[0][0] < cutoff:
            self.usage.popleft()

# Usage
window = TokenWindow(tpm_limit=80000)

for prompt in prompts:
    estimated = estimate_tokens(prompt)
    if window.available() < estimated:
        wait_time = 60 - (time.monotonic() - window.usage[0][0])
        time.sleep(max(0, wait_time))
    response = client.messages.create(...)
    total_tokens = response.usage.input_tokens + response.usage.output_tokens
    window.record(total_tokens)
```

## Circuit Breaker Pattern for Production Systems

Simple retry logic is not enough for production applications. When the API is persistently rate-limited, retrying every request wastes time and compute. A circuit breaker stops sending requests entirely when failure rates are high, then gradually resumes.

```python
import time
import threading
from enum import Enum

class CircuitState(Enum):
    CLOSED = "closed"        # Normal operation
    OPEN = "open"            # Blocking all requests
    HALF_OPEN = "half_open"  # Testing if API recovered

class CircuitBreaker:
    def __init__(self, failure_threshold=5, recovery_timeout=60):
        self.failure_threshold = failure_threshold
        self.recovery_timeout = recovery_timeout
        self.state = CircuitState.CLOSED
        self.failure_count = 0
        self.last_failure_time = 0
        self.lock = threading.Lock()

    def can_execute(self) -> bool:
        with self.lock:
            if self.state == CircuitState.CLOSED:
                return True
            if self.state == CircuitState.OPEN:
                if time.monotonic() - self.last_failure_time > self.recovery_timeout:
                    self.state = CircuitState.HALF_OPEN
                    return True
                return False
            # HALF_OPEN: allow one test request
            return True

    def record_success(self):
        with self.lock:
            self.failure_count = 0
            self.state = CircuitState.CLOSED

    def record_failure(self):
        with self.lock:
            self.failure_count += 1
            self.last_failure_time = time.monotonic()
            if self.failure_count >= self.failure_threshold:
                self.state = CircuitState.OPEN

# Usage with Anthropic SDK
import anthropic

client = anthropic.Anthropic()
breaker = CircuitBreaker(failure_threshold=3, recovery_timeout=30)

def call_with_circuit_breaker(messages, **kwargs):
    if not breaker.can_execute():
        raise RuntimeError("Circuit breaker OPEN — API rate limited, waiting for recovery")

    try:
        result = client.messages.create(messages=messages, **kwargs)
        breaker.record_success()
        return result
    except anthropic.RateLimitError:
        breaker.record_failure()
        raise
```

The circuit breaker transitions through three states: CLOSED (normal), OPEN (all requests blocked), and HALF_OPEN (one test request allowed). This prevents your application from hammering a rate-limited API and gives the rate limit window time to reset.

---

*These diagnostic steps are from [The Claude Code Playbook](https://zovo.one/pricing) — 200 production-ready templates including error prevention rules and CLAUDE.md configs tested across 50+ project types.*

## Cost of Rate Limiting vs Batching

When you regularly hit rate limits, consider whether the Message Batches API is more cost-effective than real-time requests with retry logic.

| Approach | Cost per 1M tokens (input) | Latency | Rate limit impact |
|----------|---------------------------|---------|-------------------|
| Real-time API | $3.00 (Sonnet) | 1-10 seconds | Counts against RPM and TPM |
| Real-time + retries | $3.00 + wasted compute on failed attempts | Variable (retries add delay) | Exacerbates the problem |
| Message Batches API | $1.50 (Sonnet, 50% discount) | Minutes to hours | Does not count against real-time limits |

For workloads that do not need immediate responses (nightly code analysis, bulk data processing, report generation), batching is strictly better: half the cost and zero rate limit pressure on your real-time quota.

For workloads that need responses within seconds (user-facing chat, interactive coding, CI pipeline steps), real-time with a circuit breaker is the right pattern.

## Upgrading Rate Limits

### Automatic Tier Progression

Anthropic automatically upgrades your tier based on cumulative spend. No action required -- once you cross a spend threshold, your limits increase within 24 hours.

### Requesting Custom Limits

For Scale and Enterprise tiers, contact Anthropic sales through the Console. Provide:

- Your current usage patterns (RPM, TPM averages and peaks)
- Your projected growth over the next 3 months
- Your use case (batch processing, real-time chat, agent workflows)

### Batching as a Rate Limit Bypass

The [Message Batches API](https://docs.anthropic.com/en/docs/build-with-claude/batch-processing) processes requests asynchronously at 50% cost and does not count against your real-time rate limits:

```python
# Batch API for non-urgent workloads
batch = client.batches.create(
    requests=[
        {
            "custom_id": f"req_{i}",
            "params": {
                "model": "claude-sonnet-4-20250514",
                "max_tokens": 1024,
                "messages": [{"role": "user", "content": prompt}]
            }
        }
        for i, prompt in enumerate(prompts)
    ]
)
print(f"Batch created: {batch.id}")
```

## Claude Code and Rate Limits

Claude Code manages rate limits internally. When it hits a 429, it automatically waits and retries. You will see a message like:

```
Waiting for rate limit to reset (retrying in 32s)...
```

To reduce how often this happens:

1. **Use `/compact` frequently.** Long conversations accumulate tokens. Compacting summarizes history and reduces the token payload on each subsequent request.

2. **Avoid unnecessary file reads.** Each file Claude Code reads adds to the input token count. Be specific about which files you want it to examine.

3. **Set `max_tokens` in CLAUDE.md.** This does not directly control Claude Code's behavior but signals intent for any API wrappers.

4. **Switch models for simple tasks.** Use `claude --model claude-haiku-4-20250514` for tasks that do not need deep reasoning. Haiku has higher rate limits and costs fewer tokens.

See the [429 retry-after guide](/claude-code-rate-limit-429-retry-after-fix/) for Claude Code specific troubleshooting.

## When "Rate Exceeded" Is Actually Overload (529)

If you receive a [529 error](/claude-api-529-overloaded-error-handling-fix/) instead of 429, the issue is not your rate limit -- it is Anthropic's capacity. The 529 means the model is saturated across all users. Your retry strategy should be longer delays (start at 30 seconds) and you should consider falling back to a smaller model.

The key difference:
- **429**: You specifically have exceeded your allocation. Other users may be fine.
- **529**: The entire model is overloaded. All users are affected.

## CLAUDE.md Rules to Reduce Token Usage

```markdown
# Token Efficiency
- Always use the smallest model that can handle the task
- Prefer targeted file reads over directory-wide searches
- Summarize long outputs before including them in follow-up prompts
- Use structured output (JSON) to reduce response verbosity
- Batch related questions into single prompts instead of multiple calls
- Set explicit max_tokens limits in every API call
- Use system prompts for persistent instructions (avoids repeating in user messages)
```

## FAQ

### How do I check my current rate limit tier?

Log into the [Anthropic Console](https://console.anthropic.com). Navigate to Settings > Plans to see your current tier. Alternatively, inspect the `anthropic-ratelimit-requests-limit` header from any successful API response.

### Do rate limits apply per API key or per organization?

Rate limits apply at the organization level. Multiple API keys within the same organization share the same rate limit pool. Creating additional API keys does not increase your limits.

### Does the Anthropic Python SDK handle rate limits automatically?

The official SDK includes automatic retry logic with exponential backoff for 429 responses. However, the defaults may not suit your use case. For high-volume applications, implement custom retry logic as shown in the examples above.

### How do I handle rate limits in a multi-user application?

Implement request queuing at the application level. Use a shared rate limiter (Redis-backed for distributed systems) that tracks usage across all users and delays requests that would exceed the limit.

### Can I get higher rate limits without paying more?

No. Rate limits are tied to your spending tier. The only ways to increase them are to spend more (triggering automatic tier upgrades) or to contact Anthropic sales for a custom enterprise agreement.

### What happens if I hit the daily token limit?

All API requests will return 429 until the 24-hour window resets. The reset time is based on when your first request of the day was made, not midnight UTC. Plan your workloads to spread token usage across the full day.

### Are rate limits different for streaming vs non-streaming requests?

No. Streaming and non-streaming requests count equally against RPM and TPM limits. Streaming does not provide any rate limit advantage, though it can improve perceived latency.

### How do rate limits work with tool use and function calling?

Tool definitions count as input tokens. Each tool in your request schema adds tokens to the input count. If you define 20 tools, you may be sending 5,000-10,000 extra tokens per request. Prune unused tools to stay within TPM limits. See the [tool token cost guide](/claude-code-rate-limit-429-retry-after-fix/) for details.

### Does prompt caching help with rate limits?

Yes. Prompt caching reduces the number of input tokens counted against your TPM limit for cached content. When your system prompt and conversation history are cached, subsequent requests consume fewer tokens from your per-minute allowance, effectively increasing your throughput without upgrading your tier.

### Can I use multiple API keys to bypass rate limits?

No. Rate limits are enforced at the organization level, not per API key. Creating additional keys within the same organization shares the same limit pool. The correct approach is to upgrade your tier through increased spend or contact Anthropic sales for custom limits.

## Related Guides

- [Fix Claude Code Rate Limit 429 Retry-After](/claude-code-rate-limit-429-retry-after-fix/)
- [Fix Claude Code Tokens Per Day Limit](/claude-code-rate-limit-tokens-per-day-fix-2026/)
- [Fix Claude API 529 Overloaded Error](/claude-api-529-overloaded-error-handling-fix/)
- [Fix Claude API 503 Service Unavailable](/claude-api-503-service-unavailable-fix/)
- [Fix Claude Internal Server Error](/claude-internal-server-error-fix/)
- [The Claude Code Playbook](/playbook/)
- [Fix Claude Code ETIMEOUT Corporate Proxy](/claude-code-etimeout-corporate-proxy-fix/)
- [Fix Claude Code Docker Cannot Reach API Endpoint](/claude-code-docker-cannot-reach-api-endpoint-fix/)
- [Fix Claude AI Rate Exceeded Error](/claude-ai-rate-exceeded-error-fix/)
- [Claude not working right now fix](/claude-not-working-right-now-fix/) — troubleshoot when Claude is down
- [Claude 5-hour usage limit](/claude-5-hour-usage-limit-guide/) — understand rolling usage windows
- [Claude extra usage cost](/claude-extra-usage-cost-guide/) — what overages actually cost

<script type="application/ld+json">
[
  {
    "@context": "https://schema.org",
    "@type": "FAQPage",
    "mainEntity": [
      {
        "@type": "Question",
        "name": "How do I check my current rate limit tier?",
        "acceptedAnswer": {
          "@type": "Answer",
          "text": "Log into the Anthropic Console at console.anthropic.com. Navigate to Settings > Plans to see your current tier. Alternatively, inspect the anthropic-ratelimit-requests-limit header from any successful API response."
        }
      },
      {
        "@type": "Question",
        "name": "Do rate limits apply per API key or per organization?",
        "acceptedAnswer": {
          "@type": "Answer",
          "text": "Rate limits apply at the organization level. Multiple API keys within the same organization share the same rate limit pool. Creating additional API keys does not increase your limits."
        }
      },
      {
        "@type": "Question",
        "name": "Does the Anthropic Python SDK handle rate limits automatically?",
        "acceptedAnswer": {
          "@type": "Answer",
          "text": "The official SDK includes automatic retry logic with exponential backoff for 429 responses. However, the defaults may not suit your use case. For high-volume applications, implement custom retry logic."
        }
      },
      {
        "@type": "Question",
        "name": "How do I handle rate limits in a multi-user application?",
        "acceptedAnswer": {
          "@type": "Answer",
          "text": "Implement request queuing at the application level. Use a shared rate limiter (Redis-backed for distributed systems) that tracks usage across all users and delays requests that would exceed the limit."
        }
      },
      {
        "@type": "Question",
        "name": "Can I get higher rate limits without paying more?",
        "acceptedAnswer": {
          "@type": "Answer",
          "text": "No. Rate limits are tied to your spending tier. The only ways to increase them are to spend more (triggering automatic tier upgrades) or to contact Anthropic sales for a custom enterprise agreement."
        }
      },
      {
        "@type": "Question",
        "name": "What happens if I hit the daily token limit?",
        "acceptedAnswer": {
          "@type": "Answer",
          "text": "All API requests will return 429 until the 24-hour window resets. The reset time is based on when your first request of the day was made, not midnight UTC. Plan your workloads to spread token usage across the full day."
        }
      },
      {
        "@type": "Question",
        "name": "Are rate limits different for streaming vs non-streaming requests?",
        "acceptedAnswer": {
          "@type": "Answer",
          "text": "No. Streaming and non-streaming requests count equally against RPM and TPM limits. Streaming does not provide any rate limit advantage, though it can improve perceived latency."
        }
      },
      {
        "@type": "Question",
        "name": "How do rate limits work with tool use and function calling?",
        "acceptedAnswer": {
          "@type": "Answer",
          "text": "Tool definitions count as input tokens. Each tool in your request schema adds tokens to the input count. If you define 20 tools, you may be sending 5,000-10,000 extra tokens per request. Prune unused tools to stay within TPM limits."
        }
      },
      {
        "@type": "Question",
        "name": "Does prompt caching help with rate limits?",
        "acceptedAnswer": {
          "@type": "Answer",
          "text": "Yes. Prompt caching reduces the number of input tokens counted against your TPM limit for cached content. When your system prompt and conversation history are cached, subsequent requests consume fewer tokens from your per-minute allowance, effectively increasing your throughput without upgrading your tier."
        }
      },
      {
        "@type": "Question",
        "name": "Can I use multiple API keys to bypass rate limits?",
        "acceptedAnswer": {
          "@type": "Answer",
          "text": "No. Rate limits are enforced at the organization level, not per API key. Creating additional keys within the same organization shares the same limit pool. The correct approach is to upgrade your tier through increased spend or contact Anthropic sales for custom limits."
        }
      }
    ]
  },
  {
    "@context": "https://schema.org",
    "@type": "HowTo",
    "name": "Fix Claude Rate Exceeded Error",
    "step": [
      {
        "@type": "HowToStep",
        "name": "Identify the rate limit type",
        "text": "Check the error message and response headers to determine which of the 5 rate limit types you hit: requests per minute (RPM), tokens per minute (TPM), tokens per day (TPD), concurrent requests, or monthly spend limits."
      },
      {
        "@type": "HowToStep",
        "name": "Implement exponential backoff",
        "text": "Add retry logic with exponential backoff and jitter. Respect the retry-after header when present. Cap maximum delay at 120 seconds and limit retries to 8 attempts."
      },
      {
        "@type": "HowToStep",
        "name": "Add request queuing and rate limiting",
        "text": "Implement a token bucket or sliding window rate limiter in your application. Track usage per minute using the rate limit response headers and throttle requests before they hit the limit."
      },
      {
        "@type": "HowToStep",
        "name": "Implement a circuit breaker for production",
        "text": "Add a circuit breaker pattern that stops sending requests when failure rates are high, then gradually resumes. This prevents hammering a rate-limited API and gives the rate limit window time to reset."
      },
      {
        "@type": "HowToStep",
        "name": "Consider the Message Batches API",
        "text": "For workloads that do not need immediate responses, switch to the Message Batches API which offers 50% cost savings and does not count against real-time rate limits."
      },
      {
        "@type": "HowToStep",
        "name": "Upgrade your rate limit tier",
        "text": "If you consistently hit limits, increase your spending to trigger automatic tier upgrades, or contact Anthropic sales for custom enterprise limits."
      }
    ]
  }
]
</script>
