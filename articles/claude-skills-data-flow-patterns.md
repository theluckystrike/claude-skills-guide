---
layout: default
title: "Claude Skills Data Flow Patterns (2026)"
description: "Design data flow between Claude Code skills using file-based interfaces, argument passing, dynamic injection, and structured output routing patterns."
permalink: /claude-skills-data-flow-patterns/
date: 2026-04-20
categories: [skills, 2026]
tags: [claude-code, claude-skills, data-flow, architecture]
last_updated: 2026-04-19
---

## The Specific Situation

You have a three-skill pipeline: a "scanner" skill reads all source files and produces a report, an "analyzer" skill processes that report and identifies issues, and a "fixer" skill applies fixes based on the analysis. The scanner's output needs to reach the analyzer, and the analyzer's output needs to reach the fixer. But skills do not share memory or return values to each other. How do they communicate?

## Technical Foundation

Claude Code skills have four data flow mechanisms. First, **file-based interfaces**: skills write structured output (JSON, CSV, Markdown) to files that other skills read. Second, **argument passing**: `$ARGUMENTS` substitution passes user input into a skill, and skill output in the conversation context is visible to the next skill invoked in the same session. Third, **dynamic context injection**: `!`command`` executes at preprocessing time and injects output into the skill content before Claude processes it. Fourth, **conversation context**: all skills invoked in the same session share the conversation, so output from one skill is visible to the next.

The file-based interface is the most reliable pattern because it persists across compaction events, does not depend on conversation memory, and produces artifacts that can be inspected and debugged independently.

## The Working SKILL.md

Pipeline with file-based interfaces:

```yaml
---
name: scan-analyze-fix
description: >
  Three-phase pipeline: scan source files for issues, analyze
  findings, and apply fixes. Each phase writes to a staging
  directory. Invoke with: /scan-analyze-fix [target-dir]
disable-model-invocation: true
allowed-tools: Read Grep Bash(*)
---

# Scan-Analyze-Fix Pipeline

## Data Flow
```
$ARGUMENTS[0] (target dir)
       |
       v
Phase 1: /scanner → .claude/staging/scan-report.json
       |
       v
Phase 2: /analyzer reads scan-report.json → .claude/staging/analysis.json
       |
       v
Phase 3: /fixer reads analysis.json → applies fixes, writes summary
```

## Phase 1: Scanner
Input: Target directory path ($ARGUMENTS[0])
Output: `.claude/staging/scan-report.json`

```json
{
  "scanned_at": "ISO-8601",
  "target": "src/",
  "files_scanned": 142,
  "findings": [
    {
      "file": "src/auth/login.ts",
      "line": 45,
      "type": "security",
      "severity": "high",
      "message": "SQL string concatenation in query"
    }
  ]
}
```

Rules:
1. Scan all files matching `**/*.{ts,py,go}` in target directory
2. Check for: SQL injection, hardcoded secrets, missing error handling
3. Write findings as JSON array with file, line, type, severity, message
4. Create staging directory if it does not exist

## Phase 2: Analyzer
Input: `.claude/staging/scan-report.json`
Output: `.claude/staging/analysis.json`

```json
{
  "analyzed_at": "ISO-8601",
  "total_findings": 12,
  "by_severity": { "high": 3, "medium": 5, "low": 4 },
  "fix_plan": [
    {
      "file": "src/auth/login.ts",
      "line": 45,
      "action": "Replace string concatenation with parameterized query",
      "auto_fixable": true,
      "estimated_risk": "low"
    }
  ]
}
```

Rules:
1. Read scan-report.json — abort if missing or malformed
2. Group findings by severity and type
3. For each finding, determine if it is auto-fixable
4. Generate a fix plan with specific actions per finding
5. Flag high-risk fixes (structural changes) for manual review

## Phase 3: Fixer
Input: `.claude/staging/analysis.json`
Output: Modified source files + `.claude/staging/fix-summary.json`

Rules:
1. Read analysis.json — abort if missing
2. Apply only auto_fixable=true fixes
3. Skip estimated_risk=high fixes (output warning)
4. After each fix, verify the file still parses (syntax check)
5. Write fix-summary.json with: applied count, skipped count, errors

## Staging Directory Convention
- All intermediate data in `.claude/staging/`
- Add `.claude/staging/` to .gitignore
- Each pipeline run creates timestamped subdirectory if needed
- Clean staging after successful pipeline completion
```

Dynamic context injection data flow:

```yaml
---
name: status-dashboard
description: >
  Show project health dashboard with live data from CI, test coverage,
  and dependency status. Pulls live data at invocation time.
allowed-tools: Bash(*)
---

# Project Status Dashboard

## Live Data (injected at load time)
- CI status: !`gh run list --limit 1 --json status,conclusion -q '.[0]'`
- Test coverage: !`cat coverage/coverage-summary.json 2>/dev/null | jq '.total.lines.pct' || echo 'no coverage data'`
- Outdated deps: !`npm outdated --json 2>/dev/null | jq 'length' || echo '0'`
- Open PRs: !`gh pr list --state open --json number -q 'length'`

## Display Format
Present the above data as a summary table.
Flag any metric that is below threshold:
- CI: anything other than "success" = red
- Coverage: below 80% = yellow, below 60% = red
- Outdated deps: above 10 = yellow, above 20 = red
- Open PRs: above 15 = yellow (review bottleneck)
```

## Common Problems and Fixes

**Intermediate file missing between pipeline phases.** Phase 2 starts before Phase 1 finishes writing. Add an existence check at the start of each phase: "Read `.claude/staging/scan-report.json`. If the file does not exist, report that Phase 1 must complete first and stop."

**JSON output is malformed.** Claude sometimes generates JSON with trailing commas or unquoted keys. Add a validation step: "After writing the JSON file, read it back with `python3 -c 'import json; json.load(open(\"file\"))'` to verify it parses."

**Dynamic context injection command fails silently.** If the `!`command`` returns an error, the error text replaces the placeholder. This can confuse Claude. Use conditional commands: `!`gh run list --limit 1 2>/dev/null || echo "GitHub CLI not available"`` to provide a clear fallback.

**Staging directory not in .gitignore.** Intermediate pipeline files should not be committed. Add `.claude/staging/` to `.gitignore` immediately. If already tracked, run `git rm -r --cached .claude/staging/` to untrack.

## Production Gotchas

File-based interfaces create disk artifacts. In CI environments or long-running sessions, staging directories accumulate data. Add a cleanup step at the end of each pipeline run, or use a timestamp-based naming convention (`staging/run-2026-04-19T14-30/`) and prune runs older than 24 hours.

Dynamic context injection runs every time the skill is invoked, not just the first time. If a skill is re-invoked after compaction, all `!`command`` blocks execute again. For expensive commands (API calls, large file processing), cache the result to a file and read from cache: `!`cat .claude/cache/ci-status.json 2>/dev/null || (gh run list > .claude/cache/ci-status.json && cat .claude/cache/ci-status.json)``.

## Checklist

- [ ] Pipeline phases write output to `.claude/staging/` directory
- [ ] Each phase validates input file exists before processing
- [ ] JSON output validated with a parse check after writing
- [ ] `.claude/staging/` added to `.gitignore`
- [ ] Dynamic injection commands have error fallbacks

## Related Guides

**Try it:** Paste your error into our [Error Diagnostic](/diagnose/) for an instant fix.

- [Claude Skill Composition Patterns](/claude-skill-composition-patterns/) -- pipeline and fan-out architectures
- [Claude Skills Shared Dependencies](/claude-skills-shared-dependencies/) -- sharing data files between skills
- [Claude Skills Performance Optimization](/claude-skills-performance-optimization/) -- reducing data flow overhead
