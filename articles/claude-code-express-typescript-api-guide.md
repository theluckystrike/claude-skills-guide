---
layout: default
title: "Claude Code Express TypeScript (2026)"
description: "A practical guide to building Express APIs with TypeScript using Claude Code. Learn project setup, routing, validation, error handling, and testing."
date: 2026-03-14
last_modified_at: 2026-04-17
categories: [guides]
tags: [express, typescript, api-development, claude-code, nodejs, backend]
author: theluckystrike
reviewed: true
score: 8
permalink: /claude-code-express-typescript-api-guide/
geo_optimized: true
---
# Claude Code Express TypeScript API Guide: Build Production-Ready APIs

Building Express APIs with TypeScript provides type safety, better developer experience, and maintainable codebases. Claude Code accelerates this workflow by generating boilerplate, writing tests, and helping you implement best practices efficiently. This guide walks through creating a production-ready Express TypeScript API with Claude Code.

## Project Setup with Claude Code

Initialize your Express TypeScript project with proper tooling. Claude Code can scaffold the entire structure including package.json, TypeScript configuration, and directory structure.

```bash
npm init -y
npm install express cors helmet morgan
npm install -D typescript @types/node @types/express @types/cors @types/morgan ts-node nodemon
npx tsc --init
```

Configure your tsconfig.json for optimal development:

```json
{
 "compilerOptions": {
 "target": "ES2022",
 "module": "commonjs",
 "outDir": "./dist",
 "rootDir": "./src",
 "strict": true,
 "esModuleInterop": true,
 "skipLibCheck": true,
 "forceConsistentCasingInFileNames": true
 }
}
```

Create your main application file with proper structure:

```typescript
// src/app.ts
import express, { Application, Request, Response, NextFunction } from 'express';
import cors from 'cors';
import helmet from 'helmet';
import morgan from 'morgan';

export const createApp = (): Application => {
 const app = express();
 app.use(helmet());
 app.use(cors());
 app.use(morgan('dev'));
 app.use(express.json());
 app.use(express.urlencoded({ extended: true }));

 app.get('/health', (_req: Request, res: Response) => {
 res.status(200).json({ status: 'ok', timestamp: new Date().toISOString() });
 });

 return app;
};
```

## Building API Routes and Controllers

Organize your API using the controller pattern. Claude Code helps generate clean, separation-of-concerns architecture.

```typescript
// src/controllers/userController.ts
import { Request, Response, NextFunction } from 'express';

export interface User {
 id: string;
 email: string;
 name: string;
 createdAt: Date;
}

const users: User[] = [];

export const userController = {
 getAll: (_req: Request, res: Response, next: NextFunction) => {
 try {
 res.status(200).json({ data: users, count: users.length });
 } catch (error) { next(error); }
 },

 getById: (req: Request, res: Response, next: NextFunction) => {
 try {
 const user = users.find(u => u.id === req.params.id);
 if (!user) return res.status(404).json({ error: 'User not found' });
 res.status(200).json({ data: user });
 } catch (error) { next(error); }
 },

 create: (req: Request, res: Response, next: NextFunction) => {
 try {
 const { email, name } = req.body;
 if (!email || !name) return res.status(400).json({ error: 'Email and name are required' });
 const newUser: User = { id: crypto.randomUUID(), email, name, createdAt: new Date() };
 users.push(newUser);
 res.status(201).json({ data: newUser });
 } catch (error) { next(error); }
 }
};
```

Wire up the routes in `src/routes/userRoutes.ts` and register them in your app entry point. Claude Code can generate the complete wiring from a brief description of your endpoint structure.

## Input Validation with Zod

Always validate incoming data. Use Zod for schema validation:

```bash
npm install zod
```

```typescript
// src/validators/userValidator.ts
import { z } from 'zod';

export const createUserSchema = z.object({
 email: z.string().email(),
 name: z.string().min(1).max(100),
 age: z.number().int().min(0).optional()
});

export type CreateUserInput = z.infer<typeof createUserSchema>;
```

```typescript
// src/middleware/validate.ts
import { Request, Response, NextFunction } from 'express';
import { ZodSchema, ZodError } from 'zod';

export const validate = (schema: ZodSchema) => {
 return (req: Request, res: Response, next: NextFunction) => {
 try {
 schema.parse(req.body);
 next();
 } catch (error) {
 if (error instanceof ZodError) {
 const fields = error.issues.reduce((acc, issue) => {
 acc[issue.path.join('.')] = issue.message;
 return acc;
 }, {} as Record<string, string>);
 return res.status(400).json({ error: 'Validation failed', fields });
 }
 next(error);
 }
 };
};
```

Apply validation to your routes:

```typescript
router.post('/users', validate(createUserSchema), userController.create);
```

## Testing with Claude Code and TDD

Claude Code combined with the tdd skill accelerates test-driven development. Create tests before implementing features:

```typescript
// src/__tests__/userController.test.ts
describe('User Controller', () => {
 let mockReq: Partial<Request>;
 let mockRes: Partial<Response>;
 let mockNext: jest.Mock;

 beforeEach(() => {
 mockReq = {};
 mockRes = { status: jest.fn().mockReturnThis(), json: jest.fn() };
 mockNext = jest.fn();
 });

 it('getAll should return 200 with user array', () => {
 userController.getAll(mockReq as Request, mockRes as Response, mockNext);
 expect(mockRes.status).toHaveBeenCalledWith(200);
 });

 it('getById should return 404 for non-existent user', () => {
 mockReq.params = { id: 'nonexistent' };
 userController.getById(mockReq as Request, mockRes as Response, mockNext);
 expect(mockRes.status).toHaveBeenCalledWith(404);
 });
});
```

Configure ts-jest in `jest.config.js`:

```javascript
module.exports = {
 preset: 'ts-jest',
 testEnvironment: 'node',
 roots: ['<rootDir>/src'],
 testMatch: ['/__tests__//*.test.ts']
};
```

## Authentication with JWT

Production APIs require authentication. JWT middleware integrates cleanly into the Express middleware chain:

```bash
npm install jsonwebtoken bcryptjs
npm install -D @types/jsonwebtoken @types/bcryptjs
```

```typescript
// src/middleware/auth.ts
import { Request, Response, NextFunction } from 'express';
import jwt from 'jsonwebtoken';

export interface AuthRequest extends Request {
 userId?: string;
}

export const authenticate = (req: AuthRequest, res: Response, next: NextFunction) => {
 const authHeader = req.headers.authorization;
 if (!authHeader?.startsWith('Bearer ')) {
 return res.status(401).json({ error: 'No token provided' });
 }
 try {
 const token = authHeader.split(' ')[1];
 const payload = jwt.verify(token, process.env.JWT_SECRET!) as { userId: string };
 req.userId = payload.userId;
 next();
 } catch {
 return res.status(401).json({ error: 'Invalid token' });
 }
};
```

Apply this middleware after public routes. Claude Code generates comprehensive auth flows. describe the token lifecycle and it scaffolds login, refresh, and logout endpoints automatically.

## Database Integration with Prisma

Prisma provides type-safe database access that complements TypeScript well:

```bash
npm install prisma @prisma/client
npx prisma init
```

Define your schema in `prisma/schema.prisma`:

```prisma
datasource db {
 provider = "postgresql"
 url = env("DATABASE_URL")
}

generator client {
 provider = "prisma-client-js"
}

model User {
 id String @id @default(cuid())
 email String @unique
 name String
 createdAt DateTime @default(now())
 updatedAt DateTime @updatedAt
}
```

Export a single shared Prisma client to avoid connection pool exhaustion:

```typescript
// src/lib/prisma.ts
import { PrismaClient } from '@prisma/client';
const globalForPrisma = global as unknown as { prisma: PrismaClient };
export const prisma = globalForPrisma.prisma ?? new PrismaClient({ log: ['error'] });
if (process.env.NODE_ENV !== 'production') globalForPrisma.prisma = prisma;
```

Claude Code generates complete Prisma schemas from plain-language data model descriptions, including relations, indexes, and seed data.

## Rate Limiting and Security Hardening

Protect your API from abuse with rate limiting:

```bash
npm install express-rate-limit
```

```typescript
// src/middleware/rateLimiter.ts
import rateLimit from 'express-rate-limit';

export const apiLimiter = rateLimit({
 windowMs: 15 * 60 * 1000,
 max: 100,
 standardHeaders: true,
 legacyHeaders: false,
 message: { error: 'Too many requests, please try again later' }
});

export const authLimiter = rateLimit({
 windowMs: 60 * 60 * 1000,
 max: 10,
 message: { error: 'Too many login attempts' }
});
```

Apply limiters selectively: use `apiLimiter` on all API routes and `authLimiter` only on authentication endpoints. Pair this with a tighter Helmet CSP configuration and HSTS headers for production deployments.

## Deployment with Docker

Package your API as a Docker container for consistent deployments:

```dockerfile
FROM node:20-alpine AS builder
WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY . .
RUN npm run build

FROM node:20-alpine AS production
WORKDIR /app
COPY package*.json ./
RUN npm ci --omit=dev
COPY --from=builder /app/dist ./dist
EXPOSE 3000
CMD ["node", "dist/index.js"]
```

Build and run:

```bash
docker build -t my-express-api .
docker run -p 3000:3000 --env-file .env my-express-api
```

Claude Code generates Dockerfiles and docker-compose configurations from a description of your stack. Provide the database and caching layer names and it scaffolds the full compose file with health checks and volume mounts.

## Common Use Cases

- Internal tooling APIs: TypeScript's type safety reduces errors in admin backends used by small teams
- Microservice endpoints: Express keeps the bundle small; TypeScript keeps interfaces explicit across services
- Mobile app backends: Zod validation and JWT auth form a complete auth layer for React Native or Flutter apps
- Webhook receivers: The middleware chain makes it easy to validate signatures and parse payloads before they reach business logic
- Prototyping: Claude Code scaffolds a working skeleton in minutes; TypeScript prevents the technical debt that usually accumulates in quick prototypes

## Best Practices Summary

When building Express TypeScript APIs with Claude Code:

- Use strict TypeScript configuration for type safety across the entire codebase
- Centralize error handling in a single error middleware registered last
- Validate all inputs using Zod schemas with field-level error messages
- Write tests alongside your code using the tdd skill
- Add JWT authentication and rate limiting before going to production
- Use Prisma for type-safe database access with a single shared client
- Containerize with Docker for reproducible deployments across environments
- Generate OpenAPI documentation automatically using the pdf skill
- Use environment variables for all configuration values
- Implement structured logging with pino or morgan for production observability

For persistent context across sessions, consider the supermemory skill to maintain project memory. When building frontend integrations, the frontend-design skill helps create consistent UI patterns that consume your API.

---

---

<div class="mastery-cta">

I'm a solo developer in Vietnam. 50K Chrome extension users. $500K+ on Upwork. 5 Claude Max subscriptions running agent fleets in parallel.

These are my actual CLAUDE.md templates, orchestration configs, and prompts. Not a course. Not theory. The files I copy into every project before I write a line of code.

**[See what's inside →](https://zovo.one/lifetime?utm_source=ccg&utm_medium=cta-default&utm_campaign=claude-code-express-typescript-api-guide)**

$99 once. Free forever. 47/500 founding spots left.

</div>

Related Reading

- [Claude Code Express Middleware Error Handling Patterns Guide](/claude-code-express-middleware-error-handling-patterns-guide/)
- [Express to Fastify Migration with Claude Code (2026)](/claude-code-express-to-fastify-migration-tutorial-2026/)
- [Claude Code for gRPC API Development: A Practical Guide](/claude-code-grpc-api-development-guide/)

Built by theluckystrike. More at [zovo.one](https://zovo.one)


