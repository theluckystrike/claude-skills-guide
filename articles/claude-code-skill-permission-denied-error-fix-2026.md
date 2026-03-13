---
layout: post
title: "Claude Code Skill Permission Denied Error Fix 2026"
description: "Fix the permission denied error in Claude Code skills. Step-by-step solutions for file permissions, sandbox settings, and skill configuration."
date: 2026-03-13
categories: [troubleshooting]
tags: [claude-code, claude-skills, troubleshooting, permissions]
author: "Claude Skills Guide"
reviewed: true
score: 8
---

# Claude Code Skill Permission Denied Error Fix 2026

If you have hit a **permission denied** error while running a Claude Code skill, you are not alone. This error surfaces in several distinct situations — and the fix depends on which layer is actually refusing access. This guide walks through every known cause in 2026 and gives you the exact steps to resolve each one.

## What the Error Looks Like

The error typically appears in one of these forms:

```
Error: EACCES: permission denied, open '/path/to/file'
SkillExecutionError: permission denied — tool call rejected by sandbox policy
bash: /usr/local/bin/my-script: Permission denied
```

The first is a Node.js filesystem error. The second is Claude's built-in sandbox rejecting a tool call. The third is a shell-level execution bit problem. Each requires a different fix.

## Cause 1: Missing Execute Bit on a Script the Skill Calls

If your skill definition calls a shell script or binary, that file must be executable.

**Check:**
```bash
ls -la /path/to/your/script.sh
```

**Fix:**
```bash
chmod +x /path/to/your/script.sh
```

Skills like the [`tdd` skill](/claude-skills-guide/articles/best-claude-skills-for-developers-2026/) and `frontend-design` sometimes call local wrapper scripts. If you customised those scripts and copied them into place without preserving permissions, this is the most common cause.

## Cause 2: Claude Code Sandbox Blocking File Access

Claude Code runs skills inside a permission sandbox. By default, the sandbox restricts access to directories outside the project root. If your skill tries to read or write outside the allowed scope, you get a sandbox rejection.

**Symptoms:**
- Error happens even with correct file permissions
- Error message contains `sandbox policy` or `tool call rejected`
- Works when you disable the skill and run the command manually

**Fix — allow additional paths in `.claude/settings.json`:**

```json
{
  "permissions": {
    "allow": [
      "Bash(/home/user/shared-data/**)",
      "Read(/etc/myapp/config.toml)"
    ]
  }
}
```

Restart Claude Code after editing `settings.json`. The sandbox re-reads this file on startup, not on hot reload.

## Cause 3: Skill YAML Referencing a Tool With Insufficient Scope

Some skills explicitly declare required tools. If the declared tool name does not match what Claude Code exposes in the current session, the runtime falls back to a restricted execution path that can produce permission errors.

Check your skill's front matter:

```yaml
tools:
  - Bash
  - Read
  - Write
```

Make sure every tool listed is spelled exactly as Claude Code exports it (capital first letter for built-ins). A mismatch like `bash` instead of `Bash` causes the skill to run with a degraded tool set, which can look like a permission issue.

## Cause 4: Skill Files With Wrong Ownership

Skills live in `~/.claude/skills/` (global) or `.claude/skills/` (project-local). If those files are owned by root — which can happen after running `sudo claude` — your regular user process cannot read them.

**Check:**
```bash
ls -la ~/.claude/skills/
```

**Fix:**
```bash
sudo chown -R $(whoami) ~/.claude/
chmod 755 ~/.claude/skills/
chmod 644 ~/.claude/skills/*.md
```

## Cause 5: Running Claude Code as Root vs. Non-Root

If you installed Claude Code globally as root (`sudo npm install -g @anthropic-ai/claude-code`) but you run it as a regular user, the node_modules path for skills may be owned by root.

**Fix — reinstall without sudo using a user-owned Node version manager:**
```bash
# Using nvm
nvm install --lts
npm install -g @anthropic-ai/claude-code
```

This ensures the entire Claude Code installation is owned by your user account, eliminating root/user permission conflicts.

## Cause 6: macOS Gatekeeper or SIP Blocking Execution

On macOS, System Integrity Protection (SIP) can block scripts in certain protected directories. Skills that reference binaries in `/usr/bin/` or `/System/` may fail with permission denied even if the file mode is correct.

**Fix — move scripts to an unprotected path:**
```bash
mkdir -p ~/bin
cp my-skill-helper.sh ~/bin/
chmod +x ~/bin/my-skill-helper.sh
export PATH="$HOME/bin:$PATH"
```

Update your skill definition to reference `~/bin/my-skill-helper.sh` instead.

## Cause 7: PDF or DOCX Skill Accessing Quarantined Files

The [`pdf` skill](/claude-skills-guide/articles/best-claude-skills-for-data-analysis/) and `docx` skills read files from your filesystem. If those files are in a directory with extended quarantine attributes — common on corporate-managed macOS — you will see permission denied even though `ls` shows you own the file.

**Check extended attributes:**
```bash
ls -le@ /path/to/document.pdf
```

**Fix:**
```bash
xattr -d com.apple.quarantine /path/to/document.pdf
```

If you are on a managed device, copy the file to your home directory first.

## Cause 8: supermemory Skill Writing to a Read-Only Volume

The [`supermemory` skill](/claude-skills-guide/articles/claude-skills-token-optimization-reduce-api-costs/) writes session state to disk. If Claude Code's working directory is on a read-only volume — a network share, mounted image, or CI filesystem — the skill will throw permission denied when trying to persist memory.

**Fix — instruct the skill explicitly with a writable path:**

Tell the supermemory skill to write to a specific writable location:

```
/supermemory
Save this context to ~/notes/project-context.md instead of the default location.
```

Or set the environment variable before launching Claude Code:
```bash
export CLAUDE_MEMORY_PATH="$HOME/.claude-memory"
mkdir -p ~/.claude-memory
claude
```

## Systematic Debugging Checklist

When permission denied hits and you are not sure which cause applies, work through this list in order:

1. Run `ls -la` on every file the skill references
2. Check `.claude/settings.json` for missing `allow` entries
3. Try the tool call manually in the Claude Code chat without invoking the skill
4. Check `Console.app` (macOS) or `journalctl` (Linux) for OS-level denials
5. Confirm Claude Code and Node.js are running as the same user

## Quick Diagnostic Script

```bash
echo "=== Claude Code Permission Diagnostic ===" \
  && echo "Skills directory:" && ls -la ~/.claude/skills/ 2>&1 \
  && echo "Current user:" && id \
  && echo "Project skills:" && ls -la .claude/skills/ 2>&1
```

## When to File a Bug

If none of the above resolves the issue, the problem may be in the skill itself. Check the skill's GitHub repo for open issues tagged `permission`. The `tdd` skill had a known regression in early 2026 where it attempted to write test output to a hardcoded `/tmp/claude-tdd/` path that conflicted with strict tmpfs mounts. That was patched in v1.4.2.

---

## Related Reading

- [Skill .md File Format Explained With Examples](/claude-skills-guide/articles/skill-md-file-format-explained-with-examples/) — Understanding the correct structure for skill files helps avoid misconfiguration that can cause permission-related failures
- [How to Write a Skill .md File for Claude Code](/claude-skills-guide/articles/how-to-write-a-skill-md-file-for-claude-code/) — A step-by-step guide to authoring valid skill files including tools declarations and file placement rules
- [Claude Skills Auto-Invocation: How It Works](/claude-skills-guide/articles/claude-skills-auto-invocation-how-it-works/) — If your skill loads but never fires, understanding the invocation model can clarify whether the issue is permissions or trigger matching

Built by theluckystrike — More at [zovo.one](https://zovo.one)
