---
layout: default
title: "Claude Code Weights and Biases Experiment Tracking"
description: "Learn how to integrate Claude Code with Weights & Biases for powerful ML experiment tracking, automated logging, and streamlined model development workflows."
date: 2026-03-14
categories: [guides]
tags: [claude-code, weights-and-biases, experiment-tracking, ml, mlops]
author: theluckystrike
reviewed: false
score: 0
permalink: /claude-code-weights-and-biases-experiment-tracking/
---

{% raw %}
# Claude Code Weights and Biases Experiment Tracking

Machine learning experimentation requires careful tracking of hyperparameters, metrics, and artifacts. Weights & Biases (W&B) has become the standard for experiment tracking, and when combined with Claude Code's CLI capabilities, you get a powerful workflow for automating your ML development pipeline. This guide shows you how to integrate Claude Code with Weights & Biases for seamless experiment tracking.

## Setting Up W&B with Claude Code

Before integrating with Claude Code, ensure you have W&B installed and authenticated:

```bash
pip install wandb
wandb login
```

Your API key will be stored locally after authentication. Claude Code can then interact with W&B through shell commands or by reading output from W&B CLI operations.

## Creating a Claude Skill for Experiment Tracking

Build a dedicated skill for managing W&B experiments. Create `skills/wandb-experiment.md`:

```markdown
---
name: wandb-exp
description: "Track ML experiments with Weights & Biases"
tools:
  - Bash
  - Read
  - Write
---

# Weights & Biases Experiment Tracking

This skill helps initialize runs, log metrics, and track experiments in W&B.

## Initialize a New Experiment Run

To start a new experiment:
1. Run `wandb init` to configure the project
2. Use `wandb.init()` in your training script
3. Log parameters, metrics, and artifacts as needed
```

## Logging Metrics from Training Scripts

When Claude Code runs your training scripts, it can capture W&B output and help you analyze results. Here's a practical example using a simple training script:

```python
import wandb
import torch
import torch.nn as nn

# Initialize W&B run with parameters
wandb.init(
    project="image-classification",
    config={
        "learning_rate": 0.001,
        "batch_size": 32,
        "epochs": 10,
        "optimizer": "adam"
    }
)

# Simple training loop
model = nn.Linear(784, 10)
optimizer = torch.optim.Adam(model.parameters(), lr=wandb.config.learning_rate)

for epoch in range(wandb.config.epochs):
    for batch in data_loader:
        optimizer.zero_grad()
        loss = model(batch.x)
        loss.backward()
        optimizer.step()
        
        # Log training metrics
        wandb.log({
            "train_loss": loss.item(),
            "epoch": epoch
        })
    
    # Log validation metrics at end of epoch
    val_loss = evaluate(model, val_data)
    wandb.log({
        "val_loss": val_loss,
        "epoch": epoch,
        "accuracy": compute_accuracy(model, val_data)
    })

wandb.finish()
```

Claude Code can execute this script and monitor the W&B output in real-time, giving you visibility into training progress without leaving your terminal.

## Using Claude Code to Compare Experiments

One of W&B's strongest features is comparing runs. Claude Code can help you query and analyze experiment results:

```bash
# List recent experiments in your project
wandb sweep create --project image-classification config.yaml
wandb agent image-classification/<sweep-id>
```

After experiments complete, use Claude Code to fetch and compare results:

```python
import wandb

api = wandb.Api()

# Fetch all runs from a project
runs = api.runs("theluckystrike/image-classification")

# Find best performing run
best_run = min(runs, key=lambda r: r.summary.get("val_loss", float("inf")))

print(f"Best run: {best_run.name}")
print(f"Validation loss: {best_run.summary['val_loss']}")
print(f"Test accuracy: {best_run.summary['accuracy']}")
```

This approach lets Claude Code analyze your experiment history and help you identify optimal hyperparameters.

## Automating Experiment Tracking with Claude Code

You can create custom Claude commands that automatically log information to W&B. For instance, a skill that tracks dataset information:

```markdown
---
name: track-data
description: "Log dataset statistics to W&B"
tools:
  - Bash
  - Read
---

# Dataset Tracking

Track dataset versions and statistics:
- Run dataset profiling scripts
- Log dataset hash and statistics to W&B
- Associate dataset version with experiment runs
```

Use this skill to ensure reproducibility by automatically attaching dataset metadata to every experiment.

## Integrating with Existing W&B Workflows

Claude Code complements your existing W&B setup:

1. **Sweep Automation**: Let Claude Code manage hyperparameter sweeps by generating sweep configurations and launching agents
2. **Artifact Management**: Use Claude Code to version and track model artifacts in W&B
3. **Report Generation**: Pull W&B metrics and generate summary reports using Claude Code

```python
# Log model artifacts
artifact = wandb.Artifact(
    name="trained-model",
    type="model",
    metadata={"accuracy": 0.95, "framework": "pytorch"}
)
artifact.add_file("model.pt")
run.log_artifact(artifact)
```

## Best Practices for Claude Code + W&B Integration

- **Consistent Naming**: Use clear, descriptive names for runs and experiments
- **Parameter Tracking**: Always log all hyperparameters to W&B config
- **Metric Logging**: Log both training and validation metrics at appropriate intervals
- **Artifact Versioning**: Use W&B artifacts to version models, datasets, and preprocessing code
- **Early Stopping**: Monitor validation metrics and implement early stopping to prevent overfitting
- **Grouping Experiments**: Use W&B groups to organize related experiments (e.g., different seeds, augmentation strategies)

## Advanced: Creating a Complete Training Workflow

Here's how you might structure a complete training workflow with Claude Code orchestrating the process:

1. **Pre-training**: Claude Code checks dataset availability, validates data integrity, and logs dataset version to W&B
2. **Training**: Execute training script with W&B logging enabled, monitoring progress in real-time
3. **Post-training**: Analyze results, compare with previous runs, and log model artifacts

```python
# Complete workflow example
import wandb
import hashlib
import os

def log_dataset_info(data_path):
    """Log dataset information for reproducibility"""
    dataset_hash = hashlib.md5(open(data_path, 'rb').read()).hexdigest()
    wandb.log({
        "dataset_hash": dataset_hash,
        "dataset_path": data_path,
        "dataset_size": os.path.getsize(data_path)
    })

# Pre-training
log_dataset_info("train_data.pt")

# Training (simplified)
wandb.init(project="my-project", name="experiment-001")
# ... training code ...

# Post-training
best_model = find_best_model()
wandb.log_artifact(best_model, name="best-model")
```

## Debugging Failed Experiments

When experiments fail, Claude Code can help you investigate:

```python
# Fetch failed runs and their error logs
api = wandb.Api()
failed_runs = [r for r in api.runs("project") if r.state == "failed"]

for run in failed_runs:
    print(f"Run: {run.name}")
    print(f"Error: {run.summary.get('failed_error', 'Unknown')}")
    print(f"Crash logs: {run.files['stderr'].download()}")
```

This debugging capability helps you quickly identify and fix issues in your training pipeline.

## Conclusion

Combining Claude Code with Weights & Biases gives you powerful experiment tracking capabilities. Claude Code can execute training scripts, analyze results, and help you manage your ML workflow while W&B handles the heavy lifting of metrics logging and comparison. Start by creating dedicated skills for your experiment tracking needs, and progressively add more automation as your workflow matures. The integration enables reproducible research, easier debugging, and faster iteration cycles for your machine learning projects.
{% endraw %}
