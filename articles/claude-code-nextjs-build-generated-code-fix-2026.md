---
title: "Next.js Build Fails With Generated Code — Fix (2026)"
permalink: /claude-code-nextjs-build-generated-code-fix-2026/
description: "Fix Next.js build errors in Claude-generated code. Handle 'use client' directives, server component boundaries, and dynamic imports."
last_tested: "2026-04-22"
render_with_liquid: false
---

## The Error

```
Error: You're importing a component that needs useState. It only works in a Client Component
but none of its parents are marked with "use client", so they're Server Components by default.

  ,----
1 | import { useState } from 'react';
  :          ^^^^^^^^
  `----
```

This error occurs when Claude generates a component using React hooks (useState, useEffect) without adding the `"use client"` directive, in a Next.js App Router project where files are Server Components by default.

## The Fix

1. Add the `"use client"` directive to the top of the component file:

```typescript
"use client";

import { useState } from 'react';

export default function MyComponent() {
  const [count, setCount] = useState(0);
  return <button onClick={() => setCount(c => c + 1)}>{count}</button>;
}
```

2. Tell Claude about your Next.js architecture in CLAUDE.md:

```bash
echo '- Next.js App Router: files are Server Components by default. Add "use client" to any file using hooks, event handlers, or browser APIs.' >> CLAUDE.md
```

3. Rebuild:

```bash
npx next build
```

## Why This Happens

Next.js 13+ App Router treats all components as Server Components by default. Components that use React hooks, browser APIs, or event handlers must be explicitly marked as Client Components with `"use client"`. Claude often generates components without this directive because it does not distinguish between Server and Client Component boundaries.

## If That Doesn't Work

- If the component uses both server and client logic, split it:

```
app/
  page.tsx          (Server Component - data fetching)
  ClientForm.tsx    (Client Component - "use client" + hooks)
```

- For dynamic imports with SSR disabled:

```typescript
import dynamic from 'next/dynamic';
const Chart = dynamic(() => import('./Chart'), { ssr: false });
```

- Check for indirect hook usage through imported utilities.

## Prevention

Add this to your `CLAUDE.md`:

```markdown
# Next.js App Router
- Default: Server Components. Add "use client" for hooks/events/browser APIs.
- Never import useState/useEffect in Server Components.
- Split pages: server logic in page.tsx, interactive parts in ClientComponent.tsx.
- Run npx next build after every change to catch boundary errors.
```


## Related

- [process exited with code 1 fix](/claude-code-process-exited-code-1-fix/) — How to fix Claude Code process exited with code 1 error
