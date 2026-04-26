---
layout: default
title: "Claude Code For Custom Lsp (2026)"
description: "Learn how to build powerful custom diagnostics workflows using Claude Code and Language Server Protocol to automate code quality checks and error."
date: 2026-03-15
last_modified_at: 2026-04-17
author: "Claude Skills Guide"
permalink: /claude-code-for-custom-lsp-diagnostics-workflow/
categories: [guides, workflows]
tags: [claude-code, claude-skills]
reviewed: true
score: 8
geo_optimized: true
---
Claude Code for Custom LSP Diagnostics Workflow

The Language Server Protocol (LSP) has revolutionized how we approach code analysis and diagnostics. By combining Claude Code with custom LSP diagnostics workflows, developers can create powerful automated systems that catch errors, enforce coding standards, and provide intelligent feedback, all without leaving their development environment.

This guide walks you through building a custom LSP diagnostics workflow using Claude Code, with practical examples you can adapt for your own projects.

## Understanding LSP Diagnostics in Claude Code

LSP diagnostics are standardized messages that language servers send to clients to report errors, warnings, and other issues in your code. Claude Code can interact with these diagnostics to help you build workflows that automatically detect, categorize, and respond to code issues.

When you work with LSP-enabled editors, diagnostics appear as squiggly lines under problematic code. But with Claude Code, you can go beyond visual indicators, you can capture, filter, and act on these diagnostics programmatically.

The LSP specification defines four severity levels:

| Level | Value | Meaning | Typical Response |
|-------|-------|---------|------------------|
| Error | 1 | Code will not compile or run | Block merge/commit |
| Warning | 2 | Potential bug or bad practice | Flag for review |
| Information | 3 | Style or convention note | Log and track |
| Hint | 4 | Suggestion for improvement | Optional |

Claude Code can consume all four levels and apply different automations to each, giving you fine-grained control over how your pipeline responds.

## Setting Up Your Diagnostic Collection

The first step in building a custom diagnostics workflow is capturing LSP messages. Here's a basic setup using Claude Code's tools:

```python
import subprocess
import json

def get_lsp_diagnostics(lsp_server, file_path):
 """Capture diagnostics from an LSP server for a given file."""
 # Initialize LSP server and send didOpen notification
 initialize_msg = {
 "jsonrpc": "2.0",
 "id": 1,
 "method": "initialize",
 "params": {
 "processId": None,
 "rootUri": "file:///your/project/root",
 "capabilities": {}
 }
 }

 # Send document open notification
 did_open_msg = {
 "jsonrpc": "2.0",
 "method": "textDocument/didOpen",
 "params": {
 "textDocument": {
 "uri": f"file://{file_path}",
 "languageId": "python",
 "version": 1,
 "text": open(file_path).read()
 }
 }
 }

 # Parse diagnostics from server response
 return parse_diagnostics_response(response)
```

This foundation lets you build more sophisticated workflows that process diagnostics in real-time.

A more production-ready version adds proper process management and timeout handling:

```python
import subprocess
import json
import threading
import time
from pathlib import Path

class LSPClient:
 def __init__(self, server_command, workspace_root):
 self.server_command = server_command
 self.workspace_root = workspace_root
 self.process = None
 self._request_id = 0
 self._diagnostics = {}
 self._lock = threading.Lock()

 def start(self):
 self.process = subprocess.Popen(
 self.server_command,
 stdin=subprocess.PIPE,
 stdout=subprocess.PIPE,
 stderr=subprocess.PIPE
 )
 self._send_initialize()
 # Start a reader thread to capture publishDiagnostics notifications
 reader = threading.Thread(target=self._read_loop, daemon=True)
 reader.start()

 def _send_initialize(self):
 self._send_request("initialize", {
 "processId": self.process.pid,
 "rootUri": f"file://{self.workspace_root}",
 "capabilities": {
 "textDocument": {
 "publishDiagnostics": {"relatedInformation": True}
 }
 }
 })

 def _next_id(self):
 with self._lock:
 self._request_id += 1
 return self._request_id

 def _send_request(self, method, params):
 msg = json.dumps({
 "jsonrpc": "2.0",
 "id": self._next_id(),
 "method": method,
 "params": params
 })
 header = f"Content-Length: {len(msg)}\r\n\r\n"
 self.process.stdin.write((header + msg).encode())
 self.process.stdin.flush()

 def open_file(self, file_path):
 text = Path(file_path).read_text()
 lang = self._detect_language(file_path)
 self._send_request("textDocument/didOpen", {
 "textDocument": {
 "uri": f"file://{file_path}",
 "languageId": lang,
 "version": 1,
 "text": text
 }
 })
 # Wait briefly for the server to publish diagnostics
 time.sleep(0.5)
 return self._diagnostics.get(f"file://{file_path}", [])

 def _detect_language(self, file_path):
 ext_map = {".py": "python", ".ts": "typescript",
 ".js": "javascript", ".go": "go", ".rs": "rust"}
 ext = Path(file_path).suffix
 return ext_map.get(ext, "plaintext")

 def _read_loop(self):
 while True:
 header = b""
 while not header.endswith(b"\r\n\r\n"):
 byte = self.process.stdout.read(1)
 if not byte:
 return
 header += byte
 content_length = int(header.split(b"Content-Length: ")[1].split(b"\r\n")[0])
 body = self.process.stdout.read(content_length)
 msg = json.loads(body)
 if msg.get("method") == "textDocument/publishDiagnostics":
 uri = msg["params"]["uri"]
 self._diagnostics[uri] = msg["params"]["diagnostics"]
```

This client manages the full LSP lifecycle: initialization, file opening, and asynchronous diagnostic collection from the server's push notifications.

## Building a Custom Diagnostics Pipeline

A well-designed diagnostics pipeline has three main stages: collection, analysis, and action. Let's build each component.

## Stage 1: Collection

Create a Claude Code skill that intercepts diagnostics from your language server:

```json
{
 "name": "diagnostics-collector",
 "description": "Collect and aggregate LSP diagnostics",
 "actions": [
 {
 "trigger": "on-save",
 "execute": "capture_current_diagnostics"
 }
 ]
}
```

For multi-file projects you need to walk the entire source tree and open each file in the LSP client before collecting:

```python
import os
from concurrent.futures import ThreadPoolExecutor, as_completed

def collect_project_diagnostics(lsp_client, source_root, extensions=None):
 """Open every source file and aggregate diagnostics."""
 if extensions is None:
 extensions = {".py", ".ts", ".js", ".go"}

 files = [
 os.path.join(root, f)
 for root, _, filenames in os.walk(source_root)
 for f in filenames
 if os.path.splitext(f)[1] in extensions
 and ".git" not in root
 and "node_modules" not in root
 ]

 all_diagnostics = {}
 with ThreadPoolExecutor(max_workers=4) as pool:
 futures = {pool.submit(lsp_client.open_file, f): f for f in files}
 for future in as_completed(futures):
 file_path = futures[future]
 try:
 diags = future.result()
 if diags:
 all_diagnostics[file_path] = diags
 except Exception as exc:
 print(f"Warning: could not collect diagnostics for {file_path}: {exc}")

 return all_diagnostics
```

## Stage 2: Analysis

Once collected, diagnostics need categorization. Here's a pattern for analyzing and grouping issues:

```python
def analyze_diagnostics(diagnostics):
 """Categorize diagnostics by severity and type."""
 categorized = {
 "errors": [],
 "warnings": [],
 "information": [],
 "by_file": {},
 "by_type": {}
 }

 for diag in diagnostics:
 severity = diag.get("severity", 3)
 if severity == 1:
 categorized["errors"].append(diag)
 elif severity == 2:
 categorized["warnings"].append(diag)
 else:
 categorized["information"].append(diag)

 # Group by file
 file = diag.get("uri", "").split("/")[-1]
 categorized["by_file"].setdefault(file, []).append(diag)

 # Group by error code
 code = diag.get("code", "unknown")
 categorized["by_type"].setdefault(code, []).append(diag)

 return categorized
```

You can extend analysis to detect trends across a time window by persisting diagnostic snapshots:

```python
import sqlite3
from datetime import datetime

def record_diagnostics_snapshot(analyzed, db_path="diagnostics.db"):
 """Persist a diagnostics snapshot for trend analysis."""
 conn = sqlite3.connect(db_path)
 conn.execute("""
 CREATE TABLE IF NOT EXISTS snapshots (
 ts TEXT,
 error_count INTEGER,
 warning_count INTEGER,
 info_count INTEGER,
 top_error_code TEXT
 )
 """)
 top_error = max(analyzed["by_type"].items(),
 key=lambda x: len(x[1]),
 default=("none", []))[0]
 conn.execute(
 "INSERT INTO snapshots VALUES (?, ?, ?, ?, ?)",
 (
 datetime.utcnow().isoformat(),
 len(analyzed["errors"]),
 len(analyzed["warnings"]),
 len(analyzed["information"]),
 top_error
 )
 )
 conn.commit()
 conn.close()
```

Running this on every CI build gives you a historical error trend chart, you can spot if a refactor branch is quietly accumulating warnings that will become errors later.

## Stage 3: Action

The final stage is taking action based on your analysis. This could mean generating reports, triggering notifications, or automatically creating fix suggestions:

```python
def generate_diagnostic_report(analyzed, output_path):
 """Create a formatted diagnostic report."""
 report = []
 report.append("# Diagnostics Report\n")

 report.append(f"## Summary")
 report.append(f"- Errors: {len(analyzed['errors'])}")
 report.append(f"- Warnings: {len(analyzed['warnings'])}")
 report.append(f"- Info: {len(analyzed['information'])}\n")

 if analyzed['errors']:
 report.append("## Critical Errors\n")
 for error in analyzed['errors']:
 report.append(f"- {error['source']}: {error['message']}")
 if 'range' in error:
 report.append(f" Location: {error['range']}")
 report.append("")

 return "\n".join(report)
```

For CI environments, you typically want to fail the build based on thresholds:

```python
def evaluate_quality_gate(analyzed, config):
 """
 Return (passed: bool, violations: list) based on configurable thresholds.

 config example:
 {"max_errors": 0, "max_warnings": 50, "block_on_codes": ["E1101", "F821"]}
 """
 violations = []

 if len(analyzed["errors"]) > config.get("max_errors", 0):
 violations.append(
 f"Error count {len(analyzed['errors'])} exceeds threshold {config['max_errors']}"
 )

 if len(analyzed["warnings"]) > config.get("max_warnings", 100):
 violations.append(
 f"Warning count {len(analyzed['warnings'])} exceeds threshold {config['max_warnings']}"
 )

 blocked_codes = config.get("block_on_codes", [])
 for code in blocked_codes:
 if code in analyzed["by_type"]:
 count = len(analyzed["by_type"][code])
 violations.append(f"Blocked diagnostic code {code} found {count} time(s)")

 return (len(violations) == 0, violations)
```

## Practical Example: Git Pre-Commit Diagnostics

One powerful use case is running diagnostics before commits. Here's how to integrate with git hooks:

```bash
#!/bin/bash
.git/hooks/pre-commit

Run diagnostics on staged files
STAGED_FILES=$(git diff --cached --name-only --diff-filter=ACM)

for file in $STAGED_FILES; do
 echo "Running diagnostics on: $file"
 claude-code run-diagnostics --file "$file" --format json
done

Exit with error if critical issues found
if [ $? -ne 0 ]; then
 echo "Critical diagnostics found. Commit aborted."
 exit 1
fi
```

This workflow ensures code quality before it enters your repository, catching issues early in the development cycle.

A more solid pre-commit hook that collects all staged file diagnostics in one pass and gives structured output:

```bash
#!/bin/bash
.git/hooks/pre-commit. LSP diagnostics gate

set -euo pipefail

STAGED_PY=$(git diff --cached --name-only --diff-filter=ACM | grep '\.py$' || true)
STAGED_TS=$(git diff --cached --name-only --diff-filter=ACM | grep '\.ts$' || true)

if [ -z "$STAGED_PY" ] && [ -z "$STAGED_TS" ]; then
 exit 0 # Nothing to check
fi

TMPDIR=$(mktemp -d)
trap "rm -rf $TMPDIR" EXIT

Collect pyright diagnostics for Python files
if [ -n "$STAGED_PY" ]; then
 echo "$STAGED_PY" | xargs pyright --outputjson 2>/dev/null \
 > "$TMPDIR/pyright.json" || true
fi

Collect typescript compiler diagnostics for TS files
if [ -n "$STAGED_TS" ]; then
 npx tsc --noEmit --pretty false 2>&1 \
 > "$TMPDIR/tsc.txt" || true
fi

Feed to Claude for assessment
ASSESSMENT=$(claude --print "
I am running a pre-commit quality gate.
Here are LSP diagnostics for staged files.

$(cat $TMPDIR/*.json $TMPDIR/*.txt 2>/dev/null)

Reply with exactly one line: PASS or FAIL, followed by a colon and a brief reason.
Only FAIL if there are severity-1 errors (not warnings).
")

echo "$ASSESSMENT"

if echo "$ASSESSMENT" | grep -q "^FAIL"; then
 echo "Pre-commit gate failed. Fix errors before committing."
 exit 1
fi

exit 0
```

## Advanced: Custom Diagnostic Rules

Beyond standard LSP diagnostics, you can create custom rules specific to your project:

```javascript
// Define custom diagnostic rules
const customRules = {
 "no-console-log": {
 "severity": "warning",
 "message": "Use a proper logging framework instead of console.log",
 "pattern": /console\.(log|debug|info)/
 },
 "auth-check-required": {
 "severity": "error",
 "message": "Route handler must include authentication check",
 "pattern": /router\.(get|post|put|delete)\(.*\)$/m,
 "requires": ["authMiddleware"]
 }
};

// Apply custom rules alongside LSP diagnostics
function applyCustomRules(sourceCode, lspDiagnostics) {
 const customIssues = [];

 for (const [ruleName, rule] of Object.entries(customRules)) {
 const matches = sourceCode.matchAll(rule.pattern);
 for (const match of matches) {
 customIssues.push({
 rule: ruleName,
 message: rule.message,
 severity: rule.severity,
 position: match.index
 });
 }
 }

 return [...lspDiagnostics, ...customIssues];
}
```

Custom rules are particularly valuable for domain-specific constraints that generic LSP servers cannot know about. Common use cases include:

- Security rules: flag direct SQL string concatenation, hard-coded credentials, or missing input sanitization
- Architecture rules: ensure services only import from their allowed dependency layer
- API contract rules: verify every public endpoint has an OpenAPI annotation
- Compliance rules: catch use of deprecated internal APIs before they cause runtime failures

Here is a Python equivalent that integrates cleanly with the analysis pipeline:

```python
import re
from dataclasses import dataclass, field
from typing import Optional

@dataclass
class CustomRule:
 name: str
 pattern: str
 severity: int # LSP severity: 1=error, 2=warning
 message: str
 file_glob: str = "/*"
 requires_absence: Optional[str] = None # Another pattern that must NOT match

CUSTOM_RULES = [
 CustomRule(
 name="no-raw-sql",
 pattern=r'execute\s*\(\s*["\']SELECT',
 severity=2,
 message="Use parameterized queries or an ORM instead of raw SQL strings",
 file_glob="/*.py"
 ),
 CustomRule(
 name="no-hardcoded-secrets",
 pattern=r'(password|secret|api_key)\s*=\s*["\'][^"\']{8,}["\']',
 severity=1,
 message="Hard-coded secret detected. use environment variables",
 file_glob="/*.py"
 ),
 CustomRule(
 name="require-type-hints",
 pattern=r'^def \w+\([^)]*\)\s*:',
 severity=2,
 message="Function missing return type annotation",
 requires_absence=r'^def \w+\([^)]*\)\s*->'
 ),
]

def run_custom_rules(file_path, source_code):
 """Apply custom rules and return LSP-compatible diagnostics."""
 findings = []
 for rule in CUSTOM_RULES:
 for m in re.finditer(rule.pattern, source_code, re.MULTILINE):
 if rule.requires_absence:
 # Check that the safeguard pattern is also absent on the same line
 line = source_code[source_code.rfind('\n', 0, m.start())+1:
 source_code.find('\n', m.end())]
 if re.search(rule.requires_absence, line):
 continue # Safeguard present, rule satisfied
 line_num = source_code[:m.start()].count('\n')
 findings.append({
 "uri": f"file://{file_path}",
 "source": "custom-rules",
 "code": rule.name,
 "severity": rule.severity,
 "message": rule.message,
 "range": {
 "start": {"line": line_num, "character": 0},
 "end": {"line": line_num, "character": len(m.group())}
 }
 })
 return findings
```

## Integrating with Claude Code for AI-Powered Fix Suggestions

The most powerful use of this pipeline is feeding diagnostics back to Claude Code to generate fix suggestions automatically. Once you have structured diagnostic output, you can prompt Claude with the affected code context:

```python
import anthropic

def generate_fix_suggestions(diagnostics, source_code_map):
 """Ask Claude to suggest fixes for each error-level diagnostic."""
 client = anthropic.Anthropic()
 suggestions = []

 errors = [d for d in diagnostics if d.get("severity") == 1]

 for error in errors[:10]: # Cap at 10 to stay within context limits
 uri = error.get("uri", "")
 file_path = uri.replace("file://", "")
 source = source_code_map.get(file_path, "")

 if not source:
 continue

 line = error["range"]["start"]["line"]
 # Extract surrounding context (5 lines before, 5 after)
 lines = source.splitlines()
 start = max(0, line - 5)
 end = min(len(lines), line + 6)
 context = "\n".join(
 f"{i+start+1}: {l}" for i, l in enumerate(lines[start:end])
 )

 prompt = (
 f"File: {file_path}\n"
 f"LSP error ({error.get('code', 'unknown')}): {error['message']}\n\n"
 f"Code context:\n{context}\n\n"
 f"Provide a concise fix. Output only the corrected lines, "
 f"no explanation needed unless the fix is non-obvious."
 )

 response = client.messages.create(
 model="claude-opus-4-6",
 max_tokens=512,
 messages=[{"role": "user", "content": prompt}]
 )
 suggestions.append({
 "diagnostic": error,
 "suggestion": response.content[0].text
 })

 return suggestions
```

## Best Practices for Diagnostic Workflows

When building your custom LSP diagnostics workflow, keep these principles in mind:

1. Prioritize by severity: Not all diagnostics are equal. Focus on errors first, then warnings, and finally informational messages.

2. Aggregate strategically: Instead of treating each diagnostic in isolation, look for patterns. A hundred similar warnings might indicate a systemic issue worth addressing holistically.

3. Integrate with your tooling: Your diagnostics workflow should play well with existing tools, linters, formatters, and CI/CD pipelines.

4. Provide actionable feedback: When diagnostics are detected, the action should be clear. Don't just say "there's an error"; explain what to do about it.

5. Cache intelligently: Running full diagnostics on every keystroke is expensive. Implement debouncing and caching to balance responsiveness with accuracy.

Here is how these principles map to implementation decisions:

| Principle | Implementation |
|-----------|---------------|
| Prioritize by severity | Quality gate thresholds per severity level |
| Aggregate strategically | Group by `code` field; alert on cluster spikes |
| Integrate with tooling | GitHub Actions step that posts diagnostic counts to PR |
| Actionable feedback | Claude-generated fix suggestions per error |
| Cache intelligently | Hash file contents; skip re-analysis if hash unchanged |

For caching, a simple content-hash approach prevents re-running the LSP on files that have not changed:

```python
import hashlib
import json
import os

def load_diagnostic_cache(cache_path):
 if os.path.exists(cache_path):
 with open(cache_path) as f:
 return json.load(f)
 return {}

def save_diagnostic_cache(cache, cache_path):
 with open(cache_path, "w") as f:
 json.dump(cache, f, indent=2)

def file_hash(path):
 with open(path, "rb") as f:
 return hashlib.sha256(f.read()).hexdigest()

def get_diagnostics_with_cache(lsp_client, file_path, cache):
 h = file_hash(file_path)
 if cache.get(file_path, {}).get("hash") == h:
 return cache[file_path]["diagnostics"] # Cache hit
 diags = lsp_client.open_file(file_path)
 cache[file_path] = {"hash": h, "diagnostics": diags}
 return diags
```

This makes large-project diagnostic runs fast on incremental changes, only modified files get re-analyzed.

## Conclusion

Building custom LSP diagnostics workflows with Claude Code opens up powerful possibilities for automated code quality assurance. By collecting diagnostics, analyzing patterns, and taking targeted actions, you can catch issues early, enforce standards consistently, and focus your attention on what matters most, writing great code.

The combination of standard LSP diagnostics, custom domain-specific rules, and Claude-generated fix suggestions creates a quality layer that scales from individual developer machines to full CI/CD pipelines. You get the precision of a language server, the flexibility of custom rules, and the reasoning power of an AI, all feeding into a single, coherent feedback loop.

Start with the pre-commit hook and a basic collection pipeline. Add custom rules for your most frequent error patterns. Then layer in Claude fix suggestions once you have the pipeline stable. The key is finding the right balance between thoroughness and performance, ensuring your diagnostics enhance rather than hinder your development process.



---


**Try it:** Paste your error into our [Error Diagnostic](/diagnose/) for an instant fix.
---

<div class="mastery-cta">

I'm a solo developer in Vietnam. 50K Chrome extension users. $500K+ on Upwork. 5 Claude Max subscriptions running agent fleets in parallel.

These are my actual CLAUDE.md templates, orchestration configs, and prompts. Not a course. Not theory. The files I copy into every project before I write a line of code.

**[See what's inside →](https://zovo.one/lifetime?utm_source=ccg&utm_medium=cta-default&utm_campaign=claude-code-for-custom-lsp-diagnostics-workflow)**

$99 once. Free forever. 47/500 founding spots left.

</div>

Related Reading


- [Troubleshooting Guide](/troubleshooting/). Diagnose and fix any Claude Code issue
- [Claude Code Data Retention Policy Workflow](/claude-code-data-retention-policy-workflow/)
- [Claude Code for Aurora Serverless V2 Workflow](/claude-code-for-aurora-serverless-v2-workflow/)
- [Claude Code for Branch Protection Rules Workflow](/claude-code-for-branch-protection-rules-workflow/)

Built by theluckystrike. More at [zovo.one](https://zovo.one)


