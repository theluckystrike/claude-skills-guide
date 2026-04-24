---
title: "Organization Billing Suspended Error"
permalink: /claude-code-organization-billing-suspended-fix-2026/
description: "Fix 'organization billing suspended' API error. Update payment method in Anthropic Console to restore access immediately."
last_tested: "2026-04-22"
render_with_liquid: false
---

## The Error

```
Error 403: Your organization's billing has been suspended. Please update your payment method at console.anthropic.com/settings/billing
```

This error blocks all API requests when your organization's payment method has failed or your prepaid credits have been exhausted.

## The Fix

1. Update your payment method immediately:

```bash
open https://console.anthropic.com/settings/billing
```

2. Add a valid credit card or update the existing one.

3. If using prepaid credits, purchase additional credits on the billing page.

4. Test that access is restored:

```bash
claude "hello world"
```

API access typically resumes within 60 seconds of a successful payment method update.

## Why This Happens

Anthropic suspends billing when a charge fails (expired card, insufficient funds, fraud hold) or when prepaid credits hit zero. The suspension is at the organization level, so all API keys under that org stop working simultaneously. This is a hard block — no requests are processed, not even cached ones.

## If That Doesn't Work

- Check if you are an org admin (only admins can update billing):

```bash
open https://console.anthropic.com/settings/members
```

- If you are not an admin, contact your org admin to update the payment method.

- If the card is valid but still failing, contact Anthropic support:

```bash
open https://support.anthropic.com
```

- Try a different payment method (some banks block charges to AI companies).

## Prevention

Add this to your `CLAUDE.md`:

```markdown
# Billing
- Set up billing alerts at $50, $100, $500 thresholds in Anthropic Console.
- Keep a backup payment method on file.
- Monitor usage weekly: console.anthropic.com/settings/usage
```

## Related Error Messages

This fix also applies if you see these related error messages:

- `AuthenticationError: invalid x-api-key`
- `Error: API key not found in environment`
- `401 Unauthorized: invalid_api_key`
- `Warning: stale cache detected, clearing`
- `CacheError: unable to read cache file`

## Frequently Asked Questions

### Where should I store my Anthropic API key?

Store it in the `ANTHROPIC_API_KEY` environment variable in your shell profile (`~/.bashrc`, `~/.zshrc`). Never hardcode API keys in source code or commit them to version control. For CI/CD, use your platform's secrets manager.

### How do I rotate my API key?

Generate a new key at console.anthropic.com, update the `ANTHROPIC_API_KEY` environment variable, then reload your shell with `source ~/.zshrc`. The old key is revoked when you delete it from the console. Active sessions using the old key will fail after the key is deleted.

### Can I use different API keys for different projects?

Yes. Set the `ANTHROPIC_API_KEY` in a project-level `.env` file or use direnv to automatically load project-specific environment variables when you enter a directory. Claude Code reads the key from the environment, so per-directory env files work seamlessly.

### What does Claude Code cache?

Claude Code caches search indexes, file metadata, and session state in `.claude/cache/` within the project directory and `~/.claude/cache/` globally. Caches speed up repeated operations but can become stale after external changes.
