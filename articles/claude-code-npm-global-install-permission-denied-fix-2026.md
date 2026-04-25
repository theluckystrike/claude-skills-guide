---
title: "npm Global Install Permission Denied"
permalink: /claude-code-npm-global-install-permission-denied-fix-2026/
description: "Claude Code guide: npm Global Install Permission Denied — practical setup steps, configuration examples, and working code you can use in your projects..."
last_tested: "2026-04-22"
---

## The Error

```
npm ERR! Error: EACCES: permission denied, mkdir '/usr/local/lib/node_modules/@anthropic-ai'
npm ERR! code EACCES
npm ERR! syscall mkdir
npm ERR! path /usr/local/lib/node_modules/@anthropic-ai/claude-code
```

This error occurs when running `npm install -g @anthropic-ai/claude-code` without sufficient permissions to write to the global node_modules directory.

## The Fix

1. The best fix is to use nvm (Node Version Manager) which installs to your home directory:

```bash
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.0/install.sh | bash
source ~/.zshrc
nvm install 22
nvm use 22
npm install -g @anthropic-ai/claude-code
```

2. Alternatively, change npm's default directory:

```bash
mkdir -p ~/.npm-global
npm config set prefix '~/.npm-global'
echo 'export PATH=~/.npm-global/bin:$PATH' >> ~/.zshrc
source ~/.zshrc
npm install -g @anthropic-ai/claude-code
```

3. Verify the installation:

```bash
which claude
claude --version
```

## Why This Happens

On macOS and Linux, the default npm global prefix is `/usr/local` which is owned by root. Running `npm install -g` tries to write there without permission. Using `sudo npm install -g` is dangerous because it creates root-owned files in your project and can break future installs. The correct fix is to change where npm installs global packages.

## If That Doesn't Work

- If nvm is already installed but still failing, ensure you are using the nvm-managed node:

```bash
nvm which current
which npm
```

- Fix ownership of the npm cache:

```bash
sudo chown -R $(whoami) ~/.npm
```

- On macOS, if Homebrew manages node, use Homebrew instead:

```bash
brew install node
npm install -g @anthropic-ai/claude-code
```

## Prevention

Add this to your `CLAUDE.md`:

```markdown
# Node.js Setup
- Use nvm for Node.js version management. Never use sudo with npm.
- Minimum Node version: 18. Recommended: 22 LTS.
- Global npm prefix should be in home directory, not /usr/local.
```

## See Also

- [EACCES Permission Denied Config Dir — Fix (2026)](/claude-code-config-dir-permission-denied-fix-2026/)
- [Claude Code EACCES Permission Denied Global Install — Fix (2026)](/claude-code-eacces-permission-denied-npm-global-install-fix/)


## Common Issues

**Claude Code ignores the configuration:** Ensure the configuration file is in the correct location. CLAUDE.md must be in the project root (the directory where you run `claude`). Settings go in `.claude/settings.json`. Verify with `ls -la CLAUDE.md .claude/settings.json`.

**Changes are not taking effect:** Claude Code reads CLAUDE.md at the start of each session. If you modify it during a session, the changes apply to new conversations but not the current one. Start a new session to pick up configuration changes.

**Slow performance on large projects:** Add a `.claudeignore` file to exclude large directories (node_modules, .git, dist, build, vendor). This reduces file scanning time and prevents Claude from reading irrelevant files. The format is identical to `.gitignore`.

**Unexpected file modifications:** Check `.claude/settings.json` for overly broad permission patterns. Narrow the allow list to specific commands and file patterns. For sensitive directories, add explicit deny rules.


## Best Practices

1. **Start with a clear CLAUDE.md.** Describe your project structure, tech stack, coding conventions, and common commands in under 300 words. This single file has the largest impact on Claude Code's accuracy and efficiency.

2. **Use skills for domain knowledge.** Move detailed reference information (API routes, database schemas, deployment procedures) into `.claude/skills/` files. This keeps CLAUDE.md concise while making specialized knowledge available when needed.

3. **Review changes before committing.** Always run `git diff` after Claude Code makes changes. Verify the edits are correct, match your project style, and do not introduce unintended side effects. This habit prevents compounding errors across sessions.

4. **Set up permission guardrails.** Configure `.claude/settings.json` with explicit allow and deny lists. Allow your standard development commands (test, build, lint) and deny destructive operations (rm -rf, git push --force, database drops).

5. **Keep sessions focused.** Give Claude Code one clear task per prompt. Multi-step requests like "refactor auth, add tests, and update docs" produce better results when broken into three separate prompts, each building on the previous result.


## Frequently Asked Questions

### What is the minimum setup required?

You need Claude Code installed (Node.js 18+), a project with a `CLAUDE.md` file, and the relevant toolchain for your project type (e.g., npm for JavaScript, pip for Python). The CLAUDE.md file should describe your project structure, conventions, and common commands so Claude Code can work effectively.

### How long does the initial setup take?

For a typical project, initial setup takes 10-20 minutes. This includes creating the CLAUDE.md file, configuring `.claude/settings.json` for permissions, and running a test task to verify everything works. Subsequent sessions start immediately because the configuration persists.

### Can I use this with a team?

Yes. Commit your `.claude/` directory and `CLAUDE.md` to version control so the entire team uses the same configuration. Each developer can add personal preferences in `~/.claude/settings.json` (user-level) without affecting the project configuration. Review CLAUDE.md changes in pull requests like any other configuration file.

### What if Claude Code produces incorrect output?

First check that your CLAUDE.md accurately describes your project conventions. Incorrect or outdated context is the most common cause of wrong output. If the output is still wrong, provide feedback in the same session — Claude Code learns from corrections within a conversation. For persistent issues, add explicit rules to CLAUDE.md (e.g., "Always use single quotes" or "Never modify files in the config/ directory").


## Related Guides

- [Claude Code Project vs Global Settings](/claude-code-project-vs-global-settings-token-impact/)
- [Claude Code Skill Permission Denied](/claude-code-skill-permission-denied-error-fix-2026/)
- [Claude Code Permission Denied Shell](/claude-code-permission-denied-shell-commands-fix/)
- [Claude Code Permission Denied](/claude-code-permission-denied-when-executing-skill-commands/)

<script type="application/ld+json">
{
  "@context": "https://schema.org",
  "@type": "FAQPage",
  "mainEntity": [
    {
      "@type": "Question",
      "name": "What is the minimum setup required?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "You need Claude Code installed (Node.js 18+), a project with a `CLAUDE.md` file, and the relevant toolchain for your project type (e.g., npm for JavaScript, pip for Python). The CLAUDE.md file should describe your project structure, conventions, and common commands so Claude Code can work effectively."
      }
    },
    {
      "@type": "Question",
      "name": "How long does the initial setup take?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "For a typical project, initial setup takes 10-20 minutes. This includes creating the CLAUDE.md file, configuring `.claude/settings.json` for permissions, and running a test task to verify everything works. Subsequent sessions start immediately because the configuration persists."
      }
    },
    {
      "@type": "Question",
      "name": "Can I use this with a team?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "Yes. Commit your `.claude/` directory and `CLAUDE.md` to version control so the entire team uses the same configuration. Each developer can add personal preferences in `~/.claude/settings.json` (user-level) without affecting the project configuration. Review CLAUDE.md changes in pull requests like any other configuration file."
      }
    },
    {
      "@type": "Question",
      "name": "What if Claude Code produces incorrect output?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "First check that your CLAUDE.md accurately describes your project conventions. Incorrect or outdated context is the most common cause of wrong output. If the output is still wrong, provide feedback in the same session — Claude Code learns from corrections within a conversation. For persistent issues, add explicit rules to CLAUDE.md (e.g., \"Always use single quotes\" or \"Never modify files in the config/ directory\"). - [Claude Code Project vs Global Settings](/claude-code-project-vs-global-settings-token-impact/) - [Claude Code Skill Permission Denied](/claude-code-skill-permission-denied-error-fix-2026/) - [Claude Code Permission Denied Shell](/claude-code-permission-denied-shell-commands-fix/) - [Claude Code Permission Denied](/claude-code-permission-denied-when-executing-skill-commands/)"
      }
    }
  ]
}
</script>
