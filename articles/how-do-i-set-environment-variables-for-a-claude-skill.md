---
layout: default
title: "How Do I Set Environment Variables (2026)"
description: "A practical guide to configuring environment variables for Claude Code skills. Learn how to set up API keys, credentials, and custom configurations for ..."
date: 2026-03-14
last_modified_at: 2026-04-17
author: "Claude Skills Guide"
reviewed: true
score: 8
categories: [tutorials]
tags: [claude-code, claude-skills]
permalink: /how-do-i-set-environment-variables-for-a-claude-skill/
geo_optimized: true
---
[Claude Code skills are powerful extensions](/best-claude-code-skills-to-install-first-2026/) in your AI sessions. Whether you're using the pdf skill for document processing, the tdd skill for test-driven development, or the supermemory skill for knowledge management, understanding how to configure environment variables is essential for getting the most out of these tools.

This guide walks you through every method of setting environment variables for Claude skills, from basic shell exports to project-scoped overrides. You'll find practical examples for the most commonly used skills, a comparison table of configuration approaches, and actionable security recommendations.

## How Claude Skills Access Environment Variables

Before diving into configuration, it's worth understanding the mechanism. Claude Code runs inside your terminal session, which means it inherits the full environment of your shell process. When a skill instruction tells Claude to "run a shell command" or "call this API using the key from your environment," Claude passes that request to the underlying shell via its tool-calling mechanism.

This means that anything exported in your shell before you start Claude Code is visible inside any skill invocation. Skills themselves are Markdown files, they contain instructions to Claude, not executable scripts. The environment variable access happens when Claude executes a bash command as part of following those skill instructions.

[Claude skills are stored as Markdown files](/claude-skill-md-format-complete-specification-guide/) in `~/.claude/skills/`. Each skill lives in its own subdirectory or as a standalone `.md` file. When you invoke a skill using its slash command, Claude reads the file and applies the instructions to your session.

Environment variables for skills can be set in several ways:

1. System-wide environment variables that Claude inherits from your shell
2. Skill-specific configuration files that the skill reads at runtime
3. Claude Code configuration in `~/.claude/settings.json`
4. Project-level `.env` files for per-project credential isolation
5. direnv for directory-scoped automatic variable loading

The method you choose depends on whether the variable should be global, per-project, or isolated entirely from your regular shell.

## Setting System-Wide Environment Variables

The simplest approach is to set environment variables in your shell configuration file. This works for any skill that reads from standard environment variables like `OPENAI_API_KEY`, `ANTHROPIC_API_KEY`, or custom variables you define.

For Zsh Users (macOS Default)

Edit your `~/.zshrc` file:

```bash
AI service keys used by Claude skills
export OPENAI_API_KEY="sk-your-key-here"
export ANTHROPIC_API_KEY="sk-ant-your-key-here"

Skill-specific keys
export SUPERMEMORY_API_KEY="your-supermemory-key"
export PDF_SERVICE_API_KEY="your-pdf-service-key"

Path overrides
export CLAUDE_OUTPUT_DIR="$HOME/Documents/claude-outputs"
export CLAUDE_TEMPLATE_DIR="$HOME/.claude/templates"
```

## For Bash Users

Edit your `~/.bashrc` or `~/.bash_profile`:

```bash
export OPENAI_API_KEY="sk-your-key-here"
export ANTHROPIC_API_KEY="sk-ant-your-key-here"
export SUPERMEMORY_API_KEY="your-supermemory-key"
```

After editing, apply the changes immediately:

```bash
source ~/.zshrc # for zsh
source ~/.bashrc # for bash
```

Then verify the variable loaded correctly before launching Claude Code:

```bash
echo $OPENAI_API_KEY
Should print your key (or at least confirm it's non-empty)
```

These variables are now available to any skill that runs in your terminal session. The pdf skill, for example, uses `PDF_SERVICE_API_KEY` when calling external document processing APIs. The supermemory skill reads `SUPERMEMORY_API_KEY` to authenticate with your knowledge base.

## For Fish Shell Users

If you use Fish shell, the syntax differs because Fish does not source traditional shell scripts:

```fish
In ~/.config/fish/config.fish
set -x OPENAI_API_KEY "sk-your-key-here"
set -x ANTHROPIC_API_KEY "sk-ant-your-key-here"
set -x SUPERMEMORY_API_KEY "your-supermemory-key"
```

Or use `fish_add_path` and `set -U` for universal variables that persist across sessions:

```fish
set -Ux ANTHROPIC_API_KEY "sk-ant-your-key-here"
```

## Skill-Specific Configuration Files

Many skills come with their own configuration mechanism. The [supermemory skill, for instance, often requires a configuration file](/building-stateful-agents-with-claude-skills-guide/) to connect to your personal knowledge base. Skill-specific config files offer more granular control and avoid polluting your global shell environment with skill-only settings.

## Configuring the Supermemory Skill

The supermemory skill typically stores configuration in `~/.claude/skills/supermemory/config.json` or reads from a `.env` file in the skill directory:

```json
{
 "apiKey": "your-supermemory-api-key",
 "vectorStore": "chroma",
 "collectionName": "claude-notes",
 "embeddingModel": "text-embedding-3-small",
 "retrievalLimit": 10,
 "host": "http://localhost:7933"
}
```

Some skills also support `.env` file syntax, which is useful if you're used to the dotenv pattern from Node.js projects:

```
SUPERMEMORY_API_KEY=your-key-here
SUPERMEMORY_HOST=http://localhost:7933
SUPERMEMORY_INDEX_NAME=my-knowledge-base
SUPERMEMORY_RETRIEVAL_LIMIT=10
```

Create the skill directory and config file in one step:

```bash
mkdir -p ~/.claude/skills/supermemory
cat > ~/.claude/skills/supermemory/.env << 'EOF'
SUPERMEMORY_API_KEY=your-key-here
SUPERMEMORY_HOST=http://localhost:7933
SUPERMEMORY_INDEX_NAME=my-knowledge-base
EOF
```

Skill-specific files give you the ability to maintain different configurations for different contexts, for example, a development supermemory instance at localhost and a production instance at a remote host, without juggling multiple global environment exports.

## Using Claude Code Settings for Skill Configuration

[Claude Code allows you to set environment variables through its settings system](/claude-code-permissions-model-security-guide-2026/). Edit `~/.claude/settings.json` to make variables available specifically to Claude without exporting them to your entire shell session:

```json
{
 "env": {
 "CLAUDE_SKILL_PDF_KEY": "your-pdf-service-key",
 "CLAUDE_SKILL_TDD_TEMPLATE_PATH": "/Users/yourname/claude-templates/tdd",
 "CLAUDE_SKILL_FRONTEND_FRAMEWORK": "react",
 "CLAUDE_SKILL_DEFAULT_LANG": "typescript",
 "CLAUDE_OUTPUT_DIR": "/Users/yourname/Documents/claude-outputs"
 },
 "allowedDirectories": ["/Users/yourname/projects"]
}
```

This approach is valuable for two reasons. First, the variables only exist within Claude's execution context, they won't appear in subshells spawned by other programs. Second, `settings.json` allows you to version-control your Claude setup without exposing keys (since you'd exclude the actual key values but keep the structure).

For project-specific overrides, Claude Code also reads from a local `.claude/settings.json` in your project directory. This means you can have different skill configurations per project:

```
~/projects/
 my-react-app/
 .claude/
 settings.json ← project-specific (FRONTEND_FRAMEWORK=react)
 my-vue-app/
 .claude/
 settings.json ← project-specific (FRONTEND_FRAMEWORK=vue)
~/.claude/
 settings.json ← global fallback
```

Local project settings override global settings, so `my-react-app` and `my-vue-app` can each have the correct framework configured without you changing global state.

## Project-Level .env File Support

For teams using `.env` files as part of their existing workflow, Claude skills can read from a `.env` file in your project root if the skill is designed to do so, or if you load the file manually before starting Claude:

```bash
Load project .env before starting Claude Code
source .env && claude
```

Or use a helper function in your shell config:

```bash
Add to ~/.zshrc
claude-project() {
 if [ -f .env ]; then
 set -a
 source .env
 set +a
 echo "Loaded .env for Claude session"
 fi
 claude "$@"
}
```

Now you can type `claude-project` in any directory and it will automatically source the local `.env` before starting.

## Using direnv for Automatic Per-Directory Loading

`direnv` is a shell extension that automatically loads and unloads environment variables when you enter or leave a directory. It works with zsh, bash, and fish, and is particularly useful if you work across multiple projects with different API credentials.

Install direnv:

```bash
brew install direnv # macOS
apt install direnv # Ubuntu/Debian
```

Add the hook to your shell config:

```bash
~/.zshrc
eval "$(direnv hook zsh)"

~/.bashrc
eval "$(direnv hook bash)"
```

Create a `.envrc` in your project root:

```bash
/Users/yourname/projects/my-project/.envrc
export OPENAI_API_KEY="sk-project-specific-key"
export PDF_API_KEY="project-pdf-key"
export TDD_FRAMEWORK="jest"
export FRONTEND_DEFAULT_FRAMEWORK="nextjs"
```

Authorize the file once:

```bash
direnv allow .
```

Now every time you `cd` into `my-project`, those variables are automatically loaded. When you leave the directory, they're unloaded. When you start Claude Code from inside that directory, it inherits the correct credentials automatically, no manual sourcing required.

## Configuration Method Comparison

| Method | Scope | Persists Across Sessions | Requires Restart | Best For |
|---|---|---|---|---|
| `~/.zshrc` / `~/.bashrc` | Global | Yes | Shell restart | Keys used by all projects |
| `~/.claude/settings.json` | Claude-only | Yes | Claude restart | Claude-specific settings |
| Project `.claude/settings.json` | Per-project | Yes | Claude restart | Per-project overrides |
| Skill `.env` file | Per-skill | Yes | No | Skill-specific credentials |
| direnv `.envrc` | Per-directory | Yes | No (auto) | Multi-project key isolation |
| `source .env && claude` | Session-only | No | Each session | Quick one-off overrides |

For most individual developers, the combination of `~/.zshrc` for global keys and `~/.claude/settings.json` for Claude-specific settings covers 90% of use cases.

## Practical Examples by Skill

## PDF Skill Configuration

The pdf skill often requires API keys for services like pdf.co, CloudConvert, or similar tools. Set the appropriate variables:

```bash
~/.zshrc
export PDF_API_KEY="your-pdf-service-key"
export PDF_OUTPUT_DIR="/Users/yourname/Documents/claude-outputs"
export PDF_DEFAULT_QUALITY="high"
export PDF_WATERMARK="false"
```

Or in `~/.claude/settings.json` to keep them Claude-isolated:

```json
{
 "env": {
 "PDF_API_KEY": "your-pdf-service-key",
 "PDF_OUTPUT_DIR": "/Users/yourname/Documents/claude-outputs",
 "PDF_DEFAULT_QUALITY": "high"
 }
}
```

When you invoke the skill with `/pdf`, it accesses these variables to process documents and save outputs to the correct location without prompting you for credentials each time.

## TDD Skill Configuration

The tdd skill works with your testing framework of choice. Configure the framework and template paths so the skill generates tests in the correct format:

```bash
export TDD_FRAMEWORK="jest"
export TDD_TEST_DIR="__tests__"
export TDD_TEMPLATE_PATH="/Users/yourname/.claude/templates/tdd"
export TDD_COVERAGE_THRESHOLD="80"
export TDD_MOCK_STYLE="jest.fn"
```

Create a base template at `~/.claude/templates/tdd/unit-test-template.js`:

```javascript
describe('ModuleName', () => {
 let instance;

 beforeEach(() => {
 instance = new ModuleName();
 });

 afterEach(() => {
 jest.clearAllMocks();
 });

 describe('methodName', () => {
 it('should return expected value for valid input', () => {
 const result = instance.methodName('input');
 expect(result).toBe('expected');
 });

 it('should throw for invalid input', () => {
 expect(() => instance.methodName(null)).toThrow(TypeError);
 });
 });
});
```

The tdd skill reads `TDD_FRAMEWORK` and `TDD_TEMPLATE_PATH` to generate tests in the correct format, placed in the correct directory.

## Frontend-Design Skill Configuration

The frontend-design skill uses environment variables to set default frameworks, styling preferences, and output directories:

```bash
export FRONTEND_DEFAULT_FRAMEWORK="nextjs"
export FRONTEND_DEFAULT_STYLING="tailwind"
export FRONTEND_OUTPUT_DIR="/Users/yourname/projects"
export FRONTEND_COMPONENT_LIB="shadcn-ui"
export FRONTEND_DEFAULT_LANG="typescript"
export FRONTEND_ICON_SET="lucide-react"
```

For a team project where everyone should use the same stack, put these in a project `.envrc` file with direnv and commit the `.envrc` to the repository (but not secrets).

## Supermemory Skill Configuration

The supermemory skill requires specific configuration to connect to your knowledge base. It supports both environment variables and a structured config file:

```bash
export SUPERMEMORY_API_KEY="your-api-key"
export SUPERMEMORY_COLLECTION="claude-code-notes"
export SUPERMEMORY_HOST="http://localhost:7933"
export SUPERMEMORY_RETRIEVAL_LIMIT="15"
```

Or create the skill configuration at `~/.claude/skills/supermemory/config.yaml`:

```yaml
api_key: your-api-key
host: http://localhost:7933
collection: claude-code-notes
retrieval_limit: 15
embedding_model: text-embedding-3-small
auto_save: true
```

The YAML format is easier to read and edit compared to JSON, and the supermemory skill accepts both depending on your version.

## Commit-Message Skill Configuration

If you use a skill for standardized commit messages, environment variables let you define your team's convention once:

```bash
export COMMIT_STYLE="conventional" # or "gitmoji", "custom"
export COMMIT_SCOPE_REQUIRED="false"
export COMMIT_MAX_LENGTH="72"
export COMMIT_TICKET_PREFIX="PROJ"
export COMMIT_BRANCH_PATTERN="feature|fix|chore|docs"
```

This means every developer on your team can use the same `/commit` skill invocation and get outputs that match your repository's conventions automatically.

## Security Considerations

API keys in shell configuration files are stored in plaintext, which is acceptable for personal development machines but requires care on shared systems or in containerized environments.

Never commit API keys to version control. Add exclusions to `.gitignore`:

```
.gitignore
.env
.env.local
.env.*.local
.envrc
~/.claude/skills/*/config.json
~/.claude/skills/*/.env
```

Scope permissions as narrowly as possible. If a skill only needs read access to an API, don't use a key with write or admin permissions. Create dedicated API keys for Claude skill use.

Rotate keys periodically. Skills with stale credentials may stop working without warning. A quarterly review of your skill configurations catches expired or revoked keys before they cause disruption.

For team environments, consider using a secrets manager like HashiCorp Vault, AWS Secrets Manager, or 1Password CLI rather than hardcoding keys in shell profiles:

```bash
Load secrets from 1Password CLI before starting Claude
export OPENAI_API_KEY=$(op item get "OpenAI API Key" --fields credential)
claude
```

File permissions matter. Restrict read access on config files that contain secrets:

```bash
chmod 600 ~/.claude/skills/supermemory/.env
chmod 600 ~/.claude/settings.json
```

This prevents other users on a shared machine from reading your credentials.

## Troubleshooting

If your skill isn't recognizing environment variables, work through these checks in order:

1. Verify the variable exists: Run `echo $VARIABLE_NAME` in your terminal. An empty result means the variable was never set or the shell config wasn't sourced.

2. Check the variable name exactly: Skills reference specific variable names. A typo like `SUPERMEMOERY_API_KEY` silently fails. Copy the expected variable name from the skill documentation.

3. Source your shell config: After editing `~/.zshrc`, run `source ~/.zshrc` in the same terminal. Opening a new terminal tab also works, since new tabs source the config automatically.

4. Restart Claude Code: New variables exported to your shell are visible to Claude Code after a restart. If Claude is currently running, exit and reopen it.

5. Use absolute paths: For `TDD_TEMPLATE_PATH` and similar path variables, use full paths (`/Users/yourname/...`) rather than tilde shortcuts (`~/...`). Some skill execution contexts don't expand tildes.

6. Check Claude Code settings.json syntax: If you're using `~/.claude/settings.json`, validate the JSON is well-formed. A syntax error in that file prevents Claude from loading any settings:

```bash
python3 -m json.tool ~/.claude/settings.json
Prints the parsed JSON if valid, or an error if malformed
```

7. Check skill-specific config files: If the skill reads from `~/.claude/skills/skillname/config.json`, ensure that file exists and has the correct keys. The skill documentation will list expected field names.

You can also run a quick environment dump from within a Claude session to verify what variables are available:

```bash
Ask Claude to run this during your session
env | grep -E "(OPENAI|ANTHROPIC|PDF|TDD|SUPERMEMORY|FRONTEND)"
```

This prints only the relevant environment variables and confirms Claude can see them.

## Summary

Setting environment variables for Claude skills involves five main approaches: shell configuration files for global access, `~/.claude/settings.json` for Claude-isolated settings, project-level settings files for per-project overrides, skill-specific config files for per-skill credentials, and direnv for automatic directory-scoped loading.

| Configuration Goal | Recommended Approach |
|---|---|
| Keys used across all projects | `~/.zshrc` or `~/.bashrc` export |
| Settings only Claude should see | `~/.claude/settings.json` env block |
| Per-project framework/style settings | Project `.claude/settings.json` |
| Skill-specific API credentials | Skill `.env` or `config.json` file |
| Auto-load per directory on `cd` | direnv `.envrc` |
| Team-shared non-secret settings | Committed `.envrc` (no secrets) |

For most skills like pdf, tdd, frontend-design, and supermemory, you'll set variables in your shell profile for credentials and optionally create skill-specific configuration files for more granular control. Remember to keep [sensitive keys secure](/getting-started-hub/) and review them periodically. With proper configuration, your Claude skills will have access to the APIs, paths, and settings they need to function effectively across every project in your development workflow.

---


**Try it:** Paste your error into our [Error Diagnostic](/diagnose/) for an instant fix.
---

<div class="mastery-cta">

This site was built by 5 autonomous agents running in tmux while I was in Bali. 2,500 articles. Zero manual work. 100% quality gate pass rate.

The orchestration configs, sprint templates, and quality gates that made that possible are in the Zovo Lifetime bundle. Along with 16 CLAUDE.md templates and 80 tested prompts.

**[See how the pipeline works →](https://zovo.one/lifetime?utm_source=ccg&utm_medium=cta-skills&utm_campaign=how-do-i-set-environment-variables-for-a-claude-skill)**

$99 once. I'm a solo dev in Da Nang. This is how I scale.

</div>

Related Reading


- [Configuration Reference](/configuration/). Complete Claude Code settings and configuration guide
- [How to Create a Private Claude Skill Not on GitHub](/how-do-i-create-a-private-claude-skill-not-on-github/). Keep skills and their credentials local without GitHub exposure
- [Claude Code Permissions Model and Security Guide 2026](/claude-code-permissions-model-security-guide-2026/). Understand security boundaries when exposing environment variables to skills
- [Claude Code Secret Scanning: Prevent Credential Leaks Guide](/claude-code-secret-scanning-prevent-credential-leaks-guide/). Ensure API keys and secrets in skills don't leak accidentally
- [Claude Skills Hub](/getting-started-hub/). Explore essential skill configuration and setup patterns

Built by theluckystrike. More at [zovo.one](https://zovo.one)



