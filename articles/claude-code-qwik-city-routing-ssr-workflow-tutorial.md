---
layout: default
title: "Claude Code Qwik City Routing SSR Workflow Tutorial"
description: "Learn how to use Claude Code to build Qwik City applications with server-side rendering. Practical guide covering routing, SSR data loading, and."
date: 2026-03-14
author: "Claude Skills Guide"
permalink: /claude-code-qwik-city-routing-ssr-workflow-tutorial/
categories: [web-development, qwik, javascript-frameworks]
tags: [claude-code, claude-skills, qwik, qwik-city, ssr, routing, tutorial]
reviewed: true
score: 8
---

{% raw %}
# Claude Code Qwik City Routing SSR Workflow Tutorial

Qwik City is a revolutionary meta-framework that brings resumability to server-side rendering, dramatically improving application performance. Combined with Claude Code, you have a powerful duo for building modern web applications. This tutorial walks you through setting up Qwik City routing with SSR using Claude Code as your development assistant.

## Understanding Qwik City's Resumability Model

Before diving into routing, it's essential to understand what makes Qwik City special. Unlike traditional frameworks that hydrate the entire application on the client, Qwik uses **resumability**—the ability to pause server execution and resume it on the client without replaying all the logic.

This approach means your applications ship less JavaScript to the browser, resulting in faster load times and better SEO. Qwik City provides the routing layer and SSR capabilities on top of Qwik's core resumability engine.

### Why Combine Qwik City with Claude Code?

Claude Code excels at understanding complex codebases and generating boilerplate, explaining concepts, and helping debug issues. When working with Qwik City:

- **Scaffold routes quickly**: Describe your desired route structure, and Claude Code generates the files
- **Understand loaders and actions**: SSR data patterns can be confusing; Claude Code explains them clearly
- **Debug SSR issues**: Get help tracing through server and client code boundaries
- **Generate type-safe APIs**: Claude Code understands TypeScript and Qwik's type system

## Setting Up Your Qwik City Project

Start by creating a new Qwik City project. Claude Code can guide you through the initial setup:

```bash
npm create qwik@latest my-qwik-app
cd my-qwik-app
npm install
```

The project structure follows a file-based routing convention similar to Next.js or Nuxt. Your routes live in the `src/routes` directory, with each folder representing a route segment.

### Understanding the Route Structure

Qwik City's routing system uses directory-based routing:

```
src/routes/
├── index.tsx           # Homepage (/)
├── about/
│   └── index.tsx      # /about
├── blog/
│   ├── index.tsx      # /blog
│   └── [slug]/
│       └── index.tsx  # /blog/:slug (dynamic)
└── layout.tsx         # Shared layout for all routes
```

Claude Code can help you visualize this structure and explain how each file maps to routes in your application.

## Implementing SSR Data Loading with routeLoader$

Server-side data loading in Qwik City uses the `routeLoader$` function. This runs on the server during the initial request, and the data becomes available to your component without sending the loading logic to the client.

Here's a practical example of fetching blog posts server-side:

```typescript
import { component$ } from '@builder.io/qwik';
import { routeLoader$ } from '@builder.io/qwik-city';

interface BlogPost {
  id: string;
  title: string;
  excerpt: string;
}

export const useBlogPosts = routeLoader$(async () => {
  // This runs ONLY on the server
  const response = await fetch('https://api.example.com/posts');
  const posts = await response.json() as BlogPost[];
  return posts;
});

export default component$(() => {
  const posts = useBlogPosts();
  
  return (
    <ul>
      {posts.value.map((post) => (
        <li key={post.id}>{post.title}</li>
      ))}
    </ul>
  );
});
```

The key insight: `routeLoader$` creates a server-only data fetching function that runs during SSR. The client receives only the serialized data, not the fetch logic.

### Using Route Parameters

Dynamic routes capture URL parameters using square brackets. Here's how to use a slug parameter:

```typescript
import { component$ } from '@builder.io/qwik';
import { routeLoader$, useLocation } from '@builder.io/qwik-city';

export const usePost = routeLoader$(async (requestEvent) => {
  const slug = requestEvent.params.slug;
  const response = await fetch(`https://api.example.com/posts/${slug}`);
  return response.json();
});

export default component$(() => {
  const post = usePost();
  const loc = useLocation();
  
  return (
    <article>
      <h1>{post.value.title}</h1>
      <p>Slug: {loc.params.slug}</p>
    </article>
  );
});
```

## Creating Layouts and Nested Routes

Qwik City supports nested layouts for shared UI elements across multiple routes. The `layout.tsx` file in each directory wraps its child routes.

### Shared Layout Example

```typescript
// src/routes/layout.tsx
import { component$, Slot } from '@builder.io/qwik';
import { Link } from '@builder.io/qwik-city';

export default component$(() => {
  return (
    <header>
      <nav>
        <Link href="/">Home</Link>
        <Link href="/blog">Blog</Link>
        <Link href="/about">About</Link>
      </nav>
      <main>
        <Slot />
      </main>
      <footer>
        <p>© 2026 My Qwik App</p>
      </footer>
    </header>
  );
});
```

This layout wraps every route in your application. You can create nested layouts by adding `layout.tsx` files in subdirectories.

### Grouped Routes (Layouts Without URL Segment)

Sometimes you want routes grouped under a common layout without adding a URL segment. Use parentheses:

```
src/routes/
├── (marketing)/
│   ├── layout.tsx
│   ├── index.tsx      # / (no marketing prefix)
│   └── pricing.tsx   # /pricing
└── (app)/
    ├── layout.tsx
    └── dashboard/
        └── index.tsx  # /dashboard
```

Claude Code can help you understand when to use grouped routes and how they affect your URL structure.

## Form Handling with routeAction$

For handling form submissions in Qwik City, use `routeAction$`. This creates server-side action handlers that work without JavaScript and progressively enhance when JS loads.

```typescript
import { component$, Form } from '@builder.io/qwik';
import { routeAction$, z, zod$ } from '@builder.io/qwik-city';

export const useAddPost = routeAction$(
  async (data, requestEvent) => {
    // Server-side logic to save the post
    const savedPost = await db.posts.create({
      title: data.title,
      content: data.content,
    });
    return { success: true, postId: savedPost.id };
  },
  zod$({
    title: z.string().min(1),
    content: z.string().min(10),
  })
);

export default component$(() => {
  const addPost = useAddPost();
  
  return (
    <Form action={addPost}>
      <input name="title" placeholder="Post title" />
      <textarea name="content" placeholder="Content" />
      <button type="submit">Add Post</button>
      {addPost.value?.success && <p>Post created!</p>}
    </Form>
  );
});
```

## Best Practices for Qwik City SSR

When building with Qwik City and Claude Code, keep these practices in mind:

### 1. Keep Server and Client Code Separate

Qwik makes it easy to distinguish server-only code using `routeLoader$`, `routeAction$`, and `$` for lazy-loading. Claude Code can help you identify when code might accidentally leak to the client.

### 2. Use TypeScript for Better DX

Qwik City's type system works well with TypeScript. Define interfaces for your data and let TypeScript catch errors before runtime:

```typescript
interface Post {
  id: string;
  title: string;
  publishedAt: string;
}

export const usePosts = routeLoader$<Post[]>(async () => {
  // Return typed data
});
```

### 3. Leverage Progressive Enhancement

Always ensure your routes work without JavaScript. Qwik City handles this automatically with `routeAction$` and standard HTML forms. Test your forms with JavaScript disabled to verify.

### 4. Optimize Images and Assets

Use Qwik's image optimization features:

```typescript
import { Image } from '@unpic/qwik';
```

Claude Code can guide you through integrating image optimization for better Core Web Vitals.

## Debugging SSR Issues

When things go wrong in SSR, Claude Code becomes invaluable. Common issues include:

- **Hydration mismatches**: Client and server render different content
- **Missing environment variables**: API keys not available on server
- **Serialization errors**: Trying to pass non-serializable data

For debugging, check the server logs and use Qwik's built-in dev tools. Describe the error to Claude Code, and it can help trace through the SSR lifecycle to find the root cause.

## Conclusion

Qwik City combined with Claude Code provides a modern, performant approach to building web applications. The resumability model eliminates hydration overhead, while Claude Code helps you navigate routing, SSR data loading, and form handling patterns.

Start with simple routes, add `routeLoader$` for server data, and progressively add `routeAction$` for form handling. Claude Code can accelerate your learning by generating boilerplate, explaining concepts, and helping debug issues along the way.

Remember: the goal isn't to use every feature, but to leverage Qwik City's strengths where they matter most—typically in content-heavy pages where SEO and initial load performance are critical.
{% endraw %}

## Related Reading

- [Claude Code for Beginners: Complete Getting Started Guide](/claude-skills-guide/claude-code-for-beginners-complete-getting-started-2026/)
- [Best Claude Skills for Developers in 2026](/claude-skills-guide/best-claude-skills-for-developers-2026/)
- [Claude Skills Guides Hub](/claude-skills-guide/guides-hub/)

