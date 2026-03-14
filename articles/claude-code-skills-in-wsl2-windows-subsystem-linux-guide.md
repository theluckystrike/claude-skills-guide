---
layout: default
title: "Claude Code Skills in WSL2: A Practical Setup Guide"
description: "Run Claude Code skills in WSL2 Windows Subsystem for Linux. Step-by-step installation, path configuration, and skill invocation examples."
date: 2026-03-14
categories: [guides]
tags: [claude-code, claude-skills, wsl2, windows-subsystem-linux, skills]
author: "Claude Skills Guide"
reviewed: true
score: 8
---

# Claude Code Skills in WSL2: A Practical Setup Guide

Windows Subsystem for Linux (WSL2) provides a powerful Linux environment directly on Windows without dual-booting. Developers who prefer WSL2 for its native Linux toolchain can also run Claude Code skills within this environment. This guide walks through setting up Claude Code skills in WSL2, configuring paths correctly, and invoking skills for common development tasks.

## Why Run Claude Code Skills in WSL2?

WSL2 offers several advantages for developers working with Claude Code skills. The filesystem performance in WSL2 rivals native Linux, making it ideal for processing large codebases or working with skills that handle substantial file operations. If your daily workflow involves Linux servers, containers, or development tools that work best in a Unix-like environment, running Claude Code skills in WSL2 keeps everything in one place. For another cross-environment setup, see [Claude Code dev containers and devcontainer.json setup guide](/claude-skills-guide/articles/claude-code-dev-containers-devcontainer-json-setup-guide/).

Many skills work identically in WSL2 as they do on native Linux. Skills like **pdf** for document processing, **xlsx** for spreadsheet manipulation, and **tdd** for test-driven development workflows execute without modification. The primary difference lies in how you configure the initial setup and manage file paths between Windows and Linux.

## Prerequisites

Before installing Claude Code skills in WSL2, ensure you have:

- Windows 10 version 2004 or later, or Windows 11
- WSL2 installed with Ubuntu 20.04 LTS or later
- Claude Code installed within WSL2
- Basic familiarity with the command line

Open your WSL2 terminal and verify your environment:

```bash
# Check WSL2 version
wsl.exe -l -v

# Verify Ubuntu version
cat /etc/os-release

# Check if Claude Code is installed
which claude || echo "Claude Code not found"
```

## Installing Claude Code in WSL2

If you have not installed Claude Code in WSL2 yet, the process differs slightly from Windows installation. Use the official installation script:

```bash
# Install Claude Code in WSL2
curl -fsSL https://claude.ai/install.sh | sh
```

After installation, verify it works:

```bash
claude --version
```

You may need to authenticate with your Anthropic account. The authentication process works the same as on native Linux.

## Setting Up the Skills Directory

Claude Code skills live in `~/.claude/skills/` within your WSL2 home directory. Create this directory if it does not exist:

```bash
mkdir -p ~/.claude/skills
ls -la ~/.claude/
```

This creates the standard location where Claude looks for skill files. Skills you download or create will go here.

## Installing Community Skills

Several community-built skills work well in WSL2. You can manually install them by creating skill files. Here is how to add some popular skills:

### The PDF Skill

The **pdf** skill handles PDF manipulation including extraction, merging, and form filling. Create the skill file:

```bash
mkdir -p ~/.claude/skills/pdf
cat > ~/.claude/skills/pdf/SKILL.md << 'EOF'
# PDF Skill

You are a PDF manipulation expert. Help users extract content, merge documents, split PDFs, and work with forms.

When asked to work with PDFs:
- Use python libraries like pypdf, pdfplumber, or PyPDF2 for processing
- Preserve PDF formatting when extracting
- Handle encrypted PDFs by requesting passwords
- Extract tables as structured data when possible
EOF
```

### The Spreadsheet Skill

The **xlsx** skill works with Excel files and CSV data:

```bash
mkdir -p ~/.claude/skills/xlsx
cat > ~/.claude/skills/xlsx/SKILL.md << 'EOF'
# Spreadsheet Skill

You are a spreadsheet expert. Help users create, edit, and analyze Excel files and CSV data.

When working with spreadsheets:
- Use openpyxl for .xlsx files
- Use pandas for data analysis
- Create formulas and charts when requested
- Handle multiple sheets within workbooks
EOF
```

### The TDD Skill

For test-driven development, create the [**tdd** skill](/claude-skills-guide/articles/claude-tdd-skill-test-driven-development-workflow/):

```bash
mkdir -p ~/.claude/skills/tdd
cat > ~/.claude/skills/tdd/SKILL.md << 'EOF'
# TDD Skill

You are a test-driven development specialist. Guide users through red-green-refactor cycles.

When helping with TDD:
- Write failing tests first (red)
- Implement minimal code to pass tests (green)
- Refactor while keeping tests passing
- Suggest test coverage improvements
EOF
```

### The Frontend Design Skill

For frontend development with design system integration:

```bash
mkdir -p ~/.claude/skills/frontend-design
cat > ~/.claude/skills/frontend-design/SKILL.md << 'EOF'
# Frontend Design Skill

You are a frontend design expert. Help create responsive, accessible user interfaces.

When working on frontend:
- Use component-based architecture
- Ensure accessibility (WCAG guidelines)
- Implement responsive designs
- Follow modern CSS practices (Flexbox, Grid)
EOF
```

### The Supermemory Skill

For note-taking and knowledge management:

```bash
mkdir -p ~/.claude/skills/supermemory
cat > ~/.claude/skills/supermemory/SKILL.md << 'EOF'
# Supermemory Skill

You are a knowledge management assistant. Help organize notes, links, and information.

When managing knowledge:
- Structure information hierarchically
- Create searchable indexes
- Link related concepts
- Summarize key points concisely
EOF
```

## Invoking Skills in WSL2

Once installed, invoke skills using the slash command syntax within a Claude Code session:

```
/pdf extract text from document.pdf
/xlsx create sales-report.xlsx with Q1 data
/tdd write tests for user authentication
/frontend-design create login component
/supermemory find notes about project deadlines
```

The invocation works identically to native Linux. Ensure you are running Claude Code inside WSL2, not in Windows PowerShell or CMD.

## Handling Windows-Linux File Paths

One common challenge involves accessing files across the Windows and Linux filesystems. WSL2 mounts Windows drives under `/mnt/`. For example:

- `C:\Users\YourName\Documents` becomes `/mnt/c/Users/YourName/Documents`

When working with files on the Windows side, use these mount points. Alternatively, store your project files within the WSL2 filesystem (`~/projects/`) for better performance.

To open files in Windows applications from WSL2:

```bash
# Open a file in the default Windows application
explorer.exe filename.pdf

# Open VS Code from WSL2
code filename.md
```

## Troubleshooting Common Issues

### Skills Not Loading

If skills do not load, verify the directory structure:

```bash
ls -la ~/.claude/skills/
ls -la ~/.claude/skills/<skill-name>/
```

Each skill needs a `SKILL.md` file in its directory.

### Authentication Problems

If authentication fails, check your network connectivity from WSL2:

```bash
curl -I https://claude.ai
```

Some corporate networks may require proxy configuration.

### Python Dependency Errors

Many skills require Python packages. Install dependencies within WSL2:

```bash
pip install openpyxl pandas pypdf2 pdfplumber
```

Consider using a virtual environment for skill dependencies:

```bash
python3 -m venv ~/.claude/skills-venv
source ~/.claude/skills-venv/bin/activate
pip install openpyxl pandas
```

## Performance Considerations

WSL2 performance generally matches native Linux for CPU-bound tasks and file operations within the Linux filesystem. For skills that process large files or run intensive computations, working from the Linux side (`~/`) rather than `/mnt/c/` provides significant speed improvements.

If you experience slowdowns, monitor resource usage:

```bash
# Check CPU and memory
top

# Check disk I/O
iostat -x 1
```

## Conclusion

Running Claude Code skills in WSL2 combines the best of both worlds: Windows as your host OS with a full Linux development environment. Skills like **pdf**, **xlsx**, **tdd**, **frontend-design**, and [**supermemory**](/claude-skills-guide/articles/claude-supermemory-skill-persistent-context-explained/) function identically to their native Linux counterparts once properly installed.

The key steps are installing Claude Code within WSL2, creating the skills directory structure, adding skill files, and invoking them with slash commands. With this setup, you have a seamless development experience that uses WSL2's capabilities while maintaining access to Claude Code's powerful skill ecosystem.

## Related Reading

- [Claude Code Dotfiles Management and Skill Sync Workflow](/claude-skills-guide/articles/claude-code-dotfiles-management-and-skill-sync-workflow/) — Sync your Claude Code skills and dotfiles from WSL2 to other environments consistently
- [Claude Code GitHub Codespaces Cloud Development Workflow](/claude-skills-guide/articles/claude-code-github-codespaces-cloud-development-workflow/) — Compare the WSL2 local setup with GitHub Codespaces cloud development for different project needs
- [Claude Code With Docker Container Skill Setup Guide](/claude-skills-guide/articles/claude-code-with-docker-container-skill-setup-guide/) — Extend your WSL2 environment with Docker container skills for isolated development workflows
- [Claude Skills: Getting Started Hub](/claude-skills-guide/getting-started-hub/) — Explore foundational Claude Code installation and skill setup patterns across all platforms

Built by theluckystrike — More at [zovo.one](https://zovo.one)
