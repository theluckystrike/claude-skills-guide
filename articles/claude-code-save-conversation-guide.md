---
title: "Save Claude Code Conversations: Full Guide (2026)"
description: "How Claude Code saves conversations automatically, where sessions are stored, how to resume them, export chat history, and manage your session data."
permalink: /claude-code-save-conversation-guide/
last_tested: "2026-04-24"
render_with_liquid: false
---

# Save Claude Code Conversations: Full Guide (2026)

Claude Code automatically saves every conversation. You do not need to do anything special to preserve your work — sessions are written to disk as they happen. This guide covers where conversations are stored, how to find and resume them, how to export session data, and how to manage your conversation history.

## Where Claude Code Saves Conversations Automatically

Every Claude Code conversation is saved to your local filesystem in a project-specific directory structure.

### Storage Location

```
~/.claude/projects/<project-hash>/
```

The `<project-hash>` is a deterministic hash of your project's absolute path. Each project you work on gets its own directory, so conversations for different codebases are kept separate.

Inside each project directory, you will find:
- **Session files** — JSONL format (one JSON object per line)
- **Session metadata** — timestamps, model used, session identifiers
- **Tool call records** — every file read, edit, bash command, and search Claude performed

### File Format: JSONL

Conversations are stored in JSONL (JSON Lines) format. Each line is a self-contained JSON object representing a single event in the conversation:

```json
{"type":"user","message":"Read the package.json file","timestamp":"2026-04-24T10:30:00Z"}
{"type":"assistant","message":"I'll read the package.json file for you.","timestamp":"2026-04-24T10:30:01Z"}
{"type":"tool_use","tool":"Read","input":{"file_path":"/Users/you/project/package.json"},"timestamp":"2026-04-24T10:30:01Z"}
{"type":"tool_result","output":"...file contents...","timestamp":"2026-04-24T10:30:02Z"}
```

This format is efficient for append-only writes (Claude Code adds lines as the conversation progresses) and easy to parse with standard tools.

## How to Find Past Conversations

### Resume the Last Conversation

The fastest way to get back to a previous conversation:

```bash
claude --resume
```

This reopens the most recent conversation for the current project directory. All previous context is loaded, and you can continue where you left off.

### Continue the Most Recent Session

```bash
claude --continue
```

Similar to `--resume`, this continues the most recent session. The difference is subtle — `--continue` picks up the latest session and sends a new message in one step:

```bash
claude --continue "Now implement the tests we discussed"
```

### Resume a Specific Session

If you have multiple sessions, use the session ID:

```bash
claude --session-id abc123
```

Session IDs are assigned automatically. You can find them by browsing the session files or by checking the output when Claude Code starts (the session ID is displayed in the startup banner).

### Name Sessions for Easy Retrieval

You can assign a human-readable name to a session when starting it:

```bash
claude --session-id "refactor-auth-module"
```

Later, resume by that exact name:

```bash
claude --session-id "refactor-auth-module" --resume
```

This is especially useful when working on multiple features within the same project.

## Exporting Conversations

### Read JSONL Files Directly

The raw conversation data is accessible in the JSONL files. You can extract and format it with standard command-line tools.

**List all sessions for the current project:**

```bash
ls ~/.claude/projects/*/
```

**Extract just the message text from a session:**

```bash
cat ~/.claude/projects/<project-hash>/session.jsonl | python3 -c "
import sys, json
for line in sys.stdin:
    obj = json.loads(line)
    if obj.get('type') in ('user', 'assistant'):
        role = obj['type'].upper()
        msg = obj.get('message', '')
        print(f'{role}: {msg}\n')
"
```

**Extract with jq:**

```bash
cat session.jsonl | jq -r 'select(.type == "user" or .type == "assistant") | "\(.type | ascii_upcase): \(.message)"'
```

### Copy Terminal Output

The simplest export method: select and copy text directly from your terminal emulator. Most terminal emulators support:

- **macOS Terminal / iTerm2:** `Cmd + A` to select all, then `Cmd + C` to copy
- **Windows Terminal:** Select with mouse, right-click to copy
- **tmux:** Enter copy mode with `Ctrl + B` then `[`, navigate and select

### Use the `script` Command for Recording

To record an entire Claude Code session to a file, use the Unix `script` command:

```bash
script -q claude-session-$(date +%Y%m%d).txt claude
```

This starts Claude Code inside a `script` session that captures all terminal output to the specified file. When you exit Claude Code, the recording stops automatically.

On macOS, the `-q` flag suppresses the "Script started" message. On Linux, use `-q` or `--quiet`.

### Using ccusage for Session Analysis

The `ccusage` tool provides structured analysis of Claude Code sessions:

```bash
npx ccusage
```

This shows token counts, costs, and session summaries across your Claude Code usage history. It reads from the same JSONL files that Claude Code produces.

## Conversation Session Management

### Sessions Persist Across Terminal Restarts

Closing your terminal does not delete your session. The conversation is already saved to disk. Open a new terminal, navigate to the same project directory, and use `--resume` to pick up where you left off.

### Context Compaction

As conversations grow long, Claude Code automatically compacts older context to fit within the model's token limit. This process:

1. Summarizes older messages into a condensed representation
2. Preserves recent messages in full detail
3. Keeps critical context (file paths, decisions, code changes)
4. Drops verbose intermediate outputs (long file contents, repetitive tool results)

You can trigger manual compaction:

```
/compact
```

This immediately summarizes the current conversation and frees up context space. The full original conversation remains in the JSONL file on disk — compaction only affects what is sent to the model.

### Session ID Management

Every session gets an auto-generated ID. You can see the current session ID in the Claude Code startup output. Using custom session IDs helps organize your work:

```bash
# Feature work
claude --session-id "feature-payment-flow"

# Bug investigation
claude --session-id "debug-memory-leak"

# Code review
claude --session-id "review-pr-247"
```

Each named session maintains its own independent conversation history.

### Cleaning Up Old Sessions

Session files accumulate over time. To clean up:

```bash
# See how much space sessions use
du -sh ~/.claude/projects/

# Remove sessions older than 30 days
find ~/.claude/projects/ -name "*.jsonl" -mtime +30 -delete
```

Be cautious — deleted session files cannot be recovered.

## Sharing Conversations

### No Built-in Share Feature

Claude Code does not currently have a one-click share button or URL-based sharing. To share conversations with teammates, use one of these approaches.

### Copy and Paste

The most straightforward method. Copy the relevant portion of terminal output and paste it into a Slack message, GitHub issue, or document.

### Export to Markdown

Convert a session to readable Markdown:

```bash
cat session.jsonl | python3 -c "
import sys, json
for line in sys.stdin:
    obj = json.loads(line)
    t = obj.get('type', '')
    if t == 'user':
        print(f\"## User\n\n{obj.get('message', '')}\n\")
    elif t == 'assistant':
        print(f\"## Claude\n\n{obj.get('message', '')}\n\")
" > conversation.md
```

### Record a Session for Sharing

Use `script` to record a session that you can share as a text file:

```bash
script -q session-recording.txt claude
# ... have your conversation ...
# exit Claude Code
# session-recording.txt now contains the full session
```

### Git-Based Sharing

For team settings, the `.claude/settings.json` file (project-level configuration) can be committed to version control, but conversation JSONL files should not be — they may contain sensitive data and are not designed for version control.

## Storage and Privacy

### What Is Stored Locally

- Full message history (your inputs and Claude's responses)
- All tool calls and their results (file reads, edits, bash commands)
- Session metadata (timestamps, model, session ID)
- Compaction summaries

### What Is Not Stored Locally

- API keys or authentication tokens (stored separately)
- Model weights or capabilities
- Other users' conversations

### Encryption

Session files are stored as plain text JSONL. They are not encrypted at rest. If your project contains sensitive data (credentials, proprietary code), be aware that the conversation files may contain references to or excerpts from that data.

For sensitive projects, consider:
- Periodically cleaning up old sessions
- Ensuring your home directory has appropriate permissions
- Using full-disk encryption on your machine

## Frequently Asked Questions

### Can I search across all past conversations?

Yes, using standard text search tools on the JSONL files:

```bash
grep -r "search term" ~/.claude/projects/
```

This searches across all projects and sessions.

### Do conversations sync across devices?

No. Conversations are stored locally on each machine. There is no built-in cloud sync for Claude Code session data.

### How much disk space do conversations use?

A typical 30-minute session produces 100 KB to 2 MB of JSONL data, depending on how many files were read and how verbose the responses were. Over months of daily use, this can grow to several hundred megabytes.

### Can I import a conversation into a new session?

Not directly. You can start a new session and paste relevant context from a previous conversation, or use `--resume` to continue an existing session.

### What happens to conversations when I update Claude Code?

Session files are preserved across Claude Code updates. The storage format is stable, and new versions can read sessions created by older versions.

### Does `/compact` delete information permanently?

No. Compaction summarizes context that is sent to the model, but the original JSONL file on disk retains the full conversation. You lose nothing from compaction — it only affects the current session's working memory.

## Related Guides

- [The Claude Code Playbook](/the-claude-code-playbook/) — comprehensive workflow reference
- [Claude Code Best Practices](/claude-code-claude-md-best-practices/) — optimize your setup
- [Claude Code Configuration Hierarchy](/claude-code-configuration-hierarchy-explained-2026/) — understand settings files
- [Claude Shortcuts Guide](/claude-shortcuts-complete-guide/) — keyboard shortcuts for all Claude interfaces
- [Claude Code Token Usage Optimization](/claude-code-token-usage-optimization-best-practices-guide/) — manage context window efficiently
- [Claude Code Security Best Practices](/claude-code-security-best-practices-2026/) — secure your workflow
- [Claude Code Getting Started](/claude-code-getting-started-terminal-setup/) — initial CLI setup
- [Claude Code Git Workflow Best Practices](/claude-code-git-workflow-best-practices-guide/) — version control integration
- [Claude Temperature Settings](/claude-temperature-settings-guide/) — control output behavior
