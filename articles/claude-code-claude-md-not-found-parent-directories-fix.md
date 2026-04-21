---
title: "Claude Code CLAUDE.md Not Found Fix (2026)"
description: "Fix Claude Code CLAUDE.md not found in parent directories. Create the file in the correct project root location. Step-by-step solution."
permalink: /claude-code-claude-md-not-found-parent-directories-fix/
last_tested: "2026-04-21"
render_with_liquid: false
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

**Related articles:** [CLAUDE.md Not Being Read Fix](/claude-md-not-being-read-by-claude-code-fix/), [How to Fix Claude Ignoring CLAUDE.md](/how-to-fix-claude-code-ignoring-my-claude-md-file/), [Config File Location](/claude-code-config-file-location/)
