---
title: "Install Karpathy Skills in Claude Code (2026)"
description: "Install Karpathy's 4-principle CLAUDE.md in under 60 seconds. Step-by-step guide with curl command, verification, and customization tips."
permalink: /how-to-install-karpathy-skills-claude-code-2026/
last_tested: "2026-04-22"
render_with_liquid: false
---

# How to Install Karpathy Skills in Claude Code (2026)

Karpathy Skills is a CLAUDE.md file containing four behavioral principles that improve how Claude reasons during coding sessions. Installation takes under a minute. Here is exactly how to do it.

## Prerequisites

- Claude Code installed and working (`claude --version` returns a version number)
- A project directory where you want the behavioral improvements
- Terminal access (macOS, Linux, or WSL)

## Step 1: Navigate to Your Project

Open your terminal and change to the project root where you want Karpathy Skills active:

```bash
cd /path/to/your/project
```

Karpathy Skills works at the project level. Claude reads the CLAUDE.md file from the current project directory at session start.

## Step 2: Download the CLAUDE.md File

Option A — curl directly from GitHub:

```bash
curl -o CLAUDE.md https://raw.githubusercontent.com/forrestchang/andrej-karpathy-skills/main/CLAUDE.md
```

Option B — clone the repo and copy:

```bash
git clone https://github.com/forrestchang/andrej-karpathy-skills.git /tmp/karpathy-skills
cp /tmp/karpathy-skills/CLAUDE.md ./CLAUDE.md
rm -rf /tmp/karpathy-skills
```

Option C — if you already have a CLAUDE.md, append instead of overwrite:

```bash
echo "" >> CLAUDE.md
echo "# Karpathy Behavioral Principles" >> CLAUDE.md
curl -s https://raw.githubusercontent.com/forrestchang/andrej-karpathy-skills/main/CLAUDE.md >> CLAUDE.md
```

## Step 3: Verify the File

Check that the file exists and contains the four principles:

```bash
head -30 CLAUDE.md
```

You should see the four core principles:
1. Don't Assume
2. Don't Hide Confusion
3. Surface Tradeoffs
4. Goal-Driven Execution

## Step 4: Test With Claude Code

Start a Claude Code session in your project directory:

```bash
claude
```

Give Claude an intentionally ambiguous task to test the principles:

```
Add user authentication to this project
```

With Karpathy Skills active, Claude should ask clarifying questions instead of assuming (e.g., "What authentication method — JWT, sessions, or OAuth?"). If Claude asks questions before coding, the installation is working.

## Step 5: Customize (Optional)

Add your project-specific rules below the Karpathy principles:

```markdown
# Project-Specific Rules
- Use TypeScript strict mode
- Package manager: pnpm
- Test framework: Vitest
- Max function length: 60 lines
```

This gives you behavioral principles from Karpathy plus domain knowledge from your own experience. See the [CLAUDE.md best practices guide](/claude-md-best-practices-10-templates-compared-2026/) for more customization patterns.

## Verification Checklist

- [ ] CLAUDE.md exists in your project root
- [ ] File contains all four Karpathy principles
- [ ] Claude asks clarifying questions for ambiguous tasks
- [ ] Claude mentions tradeoffs when you request a specific approach
- [ ] Claude admits confusion rather than guessing

## Understanding Each Principle in Practice

Knowing what each principle looks like in real sessions helps you verify the install and get the most from it:

**Don't Assume in action**: You say "add a cache layer." Without Karpathy Skills, Claude picks Redis and starts coding. With Karpathy Skills, Claude asks: "What cache backend — Redis, Memcached, or in-memory? What TTL policy? What invalidation strategy?" These questions prevent you from getting code that does not match your architecture.

**Don't Hide Confusion in action**: You reference a function that does not exist in the codebase. Without Karpathy Skills, Claude might silently create a placeholder. With Karpathy Skills, Claude says: "I cannot find `processPayment()` in the codebase. Should I create it, or does it exist under a different name?"

**Surface Tradeoffs in action**: You ask for a quick fix for a performance issue. Claude implements the fix but also notes: "This caching approach trades memory for speed. It will use approximately 200MB of RAM for 10K cached entries. If memory is constrained, consider an LRU cache with a 1K entry limit instead."

**Goal-Driven Execution in action**: You ask Claude to "add error handling to every function." Claude responds: "Adding try-catch to every function would make the code verbose without improving reliability. Instead, I recommend adding error handling at the API boundary layer and letting internal functions throw. This achieves the same goal (preventing unhandled crashes) with less code. Should I proceed with this approach?"

## Measuring the Impact

After installing Karpathy Skills, track these metrics across your next 10 sessions:

- Number of times Claude asks clarifying questions (should increase)
- Number of bugs from incorrect assumptions (should decrease)
- Number of times Claude mentions tradeoffs (should increase)
- Overall code review findings on Claude's output (should decrease)

Most developers report a noticeable difference within the first session. The improvement compounds as you learn to work with a Claude that communicates more openly.

## Troubleshooting

**Claude does not seem to follow the principles**: Make sure the CLAUDE.md is in the project root, not a subdirectory. Claude reads CLAUDE.md from the working directory where you launch the session. Verify by asking Claude: "What behavioral principles are in my CLAUDE.md?"

**Existing CLAUDE.md conflict**: If your project already has a CLAUDE.md, use Option C above to append rather than overwrite. Place Karpathy principles at the top so they take priority. Rules at the top of CLAUDE.md carry more weight.

**Principles feel too strict**: If "Don't Assume" makes Claude ask too many questions for your workflow, you can soften it: change "ask for clarification" to "state your assumption and proceed, but flag it clearly." This gives you the transparency without the interruption.

**Principles ignored after long sessions**: As context windows fill, earlier instructions can get compressed. Run `/compact` periodically to maintain CLAUDE.md influence throughout long sessions.

## Next Steps

- Explore [combining Karpathy Skills with SuperClaude](/how-to-combine-karpathy-superclaude-2026/) for maximum coverage
- Check the [Claude Code best practices](/karpathy-skills-vs-claude-code-best-practices-2026/) for workflow optimization
- Browse the [skills directory](/claude-skills-directory-where-to-find-skills/) for additional behavioral plugins
