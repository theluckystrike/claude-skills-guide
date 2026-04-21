---
title: "Knowledge Base Exceeds 512KB Maximum — Fix (2026)"
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
