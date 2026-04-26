---
layout: default
title: "Next.js Build Fails With Generated Code (2026)"
permalink: /claude-code-nextjs-build-generated-code-fix-2026/
date: 2026-04-20
description: "Fix Next.js build errors in Claude-generated code. Handle 'use client' directives, server component boundaries, and dynamic imports."
last_tested: "2026-04-22"
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


## Related Error Messages

This fix also applies if you see variations of this error:

- Connection or process errors with similar root causes in the same subsystem
- Timeout variants where the operation starts but does not complete
- Permission variants where access is denied to the same resource
- Configuration variants where the same setting is missing or malformed

If your specific error message differs slightly from the one shown above, the fix is likely the same. The key indicator is the operation that failed (shown in the stack trace) rather than the exact wording of the message.


## Frequently Asked Questions

### Does this error affect all operating systems?

This error can occur on macOS, Linux, and Windows (WSL). The exact error message may differ slightly between platforms, but the root cause and fix are the same. macOS users may see additional Gatekeeper or notarization prompts. Linux users should check that the relevant system packages are installed. Windows users should ensure they are running inside WSL2, not native Windows.

### Will this error come back after updating Claude Code?

Updates can occasionally reintroduce this error if the update changes default configurations or dependency requirements. After updating Claude Code, verify your project still builds and runs correctly. If the error returns, reapply the fix and check the changelog for breaking changes.

### Can this error cause data loss?

No, this error occurs before or during an operation and does not corrupt existing files. Claude Code's edit operations are atomic — they either complete fully or not at all. However, if the error occurs during a multi-step operation, you may have partial changes that need to be reviewed with `git diff` before continuing.

### How do I report this error to Anthropic if the fix does not work?

Open an issue at github.com/anthropics/claude-code with: (1) the full error message including stack trace, (2) your Node.js version (`node --version`), (3) your Claude Code version (`claude --version`), (4) your operating system and version, and (5) the command or operation that triggered the error.


## Related Guides

- [Claude Code Error: npm Install Fails in Skill Workflow](/claude-code-error-npm-install-fails-in-skill-workflow/)
- [Claude Code VS Code Extension Fails](/claude-code-vscode-extension-fails-to-activate-fix/)
- [Fix: Claude Code Auth Fails on Headless](/claude-code-headless-linux-auth/)
- [Update Fails Behind Corporate Proxy](/claude-code-update-fails-behind-proxy-fix-2026/)

<script type="application/ld+json">
{
  "@context": "https://schema.org",
  "@type": "FAQPage",
  "mainEntity": [
    {
      "@type": "Question",
      "name": "Does this error affect all operating systems?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "This error can occur on macOS, Linux, and Windows (WSL). The exact error message may differ slightly between platforms, but the root cause and fix are the same. macOS users may see additional Gatekeeper or notarization prompts."
      }
    },
    {
      "@type": "Question",
      "name": "Will this error come back after updating Claude Code?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "Updates can occasionally reintroduce this error if the update changes default configurations or dependency requirements. After updating Claude Code, verify your project still builds and runs correctly. If the error returns, reapply the fix and check the changelog for breaking changes."
      }
    },
    {
      "@type": "Question",
      "name": "Can this error cause data loss?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "No, this error occurs before or during an operation and does not corrupt existing files. Claude Code's edit operations are atomic — they either complete fully or not at all. However, if the error occurs during a multi-step operation, you may have partial changes that need to be reviewed with git..."
      }
    },
    {
      "@type": "Question",
      "name": "How do I report this error to Anthropic if the fix does not work?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "Open an issue at github.com/anthropics/claude-code with: (1) the full error message including stack trace, (2) your Node.js version (node --version), (3) your Claude Code version (claude --version), (4) your operating system and version, and (5) the command or operation that triggered the error."
      }
    }
  ]
}
</script>
