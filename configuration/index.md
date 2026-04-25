---
title: "Claude Code Configuration"
permalink: /configuration/
description: "Complete Claude Code settings reference — settings.json, CLAUDE.md, environment variables, MCP servers, and permission configuration."
layout: default
---

# Claude Code Configuration

Claude Code's behavior is controlled by a layered configuration system: settings.json files at project and global levels, CLAUDE.md files for project-specific instructions, environment variables for runtime control, MCP server definitions for tool integrations, and permission rules for security. This page maps every configuration surface and links to detailed guides.

---

## Configuration Hierarchy

Claude Code reads configuration from multiple sources, with specific precedence rules. Understanding the hierarchy prevents conflicts and unexpected behavior.

- [Claude Code Config Hierarchy Explained](/claude-code-configuration-hierarchy-explained-2026/) -- complete precedence order with examples
- [Claude Code Project vs Global Settings](/claude-code-project-vs-global-settings-token-impact/) -- when to use project vs global config
- [Claude Code Config File Location](/claude-code-config-file-location/) -- where configuration files live on each OS

**Precedence order (highest to lowest):**
1. Command-line flags ({% raw %}`--model`{% endraw %}, {% raw %}`--dangerously-skip-permissions`{% endraw %})
2. Environment variables ({% raw %}`ANTHROPIC_API_KEY`{% endraw %}, {% raw %}`CLAUDE_MODEL`{% endraw %})
3. Project settings ({% raw %}`.claude/settings.json`{% endraw %})
4. User settings ({% raw %}`~/.claude/settings.json`{% endraw %})
5. CLAUDE.md instructions
6. Default values

---

## settings.json Configuration

The {% raw %}`.claude/settings.json`{% endraw %} file controls Claude Code's operational behavior: which tools are allowed, what permissions are granted, and how the agent interacts with your system.

### Project Settings

Project settings live in {% raw %}`.claude/settings.json`{% endraw %} within your repository. They are committed to version control and shared across the team.

- [Claude Code .claude/settings.json Cost Saving Configuration](/claude-code-settings-json-cost-saving-configuration/) -- cost-focused settings
- [Claude Code Permission Rules in settings.json](/claude-code-permission-rules-settings-json-guide/) -- granular permission configuration
- [Configure disallowedTools in Claude Code](/claude-code-disallowedtools-security-configuration/) -- tool restriction lists
- [Claude Code Custom Keybindings](/claude-code-custom-keybindings-configuration/) -- keyboard shortcut configuration

### Global Settings

Global settings live in {% raw %}`~/.claude/settings.json`{% endraw %} and apply to all projects. Use these for personal preferences that should not vary by project.

- [Claude Code Managed Settings Enterprise](/claude-code-managed-settings-enterprise-guide/) -- organization-managed global settings
- [Claude Code Project vs Global Settings Token Impact](/claude-code-project-vs-global-settings-token-impact/) -- performance implications of each level

---

## CLAUDE.md Configuration

Your CLAUDE.md file is not just documentation -- it is active configuration that shapes how Claude Code interprets and modifies your codebase.

### Core Guides

- [CLAUDE.md Best Practices: Definitive Guide](/claude-md-best-practices-definitive-guide/) -- comprehensive writing guide
- [Claude Md File: What It Does](/claude-md-file-complete-guide-what-it-does/) -- technical explanation of how CLAUDE.md works
- [CLAUDE.md Length Optimization](/claude-md-length-optimization/) -- keeping config within token-efficient bounds
- [Fix Claude MD Too Long Context Window](/claude-md-too-long-context-window-optimization/) -- handling oversized configs
- [CLAUDE.md Too Long? How to Split](/claude-md-too-long-fix/) -- splitting strategies for large configs
- [Pre-Loading Context via CLAUDE.md](/pre-loading-context-claude-md-sections-save-tokens/) -- smart context loading patterns
- [Progressive Disclosure in CLAUDE.md](/progressive-disclosure-claude-md-load-only-needed/) -- load-on-demand configuration sections

**Generate yours:** The [CLAUDE.md Generator](/generator/) creates a production-ready configuration file in under 60 seconds.

### Framework-Specific Templates

CLAUDE.md templates tuned for specific tech stacks:

- [CLAUDE.md for Next.js + TypeScript](/claude-md-example-for-nextjs-typescript/) -- Next.js projects
- [CLAUDE.md for React + Vite + TypeScript](/claude-md-example-for-react-vite-typescript/) -- React SPA projects
- [CLAUDE.md for Node.js + Express + Prisma](/claude-md-example-for-nodejs-express-prisma/) -- Express API projects
- [CLAUDE.md for Django + PostgreSQL](/claude-md-example-for-django-postgresql/) -- Python Django projects
- [CLAUDE.md for FastAPI + SQLAlchemy](/claude-md-example-for-fastapi-sqlalchemy/) -- Python FastAPI projects
- [CLAUDE.md for Go + Gin + GORM](/claude-md-example-for-go-gin-gorm/) -- Go web projects
- [CLAUDE.md for Rust + Axum + SQLx](/claude-md-example-for-rust-axum-sqlx/) -- Rust web projects
- [CLAUDE.md for Rails + Turbo + Stimulus](/claude-md-example-for-rails-turbo-stimulus/) -- Ruby on Rails projects
- [CLAUDE.md for Flutter + Dart + Riverpod](/claude-md-example-for-flutter-dart-riverpod/) -- Flutter mobile projects
- [CLAUDE.md for iOS + Swift + SwiftUI](/claude-md-example-for-ios-swift-swiftui/) -- iOS projects

### Specialized Configuration

- [CLAUDE.md for API Design Patterns](/claude-md-api-design-patterns/) -- API conventions
- [CLAUDE.md for Database Conventions](/claude-md-database-conventions/) -- database patterns and migrations
- [CLAUDE.md for Error Handling](/claude-md-error-handling-patterns/) -- error handling rules
- [CLAUDE.md for Testing Conventions](/claude-md-testing-conventions/) -- test structure and coverage requirements
- [CLAUDE.md for Security Rules](/claude-md-security-rules/) -- security constraints
- [CLAUDE.md for Frontend Projects](/claude-md-frontend-projects/) -- frontend-specific conventions
- [CLAUDE.md for Architecture Decisions](/claude-md-for-architecture-decisions/) -- ADR integration

---

## Environment Variables

Environment variables control Claude Code's runtime behavior without modifying configuration files. They are essential for CI/CD, Docker, and headless deployments.

- [Claude Code Environment Variables Reference](/claude-code-environment-variables-reference/) -- complete ENV variable list
- [Environment Variables for Claude Code Cost Control](/environment-variables-claude-code-cost-control/) -- cost-related variables
- [How Do I Set Environment Variables for a Claude Skill](/how-do-i-set-environment-variables-for-a-claude-skill/) -- skill-specific ENV configuration
- [Container Environment Variables Management](/claude-code-container-environment-variables-management/) -- Docker and container ENV patterns
- [Claude Code Dotenv Configuration](/claude-code-dotenv-configuration-workflow/) -- .env file integration

**Key environment variables:**

| Variable | Purpose |
|----------|---------|
| {% raw %}`ANTHROPIC_API_KEY`{% endraw %} | API authentication |
| {% raw %}`CLAUDE_MODEL`{% endraw %} | Default model selection |
| {% raw %}`ANTHROPIC_BASE_URL`{% endraw %} | Custom API endpoint (Bedrock, OpenRouter) |
| {% raw %}`HTTP_PROXY`{% endraw %} / {% raw %}`HTTPS_PROXY`{% endraw %} | Proxy configuration |

---

## MCP Server Configuration

MCP (Model Context Protocol) servers extend Claude Code's capabilities with external tools -- databases, APIs, cloud services, and more.

### Setup Guides

- [Claude Code MCP Configuration Guide](/claude-code-mcp-configuration-guide/) -- comprehensive MCP setup
- [Claude Code MCP Server Setup](/claude-code-mcp-server-setup/) -- step-by-step server connection
- [How to Add an MCP Server to Claude Code](/how-to-add-mcp-server-claude-code-2026/) -- adding new servers
- [claude_desktop_config.json Setup](/claude-desktop-config-json-guide/) -- desktop app MCP configuration
- [Connect Claude Code to Remote MCP Servers](/claude-code-mcp-remote-http-server-setup/) -- remote server connections
- [Fix Claude Code MCP Timeout Settings](/claude-code-mcp-timeout-settings-configuration-guide/) -- timeout tuning

### Popular MCP Servers

- [Best MCP Servers for Claude Code](/best-mcp-servers-for-claude-code-2026/) -- curated server recommendations
- [Top MCP Servers for Claude Code Developers](/top-mcp-servers-for-claude-code-developers-2026/) -- ranked by developer usage
- [MCP Servers for Claude Code: Complete Setup](/mcp-servers-claude-code-complete-setup-2026/) -- multi-server configuration
- [Claude Code + Supabase MCP: Setup Guide](/claude-code-mcp-supabase-setup-guide/) -- database integration
- [AWS MCP Server Cloud Automation](/aws-mcp-server-cloud-automation-with-claude-code/) -- AWS service integration
- [GitHub MCP Server Advanced Workflow](/github-mcp-server-advanced-workflow-automation/) -- GitHub integration
- [Figma MCP Server: Design to Code](/figma-mcp-server-design-to-code-workflow/) -- design tool integration

---

## Permission Configuration

Permissions control what Claude Code can read, write, execute, and access. Proper permission configuration is critical for security.

- [Claude Code Permission Modes Explained](/claude-code-permission-modes/) -- understanding ask, auto, and custom modes
- [Claude Code Permission Modes and Token Usage](/claude-code-permission-modes-affect-token-usage/) -- how modes affect costs
- [Claude Code Permission Rules in settings.json](/claude-code-permission-rules-settings-json-guide/) -- rule syntax and examples
- [Configure disallowedTools in Claude Code](/claude-code-disallowedtools-security-configuration/) -- blocking specific tools
- [Claude --dangerously-skip-permissions](/claude-dangerously-skip-permissions-flag/) -- understanding the skip flag
- [Why Claude Code Keeps Asking Permission](/why-does-claude-code-keep-asking-for-permission-repeatedly/) -- reducing permission fatigue

---

## Provider Configuration

Claude Code can connect to different API providers beyond the default Anthropic API.

- [Claude Code AWS Bedrock Setup](/claude-code-aws-bedrock-setup/) -- using Claude via AWS Bedrock
- [Claude Code with OpenRouter](/claude-code-openrouter-setup-guide/) -- OpenRouter as API provider
- [Claude Code + OpenRouter Pricing](/claude-code-openrouter-alternative-pricing/) -- cost comparison
- [Configure Claude Code Proxy: HTTP_PROXY](/claude-code-network-proxy-configuration-for-enterprise/) -- enterprise proxy setup
- [Claude Code Auto Mode Setup](/claude-code-auto-mode-setup-guide/) -- configuring auto-accept mode

---

## Frequently Asked Questions

### Where does Claude Code store its configuration?
Three locations: project-level at {% raw %}`.claude/settings.json`{% endraw %} (committed to git), user-level at {% raw %}`~/.claude/settings.json`{% endraw %} (not committed), and CLAUDE.md in your project root. Environment variables override file-based settings. See [Config File Location](/claude-code-config-file-location/).

### What is the difference between settings.json and CLAUDE.md?
settings.json controls Claude Code's operational behavior (permissions, tools, model selection). CLAUDE.md controls Claude's understanding of your project (architecture, coding standards, build commands). Both are necessary for a well-configured project.

### How do I configure MCP servers?
Add MCP server definitions to your {% raw %}`.claude/settings.json`{% endraw %} file under the {% raw %}`mcpServers`{% endraw %} key. Each server needs a name, transport type (stdio or HTTP), and command or URL. See [MCP Configuration Guide](/claude-code-mcp-configuration-guide/).

### Can I use Claude Code with AWS Bedrock instead of the Anthropic API?
Yes. Set {% raw %}`ANTHROPIC_BASE_URL`{% endraw %} to your Bedrock endpoint and configure AWS credentials. This gives you data residency control and consolidated AWS billing. See [AWS Bedrock Setup](/claude-code-aws-bedrock-setup/).

### How do I restrict which files Claude Code can modify?
Use the {% raw %}`allowedPaths`{% endraw %} and {% raw %}`disallowedPaths`{% endraw %} rules in settings.json, and add explicit scoping instructions to your CLAUDE.md. Together, these prevent Claude from modifying sensitive files. See [Permission Rules Guide](/claude-code-permission-rules-settings-json-guide/).

### What happens if settings.json and CLAUDE.md conflict?
settings.json always takes precedence for operational settings (permissions, tools). CLAUDE.md instructions guide Claude's behavior within the boundaries set by settings.json. For example, settings.json can block a tool that CLAUDE.md recommends using.

### How do I configure Claude Code for a CI/CD pipeline?
Use environment variables for authentication ({% raw %}`ANTHROPIC_API_KEY`{% endraw %}), enable headless mode ({% raw %}`--dangerously-skip-permissions`{% endraw %}), and set the model via {% raw %}`CLAUDE_MODEL`{% endraw %}. See [GitHub Actions Setup](/claude-code-github-actions-setup-guide/).

### How do I manage settings across multiple team members?
Commit {% raw %}`.claude/settings.json`{% endraw %} and CLAUDE.md to your repository for shared settings. Team members use {% raw %}`~/.claude/settings.json`{% endraw %} for personal preferences. Enterprise teams can use managed settings for organization-wide policies. See [Managed Settings Enterprise](/claude-code-managed-settings-enterprise-guide/).

<script type="application/ld+json">
{
  "@context": "https://schema.org",
  "@type": "FAQPage",
  "mainEntity": [
    {
      "@type": "Question",
      "name": "Where does Claude Code store its configuration?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "Three locations: project-level at .claude/settings.json (committed to git), user-level at ~/.claude/settings.json (not committed), and CLAUDE.md in your project root. Environment variables override file-based settings."
      }
    },
    {
      "@type": "Question",
      "name": "What is the difference between settings.json and CLAUDE.md?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "settings.json controls Claude Code's operational behavior (permissions, tools, model selection). CLAUDE.md controls Claude's understanding of your project (architecture, coding standards, build commands). Both are necessary for a well-configured project."
      }
    },
    {
      "@type": "Question",
      "name": "How do I configure MCP servers?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "Add MCP server definitions to your .claude/settings.json file under the mcpServers key. Each server needs a name, transport type (stdio or HTTP), and command or URL."
      }
    },
    {
      "@type": "Question",
      "name": "Can I use Claude Code with AWS Bedrock instead of the Anthropic API?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "Yes. Set ANTHROPIC_BASE_URL to your Bedrock endpoint and configure AWS credentials. This gives you data residency control and consolidated AWS billing."
      }
    },
    {
      "@type": "Question",
      "name": "How do I restrict which files Claude Code can modify?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "Use the allowedPaths and disallowedPaths rules in settings.json, and add explicit scoping instructions to your CLAUDE.md. Together, these prevent Claude from modifying sensitive files."
      }
    },
    {
      "@type": "Question",
      "name": "What happens if settings.json and CLAUDE.md conflict?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "settings.json always takes precedence for operational settings (permissions, tools). CLAUDE.md instructions guide Claude's behavior within the boundaries set by settings.json."
      }
    },
    {
      "@type": "Question",
      "name": "How do I configure Claude Code for a CI/CD pipeline?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "Use environment variables for authentication (ANTHROPIC_API_KEY), enable headless mode (--dangerously-skip-permissions), and set the model via CLAUDE_MODEL."
      }
    },
    {
      "@type": "Question",
      "name": "How do I manage settings across multiple team members?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "Commit .claude/settings.json and CLAUDE.md to your repository for shared settings. Team members use ~/.claude/settings.json for personal preferences. Enterprise teams can use managed settings for organization-wide policies."
      }
    }
  ]
}
</script>

---

## Master Every Configuration Surface

This reference covers the configuration options. For battle-tested configuration patterns, CLAUDE.md templates for 15 tech stacks, and enterprise deployment playbooks, get the [Claude Code Mastery Playbook](/mastery/) ($99).
