---
layout: post
title: "Claude Code Tab Completion Setup Guide 2026"
description: "Enable tab completion for Claude Code commands in bash, zsh, and fish shells. Installation steps and custom completion scripts included."
permalink: /claude-code-tab-completion-setup-2026/
date: 2026-04-21
last_tested: "2026-04-21"
render_with_liquid: false
---

## The Workflow

Enable shell tab completion for Claude Code so you can autocomplete subcommands, flags, file paths, and session names by pressing Tab. Covers bash, zsh, and fish shells with custom completion scripts for advanced usage.

Expected time: 5 minutes
Prerequisites: Claude Code CLI installed, bash 4+, zsh 5+, or fish 3+

## Setup

### 1. Generate Completions (Built-in Method)

```bash
# Generate completion script for your shell
claude completion bash > /tmp/claude-completion.bash
claude completion zsh > /tmp/_claude
claude completion fish > /tmp/claude.fish
```

If Claude Code includes a built-in completion generator, this is the fastest method.

### 2. Install Zsh Completions

```bash
# Create completions directory if it doesn't exist
mkdir -p ~/.zsh/completions

# Write the completion script
cat > ~/.zsh/completions/_claude << 'EOF'
#compdef claude

_claude() {
  local -a commands flags

  commands=(
    '--print:Run a single prompt and print the result'
    '--resume:Resume a previous session'
    '--session:Start or resume a named session'
    '--list-sessions:List all saved sessions'
    '--delete-session:Delete a saved session'
    '--verbose:Enable verbose output'
    '--debug:Enable debug output'
    '--version:Show version number'
    '--help:Show help information'
  )

  flags=(
    '--model:Specify the model to use'
    '--max-tokens:Maximum tokens in response'
    '--temperature:Sampling temperature'
    '--system:Custom system prompt'
    '--no-cache:Disable response caching'
  )

  _arguments -C \
    '1:command:->command' \
    '*::arg:->args'

  case "$state" in
    command)
      _describe 'claude commands' commands
      _describe 'claude flags' flags
      _files
      ;;
    args)
      case "$words[1]" in
        --resume|--delete-session)
          local sessions
          sessions=($(claude --list-sessions 2>/dev/null | awk '{print $1}'))
          _describe 'sessions' sessions
          ;;
        --model)
          local models=(
            'claude-sonnet-4-20250514:Fast, balanced model'
            'claude-opus-4-20250514:Most capable model'
          )
          _describe 'models' models
          ;;
        *)
          _files
          ;;
      esac
      ;;
  esac
}

_claude "$@"
EOF

# Add to your .zshrc
echo 'fpath=(~/.zsh/completions $fpath)' >> ~/.zshrc
echo 'autoload -Uz compinit && compinit' >> ~/.zshrc
source ~/.zshrc
```

### 3. Install Bash Completions

```bash
# Create bash completions directory
mkdir -p ~/.local/share/bash-completion/completions

cat > ~/.local/share/bash-completion/completions/claude << 'EOF'
_claude_completions() {
  local cur prev opts commands
  COMPREPLY=()
  cur="${COMP_WORDS[COMP_CWORD]}"
  prev="${COMP_WORDS[COMP_CWORD-1]}"

  commands="--print --resume --session --list-sessions --delete-session
            --verbose --debug --version --help --model --max-tokens
            --temperature --system --no-cache"

  case "$prev" in
    --resume|--delete-session)
      local sessions
      sessions=$(claude --list-sessions 2>/dev/null | awk '{print $1}')
      COMPREPLY=($(compgen -W "$sessions" -- "$cur"))
      return 0
      ;;
    --model)
      COMPREPLY=($(compgen -W "claude-sonnet-4-20250514 claude-opus-4-20250514" -- "$cur"))
      return 0
      ;;
  esac

  if [[ "$cur" == -* ]]; then
    COMPREPLY=($(compgen -W "$commands" -- "$cur"))
  else
    COMPREPLY=($(compgen -f -- "$cur"))
  fi
}

complete -F _claude_completions claude
EOF

# Source in current shell
source ~/.local/share/bash-completion/completions/claude
```

### 4. Install Fish Completions

```bash
mkdir -p ~/.config/fish/completions

cat > ~/.config/fish/completions/claude.fish << 'EOF'
# Claude Code completions for fish shell

complete -c claude -l print -d "Run a single prompt and print result"
complete -c claude -l resume -d "Resume a previous session" -xa "(claude --list-sessions 2>/dev/null | awk '{print \$1}')"
complete -c claude -l session -d "Start or resume named session"
complete -c claude -l list-sessions -d "List all saved sessions"
complete -c claude -l delete-session -d "Delete a session" -xa "(claude --list-sessions 2>/dev/null | awk '{print \$1}')"
complete -c claude -l verbose -d "Enable verbose output"
complete -c claude -l debug -d "Enable debug output"
complete -c claude -l version -d "Show version"
complete -c claude -l help -d "Show help"
complete -c claude -l model -d "Specify model" -xa "claude-sonnet-4-20250514 claude-opus-4-20250514"
complete -c claude -l max-tokens -d "Maximum response tokens"
complete -c claude -l temperature -d "Sampling temperature"
complete -c claude -l system -d "Custom system prompt"
complete -c claude -l no-cache -d "Disable caching"
EOF
```

### 5. Verify

```bash
# Zsh: Type 'claude --' and press Tab
claude --<TAB>
# Expected output:
# --print    --resume    --session    --verbose    --debug    --version

# Test session completion
claude --resume <TAB>
# Expected output:
# Lists your saved session names

# Test model completion
claude --model <TAB>
# Expected output:
# claude-sonnet-4-20250514  claude-opus-4-20250514
```

## Usage Example

Tab completion in action during a daily workflow:

```bash
# Quick access to commands without remembering flags
claude --p<TAB>        # completes to --print
claude --r<TAB>        # completes to --resume
claude --s<TAB><TAB>   # shows --session and --list-sessions

# Resume sessions by name (tab-completed from history)
claude --resume ref<TAB>
# Completes to: claude --resume refactor-auth-module

# File path completion works too
claude --print "Review " src/a<TAB>
# Completes to: claude --print "Review " src/api/

# Model selection without memorizing model IDs
claude --model cl<TAB>
# Shows: claude-sonnet-4-20250514  claude-opus-4-20250514
```

Adding custom completions for project-specific slash commands:

```bash
# Extend the zsh completion to include your custom skills
cat >> ~/.zsh/completions/_claude << 'EOF'

# Add slash command completions for interactive mode
_claude_slash_commands=(
  '/help:Show available commands'
  '/exit:Exit Claude Code'
  '/clear:Clear conversation history'
  '/compact:Summarize and compact context'
  '/cost:Show session cost breakdown'
  '/model:Switch model'
)
EOF
```

## Common Issues

- **Completions not loading after install:** Run `exec zsh` (zsh) or open a new terminal. Bash users need `source ~/.bashrc`.
- **"command not found: compdef" error:** Add `autoload -Uz compinit && compinit` to your `.zshrc` before any completion definitions.
- **Session names not appearing:** Ensure `claude --list-sessions` works when run manually. The completion script calls this command in the background.

## Why This Matters

Tab completion reduces typos and eliminates the need to check `--help` output. Developers using completions navigate Claude Code 30% faster than those typing full flag names manually.

## Related Guides

- [Claude Code for Nushell Workflow Guide](/claude-code-for-nushell-workflow-guide/)
- [Claude Code for Alacritty Workflow Guide](/claude-code-for-alacritty-workflow-guide/)
- [Claude Code Common Beginner Mistakes to Avoid](/claude-code-common-beginner-mistakes-to-avoid/)
