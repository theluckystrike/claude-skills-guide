---
title: "Claude Code Jest Test Runner Mock"
description: "Fix Claude Code Jest test runner mock conflicts. Reset mock state and fix module resolution ordering. Step-by-step solution."
permalink: /claude-code-jest-runner-mock-conflict-fix/
last_tested: "2026-04-21"
render_with_liquid: false
---

## The Error

```
FAIL src/__tests__/api.test.ts
  ● API Client › should call endpoint

    TypeError: Cannot read properties of undefined (reading 'mockImplementation')
      at Object.<anonymous> (src/__tests__/api.test.ts:15:22)

# Or:
jest.mock() calls must be at the top level of the module.
  Cannot call jest.mock() inside a function, test, or describe block.

# Or:
The module factory of `jest.mock()` is not allowed to reference
  any out-of-scope variables.
```

## The Fix

1. **Move jest.mock() to the top level and use factory functions**

```typescript
// WRONG — mock inside describe
describe("API", () => {
  jest.mock("./api-client");  // Error: not top level

// CORRECT — mock at module top level
jest.mock("./api-client", () => ({
  fetchData: jest.fn(),
}));

import { fetchData } from "./api-client";

describe("API", () => {
  beforeEach(() => {
    jest.clearAllMocks();  // Reset between tests
  });

  it("should call endpoint", () => {
    (fetchData as jest.Mock).mockResolvedValue({ data: "test" });
    // ... test logic
  });
});
```

2. **For Claude-generated tests, fix the mock variable scoping**

```typescript
// WRONG — referencing outer variable in mock factory
const mockFn = jest.fn();
jest.mock("./module", () => ({ handler: mockFn }));
// Error: mockFn is out of scope

// CORRECT — use inline mock or jest.mocked()
jest.mock("./module");
import { handler } from "./module";

it("works", () => {
  const mocked = jest.mocked(handler);
  mocked.mockReturnValue("test");
});
```

3. **Verify the fix:**

```bash
npx jest --testPathPattern="api.test" --verbose
# Expected: PASS with all tests green
```

## Why This Happens

Jest hoists `jest.mock()` calls to the top of the file during compilation, before any imports execute. This hoisting means mock factories cannot reference variables declared after the mock call — even though they appear before it in the source code. Claude Code sometimes generates mocks inside `describe` or `it` blocks, or creates factory functions that reference variables defined between the mock call and the import, both of which break Jest's hoisting semantics.

## If That Doesn't Work

- **Alternative 1:** Use `jest.spyOn()` instead of `jest.mock()` for targeted method mocking without hoisting issues: `jest.spyOn(module, 'method').mockReturnValue('test')`
- **Alternative 2:** Use manual mocks in `__mocks__/` directories which Jest discovers automatically
- **Check:** Run `npx jest --showConfig | grep transform` to verify your transform pipeline — TypeScript transforms can interfere with mock hoisting

## Prevention

Add to your `CLAUDE.md`:
```markdown
Place all jest.mock() calls at the file's top level, before imports. Use jest.mocked() for type-safe mock access. Call jest.clearAllMocks() in beforeEach. Never reference outer-scope variables in mock factory functions.
```

**Related articles:** [Jest Unit Testing Guide](/claude-code-jest-unit-testing-workflow-guide/), [Claude Code Breaks Tests Fix](/claude-code-breaks-existing-tests-after-changes-fix/), [Debugging Skills](/claude-code-debugging-skill/)

## See Also

- [Claude Code Jest Mock Modules and Spies Deep Dive Guide](/claude-code-jest-mock-modules-and-spies-deep-dive-guide/)
