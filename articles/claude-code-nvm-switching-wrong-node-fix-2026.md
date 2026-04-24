---
title: "nvm Switching to Wrong Node Version"
permalink: /claude-code-nvm-switching-wrong-node-fix-2026/
description: "Fix nvm using wrong Node version for Claude Code. Set default alias and add .nvmrc to auto-switch on directory change."
last_tested: "2026-04-22"
render_with_liquid: false
---

## The Error

```
$ nvm use 22
Now using node v22.12.0
$ cd ~/myproject
$ node --version
v16.20.2
$ claude
Error: Claude Code requires Node.js 18 or higher.
```

This error occurs when nvm auto-switches to an old Node version specified by a project's `.nvmrc` file or when the default alias points to an old version.

## The Fix

1. Set the nvm default to Node 22:

```bash
nvm alias default 22
```

2. Verify the default is set:

```bash
nvm alias default
# Should show: default -> 22 (-> v22.x.x)
```

3. If the project has an `.nvmrc` file with an old version, update it:

```bash
echo "22" > .nvmrc
nvm use
```

4. Reinstall Claude Code on the correct Node:

```bash
nvm use default
npm install -g @anthropic-ai/claude-code
claude --version
```

## Why This Happens

nvm manages multiple Node versions and switches between them. If a project has an `.nvmrc` file specifying Node 16 and you have nvm auto-switching enabled, entering that directory switches to Node 16. Global packages (like Claude Code) installed on Node 22 are not available when nvm switches to Node 16. Each Node version has its own global package directory.

## If That Doesn't Work

- Install Claude Code on every Node version you use:

```bash
nvm use 16 && npm install -g @anthropic-ai/claude-code
nvm use 18 && npm install -g @anthropic-ai/claude-code
nvm use 22 && npm install -g @anthropic-ai/claude-code
```

- Disable auto-switching by removing the nvm cd hook from your shell profile.
- Use `npx @anthropic-ai/claude-code` which does not depend on global installs.

## Prevention

Add this to your `CLAUDE.md`:

```markdown
# nvm Configuration
- Set nvm alias default 22 to ensure Claude Code always works.
- Update .nvmrc to 22 in all active projects.
- If you must use Node 16 for a project, install Claude Code on that version too.
```

## See Also

- [Wrong Node.js Version in PATH Fix](/claude-code-wrong-node-version-in-path-fix-2026/)
- [Claude Amending Wrong Commit Fix](/claude-code-amending-wrong-commit-fix-2026/)
