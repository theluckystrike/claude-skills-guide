---
layout: default
title: "Claude Code for Kamal Deploy (2026)"
description: "Claude Code for Kamal Deploy — practical guide with working examples, tested configurations, and tips for developer workflows."
date: 2026-04-18
permalink: /claude-code-for-kamal-deploy-workflow-guide/
categories: [workflow, niche-tools]
tags: [claude-code, kamal, workflow]
---

## The Setup

You are deploying web applications with Kamal (formerly MRSK), the deployment tool from 37signals that deploys Docker containers to bare servers with zero-downtime rolling deploys, automatic SSL, and no Kubernetes needed. Claude Code can configure Kamal deployments, but it generates Kubernetes manifests or Docker Compose files instead.

## What Claude Code Gets Wrong By Default

1. **Creates Kubernetes manifests.** Claude writes `deployment.yaml` with pod specs. Kamal deploys Docker containers directly to servers via SSH — no Kubernetes cluster, no orchestrator, just SSH and Docker.

2. **Uses Docker Compose for production.** Claude generates `docker-compose.yml` with service definitions. Kamal has its own config format (`config/deploy.yml`) that handles container orchestration, health checks, and rolling deploys.

3. **Ignores Traefik proxy integration.** Claude sets up Nginx as a reverse proxy manually. Kamal uses Traefik as an automatic proxy — it handles SSL, routing, and zero-downtime deploys out of the box.

4. **Manages servers with Terraform/Ansible.** Claude writes infrastructure provisioning code. Kamal does not provision servers — you provide existing servers and Kamal handles Docker, the proxy, and deployments.

## The CLAUDE.md Configuration

```
# Kamal Deployment Project

## Deploy
- Tool: Kamal (zero-downtime Docker deploys via SSH)
- Config: config/deploy.yml
- Proxy: Traefik (auto-managed by Kamal)
- SSL: automatic via Let's Encrypt through Traefik

## Kamal Rules
- Config in config/deploy.yml (YAML)
- Servers: list of IPs, Kamal SSHes to deploy
- Docker image: built and pushed to registry by Kamal
- Deploy: kamal deploy (build, push, rolling restart)
- Accessories: databases, Redis defined in config
- Secrets: stored in .kamal/secrets, injected as env vars
- Health check: /up endpoint required for zero-downtime
- Traefik handles SSL and routing automatically

## Conventions
- Dockerfile at project root (multi-stage for production)
- config/deploy.yml for main deploy config
- .kamal/secrets for environment variables (not committed)
- /up health check endpoint (returns 200 when ready)
- Accessory services: kamal accessory boot <name>
- Rollback: kamal rollback (revert to previous version)
- Logs: kamal app logs (tail container logs)
```

## Workflow Example

You want to deploy a Rails/Next.js app to a single server. Prompt Claude Code:

"Create a Kamal deploy configuration for deploying to a single server at 123.45.67.89. Configure the Docker image registry, add a PostgreSQL database as an accessory, and set up the health check endpoint."

Claude Code should create `config/deploy.yml` with the server IP, Docker registry configuration, a PostgreSQL accessory definition with volume persistence, the health check path pointing to `/up`, and a `.kamal/secrets` template for database credentials and registry auth.

## Common Pitfalls

1. **Missing the health check endpoint.** Claude deploys without a `/up` route. Kamal performs health checks during rolling deploys — without a working health check, Kamal cannot verify the new container is healthy and the deploy hangs or rolls back.

2. **Secrets not configured.** Claude puts environment variables directly in `deploy.yml`. Kamal reads secrets from `.kamal/secrets` and injects them — putting secrets in the config file commits them to version control.

3. **Docker registry authentication.** Claude forgets to configure registry credentials. Kamal builds images locally and pushes to a registry (Docker Hub, GHCR). The registry credentials must be in `.kamal/secrets` as `KAMAL_REGISTRY_PASSWORD`.

## Related Guides

- [Best Claude Skills for DevOps and Deployment](/best-claude-skills-for-devops-and-deployment/)
- [Claude Code Docker Compose Production Guide](/claude-code-docker-compose-production-guide/)
- [Best Way to Use Claude Code with Existing CI/CD](/best-way-to-use-claude-code-with-existing-ci-cd/)

## Related Articles

- [Deploy to Vercel with Claude Code](/claude-code-deploy-to-vercel/)
- [Deploy to AWS with Claude Code](/claude-code-deploy-to-aws/)
- [Claude Code for Railway Deploy — Workflow Guide](/claude-code-for-railway-deploy-workflow-guide/)


## Common Questions

### How do I get started with claude code for kamal deploy?

Begin with the setup instructions in this guide. Install the required dependencies, configure your environment, and test with a small project before scaling to your full codebase.

### What are the prerequisites?

You need a working development environment with Node.js or Python installed. Familiarity with the command line and basic Git operations is helpful. No advanced AI knowledge is required.

### Can I use this with my existing development workflow?

Yes. These techniques integrate with standard development tools and CI/CD pipelines. Start by adding them to a single project and expand once you have verified the benefits.

### Where can I find more advanced techniques?

Explore the related resources below for deeper coverage. The Claude Code documentation and community forums also provide advanced patterns and real-world case studies.

## Related Resources

- [Deploy to AWS with Claude Code](/claude-code-deploy-to-aws/)
- [Deploy to Vercel with Claude Code](/claude-code-deploy-to-vercel/)
- [Claude Code Wrong Environment Deploy](/claude-code-deploying-wrong-environment-prevent-mistakes/)
