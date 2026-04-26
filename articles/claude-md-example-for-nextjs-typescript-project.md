---
layout: default
title: "Claude MD Example For Next.js (2026)"
description: "A practical guide to using Claude Code with Next.js and TypeScript. Learn how to create effective skill files, automate component generation, and."
date: 2026-03-14
last_modified_at: 2026-04-17
author: "Claude Skills Guide"
permalink: /claude-md-example-for-nextjs-typescript-project/
categories: [guides]
reviewed: true
score: 7
tags: [claude-code, claude-skills]
render_with_liquid: false
geo_optimized: true
---
{% raw %}
Building modern web applications with Next.js and TypeScript requires efficient workflows and consistent code patterns. Claude Code, combined with well-structured skill files in Markdown format, transforms how developers approach full-stack development. This guide provides concrete examples of setting up and using Claude skills specifically designed for Next.js TypeScript projects.

## Why Claude Skills Matter for Next.js Projects

Before diving into examples, it is worth understanding what makes Claude skills particularly valuable in a Next.js TypeScript context. Without a skill file, each prompt to Claude starts from scratch. You might get excellent TypeScript on one component and inconsistent patterns on the next. You might get a Client Component when you needed a Server Component. Skill files solve this by encoding your team's conventions once and reusing them across every interaction.

The difference between a project with and without Claude skills looks like this in practice:

| Workflow | Without Skills | With Skills |
|---|---|---|
| Component generation | Manual prompting, inconsistent props pattern | Single invocation, typed interface every time |
| API route creation | Copy-paste boilerplate, varies per developer | Consistent Zod validation, error handling baked in |
| Test scaffolding | Developer writes tests from memory | Vitest spec file generated alongside implementation |
| Onboarding | New dev reads docs, asks questions | New dev inherits skills, generates conformant code immediately |
| Code review overhead | High, catch inconsistencies manually | Lower, Claude enforces conventions before review |

The return on investment compounds as your project grows. A skill file written once pays dividends across hundreds of generated files.

## Setting Up Your Next.js Project with Claude Skills

Before creating skill files, initialize a Next.js project with TypeScript:

```bash
npx create-next-app@latest my-app --typescript --tailwind --eslint
cd my-app
```

After initialization, create a dedicated skills folder for your Next.js workflow. Place custom skill files in `~/.claude/skills/` or within your project repository for version control. Each skill follows the `.md` file extension and uses YAML front matter for configuration.

A recommended project layout that keeps skills close to the codebase they serve:

```
my-app/
 .claude/
 skills/
 nextjs-component.md
 nextjs-api-route.md
 nextjs-page-layout.md
 nextjs-tdd.md
 src/
 app/
 components/
 lib/
 tsconfig.json
 package.json
```

Storing skills inside `.claude/skills/` at the project root means every team member picks them up automatically when they open the repo in Claude Code. No manual installation, no documentation to follow.

## Creating a Next.js Component Generation Skill

The most practical starting point is a skill that generates components with proper TypeScript typing and Next.js best practices. Here is a complete example:

```markdown
---
name: nextjs-component
description: Generate TypeScript React components for Next.js with App Router
---

Next.js Component Generator

You generate type-safe React components following Next.js 14+ App Router conventions.

Component Structure

Every component must include:
1. Proper TypeScript interface for props
2. "use client" directive when using hooks
3. Tailwind CSS classes for styling
4. Proper export statement

Props Interface Pattern

Use explicit interfaces rather than inline types:

```typescript
interface ButtonProps {
 children: React.ReactNode;
 onClick?: () => void;
 variant?: 'primary' | 'secondary' | 'outline';
 disabled?: boolean;
 className?: string;
}
```

When I ask you to create a component, generate complete files with all imports, interfaces, and implementation.
```

This skill demonstrates several key patterns. The front matter declares the skill name and description. The body provides specific guidance on component structure that Claude will follow when generating code.

When you invoke this skill and ask for a Button component, Claude produces something like the following every single time. no prompting variation, no missing types:

```typescript
// src/components/Button.tsx

interface ButtonProps {
 children: React.ReactNode;
 onClick?: () => void;
 variant?: 'primary' | 'secondary' | 'outline';
 disabled?: boolean;
 className?: string;
}

export function Button({
 children,
 onClick,
 variant = 'primary',
 disabled = false,
 className = '',
}: ButtonProps) {
 const baseClasses = 'px-4 py-2 rounded font-medium transition-colors focus:outline-none focus:ring-2';

 const variantClasses = {
 primary: 'bg-blue-600 text-white hover:bg-blue-700 focus:ring-blue-500',
 secondary: 'bg-gray-100 text-gray-900 hover:bg-gray-200 focus:ring-gray-400',
 outline: 'border border-gray-300 text-gray-700 hover:bg-gray-50 focus:ring-gray-400',
 };

 return (
 <button
 onClick={onClick}
 disabled={disabled}
 className={`${baseClasses} ${variantClasses[variant]} ${disabled ? 'opacity-50 cursor-not-allowed' : ''} ${className}`}
 >
 {children}
 </button>
 );
}
```

Without the skill file, that same request might return an untyped component, miss the variant union, or omit the focus ring classes. The skill makes the output deterministic.

## Server vs. Client Components: Encoding the Decision

One of the most common mistakes in Next.js App Router projects is misusing Server and Client Components. Add a decision section to your component skill so Claude chooses correctly:

```markdown
Server vs. Client Decision

Default to Server Components unless the component:
- Uses React hooks (useState, useEffect, useReducer, etc.)
- Accesses browser-only APIs (window, document, localStorage)
- Uses event handlers attached directly to JSX (onClick, onChange, etc.)
- Relies on third-party libraries that require client context

For Client Components, add "use client"; as the very first line before imports.
For Server Components, omit the directive entirely. do not add a comment.
```

With this rule in the skill, a data display component stays as a Server Component and only interactive widgets get the `"use client"` directive. This keeps your bundle sizes optimal without requiring the developer to make the decision manually each time.

## Generating API Routes with Type Safety

Next.js API routes benefit significantly from TypeScript. Create a skill focused on route handler generation:

```markdown
---
name: nextjs-api-route
description: Create Next.js 14 API routes with Zod validation and proper typing
---

API Route Generator

Generate Next.js App Router route handlers with these requirements:

Route Handler Structure

```typescript
import { NextRequest, NextResponse } from 'next/server';
import { z } from 'zod';

const inputSchema = z.object({
 email: z.string().email(),
 name: z.string().min(2).optional(),
});

export async function POST(request: NextRequest) {
 try {
 const body = await request.json();
 const validated = inputSchema.parse(body);

 // Your logic here

 return NextResponse.json({ success: true, data: validated });
 } catch (error) {
 return NextResponse.json(
 { success: false, error: 'Validation failed' },
 { status: 400 }
 );
 }
}
```

Always use Zod for input validation and explicit return typing.
```

A production-ready extension of this pattern adds HTTP method typing and structured error responses:

```typescript
// src/app/api/users/route.ts

import { NextRequest, NextResponse } from 'next/server';
import { z } from 'zod';

const createUserSchema = z.object({
 email: z.string().email('Invalid email format'),
 name: z.string().min(2, 'Name must be at least 2 characters'),
 role: z.enum(['admin', 'editor', 'viewer']).default('viewer'),
});

type CreateUserInput = z.infer<typeof createUserSchema>;

interface ApiResponse<T> {
 success: boolean;
 data?: T;
 error?: string;
 details?: z.ZodError['errors'];
}

export async function POST(
 request: NextRequest
): Promise<NextResponse<ApiResponse<CreateUserInput>>> {
 try {
 const body = await request.json();
 const validated = createUserSchema.parse(body);

 // Persist to database here
 // const user = await db.user.create({ data: validated });

 return NextResponse.json(
 { success: true, data: validated },
 { status: 201 }
 );
 } catch (error) {
 if (error instanceof z.ZodError) {
 return NextResponse.json(
 {
 success: false,
 error: 'Validation failed',
 details: error.errors,
 },
 { status: 422 }
 );
 }

 return NextResponse.json(
 { success: false, error: 'Internal server error' },
 { status: 500 }
 );
 }
}

export async function GET(
 request: NextRequest
): Promise<NextResponse<ApiResponse<CreateUserInput[]>>> {
 const { searchParams } = new URL(request.url);
 const role = searchParams.get('role');

 // Query database here
 // const users = await db.user.findMany({ where: role ? { role } : undefined });

 return NextResponse.json({ success: true, data: [] });
}
```

The key improvement over the basic pattern is the generic `ApiResponse<T>` type on the return value. This gives you compile-time guarantees that every response shape is correct, and IDEs surface the type when callers use `fetch` with typed wrappers.

## Skill Comparison: Basic vs. Enhanced API Route Skills

| Feature | Basic Skill | Enhanced Skill |
|---|---|---|
| Zod input validation | Yes | Yes |
| Generic response typing | No | Yes |
| ZodError differentiation | No | Yes, returns 422 |
| HTTP method coverage | POST only | POST + GET |
| Status codes | 200 / 400 | 201 / 422 / 500 |
| Database placeholder | No | Yes, commented hint |
| Type inference from schema | No | Yes, `z.infer<typeof schema>` |

Building the enhanced version into your skill file from the start costs nothing but pays off during every code review.

## Integrating Testing with the TDD Skill

Pair your Next.js skills with the tdd skill for test-driven development workflows. The tdd skill provides structured prompts for generating unit tests, integration tests, and end-to-end tests using Vitest and Playwright. When working on complex components, invoke both skills together to generate implementation and tests in parallel.

A dedicated nextjs-tdd skill for your project might look like this:

```markdown
---
name: nextjs-tdd
description: Generate Vitest unit tests and Playwright e2e tests for Next.js components and routes
---

Next.js TDD Helper

When given a component or API route, generate corresponding test files.

Unit Test Pattern (Vitest + Testing Library)

```typescript
import { describe, it, expect, vi } from 'vitest';
import { render, screen, fireEvent } from '@testing-library/react';
import { Button } from './Button';

describe('Button', () => {
 it('renders children correctly', () => {
 render(<Button>Click me</Button>);
 expect(screen.getByText('Click me')).toBeInTheDocument();
 });

 it('calls onClick when clicked', () => {
 const handleClick = vi.fn();
 render(<Button onClick={handleClick}>Click me</Button>);
 fireEvent.click(screen.getByText('Click me'));
 expect(handleClick).toHaveBeenCalledOnce();
 });

 it('applies disabled state correctly', () => {
 render(<Button disabled>Click me</Button>);
 expect(screen.getByRole('button')).toBeDisabled();
 });
});
```

API Route Test Pattern

```typescript
import { describe, it, expect } from 'vitest';
import { POST } from './route';
import { NextRequest } from 'next/server';

describe('POST /api/users', () => {
 it('creates a user with valid data', async () => {
 const request = new NextRequest('http://localhost/api/users', {
 method: 'POST',
 body: JSON.stringify({ email: 'test@example.com', name: 'Test User' }),
 });
 const response = await POST(request);
 const data = await response.json();
 expect(response.status).toBe(201);
 expect(data.success).toBe(true);
 });

 it('returns 422 for invalid email', async () => {
 const request = new NextRequest('http://localhost/api/users', {
 method: 'POST',
 body: JSON.stringify({ email: 'not-an-email', name: 'Test' }),
 });
 const response = await POST(request);
 expect(response.status).toBe(422);
 });
});
```

Generate both unit tests and a brief Playwright spec when asked.
```

Having a dedicated test skill means the testing standard travels with the team. Senior developers write the skill once; junior developers invoke it and produce tests that match the project's conventions without needing a mentor to review the approach.

## Page Layouts and Frontend Design Patterns

The frontend-design skill complements Next.js development by providing guidance on responsive layouts, Tailwind configuration, and design system implementation. Combine these skills when building multi-page applications:

```markdown
---
name: nextjs-page-layout
description: Create Next.js page layouts with proper metadata and responsive design
---

Page Layout Generator

Generate pages with these Next.js 14 App Router patterns:

Page with Metadata

```typescript
import type { Metadata } from 'next';

export const metadata: Metadata = {
 title: 'Page Title',
 description: 'Page description for SEO',
 openGraph: {
 title: 'Page Title',
 description: 'Page description',
 type: 'website',
 },
};

export default function Page() {
 return (
 <main className="min-h-screen p-8">
 <h1 className="text-4xl font-bold">Page Title</h1>
 </main>
 );
}
```

Include proper metadata exports for every page.
```

An expanded page layout skill adds dynamic metadata for content-driven routes:

```typescript
// src/app/blog/[slug]/page.tsx

import type { Metadata } from 'next';
import { notFound } from 'next/navigation';

interface PageProps {
 params: { slug: string };
}

export async function generateMetadata(
 { params }: PageProps
): Promise<Metadata> {
 // Fetch post data for dynamic metadata
 const post = await getPost(params.slug);

 if (!post) {
 return { title: 'Post Not Found' };
 }

 return {
 title: post.title,
 description: post.excerpt,
 openGraph: {
 title: post.title,
 description: post.excerpt,
 type: 'article',
 publishedTime: post.publishedAt,
 authors: [post.author],
 },
 twitter: {
 card: 'summary_large_image',
 title: post.title,
 description: post.excerpt,
 },
 };
}

export async function generateStaticParams() {
 const posts = await getAllPosts();
 return posts.map((post) => ({ slug: post.slug }));
}

export default async function BlogPostPage({ params }: PageProps) {
 const post = await getPost(params.slug);

 if (!post) {
 notFound();
 }

 return (
 <article className="max-w-3xl mx-auto px-4 py-12">
 <header className="mb-8">
 <h1 className="text-4xl font-bold mb-4">{post.title}</h1>
 <time className="text-gray-500 text-sm">
 {new Date(post.publishedAt).toLocaleDateString()}
 </time>
 </header>
 <div
 className="prose prose-lg"
 dangerouslySetInnerHTML={{ __html: post.contentHtml }}
 />
 </article>
 );
}
```

By encoding both the static and dynamic metadata patterns in the page layout skill, you ensure every page in the project ships SEO-ready without developers needing to remember the Next.js metadata API shape.

## Managing Project Documentation

For larger Next.js projects, the supermemory skill helps maintain project context and documentation. Use it to track architectural decisions, component libraries, and API contracts across your codebase. When working with design teams, the pdf skill enables extracting requirements from design specifications and converting them to actionable development tasks.

A practical supermemory entry for a Next.js project might capture decisions like this:

```markdown
Architecture Decision: Data Fetching Strategy

Date: 2026-03-01
Decision: Use React Server Components for all data fetching. No client-side
fetch calls except for real-time features. SWR used only for mutation
optimistic updates.

Rationale: Reduces client bundle size, improves initial page load, simplifies
cache invalidation via Next.js revalidatePath.

Components affected: ProductList, UserProfile, BlogPost, SearchResults
```

Storing these decisions in supermemory means Claude can reference them in future sessions. When a developer asks why a component is a Server Component, Claude can surface the decision record rather than making a guess.

## Real-World Workflow Example

Consider a typical development session with Claude and these skills:

1. Initialize task: Use nextjs-component to generate a new Card component with props interface
2. Add validation: Apply nextjs-api-route to create the corresponding API endpoint
3. Write tests: Invoke the nextjs-tdd skill to generate Vitest unit tests for both
4. Document: Use supermemory to record the component API for future reference
5. Extract from designs: If working from a PDF mockup, use the pdf skill to parse and generate layout code

This workflow demonstrates how multiple skills work together. Each skill handles a specific aspect of development while maintaining consistency across your project.

Here is what an actual session sequence looks like in practice using the Claude Code CLI:

```bash
Step 1: Generate the Card component
claude --skill nextjs-component "Create a Card component with title, description, image, and href props. Image should be optional."

Step 2: Generate the supporting API route
claude --skill nextjs-api-route "Create a GET route at /api/cards that returns a paginated list of cards with optional category filter"

Step 3: Generate tests for both
claude --skill nextjs-tdd "Generate Vitest tests for the Card component and the /api/cards GET route we just created"

Step 4: Document the pattern
claude --skill supermemory "Record: Card component accepts CardProps interface, GET /api/cards returns PaginatedResponse, added 2026-03-22"
```

Each command is short, focused, and produces output that conforms to your project standards. Contrast this with an ad-hoc workflow where each prompt reinvents the conventions.

## Common Pitfalls and How Skills Fix Them

Several recurring mistakes in Next.js TypeScript projects are solved directly by well-written skills.

Missing `async` on Server Components that fetch data. A skill can mandate: "All Server Components that call fetch or database functions must be declared async." Claude then produces `export default async function Page()` correctly every time.

Forgetting `notFound()` in dynamic routes. Add a rule to the page layout skill: "Every dynamic route must call `notFound()` when the resource does not exist. Never return null or an empty state instead." This prevents 200 responses on pages that should 404.

Untyped `params` and `searchParams` in pages. The page layout skill can include the correct interface so Claude never generates a page without typed params:

```typescript
interface PageProps {
 params: { slug: string };
 searchParams: { [key: string]: string | string[] | undefined };
}
```

Inline styles instead of Tailwind. A simple rule in the component skill. "Never use the style prop. All styling must use Tailwind utility classes.". eliminates the entire class of inconsistency.

Catching errors without differentiating types. The API route skill's Zod error differentiation pattern (shown earlier) prevents generic 500 responses where a 422 would be more accurate and actionable for API consumers.

## Best Practices for Next.js Skill Development

Keep skill files focused on single responsibilities rather than combining too many patterns. Smaller, composable skills are easier to maintain and combine. Use the tools front matter to restrict available actions. this prevents accidental file modifications outside the intended scope.

Version control your skill files within your project repository. This ensures team members share consistent development patterns and simplifies onboarding new developers to your Next.js codebase.

Test your skills by invoking them with specific prompts. Review the generated code for TypeScript correctness, Next.js best practices adherence, and alignment with your project's coding standards. Iterate on skill descriptions until output consistently meets expectations.

A maintenance checklist for Next.js skills:

| Trigger | Action |
|---|---|
| Next.js major version upgrade | Review Server/Client Component rules, update metadata API patterns |
| Zod major version upgrade | Update schema syntax examples in API route skill |
| New linting rule added | Add the rule as a constraint in the component skill |
| New developer joins team | Walk through each skill file as part of onboarding |
| Recurring code review comment | Add the corrected pattern to the relevant skill |

Treat skill files as living documentation. A skill that reflects your current standards saves more review time than a skill that reflects how you worked six months ago.

## Conclusion

Claude skills in Markdown format provide a powerful mechanism for standardizing Next.js TypeScript development workflows. By creating focused skills for components, API routes, pages, and tests, you establish consistent patterns across your entire codebase. The combination of specialized skills like the tdd skill, the frontend-design skill, and supermemory creates a comprehensive development environment that scales with your project complexity.

The investment in writing a good skill file is small compared to the accumulated time saved across hundreds of code generation tasks. Start with the three core skills. component, API route, and page layout. then extend them as your project's conventions evolve. Every rule you encode in a skill is a convention that no longer needs to be communicated in a code review.

---


**Try it:** Paste your error into our [Error Diagnostic](/diagnose/) for an instant fix.
---

<div class="mastery-cta">

This site was built by 5 autonomous agents running in tmux while I was in Bali. 2,500 articles. Zero manual work. 100% quality gate pass rate.

The orchestration configs, sprint templates, and quality gates that made that possible are in the Zovo Lifetime bundle. Along with 16 CLAUDE.md templates and 80 tested prompts.

**[See how the pipeline works →](https://zovo.one/lifetime?utm_source=ccg&utm_medium=cta-skills&utm_campaign=claude-md-example-for-nextjs-typescript-project)**

$99 once. I'm a solo dev in Da Nang. This is how I scale.

</div>

Related Reading

- [Claude MD Example for Android Kotlin Project](/claude-md-example-for-android-kotlin-project/)
- [Claude.md Example for Data Science Python Project](/claude-md-example-for-data-science-python-project/)
- [Claude MD Example for .NET ASP.NET Core Project](/claude-md-example-for-dotnet-aspnet-core-project/)

Built by theluckystrike. More at [zovo.one](https://zovo.one)
{% endraw %}


**Find the right skill →** Browse 155+ skills in our [Skill Finder](/skill-finder/).

**Quick setup →** Launch your project with our [Project Starter](/starter/).
