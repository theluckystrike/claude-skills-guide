---
layout: default
title: "Claude Code CLAUDE.md Not Found Fix (2026)"
description: "Fix Claude Code CLAUDE.md not found in parent directories. Create the file in the correct project root location. Step-by-step solution."
permalink: /claude-code-claude-md-not-found-parent-directories-fix/
date: 2026-04-20
last_tested: "2026-04-21"
---

## The Error

```
Warning: No CLAUDE.md found in current directory or parent directories.
  Claude Code will use default behavior without project-specific instructions.
  Searched: /Users/you/projects/myapp/src/components/
            /Users/you/projects/myapp/src/
            /Users/you/projects/myapp/
            /Users/you/projects/
            /Users/you/

# Or when instructions seem to be ignored:
# Claude Code runs but doesn't follow rules you wrote in CLAUDE.md
```

## The Fix

1. **Place CLAUDE.md in your project root (next to package.json or .git)**

```bash
# Find your project root
git rev-parse --show-toplevel 2>/dev/null || pwd

# Create CLAUDE.md there
cat > "$(git rev-parse --show-toplevel)/CLAUDE.md" << 'EOF'
# Project Instructions

## Code Style
- Use TypeScript strict mode
- Format with Prettier (config in .prettierrc)
- Lint with ESLint before committing

## Architecture
- src/components/ for React components
- src/utils/ for shared utilities
- src/api/ for API client code
EOF
```

2. **Verify Claude Code finds it**

```bash
# cd to the project root
cd "$(git rev-parse --show-toplevel)"

# Start Claude Code and check
claude -p "What instructions do you see in CLAUDE.md?"
```

3. **Verify the fix:**

```bash
ls -la "$(git rev-parse --show-toplevel)/CLAUDE.md"
# Expected: -rw-r--r-- ... CLAUDE.md (file exists at project root)

claude -p "Summarize your project instructions" --trust --yes
# Expected: Claude describes the rules from your CLAUDE.md
```

## Why This Happens

Claude Code searches for `CLAUDE.md` by walking up the directory tree from your current working directory to the filesystem root. If you start Claude Code from a deeply nested directory and the CLAUDE.md is not in any parent directory, the search fails silently. Common causes: the file is named `claude.md` (wrong case on case-sensitive filesystems), placed in a subdirectory instead of the root, or the file is in the home directory but you're working in a different tree. Claude Code also supports `.claude/CLAUDE.md` as an alternative location.

## If That Doesn't Work

- **Alternative 1:** Use the home-level CLAUDE.md at `~/.claude/CLAUDE.md` for global instructions that apply to all projects
- **Alternative 2:** Check file permissions — `chmod 644 CLAUDE.md` — Claude Code needs read access
- **Check:** Run `find . -maxdepth 3 -iname "claude.md" -o -iname "claude.md"` to find misplaced files

## Prevention

Add to your `CLAUDE.md`:
```markdown
This file should be at the git repository root, next to package.json. Always start Claude Code from the project root directory, not a subdirectory. Maintain both project CLAUDE.md and ~/.claude/CLAUDE.md for global defaults.
```

On case-sensitive filesystems like Linux ext4, `claude.md` and `CLAUDE.md` are different files. Claude Code only recognizes the uppercase `CLAUDE.md` filename. Verify the exact case with `ls -la | grep -i claude` in your project root.

**Related articles:** [CLAUDE.md Not Being Read Fix](/claude-md-not-being-read-by-claude-code-fix/), [How to Fix Claude Ignoring CLAUDE.md](/how-to-fix-claude-code-ignoring-my-claude-md-file/), [Config File Location](/claude-code-config-file-location/)

## See Also

- [CLAUDE.md Not Loading in Claude Code — Fix Guide (2026)](/claude-md-not-loading-fix/)


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

- [CLAUDE.md for Database Conventions](/claude-md-database-conventions/)
- [CLAUDE.md for Architecture Decisions](/claude-md-for-architecture-decisions/)
- [CLAUDE.md Length Optimization](/claude-md-length-optimization/)
- [CLAUDE.md for Security Rules](/claude-md-security-rules/)

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
