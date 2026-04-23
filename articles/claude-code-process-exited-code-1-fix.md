---
title: "Fix: Claude Code Process Exited With Code 1 (2026)"
description: "Diagnose and fix Claude Code exit code 1 errors. 10 specific causes with step-by-step tested fixes for macOS, Linux, Windows WSL, and Docker."
permalink: /claude-code-process-exited-code-1-fix/
last_tested: "2026-04-24"
render_with_liquid: false
---

# Fix: Claude Code Process Exited With Code 1 (2026)

## What Exit Code 1 Means

In Unix systems, exit code 0 means success. Exit code 1 means "general error" — the process failed, but the failure is not categorized into a more specific exit code (2 for misuse, 126 for permission denied, 127 for command not found, etc.).

When Claude Code exits with code 1, it means the process started but could not complete its initialization, lost connection during a session, or encountered a fatal error during execution. The fix depends on which specific condition triggered it.

## Error Message Variations

You might see any of these:

```
Error: Process exited with code 1
```

```
claude exited with code 1
```

```
error: claude code process exited with code 1
```

```
npm ERR! code 1
npm ERR! path /usr/local/lib/node_modules/@anthropic-ai/claude-code
```

```
/usr/local/bin/claude: line 1: syntax error near unexpected token
...
exit code 1
```

```
FATAL ERROR: CALL_AND_RETRY_LAST Allocation failed - JavaScript heap out of memory
...exited with code 1
```

```
Error: Cannot find module '@anthropic-ai/claude-code/cli'
...
Process exited with code 1
```

The error message before "exited with code 1" tells you the root cause. If there is no message — just the exit code — work through the diagnostic causes below in order.

## 10 Specific Causes and Fixes

### Cause 1: Node.js Version Mismatch

Claude Code requires Node.js 18.0.0 or later. Running it on Node 16, 14, or a system-installed ancient Node produces a silent crash or syntax error followed by exit code 1.

**Check:**

```bash
node --version
```

If the output is below `v18.0.0`, this is your problem.

**Fix (using nvm):**

```bash
# Install nvm if you don't have it
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash

# Reload shell
source ~/.bashrc  # or ~/.zshrc on macOS

# Install and activate Node 18+
nvm install 20
nvm use 20
nvm alias default 20

# Verify
node --version  # Should show v20.x.x

# Reinstall Claude Code with the correct Node
npm install -g @anthropic-ai/claude-code
```

**Fix (using Homebrew on macOS):**

```bash
brew install node@20
brew link --overwrite node@20
node --version
npm install -g @anthropic-ai/claude-code
```

**Common trap:** Multiple Node installations. Your shell might use `/usr/bin/node` (system Node, often v16) instead of the nvm or Homebrew version. Check which node is being used:

```bash
which node
# Should be something like: /Users/you/.nvm/versions/node/v20.x.x/bin/node
# NOT: /usr/bin/node or /usr/local/bin/node (if that's an old version)
```

### Cause 2: Missing or Expired API Key

Claude Code needs a valid API key to start. If the key is missing, expired, revoked, or malformed, the process exits with code 1 during initialization.

**Check:**

```bash
# For direct API usage:
echo $ANTHROPIC_API_KEY | head -c 15
# Should show: sk-ant-api03-...

# For Claude Pro/Max subscription:
# No API key needed — authentication happens through the browser login
# If login has expired, you'll see an auth error
```

**Fix (API key users):**

1. Go to [console.anthropic.com](https://console.anthropic.com)
2. Navigate to API Keys
3. Check if your key is active (not revoked or expired)
4. If expired, create a new key
5. Set the environment variable:

```bash
export ANTHROPIC_API_KEY="sk-ant-api03-your-key-here"

# Make it permanent:
echo 'export ANTHROPIC_API_KEY="sk-ant-api03-your-key-here"' >> ~/.zshrc
source ~/.zshrc
```

**Fix (Claude Pro/Max users):**

```bash
# Force re-authentication
claude auth logout
claude auth login
# Follow the browser-based login flow
```

**Common trap:** API key set in one shell but not another. If you set the key in `.bashrc` but use `zsh`, or set it in a terminal tab that you closed, new shells will not have it. Verify the key is actually present in the shell where you are running Claude:

```bash
# This should NOT be empty
printenv ANTHROPIC_API_KEY
```

### Cause 3: Network Timeout / Connection Refused

Claude Code connects to `api.anthropic.com` over HTTPS. If this connection fails — corporate firewall, DNS resolution failure, proxy misconfiguration, or API outage — the process exits with code 1.

**Check:**

```bash
# Test basic connectivity
curl -sI https://api.anthropic.com/v1/messages | head -5

# Expected: HTTP/2 401 or HTTP/2 200 (the 401 means the server is reachable; auth is separate)
# Bad: Connection refused, timeout, or DNS resolution error
```

```bash
# Check DNS resolution
nslookup api.anthropic.com

# Check for proxy settings that might interfere
echo $HTTP_PROXY
echo $HTTPS_PROXY
echo $NO_PROXY
```

**Fix (corporate proxy):**

```bash
# Set proxy for Claude Code
export HTTPS_PROXY="http://your-proxy:8080"
export HTTP_PROXY="http://your-proxy:8080"
export NO_PROXY="localhost,127.0.0.1"

# Or configure Node.js specifically
export NODE_EXTRA_CA_CERTS="/path/to/corporate-ca-bundle.crt"
```

**Fix (firewall):**

Ensure outbound HTTPS (port 443) to `api.anthropic.com` is allowed. If your organization uses a firewall allowlist, add:

```
api.anthropic.com:443
```

**Fix (VPN issues):**

Some VPNs interfere with DNS or route traffic through regions where the API has higher latency. Try disconnecting the VPN temporarily to verify the connection works, then work with your IT team to allowlist the API endpoint.

**Fix (API outage):**

Check [status.anthropic.com](https://status.anthropic.com) for current incidents. If the API is down, wait for recovery.

### Cause 4: Insufficient Disk Space

Claude Code writes temporary files, caches conversation state, and stores configuration in `~/.claude/`. If the filesystem is full, write operations fail and the process crashes with exit code 1.

**Check:**

```bash
# Check disk space on the relevant filesystems
df -h /tmp
df -h ~
df -h /

# Check how much space ~/.claude/ uses
du -sh ~/.claude/ 2>/dev/null
```

**Fix:**

```bash
# Clear Claude Code's cache
rm -rf ~/.claude/cache/

# Clear Node.js temp files
rm -rf /tmp/claude-*
rm -rf /tmp/npm-*

# Clear npm cache
npm cache clean --force

# If /tmp is full (common on Linux servers):
sudo rm -rf /tmp/npm-*
sudo rm -rf /tmp/node-*

# Verify space was freed
df -h /tmp
```

If your root filesystem is full, clear space outside of Claude's directories first — Docker images, old logs, and package caches are common culprits:

```bash
# Docker (can reclaim GBs)
docker system prune -af

# Old log files
sudo journalctl --vacuum-size=100M

# Old package manager caches
brew cleanup        # macOS
sudo apt clean      # Ubuntu/Debian
```

### Cause 5: Permission Denied on Config Directory

Claude Code reads and writes to `~/.claude/`. If this directory has wrong ownership or restrictive permissions — often caused by running Claude with `sudo` once — the process cannot access its own configuration.

**Check:**

```bash
ls -la ~/.claude/
# Look at the owner and permissions
# If owner is "root" instead of your username, this is the problem
```

```bash
# Check if the directory is writable
touch ~/.claude/test-write-permission 2>&1
rm -f ~/.claude/test-write-permission
```

**Fix:**

```bash
# Fix ownership (replace YOUR_USERNAME with your actual username)
sudo chown -R $(whoami) ~/.claude/

# Fix permissions
chmod -R 755 ~/.claude/

# Verify
ls -la ~/.claude/
```

**Prevention:** Never run Claude Code with `sudo`. If you installed it globally with `sudo npm install -g`, that is fine — but running `sudo claude` is what causes the ownership problem. The global install needs sudo; the execution does not.

If you have been running Claude Code with `sudo`, also check:

```bash
# These should all be owned by your user, not root
ls -la ~/.claude/settings.json
ls -la ~/.claude/credentials.json
ls -la ~/.claude/cache/
```

### Cause 6: Corrupted Installation

npm installations can become corrupted through interrupted installs, version conflicts, filesystem errors, or partial upgrades. The symptoms are cryptic JavaScript errors followed by exit code 1.

**Check:**

```bash
# See if the main binary resolves
which claude

# Check if the package files are intact
npm ls -g @anthropic-ai/claude-code 2>&1
# If this shows "missing" or "ELSPROBLEMS", the installation is corrupted
```

**Fix:**

```bash
# Complete removal and clean reinstall
npm uninstall -g @anthropic-ai/claude-code

# Clear any cached artifacts
npm cache clean --force

# Remove any leftover files (check the path from 'which claude' first)
rm -f $(which claude 2>/dev/null)

# Fresh install
npm install -g @anthropic-ai/claude-code

# Verify
claude --version
```

**If npm itself is broken:**

```bash
# On macOS with Homebrew Node:
brew reinstall node
npm install -g @anthropic-ai/claude-code

# With nvm:
nvm install 20 --reinstall-packages-from=current
npm install -g @anthropic-ai/claude-code
```

For persistent npm permission errors during global installs, see [Permission Denied Shell Commands Fix](/claude-code-permission-denied-shell-commands-fix/).

### Cause 7: Conflicting Process / Port Already in Use

Claude Code's internal server may conflict with another process. This is less common but happens when a previous Claude Code session did not shut down cleanly and a socket or lock file remains.

**Check:**

```bash
# Look for zombie Claude processes
ps aux | grep -i claude | grep -v grep

# Check for lock files
ls -la ~/.claude/*.lock 2>/dev/null
ls -la ~/.claude/cache/*.lock 2>/dev/null
```

**Fix:**

```bash
# Kill any lingering Claude processes
pkill -f "claude-code" 2>/dev/null
pkill -f "@anthropic-ai/claude" 2>/dev/null

# Remove stale lock files
rm -f ~/.claude/*.lock
rm -f ~/.claude/cache/*.lock

# Try again
claude
```

**If a specific port is in use:**

```bash
# Find what's using the port (replace PORT with the actual port number from the error)
lsof -i :PORT

# Kill the process using it
kill -9 PID_FROM_ABOVE
```

### Cause 8: Package Dependency Conflict

Global npm packages can conflict with each other. If you have another global package that installs a different version of a shared dependency, Claude Code's modules may fail to load.

**Check:**

```bash
# List all global packages
npm ls -g --depth=0

# Look for errors in the dependency tree
npm ls -g @anthropic-ai/claude-code
```

**Fix:**

```bash
# Clear npm cache
npm cache clean --force

# Remove the package completely
npm uninstall -g @anthropic-ai/claude-code

# Remove the npm cache for this specific package
rm -rf $(npm root -g)/@anthropic-ai/claude-code

# Reinstall from scratch
npm install -g @anthropic-ai/claude-code
```

**Nuclear option (if nothing else works):**

```bash
# Remove ALL global npm packages (use with caution)
# First, save a list of what you have
npm ls -g --depth=0 > ~/npm-global-backup.txt

# Clear everything
rm -rf $(npm root -g)/*

# Reinstall only Claude Code
npm install -g @anthropic-ai/claude-code

# Reinstall other packages you need from your backup list
```

### Cause 9: WSL-Specific Issues (Windows)

Running Claude Code in Windows Subsystem for Linux introduces a layer of complexity. WSL1 has known networking and filesystem issues that cause silent exit code 1 failures.

**Check:**

```bash
# Verify WSL version
wsl.exe -l -v
# Version 2 is required for reliable operation
```

```bash
# Check if DNS resolution works inside WSL
nslookup api.anthropic.com

# Check if the clock is synced (WSL clock drift causes TLS failures)
date
# Compare with actual time — if it's off by more than a few minutes, this is the issue
```

**Fix (WSL1 to WSL2 upgrade):**

```powershell
# In PowerShell (as admin):
wsl --set-version Ubuntu 2

# Or set WSL2 as default for new distros:
wsl --set-default-version 2
```

**Fix (DNS resolution in WSL2):**

```bash
# Create or edit /etc/wsl.conf
sudo tee /etc/wsl.conf << 'EOF'
[network]
generateResolvConf = false
EOF

# Set a reliable DNS server
sudo rm /etc/resolv.conf
sudo tee /etc/resolv.conf << 'EOF'
nameserver 8.8.8.8
nameserver 8.8.4.4
EOF

# Restart WSL (from PowerShell):
# wsl --shutdown
# Then reopen your WSL terminal
```

**Fix (clock drift):**

```bash
# Sync the WSL clock
sudo hwclock -s
# Or:
sudo ntpdate time.windows.com
```

**Fix (network bridge configuration):**

If WSL2 cannot reach the internet, the virtual network adapter may need configuration:

```powershell
# In PowerShell (as admin):
# Create .wslconfig in your Windows user profile
notepad "$env:USERPROFILE\.wslconfig"
```

Add:
```ini
[wsl2]
networkingMode=mirrored
```

Then restart WSL.

### Cause 10: Docker Container OOM / Resource Limits

When running Claude Code inside Docker, the container may hit memory limits, CPU limits, or lack required system capabilities, causing the Node.js process to be killed with exit code 1.

**Check:**

```bash
# Check container memory limit
docker stats --no-stream

# Check if the container was OOM-killed
docker inspect CONTAINER_ID | grep -i oom
```

**Fix (increase memory):**

```bash
# Run with explicit memory allocation (2GB minimum recommended)
docker run --rm \
  --memory=4g \
  --memory-swap=4g \
  -e ANTHROPIC_API_KEY="$ANTHROPIC_API_KEY" \
  my-claude-image "your prompt"
```

**Fix (Docker Compose):**

```yaml
services:
  claude:
    image: my-claude-image
    deploy:
      resources:
        limits:
          memory: 4G
          cpus: "2.0"
        reservations:
          memory: 2G
    environment:
      - ANTHROPIC_API_KEY=${ANTHROPIC_API_KEY}
      - NODE_OPTIONS=--max-old-space-size=3072
```

**Fix (increase Node.js heap size):**

```bash
# Set inside the container or Dockerfile
export NODE_OPTIONS="--max-old-space-size=3072"
claude -p "your prompt" --dangerously-skip-permissions
```

**Fix (base image):**

Ensure your Dockerfile uses a sufficient base image:

```dockerfile
# Good — full Node with required system libraries
FROM node:20-slim

# Bad — too minimal, missing required libraries
FROM alpine:latest
```

Alpine-based images may be missing `glibc` or other libraries Claude Code depends on. Use `node:20-slim` (Debian-based) as the minimum viable base image.

See [Docker Container Setup](/claude-code-docker-container-setup-2026/) and [Docker Build Failed Fix](/claude-code-docker-build-failed-fix/) for complete Docker configuration guides.

## Environment-Specific Guides

### macOS

macOS is the most common Claude Code environment. The typical issues are:

**Homebrew Node conflicts with nvm:**

```bash
# Check if both exist
which -a node
# If you see multiple entries (e.g., /usr/local/bin/node AND ~/.nvm/versions/...)

# Fix: remove Homebrew Node if using nvm
brew uninstall node

# Or remove nvm if using Homebrew
rm -rf ~/.nvm
# Then remove the nvm lines from ~/.zshrc
```

**System Integrity Protection (SIP) blocks writes:**

If Claude Code cannot write to certain directories, SIP may be involved. The fix is to use Claude Code's default config directory (`~/.claude/`) which is always writable.

**macOS keychain prompt loops:**

Some macOS versions prompt repeatedly for keychain access when Claude Code reads credentials. Fix:

```bash
# Store the API key in the environment instead of the keychain
echo 'export ANTHROPIC_API_KEY="your-key"' >> ~/.zshrc
source ~/.zshrc
```

### Linux (Ubuntu/Debian)

```bash
# Install Node.js 20 (if not using nvm)
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
sudo apt-get install -y nodejs

# Install Claude Code
npm install -g @anthropic-ai/claude-code

# If you get EACCES errors on global install:
mkdir -p ~/.npm-global
npm config set prefix '~/.npm-global'
echo 'export PATH=~/.npm-global/bin:$PATH' >> ~/.bashrc
source ~/.bashrc
npm install -g @anthropic-ai/claude-code
```

### Linux (Fedora/RHEL)

```bash
# Install Node.js 20
sudo dnf module enable nodejs:20
sudo dnf install nodejs

# Or use nvm (works on any distro)
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash
source ~/.bashrc
nvm install 20
nvm use 20

npm install -g @anthropic-ai/claude-code
```

### Windows WSL

```bash
# Confirm WSL2 (from PowerShell: wsl -l -v)

# Inside WSL, install nvm
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash
source ~/.bashrc
nvm install 20
nvm use 20

# Set API key
export ANTHROPIC_API_KEY="your-key"
echo 'export ANTHROPIC_API_KEY="your-key"' >> ~/.bashrc

# Install
npm install -g @anthropic-ai/claude-code

# Test
claude --version
```

### Docker

Minimum viable Dockerfile for Claude Code:

```dockerfile
FROM node:20-slim

# Install Claude Code
RUN npm install -g @anthropic-ai/claude-code

# Set working directory
WORKDIR /app

# Increase Node memory for large codebases
ENV NODE_OPTIONS="--max-old-space-size=3072"

ENTRYPOINT ["claude"]
```

Build and run:

```bash
docker build -t claude-code .
docker run --rm \
  -e ANTHROPIC_API_KEY="$ANTHROPIC_API_KEY" \
  -v $(pwd):/app \
  --memory=4g \
  claude-code \
  -p "Your prompt here" \
  --dangerously-skip-permissions \
  --max-turns 10
```

For production Docker setups, see [Docker Container Setup](/claude-code-docker-container-setup-2026/).

## Diagnostic Flowchart

Start here and follow the path until you find your issue.

**Step 1: Does `claude --version` output a version number?**
- YES: Go to Step 3
- NO: Go to Step 2

**Step 2: Is Claude Code installed?**
```bash
npm ls -g @anthropic-ai/claude-code
```
- NOT INSTALLED: Run `npm install -g @anthropic-ai/claude-code` then retry
- INSTALLED BUT BROKEN: See [Cause 6: Corrupted Installation](#cause-6-corrupted-installation)

**Step 3: Is Node.js 18+?**
```bash
node --version
```
- BELOW v18: See [Cause 1: Node.js Version Mismatch](#cause-1-nodejs-version-mismatch)
- v18 OR ABOVE: Go to Step 4

**Step 4: Is the API key set?**
```bash
printenv ANTHROPIC_API_KEY
```
- EMPTY: See [Cause 2: Missing or Expired API Key](#cause-2-missing-or-expired-api-key)
- SET: Go to Step 5

**Step 5: Can you reach the API?**
```bash
curl -sI https://api.anthropic.com/v1/messages | head -1
```
- TIMEOUT/ERROR: See [Cause 3: Network Timeout](#cause-3-network-timeout--connection-refused)
- HTTP RESPONSE: Go to Step 6

**Step 6: Is there disk space?**
```bash
df -h /tmp && df -h ~
```
- LESS THAN 1GB FREE: See [Cause 4: Insufficient Disk Space](#cause-4-insufficient-disk-space)
- PLENTY OF SPACE: Go to Step 7

**Step 7: Is ~/.claude/ owned by your user?**
```bash
ls -la ~/.claude/ | head -3
```
- OWNED BY ROOT: See [Cause 5: Permission Denied on Config Directory](#cause-5-permission-denied-on-config-directory)
- OWNED BY YOU: Go to Step 8

**Step 8: Are there stale processes?**
```bash
ps aux | grep claude | grep -v grep | wc -l
```
- MORE THAN 0: See [Cause 7: Conflicting Process](#cause-7-conflicting-process--port-already-in-use)
- ZERO: Go to Step 9

**Step 9: Are you running in WSL?**
- YES: See [Cause 9: WSL-Specific Issues](#cause-9-wsl-specific-issues-windows)
- NO: Go to Step 10

**Step 10: Are you running in Docker?**
- YES: See [Cause 10: Docker Container OOM](#cause-10-docker-container-oom--resource-limits)
- NO: Try the nuclear reinstall in [Cause 6](#cause-6-corrupted-installation)

## Prevention: CLAUDE.md and Settings Configuration

Add these checks to your project to prevent exit code 1 errors for your team:

```markdown
# CLAUDE.md — Environment Requirements

## Prerequisites
- Node.js 20+ (check with `node --version`)
- npm 10+ (check with `npm --version`)
- At least 2GB free disk space
- ANTHROPIC_API_KEY environment variable set

## First-Time Setup
Run `./scripts/verify-environment.sh` before starting Claude Code.
```

Create the verification script:

```bash
#!/bin/bash
# scripts/verify-environment.sh — Verify Claude Code can run

set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

ERRORS=0

# Check Node version
NODE_VERSION=$(node --version 2>/dev/null | sed 's/v//' | cut -d. -f1)
if [ -z "$NODE_VERSION" ] || [ "$NODE_VERSION" -lt 18 ]; then
  echo -e "${RED}FAIL: Node.js 18+ required (found: $(node --version 2>/dev/null || echo 'not installed'))${NC}"
  ERRORS=$((ERRORS + 1))
else
  echo -e "${GREEN}OK: Node.js $(node --version)${NC}"
fi

# Check Claude Code installed
if ! command -v claude &>/dev/null; then
  echo -e "${RED}FAIL: Claude Code not installed (run: npm install -g @anthropic-ai/claude-code)${NC}"
  ERRORS=$((ERRORS + 1))
else
  echo -e "${GREEN}OK: Claude Code $(claude --version 2>/dev/null)${NC}"
fi

# Check API key
if [ -z "${ANTHROPIC_API_KEY:-}" ]; then
  echo -e "${RED}FAIL: ANTHROPIC_API_KEY not set${NC}"
  ERRORS=$((ERRORS + 1))
else
  echo -e "${GREEN}OK: ANTHROPIC_API_KEY is set (${ANTHROPIC_API_KEY:0:12}...)${NC}"
fi

# Check network
if ! curl -sI https://api.anthropic.com/v1/messages --max-time 5 >/dev/null 2>&1; then
  echo -e "${RED}FAIL: Cannot reach api.anthropic.com${NC}"
  ERRORS=$((ERRORS + 1))
else
  echo -e "${GREEN}OK: api.anthropic.com reachable${NC}"
fi

# Check disk space (need at least 500MB free)
FREE_KB=$(df -k /tmp | tail -1 | awk '{print $4}')
if [ "$FREE_KB" -lt 512000 ]; then
  echo -e "${RED}FAIL: Less than 500MB free on /tmp${NC}"
  ERRORS=$((ERRORS + 1))
else
  echo -e "${GREEN}OK: $(df -h /tmp | tail -1 | awk '{print $4}') free on /tmp${NC}"
fi

# Check ~/.claude permissions
if [ -d ~/.claude ] && [ ! -w ~/.claude ]; then
  echo -e "${RED}FAIL: ~/.claude is not writable (run: sudo chown -R $(whoami) ~/.claude)${NC}"
  ERRORS=$((ERRORS + 1))
else
  echo -e "${GREEN}OK: ~/.claude is writable${NC}"
fi

echo ""
if [ "$ERRORS" -gt 0 ]; then
  echo -e "${RED}$ERRORS issue(s) found. Fix them before running Claude Code.${NC}"
  exit 1
else
  echo -e "${GREEN}All checks passed. Claude Code is ready.${NC}"
fi
```

Make it executable:

```bash
chmod +x scripts/verify-environment.sh
```

For team environments, run this as a git hook or CI step. See [Hooks Guide](/claude-code-hooks-explained/) for integrating this into your Claude Code workflow.

## Frequently Asked Questions

### I get exit code 1 but no error message. How do I get more details?

Run Claude Code with verbose output:

```bash
DEBUG=* claude 2>&1 | tee claude-debug.log
```

Or check if Node produces a stack trace:

```bash
node $(which claude) 2>&1
```

The raw Node invocation often shows the full error that the launcher script suppresses.

### Does exit code 1 mean my API key is being charged?

No. If Claude Code exits during initialization (before making an API call), no tokens are consumed and nothing is charged. If the exit happens mid-conversation (network drop, OOM), you may have been charged for any API calls that completed before the crash.

### I fixed the issue but Claude Code still exits with code 1. What now?

Clear all cached state:

```bash
rm -rf ~/.claude/cache/
rm -rf /tmp/claude-*
npm cache clean --force
```

Then restart your terminal (not just run `source ~/.zshrc` — actually close and reopen the terminal application). Some environment variable changes do not take effect until a fresh shell process starts.

### Exit code 1 only happens in my CI pipeline, not locally. Why?

CI runners have different environments than your local machine. The most common CI-specific causes are:

1. Node.js version pinned too low in the CI config
2. API key not available as an environment variable (secret not configured)
3. Network restrictions in the CI runner's environment
4. Insufficient memory allocation for the CI runner

Check your CI config for the Node version and ensure secrets are properly configured. See [CI/CD Integration Guide](/claude-code-ci-cd-integration-guide-2026/) and [CI/CD Runner Missing Dependencies Fix](/claude-code-ci-cd-runner-missing-dependencies-fix-2026/).

### Can exit code 1 corrupt my project files?

Unlikely. If Claude Code crashes mid-edit, the file being edited may be in a partially written state. But Claude Code uses atomic writes for most operations (write to temp file, then rename), so the risk is minimal. Use git to check for unexpected changes:

```bash
git status
git diff
```

If you find partial edits, revert them with `git checkout -- path/to/file`.

### Is exit code 1 different from exit code 137 or exit code 139?

Yes, and the distinction matters:

- **Exit code 1**: General application error (covered in this guide)
- **Exit code 137**: Process killed by SIGKILL — usually OOM killer on Linux or Docker memory limit exceeded
- **Exit code 139**: Segmentation fault — rare with Claude Code, usually indicates a native module crash
- **Exit code 127**: Command not found — Claude Code is not installed or not in PATH
- **Exit code 126**: Permission denied on the executable — fix with `chmod +x $(which claude)`

For exit code 137, see [Cause 10: Docker Container OOM](#cause-10-docker-container-oom--resource-limits). The fix is the same: increase memory limits.

### I am on a company-managed laptop. Can IT policy cause exit code 1?

Yes. Common IT-managed causes:

- **Certificate pinning** that blocks connections to api.anthropic.com (fix: get IT to allowlist the domain)
- **Antivirus** that quarantines Node.js modules (fix: add an exception for the npm global directory)
- **Disk encryption** that causes slow write operations and timeouts (fix: increase timeout settings)
- **Software restrictions** that block running global npm packages (fix: use npx instead of global install)

```bash
# Alternative: run without global install
npx @anthropic-ai/claude-code
```

### How do I report exit code 1 if none of these fixes work?

Gather this diagnostic information and report it to Anthropic:

```bash
# Run this and include the full output in your report
echo "=== System Info ==="
uname -a
echo "=== Node Version ==="
node --version
echo "=== npm Version ==="
npm --version
echo "=== Claude Code Version ==="
claude --version 2>&1 || echo "Could not get version"
echo "=== Claude Code Path ==="
which claude
echo "=== Package Info ==="
npm ls -g @anthropic-ai/claude-code 2>&1
echo "=== Disk Space ==="
df -h /tmp ~
echo "=== ~/.claude permissions ==="
ls -la ~/.claude/ 2>&1
echo "=== Debug Output ==="
DEBUG=* claude --version 2>&1 | tail -50
```

Post this output in the [Claude Code GitHub Issues](https://github.com/anthropics/claude-code/issues) or include it in a support request.

## Related Guides

- [Permission Denied Shell Commands Fix](/claude-code-permission-denied-shell-commands-fix/) — When Claude Code runs but cannot execute commands
- [Permission Denied Sandbox Mode Fix](/claude-code-permission-denied-sandbox-mode-fix-2026/) — Sandbox-specific permission issues
- [Docker Container Setup](/claude-code-docker-container-setup-2026/) — Building reliable Docker environments for Claude Code
- [Docker Build Failed Fix](/claude-code-docker-build-failed-fix/) — When Docker builds fail during Claude Code installation
- [CI/CD Integration Guide](/claude-code-ci-cd-integration-guide-2026/) — Setting up Claude Code in automated pipelines
- [CI/CD Runner Missing Dependencies](/claude-code-ci-cd-runner-missing-dependencies-fix-2026/) — Fixing dependency issues in CI environments
- [Security Threat Model](/claude-code-security-threat-model-2026/) — Understanding Claude Code's security architecture
- [The Claude Code Playbook](/the-claude-code-playbook/) — Complete guide to working with Claude Code effectively
