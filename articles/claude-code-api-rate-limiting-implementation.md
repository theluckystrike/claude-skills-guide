---
layout: default
title: "Claude Code API Rate Limiting Implementation"
description: "A practical guide to implementing API rate limiting in your Claude Code projects. Learn token bucket algorithms, middleware patterns, and real-world examples for production systems."
date: 2026-03-14
author: theluckystrike
permalink: /claude-code-api-rate-limiting-implementation/
---

# Claude Code API Rate Limiting Implementation

API rate limiting protects your services from abuse, ensures fair resource allocation, and maintains stable performance for all users. When building applications that integrate with Claude Code or creating custom skills that make API calls, implementing proper rate limiting becomes essential for production-ready systems.

This guide covers practical rate limiting implementations using token bucket and sliding window algorithms, with code examples you can adapt directly into your projects.

## Understanding Rate Limiting Fundamentals

Rate limiting controls how many requests a client can make within a time window. The most common approaches include:

**Token Bucket** — Tokens fill a bucket at a fixed rate. Each request consumes a token. When the bucket empties, requests wait or fail.

**Sliding Window** — Tracks requests in a rolling time frame. More accurate than fixed windows but requires more memory.

**Leaky Bucket** — Processes requests at a constant rate regardless of incoming speed. Ideal for smoothing traffic bursts.

For most Claude Code integrations, token bucket provides the right balance of simplicity and effectiveness.

## Implementing Token Bucket Rate Limiter

Here's a production-ready implementation in JavaScript:

```javascript
class TokenBucket {
  constructor(capacity, refillRate) {
    this.capacity = capacity;
    this.tokens = capacity;
    this.refillRate = refillRate; // tokens per second
    this.lastRefill = Date.now();
  }

  async consume(tokensNeeded = 1) {
    this.refill();
    
    if (this.tokens >= tokensNeeded) {
      this.tokens -= tokensNeeded;
      return { allowed: true, remaining: this.tokens };
    }
    
    return { 
      allowed: false, 
      remaining: this.tokens,
      retryAfter: Math.ceil((tokensNeeded - this.tokens) / this.refillRate)
    };
  }

  refill() {
    const now = Date.now();
    const elapsed = (now - this.lastRefill) / 1000;
    const newTokens = elapsed * this.refillRate;
    this.tokens = Math.min(this.capacity, this.tokens + newTokens);
    this.lastRefill = now;
  }
}
```

This implementation supports multiple independent buckets per client, which works well when integrating with skills like the `frontend-design` skill that might make concurrent API calls.

## Rate Limiting Middleware for Express

If you're building a web service that wraps Claude Code calls, integrate rate limiting as middleware:

```javascript
const rateLimit = new Map();

function rateLimiter(options = {}) {
  const { 
    windowMs = 60000, 
    maxRequests = 100,
    keyFn = (req) => req.ip 
  } = options;

  return async (req, res, next) => {
    const key = keyFn(req);
    const now = Date.now();
    
    if (!rateLimit.has(key)) {
      rateLimit.set(key, { count: 1, resetTime: now + windowMs });
      return next();
    }
    
    const client = rateLimit.get(key);
    
    if (now > client.resetTime) {
      client.count = 1;
      client.resetTime = now + windowMs;
      return next();
    }
    
    if (client.count >= maxRequests) {
      return res.status(429).json({
        error: 'Rate limit exceeded',
        retryAfter: Math.ceil((client.resetTime - now) / 1000)
      });
    }
    
    client.count++;
    next();
  };
}
```

Apply this middleware to routes handled by skills like `pdf` or `docx` that process multiple documents:

```javascript
app.post('/api/process-document', 
  rateLimiter({ windowMs: 60000, maxRequests: 20 }),
  async (req, res) => {
    // Your document processing logic
  }
);
```

## Distributed Rate Limiting with Redis

For multi-server deployments, centralize rate limiting state using Redis:

```javascript
const Redis = require('ioredis');
const redis = new Redis(process.env.REDIS_URL);

async function distributedRateLimit(key, limit, windowSeconds) {
  const current = await redis.incr(key);
  
  if (current === 1) {
    await redis.expire(key, windowSeconds);
  }
  
  const ttl = await redis.ttl(key);
  
  if (current > limit) {
    return { allowed: false, remaining: 0, retryAfter: ttl };
  }
  
  return { allowed: true, remaining: limit - current };
}
```

This pattern works seamlessly with Claude Code skills that coordinate across instances, such as the `supermemory` skill for distributed note synchronization.

## Handling Rate Limit Responses

When your application hits a rate limit, implement exponential backoff:

```javascript
async function callWithRetry(fn, maxRetries = 3) {
  for (let attempt = 0; attempt < maxRetries; attempt++) {
    try {
      return await fn();
    } catch (error) {
      if (error.status === 429 && attempt < maxRetries - 1) {
        const delay = Math.pow(2, attempt) * 1000;
        await new Promise(r => setTimeout(r, delay));
        continue;
      }
      throw error;
    }
  }
}
```

The `tdd` skill pairs well with rate limiting development — write tests that verify your limiter correctly blocks excess requests and allows legitimate traffic.

## Monitoring and Observability

Track rate limiter performance with custom metrics:

```javascript
function createInstrumentedLimiter(bucket, metrics) {
  return {
    async consume(tokens) {
      const result = await bucket.consume(tokens);
      
      metrics.record('rate_limit_attempt', 1, {
        outcome: result.allowed ? 'allowed' : 'denied'
      });
      
      if (!result.allowed) {
        metrics.record('rate_limit_retry', result.retryAfter, {
          endpoint: metrics.endpointName
        });
      }
      
      return result;
    }
  };
}
```

This data helps you adjust limits based on actual usage patterns and identify potential issues before they impact users.

## Configuration Best Practices

Set rate limits based on your API tier and user requirements:

| Tier | Requests/Minute | Burst Allowance |
|------|-----------------|-----------------|
| Free | 10 | 5 |
| Pro | 60 | 20 |
| Enterprise | 300 | 100 |

Document your rate limit headers consistently:

```javascript
function setRateLimitHeaders(res, result, limit) {
  res.set('X-RateLimit-Limit', limit);
  res.set('X-RateLimit-Remaining', result.remaining);
  res.set('X-RateLimit-Reset', Math.floor(Date.now() / 1000) + (result.retryAfter || 60));
}
```

## Conclusion

Rate limiting protects your Claude Code integrations from abuse while ensuring reliable performance. The token bucket algorithm provides flexibility for burst handling, Redis enables distributed rate limiting across multiple servers, and proper observability helps you fine-tune limits over time.

Start with simple in-memory limiting for single-server deployments, then scale to Redis-backed limiting as your usage grows. The `tdd` skill helps you test these implementations thoroughly before production deployment.

Built by theluckystrike — More at [zovo.one](https://zovo.one)
