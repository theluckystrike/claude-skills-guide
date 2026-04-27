---
sitemap: false
layout: default
title: "Fix Claude Code NPM Install Eacces (2026)"
description: "Resolve npm EACCES permission denied errors when Claude Code runs npm install. Fix global installs, node_modules ownership, and cache issues."
last_tested: "2026-04-22"
date: 2026-04-15
last_modified_at: 2026-04-17
author: "Claude Code Guides"
permalink: /claude-code-npm-install-eacces-permission-fix/
reviewed: true
categories: [troubleshooting, claude-code]
tags: [npm, eacces, permissions, node-modules, installation]
geo_optimized: true
---
# Fix EACCES Permission Errors During npm Install in Claude Code

## The Problem

Claude Code runs `npm install` and hits a permission error:

```
npm ERR! code EACCES
npm ERR! syscall mkdir
npm ERR! path /usr/local/lib/node_modules/some-package
npm ERR! errno -13
npm ERR! Error: EACCES: permission denied, mkdir '/usr/local/lib/node_modules/some-package'
```

Or a variation targeting the npm cache:

```
npm ERR! code EACCES
npm ERR! syscall open
npm ERR! path /Users/you/.npm/_cacache/tmp/some-hash
npm ERR! errno -13
```

The installation fails, and Claude Code cannot proceed with dependency setup.

## Quick Fix

For local project installs, fix the node_modules ownership:

```bash
sudo chown -R $(whoami) node_modules/
npm install
```

For global install permission issues, configure npm to use a user-owned directory:

```bash
mkdir -p ~/.npm-global
npm config set prefix '~/.npm-global'
echo 'export PATH=~/.npm-global/bin:$PATH' >> ~/.zshrc
source ~/.zshrc
```

## What's Happening

EACCES errors occur when the current user lacks write permission to a directory that npm needs to modify. This happens in three common scenarios:

1. **Previous sudo install**: Someone ran `sudo npm install` at some point, and now root owns files inside `node_modules/`. Subsequent non-sudo installs fail because your user cannot write to root-owned directories.

2. **Global prefix pointing to system directory**: npm's default global prefix (`/usr/local`) requires root access on most systems. When Claude Code tries to install a global tool, it fails without sudo.

3. **Corrupted npm cache**: The npm cache directory has mixed ownership from previous sudo operations.

Claude Code runs commands as your current user. It does not use sudo by default (and should not). So any path requiring elevated permissions will trigger EACCES.

## Step-by-Step Fix

### Step 1: Diagnose the exact cause

Ask Claude Code to identify which path is causing the error:

```
Run npm install and show me the full error output. Then check
the ownership of the failing path.
```

Claude Code will run:

```bash
npm install 2>&1
ls -la node_modules/ | head -20
ls -la $(npm config get prefix)/lib/node_modules/ 2>/dev/null
```

### Step 2: Fix node_modules ownership (local installs)

If `node_modules/` has mixed ownership:

```bash
# Check for root-owned files
find node_modules/ -user root -type f | head -10

# Fix ownership recursively
sudo chown -R $(whoami):$(id -gn) node_modules/

# Now install normally
npm install
```

If node_modules is severely corrupted, remove and reinstall:

```bash
rm -rf node_modules package-lock.json
npm install
```

### Step 3: Fix global prefix (global installs)

The recommended approach is to change npm's global prefix to a user-owned directory:

```bash
# Create a dedicated directory
mkdir -p ~/.npm-global

# Tell npm to use it
npm config set prefix '~/.npm-global'

# Add to PATH (for zsh)
echo 'export PATH=~/.npm-global/bin:$PATH' >> ~/.zshrc
source ~/.zshrc

# Verify
npm config get prefix
# Should output: /Users/you/.npm-global
```

If you use pnpm (which handles this better by default):

```bash
pnpm config set global-dir ~/.pnpm-global
pnpm config set global-bin-dir ~/.pnpm-global/bin
```

### Step 4: Fix npm cache permissions

If the npm cache is the problem:

```bash
# Check cache location
npm config get cache

# Fix cache ownership
sudo chown -R $(whoami):$(id -gn) ~/.npm

# Or clean the cache entirely
npm cache clean --force
```

### Step 5: Verify the fix

Ask Claude Code to confirm everything works:

```
Run npm install and verify it completes without permission errors.
Then run npm ls --depth=0 to confirm all dependencies are installed.
```

### Step 6: Handle CI/CD environments

If this happens in CI where Claude Code manages your build pipeline:

```yaml
# GitHub Actions example - ensure correct permissions
- name: Setup Node.js
 uses: actions/setup-node@v4
 with:
 node-version: '20'
 cache: 'npm'

- name: Install dependencies
 run: npm ci
```

In Docker containers, avoid running as root:

```dockerfile
FROM node:20-slim
RUN groupadd -r app && useradd -r -g app app
WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY . .
USER app
```

## Using pnpm Instead

pnpm avoids most EACCES issues because it uses a content-addressable store in user space:

```bash
# Switch to pnpm (no global permission issues)
npm install -g pnpm # last time you need npm for global install
pnpm install
```

Tell Claude Code to prefer pnpm in your CLAUDE.md:

```markdown
## Package Management
- Use pnpm, not npm or yarn
- Run `pnpm install` for dependency installation
- Run `pnpm run` for scripts
```

## Prevention

Never run `sudo npm install` for local project dependencies. If a tutorial tells you to use sudo with npm, it is giving bad advice. The correct fix is always to change ownership or the global prefix.

Add a `.npmrc` file to your project root to enforce consistent behavior:

```ini
engine-strict=true
save-exact=true
fund=false
audit=false
```

This ensures all team members and CI environments use compatible settings.

---


<div class="author-bio">

**Written by Michael** — solo dev, Da Nang, Vietnam. 50K+ Chrome extension users. $500K+ on Upwork (100% Job Success). Runs 5 Claude Max subs in parallel. Built this site with autonomous agent fleets. [See what I'm building →](https://zovo.one)

</div>

---

<div class="mastery-cta">

This took me 3 hours to figure out. I put it in a CLAUDE.md so I'd never figure it out again. Now Claude gets it right on the first try, every project.

16 framework templates. Next.js, FastAPI, Laravel, Rails, Go, Rust, Terraform, and 9 more. Each one 300+ lines of "here's exactly how this stack works." Copy into your project. Done.

**[See the templates →](https://zovo.one/lifetime?utm_source=ccg&utm_medium=cta-config&utm_campaign=claude-code-npm-install-eacces-permission-fix)**

$99 once. Yours forever. I keep adding templates monthly.

</div>

---

## Related Guides

**Configure permissions →** Build your settings with our [Permission Configurator](/permissions/).

**Try it:** Paste your error into our [Error Diagnostic](/diagnose/) for an instant fix.

- [Claude Code Error npm Install Fails in Skill Workflow](/claude-code-error-npm-install-fails-in-skill-workflow/)
- [Claude Code Error Out of Memory Large Codebase Fix](/claude-code-error-out-of-memory-large-codebase-fix/)
- [Claude Code Setup on Mac Step by Step](/claude-code-setup-on-mac-step-by-step/)

## See Also

- [npm Global Install Permission Denied — Fix (2026)](/claude-code-npm-global-install-permission-denied-fix-2026/)
- [Claude Code EACCES Permission Denied Global Install — Fix (2026)](/claude-code-eacces-permission-denied-npm-global-install-fix/)
- [EACCES npm Cache Permission Error — Fix (2026)](/claude-code-eacces-npm-cache-fix-2026/)
- [Getting Started Guide](/getting-started/). From zero to productive with Claude Code
