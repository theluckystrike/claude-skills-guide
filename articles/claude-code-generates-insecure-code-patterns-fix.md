---
layout: default
title: "Fix: How to Use Generates Insecure Code Patterns Fix (2026)"
description: "Generates Insecure Code Patterns Fix. Practical guide with working examples for developers. Updated for 2026."
last_tested: "2026-04-22"
date: 2026-03-14
last_modified_at: 2026-04-17
categories: [troubleshooting]
tags: [claude-code, claude-skills, security, code-quality, best-practices]
author: "theluckystrike"
reviewed: true
score: 8
permalink: /claude-code-generates-insecure-code-patterns-fix/
render_with_liquid: false
geo_optimized: true
---

{% raw %}
[When working with Claude Code, you might occasionally receive code that contains security vulnerabilities](/best-claude-code-skills-to-install-first-2026/) This happens because AI models generate code based on patterns in their training data, which can include legacy or insecure practices. Understanding how to identify and fix these patterns is essential for building secure applications.

[This guide covers common insecure code patterns that Claude Code might generate, how to recognize them](/claude-tdd-skill-test-driven-development-workflow/), and practical workflows using Claude skills to improve your code security.

## Why AI-Generated Code Can Be Insecure

Before jumping to fixes, it helps to understand the root cause. Claude Code learns from enormous corpora of publicly available code. That training data includes Stack Overflow answers from 2012 that predate modern security guidance, tutorials that prioritize brevity over safety, and legacy codebases where security was retrofitted rather than designed in. The model does not inherently know that a pattern is dangerous, it knows that the pattern solves a certain kind of problem, because it has seen thousands of examples of that pattern doing so.

This does not mean Claude Code is unreliable. It means the same thing that has always been true of code generation tools: the output requires review. The difference is that AI-generated code is produced at a much higher velocity than hand-written code, which amplifies the impact of any security blind spots.

The good news is that Claude Code responds well to explicit security framing. Telling it "write this function securely, using parameterized queries and input validation" will produce a significantly different output than "write a login function." Your prompting habits are the first layer of defense.

## Common Insecure Patterns in AI-Generated Code

## SQL Injection Vulnerabilities

One of the most frequent issues appears in database queries. Claude might generate code like this:

```python
INSECURE - Never use this pattern
user_input = request.form['username']
query = f"SELECT * FROM users WHERE name = '{user_input}'"
cursor.execute(query)
```

This pattern is vulnerable to SQL injection attacks. An attacker who supplies `' OR '1'='1` as the username will receive every row in the users table. Supply `'; DROP TABLE users; --` and the table is gone.

The fix is straightforward, use parameterized queries instead:

```python
SECURE - Using parameterized query
user_input = request.form['username']
query = "SELECT * FROM users WHERE name = %s"
cursor.execute(query, (user_input,))
```

The `%s` placeholder is never interpreted as SQL. The database driver handles escaping completely, regardless of what the user submits. The same principle applies across all database libraries:

```python
SQLite
cursor.execute("SELECT * FROM users WHERE name = ?", (user_input,))

SQLAlchemy ORM (safest option, no raw SQL)
user = session.query(User).filter(User.name == user_input).first()

SQLAlchemy Core with text()
from sqlalchemy import text
stmt = text("SELECT * FROM users WHERE name = :name")
result = conn.execute(stmt, {"name": user_input})
```

When you encounter this pattern, you can [use the `tdd` skill to write proper test cases](/claude-tdd-skill-test-driven-development-workflow/) that verify your queries are safe.

Prompt Claude securely: Ask "generate a user lookup function using SQLAlchemy ORM with parameterized queries and error handling for missing users" rather than "generate a SQL query to look up a user by name."

## Hardcoded Secrets and API Keys

Another common issue is hardcoded credentials:

```javascript
// INSECURE
const API_KEY = "sk-1234567890abcdef";
const dbPassword = "mysecretpassword";
```

Always use environment variables:

```javascript
// SECURE
const API_KEY = process.env.API_KEY;
const dbPassword = process.env.DB_PASSWORD;
```

The [supermemory skill](/claude-supermemory-skill-persistent-context-explained/) can help you maintain a secure checklist of patterns to review in every project.

But environment variables alone are not enough. You also need to ensure those variables are never logged, never returned in API responses, and never committed to source control. A complete secrets management approach looks like this:

```python
import os
import logging

Load from environment
DATABASE_URL = os.environ.get("DATABASE_URL")
if not DATABASE_URL:
 raise RuntimeError("DATABASE_URL environment variable is required")

Never log secrets directly
logger = logging.getLogger(__name__)
logger.info("Connecting to database") # GOOD - no secret in log
logger.info(f"Connecting to {DATABASE_URL}") # BAD - logs the secret

Mask secrets in debug output
def get_safe_db_url(url: str) -> str:
 """Return a version of the URL safe to log."""
 from urllib.parse import urlparse, urlunparse
 parsed = urlparse(url)
 masked = parsed._replace(password="*")
 return urlunparse(masked)

logger.debug(f"Database: {get_safe_db_url(DATABASE_URL)}")
```

For production systems, use a secrets manager rather than relying solely on environment variables. AWS Secrets Manager, HashiCorp Vault, and GCP Secret Manager all provide rotation, auditing, and fine-grained access control that environment variables cannot offer:

```python
import boto3
import json

def get_secret(secret_name: str, region: str = "us-east-1") -> dict:
 client = boto3.client("secretsmanager", region_name=region)
 response = client.get_secret_value(SecretId=secret_name)
 return json.loads(response["SecretString"])

Usage - secret is fetched at runtime, never stored in code
db_creds = get_secret("myapp/production/database")
db_password = db_creds["password"]
```

Add `.env` and any `*secret*` or `*credential*` patterns to your `.gitignore` immediately when starting any project. Claude can help you generate a comprehensive `.gitignore` tailored to your tech stack.

## Insecure Random Number Generation

For cryptographic operations, never use `Math.random()` in JavaScript:

```javascript
// INSECURE - Predictable, not cryptographically secure
const sessionId = Math.random().toString(36);
```

Use the crypto module instead:

```javascript
// SECURE - Cryptographically secure
const crypto = require('crypto');
const sessionId = crypto.randomBytes(32).toString('hex');
```

The same issue exists in Python, where `random.random()` is a pseudorandom number generator (PRNG) suitable for simulations but not security:

```python
INSECURE
import random
token = str(random.getrandbits(128))

SECURE
import secrets
token = secrets.token_hex(32) # 32 bytes = 64 hex characters
reset_url_token = secrets.token_urlsafe(32) # URL-safe base64
```

The `secrets` module in Python 3.6+ is specifically designed for cryptographic use. Always use it for session tokens, password reset links, API keys, and any other value that needs to be unpredictable.

| Use Case | Insecure | Secure |
|---|---|---|
| Session token (Python) | `random.randint()` | `secrets.token_hex(32)` |
| Session token (JS/Node) | `Math.random()` | `crypto.randomBytes(32)` |
| Password reset link | UUID v4 (time-seeded) | `secrets.token_urlsafe(32)` |
| API key generation | `uuid.uuid4()` | `secrets.token_hex(32)` |
| OTP/TOTP secrets | Any PRNG | `pyotp.random_base32()` |

## Cross-Site Scripting (XSS) Vulnerabilities

When rendering user input in web applications, always escape output:

```html
<!-- INSECURE -->
<div>{{ userComment }}</div>

<!-- SECURE - Using a template engine's escaping -->
<div>{{ userComment | escape }}</div>
```

If you're using the `frontend-design` skill, configure it to include security headers and output encoding by default.

In JavaScript frameworks, the danger often lurks in `innerHTML` assignments:

```javascript
// INSECURE - Direct HTML injection
document.getElementById('output').innerHTML = userInput;

// SECURE - Text node assignment
document.getElementById('output').textContent = userInput;

// SECURE - Sanitize if you need to render HTML
import DOMPurify from 'dompurify';
document.getElementById('output').innerHTML = DOMPurify.sanitize(userInput);
```

In React, `dangerouslySetInnerHTML` is aptly named. Claude will sometimes generate it as a quick solution for rendering rich text. If you genuinely need to render HTML, always pass the content through DOMPurify first:

```jsx
// INSECURE
function Comment({ html }) {
 return <div dangerouslySetInnerHTML={{ __html: html }} />;
}

// SECURE
import DOMPurify from 'dompurify';

function Comment({ html }) {
 const clean = DOMPurify.sanitize(html, {
 ALLOWED_TAGS: ['b', 'i', 'em', 'strong', 'a'],
 ALLOWED_ATTR: ['href'],
 });
 return <div dangerouslySetInnerHTML={{ __html: clean }} />;
}
```

Beyond output escaping, set the `Content-Security-Policy` HTTP header to restrict what scripts can run on your page. Claude can help you draft a policy appropriate for your application:

```
Content-Security-Policy: default-src 'self'; script-src 'self' https://cdn.trusted.com; style-src 'self' 'unsafe-inline'; img-src 'self' data: https:;
```

## Command Injection

A less common but extremely dangerous pattern is passing user input to shell commands:

```python
INSECURE - Command injection
import subprocess
filename = request.args.get('file')
result = subprocess.run(f"cat {filename}", shell=True, capture_output=True)

An attacker passes: filename=../../etc/passwd
Or: filename=harmless.txt; rm -rf /
```

Use `subprocess` with a list of arguments and `shell=False`:

```python
SECURE - No shell interpretation
import subprocess
import os

filename = request.args.get('file', '')

Validate the filename before using it
if not filename or not filename.replace('.', '').replace('-', '').replace('_', '').isalnum():
 return "Invalid filename", 400

Construct a safe path
safe_dir = '/var/app/uploads'
safe_path = os.path.realpath(os.path.join(safe_dir, filename))

Prevent directory traversal
if not safe_path.startswith(safe_dir):
 return "Access denied", 403

result = subprocess.run(['cat', safe_path], shell=False, capture_output=True, text=True)
```

When `shell=False`, the OS never interprets the arguments as shell commands. There is no injection surface.

## Path Traversal

Related to command injection, path traversal attacks occur when user input controls a file path:

```python
INSECURE - Path traversal
def serve_file(filename):
 path = f"/var/app/uploads/{filename}"
 with open(path) as f:
 return f.read()

Attacker passes: filename=../../etc/passwd
```

Always normalize the path and verify it stays within your intended directory:

```python
import os

def serve_file(filename: str) -> str:
 base_dir = os.path.realpath('/var/app/uploads')

 # Normalize and resolve symlinks
 requested_path = os.path.realpath(os.path.join(base_dir, filename))

 # Verify the resolved path is still within base_dir
 if not requested_path.startswith(base_dir + os.sep):
 raise PermissionError("Access outside upload directory is not allowed")

 with open(requested_path) as f:
 return f.read()
```

## Using Claude Skills for Security Reviews

## The Security Checklist Skill

Create a custom skill for security reviews. Place this in `~/.claude/skills/security-review.md`:

```markdown
Security Review Skill

When reviewing code, check for:

1. SQL injection - use parameterized queries
2. XSS - escape all user input
3. CSRF - implement tokens
4. Authentication - never hardcode secrets
5. File operations - validate paths, prevent directory traversal
6. Command injection - avoid shell execution with user input

For each vulnerability found, explain the risk and provide a fixed version.
```

Use this skill with any code review task:

```
/security-review
```

A more detailed prompt that Claude responds well to is: "Review the following code for the OWASP Top 10 vulnerabilities. For each issue found, rate the severity (Critical/High/Medium/Low), explain the attack vector, and provide a corrected version of the affected code."

## Integrating with TDD Workflow

The `tdd` skill already encourages writing tests first. Extend this practice to include security test cases:

```python
def test_login_sql_injection():
 # Test that SQL injection attempts are handled safely
 malicious_input = "' OR '1'='1"
 result = authenticate(malicious_input, "anypassword")
 assert result is None # Should not authenticate

def test_login_sql_injection_drop_table():
 malicious_input = "'; DROP TABLE users; --"
 result = authenticate(malicious_input, "anypassword")
 assert result is None

def test_session_token_uniqueness():
 """Verify tokens are not predictable."""
 tokens = {generate_session_token() for _ in range(10000)}
 assert len(tokens) == 10000 # All tokens must be unique

def test_session_token_length():
 token = generate_session_token()
 # 32 bytes encoded as hex = 64 characters
 assert len(token) >= 64
```

Run your security tests alongside regular unit tests. The `tdd` skill will help structure these tests properly.

## Automating Security Checks

Consider adding automated security scanning to your workflow. Tools like Bandit (Python), ESLint with security plugins (JavaScript), and SAST scanners can catch many issues automatically. You can create a Claude skill that runs these tools:

```markdown
Security Scan Skill

Run the following security checks on the codebase:

1. Bandit for Python: bandit -r .
2. ESLint for JavaScript: eslint --ext .js .
3. Check for secrets: git-secrets or similar

Report findings in a structured format.
```

Here is a concrete example of running Bandit and interpreting the output with Claude's help:

```bash
Install Bandit
pip install bandit

Run against your project (exclude test files)
bandit -r src/ -x tests/ -f json -o bandit_report.json

Then ask Claude: "Review this Bandit report and explain which findings
are high priority and how to fix them"
cat bandit_report.json
```

For JavaScript projects, set up `eslint-plugin-security`:

```bash
npm install --save-dev eslint eslint-plugin-security

.eslintrc.json
{
 "plugins": ["security"],
 "extends": ["plugin:security/recommended"]
}

Run the check
npx eslint src/ --ext .js,.ts
```

Integrate these checks into your CI pipeline so they run on every pull request. Claude can help you write the GitHub Actions configuration, CircleCI config, or whatever CI system you use.

## Building Secure Defaults

## Project Templates

When starting new projects, establish secure defaults early. Use the `pdf` skill if you need to generate security documentation, or apply the `canvas-design` skill to create security awareness materials for your team.

A practical way to establish secure defaults is to create a project scaffold that includes security tooling out of the box:

```
project/
 .github/
 workflows/
 security.yml # CI security checks
 .gitignore # Includes .env, secrets/
 .env.example # Template with no real values
 pyproject.toml # Includes bandit, safety dependencies
 src/
 security/
 __init__.py
 auth.py # Secure auth utilities
 validation.py # Input validation helpers
```

Ask Claude to generate this scaffold with appropriate content in each file: "Create a Python project scaffold that includes Bandit security scanning, a pre-commit hook for secret detection, and a validation module with common input sanitizers."

## Dependency Management

AI-generated code might include outdated dependencies with known vulnerabilities. Always:

- Run `npm audit` or `pip-audit` after generating code
- Review the `package-lock.json` or `requirements.txt` for vulnerable packages
- Use tools like Snyk or Dependabot to monitor dependencies

The `pip-audit` command is particularly useful because it checks your installed packages against the Python Package Advisory Database:

```bash
pip install pip-audit
pip-audit

Output example:
Found 2 known vulnerabilities in 2 packages
Name Version ID Fix Versions
------ ------- --------------- ------------
requests 2.25.1 GHSA-29mw-wpgm 2.31.0
Pillow 8.1.0 GHSA-8vj2-vxx3 9.3.0
```

When reviewing AI-generated `requirements.txt` files, check each pinned version against the current release. Claude will often use versions it saw frequently in training data, which is one or two major releases behind.

## Input Validation

Never trust user input. Implement validation at every layer:

```typescript
// Example: Input validation with type safety
function createUser(input: unknown): User {
 if (!isValidUserInput(input)) {
 throw new ValidationError("Invalid input");
 }

 // Proceed with sanitized input
 return { ... };
}
```

For production Python applications, use Pydantic for data validation. It provides type enforcement, value constraints, and clear error messages, all in a declarative style that Claude generates reliably:

```python
from pydantic import BaseModel, Field, validator
from typing import Optional
import re

class UserCreateRequest(BaseModel):
 username: str = Field(min_length=3, max_length=32)
 email: str = Field(max_length=254)
 password: str = Field(min_length=12)
 display_name: Optional[str] = Field(default=None, max_length=64)

 @validator('username')
 def username_alphanumeric(cls, v):
 if not re.match(r'^[a-zA-Z0-9_-]+$', v):
 raise ValueError('Username must be alphanumeric with _ or -')
 return v

 @validator('email')
 def email_format(cls, v):
 if '@' not in v or '.' not in v.split('@')[-1]:
 raise ValueError('Invalid email format')
 return v.lower()

 @validator('password')
 def password_strength(cls, v):
 if not re.search(r'[A-Z]', v):
 raise ValueError('Password must contain an uppercase letter')
 if not re.search(r'[0-9]', v):
 raise ValueError('Password must contain a digit')
 return v

Usage in a FastAPI route
from fastapi import FastAPI, HTTPException

app = FastAPI()

@app.post("/users/")
async def create_user(request: UserCreateRequest):
 # request is already validated and type-safe
 # hash the password before storing it
 hashed = bcrypt.hashpw(request.password.encode(), bcrypt.gensalt())
 ...
```

Pydantic validation runs before your business logic executes, so invalid data never reaches your database layer or external API calls.

## Practical Workflow for Secure Development

1. Before generating code: Use the `supermemory` skill to recall security patterns relevant to your tech stack

2. During code generation: Activate your security checklist skill to prompt for secure implementations

3. After code generation: Run the `tdd` skill to write security-focused test cases, then execute security scans

4. Before deployment: Perform a manual security review using your custom security skill

This layered approach catches vulnerabilities at multiple stages.

To make this concrete, here is how each stage looks in practice:

Before generating code. Include security requirements in your initial prompt. Instead of "write a password reset endpoint," say "write a password reset endpoint that generates a cryptographically secure token, stores a hash of it with a 1-hour expiry, and invalidates the token after first use."

During code generation. Watch for the red-flag patterns covered in this guide. When you see string interpolation in a query, an f-string building a shell command, or `Math.random()` generating a security token, stop and ask Claude to revise with the specific secure pattern: "Use parameterized queries instead" or "Use secrets.token_hex instead of random."

After code generation. Run your automated tools (Bandit, ESLint security plugin, npm audit) and review their output. Ask Claude to explain any findings you don't understand and generate fixes for the ones it identifies.

Before deployment. Do a manual pass through the OWASP Top 10 checklist for your application category. Claude can walk you through each item and help you determine whether your current implementation is compliant.

## Quick Reference: Secure Patterns

| Insecure Pattern | Secure Alternative |
|-----------------|-------------------|
| f-string SQL queries | Parameterized queries (`%s`, `?`, `:name`) |
| `Math.random()` for tokens | `crypto.randomBytes(32)` |
| `random.random()` for tokens | `secrets.token_hex(32)` |
| Hardcoded API keys | Environment variables + secrets manager |
| `innerHTML` with user input | `textContent` or DOMPurify |
| `eval()` with user data | `JSON.parse()` or safe parsers |
| `subprocess(shell=True)` with user input | `subprocess(shell=False)` with list args |
| Raw file paths from user input | `os.path.realpath()` + prefix check |
| Dictionary comprehension of params | Explicit loop or ORM model |
| `md5` for passwords | `bcrypt`, `argon2`, or `scrypt` |
| HTTP-only cookies | `Secure; HttpOnly; SameSite=Strict` flags |

## Conclusion

Claude Code generates code based on patterns it has seen in training data, which sometimes includes legacy or insecure practices. By understanding common vulnerability patterns and using Claude skills strategically, you can catch and fix these issues before they reach production.

The key is establishing security as a consistent part of your development workflow. Use the `tdd` skill for test-driven security, create custom security review skills, and automate scanning where possible. With these practices in place, you get the speed benefits of AI-assisted development without sacrificing code security.

Built by theluckystrike. More at [zovo.one](https://zovo.one)
---

---

<div class="mastery-cta">

I hit this exact error six months ago. Then I wrote a CLAUDE.md that tells Claude my stack, my conventions, and my error handling patterns. Haven't seen it since.

I run 5 Claude Max subs, 16 Chrome extensions serving 50K users, and bill $500K+ on Upwork. These CLAUDE.md templates are what I actually use. Not theory — production configs.

**[Grab the templates — $99 once, free forever →](https://zovo.one/lifetime?utm_source=ccg&utm_medium=cta-error&utm_campaign=claude-code-generates-insecure-code-patterns-fix)**

47/500 founding spots. Price goes up when they're gone.

</div>

Related Reading

- [Automated Testing Pipeline with Claude TDD Skill](/claude-tdd-skill-test-driven-development-workflow/)
- [How to Make Claude Code Write Secure Code Always](/how-to-make-claude-code-write-secure-code-always/)
- [Claude Code GDPR Data Privacy Implementation Checklist](/claude-code-gdpr-data-privacy-implementation-checklist/)
- [Troubleshooting Hub](/troubleshooting-hub/)
- [Claude Code for CORS Misconfiguration Fix Workflow Guide](/claude-code-for-cors-misconfiguration-fix-workflow-guide/)
- [Fix Claude Code Bun Crash](/claude-code-bun-crash/)
- [Fix Claude Code Login — Cannot Paste Auth Code](/claude-code-login-paste-fix/)
{% endraw %}


