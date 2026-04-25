---

layout: default
title: "How to Make Claude Code Write Secure"
description: "A practical guide to configuring Claude Code for secure coding practices. Learn to use security-focused skills, define security constraints, and."
date: 2026-03-14
last_modified_at: 2026-04-17
author: "Claude Skills Guide"
permalink: /how-to-make-claude-code-write-secure-code-always/
categories: [guides]
tags: [claude-code, claude-skills]
reviewed: true
score: 7
geo_optimized: true
---

Getting Claude Code to consistently produce secure code requires more than just hoping for the best. You need to actively configure your environment, use the right skills, and establish security constraints that the model follows. This guide shows you practical methods to ensure every piece of code Claude generates meets security standards.

## Configure Security Constraints in Your System Prompt

The foundation of secure code generation starts with how you instruct Claude. Add explicit security requirements to your global instructions or create a dedicated security profile that loads with every session. This tells Claude exactly what security standards to maintain regardless of what you're building.

Your system prompt should include requirements like validating all inputs, sanitizing data before use, avoiding hardcoded secrets, and following the principle of least privilege. When you explicitly state these requirements, Claude incorporates them into its decision-making process for every code generation task.

Here is a practical example of a security-focused system prompt you can drop into your Claude Code configuration:

```
You are a security-conscious developer. For every code generation task:
- Validate and sanitize all user inputs before processing
- Use parameterized queries or prepared statements for all database operations
- Never hardcode secrets, API keys, passwords, or tokens
- Apply the principle of least privilege to all permissions and access controls
- Use framework-provided escaping functions for all output rendering
- Wrap sensitive operations in try/catch blocks that do not leak stack traces
- Prefer well-audited libraries over hand-rolled cryptography
- Always use HTTPS for external API calls
- Log security events but never log credentials or PII
```

When this prompt is active, Claude will automatically add input validation when generating a Python API endpoint, use parameterized queries for database operations, and avoid exposing sensitive data in error messages. The explicit declaration removes ambiguity. Claude does not have to guess your standards.

## A Real Example: Insecure vs. Secure Output

Without a security-focused system prompt, Claude might generate this login handler:

```python
WITHOUT security instructions. dangerous
def login(username, password):
 query = f"SELECT * FROM users WHERE username='{username}' AND password='{password}'"
 user = db.execute(query).fetchone()
 if user:
 return {"status": "ok", "user": dict(user)}
 return {"status": "fail", "error": f"No user found for {username}"}
```

This code is vulnerable to SQL injection, leaks usernames in error messages, and likely stores plaintext passwords. With a security-focused system prompt active, Claude instead produces:

```python
WITH security instructions. secure
import bcrypt
from sqlalchemy import text

def login(username: str, password: str) -> dict:
 if not username or not password:
 return {"status": "fail", "error": "Invalid credentials"}

 query = text("SELECT id, password_hash FROM users WHERE username = :username")
 user = db.execute(query, {"username": username}).fetchone()

 if not user or not bcrypt.checkpw(password.encode(), user.password_hash):
 # Generic error prevents username enumeration
 return {"status": "fail", "error": "Invalid credentials"}

 return {"status": "ok", "user_id": user.id}
```

The difference is dramatic. parameterized queries, bcrypt for password comparison, and a generic error message that prevents username enumeration attacks.

## Use the TDD Skill for Test-Driven Security

The TDD skill (Test-Driven Development) proves invaluable when you need secure code. Writing tests before code forces you to consider security requirements as part of your design. When combined with security-focused test cases, the TDD skill ensures your code passes security validation before implementation begins.

Create tests that verify:
- Input validation handles malicious payloads
- Authentication and authorization checks work correctly
- Sensitive data gets properly encrypted
- Error handling doesn't leak information

Here is a concrete set of security tests you would write before implementing a user registration endpoint:

```python
import pytest
from app import create_user

class TestUserRegistration:

 def test_rejects_sql_injection_in_username(self):
 result = create_user("admin'--", "password123")
 assert result["status"] == "error"

 def test_rejects_script_tags_in_username(self):
 result = create_user("<script>alert(1)</script>", "password123")
 assert result["status"] == "error"

 def test_password_is_not_stored_in_plaintext(self):
 create_user("alice", "mysecretpassword")
 raw = db.execute("SELECT password FROM users WHERE username='alice'").scalar()
 assert raw != "mysecretpassword"
 assert raw.startswith("$2b$") # bcrypt hash prefix

 def test_error_does_not_reveal_existing_usernames(self):
 create_user("bob", "pass1")
 result = create_user("bob", "pass2")
 assert "already exists" not in result.get("error", "")

 def test_rejects_empty_credentials(self):
 assert create_user("", "password")["status"] == "error"
 assert create_user("user", "")["status"] == "error"
```

The TDD skill then guides Claude to write code that passes these security tests. This approach catches vulnerabilities early rather than discovering them after deployment. Security tests also serve as executable documentation that communicates your security requirements to every developer on the team.

## Use MCP Skills for Security Validation

Model Context Protocol (MCP) skills extend Claude's capabilities in powerful ways. Several MCP skills directly address security concerns:

- secret-detection: Automatically scans generated code for hardcoded API keys, passwords, and tokens
- dependency-scanner: Checks for known vulnerabilities in libraries and frameworks you use
- static-analysis: Performs code quality and security checks on the fly

Install these MCP skills to add an automated security layer. After Claude generates code, these tools can flag potential issues before you even review the output. This creates a feedback loop where Claude learns from security scans and improves subsequent code generation.

## Setting Up a Security Scanning Pipeline

The real power comes from chaining these skills. Configure Claude to run this sequence after generating any production code:

1. Run `secret-detection` on the generated files. blocks anything with hardcoded credentials
2. Run `dependency-scanner` against the package manifest. catches CVEs in new dependencies
3. Run `static-analysis` for OWASP Top 10 patterns. flags injection risks, broken access control, and insecure deserialization

When the secret-detection skill flags an issue, Claude receives the output and revises the code. This is faster than a human review cycle and eliminates an entire class of accidental credential exposure that is common in rapid development.

## Create Custom Security Skills

Build a custom skill specifically for security enforcement. This skill contains your organization's security policies, compliance requirements, and coding standards. When activated, it adds a security lens to every code generation task.

Your custom security skill should include:

1. Security patterns - Pre-approved code templates for common secure operations like password hashing, token generation, and encryption
2. Forbidden practices - Clear list of what not to do: eval(), string concatenation for SQL, hardcoded credentials
3. Validation rules - Requirements for input sanitization, output encoding, and error handling

Here is an example skill definition for a Node.js backend project:

```markdown
Security Skill: NodeJS Backend

Approved Patterns

Password Hashing
Always use bcrypt with a cost factor of at least 12:
```javascript
const bcrypt = require('bcrypt');
const SALT_ROUNDS = 12;
const hash = await bcrypt.hash(plaintext, SALT_ROUNDS);
```

JWT Generation
Use short-lived access tokens with refresh token rotation:
```javascript
const accessToken = jwt.sign(payload, process.env.JWT_SECRET, { expiresIn: '15m' });
const refreshToken = crypto.randomBytes(40).toString('hex');
```

Input Validation
Use Joi or Zod schema validation on all request bodies before processing.

Forbidden Practices
- Never use eval() or new Function() with user input
- Never concatenate user data into SQL strings
- Never log req.body, passwords, or tokens
- Never use MD5 or SHA1 for password storage

Compliance Notes
- All endpoints handling PII must log access to the audit table
- Encryption at rest required for all columns tagged [sensitive]
```

Call this skill at the start of any security-sensitive task. Claude will reference it throughout the coding session, producing code that aligns with your requirements.

## Prevent Common Vulnerabilities

Focus on preventing the vulnerabilities that plague most projects. Here is how to configure Claude for each of the OWASP Top 10:

## SQL Injection

Always use parameterized queries or ORMs. When using database skills, specify ORM usage explicitly in your prompts. Compare the two approaches:

```python
Vulnerable. never generate this
def get_user(user_id):
 query = f"SELECT * FROM users WHERE id = {user_id}"
 return db.execute(query).fetchone()

Secure. always generate this
def get_user(user_id: int):
 return db.execute(
 text("SELECT id, username, email FROM users WHERE id = :id"),
 {"id": user_id}
 ).fetchone()
```

Add this to your system prompt: "Always use SQLAlchemy's text() with bound parameters or the ORM. Never use f-strings or string concatenation in SQL queries."

Cross-Site Scripting (XSS)

Ensure output encoding happens at the right layer. Tell Claude to use framework-provided escaping functions:

```javascript
// Vulnerable
element.innerHTML = userInput;

// Secure. use textContent for text, or a sanitizer for HTML
element.textContent = userInput;

// When HTML is required, use DOMPurify
element.innerHTML = DOMPurify.sanitize(userInput);
```

## Broken Authentication

Specify proper session management, token expiration, and rate limiting in your requirements. A secure authentication configuration looks like this:

```python
Rate limiting on login endpoint
from slowapi import Limiter
limiter = Limiter(key_func=get_remote_address)

@app.post("/login")
@limiter.limit("5/minute")
async def login(request: Request, credentials: LoginSchema):
 # Constant-time comparison prevents timing attacks
 user = await get_user_by_email(credentials.email)
 if not user:
 # Still run bcrypt to prevent timing-based user enumeration
 bcrypt.checkpw(b"dummy", b"$2b$12$dummy_hash_to_waste_time_AAAAAAAAAAAAAAAAAAAAAA")
 raise HTTPException(status_code=401, detail="Invalid credentials")
 ...
```

## Sensitive Data Exposure

Remind Claude to never log sensitive information, use environment variables for secrets, and implement proper encryption at rest and in transit:

```python
import logging

Configure logger to redact sensitive fields
class SensitiveDataFilter(logging.Filter):
 SENSITIVE_KEYS = {'password', 'token', 'api_key', 'secret', 'ssn', 'credit_card'}

 def filter(self, record):
 if hasattr(record, 'data') and isinstance(record.data, dict):
 record.data = {
 k: '[REDACTED]' if k in self.SENSITIVE_KEYS else v
 for k, v in record.data.items()
 }
 return True
```

The supermemory skill helps you track which vulnerabilities you've addressed in past projects, building institutional knowledge about your security requirements.

## Implement Code Review Workflows

Even with all precautions, automated checks won't catch everything. Pair Claude's code generation with systematic review processes. Use skills that help code review:

- pull-request-skill: Automates the creation of pull requests with security checklists
- diff-review: Helps you examine changes for security implications
- documentation-skill: Ensures security considerations get documented

When Claude generates code, run it through this review workflow. The combination of proactive configuration and reactive review creates defense in depth. A practical security checklist for every pull request should cover:

```markdown
Security Checklist

- [ ] No secrets or credentials in code or comments
- [ ] All user inputs are validated before use
- [ ] Database queries use parameterized statements
- [ ] Error messages do not expose internal details
- [ ] New dependencies scanned for known CVEs
- [ ] Authentication and authorization checks present on protected routes
- [ ] Sensitive data not written to logs
- [ ] HTTPS enforced for all external calls
```

Paste this checklist into your pull-request-skill configuration. Claude will automatically populate it and flag unchecked items before requesting review.

## Use Environment-Specific Security Rules

Different environments require different security approaches. Configure Claude with environment-specific rules that activate based on context:

| Environment | Validation | Logging | Encryption | Audit Trail |
|---|---|---|---|---|
| Development | Basic | Verbose | Optional | Off |
| Staging | Full | Standard | Required | On |
| Production | Strict | Minimal | Required | On |

```python
import os

SECURITY_CONFIG = {
 "development": {
 "validate_inputs": True,
 "strict_csp": False,
 "require_https": False,
 "log_level": "DEBUG"
 },
 "staging": {
 "validate_inputs": True,
 "strict_csp": True,
 "require_https": True,
 "log_level": "INFO"
 },
 "production": {
 "validate_inputs": True,
 "strict_csp": True,
 "require_https": True,
 "log_level": "WARNING",
 "audit_log_pii_access": True
 }
}

config = SECURITY_CONFIG[os.environ.get("APP_ENV", "development")]
```

Claude detects the environment from your working directory or configuration and applies appropriate security constraints automatically.

## Monitor and Iterate

Security isn't a one-time configuration. Review the code Claude produces over time and identify patterns. If you notice repeated security gaps, update your system prompts or custom skills to address them.

Track metrics like:
- Vulnerabilities caught by automated scanning
- Security issues found in code review
- Time spent fixing security bugs versus feature work

A simple tracking approach is to keep a security log in your project notes:

```
2026-03-01: Claude generated MD5 password hash. added explicit bcrypt requirement to system prompt
2026-03-08: Missing rate limiting on signup endpoint. added rate limiting to security skill patterns
2026-03-15: JWT secret not loaded from env. added dotenv requirement to forbidden practices list
```

This log becomes the changelog for your security configuration. Each entry tightens the constraints so the same issue never reappears. Claude learns from the corrections, improving its security output over time.

## Comparison: Default vs. Configured Claude Code Security Output

The following table summarizes the difference between running Claude Code without security configuration versus with the full setup described in this guide:

| Concern | Default Claude | Configured Claude |
|---|---|---|
| SQL queries | Mixed. sometimes parameterized | Always parameterized |
| Password storage | Variable. may use SHA256 | Always bcrypt with cost 12+ |
| Error messages | May leak internals | Generic, non-revealing |
| Secrets handling | May hardcode in comments | Always env vars |
| Input validation | Often missing | Present on every endpoint |
| Dependency choice | Popular libraries | Security-audited libraries |
| Rate limiting | Rarely added | Added to auth endpoints |

The investment in configuration is small compared to the cost of a security incident. Most of the setup described here. system prompt, custom skill, and MCP tools. takes under an hour to configure and applies automatically to every subsequent session.

## Conclusion

Making Claude Code write secure code consistently requires deliberate setup. Configure security constraints in your system prompts, use the TDD skill for test-driven validation, use MCP skills for automated scanning, and build custom security skills that encode your organization's policies. Combine these approaches with code review workflows and continuous iteration.

The effort pays off in reduced vulnerabilities, faster development cycles, and code that meets security standards from the first line written. Security becomes embedded in your development process rather than an afterthought.

---

---

<div class="mastery-cta">

I'm a solo developer in Vietnam. 50K Chrome extension users. $500K+ on Upwork. 5 Claude Max subscriptions running agent fleets in parallel.

These are my actual CLAUDE.md templates, orchestration configs, and prompts. Not a course. Not theory. The files I copy into every project before I write a line of code.

**[See what's inside →](https://zovo.one/lifetime?utm_source=ccg&utm_medium=cta-default&utm_campaign=how-to-make-claude-code-write-secure-code-always)**

$99 once. Free forever. 47/500 founding spots left.

</div>

Related Reading

- [Claude Code Permissions Model Security Guide 2026](/claude-code-permissions-model-security-guide-2026/). Understand Claude Code's security model first
- [Claude Code Generates Insecure Code Patterns Fix](/claude-code-generates-insecure-code-patterns-fix/). Fix insecure patterns when they appear
- [Claude TDD Skill: Test-Driven Development Workflow](/claude-tdd-skill-test-driven-development-workflow/). Security tests catch vulnerabilities before they ship
- [Best Way to Prompt Claude Code for Complex Features](/how-to-write-effective-prompts-for-claude-code/). Include security requirements in complex prompts
- [How To Make Claude Code Not — Complete Developer Guide](/how-to-make-claude-code-not-break-type-definitions/)
- [How To Make Claude Code Document — Complete Developer Guide](/how-to-make-claude-code-document-functions-automatically/)
- [How To Make Claude Code Generate — Complete Developer Guide](/how-to-make-claude-code-generate-complete-files-not-snippets/)
- [How To Make Claude Code Explain — Complete Developer Guide](/how-to-make-claude-code-explain-its-reasoning-steps/)
- [How To Make Claude Code Not Add — Complete Developer Guide](/how-to-make-claude-code-not-add-unused-imports/)
- [How to Make Claude Code Stop Overwriting Your Edits (2026)](/how-to-make-claude-code-stop-overwriting-my-edits/)
- [Best Free VPN for Chrome + Always-On Android Guide](/how-to-set-up-always-on-vpn-on-android-technically/)
- [How to Make Claude Code Use Specific Library Version](/how-to-make-claude-code-use-specific-library-version/)

Built by theluckystrike. More at [zovo.one](https://zovo.one)

## See Also

- [Claude Code Write Path Outside Workspace — Fix (2026)](/claude-code-write-tool-path-outside-workspace-fix-2026/)
