---

layout: default
title: "Claude Code for Rate Limiting Middleware Workflow"
description: "Learn how to build rate limiting middleware using Claude Code. A practical guide for developers implementing API protection with token bucket and sliding window algorithms."
date: 2026-03-15
author: "Claude Skills Guide"
permalink: /claude-code-for-rate-limiting-middleware-workflow/
categories: [guides]
reviewed: true
score: 7
tags: [claude-code, claude-skills]
---

# Claude Code for Rate Limiting Middleware Workflow

Rate limiting is a critical component of any robust API infrastructure. Whether you're protecting against abuse, ensuring fair resource allocation, or maintaining service stability, implementing rate limiting middleware requires careful consideration of algorithms, storage backends, and integration patterns. This guide demonstrates how to use Claude Code to streamline the entire rate limiting middleware development workflow.

## Understanding Rate Limiting Fundamentals

Before diving into implementation, it's essential to understand the common algorithms used for rate limiting. The token bucket algorithm allows bursts while maintaining a steady refill rate—ideal for APIs where occasional spikes are acceptable. The sliding window algorithm provides smoother rate limiting by tracking requests within a rolling time window. The fixed window approach is simpler but may allow traffic spikes at window boundaries.

Claude Code can help you explore these patterns and select the right approach for your use case. When starting a new rate limiting implementation, describe your requirements to Claude and ask for algorithm recommendations:

```bash
claude "I need rate limiting for a REST API that handles 1000 requests per minute per user. Users occasionally burst to 50 requests but sustained traffic is around 10 RPS. Recommend an algorithm and explain tradeoffs."
```

This conversation helps clarify your requirements before writing any code.

## Setting Up Your Rate Limiting Project

Initialize your middleware project with proper structure from the start. Claude Code excels at scaffolding projects with appropriate patterns. Create a directory structure that separates the core rate limiting logic from framework-specific integrations:

```bash
mkdir -p rate-limiter/src/core
mkdir -p rate-limiter/src/middleware
mkdir -p rate-limiter/tests
cd rate-limiter
```

When setting up the project, specify your language and framework in the prompt to get relevant code:

```bash
claude "Set up a Node.js Express rate limiting middleware project with TypeScript. Include package.json with express, redis, and ioredis dependencies. Create a basic project structure."
```

Claude will generate the scaffold with appropriate configurations and dependencies.

## Implementing Core Rate Limiting Logic

The core rate limiting logic should be framework-agnostic, making it reusable across different web frameworks and contexts. Here's how to implement a token bucket rate limiter with Claude Code guidance:

```typescript
// src/core/token-bucket.ts
export interface RateLimiterConfig {
  capacity: number;
  refillRate: number; // tokens per second
  windowSize: number; // in milliseconds
}

export interface RateLimitResult {
  allowed: boolean;
  remaining: number;
  resetTime: number;
  retryAfter?: number;
}

export class TokenBucket {
  private tokens: number;
  private lastRefill: number;
  private readonly capacity: number;
  private readonly refillRate: number;
  private readonly windowSize: number;

  constructor(config: RateLimiterConfig) {
    this.capacity = config.capacity;
    this.refillRate = config.refillRate;
    this.windowSize = config.windowSize;
    this.tokens = config.capacity;
    this.lastRefill = Date.now();
  }

  tryConsume(tokens: number = 1): RateLimitResult {
    this.refill();
    
    if (this.tokens >= tokens) {
      this.tokens -= tokens;
      return {
        allowed: true,
        remaining: Math.floor(this.tokens),
        resetTime: this.lastRefill + this.windowSize,
      };
    }

    const retryAfter = Math.ceil((tokens - this.tokens) / this.refillRate * 1000);
    return {
      allowed: false,
      remaining: 0,
      resetTime: this.lastRefill + this.windowSize,
      retryAfter,
    };
  }

  private refill(): void {
    const now = Date.now();
    const elapsed = now - this.lastRefill;
    const tokensToAdd = (elapsed / 1000) * this.refillRate;
    
    this.tokens = Math.min(this.capacity, this.tokens + tokensToAdd);
    this.lastRefill = now;
  }
}
```

To get this implementation, prompt Claude with specific requirements:

```bash
claude "Implement a TokenBucket class in TypeScript with tryConsume method that returns {allowed, remaining, resetTime, retryAfter}. Include automatic token refill based on elapsed time."
```

## Building Framework-Specific Middleware

Once you have the core logic, create middleware that integrates with your web framework. For Express.js:

```typescript
// src/middleware/express-rate-limit.ts
import { Request, Response, NextFunction } from 'express';
import { TokenBucket, RateLimitResult } from '../core/token-bucket';

export interface RateLimitOptions {
  windowMs: number;
  maxRequests: number;
  keyGenerator?: (req: Request) => string;
  handler?: (req: Request, res: Response) => void;
}

export function createRateLimitMiddleware(
  limiter: TokenBucket,
  options: RateLimitOptions
) {
  return (req: Request, res: Response, next: NextFunction) => {
    const key = options.keyGenerator 
      ? options.keyGenerator(req) 
      : req.ip || 'unknown';
    
    const result = limiter.tryConsume(1);
    
    res.setHeader('X-RateLimit-Limit', options.maxRequests);
    res.setHeader('X-RateLimit-Remaining', result.remaining);
    res.setHeader('X-RateLimit-Reset', Math.ceil(result.resetTime / 1000));
    
    if (!result.allowed) {
      res.setHeader('Retry-After', result.retryAfter || 0);
      
      if (options.handler) {
        return options.handler(req, res);
      }
      
      return res.status(429).json({
        error: 'Too Many Requests',
        retryAfter: result.retryAfter,
      });
    }
    
    next();
  };
}
```

The middleware follows Express conventions, making it familiar to developers. Request Claude to generate adapters for other frameworks:

```bash
claude "Create a Fastify rate limit middleware adapter that wraps the TokenBucket class. Follow Fastify's middleware plugin pattern with register and hook."
```

## Adding Distributed Rate Limiting with Redis

For production systems running multiple instances, local in-memory rate limiting won't work—requests can be distributed across servers. Implement Redis-backed rate limiting:

```typescript
// src/core/distributed-rate-limiter.ts
import Redis from 'ioredis';

export class DistributedTokenBucket {
  private redis: Redis;
  private readonly keyPrefix: string;
  private readonly capacity: number;
  private readonly refillRate: number;

  constructor(redis: Redis, capacity: number, refillRate: number) {
    this.redis = redis;
    this.keyPrefix = 'ratelimit:';
    this.capacity = capacity;
    this.refillRate = refillRate;
  }

  async tryConsume(key: string, tokens: number = 1): Promise<RateLimitResult> {
    const fullKey = `${this.keyPrefix}${key}`;
    const now = Date.now();
    
    const script = `
      local key = KEYS[1]
      local now = tonumber(ARGV[1])
      local capacity = tonumber(ARGV[2])
      local refillRate = tonumber(ARGV[3])
      local tokens = tonumber(ARGV[4])
      
      local bucket = redis.call('HMGET', key, 'tokens', 'lastRefill')[1]
      local lastRefill = redis.call('HMGET', key, 'lastRefill')[1]
      
      if not bucket then
        bucket = capacity
        lastRefill = now
      end
      
      local elapsed = (now - tonumber(lastRefill)) / 1000
      local newTokens = math.min(capacity, tonumber(bucket) + (elapsed * refillRate))
      
      if newTokens >= tokens then
        newTokens = newTokens - tokens
        redis.call('HMSET', key, 'tokens', newTokens, 'lastRefill', now)
        redis.call('EXPIRE', key, 60)
        return {1, math.floor(newTokens), 1}
      else
        local retryAfter = math.ceil((tokens - newTokens) / refillRate * 1000)
        return {0, 0, retryAfter}
      end
    `;
    
    const result = await this.redis.eval(
      script, 1, fullKey, now, this.capacity, this.refillRate, tokens
    ) as number[];
    
    return {
      allowed: result[0] === 1,
      remaining: result[1],
      resetTime: now + 60000,
      retryAfter: result[2],
    };
  }
}
```

## Testing Your Rate Limiting Implementation

Comprehensive testing ensures your rate limiter behaves correctly under various conditions. Claude Code can generate test cases:

```bash
claude "Write Jest tests for the TokenBucket class covering: 
1. First request should be allowed
2. Burst traffic up to capacity should be allowed
3. Requests exceeding capacity should be denied
4. Token refill over time should allow new requests
5. Concurrent access should be handled correctly"
```

For integration testing with Redis, ensure you use a test container:

```typescript
// tests/integration/distributed-rate-limiter.test.ts
import { DockerComposeRunner } from 'testcontainers';

describe('DistributedTokenBucket', () => {
  let redis: Redis;
  
  beforeAll(async () => {
    // Use testcontainers to spin up Redis
    const container = await new DockerComposeRunner()
      .withFile('docker-compose.test.yml')
      .up(['redis']);
      
    redis = new Redis(container.getHostPort(6379));
  });
  
  afterAll(async () => {
    await redis.quit();
  });
  
  it('should limit requests across multiple instances', async () => {
    const limiter1 = new DistributedTokenBucket(redis, 10, 1);
    const limiter2 = new DistributedTokenBucket(redis, 10, 1);
    
    // Consume from instance 1
    const result1 = await limiter1.tryConsume('user1', 5);
    expect(result1.allowed).toBe(true);
    
    // Should be limited when checking from instance 2
    const result2 = await limiter2.tryConsume('user1', 6);
    expect(result2.allowed).toBe(false);
  });
});
```

## Best Practices and Actionable Advice

When implementing rate limiting in production, consider these recommendations:

**Start with headers that inform clients.** Always include `X-RateLimit-Limit`, `X-RateLimit-Remaining`, and `X-RateLimit-Reset` in responses. This lets clients adjust their behavior proactively rather than receiving 429 errors.

**Use hierarchical rate limiting.** Implement rate limits at multiple levels: global, per-user, and per-endpoint. This provides defense in depth and allows granular control.

**Make rate limits configurable per environment.** Development environments might need higher limits for testing, while production needs conservative defaults. Use environment variables or configuration files.

**Monitor your rate limiter itself.** Track metrics like blocked requests, cache hit rates for distributed limiters, and latency. This helps identify issues before they impact users.

Claude Code accelerates each phase of this workflow—from initial algorithm exploration to production-ready implementation. By leveraging Claude's ability to generate scaffold code, implement complex patterns, and create comprehensive tests, you can build robust rate limiting middleware in a fraction of the time it would take manually.

