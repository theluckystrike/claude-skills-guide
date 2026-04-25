---
layout: default
title: "Fix Claude Code Touching Unrelated (2026)"
description: "Diagnose and fix Claude Code's habit of modifying files outside the task scope — with CLAUDE.md rules, scope declarations, and diff audits."
permalink: /karpathy-surgical-changes-debugging-2026/
date: 2026-04-20
last_tested: "2026-04-22"
---

# Fix Claude Code Touching Unrelated Files (2026)

You asked Claude Code to fix a bug in `auth.ts` and it also modified `config.ts`, `types.ts`, and `utils.ts`. Here's why it happens and how to stop it.

## The Problem

Claude Code modifies files outside the task's scope. Common patterns:
- Fixing a bug in file A but also "improving" files B and C
- Adding a feature that touches 3 files but getting changes in 8
- Reformatting imports, adding types, or renaming variables in files it opened for reference

## Root Cause

Claude Code reads files to understand context. When it reads a file, it also notices issues — missing types, inconsistent formatting, suboptimal patterns. Without scope constraints, it "fixes" these issues alongside the actual task.

The agent treats every opened file as a potential modification target. Reading `config.ts` to check a value becomes "while I'm here, let me also restructure this config."

## The Fix

### Step 1: Add Scope Declaration Rules

```markdown
## File Scope Control
Before making any changes, declare which files will be modified and why.
Format:
- **[filename]** — [reason this file must change for the task]

Do NOT modify any file not in this list. If you discover a file needs
changing mid-implementation, update the list and explain before modifying.
```

### Step 2: Separate Read from Write

```markdown
## Read vs. Write
You may READ any file for context. Reading a file does NOT give you
permission to modify it. Only modify files that must change for the
current task to work.
```

### Step 3: Add a Diff Audit Step

```markdown
## Post-Change Audit
After completing changes, list every file modified and justify each:
- **[filename]** — [why this change was necessary for the task]

If you cannot justify a modification with "this must change for the task
to work," revert it.
```

## CLAUDE.md Rule to Add

```markdown
## Scope Discipline
1. Declare files to modify before starting
2. Reading a file ≠ permission to edit it
3. Every modified file needs a task-related justification
4. "While I'm here" improvements go in "Noticed but not fixed" list
5. Reformatting (whitespace, imports, semicolons) in unrelated files is prohibited
```

## Verification

Test with a scoped task:

```
Fix the null pointer error in src/services/user-service.ts line 42
```

**Bad output:** modifies `user-service.ts`, `types/user.ts`, `utils/validation.ts`, and `index.ts`
**Good output:** modifies only `user-service.ts`, reports noticed issues elsewhere

Check the diff. If files beyond the stated scope are modified, strengthen the rules.

## Common Mistakes

1. **Not distinguishing necessary cross-file changes** — sometimes a fix genuinely requires changing multiple files (e.g., updating an interface requires updating its implementations). The rule is "necessary changes only," not "one file only."

2. **Forgetting about test files** — fixing a bug may require updating a test. That's a valid cross-file change. The scope declaration should include tests.

3. **Being too strict during refactoring tasks** — if the task IS a refactor, touching many files is expected. Scope rules apply to non-refactoring tasks.

## Related Principles

- [Surgical Changes Principle](/karpathy-surgical-changes-principle-2026/) — the underlying principle
- [Stop Claude Code Touching Unrelated Files](/claude-code-touches-unrelated-files-fix-2026/) — problem-specific guide
- [CLAUDE.md Best Practices](/claude-md-best-practices-10-templates-compared-2026/) — structuring scope rules


## Frequently Asked Questions

### Does this error affect all operating systems?

This error can occur on macOS, Linux, and Windows (WSL). The exact error message may differ slightly between platforms, but the root cause and fix are the same. macOS users may see additional Gatekeeper or notarization prompts. Linux users should check that the relevant system packages are installed. Windows users should ensure they are running inside WSL2, not native Windows.

### Will this error come back after updating Claude Code?

Updates can occasionally reintroduce this error if the update changes default configurations or dependency requirements. After updating Claude Code, verify your project still builds and runs correctly. If the error returns, reapply the fix and check the changelog for breaking changes.

### Can this error cause data loss?

No, this error occurs before or during an operation and does not corrupt existing files. Claude Code's edit operations are atomic — they either complete fully or not at all. However, if the error occurs during a multi-step operation, you may have partial changes that need to be reviewed with `git diff` before continuing.

### How do I report this error to Anthropic if the fix does not work?

Open an issue at github.com/anthropics/claude-code with: (1) the full error message including stack trace, (2) your Node.js version (`node --version`), (3) your Claude Code version (`claude --version`), (4) your operating system and version, and (5) the command or operation that triggered the error.


## Prevention

Add these rules to your project's `CLAUDE.md` to prevent this issue from recurring:

```markdown
# Environment Checks
Before running commands, verify the required tools are available.
Check versions match project requirements before proceeding.
If a command fails, read the error message carefully before retrying.
Do not retry failed commands without changing something first.
```

Additionally, consider adding a project setup validation script:

```bash
#!/bin/bash
# validate-env.sh — run before starting Claude Code sessions
set -euo pipefail

echo "Checking environment..."
node --version | grep -q "v2[0-2]" || echo "WARN: Node.js 20+ recommended"
command -v git >/dev/null || echo "ERROR: git not found"
[ -f package.json ] || echo "ERROR: not in project root"
echo "Environment check complete."
```


## Related Guides

- [Stop Claude Code Modifying Unrelated](/how-to-stop-claude-code-from-modifying-unrelated-files/)

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
        "text": "Open an issue at github.com/anthropics/claude-code with: (1) the full error message including stack trace, (2) your Node.js version (`node --version`), (3) your Claude Code version (`claude --version`), (4) your operating system and version, and (5) the command or operation that triggered the error. Add these rules to your project's `CLAUDE.md` to prevent this issue from recurring: ```markdown # Environment Checks Before running commands, verify the required tools are available. Check versions match project requirements before proceeding. If a command fails, read the error message carefully before retrying. Do not retry failed commands without changing something first. ``` Additionally, consider adding a project setup validation script: ```bash #!/bin/bash # validate-env.sh — run before starting Claude Code sessions set -euo pipefail echo \"Checking environment...\" node --version | grep -q \"v2[0-2]\" || echo \"WARN: Node.js 20+ recommended\" command -v git >/dev/null || echo \"ERROR: git not found\" [ -f package.json ] || echo \"ERROR: not in project root\" echo \"Environment check complete.\" ``` - [Stop Claude Code Modifying Unrelated](/how-to-stop-claude-code-from-modifying-unrelated-files/)"
      }
    }
  ]
}
</script>
