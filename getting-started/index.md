---
title: "Getting Started with Claude Code"
permalink: /getting-started/
description: "Learn Claude Code from zero to productive — installation, first session walkthrough, essential commands, and CLAUDE.md setup guide."
layout: default
date: 2026-04-20
---

# Getting Started with Claude Code

Claude Code is Anthropic's official command-line tool for AI-assisted software development. It reads your codebase, understands your project structure, writes code, runs tests, and commits changes -- all from your terminal.

This page takes you from zero to productive in under 30 minutes. Follow the steps in order.

---

## Prerequisites

Before installing Claude Code, make sure you have:

- **Node.js 18+** -- Claude Code runs on Node.js. Check with {% raw %}`node --version`{% endraw %}.
- **npm or pnpm** -- The package manager ships with Node.js. Check with {% raw %}`npm --version`{% endraw %}.
- **An Anthropic API key** -- Sign up at [console.anthropic.com](https://console.anthropic.com) and generate an API key.
- **A terminal** -- Terminal.app (Mac), Windows Terminal (Windows), or any Linux terminal.

---

## Step 1: Install Claude Code

Install Claude Code globally with a single command:

{% raw %}```bash
npm install -g @anthropic-ai/claude-code
```{% endraw %}

Verify the installation:

{% raw %}```bash
claude --version
```{% endraw %}

If you get "command not found," your PATH does not include the npm global bin directory. See [Fix 'command not found' After Install](/claude-code-command-not-found-after-install-fix/) for the fix.

**Platform-specific guides:**
- [Claude Code Setup on Mac](/claude-code-setup-on-mac-step-by-step/) -- macOS-specific steps including Homebrew alternatives
- [How to Use Claude Code with WSL2](/claude-code-wsl2-windows-setup-2026/) -- Windows setup via WSL2
- [Claude Code Bun Install Setup Guide](/claude-code-bun-install/) -- alternative installation using Bun
- [Claude Code Tab Completion Setup](/claude-code-tab-completion-setup-2026/) -- enable shell autocompletion

---

## Step 2: Your First Session

Navigate to any project directory and start Claude Code:

{% raw %}```bash
cd your-project
claude
```{% endraw %}

Claude Code scans your project structure, reads your CLAUDE.md (if present), and opens an interactive session. Try these starter prompts:

- **"Explain the architecture of this project"** -- Claude reads your files and describes the structure
- **"Find all TODO comments in the codebase"** -- searches across files
- **"Write a unit test for the User model"** -- generates code based on your existing patterns
- **"Fix the failing test in auth.test.ts"** -- reads test output and applies fixes

Claude Code operates in your terminal and modifies files directly. It will ask for permission before making changes (in default mode).

**Detailed walkthrough:** [Claude Code First Project Tutorial](/claude-code-first-project-tutorial-hello-world/) covers a complete first-session example with a real project.

---

## Step 3: Set Up Your CLAUDE.md

A CLAUDE.md file is the single most impactful configuration you can create. It tells Claude Code how your project works, what standards to follow, and what patterns to use.

Create a CLAUDE.md in your project root:

{% raw %}```bash
touch CLAUDE.md
```{% endraw %}

Add these essential sections:

{% raw %}```markdown
# Project Overview
Brief description of what this project does and its tech stack.

# Build and Test Commands
- Build: `npm run build`
- Test: `npm test`
- Lint: `npm run lint`

# Coding Standards
- Use TypeScript strict mode
- Functions must be under 50 lines
- All public APIs need JSDoc comments

# Directory Structure
- src/ — application source code
- tests/ — test files mirroring src/ structure
- docs/ — documentation
```{% endraw %}

**Generate one automatically:** The [CLAUDE.md Generator](/generator/) creates a production-ready CLAUDE.md by asking you a few questions about your project.

**Learn more:**
- [CLAUDE.md Best Practices: Definitive Guide](/claude-md-best-practices-definitive-guide/) -- comprehensive authoring guide
- [How to Write Effective CLAUDE.md](/how-to-write-effective-claude-md-for-your-project/) -- step-by-step writing tutorial
- [Claude Md File: What It Does](/claude-md-file-complete-guide-what-it-does/) -- understanding CLAUDE.md internals
- [Why Does Claude Code Perform Better with CLAUDE.md?](/why-does-claude-code-perform-better-with-claude-md/) -- measurable impact data

---

## Step 4: Essential Commands

Claude Code supports both interactive chat and CLI commands. Here are the commands you will use most:

| Command | What It Does |
|---------|-------------|
| {% raw %}`claude`{% endraw %} | Start an interactive session |
| {% raw %}`claude "your prompt"`{% endraw %} | Run a single prompt and exit |
| {% raw %}`claude --continue`{% endraw %} | Resume your last session |
| {% raw %}`claude --model`{% endraw %} | Specify which Claude model to use |
| {% raw %}`/help`{% endraw %} | Show available slash commands (in session) |
| {% raw %}`/clear`{% endraw %} | Clear the current conversation context |
| {% raw %}`/cost`{% endraw %} | Show token usage and estimated cost |

**Deep dive:** [Best Claude Code Commands You're Not Using](/best-claude-code-commands-you-are-not-using-2026/) covers power-user commands that most developers overlook.

---

## Step 5: Understand Permission Modes

Claude Code has three permission modes that control how much autonomy it has:

1. **Ask mode (default)** -- Claude asks permission before every file modification and command execution. Best for learning and sensitive codebases.
2. **Auto-accept mode** -- Claude executes without asking. Enable with {% raw %}`claude --dangerously-skip-permissions`{% endraw %}. Use only in sandboxed environments.
3. **Custom rules** -- Define granular permissions in settings.json for specific tools and directories.

**Learn more:** [Claude Code Permission Modes Explained](/claude-code-permission-modes/) covers all modes with security implications.

---

## Top 10 Articles for Beginners

These articles answer the questions that new Claude Code users ask most frequently:

1. [What Is Claude Code And Why Developers Love It](/what-is-claude-code-and-why-developers-love-it-2026/) -- overview and value proposition
2. [Claude Code for Beginners](/claude-code-for-beginners-complete-getting-started-2026/) -- complete beginner walkthrough
3. [How to Use Claude Code: Beginner Guide](/how-to-use-claude-code-beginner-guide/) -- practical usage patterns
4. [Claude Code Tips For Absolute Beginners](/claude-code-tips-for-absolute-beginners-2026/) -- quick tips for day one
5. [Claude Code Common Beginner Mistakes](/claude-code-common-beginner-mistakes-to-avoid/) -- avoid these pitfalls
6. [Claude Code Pair Programming](/claude-code-pair-programming-for-beginner-developers/) -- using Claude as a coding partner
7. [Is Claude Code Worth It? Honest Beginner Review](/is-claude-code-worth-it-honest-beginner-review-2026/) -- unbiased assessment
8. [How Claude Code Changed My Development Workflow](/how-claude-code-changed-my-development-workflow/) -- real workflow transformation
9. [Best Claude Code Learning Resources](/best-claude-code-learning-resources-2026/) -- curated learning path
10. [Best Claude Code Courses and Tutorials](/best-claude-code-courses-tutorials-2026/) -- structured learning options

---

## Next Steps

Once you are comfortable with the basics:

- **Add MCP servers** for extended capabilities: [MCP Integration Guide for Beginners](/mcp-integration-guide-for-claude-code-beginners/)
- **Install your first skill** for reusable workflows: [Best Claude Code Skills to Install First](/best-claude-code-skills-to-install-first-2026/)
- **Optimize costs** before they add up: [Track Claude Token Spend Per Project](/track-claude-token-spend-per-project-team/)
- **Learn advanced patterns**: [Advanced Claude Code Usage](/advanced-usage/) for multi-agent orchestration, hooks, and subagents
- **Explore configuration options**: [Claude Code Configuration](/configuration/) for settings, environment variables, and MCP setup

---

## Frequently Asked Questions

### How much does Claude Code cost?
Claude Code uses the Anthropic API with pay-per-use pricing. Costs depend on the model you use and how many tokens your sessions consume. A typical development session costs $0.50-$5.00. Use {% raw %}`/cost`{% endraw %} during sessions to monitor spending. See the [Cost Calculator](/calculator/) for project estimates.

### Does Claude Code work with any programming language?
Yes. Claude Code works with any language that has text-based source files. It performs best with popular languages (Python, JavaScript, TypeScript, Go, Rust, Java) because those have the most training data, but it handles less common languages effectively as well.

### Is my code sent to Anthropic's servers?
Yes, file contents that Claude Code reads are sent to the Anthropic API for processing. Anthropic's data retention policy states that API inputs and outputs are not used for model training. For sensitive codebases, review the [Security Best Practices](/best-practices/) and consider using AWS Bedrock for data residency control.

### Can I use Claude Code without an internet connection?
No. Claude Code requires an active internet connection to communicate with the Anthropic API. For air-gapped environments, see [Use Claude Skills in Air-Gapped Environments](/how-do-i-use-claude-skills-in-an-air-gapped-environment/).

### What is the difference between Claude Code and Claude Desktop?
Claude Code is a command-line tool for developers that operates in your terminal and modifies files directly. Claude Desktop is a graphical chat application for general-purpose conversations. Claude Code uses the same Claude models but adds developer-specific features like file editing, test running, and git integration.

### How do I update Claude Code?
Run {% raw %}`npm install -g @anthropic-ai/claude-code@latest`{% endraw %} to update to the latest version. Check the [Changelog](/claude-code-changelog-what-changed-this-week/) for what changed.

<script type="application/ld+json">
{
  "@context": "https://schema.org",
  "@type": "FAQPage",
  "mainEntity": [
    {
      "@type": "Question",
      "name": "How much does Claude Code cost?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "Claude Code uses the Anthropic API with pay-per-use pricing. Costs depend on the model you use and how many tokens your sessions consume. A typical development session costs $0.50-$5.00."
      }
    },
    {
      "@type": "Question",
      "name": "Does Claude Code work with any programming language?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "Yes. Claude Code works with any language that has text-based source files. It performs best with popular languages (Python, JavaScript, TypeScript, Go, Rust, Java) because those have the most training data."
      }
    },
    {
      "@type": "Question",
      "name": "Is my code sent to Anthropic's servers?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "Yes, file contents that Claude Code reads are sent to the Anthropic API for processing. Anthropic's data retention policy states that API inputs and outputs are not used for model training."
      }
    },
    {
      "@type": "Question",
      "name": "Can I use Claude Code without an internet connection?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "No. Claude Code requires an active internet connection to communicate with the Anthropic API."
      }
    },
    {
      "@type": "Question",
      "name": "What is the difference between Claude Code and Claude Desktop?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "Claude Code is a command-line tool for developers that operates in your terminal and modifies files directly. Claude Desktop is a graphical chat application for general-purpose conversations. Claude Code uses the same Claude models but adds developer-specific features like file editing, test running, and git integration."
      }
    },
    {
      "@type": "Question",
      "name": "How do I update Claude Code?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "Run npm install -g @anthropic-ai/claude-code@latest to update to the latest version."
      }
    }
  ]
}
</script>

## Explore More Guides

- [Production-ready guidelines](/best-practices/)
- [Complete settings reference](/configuration/)
- [Error reference when things go wrong](/error-handling/)
- [Fix common beginner issues](/troubleshooting/)
- [Ready for the next level?](/advanced-usage/)


---

## Ready to Go Deeper?

This page gets you started. For 200 production-tested practices covering advanced workflows, cost optimization, multi-agent patterns, and team scaling, get the [Claude Code Mastery Playbook](/mastery/) ($99).
