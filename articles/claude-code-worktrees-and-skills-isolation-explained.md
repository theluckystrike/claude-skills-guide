---
layout: default
title: "Claude Code Worktrees and Skills Isolation Explained"
description: "How Claude Code uses git worktrees to isolate skill execution — what gets isolated, what doesn't, and how to design skills that work correctly in worktree environments."
date: 2026-03-13
author: theluckystrike
---

# Claude Code Worktrees and Skills Isolation Explained

Claude Code's worktree feature is one of the most useful but least understood capabilities in the system. It lets you run Claude agents in isolated git worktrees — separate working directories checked out from the same repository — so that parallel work doesn't interfere with your main branch. Understanding how this interacts with skills is essential for multi-agent and parallel-workflow setups.

## What Is a Worktree?

A git worktree is an additional working directory associated with the same git repository. Unlike cloning, which creates a full copy of the repository, a worktree shares the same `.git` object store with the main repository but has its own checked-out files and branch.

```bash
# Create a worktree for Claude to use
git worktree add .claude/worktrees/feature-auth feature/auth-system

# Claude Code creates this for you with:
# /worktree feature-auth
```

The resulting directory structure:
```
myproject/              ← main worktree (your working directory)
  .git/
  .claude/
    worktrees/
      feature-auth/     ← Claude's isolated worktree
        .git            ← file pointing back to main .git
        src/
        ...
```

## How Claude Code Uses Worktrees

When you invoke `/worktree {name}` in Claude Code, it:

1. Creates a new worktree at `.claude/worktrees/{name}`
2. Checks out a new branch named after the worktree
3. Starts a Claude Code session with that worktree as the project root
4. Any file operations in that session are scoped to the worktree directory

The key isolation benefit: Claude can modify files freely in the worktree without affecting your main branch or any other worktree.

## What Gets Isolated

**Isolated per worktree:**
- All files in the working tree (source code, config files, etc.)
- The git branch and staging area
- The Claude Code session and conversation history
- Tool call history for that session

**Shared across worktrees:**
- The git object store (commits, trees, blobs)
- Git hooks (`.git/hooks/`)
- The underlying git history

**Partially shared (important):**
- `.claude/skills/` — skill files are read from the project root `.claude/skills/`, not from the worktree. See below.
- `.claude/settings.json` — session settings come from the main project, not the worktree.
- MCP servers — registered globally, not per-worktree.

## Skills and Worktrees: The Critical Detail

Skills are read from `.claude/skills/` relative to the **main project root**, not from the worktree. This means:

1. All worktrees share the same set of skills
2. Changes to skills affect all worktrees immediately (since they read from the same path)
3. A skill cannot be "scoped" to a specific worktree through normal placement

This is by design — you don't want different worktrees running different versions of your `tdd` skill. It creates consistency across parallel workstreams.

### Worktree-Aware context_files

The `context_files` in a skill's front matter are resolved relative to the **current working directory** at invocation time, which for a worktree session is the worktree directory. This means context files will correctly read from the worktree's version of the files:

```yaml
---
name: tdd
context_files:
  - src/test-utils/setup.ts    # Reads from worktree's version
  - docs/testing-guide.md      # Reads from worktree's version
---
```

This is the correct behavior — when Claude is working in a worktree branch for a feature, it should see that branch's version of the test utilities, not the main branch's version.

## Designing Skills for Worktree Use

Skills that will be used in worktrees need to be explicit about which directory they're operating in.

### Avoid Hardcoded Absolute Paths

Bad:
```
Write test files to /Users/dev/myapp/src/tests/
```

Good:
```
Write test files to the appropriate __tests__ directory relative to the source file.
Use the project root as the base: {project_root}/src/
```

The `{{project_root}}` template variable resolves to the current worktree's root, not the main project root.

### State Files and Worktrees

If your skill uses state files (see the stateful agents guide), the state file should be written to the worktree directory, not the main project root:

```
Write state files to .claude/state/ within the current project root.
In a worktree, this will be {project_root}/.claude/state/ — which is inside 
the worktree directory, keeping state isolated per worktree.
```

However, the `.claude/state/` directory is inside the worktree's `.claude/` which is separate from the main project's `.claude/`. This is the right behavior: each worktree has its own task state.

## Parallel Skill Execution via Worktrees

The most powerful use of worktrees is running the same skill in parallel across multiple branches:

```bash
#!/bin/bash
# Spawn parallel Claude agents in separate worktrees

FEATURES=("auth-system" "payment-flow" "user-profile")

for FEATURE in "${FEATURES[@]}"; do
    # Create worktree from feature branch
    git worktree add ".claude/worktrees/${FEATURE}" "feature/${FEATURE}" 2>/dev/null || true
    
    # Run tdd skill non-interactively in the worktree
    (
        cd ".claude/worktrees/${FEATURE}"
        claude --skill tdd \
               --message "Generate comprehensive tests for all new files in this branch" \
               --non-interactive \
               --output-file ".claude/results/tdd-${FEATURE}.json" &
    )
done

wait
echo "All parallel tdd runs complete"
```

Each agent runs the same `tdd` skill but in a completely isolated working tree. They cannot interfere with each other's file writes.

## Worktree Cleanup

Worktrees accumulate. Build cleanup into your workflow:

```bash
# List all Claude worktrees
git worktree list | grep ".claude/worktrees"

# Remove a specific worktree after work is merged
git worktree remove .claude/worktrees/feature-auth

# Remove all worktrees whose branches have been merged to main
git worktree list --porcelain | grep "worktree" | awk '{print $2}' | \
  grep ".claude/worktrees" | while read wt; do
    branch=$(git -C "$wt" branch --show-current)
    if git merge-base --is-ancestor "$branch" main; then
        echo "Removing merged worktree: $wt"
        git worktree remove "$wt"
    fi
  done
```

## The WorktreeCreate Hook

Claude Code has a `WorktreeCreate` hook that fires when a new worktree is created via `/worktree`. Use it to initialize the worktree environment:

```json
{
  "hooks": {
    "WorktreeCreate": [
      {
        "matcher": {},
        "command": ".claude/hooks/init-worktree.sh"
      }
    ]
  }
}
```

The init script receives the worktree path via `$WORKTREE_PATH`:

```bash
#!/bin/bash
# .claude/hooks/init-worktree.sh
cd "$WORKTREE_PATH"

# Create necessary directories
mkdir -p .claude/state
mkdir -p .claude/results

# Install dependencies if needed
if [ -f "package.json" ]; then
    npm install --silent
fi

echo "Worktree initialized: $WORKTREE_PATH"
```

## Skills That Should Not Run in Worktrees

Some skills are not safe to run in worktrees because they affect shared state:

- **Skills that modify `~/.claude/` global config**: These affect all sessions, not just the worktree.
- **Skills that write to the main `.git/` directory directly**: Could corrupt the shared git store.
- **Skills that manage git remotes or push to origin**: Should typically be done from the main worktree, not from a feature worktree.

Add a guard to such skills:

```
Safety check:
Before starting, verify you are not running in a worktree:
bash: git rev-parse --git-common-dir

If the output is ".git" (same as current directory), you are in the main worktree.
If the output is a different path, you are in a worktree. For this skill, that is 
unexpected — warn the user and stop.
```

---

Built by theluckystrike — More at [zovo.one](https://zovo.one)
