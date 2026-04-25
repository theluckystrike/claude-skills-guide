---
title: "Fix: Claude Code Process Exited (2026)"
description: "Diagnose and fix Claude Code exit code 1 errors. 10 specific causes with step-by-step tested fixes for macOS, Linux, Windows WSL, and Docker."
permalink: /claude-code-process-exited-code-1-fix/
last_tested: "2026-04-24"
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

<div id="diag-tool" style="background:#1a1a2e;border:1px solid #2a2a3a;border-radius:8px;padding:20px;margin:24px 0;font-family:system-ui,-apple-system,sans-serif;">
<h3 style="color:#6ee7b7;margin:0 0 12px 0;font-size:18px;">Exit Code 1 Diagnostic</h3>
<p style="color:#94a3b8;margin:0 0 16px 0;font-size:14px;">Answer two questions to get your specific fix.</p>
<div style="margin-bottom:12px;">
<label style="color:#e2e8f0;font-size:14px;display:block;margin-bottom:4px;">Your operating system:</label>
<select id="diag-os" style="width:100%;padding:8px;background:#0f172a;color:#e2e8f0;border:1px solid #334155;border-radius:6px;font-size:14px;">
<option value="">Select OS...</option>
<option value="mac">macOS</option>
<option value="linux">Linux (Ubuntu/Debian)</option>
<option value="fedora">Linux (Fedora/RHEL)</option>
<option value="wsl">Windows (WSL)</option>
<option value="docker">Docker</option>
</select>
</div>
<div style="margin-bottom:16px;">
<label style="color:#e2e8f0;font-size:14px;display:block;margin-bottom:4px;">What happens when you run <code style="background:#0f172a;padding:2px 6px;border-radius:3px;">claude</code>?</label>
<select id="diag-sym" style="width:100%;padding:8px;background:#0f172a;color:#e2e8f0;border:1px solid #334155;border-radius:6px;font-size:14px;">
<option value="">Select symptom...</option>
<option value="notfound">Command not found</option>
<option value="apikey">API key error</option>
<option value="network">Network/connection error</option>
<option value="permission">Permission denied</option>
<option value="crash">Immediate crash with exit code 1</option>
<option value="hang">Hangs then exits</option>
</select>
</div>
<div id="diag-result" style="background:#0f172a;padding:16px;border-radius:6px;color:#e2e8f0;font-size:14px;min-height:40px;display:none;"></div>
</div>
{% raw %}
<script>
var df={mac:{notfound:"Run: <code>npm install -g @anthropic-ai/claude-code</code><br>Then restart your terminal. If using nvm: <code>nvm use 18 && npm i -g @anthropic-ai/claude-code</code>",apikey:"Run: <code>echo $ANTHROPIC_API_KEY</code><br>If empty: <code>export ANTHROPIC_API_KEY='sk-ant-...'</code><br>Add to ~/.zshrc for persistence.",network:"Check: <code>curl -s https://api.anthropic.com/v1/messages</code><br>If timeout: check VPN/proxy. Try: <code>networksetup -setv6off Wi-Fi</code>",permission:"Run: <code>sudo chown -R $(whoami) $(npm prefix -g)</code><br>Then reinstall: <code>npm i -g @anthropic-ai/claude-code</code>",crash:"Check Node version: <code>node -v</code> (need 18+)<br>Check disk: <code>df -h ~</code> (need 1GB free)<br>Reinstall: <code>npm rm -g @anthropic-ai/claude-code && npm i -g @anthropic-ai/claude-code</code>",hang:"Check: <code>curl -m 5 https://api.anthropic.com/v1/messages</code><br>If slow: corporate proxy may be interfering. Try direct connection."},linux:{notfound:"Run: <code>sudo npm install -g @anthropic-ai/claude-code</code><br>Or with nvm: <code>nvm install 18 && npm i -g @anthropic-ai/claude-code</code>",apikey:"Run: <code>echo $ANTHROPIC_API_KEY</code><br>If empty: <code>export ANTHROPIC_API_KEY='sk-ant-...'</code><br>Add to ~/.bashrc for persistence.",network:"Check: <code>curl -sv https://api.anthropic.com/v1/messages 2>&1 | head -20</code><br>Check DNS: <code>nslookup api.anthropic.com</code>",permission:"Run: <code>mkdir -p ~/.npm-global && npm config set prefix '~/.npm-global'</code><br>Add to PATH: <code>export PATH=~/.npm-global/bin:$PATH</code>",crash:"Check Node: <code>node -v</code> (need 18+)<br>Check memory: <code>free -h</code><br>Try: <code>NODE_OPTIONS='--max-old-space-size=4096' claude</code>",hang:"Check firewall: <code>sudo iptables -L | grep DROP</code><br>Try: <code>curl -m 10 https://api.anthropic.com/v1/messages</code>"},fedora:{notfound:"Run: <code>sudo npm install -g @anthropic-ai/claude-code</code><br>If npm missing: <code>sudo dnf install nodejs npm</code>",apikey:"Same as Linux: <code>export ANTHROPIC_API_KEY='sk-ant-...'</code> in ~/.bashrc",network:"Check SELinux: <code>getenforce</code><br>If Enforcing, try: <code>sudo setsebool -P httpd_can_network_connect 1</code>",permission:"Run: <code>sudo npm i -g @anthropic-ai/claude-code --unsafe-perm</code>",crash:"Check: <code>node -v && npm -v</code><br>Update: <code>sudo dnf update nodejs</code>",hang:"Check firewalld: <code>sudo firewall-cmd --list-all</code>"},wsl:{notfound:"In WSL terminal: <code>npm install -g @anthropic-ai/claude-code</code><br>If npm missing: <code>sudo apt update && sudo apt install nodejs npm</code>",apikey:"Run: <code>export ANTHROPIC_API_KEY='sk-ant-...'</code><br>Add to ~/.bashrc. Note: Windows env vars do NOT transfer to WSL.",network:"WSL networking can fail. Check: <code>cat /etc/resolv.conf</code><br>Fix DNS: <code>echo 'nameserver 8.8.8.8' | sudo tee /etc/resolv.conf</code>",permission:"Run: <code>sudo chown -R $(whoami) /usr/local/lib/node_modules</code>",crash:"Check: <code>wsl --version</code> (need WSL 2)<br>Update: <code>wsl --update</code> from PowerShell",hang:"WSL clock drift causes TLS failures. Fix: <code>sudo hwclock -s</code>"},docker:{notfound:"In Dockerfile: <code>RUN npm install -g @anthropic-ai/claude-code</code><br>Use node:18+ base image.",apikey:"Pass via: <code>docker run -e ANTHROPIC_API_KEY=$ANTHROPIC_API_KEY ...</code><br>Never bake keys into images.",network:"Check: <code>docker run --rm alpine wget -qO- https://api.anthropic.com</code><br>If fails: check Docker network mode.",permission:"Use non-root user: <code>USER node</code> in Dockerfile after global install.",crash:"Check memory: <code>docker stats</code><br>Increase: <code>docker run --memory=4g ...</code>",hang:"Check DNS inside container: <code>cat /etc/resolv.conf</code><br>Try: <code>docker run --dns=8.8.8.8 ...</code>"}};
document.getElementById('diag-os').addEventListener('change',showDiag);
document.getElementById('diag-sym').addEventListener('change',showDiag);
function showDiag(){var o=document.getElementById('diag-os').value,s=document.getElementById('diag-sym').value,r=document.getElementById('diag-result');if(o&&s&&df[o]&&df[o][s]){r.innerHTML='<strong style="color:#6ee7b7;">Fix for '+o.toUpperCase()+' \u2014 '+s+':</strong><br><br>'+df[o][s];r.style.display='block'}else if(o&&s){r.innerHTML='Select a valid combination.';r.style.display='block'}else{r.style.display='none'}}
</script>

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

---

*These diagnostic steps are from [The Claude Code Playbook](https://zovo.one/pricing) — 200 production-ready templates including error prevention rules and CLAUDE.md configs tested across 50+ project types.*

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

For team environments, run this as a git hook or CI step. See [Hooks Guide](/understanding-claude-code-hooks-system-complete-guide/) for integrating this into your Claude Code workflow.

## Automated Recovery Script

Instead of manually diagnosing exit code 1 every time, use this script as a pre-session check that catches the most common causes and attempts automatic repair. Save it as `claude-preflight.sh` and run it before starting any Claude Code session, or integrate it into your shell profile so it runs automatically.

```bash
#!/bin/bash
# claude-preflight.sh — Diagnose and auto-fix Claude Code exit code 1 causes
# Run before every Claude Code session to prevent crashes
set -uo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'
FIXED=0
FAILED=0

echo "=== Claude Code Pre-Session Health Check ==="
echo ""

# 1. Check Node.js version
echo -n "1. Node.js version... "
if ! command -v node &>/dev/null; then
  echo -e "${RED}NOT INSTALLED${NC}"
  echo "   Attempting fix: installing Node.js 22 via nvm..."
  if command -v nvm &>/dev/null; then
    nvm install 22 && nvm use 22 && FIXED=$((FIXED + 1))
  else
    echo -e "   ${RED}nvm not found. Install Node.js 18+ manually.${NC}"
    FAILED=$((FAILED + 1))
  fi
else
  NODE_MAJOR=$(node --version | sed 's/v//' | cut -d. -f1)
  if [ "$NODE_MAJOR" -lt 18 ]; then
    echo -e "${YELLOW}v$(node --version) — too old (need 18+)${NC}"
    if command -v nvm &>/dev/null; then
      echo "   Auto-fixing: upgrading to Node.js 22..."
      nvm install 22 && nvm use 22 && FIXED=$((FIXED + 1))
    else
      FAILED=$((FAILED + 1))
    fi
  else
    echo -e "${GREEN}$(node --version)${NC}"
  fi
fi

# 2. Check API key
echo -n "2. API key... "
if [ -z "${ANTHROPIC_API_KEY:-}" ]; then
  echo -e "${RED}NOT SET${NC}"
  # Check common locations for the key
  if [ -f ~/.config/anthropic/api_key ]; then
    export ANTHROPIC_API_KEY=$(cat ~/.config/anthropic/api_key)
    echo -e "   ${GREEN}Auto-loaded from ~/.config/anthropic/api_key${NC}"
    FIXED=$((FIXED + 1))
  elif [ -f .env ] && grep -q "ANTHROPIC_API_KEY" .env 2>/dev/null; then
    export ANTHROPIC_API_KEY=$(grep "ANTHROPIC_API_KEY" .env | cut -d= -f2 | tr -d '"' | tr -d "'")
    echo -e "   ${GREEN}Auto-loaded from .env${NC}"
    FIXED=$((FIXED + 1))
  else
    echo -e "   ${RED}Set ANTHROPIC_API_KEY in your environment${NC}"
    FAILED=$((FAILED + 1))
  fi
elif [[ ! "${ANTHROPIC_API_KEY}" =~ ^sk-ant- ]]; then
  echo -e "${YELLOW}SET but format looks wrong (expected sk-ant-...)${NC}"
else
  echo -e "${GREEN}SET (${ANTHROPIC_API_KEY:0:12}...)${NC}"
fi

# 3. Check disk space
echo -n "3. Disk space... "
FREE_MB=$(df -m /tmp 2>/dev/null | tail -1 | awk '{print $4}')
if [ -n "$FREE_MB" ] && [ "$FREE_MB" -lt 500 ]; then
  echo -e "${YELLOW}${FREE_MB}MB free on /tmp — low${NC}"
  echo "   Auto-cleaning: removing old Claude cache files..."
  rm -rf /tmp/claude-* 2>/dev/null
  rm -rf ~/.claude/cache/* 2>/dev/null
  NEW_FREE=$(df -m /tmp 2>/dev/null | tail -1 | awk '{print $4}')
  echo -e "   ${GREEN}Freed $((NEW_FREE - FREE_MB))MB. Now ${NEW_FREE}MB available.${NC}"
  FIXED=$((FIXED + 1))
else
  echo -e "${GREEN}${FREE_MB}MB free${NC}"
fi

# 4. Check permissions on ~/.claude
echo -n "4. Config directory permissions... "
if [ -d ~/.claude ] && [ ! -w ~/.claude ]; then
  echo -e "${RED}NOT WRITABLE${NC}"
  echo "   Auto-fixing: resetting ownership..."
  sudo chown -R "$(whoami)" ~/.claude 2>/dev/null && FIXED=$((FIXED + 1)) || FAILED=$((FAILED + 1))
else
  echo -e "${GREEN}OK${NC}"
fi

# 5. Check network connectivity
echo -n "5. API connectivity... "
HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" --max-time 5 \
  https://api.anthropic.com/v1/messages 2>/dev/null || echo "000")
if [ "$HTTP_CODE" = "000" ]; then
  echo -e "${RED}UNREACHABLE${NC}"
  echo "   Check your network, VPN, or proxy settings."
  FAILED=$((FAILED + 1))
elif [ "$HTTP_CODE" = "401" ] || [ "$HTTP_CODE" = "400" ]; then
  echo -e "${GREEN}REACHABLE (HTTP $HTTP_CODE — auth expected)${NC}"
else
  echo -e "${GREEN}REACHABLE (HTTP $HTTP_CODE)${NC}"
fi

# 6. Check for stale processes
echo -n "6. Stale Claude processes... "
STALE=$(ps aux 2>/dev/null | grep "[c]laude" | grep -v "claude-preflight" | wc -l | tr -d ' ')
if [ "$STALE" -gt 0 ]; then
  echo -e "${YELLOW}$STALE found${NC}"
  echo "   Auto-fixing: killing stale processes..."
  pkill -f "claude" 2>/dev/null || true
  FIXED=$((FIXED + 1))
else
  echo -e "${GREEN}NONE${NC}"
fi

# Summary
echo ""
echo "=== Results ==="
if [ "$FAILED" -gt 0 ]; then
  echo -e "${RED}$FAILED issue(s) need manual attention.${NC}"
  echo -e "${GREEN}$FIXED issue(s) auto-fixed.${NC}"
  exit 1
elif [ "$FIXED" -gt 0 ]; then
  echo -e "${GREEN}$FIXED issue(s) auto-fixed. Claude Code is ready.${NC}"
else
  echo -e "${GREEN}All checks passed. Claude Code is ready.${NC}"
fi
```

### Adding It as a Pre-Session Check

To run this automatically before every Claude Code session, add an alias to your shell configuration:

```bash
# Add to ~/.zshrc or ~/.bashrc
alias claude='bash ~/scripts/claude-preflight.sh && command claude'
```

This runs the health check before launching Claude Code. If any check fails that cannot be auto-repaired, it stops before Claude starts, preventing the cryptic exit code 1 error entirely. For CI/CD pipelines, add the preflight script as a step before any Claude Code invocation to catch environment issues before they waste pipeline minutes.

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

### What is the fastest way to fix exit code 1?

Run `node --version` to confirm Node.js 18+, then `printenv ANTHROPIC_API_KEY` to check your key, then `curl -sI https://api.anthropic.com/v1/messages | head -1` to test connectivity. These three checks catch 80% of cases. If all pass, try a clean reinstall: `npm uninstall -g @anthropic-ai/claude-code && npm cache clean --force && npm install -g @anthropic-ai/claude-code`.

### Does exit code 1 happen more often on macOS or Linux?

Neither has a significantly higher rate. macOS users more commonly hit Node version conflicts (Homebrew vs nvm) and keychain prompt loops. Linux users more often encounter permission issues on `/usr/local` and disk space problems on `/tmp`. WSL users have the most unique issues (clock drift, DNS resolution).

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
- [The Claude Code Playbook](/playbook/) — Complete guide to working with Claude Code effectively

<script type="application/ld+json">
[
  {
    "@context": "https://schema.org",
    "@type": "FAQPage",
    "mainEntity": [
      {
        "@type": "Question",
        "name": "I get exit code 1 but no error message. How do I get more details?",
        "acceptedAnswer": {
          "@type": "Answer",
          "text": "Run Claude Code with verbose output: DEBUG=* claude 2>&1 | tee claude-debug.log. Or check if Node produces a stack trace with: node $(which claude) 2>&1. The raw Node invocation often shows the full error that the launcher script suppresses."
        }
      },
      {
        "@type": "Question",
        "name": "Does exit code 1 mean my API key is being charged?",
        "acceptedAnswer": {
          "@type": "Answer",
          "text": "No. If Claude Code exits during initialization before making an API call, no tokens are consumed and nothing is charged. If the exit happens mid-conversation, you may have been charged for any API calls that completed before the crash."
        }
      },
      {
        "@type": "Question",
        "name": "I fixed the issue but Claude Code still exits with code 1. What now?",
        "acceptedAnswer": {
          "@type": "Answer",
          "text": "Clear all cached state: rm -rf ~/.claude/cache/ && rm -rf /tmp/claude-* && npm cache clean --force. Then restart your terminal completely — actually close and reopen the terminal application. Some environment variable changes do not take effect until a fresh shell process starts."
        }
      },
      {
        "@type": "Question",
        "name": "Exit code 1 only happens in my CI pipeline, not locally. Why?",
        "acceptedAnswer": {
          "@type": "Answer",
          "text": "CI runners have different environments than your local machine. The most common CI-specific causes are Node.js version pinned too low, API key not available as an environment variable, network restrictions in the CI runner, and insufficient memory allocation."
        }
      },
      {
        "@type": "Question",
        "name": "Can exit code 1 corrupt my project files?",
        "acceptedAnswer": {
          "@type": "Answer",
          "text": "Unlikely. If Claude Code crashes mid-edit, the file being edited may be in a partially written state. But Claude Code uses atomic writes for most operations, so the risk is minimal. Use git status and git diff to check for unexpected changes."
        }
      },
      {
        "@type": "Question",
        "name": "Is exit code 1 different from exit code 137 or exit code 139?",
        "acceptedAnswer": {
          "@type": "Answer",
          "text": "Yes. Exit code 1 is a general application error. Exit code 137 means the process was killed by SIGKILL, usually from the OOM killer or Docker memory limit. Exit code 139 is a segmentation fault. Exit code 127 means command not found. Exit code 126 means permission denied on the executable."
        }
      },
      {
        "@type": "Question",
        "name": "I am on a company-managed laptop. Can IT policy cause exit code 1?",
        "acceptedAnswer": {
          "@type": "Answer",
          "text": "Yes. Common IT-managed causes include certificate pinning that blocks connections to api.anthropic.com, antivirus that quarantines Node.js modules, disk encryption that causes slow write operations and timeouts, and software restrictions that block running global npm packages. Try npx @anthropic-ai/claude-code as an alternative to global install."
        }
      },
      {
        "@type": "Question",
        "name": "What is the fastest way to fix exit code 1?",
        "acceptedAnswer": {
          "@type": "Answer",
          "text": "Run node --version to confirm Node.js 18+, then printenv ANTHROPIC_API_KEY to check your key, then curl -sI https://api.anthropic.com/v1/messages to test connectivity. These three checks catch 80% of cases. If all pass, try a clean reinstall with npm uninstall -g @anthropic-ai/claude-code && npm cache clean --force && npm install -g @anthropic-ai/claude-code."
        }
      },
      {
        "@type": "Question",
        "name": "Does exit code 1 happen more often on macOS or Linux?",
        "acceptedAnswer": {
          "@type": "Answer",
          "text": "Neither has a significantly higher rate. macOS users more commonly hit Node version conflicts (Homebrew vs nvm) and keychain prompt loops. Linux users more often encounter permission issues on /usr/local and disk space problems on /tmp. WSL users have the most unique issues including clock drift and DNS resolution."
        }
      },
      {
        "@type": "Question",
        "name": "How do I report exit code 1 if none of these fixes work?",
        "acceptedAnswer": {
          "@type": "Answer",
          "text": "Gather diagnostic information including system info (uname -a), Node version, npm version, Claude Code version, package info (npm ls -g @anthropic-ai/claude-code), disk space, and ~/.claude permissions. Post this output in the Claude Code GitHub Issues or include it in a support request to Anthropic."
        }
      }
    ]
  },
  {
    "@context": "https://schema.org",
    "@type": "HowTo",
    "name": "Fix Claude Code Process Exited With Code 1",
    "step": [
      {
        "@type": "HowToStep",
        "name": "Check Node.js version",
        "text": "Run node --version and verify it shows v18.0.0 or higher. If below v18, install Node 20+ using nvm install 20 or brew install node@20."
      },
      {
        "@type": "HowToStep",
        "name": "Verify API key",
        "text": "Run printenv ANTHROPIC_API_KEY to confirm your key is set. If empty, set it with export ANTHROPIC_API_KEY=sk-ant-your-key-here and add to ~/.zshrc for persistence."
      },
      {
        "@type": "HowToStep",
        "name": "Test network connectivity",
        "text": "Run curl -sI https://api.anthropic.com/v1/messages | head -1 to check connectivity. If timeout or error, check firewall, proxy, and VPN settings."
      },
      {
        "@type": "HowToStep",
        "name": "Check disk space",
        "text": "Run df -h /tmp and df -h ~ to ensure at least 1GB free. Clear Claude cache with rm -rf ~/.claude/cache/ if needed."
      },
      {
        "@type": "HowToStep",
        "name": "Fix permissions",
        "text": "Run ls -la ~/.claude/ to check ownership. If owned by root, fix with sudo chown -R $(whoami) ~/.claude/ and chmod -R 755 ~/.claude/."
      },
      {
        "@type": "HowToStep",
        "name": "Clean reinstall",
        "text": "If all checks pass, do a clean reinstall: npm uninstall -g @anthropic-ai/claude-code && npm cache clean --force && npm install -g @anthropic-ai/claude-code."
      }
    ]
  }
]
</script>

- [Claude internal server error fix](/claude-internal-server-error-fix/) — Fix server-side errors causing exit failures
- [Claude rate exceeded error fix](/claude-rate-exceeded-error-fix/) — Rate limits can cause process exits

Related Reading

- [Error Handling Reference](/error-handling/). Complete error diagnosis and resolution guide
- [Troubleshooting Guide](/troubleshooting/). Diagnose and fix any Claude Code issue

{% endraw %}
