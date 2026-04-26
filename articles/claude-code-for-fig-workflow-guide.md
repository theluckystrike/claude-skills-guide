---
layout: default
title: "Claude Code for Fig — Workflow Guide (2026)"
description: "Claude Code for Fig — Workflow Guide — practical guide with working examples, tested configurations, and tips for developer workflows."
date: 2026-04-18
permalink: /claude-code-for-fig-workflow-guide/
categories: [workflow, niche-tools]
tags: [claude-code, fig, workflow]
---

## The Setup

You are using Fig (now part of Amazon Q Developer CLI) for terminal autocomplete — a tool that adds IDE-style autocomplete to your existing terminal with visual suggestions for commands, arguments, and file paths. Fig provides completion specs for hundreds of CLI tools and lets you write custom specs for your own scripts. Claude Code can work alongside Fig, but it does not account for Fig's presence in your terminal workflow.

## What Claude Code Gets Wrong By Default

1. **Writes long commands without considering autocomplete.** Claude outputs complete commands with all flags. With Fig installed, you type the command prefix and Fig autocompletes the rest — Claude should reference the command structure, not spell out every flag.

2. **Creates bash aliases for common commands.** Claude adds aliases to `.bashrc` for frequently used commands. Fig provides autocomplete for the full commands — aliases can actually break Fig's completion specs since Fig does not know what the alias expands to.

3. **Ignores custom completion specs.** Claude tells you to remember CLI flags or check `--help`. Fig lets you write completion specs (TypeScript/JSON) for your custom CLI tools — Claude should generate these specs for project-specific commands.

4. **Suggests installing shell completion scripts.** Claude adds bash/zsh completion scripts for tools. Fig already provides completions for most popular tools — installing shell completions can conflict with Fig's visual autocomplete.

## The CLAUDE.md Configuration

```
# Fig Terminal Autocomplete

## Terminal
- Autocomplete: Fig (Amazon Q Developer CLI)
- Completions: Visual IDE-style suggestions
- Specs: TypeScript completion specs for custom CLIs
- Integration: Works with any terminal emulator

## Fig Rules
- Fig handles autocomplete for standard CLI tools
- Custom specs: .fig/autocomplete/src/ directory
- Spec format: TypeScript with Fig.Spec type
- Do not create bash/zsh completions that conflict with Fig
- Aliases can break Fig specs — prefer functions
- Fig scripts: ~/.fig/scripts/ for custom workflows

## Conventions
- Write Fig completion specs for project CLI commands
- Spec includes: name, description, args, options, subcommands
- Use generators for dynamic completions (git branches, etc.)
- Place specs in .fig/autocomplete/src/[command].ts
- Test specs with fig settings autocomplete.developerMode true
- Avoid shell aliases — use shell functions instead
- Document CLI usage so Fig specs stay accurate
```

## Workflow Example

You want to create Fig autocomplete for your project's custom CLI tool. Prompt Claude Code:

"Write a Fig completion spec for our `deploy` CLI that has subcommands: `staging`, `production`, and `rollback`. The staging and production subcommands take `--branch` and `--tag` options. The rollback subcommand takes a `--version` argument with dynamic completion from git tags."

Claude Code should create a TypeScript file at `.fig/autocomplete/src/deploy.ts` that exports a `Fig.Spec` with three subcommands, options with descriptions, and a generator for the `--version` argument that runs `git tag --list` to provide dynamic suggestions.

## Common Pitfalls

1. **Conflicts between Fig and shell completions.** Claude installs zsh completions for a tool that Fig already covers. Both systems try to provide suggestions, causing duplicates or broken completion. Remove shell completions for tools where Fig provides specs.

2. **Aliases hiding commands from Fig.** Claude creates `alias k=kubectl` in shell config. Fig cannot detect that `k` maps to `kubectl` — completions break for the alias. Use `fig alias` to register aliases, or prefer shell functions.

3. **Spec not loading for custom CLIs.** Claude creates a Fig spec but it does not appear in suggestions. Custom specs need to be in the correct directory and the CLI must be in PATH. Run `fig settings autocomplete.developerMode true` during development to reload specs on change.



**Which model? →** Take the 5-question quiz in our [Model Selector](/model-selector/).

## Related Guides

**Try it:** Paste your error into our [Error Diagnostic](/diagnose/) for an instant fix.

- [Why Is Claude Code Terminal Based Not GUI](/why-is-claude-code-terminal-based-not-gui-application/)
- [Building a CLI Devtool with Claude Code Walkthrough](/building-a-cli-devtool-with-claude-code-walkthrough/)
- [Claude Code for Warp AI Terminal Workflow Guide](/claude-code-for-warp-ai-terminal-workflow-guide/)

## Related Articles

- [Claude Code For Strangler Fig — Complete Developer Guide](/claude-code-for-strangler-fig-pattern-workflow/)


## Common Questions

### What AI models work best with this approach?

Claude Opus 4 and Claude Sonnet 4 handle complex reasoning tasks. For simpler operations, Claude Haiku 3.5 offers faster responses at lower cost. Match model capability to task complexity.

### How do I handle AI agent failures gracefully?

Implement retry logic with exponential backoff, set clear timeout boundaries, and design fallback paths for critical operations. Log all failures for pattern analysis.

### Can this workflow scale to production?

Yes. Add rate limiting, request queuing, and monitoring before production deployment. Most AI agent architectures scale horizontally by adding worker instances behind a load balancer.

## Related Resources

- [Claude Code Academic Workflow Guide](/claude-code-academic-workflow-guide-2026/)
- [Claude Code Debugging Workflow Guide](/claude-code-debugging-workflow-guide-2026/)
- [Claude Code for Ark UI — Workflow Guide](/claude-code-for-ark-ui-workflow-guide/)
