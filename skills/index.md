---
title: "Claude Skills — Complete Reference (2026)"
description: "Every aspect of Claude Skills: creation, team sharing, troubleshooting, use cases, architecture, comparisons."
permalink: /skills/
render_with_liquid: false
---

# Claude Skills Complete Reference

Claude Code skills extend what Claude can do by packaging instructions, scripts, and templates into reusable units. This reference covers everything from creating your first skill to deploying skills across enterprise teams.

## Getting Started

Build, test, and ship your first skill with the fundamentals.

- [Build Your First Claude Code Skill in 5 Minutes](/building-your-first-claude-skill/) -- Create a working SKILL.md from scratch with frontmatter and instructions
- [Claude Skills Folder Structure Explained](/claude-skills-folder-structure/) -- Directory layout, supporting files, and where skills live
- [Every SKILL.md Frontmatter Field Explained](/skill-md-file-frontmatter-fields-explained/) -- Complete reference for all 14 YAML frontmatter fields
- [Claude Skill Naming Conventions](/claude-skill-naming-conventions/) -- Naming rules, namespaces, and collision avoidance
- [Claude Skills Versioning Strategies](/claude-skills-versioning-strategies/) -- Semantic versioning and backward compatibility for skills
- [Claude Skills with Embedded Scripts](/claude-skills-with-embedded-scripts/) -- Bundle Python, Bash, and Node scripts inside skills
- [Claude Skills for Git, Docker, and Testing](/claude-skills-for-git-docker-testing/) -- Practical skills for common development workflows
- [Claude Skills vs MCP Servers](/claude-skills-vs-mcp-servers-differences/) -- When to use each and how they complement each other
- [Publishing Claude Skills to GitHub](/publishing-claude-skills-to-github/) -- Share skills via git repositories
- [Testing Claude Skills Before Production](/testing-claude-skills-before-production/) -- Validation, dry runs, and quality checks

## Team Collaboration

Share skills across teams without conflicts or breaking workflows.

- [How to Share Claude Skills with Your Team](/how-to-share-claude-skills-with-team/) -- Distribution methods: git, plugins, managed settings
- [Managing Claude Skills Across Team Members](/managing-claude-skills-across-team-members/) -- Prevent naming conflicts and version drift
- [Claude Skills Distribution Methods](/claude-skills-distribution-methods/) -- Project, personal, enterprise, and plugin scopes
- [Claude Skills CI/CD Patterns](/claude-skills-ci-cd-patterns/) -- Automate skill testing and deployment in pipelines
- [Claude Skills Code Review Workflow](/claude-skills-code-review-workflow/) -- Review process for skill changes
- [Claude Skills Library Pattern for Organizations](/claude-skills-library-pattern-for-orgs/) -- Centralized skill libraries for large teams
- [Claude Skills Onboarding for New Developers](/claude-skills-onboarding-new-developers/) -- Getting new team members productive with skills
- [Security Review Process for Claude Skills](/security-review-process-for-claude-skills/) -- Audit skills for safety before deployment
- [Team SKILL.md Conventions Style Guide](/team-skill-md-conventions-style-guide/) -- Consistent skill authoring across a team
- [Update Shared Skills Without Breaking Workflows](/updating-shared-claude-skills-without-breaking-workflows/) -- Safe rollout strategies for skill changes

## Troubleshooting

Fix the most common Claude Skills errors.

- [Fix Claude Code Skills Not Showing Up](/fix-claude-code-skills-not-showing-up/) -- Diagnostic steps when skills do not appear in the menu
- [Fix Unknown Skill Error](/fix-unknown-skill-error-claude-code/) -- Resolve "unknown skill" after renaming or moving
- [Fix ENOENT No Such File or Directory](/fix-claude-code-enoent-skills/) -- Path resolution and missing file errors
- [Fix Skill Timeout Errors](/fix-claude-skill-timeout-errors/) -- Timeout causes and remediation strategies
- [Fix Spawn Unknown Error](/fix-claude-code-spawn-unknown-error-skills/) -- Script execution failures in skills
- [Fix Malformed YAML Frontmatter](/fix-malformed-yaml-frontmatter-skill-md/) -- Common YAML syntax errors and fixes
- [Fix Skill Name Already in Use](/fix-skill-name-already-in-use-error/) -- Naming conflicts across scopes
- [Fix Claude Not Finding Skills Directory](/fix-claude-not-finding-skills-directory/) -- Directory placement and discovery issues
- [Fix Skill Infinite Loop](/fix-claude-skill-infinite-loop/) -- Break recursive skill invocations
- [Fix Skill Conflicts with MCP Server](/fix-skill-conflicts-with-mcp-server/) -- Namespace collisions and resolution

## By Industry

Practical skill implementations for specific verticals.

- [Claude Skills for E-Commerce](/claude-skills-for-ecommerce-platforms/) -- Product catalog, pricing, and inventory automation
- [Claude Skills for Financial Analysis](/claude-skills-for-financial-analysis/) -- Portfolio analysis, risk assessment, and compliance
- [Claude Skills for Legal Document Review](/claude-skills-for-legal-document-review/) -- Contract analysis, clause extraction, and due diligence
- [Claude Skills for Medical Records](/claude-skills-for-medical-records-processing/) -- CPT codes, FHIR validation, and clinical notes
- [Claude Skills for Academic Research](/claude-skills-for-academic-research/) -- Literature review, citation, and statistical validation
- [Claude Skills for Logistics](/claude-skills-for-logistics-supply-chain/) -- HS codes, shipment tracking, and inventory alerts
- [Claude Skills for Real Estate](/claude-skills-for-real-estate-data-extraction/) -- Property data, comps, and listing automation
- [Claude Skills for Manufacturing QA](/claude-skills-for-manufacturing-qa/) -- Quality control, defect tracking, and SPC
- [Claude Skills for Travel Booking](/claude-skills-for-travel-booking-platforms/) -- Itinerary optimization and fare comparison
- [Claude Skills for SEO Content](/claude-skills-for-seo-content-generation/) -- Content optimization and keyword targeting

## Architecture & Patterns

Advanced patterns for building complex skill systems.

- [How to Combine Multiple Claude Skills](/how-to-combine-multiple-claude-skills/) -- Composition patterns for multi-skill workflows
- [Claude Skill Composition Patterns](/claude-skill-composition-patterns/) -- Chain, fan-out, and pipeline architectures
- [Claude Skill Inheritance and Composition](/claude-skill-inheritance-composition/) -- Extend base skills without duplication
- [Claude Skills vs Subagents: When to Use Each](/claude-skills-vs-subagents-when-to-use/) -- Inline vs isolated execution
- [Claude Skills Data Flow Patterns](/claude-skills-data-flow-patterns/) -- Input/output contracts between skills
- [Claude Skills for Monorepo Projects](/claude-skills-for-monorepo-projects/) -- Nested discovery and team isolation
- [Claude Skill Registry Pattern](/claude-skill-registry-pattern-for-teams/) -- Centralized skill catalog for large organizations
- [Claude Skills Performance Optimization](/claude-skills-performance-optimization/) -- Reduce token usage and execution time
- [Claude Skills Shared Dependencies](/claude-skills-shared-dependencies/) -- Share templates and scripts across skills
- [Polyglot Claude Skills](/polyglot-claude-skills-multi-language/) -- Multi-language skill implementations

## Skills vs Alternatives

How Claude Skills compare to other approaches.

- [Claude Skills vs ChatGPT Custom GPTs](/claude-skills-vs-chatgpt-custom-gpts/) -- Feature-by-feature comparison
- [Claude Skills vs OpenAI Assistants API](/claude-skills-vs-openai-assistants-api/) -- Architecture, cost, and capability comparison
- [Claude Skills vs MCP Servers (Detailed)](/claude-skills-vs-mcp-servers-comparison/) -- When structured skills beat server-based tools
- [Claude Skills vs Subagents (Detailed)](/claude-skills-vs-subagents-comparison/) -- Inline instructions vs isolated execution
- [Claude Skills vs Claude AI Projects](/claude-skills-vs-claude-ai-projects/) -- Code skills vs web app projects
- [Claude Skills vs LangFlow Agents](/claude-skills-vs-langflow-ai-agents/) -- Markdown vs visual agent builders
- [Claude Skills vs Raw Prompts with Tools](/claude-skills-vs-raw-prompts-with-tools/) -- When structured skills beat ad-hoc prompting
- [Hybrid Patterns: Skills + MCP + Custom Tools](/hybrid-patterns-skills-mcp-custom-tools/) -- Combining approaches for maximum coverage
- [Claude Memory vs SuperMemory Skill](/claude-memory-vs-supermemory-skill/) -- Built-in vs skill-based memory
- [Migrating OpenAI Assistants to Claude Skills](/migrating-openai-assistants-to-claude-skills/) -- Step-by-step migration guide
