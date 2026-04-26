---
layout: default
title: "Best Claude Code Skills for Token (2026)"
description: "Ranked list of Claude Code skills that reduce token usage, from commit automation saving 5K tokens per use to code review skills cutting PR review costs 40%."
permalink: /best-claude-code-skills-token-reduction-2026-ranked/
date: 2026-04-22
last_tested: "2026-04-22"
---

# Best Claude Code Skills for Token Reduction (2026 Ranked)

## What It Does

Claude Code skills are reusable instruction sets (stored as markdown files in `.claude/skills/`) that pre-load context and procedures for specific tasks. A well-crafted skill eliminates discovery overhead, reduces prompt length, and standardizes agent behavior -- each of which directly reduces token usage. The best skills save 3,000-15,000 tokens per invocation compared to ad-hoc prompting.

## Installation / Setup

Skills are markdown files placed in the `.claude/skills/` directory of a project or in `~/.claude/skills/` for global availability.

```bash
# Create the skills directory
mkdir -p .claude/skills

# Create a skill file
cat > .claude/skills/commit.md << 'SKILL'
# Commit Skill
When asked to commit:
1. Run `git diff --staged --stat` to see what is staged
2. If nothing staged, run `git add -p` for selective staging
3. Write a conventional commit message (type: description)
4. Keep message under 72 characters
5. Do not run git push unless explicitly asked
SKILL
```

## Configuration for Cost Optimization

Skills reduce tokens through three mechanisms: eliminating discovery (no need to figure out project conventions), constraining output (specific format requirements), and preventing waste (explicit "do not" rules).

```yaml
# .claude/skills/review.md -- code review skill (~200 tokens loaded)
# Replaces: 3-5 discovery prompts averaging 1,500 tokens each

# Code Review Skill
When reviewing code:
1. Read only the changed files (use git diff, not full files)
2. Check for: type safety, error handling, test coverage, naming
3. Output format: file:line -- issue -- severity (high/medium/low)
4. Maximum 10 findings per review (prioritize by severity)
5. Do not suggest style changes covered by the linter
6. Do not read files that were not changed in the PR
```

## Usage Examples

### Basic Usage

```bash
# Invoke a skill by name
claude /review

# Or reference it in a prompt
claude "Using the review skill, check the staged changes"
```

### Advanced: Cost-Saving Pattern

Stack multiple skills for complex workflows to pre-load all necessary context in a single skill load rather than multiple discovery cycles.

```yaml
# .claude/skills/feature.md -- feature implementation skill
# Saves: ~8,000 tokens per feature task (eliminates discovery + constrains output)

# Feature Implementation Skill
When implementing a new feature:

## Discovery Phase (use Haiku)
1. Read the relevant route file and its corresponding service file
2. Check for existing patterns in adjacent files (read only the first 30 lines of 2 similar files)

## Implementation Phase (use Sonnet)
3. Create/modify the service function first
4. Update the route handler second
5. Add Zod validation schema third

## Validation Phase
6. Run `pnpm test <relevant-test-file>` with output capped at 30 lines
7. Run `pnpm lint <changed-files>` in quiet mode

## Output Rules
- Do not explain the implementation unless asked
- Do not suggest follow-up tasks
- Do not modify files outside the feature's module
```

## Token Usage Measurements

Measured token savings for each skill type, comparing skill-guided execution versus ad-hoc prompting:

| Skill Type | Tokens Without Skill | Tokens With Skill | Savings |
|-----------|---------------------|-------------------|---------|
| Commit | 8,000-12,000 | 3,000-5,000 | 5,000-7,000 (58%) |
| Code review | 30,000-80,000 | 18,000-45,000 | 12,000-35,000 (40%) |
| Feature implementation | 50,000-120,000 | 30,000-70,000 | 20,000-50,000 (42%) |
| Bug fix | 20,000-100,000 | 15,000-60,000 | 5,000-40,000 (35%) |
| Test writing | 15,000-40,000 | 10,000-25,000 | 5,000-15,000 (38%) |
| Refactoring | 40,000-80,000 | 25,000-50,000 | 15,000-30,000 (38%) |

### Ranked by Token Savings (per month, daily use)

1. **Code review skill** -- saves 12K-35K tokens per review. At 5 reviews/week on Opus: **$9-$26/month**.
2. **Feature implementation skill** -- saves 20K-50K tokens per feature. At 3 features/week: **$9-$23/month**.
3. **Refactoring skill** -- saves 15K-30K tokens per refactor. At 2 refactors/week: **$4.50-$9/month**.
4. **Bug fix skill** -- saves 5K-40K tokens per fix. At 5 fixes/week: **$3.75-$30/month**.
5. **Test writing skill** -- saves 5K-15K tokens per test suite. At 3 suites/week: **$2.25-$6.75/month**.
6. **Commit skill** -- saves 5K-7K tokens per commit. At 10 commits/week: **$7.50-$10.50/month**.

## Comparison with Alternatives

| Approach | Setup Time | Token Savings | Reusability |
|----------|-----------|---------------|-------------|
| Skills (.claude/skills/) | 10-30 min | 35-58% per task | Project-wide, team-shared |
| CLAUDE.md rules | 5-10 min | 20-40% per task | Project-wide |
| Detailed prompts | 1-2 min per prompt | 10-30% per interaction | Single-use |
| No optimization | 0 | 0% | N/A |

Skills outperform CLAUDE.md rules for task-specific optimization because they load only when invoked, keeping the base CLAUDE.md lean. They outperform detailed prompts because they are reusable and team-shareable.

## Troubleshooting

**Skill not loading** -- Verify the file is in `.claude/skills/` with a `.md` extension. Check that the filename matches what is being invoked. Skills are case-sensitive.

**Skill rules being ignored after compaction** -- If a skill's context is compacted away, re-invoke the skill. Add critical rules to CLAUDE.md instead, which is re-loaded after compaction.

**Token savings not materializing** -- Measure before and after with `/cost`. If savings are under 20%, the skill may be too broad. Narrow the skill scope to specific, repeatable tasks rather than general guidance.



**Which model? →** Take the 5-question quiz in our [Model Selector](/model-selector/).

## Related Guides

**Try it:** Paste your error into our [Error Diagnostic](/diagnose/) for an instant fix.

- [Claude Code Skills Guide](/skills/) -- complete skills authoring and management guide
- [Scoping Skills Narrowly: Why One Broad Skill Wastes Tokens](/scoping-skills-narrowly-broad-skill-wastes-tokens/) -- the case for narrow, focused skills
- [CLAUDE.md as Cost Control](/claude-md-cost-control-rules-prevent-token-waste/) -- when to use CLAUDE.md vs skills
