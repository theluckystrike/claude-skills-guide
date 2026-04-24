---
layout: default
title: "Claude Code Crashes When Loading Skill (2026)"
description: "Fix Claude Code skill loading crashes: YAML front matter errors, file permissions, skill directory structure, and systematic isolation techniques."
date: 2026-03-13
last_modified_at: 2026-04-17
categories: [troubleshooting]
tags: [claude-code, claude-skills, debugging, troubleshooting]
author: "Claude Skills Guide"
reviewed: true
score: 9
permalink: /claude-code-crashes-when-loading-skill-debug-steps/
geo_optimized: true
---

# Claude Code Crashes When Loading Skill: Debug Steps

[When Claude Code fails loading a skill, it usually comes down to one of three things](/claude-skill-md-format-complete-specification-guide/): invalid YAML in the skill file, a missing file, or a naming mismatch. Here's a systematic approach to find and fix the problem.

## What a Skill File Actually Is

Claude Code skills are single [skill.md files](/claude-skill-md-format-complete-specification-guide/). plain Markdown with YAML front matter. There are no companion `.js` files, no compiled assets, no build steps. The entire skill lives in one file:

```
~/.claude/skills/
 my-skill.md
```

If you're expecting a directory structure with `skill.js` or `skill.json`, that's the source of the crash.

## Step 1: Check the File Exists

Verify the skill file is where Claude Code expects it:

```bash
ls -la ~/.claude/skills/
```

If the file is missing or misnamed, Claude can't load it. [Skill names are case-sensitive. `TDD.md` and `tdd.md` are different](/claude-skill-md-format-complete-specification-guide/).

## Step 2: Validate YAML Front Matter

[The most common crash cause is malformed YAML at the top of the skill file](/claude-skill-md-format-complete-specification-guide/). The front matter must be valid YAML between `---` delimiters:

```yaml
---
name: my-skill
description: "What this skill does"
---
```

Common YAML mistakes that cause crashes:

```yaml
BROKEN. colon in unquoted string
description: Handles: multiple cases

FIXED
description: "Handles: multiple cases"
```

```yaml
BROKEN. mixed indentation (tabs vs spaces)
config:
 option: true
	other: false # tab here breaks YAML

FIXED. consistent 2-space indentation
config:
 option: true
 other: false
```

Validate your YAML with:

```bash
python3 -c "import yaml; yaml.safe_load(open('~/.claude/skills/my-skill.md').read())"
```

Or use `yamllint`:

```bash
pip install yamllint
yamllint ~/.claude/skills/my-skill.md
```

## Step 3: Check File Permissions

Claude Code needs read access to skill files:

```bash
Fix permissions if needed
chmod 644 ~/.claude/skills/my-skill.md

Check ownership
ls -la ~/.claude/skills/
```

If the file is owned by root or another user, Claude Code may fail silently. This happens most often when you created the skill file using `sudo`, copied it from a mounted volume, or moved it from a system-wide location. The process running Claude Code must be able to open and read the file. write access is not required, but read access is non-negotiable.

```bash
Check who owns the file versus who runs claude
ls -la ~/.claude/skills/
whoami

If root owns it, fix ownership
sudo chown $(whoami) ~/.claude/skills/my-skill.md

If permissions are too restrictive
stat -f "%A %N" ~/.claude/skills/my-skill.md # macOS
stat -c "%a %n" ~/.claude/skills/my-skill.md # Linux
```

A file with mode `600` (owner-read only) is usually fine if you own it. A file with mode `000` or owned by a different user will cause a silent failure. Claude Code won't crash with a helpful error, it just won't see the skill.

## Step 4: Isolate the Problem Skill

If you have multiple skills and only some are crashing, isolate by temporarily moving others out:

```bash
mkdir ~/.claude/skills.disabled
mv ~/.claude/skills/*.md ~/.claude/skills.disabled/

Re-add one at a time to find the bad one
mv ~/.claude/skills.disabled/suspected-bad.md ~/.claude/skills/
```

Restart Claude Code after each move and test if the crash reproduces.

## Step 5: Check for Encoding Issues and Corrupted Files

Skills copied from Windows or certain editors sometimes have UTF-16 encoding or Windows line endings (`\r\n`) that break YAML parsing:

```bash
Check encoding
file ~/.claude/skills/my-skill.md

Convert to UTF-8 with Unix line endings if needed
iconv -f UTF-16 -t UTF-8 my-skill.md > my-skill-fixed.md
or
sed -i 's/\r$//' my-skill.md
```

Beyond encoding, a skill file can be silently corrupted. truncated mid-write, containing null bytes, or mangled by a text editor that doesn't handle Markdown gracefully. These corruptions don't always show up as obvious YAML errors; Claude Code may just fail to load the file without a clear message.

```bash
Look for null bytes, which break most parsers
grep -Pc '\x00' ~/.claude/skills/my-skill.md
Output of 0 means no null bytes; anything higher means the file is corrupted

Check file size. a skill file should not be 0 bytes
wc -c ~/.claude/skills/my-skill.md

Inspect the raw bytes around the front matter delimiters
hexdump -C ~/.claude/skills/my-skill.md | head -20
You should see 2d 2d 2d on the first line (the "---" delimiter in hex)
```

If `hexdump` shows unexpected bytes before the first `---`, the file has a BOM (Byte Order Mark) or garbage data prepended. Most YAML parsers choke on a BOM:

```bash
Strip a UTF-8 BOM if present
sed -i '1s/^\xef\xbb\xbf//' ~/.claude/skills/my-skill.md
```

The safest fix for a corrupted file is to create a fresh copy using a plain-text editor (not a rich text editor or word processor), paste the content manually, and confirm the encoding with `file` before replacing the original.

## Step 6: Check Claude Code Version

Outdated Claude Code may have compatibility issues with skill features:

```bash
claude --version

Update via npm
npm update -g @anthropic-ai/claude-code
```

## Using Verbose Mode to Diagnose Skill Loading Failures

When the standard debug steps don't surface the problem, verbose output is your next tool. Claude Code exposes additional diagnostic information when you increase logging verbosity, and skill loading errors that are swallowed at normal log levels often appear clearly in verbose output.

Run Claude Code with verbose logging enabled:

```bash
claude --verbose
```

With verbose mode active, Claude Code prints each skill file it attempts to load, the result of parsing the YAML front matter, and any errors encountered during the process. Look for lines that reference your skill's filename. a parse error will appear immediately after the filename.

If you need to capture the output for inspection or to share with a collaborator:

```bash
claude --verbose 2>&1 | tee /tmp/claude-debug.log
```

This routes both stdout and stderr into a file while still showing output in your terminal. Open `/tmp/claude-debug.log` and search for your skill filename to jump directly to the relevant section:

```bash
grep -n "my-skill" /tmp/claude-debug.log
```

A healthy skill load looks like a single line acknowledging the file was registered. A broken skill produces one or more error lines. typically a YAML parser traceback or a "file not found" message. followed by the skill being skipped.

If verbose output shows the file being loaded but the skill never appears as available, the problem is almost always in the front matter `name` field. Claude Code uses `name` to register the skill internally; if `name` is missing or contains characters that don't map to a valid identifier, the skill is parsed successfully but never registered.

```bash
Quick check. does your skill file have a name field?
grep -m1 "^name:" ~/.claude/skills/my-skill.md
```

No output from that command means your `name` field is either missing or indented incorrectly (which puts it outside the top-level YAML namespace). Both cause silent registration failures.

## Common YAML Front Matter Errors in Skill Files That Cause Crashes

The YAML front matter in a skill file is deceptively easy to get wrong. The YAML spec is strict in ways that aren't obvious to someone who only writes YAML occasionally. These are the patterns that come up most frequently.

Unquoted strings containing special characters. YAML treats colons, hash marks, brackets, and several other characters as syntax tokens unless the string is quoted:

```yaml
BROKEN. colon after a word is interpreted as a key-value separator
description: Fix errors: retry logic included

FIXED
description: "Fix errors: retry logic included"
```

```yaml
BROKEN. hash mark starts a YAML comment inline
description: Handles retries # up to 3 attempts

FIXED
description: "Handles retries # up to 3 attempts"
```

Multi-line strings with incorrect continuation. If your description spans multiple lines, YAML requires either a block scalar (`|` or `>`) or explicit quoting:

```yaml
BROKEN. bare newline in a plain scalar
description: This skill handles
 retries and backoff

FIXED with folded block scalar
description: >
 This skill handles
 retries and backoff
```

Duplicate keys. If you paste a template and accidentally end up with `name:` appearing twice, most YAML parsers will take the last value. but Claude Code's loader may reject the file entirely depending on the parser it uses:

```bash
Check for duplicate keys in front matter
awk '/^---/{count++; if(count==2) exit} count==1' ~/.claude/skills/my-skill.md \
 | grep "^[a-z]" | sort | uniq -d
```

Any output from that command is a key that appears more than once in your front matter.

Boolean and null collisions. YAML 1.1 (which many parsers still use) treats bare `yes`, `no`, `true`, `false`, `on`, `off`, `null`, and `~` as typed values, not strings. If your skill name or description contains any of these unquoted, the value gets coerced:

```yaml
BROKEN. "null" is parsed as YAML null, not the string "null"
name: null-safety-checker

FIXED
name: "null-safety-checker"
```

Missing closing delimiter. The front matter must be closed with a second `---` on its own line. If the closing delimiter is missing or has trailing spaces, the YAML block never terminates and the parser either errors or consumes the entire file as front matter:

```bash
Confirm the closing --- exists as the second occurrence
grep -n "^---" ~/.claude/skills/my-skill.md
Output should show exactly two lines: one near the top, one a few lines down
```

If you only see one `---`, the closing delimiter is absent. Add it as a standalone line immediately after the last front matter key.

## Prevention

- Store skill files in version control
- Validate YAML before deploying new skills: `python3 -c "import yaml; yaml.safe_load(open('skill.md').read())"`
- Keep a backup of known-working skill configurations: `cp -r ~/.claude/skills/ ~/.claude/skills.backup/`
- Test new skills in isolation before adding them to your main directory

---

---

<div class="mastery-cta">

This site was built by 5 autonomous agents running in tmux while I was in Bali. 2,500 articles. Zero manual work. 100% quality gate pass rate.

The orchestration configs, sprint templates, and quality gates that made that possible are in the Zovo Lifetime bundle. Along with 16 CLAUDE.md templates and 80 tested prompts.

**[See how the pipeline works →](https://zovo.one/lifetime?utm_source=ccg&utm_medium=cta-skills&utm_campaign=claude-code-crashes-when-loading-skill-debug-steps)**

$99 once. I'm a solo dev in Da Nang. This is how I scale.

</div>

Related Reading

- [Skill MD File Format Explained With Examples](/claude-skill-md-format-complete-specification-guide/). Complete skill.md format reference
- [How to Write a Skill MD File for Claude Code](/how-to-write-a-skill-md-file-for-claude-code/). Step-by-step skill creation guide
- [Claude Skills Auto Invocation: How It Works](/claude-skills-auto-invocation-how-it-works/). How skills activate automatically
- [Claude Code Keeps Breaking Imports When Refactoring](/claude-code-keeps-breaking-imports-when-refactoring/)

---

*Built by theluckystrike. More at [zovo.one](https://zovo.one)
*


