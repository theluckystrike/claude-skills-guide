---
title: "Claude Code Custom Slash Command Not"
description: "Fix Claude Code custom slash command not recognized error. Place command files in the correct .claude/commands/ directory. Step-by-step solution."
permalink: /claude-code-custom-slash-command-not-recognized-fix/
last_tested: "2026-04-21"
render_with_liquid: false
---

## The Error

```
Unknown command: /my-review
  Available commands: /help, /clear, /compact, /cost, /mcp, ...

# Or:
Error: Slash command "my-review" not found.
  Searched in:
    - /Users/you/projects/myapp/.claude/commands/
    - /Users/you/.claude/commands/

# Or:
Error: Failed to parse slash command file "my-review.md"
  Invalid frontmatter or missing template
```

## The Fix

1. **Create the command file in the correct directory**

```bash
# Project-level commands (available in this project only)
mkdir -p .claude/commands

# Create a slash command
cat > .claude/commands/my-review.md << 'EOF'
Review the code changes in the current git diff. Focus on:
1. Security issues (SQL injection, XSS, auth bypass)
2. Performance problems (N+1 queries, missing indexes)
3. Error handling gaps

Run `git diff --staged` to see the changes, then provide a structured review.
EOF
```

2. **For global commands available in all projects**

```bash
mkdir -p ~/.claude/commands

cat > ~/.claude/commands/test-and-fix.md << 'EOF'
Run the project's test suite. If any tests fail:
1. Read the failing test file
2. Read the implementation file
3. Fix the implementation (not the test)
4. Run the test again to verify
EOF
```

3. **Verify the fix:**

```bash
# List available commands inside Claude Code
ls .claude/commands/ ~/.claude/commands/ 2>/dev/null
# Expected: my-review.md (and any other command files)

# Test it in Claude Code:
claude -p "/my-review" --trust --yes
# Expected: Claude executes the review command
```

## Why This Happens

Custom slash commands are markdown files placed in `.claude/commands/` (project-level) or `~/.claude/commands/` (global). The filename without extension becomes the command name. Common reasons for "not recognized": wrong directory path (`.claude/` vs `claude/`), file extension mismatch (must be `.md`), file placed at the wrong level in the directory hierarchy, or Claude Code started before the command file was created (requires restart to detect new commands).

## If That Doesn't Work

- **Alternative 1:** Restart Claude Code after adding new commands — it only scans for commands at startup
- **Alternative 2:** Use the full path syntax: `/project:my-review` for project commands or `/user:test-and-fix` for user commands
- **Check:** Run `find . -name "*.md" -path "*/.claude/commands/*"` to locate all command files and verify their paths

## Prevention

Add to your `CLAUDE.md`:
```markdown
Store project slash commands in .claude/commands/ as .md files. Global commands go in ~/.claude/commands/. Restart Claude Code after adding new commands. Use descriptive filenames — the filename becomes the command name.
```

**Related articles:** [Claude Code Config File Location](/claude-code-config-file-location/), [Claude Code Debugging Skill](/claude-code-debugging-skill/), [Troubleshooting Hub](/troubleshooting-hub/)

## See Also

- [Create Custom Slash Commands for Claude (2026)](/how-to-create-custom-slash-command-claude-2026/)
