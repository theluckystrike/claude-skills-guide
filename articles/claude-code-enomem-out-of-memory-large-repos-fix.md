---
title: "Claude Code ENOMEM Out of Memory Large (2026)"
description: "Fix Claude Code ENOMEM out of memory on large repos. Increase Node.js heap and exclude heavy directories. Step-by-step solution."
permalink: /claude-code-enomem-out-of-memory-large-repos-fix/
last_tested: "2026-04-21"
---

## The Error

```
FATAL ERROR: Reached heap limit Allocation failed - JavaScript heap out of memory
 1: 0x100a4c0d4 node::Abort() [/usr/local/bin/node]
 2: 0x100a4c248 node::OOMErrorHandler(char const*, v8::OOMDetails const&)

# Or:
Error: ENOMEM: not enough memory, read
    at Object.readSync (node:fs:735:3)
    at readFileSync (node:fs:623:35)
```

## The Fix

1. **Increase Node.js heap size for Claude Code**

```bash
export NODE_OPTIONS="--max-old-space-size=8192"
claude
```

2. **Add a .claudeignore file to exclude heavy directories**

```bash
cat > .claudeignore << 'EOF'
node_modules/
.git/objects/
dist/
build/
*.min.js
*.bundle.js
data/
*.sqlite
*.db
EOF
```

3. **Verify the fix:**

```bash
NODE_OPTIONS="--max-old-space-size=8192" claude --version
# Expected: @anthropic-ai/claude-code/X.X.X (no OOM crash)

# Check current memory limit:
node -e "console.log('Heap limit:', (v8.getHeapStatistics().heap_size_limit / 1024 / 1024).toFixed(0), 'MB')"
# Expected: Heap limit: 8192 MB
```

## Why This Happens

Claude Code indexes files in your working directory to build context for the AI. On repositories with hundreds of thousands of files (monorepos, repos with vendored dependencies, or large data directories), this indexing process exhausts Node.js's default heap limit of ~4 GB. The V8 engine throws a fatal OOM error and the process crashes. The `.claudeignore` file tells Claude Code to skip directories that don't need AI analysis.

## If That Doesn't Work

- **Alternative 1:** Run Claude Code from a subdirectory — `cd src/ && claude` — to limit the scope of file discovery
- **Alternative 2:** Set heap even higher for very large repos: `NODE_OPTIONS="--max-old-space-size=16384"` (16 GB)
- **Check:** Run `find . -not -path '*/node_modules/*' -not -path '*/.git/*' | wc -l` to count files Claude Code will scan

## Prevention

Add to your `CLAUDE.md`:
```markdown
Always create a .claudeignore excluding node_modules, .git/objects, dist, build, and data directories. For repos with over 50K files, set NODE_OPTIONS="--max-old-space-size=8192" in shell profile. Run Claude Code from the most specific subdirectory possible.
```

The OOM threshold depends on how many files Claude Code indexes at startup. Monorepos with vendored dependencies like `node_modules`, Go vendor directories, or Python virtual environments can contain hundreds of thousands of files. The `.claudeignore` approach is more effective than increasing heap alone because it reduces the total number of files that need indexing.

**Related articles:** [Claude Code Out of Memory Fix](/claude-code-error-out-of-memory-large-codebase-fix/), [Claude Code Slow Response Fix](/claude-code-slow-response-fix/), [Claude Code Not Responding Fix](/claude-code-not-responding-terminal-hangs-fix/)

## See Also

- [Claude Code pnpm Lock File Out of Sync — Fix (2026)](/claude-code-pnpm-lock-file-out-of-sync-fix/)


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

- [Fix: Anthropic SDK Grammar Too Large](/anthropic-sdk-structured-output-grammar-too-large/)
- [Claude Code Large File Refactoring](/best-way-to-use-claude-code-for-large-file-refactoring/)
- [Fix Claude Code Large File Crashes](/claude-code-crashes-on-large-files-how-to-fix/)
- [Claude Code git diff too large --](/claude-code-git-diff-too-large-reducing-context/)

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
