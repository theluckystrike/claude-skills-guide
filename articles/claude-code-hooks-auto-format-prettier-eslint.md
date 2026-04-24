---
layout: default
title: "Auto-Format Code with Claude Code Hooks (2026)"
description: "Set up PostToolUse hooks to run Prettier and ESLint automatically after every Claude Code edit. Step-by-step configuration guide."
date: 2026-04-15
permalink: /claude-code-hooks-auto-format-prettier-eslint/
categories: [guides, claude-code]
tags: [hooks, prettier, eslint, formatting, PostToolUse]
last_modified_at: 2026-04-17
geo_optimized: true
---

# Auto-Format Code with Claude Code Hooks

## The Problem

Claude Code edits files but does not automatically run your project's formatter or linter. You end up with formatting inconsistencies that you have to fix manually, or your pre-commit hooks fail because files are not properly formatted.

## Quick Fix

Add a PostToolUse hook that runs Prettier on every file Claude edits. Add this to `.claude/settings.json` in your project root:

```json
{
 "hooks": {
 "PostToolUse": [
 {
 "matcher": "Edit|Write",
 "hooks": [
 {
 "type": "command",
 "command": "jq -r '.tool_input.file_path' | xargs npx prettier --write"
 }
 ]
 }
 ]
 }
}
```

## What's Happening

Claude Code hooks are shell commands that execute automatically at specific points in the agent's lifecycle. The `PostToolUse` event fires after every tool call succeeds. By setting the matcher to `Edit|Write`, the hook runs only after file-editing tools, not after reads or shell commands.

The hook receives JSON context on stdin that includes the tool name and input parameters. For the Edit and Write tools, `tool_input.file_path` contains the path of the modified file. The command extracts this path with `jq` and passes it to Prettier.

This gives you deterministic formatting enforcement. Instead of hoping Claude formats code correctly, the hook guarantees every edit passes through your project's formatter.

## Step-by-Step Fix

### Step 1: Install jq

The hook examples use `jq` for JSON parsing. Install it if you do not have it:

```bash
# macOS
brew install jq

# Debian/Ubuntu
sudo apt-get install jq
```

### Step 2: Configure the Prettier hook

Add the hook to your project settings at `.claude/settings.json`:

```json
{
 "hooks": {
 "PostToolUse": [
 {
 "matcher": "Edit|Write",
 "hooks": [
 {
 "type": "command",
 "command": "jq -r '.tool_input.file_path' | xargs npx prettier --write"
 }
 ]
 }
 ]
 }
}
```

This runs Prettier on every file Claude creates or modifies. The `Edit|Write` matcher means the hook fires for both the Edit tool (inline replacements) and the Write tool (full file creation).

### Step 3: Add ESLint auto-fix

To also run ESLint with auto-fix, add a second hook entry in the same PostToolUse array:

```json
{
 "hooks": {
 "PostToolUse": [
 {
 "matcher": "Edit|Write",
 "hooks": [
 {
 "type": "command",
 "command": "jq -r '.tool_input.file_path' | xargs npx prettier --write"
 },
 {
 "type": "command",
 "command": "jq -r '.tool_input.file_path' | xargs npx eslint --fix 2>/dev/null || true"
 }
 ]
 }
 ]
 }
}
```

The `|| true` ensures the hook does not block Claude if ESLint reports unfixable issues.

### Step 4: Filter by file extension

To run Prettier only on supported file types, add a conditional:

```json
{
 "hooks": {
 "PostToolUse": [
 {
 "matcher": "Edit|Write",
 "hooks": [
 {
 "type": "command",
 "command": "FILE=$(jq -r '.tool_input.file_path'); case \"$FILE\" in *.ts|*.tsx|*.js|*.jsx|*.json|*.css|*.md) npx prettier --write \"$FILE\" ;; esac"
 }
 ]
 }
 ]
 }
}
```

### Step 5: Verify the hook is loaded

Inside Claude Code, type:

```text
/hooks
```

This opens the hooks browser. You should see PostToolUse with a count showing your configured hooks. Select it to verify the matcher and command are correct.

### Step 6: Test the hook

Ask Claude to make a small edit to any file. After the edit completes, the hook should run and you should see the file reformatted according to your Prettier configuration.

## Prevention

Commit your `.claude/settings.json` file to version control so every team member gets the same formatting hooks. This guarantees consistent formatting regardless of which developer is using Claude Code.

For user-level hooks that apply to all your projects, add them to `~/.claude/settings.json` instead. Multiple hook events can coexist in the same settings file:

```json
{
 "hooks": {
 "PostToolUse": [
 {
 "matcher": "Edit|Write",
 "hooks": [
 {
 "type": "command",
 "command": "jq -r '.tool_input.file_path' | xargs npx prettier --write"
 }
 ]
 }
 ],
 "Notification": [
 {
 "matcher": "",
 "hooks": [
 {
 "type": "command",
 "command": "osascript -e 'display notification \"Claude Code needs attention\" with title \"Claude Code\"'"
 }
 ]
 }
 ]
 }
}
```

---

### Level Up Your Claude Code Workflow

The developers who get the most out of Claude Code aren't just fixing errors — they're running multi-agent pipelines, using battle-tested CLAUDE.md templates, and shipping with production-grade operating principles.

---


<div class="author-bio">

**Written by Michael** — solo dev, Da Nang, Vietnam. 50K+ Chrome extension users. $500K+ on Upwork (100% Job Success). Runs 5 Claude Max subs in parallel. Built this site with autonomous agent fleets. [See what I'm building →](https://zovo.one)

</div>

---

<div class="mastery-cta">

This site was built by 5 autonomous agents running in tmux while I was in Bali. 2,500 articles. Zero manual work. 100% quality gate pass rate.

The orchestration configs, sprint templates, and quality gates that made that possible are in the Zovo Lifetime bundle. Along with 16 CLAUDE.md templates and 80 tested prompts.

**[See how the pipeline works →](https://zovo.one/lifetime?utm_source=ccg&utm_medium=cta-skills&utm_campaign=claude-code-hooks-auto-format-prettier-eslint)**

$99 once. I'm a solo dev in Da Nang. This is how I scale.

</div>

---

## Related Guides

- [Understanding Claude Code Hooks System Complete Guide](/understanding-claude-code-hooks-system-complete-guide/)
- [Claude Code PreToolUse Hooks Bypassed](/claude-code-pretooluse-hooks-bypassed/)
- [Claude Code 2026 New Features Skills and Hooks Roundup](/claude-code-2026-new-features-skills-and-hooks-roundup/)
- [Best Way to Validate Claude Code Output Before Committing](/best-way-to-validate-claude-code-output-before-committing/)

## See Also

- [Claude Code vs ESLint + Prettier: Code Quality Tools](/claude-code-vs-eslint-prettier-comparison/)
