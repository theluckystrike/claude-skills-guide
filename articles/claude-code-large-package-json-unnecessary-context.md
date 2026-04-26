---
layout: default
title: "Claude Code and large package.json (2026)"
description: "A large package.json costs Claude Code 2,000-8,000 tokens when read unnecessarily. Prevent automatic loading and create a lean dependency summary instead."
permalink: /claude-code-large-package-json-unnecessary-context/
date: 2026-04-22
last_tested: "2026-04-22"
---

# Claude Code and large package.json -- unnecessary context loading

## The Problem

Claude Code reads `package.json` early in most Node.js sessions to understand the project. In large projects, `package.json` can exceed 200 lines with 50-150 dependencies, scripts, configuration blocks, and metadata. Reading the full file costs 2,000-8,000 tokens, and those tokens persist in the conversation history for every subsequent turn. Over a 20-turn session, this single file read compounds to 40,000-160,000 tokens of unnecessary input. At Sonnet 4.6 rates ($3/$15 per MTok), a bloated package.json costs $0.12-$0.48 per session in context overhead.

## Quick Fix (2 Minutes)

1. **Add a project summary to CLAUDE.md** so Claude does not need to read package.json for basic project info:
   ```markdown
   ## Project
   - Runtime: Node.js 20, TypeScript 5.4
   - Package manager: pnpm
   - Build: `pnpm build`
   - Test: `pnpm test`
   - Lint: `pnpm lint`
   - Framework: Next.js 15 + Express API
   ```

2. **Add CLAUDE.md instruction** to avoid reading the full file:
   ```markdown
   ## File Reading Rules
   - Do NOT read package.json unless specifically needed for dependency changes
   - Project scripts are listed above -- use those instead of reading package.json
   ```

## Why This Happens

Claude Code reads package.json for three reasons:

1. **Script discovery**: Finding available npm scripts (build, test, dev, lint). This is the most common and most easily eliminated reason.

2. **Dependency checking**: Determining which packages are installed before suggesting imports or APIs. Legitimate use, but rarely needs the full file.

3. **Project type detection**: Understanding the project framework (Next.js, Express, React) from dependencies. Only needs the first few dependency names.

The problem scales with project size:

| Project Size | package.json Lines | Estimated Tokens | Session Cost Impact |
|-------------|-------------------|-----------------|-------------------|
| Small (10 deps) | 30-50 | 500-800 | $0.01-$0.02 |
| Medium (40 deps) | 80-120 | 1,500-2,500 | $0.05-$0.08 |
| Large (100 deps) | 200-400 | 3,000-6,000 | $0.09-$0.18 |
| Monorepo root | 300-600 | 5,000-8,000 | $0.15-$0.24 |

The session cost impact accounts for the tokens being re-sent as input on every subsequent turn (20-turn session multiplier).

## The Full Fix

### Step 1: Diagnose

Check how large the package.json actually is:

```bash
# Word count (rough token estimate)
wc -w package.json
# Example: 450 words ≈ 600 tokens (just the file, multiply by turns for session impact)

# Line count
wc -l package.json
# Example: 180 lines

# Count dependencies
grep -c '"' package.json | head -1
# Or more precisely:
node -e "const p = require('./package.json'); console.log('deps:', Object.keys(p.dependencies||{}).length, 'devDeps:', Object.keys(p.devDependencies||{}).length)"
```

### Step 2: Fix

Create a lean dependency summary as a skill:

```bash
#!/bin/bash
# scripts/generate-dep-summary.sh
set -euo pipefail

OUTPUT=".claude/skills/dependencies.md"
mkdir -p .claude/skills

cat > "$OUTPUT" << 'HEADER'
# Project Dependencies Summary
HEADER

# Extract key info from package.json (bounded: max 50 deps shown)
node -e "
const pkg = require('./package.json');
const deps = Object.keys(pkg.dependencies || {}).sort();
const devDeps = Object.keys(pkg.devDependencies || {}).sort();
const scripts = Object.entries(pkg.scripts || {});

console.log('## Scripts');
scripts.slice(0, 20).forEach(([k, v]) => console.log('- \`pnpm ' + k + '\`: ' + v));

console.log('\n## Key Dependencies (' + deps.length + ' total)');
deps.slice(0, 30).forEach(d => console.log('- ' + d));
if (deps.length > 30) console.log('- ... and ' + (deps.length - 30) + ' more');

console.log('\n## Dev Dependencies (' + devDeps.length + ' total)');
devDeps.slice(0, 20).forEach(d => console.log('- ' + d));
if (devDeps.length > 20) console.log('- ... and ' + (devDeps.length - 20) + ' more');
" >> "$OUTPUT"

WORDS=$(wc -w < "$OUTPUT" | tr -d ' ')
echo "Generated dependency summary: $WORDS words (~$((WORDS * 100 / 75)) tokens)"
```

```bash
chmod +x scripts/generate-dep-summary.sh
./scripts/generate-dep-summary.sh
```

This produces a ~300-token summary versus a 3,000-8,000 token full file read.

### Step 3: Prevent

Add explicit rules to CLAUDE.md:

```markdown
# CLAUDE.md

## Package Management
- Scripts: see above (Build, Test, Lint sections)
- Dependencies: see dependencies skill for summary
- Do NOT read package.json for script discovery (they are listed in this file)
- Read package.json ONLY when: adding/removing dependencies, updating versions
- NEVER read pnpm-lock.yaml or package-lock.json (these are enormous and useless for context)
```

Also add lock files to .claudeignore:

```gitignore
# .claudeignore
pnpm-lock.yaml
package-lock.json
yarn.lock
```

This prevents accidental lock file reads. A `pnpm-lock.yaml` can be 20,000-100,000 lines, which would consume the entire context window.

### The Lock File Trap

Even more dangerous than package.json is the lock file. A `pnpm-lock.yaml` in a medium project spans 10,000-50,000 lines. If Claude Code attempts to read it (even partially with a `head` command), the result floods the context window:

```bash
# This command in Claude Code would inject thousands of tokens:
# head -500 pnpm-lock.yaml
# Output: ~2,000 tokens of dependency resolution data that is useless for any task

# The .claudeignore file prevents this entirely:
# pnpm-lock.yaml
# package-lock.json
# yarn.lock
```

Without `.claudeignore`, a single accidental lock file read can consume 5,000-20,000 tokens -- the equivalent of 3-12 useful file reads wasted on dependency hashes.

### The node_modules Trap

Similarly, if Claude Code searches inside `node_modules/` (possible with Glob or Grep patterns), it can return hundreds of matches from dependency source files, each of which might trigger a follow-up Read call:

```bash
# A Grep for "createServer" without path scoping might search node_modules
# and return 50+ matches from Express, HTTP, test frameworks, etc.
# Each match adds to the context, and Claude may Read several to understand them.
# Prevention: .claudeignore with node_modules/ entry
```

### Alternative: Use Package Manager Commands

When Claude Code genuinely needs dependency information, package manager commands are cheaper than reading the full package.json:

```bash
# Check if a specific package is installed (cheaper than reading package.json)
pnpm list express
# Output: express@4.18.2 (3 lines, ~50 tokens)

# Check all peer dependency warnings
pnpm install --dry-run 2>&1 | head -20
# Targeted output instead of full file read
```

These commands return focused, small outputs instead of the 200-line package.json.

## Cost Recovery

The tokens from past sessions are already spent. Prevention saves:

- **Per session**: 2,000-8,000 tokens in direct reads + 40,000-160,000 tokens in conversation compounding
- **Monthly (100 sessions)**: $12-$48 on Sonnet 4.6
- **Team of 5**: $60-$240/month

The fix takes 5 minutes (CLAUDE.md rules + .claudeignore). ROI is immediate.

## Prevention Rules for CLAUDE.md

```markdown
## File Reading Restrictions
- package.json: do NOT read unless modifying dependencies
- pnpm-lock.yaml / package-lock.json: NEVER read (in .claudeignore)
- node_modules/: NEVER read (in .claudeignore)
- Project scripts and dependencies are summarized in this file and skills
- When checking if a package is installed: use `pnpm list <package>` instead of reading package.json
```

### Extending to Other Large Configuration Files

The same principle applies to other configuration files that Claude Code might read unnecessarily:

- **tsconfig.json** (~200-500 tokens): Only relevant when modifying TypeScript configuration. Add build commands to CLAUDE.md instead.
- **.eslintrc.json** (~300-800 tokens): Only relevant when changing lint rules. Reference existing lint rules in CLAUDE.md.
- **docker-compose.yml** (~200-600 tokens): Only relevant when modifying services. Document service names and ports in CLAUDE.md.
- **Makefile** (~200-1,000 tokens): Only relevant when adding new make targets. List key targets in CLAUDE.md.

For each large configuration file, ask: "Does Claude Code need to read this file for the current task, or would a 2-line summary in CLAUDE.md suffice?" The answer is usually the summary.

## Related Guides

**Try it:** Paste your error into our [Error Diagnostic](/diagnose/) for an instant fix.

- [Claude Code for Large Codebases: Cost-Effective Strategies](/claude-code-large-codebases-cost-effective-strategies/) -- broader large-project optimization
- [Claude Code Caching Strategies: Don't Re-Discover What You Already Know](/claude-code-caching-strategies-dont-rediscover/) -- cache project knowledge
- [Claude Code Context Window Management](/claude-code-context-window-management-2026/) -- prevent context bloat from large files

## See Also

- [Large File Committed Exceeds GitHub Limit Fix](/claude-code-large-file-committed-github-limit-fix-2026/)
- [Large File Read Memory Spike Fix](/claude-code-large-file-read-memory-spike-fix-2026/)
- [Stop Claude Code Adding Extra Dependencies (2026)](/claude-code-adds-unnecessary-dependencies-fix-2026/)
