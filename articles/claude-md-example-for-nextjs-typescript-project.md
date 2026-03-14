---
layout: default
title: "Claude MD Example for Next.js TypeScript Project"
description: "A practical guide to using Claude Code with Next.js and TypeScript. Learn how to create effective skill files, automate component generation, and streamline your full-stack development workflow."
date: 2026-03-14
author: theluckystrike
permalink: /claude-md-example-for-nextjs-typescript-project/
---

# Claude MD Example for Next.js TypeScript Project

Building modern web applications with Next.js and TypeScript requires efficient workflows and consistent code patterns. Claude Code, combined with well-structured skill files in Markdown format, transforms how developers approach full-stack development. This guide provides concrete examples of setting up and using Claude skills specifically designed for Next.js TypeScript projects.

## Setting Up Your Next.js Project with Claude Skills

Before creating skill files, initialize a Next.js project with TypeScript:

```bash
npx create-next-app@latest my-app --typescript --tailwind --eslint
cd my-app
```

After initialization, create a dedicated skills folder for your Next.js workflow. Place custom skill files in `~/.claude/skills/` or within your project repository for version control. Each skill follows the `.md` file extension and uses YAML front matter for configuration.

## Creating a Next.js Component Generation Skill

The most practical starting point is a skill that generates components with proper TypeScript typing and Next.js best practices. Here is a complete example:

```markdown
---
name: nextjs-component
description: Generate TypeScript React components for Next.js with App Router
tools: [Write, Read, Bash]
---

# Next.js Component Generator

You generate type-safe React components following Next.js 14+ App Router conventions.

## Component Structure

Every component must include:
1. Proper TypeScript interface for props
2. "use client" directive when using hooks
3. Tailwind CSS classes for styling
4. Proper export statement

## Props Interface Pattern

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

This skill demonstrates several key patterns. The front matter declares the skill name, description, and available tools. The body provides specific guidance on component structure that Claude will follow when generating code.

## Generating API Routes with Type Safety

Next.js API routes benefit significantly from TypeScript. Create a skill focused on route handler generation:

```markdown
---
name: nextjs-api-route
description: Create Next.js 14 API routes with Zod validation and proper typing
tools: [Write, Read, Bash]
---

# API Route Generator

Generate Next.js App Router route handlers with these requirements:

## Route Handler Structure

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

## Integrating Testing with the TDD Skill

Pair your Next.js skills with the tdd skill for test-driven development workflows. The tdd skill provides structured prompts for generating unit tests, integration tests, and end-to-end tests using Vitest and Playwright. When working on complex components, invoke both skills together to generate implementation and tests in parallel.

## Page Layouts and Frontend Design Patterns

The frontend-design skill complements Next.js development by providing guidance on responsive layouts, Tailwind configuration, and design system implementation. Combine these skills when building multi-page applications:

```markdown
---
name: nextjs-page-layout
description: Create Next.js page layouts with proper metadata and responsive design
tools: [Write, Read, Glob]
---

# Page Layout Generator

Generate pages with these Next.js 14 App Router patterns:

## Page with Metadata

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

## Managing Project Documentation

For larger Next.js projects, the supermemory skill helps maintain project context and documentation. Use it to track architectural decisions, component libraries, and API contracts across your codebase. When working with design teams, the pdf skill enables extracting requirements from design specifications and converting them to actionable development tasks.

## Real-World Workflow Example

Consider a typical development session with Claude and these skills:

1. **Initialize task**: Use nextjs-component to generate a new Card component with props interface
2. **Add validation**: Apply nextjs-api-route to create the corresponding API endpoint
3. **Write tests**: Invoke tdd skill to generate Vitest unit tests for both
4. **Document**: Use supermemory to record the component API for future reference
5. **Extract from designs**: If working from a PDF mockup, use pdf to parse and generate layout code

This workflow demonstrates how multiple skills work together. Each skill handles a specific aspect of development while maintaining consistency across your project.

## Best Practices for Next.js Skill Development

Keep skill files focused on single responsibilities rather than combining too many patterns. Smaller, composable skills are easier to maintain and combine. Use the tools front matter to restrict available actions—this prevents accidental file modifications outside the intended scope.

Version control your skill files within your project repository. This ensures team members share consistent development patterns and simplifies onboarding new developers to your Next.js codebase.

Test your skills by invoking them with specific prompts. Review the generated code for TypeScript correctness, Next.js best practices adherence, and alignment with your project's coding standards. Iterate on skill descriptions until output consistently meets expectations.

## Conclusion

Claude skills in Markdown format provide a powerful mechanism for standardizing Next.js TypeScript development workflows. By creating focused skills for components, API routes, pages, and tests, you establish consistent patterns across your entire codebase. The combination of specialized skills like tdd, frontend-design, and supermemory creates a comprehensive development environment that scales with your project complexity.

Built by theluckystrike — More at [zovo.one](https://zovo.one)
