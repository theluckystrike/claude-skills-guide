---
layout: default
title: "Claude Code for Modal Serverless ML"
description: "Claude Code for Modal Serverless ML — practical guide with working examples, tested configurations, and tips for developer workflows."
date: 2026-04-18
permalink: /claude-code-for-modal-serverless-ml-workflow-guide/
categories: [workflow, niche-tools]
tags: [claude-code, modal, workflow]
---

## The Setup

You are deploying machine learning workloads with Modal, a serverless platform designed for ML inference and batch processing. Modal provides GPU containers that scale to zero, custom container images defined in Python, and a Python-native SDK for deploying functions. Claude Code can set up ML infrastructure, but it generates Docker + Kubernetes configurations instead of Modal's Python-first approach.

## What Claude Code Gets Wrong By Default

1. **Creates Dockerfiles and Kubernetes manifests.** Claude writes Dockerfile, deployment.yaml, and service.yaml for ML serving. Modal replaces all of this with Python decorators — `@app.function(gpu="A100")` is the entire infrastructure definition.

2. **Uses Flask/FastAPI for serving.** Claude creates REST API servers for inference. Modal has `@app.web_endpoint()` that creates HTTPS endpoints directly — no web framework needed.

3. **Manages container images separately.** Claude writes a Dockerfile for the ML environment. Modal defines images in Python: `modal.Image.debian_slim().pip_install("torch", "transformers")` — the image is built and cached by Modal.

4. **Provisions static GPU instances.** Claude sets up always-on GPU servers. Modal scales to zero and cold-starts in seconds — you pay only for active compute, not idle GPUs.

## The CLAUDE.md Configuration

```
# Modal ML Deployment

## Infrastructure
- Platform: Modal (serverless ML compute)
- GPU: A100, H100, T4, L4 on-demand
- Scale: auto-scale to zero, pay per second
- Deploy: modal deploy app.py

## Modal Rules
- App: app = modal.App("my-app")
- Function: @app.function(gpu="A100", image=image)
- Image: modal.Image.debian_slim().pip_install(...)
- Web: @app.web_endpoint() for HTTP endpoints
- Cron: @app.function(schedule=modal.Period(hours=1))
- Volumes: modal.Volume for persistent storage
- Secrets: modal.Secret.from_name("my-secret")

## Conventions
- Define images in Python, not Dockerfiles
- Use @app.cls() for stateful GPU functions (model loading)
- Load model in __enter__, inference in methods
- @modal.enter() for one-time setup per container
- Use volumes for model cache (avoid re-download)
- modal serve app.py for local development
- modal deploy app.py for production
```

## Workflow Example

You want to deploy a text-to-image model for inference. Prompt Claude Code:

"Deploy a Stable Diffusion XL model on Modal with a web endpoint. Use an A100 GPU, cache the model weights in a Modal Volume to avoid re-downloading, and return the generated image as a PNG response. Include a health check endpoint."

Claude Code should create a Modal app with a custom image installing `diffusers` and `torch`, a `@app.cls(gpu="A100")` class that loads the model in `@modal.enter()` from a Volume cache, an inference method with `@modal.web_endpoint()` that accepts a prompt and returns a PNG, and a simple health check endpoint.

## Common Pitfalls

1. **Re-downloading models on every cold start.** Claude loads models from Hugging Face in the function body. Without a Modal Volume for caching, the model downloads on every container start. Use `modal.Volume` to persist model weights across invocations.

2. **Not using @app.cls for stateful functions.** Claude loads the model inside the function on every call. Modal's `@app.cls()` with `@modal.enter()` loads the model once per container lifecycle — subsequent calls reuse the loaded model.

3. **Image layer cache invalidation.** Claude puts frequently changing code in the image definition. Modal caches image layers — put stable dependencies in the image and dynamic code in the function. Use `modal.Mount` for code that changes between deploys.

## Related Guides

- [Claude Code for Groq Inference Workflow Guide](/claude-code-for-groq-inference-workflow-guide/)
- [Claude Code for Ollama Local LLM Workflow Guide](/claude-code-for-ollama-local-llm-workflow-guide/)
- [Best AI Tools for Backend Development 2026](/best-ai-tools-for-backend-development-2026/)


## Common Questions

### How do I get started with claude code for modal serverless ml?

Begin with the setup instructions in this guide. Install the required dependencies, configure your environment, and test with a small project before scaling to your full codebase.

### What are the prerequisites?

You need a working development environment with Node.js or Python installed. Familiarity with the command line and basic Git operations is helpful. No advanced AI knowledge is required.

### Can I use this with my existing development workflow?

Yes. These techniques integrate with standard development tools and CI/CD pipelines. Start by adding them to a single project and expand once you have verified the benefits.

### Where can I find more advanced techniques?

Explore the related resources below for deeper coverage. The Claude Code documentation and community forums also provide advanced patterns and real-world case studies.

## Related Resources

- [Claude Code for Accessible Modal Dialog](/claude-code-for-accessible-modal-dialog-implementation/)
- [Claude Code For Apache Spark Ml](/claude-code-for-apache-spark-ml-workflow/)
- [Claude Code For Beam Cloud Ml](/claude-code-for-beam-cloud-ml-workflow-guide/)
