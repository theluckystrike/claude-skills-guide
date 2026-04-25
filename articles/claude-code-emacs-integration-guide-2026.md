---
layout: post
title: "Claude Code + Emacs Integration Guide"
description: "Integrate Claude Code with Emacs using shell-mode, vterm, and custom elisp. Includes keybindings, context passing, and workflow automation."
permalink: /claude-code-emacs-integration-guide-2026/
date: 2026-04-21
last_tested: "2026-04-21"
---

## The Workflow

Set up Claude Code as an integrated development companion within GNU Emacs. Use vterm for interactive sessions, shell-mode for quick queries, and custom elisp functions for context-aware prompting directly from your buffers.

Expected time: 20 minutes
Prerequisites: Emacs 29+, vterm package, Claude Code CLI installed, Node.js 18+

## Setup

### 1. Install Required Emacs Packages

```elisp
;; In your init.el or .emacs
(use-package vterm
  :ensure t
  :config
  (setq vterm-max-scrollback 100000)
  (setq vterm-shell "/bin/zsh"))

(use-package vterm-toggle
  :ensure t
  :bind (("C-c t" . vterm-toggle)
         ("C-c T" . vterm-toggle-cd)))
```

Vterm provides a full terminal emulator inside Emacs, which Claude Code requires for interactive mode.

### 2. Create Claude Code Elisp Functions

```elisp
;; ~/.emacs.d/lisp/claude-code.el

(defgroup claude-code nil
  "Claude Code integration for Emacs."
  :group 'tools)

(defvar claude-code-buffer-name "*claude-code*"
  "Name of the Claude Code vterm buffer.")

(defun claude-code-start ()
  "Start an interactive Claude Code session in vterm."
  (interactive)
  (let ((buf (get-buffer claude-code-buffer-name)))
    (if (and buf (buffer-live-p buf))
        (switch-to-buffer-other-window buf)
      (let ((vterm-shell "claude"))
        (vterm claude-code-buffer-name)))))

(defun claude-code-send-region (start end)
  "Send the selected region to Claude Code with a prompt."
  (interactive "r")
  (let* ((code (buffer-substring-no-properties start end))
         (file-name (buffer-file-name))
         (lang (or (file-name-extension file-name) "text"))
         (prompt (read-string "Prompt: " "Explain this code: "))
         (full-prompt (format "%s\n\n```%s\n%s\n```" prompt lang code)))
    (claude-code--send-to-session full-prompt)))

(defun claude-code-explain-function ()
  "Explain the function at point using Claude Code."
  (interactive)
  (let* ((bounds (bounds-of-thing-at-point 'defun))
         (code (buffer-substring-no-properties (car bounds) (cdr bounds)))
         (prompt (format "Explain this function concisely:\n\n```\n%s\n```" code)))
    (claude-code--send-to-session prompt)))

(defun claude-code-print (prompt)
  "Send a one-shot query to Claude Code and display result."
  (interactive "sPrompt: ")
  (let ((output (shell-command-to-string
                 (format "claude --print %s"
                         (shell-quote-argument prompt)))))
    (with-current-buffer (get-buffer-create "*claude-output*")
      (erase-buffer)
      (insert output)
      (markdown-mode)
      (display-buffer (current-buffer)))))

(defun claude-code--send-to-session (text)
  "Send TEXT to the running Claude Code vterm session."
  (let ((buf (get-buffer claude-code-buffer-name)))
    (unless (and buf (buffer-live-p buf))
      (claude-code-start)
      (setq buf (get-buffer claude-code-buffer-name))
      (sleep-for 2))
    (with-current-buffer buf
      (vterm-send-string text)
      (vterm-send-return))
    (switch-to-buffer-other-window buf)))

(provide 'claude-code)
```

### 3. Add Keybindings

```elisp
;; In init.el
(add-to-list 'load-path "~/.emacs.d/lisp/")
(require 'claude-code)

(global-set-key (kbd "C-c c c") #'claude-code-start)
(global-set-key (kbd "C-c c r") #'claude-code-send-region)
(global-set-key (kbd "C-c c e") #'claude-code-explain-function)
(global-set-key (kbd "C-c c p") #'claude-code-print)
```

### 4. Configure Environment

```bash
# Ensure your shell exports the API key
echo 'export ANTHROPIC_API_KEY="sk-ant-your-key-here"' >> ~/.zshrc
source ~/.zshrc
```

### 5. Verify

```bash
# From Emacs: M-x shell-command RET
claude --print "Hello from Emacs"
# Expected output:
# Hello from Emacs! (or similar greeting)
```

Or press `C-c c c` to open an interactive Claude Code session in a split window.

## Usage Example

Working on a Python project in Emacs with Claude Code:

```elisp
;; 1. Open your Python file
;; 2. Select a function with C-M-h (mark-defun)
;; 3. Press C-c c r to send the region to Claude Code
;; 4. At the prompt, type: "Add type hints and improve error handling"
```

Example interaction with a Python function:

```python
# Original function in your buffer
def fetch_user_data(user_id, api_client, cache):
    cached = cache.get(f"user:{user_id}")
    if cached:
        return cached
    response = api_client.get(f"/users/{user_id}")
    if response.status_code == 200:
        data = response.json()
        cache.set(f"user:{user_id}", data, ttl=300)
        return data
    return None
```

After `C-c c r` with prompt "Add type hints and improve error handling":

```python
from typing import Any
from dataclasses import dataclass

@dataclass
class UserData:
    id: str
    name: str
    email: str

class UserFetchError(Exception):
    def __init__(self, user_id: str, status_code: int):
        self.user_id = user_id
        self.status_code = status_code
        super().__init__(f"Failed to fetch user {user_id}: HTTP {status_code}")

def fetch_user_data(
    user_id: str,
    api_client: "HttpClient",
    cache: "CacheBackend",
) -> UserData | None:
    """Fetch user data with caching. Raises UserFetchError on API failure."""
    cache_key = f"user:{user_id}"
    cached: dict[str, Any] | None = cache.get(cache_key)
    if cached is not None:
        return UserData(**cached)

    response = api_client.get(f"/users/{user_id}")

    if response.status_code == 404:
        return None
    if response.status_code != 200:
        raise UserFetchError(user_id, response.status_code)

    data = response.json()
    cache.set(cache_key, data, ttl=300)
    return UserData(**data)
```

Use `C-c c p` for quick one-shot queries without entering the interactive session:

```
C-c c p RET "What's the idiomatic way to handle optional chaining in Emacs Lisp?" RET
```

## Common Issues

- **Vterm not displaying colors:** Add `(setq vterm-term-environment-variable "xterm-256color")` to your config.
- **Claude Code session dies on Emacs frame close:** Use `(setq vterm-kill-buffer-on-exit nil)` to preserve the buffer.
- **Shell environment not loaded in vterm:** Set `(setq vterm-shell "/bin/zsh -l")` to force login shell which sources your profile.

## Why This Matters

Emacs users who add Claude Code to their workflow report completing complex refactoring tasks 40% faster by eliminating context switches between terminal and editor.

## Related Guides

- [Claude Code for Alacritty Workflow Guide](/claude-code-for-alacritty-workflow-guide/)
- [Claude Code Tmux Session Management](/claude-code-tmux-session-management-multi-agent-workflow/)
- [How to Write Effective CLAUDE.md for Your Project](/how-to-write-effective-claude-md-for-your-project/)


## Frequently Asked Questions

### What is the minimum setup required?

You need Claude Code installed (Node.js 18+), a project with a `CLAUDE.md` file, and the relevant toolchain for your project type (e.g., npm for JavaScript, pip for Python). The CLAUDE.md file should describe your project structure, conventions, and common commands so Claude Code can work effectively.

### How long does the initial setup take?

For a typical project, initial setup takes 10-20 minutes. This includes creating the CLAUDE.md file, configuring `.claude/settings.json` for permissions, and running a test task to verify everything works. Subsequent sessions start immediately because the configuration persists.

### Can I use this with a team?

Yes. Commit your `.claude/` directory and `CLAUDE.md` to version control so the entire team uses the same configuration. Each developer can add personal preferences in `~/.claude/settings.json` (user-level) without affecting the project configuration. Review CLAUDE.md changes in pull requests like any other configuration file.

### What if Claude Code produces incorrect output?

First check that your CLAUDE.md accurately describes your project conventions. Incorrect or outdated context is the most common cause of wrong output. If the output is still wrong, provide feedback in the same session — Claude Code learns from corrections within a conversation. For persistent issues, add explicit rules to CLAUDE.md (e.g., "Always use single quotes" or "Never modify files in the config/ directory").


## Best Practices

1. **Start with a clear CLAUDE.md.** Describe your project structure, tech stack, coding conventions, and common commands in under 300 words. This single file has the largest impact on Claude Code's accuracy and efficiency.

2. **Use skills for domain knowledge.** Move detailed reference information (API routes, database schemas, deployment procedures) into `.claude/skills/` files. This keeps CLAUDE.md concise while making specialized knowledge available when needed.

3. **Review changes before committing.** Always run `git diff` after Claude Code makes changes. Verify the edits are correct, match your project style, and do not introduce unintended side effects. This habit prevents compounding errors across sessions.

4. **Set up permission guardrails.** Configure `.claude/settings.json` with explicit allow and deny lists. Allow your standard development commands (test, build, lint) and deny destructive operations (rm -rf, git push --force, database drops).

5. **Keep sessions focused.** Give Claude Code one clear task per prompt. Multi-step requests like "refactor auth, add tests, and update docs" produce better results when broken into three separate prompts, each building on the previous result.


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
        "text": "First check that your CLAUDE.md accurately describes your project conventions. Incorrect or outdated context is the most common cause of wrong output. If the output is still wrong, provide feedback in the same session — Claude Code learns from corrections within a conversation. For persistent issues, add explicit rules to CLAUDE.md (e.g., \"Always use single quotes\" or \"Never modify files in the config/ directory\"). 1. **Start with a clear CLAUDE.md.** Describe your project structure, tech stack, coding conventions, and common commands in under 300 words. This single file has the largest impact on Claude Code's accuracy and efficiency. 2. **Use skills for domain knowledge.** Move detailed reference information (API routes, database schemas, deployment procedures) into `.claude/skills/` files. This keeps CLAUDE.md concise while making specialized knowledge available when needed. 3. **Review changes before committing.** Always run `git diff` after Claude Code makes changes. Verify the edits are correct, match your project style, and do not introduce unintended side effects. This habit prevents compounding errors across sessions. 4. **Set up permission guardrails.** Configure `.claude/settings.json` with explicit allow and deny lists. Allow your standard development commands (test, build, lint) and deny destructive operations (rm -rf, git push --force, database drops). 5. **Keep sessions focused.** Give Claude Code one clear task per prompt. Multi-step requests like \"refactor auth, add tests, and update docs\" produce better results when broken into three separate prompts, each building on the previous result."
      }
    }
  ]
}
</script>
