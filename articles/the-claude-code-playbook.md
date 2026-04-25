---
layout: default
title: "Claude Code Guides: Complete Collection"
description: "Complete Claude Code collection: 50 error fixes, 25 CLAUDE.md templates, 15 orchestration configs, and 100 proven prompts. Tested April 2026."
date: 2026-04-19
last_tested: "2026-04-21"
author: "Claude Skills Guide"
permalink: /playbook/
categories: [playbook]
tags: [claude-code, playbook, templates, errors, prompts, cost-optimization]
score: 10
---

# The Claude Code Playbook

**200 battle-tested patterns, curated from 3,000+ articles.**

This is not another list of tips. Every pattern in this collection has been tested, scored, and ranked by real-world effectiveness. We reviewed over 3,000 Claude Code articles and distilled them down to the 200 that actually matter.

**What you get:**

- **50 error fixes** -- exact solutions, not vague suggestions
- **25 CLAUDE.md templates** -- copy-paste ready for 20+ frameworks
- **15 orchestration configs** -- production-ready Docker, CI/CD, and MCP setups
- **10 cost optimization patterns** -- with real dollar amounts and math you can verify
- **100 prompts and skills** -- organized by what you actually do every day

---

## Error Fixes (50)

**Stop debugging. Start fixing.**

Every error article follows the same structure: the exact error message, the root cause, the fix, and how to prevent it from happening again. No guesswork.

| # | Error | Fix |
|---|-------|-----|
| 1 | [Claude API Error 401 authentication_error Fix](/claude-api-error-401-authenticationerror-explained/) | Invalid API keys, environment variable setup, SDK authentication |
| 2 | [Claude Code Error: Unexpected Token in JSON Response Fix](/claude-code-error-unexpected-token-in-json-response-fix/) | JSON parsing failures, debugging techniques, prevention |
| 3 | [Stream Idle Timeout -- Fix Partial Response Error](/anthropic-sdk-streaming-hang-timeout/) | Idle timeout detection code for streaming large inputs |
| 4 | [Fix: Claude Code Image 400 Error Loop](/claude-code-image-could-not-process-400/) | Unrecoverable image processing 400 error workaround |
| 5 | [Fix: MCP Server Disconnected Error](/claude-code-mcp-server-disconnected/) | Progress token handling in stdio transport |
| 6 | [Fix: SDK TypeError: terminated Streaming](/anthropic-sdk-typeerror-terminated/) | Intermittent undici failures with large streaming inputs |
| 7 | [Claude API Error 413 request_too_large Fix](/claude-api-error-413-requesttoolarge-explained/) | Request size limits for Messages, Batch, and Files endpoints |
| 8 | [Fix Claude API Error 500 Apierror Explained](/claude-api-error-500-apierror-explained/) | Retry strategies and error handling in Python/TypeScript SDKs |
| 9 | [Fix: Claude Code Slow Response Latency](/claude-code-slow-response-fix/) | Diagnose and fix 2+ minute latency and minimal output |
| 10 | [Fix Claude Code TLS/SSL Errors Behind Proxy](/claude-code-tls-ssl-connection-error-corporate-proxy-fix/) | TLS connect errors and certificate failures behind proxies |
| 11 | [Fix 'command not found: claude' After Install](/claude-code-command-not-found-after-install-fix/) | PATH fixes for macOS, Linux, and Windows |
| 12 | [Fix Claude Code Install Killed on Linux](/claude-code-install-killed-low-memory-linux-fix/) | Swap space fix for low-memory Linux servers and VPS |
| 13 | [Fix Claude Tool Use Not Working](/claude-tool-use-not-working/) | Tool definition validation, tool_choice, strict mode |
| 14 | [Claude API Error 429 rate_limit_error Fix](/claude-api-error-429-ratelimiterror-explained/) | Retry logic, backoff strategies, rate limit headers |
| 15 | [Claude API Error 529 overloaded_error Fix](/claude-api-error-529-overloadederror-explained/) | Retry strategies, fallback models, and Batch API |
| 16 | [Fix Docker Build Failures When Using Claude Code](/claude-code-docker-build-failed-fix/) | Multi-stage build errors, dependencies, layer caching |
| 17 | [Fix: Claude Code Auth Fails on Headless Linux](/claude-code-headless-linux-auth/) | OAuth token refresh blocked by Cloudflare WAF |
| 18 | [Fix: Claude Code High Token Usage](/claude-code-high-token-usage/) | Context accumulation and token consumption control |
| 19 | [Fix Claude Code Login -- Cannot Paste Auth Code](/claude-code-login-paste-fix/) | Paste bracket mode, Linux, WSL auth code issues |
| 20 | [Fix Claude Code NPM Install Eacces Permission](/claude-code-npm-install-eacces-permission-fix/) | npm EACCES permission denied during installs |
| 21 | [Fix Prisma Migration Failures with Claude Code](/claude-code-prisma-migration-failed-fix/) | Drift detection, failed migrations, data loss warnings |
| 22 | [Fix WebSocket Connection Failures in Claude Code](/claude-code-websocket-connection-failed-fix/) | WS handshake failures, proxy issues, CORS errors |
| 23 | [Fix Claude Opus Prefill Not Supported Error](/claude-opus-prefill-not-supported-error-fix/) | Use structured outputs or system prompts instead |
| 24 | [Fix Claude Code Econnrefused MCP](/claude-code-econnrefused-mcp-fix/) | ECONNREFUSED when connecting to MCP servers |
| 25 | [Fix ESLint and Prettier Conflicts in Claude Code Projects](/claude-code-eslint-prettier-conflict-fix/) | Configure ESLint and Prettier to work together |
| 26 | [Fix Claude Extended Thinking Not Working](/claude-extended-thinking-not-working/) | budget_tokens validation, tool_choice conflicts |
| 27 | [Fix Claude Md Not Being Read By Claude Code](/claude-md-not-being-read-by-claude-code-fix/) | CLAUDE.md file loading troubleshooting |
| 28 | [Fix Claude Prompt Caching Not Working](/claude-prompt-caching-not-working/) | Minimum token thresholds, cache invalidation |
| 29 | [Fix Claude Code Bun Errors](/claude-code-bun-error/) | Bun runtime module resolution and compatibility |
| 30 | [Claude Code Maximum Call Stack Exceeded: Skill Debug Guide](/claude-code-maximum-call-stack-exceeded-skill-debug/) | Recursive call stack overflow in skills |
| 31 | [Fix Next.js Hydration Errors Using Claude Code](/claude-code-next-js-hydration-error-fix/) | Server/client rendering differences, dynamic content |
| 32 | [Claude Code Skill Circular Dependency Detected Error Fix](/claude-code-skill-circular-dependency-detected-error-fix/) | Circular dependency resolution in skills |
| 33 | [Fix TypeScript Strict Mode Errors with Claude Code](/claude-code-typescript-strict-mode-errors-fix/) | strictNullChecks, noImplicitAny, strict initialization |
| 34 | [Claude Code Error: Git Push Rejected During Skill Fix](/claude-code-error-git-push-rejected-during-skill-fix/) | Branch conflicts and skill synchronization |
| 35 | [Claude Code Keeps Adding Unnecessary Console.log](/claude-code-keeps-adding-unnecessary-console-log-statements/) | Prevent unwanted console.log injection |
| 36 | [Fix Skill Invalid YAML Syntax Error How to Debug](/claude-code-skill-invalid-yaml-syntax-error-how-to-debug/) | YAML syntax debugging in Claude skills |
| 37 | [Claude Skills Directory GitHub: Fix Skill Not Found](/claude-code-skill-not-found-in-skills-directory-how-to-fix/) | Skills directory configuration |
| 38 | [Claude Code Gives Incorrect Imports: How to Fix](/claude-code-gives-incorrect-imports-how-to-fix/) | Import statement fixes for JS, Python, TypeScript |
| 39 | [Fix: Claude Code PreToolUse Hooks Stop Working](/claude-code-pretooluse-hooks-bypassed/) | Hooks bypassed after background tasks complete |
| 40 | [Fix Cannot Read Properties of Undefined](/claude-code-cannot-read-property-undefined-null-error/) | input_tokens, trim, and OAuth null errors |
| 41 | [Claude Code Error: npm install Fails in Skill Workflow](/claude-code-error-npm-install-fails-in-skill-workflow/) | Dependency issues with pdf, puppeteer skills |
| 42 | [Claude Says Response Incomplete -- How to Fix](/claude-code-keeps-outputting-incomplete-truncated-code/) | Context limits, prompt structure, output settings |
| 43 | [Claude Code Unknown Skill Error: Fix Spawn Issues](/claude-code-spawn-unknown-error-node-skill-fix/) | Spawn failures, child_process path issues |
| 44 | [Fix: Anthropic SDK toolRunner Drops Headers](/anthropic-sdk-toolrunner-drops-headers/) | defaultHeaders dropped on follow-up requests |
| 45 | [Fix Claude Code Esm Module Not Found Import](/claude-code-esm-module-not-found-import-error-fix/) | CommonJS vs ESM configuration conflicts |
| 46 | [Claude Code Stuck in Loop Repeating Same Output Fix](/claude-code-stuck-in-loop-repeating-same-output-fix/) | Break repetitive output patterns |
| 47 | [Fix: Structured Output + Thinking + Tool Use Bugs](/anthropic-sdk-structured-output-thinking-tool-use-bug/) | Missing tool_use blocks, invalid combinations |
| 48 | [Fix Claude Code Not Working After Update](/claude-code-not-working-after-update-how-to-fix/) | Skill failures, path errors post-update |
| 49 | [Fix Skills Context Window Exceeded](/claude-code-skills-context-window-exceeded-error-fix/) | Token budgeting and session management |
| 50 | [Claude Code Keeps Producing Slightly Different Code](/claude-code-keeps-producing-slightly-different-code-each-tim/) | Achieve consistent, reproducible output |

---

## CLAUDE.md Templates (25)

**Copy. Paste. Ship.**

Each template is a production-ready CLAUDE.md file for a specific framework. Drop it in your project root and Claude Code immediately follows your team's conventions, naming patterns, and architecture rules.

### Framework-Specific Templates

| # | Template | Use Case |
|---|----------|----------|
| 1 | [CLAUDE.md for Go + Gin + GORM](/claude-md-example-for-go-gin-gorm/) | Go 1.23 API -- middleware chains, context propagation, error wrapping |
| 2 | [CLAUDE.md for Next.js + TypeScript](/claude-md-example-for-nextjs-typescript/) | Next.js 15 -- App Router, Server Components, Server Actions |
| 3 | [CLAUDE.md for Node.js + Express + Prisma](/claude-md-example-for-nodejs-express-prisma/) | Node.js 22 -- Express 5, Prisma 6, middleware patterns |
| 4 | [CLAUDE.md for Rails + Turbo + Stimulus](/claude-md-example-for-rails-turbo-stimulus/) | Rails 8.0 -- Hotwire, Turbo Streams, Stimulus controllers |
| 5 | [CLAUDE.md for Rust + Axum + SQLx](/claude-md-example-for-rust-axum-sqlx/) | Rust 1.83 -- Tower middleware, extractors, error handling |
| 6 | [CLAUDE.md for Django + PostgreSQL](/claude-md-example-for-django-postgresql/) | Django 5.1 -- DRF, Celery, migration safety |
| 7 | [CLAUDE.md for Elixir + Phoenix + LiveView](/claude-md-example-for-elixir-phoenix-liveview/) | Elixir 1.17 -- LiveView lifecycle, Ecto changesets |
| 8 | [CLAUDE.md for FastAPI + SQLAlchemy](/claude-md-example-for-fastapi-sqlalchemy/) | FastAPI 0.115 -- async patterns, Pydantic v2, Alembic |
| 9 | [CLAUDE.md for Flutter + Dart + Riverpod](/claude-md-example-for-flutter-dart-riverpod/) | Flutter 3.27 -- provider patterns, freezed, go_router |
| 10 | [CLAUDE.md for iOS + Swift + SwiftUI](/claude-md-example-for-ios-swift-swiftui/) | iOS 18 -- @Observable, SwiftData, async/await |
| 11 | [CLAUDE.md for Laravel + PHP](/claude-md-example-for-laravel-php/) | Laravel 11 -- Eloquent, Blade, queue workers |
| 12 | [CLAUDE.md for NestJS + TypeORM](/claude-md-example-for-nestjs-typeorm/) | NestJS 11 -- modules, providers, guards, interceptors |
| 13 | [CLAUDE.md for React + Vite + TypeScript](/claude-md-example-for-react-vite-typescript/) | React 19 -- Vite 6, HMR, lazy loading, Tanstack Query |
| 14 | [CLAUDE.md for Android + Kotlin + Jetpack Compose](/claude-md-example-for-android-kotlin-jetpack/) | Kotlin 2.1 -- Compose state, ViewModel, Room |
| 15 | [CLAUDE.md for React Native + Expo](/claude-md-example-for-react-native-expo/) | React Native 0.76 -- Expo SDK 52, EAS Build, Reanimated |
| 21 | CLAUDE.md for SvelteKit | SvelteKit 2.x -- Svelte 5 runes, form actions, Drizzle ORM |
| 22 | CLAUDE.md for Nuxt 3 + Vue | Nuxt 3.14 -- Vue 3 Composition API, Pinia, Nitro server routes |
| 23 | CLAUDE.md for Spring Boot + Java | Spring Boot 3.4 -- Java 21, JPA, Spring Security, virtual threads |
| 24 | CLAUDE.md for Astro | Astro 5.1 -- content collections, islands architecture, MDX |
| 25 | [CLAUDE.md for .NET + ASP.NET Core](/claude-md-example-for-dotnet-aspnet-core-project/) | ASP.NET Core 9.0 -- C# 13, EF Core 9, minimal APIs, MediatR |

### Pattern-Specific Templates

| # | Template | Use Case |
|---|----------|----------|
| 16 | [CLAUDE.md for Testing Conventions](/claude-md-testing-conventions/) | Test structure, coverage requirements, mocking strategies |
| 17 | [CLAUDE.md for Error Handling Patterns](/claude-md-error-handling-patterns/) | Prevent silent failures, typed errors, recovery |
| 18 | [CLAUDE.md for API Design Patterns](/claude-md-api-design-patterns/) | REST endpoints, response envelopes, pagination, versioning |
| 19 | [CLAUDE.md for Frontend Projects](/claude-md-frontend-projects/) | React components, state management, styling, a11y |
| 20 | [CLAUDE.md for Security Rules](/claude-md-security-rules/) | Prevent SQL injection, XSS, insecure auth at generation time |

---

## Orchestration Configs (15)

**Production-ready configs with WHY comments.**

These are not toy examples. Each config has been extracted from real production environments. They include failure modes, edge cases, and the reasoning behind every setting.

| # | Config | What It Covers |
|---|--------|---------------|
| 1 | [Container Environment Variables in Claude Code](/claude-code-container-environment-variables-management/) | Secrets, config injection, Docker Compose env management |
| 2 | [Claude Code Docker CI/CD Pipeline Integration](/claude-code-docker-ci-cd-pipeline-integration-guide/) | Docker-based CI/CD pipeline automation |
| 3 | [Claude Code Docker Compose Development Workflow](/claude-code-docker-compose-development-workflow/) | Local dev, testing, and deployment with Compose |
| 4 | [Claude Code MCP Server Incident Response Guide](/claude-code-mcp-server-incident-response-guide/) | MCP server diagnostics, log analysis, recovery |
| 5 | [Best Claude Skills for DevOps and Deployment](/best-claude-skills-for-devops-and-deployment/) | Shell scripting, Docker, Terraform, CI/CD, security |
| 6 | [Claude Code AWS ECS Fargate Setup and Deployment](/claude-code-aws-ecs-fargate-setup-deployment-tutorial/) | Task definitions, secrets management, CI/CD |
| 7 | [Claude Code for Azure Arc Kubernetes](/claude-code-for-azure-arc-kubernetes-workflow/) | Arc-enabled cluster management, deployment automation |
| 8 | [Claude Code for Carvel ytt Templating](/claude-code-for-carvel-ytt-workflow-tutorial/) | Advanced Carvel ytt config templating |
| 9 | [Claude Code GitHub Actions Caching Strategies](/claude-code-github-actions-caching-strategies/) | CI/CD caching for faster pipeline runs |
| 10 | [Claude Code Vercel Deployment Guide](/claude-code-vercel-deployment-nextjs-workflow-guide/) | Vercel + Next.js deploys, previews, environment management |
| 11 | [Jira MCP Server Claude Code Integration](/jira-mcp-server-claude-code-integration-guide/) | Project management automation via MCP |
| 12 | [MCP Transport Layer Security TLS Configuration](/mcp-transport-layer-security-tls-configuration/) | TLS for MCP servers with security best practices |
| 13 | [Slack MCP Server Team Notification Automation](/slack-mcp-server-team-notification-automation/) | CI/CD alerts, deploy notifications, monitoring |
| 14 | [Telegram MCP Server Bot Automation](/telegram-mcp-server-bot-automation-workflow/) | Message handling, workflow automation, security |
| 15 | [Claude Code Chaos Engineering Testing Automation](/claude-code-chaos-engineering-testing-automation-guide/) | Resilience testing with Claude skills |

---

## Cost Optimization (10)

**Cut your Claude API bill by 50%+.**

Every article includes real dollar amounts, verifiable math, and before/after comparisons. No hand-waving. These techniques compound -- use them together and the savings stack.

| # | Pattern | Savings |
|---|---------|---------|
| 1 | [Token-Efficient Few-Shot Examples for Claude](/token-efficient-few-shot-examples-claude/) | Compress 2,000 to 400 tokens -- save $80 per 10K Opus requests |
| 2 | [Web Search Costs $10 per 1,000 Searches](/claude-web-search-costs-10-per-thousand/) | Understand true cost: $750/month at 1,000 daily searches |
| 3 | [Claude Caching for Multi-Turn Conversations](/claude-caching-multi-turn-conversations/) | Save 76% on multi-turn -- $0.72 to $0.17 per 8-turn chat |
| 4 | [Claude Batch API 50% Discount Complete Guide](/claude-batch-api-50-percent-discount-guide/) | Opus drops from $5/$25 to $2.50/$12.50 per million tokens |
| 5 | [Prompt Compression Techniques for Claude API](/prompt-compression-techniques-claude-api/) | Reduce token count by 30-60% -- save $75 per 10K Opus requests |
| 6 | [System Prompt Optimization to Cut Claude Costs](/system-prompt-optimization-cut-claude-costs/) | Compress 2,000 to 500 tokens -- 75% input cost reduction |
| 7 | [Reduce Claude Code Token Consumption by 60%](/reduce-claude-code-token-consumption-60-percent/) | Five techniques: targeted reads, compact, session splitting |
| 8 | [Optimizing Tool Schemas to Cut Token Count](/optimizing-tool-schemas-reduce-token-count/) | Trim schemas by 50% -- save $50 per 10K Opus requests |
| 9 | [Claude API Cost Dashboard Setup Guide 2026](/claude-api-cost-dashboard-setup-guide-2026/) | Real-time spend tracking -- teams save $2,400/month from visibility |
| 10 | [Chunking Strategies to Cut Claude Context Costs](/chunking-strategies-cut-claude-context-costs/) | Reduce 500K context to 30K -- save $70.50 per 50 requests |

---

## Prompts and Skills (100)

**100 techniques that work.**

Organized by what you actually do: write code, review PRs, debug issues, deploy to production. Each article includes a prompt you can copy, an explanation of why it works, and guidance on adapting it to your codebase.

### Skill Creation (8 articles)

Build, share, and optimize custom Claude Code skills.

| # | Article |
|---|---------|
| 1 | [Claude Skill .md File Format: Full Specification Guide](/claude-skill-md-format-complete-specification-guide/) |
| 3 | [How to Share Claude Skills with Team: Complete Guide](/how-to-share-claude-skills-with-your-team/) |
| 8 | [How to Contribute Claude Skills to Open Source](/how-to-contribute-claude-skills-to-open-source/) |
| 31 | [How to Optimize Claude Skill Prompts for Accuracy](/how-to-optimize-claude-skill-prompts-for-accuracy/) |
| 34 | [Advanced Claude Skills with Tool Use and Function Calling](/advanced-claude-skills-with-tool-use-and-function-calling/) |
| 46 | [Build Your First Claude Code Skill in 5 Minutes](/building-your-first-claude-skill/) |
| 51 | [Claude Skills Marketplace Guide for Publishers](/claude-skills-marketplace-skillsmp-guide-for-publishers/) |
| 52 | [Antigravity vs Claude Native Skills: Complete Guide](/antigravity-skills-vs-claude-native-skills/) |

### Prompt Engineering (8 articles)

Write prompts that produce consistent, accurate results on the first try.

| # | Article |
|---|---------|
| 4 | [How to Use Tree of Thought Prompting with Claude Code](/claude-code-for-tree-of-thought-prompting-workflow-guide/) |
| 7 | [Claude Code for Few-Shot Prompting Best Practices Workflow](/claude-code-for-few-shot-prompting-best-practices-workflow/) |
| 13 | [Speed Up Claude Code Responses with Better Prompt Structure](/speed-up-claude-code-responses-with-better-prompt-structure/) |
| 16 | [How to Write Effective Prompts for Claude Code](/how-to-write-effective-prompts-for-claude-code/) |
| 18 | [Claude Code for Self-Consistency Prompting Workflow](/claude-code-for-self-consistency-prompting-workflow-tutorial/) |
| 19 | [Claude Code Prompt Management Workflow Guide](/claude-code-prompt-management-workflow-guide/) |
| 61 | [Claude Code for Prompt Chaining Workflows](/claude-code-for-prompt-chaining-workflows-tutorial-guide/) |
| 62 | [Claude Code Debugging Prompts That Work](/claude-code-debugging-prompt/) |

### Code Review (8 articles)

Automate PR reviews, enforce standards, and catch issues before merge.

| # | Article |
|---|---------|
| 5 | [Claude Code Automated Pull Request Review Workflow](/claude-code-automated-pull-request-review-workflow-guide/) |
| 39 | [Claude Code Engineering Manager Pull Request Review Workflow](/claude-code-engineering-manager-pull-request-review-workflow/) |
| 47 | [Claude Code for Pair Review Workflow Tutorial Guide](/claude-code-for-pair-review-workflow-tutorial-guide/) |
| 72 | [Claude Skills Code Review Workflow for Pull Requests](/claude-skills-code-review-workflow/) |
| 74 | [AI Assisted Code Review Workflow Best Practices](/ai-assisted-code-review-workflow-best-practices/) |
| 75 | [Code Review Workflow with Claude Code](/how-to-make-claude-code-review-its-own-output/) |
| 87 | [Claude Code for ESLint Custom Plugin Workflow](/claude-code-for-eslint-custom-plugin-workflow-tutorial/) |
| 88 | [Claude Code for OSS Code Review Contribution Guide](/claude-code-for-oss-code-review-contribution-guide/) |

### Performance (8 articles)

Profile, optimize, and reduce latency across your stack.

| # | Article |
|---|---------|
| 6 | [Claude Code for Go Pprof Profiling](/claude-code-for-go-pprof-profiling-workflow-tutorial/) |
| 10 | [Claude Code for Node.js Profiling](/claude-code-for-nodejs-profiling-workflow-tutorial/) |
| 14 | [Claude Code for Dead Code Elimination](/claude-code-for-dead-code-elimination-workflow-guide/) |
| 38 | [Claude Code for P99 Latency Optimization](/claude-code-for-p99-latency-optimization-workflow/) |
| 43 | [Bundle Size Reduction: Webpack to Vite 2026 Guide](/claude-code-bundle-size-reduction-webpack-vite-workflow/) |
| 58 | [Claude Code for Rust Profiling Workflow](/claude-code-for-rust-profiling-workflow-tutorial-guide/) |
| 63 | [Claude Skills Slow Performance Speed Up Guide](/claude-skills-slow-performance-speed-up-guide/) |
| 64 | [Claude Code for CDN Optimization Workflow](/claude-code-for-cdn-optimization-workflow-tutorial/) |

### Debugging (8 articles)

Systematic approaches to finding and fixing bugs with Claude Code.

| # | Article |
|---|---------|
| 9 | [Claude Code Capacitor Hybrid App Debugging Workflow](/claude-code-capacitor-hybrid-app-debugging-workflow/) |
| 17 | [Fix Claude Code Over-Engineers Simple Solutions](/claude-code-over-engineers-simple-solution-fix/) |
| 23 | [Claude Code Crashes When Loading Skill: Debug Guide](/claude-code-crashes-when-loading-skill-debug-steps/) |
| 29 | [How to Make Claude Code Explain Its Reasoning Steps](/how-to-make-claude-code-explain-its-reasoning-steps/) |
| 44 | [Claude Code Debug Configuration Workflow](/claude-code-debug-configuration-workflow/) |
| 49 | [Claude Code Skill Circular Dependency Error Fix](/claude-code-skill-circular-dependency-detected-error-fix/) |
| 50 | [Claude Code CS50 Project Help and Debugging Guide](/claude-code-cs50-project-help-and-debugging-guide/) |
| 53 | [Fix Claude Skill Not Triggering Automatically](/claude-skill-not-triggering-automatically-troubleshoot/) |

### Testing (8 articles)

Generate tests that catch real bugs -- property testing, snapshot testing, browser testing, and more.

| # | Article |
|---|---------|
| 20 | [Claude Code Hypothesis Property Testing Guide](/claude-code-hypothesis-property-testing-guide/) |
| 40 | [Claude Code Jest Snapshot Testing Workflow Best Practices](/claude-code-jest-snapshot-testing-workflow-best-practices/) |
| 55 | [Claude Code for Documentation Testing](/claude-code-for-documentation-testing-workflow-guide/) |
| 70 | [Claude Code Selenium Browser Testing Automation](/claude-code-selenium-browser-testing-automation-guide/) |
| 76 | [Claude Code Pytest Parametrize Advanced Workflow Patterns](/claude-code-pytest-parametrize-advanced-workflow-patterns/) |
| 84 | [Claude Code L10n Testing Automation Workflow](/claude-code-l10n-testing-automation-workflow-tutorial/) |
| 92 | [Claude Code JUnit5 Test Patterns Guide](/claude-code-junit5-test-patterns-guide/) |
| 96 | [Claude Code Artillery Performance Testing](/claude-code-artillery-performance-testing/) |

### DevOps (8 articles)

CI/CD pipelines, container management, cloud deployments, and infrastructure as code.

| # | Article |
|---|---------|
| 12 | [Claude Code DevOps Engineer CI/CD Pipeline Daily Workflow](/claude-code-devops-engineer-ci-cd-pipeline-daily-workflow/) |
| 30 | [Claude Code Nix Flake Reproducible Development Environment](/claude-code-nix-flake-reproducible-development-environment/) |
| 56 | [Claude Code GCP Google Cloud Setup and Deployment Guide](/claude-code-gcp-google-cloud-setup-and-deployment-guide/) |
| 59 | [Claude Code Kubernetes Persistent Volumes Guide](/claude-code-kubernetes-persistent-volumes-guide/) |
| 77 | [Claude Code for Fly.io Deployment Automation](/claude-code-for-fly-io-deployment-automation-workflow/) |
| 81 | [Claude Skills + AWS Lambda: Serverless Guide](/claude-skills-aws-lambda-serverless-integration/) |
| 85 | [Claude Code Docker Health Checks Guide](/claude-code-docker-health-checks-guide/) |
| 89 | [Claude Code Container Security Scanning Workflow](/claude-code-container-security-scanning-workflow-guide/) |

### Development Workflows (8 articles)

Daily workflows, package publishing, data management, and developer tools.

| # | Article |
|---|---------|
| 21 | [Claude Code for PR Diff Analysis](/claude-code-for-pr-diff-analysis-workflow-tutorial/) |
| 24 | [How to Use Claude Data Access Permissions: Retention](/claude-code-data-retention-policy-workflow/) |
| 25 | [Claude Code for PyPI Package Publishing](/claude-code-for-pypi-package-publishing-workflow-guide/) |
| 26 | [How to Use Claude Knowledge Base Markdown Files: Setup](/claude-code-for-knowledge-base-workflow-tutorial-guide/) |
| 28 | [Claude Code for Call Graph Analysis](/claude-code-for-call-graph-analysis-workflow-tutorial/) |
| 37 | [Claude Code Developer Portal Setup Guide](/claude-code-developer-portal-setup-guide/) |
| 41 | [Claude Code for Maven Artifact Publishing](/claude-code-for-maven-artifact-publishing-workflow/) |
| 42 | [Claude Code Skills for C# .NET Developers](/claude-code-skills-for-c-sharp-dotnet-developers/) |

### Frontend (7 articles)

Component architecture, style guides, naming conventions, and cross-platform development.

| # | Article |
|---|---------|
| 11 | [Claude CLAUDE.md for Fullstack Projects](/claude-md-for-fullstack-projects-complete-guide/) |
| 22 | [How to Make Claude Code Follow Team Style Guide](/how-to-make-claude-code-follow-team-style-guide/) |
| 27 | [Claude Code Daily Workflow for Frontend Developers](/claude-code-daily-workflow-for-frontend-developers-guide/) |
| 35 | [How to Make Claude Code Follow My Naming Conventions](/how-to-make-claude-code-follow-my-naming-conventions/) |
| 80 | [How to Use Astro Workflow](/claude-code-astro-static-site-generation-workflow-guide/) |
| 94 | [Claude CLAUDE.md Example for Remix Fullstack Application](/claude-md-example-for-remix-fullstack-application/) |
| 99 | [Claude Code for Redwood JS Fullstack Workflow](/claude-code-for-redwood-js-fullstack-workflow-guide/) |

### Git Workflow (6 articles)

Branching strategies, monorepo management, and commit enforcement.

| # | Article |
|---|---------|
| 2 | [Claude Code Conventional Commits Enforcement Workflow](/claude-code-conventional-commits-enforcement-workflow/) |
| 45 | [Organize Claude Skills in a Monorepo: Best Way](/what-is-the-best-way-to-organize-claude-skills-in-a-monorepo/) |
| 57 | [Claude Code Git Worktree Parallel Development Workflow](/claude-code-git-worktree-parallel-development-workflow/) |
| 65 | [Claude Code for Release Branching Strategy](/claude-code-for-release-branching-strategy-workflow/) |
| 69 | [Claude Code Skills Monorepo Management Workflow](/claude-code-skills-monorepo-management-workflow/) |
| 83 | [Claude Code Git Workflow Best Practices Guide](/claude-code-git-workflow-best-practices-guide/) |

### Documentation (6 articles)

API reference generation, changelogs, docs-as-code, and automated documentation.

| # | Article |
|---|---------|
| 33 | [Claude Code API Reference Generation Guide](/claude-code-api-reference-generation-guide/) |
| 36 | [Automated Code Documentation Workflow with Claude Skills](/automated-code-documentation-workflow-with-claude-skills/) |
| 60 | [Claude Code for Docs as Code Workflow](/claude-code-for-docs-as-code-workflow-tutorial-guide/) |
| 68 | [Claude Code for Keep a Changelog Workflow](/claude-code-for-keep-a-changelog-workflow-tutorial/) |
| 73 | [Claude Code Confluence Documentation Guide](/claude-code-confluence-documentation-guide/) |
| 86 | [Claude Code for Technical Documentation Workflow](/claude-code-for-technical-documentation-workflow-guide/) |

### Database (7 articles)

ORM workflows, query optimization, infrastructure as code for data stores.

| # | Article |
|---|---------|
| 32 | [How to Use TypeORM Entities Relations Migration](/claude-code-typeorm-entities-relations-migration-workflow/) |
| 54 | [Claude Code for CDKTF Terraform CDK Workflow](/claude-code-for-cdktf-terraform-cdk-workflow/) |
| 66 | [Claude Code Dart Flutter Cross Platform Development](/claude-code-dart-flutter-cross-platform-development-guide/) |
| 67 | [Claude Code for Terraform Cloud Run Workflow](/claude-code-for-terraform-cloud-run-workflow-guide/) |
| 82 | [How to Use Supabase Full Stack Apps](/claude-code-skills-for-supabase-full-stack-apps-guide/) |
| 98 | [Claude Code ActiveRecord Query Optimization](/claude-code-activerecord-query-optimization-workflow-guide/) |
| 100 | [Claude Code Laravel Eloquent ORM](/claude-code-laravel-eloquent-orm-guide/) |

### API Development (4 articles)

Tool use, function calling, OpenAPI spec generation, and API client development.

| # | Article |
|---|---------|
| 15 | [Claude API Tool Use and Function Calling Deep Dive](/claude-api-tool-use-function-calling-deep-dive-guide/) |
| 78 | [How to Use OpenAPI Spec Generation](/claude-code-openapi-spec-generation-guide/) |
| 79 | [Claude Code Rails API Mode Full Stack Workflow](/claude-code-rails-api-mode-full-stack-workflow/) |
| 90 | [Claude Code API Client TypeScript Guide](/claude-code-api-client-typescript-guide/) |

### Architecture (4 articles)

Refactoring legacy code, design patterns, microservices, and parallel agents.

| # | Article |
|---|---------|
| 48 | [How to Use Claude Code to Refactor Legacy JavaScript](/how-to-use-claude-code-to-refactor-legacy-javascript-code/) |
| 91 | [Claude Code Design Patterns Refactoring Guide](/claude-code-design-patterns-refactoring-guide/) |
| 95 | [Claude Code for Monolith to Microservices Refactor](/claude-code-for-monolith-to-microservices-refactor-guide/) |
| 97 | [Claude Code Parallel Subagents -- Best Practices](/parallel-subagents-claude-code-best-practices-2026/) |

### Security (2 articles)

Prompt injection prevention and security engineering workflows.

| # | Article |
|---|---------|
| 71 | [How to Use MCP Prompt Injection Attack Prevention](/mcp-prompt-injection-attack-prevention-guide/) |
| 93 | [Claude Code Skills for Security Engineers and Pentesters](/claude-code-skills-for-security-engineers-and-pentesters/) |

---

## Get the Complete Playbook

**Want all 200 patterns in a single downloadable package?**

The complete Playbook includes every article above as clean markdown files, organized by category, plus a quick-start guide that tells you the 5 articles to read first.

Download the Complete Playbook -- Free with email signup.

The public half (100 patterns) is also available as a [GitHub repository](https://github.com/theluckystrike/claude-code-playbook) you can star, fork, and contribute to.


## Related

- [Claude shortcuts guide](/claude-shortcuts-complete-guide/) — Complete guide to Claude Code keyboard shortcuts and slash commands
- [Error Handling Reference](/error-handling/). Complete error diagnosis and resolution guide
- [Troubleshooting Guide](/troubleshooting/). Diagnose and fix any Claude Code issue

---

*Last updated: April 2026. Curated from 3,000+ Claude Code articles by the Claude Skills Guide team.*

