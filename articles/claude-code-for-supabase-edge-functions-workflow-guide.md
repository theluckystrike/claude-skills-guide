---
layout: default
title: "Claude Code for Supabase Edge Functions — Guide"
description: "Deploy serverless functions on Supabase Edge and Claude Code. Tested setup with copy-paste CLAUDE.md config."
date: 2026-04-18
permalink: /claude-code-for-supabase-edge-functions-workflow-guide/
render_with_liquid: false
categories: [workflow, niche-tools]
tags: [claude-code, supabase-edge, workflow]
---

## The Setup

You are deploying serverless functions with Supabase Edge Functions, which run Deno-based TypeScript functions on the edge close to your users. Edge Functions integrate natively with Supabase's database, auth, and storage services. Claude Code can create serverless functions, but it generates AWS Lambda or Vercel Functions code instead of Supabase's Deno-based edge functions.

## What Claude Code Gets Wrong By Default

1. **Writes Node.js Lambda handlers.** Claude creates `exports.handler = async (event, context) => {}` for AWS Lambda. Supabase Edge Functions use Deno's `Deno.serve()` with `Request`/`Response` web standard APIs.

2. **Imports npm packages with require.** Claude writes `const express = require('express')`. Edge Functions use Deno — import from URLs (`import { serve } from "https://deno.land/std/http/server.ts"`) or use the `npm:` prefix for npm packages.

3. **Connects to Supabase with service key in code.** Claude hardcodes `createClient(url, serviceKey)`. Edge Functions have automatic access to Supabase services — use environment variables `SUPABASE_URL` and `SUPABASE_SERVICE_ROLE_KEY` which are pre-configured.

4. **Deploys with custom infrastructure.** Claude creates Terraform or Dockerfile for deployment. Edge Functions deploy with `supabase functions deploy function-name` — no infrastructure configuration needed.

## The CLAUDE.md Configuration

```
# Supabase Edge Functions

## Serverless
- Platform: Supabase Edge Functions (Deno runtime)
- API: Web standard Request/Response
- Deploy: supabase functions deploy
- Integration: native Supabase DB, auth, storage access

## Edge Function Rules
- Handler: Deno.serve(async (req) => new Response(...))
- Imports: Deno-style URLs or npm: prefix
- Env: Deno.env.get('SUPABASE_URL') for config
- CORS: handle in function with headers
- Auth: verify JWT from Authorization header
- DB: createClient with auto-configured env vars
- Local: supabase functions serve for development

## Conventions
- One function per supabase/functions/[name]/index.ts
- Use import_map.json for shared dependencies
- Verify auth token for protected functions
- Return JSON with proper Content-Type header
- Handle CORS with OPTIONS preflight
- Use supabase functions serve for local testing
- Secrets: supabase secrets set KEY=value
```

## Workflow Example

You want to create an edge function that processes webhook events. Prompt Claude Code:

"Create a Supabase Edge Function that receives Stripe webhook events, verifies the webhook signature, updates the user's subscription status in the Supabase database, and returns a 200 response. Handle CORS and authentication."

Claude Code should create `supabase/functions/stripe-webhook/index.ts` with `Deno.serve()`, verify the Stripe signature using the `crypto` web API, create a Supabase client with `SUPABASE_SERVICE_ROLE_KEY`, update the user's subscription in the database, add CORS headers, and return appropriate status codes.

## Common Pitfalls

1. **Missing CORS headers.** Claude does not handle CORS in edge functions. Browser requests to edge functions need CORS headers. Add an OPTIONS handler and `Access-Control-Allow-Origin` headers to all responses.

2. **Cold start performance issues.** Claude imports large libraries at the top level. Edge functions have cold starts — minimize imports and defer heavy initialization to keep cold start times low.

3. **Not using import maps for shared code.** Claude duplicates utility code across functions. Supabase Edge Functions support `import_map.json` for shared dependencies — define common imports once and reuse across all functions.

## Related Guides

- [Claude Code for Durable Objects CF Workflow Guide](/claude-code-for-durable-objects-cf-workflow-guide/)
- [Building a REST API with Claude Code Tutorial](/building-a-rest-api-with-claude-code-tutorial/)
- [Claude Code for SST Serverless Workflow Guide](/claude-code-for-sst-serverless-workflow-guide/)

## Related Articles

- [Claude Code Supabase Storage Signed URL Workflow Guide](/claude-code-supabase-storage-signed-url-workflow-guide/)
- [Claude Code Supabase Backend Development Workflow Tips](/claude-code-supabase-backend-development-workflow-tips/)
- [How to Use Supabase Integration: Backend (2026)](/claude-code-with-supabase-backend-integration-guide/)
- [Claude Code Supabase Auth Row — Complete Developer Guide](/claude-code-supabase-auth-row-level-security-guide/)
