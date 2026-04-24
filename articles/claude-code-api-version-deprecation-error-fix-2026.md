---
title: "API Version Deprecated Error — Fix (2026)"
permalink: /claude-code-api-version-deprecation-error-fix-2026/
description: "Fix 'API version deprecated' error by updating anthropic-version header. Upgrade SDK to get the latest supported version."
last_tested: "2026-04-22"
---

## The Error

```
Error 400: API version '2023-01-01' is deprecated. Minimum supported version is '2023-06-01'. Please update the anthropic-version header.
```

This error occurs when your SDK or manual API calls use a deprecated `anthropic-version` header value. Anthropic periodically sunsets old API versions.

## The Fix

1. Update the Anthropic SDK to the latest version:

```bash
pip install --upgrade anthropic
# or for Node.js
npm install @anthropic-ai/sdk@latest
```

2. If making direct HTTP calls, update the header:

```bash
curl https://api.anthropic.com/v1/messages \
  -H "anthropic-version: 2023-06-01" \
  -H "x-api-key: $ANTHROPIC_API_KEY" \
  -H "content-type: application/json" \
  -d '{"model":"claude-sonnet-4-20250514","max_tokens":100,"messages":[{"role":"user","content":"test"}]}'
```

3. Verify Claude Code itself is up to date:

```bash
claude --version
npm update -g @anthropic-ai/claude-code
```

## Why This Happens

Anthropic uses API versioning to evolve the message format, tool schemas, and response structures. Older versions eventually become unsupported as breaking changes accumulate. The SDK normally sets the correct version automatically, but pinned dependencies or old SDK versions send outdated headers.

## If That Doesn't Work

- Check if your code manually sets the version header, overriding the SDK:

```bash
grep -r "anthropic-version" . --include="*.py" --include="*.ts" --include="*.js"
```

- Check your lockfile for a pinned SDK version:

```bash
pip show anthropic | grep Version
# or
npm ls @anthropic-ai/sdk
```

- If using a wrapper library, check that it has been updated to support the current API version.

## Prevention

Add this to your `CLAUDE.md`:

```markdown
# SDK Version
- Keep @anthropic-ai/sdk at latest. Run npm update weekly.
- Never hardcode anthropic-version header — let the SDK manage it.
- Pin SDK major version only (e.g., ^1.0.0), allow minor/patch updates.
```

## Related Error Messages

This fix also applies if you see these related error messages:

- `npm ERR! code EACCES`
- `npm ERR! code ERESOLVE`
- `npm ERR! peer dep missing`
- `TokenLimitExceeded: max tokens reached`
- `Error: output truncated at max_tokens`

## Frequently Asked Questions

### Should I use npm or pnpm with Claude Code?

Claude Code works with any Node.js package manager. If your project uses pnpm, add `Use pnpm instead of npm for all package operations` to your CLAUDE.md so Claude Code respects your toolchain choice.

### Why does Claude Code sometimes run npm commands that fail?

Claude Code infers the package manager from lock files. If both `package-lock.json` and `pnpm-lock.yaml` exist, it may pick the wrong one. Delete the unused lock file or add an explicit instruction in CLAUDE.md.

### How do I verify my npm installation is working?

Run `npm doctor` to check your npm environment. It validates the registry connection, permissions, cache integrity, and Node.js compatibility in one command.

### What causes token count mismatches?

Token counts are estimated before sending a request and precisely calculated on the server. The estimation uses a fast local tokenizer that may differ slightly from the server's tokenizer. Small discrepancies (1-3%) are normal and do not affect functionality.


## Related Guides

- [CLAUDE.md Version Control Strategies](/claude-md-version-control-strategies/)
- [Claude Code for Version Matrix Workflow](/claude-code-for-version-matrix-workflow-tutorial-guide/)
- [Claude Code Version History and Changes](/claude-code-version-history-changes-2026/)
- [TLS Version Negotiation Failure — Fix](/claude-code-tls-version-negotiation-failure-fix-2026/)

## Implementation Details

When working with this in Claude Code, pay attention to these practical details:

**Project configuration.** Add specific instructions to your CLAUDE.md file describing how your project handles this area. Include file paths, naming conventions, and any patterns that differ from common defaults. Claude Code reads CLAUDE.md at the start of every session and uses it to guide all operations.

**Testing the setup.** After configuration, verify everything works by running a simple test task. Ask Claude Code to perform a read-only operation first (like listing files or reading a config) before moving to write operations. This confirms that permissions, paths, and tools are all correctly configured.

**Monitoring and iteration.** Track your results over several sessions. If Claude Code consistently makes the same mistake, the fix is usually a more specific CLAUDE.md instruction. If it makes different mistakes each time, the issue is likely in the project setup or toolchain configuration.

## Troubleshooting Checklist

When something does not work as expected, check these items in order:

1. **CLAUDE.md exists at the project root** — run `ls -la CLAUDE.md` to verify
2. **Node.js version is 18+** — run `node --version` to check
3. **API key is set** — run `echo $ANTHROPIC_API_KEY | head -c 10` to verify (shows first 10 characters only)
4. **Disk space is available** — run `df -h .` to check
5. **Network can reach the API** — run `curl -s -o /dev/null -w "%{http_code}" https://api.anthropic.com` (should return 401 without auth, meaning the server is reachable)
6. **No conflicting processes** — run `ps aux | grep claude | grep -v grep` to check for stale sessions
