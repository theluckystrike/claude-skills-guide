---
layout: default
title: "Claude Code .env File Not Loaded — Fix (2026)"
description: "Fix Claude Code .env file not loaded in project scope. Source the file or use direnv for automatic loading. Step-by-step solution."
permalink: /claude-code-env-file-not-loaded-project-scope-fix/
date: 2026-04-20
last_tested: "2026-04-21"
---

## The Error

```
Error: ANTHROPIC_API_KEY is not set.
  (But it's defined in your .env file)

# Or when Claude Code runs your app:
Error: Missing required environment variable DATABASE_URL
  dotenv: .env file not found or not loaded

# Or:
process.env.API_SECRET is undefined
  (The .env file exists in the project root but variables aren't available)
```

## The Fix

1. **Source the .env file before starting Claude Code**

```bash
# Export all variables from .env into your shell
set -a && source .env && set +a

# Verify the variable is set
echo $ANTHROPIC_API_KEY | cut -c1-10
# Expected: First 10 chars of your key
```

2. **Use direnv for automatic loading (recommended)**

```bash
# Install direnv
brew install direnv  # macOS
# or: sudo apt install direnv  # Ubuntu

# Add to shell profile
echo 'eval "$(direnv hook zsh)"' >> ~/.zshrc
source ~/.zshrc

# Create .envrc that sources .env
echo 'dotenv' > .envrc
direnv allow
```

3. **Verify the fix:**

```bash
# Start Claude Code and verify env vars are available
claude -p "Run: echo \$ANTHROPIC_API_KEY | cut -c1-10" --trust --yes
# Expected: First 10 characters of your API key printed
```

## Why This Happens

`.env` files are not automatically loaded by the shell or by Claude Code. They require explicit loading via `source`, `dotenv` (in Node.js), or a tool like `direnv`. When you start Claude Code from a terminal, it inherits only the shell's current environment variables — not variables defined in `.env` files. Node.js applications typically use the `dotenv` package to load these at runtime, but Claude Code's own process doesn't call `dotenv.config()` on your project's `.env` file.

## If That Doesn't Work

- **Alternative 1:** Add the variables to your shell profile (`~/.zshrc`) for persistent availability across all terminals
- **Alternative 2:** Pass variables inline: `ANTHROPIC_API_KEY=sk-ant-... claude -p "test"`
- **Check:** Run `env | grep -c "."` inside and outside the project directory to compare which variables are loaded

## Prevention

Add to your `CLAUDE.md`:
```markdown
Use direnv with a .envrc file containing `dotenv` to auto-load .env variables. Never commit .env files to git — use .env.example as a template. Verify required environment variables are set before starting long Claude Code sessions.
```

**Related articles:** [Config File Location](/claude-code-config-file-location/), [Invalid API Key After Rotation](/claude-code-error-invalid-api-key-after-rotation-fix/), [Troubleshooting Hub](/troubleshooting-hub/)

## See Also

- [.env File Not Loaded by Claude Fix](/claude-code-env-file-not-loaded-fix-2026/)


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




**Find the right skill →** Browse 155+ skills in our [Skill Finder](/skill-finder/).

## Related Guides

**Try it:** Paste your error into our [Error Diagnostic](/diagnose/) for an instant fix.

- [Optimal Skill File Size and Complexity](/optimal-skill-file-size-and-complexity-guidelines/)
- [Claude Code Large File Refactoring](/best-way-to-use-claude-code-for-large-file-refactoring/)
- [Declaration File .d.ts Missing Error — Fix (2026)](/claude-code-declaration-file-dts-missing-fix-2026/)
- [Claude Code Enoent No Such File](/claude-code-enoent-no-such-file-directory-skill/)

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
