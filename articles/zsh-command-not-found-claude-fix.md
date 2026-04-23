---
title: "Fix zsh: command not found: claude (2026)"
description: "Fix the zsh command not found claude error. Six causes with step-by-step PATH, Node.js, and permission fixes for macOS, Linux, and WSL shells."
permalink: /zsh-command-not-found-claude-fix/
last_tested: "2026-04-24"
render_with_liquid: false
---

## The Error

```
zsh: command not found: claude
```

Or in bash:

```
bash: claude: command not found
```

This error means your shell cannot find the `claude` executable in any directory listed in your `$PATH`. The Claude Code CLI is either not installed, installed in a non-standard location, or your shell configuration is missing the correct PATH entry.

## Cause 1: Claude Code Is Not Installed

The most common cause. Claude Code is an npm package that must be installed globally.

**Fix:**

```bash
npm install -g @anthropic-ai/claude-code
```

Verify the installation:

```bash
which claude && claude --version
```

Expected output:

```
/usr/local/bin/claude    # or ~/.npm-global/bin/claude
claude-code 1.x.x
```

If `npm install -g` fails with a permission error, do not use `sudo`. See Cause 6 below.

## Cause 2: Wrong Node.js Version

Claude Code requires Node.js 18 or later. Older versions will either fail to install the package or install it in an incompatible state.

**Diagnose:**

```bash
node --version
```

If the output shows `v16.x.x` or lower, you need to upgrade.

**Fix:**

```bash
# Using nvm (recommended)
nvm install 22
nvm use 22
nvm alias default 22

# Verify
node --version
# Expected: v22.x.x

# Now install Claude Code
npm install -g @anthropic-ai/claude-code
```

If you do not have nvm installed:

```bash
# Install nvm
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash

# Reload shell
source ~/.zshrc

# Install Node 22
nvm install 22
```

On macOS, if you installed Node through Homebrew:

```bash
brew update && brew upgrade node
```

## Cause 3: npm Global Bin Directory Not in PATH

npm installs global packages in a directory that may not be in your shell's PATH. This is the second most common cause of the error.

**Diagnose:**

```bash
# Where does npm put global binaries?
npm config get prefix

# Is that directory's bin/ in your PATH?
echo $PATH | tr ':' '\n' | grep "$(npm config get prefix)"
```

If the grep returns nothing, the npm bin directory is not in your PATH.

**Fix:**

```bash
# Get the npm prefix
NPM_PREFIX=$(npm config get prefix)

# Add to PATH for the current session
export PATH="$NPM_PREFIX/bin:$PATH"

# Verify it works now
which claude
```

Then make it permanent (see the shell-specific sections below).

## Cause 4: Installed with a Different Package Manager

If you installed Claude Code with yarn or pnpm instead of npm, the binary is in a different location.

**Diagnose:**

```bash
# Check all possible locations
ls -la $(npm config get prefix)/bin/claude 2>/dev/null
ls -la $(yarn global bin 2>/dev/null)/claude 2>/dev/null
ls -la $(pnpm bin -g 2>/dev/null)/claude 2>/dev/null
```

**Fix for yarn:**

```bash
# Find yarn's global bin
yarn global bin
# Example output: /Users/you/.yarn/bin

# Add to PATH
export PATH="$(yarn global bin):$PATH"
```

**Fix for pnpm:**

```bash
# Find pnpm's global bin
pnpm bin -g
# Example output: /Users/you/Library/pnpm

# Add to PATH
export PATH="$(pnpm bin -g):$PATH"
```

**Recommended approach:** Uninstall from yarn/pnpm and reinstall with npm for consistency:

```bash
yarn global remove @anthropic-ai/claude-code 2>/dev/null
pnpm remove -g @anthropic-ai/claude-code 2>/dev/null
npm install -g @anthropic-ai/claude-code
```

## Cause 5: Shell Configuration Not Sourced

You added the PATH export to your shell config file, but the current terminal session is using an older environment that does not include it.

**Diagnose:**

```bash
# Check if your shell config has the PATH entry
grep -n "claude\|npm.*bin\|NPM_PREFIX" ~/.zshrc ~/.bashrc ~/.bash_profile 2>/dev/null
```

**Fix:**

```bash
# Reload your shell configuration
source ~/.zshrc    # for zsh
source ~/.bashrc   # for bash

# Or simply open a new terminal window
```

If the PATH entry is missing from your config file entirely, add it:

```bash
# For zsh (default on macOS)
echo 'export PATH="$(npm config get prefix)/bin:$PATH"' >> ~/.zshrc
source ~/.zshrc

# For bash
echo 'export PATH="$(npm config get prefix)/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc
```

## Cause 6: macOS Permission Issues with /usr/local

On macOS, npm's default global prefix is `/usr/local`, which requires elevated permissions. If you ran `sudo npm install -g` in the past, the `/usr/local/lib/node_modules` directory may be owned by root, causing future non-sudo installs to fail silently.

**Diagnose:**

```bash
ls -la /usr/local/lib/node_modules/ | head -5
# If you see "root" as the owner, permissions are wrong

npm install -g @anthropic-ai/claude-code 2>&1
# Look for EACCES errors
```

**Fix (Option A -- change npm prefix to a user-owned directory):**

```bash
# Create a directory for global packages
mkdir -p ~/.npm-global

# Configure npm to use it
npm config set prefix ~/.npm-global

# Add to PATH
echo 'export PATH="$HOME/.npm-global/bin:$PATH"' >> ~/.zshrc
source ~/.zshrc

# Now install without sudo
npm install -g @anthropic-ai/claude-code
```

**Fix (Option B -- fix ownership of /usr/local):**

```bash
sudo chown -R $(whoami) /usr/local/lib/node_modules
sudo chown -R $(whoami) /usr/local/bin
npm install -g @anthropic-ai/claude-code
```

Option A is safer because it avoids touching system directories. Option B works if you are the only user on the machine.

**Never use `sudo npm install -g`.** It creates root-owned files in your global node_modules, which causes cascading permission problems for every future global install.

## Shell-Specific Permanent PATH Fixes

### zsh (default on macOS)

```bash
# Edit your zsh config
nano ~/.zshrc

# Add this line at the end:
export PATH="$(npm config get prefix)/bin:$PATH"

# If using nvm, make sure the nvm block loads first:
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
export PATH="$(npm config get prefix)/bin:$PATH"

# Save and reload
source ~/.zshrc
```

### bash

```bash
# On macOS, bash reads ~/.bash_profile for login shells
echo 'export PATH="$(npm config get prefix)/bin:$PATH"' >> ~/.bash_profile
source ~/.bash_profile

# On Linux, bash reads ~/.bashrc for interactive shells
echo 'export PATH="$(npm config get prefix)/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc
```

### fish

```bash
# Fish uses a different syntax
set -Ux fish_user_paths (npm config get prefix)/bin $fish_user_paths

# Verify
which claude
```

## Complete Diagnostic Script

Run this to identify exactly what is wrong:

```bash
echo "=== Node.js ==="
which node && node --version || echo "Node.js NOT FOUND"

echo ""
echo "=== npm ==="
which npm && npm --version || echo "npm NOT FOUND"

echo ""
echo "=== npm global prefix ==="
npm config get prefix 2>/dev/null || echo "Cannot determine npm prefix"

echo ""
echo "=== Claude Code installed? ==="
npm list -g @anthropic-ai/claude-code 2>/dev/null || echo "Claude Code NOT installed globally"

echo ""
echo "=== Claude binary location ==="
find "$(npm config get prefix 2>/dev/null)/bin" -name "claude" 2>/dev/null || echo "claude binary not found in npm bin"

echo ""
echo "=== PATH contains npm bin? ==="
NPM_BIN="$(npm config get prefix 2>/dev/null)/bin"
echo "$PATH" | tr ':' '\n' | grep -q "$NPM_BIN" && echo "YES: $NPM_BIN is in PATH" || echo "NO: $NPM_BIN is NOT in PATH"

echo ""
echo "=== Shell ==="
echo "$SHELL"
echo "Config files:"
ls -la ~/.zshrc ~/.bashrc ~/.bash_profile 2>/dev/null
```

This script tells you exactly which cause applies to your situation. Fix the identified issue using the corresponding section above.

## Verifying the Fix

After applying any fix, run this verification sequence:

```bash
# 1. Check the binary is found
which claude
# Expected: a path like /usr/local/bin/claude or ~/.npm-global/bin/claude

# 2. Check the version
claude --version
# Expected: claude-code followed by a version number

# 3. Run a quick test
claude -p "Say hello"
# Expected: A response from Claude
```

If `which claude` still returns nothing after following the steps above, open a brand new terminal window (not a new tab in the same window). Some terminal emulators cache the PATH from the session that spawned them.

## FAQ

### I installed Claude Code but it only works in one terminal window. Why?

You added the PATH export to the current session with `export PATH=...` but did not add it to your shell configuration file (~/.zshrc or ~/.bashrc). The fix applies only to the terminal where you ran it. Add the export line to your config file and source it.

### Should I use sudo to install Claude Code globally?

No. Using `sudo npm install -g` creates root-owned files that break future installs. Instead, change your npm prefix to a user-owned directory (see Cause 6, Option A).

### I use nvm and the error comes back after switching Node versions.

nvm installs global packages per Node version. When you switch versions with `nvm use`, you lose packages installed under the previous version. Reinstall after switching: `nvm use 22 && npm install -g @anthropic-ai/claude-code`.

### Does Claude Code work on Windows?

Claude Code requires macOS or Linux (including WSL on Windows). It does not run natively on Windows outside of WSL. In WSL, the error would show as `bash: claude: command not found` and the same PATH fixes apply.

### The install succeeded but `which claude` shows a different path than expected. Is that a problem?

Not necessarily. As long as `which claude` returns a valid path and `claude --version` outputs a version number, the installation is correct. Different paths occur depending on whether you use nvm, Homebrew, or a custom npm prefix.

### I see `ENOENT` errors during installation. What does that mean?

`ENOENT` means a file or directory was not found during the install process. This usually indicates a corrupted npm cache. Fix it with: `npm cache clean --force && npm install -g @anthropic-ai/claude-code`.

## Related Guides

- [The Claude Code Playbook](/the-claude-code-playbook/)
- [Fix Claude Code ETIMEOUT Corporate Proxy](/claude-code-etimeout-corporate-proxy-fix/)
- [Fix Claude Internal Server Error](/claude-internal-server-error-fix/)
- [Fix Claude Code Rate Limit 429 Error](/claude-code-rate-limit-429-retry-after-fix/)
- [Fix Claude Code Docker Cannot Reach API Endpoint](/claude-code-docker-cannot-reach-api-endpoint-fix/)
- [Fix Claude Code Model Not Available in Region](/claude-code-model-not-available-region-fix/)
- [Fix Claude API 503 Service Unavailable](/claude-api-503-service-unavailable-fix/)
- [Fix Claude Rate Exceeded Error](/claude-rate-exceeded-error-fix/)
