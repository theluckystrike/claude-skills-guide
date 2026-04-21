---
title: "Circular Dependency Detected in Build — Fix (2026)"
permalink: /claude-code-circular-dependency-detected-build-fix-2026/
description: "Fix circular dependency errors in builds. Use madge to detect cycles and refactor shared types into a separate module."
last_tested: "2026-04-22"
render_with_liquid: false
---

## The Error

```
Warning: Circular dependency detected:
  src/models/user.ts -> src/services/auth.ts -> src/models/user.ts
This may cause undefined imports at runtime.
```

This error occurs when two or more modules import each other, directly or through a chain. Bundlers warn about it; at runtime, one of the imports resolves to `undefined`.

## The Fix

1. Detect all circular dependencies:

```bash
npx madge --circular --extensions ts src/
```

2. Break the cycle by extracting shared types:

```bash
# Create a shared types file:
mkdir -p src/types
# Move shared interfaces to src/types/user.types.ts
```

```typescript
// src/types/user.types.ts (new shared file)
export interface User { id: string; name: string; }

// src/models/user.ts (import from shared)
import { User } from '../types/user.types';

// src/services/auth.ts (import from shared, not from models)
import { User } from '../types/user.types';
```

3. Verify the cycle is broken:

```bash
npx madge --circular --extensions ts src/
# Should output: No circular dependency found!
```

## Why This Happens

Claude generates code that imports from the most logical module, but in large codebases this creates import chains that loop back to the originating module. At build time, one module in the cycle is not yet initialized when the other tries to import from it. The result is `undefined` values for what should be valid exports.

## If That Doesn't Work

- Use lazy imports (dynamic import) to break runtime cycles:

```typescript
// Instead of top-level import:
async function getAuth() {
  const { AuthService } = await import('./services/auth');
  return new AuthService();
}
```

- Use dependency injection to decouple the modules.
- Merge tightly coupled modules into a single file if they are small.

## Prevention

Add this to your `CLAUDE.md`:

```markdown
# Module Architecture
- No circular dependencies allowed. Run: npx madge --circular src/
- Shared types go in src/types/. Services import from types, not from each other.
- Use dependency injection for cross-service communication.
```
