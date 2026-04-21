---
title: "Claude Code Enterprise Setup and Config (2026)"
description: "Set up Claude Code for enterprise teams with organization policies, security controls, approved plugin lists, and team configuration."
permalink: /claude-code-enterprise-setup-guide-2026/
last_tested: "2026-04-22"
render_with_liquid: false
---

# Claude Code Enterprise Setup and Configuration (2026)

Deploying Claude Code across a team of 10 or 100 developers requires more than individual setup. You need consistent configuration, security controls, approved tools, and onboarding processes. This guide covers enterprise-specific configuration patterns.

## Enterprise Architecture

```
Organization Policy (admin-controlled)
├── Security rules (data handling, model access)
├── Approved MCP servers
└── Tool permission policies

Team Shared Config (repository-level)
├── .claude/settings.json (hooks, project MCP)
├── CLAUDE.md (coding standards)
└── .claude/commands/ (team workflows)

Individual Developer (user-level)
├── ~/.claude/settings.json (personal MCP, global prefs)
└── ~/.claude/CLAUDE.md (personal preferences)
```

Organization policy overrides everything below it. See our [configuration hierarchy guide](/claude-code-configuration-hierarchy-explained-2026/) for the full precedence model.

## Step 1: Create the Team CLAUDE.md Template

Start with the [andrej-karpathy-skills](https://github.com/forrestchang/andrej-karpathy-skills) (72K+ stars) behavioral principles, then add your organization-specific sections:

```markdown
# Team CLAUDE.md Template

## Behavioral Principles
- Don't Assume: Ask when requirements are ambiguous
- Surface Tradeoffs: Explain pros/cons of each approach
- Goal-Driven Execution: Do what was asked, nothing more

## Company Standards
- Language: TypeScript (strict mode)
- Testing: Vitest, 80% minimum coverage for new code
- Git: Conventional commits (feat:, fix:, chore:)
- PRs: Must pass CI, require 1 review

## Security Requirements
- No hardcoded secrets (use env vars via process.env)
- All user input validated with Zod
- SQL queries parameterized (use ORM, no raw SQL)
- Dependencies: approved list only (see package-policy.json)
- NEVER commit .env files

## Architecture
[Your specific architecture details]

## Code Style
[Your specific style guide]
```

Distribute this template to all repositories. Consider a shared repository that teams fork.

## Step 2: Configure Approved MCP Servers

Not all MCP servers are safe for enterprise use. Create an approved list:

```json
{
  "mcpServers": {
    "filesystem": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-filesystem", "./src", "./tests"],
      "note": "Scoped to source directories only"
    },
    "github": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-github"],
      "env": {
        "GITHUB_PERSONAL_ACCESS_TOKEN": "${GITHUB_TOKEN}"
      }
    }
  }
}
```

**Blocked servers:** Document which servers are NOT approved and why:
- Servers that send data to third-party services
- Servers with broad filesystem access
- Servers that modify infrastructure (cloud providers) without approval

The [awesome-mcp-servers](https://github.com/punkpeye/awesome-mcp-servers) index is useful for evaluating options, but each server should be reviewed by your security team.

## Step 3: Set Up Team Hooks

Standardize code quality with shared hooks:

```json
{
  "hooks": {
    "post-tool-use": [
      {
        "tool": "write_file",
        "command": "npx eslint --fix $FILE 2>/dev/null && npx prettier --write $FILE 2>/dev/null"
      },
      {
        "tool": "write_file",
        "command": "npx tsc --noEmit 2>&1 | head -10"
      },
      {
        "tool": "write_file",
        "command": "grep -rn 'API_KEY\\|SECRET\\|PASSWORD' $FILE | grep -v '.env' | head -3"
      }
    ]
  }
}
```

Commit this as `.claude/settings.json` in every repository.

## Step 4: Create Team Slash Commands

Build commands for common team workflows:

### Code Review Command
`.claude/commands/review.md`:
```markdown
Review the staged changes (git diff --cached).

Check for:
1. Security issues (OWASP Top 10)
2. Our CLAUDE.md convention compliance
3. Test coverage for new code
4. Performance concerns

Output format:
## Review Summary
- CRITICAL: [must fix]
- WARNING: [should fix]
- SUGGESTION: [nice to have]
## Verdict: APPROVE / REQUEST CHANGES
```

### Onboarding Command
`.claude/commands/onboard.md`:
```markdown
Give me an overview of this project.

1. Read CLAUDE.md for project context
2. List the main directories and their purposes
3. Identify the tech stack from package.json
4. Show the most recently modified files
5. Explain how to run the project locally
```

## Step 5: Set Up Cost Monitoring

Use [ccusage](https://github.com/ryoppippi/ccusage) (13K+ stars) to track per-developer and per-project spending:

```bash
npx ccusage
```

For team visibility, set up a weekly cost report:

```bash
# Add to a cron job or CI schedule
npx ccusage --format json > ~/claude-usage-$(date +%Y%m%d).json
```

## Step 6: Security Controls

### Data Classification
Define which repositories can use Claude Code:

| Classification | Claude Code Allowed? | Restrictions |
|----------------|---------------------|--------------|
| Public/Open Source | Yes | None |
| Internal | Yes | No sensitive data in prompts |
| Confidential | With approval | Approved MCP servers only |
| Restricted | No | Not permitted |

### Audit Trail
Session logs in `~/.claude/projects/` contain every interaction. For compliance:
- Set retention policies for session logs
- Review logs periodically for policy violations
- Use ccusage for automated spend auditing

### .claudeignore Standard
Require this minimum `.claudeignore` in all repositories:

```
.env
.env.*
*.pem
*.key
*.p12
credentials.json
secrets/
.aws/
.gcp/
```

## Step 7: Developer Onboarding Checklist

For each new team member:

- [ ] Install Claude Code CLI
- [ ] Copy team `~/.claude/settings.json` template (global MCP servers)
- [ ] Verify CLAUDE.md exists in all assigned repositories
- [ ] Run the `/onboard` command in their primary project
- [ ] Review the security policy and data classification rules
- [ ] Install ccusage for self-monitoring
- [ ] Complete the team's Claude Code security quiz (adapt from [claude-code-ultimate-guide](https://github.com/FlorianBruniaux/claude-code-ultimate-guide) 271 questions)

## FAQ

### Can we use Claude Code with our private model deployment?
Claude Code connects to Anthropic's API by default. For self-hosted deployments, check Anthropic's enterprise offerings for API endpoint configuration.

### How do we prevent developers from overriding organization policies?
Organization-level policies cannot be overridden by user or project settings. Configure policies through your Anthropic enterprise dashboard.

### What is the cost model for teams?
Claude Code charges per API token. Costs vary by usage. Budget $50-200/developer/month for active usage. Use ccusage for actual tracking.

### Can we integrate with our existing SSO?
Check Anthropic's enterprise plans for SSO integration. The CLI supports API key authentication, which can be managed through your secrets management system.

For team onboarding workflows, see the [onboarding playbook](/claude-code-team-onboarding-playbook-2026/). For security-specific setup, read the [threat model guide](/claude-code-security-threat-model-2026/). For CI/CD integration, see the [CI/CD guide](/claude-code-ci-cd-integration-guide-2026/).
