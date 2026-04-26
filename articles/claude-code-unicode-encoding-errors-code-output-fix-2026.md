---
layout: default
title: "Unicode Encoding Errors in Code Output — Fix (2026)"
permalink: /claude-code-unicode-encoding-errors-code-output-fix-2026/
date: 2026-04-20
description: "Fix Unicode encoding errors in Claude Code output. Set UTF-8 locale and terminal encoding to prevent garbled characters in generated code files."
last_tested: "2026-04-22"
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

## See Also

- [Locale LC_ALL Not Set Encoding Errors Fix](/claude-code-locale-lc-all-not-set-encoding-errors-fix-2026/)
- [Output Channel Buffer Full Truncated — Fix (2026)](/claude-code-output-channel-buffer-full-fix-2026/)

## Related Error Messages

This fix also applies if you see these related error messages:

- `Error: spawn git ENOENT in container`
- `ENOENT: no such file or directory '/usr/bin/rg'`
- `OCI runtime create failed`
- `bash: command not found: claude`
- `zsh: command not found: claude`

## Frequently Asked Questions

### What base Docker image works best with Claude Code?

Use `node:20` (the full image, not slim or alpine). It includes git, curl, and other tools Claude Code depends on. Alpine images require additional package installation and may have compatibility issues with native modules.

### How do I pass my API key to a Docker container?

Use `docker run -e ANTHROPIC_API_KEY=$ANTHROPIC_API_KEY my-image`. Never bake API keys into Docker images. For Docker Compose, use an `.env` file referenced in your `docker-compose.yml` with `env_file: .env`.

### Can Claude Code access files outside the container?

Only if you mount host directories as volumes: `docker run -v /host/path:/container/path my-image`. Claude Code inside the container sees only the container filesystem. Mount your project directory to give Claude Code access to your source code.

### Why is the claude command not found after installation?

The installation directory is not in your PATH. Run `which claude` to check if it is accessible. If not, add the npm global bin directory to your PATH: `export PATH=$(npm bin -g):$PATH` and add this line to your shell profile (`~/.bashrc` or `~/.zshrc`).


## Related Guides

**Try it:** Paste your error into our [Error Diagnostic](/diagnose/) for an instant fix.

- [Fix Skill Exceeded Maximum Output](/claude-code-skill-exceeded-maximum-output-length-error-fix/)
- [Fix: Structured Output + Thinking +](/anthropic-sdk-structured-output-thinking-tool-use-bug/)
- [Claude Code Skill Output Streaming](/claude-code-skill-output-streaming-optimization/)
- [Customize Claude Code Output Format](/best-way-to-customize-claude-code-output-format-style/)