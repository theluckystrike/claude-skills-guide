---
layout: post
title: "Claude Code + WebStorm JetBrains Setup"
description: "Use Claude Code with WebStorm for JavaScript and TypeScript development. Terminal integration, file watching, and workflow automation tips."
permalink: /claude-code-webstorm-jetbrains-setup-2026/
date: 2026-04-21
last_tested: "2026-04-21"
render_with_liquid: false
---

## The Workflow

Configure Claude Code to work inside WebStorm's built-in terminal for JavaScript and TypeScript projects. Leverage WebStorm's file watcher to automatically reload when Claude Code modifies files, creating a tight feedback loop.

Expected time: 10 minutes
Prerequisites: WebStorm 2024.3+, Claude Code CLI installed, Node.js 18+

## Setup

### 1. Install Claude Code

```bash
npm install -g @anthropic-ai/claude-code
claude --version
```

Confirms Claude Code is accessible from WebStorm's terminal.

### 2. Configure WebStorm Terminal

```
Settings → Tools → Terminal:
  Shell path: /bin/zsh (macOS) or /bin/bash (Linux)
  Default tab name: Claude Code
  Shell integration: enabled

Environment variables:
  ANTHROPIC_API_KEY=sk-ant-your-key-here
```

### 3. Create an External Tool Shortcut

```
Settings → Tools → External Tools → [+]:
  Name: Claude Code Interactive
  Program: claude
  Arguments: (empty)
  Working directory: $ProjectFileDir$

  Name: Claude Code Print
  Program: claude
  Arguments: --print "$SelectedText$"
  Working directory: $ProjectFileDir$
```

Assign keyboard shortcuts via Settings → Keymap → External Tools.

### 4. Set Up File Watcher for Auto-Reload

```
Settings → Tools → File Watchers → [+] Custom:
  Name: Claude Code Changes
  File type: Any
  Scope: Project Files
  Program: (leave empty - WebStorm auto-detects changes)

  Under "Advanced":
  ☑ Auto-save edited files to trigger the watcher
  ☑ Trigger the watcher on external changes
```

WebStorm automatically detects file changes from Claude Code and reloads them in the editor.

### 5. Create Project CLAUDE.md

```markdown
# Project Context

TypeScript monorepo using pnpm workspaces.
Framework: Next.js 14 (App Router) + tRPC
Package manager: pnpm 9.x
Test runner: Vitest with Testing Library

## Conventions
- Use 'type' keyword for type-only imports
- Prefer named exports over default exports
- Co-locate tests with source files (*.test.ts)
- Use Zod for all runtime validation
- CSS: Tailwind with cn() utility from @/lib/utils
```

### 6. Verify

```bash
# In WebStorm's terminal (Alt+F12):
claude --print "List the TypeScript files in this project's src directory"
# Expected output:
# Lists your .ts/.tsx source files
```

## Usage Example

Building a React component with Claude Code in WebStorm:

```bash
# Open WebStorm terminal (Alt+F12)
claude

# Generate a new component
> Create a SearchInput component with:
> - Debounced input (300ms)
> - Loading spinner during search
> - Clear button
> - Keyboard shortcut (Cmd+K) to focus
> - Use our cn() utility for class merging
> - Write to src/components/search-input.tsx
```

Claude Code generates:

```typescript
// src/components/search-input.tsx
"use client";

import { useCallback, useEffect, useRef, useState } from "react";
import { Search, X, Loader2 } from "lucide-react";
import { cn } from "@/lib/utils";

interface SearchInputProps {
  onSearch: (query: string) => void;
  isLoading?: boolean;
  placeholder?: string;
  className?: string;
}

export function SearchInput({
  onSearch,
  isLoading = false,
  placeholder = "Search...",
  className,
}: SearchInputProps) {
  const [value, setValue] = useState("");
  const inputRef = useRef<HTMLInputElement>(null);
  const debounceRef = useRef<ReturnType<typeof setTimeout>>();

  const handleChange = useCallback(
    (e: React.ChangeEvent<HTMLInputElement>) => {
      const newValue = e.target.value;
      setValue(newValue);

      if (debounceRef.current) {
        clearTimeout(debounceRef.current);
      }

      debounceRef.current = setTimeout(() => {
        onSearch(newValue);
      }, 300);
    },
    [onSearch]
  );

  const handleClear = useCallback(() => {
    setValue("");
    onSearch("");
    inputRef.current?.focus();
  }, [onSearch]);

  useEffect(() => {
    const handleKeyDown = (e: KeyboardEvent) => {
      if ((e.metaKey || e.ctrlKey) && e.key === "k") {
        e.preventDefault();
        inputRef.current?.focus();
      }
    };

    document.addEventListener("keydown", handleKeyDown);
    return () => document.removeEventListener("keydown", handleKeyDown);
  }, []);

  useEffect(() => {
    return () => {
      if (debounceRef.current) {
        clearTimeout(debounceRef.current);
      }
    };
  }, []);

  return (
    <div className={cn("relative flex items-center", className)}>
      <Search className="absolute left-3 h-4 w-4 text-muted-foreground" />
      <input
        ref={inputRef}
        type="text"
        value={value}
        onChange={handleChange}
        placeholder={placeholder}
        className={cn(
          "h-10 w-full rounded-md border border-input bg-background",
          "pl-9 pr-9 text-sm ring-offset-background",
          "placeholder:text-muted-foreground",
          "focus-visible:outline-none focus-visible:ring-2",
          "focus-visible:ring-ring focus-visible:ring-offset-2"
        )}
      />
      <div className="absolute right-3">
        {isLoading ? (
          <Loader2 className="h-4 w-4 animate-spin text-muted-foreground" />
        ) : value ? (
          <button
            onClick={handleClear}
            className="text-muted-foreground hover:text-foreground"
          >
            <X className="h-4 w-4" />
          </button>
        ) : (
          <kbd className="hidden text-xs text-muted-foreground sm:inline-block">
            ⌘K
          </kbd>
        )}
      </div>
    </div>
  );
}
```

WebStorm immediately detects the new file and adds it to the project tree. You can see TypeScript checking it in real-time.

```bash
# Generate the test file
> Now write a Vitest test for SearchInput with Testing Library.
> Test debounce behavior, clear button, and keyboard shortcut.
> Write to src/components/search-input.test.tsx
```

Run tests directly in WebStorm's test runner while Claude Code stays open in the terminal pane.

## Common Issues

- **Claude Code not found after npm install -g:** WebStorm's terminal may not pick up PATH changes. Restart WebStorm or set the full path in External Tools configuration.
- **File watcher not triggering:** Enable "Use safe write" under Settings → Appearance & Behavior → System Settings, and ensure "Synchronize files on frame or editor tab activation" is checked.
- **TypeScript errors after Claude Code generates files:** Run `pnpm typecheck` in the terminal to trigger a full project check if WebStorm's incremental check misses imports.

## Why This Matters

WebStorm's immediate type-checking feedback combined with Claude Code's generation speed creates a workflow where you generate, validate, and iterate on components in under 2 minutes per feature.

## Related Guides

- [Claude Code for JetBrains Plugin Workflow](/claude-code-for-jetbrains-plugin-workflow-tutorial/)
- [How to Create React Components Faster with Claude Code](/how-to-create-react-components-faster-with-claude-code/)
- [Best Way to Use Claude Code for Frontend Styling](/best-way-to-use-claude-code-for-frontend-styling/)
