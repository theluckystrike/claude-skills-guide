---
title: "Claude Code Workspace Trust Blocks Headless — Fix (2026)"
description: "Fix Claude Code workspace trust dialog blocking headless and CI mode. Pre-approve directories with settings.json. Step-by-step solution."
permalink: /claude-code-workspace-trust-blocks-headless-mode-fix/
last_tested: "2026-04-21"
render_with_liquid: false
---

## The Error

```
? Do you trust the files in this workspace?
  This workspace contains a CLAUDE.md file that may modify Claude's behavior.
  [Trust] [Don't Trust] [Cancel]

# In CI/headless:
Error: Interactive prompt required but running in non-interactive mode.
  Cannot display workspace trust dialog.
  Set CLAUDE_CODE_TRUST_WORKSPACE=1 or use --trust flag.
```

## The Fix

1. **Pass the trust flag for headless/CI execution**

```bash
# Single command execution
claude --trust --yes -p "Run the test suite"

# Or set the environment variable
export CLAUDE_CODE_TRUST_WORKSPACE=1
claude -p "Run the test suite"
```

2. **Pre-approve specific directories in settings**

```bash
mkdir -p ~/.claude
cat > ~/.claude/settings.json << 'EOF'
{
  "trustedDirectories": [
    "/home/runner/work",
    "/Users/you/projects"
  ],
  "permissions": {
    "allow": ["Bash", "Read", "Write", "Edit"]
  }
}
EOF
```

3. **Verify the fix:**

```bash
CLAUDE_CODE_TRUST_WORKSPACE=1 claude --version
# Expected: Version prints without trust prompt
```

## Why This Happens

Claude Code's workspace trust system is a security feature that prevents untrusted `CLAUDE.md` files from automatically modifying Claude's behavior. When you open a project for the first time, or in a CI pipeline where there's no persistent trust state, Claude Code prompts for confirmation. In headless mode (piped input, CI runners, Docker containers), there's no TTY to display the prompt, so the process errors out. This is intentional — it prevents supply-chain attacks via malicious `CLAUDE.md` files in cloned repositories.

## If That Doesn't Work

- **Alternative 1:** In GitHub Actions, add the trust env var to your workflow: `env: { CLAUDE_CODE_TRUST_WORKSPACE: "1" }`
- **Alternative 2:** Remove the `CLAUDE.md` from the workspace if you don't need it: `mv CLAUDE.md CLAUDE.md.disabled`
- **Check:** Run `cat ~/.claude/settings.json` to see if your trusted directories list includes the current workspace path

## Prevention

Add to your `CLAUDE.md`:
```markdown
In CI, always pass --trust --yes flags or set CLAUDE_CODE_TRUST_WORKSPACE=1. Add working directories to trustedDirectories in ~/.claude/settings.json for persistent trust.
```

**Related articles:** [Workspace Trust Required Fix](/claude-code-workspace-trust-required-fix-2026/), [GitHub Actions Setup](/claude-code-github-actions-setup-guide/), [Config File Location](/claude-code-config-file-location/)
