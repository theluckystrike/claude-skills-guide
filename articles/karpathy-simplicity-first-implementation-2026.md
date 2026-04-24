---
title: "Implement Simplicity First in CLAUDE.md (2026)"
description: "Copy-paste CLAUDE.md rules that enforce Karpathy's Simplicity First principle — with complexity budgets, abstraction gates, and file limits."
permalink: /karpathy-simplicity-first-implementation-2026/
last_tested: "2026-04-22"
render_with_liquid: false
---

# Implement Simplicity First in CLAUDE.md (2026)

Production-ready CLAUDE.md blocks that stop Claude Code from overengineering. Each version includes a complexity budget, abstraction gates, and concrete rules for file creation.

## The Principle

Start with the simplest solution that works. Add complexity only when requirements force it. See the [principle overview](/karpathy-simplicity-first-principle-claude-code-2026/) for background.

## Why It Matters

Overengineering is Claude Code's most expensive default behavior. A 50-line solution ballooned to 300 lines across 6 files costs 6x more tokens to generate, takes longer to review, and introduces maintenance burden for abstractions you didn't ask for.

## CLAUDE.md Implementation

### Minimal Version

```markdown
## Simplicity Rule
- Implement the simplest version that works. No preemptive abstractions.
- If a function works, don't wrap it in a class.
- If inline code works, don't extract it to a utility.
- Ask: "Would the simplest approach work here?" If yes, use it.
```

### Standard Version

```markdown
## Simplicity First — Complexity Budget

### File Budget
- A task that could be done in 1 file should not create 3 files.
- Before creating a new file, explain why existing files can't hold this code.

### Abstraction Gate
- Interfaces/abstract classes: only when 3+ concrete implementations exist NOW (not "might exist later")
- Factory/builder patterns: only when construction logic is genuinely complex (5+ parameters, conditional assembly)
- Event systems: only when 3+ independent consumers need the same event
- Plugin/middleware patterns: only when the extension point is an explicit requirement

### Indirection Limit
- Maximum 1 hop between the caller and the actual work. If A calls B which calls C which does the work, flatten to A calls C.
- Exception: framework-required layers (middleware in Express, route handlers in Next.js)

### Code Budget
- If the simple version is under 50 lines, do not create an abstracted version.
- If the simple version is 50-200 lines, add abstraction only if there's clear repetition.
- Over 200 lines: discuss decomposition approach before implementing.
```

### Strict Version

```markdown
## Simplicity First — Strict Mode

### BEFORE writing ANY code, answer:
1. What is the minimum code needed to satisfy this requirement?
2. Am I adding anything "just in case" or "for future flexibility"?
3. Would a junior developer understand this in under 5 minutes?

### NEVER (without explicit request):
- Create abstract base classes with single implementations
- Add dependency injection containers
- Build configuration systems for fewer than 5 config values
- Create utility files for functions used in only one place
- Implement observer/event patterns for fewer than 3 consumers
- Add caching layers without measured performance problems
- Create type-safe builders for simple object construction

### ALWAYS prefer:
- Functions over classes (for stateless operations)
- Direct imports over dependency injection (unless testing demands it)
- Hardcoded values over config files (for 1-3 values)
- Inline validation over validation frameworks (for 1-3 fields)
- String concatenation over template engines (for simple strings)
- If/else over strategy pattern (for 2-3 branches)
```

## Before/After Examples

### Before: Over-Abstracted Logger

```typescript
// Claude Code without simplicity rules
interface LogTransport { write(msg: string): void; }
class ConsoleTransport implements LogTransport { /* ... */ }
class FileTransport implements LogTransport { /* ... */ }
class Logger {
  private transports: LogTransport[] = [];
  addTransport(t: LogTransport) { this.transports.push(t); }
  log(level: string, msg: string) {
    this.transports.forEach(t => t.write(`[${level}] ${msg}`));
  }
}
// + factory + config + 3 files + 80 lines
```

### After: Simple Logger

```typescript
// With simplicity rules — project only needs console logging
function log(level: 'info' | 'warn' | 'error', msg: string) {
  console.log(`[${level}] ${new Date().toISOString()} ${msg}`);
}
```

5 lines. If the project later needs file transport, refactor then.

### Before: Config System for 3 Values

```typescript
// Claude Code builds a config system
const config = new ConfigLoader()
  .fromEnv()
  .fromFile('.config.json')
  .withDefaults({ port: 3000, host: 'localhost', debug: false })
  .validate(ConfigSchema)
  .build();
// + 3 files + 120 lines
```

### After: Direct Values

```typescript
const PORT = parseInt(process.env.PORT ?? '3000');
const HOST = process.env.HOST ?? 'localhost';
const DEBUG = process.env.DEBUG === 'true';
```

3 lines. No config loader, no schema, no file parsing.

## Common Mistakes

1. **Banning all patterns** — the goal isn't zero abstractions. It's zero premature abstractions. When complexity is earned (3+ implementations, measured performance problems, explicit extensibility requirements), use patterns.

2. **Strict mode in creative exploration** — if you're prototyping and don't know what you're building yet, strict simplicity can be too constraining. Use the minimal version during exploration.

3. **Not accounting for team size** — solo developers can hold more context, so simpler code works well. Large teams may need more structure for coordination. Calibrate accordingly.

## Related Principles

- [Simplicity First: Before and After Code](/karpathy-simplicity-first-examples-2026/) — more examples
- [Fix Claude Code Overengineering](/karpathy-simplicity-debugging-overengineered-2026/) — debugging complexity
- [CLAUDE.md Best Practices](/claude-md-best-practices-10-templates-compared-2026/) — where these rules fit in your CLAUDE.md
- [The Claude Code Playbook](/playbook/) — workflow integration
