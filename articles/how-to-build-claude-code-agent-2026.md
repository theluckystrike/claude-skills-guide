---
title: "Build a Custom Claude Code Agent (2026)"
description: "Build a custom agent for Claude Code by writing a CLAUDE.md persona, adding commands, and configuring hooks. Step-by-step with a security reviewer example."
permalink: /how-to-build-claude-code-agent-2026/
last_tested: "2026-04-22"
render_with_liquid: false
---

# How to Build a Custom Claude Code Agent (2026)

A Claude Code agent is a combination of behavioral rules (CLAUDE.md), slash commands, and hooks that make Claude behave as a specialized tool for a specific task. Here is how to build one from scratch.

## Prerequisites

- Claude Code installed
- Understanding of CLAUDE.md basics (see the [best practices guide](/claude-md-file-best-practices-guide/))
- A clear idea of what your agent should specialize in

## Step 1: Define the Agent's Purpose

Before writing any files, answer these questions:
- What specific task does this agent handle?
- What should it always do?
- What should it never do?
- What tools does it need access to?
- What output format should it produce?

Example: We will build a **Security Reviewer** agent that audits code for vulnerabilities.

## Step 2: Write the Agent's CLAUDE.md

Create a CLAUDE.md (or a section within your existing one) that defines the agent's behavior:

```markdown
# Security Reviewer Agent

## Role
You are a security-focused code reviewer. Every response should prioritize identifying security vulnerabilities, data exposure risks, and attack vectors.

## Always Do
- Check for hardcoded secrets, API keys, and credentials
- Identify SQL injection, XSS, and CSRF vulnerabilities
- Flag insecure dependencies
- Verify input validation on all external data
- Check authentication and authorization logic
- Review file permission handling

## Never Do
- Ignore potential security issues to avoid slowing down the review
- Suggest fixes that introduce new vulnerabilities
- Skip reviewing test files (they may contain real credentials)
- Approve code without explicitly stating "No security issues found" when clean

## Output Format
For each finding:
- **Severity**: Critical / High / Medium / Low
- **Location**: File path and line number
- **Issue**: Description of the vulnerability
- **Impact**: What an attacker could do
- **Fix**: Specific code change to remediate

## Tools
Prioritize Read and Grep for analysis. Avoid Write unless explicitly asked to implement fixes.
```

## Step 3: Create Agent-Specific Commands

Create commands that activate the agent's specialized behaviors.

`.claude/commands/security-scan.md`:
```markdown
Perform a full security scan of this project. Check every source file for:

1. Hardcoded secrets and API keys
2. SQL injection vulnerabilities
3. XSS attack vectors
4. CSRF protection gaps
5. Insecure dependency versions
6. Missing input validation
7. Authentication/authorization flaws
8. Insecure file operations

Report findings sorted by severity. Include file paths, line numbers, and specific fixes.
```

`.claude/commands/check-deps.md`:
```markdown
Analyze the project's dependencies for known security vulnerabilities.

Check:
- package.json / requirements.txt / Cargo.toml (whichever exists)
- Lock files for pinned vulnerable versions
- Transitive dependencies with known CVEs

For each vulnerable dependency, report:
- Package name and version
- CVE identifier
- Severity
- Fixed version (if available)
- Whether it is a direct or transitive dependency
```

## Step 4: Add Supporting Hooks

Create a hook that logs all files Claude reads during a security review:

```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Read",
        "hooks": [
          {
            "type": "command",
            "command": "bash .claude/hooks/log-reviewed-files.sh"
          }
        ]
      }
    ]
  }
}
```

`.claude/hooks/log-reviewed-files.sh`:
```bash
#!/bin/bash
INPUT=$(cat)
FILE=$(echo "$INPUT" | python3 -c "import sys,json; print(json.load(sys.stdin).get('tool_input',{}).get('file_path',''))" 2>/dev/null)
if [ -n "$FILE" ]; then
    echo "$(date '+%Y-%m-%d %H:%M:%S') $FILE" >> .claude/security-review-log.txt
fi
exit 0
```

## Step 5: Test the Agent

```bash
claude
```

Run the security scan command:
```
/security-scan
```

Verify:
- Claude focuses exclusively on security issues
- Output follows the severity/location/issue/impact/fix format
- The review log captures files examined
- Claude does not write files unless you ask for fixes

## Verification Checklist

- [ ] CLAUDE.md contains the agent's behavioral rules
- [ ] Commands are in `.claude/commands/` with `.md` extension
- [ ] Hooks are executable and configured in settings.json
- [ ] Agent behavior matches the defined role consistently
- [ ] Output format matches the specification

## Agent Design Patterns

Three patterns that produce effective agents:

**The Specialist**: Focuses on one task type. The Security Reviewer above is a specialist — it only does security reviews. Specialists have the clearest behavior because their rules are narrow and specific.

**The Workflow Agent**: Guides Claude through a multi-step process. Instead of defining what Claude should focus on, it defines the steps Claude should follow. Good for deployment pipelines, release processes, and onboarding workflows.

**The Persona Agent**: Gives Claude a complete personality for a role. A "Senior Backend Engineer" agent has opinions about architecture, database design, API conventions, and testing strategies. Personas work well for pair programming and code review.

## Sharing Agents With Your Team

Once your agent works well, share it:

1. Commit the CLAUDE.md section, commands, and hooks to your repository
2. Document the agent's purpose, commands, and expected behavior in a README
3. Include example sessions showing the agent in action
4. Add setup instructions for any dependencies (linters, tools, MCP servers)

Team agents should be versioned and reviewed like any other code. Changes to the agent's behavior affect everyone's Claude experience.

## Troubleshooting

**Agent does not follow the persona**: Make sure the CLAUDE.md rules are near the top of the file. If other rules conflict, the agent persona may be overridden. Test by starting a fresh session and immediately invoking the agent.

**Commands produce generic output**: Make the command prompts more specific. Include exact output formats and explicit instructions. Add negative constraints: "Do NOT provide general code quality feedback — focus only on security vulnerabilities."

**Hooks interfere with normal work**: Use the matcher to limit hooks to specific tools. Consider enabling the agent's hooks only when doing security reviews. You can also use separate CLAUDE.md files for different agent configurations and swap between them.

## Next Steps

- Browse [pre-built agents](/best-claude-code-agents-frontend-2026/) for inspiration
- Explore [Claude Code Templates](/how-to-install-claude-code-templates-cli-2026/) for 600+ agent configurations
- Learn about [hooks](/claude-code-hooks-explained/) for more advanced agent automation
- Share your agent with the community via the [skills directory](/claude-skills-directory-where-to-find-skills/)
