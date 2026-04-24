---
title: "Knowledge Base Exceeds 512KB Maximum"
permalink: /claude-code-knowledge-base-too-large-fix-2026/
description: "Split your CLAUDE.md into focused sub-files under the .claude/docs/ directory. Resolves the 512KB project knowledge base maximum size limit error."
last_tested: "2026-04-21"
render_with_liquid: false
---

## The Error

```
Project knowledge base exceeds maximum size (512KB)
```

## The Fix

```bash
# Split your monolithic CLAUDE.md into smaller focused files
mkdir -p .claude/docs
# Move sections into separate files
mv CLAUDE.md CLAUDE-backup.md
# Create a lean root CLAUDE.md that references sub-docs
cat > CLAUDE.md << 'EOF'
# Project Guidelines
See .claude/docs/ for detailed documentation.
Key rules: [keep only critical 5-10 rules here]
EOF
# Move detailed content into sub-files
# .claude/docs/architecture.md, .claude/docs/conventions.md, etc.
```

## Why This Works

Claude Code loads the entire knowledge base into the context window on every request. The 512KB cap prevents context overflow. By splitting into sub-files under `.claude/docs/`, only the root CLAUDE.md is loaded automatically. Sub-documents are referenced on demand, keeping the base payload under the limit.

## If That Doesn't Work

```bash
# Check what's consuming space
wc -c CLAUDE.md .claude/docs/*.md
# Remove generated content, logs, or duplicated dependency lists
# Keep only human-authored guidelines under 512KB total
```

If your project genuinely needs extensive documentation in context, use the `--knowledge` flag to selectively load specific files per session rather than including everything by default.

## Prevention

Add to your CLAUDE.md:
```
Root CLAUDE.md must stay under 50KB. Detailed docs go in .claude/docs/ and are loaded only when relevant to the current task.
```

## See Also

- [Claude Code Glob Pattern Too Broad Error — Fix (2026)](/claude-code-glob-pattern-too-broad-fix-2026/)
- [Claude API 413 Request Payload Too Large — Fix (2026)](/claude-api-413-request-payload-too-large-fix/)
- [Tool Result Exceeds 100KB Truncating — Fix (2026)](/claude-code-tool-result-too-large-fix-2026/)
- [Claude Code git diff too large -- reducing context size](/claude-code-git-diff-too-large-reducing-context/)

## Related Error Messages

This fix also applies if you see these related error messages:

- `fatal: not a git repository`
- `error: failed to push some refs`
- `fatal: refusing to merge unrelated histories`
- `ContextWindowExceeded: input exceeds maximum context length`
- `Error: message content too large`

## Frequently Asked Questions

### Why does Claude Code require git?

Claude Code uses git for several core operations: tracking file changes, creating commits, reading blame information, searching history with `git log`, and managing branches. Without git, these operations fail and Claude Code falls back to less efficient alternatives.

### Can Claude Code work in a non-git directory?

Yes, but with reduced functionality. File search and editing work normally, but version control operations (commit, diff, blame) are unavailable. Claude Code displays a warning when opened in a directory without git initialization.

### How do I prevent Claude Code from making unwanted git operations?

Add rules to your CLAUDE.md: `Do not create commits automatically. Do not run git push. Always ask before any git operation that modifies history.` Claude Code respects these constraints and asks for confirmation before proceeding.

### What is the context window limit?

Claude's context window is 200,000 tokens. This includes system prompts, conversation history, file contents read during the session, and tool results. When the total exceeds this limit, Claude Code must compress or drop earlier context.
