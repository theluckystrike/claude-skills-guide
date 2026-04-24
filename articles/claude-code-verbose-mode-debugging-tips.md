---
layout: default
title: "Claude Code Verbose Output (2026)"
description: "Use Claude Code verbose mode to trace tool execution and diagnose skill issues. Debug tips and output interpretation explained."
date: 2026-03-14
last_modified_at: 2026-04-17
categories: [troubleshooting]
tags: [claude-code, claude-skills, debugging, verbose-mode, troubleshooting]
author: "Claude Skills Guide"
reviewed: true
score: 7
permalink: /claude-code-verbose-mode-debugging-tips/
geo_optimized: true
---

# Claude Code Verbose Mode Debugging Tips

[When you're building custom Claude skills or integrating AI assistance](/claude-skill-md-format-complete-specification-guide/), understanding how to debug effectively is essential. Claude Code provides verbose mode options that expose the internal decision-making process, tool invocations, and intermediate reasoning steps that help you identify why a skill behaves unexpectedly.

This guide covers practical techniques for using Claude Code's verbose mode to troubleshoot skill issues, trace execution flow, and optimize your AI-assisted development process.

## Enabling Verbose Mode in Claude Code

[Claude Code offers multiple levels of verbosity that reveal different amounts of internal information](/best-claude-code-skills-to-install-first-2026/) The primary flags you can use are `--verbose` and `--debug`, which control the detail level of output.

```bash
Basic verbose output
claude --verbose

Maximum debug information
claude --debug

Combine with specific commands
claude --verbose "analyze this codebase"
```

For persistent configuration, you can set verbose mode in your Claude Code configuration file:

```json
{
 "verbose": true,
 "logLevel": "debug",
 "logTools": true
}
```

The difference between these modes matters for debugging. Verbose mode shows reasoning steps and tool selections, while debug mode adds raw API responses and internal state information. In practice, start with `--verbose` for most debugging tasks. Reserve `--debug` for situations where you suspect an API-level issue, an unexpected token count problem, or a mismatch between what the model receives and what you expect it to receive.

You can also toggle verbosity at the environment variable level, which is useful when running Claude Code from scripts or CI pipelines:

```bash
export CLAUDE_VERBOSE=1
export CLAUDE_LOG_LEVEL=debug

Then run normally
claude "run the audit skill"
```

This approach keeps your command invocations clean while ensuring all subprocess calls also inherit the verbose setting.

## Understanding What Verbose Mode Actually Shows

Before diving into debugging patterns, it helps to understand the structure of verbose output. When you run with `--verbose`, Claude Code emits labeled blocks that correspond to different phases of execution.

A typical verbose session looks like this:

```
[VERBOSE] User message received: "generate tests for auth module"
[VERBOSE] Skill context loaded: tdd.md (847 tokens)
[VERBOSE] Tool selection phase started
[VERBOSE] Candidate tools: Read, Bash, Glob, Grep, Write
[VERBOSE] Selected: Glob. reason: locate test files matching pattern
[VERBOSE] Glob result: 3 files found in src/__tests__/
[VERBOSE] Selected: Read. reason: inspect existing test structure
[VERBOSE] Read result: 124 lines from auth.test.ts
[VERBOSE] Generating test stubs for 6 exported functions
[VERBOSE] Selected: Write. reason: output new test file
[VERBOSE] Write complete: src/__tests__/auth.generated.test.ts
```

Each line tells you the operation name, the rationale the model applied, and the result. When something breaks, this trail narrows the problem to a specific step rather than leaving you to guess which of many operations went wrong.

Debug mode adds lower-level details to this picture:

```
[DEBUG] API request payload: 14,203 tokens (context: 12,841 / completion budget: 1,362)
[DEBUG] Tool call raw response: {"type":"tool_use","name":"Glob","input":{"pattern":"/*.test.ts"}}
[DEBUG] Tool execution time: 43ms
[DEBUG] Tool result size: 218 bytes
```

This is the information you need when troubleshooting token limits, slow tool execution, or surprising model decisions based on what was actually in the context window.

## Tracing Skill Execution

When a custom skill behaves unexpectedly, verbose mode helps you trace exactly what the skill is doing. Consider a scenario where you're using the tdd skill to generate tests but receiving unexpected results.

Enable verbose output to see:

- Which tools the skill selects and why
- The exact prompts being sent to the model
- Tool execution results and timing
- Any errors or warnings in the skill workflow

```bash
claude --verbose "generate tests for auth module"
```

The output reveals each step: initial prompt analysis, tool selection, file reads, test generation, and verification. When something goes wrong, this trace shows you exactly where the process diverged from expectations.

A common pattern is discovering that a skill reads the wrong file. Without verbose mode, you see unexpected test output and have no idea why. With verbose mode, you see a line like:

```
[VERBOSE] Selected: Read. reason: load module under test
[VERBOSE] Read result: 89 lines from src/auth-legacy.ts
```

And now you know the skill picked up `auth-legacy.ts` instead of `auth.ts` because the Glob pattern matched both. You can then refine your prompt to specify the exact file, or update the skill's instructions to be more precise.

## Debugging Tool Selection Issues

One common debugging scenario involves skills that select inappropriate tools. For instance, if you're using the pdf skill to process documents but it attempts to use image processing tools instead, verbose mode shows the decision-making process.

Look for these patterns in verbose output:

```
[DEBUG] Evaluating tool candidates: Read, Bash, pdf_processor
[DEBUG] Selected tool: pdf_processor (confidence: 0.92)
[DEBUG] Reasoning: User requested PDF manipulation, pdf_processor matches intent
```

If you see unexpected tool selection, you can adjust your skill definition to constrain tool availability or refine the skill's guidance prompts.

A more subtle problem is when the model selects the correct tool but calls it with wrong parameters. Verbose output exposes this:

```
[DEBUG] Tool call: Bash
[DEBUG] Input: {"command": "pdfinfo document.pdf"}
[DEBUG] Result: "Error: command not found: pdfinfo"
[DEBUG] Fallback: retrying with python3 -c "import fitz; ..."
```

Without visibility into that sequence, you would only see the final (possibly successful) result and miss that the skill silently tried and failed before finding a workaround. That matters because the workaround is slower, produce slightly different output, or fail in edge cases you have not encountered yet.

## Constraining Tool Access for Cleaner Traces

When debugging a specific skill, you can reduce noise by limiting which tools are available. In your Claude Code settings or skill definition, specify allowed tools:

```json
{
 "allowedTools": ["Read", "Write", "Bash"],
 "disabledTools": ["WebFetch", "WebSearch"]
}
```

This forces the skill to use only the tools relevant to your debugging scenario, making the verbose trace easier to follow.

## Analyzing Conversation Context

Verbose mode also exposes how Claude Code maintains conversation context, which helps when debugging issues with multi-turn conversations. This is particularly useful when working with skills like supermemory that manage persistent context across sessions.

The debug output shows:

- Context window usage and token counts
- Which previous messages are included in each request
- Context truncation decisions
- Memory retrieval and storage operations

```bash
claude --debug "continue our discussion about the API"
```

This information helps you understand why Claude might "forget" details or produce inconsistent responses across conversation turns.

A practical example: you ask Claude to refactor a function, it does so correctly, then you ask it to "make the same change to the other three functions." It only updates one. Debug mode reveals that by the time of the second request, earlier messages were truncated to fit the context window, so the model only saw context for a single function.

The fix in this case is to structure your workflow to pass explicit references rather than relying on implicit conversation history:

```bash
Less reliable across long sessions
claude "make the same change to the other functions"

More reliable
claude "apply the same async/await refactor you just applied to parseUser() to parseSession(), parseToken(), and parseRole()"
```

Verbose mode makes these problems visible so you can design around them.

## Working with Frontend Design Skills

Debugging becomes more complex when working with visual skills like frontend-design or canvas-design, where the output is visual rather than textual. Verbose mode helps by showing the intermediate steps:

- Design parameter extraction from your prompts
- Style and layout decisions
- Component hierarchy construction
- Final rendering instructions

If a design skill produces unexpected results, the verbose trace shows exactly which decisions led to that output, allowing you to adjust your prompts accordingly.

For example, if the skill generates a layout with the wrong breakpoints, verbose output might show:

```
[VERBOSE] Extracted design tokens: breakpoints not specified in prompt
[VERBOSE] Applying defaults: sm=640px, md=768px, lg=1024px
[VERBOSE] User intent: "responsive dashboard". inferring Tailwind defaults
```

Knowing that the skill filled in defaults because you did not specify breakpoints tells you exactly what to add to your prompt to get consistent results.

## Common Debugging Patterns

Here are practical patterns for common debugging scenarios:

Unexpected behavior in multi-step workflows:
```bash
claude --debug "complex task with multiple steps"
Review each step's input/output in detail
```

Context or memory issues:
```bash
claude --debug "store this detail in memory"
Observe memory operations in trace
```

API or network errors:
```bash
claude --debug "operation that failed"
Examine raw API responses and error messages
```

Skill not finding the right files:
```bash
claude --verbose "run the audit skill on this project"
Watch Glob and Read calls to verify file targeting
```

Unexpectedly slow skill execution:
```bash
claude --debug "slow operation" 2>&1 | grep "execution time"
Identify which tool calls are taking the most time
```

## Interpreting Verbose Output

The verbose and debug outputs can be overwhelming at first. Focus on these key sections:

1. Tool Selection: Shows which tools Claude chose and why
2. Execution Results: Shows what each tool returned
3. Reasoning Steps: Shows the model's chain of thought
4. Errors and Warnings: Highlights issues requiring attention
5. Token counts: Shows context usage, useful for diagnosing truncation issues

When debugging skill issues, start with verbose mode (`--verbose`) and escalate to debug mode (`--debug`) only if you need more detail.

A useful mental model: verbose mode answers "what did the skill do," while debug mode answers "what did the model actually see and how did the API respond." Most skill problems are in the first category.

## Filtering Verbose Output

Raw debug output from a complex skill can run to thousands of lines. Use filtering to focus on what matters:

```bash
Show only tool selection decisions
claude --verbose "task" 2>&1 | grep "Selected:"

Show only errors and warnings
claude --debug "task" 2>&1 | grep -E "\[ERROR\]|\[WARN\]"

Show token usage across the session
claude --debug "task" 2>&1 | grep "tokens"

Show timing for all tool calls
claude --debug "task" 2>&1 | grep "execution time"
```

These one-liners let you extract a specific diagnostic signal from a noisy trace without reading line by line.

## Optimizing Your Debug Workflow

Rather than running verbose mode constantly, use it strategically:

- Enable verbose mode only when actively debugging
- Redirect debug output to a file for later analysis: `claude --debug task > debug.log 2>&1`
- Use grep to filter output: `claude --debug task | grep -i error`
- Create aliases for common debugging scenarios:

```bash
alias claude-debug='claude --debug 2>&1 | tee debug-$(date +%Y%m%d-%H%M%S).log'
alias claude-verbose='claude --verbose 2>&1 | tee verbose-$(date +%Y%m%d-%H%M%S).log'
```

The `tee` command writes output to both the terminal and a log file simultaneously, so you can watch in real time and review the full trace later.

For repeatable debugging during skill development, create a test script that runs the skill with verbose mode and checks for expected patterns in the output:

```bash
#!/bin/bash
test-skill-debug.sh

OUTPUT=$(claude --verbose "run tdd skill on src/auth.ts" 2>&1)

Verify skill loaded correctly
echo "$OUTPUT" | grep -q "Skill context loaded: tdd.md" && echo "PASS: skill loaded" || echo "FAIL: skill not loaded"

Verify it read the target file
echo "$OUTPUT" | grep -q "Read result.*auth.ts" && echo "PASS: correct file read" || echo "FAIL: wrong file"

Verify test file was written
echo "$OUTPUT" | grep -q "Write complete.*auth.*test" && echo "PASS: tests written" || echo "FAIL: no test output"
```

This kind of lightweight assertion script turns verbose output into an automated quality check during skill development.

## Integration with Skill Development

When developing custom skills, verbose mode becomes invaluable for:

- Testing skill prompts and instructions
- Verifying tool availability and permissions
- Understanding model behavior with your skill
- Iterating on skill improvements based on actual traces

The pdf skill, tdd skill, and other specialized skills all benefit from verbose debugging when you're troubleshooting or optimizing their behavior.

A particularly effective pattern during skill development is the "trace-compare" cycle: run the skill with verbose mode on a known-good input, save the trace as a baseline, then compare subsequent traces as you modify the skill definition. Differences in tool selection or reasoning steps immediately reveal whether your changes had the intended effect.

```bash
Capture baseline trace
claude --verbose "test input" 2>&1 > baseline.log

Make changes to your skill .md file
...

Capture new trace
claude --verbose "test input" 2>&1 > updated.log

Compare
diff baseline.log updated.log
```

The diff output shows exactly how your skill modification changed model behavior, making it easy to validate improvements and catch unintended regressions.


## Related

- [Claude temperature settings guide](/claude-temperature-settings-guide/) — How to configure temperature and sampling parameters in Claude
---

- [Claude shortcuts guide](/claude-shortcuts-complete-guide/) — Complete guide to Claude Code keyboard shortcuts and slash commands
Mastering Claude Code's verbose mode transforms debugging from guesswork into systematic analysis. By understanding what happens inside the "black box," you gain control over your AI-assisted development workflow and can build more reliable, predictable skill integrations.

---

---

<div class="mastery-cta">

I hit this exact error six months ago. Then I wrote a CLAUDE.md that tells Claude my stack, my conventions, and my error handling patterns. Haven't seen it since.

I run 5 Claude Max subs, 16 Chrome extensions serving 50K users, and bill $500K+ on Upwork. These CLAUDE.md templates are what I actually use. Not theory — production configs.

**[Grab the templates — $99 once, free forever →](https://zovo.one/lifetime?utm_source=ccg&utm_medium=cta-error&utm_campaign=claude-code-verbose-mode-debugging-tips)**

47/500 founding spots. Price goes up when they're gone.

</div>

Related Reading

- [Claude Skill .md Format: Complete Specification Guide](/claude-skill-md-format-complete-specification-guide/)
- [Claude Code Crashes When Loading Skill: Debug Steps](/claude-code-crashes-when-loading-skill-debug-steps/)
- [Claude Code Output Quality: How to Improve Results](/claude-code-output-quality-how-to-improve-results/)
- [Troubleshooting Hub](/troubleshooting-hub/)

Built by theluckystrike. More at [zovo.one](https://zovo.one)
- [Claude Code Verbose Mode: Debug Output Guide 2026](/claude-code-verbose-mode-debug-output-2026/)
