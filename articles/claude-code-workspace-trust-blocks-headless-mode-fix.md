---
title: "Claude Code Workspace Trust Blocks (2026)"
description: "Fix Claude Code workspace trust dialog blocking headless and CI mode. Pre-approve directories with settings.json. Step-by-step solution."
permalink: /claude-code-workspace-trust-blocks-headless-mode-fix/
last_tested: "2026-04-21"
---

## The Error

```
? Do you trust the files in this workspace?
  This workspace contains a CLAUDE.md file that may modify Claude's behavior.
  [Trust] [Don't Trust] [Cancel]

# In CI/headless:
Error: Interactive prompt required but running in non-interactive mode.
  Cannot display workspace trust dialog.
  Set CLAUDE_CODE_TRUST_WORKSPACE=1 or use --trust flag.
```

## The Fix

1. **Pass the trust flag for headless/CI execution**

```bash
# Single command execution
claude --trust --yes -p "Run the test suite"

# Or set the environment variable
export CLAUDE_CODE_TRUST_WORKSPACE=1
claude -p "Run the test suite"
```

2. **Pre-approve specific directories in settings**

```bash
mkdir -p ~/.claude
cat > ~/.claude/settings.json << 'EOF'
{
  "trustedDirectories": [
    "/home/runner/work",
    "/Users/you/projects"
  ],
  "permissions": {
    "allow": ["Bash", "Read", "Write", "Edit"]
  }
}
EOF
```

3. **Verify the fix:**

```bash
CLAUDE_CODE_TRUST_WORKSPACE=1 claude --version
# Expected: Version prints without trust prompt
```

## Why This Happens

Claude Code's workspace trust system is a security feature that prevents untrusted `CLAUDE.md` files from automatically modifying Claude's behavior. When you open a project for the first time, or in a CI pipeline where there's no persistent trust state, Claude Code prompts for confirmation. In headless mode (piped input, CI runners, Docker containers), there's no TTY to display the prompt, so the process errors out. This is intentional — it prevents supply-chain attacks via malicious `CLAUDE.md` files in cloned repositories.

## If That Doesn't Work

- **Alternative 1:** In GitHub Actions, add the trust env var to your workflow: `env: { CLAUDE_CODE_TRUST_WORKSPACE: "1" }`
- **Alternative 2:** Remove the `CLAUDE.md` from the workspace if you don't need it: `mv CLAUDE.md CLAUDE.md.disabled`
- **Check:** Run `cat ~/.claude/settings.json` to see if your trusted directories list includes the current workspace path

## Prevention

Add to your `CLAUDE.md`:
```markdown
In CI, always pass --trust --yes flags or set CLAUDE_CODE_TRUST_WORKSPACE=1. Add working directories to trustedDirectories in ~/.claude/settings.json for persistent trust.
```

For Docker-based CI runners, bake the trust environment variable into the container image or pass it via `docker run -e CLAUDE_CODE_TRUST_WORKSPACE=1` so every containerized invocation runs without the trust prompt.

**Related articles:** [Workspace Trust Required Fix](/claude-code-workspace-trust-required-fix-2026/), [GitHub Actions Setup](/claude-code-github-actions-setup-guide/), [Config File Location](/claude-code-config-file-location/)

## See Also

- [Workspace Trust Blocking Execution Fix](/claude-code-workspace-trust-blocking-execution-fix-2026/)


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

- [Fix Claude Code Incomplete Code Blocks](/why-does-claude-code-produce-incomplete-code-blocks-fix/)
- [Chrome Enterprise Device Trust](/chrome-enterprise-device-trust-connector/)
- [Claude Code Zero Trust Security](/claude-code-for-zero-trust-security-workflow-guide/)
- [MCP Zero Trust Architecture](/mcp-zero-trust-architecture-implementation/)

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
        "text": "This error can occur on macOS, Linux, and Windows (WSL). The exact error message may differ slightly between platforms, but the root cause and fix are the same. macOS users may see additional Gatekeeper or notarization prompts. Linux users should check that the relevant system packages are installed. Windows users should ensure they are running inside WSL2, not native Windows."
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
        "text": "No, this error occurs before or during an operation and does not corrupt existing files. Claude Code's edit operations are atomic — they either complete fully or not at all. However, if the error occurs during a multi-step operation, you may have partial changes that need to be reviewed with `git diff` before continuing."
      }
    },
    {
      "@type": "Question",
      "name": "How do I report this error to Anthropic if the fix does not work?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "Open an issue at github.com/anthropics/claude-code with: (1) the full error message including stack trace, (2) your Node.js version (`node --version`), (3) your Claude Code version (`claude --version`), (4) your operating system and version, and (5) the command or operation that triggered the error."
      }
    }
  ]
}
</script>
