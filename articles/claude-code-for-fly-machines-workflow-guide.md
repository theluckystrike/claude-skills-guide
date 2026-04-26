---
layout: default
title: "Claude Code for Fly Machines (2026)"
description: "Claude Code for Fly Machines — practical guide with working examples, tested configurations, and tips for developer workflows."
date: 2026-04-18
permalink: /claude-code-for-fly-machines-workflow-guide/
categories: [workflow, niche-tools]
tags: [claude-code, fly-io, workflow]
---

## The Setup

You are deploying applications on Fly.io using Machines, the lightweight VM platform that starts in milliseconds and runs your Docker containers globally. Fly Machines provide fine-grained control over compute placement, auto-scaling, and geographic distribution. Claude Code can write Fly.io configurations, but it generates Heroku or AWS deployment patterns.

## What Claude Code Gets Wrong By Default

1. **Creates Heroku Procfiles.** Claude writes `web: node server.js` Heroku format. Fly.io uses `fly.toml` for configuration and Docker for builds — no Procfile needed.

2. **Uses AWS-style load balancer config.** Claude configures ALB target groups. Fly.io handles load balancing automatically through its Anycast network — requests route to the nearest Machine based on the fly-replay header and geographic proximity.

3. **Ignores Fly's multi-region capability.** Claude deploys to a single region. Fly Machines can run in 30+ regions simultaneously, placing your app near users worldwide with `fly machine clone --region nrt`.

4. **Sets up external databases.** Claude provisions RDS or PlanetScale. Fly provides built-in Postgres (`fly postgres create`), LiteFS for distributed SQLite, and Tigris for S3-compatible object storage.

## The CLAUDE.md Configuration

```
# Fly.io Machines Project

## Platform
- Deploy: Fly.io (lightweight VMs, global distribution)
- Config: fly.toml at project root
- CLI: fly (flyctl)
- Build: Docker (Dockerfile required)

## Fly.io Rules
- Deploy: fly deploy (builds Docker, pushes, starts Machines)
- Config: fly.toml for app settings, scaling, services
- Regions: fly regions add nrt lhr iad (multi-region)
- Scale: fly scale count 3 (multiple Machines)
- Secrets: fly secrets set DATABASE_URL=... (encrypted)
- Postgres: fly postgres create (managed, Fly-internal)
- Volumes: fly volumes create data --region iad --size 10
- Health checks: configured in fly.toml [[services.checks]]

## Conventions
- Dockerfile at project root (multi-stage for production)
- fly.toml committed to version control
- Secrets via fly secrets set, never in fly.toml
- Health check endpoint: /health or /up
- Internal services: .internal hostname for service-to-service
- Volumes for persistent data (databases, uploads)
- Use fly proxy for local database access
```

## Workflow Example

You want to deploy a Node.js API with a managed Postgres database. Prompt Claude Code:

"Deploy this Express app to Fly.io with a managed Postgres database. Configure auto-scaling from 1 to 5 machines, add health checks, and set up the DATABASE_URL secret."

Claude Code should create/verify the `Dockerfile`, configure `fly.toml` with `[[services]]` for HTTP, `[[services.checks]]` for health, `[processes]` for the app, run `fly postgres create` for the database, attach it with `fly postgres attach`, and configure auto-scaling with `fly autoscale set min=1 max=5`.

## Common Pitfalls

1. **Volume attachment across regions.** Claude creates a volume in one region and tries to access it from Machines in other regions. Fly volumes are region-specific — a Machine can only mount volumes in the same region. Create volumes in each region where Machines run.

2. **Missing internal DNS for multi-service.** Claude connects between Fly apps using public URLs. Fly apps communicate internally via `appname.internal` DNS over the private WireGuard network. Use internal addresses for service-to-service calls to avoid public network latency and egress.

3. **Fly Postgres is not managed RDS.** Claude treats Fly Postgres like a fully managed service. Fly Postgres runs as a regular Fly app — you are responsible for backups, monitoring, and failover configuration. Set up `fly postgres backup` and monitoring.



**Find the right skill →** Browse 155+ skills in our [Skill Finder](/skill-finder/).

## Related Guides

**Try it:** Paste your error into our [Error Diagnostic](/diagnose/) for an instant fix.

- [Best Claude Skills for DevOps and Deployment](/best-claude-skills-for-devops-and-deployment/)
- [Claude Code Docker Compose Production Guide](/claude-code-docker-compose-production-guide/)
- [Best Way to Use Claude Code with Existing CI/CD](/best-way-to-use-claude-code-with-existing-ci-cd/)

## Related Articles

- [Claude Code Unleash Strategy: Custom Activation Workflow](/claude-code-unleash-strategy-custom-activation-workflow/)
- [Claude Code for Inspector v2 Workflow](/claude-code-for-inspector-v2-workflow/)
- [Claude Code for Diagramming: Mermaid Workflow Guide](/claude-code-for-diagramming-mermaid-workflow/)
- [Claude Code for Dependabot Configuration Workflow](/claude-code-for-dependabot-configuration-workflow/)
- [Claude Code for Amber: Bash Scripting Workflow Guide](/claude-code-for-amber-bash-scripting-workflow-guide/)
- [Claude Code for SolidJS Resources Workflow Guide](/claude-code-for-solidjs-resources-workflow-guide/)
- [Claude Code for Hive Metastore Workflow Guide](/claude-code-for-hive-metastore-workflow-guide/)
- [Claude Code for Release Candidate Workflow Tutorial](/claude-code-for-release-candidate-workflow-tutorial/)


## Common Questions

### How do I get started with claude code for fly machines?

Begin with the setup instructions in this guide. Install the required dependencies, configure your environment, and test with a small project before scaling to your full codebase.

### What are the prerequisites?

You need a working development environment with Node.js or Python installed. Familiarity with the command line and basic Git operations is helpful. No advanced AI knowledge is required.

### Can I use this with my existing development workflow?

Yes. These techniques integrate with standard development tools and CI/CD pipelines. Start by adding them to a single project and expand once you have verified the benefits.

### Where can I find more advanced techniques?

Explore the related resources below for deeper coverage. The Claude Code documentation and community forums also provide advanced patterns and real-world case studies.

## Related Resources

- [Claude Code Announcements 2026](/anthropic-claude-code-announcements-2026/)
- [Fix Stream Idle Timeout in Claude Code](/anthropic-sdk-streaming-hang-timeout/)
- [How to Audit Your Claude Code Token](/audit-claude-code-token-usage-step-by-step/)
