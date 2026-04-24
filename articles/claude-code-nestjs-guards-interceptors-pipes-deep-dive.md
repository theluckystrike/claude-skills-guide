---

layout: default
title: "Claude Code NestJS Guards Interceptors"
description: "Master NestJS guards, interceptors, and pipes with Claude Code. Learn to build secure, efficient, and well-structured Node.js applications with."
date: 2026-03-14
last_modified_at: 2026-04-17
author: Claude Skills Guide
permalink: /claude-code-nestjs-guards-interceptors-pipes-deep-dive/
categories: [guides]
tags: [claude-code, claude-skills]
reviewed: true
score: 7
geo_optimized: true
---


Claude Code NestJS Guards Interceptors Pipes Detailed look

When building solid Node.js applications with NestJS, understanding guards, interceptors, and pipes is essential for creating maintainable and secure code. These three middleware-like components form the backbone of NestJS's request processing pipeline, each serving a distinct purpose in your application's lifecycle. This guide walks you through each concept with practical examples you can implement immediately in your projects.

## Understanding the NestJS Request Pipeline

Before diving into individual components, it's crucial to understand how requests flow through a NestJS application. When a client sends a request, it passes through several stages: first, the request hits guards for authorization, then pipes for validation and transformation, and finally, interceptors wrap the entire response process for logging, caching, or modification.

This layered approach allows you to keep your business logic clean by separating cross-cutting concerns from your route handlers. Claude Code can help you generate these components quickly while ensuring they follow NestJS best practices.

The full execution order in NestJS is worth committing to memory:

1. Middleware. runs before guards, used for logging or request mutation
2. Guards. authorization check; can block the request entirely
3. Interceptors (pre-handler). before the route handler executes
4. Pipes. validate and transform route arguments
5. Route handler. your controller method runs
6. Interceptors (post-handler). after the handler returns, can transform response
7. Exception filters. catch any unhandled exceptions at any prior stage

Understanding this order prevents a common source of confusion: pipes run after guards. If your guard depends on a transformed or validated value, you need a different approach, extract the raw value in the guard directly from the request context rather than relying on a pipe to have already processed it.

## Guards: Securing Your Routes

Guards determine whether a request should be handled by a route handler. They return a boolean value, true allows the request to proceed, while false blocks access. Unlike middleware, guards have access to the `ExecutionContext`, giving them information about the route being accessed.

## Creating an Auth Guard

```typescript
import { Injectable, CanActivate, ExecutionContext, UnauthorizedException } from '@nestjs/common';

@Injectable()
export class AuthGuard implements CanActivate {
 canActivate(context: ExecutionContext): boolean {
 const request = context.switchToHttp().getRequest();
 const token = request.headers.authorization?.replace('Bearer ', '');

 if (!token || !this.validateToken(token)) {
 throw new UnauthorizedException('Invalid or missing token');
 }

 return true;
 }

 private validateToken(token: string): boolean {
 // Your token validation logic here
 return token.length > 0;
 }
}
```

## JWT-Based Auth Guard with User Injection

A real-world auth guard typically decodes a JWT, verifies the signature, and attaches the decoded user to the request so downstream handlers don't need to re-parse the token:

```typescript
import { Injectable, CanActivate, ExecutionContext, UnauthorizedException } from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import { Request } from 'express';

@Injectable()
export class JwtAuthGuard implements CanActivate {
 constructor(private jwtService: JwtService) {}

 async canActivate(context: ExecutionContext): Promise<boolean> {
 const request = context.switchToHttp().getRequest<Request>();
 const token = this.extractToken(request);

 if (!token) {
 throw new UnauthorizedException('No token provided');
 }

 try {
 const payload = await this.jwtService.verifyAsync(token, {
 secret: process.env.JWT_SECRET,
 });
 // Attach the decoded user to the request object
 request['user'] = payload;
 } catch {
 throw new UnauthorizedException('Token is invalid or expired');
 }

 return true;
 }

 private extractToken(request: Request): string | undefined {
 const [type, token] = request.headers.authorization?.split(' ') ?? [];
 return type === 'Bearer' ? token : undefined;
 }
}
```

Now any controller method can access `@Request() req` and read `req.user` without touching JWT logic.

## Role-Based Access Control

Extending guard behavior with custom metadata enables role-based access control (RBAC) without duplicating logic across controllers:

```typescript
// roles.decorator.ts
import { SetMetadata } from '@nestjs/common';
export const Roles = (...roles: string[]) => SetMetadata('roles', roles);

// roles.guard.ts
import { Injectable, CanActivate, ExecutionContext } from '@nestjs/common';
import { Reflector } from '@nestjs/core';

@Injectable()
export class RolesGuard implements CanActivate {
 constructor(private reflector: Reflector) {}

 canActivate(context: ExecutionContext): boolean {
 const requiredRoles = this.reflector.getAllAndOverride<string[]>('roles', [
 context.getHandler(),
 context.getClass(),
 ]);

 if (!requiredRoles) {
 return true; // No roles required, allow access
 }

 const { user } = context.switchToHttp().getRequest();
 return requiredRoles.some(role => user?.roles?.includes(role));
 }
}
```

Apply it to a controller:

```typescript
@Controller('admin')
@UseGuards(JwtAuthGuard, RolesGuard)
export class AdminController {
 @Get('dashboard')
 @Roles('admin', 'superuser')
 getDashboard() {
 return { message: 'Admin dashboard' };
 }

 @Delete('users/:id')
 @Roles('superuser')
 deleteUser(@Param('id') id: string) {
 return { message: `Deleted user ${id}` };
 }
}
```

Using guards in Controllers applies them at the controller or method level:

```typescript
@Controller('users')
@UseGuards(AuthGuard)
export class UsersController {
 @Get(':id')
 findOne(@Param('id') id: string) {
 return { id, name: 'John Doe' };
 }
}
```

Actionable Advice: Chain multiple guards in sequence. NestJS evaluates them left to right, put authentication guards before authorization guards so the user object is populated when the roles guard runs.

## Pipes: Transforming and Validating Data

Pipes operate on method arguments before they reach your route handler. They're perfect for data validation, type transformation, and parsing input from requests. NestJS provides built-in pipes like `ValidationPipe` and `ParseIntPipe`, but you can create custom pipes for specific needs.

## Built-in Pipe Examples

```typescript
@Controller('products')
export class ProductsController {
 @Get(':id')
 findOne(@Param('id', ParseIntPipe) id: number) {
 // id is already converted to a number
 return { id, name: 'Product' };
 }

 @Post()
 create(@Body(new ValidationPipe({ whitelist: true })) createProductDto: CreateProductDto) {
 // Only validated properties in createProductDto
 return createProductDto;
 }
}
```

## DTO Validation with class-validator

The full power of `ValidationPipe` comes from pairing it with `class-validator` decorators on your DTOs. This approach moves validation rules directly onto the data shape, making them discoverable and self-documenting:

```typescript
import { IsString, IsEmail, IsInt, Min, Max, IsOptional, Length } from 'class-validator';
import { Transform } from 'class-transformer';

export class CreateUserDto {
 @IsString()
 @Length(2, 50)
 name: string;

 @IsEmail()
 email: string;

 @IsInt()
 @Min(13)
 @Max(120)
 age: number;

 @IsOptional()
 @IsString()
 @Transform(({ value }) => value?.trim())
 bio?: string;
}
```

Enable global validation in `main.ts` so you don't need to add `ValidationPipe` to every endpoint:

```typescript
async function bootstrap() {
 const app = await NestFactory.create(AppModule);
 app.useGlobalPipes(
 new ValidationPipe({
 whitelist: true, // Strip unknown properties
 forbidNonWhitelisted: true, // Throw error if unknown properties sent
 transform: true, // Auto-transform payloads to DTO instances
 transformOptions: {
 enableImplicitConversion: true, // Convert string params to number/boolean
 },
 }),
 );
 await app.listen(3000);
}
```

## Creating a Custom Pipe

```typescript
import { PipeTransform, Injectable, ArgumentMetadata, BadRequestException } from '@nestjs/common';

@Injectable()
export class CustomValidationPipe implements PipeTransform {
 transform(value: any, metadata: ArgumentMetadata) {
 if (metadata.type === 'param' && value < 1) {
 throw new BadRequestException('ID must be greater than 0');
 }
 return value;
 }
}
```

A practical custom pipe for parsing and validating UUIDs, useful when your database uses UUID primary keys and you want to reject malformed IDs early:

```typescript
import { PipeTransform, Injectable, BadRequestException } from '@nestjs/common';
import { validate as isUUID } from 'uuid';

@Injectable()
export class ParseUUIDPipe implements PipeTransform<string, string> {
 transform(value: string): string {
 if (!isUUID(value)) {
 throw new BadRequestException(`${value} is not a valid UUID`);
 }
 return value;
 }
}

// Usage in controller
@Get(':id')
findOne(@Param('id', ParseUUIDPipe) id: string) {
 return this.usersService.findOne(id);
}
```

Actionable Advice: Use `ValidationPipe` with class-validator decorators for automatic DTO validation. Set `whitelist: true` to strip unknown properties and prevent over-posting attacks.

## Interceptors: Wrapping Request Lifecycle

Interceptors can wrap the method execution before and after the handler runs. They transform the returned value, catch exceptions, extend the basic response handling, and even replace the method execution entirely. Use interceptors for logging, response formatting, caching, and timing metrics.

## Building a Logging Interceptor

```typescript
import { Injectable, NestInterceptor, ExecutionContext, CallHandler } from '@nestjs/common';
import { Observable } from 'rxjs';
import { tap } from 'rxjs/operators';

@Injectable()
export class LoggingInterceptor implements NestInterceptor {
 intercept(context: ExecutionContext, next: CallHandler): Observable<any> {
 const request = context.switchToHttp().getRequest();
 const method = request.method;
 const url = request.url;
 const now = Date.now();

 return next
 .handle()
 .pipe(
 tap(() => console.log(`${method} ${url} - ${Date.now() - now}ms`)),
 );
 }
}
```

## Response Formatting Interceptor

```typescript
@Injectable()
export class TransformInterceptor implements NestInterceptor {
 intercept(context: ExecutionContext, next: CallHandler): Observable<any> {
 return next.handle().pipe(
 map(data => ({
 success: true,
 data,
 timestamp: new Date().toISOString(),
 })),
 );
 }
}
```

Apply interceptors globally, at the controller level, or on specific methods:

```typescript
// Global
app.useGlobalInterceptors(new LoggingInterceptor());

// Controller or method
@Controller('users')
@UseInterceptors(LoggingInterceptor)
export class UsersController {}
```

## Caching Interceptor

An interceptor-based cache avoids redundant downstream calls without modifying your controller or service logic:

```typescript
import {
 Injectable, NestInterceptor, ExecutionContext,
 CallHandler, Inject
} from '@nestjs/common';
import { Cache } from 'cache-manager';
import { CACHE_MANAGER } from '@nestjs/cache-manager';
import { Observable, of } from 'rxjs';
import { tap } from 'rxjs/operators';

@Injectable()
export class HttpCacheInterceptor implements NestInterceptor {
 constructor(@Inject(CACHE_MANAGER) private cacheManager: Cache) {}

 async intercept(context: ExecutionContext, next: CallHandler): Promise<Observable<any>> {
 const request = context.switchToHttp().getRequest();

 // Only cache GET requests
 if (request.method !== 'GET') {
 return next.handle();
 }

 const key = request.url;
 const cachedResponse = await this.cacheManager.get(key);

 if (cachedResponse) {
 return of(cachedResponse);
 }

 return next.handle().pipe(
 tap(response => this.cacheManager.set(key, response, 60000)), // 60 second TTL
 );
 }
}
```

## Error Handling Interceptor

Centralizing error transformation in an interceptor prevents implementation details from leaking into HTTP responses:

```typescript
import {
 Injectable, NestInterceptor, ExecutionContext,
 CallHandler, BadGatewayException
} from '@nestjs/common';
import { Observable, throwError } from 'rxjs';
import { catchError } from 'rxjs/operators';

@Injectable()
export class ErrorInterceptor implements NestInterceptor {
 intercept(context: ExecutionContext, next: CallHandler): Observable<any> {
 return next.handle().pipe(
 catchError(err => {
 // Map database-specific errors to HTTP exceptions
 if (err.code === 'ECONNREFUSED') {
 return throwError(() => new BadGatewayException('Database connection failed'));
 }
 return throwError(() => err);
 }),
 );
 }
}
```

Actionable Advice: Combine interceptors with RxJS operators for powerful patterns. Use `retry()` for transient failures, `timeout()` for long-running operations, and `catchError()` for centralized error handling.

## Testing Guards, Pipes, and Interceptors

These components are straightforward to unit test because they receive explicit inputs and produce explicit outputs. Testing in isolation, without spinning up the full NestJS application, keeps tests fast.

## Testing a Guard

```typescript
describe('RolesGuard', () => {
 let guard: RolesGuard;
 let reflector: Reflector;

 beforeEach(async () => {
 const module = await Test.createTestingModule({
 providers: [
 RolesGuard,
 { provide: Reflector, useValue: { getAllAndOverride: jest.fn() } },
 ],
 }).compile();

 guard = module.get(RolesGuard);
 reflector = module.get(Reflector);
 });

 it('allows access when no roles required', () => {
 jest.spyOn(reflector, 'getAllAndOverride').mockReturnValue(undefined);
 const context = createMockExecutionContext({ user: { roles: [] } });
 expect(guard.canActivate(context)).toBe(true);
 });

 it('denies access when user lacks required role', () => {
 jest.spyOn(reflector, 'getAllAndOverride').mockReturnValue(['admin']);
 const context = createMockExecutionContext({ user: { roles: ['user'] } });
 expect(guard.canActivate(context)).toBe(false);
 });
});
```

## Testing a Custom Pipe

```typescript
describe('ParseUUIDPipe', () => {
 const pipe = new ParseUUIDPipe();

 it('passes through valid UUIDs', () => {
 const valid = '550e8400-e29b-41d4-a716-446655440000';
 expect(pipe.transform(valid)).toBe(valid);
 });

 it('throws BadRequestException for invalid UUIDs', () => {
 expect(() => pipe.transform('not-a-uuid')).toThrow(BadRequestException);
 });
});
```

## Putting It All Together

The real power of NestJS emerges when you combine these three components strategically. Here's a typical flow:

1. Guard checks if the user is authenticated and authorized
2. Pipe validates and transforms incoming request data
3. Interceptor logs the request, measures performance, and formats the response

This separation of concerns keeps your code modular and testable. Each component has a single responsibility, making your application easier to maintain and extend.

A real-world controller showing all three working together:

```typescript
@Controller('orders')
@UseGuards(JwtAuthGuard, RolesGuard)
@UseInterceptors(LoggingInterceptor, TransformInterceptor)
export class OrdersController {
 constructor(private ordersService: OrdersService) {}

 @Post()
 @Roles('customer', 'admin')
 create(
 @Body(new ValidationPipe({ whitelist: true, transform: true }))
 createOrderDto: CreateOrderDto,
 @Request() req,
 ) {
 return this.ordersService.create(createOrderDto, req.user.id);
 }

 @Get(':id')
 @Roles('customer', 'admin')
 findOne(
 @Param('id', ParseUUIDPipe) id: string,
 @Request() req,
 ) {
 return this.ordersService.findOne(id, req.user.id);
 }
}
```

The `JwtAuthGuard` runs first, populates `req.user`, then `RolesGuard` checks whether `req.user.roles` includes the required role. If both pass, `ValidationPipe` transforms and validates the request body, and both interceptors wrap the entire execution from start to finish.

## Comparing Guards, Pipes, and Interceptors

When deciding where to put logic, use this reference:

| Concern | Best Component | Why |
|---|---|---|
| Is user authenticated? | Guard | Returns boolean to block/allow |
| Does user have permission? | Guard | Access to metadata via Reflector |
| Parse string param to number | Pipe | Transforms argument value |
| Validate request body shape | Pipe | class-validator integration |
| Log request and response time | Interceptor | Wraps full execution |
| Standardize response envelope | Interceptor | Transforms return value |
| Cache GET responses | Interceptor | Can short-circuit with `of()` |
| Map DB errors to HTTP errors | Interceptor | catchError on the observable |
| Parse cookies or headers for all routes | Middleware | Runs before guard, no context needed |

## Best Practices Summary

- Keep guards focused on authorization logic only
- Use pipes early in the pipeline for input validation
- Use interceptors for cross-cutting concerns like logging and caching
- Combine class-validator with pipes for declarative validation
- Use dependency injection to make components testable
- Apply components at the appropriate scope (global, controller, or method)
- Register global guards, pipes, and interceptors in `main.ts` using `useGlobalGuards`, `useGlobalPipes`, and `useGlobalInterceptors` for app-wide behavior, but use DI-registered versions (via `APP_GUARD`, `APP_PIPE`, `APP_INTERCEPTOR` tokens in a module) when the components themselves need injected services
- Avoid putting business logic inside guards or interceptors, they should only concern themselves with the mechanics of the request pipeline

By mastering guards, interceptors, and pipes, you'll build NestJS applications that are secure, well-structured, and production-ready. Claude Code can accelerate your learning by generating these patterns while you focus on your business logic.


---

---

<div class="mastery-cta">

I'm a solo developer in Vietnam. 50K Chrome extension users. $500K+ on Upwork. 5 Claude Max subscriptions running agent fleets in parallel.

These are my actual CLAUDE.md templates, orchestration configs, and prompts. Not a course. Not theory. The files I copy into every project before I write a line of code.

**[See what's inside →](https://zovo.one/lifetime?utm_source=ccg&utm_medium=cta-default&utm_campaign=claude-code-nestjs-guards-interceptors-pipes-deep-dive)**

$99 once. Free forever. 47/500 founding spots left.

</div>

Related Reading

- [Claude API Tool Use and Function Calling Deep Dive Guide](/claude-api-tool-use-function-calling-deep-dive-guide/)
- [Claude Code Agent Task Queue Architecture Deep Dive](/claude-code-agent-task-queue-architecture-deep-dive/)
- [Claude Code Astro Islands Architecture Workflow Deep Dive](/claude-code-astro-islands-architecture-workflow-deep-dive/)

Built by theluckystrike. More at [zovo.one](https://zovo.one)


