---
layout: post
title: "Claude Code + Neovim Terminal"
description: "Use Claude Code inside Neovim terminal with toggleterm, custom Lua commands, and context-aware prompting. Full config examples included."
permalink: /claude-code-neovim-terminal-integration-2026/
date: 2026-04-21
last_tested: "2026-04-21"
render_with_liquid: false
---

## The Workflow

Integrate Claude Code into Neovim using toggleterm for a seamless split-pane development experience. Send code from your buffer directly to Claude Code sessions, and pull generated code back into your editor without leaving Neovim.

Expected time: 15 minutes
Prerequisites: Neovim 0.9+, lazy.nvim or packer, Claude Code CLI installed, Node.js 18+

## Setup

### 1. Install toggleterm.nvim

```lua
-- In your lazy.nvim plugin spec (lua/plugins/toggleterm.lua)
return {
  "akinsho/toggleterm.nvim",
  version = "*",
  config = function()
    require("toggleterm").setup({
      size = function(term)
        if term.direction == "horizontal" then
          return 20
        elseif term.direction == "vertical" then
          return vim.o.columns * 0.4
        end
      end,
      open_mapping = [[<C-\>]],
      direction = "vertical",
      shade_terminals = true,
      shading_factor = 2,
      persist_size = true,
      persist_mode = true,
    })
  end,
}
```

### 2. Create Claude Code Terminal Commands

```lua
-- lua/plugins/claude-code.lua
return {
  "akinsho/toggleterm.nvim",
  config = function()
    local Terminal = require("toggleterm.terminal").Terminal

    -- Dedicated Claude Code terminal
    local claude_term = Terminal:new({
      cmd = "claude",
      direction = "vertical",
      hidden = true,
      on_open = function(term)
        vim.cmd("startinsert!")
        vim.api.nvim_buf_set_keymap(
          term.bufnr, "t", "<Esc>", "<C-\\><C-n>", { noremap = true }
        )
      end,
    })

    -- Claude Code print mode (non-interactive)
    local claude_print = Terminal:new({
      direction = "float",
      hidden = true,
      float_opts = {
        border = "curved",
        width = math.floor(vim.o.columns * 0.8),
        height = math.floor(vim.o.lines * 0.8),
      },
    })

    -- Toggle Claude Code terminal
    vim.keymap.set("n", "<leader>cc", function()
      claude_term:toggle()
    end, { desc = "Toggle Claude Code" })

    -- Send current buffer to Claude Code
    vim.keymap.set("n", "<leader>cb", function()
      local file = vim.fn.expand("%:p")
      local cmd = string.format("claude --print 'Review this file: %s'", file)
      claude_print.cmd = cmd
      claude_print:toggle()
    end, { desc = "Claude review current buffer" })

    -- Send visual selection to Claude Code
    vim.keymap.set("v", "<leader>cs", function()
      local lines = vim.fn.getregion(
        vim.fn.getpos("v"), vim.fn.getpos("."), { type = vim.fn.mode() }
      )
      local code = table.concat(lines, "\n")
      local filetype = vim.bo.filetype
      local escaped = code:gsub("'", "'\\''")
      local prompt = vim.fn.input("Claude prompt: ")
      if prompt == "" then return end

      local cmd = string.format(
        "echo '```%s\n%s\n```\n\n%s' | claude --print -",
        filetype, escaped, prompt
      )
      claude_print.cmd = cmd
      claude_print:toggle()
    end, { desc = "Send selection to Claude" })
  end,
}
```

### 3. Add CLAUDE.md Awareness

```lua
-- lua/plugins/claude-context.lua
-- Auto-detect CLAUDE.md and show notification
vim.api.nvim_create_autocmd("DirChanged", {
  callback = function()
    local claude_md = vim.fn.findfile("CLAUDE.md", ".;")
    if claude_md ~= "" then
      vim.notify("CLAUDE.md found - Claude Code has project context",
        vim.log.levels.INFO)
    end
  end,
})
```

### 4. Configure Keybindings Summary

```lua
-- All Claude Code keybindings in one place
-- <leader>cc  - Toggle Claude Code interactive terminal
-- <leader>cb  - Review current buffer
-- <leader>cs  - Send visual selection with prompt
-- <C-\>       - Toggle generic terminal
-- <Esc>       - Exit terminal insert mode (in Claude term)
```

### 5. Verify

```bash
nvim

# Press <leader>cc to open Claude Code in a vertical split
# Expected: Claude Code interactive session opens on the right
# Type a prompt and verify response appears

# Or test from command mode:
:!claude --print "Hello from Neovim"
# Expected output:
# Hello from Neovim! (or similar)
```

## Usage Example

Full workflow: editing a Rust file and using Claude Code for assistance.

```lua
-- Your Neovim session:
-- Left pane: src/lib.rs (your code)
-- Right pane: Claude Code terminal (via <leader>cc)
```

In the left pane, you have this Rust code:

```rust
// src/lib.rs
use std::collections::HashMap;

pub struct Cache<V> {
    store: HashMap<String, (V, u64)>,
    max_age_ms: u64,
}

impl<V: Clone> Cache<V> {
    pub fn new(max_age_ms: u64) -> Self {
        Self {
            store: HashMap::new(),
            max_age_ms,
        }
    }

    pub fn get(&self, key: &str) -> Option<V> {
        self.store.get(key).and_then(|(val, ts)| {
            let now = std::time::SystemTime::now()
                .duration_since(std::time::UNIX_EPOCH)
                .unwrap()
                .as_millis() as u64;
            if now - ts < self.max_age_ms {
                Some(val.clone())
            } else {
                None
            }
        })
    }

    pub fn set(&mut self, key: String, value: V) {
        let now = std::time::SystemTime::now()
            .duration_since(std::time::UNIX_EPOCH)
            .unwrap()
            .as_millis() as u64;
        self.store.insert(key, (value, now));
    }
}
```

Select the entire `impl` block with `vip`, then press `<leader>cs`:

```
Claude prompt: Add an eviction method that removes expired entries, and make this thread-safe with RwLock
```

Claude Code returns the improved version in a floating window, which you can yank and paste back into your buffer.

## Common Issues

- **Terminal not inheriting PATH:** Add `vim.env.PATH = vim.env.HOME .. "/.local/bin:" .. vim.env.PATH` to your init.lua if Claude Code is installed locally.
- **Claude Code prompt overlaps with statusline:** Increase the `size` function return value for horizontal terminals to at least 25 lines.
- **Visual selection not captured correctly:** Ensure you are in visual mode (not visual-line) when using `<leader>cs` for inline code snippets.

## Why This Matters

Neovim users maintain their modal editing speed while gaining AI assistance. The split-pane approach keeps your code and Claude Code responses visible simultaneously, reducing cognitive overhead during complex tasks.

## Related Guides

- [Claude Code for Alacritty Workflow Guide](/claude-code-for-alacritty-workflow-guide/)
- [Claude Code for Kitty Terminal Workflow Guide](/claude-code-for-kitty-terminal-workflow-guide/)
- [Claude Code Tmux Session Management](/claude-code-tmux-session-management-multi-agent-workflow/)

## See Also

- [Neovim Plugin Socket Error Fix](/claude-code-neovim-plugin-socket-error-fix-2026/)
- [Claude Code for DeFi Protocol Integration (2026)](/claude-code-defi-protocol-integration-2026/)
- [Claude Code + Linear MCP Integration Guide 2026](/claude-code-linear-mcp-integration-2026/)
- [How to Use Claude Code in IntelliJ IDEA 2026](/claude-code-intellij-idea-integration-2026/)
