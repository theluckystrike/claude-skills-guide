---
layout: default
title: "Fix: Claude Isn't Working Right Now (2026)"
description: "Fix every Claude not working scenario: API outages, rate limits, account issues, browser problems, and CLI errors. Quick diagnostic checklist."
permalink: /claude-not-working-right-now-fix/
date: 2026-04-20
last_tested: "2026-04-24"
---

# Fix: Claude Isn't Working Right Now (2026)

You open Claude and get an error, a blank screen, or a message that says "This isn't working right now." This guide covers every known cause and fix, organized from most common to least common.

Start with the Quick Diagnostic Checklist, then drill into the specific section that matches your situation.

## Quick Diagnostic Checklist

Run through these five checks in order. Most issues resolve within the first three.

1. **Check Anthropic status**: Visit status.anthropic.com. If there is an active incident, wait for resolution.
2. **Check your internet**: Open any website. If other sites load, your connection is fine.
3. **Check your plan**: Log in to claude.ai/settings. Verify your subscription is active and not expired.
4. **Hard refresh**: Press Ctrl+Shift+R (Cmd+Shift+R on Mac) in your browser. This clears cached data.
5. **Try a different browser or incognito**: If Claude works in incognito, a browser extension is causing the issue.

If none of these fix it, continue to the specific sections below.

## Scenario 1: Anthropic Service Outage

**Symptoms**: Everyone sees errors. Claude.ai shows error pages. API returns 500/503 errors. Claude Code fails with connection errors.

**Check**: Visit status.anthropic.com

**What to do**:
- Wait. Anthropic usually resolves outages within 30 minutes to 2 hours.
- Subscribe to status updates on the status page for email/SMS notifications.
- If using Claude Code with an API key, there is no workaround (the backend is down).
- If urgent, consider using [OpenRouter](/claude-code-openrouter-setup-guide/) with a fallback model from another provider.

**How to confirm it is an outage vs your issue**: Check Twitter/X for "Claude down" or the Anthropic Discord. If multiple people report issues, it is an outage.

## Scenario 2: Rate Limited (429 Error)

**Symptoms**: "You've sent too many messages" or HTTP 429 error. Works for a while, then stops. Usually happens during heavy usage periods.

### On Claude.ai (Web)

**Cause**: You hit the [usage limit for your plan tier](/claude-5-hour-usage-limit-guide/).

**Fixes**:
1. Wait for the limit to reset (rolling 5-hour window for most plans)
2. Switch to a less powerful model (Haiku uses less quota than Opus)
3. Upgrade from Pro ($20/month) to Max ($100 or $200/month) for higher limits
4. Reduce message length to consume fewer tokens per message

### On Claude Code (CLI)

**Cause**: API rate limit exceeded.

**Fixes**:
1. Check remaining rate limit from the error message headers
2. Wait for the reset window (usually 1 minute for request limits)
3. Switch to Haiku for less demanding tasks: `/model haiku`
4. Use the `/compact` command to reduce context size (smaller contexts use fewer tokens per request)
5. See [rate limit handling strategies](/anthropic-api-error-429-rate-limit/)

### On the API

**Cause**: Exceeded requests per minute (RPM) or tokens per minute (TPM) for your tier.

**Fix**: Implement exponential backoff:

```python
import time
import anthropic

client = anthropic.Anthropic()

for attempt in range(5):
    try:
        response = client.messages.create(
            model="claude-sonnet-4-20250514",
            max_tokens=1024,
            messages=[{"role": "user", "content": "Hello"}]
        )
        break
    except anthropic.RateLimitError as e:
        wait_time = 2 ** attempt
        print(f"Rate limited. Waiting {wait_time}s...")
        time.sleep(wait_time)
```

## Scenario 3: Account or Subscription Issues

**Symptoms**: "Unable to access" or "subscription required" messages. Previously worked, now shows errors.

### Expired Subscription

**Check**: Go to claude.ai/settings (or console.anthropic.com for API).

**Fixes**:
1. Renew your subscription payment method
2. Check for failed payment notifications in your email
3. Update your credit card if it expired
4. Contact support@anthropic.com if your subscription shows active but access is blocked

### API Credits Exhausted

**Check**: Visit console.anthropic.com, look at your credit balance.

**Fixes**:
1. Add more credits to your account
2. Set up auto-recharge to prevent interruptions
3. Review your [spending](/claude-extra-usage-cost-guide/) to understand what consumed credits
4. Set up [cost alerts](/claude-code-cost-alerts-notifications-budget/) to catch this earlier

### Account Suspended

**Symptoms**: Login works but all interactions return errors about account status.

**Cause**: Terms of service violation, unusual activity detection, or billing issues.

**Fix**: Contact support@anthropic.com. Include your account email and the exact error message.

## Scenario 4: Browser-Specific Issues

**Symptoms**: Claude works in one browser but not another. Works in incognito but not regular mode.

### Browser Extension Conflicts

Common conflicting extensions:
- Ad blockers (uBlock Origin, AdBlock Plus) blocking Anthropic API requests
- Privacy extensions (Privacy Badger, Ghostery) interfering with WebSocket connections
- VPN extensions routing traffic through unsupported regions
- JavaScript-modifying extensions breaking the Claude.ai frontend

**Fix**: Temporarily disable all extensions and try again. Re-enable them one by one to identify the culprit. Then add an exception for claude.ai in the blocking extension.

### Cached Data Issues

**Fix**: Clear site data for claude.ai:
1. Open browser developer tools (F12)
2. Go to Application tab
3. Under Storage, click "Clear site data"
4. Reload the page

### Cookie Issues

Claude.ai requires cookies for authentication.

**Fix**:
1. Ensure cookies are enabled for claude.ai
2. Remove all claude.ai cookies and log in again
3. Check that your browser is not set to clear cookies on close (if so, add an exception for claude.ai)

### JavaScript Disabled

Claude.ai requires JavaScript.

**Fix**: Enable JavaScript in your browser settings. If using NoScript or similar, whitelist claude.ai and anthropic.com domains.

### Outdated Browser

**Fix**: Update to the latest version of Chrome, Firefox, Safari, or Edge. Claude.ai drops support for old browser versions.

## Scenario 5: Claude Code CLI Issues

**Symptoms**: Claude Code crashes, hangs, or returns errors in the terminal.

### "ANTHROPIC_API_KEY not set"

```
Error: ANTHROPIC_API_KEY environment variable is not set
```

**Fix**:
```bash
export ANTHROPIC_API_KEY="sk-ant-your-key-here"
```

Add to your shell profile (`~/.zshrc` or `~/.bashrc`) for persistence. See our [beginner guide](/how-to-use-claude-code-beginner-guide/) for detailed setup.

### "Connection refused" or Network Errors

**Fixes**:
1. Check your internet connection
2. Check if a corporate firewall blocks api.anthropic.com
3. If using a VPN, try disconnecting
4. If using a proxy, ensure it forwards to Anthropic's API correctly

```bash
# Test connectivity
curl -I https://api.anthropic.com
```

### Claude Code Hangs (No Response)

**Cause**: Usually a large context or complex operation timing out.

**Fixes**:
1. Press Ctrl+C to cancel the current operation
2. Start a new session: exit and run `claude` again
3. Use `/compact` before large operations to reduce context
4. Check if extended thinking is consuming time (thinking tokens take longer)

### "Module not found" or Installation Errors

**Fix**: Reinstall Claude Code:
```bash
npm uninstall -g @anthropic-ai/claude-code
npm install -g @anthropic-ai/claude-code
```

If permission errors persist:
```bash
sudo npm install -g @anthropic-ai/claude-code
```

### Outdated Version

**Fix**: Update to the latest version:
```bash
npm update -g @anthropic-ai/claude-code
claude --version
```

Many "not working" issues are fixed in newer releases.

## Scenario 6: API Integration Issues

**Symptoms**: Your application that uses the Claude API stops working.

### Invalid API Key

```json
{"type":"error","error":{"type":"authentication_error","message":"invalid x-api-key"}}
```

**Fixes**:
1. Verify the key in console.anthropic.com
2. Generate a new key if the old one was revoked
3. Check for whitespace or invisible characters in the key
4. Ensure the key is sent in the `x-api-key` header (not `Authorization: Bearer`)

### Model Not Found

```json
{"type":"error","error":{"type":"not_found_error","message":"model: claude-xyz not found"}}
```

**Fix**: Use the exact model ID from Anthropic's documentation:
- `claude-opus-4-0520` (not "claude-opus-4" or "claude-4-opus")
- `claude-sonnet-4-20250514`
- `claude-3-5-haiku-20241022`

### Request Too Large

```json
{"type":"error","error":{"type":"invalid_request_error","message":"prompt is too long"}}
```

**Fix**: Reduce your input tokens below the model's context window (200K tokens). Options:
- Trim unnecessary context
- Summarize long documents before sending
- Use [prompt caching](/claude-api-pricing-complete-guide/) to handle repeated static content efficiently
- Split the request into smaller chunks

### Streaming Interrupted

**Symptoms**: Partial responses, cut-off text, or [connection drops mid-stream](/anthropic-sdk-streaming-connection-dropped-fix/).

**Fixes**:
1. Implement reconnection logic in your application
2. Check for network instability
3. Increase timeout settings
4. Reduce `max_tokens` to get shorter, more reliable responses

## Scenario 7: Regional Access Issues

**Symptoms**: Claude works from some locations but not others. VPN changes fix/break access.

**Causes**:
- Anthropic restricts access from certain countries
- Corporate networks blocking AI services
- ISP-level interference

**Fixes**:
1. Check Anthropic's supported regions list
2. If using a VPN, connect to a US or EU server
3. If on a corporate network, ask IT if api.anthropic.com is blocked
4. Try from a personal network to isolate the issue

*Need the complete toolkit? [The Claude Code Playbook](https://zovo.one/pricing) includes 200 production-ready templates.*

## Scenario 8: Specific Error Messages

### "Overloaded" / "The model is currently overloaded"

**Cause**: High demand on Anthropic's servers.

**Fixes**:
1. Wait 1-5 minutes and retry
2. Switch to a less popular model (Haiku is rarely overloaded)
3. Try during off-peak hours (US morning/late night)
4. For API users: implement retry with backoff

### "This conversation is too long"

**Cause**: Context window exceeded.

**Fixes**:
1. Start a new conversation
2. In Claude Code, use `/compact` to summarize and free context
3. Send shorter messages
4. Remove unnecessary files from the conversation

### "Something went wrong"

**Cause**: Generic server-side error. Could be anything.

**Fixes**:
1. Retry the same message
2. Simplify your prompt (remove complex formatting, reduce attachments)
3. Try a different model
4. If persistent, check status.anthropic.com

### "Unable to complete your request"

**Cause**: Content policy trigger, malformed request, or server issue.

**Fixes**:
1. Rephrase your request
2. Remove any content that might trigger content filters
3. If the request is legitimate, try breaking it into smaller parts
4. Contact support if you believe it is incorrectly filtered

## Prevention Strategies

### Set Up Monitoring

Do not wait for Claude to break. Set up proactive monitoring:

1. **Status page alerts**: Subscribe to status.anthropic.com updates
2. **Budget alerts**: Configure [spending notifications](/claude-code-cost-alerts-notifications-budget/) to catch credit exhaustion
3. **Health checks**: If running API integrations, add a ping endpoint that verifies Claude API connectivity

### Keep Software Updated

```bash
# Check for Claude Code updates weekly
npm outdated -g @anthropic-ai/claude-code

# Update
npm update -g @anthropic-ai/claude-code
```

### Document Your Configuration

Keep a record of your working configuration:
- API key location
- Environment variables set
- Proxy/VPN settings
- Claude Code version
- [CLAUDE.md configuration](/claude-md-best-practices-definitive-guide/)

When something breaks, you can compare against your known-working state.

### Have a Fallback Plan

For production systems, plan for Claude downtime:
- Queue messages and retry when service returns
- Fall back to a local model for simple tasks
- Use [OpenRouter](/claude-code-openrouter-setup-guide/) for multi-provider routing
- Document manual procedures for critical tasks

## Frequently Asked Questions

### How long do Claude outages usually last?
Most outages resolve within 30 minutes to 2 hours. Major incidents are rare and Anthropic communicates updates through status.anthropic.com.

### Does clearing my browser cache delete my conversations?
No. Conversations are stored server-side. Clearing cache only removes local session data. You will need to log in again.

### Why does Claude work on my phone but not my computer?
Usually a browser extension, VPN, or network configuration issue on your computer. Try incognito mode or a different browser to confirm.

### Can I get a refund for downtime?
Anthropic's subscription terms do not typically include SLA-based refunds for consumer plans. Enterprise plans may have different terms. Contact support for significant outages affecting paid plans.

### Why does Claude say "I can't help with that" when I ask a normal question?
This is a content policy false positive. Rephrase your question with different wording. If the topic is clearly harmless, try providing more context about why you are asking.

### Is there a way to check Claude's status programmatically?
Yes. Monitor status.anthropic.com or build a simple health check that makes a test API call:
```bash
curl -s -o /dev/null -w "%{http_code}" \
  -H "x-api-key: $ANTHROPIC_API_KEY" \
  -H "content-type: application/json" \
  -d '{"model":"claude-3-5-haiku-20241022","max_tokens":1,"messages":[{"role":"user","content":"hi"}]}' \
  https://api.anthropic.com/v1/messages
```
A 200 response means the API is operational.

### Why does Claude Code fail but Claude.ai works?
Claude Code uses the API, while Claude.ai uses a web interface with separate infrastructure. If the API is having issues but the web interface is not (or vice versa), they can fail independently. Also check that your API key is valid and has credits.

### Should I use a VPN with Claude?
Only if you are in a region where Anthropic restricts access. VPNs can sometimes cause issues (slow connections, IP-based rate limiting). If Claude works without a VPN, you do not need one.


{% raw %}
<script type="application/ld+json">
{
  "@context": "https://schema.org",
  "@type": "FAQPage",
  "mainEntity": [
    {
      "@type": "Question",
      "name": "### How long do Claude outages usually last?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "Most outages resolve within 30 minutes to 2 hours. Major incidents are rare and Anthropic communicates updates through status.anthropic.com."
      }
    },
    {
      "@type": "Question",
      "name": "Does clearing my browser cache delete my conversations?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "No. Conversations are stored server-side. Clearing cache only removes local session data. You will need to log in again."
      }
    },
    {
      "@type": "Question",
      "name": "Why does Claude work on my phone but not my computer?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "Usually a browser extension, VPN, or network configuration issue on your computer. Try incognito mode or a different browser to confirm."
      }
    },
    {
      "@type": "Question",
      "name": "Can I get a refund for downtime?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "Anthropic's subscription terms do not typically include SLA-based refunds for consumer plans. Enterprise plans may have different terms. Contact support for significant outages affecting paid plans."
      }
    },
    {
      "@type": "Question",
      "name": "Why does Claude say \\\"I can't help with that\\\" when I ask a normal question?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "This is a content policy false positive. Rephrase your question with different wording. If the topic is clearly harmless, try providing more context about why you are asking."
      }
    },
    {
      "@type": "Question",
      "name": "Is there a way to check Claude's status programmatically?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "Yes. Monitor status.anthropic.com or build a simple health check that makes a test API call: bash curl -s -o /dev/null -w \\\"%{httpcode}\\\" \\   -H \\\"x-api-key: $ANTHROPICAPIKEY\\\" \\   -H \\\"content-type: application/json\\\" \\   -d '{\\\"model\\\":\\\"claude-3-5-haiku-20241022\\\",\\\"maxtokens\\\":1,\\\"messages\\\":[{\\\"role\\\":\\\"user\\\",\\\"content\\\":\\\"hi\\\"}]}' \\   https://api.anthropic.com/v1/messages  A 200 response means the API is operational."
      }
    },
    {
      "@type": "Question",
      "name": "Why does Claude Code fail but Claude.ai works?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "Claude Code uses the API, while Claude.ai uses a web interface with separate infrastructure. If the API is having issues but the web interface is not (or vice versa), they can fail independently. Also check that your API key is valid and has credits."
      }
    },
    {
      "@type": "Question",
      "name": "Should I use a VPN with Claude?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "Only if you are in a region where Anthropic restricts access. VPNs can sometimes cause issues (slow connections, IP-based rate limiting). If Claude works without a VPN, you do not need one."
      }
    }
  ]
}
</script>

## See Also

- [Claude Rate Exceeded Error Fix](/claude-rate-exceeded-error-fix/)
- [Claude Internal Server Error Fix](/claude-internal-server-error-fix/)
- [Claude Code Process Exited Code 1 Fix](/claude-code-process-exited-code-1-fix/)


{% endraw %}