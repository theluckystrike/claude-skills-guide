---
title: "Unicode Encoding Errors in Code Output Fix"
permalink: /claude-code-unicode-encoding-errors-code-output-fix-2026/
description: "Fix Unicode encoding errors in Claude Code output. Set UTF-8 locale and terminal encoding to prevent garbled characters in generated code files."
last_tested: "2026-04-22"
render_with_liquid: false
---

## The Error

```
UnicodeEncodeError: 'ascii' codec can't encode character '\u2019' in position 42
Error writing file: Invalid byte sequence in UTF-8 at position 1847
File 'src/i18n/messages.ts' contains characters that cannot be encoded with current locale
```

This appears when Claude Code generates or writes code containing non-ASCII characters (smart quotes, em dashes, emoji, CJK characters) and the system locale or file encoding does not support them.

## The Fix

```bash
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8
claude
```

1. Set your terminal locale to UTF-8 before launching Claude Code.
2. Add the locale exports to your shell profile (`~/.zshrc` or `~/.bashrc`) for persistence.
3. Verify the locale is active: `locale` should show UTF-8 for all categories.

## Why This Happens

Claude Code generates UTF-8 text by default, but the Write tool uses the system locale when writing to disk. If your system locale is set to `POSIX` or `C` (common on minimal Linux installations and Docker containers), the file write fails when it encounters any character outside the ASCII range. This is especially common with internationalization files, comments containing curly quotes, or code copied from documentation.

## If That Doesn't Work

Install the required locale on Linux:

```bash
sudo locale-gen en_US.UTF-8
sudo update-locale LANG=en_US.UTF-8
```

Force UTF-8 encoding in the file write:

```bash
claude "When writing files with non-ASCII characters, ensure the file starts with a UTF-8 BOM or uses only ASCII-safe equivalents"
```

Convert existing files with encoding issues:

```bash
iconv -f ISO-8859-1 -t UTF-8 broken-file.ts > fixed-file.ts
```

## Prevention

```markdown
# CLAUDE.md rule
Always use straight quotes (') not smart quotes. Avoid non-ASCII characters in code comments. Set LANG=en_US.UTF-8 in your shell profile and Docker containers.
```
