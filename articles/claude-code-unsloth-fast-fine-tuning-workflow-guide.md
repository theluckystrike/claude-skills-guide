---

layout: default
title: "Claude Code + Unsloth Fast Fine-Tuning (2026)"
description: "Fine-tune LLMs 2x faster with Unsloth and Claude Code for QLoRA training, dataset preparation, and model merging. Reduce GPU costs significantly."
date: 2026-03-14
last_modified_at: 2026-04-17
last_tested: "2026-04-21"
categories: [guides]
tags: [claude-code, claude-skills]
author: "Claude Skills Guide"
permalink: /claude-code-unsloth-fast-fine-tuning-workflow-guide/
reviewed: true
score: 7
geo_optimized: true
---


Claude Code + Unsloth: Fast Fine-Tuning Workflow Guide

Fine-tuning large language models has become an essential skill for developers and data scientists looking to customize AI behavior for specific domains. Unsloth, an optimized fine-tuning library, makes this process dramatically faster and more memory-efficient. Combined with Claude Code's powerful CLI capabilities, you can build production-ready fine-tuning pipelines with unprecedented speed and reliability.

What Makes Unsloth Different?

Unsloth is a drop-in replacement for Hugging Face's Transformers training that offers 2x faster training and 60% less memory usage through several key innovations:

- Gradient checkpointing optimization - Reduces memory by recomputing activations during backpropagation
- Flash Attention v2 integration - Leverages the latest efficient attention mechanisms
- LoRA (Low-Rank Adaptation) - Trains only a small fraction of parameters instead of the full model
- Dynamic 4-bit quantization - Compresses model weights for inference

This guide shows you how to integrate Claude Code into your Unsloth fine-tuning workflow for better project management, automation, and reproducibility.

## Unsloth vs. Standard Transformers Training

To understand why this combination matters, consider what you give up with vanilla Hugging Face training on a 24GB GPU when fine-tuning a 7B parameter model:

| Metric | Standard Transformers | Unsloth |
|--------|----------------------|---------|
| Training speed | ~180 tokens/sec | ~380 tokens/sec |
| VRAM usage | ~22GB | ~9GB |
| Gradient checkpointing | Manual | Automatic |
| Flash Attention | Optional | Built-in |
| 4-bit support | bitsandbytes | Native |

The memory reduction is the more impactful number. Dropping from 22GB to 9GB means you can fit a 7B model fine-tune on a single consumer RTX 3090 or 4090, making serious fine-tuning accessible without renting cloud GPUs. More importantly, it means you can increase batch size or sequence length within the same VRAM budget, which often translates directly to better training stability and model quality.

## Setting Up Your Environment

Claude Code excels at environment setup and dependency management. Use it to scaffold your fine-tuning project with proper structure:

```bash
Initialize your project structure with Claude Code
mkdir -p my-finetune-project/{data,models,scripts,configs,outputs}
cd my-finetune-project
```

Create a CLAUDE.md file to establish consistent behavior for your fine-tuning project:

```
Fine-Tuning Project Guidelines

Environment Requirements
- Python 3.10+
- CUDA 12.1+
- Minimum 24GB VRAM for fine-tuning

Model Selection
- Default: meta-llama/Llama-3.1-8B-Instruct
- Alternative: mistralai/Mistral-7B-Instruct-v0.2

Training Configuration
- Use LoRA with rank 16, alpha 32
- Maximum sequence length: 2048 tokens
- Learning rate: 2e-4 with cosine schedule
```

The CLAUDE.md file serves a dual purpose: it documents your project's conventions for human collaborators, and it gives Claude Code the context it needs to make sensible suggestions. When Claude Code understands that you're using LoRA rank 16, it won't suggest changes to rank that conflict with your GPU budget. When it knows your target base model, it can pull in model-specific tokenizer quirks without you having to re-explain them in every session.

## Installing Unsloth

Unsloth installation depends on your CUDA version. Claude Code can detect this automatically:

```bash
Check your CUDA version first
nvcc --version
python -c "import torch; print(torch.version.cuda)"

Install for CUDA 12.1 (most common in 2026)
pip install "unsloth[cu121-torch240] @ git+https://github.com/unslothai/unsloth.git"

Or for CUDA 11.8 (older setups)
pip install "unsloth[cu118-torch220] @ git+https://github.com/unslothai/unsloth.git"

Install remaining dependencies
pip install datasets transformers accelerate peft trl
```

If you run into installation issues with Flash Attention (common on Windows or older CUDA), Unsloth falls back gracefully to standard attention. you lose some speed but training still works. Claude Code can help diagnose installation errors by reading logs and suggesting corrective steps.

## Data Preparation with Claude Code

Claude Code can help preprocess your training data into formats compatible with Unsloth's training pipeline. Create a data preparation script:

```python
from unsloth import standardize_sharegpt
import json

def prepare_training_data(input_file, output_file):
 """Convert raw conversations to Unsloth-compatible format."""
 with open(input_file, 'r') as f:
 raw_data = json.load(f)

 # Standardize to ShareGPT format
 standardized = standardize_sharegpt(raw_data)

 with open(output_file, 'w') as f:
 json.dump(standardized, f, indent=2)

 print(f"Processed {len(standardized)} conversations")
 return standardized
```

Claude Code can also help validate your dataset quality:

- Check for conversation completeness
- Verify response quality
- Identify potential data leakage
- Ensure proper tokenization

## Understanding Data Format Requirements

Unsloth works with several standard conversation formats. The most reliable is ShareGPT, which uses a list of turns with `from` and `value` keys:

```json
[
 {
 "conversations": [
 {"from": "human", "value": "What is the capital of France?"},
 {"from": "gpt", "value": "The capital of France is Paris."}
 ]
 },
 {
 "conversations": [
 {"from": "human", "value": "Explain gradient descent in simple terms."},
 {"from": "gpt", "value": "Gradient descent is like finding the bottom of a valley by always walking downhill..."}
 ]
 }
]
```

The Alpaca format (instruction/input/output) is also supported and sometimes easier to generate programmatically:

```json
[
 {
 "instruction": "Summarize the following text in two sentences.",
 "input": "The quick brown fox jumps over the lazy dog. This sentence contains every letter of the alphabet.",
 "output": "This sentence contains every letter in the English alphabet. It is commonly used as a typing practice or font display example."
 }
]
```

A practical validation script Claude Code can help you build:

```python
def validate_dataset(data, format="sharegpt"):
 """Validate training data quality before fine-tuning."""
 issues = []

 for i, item in enumerate(data):
 if format == "sharegpt":
 convs = item.get("conversations", [])
 if len(convs) < 2:
 issues.append(f"Item {i}: fewer than 2 turns")
 if convs and convs[-1]["from"] != "gpt":
 issues.append(f"Item {i}: last turn is not from assistant")
 for turn in convs:
 if len(turn["value"].strip()) < 10:
 issues.append(f"Item {i}: very short turn value")
 elif format == "alpaca":
 if not item.get("instruction"):
 issues.append(f"Item {i}: missing instruction")
 if len(item.get("output", "")) < 20:
 issues.append(f"Item {i}: very short output")

 print(f"Validated {len(data)} items. Issues found: {len(issues)}")
 for issue in issues[:10]: # Show first 10 issues
 print(f" - {issue}")

 return len(issues) == 0
```

Running this before training saves hours of wasted compute on corrupted or malformed datasets.

## Building the Training Pipeline

Here's a complete fine-tuning script using Unsloth's capabilities:

```python
from unsloth import FastLanguageModel
from unsloth.trainer import UnslothTrainer
from transformers import TrainingArguments
import torch

Model and tokenizer setup
model, tokenizer = FastLanguageModel.from_pretrained(
 model_name="meta-llama/Llama-3.1-8B-Instruct",
 max_seq_length=2048,
 dtype=torch.float16,
 load_in_4bit=True,
)

Configure LoRA
model = FastLanguageModel.get_peft_model(
 model,
 r=16,
 target_modules=["q_proj", "k_proj", "v_proj", "o_proj", "gate_proj"],
 lora_alpha=32,
 lora_dropout=0.05,
 bias="none",
 use_gradient_checkpointing="unsloth",
)

Training arguments
training_args = TrainingArguments(
 per_device_train_batch_size=2,
 gradient_accumulation_steps=4,
 warmup_steps=100,
 num_train_epochs=3,
 learning_rate=2e-4,
 fp16=not torch.cuda.is_bf16_supported(),
 bf16=torch.cuda.is_bf16_supported(),
 logging_steps=10,
 optim="adamw_8bit",
 weight_decay=0.01,
 lr_scheduler_type="cosine",
 output_dir="outputs",
 save_strategy="epoch",
)

Initialize trainer
trainer = UnslothTrainer(
 model=model,
 tokenizer=tokenizer,
 train_dataset=train_dataset,
 dataset_text_field="text",
 max_seq_length=2048,
 training_arguments=training_args,
)

Start training
trainer.train()
```

## Choosing LoRA Rank and Alpha

The `r` (rank) and `lora_alpha` parameters are the most consequential choices in your LoRA configuration. The rule of thumb is that `lora_alpha` should be 2x your rank, which is why `r=16, alpha=32` appears so often.

- r=8: Smallest footprint, fastest training. Use this for domain adaptation where the base model already understands the task format.
- r=16: Good balance. Use this for most instruction-following or specialized knowledge tasks.
- r=32: Better at learning complex new behaviors. Use this when the base model needs to change substantially.
- r=64: Approaching full fine-tune territory in terms of expressiveness. Rarely necessary with modern base models.

The `target_modules` list controls which layers get LoRA adapters. The attention projections (`q_proj`, `k_proj`, `v_proj`, `o_proj`) are almost always included. Adding `gate_proj` and `up_proj` (the MLP layers) increases parameters but often improves instruction following on complex tasks.

## Automating with Claude Code Skills

Create a Claude Code skill to automate repetitive fine-tuning tasks:

```yaml
.claude/skill.md
name: unsloth-finetune
description: Automate Unsloth fine-tuning workflows
```

Beyond a simple skill stub, Claude Code's real value in this workflow is as an orchestration layer. You can ask it to:

- Monitor training logs and flag anomalies like sudden loss spikes or NaN gradients
- Compare experiment configs across multiple runs stored in your configs directory
- Generate evaluation prompts tailored to your domain from a description
- Write deployment scripts that package model weights with the appropriate inference code

A practical use pattern: keep a `runs/` directory where each experiment gets a subdirectory with its config, logs, and evaluation results. Ask Claude Code to read across those directories and identify which hyperparameter changes correlated with lower evaluation loss. This kind of multi-file analysis is where Claude Code's context window pays off.

## Model Evaluation and Testing

After training, Claude Code can help you systematically evaluate your fine-tuned model:

```python
from unsloth import FastLanguageModel
import torch

def evaluate_model(model_path, test_cases):
 """Run evaluation on test cases."""
 model, tokenizer = FastLanguageModel.from_pretrained(
 model_name=model_path,
 max_seq_length=2048,
 dtype=torch.float16,
 load_in_4bit=True,
 )
 FastLanguageModel.for_inference(model)

 results = []
 for test in test_cases:
 inputs = tokenizer(test["prompt"], return_tensors="pt").to("cuda")

 with torch.no_grad():
 outputs = model.generate(
 inputs,
 max_new_tokens=512,
 temperature=0.7,
 top_p=0.9,
 )

 response = tokenizer.decode(outputs[0], skip_special_tokens=True)
 results.append({
 "prompt": test["prompt"],
 "expected": test["expected"],
 "actual": response,
 "match": test["expected"].lower() in response.lower()
 })

 accuracy = sum(r["match"] for r in results) / len(results)
 print(f"Accuracy: {accuracy:.1%} ({sum(r['match'] for r in results)}/{len(results)})")
 return results
```

## Writing Meaningful Evaluation Sets

The match-based evaluation above is a starting point, but for production use you want more nuanced evaluation. A few patterns that work well:

Format compliance checking: If your model should always output JSON, check that it does:
```python
import json

def check_json_output(response):
 try:
 json.loads(response)
 return True
 except json.JSONDecodeError:
 return False
```

Semantic similarity: For open-ended responses, exact string matching misses correct paraphrases. Use a small embedding model to check similarity:
```python
from sentence_transformers import SentenceTransformer, util

embed_model = SentenceTransformer("all-MiniLM-L6-v2")

def semantic_match(expected, actual, threshold=0.85):
 embs = embed_model.encode([expected, actual])
 score = util.cos_sim(embs[0], embs[1]).item()
 return score >= threshold, score
```

Regression checks: Before deploying a new checkpoint, run it against the previous checkpoint's outputs on a fixed prompt set. If quality drops on more than 10% of prompts, investigate before shipping.

## Deployment and Export

Claude Code can orchestrate the export process to various deployment formats:

```bash
Export to GGUF for local inference with llama.cpp or Ollama
python -m unsloth export --model outputs/final --format gguf --quantization q4_k_m

Export to Hugging Face Hub
python -m unsloth export --model outputs/final --hub my-org/my-model

Create an API server
python -m unsloth serve --model outputs/final --port 8000
```

## Picking the Right Export Format

The export format decision depends on where and how the model runs:

- GGUF (q4_K_M): Best for local deployment on laptops or desktops via Ollama or llama.cpp. The Q4_K_M quantization balances quality and size well for most tasks. Use Q5_K_M if you have headroom and need better quality on reasoning tasks.
- SafeTensors (fp16): Best for cloud inference via vLLM or TGI. Larger than GGUF but faster on GPU since there's no dequantization overhead.
- ONNX: Use if you need to serve on CPU at scale or integrate with non-Python inference stacks.
- Hugging Face Hub: Push here first regardless of final deployment target. it gives you versioned checkpoints you can pull from anywhere.

A full export script that handles all cases:

```python
import subprocess
import os

def export_model(checkpoint_dir, model_name, hf_token=None):
 """Export a trained model to multiple formats."""
 os.makedirs("exports", exist_ok=True)

 # GGUF for local inference
 subprocess.run([
 "python", "-m", "unsloth", "export",
 "--model", checkpoint_dir,
 "--format", "gguf",
 "--quantization", "q4_k_m",
 "--output", f"exports/{model_name}.gguf"
 ], check=True)

 # Push to Hub if token provided
 if hf_token:
 subprocess.run([
 "python", "-m", "unsloth", "export",
 "--model", checkpoint_dir,
 "--hub", f"your-org/{model_name}",
 "--token", hf_token
 ], check=True)

 print(f"Export complete. Files in exports/")
```

## Best Practices

When combining Claude Code with Unsloth:

1. Use CLAUDE.md - Define your project's conventions, preferred hyperparameters, and model choices
2. Version your data - Keep training datasets in version control or use DVC
3. Track experiments - Use MLflow or Weights & Biases to log training metrics
4. Test incrementally - Run evaluation after each epoch to catch issues early
5. Automate with skills - Create reusable Claude Code skills for common workflows

Two additional practices that pay dividends at scale:

Checkpoint management: Unsloth saves a checkpoint per epoch by default, which adds up quickly at 4-8GB per checkpoint. Set `save_total_limit=2` in TrainingArguments to keep only the last two, or better yet write a post-training hook that automatically evaluates and deletes underperforming checkpoints.

Experiment naming: Name your output directories with enough metadata to reconstruct the experiment without reading the config. `outputs/llama31-8b_r16_lr2e4_3ep_2026-03-14` tells you everything at a glance. Claude Code can generate these names automatically from your training config.

## Common Issues and Solutions

Claude Code can help diagnose and resolve common fine-tuning problems:

- Out of memory: Reduce batch size, enable gradient checkpointing, or use 4-bit quantization
- Training instability: Lower learning rate, check for data quality issues
- Poor model quality: Increase training data, adjust LoRA rank, try different base models
- Overfitting: Add regularization, increase dropout, reduce training epochs

## Diagnosing Loss Curves

A healthy training run has a loss that decreases smoothly and begins to plateau by the final epoch. Common pathological patterns:

- Spike at step 0 then recovery: Normal. the optimizer is cold-starting. If the spike doesn't recover within 50 steps, lower the learning rate.
- Oscillating loss: Usually means learning rate is too high or batch size is too small. Try halving the LR or doubling gradient accumulation steps.
- Loss plateaus immediately: The model has already learned what it can from the data. Either your dataset is too small, the LoRA rank is too low for the task complexity, or your data quality is poor.
- NaN loss: Almost always a data quality issue. check for empty strings, extremely long sequences, or encoding errors in your dataset.

Claude Code is particularly useful here because you can paste your loss log directly into the conversation and get a diagnosis without switching contexts.

## Conclusion

The combination of Claude Code's CLI automation and Unsloth's optimized fine-tuning creates a powerful workflow for customizing language models. Claude Code handles project management, automation, and reproducibility while Unsloth delivers the speed and memory efficiency needed for production fine-tuning.

Start with small models and datasets, iterate quickly, and scale up as you validate your approach. The workflow automation provided by Claude Code ensures consistency across experiments and makes collaboration with team members straightforward.

The most underrated aspect of this combination is debugging velocity. Fine-tuning involves a chain of failures. bad data formats, CUDA OOM errors, bad hyperparameters, poor evaluation metrics. that each waste hours without fast diagnosis. Claude Code shortens every one of those loops. Paste your error, get a fix. Describe your loss curve behavior, get a hypothesis. Ask it to write the next evaluation script, review it, and move on.

Remember to document your experiments, version your data, and always validate your fine-tuned model on held-out test sets before deployment. With this workflow, you're equipped to build production-quality fine-tuned models efficiently and reliably.


---

---

<div class="mastery-cta">

I'm a solo developer in Vietnam. 50K Chrome extension users. $500K+ on Upwork. 5 Claude Max subscriptions running agent fleets in parallel.

These are my actual CLAUDE.md templates, orchestration configs, and prompts. Not a course. Not theory. The files I copy into every project before I write a line of code.

**[See what's inside →](https://zovo.one/lifetime?utm_source=ccg&utm_medium=cta-default&utm_campaign=claude-code-unsloth-fast-fine-tuning-workflow-guide)**

$99 once. Free forever. 47/500 founding spots left.

</div>

Related Reading

- [Claude Code for Unsloth Fast Fine Tuning Workflow Tutorial](/claude-code-for-unsloth-fast-fine-tuning-workflow-tutorial/)
- [Claude Code for Axolotl Fine-Tuning Workflow Guide](/claude-code-for-axolotl-fine-tuning-workflow-guide/)
- [Claude Code for PyTorch LoRA Fine-Tuning Workflow](/claude-code-for-pytorch-lora-fine-tuning-workflow/)
- [Claude Code for Inngest — Workflow Guide](/claude-code-for-inngest-workflow-guide/)
- [Claude Code for Just — Workflow Guide](/claude-code-for-just-command-runner-workflow-guide/)
- [Claude Code for Zed Editor — Workflow Guide](/claude-code-for-zed-editor-workflow-guide/)
- [Claude Code for StarRocks — Workflow Guide](/claude-code-for-starrocks-workflow-guide/)
- [Claude Code for Typia Validator — Workflow Guide](/claude-code-for-typia-runtime-validator-workflow-guide/)
- [Claude Code for Difftastic — Workflow Guide](/claude-code-for-difftastic-workflow-guide/)
- [Claude Code for RisingWave Streaming — Guide](/claude-code-for-risingwave-streaming-workflow-guide/)
- [Claude Code for Python Reflex — Workflow Guide](/claude-code-for-python-reflex-workflow-guide/)

Built by theluckystrike. More at [zovo.one](https://zovo.one)


