---
layout: default
title: "ANTHROPIC_API_KEY Not Set in Subprocess (2026)"
permalink: /claude-code-anthropic-api-key-not-set-subprocess-fix-2026/
date: 2026-04-20
description: "Fix ANTHROPIC_API_KEY not set in subprocess spawned by Claude Code. Export the key in shell profile or pass it explicitly to child process environments."
last_tested: "2026-04-22"
---

## The Error

```
Error: ANTHROPIC_API_KEY environment variable is not set
  Subprocess spawned by Claude Code cannot authenticate
  Parent process has the key, but child process does not inherit it
  at ApiClient.validateKey (api-client.js:12)
```

This appears when a script or tool spawned by Claude Code tries to use the Anthropic API but cannot access the API key because it was not exported to child process environments.

## The Fix

```bash
export ANTHROPIC_API_KEY="sk-ant-..."
```

1. Ensure the API key is `export`ed (not just `set`) so child processes inherit it.
2. Add the export to your `~/.zshrc` or `~/.bashrc` for persistence.
3. Verify it propagates: `env | grep ANTHROPIC_API_KEY`.

## Why This Happens

In Unix shells, variables set with `VAR=value` are local to the current shell. Only `export VAR=value` makes them available to child processes. If you set `ANTHROPIC_API_KEY` without `export` in a shell config file, or if you set it in a parent shell but the child process (like a Python script calling the Anthropic SDK) starts in a new environment, the key is not inherited. Docker containers, CI runners, and subshells each have their own environment.

## If That Doesn't Work

Check if the key is actually exported:

```bash
env | grep ANTHROPIC
# vs
set | grep ANTHROPIC  # shows local vars too
```

Pass the key explicitly to a subprocess:

```bash
ANTHROPIC_API_KEY="$ANTHROPIC_API_KEY" python script.py
```

For Docker containers, pass it as a build arg or runtime env:

```bash
docker run -e ANTHROPIC_API_KEY="$ANTHROPIC_API_KEY" my-image
```

Check for shadowed variable names:

```bash
grep -r "ANTHROPIC_API_KEY" ~/.zshrc ~/.bashrc ~/.profile
```

## Prevention

```markdown
# CLAUDE.md rule
Ensure ANTHROPIC_API_KEY is exported (not just set) in your shell profile. Verify with 'env | grep ANTHROPIC_API_KEY'. For Docker and CI, pass the key explicitly via -e flag or secrets.
```

## See Also

- [Locale LC_ALL Not Set Encoding Errors Fix](/claude-code-locale-lc-all-not-set-encoding-errors-fix-2026/)
- [API Key Region Mismatch eu-west-1 — Fix (2026)](/claude-code-anthropic-api-key-region-mismatch-fix-2026/)


## Related Error Messages

This fix also applies if you see variations of this error:

- Connection or process errors with similar root causes in the same subsystem
- Timeout variants where the operation starts but does not complete
- Permission variants where access is denied to the same resource
- Configuration variants where the same setting is missing or malformed

If your specific error message differs slightly from the one shown above, the fix is likely the same. The key indicator is the operation that failed (shown in the stack trace) rather than the exact wording of the message.


## Frequently Asked Questions

### Does this error affect all operating systems?

This error can occur on macOS, Linux, and Windows (WSL). The exact error message may differ slightly between platforms, but the root cause and fix are the same. macOS users may see additional Gatekeeper or notarization prompts. Linux users should check that the relevant system packages are installed. Windows users should ensure they are running inside WSL2, not native Windows.

### Will this error come back after updating Claude Code?

Updates can occasionally reintroduce this error if the update changes default configurations or dependency requirements. After updating Claude Code, verify your project still builds and runs correctly. If the error returns, reapply the fix and check the changelog for breaking changes.

### Can this error cause data loss?

No, this error occurs before or during an operation and does not corrupt existing files. Claude Code's edit operations are atomic — they either complete fully or not at all. However, if the error occurs during a multi-step operation, you may have partial changes that need to be reviewed with `git diff` before continuing.

### How do I report this error to Anthropic if the fix does not work?

Open an issue at github.com/anthropics/claude-code with: (1) the full error message including stack trace, (2) your Node.js version (`node --version`), (3) your Claude Code version (`claude --version`), (4) your operating system and version, and (5) the command or operation that triggered the error.


## Related Guides

- [How to Set ANTHROPIC_API_KEY for Claude](/how-to-set-anthropicapikey-for-claude/)
- [API Endpoint Testing Workflow](/claude-code-api-endpoint-testing-guide/)
- [Claude Code for Health Endpoint Pattern](/claude-code-for-health-endpoint-pattern-workflow/)
- [Fix Claude Code Request Timed Out](/claude-code-fetch-failed-network-request-skill-error/)

<script type="application/ld+json">
{
  "@context": "https://schema.org",
  "@type": "FAQPage",
  "mainEntity": [
    {
      "@type": "Question",
      "name": "Does this error affect all operating systems?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "This error can occur on macOS, Linux, and Windows (WSL). The exact error message may differ slightly between platforms, but the root cause and fix are the same. macOS users may see additional Gatekeeper or notarization prompts."
      }
    },
    {
      "@type": "Question",
      "name": "Will this error come back after updating Claude Code?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "Updates can occasionally reintroduce this error if the update changes default configurations or dependency requirements. After updating Claude Code, verify your project still builds and runs correctly. If the error returns, reapply the fix and check the changelog for breaking changes."
      }
    },
    {
      "@type": "Question",
      "name": "Can this error cause data loss?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "No, this error occurs before or during an operation and does not corrupt existing files. Claude Code's edit operations are atomic — they either complete fully or not at all. However, if the error occurs during a multi-step operation, you may have partial changes that need to be reviewed with git..."
      }
    },
    {
      "@type": "Question",
      "name": "How do I report this error to Anthropic if the fix does not work?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "Open an issue at github.com/anthropics/claude-code with: (1) the full error message including stack trace, (2) your Node.js version (node --version), (3) your Claude Code version (claude --version), (4) your operating system and version, and (5) the command or operation that triggered the error."
      }
    }
  ]
}
</script>
