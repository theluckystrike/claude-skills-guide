---
layout: default
title: "Claude Code for Coolify — Workflow Guide"
description: "Self-host apps with Coolify and Claude Code deployment. Tested setup with copy-paste CLAUDE.md config."
date: 2026-04-18
permalink: /claude-code-for-coolify-self-hosting-workflow-guide/
render_with_liquid: false
categories: [workflow, niche-tools]
tags: [claude-code, coolify, workflow]
---

## The Setup

You are deploying applications using Coolify, the open-source, self-hosted alternative to Heroku/Vercel/Netlify. Coolify runs on your own server and handles Docker builds, SSL certificates, databases, and deployments through a web UI and API. Claude Code can configure deployments, but it defaults to Vercel or Heroku CLI patterns.

## What Claude Code Gets Wrong By Default

1. **Uses Vercel/Heroku CLI commands.** Claude writes `vercel deploy` or `heroku push`. Coolify deployments are triggered through its web UI, API, or Git webhooks — not a custom CLI.

2. **Creates platform-specific config files.** Claude generates `vercel.json` or `Procfile`. Coolify uses Docker for builds — provide a `Dockerfile` or use Coolify's Nixpacks auto-detection.

3. **Configures DNS with platform-specific instructions.** Claude writes Vercel-specific DNS setup. Coolify manages SSL with Let's Encrypt and requires standard DNS A/CNAME records pointing to your server IP.

4. **Ignores Coolify's built-in database provisioning.** Claude sets up external database services. Coolify can provision PostgreSQL, MySQL, Redis, and MongoDB containers alongside your app with one-click setup.

## The CLAUDE.md Configuration

```
# Coolify Self-Hosted Deployment

## Platform
- Hosting: Coolify (self-hosted PaaS on your server)
- Build: Docker or Nixpacks (auto-detect)
- SSL: Let's Encrypt automatic certificates
- Databases: Provisioned alongside app via Coolify

## Coolify Rules
- Deploy via Git push (webhook), API, or Coolify dashboard
- Provide Dockerfile for custom builds, or let Nixpacks detect
- Environment variables set in Coolify dashboard or API
- Database connection strings auto-configured between services
- Domain config: Add A record to server IP, configure in Coolify
- Health checks: Coolify monitors container health
- Coolify API: POST /api/v1/deploy for programmatic deploys

## Conventions
- Dockerfile at project root for predictable builds
- .dockerignore to exclude node_modules, .git, etc.
- Health check endpoint: /api/health (for Coolify monitoring)
- Env vars: never in code — set via Coolify dashboard
- Database: provision via Coolify, use internal network hostname
- Persistent volumes: configured in Coolify for data directories
```

## Workflow Example

You want to deploy a Next.js app with a PostgreSQL database on Coolify. Prompt Claude Code:

"Set up this Next.js project for Coolify deployment. Create a production Dockerfile, add a health check endpoint, and document the Coolify configuration for connecting to a Coolify-provisioned PostgreSQL database."

Claude Code should create a multi-stage `Dockerfile` optimized for Next.js standalone output, add a `/api/health` endpoint returning 200, and document that the PostgreSQL connection string is available as an environment variable configured in Coolify's dashboard, using the internal Docker network hostname for the database service.

## Common Pitfalls

1. **Using localhost for database connections.** Claude writes `DATABASE_URL=postgresql://localhost:5432`. In Coolify, services communicate over Docker networks using service hostnames, not localhost. Use the hostname Coolify assigns to the database service.

2. **Missing health check endpoint.** Claude deploys without a health check. Coolify uses health checks to determine if a deployment succeeded. Without one, Coolify cannot roll back failed deployments automatically.

3. **Large Docker images wasting server resources.** Claude creates single-stage Docker builds that include dev dependencies and build tools. Coolify runs on your own server with limited resources — use multi-stage builds to keep production images small.

## Related Guides

- [Claude Code Docker Compose Production Guide](/claude-code-docker-compose-production-guide/)
- [Claude Code AWS Lambda Deployment Guide](/claude-code-aws-lambda-deployment-guide/)
- [Best Claude Skills for DevOps and Deployment](/best-claude-skills-for-devops-and-deployment/)

## Related Articles

- [Claude Code for WebDriverIO Automation Workflow](/claude-code-for-webdriverio-automation-workflow/)
- [Claude Code for Runbook Review Process Workflow](/claude-code-for-runbook-review-process-workflow/)
- [Claude Code for Cloud Run Jobs Workflow](/claude-code-for-cloud-run-jobs-workflow/)
- [Claude Code Sre Reliability — Complete Developer Guide](/claude-code-sre-reliability-engineering-workflow-guide/)
- [Claude Code for TorchScript Workflow Guide](/claude-code-for-torchscript-workflow-guide/)
- [Claude Code for Viem Ethereum Workflow Guide](/claude-code-for-viem-ethereum-workflow-guide/)
- [Claude Code for Great Expectations Data Workflow](/claude-code-for-great-expectations-data-workflow/)
- [Claude Code for OpenLineage Workflow Tutorial Guide](/claude-code-for-openlineage-workflow-tutorial-guide/)
