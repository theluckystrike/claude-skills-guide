---

layout: default
title: "Claude Code Next.js App Router Migration Guide"
description: "A practical guide for developers migrating from Next.js Pages Router to App Router using Claude Code. Includes code examples, common pitfalls, and."
date: 2026-03-14
author: "Claude Skills Guide"
permalink: /claude-code-nextjs-app-router-migration-guide/
categories: [guides]
reviewed: true
score: 7
tags: [claude-code, claude-skills]
---


# Claude Code Next.js App Router Migration Guide

Migrating from Next.js Pages Router to App Router represents one of the most significant architectural shifts in the framework's history. This transition involves moving from a directory-based routing system to a file-system based approach with React Server Components, new data fetching patterns, and fundamentally different caching mechanisms. For developers working with Claude Code, this migration becomes considerably smoother when you use the right skills and workflows.

This guide walks you through the practical aspects of migrating your Next.js application to the App Router while maximizing your productivity with Claude Code and related skills.

## Understanding the Key Differences

Before diving into code changes, you need to understand what actually changes between the two routing systems. The App Router introduces React Server Components by default, which means your components run on the server unless you explicitly opt into client-side rendering with the `"use client"` directive.

In the Pages Router, every page was essentially a server-side rendered page by default, with optional static generation through `getStaticProps`. The App Router replaces this with a more granular approach: `async` components automatically become Server Components, while you use Server Actions for mutations instead of API routes.

```javascript
// Pages Router - pages/api/users.js
export default function handler(req, res) {
  const users = getUsers();
  res.status(200).json(users);
}

// App Router - app/api/users/route.js
import { NextResponse } from 'next/server';

export async function GET() {
  const users = await getUsers();
  return NextResponse.json(users);
}
```

Notice how the API route structure changes from a handler function to route modules with explicit HTTP method exports.

## Setting Up Claude Code for the Migration

Proper tool configuration significantly impacts migration efficiency. Install the **frontend-design** skill first—it provides component patterns and styling workflows that align with App Router conventions. The **tdd** skill helps you maintain test coverage during the transition, ensuring nothing breaks.

Create a Claude.md file in your project root to establish migration-specific guidelines:

```markdown
# Migration Guidelines

- Use App Router conventions for all new files
- Prefer Server Components over Client Components
- Use Server Actions for form submissions and mutations
- Implement loading.tsx and error.tsx for each route segment
- Migrate API routes to Route Handlers (route.js)
```

This tells Claude Code exactly how to approach new code and modifications during your migration.

## Migrating Pages to App Router

The most straightforward migration path involves moving each page individually while maintaining functionality. Start with simple pages that have minimal data fetching requirements.

For a typical pages directory structure:

```
pages/
├── _app.tsx
├── _document.tsx
├── index.tsx
├── about.tsx
├── products/
│   ├── index.tsx
│   └── [id].tsx
└── api/
    └── products/
        └── [id].js
```

Your target App Router structure becomes:

```
app/
├── layout.tsx
├── page.tsx
├── about/
│   └── page.tsx
├── products/
│   ├── page.tsx
│   └── [id]/
│       └── page.tsx
└── api/
    └── products/
        └── [id]/
            └── route.js
```

## Converting getStaticProps and getServerSideProps

This represents the most substantial change in the migration. The App Router replaces these data fetching functions with async component patterns:

```typescript
// Pages Router - pages/products/[id].tsx
export async function getStaticPaths() {
  const products = await getAllProducts();
  return {
    paths: products.map(p => ({ params: { id: p.id } })),
    fallback: 'blocking'
  };
}

export async function getStaticProps({ params }) {
  const product = await getProduct(params.id);
  return { props: { product } };
}

// App Router - app/products/[id]/page.tsx
async function getProduct(id: string) {
  const res = await fetch(`https://api.example.com/products/${id}`, {
    cache: 'no-store' // equivalent to getServerSideProps
  });
  return res.json();
}

export default async function ProductPage({ params }) {
  const product = await getProduct(params.id);
  return <ProductDetail product={product} />;
}
```

For static generation with caching, use `generateStaticParams` instead of `getStaticPaths`:

```typescript
// app/products/[id]/page.tsx
export async function generateStaticParams() {
  const products = await getAllProducts();
  return products.map(product => ({
    id: product.id
  }));
}

export const revalidate = 3600; // ISR: revalidate every hour
```

## Handling _app.tsx and _document.tsx

The App Router uses `layout.tsx` files that wrap your pages. This replaces both `_app.tsx` and `_document.tsx` functionality:

```typescript
// app/layout.tsx
import './globals.css';
import { Metadata } from 'next';

export const metadata: Metadata = {
  title: 'My App',
  description: 'Application description',
};

export default function RootLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return (
    <html lang="en">
      <body>{children}</body>
    </html>
  );
}
```

For fonts, use `next/font` which automatically optimizes and loads Google Fonts:

```typescript
import { Inter } from 'next/font/google';

const inter = Inter({ subsets: ['latin'] });

export default function RootLayout({ children }) {
  return (
    <html lang="en">
      <body className={inter.className}>{children}</body>
    </html>
  );
}
```

## Migrating API Routes

API routes become Route Handlers using the Web Fetch API:

```javascript
// pages/api/products/[id].js
export default function handler(req, res) {
  const { query: { id }, method } = req;
  
  switch(method) {
    case 'GET':
      // Fetch single product
      res.status(200).json(getProduct(id));
      break;
    case 'PUT':
      // Update product
      res.status(200).json(updateProduct(id, req.body));
      break;
    case 'DELETE':
      // Delete product
      res.status(200).json(deleteProduct(id));
      break;
  }
}

// app/api/products/[id]/route.js
import { NextResponse } from 'next/server';

export async function GET(request, { params }) {
  const product = await getProduct(params.id);
  return NextResponse.json(product);
}

export async function PUT(request, { params }) {
  const body = await request.json();
  const product = await updateProduct(params.id, body);
  return NextResponse.json(product);
}

export async function DELETE(request, { params }) {
  await deleteProduct(params.id);
  return NextResponse.json({ success: true });
}
```

## Using Server Actions

One of the App Router's most powerful features replaces API routes for mutations. Define server actions directly in your components or separate files:

```typescript
// app/actions.ts
'use server';

export async function createProduct(formData: FormData) {
  const name = formData.get('name');
  const price = formData.get('price');
  
  const product = await db.product.create({
    name: name as string,
    price: Number(price)
  });
  
  return { success: true, product };
}

// app/products/new/page.tsx
'use client';

import { createProduct } from '@/app/actions';

export default function NewProduct() {
  return (
    <form action={createProduct}>
      <input name="name" type="text" required />
      <input name="price" type="number" required />
      <button type="submit">Create</button>
    </form>
  );
}
```

## Implementing Error and Loading States

The App Router provides built-in error handling through error.tsx files:

```typescript
// app/products/[id]/error.tsx
'use client';

export default function Error({
  error,
  reset,
}: {
  error: Error;
  reset: () => void;
}) {
  return (
    <div>
      <h2>Something went wrong!</h2>
      <button onClick={() => reset()}>Try again</button>
    </div>
  );
}
```

Loading states use loading.tsx:

```typescript
// app/products/loading.tsx
export default function Loading() {
  return <p>Loading products...</p>;
}
```

## Recommended Skills for Migration

Beyond **frontend-design** and **tdd**, several skills accelerate your migration workflow. The **pdf** skill helps generate migration documentation. For teams managing this transition, **supermemory** provides persistent context about migration decisions and patterns discovered.

The **skill-creator** skill becomes valuable when you need to build custom migration prompts specific to your codebase patterns.

## Common Pitfalls to Avoid

Many developers struggle with the client-server boundary in App Router. Remember: components are Server Components by default. Only add `"use client"` when you need hooks like `useState`, `useEffect`, or event handlers.

Another frequent issue involves `next/image` and `next/font` imports—these work differently in App Router and may require configuration updates in next.config.js.

Finally, API routes that rely on request body parsing need adjustment since Route Handlers use the Web Fetch API's Request object.

## Testing Your Migration

Run your development server and test each migrated route systematically:

```bash
npm run dev
```

Check both the UI rendering and any API endpoints. Use the Network tab in browser DevTools to verify proper caching headers and Server Component streaming behavior.

The **playwright** skill provides excellent E2E testing capabilities for validating your migration completeness.

---


## Related Reading

- [Claude Code for Beginners: Complete Getting Started Guide](/claude-skills-guide/claude-code-for-beginners-complete-getting-started-2026/)
- [Best Claude Skills for Developers in 2026](/claude-skills-guide/best-claude-skills-for-developers-2026/)
- [Claude Skills Guides Hub](/claude-skills-guide/guides-hub/)

Built by theluckystrike — More at [zovo.one](https://zovo.one)
