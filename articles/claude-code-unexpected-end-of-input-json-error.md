---

layout: default
title: "Fixing Claude Code's 'Unexpected End (2026)"
description: "Fixing Claude Code's 'Unexpected End — step-by-step fix with tested commands, error codes, and verified solutions for developers."
date: 2026-03-14
last_modified_at: 2026-04-17
author: "Claude Skills Guide"
permalink: /claude-code-unexpected-end-of-input-json-error/
categories: [troubleshooting]
tags: [claude-code, claude-skills]
reviewed: true
score: 7
geo_optimized: true
---


Fixing Claude Code's "Unexpected End of Input" JSON Error

If you're working with Claude Code (claude.ai/cli), you've probably encountered the frustrating "unexpected end of input" JSON error at some point. This error typically occurs when Claude Code tries to parse a configuration file or JSON input and finds that the file is incomplete, malformed, or truncated. this guide covers what causes this error, how to identify it, and, most importantly, how to fix it.

## Understanding the Error

The "unexpected end of input" error is a JSON parsing error that happens when the JSON parser reaches the end of the input but expects more data to complete a valid JSON structure. This is a missing closing bracket, a missing quote, or an incomplete object/array.

JSON requires every opening delimiter to have a corresponding closing delimiter. When a parser reads through the input and hits the end of the file (EOF) while still expecting more data, another `}`, `]`, or `"`, it throws an "unexpected end of input" error. The parser was surprised to find nothing where it expected something.

In the context of Claude Code, this error commonly appears in several scenarios:

- Configuration files (like `CLAUDE.md`, project settings)
- MCP (Model Context Protocol) server configurations
- Tool responses that return malformed JSON
- Environment variables containing JSON data
- `.claude/settings.json` files edited manually

Understanding which file is the culprit is half the battle. Claude Code's error message usually includes the file path; read the full error message before starting to debug.

## Anatomy of a JSON Parse Error

Before diving into specific fixes, it helps to understand the different types of JSON errors you might encounter:

| Error Type | Example Cause | Typical Message |
|-----------|--------------|----------------|
| Unexpected end of input | Missing closing `}` or `]` | `SyntaxError: Unexpected end of JSON input` |
| Unexpected token | Trailing comma, comment | `SyntaxError: Unexpected token , in JSON` |
| Unexpected string | Unquoted key | `SyntaxError: Unexpected string in JSON` |
| Invalid escape | `\n` in unquoted context | `SyntaxError: Invalid escape sequence` |

The "unexpected end of input" variant is almost always a structural problem: an unclosed bracket, brace, or string. JSON does not allow trailing commas, comments, or single-quoted strings, so those cases produce different error messages.

## Common Causes and Solutions

1. Incomplete Configuration Files

One of the most frequent causes is a malformed `CLAUDE.md` file or other configuration files. This often happens when editing configuration files manually and accidentally deleting a closing bracket or brace.

Example of invalid JSON (missing closing brace):

```json
{
 "mcpServers": {
 "filesystem": {
 "command": "npx",
 "args": ["-y", "@modelcontextprotocol/server-filesystem", "/path/to/dir"]
 }
 // Missing closing brace here
```

Fixed version:

```json
{
 "mcpServers": {
 "filesystem": {
 "command": "npx",
 "args": ["-y", "@modelcontextprotocol/server-filesystem", "/path/to/dir"]
 }
 }
}
```

The quickest way to spot the structural problem is to paste the JSON into a linter that shows a visual bracket-matching view. Tools like `jq` on the command line will tell you exactly where the parse failed, which narrows the problem to a specific region of the file.

2. MCP Server Configuration Issues

When setting up MCP servers in Claude Code, incorrect JSON configuration can trigger this error. The MCP server configuration lives in your Claude Code settings file.

To check your MCP configuration:

First, locate your Claude Code configuration directory. On macOS, it's typically at `~/Library/Application Support/Claude/settings.json`. On Linux, it's `~/.config/Claude/settings.json`. On Windows, check `%APPDATA%\Claude\settings.json`.

Example of properly formatted MCP configuration:

```json
{
 "mcpServers": {
 "puppeteer": {
 "command": "npx",
 "args": ["-y", "@modelcontextprotocol/server-puppeteer"]
 },
 "filesystem": {
 "command": "npx",
 "args": ["-y", "@modelcontextprotocol/server-filesystem", "./public"]
 }
 }
}
```

Notice how each server object is properly closed with `}` and the entire configuration is wrapped in outer braces. A very common mistake when adding a new MCP server is forgetting to add the comma between server entries, or adding a comma after the last entry. Both cause parse errors:

```json
{
 "mcpServers": {
 "puppeteer": {
 "command": "npx",
 "args": ["-y", "@modelcontextprotocol/server-puppeteer"]
 }, <- this comma is correct (more entries follow)
 "filesystem": {
 "command": "npx",
 "args": ["-y", "@modelcontextprotocol/server-filesystem", "./public"]
 } <- no comma here (last entry)
 }
}
```

3. Environment Variables with JSON

If you're passing JSON through environment variables, make sure the JSON is properly escaped and quoted.

Incorrect way:

```bash
export CLAUDE_CONFIG='{"key": "value"} # Missing closing quote
```

Correct way:

```bash
export CLAUDE_CONFIG='{"key": "value"}'
```

When JSON contains special shell characters, single quotes are safer than double quotes because they prevent the shell from interpreting `$`, backticks, or backslashes inside the string. However, single-quoted strings cannot contain a literal single quote. If your JSON value contains a single quote, use a here-string or a temp file:

```bash
Using a temp file for complex JSON
TMPFILE=$(mktemp)
cat > "$TMPFILE" <<'ENDJSON'
{
 "key": "value with 'quotes' inside",
 "nested": {"a": 1}
}
ENDJSON
export CLAUDE_CONFIG=$(cat "$TMPFILE")
rm "$TMPFILE"
```

4. Project-Specific Configuration

Claude Code respects project-specific configuration through a `CLAUDE.md` file in your project root. If this file contains invalid JSON-like structures (even though it's primarily Markdown), you might encounter issues.

Make sure any JSON code blocks within `CLAUDE.md` are properly formatted:

```markdown
My Project

Here's my project configuration:

```json
{
 "tools": {
 "Bash": {
 "enabled": true,
 "description": "Run shell commands"
 }
 }
}
```
```

Additionally, Claude Code reads `.claude/settings.json` at the project level if it exists. If you initialized Claude Code in a project directory, this file may have been created. Check whether it exists and whether it's valid:

```bash
ls -la .claude/settings.json
python3 -c "import json; json.load(open('.claude/settings.json')); print('Valid')"
```

5. Truncated File from Disk Write Errors

A less obvious cause is a file that was partially written due to a disk-full condition, a crash during a write, or an interrupted save. The file exists and has content, but it ends abruptly mid-structure. This is particularly common on laptops that ran out of disk space.

Check available disk space:

```bash
df -h ~
```

If you find a truncated settings file, the safest approach is to delete it and let Claude Code recreate it with defaults, then re-add your custom settings one section at a time.

## Debugging Steps

When you encounter this error, follow these systematic debugging steps:

## Step 1: Validate Your JSON

Use a JSON validator to check if your configuration files are valid. You can use online tools or the command line:

```bash
Validate JSON using python
python3 -c "import json; json.load(open('settings.json'))"

Or using jq
cat settings.json | jq .
```

If `jq` is not installed, you can install it quickly:

```bash
macOS
brew install jq

Ubuntu/Debian
sudo apt install jq

Windows (via winget)
winget install jqlang.jq
```

The `jq` output is particularly useful because it prints the parsed and reformatted JSON if valid, or a precise error message with a character position if not. That character position lets you jump directly to the problem in your editor.

```bash
Get character position of the error
python3 -c "
import json, sys
try:
 json.load(open('settings.json'))
 print('Valid JSON')
except json.JSONDecodeError as e:
 print(f'Error at line {e.lineno}, column {e.colno}: {e.msg}')
"
```

## Step 2: Check Recent Changes

If the error appeared after a recent change, review your recent edits to configuration files:

```bash
Check recent changes to settings
git diff ~/.config/Claude/settings.json

Or check modification time
ls -la ~/.config/Claude/settings.json
```

If you didn't version-control the settings file (most people don't), check if your editor's undo history can help you identify what changed. Many editors also keep backup files (`settings.json~` or `settings.json.bak`).

## Step 3: Simplify and Rebuild

If you're unsure where the problem is, start with a minimal valid configuration and gradually add back your settings:

```json
{
 "mcpServers": {}
}
```

Then add one MCP server at a time, validating after each addition:

```bash
After adding each server, validate
python3 -c "import json; json.load(open('settings.json')); print('OK')"
```

This bisection approach quickly narrows down which server entry contains the syntax error, even in large configuration files.

## Step 4: Check File Permissions

Sometimes, Claude Code might not be able to read the full configuration file due to permission issues. Verify file permissions:

```bash
ls -la ~/.config/Claude/settings.json
chmod 644 ~/.config/Claude/settings.json
```

On macOS, the `~/Library/Application Support/Claude/` directory is sometimes protected by macOS privacy controls. If you recently changed your system privacy settings or migrated from another machine, verify that your terminal application has Full Disk Access in System Settings > Privacy & Security > Full Disk Access.

## Step 5: Check for BOM or Encoding Issues

A subtle but real source of parse errors is a Byte Order Mark (BOM) at the start of the file. Some Windows editors prepend a BOM (`\xEF\xBB\xBF`) to UTF-8 files, which is invisible in most text editors but causes JSON parsers to fail immediately.

```bash
Check for BOM
file settings.json
Should say "ASCII text" or "UTF-8 Unicode text"
NOT "UTF-8 Unicode (with BOM) text"

Remove BOM if present
sed -i '' $'1s/^\xEF\xBB\xBF//' settings.json # macOS
sed -i '1s/^\xEF\xBB\xBF//' settings.json # Linux
```

## Preventing Future Errors

## Use a Linter

Set up a linter or pre-commit hook to validate JSON files before committing:

```json
// .git/hooks/pre-commit
#!/bin/bash
python3 -c "import json; json.load(open('settings.json'))" || exit 1
```

For projects that have multiple JSON configuration files, a broader hook is more useful:

```bash
#!/bin/bash
Validate all JSON files in the project
ERRORS=0
while IFS= read -r -d '' file; do
 if ! python3 -c "import json; json.load(open('$file'))" 2>/dev/null; then
 echo "Invalid JSON: $file"
 ERRORS=$((ERRORS + 1))
 fi
done < <(find . -name "*.json" -not -path "*/node_modules/*" -print0)

if [ "$ERRORS" -gt 0 ]; then
 echo "$ERRORS JSON file(s) failed validation. Aborting commit."
 exit 1
fi
```

## Use an Editor with JSON Validation

Most modern editors validate JSON in real time. If you're editing Claude Code configuration files in a plain text editor, consider switching to VS Code with the built-in JSON language support, which shows inline errors as you type. The JSON extension in VS Code also provides schema validation for known configuration formats.

For VS Code, you can associate Claude Code's settings file with a JSON schema for even better validation:

```json
// In VS Code settings.json
{
 "json.schemas": [
 {
 "fileMatch": ["/Claude/settings.json"],
 "schema": {
 "type": "object",
 "properties": {
 "mcpServers": {
 "type": "object",
 "additionalProperties": {
 "type": "object",
 "required": ["command"],
 "properties": {
 "command": {"type": "string"},
 "args": {"type": "array", "items": {"type": "string"}},
 "env": {"type": "object"}
 }
 }
 }
 }
 }
 }
 ]
}
```

## Version Control Your Configurations

Keep your Claude Code configurations in version control (with appropriate .gitignore entries for sensitive data):

```bash
In your .gitignore
~/.config/Claude/settings.local.json
```

A practical approach is to keep a `settings.template.json` in your dotfiles repository with the structural skeleton and placeholders for sensitive values like API keys, then use a setup script to fill in the real values:

```bash
#!/bin/bash
setup-claude.sh
SETTINGS_DIR="$HOME/.config/Claude"
mkdir -p "$SETTINGS_DIR"
sed "s/YOUR_API_KEY/$ANTHROPIC_API_KEY/g" settings.template.json > "$SETTINGS_DIR/settings.json"
python3 -c "import json; json.load(open('$SETTINGS_DIR/settings.json'))" && echo "Settings valid"
```

## Use Claude Code's Built-in Validation

Claude Code will often tell you which file has the parsing error. Pay attention to error messages, they usually include the file path.

When Claude Code fails to start and shows a JSON error, the error message typically follows one of these patterns:

```
Error: Failed to parse config at /Users/you/.config/Claude/settings.json
SyntaxError: Unexpected end of JSON input

Error reading MCP configuration: SyntaxError: Unexpected token } in JSON at position 234
```

The file path in the first line tells you which file to fix. The second line tells you what the parser found. The position number (234 in the example above) is the byte offset in the file, which you can use with your editor's "Go to offset" feature.

## Advanced: Debugging MCP Server Responses

If the error comes from an MCP server returning invalid JSON, you can debug it by:

1. Checking the server logs
2. Testing the server independently
3. Verifying the JSON output from the server

```bash
Test an MCP server directly
npx -y @modelcontextprotocol/server-filesystem /path 2>&1 | head -50
```

MCP servers communicate using JSON-RPC over stdin/stdout. If a server crashes mid-response or writes non-JSON output (such as a debug print statement from Node.js), Claude Code receives a partial or invalid JSON message. You can intercept the communication by running the server manually and checking its output:

```bash
Start the server and send a minimal initialization request
echo '{"jsonrpc":"2.0","id":1,"method":"initialize","params":{"protocolVersion":"2024-11-05","capabilities":{},"clientInfo":{"name":"test","version":"0.0.1"}}}' \
 | npx -y @modelcontextprotocol/server-filesystem /path/to/dir 2>/dev/null
```

If the server outputs anything before the JSON response, such as a startup message, warning, or debug log, that prefix will break Claude Code's JSON parser. For custom MCP servers, ensure all non-protocol output goes to stderr rather than stdout:

```javascript
// Incorrect. writes to stdout, corrupts MCP protocol stream
console.log("Server starting...");

// Correct. stderr does not interfere with the protocol stream
console.error("Server starting...");
process.stderr.write("Debug: " + JSON.stringify(data) + "\n");
```

## Quick Reference: Most Common Fixes

| Symptom | Most Likely Cause | Fix |
|---------|------------------|-----|
| Error at startup, before any prompt | `settings.json` malformed | Validate and fix `~/.config/Claude/settings.json` |
| Error after adding MCP server | Missing/extra comma or brace | Check the MCP entry you just added |
| Error only in one project | `.claude/settings.json` malformed | Validate `.claude/settings.json` in project root |
| Error after update | Settings format changed | Recreate settings from scratch, re-add customizations |
| Error with environment variable | Unquoted or unterminated string | Wrap value in single quotes |
| Error from MCP tool response | Server writing to stdout | Redirect server debug output to stderr |

## Conclusion

The "unexpected end of input" JSON error in Claude Code is usually caused by malformed configuration files, most commonly missing closing braces or brackets. The fix is straightforward: validate your JSON, check for typos, and ensure all brackets and braces are properly closed.

By following the debugging steps outlined in this guide, you can quickly identify and resolve these JSON parsing errors. The key habits that prevent this error from recurring are: using an editor with JSON validation built in, validating configuration files programmatically after every manual edit, and making incremental changes so you can easily identify what caused any issues.

If you continue to experience this error after checking your local configurations, it is worth checking Claude Code's documentation or community forums for known issues with specific versions or configurations. The Claude Code GitHub repository also tracks open issues, so searching for "unexpected end of input" there may surface a version-specific bug or workaround.


---

---

<div class="mastery-cta">

I hit this exact error six months ago. Then I wrote a CLAUDE.md that tells Claude my stack, my conventions, and my error handling patterns. Haven't seen it since.

I run 5 Claude Max subs, 16 Chrome extensions serving 50K users, and bill $500K+ on Upwork. These CLAUDE.md templates are what I actually use. Not theory — production configs.

**[Grab the templates — $99 once, free forever →](https://zovo.one/lifetime?utm_source=ccg&utm_medium=cta-error&utm_campaign=claude-code-unexpected-end-of-input-json-error)**

47/500 founding spots. Price goes up when they're gone.

</div>

Related Reading

- [Claude Code for Beginners: Complete Getting Started Guide](/claude-code-for-beginners-complete-getting-started-2026/)
- [Claude Code Not Working After Update: How to Fix](/claude-code-not-working-after-update-how-to-fix/)
- [Best Claude Skills for Developers in 2026](/best-claude-skills-for-developers-2026/)
- [Claude Code Troubleshooting Hub](/troubleshooting-hub/)

Built by theluckystrike. More at [zovo.one](https://zovo.one)


