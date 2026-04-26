---
layout: default
title: "Claude Code for ModSecurity WAF Rules (2026)"
description: "Write and test ModSecurity WAF rules with Claude Code. Covers OWASP CRS tuning, false positive reduction, and virtual patching for web applications."
date: 2026-03-15
last_modified_at: 2026-04-17
author: "Claude Skills Guide"
permalink: /claude-code-for-modsecurity-waf-workflow-guide/
categories: [guides]
tags: [claude-code, claude-skills]
reviewed: true
score: 7
geo_optimized: true
last_tested: "2026-04-21"
---
Claude Code for ModSecurity WAF Workflow Guide

ModSecurity is the de facto open-source Web Application Firewall (WAF) that protects web applications from a wide range of attacks, including SQL injection, cross-site scripting (XSS), and other OWASP Top 10 vulnerabilities. Integrating Claude Code into your ModSecurity workflow can dramatically accelerate rule development, simplify configuration management, and help troubleshoot false positives efficiently. This guide walks you through practical workflows for using Claude Code with ModSecurity.

## Setting Up Your ModSecurity Development Environment

Before diving into rule development, ensure you have a proper development environment. Claude Code can help you set this up quickly.

Start by creating a working directory for your ModSecurity configurations:

```bash
mkdir -p ~/modsecurity-rules/{rules,logs,conf}
cd ~/modsecurity-rules
```

Next, create a basic ModSecurity configuration file that Claude Code can help you expand:

```apache
ServerName localhost
LoadModule mod_security2 modules/mod_security2.so
LoadModule mod_unique_id modules/mod_unique_id.so

<IfModule mod_security2.c>
 SecRuleEngine On
 SecRequestBodyAccess On
 SecResponseBodyAccess Off
 SecRequestBodyLimit 13107200
 SecRequestBodyNoFilesLimit 131072
 SecRequestBodyLimitAction Reject
 SecPcreMatchLimit 1000
 SecPcreMatchLimitRecursion 1000

 # Include your custom rules
 Include rules/*.conf
</IfModule>
```

Claude Code can review this configuration and suggest improvements based on your specific application requirements. Simply ask: "Review this ModSecurity configuration and suggest hardening recommendations."

## Choosing Between ModSecurity v2 and v3

Before you write your first rule, it is worth understanding which version of ModSecurity you are running. The two versions share the same rule syntax in most respects, but differ in how they integrate with web servers and in their performance characteristics.

| Feature | ModSecurity v2 | ModSecurity v3 (libmodsecurity) |
|---|---|---|
| Primary integration | Apache (native module) | NGINX, Apache via connector |
| Performance | Moderate | Higher throughput |
| Rule compatibility | Full CRS support | Full CRS support |
| Audit log format | JSON and legacy | JSON preferred |
| Active development | Maintenance mode | Active |
| Recommended for new projects | No | Yes |

Claude Code can read your Apache or NGINX configuration and immediately tell you which version is active. Ask: "Look at my web server configuration and confirm which version of ModSecurity is loaded and whether it is in detection or enforcement mode."

## Writing Effective ModSecurity Rules with Claude Code

ModSecurity rules use the SecRule directive to inspect requests and responses. Claude Code excels at generating and refining these rules based on security best practices.

## Basic Rule Structure

A ModSecurity rule follows this pattern:

```apache
SecRule VARIABLES "OPERATOR" "ACTIONS"
```

For example, to block SQL injection attempts in query parameters:

```apache
SecRule ARGS:id "@rx (?i)(\b(SELECT|INSERT|UPDATE|DELETE|DROP|UNION|ALTER|CREATE|TRUNCATE)\b)" \
 "id:1001,deny,status:403,msg:'SQL Injection Attempt',logdata:'Matched %{MATCHED_VAR}'"
```

Claude Code can help you generate rules for common attack patterns. Simply describe your requirement:

- "Create a rule to detect XSS attempts in all request parameters"
- "Write rules to protect against path traversal in file upload forms"
- "Generate rules to block common remote file inclusion patterns"

## Phases in ModSecurity Rules

Every rule executes in one of five phases. Getting the phase right improves both security and performance because ModSecurity can short-circuit processing early.

| Phase | Name | What is available |
|---|---|---|
| 1 | Request headers | Headers, IP, method, URI |
| 2 | Request body | POST data, uploaded files |
| 3 | Response headers | Status code, response headers |
| 4 | Response body | Full response content |
| 5 | Logging | After response is sent |

Use phase 1 for IP reputation checks and rate limiting because they require no body parsing. Use phase 2 for payload inspection rules. Avoid phase 4 unless you specifically need to inspect response bodies. it adds significant overhead.

```apache
Phase 1: block known bad IPs before any parsing
SecRule REMOTE_ADDR "@ipMatch 192.168.100.0/24" \
 "id:1000,phase:1,deny,status:403,msg:'Blocked IP range'"

Phase 2: inspect POST body for serialization attacks
SecRule REQUEST_BODY "@rx __class__.*__init__" \
 "id:1010,phase:2,deny,status:403,msg:'Python deserialization attempt'"
```

Claude Code can audit an existing rule set and flag any rules running in a higher phase than necessary. Ask: "Review these rules and identify any that are running in a later phase than required, with suggestions for the correct phase."

## Rule Chaining for Complex Conditions

Many security scenarios require combining multiple conditions. Claude Code can help you construct rule chains:

```apache
Block IP if they trigger 5 or more rules within 60 seconds
SecRule IP:COUNT "@gt 5" \
 "id:2001,deny,status:403,msg:'Rate Limit Exceeded',phase:1, \
 chain,setvar:IP.COUNT=+1,expirevar:IP.COUNT=60"
SecRule &IP:COUNT "@eq 0"
```

A more practical rate limiting example that tracks failed authentication attempts:

```apache
Increment counter on 401 or 403 response
SecRule RESPONSE_STATUS "@rx ^(401|403)$" \
 "id:2010,phase:3,pass,setvar:IP.auth_fail=+1,expirevar:IP.auth_fail=300"

Block if more than 10 failures in 5 minutes
SecRule IP:AUTH_FAIL "@gt 10" \
 "id:2011,phase:1,deny,status:429,msg:'Too many authentication failures'"
```

When you present this pattern to Claude Code, you can ask it to parameterize the thresholds, add logging for SIEM ingestion, or adapt the logic for per-user tracking using session cookies.

Using OWASP ModSecurity Core Rule Set (CRS)

The OWASP CRS provides a comprehensive set of rules out of the box. Claude Code can help you integrate and customize CRS for your application:

```apache
Include CRS with minimal configuration
Include crs/crs-setup.conf
Include crs/rules/*.conf

Override specific rules for your application
SecRuleUpdateActionById 942100 "log,pass"
```

Ask Claude Code to explain specific CRS rules or help you create application-specific exclusions without weakening your security posture.

## Writing Allowlist Rules for Known-Good Traffic

Allowlisting is safer than broad exclusions. Instead of disabling a rule globally, scope the bypass to the exact URI, method, and parameter that produces the false positive.

```apache
Allow the /api/search endpoint to receive SQL-like syntax
Only when the Content-Type is application/json
SecRule REQUEST_URI "@beginsWith /api/search" \
 "id:9001,phase:1,pass,nolog, \
 ctl:ruleRemoveTargetById=942100;ARGS:query, \
 chain"
SecRule REQUEST_HEADERS:Content-Type "@contains application/json"
```

This pattern. chaining a URI check with a header check before granting the exclusion. is the recommended approach from the CRS project. Claude Code can generate these targeted allowlists when you paste a false-positive log entry and describe the legitimate use case.

## Troubleshooting False Positives

False positives are one of the biggest challenges when deploying ModSecurity. Claude Code can help you diagnose and resolve them systematically.

## Analyzing Audit Logs

ModSecurity's audit logs contain detailed information about each transaction. Use this command to extract relevant entries:

```bash
grep "id:1001" /var/log/modsec_audit.log | tail -50
```

Then ask Claude Code to analyze the log entry and suggest rule refinements. For example:

"Here's a blocked request that appears to be a false positive. Analyze the payload and suggest how to modify the rule to allow this legitimate traffic while still catching malicious requests."

A typical audit log entry looks like this:

```
--abc123-A--
[15/Mar/2026:10:22:01 +0000] abc123def456 192.168.1.50 54321 10.0.0.1 443
--abc123-B--
POST /api/users HTTP/1.1
Host: example.com
Content-Type: application/json
Content-Length: 87

--abc123-C--
{"username":"alice","query":"SELECT * FROM preferences WHERE user='alice'"}
--abc123-H--
ModSecurity: Warning. Matched "Operator `Rx' with parameter `(?i)SELECT' against variable `ARGS:query'
(Value: `SELECT * FROM preferences WHERE user=\'alice\'' )
[id "942100"] [msg "SQL Injection Attack Detected via libinjection"]
```

Paste the entire log section into Claude Code and ask: "This transaction was blocked by rule 942100. The payload appears to be a legitimate SQL-style search from an internal analytics tool. How should I write an exclusion that is scoped correctly?" Claude Code will identify the right `ctl` action, the target variable, and recommend the URI scope for the exclusion.

## Creating Targeted Exclusions

When you need to create exclusions, always make them as specific as possible:

```apache
Only exclude for specific URI and parameter combination
SecRule ARGS:id "@rx ^[0-9]+$" \
 "id:1002,phase:1,pass,ctl:ruleRemoveById=1001"
```

Claude Code can help you write exclusion rules that are specific to your application's legitimate traffic patterns, avoiding overly broad bypasses.

## Using Detection Mode During Rollout

Never skip detection mode. A staged rollout protects production while you tune your rules:

```apache
Stage 1: log everything, block nothing
SecRuleEngine DetectionOnly

Stage 2: block high-confidence rules, log the rest
(switch specific rule actions to deny, leave others as log/pass)

Stage 3: full enforcement
SecRuleEngine On
```

Claude Code can help you implement a gradual rollout strategy. Ask: "Help me build a rule file that runs CRS in detection mode for all rules except SQL injection and path traversal, which should be blocking." This produces a hybrid configuration you can tighten over two to three weeks as you verify the absence of false positives.

## Automating Rule Testing

Testing ModSecurity rules is critical before deployment. Claude Code can help you create automated test suites.

## Using curl for Basic Tests

Test a rule with a simple curl command:

```bash
curl -H "X-Forwarded-For: 1.2.3.4" "http://localhost/test?id=1' OR '1'='1"
```

Check the error log:

```bash
tail -f /var/log/modsec_error.log
```

## Creating a Test Script

Claude Code can generate a comprehensive test script:

```bash
#!/bin/bash
test-modsecurity.sh

TEST_HOST="localhost"
TEST_URI="/api/users"

Test cases: (description, expected_block, payload)
declare -a TESTS=(
 "SQL Injection Test,true,id=1' OR '1'='1"
 "XSS Test,true,name=<script>alert(1)</script>"
 "Valid Request,false,name=John"
)

for test in "${TESTS[@]}"; do
 IFS=',' read -r desc expected payload <<< "$test"
 response=$(curl -s -o /dev/null -w "%{http_code}" \
 "$TEST_HOST$TEST_URI?$payload")

 if [[ "$expected" == "true" && "$response" == "403" ]]; then
 echo "[PASS] $desc - Correctly blocked"
 elif [[ "$expected" == "false" && "$response" != "403" ]]; then
 echo "[PASS] $desc - Correctly allowed"
 else
 echo "[FAIL] $desc - Expected $expected, got $response"
 fi
done
```

Ask Claude Code to expand this with more comprehensive test cases covering different attack vectors and legitimate use cases.

## Integrating Tests into CI/CD

A stronger approach embeds WAF tests in your deployment pipeline. Here is a GitHub Actions job that spins up a local ModSecurity container and runs the test suite on every pull request:

```yaml
name: WAF Rule Tests

on:
 pull_request:
 paths:
 - 'waf/rules/'
 - 'waf/conf/'

jobs:
 test-waf:
 runs-on: ubuntu-latest
 steps:
 - uses: actions/checkout@v4

 - name: Start ModSecurity container
 run: |
 docker run -d --name modsec-test \
 -p 8080:80 \
 -v $PWD/waf/rules:/etc/modsecurity/rules \
 -v $PWD/waf/conf/modsecurity.conf:/etc/modsecurity/modsecurity.conf \
 owasp/modsecurity-crs:nginx

 - name: Wait for container
 run: sleep 5

 - name: Run WAF tests
 run: bash ./tests/test-modsecurity.sh http://localhost:8080

 - name: Dump error log on failure
 if: failure()
 run: docker logs modsec-test
```

Claude Code can write the full workflow file when you describe your stack. It can also generate tests for your specific application endpoints by reading your OpenAPI specification and deriving attack payloads from each parameter's type and format.

## Monitoring and Alerting

A deployed WAF is not a set-and-forget system. You need visibility into what it is blocking and why.

## Structured Logging for SIEM Integration

ModSecurity supports JSON audit log format in v3. Enable it so that logs flow cleanly into Elasticsearch, Splunk, or any other SIEM:

```apache
SecAuditLogFormat JSON
SecAuditLog /var/log/modsec_audit.json
SecAuditLogParts ABCFHZ
```

With structured logs in place, Claude Code can help you write Kibana queries or Splunk SPL to create dashboards that show blocked requests by rule ID, attack category, and source IP. Ask: "Write a Kibana query that shows the top 10 triggered rule IDs in the last 24 hours and groups them by client IP."

## Building a False Positive Review Queue

Rather than reviewing every blocked request manually, build a lightweight triage queue. The following Python script reads the JSON audit log and flags transactions where the same IP made multiple requests in the same session, with some blocked and some allowed. a strong signal that the block is a false positive rather than a real attack:

```python
import json
import sys
from collections import defaultdict

def analyze_audit_log(path):
 sessions = defaultdict(lambda: {"blocked": [], "allowed": []})

 with open(path) as f:
 for line in f:
 try:
 entry = json.loads(line)
 ip = entry.get("transaction", {}).get("client_ip")
 status = entry.get("response", {}).get("status", 200)
 rules = entry.get("audit_data", {}).get("rules", [])

 if int(status) == 403:
 sessions[ip]["blocked"].append(rules)
 else:
 sessions[ip]["allowed"].append(entry.get("request", {}).get("uri"))
 except (json.JSONDecodeError, KeyError):
 continue

 for ip, data in sessions.items():
 if data["blocked"] and data["allowed"]:
 print(f"Possible false positive. IP {ip}")
 print(f" Blocked on rules: {data['blocked']}")
 print(f" Also had allowed requests to: {data['allowed'][:3]}")

if __name__ == "__main__":
 analyze_audit_log(sys.argv[1])
```

Claude Code can extend this script to output a CSV for ticket creation, or adapt it to query Elasticsearch directly if your logs are already centralized.

## Best Practices for Claude Code with ModSecurity

Follow these recommendations for productive Claude Code workflows:

1. Start with CRS: Begin with the OWASP Core Rule Set and customize from there rather than writing rules from scratch.

2. Test in Detection Mode First: Deploy new rules in detection mode (`SecRuleEngine DetectionOnly`) before blocking traffic.

3. Log Extensively: Enable detailed logging during development to understand rule behavior.

4. Version Control Your Rules: Keep your ModSecurity configurations in git. Claude Code can help you write commit messages and track changes.

5. Document Rule Rationale: Add meaningful `msg` and `logdata` actions so future maintainers understand why each rule exists.

6. Review Logs Regularly: Use Claude Code to analyze blocked requests weekly and identify patterns that need rule adjustments.

7. Scope Exclusions Tightly: Always combine URI, method, and parameter constraints in exclusion rules. Never disable a rule globally unless absolutely necessary.

8. Treat WAF Rules as Code: Apply the same review standards to rule changes that you apply to application code. Use pull requests, require approvals, and run automated tests before merging.

9. Keep CRS Updated: The CRS team releases updates that address emerging threats and reduce false positives. Claude Code can help you review the changelog between versions and assess whether exclusions you wrote still apply.

## Conclusion

Claude Code transforms ModSecurity WAF management from a tedious manual process into an efficient, assisted workflow. By using Claude Code for rule generation, configuration review, false positive analysis, and test automation, you can maintain solid web application security without sacrificing development speed. The ability to ask natural-language questions about log entries, receive targeted exclusion rules, and generate CI/CD pipeline integrations means that WAF maintenance shifts from reactive firefighting to deliberate, documented improvement. Start integrating these patterns into your workflow today, and you will see faster rule deployment cycles, more effective protection against web application threats, and a WAF configuration that your entire team can understand and maintain.


---


**Try it:** Paste your error into our [Error Diagnostic](/diagnose/) for an instant fix.
---

<div class="mastery-cta">

I'm a solo developer in Vietnam. 50K Chrome extension users. $500K+ on Upwork. 5 Claude Max subscriptions running agent fleets in parallel.

These are my actual CLAUDE.md templates, orchestration configs, and prompts. Not a course. Not theory. The files I copy into every project before I write a line of code.

**[See what's inside →](https://zovo.one/lifetime?utm_source=ccg&utm_medium=cta-default&utm_campaign=claude-code-for-modsecurity-waf-workflow-guide)**

$99 once. Free forever. 47/500 founding spots left.

</div>

Related Reading

- [Claude Code for AWS WAF Workflow: A Practical Guide](/claude-code-for-aws-waf-workflow/)
- [Claude Code for Cloudflare WAF Rules Workflow](/claude-code-for-cloudflare-waf-rules-workflow/)
- [Claude Code for NGINX WAF Workflow Tutorial](/claude-code-for-nginx-waf-workflow-tutorial/)

Built by theluckystrike. More at [zovo.one](https://zovo.one)


