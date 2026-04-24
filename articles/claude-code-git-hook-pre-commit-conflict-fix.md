---
title: "Claude Code Git Hook Pre-commit (2026)"
description: "Fix Claude Code git hook pre-commit conflict blocking commits. Configure hooks to work with AI-generated code. Step-by-step solution."
permalink: /claude-code-git-hook-pre-commit-conflict-fix/
last_tested: "2026-04-21"
---

## The Error

```
husky - pre-commit hook exited with code 1 (error)

hint: The '.husky/pre-commit' hook was ignored because it's not set as executable.
hint: You can disable this warning with `git config advice.ignoredHook false`.

# Or:
lint-staged: Running tasks for staged files...
  ✖ eslint --fix failed
  ✖ prettier --write failed
  ERROR: Pre-commit hook failed. Claude Code commit aborted.
```

## The Fix

1. **Make hooks executable and check what's running**

```bash
# List all hooks
ls -la .husky/ .git/hooks/

# Make hooks executable
chmod +x .husky/pre-commit
chmod +x .husky/_/husky.sh
```

2. **Run the pre-commit check manually to see exact errors**

```bash
# Run lint-staged directly to see what fails
npx lint-staged --debug

# Or run the hook manually
bash .husky/pre-commit
```

3. **Verify the fix:**

```bash
# Stage a test change and commit
echo "// test" >> test-temp.js
git add test-temp.js
git commit -m "test: verify pre-commit hook"
git reset HEAD~1
rm test-temp.js
# Expected: Commit succeeds without hook errors
```

## Why This Happens

Claude Code creates and stages files, then attempts to commit. Pre-commit hooks (typically lint-staged + husky) run formatters and linters on the staged files. Claude-generated code may not match your project's exact ESLint or Prettier configuration, causing the hook to fail. Additionally, husky hooks created on one OS may lose their executable bit when checked out on another, or after a fresh `git clone` where `husky install` wasn't run.

## If That Doesn't Work

- **Alternative 1:** Add auto-fix to your lint-staged config so it repairs issues instead of failing: `"*.ts": ["eslint --fix", "prettier --write"]`
- **Alternative 2:** Update your `CLAUDE.md` to tell Claude Code about your lint rules so it generates compliant code from the start
- **Check:** Run `git config core.hooksPath` to verify hooks are pointed at the right directory (should be `.husky` or `.git/hooks`)

## Prevention

Add to your `CLAUDE.md`:
```markdown
Before committing, run `npx lint-staged` to verify all staged files pass. Follow the ESLint and Prettier configs in this project exactly. After generating code, always run the project formatter before staging.
```

**Related articles:** [Claude Code Git Hook Blocked Commit](/claude-code-git-hook-blocked-commit-fix-2026/), [ESLint Prettier Conflict Fix](/claude-code-eslint-prettier-conflict-fix/), [Debugging Tips](/claude-code-verbose-mode-debugging-tips/)

## See Also

- [Pre-Commit Hook Failure on Claude Changes Fix](/claude-code-pre-commit-hook-failure-fix-2026/)
- [Git Submodule Not Initialized Error Fix](/claude-code-submodule-not-initialized-fix-2026/)


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

- [Claude Code Hook Script Not Executable — Fix (2026)](/claude-code-hook-script-not-executable-fix-2026/)
- [Write Your First Claude Code Hook](/how-to-write-claude-code-hook-2026/)
- [Fix Claude Code Poor Commit Messages](/claude-code-poor-commit-messages-fix-2026/)
- [Claude Code Git Commit Message](/claude-code-git-commit-message-generator-guide/)

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
