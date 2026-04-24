---

layout: default
title: "Claude Code Weights and Biases"
description: "Learn how to integrate Claude Code with Weights & Biases for powerful ML experiment tracking, automated logging, and streamlined model development."
date: 2026-03-14
last_modified_at: 2026-04-17
categories: [guides]
tags: [claude-code, weights-and-biases, experiment-tracking, ml, mlops, claude-skills]
author: "Claude Skills Guide"
reviewed: true
score: 7
permalink: /claude-code-weights-and-biases-experiment-tracking/
geo_optimized: true
---


Claude Code Weights and Biases Experiment Tracking

Machine learning experimentation requires careful tracking of hyperparameters, metrics, and artifacts. Weights & Biases (W&B) has become the standard for experiment tracking, and when combined with Claude Code's CLI capabilities, you get a powerful workflow for automating your ML development pipeline. This guide shows you how to integrate Claude Code with Weights & Biases for smooth experiment tracking.

## Setting Up W&B with Claude Code

Before integrating with Claude Code, ensure you have W&B installed and authenticated:

```bash
pip install wandb
wandb login
```

Your API key will be stored locally after authentication. Claude Code can then interact with W&B through shell commands or by reading output from W&B CLI operations.

It is also worth installing the full ecosystem of packages you will likely use together:

```bash
pip install wandb torch torchvision scikit-learn pandas matplotlib
Verify wandb is reachable
wandb status
```

## Configuring a CLAUDE.md for ML Projects

Create a `CLAUDE.md` at your project root so Claude Code understands your ML setup without needing repeated context:

```markdown
ML Project: Image Classifier

Environment
- Python 3.11, PyTorch 2.2, CUDA 12.1
- W&B project: theluckystrike/image-classification

Key Commands
- `python train.py --config configs/baseline.yaml`. run training
- `wandb sweep configs/sweep.yaml --project image-classification`. launch sweep
- `wandb agent <sweep-id>`. start a sweep agent
- `python evaluate.py --run-id <id>`. evaluate a specific run

Experiment Naming Convention
- Format: `{model}-{dataset}-{notes}` e.g. `resnet50-cifar10-aug-v2`
- Groups: use dataset name as group for related ablations

Artifact Naming
- Models: `{model-name}-epoch{n}` stored as type "model"
- Datasets: `{dataset-name}-{split}` stored as type "dataset"
```

This file removes ambiguity when you ask Claude Code to "start a new experiment" or "compare the last three runs."

## Creating a Claude Skill for Experiment Tracking

Build a dedicated skill for managing W&B experiments. Create `skills/wandb-experiment.md`:

```markdown
---
name: wandb-exp
description: "Track ML experiments with Weights & Biases"
---

Weights & Biases Experiment Tracking

This skill helps initialize runs, log metrics, and track experiments in W&B.

Initialize a New Experiment Run

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

Initialize W&B run with parameters
wandb.init(
 project="image-classification",
 config={
 "learning_rate": 0.001,
 "batch_size": 32,
 "epochs": 10,
 "optimizer": "adam"
 }
)

Simple training loop
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

## Structured Training Script with W&B Best Practices

A more production-ready training script makes better use of W&B's features and gives Claude Code more to work with when analyzing results:

```python
import wandb
import torch
import torch.nn as nn
from torch.utils.data import DataLoader
from torchvision import datasets, transforms, models
import time

def build_model(architecture: str, num_classes: int) -> nn.Module:
 """Build a pretrained model and replace the final classifier."""
 if architecture == "resnet50":
 model = models.resnet50(pretrained=True)
 model.fc = nn.Linear(model.fc.in_features, num_classes)
 elif architecture == "efficientnet_b0":
 model = models.efficientnet_b0(pretrained=True)
 model.classifier[1] = nn.Linear(model.classifier[1].in_features, num_classes)
 else:
 raise ValueError(f"Unknown architecture: {architecture}")
 return model

def train_one_epoch(model, loader, optimizer, criterion, device, epoch):
 model.train()
 total_loss = 0
 correct = 0
 total = 0

 for batch_idx, (images, labels) in enumerate(loader):
 images, labels = images.to(device), labels.to(device)
 optimizer.zero_grad()
 outputs = model(images)
 loss = criterion(outputs, labels)
 loss.backward()
 optimizer.step()

 total_loss += loss.item()
 _, predicted = outputs.max(1)
 correct += predicted.eq(labels).sum().item()
 total += labels.size(0)

 # Log at every step for granular loss curves
 wandb.log({
 "train/step_loss": loss.item(),
 "train/step": epoch * len(loader) + batch_idx,
 })

 return total_loss / len(loader), 100.0 * correct / total

def validate(model, loader, criterion, device):
 model.eval()
 total_loss = 0
 correct = 0
 total = 0

 with torch.no_grad():
 for images, labels in loader:
 images, labels = images.to(device), labels.to(device)
 outputs = model(images)
 loss = criterion(outputs, labels)
 total_loss += loss.item()
 _, predicted = outputs.max(1)
 correct += predicted.eq(labels).sum().item()
 total += labels.size(0)

 return total_loss / len(loader), 100.0 * correct / total

def main():
 config = {
 "architecture": "resnet50",
 "dataset": "cifar10",
 "num_classes": 10,
 "learning_rate": 3e-4,
 "batch_size": 64,
 "epochs": 20,
 "optimizer": "adamw",
 "weight_decay": 1e-4,
 "scheduler": "cosine",
 "augmentation": "standard",
 }

 run = wandb.init(
 project="image-classification",
 config=config,
 tags=["resnet50", "cifar10", "baseline"],
 notes="Baseline run with cosine LR schedule",
 )

 device = torch.device("cuda" if torch.cuda.is_available() else "cpu")
 model = build_model(wandb.config.architecture, wandb.config.num_classes).to(device)
 wandb.watch(model, log="gradients", log_freq=100) # Track gradient norms

 optimizer = torch.optim.AdamW(
 model.parameters(),
 lr=wandb.config.learning_rate,
 weight_decay=wandb.config.weight_decay,
 )
 scheduler = torch.optim.lr_scheduler.CosineAnnealingLR(optimizer, T_max=wandb.config.epochs)
 criterion = nn.CrossEntropyLoss()

 best_val_acc = 0.0

 for epoch in range(wandb.config.epochs):
 t0 = time.time()
 train_loss, train_acc = train_one_epoch(model, train_loader, optimizer, criterion, device, epoch)
 val_loss, val_acc = validate(model, val_loader, criterion, device)
 scheduler.step()

 epoch_time = time.time() - t0

 wandb.log({
 "epoch": epoch,
 "train/loss": train_loss,
 "train/accuracy": train_acc,
 "val/loss": val_loss,
 "val/accuracy": val_acc,
 "lr": scheduler.get_last_lr()[0],
 "epoch_time_seconds": epoch_time,
 })

 # Save best model as W&B artifact
 if val_acc > best_val_acc:
 best_val_acc = val_acc
 torch.save(model.state_dict(), "best_model.pt")
 artifact = wandb.Artifact(
 name=f"resnet50-cifar10-epoch{epoch}",
 type="model",
 metadata={"val_accuracy": val_acc, "epoch": epoch},
 )
 artifact.add_file("best_model.pt")
 run.log_artifact(artifact)

 print(f"Training complete. Best val accuracy: {best_val_acc:.2f}%")
 wandb.finish()

if __name__ == "__main__":
 main()
```

When you ask Claude Code to run this script and report on it, it can monitor the W&B run URL, check metrics as they stream in, and flag early if the validation loss diverges from the training loss (a sign of overfitting).

## Using Claude Code to Compare Experiments

One of W&B's strongest features is comparing runs. Claude Code can help you query and analyze experiment results:

```bash
List recent experiments in your project
wandb sweep create --project image-classification config.yaml
wandb agent image-classification/<sweep-id>
```

After experiments complete, use Claude Code to fetch and compare results:

```python
import wandb

api = wandb.Api()

Fetch all runs from a project
runs = api.runs("theluckystrike/image-classification")

Find best performing run
best_run = min(runs, key=lambda r: r.summary.get("val_loss", float("inf")))

print(f"Best run: {best_run.name}")
print(f"Validation loss: {best_run.summary['val_loss']}")
print(f"Test accuracy: {best_run.summary['accuracy']}")
```

This approach lets Claude Code analyze your experiment history and help you identify optimal hyperparameters.

## Building a Richer Comparison Table

You can ask Claude Code to generate a comparison across multiple runs with a structured output:

```python
import wandb
import pandas as pd

api = wandb.Api()
runs = api.runs("theluckystrike/image-classification", filters={"state": "finished"})

records = []
for run in runs:
 records.append({
 "name": run.name,
 "architecture": run.config.get("architecture"),
 "lr": run.config.get("learning_rate"),
 "batch_size": run.config.get("batch_size"),
 "optimizer": run.config.get("optimizer"),
 "val_accuracy": run.summary.get("val/accuracy"),
 "val_loss": run.summary.get("val/loss"),
 "epochs": run.summary.get("epoch"),
 "duration_min": run.summary.get("_wandb", {}).get("runtime", 0) / 60,
 })

df = pd.DataFrame(records).sort_values("val_accuracy", ascending=False)
print(df.to_string(index=False))
```

Sample output Claude Code might produce from this:

```
name architecture lr batch_size optimizer val_accuracy val_loss epochs duration_min
resnet50-cosine-aug-v2 resnet50 0.0003 64 adamw 94.21 0.2103 20 47.3
resnet50-baseline resnet50 0.0010 32 adam 91.84 0.2891 20 52.1
efficientnet-b0-aug efficientnet_b0 0.0003 64 adamw 93.47 0.2241 20 38.6
resnet50-no-pretrain resnet50 0.0003 64 adamw 87.12 0.4102 20 46.9
```

From this table, Claude Code can immediately identify the key findings: cosine scheduling with AdamW outperforms plain Adam, pretraining makes a large difference, and EfficientNet-B0 is competitive with fewer training minutes.

## Automating Experiment Tracking with Claude Code

You can create custom Claude commands that automatically log information to W&B. For instance, a skill that tracks dataset information:

```markdown
---
name: track-data
description: "Log dataset statistics to W&B"
---

Dataset Tracking

Track dataset versions and statistics:
- Run dataset profiling scripts
- Log dataset hash and statistics to W&B
- Associate dataset version with experiment runs
```

Use this skill to ensure reproducibility by automatically attaching dataset metadata to every experiment.

## Dataset Artifact Logging

Reproducibility depends on knowing exactly which data was used to train each model. Claude Code can help you implement dataset versioning through W&B artifacts:

```python
import wandb
import hashlib
import os
import json
from pathlib import Path

def log_dataset_artifact(data_dir: str, split: str, project: str) -> wandb.Artifact:
 """
 Create a W&B artifact for a dataset split, including a manifest of all files.

 Args:
 data_dir: Path to the dataset directory.
 split: Dataset split name (train, val, test).
 project: W&B project name.

 Returns:
 The logged W&B artifact.
 """
 run = wandb.init(project=project, job_type="data-versioning")

 artifact = wandb.Artifact(
 name=f"cifar10-{split}",
 type="dataset",
 description=f"CIFAR-10 {split} split",
 metadata={"split": split, "source": "torchvision"},
 )

 # Build a file manifest with hashes for integrity checking
 manifest = {}
 data_path = Path(data_dir)
 for f in sorted(data_path.rglob("*")):
 if f.is_file():
 file_hash = hashlib.sha256(f.read_bytes()).hexdigest()
 manifest[str(f.relative_to(data_path))] = file_hash

 # Save manifest as metadata
 manifest_path = f"/tmp/manifest_{split}.json"
 with open(manifest_path, "w") as fp:
 json.dump(manifest, fp, indent=2)

 artifact.add_file(manifest_path, name="manifest.json")
 artifact.add_dir(data_dir, name=split)

 run.log_artifact(artifact)
 run.finish()

 return artifact

Call from Claude Code prompt: "version the CIFAR-10 train split"
artifact = log_dataset_artifact("data/cifar10/train", "train", "image-classification")
print(f"Artifact version: {artifact.version}")
```

Once the dataset is versioned as an artifact, you can pin any training run to a specific dataset version, making results fully reproducible even after the underlying data changes.

## Hyperparameter Sweep Automation

W&B sweeps let you search hyperparameter space systematically. Claude Code can generate sweep configs and manage agents for you.

## Generating a Sweep Configuration

Ask Claude Code: "Create a Bayesian sweep config for learning rate, batch size, and optimizer type":

```yaml
configs/sweep.yaml
program: train.py
method: bayes
metric:
 goal: maximize
 name: val/accuracy
early_terminate:
 type: hyperband
 min_iter: 5
parameters:
 learning_rate:
 distribution: log_uniform_values
 min: 1e-5
 max: 1e-2
 batch_size:
 values: [32, 64, 128]
 optimizer:
 values: [adam, adamw, sgd]
 weight_decay:
 distribution: log_uniform_values
 min: 1e-6
 max: 1e-2
 scheduler:
 values: [cosine, step, none]
```

Launch the sweep and agents with Claude Code executing the commands:

```bash
Claude Code runs these in sequence
wandb sweep configs/sweep.yaml --project image-classification
Returns: sweep ID, e.g., abc123

wandb agent theluckystrike/image-classification/abc123 --count 20
Runs 20 trials, logging all results to W&B
```

After the sweep completes, ask Claude Code to analyze results:

> "Which hyperparameters had the most impact on validation accuracy in the last sweep?"

Claude Code queries the W&B API, computes correlations between config values and the target metric, and summarizes findings like: "Learning rate had the strongest correlation (r=0.72). Batch size 64 outperformed 128 by an average of 1.3%. AdamW beat Adam in 18/20 trials."

## Integrating with Existing W&B Workflows

Claude Code complements your existing W&B setup:

1. Sweep Automation: Let Claude Code manage hyperparameter sweeps by generating sweep configurations and launching agents
2. Artifact Management: Use Claude Code to version and track model artifacts in W&B
3. Report Generation: Pull W&B metrics and generate summary reports using Claude Code

```python
Log model artifacts
artifact = wandb.Artifact(
 name="trained-model",
 type="model",
 metadata={"accuracy": 0.95, "framework": "pytorch"}
)
artifact.add_file("model.pt")
run.log_artifact(artifact)
```

## Comparison: W&B Experiment Management Approaches

| Approach | Setup Effort | Collaboration | Reproducibility | Claude Code Integration |
|---|---|---|---|---|
| W&B manual logging only | Low | Good (shared dashboard) | Medium | Basic. run scripts, view URLs |
| W&B + structured config files | Medium | Good | High | Strong. reads configs, suggests changes |
| W&B + artifacts for data + models | Medium-High | Excellent | Very High | Excellent. full lineage tracking |
| W&B sweeps + agents | Medium | Excellent | Very High | Best. automates launch and analysis |
| W&B + custom skills in CLAUDE.md | Low additional | Excellent | Very High | Optimal. context-aware automation |

The highest-value integration point is combining W&B artifacts (for data and model versioning) with Claude Code skills (for automating the workflow around them). This combination gives you reproducible experiments without manual bookkeeping.

## Best Practices for Claude Code + W&B Integration

- Consistent Naming: Use clear, descriptive names for runs and experiments
- Parameter Tracking: Always log all hyperparameters to W&B config
- Metric Logging: Log both training and validation metrics at appropriate intervals
- Artifact Versioning: Use W&B artifacts to version models, datasets, and preprocessing code
- Early Stopping: Monitor validation metrics and implement early stopping to prevent overfitting
- Grouping Experiments: Use W&B groups to organize related experiments (e.g., different seeds, augmentation strategies)
- Step vs. Epoch Logging: Log step-level loss for detailed curves and epoch-level accuracy for summaries. do both, they serve different diagnostic purposes
- Tags for Filtering: Add tags like `baseline`, `ablation`, `production` so Claude Code can filter runs intelligently when you ask for comparisons
- Use wandb.watch() Sparingly: Gradient tracking is useful for debugging but adds overhead. enable it for debug runs, disable for production sweeps

## Advanced: Creating a Complete Training Workflow

Here's how you might structure a complete training workflow with Claude Code orchestrating the process:

1. Pre-training: Claude Code checks dataset availability, validates data integrity, and logs dataset version to W&B
2. Training: Execute training script with W&B logging enabled, monitoring progress in real-time
3. Post-training: Analyze results, compare with previous runs, and log model artifacts

```python
Complete workflow example
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

Pre-training
log_dataset_info("train_data.pt")

Training (simplified)
wandb.init(project="my-project", name="experiment-001")
... training code ...

Post-training
best_model = find_best_model()
wandb.log_artifact(best_model, name="best-model")
```

## Automating the Full Cycle with Claude Code

The workflow above becomes fully automated when you give Claude Code a prompt like:

> "Run a full training cycle: version the dataset, train for 20 epochs, log artifacts, then compare this run's val accuracy against the last 5 runs and tell me if it improved."

Claude Code will:

1. Execute the dataset versioning script and capture the artifact ID
2. Launch training with the artifact ID injected into the run config
3. Monitor the W&B run URL until training completes
4. Query the API for the last 5 completed runs
5. Print a comparison table and a one-sentence verdict

This loop, version, train, compare, decide, is the core of modern ML experimentation, and Claude Code handles the mechanical parts so you can focus on the modeling decisions.

## Debugging Failed Experiments

When experiments fail, Claude Code can help you investigate:

```python
Fetch failed runs and their error logs
api = wandb.Api()
failed_runs = [r for r in api.runs("project") if r.state == "failed"]

for run in failed_runs:
 print(f"Run: {run.name}")
 print(f"Error: {run.summary.get('failed_error', 'Unknown')}")
 print(f"Crash logs: {run.files['stderr'].download()}")
```

This debugging capability helps you quickly identify and fix issues in your training pipeline.

## Common Failure Patterns and Fixes

| Failure Type | W&B Signal | Claude Code Action |
|---|---|---|
| CUDA OOM | Run crashes at epoch 1, no val metrics | Suggests reducing batch size or enabling gradient checkpointing |
| Exploding gradients | `train/step_loss` spikes to NaN | Recommends gradient clipping (`clip_grad_norm_`) |
| Learning rate too high | `val/loss` diverges from `train/loss` immediately | Suggests LR warmup or reducing by 10x |
| Overfitting | `val/loss` rises while `train/loss` falls | Recommends stronger augmentation, dropout, or weight decay |
| Data leak | `val/accuracy` suspiciously high (>99%) | Checks dataset split logic for overlap |
| Slow convergence | Loss barely moves for first 5 epochs | Checks if pretrained weights are frozen or LR is too small |

Ask Claude Code: "Look at run `resnet50-baseline` in W&B. does the loss curve indicate overfitting?" and it will fetch the metrics, plot them conceptually, and give you a diagnosis with specific recommendations.

## Conclusion

Combining Claude Code with Weights & Biases gives you powerful experiment tracking capabilities. Claude Code can execute training scripts, analyze results, and help you manage your ML workflow while W&B handles the heavy lifting of metrics logging and comparison. Start by creating dedicated skills for your experiment tracking needs, and progressively add more automation as your workflow matures. The integration enables reproducible research, easier debugging, and faster iteration cycles for your machine learning projects.


---

---

<div class="mastery-cta">

I'm a solo developer in Vietnam. 50K Chrome extension users. $500K+ on Upwork. 5 Claude Max subscriptions running agent fleets in parallel.

These are my actual CLAUDE.md templates, orchestration configs, and prompts. Not a course. Not theory. The files I copy into every project before I write a line of code.

**[See what's inside →](https://zovo.one/lifetime?utm_source=ccg&utm_medium=cta-default&utm_campaign=claude-code-weights-and-biases-experiment-tracking)**

$99 once. Free forever. 47/500 founding spots left.

</div>

Related Reading

- [Claude Code for ZenML MLOps Workflow Guide](/claude-code-for-zenml-mlops-workflow-guide/)
- [Claude Code for MLflow Experiment Tracking Workflow](/claude-code-for-mlflow-experiment-tracking-workflow/)
- [Claude Code for Weights & Biases Workflow Guide](/claude-code-for-weights-and-biases-workflow-guide/)

Built by theluckystrike. More at [zovo.one](https://zovo.one)


