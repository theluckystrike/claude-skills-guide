---
title: "How to Use Claude Code: Beginner Guide"
description: "Step-by-step beginner guide to Claude Code. Install, first session, CLAUDE.md setup, commands, workflows, and tips for productive AI-assisted coding."
permalink: /how-to-use-claude-code-beginner-guide/
last_tested: "2026-04-24"
render_with_liquid: false
---

# How to Use Claude Code: Beginner Guide (2026)

Claude Code is a terminal-based AI coding assistant made by Anthropic. You type what you want in plain English, and Claude reads your code, writes new code, runs commands, and makes edits directly in your project. It works in your terminal alongside your existing tools.

This guide takes you from zero to productive. No prior AI coding experience required. Every step includes what to type and what to expect.

## What Claude Code Can Do

Before installing, here is what Claude Code actually does:

- **Read your entire codebase**: Claude sees your files, understands your project structure, and follows your patterns
- **Write and edit code**: Creates new files, edits existing ones, adds features, fixes bugs
- **Run terminal commands**: Executes build scripts, tests, git commands, anything your terminal can do
- **Search across files**: Finds functions, variables, patterns, and references faster than manual searching
- **Debug issues**: Reads error messages, traces problems, and applies fixes
- **Explain code**: Walks through unfamiliar code in plain language

Claude Code is not an IDE plugin. It runs in your terminal as a standalone program. You can use it alongside VS Code, Vim, JetBrains, or any editor.

## Prerequisites

You need three things:

1. **Node.js 18 or later**: Check with `node --version` in your terminal
2. **A terminal**: Terminal.app (Mac), Windows Terminal, iTerm2, or any modern terminal
3. **An Anthropic account**: Either a Pro/Max subscription ($20-$200/month) or an API key

### Which Plan Should You Choose?

- **Pro plan ($20/month)**: Best for getting started. Includes Claude Code access with [usage limits](/claude-5-hour-usage-limit-guide/)
- **API key**: Pay per use. Better for heavy users or teams. See [pricing details](/claude-api-pricing-complete-guide/)
- **Max plan ($100-$200/month)**: Best for full-time use. Higher rate limits. See [plan comparison](/claude-pro-subscription-price-guide/)

## Step 1: Install Claude Code

Open your terminal and run:

```bash
npm install -g @anthropic-ai/claude-code
```

If you use yarn:

```bash
yarn global add @anthropic-ai/claude-code
```

Verify the installation:

```bash
claude --version
```

You should see a version number. If you get "command not found," make sure your global npm bin directory is in your PATH.

### Troubleshooting Installation

**Permission error on Mac/Linux:**
```bash
sudo npm install -g @anthropic-ai/claude-code
```

**npm not found:**
Install Node.js from nodejs.org or use nvm:
```bash
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash
nvm install 22
```

**Windows specific:**
Use Windows Terminal (not cmd.exe). PowerShell works but may need execution policy adjustment:
```powershell
Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy RemoteSigned
```

## Step 2: Authenticate

Run Claude Code for the first time:

```bash
claude
```

It will prompt you to log in. You have two options:

### Option A: Subscription Login (Pro/Max)

1. Claude Code opens a browser window
2. Log in to your Anthropic account
3. Authorize Claude Code
4. Return to your terminal (authentication completes automatically)

### Option B: API Key

Set your API key as an environment variable:

```bash
export ANTHROPIC_API_KEY="sk-ant-your-key-here"
```

Add this line to your shell profile (`~/.zshrc` or `~/.bashrc`) so it persists:

```bash
echo 'export ANTHROPIC_API_KEY="sk-ant-your-key-here"' >> ~/.zshrc
source ~/.zshrc
```

Then start Claude Code:

```bash
claude
```

## Step 3: Your First Session

Navigate to a project directory and start Claude Code:

```bash
cd ~/projects/my-app
claude
```

You will see a prompt where you can type. Try these first commands:

### Understanding Your Project

Type:
```
What does this project do? Give me a high-level overview.
```

Claude reads your files and explains the project structure. It looks at package.json, README files, source code, and configuration to understand the project.

### Making a Simple Change

Type:
```
Add a health check endpoint at GET /health that returns { status: "ok" }
```

Claude will:
1. Find your server file
2. Show you the proposed change
3. Ask for permission to edit the file
4. Apply the change

You will see a permission prompt like:

```
Claude wants to edit src/server.ts
Allow? (y/n)
```

Type `y` to approve. After a few sessions, you can configure auto-approval for trusted operations.

### Running a Command

Type:
```
Run the tests and tell me if anything fails
```

Claude will propose running your test command. You will see:

```
Claude wants to run: npm test
Allow? (y/n)
```

Approve it, and Claude runs the tests, reads the output, and tells you the results.

## Step 4: Understanding Permissions

Claude Code asks for permission before:
- Writing or editing files
- Running shell commands
- Searching the web

The permission prompt shows exactly what Claude wants to do. You always have the choice to:
- **y (yes)**: Allow this specific action
- **n (no)**: Deny this action
- **always**: Always allow this type of action for this session

### Safe Defaults

When starting out, approve each action individually. This teaches you what Claude does for different requests. After you are comfortable, you can allow common operations automatically.

## Step 5: Set Up CLAUDE.md

A CLAUDE.md file tells Claude about your project's specific rules and preferences. Create one in your project root:

```bash
touch CLAUDE.md
```

Add project-specific instructions. Here is a starter template:

```markdown
# Project: My App

## Stack
- Runtime: Node.js 22
- Framework: Express
- Database: PostgreSQL
- Language: TypeScript

## Rules
- Use async/await, never callbacks
- All functions must have TypeScript return types
- Keep functions under 50 lines
- Use descriptive variable names (not abbreviations)
- Always handle errors with try/catch

## Testing
- Run tests with: npm test
- Test framework: Jest
- Every new function needs a test

## File Structure
- src/routes/ - API endpoints
- src/services/ - Business logic
- src/models/ - Database models
- src/utils/ - Helper functions
```

Claude reads this file at the start of every session. It follows these rules automatically. For advanced configuration, see our [CLAUDE.md best practices guide](/claude-md-best-practices-definitive-guide/).

## Step 6: Common Workflows

### Writing New Features

```
Create a user registration endpoint that:
- Accepts email and password
- Validates email format
- Hashes the password with bcrypt
- Stores the user in the database
- Returns the user ID
```

Claude will create the route file, service file, and potentially a test file. It follows your CLAUDE.md rules for code style.

### Fixing Bugs

```
Users are reporting a 500 error when uploading large files.
The error log shows "PayloadTooLargeError".
Find the issue and fix it.
```

Claude searches your codebase for file upload handling, identifies the body parser limit, and fixes it.

### Refactoring

```
The function processOrder in src/services/orders.ts is 200 lines long.
Break it into smaller functions, each under 50 lines.
```

Claude reads the function, identifies logical sections, extracts them into separate functions, updates the call sites, and verifies the refactoring with your tests.

### Adding Tests

```
Write tests for src/services/auth.ts. Cover the happy path
and edge cases: invalid email, weak password, duplicate user.
```

### Understanding Unfamiliar Code

```
I just joined this project. Explain how the authentication flow
works, from login to token verification.
```

Claude traces the code path and explains each step in plain language.

### Git Operations

```
Show me what changed since the last commit, then create a commit
with a clear message.
```

Claude runs `git diff`, analyzes the changes, and creates an appropriate commit.

## Step 7: Essential Commands

Within a Claude Code session, you can use these slash commands:

| Command | What It Does |
|---------|-------------|
| `/help` | Show available commands |
| `/clear` | Clear conversation history |
| `/compact` | Summarize conversation to save context |
| `/model` | Switch between models (Sonnet, Opus, Haiku) |
| `/cost` | Show token usage and costs for this session |
| `/permissions` | View and modify permission settings |

### The /compact Command

As your conversation grows, Claude's context window fills up. When you see messages about approaching context limits, use `/compact`:

```
/compact
```

Claude summarizes the conversation history into a shorter form, freeing context space while retaining key information.

### Switching Models

By default, Claude Code uses Sonnet 4 (fast and capable). For complex tasks, switch to Opus:

```
/model opus
```

For quick, simple tasks, switch to Haiku:

```
/model haiku
```

Switch back when the task is done to save [tokens and cost](/audit-claude-code-token-usage-step-by-step/).

## Understanding the Permission System

Claude Code's permission system protects you from unintended changes. Here is how each permission level works in practice.

### File Read Permissions

Claude reads files freely without asking permission. This is safe because reading does not modify anything. When Claude says "Let me look at your code," it is reading files silently.

### File Write Permissions

Claude asks permission before creating or modifying files:

```
Claude wants to write to src/services/auth.ts
Allow? (y/n/always)
```

Choose "always" to auto-approve all file writes for this session. This is safe if you are using git (you can always revert).

### Bash Command Permissions

Claude asks permission before running any terminal command:

```
Claude wants to run: npm install bcrypt
Allow? (y/n/always)
```

Be cautious with "always" for bash commands. Some commands are destructive. A good practice: approve "always" for safe commands (npm test, npm run lint) but approve individually for others.

### Web Access Permissions

Claude asks before making any web requests:

```
Claude wants to fetch: https://api.github.com/repos/...
Allow? (y/n)
```

### Setting Up Auto-Approve Rules

After you are comfortable with Claude Code, configure auto-approval in `.claude/settings.json`:

```json
{
  "permissions": {
    "allow": [
      "Read",
      "Write",
      "Edit",
      "Glob",
      "Grep"
    ]
  }
}
```

This auto-approves file operations while still requiring approval for bash commands and web access. It is a good balance of convenience and safety.

### The Importance of Git

Always work with git initialized. Before a Claude Code session:

```bash
git status  # Make sure working tree is clean
git stash   # Or commit current changes
```

After a session:

```bash
git diff    # Review all changes
git add -p  # Stage changes selectively
```

If Claude made a mistake, revert specific files:

```bash
git checkout -- src/broken-file.ts
```

## Step 8: Working with Multiple Files

Claude Code handles multi-file operations naturally. Just describe what you want:

```
Create a complete CRUD API for a "products" resource with:
- Route file in src/routes/products.ts
- Service file in src/services/products.ts
- Type definitions in src/types/product.ts
- Tests in tests/products.test.ts
```

Claude creates all four files with consistent types and imports between them.

### Large Codebase Navigation

For large projects, tell Claude where to focus:

```
Look only in the src/billing/ directory. Find where we calculate
tax rates and add support for Canadian provinces.
```

This prevents Claude from searching your entire codebase when you know where the relevant code lives.

## Step 9: Tips for Better Results

### Be Specific

```
# Vague (Claude has to guess)
Make the API faster

# Specific (Claude knows exactly what to do)
Add Redis caching to the GET /users/:id endpoint with a 5-minute TTL
```

### Provide Context

```
# Without context
Fix the login bug

# With context
Users on Safari cannot log in. The error is "SameSite cookie not set".
The login endpoint is in src/routes/auth.ts and uses express-session.
```

### Break Large Tasks into Steps

Instead of:
```
Rebuild the entire authentication system with OAuth, MFA,
password reset, email verification, and rate limiting
```

Do this:
```
Step 1: Add OAuth2 login with Google. Just the basic flow first.
```

Then after that works:
```
Step 2: Add MFA with TOTP (Google Authenticator compatible).
```

### Use CLAUDE.md for Repeated Instructions

If you find yourself telling Claude the same thing every session, add it to CLAUDE.md:

```markdown
## Always
- Run `npm run lint` after editing TypeScript files
- Use named exports, not default exports
- Add JSDoc comments to public functions
```

### Review Before Approving

Read Claude's proposed changes before pressing `y`. Claude is good but not perfect. Look for:
- Correct file paths
- Matching code style
- No hardcoded values that should be environment variables
- No accidental deletions

## Step 10: Next Steps

Once you are comfortable with the basics:

1. **Set up [hooks](/claude-code-hooks-complete-guide/)**: Automate linting, formatting, and testing after Claude edits files
2. **Connect [MCP servers](/claude-code-mcp-server-setup/)**: Give Claude access to your database, GitHub issues, or other tools
3. **Try [spec-driven workflows](/claude-code-spec-workflow-guide/)**: Write specs first, then have Claude implement them
4. **Explore [cost optimization](/best-claude-code-cost-saving-tools-2026/)**: Track and reduce your token spending
5. **Learn [advanced commands](/best-claude-code-commands-you-are-not-using-2026/)**: Power features for experienced users

*Need the complete toolkit? [The Claude Code Playbook](https://zovo.one/pricing) includes 200 production-ready templates.*

## Common Mistakes to Avoid

### Mistake 1: Not Using CLAUDE.md

Without a CLAUDE.md, Claude guesses your preferences. It might use tabs when you use spaces, or CommonJS when you use ESM. Always create a CLAUDE.md.

### Mistake 2: Context Window Overflow

Long sessions accumulate context. When Claude starts forgetting earlier instructions or making mistakes, use `/compact` or start a new session.

### Mistake 3: Never Checking Claude's Work

Claude can introduce subtle bugs. Always run your test suite after changes:

```
Run the tests to verify nothing is broken
```

### Mistake 4: Too-Large Requests

Asking Claude to build an entire application in one prompt leads to errors. Break work into features, each building on the last.

### Mistake 5: Ignoring Cost

If using an API key, long sessions with Opus 4 can cost $10-50+. Check costs with `/cost` regularly. Use Sonnet 4 for most work and Opus 4 only for complex reasoning tasks.

### Mistake 6: Not Reading Error Messages

When Claude encounters errors, it shows you what happened. Read the error messages. They often indicate a simple fix like a missing package or wrong file path.

## Working with Different Project Types

### JavaScript/TypeScript Projects

Claude Code works best with typed languages. For JS/TS projects:

```
# Claude understands package.json, tsconfig.json, and .eslintrc
# It follows your existing patterns automatically

Add a new Express middleware that validates JWT tokens
and attaches the user object to req.user
```

Claude reads your existing middleware, matches the pattern, and generates compatible code.

### Python Projects

```
# Claude understands requirements.txt, pyproject.toml, and setup.py

Add a FastAPI endpoint that accepts CSV file uploads
and returns a summary statistics JSON response
```

Claude uses your existing dependency versions and coding patterns.

### Full-Stack Projects

For projects with separate frontend and backend:

```
Add a "forgot password" feature. This needs:
1. A POST /api/auth/forgot-password endpoint
2. An email sending function using our Resend integration
3. A React form at /forgot-password that calls the endpoint
```

Claude handles cross-cutting features by working in both directories.

### Monorepos

Tell Claude about your monorepo structure in CLAUDE.md:

```markdown
## Monorepo Structure
This is a pnpm workspace monorepo.
- packages/api/ - Express API server
- packages/web/ - Next.js frontend
- packages/shared/ - Shared types and utilities
- packages/email/ - Email templates

When changing shared types, update both api and web packages.
```

## Keyboard Shortcuts

| Shortcut | Action |
|----------|--------|
| `Ctrl+C` | Cancel current Claude response |
| `Ctrl+D` | Exit Claude Code |
| `Up arrow` | Recall previous message |
| `Enter` | Send message |
| `Shift+Enter` | New line in message |
| `Esc` | Cancel current input |

## Getting Help

- **In-session**: Type `/help` for available commands
- **Community resources**: Check the [Claude Code repos on GitHub](/best-claude-code-repos-github-2026/) for examples and templates
- **Error guides**: If you hit specific errors, see our [troubleshooting guides](/claude-not-working-right-now-fix/)
- **Learning paths**: Follow [structured courses](/best-claude-code-courses-tutorials-2026/) for deeper knowledge
- **Feature announcements**: Stay current with [Claude Code news](/anthropic-claude-code-announcements-2026/)

## Frequently Asked Questions

### Do I need to be a programmer to use Claude Code?
Basic terminal knowledge helps (navigating directories, running commands), but you do not need to be an experienced programmer. Claude Code explains what it does at each step.

### Does Claude Code work with any programming language?
Yes. Claude Code supports Python, JavaScript, TypeScript, Go, Rust, Java, C++, Ruby, PHP, Swift, and many more. It is strongest with Python, JavaScript/TypeScript, and Rust.

### Will Claude Code mess up my code?
Claude Code asks for permission before making changes. You can review every edit before approving. Use git so you can always revert. Running `git diff` after a session shows exactly what changed.

### How much does it cost?
With a Pro subscription ($20/month), Claude Code is included with [usage limits](/claude-5-hour-usage-limit-guide/). With an API key, a typical session costs $0.10-$5.00 depending on complexity and model choice.

### Can Claude Code access the internet?
Yes, but only when you approve it. Claude Code can search the web and fetch URLs. It asks for permission before accessing any external resource.

### Does my code get sent to Anthropic?
Yes, code you discuss with Claude is sent to Anthropic's API for processing. Anthropic states they do not train on API/Claude Code data. For sensitive code, review Anthropic's data policies.

### Can multiple people on my team use Claude Code?
Yes. Each person needs their own authentication (subscription or API key). Share a [CLAUDE.md file](/claude-md-best-practices-definitive-guide/) through your git repo so everyone has the same project configuration.

### What is the difference between Claude Code and Claude.ai?
Claude.ai is a web chat interface. Claude Code is a terminal application that can read, write, and execute code in your actual project. Claude Code is built for developers; Claude.ai is for general-purpose conversations.

### Can I use Claude Code in CI/CD pipelines?
Yes. Use `claude --print "your prompt"` for non-interactive mode. This works in [GitHub Actions, Jenkins, and other CI systems](/claude-code-ci-cd-automation-guide/).

### How do I update Claude Code?
```bash
npm update -g @anthropic-ai/claude-code
```

Run this periodically to get new features and bug fixes.

### Can Claude Code work offline?
No. Claude Code requires an internet connection to communicate with Anthropic's API. All processing happens on Anthropic's servers, not locally. Your code is sent to the API for analysis and the response is streamed back.

### What editors work with Claude Code?
Claude Code runs in the terminal independently of your editor. You can use it alongside VS Code, Vim, Neovim, Emacs, JetBrains IDEs, Sublime Text, or any other editor. Changes Claude makes to files appear in your editor when the editor detects file changes on disk. There is also a dedicated VS Code extension that integrates Claude Code directly into the editor interface.


<script type="application/ld+json">
{
  "@context": "https://schema.org",
  "@type": "FAQPage",
  "mainEntity": [
    {
      "@type": "Question",
      "name": "### Do I need to be a programmer to use Claude Code?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "Basic terminal knowledge helps (navigating directories, running commands), but you do not need to be an experienced programmer. Claude Code explains what it does at each step."
      }
    },
    {
      "@type": "Question",
      "name": "Does Claude Code work with any programming language?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "Yes. Claude Code supports Python, JavaScript, TypeScript, Go, Rust, Java, C++, Ruby, PHP, Swift, and many more. It is strongest with Python, JavaScript/TypeScript, and Rust."
      }
    },
    {
      "@type": "Question",
      "name": "Will Claude Code mess up my code?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "Claude Code asks for permission before making changes. You can review every edit before approving. Use git so you can always revert. Running git diff after a session shows exactly what changed."
      }
    },
    {
      "@type": "Question",
      "name": "How much does it cost?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "With a Pro subscription ($20/month), Claude Code is included with usage limits. With an API key, a typical session costs $0.10-$5.00 depending on complexity and model choice."
      }
    },
    {
      "@type": "Question",
      "name": "Can Claude Code access the internet?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "Yes, but only when you approve it. Claude Code can search the web and fetch URLs. It asks for permission before accessing any external resource."
      }
    },
    {
      "@type": "Question",
      "name": "Does my code get sent to Anthropic?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "Yes, code you discuss with Claude is sent to Anthropic's API for processing. Anthropic states they do not train on API/Claude Code data. For sensitive code, review Anthropic's data policies."
      }
    },
    {
      "@type": "Question",
      "name": "Can multiple people on my team use Claude Code?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "Yes. Each person needs their own authentication (subscription or API key). Share a CLAUDE.md file through your git repo so everyone has the same project configuration."
      }
    },
    {
      "@type": "Question",
      "name": "What is the difference between Claude Code and Claude.ai?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "Claude.ai is a web chat interface. Claude Code is a terminal application that can read, write, and execute code in your actual project. Claude Code is built for developers; Claude.ai is for general-purpose conversations."
      }
    },
    {
      "@type": "Question",
      "name": "Can I use Claude Code in CI/CD pipelines?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "Yes. Use claude --print \\\"your prompt\\\" for non-interactive mode. This works in GitHub Actions, Jenkins, and other CI systems."
      }
    },
    {
      "@type": "Question",
      "name": "How do I update Claude Code?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "bash npm update -g @anthropic-ai/claude-code "
      }
    },
    {
      "@type": "Question",
      "name": "Can Claude Code work offline?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "No. Claude Code requires an internet connection to communicate with Anthropic's API. All processing happens on Anthropic's servers, not locally. Your code is sent to the API for analysis and the response is streamed back."
      }
    },
    {
      "@type": "Question",
      "name": "What editors work with Claude Code?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "Claude Code runs in the terminal independently of your editor. You can use it alongside VS Code, Vim, Neovim, Emacs, JetBrains IDEs, Sublime Text, or any other editor. Changes Claude makes to files appear in your editor when the editor detects file changes on disk. There is also a dedicated VS Code extension that integrates Claude Code directly into the editor interface."
      }
    }
  ]
}
</script>

## See Also

- [CLAUDE.md Best Practices Definitive Guide](/claude-md-best-practices-definitive-guide/)
- [Claude Code Statusline Guide](/claude-code-statusline-guide/)
- [Claude Code Hooks Complete Guide](/claude-code-hooks-complete-guide/)

