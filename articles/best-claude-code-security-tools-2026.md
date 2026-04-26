---
layout: default
title: "Best Claude Code Security Tools (2026)"
description: "Ranked list of security tools for Claude Code including secret scanners, dependency auditors, SAST integration, and MCP security servers."
permalink: /best-claude-code-security-tools-2026/
date: 2026-04-20
last_tested: "2026-04-22"
---

# Best Claude Code Security Tools (2026)

Claude Code generates code quickly. It can also generate code with security vulnerabilities quickly. These tools catch issues before they reach production, ranked by detection coverage and ease of integration.

## 1. CLAUDE.md Security Rules (Foundation)

**What:** Hardcoded security rules in your CLAUDE.md that Claude Code follows for every code generation.

**Configuration:**
```markdown
## Security Rules -- MANDATORY
- ALL database queries: parameterized (ORM or prepared statements)
- ALL user input: validated with Zod at the boundary
- ALL passwords: bcrypt with cost factor 12+
- ALL tokens: httpOnly cookies, never localStorage
- ALL secrets: environment variables, never hardcoded
- ALL error responses: generic messages, no stack traces
- NEVER: eval(), innerHTML with user data, string-concat SQL
```

**Pros:** Zero cost. Always active. Prevents issues at generation time.
**Cons:** Advisory only. Claude Code can still miss things. No automated enforcement.
**Limitation:** Only as good as your rules. Miss a category and it is unprotected.

The [claude-code-ultimate-guide](https://github.com/FlorianBruniaux/claude-code-ultimate-guide) (4K+ stars, 271 quiz questions) provides the most thorough security rule set in the ecosystem.

**Install:** Add to your project CLAUDE.md.

## 2. Secret Scanner Hook

**What:** A post-write hook that scans every file Claude Code creates for hardcoded secrets.

**Configuration:**
```json
{
  "hooks": {
    "post-tool-use": [{
      "tool": "write_file",
      "command": "grep -rn 'API_KEY\\|SECRET\\|PASSWORD\\|TOKEN\\|PRIVATE_KEY\\|Bearer ' $FILE | grep -v '\\.env\\|test\\|mock\\|example' | head -5"
    }]
  }
}
```

**Pros:** Catches secrets in real time. Output tells Claude Code to remove them immediately. Zero dependency.
**Cons:** Regex-based (can false positive on variable names containing "SECRET"). Does not catch base64-encoded secrets.
**Limitation:** Pattern matching, not semantic analysis. A secret named `db_connection` slips through.

For more sophisticated scanning, add `gitleaks` to the hook:
```json
{
  "command": "gitleaks detect --source=$FILE --no-banner 2>&1 | head -10"
}
```

**Install:** Add to `.claude/settings.json`.

## 3. npm audit Integration

**What:** Checks for known vulnerabilities in dependencies after Claude Code installs packages.

**Configuration:**
```json
{
  "hooks": {
    "post-tool-use": [{
      "tool": "bash",
      "command": "npm audit --audit-level=high 2>&1 | tail -15"
    }]
  }
}
```

**Pros:** Catches known CVEs immediately. Uses npm's built-in database. Zero setup.
**Cons:** Only covers npm packages. Does not detect zero-day vulnerabilities. Can be noisy.
**Limitation:** Reactive (finds known issues in installed packages), not proactive (cannot evaluate packages before install).

**Install:** Add to `.claude/settings.json`.

## 4. ESLint Security Plugin

**What:** Static analysis rules that catch common security patterns in JavaScript/TypeScript.

**Configuration:**
```bash
pnpm add -D eslint-plugin-security
```

```json
// .eslintrc.json
{
  "plugins": ["security"],
  "extends": ["plugin:security/recommended"]
}
```

Combined with the auto-lint hook:
```json
{
  "hooks": {
    "post-tool-use": [{
      "tool": "write_file",
      "command": "npx eslint --plugin security $FILE 2>&1 | tail -10"
    }]
  }
}
```

**Pros:** Catches eval(), non-literal regex, unsafe child_process, prototype pollution patterns. Runs automatically via hook.
**Cons:** JavaScript/TypeScript only. Limited rule set compared to dedicated SAST tools.
**Limitation:** Pattern-based, not flow-based. Cannot trace data from source to sink.

**Install:** npm package + hook configuration.

## 5. Protected File Guard

**What:** Blocks Claude Code from modifying security-sensitive files.

**Configuration:**
```json
{
  "hooks": {
    "pre-tool-use": [{
      "tool": "write_file",
      "command": "echo $FILE | grep -qE '(\\.env|migrations/|auth\\.config|security\\.config|credentials|secrets)' && echo 'BLOCKED: Protected file' && exit 1 || true"
    }]
  }
}
```

**Pros:** Prevents accidental modification of auth configs, migrations, and credential files. Hard block (not advisory).
**Cons:** May need updating as your project grows. Can block legitimate changes.
**Limitation:** Path-based matching only. Cannot evaluate the content of changes.

**Install:** Add to `.claude/settings.json`.

## 6. .claudeignore for Sensitive Paths

**What:** Prevents Claude Code from reading sensitive files at all.

**Configuration:**
```
# .claudeignore
.env
.env.*
*.pem
*.key
*.p12
*.pfx
credentials.json
secrets/
.aws/
.gcp/
.ssh/
```

**Pros:** Files are invisible to Claude Code. Cannot be accidentally included in context.
**Cons:** Claude Code cannot help debug issues in ignored files. May need temporary removal.
**Limitation:** All-or-nothing per path. Cannot allow read but block write.

**Install:** Create `.claudeignore` in project root.

## 7. Dependency Allowlist

**What:** CLAUDE.md rule that restricts which packages Claude Code can suggest installing.

**Configuration:**
```markdown
## Approved Dependencies -- DO NOT ADD OTHERS
| Category | Package | NEVER use |
|----------|---------|-----------|
| HTTP | ky | axios, got, node-fetch |
| Validation | zod | joi, yup |
| Auth | next-auth | passport, custom JWT |
| Crypto | built-in crypto | bcryptjs (use bcrypt) |

## Adding New Dependencies
- Requires security review
- Must have 100+ stars and recent commits
- No packages with open CVEs
- Ask before installing anything not on this list
```

**Pros:** Prevents supply chain risk from untrusted packages. Reduces attack surface.
**Cons:** Requires maintenance as project needs evolve. May block legitimate packages.
**Limitation:** Claude Code may still suggest unlisted packages. Enforcement is advisory.

**Install:** Add to CLAUDE.md.

## 8. Semgrep Integration

**What:** Advanced SAST (Static Application Security Testing) that understands code flow.

**Configuration:**
```bash
pip install semgrep
```

Hook integration:
```json
{
  "hooks": {
    "post-tool-use": [{
      "tool": "write_file",
      "command": "semgrep --config auto $FILE 2>&1 | tail -15"
    }]
  }
}
```

**Pros:** Flow-sensitive analysis. Large rule database. Supports many languages. Can detect injection paths from input to output.
**Cons:** Slower than ESLint (2-5 second delay per file). Python dependency. Learning curve for custom rules.
**Limitation:** Free tier has rule limits. Full coverage requires Semgrep Pro for some rulesets.

**Install:** pip install + hook configuration.

## 9. Security Review Slash Command

**What:** An on-demand security audit command for targeted reviews.

`.claude/commands/security-audit.md`:
```markdown
Perform a security audit of this project.

1. Check all API endpoints for input validation
2. Grep for hardcoded secrets (API_KEY, SECRET, PASSWORD, TOKEN)
3. Check authentication and authorization on each route
4. Review database queries for injection vulnerabilities
5. Check CORS configuration
6. Run npm audit
7. Output a Security Report:

## Security Audit Report
### Critical Issues (fix immediately)
### High Issues (fix before next release)
### Medium Issues (fix in next sprint)
### Recommendations
```

**Pros:** Thorough on-demand review. Covers multiple security categories. Structured output.
**Cons:** Costs tokens (10K-50K per audit). Depends on Claude Code's security knowledge.
**Limitation:** AI-generated findings may include false positives. Always verify critical findings.

**Install:** Create `.claude/commands/security-audit.md`.

## 10. MCP-Based Security Monitoring

**What:** Connect Claude Code to security monitoring services via MCP servers.

From the [awesome-mcp-servers](https://github.com/punkpeye/awesome-mcp-servers) index, relevant servers include those for error tracking, log analysis, and vulnerability databases.

**Pros:** Real-time security data in Claude Code sessions.
**Cons:** Requires MCP server setup per service. API keys needed.
**Limitation:** Depends on external service availability.

## Recommended Security Stack

### Minimum (5 minutes to set up):
1. CLAUDE.md security rules
2. Secret scanner hook
3. .claudeignore for sensitive paths

### Standard (15 minutes):
Add to minimum:
4. ESLint security plugin + auto-lint hook
5. Protected file guard
6. Dependency allowlist

### Full (30 minutes):
Add to standard:
7. npm audit hook
8. Semgrep integration
9. Security audit command
10. MCP monitoring

For the security threat model, see our [threat model guide](/claude-code-security-threat-model-2026/). For hook configuration, read the [hooks guide](/claude-code-hooks-explained-complete-guide-2026/). For enterprise security setup, see the [enterprise guide](/claude-code-enterprise-setup-guide-2026/).

**Try it:** Paste your error into our [Error Diagnostic](/diagnose/) for an instant fix.
