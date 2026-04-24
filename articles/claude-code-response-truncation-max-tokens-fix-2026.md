---
title: "Response Truncation Max Tokens Hit Fix"
permalink: /claude-code-response-truncation-max-tokens-fix-2026/
description: "Fix response truncation when max tokens hit in Claude Code. Increase output limit or split large generation tasks to get complete code output."
last_tested: "2026-04-22"
render_with_liquid: false
---

## The Error

```
Warning: Response truncated — max_tokens limit reached (16,384).
Output is incomplete. The generated code may be missing closing brackets or functions.
```

This appears when Claude Code's response hits the maximum output token limit, cutting off the generated code mid-line or mid-function.

## The Fix

```bash
claude --max-tokens 32768 "Generate the full CRUD API for users"
```

1. Increase the `--max-tokens` flag to allow longer responses (up to the model's maximum).
2. If the task requires more output than the model supports, break it into smaller pieces.
3. Ask Claude Code to continue from where it left off: `"Continue from the updateUser function"`.

## Why This Happens

The Anthropic API enforces a maximum output token limit per response. When Claude Code generates a large amount of code, documentation, or multi-file output in a single turn, it can hit this ceiling. The API truncates the response at exactly the token limit, often mid-statement. Claude Code does not automatically detect and retry truncated responses.

## If That Doesn't Work

Split generation into file-by-file requests:

```bash
claude "Generate only the User model in src/models/user.ts"
claude "Generate only the User controller in src/controllers/user.ts"
```

Use the Write tool instead of inline code generation for large files:

```bash
claude "Write the complete router to src/routes/users.ts — use the Write tool, not inline output"
```

Check if extended thinking is consuming output budget:

```bash
claude --no-thinking "Generate the full component"
```

## Prevention

```markdown
# CLAUDE.md rule
For code generation tasks, work one file at a time. Never generate more than 300 lines of code in a single turn. Use the Write tool for files over 100 lines.
```


## Related

- [Claude upload limit guide](/claude-upload-limit-guide/) — Understanding Claude file upload limits and workarounds
- [Claude Code max_tokens Ignored in API Mode — Fix (2026)](/claude-code-max-tokens-ignored-api-mode-fix/)
- [Response JSON Parse Failure — Fix (2026)](/claude-code-response-json-parse-failure-fix-2026/)
