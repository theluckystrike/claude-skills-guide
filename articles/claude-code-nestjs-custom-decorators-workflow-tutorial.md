---
layout: default
title: "Claude Code NestJS Custom Decorators Workflow Tutorial"
description: "Learn how to create custom decorators in NestJS with practical examples. This tutorial covers decorator composition, parameter decorators, and workflow patterns for building scalable NestJS applications with Claude Code."
date: 2026-03-14
author: "Claude Skills Guide"
permalink: /claude-code-nestjs-custom-decorators-workflow-tutorial/
categories: [tutorials]
tags: [claude-code, claude-skills, nestjs, decorators, typescript]
---

{% raw %}
# Claude Code NestJS Custom Decorators Workflow Tutorial

NestJS decorators are one of the most powerful features for building scalable backend applications. When combined with Claude Code's development workflow, you can create clean, maintainable, and type-safe decorator patterns that accelerate your development process. This tutorial walks you through creating custom decorators in NestJS while leveraging Claude Code for intelligent code generation and refactoring.

## Understanding NestJS Decorators

Decorators in NestJS allow you to add metadata to classes, methods, properties, and parameters. They follow the decorator pattern introduced in TypeScript and are extensively used throughout the NestJS framework for dependency injection, routing, and middleware configuration.

The most common decorator types in NestJS include:

- **Class decorators**: `@Controller()`, `@Injectable()`, `@Module()`
- **Method decorators**: `@Get()`, `@Post()`, `@Put()`, `@Delete()`
- **Parameter decorators**: `@Req()`, `@Res()`, `@Body()`, `@Param()`, `@Query()`

Creating custom decorators enables you to encapsulate repetitive logic, implement cross-cutting concerns, and build a more expressive API for your application.

## Creating Your First Custom Decorator

Let's start with a practical example. Suppose you need to track which user performed an action in your application for audit logging purposes. Instead of manually extracting the user from the request in every handler, you can create a custom decorator.

### The User Decorator

First, create a decorator file in your decorators folder:

```typescript
import { createParamDecorator, ExecutionContext } from '@nestjs/common';

export const CurrentUser = createParamDecorator(
  (data: string | undefined, ctx: ExecutionContext) => {
    const request = ctx.switchToHttp().getRequest();
    const user = request.user;

    return data ? user?.[data] : user;
  },
);
```

This decorator extracts the authenticated user from the request object. You can use it in your controllers like this:

```typescript
@Controller('posts')
export class PostsController {
  @Post()
  create(@CurrentUser() user: User, @Body() createPostDto: CreatePostDto) {
    return this.postsService.create(createPostDto, user.id);
  }

  @Get()
  findAll(@CurrentUser('id') userId: string) {
    return this.postsService.findAll(userId);
  }
}
```

The `CurrentUser` decorator handles two scenarios: when called without arguments, it returns the entire user object; when called with a property name like `'id'`, it returns just that specific property.

## Decorator Composition for Complex Workflows

As your application grows, you'll find yourself combining multiple decorators to handle complex authentication and authorization scenarios. NestJS allows you to compose decorators for cleaner, more expressive code.

### Creating Custom Method Decorators

Let's build a decorator that logs method execution time:

```typescript
import { SetMetadata } from '@nestjs/common';

export const TIMEOUT_KEY = 'timeout';
export const Timeout = (timeout: number) => SetMetadata(TIMEOUT_KEY, timeout);
```

Then create a guard that uses this metadata:

```typescript
@Injectable()
export class TimeoutGuard implements CanActivate {
  canActivate(context: ExecutionContext): boolean {
    const timeout = Reflector.get(
      TIMEOUT_KEY,
      context.getHandler(),
    );
    
    if (timeout) {
      // Implement timeout logic
      console.log(`Method timeout set to ${timeout}ms`);
    }
    
    return true;
  }
}
```

### Combining Decorators for Authorization

A more practical example combines multiple decorators to create an expressive authorization system:

```typescript
// roles.decorator.ts
export const Roles = (...roles: string[]) => SetMetadata('roles', roles);

// permissions.decorator.ts
export const Permissions = (...permissions: string[]) => 
  SetMetadata('permissions', permissions);

// combined decorator
export const RequireAuth = (config: { roles?: string[]; permissions?: string[] }) => {
  return (target: any, propertyKey: string, descriptor: PropertyDescriptor) => {
    if (config.roles) {
      Roles(...config.roles)(target, propertyKey, descriptor);
    }
    if (config.permissions) {
      Permissions(...config.permissions)(target, propertyKey, descriptor);
    }
  };
};
```

Use this combined decorator in your controller:

```typescript
@Controller('admin')
export class AdminController {
  @RequireAuth({ roles: ['admin'], permissions: ['users:read', 'users:write'] })
  @Get('users')
  findAllUsers() {
    return this.adminService.findAllUsers();
  }
}
```

## Parameter Decorators for Request Handling

Parameter decorators provide the most granular control over request handling. They allow you to extract specific parts of the request and inject them directly as function parameters.

### Building a Paginated Query Decorator

Here's how to create a decorator that automatically parses pagination parameters:

```typescript
import { createParamDecorator, ExecutionContext } from '@nestjs/common';

export interface PaginationParams {
  page: number;
  limit: number;
  offset: number;
}

export const Pagination = createParamDecorator(
  (data: Partial<PaginationParams> = {}, ctx: ExecutionContext): PaginationParams => {
    const request = ctx.switchToHttp().getRequest();
    const query = request.query;

    const page = parseInt(query.page || '1', 10);
    const limit = parseInt(query.limit || '10', 10);

    return {
      page: Math.max(1, page),
      limit: Math.min(100, Math.max(1, limit)),
      offset: (page - 1) * limit,
    };
  },
);
```

Usage in a controller becomes remarkably clean:

```typescript
@Controller('products')
export class ProductsController {
  @Get()
  findAll(@Pagination() pagination: PaginationParams) {
    return this.productsService.findAll(pagination);
  }
}
```

## Best Practices for Custom Decorators

When building custom decorators in your NestJS applications, follow these guidelines for maintainable and scalable code:

**Keep decorators focused and single-purpose**: Each decorator should handle one specific concern. This makes testing easier and keeps your code composable.

**Always type your decorators**: TypeScript's type system is essential for decorator development. Define proper interfaces for the data your decorators work with.

**Handle edge cases gracefully**: Your decorators should handle missing data gracefully. Return sensible defaults or throw descriptive errors.

**Document your decorators**: Since decorators can be cryptic, always add JSDoc comments explaining what the decorator does, what parameters it accepts, and what it returns.

**Test thoroughly**: Decorators are used throughout your application, so comprehensive testing is crucial. Test both success and failure scenarios.

## Integrating with Claude Code Workflow

Claude Code can significantly accelerate your decorator development workflow. When working on NestJS projects, you can leverage Claude Code to:

1. **Generate boilerplate**: Describe your decorator requirements and let Claude Code generate the initial implementation
2. **Refactor existing code**: Convert repetitive patterns into reusable decorators
3. **Add type safety**: Enhance decorators with proper TypeScript types
4. **Create tests**: Generate unit tests for your custom decorators
5. **Document automatically**: Add comprehensive documentation to your decorator implementations

For example, when you need a new decorator, you can describe it to Claude Code: "Create a decorator that extracts the current tenant ID from the request header and validates it against the database." Claude Code will generate a complete, type-safe implementation.

## Conclusion

Custom decorators in NestJS provide a powerful mechanism for building clean, maintainable, and expressive applications. By understanding how to create class, method, and parameter decorators, you can encapsulate cross-cutting concerns and reduce boilerplate code throughout your application.

The workflow patterns demonstrated in this tutorial—from simple user extraction to complex authorization systems—showcase the flexibility of NestJS's decorator system. Combined with Claude Code's intelligent development assistance, you can rapidly develop and iterate on custom decorator patterns that scale with your application.

Start with simple decorators and progressively build more complex compositions as your application evolves. This incremental approach ensures your decorators remain focused, testable, and maintainable over time.
{% endraw %}
