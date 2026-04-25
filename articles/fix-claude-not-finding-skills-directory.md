---
layout: default
title: "Fix Claude Code Not Finding the Skills (2026)"
description: "Resolve discovery failures when Claude Code cannot locate .claude/skills/ due to working directory, gitignore, permissions, or monorepo nesting issues."
permalink: /fix-claude-not-finding-skills-directory/
date: 2026-04-20
categories: [skills, 2026]
tags: [claude-code, claude-skills, error, directory, discovery, troubleshooting]
last_updated: 2026-04-19
---

## The Specific Situation

You have a `.claude/skills/` directory in your project with three skills inside. You start Claude Code and ask "What skills are available?" Claude reports zero skills. You check the directory -- files are there. The issue is that Claude Code is not looking where you think it is looking.

## Technical Foundation

Claude Code scans for skills relative to the working directory at session start. It looks for `.claude/skills/` in the current directory and walks up the directory tree. For personal skills, it checks `~/.claude/skills/`. For additional directories specified with `--add-dir`, it checks `.claude/skills/` within each.

Key discovery rules:
- Ancestor loading: Claude loads `.claude/skills/` from directories above the working directory
- Subdirectory loading: Nested `.claude/skills/` in subdirectories loads when Claude works with files there
- Live watch: Once a skills directory is found, changes are detected without restart
- First-time creation: A NEW `.claude/skills/` directory requires a restart

## The Working SKILL.md

Verify your structure matches this exactly:

```
project-root/           # Start Claude Code HERE
├── .claude/
│   └── skills/
│       └── my-skill/
│           └── SKILL.md
├── src/
└── package.json
```

The SKILL.md:

```yaml
---
name: my-skill
description: A test skill to verify discovery works
---

This skill was discovered successfully.
```

Test discovery:

```bash
# Start Claude Code from project root
cd project-root
claude

# In Claude Code, ask:
# "What skills are available?"
```

## Cause 1: Wrong Working Directory

Claude Code scans from the current working directory upward. If you start Claude from a subdirectory, it may not find the project-level skills.

```bash
# WRONG: started from a subdirectory
cd project-root/src/components
claude  # Will NOT find project-root/.claude/skills/

# CORRECT: started from project root
cd project-root
claude  # WILL find .claude/skills/
```

Fix: Start Claude Code from the project root where `.claude/skills/` exists.

Exception: Claude does scan ancestor directories. If you start from `project-root/src/`, it walks up and finds `project-root/.claude/skills/`. But starting from outside the project tree entirely will fail.

## Cause 2: .claude/ Is Gitignored

Some `.gitignore` templates include `.claude/` as an excluded pattern. This does not affect local discovery, but it prevents teammates from getting the skills after cloning.

```bash
# Check gitignore
grep -n "claude" .gitignore

# If you see:
# .claude/

# Add an exception for skills:
# .claude/
# !.claude/skills/
```

Fix: Add `!.claude/skills/` to `.gitignore` to exclude it from the ignore pattern.

## Cause 3: Permissions Issue

On some systems, the `.claude/` directory may have restrictive permissions preventing Claude Code from reading it.

```bash
# Check permissions
ls -la .claude/
ls -la .claude/skills/
ls -la .claude/skills/my-skill/SKILL.md

# Fix permissions if needed
chmod -R 755 .claude/skills/
```

Fix: Ensure the `.claude/skills/` directory and all contents are readable by your user account.

## Cause 4: Monorepo Nesting Issue

In monorepos, nested skills directories are only discovered when Claude works with files in that subdirectory:

```
monorepo/
├── .claude/skills/        # Always discovered (root level)
│   └── shared-lint/
├── packages/
│   ├── frontend/
│   │   └── .claude/skills/  # Only when editing frontend files
│   │       └── react-gen/
│   └── backend/
│       └── .claude/skills/  # Only when editing backend files
│           └── api-gen/
```

If you ask "What skills are available?" before editing any files in `packages/frontend/`, the `react-gen` skill will not appear.

Fix: Read or edit a file in the subdirectory first. Claude Code auto-discovers nested skills when it accesses files in that directory tree.

## Cause 5: Directory Created After Session Start

If `.claude/skills/` did not exist when Claude Code started, and you created it during the session, the file watcher was never initialized.

```bash
# During an active session:
mkdir -p .claude/skills/my-skill
# Write SKILL.md
# Claude CANNOT see this because the watcher was never set up
```

Fix: Restart Claude Code. After restart, the existing directory is detected and watched.

Note: This only applies to creating a NEW top-level skills directory. Adding new skill subdirectories to an EXISTING `.claude/skills/` directory is detected live.

## Cause 6: --add-dir Not Including Skills

When using `--add-dir` to access additional directories, `.claude/skills/` within that directory is loaded automatically as an exception. But the directory must be specified correctly.

```bash
# CORRECT: add-dir pointing to directory containing .claude/skills/
claude --add-dir /path/to/shared-repo

# The following is discovered:
# /path/to/shared-repo/.claude/skills/

# WRONG: add-dir pointing directly to skills
claude --add-dir /path/to/shared-repo/.claude/skills/
# This grants file access but does NOT set up skill discovery
```

Fix: Point `--add-dir` at the parent directory that contains `.claude/skills/`, not at the skills directory itself.

## Diagnostic Commands

```bash
# 1. Find all SKILL.md files accessible from current directory
find . -path "*/.claude/skills/*/SKILL.md" 2>/dev/null

# 2. Find personal skills
find ~/.claude/skills -name "SKILL.md" 2>/dev/null

# 3. Check current working directory
pwd

# 4. Verify .claude is not gitignored
git check-ignore .claude/skills/ 2>/dev/null
# If output shows the path, it IS gitignored
```

## Common Problems and Fixes

**Skills work on one machine but not another**: Check that `.claude/skills/` is committed to git (not gitignored). Run `git ls-files .claude/skills/` to verify tracked files.

**Skills disappear after switching branches**: The branch you switched to may not have `.claude/skills/`. Check `git log --oneline -- .claude/skills/` on both branches.

**Skills from --add-dir inconsistent**: Ensure the added directory path is absolute, not relative. Relative paths resolve differently depending on where Claude Code was started.

**Personal skills directory does not exist**: Create it: `mkdir -p ~/.claude/skills/`. Then restart Claude Code so the new directory is detected.

## Production Gotchas

The ancestor directory scan for `.claude/skills/` stops at the filesystem root. It does not cross mount points or symlink boundaries on all operating systems. If your project is on a mounted volume, start Claude Code from within the mount.

On network filesystems (NFS, CIFS, SSHFS), file watchers may not work reliably. If skills are not detected after changes, restart Claude Code to force a full rescan.

The `CLAUDE_CODE_ADDITIONAL_DIRECTORIES_CLAUDE_MD=1` environment variable enables CLAUDE.md loading from `--add-dir` directories. But skills are always loaded from `--add-dir` regardless of this setting. This environment variable has no effect on skill discovery.

## Checklist

- [ ] Claude Code started from project root or ancestor directory
- [ ] `.claude/skills/` not gitignored (or has `!.claude/skills/` exception)
- [ ] Directory permissions allow read access
- [ ] Session restarted if `.claude/skills/` was created mid-session
- [ ] Nested monorepo skills tested by editing files in that subdirectory

## Related Guides

- [Fix Unknown Skill Error in Claude Code](/fix-unknown-skill-error-claude-code/)
- [Fix Claude Code Skills Not Showing Up](/fix-claude-code-skills-not-showing-up/)
- [Claude Skills Folder Structure](/claude-skills-folder-structure/)
