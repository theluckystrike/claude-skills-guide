---
layout: default
title: "Fix Claude Code Install Killed on Linux"
description: "Resolve the 'Killed' error during Claude Code installation on low-memory Linux servers and VPS instances by adding swap space."
date: 2026-04-15
permalink: /claude-code-install-killed-low-memory-linux-fix/
categories: [troubleshooting, claude-code]
tags: [installation, linux, memory, swap, OOM, VPS]
---

# Fix Claude Code Install Killed on Linux

## The Error

During Claude Code installation on a Linux VPS or cloud instance, the process is terminated:

```text
Setting up Claude Code...
Installing Claude Code native build latest...
bash: line 142: 34803 Killed    "$binary_path" install ${TARGET:+"$TARGET"}
```

## Quick Fix

Add swap space and retry the installation:

```bash
sudo fallocate -l 2G /swapfile
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile
curl -fsSL https://claude.ai/install.sh | bash
```

## What's Happening

The Linux OOM (Out of Memory) killer terminated the Claude Code installation process because the system ran out of physical memory. Claude Code requires at least 4 GB of available RAM for the installation and setup phase.

Many VPS and cloud instances ship with 1-2 GB of RAM and no swap space. When the installer extracts and configures the binary, memory usage spikes. Without swap as an overflow, the kernel kills the most memory-hungry process to prevent a system crash.

The `Killed` message with no additional error context is the telltale sign of the OOM killer. You can confirm this by checking the kernel log:

```bash
dmesg | grep -i "oom\|killed"
```

## Step-by-Step Fix

### Step 1: Check available memory

```bash
free -h
```

Look at the "available" column. If it is under 4 GB and swap shows 0, this is the cause.

### Step 2: Check for existing swap

```bash
swapon --show
```

If there is no output, no swap is configured.

### Step 3: Create a swap file

Create a 2 GB swap file:

```bash
sudo fallocate -l 2G /swapfile
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile
```

Verify swap is active:

```bash
free -h
```

You should now see swap space in the output.

### Step 4: Retry the installation

```bash
curl -fsSL https://claude.ai/install.sh | bash
```

### Step 5: Make swap permanent (optional)

If you want the swap file to persist across reboots:

```bash
echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab
```

### Step 6: Docker-specific fix

When installing Claude Code in a Docker container, the issue is compounded if the container runs as root with `/` as the working directory. The installer scans the filesystem and excessive memory usage follows.

Set a working directory before installing:

```dockerfile
WORKDIR /tmp
RUN curl -fsSL https://claude.ai/install.sh | bash
```

Increase Docker memory limits if using Docker Desktop:

```bash
docker build --memory=4g .
```

## Prevention

Before installing Claude Code on any Linux server, verify memory availability:

```bash
free -h
```

If available memory is under 4 GB, add swap first. For production servers running Claude Code, allocate at least 4 GB of RAM. Close unnecessary processes before installation to free memory.

For automated provisioning, include swap setup in your cloud-init or Terraform configuration:

```bash
#!/bin/bash
fallocate -l 2G /swapfile
chmod 600 /swapfile
mkswap /swapfile
swapon /swapfile
echo '/swapfile none swap sw 0 0' >> /etc/fstab
curl -fsSL https://claude.ai/install.sh | bash
```

---

### Level Up Your Claude Code Workflow

The developers who get the most out of Claude Code aren't just fixing errors — they're running multi-agent pipelines, using battle-tested CLAUDE.md templates, and shipping with production-grade operating principles.

**[Claude Code Mastery →](https://claudecodeguides.com/mastery/?utm_source=ccg&utm_medium=article&utm_campaign=claude-code-install-killed-low-memory-linux-fix)**
Templates, configs, and orchestration playbooks used by a Top Rated Plus developer with $400K+ earned building with Claude Code.

$19/month · $149 lifetime · No fluff, no courses, just tools that ship.

---

## Related Guides

- [Claude Code Headless Linux Auth](/claude-code-headless-linux-auth/)
- [Claude Code Dev Containers Setup Guide](/claude-code-dev-containers-devcontainer-json-setup-guide/)
- [Claude Code Docker Permission Denied Fix](/claude-code-docker-permission-denied-bind-mount-error/)
- [Best Way to Set Up Claude Code for a New Project](/best-way-to-set-up-claude-code-for-new-project/)
