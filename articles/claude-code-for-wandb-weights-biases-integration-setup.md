---
layout: default
title: "Claude Code for W&B Weights & Biases Integration Setup"
description: "A practical guide to integrating Claude Code with Weights & Biases for experiment tracking, model versioning, and ML workflow automation."
date: 2026-03-14
categories: [tutorials]
tags: [claude-code, claude-skills, wandb, weights-biases, mlops, experiment-tracking, ai-engineering]
author: "Claude Skills Guide"
reviewed: true
score: 7
---

# Claude Code for W&B Weights & Biases Integration Setup

Integrating Claude Code with Weights & Biases (W&B) transforms how you track machine learning experiments, manage model versions, and collaborate on AI projects. For a broader look at integration patterns, visit the [integrations hub](/claude-skills-guide/integrations-hub/). This guide covers practical setup steps, configuration patterns, and workflow examples that work directly within Claude Code sessions.

## Why Combine Claude Code with W&B

Claude Code brings AI-assisted development to your workflow, while W&B provides experiment tracking, model registry, and visualization capabilities. Using them together means you can write training scripts, debug model behavior, and log results without leaving your Claude session. The combination appeals to developers building production ML systems and researchers running iterative experiments.

W&B integration requires minimal setup. You need a W&B account, your API key, and the `wandb` Python package. Claude Code then interacts with W&B through shell commands and Python scripts you write during your session.

## Setting Up W&B with Claude Code

First, install the W&B library in your Python environment:

```
uv pip install wandb
```

Or if you prefer pip:

```
pip install wandb
```

Next, authenticate with W&B. The standard approach uses an API key:

```
wandb login
```

This command prompts you for your API key, found at your W&B settings page. For scripted workflows, set the environment variable:

```
export WANDB_API_KEY=your_key_here
```

You can include this in your shell profile or a `.env` file that Claude Code loads when working on your project.

## Basic Experiment Tracking Example

Create a simple training script that logs metrics to W&B. Here's a practical example:

```python
import wandb
import torch
import torch.nn as nn
from torchvision import datasets, transforms

# Initialize W&B run
wandb.init(
    project="mnist-classifier",
    config={
        "learning_rate": 0.01,
        "batch_size": 64,
        "epochs": 10,
        "optimizer": "adam"
    }
)

# Simple neural network
model = nn.Sequential(
    nn.Flatten(),
    nn.Linear(784, 128),
    nn.ReLU(),
    nn.Linear(128, 10)
)

optimizer = torch.optim.Adam(model.parameters(), lr=wandb.config.learning_rate)
loss_fn = nn.cross_entropy_loss()

# Training loop
for epoch in range(wandb.config.epochs):
    for batch_idx, (data, target) in enumerate(train_loader):
        optimizer.zero_grad()
        output = model(data)
        loss = loss_fn(output, target)
        loss.backward()
        optimizer.step()
        
        if batch_idx % 100 == 0:
            wandb.log({
                "epoch": epoch,
                "loss": loss.item(),
                "step": batch_idx
            })

wandb.finish()
```

When you run this script, W&B creates a run in your project, logs the configuration, and tracks loss values. Each logged step appears in the W&B dashboard with timestamps and system metrics.

## Integrating with Claude Skills

Several Claude skills enhance W&B workflows. The **tdd** skill helps you write tests for training pipelines before implementation — see the [automated testing pipeline with Claude TDD skill](/claude-skills-guide/automated-testing-pipeline-with-claude-tdd-skill-2026/) guide for details. When building model training code, invoke the skill:

```
/tdd
```

Then describe your training logic. Claude applies test-driven development principles, generating test cases for data loading, model forward passes, and metric calculations. This approach catches bugs before they affect your experiment runs.

The **pdf** skill becomes useful when generating reports from W&B data. After completing experiments, use it to create documentation:

```
/pdf
```

Describe what you need—a summary of run results, comparison charts, or hyperparameter tables—and Claude produces a formatted PDF document with your W&B metrics.

The **supermemory** skill complements W&B by tracking context across sessions. When working on long ML projects, invoke it to maintain notes about experiment configurations, key findings, and model decisions:

```
/supermemory
```

This creates a persistent knowledge base that connects your Claude sessions with your W&B experiment history.

## Advanced W&B Features in Claude Code

Beyond basic logging, W&B offers features that integrate smoothly with Claude Code workflows.

### Model Registry

Store and version models directly in W&B:

```python
wandb.init(job_type="train")
# ... training code ...
artifact = wandb.Artifact("model weights", type="model")
artifact.add_file("model.pt")
wandb.log_artifact(artifact)
```

In Claude Code, you reference these artifacts in subsequent sessions by name, loading checkpointed weights for fine-tuning or evaluation.

### Sweeps for Hyperparameter Optimization

W&B sweeps automate hyperparameter search. Define a sweep configuration:

```yaml
program: train.py
method: bayes
metric:
  name: validation_loss
  goal: minimize
parameters:
  learning_rate:
    distribution: log_uniform
    min: 0.0001
    max: 0.1
  batch_size:
    values: [32, 64, 128]
```

Run the sweep controller from your terminal within Claude Code, then monitor results in the W&B dashboard while Claude assists with code modifications between runs.

### Artifacts for Data Versioning

Version datasets alongside models:

```python
artifact = wandb.Artifact("training-data", type="dataset")
artifact.add_dir("./data/train")
wandb.log_artifact(artifact)
```

Later sessions can pull specific dataset versions, ensuring reproducibility across experiments.

## Project Structure Recommendations

Organize your ML projects to use both Claude Code and W&B effectively:

- **Config files**: Store W&B configurations in `configs/` with version control
- **Scripts**: Keep training and evaluation scripts in `scripts/` or `src/`
- **Notebooks**: Use W&B's integrated notebooks or export results for Claude's **pptx** skill to present findings
- **Artifacts**: Name artifacts consistently—`dataset-v1`, `model-run42`—for easy retrieval

When starting a new ML project in Claude Code, create a `wandb.env` file containing your API key (add it to `.gitignore`) and source it in your shell:

```
source wandb.env
```

## Common Integration Patterns

Developers frequently use these patterns when combining Claude Code with W&B:

1. **Iterative debugging**: Log model outputs at intermediate layers, inspect in W&B, then modify architecture in Claude Code
2. **A/B testing**: Compare model variants by logging to separate W&B run names, analyzing results, then refining
3. **Collaboration**: Share W&B run links in Claude Code session notes, enabling team members to reproduce experiments
4. **CI/CD integration**: Trigger W&B runs from deployment scripts, tracking performance in production environments — the [Claude Skills with GitHub Actions CI/CD Pipeline](/claude-skills-guide/claude-skills-with-github-actions-ci-cd-pipeline/) guide covers the automation patterns

The **internal-comms** skill helps when documenting these workflows for team distribution, generating status updates that reference specific W&B run IDs.

## Summary

Setting up Claude Code with Weights & Biases requires only a few configuration steps—install the package, authenticate, and start logging. The real value emerges in how you structure experiments, version models, and collaborate. Claude skills like tdd, pdf, supermemory, and internal-comms enhance this workflow by adding testing rigor, documentation generation, context persistence, and team communication.

By combining AI-assisted coding from Claude Code with experiment tracking from W&B, you build a development environment where every model iteration connects to its source code, hyperparameters, and results.

## Related Reading

- [Claude Skills for Data Science and Jupyter: 2026 Guide](/claude-skills-guide/claude-skills-for-data-science-and-jupyter-notebooks/) — combine Jupyter notebooks with Claude skills for end-to-end ML workflows
- [Automated Testing Pipeline with Claude TDD Skill](/claude-skills-guide/automated-testing-pipeline-with-claude-tdd-skill-2026/) — apply TDD to ML training pipelines and evaluation scripts
- [Claude Code LLM Evaluation and Benchmarking Workflow](/claude-skills-guide/claude-code-llm-evaluation-and-benchmarking-workflow/) — systematically evaluate and compare model performance
- [Claude Skills with GitHub Actions CI/CD Pipeline](/claude-skills-guide/claude-skills-with-github-actions-ci-cd-pipeline/) — automate experiment tracking as part of your CI/CD pipeline

Built by theluckystrike — More at [zovo.one](https://zovo.one)
