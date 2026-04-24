---
layout: post
title: "How to Use Claude Code with WSL2"
description: "Install and configure Claude Code in WSL2 on Windows. Path resolution, SSH keys, proxy settings, and VS Code remote integration covered."
permalink: /claude-code-wsl2-windows-setup-2026/
date: 2026-04-21
last_tested: "2026-04-21"
render_with_liquid: false
---

## The Workflow

Install and configure Claude Code inside WSL2 on Windows for a native Linux development experience. Handle Windows-Linux path translation, SSH key sharing, and VS Code Remote integration so Claude Code operates seamlessly across both environments.

Expected time: 20 minutes
Prerequisites: Windows 11 with WSL2 enabled, Ubuntu 22.04+ distribution installed

## Setup

### 1. Install Node.js in WSL2

```bash
# Inside WSL2 (open Windows Terminal → Ubuntu)
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
sudo apt-get install -y nodejs

# Verify
node --version
# Expected: v20.x.x
npm --version
# Expected: 10.x.x
```

### 2. Install Claude Code

```bash
npm install -g @anthropic-ai/claude-code

# Verify installation
claude --version
# Expected: claude-code x.x.x
```

### 3. Configure Environment Variables

```bash
# Add to ~/.bashrc or ~/.zshrc
cat >> ~/.bashrc << 'EOF'

# Claude Code configuration
export ANTHROPIC_API_KEY="sk-ant-your-key-here"

# Fix Windows/Linux path issues for Claude Code
export DONT_PROMPT_WSL_INSTALL=1

# Ensure Claude Code uses Linux paths
export CLAUDE_CODE_CWD_MODE="linux"
EOF

source ~/.bashrc
```

### 4. Set Up SSH Key Sharing Between Windows and WSL2

```bash
# Copy Windows SSH keys to WSL2 (if you have existing keys)
cp -r /mnt/c/Users/YourUser/.ssh ~/.ssh
chmod 700 ~/.ssh
chmod 600 ~/.ssh/id_*
chmod 644 ~/.ssh/*.pub

# Or generate new keys specifically for WSL2
ssh-keygen -t ed25519 -C "your-email@example.com"
```

### 5. Configure Git for Cross-Environment Work

```bash
# Set Git to handle line endings correctly
git config --global core.autocrlf input
git config --global core.eol lf

# Set your identity
git config --global user.name "Your Name"
git config --global user.email "your-email@example.com"
```

### 6. Integrate with VS Code Remote - WSL

```bash
# Install VS Code Server in WSL (happens automatically when you open VS Code)
# From Windows: code .  (in a WSL directory)
# This launches VS Code connected to WSL2

# In VS Code terminal (which runs in WSL2):
claude
# Claude Code now has access to your WSL2 Linux filesystem
```

### 7. Verify

```bash
# Test Claude Code works in WSL2
claude --print "What OS am I running on? Show uname output."
# Expected output:
# Linux [hostname] 5.15.x-microsoft-standard-WSL2

# Test file access
claude --print "List files in my home directory"
# Expected: Lists your WSL2 home directory contents
```

## Usage Example

Setting up a complete development workflow with Claude Code in WSL2:

```bash
# Create a project in WSL2 filesystem (NOT /mnt/c/ for performance)
mkdir -p ~/projects/my-api
cd ~/projects/my-api
git init
npm init -y

# Start Claude Code
claude

> Set up an Express TypeScript project with:
> - src/ directory with proper tsconfig
> - ESLint + Prettier config
> - Docker Compose with PostgreSQL
> - Jest for testing
> - A .env.example file
```

Claude Code generates the project structure:

```json
// tsconfig.json
{
  "compilerOptions": {
    "target": "ES2022",
    "module": "NodeNext",
    "moduleResolution": "NodeNext",
    "rootDir": "./src",
    "outDir": "./dist",
    "strict": true,
    "esModuleInterop": true,
    "skipLibCheck": true,
    "forceConsistentCasingInFileNames": true,
    "resolveJsonModule": true,
    "declaration": true,
    "declarationMap": true,
    "sourceMap": true
  },
  "include": ["src/**/*"],
  "exclude": ["node_modules", "dist"]
}
```

```yaml
# docker-compose.yml
version: "3.9"
services:
  postgres:
    image: postgres:16-alpine
    environment:
      POSTGRES_USER: dev
      POSTGRES_PASSWORD: devpass
      POSTGRES_DB: myapi
    ports:
      - "5432:5432"
    volumes:
      - pgdata:/var/lib/postgresql/data

  app:
    build: .
    ports:
      - "3000:3000"
    environment:
      DATABASE_URL: postgresql://dev:devpass@postgres:5432/myapi
    depends_on:
      - postgres
    volumes:
      - .:/app
      - /app/node_modules

volumes:
  pgdata:
```

Working with Windows paths when needed:

```bash
# Access Windows files from WSL2 (slower, avoid for projects)
ls /mnt/c/Users/YourUser/Documents/

# Tell Claude Code about a Windows file
claude --print "Read /mnt/c/Users/YourUser/Documents/spec.pdf and summarize it"

# Better: Copy to WSL2 first for performance
cp /mnt/c/Users/YourUser/Documents/spec.pdf ~/projects/docs/
```

## Common Issues

- **Slow file operations on /mnt/c/:** Always keep projects in the WSL2 Linux filesystem (`~/projects/`), not on the Windows mount. Performance difference is 10-50x.
- **npm global install permission errors:** Run `mkdir -p ~/.npm-global && npm config set prefix ~/.npm-global` and add `~/.npm-global/bin` to your PATH.
- **VS Code terminal shows Windows path:** Ensure you opened VS Code via WSL (`code .` from WSL terminal), not from Windows Explorer. Check the bottom-left corner shows "WSL: Ubuntu".

## Why This Matters

WSL2 gives Windows developers the Linux environment Claude Code expects. Projects run at native Linux filesystem speed while maintaining access to Windows GUI tools like VS Code, browsers, and design applications.

## Related Guides

- [Claude Code Skills in WSL2 Windows Subsystem Linux Guide](/claude-code-skills-in-wsl2-windows-subsystem-linux-guide/)
- [Best Way to Set Up Claude Code for a New Project](/best-way-to-set-up-claude-code-for-new-project/)
- [Claude Code Common Beginner Mistakes to Avoid](/claude-code-common-beginner-mistakes-to-avoid/)
