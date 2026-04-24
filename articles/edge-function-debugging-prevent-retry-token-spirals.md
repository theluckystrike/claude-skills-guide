---
title: "Edge Function Debugging: Prevent 8-Retry Token Spirals"
description: "Prevent Claude Code from burning 50K-200K tokens retrying edge function deployments by adding structured error handling and retry limits to CLAUDE.md."
permalink: /edge-function-debugging-prevent-retry-token-spirals/
date: 2026-04-22
last_tested: "2026-04-22"
render_with_liquid: false
---

# Edge Function Debugging: Prevent 8-Retry Token Spirals

## The Pattern

Edge function debugging in Claude Code frequently triggers retry spirals: the agent deploys a function, it fails, the agent modifies and redeploys, it fails differently, and the cycle repeats 5-10 times. Each retry costs 5,000-20,000 tokens (code modification + deployment command + error parsing). An 8-retry spiral consumes 40,000-160,000 tokens -- often more than the entire rest of the session combined. The pattern: diagnose fully before retrying, and enforce a hard retry cap.

## Why It Matters for Token Cost

Edge functions (Supabase, Cloudflare Workers, Vercel, AWS Lambda) have a unique cost-amplifying characteristic: deployment is slow (5-30 seconds), error messages are often incomplete, and the debug cycle requires re-sending the full function code each time. A typical edge function is 50-300 lines (400-2,400 tokens). Each deploy-fail-modify cycle re-sends this code plus the error output plus the modification reasoning.

At Opus 4.6 rates, an 8-retry spiral costs:
- 8 code re-sends: 8 * 1,500 avg = 12,000 tokens
- 8 deploy commands: 8 * 245 = 1,960 tokens
- 8 error readings: 8 * 800 = 6,400 tokens
- 8 modification reasoning chains: 8 * 2,000 = 16,000 tokens
- Context growth: ~36,000 tokens accumulating across 8 turns
- **Total: approximately 72,360 tokens = $1.09-$5.43**

## The Anti-Pattern (What NOT to Do)

```bash
# Anti-pattern: Blind retry loop (each attempt costs ~9,000 tokens)

# Attempt 1: Deploy function
supabase functions deploy payment-webhook
# Error: "TypeError: Cannot read properties of undefined"

# Attempt 2: Add null check, redeploy (same error, different line)
supabase functions deploy payment-webhook
# Error: "TypeError: Cannot read properties of undefined"

# Attempt 3: Add more null checks (wrong approach, underlying issue is import)
supabase functions deploy payment-webhook
# Error: "Module not found: @supabase/supabase-js"

# Attempt 4: Fix import, redeploy (new error)
supabase functions deploy payment-webhook
# Error: "Invalid header: content-type"

# ... continues through attempt 8 ...
# Total cost: ~72,000 tokens spent, problem still not fully resolved
```

## The Pattern in Action

### Step 1: Diagnose Before Deploying

Before any retry, the agent should fully analyze the error rather than applying quick fixes.

```yaml
# CLAUDE.md -- edge function debugging protocol
## Edge Function Retry Limits
- Maximum 3 deploy attempts for any single edge function
- Before EACH retry: read the full error, check Deno/Node compatibility, verify imports
- After 3 failures: stop, summarize all 3 errors, and present a diagnostic report

## Edge Function Pre-Deploy Checklist
Before deploying, verify:
1. All imports resolve (check import map or package.json)
2. Environment variables are set (check .env or secrets config)
3. Request/response types match the runtime (Deno vs Node)
4. Function compiles locally: `deno check functions/name/index.ts` or `tsc --noEmit`
```

### Step 2: Local Validation Before Remote Deployment

```bash
# Validate locally BEFORE deploying (costs ~500 tokens total)
# Step 1: Type check
deno check supabase/functions/payment-webhook/index.ts 2>&1 | head -20
# If errors: fix them before deploying

# Step 2: Verify imports resolve
deno info supabase/functions/payment-webhook/index.ts 2>&1 | head -20
# If missing modules: update import map

# Step 3: Test locally
supabase functions serve payment-webhook --no-verify-jwt &
curl -X POST http://localhost:54321/functions/v1/payment-webhook \
  -H "Content-Type: application/json" \
  -d '{"test": true}' 2>&1 | head -30

# Only deploy after local validation passes
supabase functions deploy payment-webhook
```

Local validation costs approximately 3 * 245 = 735 tokens in Bash overhead plus output. A failed remote deploy costs 2,000-5,000 tokens per attempt. Validating locally first prevents 2-5 failed remote deploys, saving 4,000-25,000 tokens.

### Step 3: Structured Error Analysis

When a deployment does fail, analyze the error systematically instead of pattern-matching and guessing.

```yaml
# CLAUDE.md -- error analysis protocol for edge functions
## When an Edge Function Deploy Fails:
1. Read the COMPLETE error message (do not just scan the first line)
2. Classify the error:
   - Import error -> check import map, verify package availability
   - Type error -> run local type check, fix types
   - Runtime error -> check environment variables, check request format
   - Permission error -> check function access configuration
3. Fix ALL issues found in the error before retrying (not just the first one)
4. Log: attempt number, error type, fix applied
5. After attempt 3: stop and present diagnostic summary
```

## Before and After

| Metric | No Retry Control | With Retry Protocol | Savings |
|--------|-----------------|--------------------|---------|
| Average retries per debug | 5-8 | 1-3 | 50-75% fewer retries |
| Tokens per debug cycle | 40K-160K | 10K-30K | 75-81% |
| Time per debug cycle | 10-30 minutes | 3-10 minutes | 67-70% |
| Cost per debug (Opus) | $3-$12 | $0.75-$2.25 | $2.25-$9.75 saved |
| Monthly (5 debug sessions/week) | $60-$240 | $15-$45 | $45-$195 saved |

## When to Use This Pattern

- Any project using Supabase Edge Functions, Cloudflare Workers, Vercel Serverless, or AWS Lambda
- When Claude Code is used for deployment and debugging of remote functions
- CI/CD pipelines that use Claude Code for automated deployment troubleshooting

## When NOT to Use This Pattern

- Simple, single-file functions with straightforward deployment (the overhead of local validation exceeds the risk of retry spirals)
- When the deployment always succeeds on the first try (rare in practice)

## Implementation in CLAUDE.md

```yaml
# CLAUDE.md -- edge function cost control
## Edge Function Rules
- ALWAYS run local type checking before deploying: `deno check <file>` or `tsc --noEmit`
- Maximum 3 deploy attempts per function per session
- After each failed deploy: full error analysis before retry (classify, fix ALL issues, not just first)
- After 3 failures: STOP, present diagnostic summary with all 3 errors
- Never deploy to production without testing in staging/local first
- Cap deploy command output: `deploy-cmd 2>&1 | tail -30`
```

## Related Guides

- [Claude Code keeps retrying the same error -- cost fix](/claude-code-keeps-retrying-same-error-cost-fix/) -- general retry spiral prevention
- [CLAUDE.md as Cost Control](/claude-md-cost-control-rules-prevent-token-waste/) -- CLAUDE.md rules for cost prevention
- [Claude Code Hooks Guide](/understanding-claude-code-hooks-system-complete-guide/) -- automating pre-deploy validation with hooks
