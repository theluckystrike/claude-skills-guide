---
layout: default
title: "Best Claude Code Hooks for Code Quality (2026)"
description: "8 Claude Code hooks that enforce code quality automatically. Pre-commit linting, post-write formatting, test runners, and security scanners."
permalink: /best-claude-code-hooks-code-quality-2026/
date: 2026-04-20
last_tested: "2026-04-22"
---

# Best Claude Code Hooks for Code Quality (2026)

Hooks run automatically before or after Claude Code tool executions. The right hooks catch quality issues before they reach your codebase. Here are the best hooks for enforcing code quality, ranked by impact.

---

## 1. Post-Write Auto-Formatter

**What it does**: Runs your code formatter (Prettier, Black, rustfmt) automatically after Claude writes or edits a file.

**Why it is good**: Claude's output is usually well-formatted, but not always matching your exact style config. Auto-formatting ensures consistency without manual intervention.

**Configuration** (`.claude/settings.json`):
```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Write|Edit",
        "hooks": [
          {
            "type": "command",
            "command": "bash .claude/hooks/auto-format.sh"
          }
        ]
      }
    ]
  }
}
```

**Hook script** (`.claude/hooks/auto-format.sh`):
```bash
#!/bin/bash
INPUT=$(cat)
FILE=$(echo "$INPUT" | python3 -c "import sys,json; print(json.load(sys.stdin).get('tool_input',{}).get('file_path',''))" 2>/dev/null)
case "$FILE" in
  *.js|*.ts|*.jsx|*.tsx|*.css|*.json) npx prettier --write "$FILE" 2>/dev/null ;;
  *.py) python3 -m black "$FILE" 2>/dev/null ;;
  *.rs) rustfmt "$FILE" 2>/dev/null ;;
esac
exit 0
```

**Limitation**: Adds a small delay after every file write. Negligible for most workflows.

---

## 2. Post-Write Linter

**What it does**: Runs ESLint, Ruff, or Clippy after Claude writes code. Reports warnings and errors immediately.

**Why it is good**: Catches lint violations before they accumulate. Claude sees the linter output and can fix issues in the same session.

**Hook script** (`.claude/hooks/post-lint.sh`):
```bash
#!/bin/bash
INPUT=$(cat)
FILE=$(echo "$INPUT" | python3 -c "import sys,json; print(json.load(sys.stdin).get('tool_input',{}).get('file_path',''))" 2>/dev/null)
case "$FILE" in
  *.js|*.ts|*.jsx|*.tsx) npx eslint "$FILE" 2>/dev/null ;;
  *.py) python3 -m ruff check "$FILE" 2>/dev/null ;;
esac
exit 0
```

**Limitation**: Requires linter configuration in your project. Without an ESLint or Ruff config, the hook has nothing to enforce.

---

## 3. Pre-Bash Security Scanner

**What it does**: Inspects bash commands before Claude runs them. Blocks dangerous operations like `rm -rf /`, `chmod 777`, or commands that access sensitive directories.

**Why it is good**: Claude sometimes generates risky commands, especially during debugging. This hook prevents accidental damage.

**Hook script** (`.claude/hooks/pre-bash-security.sh`):
```bash
#!/bin/bash
INPUT=$(cat)
CMD=$(echo "$INPUT" | python3 -c "import sys,json; print(json.load(sys.stdin).get('tool_input',{}).get('command',''))" 2>/dev/null)

# Block dangerous patterns
if echo "$CMD" | grep -qE 'rm\s+-rf\s+/|chmod\s+777|> /etc/|curl.*\| bash'; then
    echo "BLOCKED: Potentially dangerous command: $CMD" >&2
    exit 1
fi
exit 0
```

**Limitation**: Pattern matching is imperfect. Determined users (or Claude) can work around simple patterns.

---

## 4. Post-Write Type Checker

**What it does**: Runs TypeScript type checking after Claude edits TypeScript files.

**Hook script** (`.claude/hooks/post-typecheck.sh`):
```bash
#!/bin/bash
INPUT=$(cat)
FILE=$(echo "$INPUT" | python3 -c "import sys,json; print(json.load(sys.stdin).get('tool_input',{}).get('file_path',''))" 2>/dev/null)
if [[ "$FILE" == *.ts || "$FILE" == *.tsx ]]; then
    npx tsc --noEmit 2>/dev/null | head -20
fi
exit 0
```

**Limitation**: Full project type checking can be slow. Consider checking only the modified file.

---

## 5. Command Logger

**What it does**: Logs every command Claude runs to a file. Creates an audit trail of all tool usage.

**Why it is good**: Debugging sessions become traceable. If something breaks, you can see exactly what Claude did.

**Hook script** (`.claude/hooks/command-logger.sh`):
```bash
#!/bin/bash
INPUT=$(cat)
TOOL=$(echo "$INPUT" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('tool_name','unknown'))" 2>/dev/null)
echo "[$(date '+%Y-%m-%d %H:%M:%S')] $TOOL: $(echo "$INPUT" | python3 -c "import sys,json; print(json.dumps(json.load(sys.stdin).get('tool_input',{})))" 2>/dev/null)" >> .claude/audit-log.txt
exit 0
```

**Limitation**: Log file grows continuously. Add rotation or periodic cleanup.

---

## 6. Test Runner on File Change

**What it does**: Runs relevant tests after Claude modifies a source file.

**Hook script** (`.claude/hooks/post-test-runner.sh`):
```bash
#!/bin/bash
INPUT=$(cat)
FILE=$(echo "$INPUT" | python3 -c "import sys,json; print(json.load(sys.stdin).get('tool_input',{}).get('file_path',''))" 2>/dev/null)
# Run tests for modified file (assumes test file naming convention)
TEST_FILE=$(echo "$FILE" | sed 's/\.ts$/.test.ts/' | sed 's/\.py$/_test.py/')
if [ -f "$TEST_FILE" ]; then
    npx vitest run "$TEST_FILE" --reporter=verbose 2>/dev/null | tail -10
fi
exit 0
```

**Limitation**: Depends on test naming conventions. Adjust the `sed` pattern for your project.

---

## 7. Dependency Vulnerability Check

**What it does**: Runs `npm audit` or `pip-audit` after Claude modifies package files.

**Hook script** (`.claude/hooks/dep-audit.sh`):
```bash
#!/bin/bash
INPUT=$(cat)
FILE=$(echo "$INPUT" | python3 -c "import sys,json; print(json.load(sys.stdin).get('tool_input',{}).get('file_path',''))" 2>/dev/null)
case "$FILE" in
  */package.json) npm audit --production 2>/dev/null | tail -5 ;;
  */requirements.txt) pip-audit -r "$FILE" 2>/dev/null | tail -5 ;;
esac
exit 0
```

**Limitation**: Only triggers on package file changes. Does not catch vulnerabilities in existing dependencies.

---

## 8. File Size Guard

**What it does**: Warns when Claude creates or modifies a file that exceeds a size threshold. Prevents accidental generation of massive files.

**Hook script** (`.claude/hooks/file-size-guard.sh`):
```bash
#!/bin/bash
INPUT=$(cat)
FILE=$(echo "$INPUT" | python3 -c "import sys,json; print(json.load(sys.stdin).get('tool_input',{}).get('file_path',''))" 2>/dev/null)
if [ -f "$FILE" ]; then
    SIZE=$(wc -l < "$FILE")
    if [ "$SIZE" -gt 500 ]; then
        echo "WARNING: $FILE has $SIZE lines (threshold: 500)" >&2
    fi
fi
exit 0
```

**Limitation**: Line count is a crude metric. Some files are legitimately large.

---

## Combining Hooks for Maximum Coverage

Individual hooks are useful. Combining them creates a quality safety net:

**The Essential Stack** (recommended for all projects):
1. Post-Write Auto-Formatter (#1) — consistent style
2. Pre-Bash Security Scanner (#3) — prevents dangerous commands
3. Command Logger (#5) — audit trail

**The Full Quality Stack** (for production projects):
1. Post-Write Auto-Formatter (#1)
2. Post-Write Linter (#2)
3. Pre-Bash Security Scanner (#3)
4. Post-Write Type Checker (#4) — if using TypeScript
5. Command Logger (#5)
6. Test Runner (#6)
7. File Size Guard (#8)

**The Security Stack** (for sensitive projects):
1. Pre-Bash Security Scanner (#3) — command filtering
2. Command Logger (#5) — complete audit trail
3. Dependency Vulnerability Check (#7) — supply chain security
4. File Size Guard (#8) — prevents data exfiltration via large files

## Performance Impact

Each hook adds latency to tool execution. Here are typical numbers:

| Hook | Added Latency | Frequency |
|---|---|---|
| Auto-Formatter | 100-300ms | Every file write |
| Linter | 200-500ms | Every file write |
| Security Scanner | < 50ms | Every bash command |
| Type Checker | 500ms-2s | Every TS file write |
| Command Logger | < 10ms | Every tool use |
| Test Runner | 1-10s | Every source file write |
| Dep Vulnerability | 2-5s | Package file changes only |
| File Size Guard | < 10ms | Every file write |

For most developers, the auto-formatter and security scanner add negligible delay. The test runner and type checker add noticeable delay but catch the most bugs. Adjust your stack based on your tolerance for latency vs your need for quality enforcement.

## Getting Started

Install hooks #1 (formatter) and #3 (security scanner) today. They provide the highest impact with the lowest risk. Add more as you identify quality gaps in your workflow.

For hook fundamentals, see the [Claude Code hooks guide](/understanding-claude-code-hooks-system-complete-guide/). For writing your first hook from scratch, follow the [hook tutorial](/how-to-write-claude-code-hook-2026/). For the full quality stack, explore the [Claude Code best practices](/karpathy-skills-vs-claude-code-best-practices-2026/) and the [Claude Code playbook](/playbook/).
