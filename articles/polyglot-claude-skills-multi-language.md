---
title: "Polyglot Claude Skills (2026)"
description: "Design Claude Code skills that adapt to multiple programming languages using path-conditional activation, language-specific references, and runtime detection."
permalink: /polyglot-claude-skills-multi-language/
categories: [skills, 2026]
tags: [claude-code, claude-skills, polyglot, multi-language]
last_updated: 2026-04-19
---

## The Specific Situation

Your codebase has a Python data pipeline (`src/pipeline/`), a TypeScript API (`src/api/`), a Rust CLI tool (`src/cli/`), and Go microservices (`src/services/`). You want a single "test generator" skill that adapts to each language: pytest patterns for Python, vitest for TypeScript, `#[test]` modules for Rust, and Go table-driven tests. You also want a universal "code review" skill that checks language-agnostic concerns (naming, complexity, error handling) but applies language-specific idioms.

## Technical Foundation

The `paths` field in skill frontmatter supports glob patterns with brace expansion: `"**/*.{ts,tsx}"`, `"**/*.py"`, `"**/*.rs"`, `"**/*.go"`. A single skill can match multiple patterns, or you can create language-specific skills that activate only for their language.

Dynamic context injection can detect the active language at runtime: `!`ls src/ | head -5`` or `!`cat package.json 2>/dev/null && echo "node" || cat Cargo.toml 2>/dev/null && echo "rust" || echo "unknown"`` injects language indicators before Claude processes the skill.

The `shell` field supports `bash` (default) or `powershell`, relevant for cross-platform skill portability.

## The Working SKILL.md

Single polyglot skill at `.claude/skills/test-gen/SKILL.md`:

```yaml
---
name: test-gen
description: >
  Generate unit tests for any function in the codebase. Adapts to
  the target language: pytest for Python, vitest for TypeScript,
  #[test] for Rust, table-driven for Go. Detects language from
  file extension and applies idiomatic patterns.
paths:
  - "**/*.ts"
  - "**/*.tsx"
  - "**/*.py"
  - "**/*.rs"
  - "**/*.go"
allowed-tools: Read Grep Bash(*)
---

# Polyglot Test Generator

## Language Detection
Determine language from the target file's extension:
- `.ts`, `.tsx` → TypeScript
- `.py` → Python
- `.rs` → Rust
- `.go` → Go

## TypeScript Test Patterns (vitest)
```typescript
import { describe, it, expect } from 'vitest'
import { functionName } from '../module'

describe('functionName', () => {
  it('should handle normal input', () => {
    expect(functionName(input)).toBe(expected)
  })

  it('should throw on invalid input', () => {
    expect(() => functionName(null)).toThrow()
  })
})
```
File location: Same directory structure under `__tests__/` or `.test.ts` suffix.
Assertion style: `expect().toBe()`, `expect().toEqual()` for objects.

## Python Test Patterns (pytest)
```python
import pytest
from module import function_name

class TestFunctionName:
    def test_normal_input(self):
        assert function_name(input) == expected

    def test_invalid_input(self):
        with pytest.raises(ValueError):
            function_name(None)

    @pytest.mark.parametrize("input,expected", [
        (1, "one"),
        (2, "two"),
    ])
    def test_parameterized(self, input, expected):
        assert function_name(input) == expected
```
File location: `tests/` directory mirroring `src/` structure.
Naming: `test_` prefix on functions, `Test` prefix on classes.

## Rust Test Patterns
```rust
#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_normal_input() {
        assert_eq!(function_name(input), expected);
    }

    #[test]
    #[should_panic(expected = "error message")]
    fn test_invalid_input() {
        function_name(invalid_input);
    }
}
```
Location: Inline `mod tests` at bottom of source file.
Integration tests: `tests/` directory at crate root.

## Go Test Patterns (table-driven)
```go
func TestFunctionName(t *testing.T) {
    tests := []struct {
        name     string
        input    InputType
        expected OutputType
        wantErr  bool
    }{
        {"normal input", validInput, expectedOutput, false},
        {"invalid input", invalidInput, zero, true},
    }

    for _, tt := range tests {
        t.Run(tt.name, func(t *testing.T) {
            got, err := FunctionName(tt.input)
            if (err != nil) != tt.wantErr {
                t.Errorf("FunctionName() error = %v, wantErr %v", err, tt.wantErr)
                return
            }
            if got != tt.expected {
                t.Errorf("FunctionName() = %v, want %v", got, tt.expected)
            }
        })
    }
}
```
File location: Same package, `_test.go` suffix.
No assertion library required (use `t.Errorf`).

## Universal Rules (all languages)
1. Test the public API, not internal implementation
2. Each test covers one behavior (single assertion preferred)
3. Test names describe the scenario, not the function
4. Include edge cases: empty input, null/nil, boundary values
5. Mock external dependencies (network, filesystem, database)
```

## Common Problems and Fixes

**Skill triggers on wrong language.** A `.ts` file in a Python project (maybe a build config) activates the TypeScript path. Narrow the paths: use `"src/api/**/*.ts"` instead of `"**/*.ts"` if TypeScript files only live in the API directory.

**Test framework detection is wrong.** The skill assumes vitest for TypeScript, but the project uses Jest. Add a detection step: "Check package.json for vitest or jest in devDependencies before generating test code."

**Rust inline tests versus integration tests confusion.** Unit tests go in `mod tests` at the bottom of the source file. Integration tests go in the `tests/` directory and can only test the public API. The skill should ask whether the target is a unit test or integration test before generating.

**Go test file placed in wrong package.** In Go, test files must be in the same package as the code they test (for white-box testing) or in `package_test` (for black-box testing). The skill should detect the package name from the source file and match it in the test file.

## Production Gotchas

Brace expansion in `paths` (`"**/*.{ts,py,rs,go}"`) is supported but creates a very broad activation surface. In a polyglot monorepo, this skill may activate when you are working on configuration files that happen to have `.py` or `.ts` extensions (like `conftest.py` or `jest.config.ts`). Consider whether a narrower path pattern is more appropriate.

The skill's code blocks are large, which pushes it toward the 500-line SKILL.md limit. For production use, move each language's test patterns to `references/typescript-tests.md`, `references/python-tests.md`, etc. The main SKILL.md then just describes the detection logic and references the appropriate file.

## Checklist

- [ ] Language detection logic matches your project's actual file layout
- [ ] Test framework verified against project config (not assumed)
- [ ] Code patterns validated for each language's latest idiomatic style
- [ ] Paths narrowed to avoid false activation on config files
- [ ] Large language sections moved to `references/` if SKILL.md exceeds 300 lines

## Related Guides

- [Claude Skills for Monorepo Projects](/claude-skills-for-monorepo-projects/) -- organizing skills across language-specific packages
- [Claude Skill Composition Patterns](/claude-skill-composition-patterns/) -- combining language-specific skills
- [Claude Skills Performance Optimization](/claude-skills-performance-optimization/) -- managing token cost of large polyglot skills
