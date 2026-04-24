---
layout: default
title: "Claude Code for ts-pattern (2026)"
description: "Claude Code for ts-pattern — practical guide with working examples, tested configurations, and tips for developer workflows."
date: 2026-04-18
permalink: /claude-code-for-ts-pattern-matching-workflow-guide/
categories: [workflow, niche-tools]
tags: [claude-code, ts-pattern, workflow]
---

## The Setup

You are using ts-pattern for exhaustive pattern matching in TypeScript — a library that provides type-safe switch/case on steroids with exhaustive checking, nested pattern matching, and discriminated union handling. Claude Code can use ts-pattern, but it writes verbose if/else chains or basic switch statements instead.

## What Claude Code Gets Wrong By Default

1. **Writes if/else chains for type narrowing.** Claude generates `if (result.type === 'success') { } else if (result.type === 'error') { }` chains. ts-pattern uses `match(result).with({ type: 'success' }, ...)` which is more readable and type-safe.

2. **Uses switch statements without exhaustive checks.** Claude writes `switch (action.type)` that silently ignores new variants. ts-pattern's `.exhaustive()` causes a compile-time error when you add a new variant without handling it.

3. **Ignores nested pattern matching.** Claude destructures nested objects manually to check deep properties. ts-pattern matches nested structures: `.with({ user: { role: 'admin' } }, ...)` without manual destructuring.

4. **Does not use wildcard and guard patterns.** Claude writes explicit checks for every value. ts-pattern provides `P.string`, `P.number`, `P.when(predicate)` for flexible pattern matching without listing every possible value.

## The CLAUDE.md Configuration

```
# ts-pattern Pattern Matching Project

## Library
- Pattern matching: ts-pattern (match, P)
- Import: import { match, P } from 'ts-pattern'

## ts-pattern Rules
- Use match(value) for discriminated unions and complex branching
- .with(pattern, handler) for each case
- .exhaustive() at the end — compile error if cases missing
- .otherwise(handler) for default case (opt-out of exhaustive)
- Nested patterns: .with({ status: 'ok', data: { items: P.array() } })
- Guards: P.when(x => x > 0), P.string.startsWith('admin')
- Wildcards: P._ matches anything, P.string matches any string
- Select: P.select() extracts matched values

## Conventions
- Use match() instead of if/else chains for 3+ branches
- Always use .exhaustive() unless default is intentional
- Prefer match() for discriminated unions (type, status, kind)
- Use P.select('name') to extract values from patterns
- Group related patterns with .with() chaining
- Match returns a value — use for assignments, not side effects
```

## Workflow Example

You want to handle API response types exhaustively. Prompt Claude Code:

"Refactor the API response handler to use ts-pattern. The response can be success with data, error with message and code, loading, or idle. Handle each state exhaustively and extract the relevant data from each pattern."

Claude Code should use `match(response).with({ status: 'success' }, ({ data }) => ...).with({ status: 'error', code: P.select() }, (code) => ...).with({ status: 'loading' }, () => ...).with({ status: 'idle' }, () => ...).exhaustive()`, using `P.select()` to extract values and ensuring all states are handled at compile time.

## Common Pitfalls

1. **Using `.otherwise()` when `.exhaustive()` is better.** Claude defaults to `.otherwise(() => null)` as a catch-all. This defeats exhaustive checking — when you add a new variant, the otherwise handler silently swallows it. Use `.exhaustive()` unless a default is genuinely correct.

2. **Pattern specificity ordering.** Claude puts generic patterns before specific ones. ts-pattern matches the first matching pattern — a `.with(P.string, ...)` before `.with('admin', ...)` means 'admin' is never reached. Put specific patterns first.

3. **Missing the `P` namespace import.** Claude tries to use `P.string` or `P.when()` without importing `P` from ts-pattern. The pattern helpers are under the `P` namespace — `import { match, P } from 'ts-pattern'`.

## Related Guides

- [Best Way to Use Claude Code with TypeScript Projects](/best-way-to-use-claude-code-with-typescript-projects/)
- [Claude Code for Algorithm Complexity Optimization Guide](/claude-code-for-algorithm-complexity-optimization-guide/)
- [Best Way to Use Claude Code for Large File Refactoring](/best-way-to-use-claude-code-for-large-file-refactoring/)

## Related Articles

- [Claude Code for Carvel imgpkg Workflow Tutorial](/claude-code-for-carvel-imgpkg-workflow-tutorial/)
- [Claude Code for Hackathon Development Workflow](/claude-code-for-hackathon-development-workflow/)
- [How to Use VSCode Reload: Hot Config (2026)](/claude-code-for-hot-config-reload-workflow-guide/)
- [Is Claude Code Good Enough For — Complete Developer Guide](/is-claude-code-good-enough-for-senior-developer-workflows/)
- [Claude Code for Bottleneck Identification Workflow](/claude-code-for-bottleneck-identification-workflow/)
- [Claude Code for Quantization with bitsandbytes Workflow](/claude-code-for-quantization-with-bitsandbytes-workflow/)
- [Claude Code for Flux Bootstrap Workflow Tutorial](/claude-code-for-flux-bootstrap-workflow-tutorial/)
- [Claude Code for Homebrew Bundle Workflow Tutorial](/claude-code-for-homebrew-bundle-workflow-tutorial/)
- [Claude Code for Effect-TS — Workflow Guide](/claude-code-for-effect-ts-workflow-guide/)
