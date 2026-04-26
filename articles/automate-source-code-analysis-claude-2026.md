---
layout: post
title: "Automate Source Code Analysis (2026)"
description: "Use Claude Code for automated code analysis: complexity metrics, dependency mapping, dead code detection, and architecture visualization scripts."
permalink: /automate-source-code-analysis-claude-2026/
date: 2026-04-21
last_tested: "2026-04-21"
---

## The Workflow

Automate static code analysis tasks using Claude Code: calculate complexity metrics, map dependencies between modules, detect dead code, and generate architecture diagrams. Produces actionable reports without requiring expensive commercial analysis tools.

Expected time: 20-40 minutes for full analysis pipeline
Prerequisites: Claude Code installed, project codebase, Python 3.10+ (for analysis scripts)

## Setup

### 1. Create an Analysis Output Directory

```bash
mkdir -p ./analysis-reports
```

### 2. Configure CLAUDE.md for Analysis Tasks

```markdown
# CLAUDE.md additions for code analysis

## Analysis Rules
- When analyzing code, read files but never modify them
- Report findings in markdown tables
- Include file paths relative to project root
- Calculate cyclomatic complexity as: decision_points + 1
- Flag functions over 50 lines or complexity over 10
- Count only production code (exclude test files, configs)
```

### 3. Install Optional Analysis Tools

```bash
# Python complexity analysis
pip install radon

# JavaScript/TypeScript
npm install -g madge typescript

# Verify
radon cc --version && madge --version
# Expected output:
# radon version numbers displayed
# madge version displayed
```

## Usage Example

Run a comprehensive analysis pipeline:

```bash
#!/bin/bash
# analyze-project.sh — Full codebase analysis with Claude Code

PROJECT_DIR="${1:-.}"
REPORT_DIR="./analysis-reports/$(date +%Y%m%d)"
mkdir -p "$REPORT_DIR"

echo "=== Analyzing: $PROJECT_DIR ==="

# Step 1: Complexity Analysis
echo "--- Step 1: Complexity Metrics ---"
claude --print "Analyze the cyclomatic complexity of all functions in src/.
For each function with complexity > 5, report:
| File | Function | Lines | Complexity | Risk Level |
Risk levels: Low (1-5), Medium (6-10), High (11-15), Critical (>15)
Sort by complexity descending. Output as a markdown table." \
  > "$REPORT_DIR/complexity.md"

# Step 2: Dependency Mapping
echo "--- Step 2: Dependency Map ---"
claude --print "Map all import/require statements in src/.
Create a dependency matrix showing:
1. Which modules import which other modules
2. Circular dependencies (if any)
3. Modules with the most dependents (most imported by others)
4. Orphan modules (imported by nothing, import nothing)
Output as markdown with a table and a text-based dependency tree." \
  > "$REPORT_DIR/dependencies.md"

# Step 3: Dead Code Detection
echo "--- Step 3: Dead Code ---"
claude --print "Find dead code in src/:
1. Exported functions/classes never imported elsewhere in src/
2. Variables assigned but never read
3. Unreachable code after return/throw statements
4. Commented-out code blocks (more than 3 lines)
For each finding, show file:line and the dead code snippet.
Output as a markdown checklist." \
  > "$REPORT_DIR/dead-code.md"

# Step 4: Architecture Overview
echo "--- Step 4: Architecture ---"
claude --print "Generate an architecture overview of this project:
1. Layer diagram (which directories form which layers)
2. Data flow (how requests move through the system)
3. External dependencies (APIs, databases, services)
4. Entry points (main files, route handlers, CLI commands)
Use text-based diagrams with box-drawing characters.
Output as markdown." \
  > "$REPORT_DIR/architecture.md"

# Step 5: Summary
echo "--- Generating Summary ---"
claude --print "Read these analysis reports and create an executive summary:
$(cat "$REPORT_DIR/complexity.md")
$(cat "$REPORT_DIR/dead-code.md")
$(cat "$REPORT_DIR/dependencies.md")

Include:
- Total files analyzed
- Top 3 riskiest modules (by complexity)
- Estimated hours to address critical issues
- Priority action items (numbered list, max 5)
Output as markdown." \
  > "$REPORT_DIR/summary.md"

echo "=== Analysis complete. Reports in: $REPORT_DIR ==="
ls -la "$REPORT_DIR"
```

For TypeScript projects, combine with `madge` for visual dependency graphs:

```bash
# Generate dependency graph data
madge --json src/ > /tmp/deps.json

# Feed to Claude for analysis
claude --print "Analyze this dependency graph JSON and identify:
1. Circular dependency chains (list each cycle)
2. God modules (more than 10 incoming dependencies)
3. Suggested module boundary splits for modules over 500 lines

Dependency data:
$(cat /tmp/deps.json)" > "$REPORT_DIR/dependency-analysis.md"
```

For Python projects, use `radon` metrics as Claude input:

```bash
# Get raw complexity data
radon cc src/ -j > /tmp/complexity.json
radon mi src/ -j > /tmp/maintainability.json

# Claude interprets and prioritizes
claude --print "Given these code metrics:

Cyclomatic Complexity:
$(cat /tmp/complexity.json)

Maintainability Index:
$(cat /tmp/maintainability.json)

Identify the 5 modules most in need of refactoring.
For each, explain why and suggest a specific refactoring approach.
Output as an actionable markdown document." > "$REPORT_DIR/refactoring-plan.md"
```

## Common Issues

- **Analysis takes too long on large codebases:** Scope analysis to specific directories. Use `--print` with file path limits: "Analyze only src/api/ and src/services/, ignore everything else."
- **False positives in dead code detection:** Exported functions may be used by external consumers not in the repo. Add exclusions: "Exclude all functions exported from src/public-api.ts from dead code analysis."
- **Dependency map is too complex to read:** Break it into layers: "Show only dependencies between top-level directories, not individual files."

## Why This Matters

Manual code analysis of a 50,000-line codebase takes days. Claude Code produces equivalent insights in minutes, letting teams prioritize technical debt reduction with data rather than guesswork.



**Build yours →** Create a custom CLAUDE.md with our [Generator Tool](/generator/).

## Related Guides

**Try it:** Estimate your monthly spend with our [Cost Calculator](/calculator/).

- [Claude Code Cyclomatic Complexity Reduction](/claude-code-cyclomatic-complexity-reduction/)
- [Claude Code Embeddings and RAG Workflow 2026](/claude-code-embeddings-rag-workflow-2026/)
- [Claude Code for Code Intelligence Indexing Workflow](/claude-code-for-code-intelligence-indexing-workflow/)


## Frequently Asked Questions

### Do I need a paid Anthropic plan to use this?

Claude Code works with any Anthropic API plan, including the free tier. However, the free tier has lower rate limits (requests per minute and tokens per minute) that may slow down multi-step workflows. For professional use, the Build or Scale plan provides higher limits and priority access during peak hours.

### How does this affect token usage and cost?

The token cost depends on the size of your prompts and Claude's responses. Typical development tasks consume 10K-50K tokens per interaction. Using a CLAUDE.md file and skills reduces exploration tokens by 50-80%, which directly lowers costs. Monitor your usage at console.anthropic.com/settings/billing.

### Can I customize this for my specific project?

Yes. All Claude Code behavior can be customized through CLAUDE.md (project rules), `.claude/settings.json` (permissions), and `.claude/skills/` (domain knowledge). The most impactful customization is adding your project's specific patterns, conventions, and common commands to CLAUDE.md so Claude Code follows your standards from the start.

### What happens when Claude Code makes a mistake?

Claude Code creates files and edits through standard filesystem operations, so all changes are visible in `git diff`. If a change is wrong, revert it with `git checkout -- <file>` for a single file or `git stash` for all changes. Claude Code does not make irreversible changes unless you explicitly allow destructive commands in settings.json.


## Practical Details

When working with Claude Code on this topic, keep these implementation details in mind:

**Project Configuration.** Your CLAUDE.md should include specific references to how your project handles this area. Include file paths, naming conventions, and any project-specific patterns that differ from defaults. Claude Code reads this file at session start and uses it to guide all operations.

**Integration with Existing Tools.** Claude Code works alongside your existing development tools rather than replacing them. It respects .gitignore for file visibility, uses your project's installed dependencies, and follows the build/test scripts defined in package.json (or equivalent). Ensure your toolchain is working correctly before involving Claude Code.

**Performance Considerations.** For large codebases (10,000+ files), Claude Code's file scanning can be slow if not properly scoped. Use `.claudeignore` to exclude generated directories (dist, build, .next, coverage) and dependency directories (node_modules, vendor). This typically reduces scan time by 80-90%.

**Version Control Integration.** All changes Claude Code makes are regular filesystem operations visible to git. Use `git diff` after each significant change to review what was modified. For experimental changes, create a branch first with `git checkout -b experiment/topic` so you can easily discard or keep the results.


<script type="application/ld+json">
{
  "@context": "https://schema.org",
  "@type": "FAQPage",
  "mainEntity": [
    {
      "@type": "Question",
      "name": "Do I need a paid Anthropic plan to use this?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "Claude Code works with any Anthropic API plan, including the free tier. However, the free tier has lower rate limits (requests per minute and tokens per minute) that may slow down multi-step workflows."
      }
    },
    {
      "@type": "Question",
      "name": "How does this affect token usage and cost?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "The token cost depends on the size of your prompts and Claude's responses. Typical development tasks consume 10K-50K tokens per interaction. Using a CLAUDE.md file and skills reduces exploration tokens by 50-80%, which directly lowers costs."
      }
    },
    {
      "@type": "Question",
      "name": "Can I customize this for my specific project?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "Yes. All Claude Code behavior can be customized through CLAUDE.md (project rules), .claude/settings.json (permissions), and .claude/skills/ (domain knowledge). The most impactful customization is adding your project's specific patterns, conventions, and common commands to CLAUDE.md so Claude Code..."
      }
    },
    {
      "@type": "Question",
      "name": "What happens when Claude Code makes a mistake?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "Claude Code creates files and edits through standard filesystem operations, so all changes are visible in git diff. If a change is wrong, revert it with git checkout -- <file> for a single file or git stash for all changes."
      }
    }
  ]
}
</script>
