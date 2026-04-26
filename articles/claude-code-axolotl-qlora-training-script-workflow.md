---

layout: default
title: "Claude Code Axolotl QLoRA Training (2026)"
description: "Learn how to use Claude Code skills to streamline Axolotl QLoRA fine-tuning workflows. Practical examples for configuring, running, and monitoring."
date: 2026-03-14
last_modified_at: 2026-04-17
categories: [guides]
tags: [claude-code, axolotl, qlora, fine-tuning, machine-learning, training, claude-skills]
author: "Claude Skills Guide"
reviewed: true
score: 7
permalink: /claude-code-axolotl-qlora-training-script-workflow/
geo_optimized: true
---


Claude Code Axolotl QLoRA Training Script Workflow

Fine-tuning large language models with QLoRA (Quantized Low-Rank Adaptation) has become a cornerstone technique for customizing AI models on consumer hardware. Axolotl provides a powerful, unified interface for running these training workflows, but managing configurations, scripts, and monitoring can quickly become complex. Claude Code skills offer a transformative approach to automating and streamlining your entire Axolotl QLoRA training pipeline.

This guide walks you through building an efficient Axolotl QLoRA training workflow powered by Claude Code skills, with practical examples you can adapt for your own projects.

## Understanding the Axolotl QLoRA Workflow

Before diving into Claude Code integration, let's establish what a typical Axolotl QLoRA training workflow looks like. The standard process involves:

1. Preparing your dataset in JSONL or Markdown format
2. Creating a YAML configuration file defining model, training parameters, and QLoRA settings
3. Running the training script with `accelerate` or directly via Python
4. Monitoring training progress through logs and metrics
5. Converting the final adapter weights for inference

Each of these steps presents opportunities for Claude Code skills to reduce friction and automate repetitive tasks.

## QLoRA vs Full Fine-Tuning: When to Choose Which

Before configuring anything, it helps to understand when QLoRA is the right tool compared to full fine-tuning or other PEFT methods.

| Method | VRAM Requirement | Training Speed | Quality | Use Case |
|---|---|---|---|---|
| Full Fine-Tuning | 80GB+ (70B model) | Slowest | Highest | Production, large budget |
| QLoRA (4-bit) | 10-24GB | Moderate | High | Consumer GPUs, most use cases |
| LoRA (16-bit) | 40-80GB | Fast | High | Multi-GPU setups |
| GPTQ+LoRA | 8-16GB | Moderate | Good | Inference-optimized deployments |
| Prefix Tuning | 8-12GB | Fast | Moderate | Simple instruction following |

QLoRA hits the sweet spot for most practitioners: you can fine-tune a 7B or 13B model on a single RTX 3090 or 4090, with quality that rivals full fine-tuning on most downstream tasks.

## Setting Up Your Claude Code Environment

The first step is ensuring Claude Code is installed and configured with relevant skills. You can verify your installation:

```bash
claude --version
```

To see which skills are available, check your `.claude/skills/` directory where skill Markdown files are stored.

For Axolotl workflows, you'll want skills that provide expertise in YAML configuration, shell scripting, and Python training scripts. If you don't have an Axolotl-specific skill, you can create one or use the general-purpose coding skills that already ship with Claude Code.

## Creating an Axolotl-Specific Claude Code Skill

A dedicated skill file gives Claude Code persistent context about your training environment, conventions, and hardware. Create `.claude/skills/axolotl-trainer.md`:

```markdown
---
name: axolotl-trainer
description: Assists with Axolotl QLoRA fine-tuning configuration, debugging, and monitoring
---

Context

This project uses Axolotl for QLoRA fine-tuning on a single RTX 4090 (24GB VRAM).
Base models are stored in /mnt/models/. Training data lives in /mnt/datasets/.
Outputs go to /mnt/outputs/ with timestamped subdirectories.

Key Conventions

- All configs use 4-bit quantization (load_in_4bit: true)
- Batch size stays at 2 with gradient_accumulation_steps = 16 (effective batch 32)
- Checkpoints saved every 500 steps, keeping last 3
- Wandb project: "llm-finetunes"

Common Issues

- OOM on 24GB: reduce sequence length before reducing batch size
- Gradient explosion: lower learning rate to 1e-5 or add gradient clipping
- Slow dataloader: set num_workers: 4 and pin_memory: true
```

With this skill loaded, Claude Code understands your hardware constraints and project conventions without you restating them every session.

## Creating Your QLoRA Configuration

The heart of any Axolotl training run is its YAML configuration file. Claude Code can help you generate and validate these configurations, ensuring all required fields are present and values are appropriate for your hardware.

Here's a complete, production-ready QLoRA configuration for fine-tuning Llama 3.1 8B on a single 24GB GPU:

```yaml
configs/llama31-8b-qlora.yaml

base_model: meta-llama/Llama-3.1-8B-Instruct
model_type: LlamaForCausalLM
tokenizer_type: AutoTokenizer

4-bit quantization settings
load_in_4bit: true
strict: false

Dataset configuration
datasets:
 - path: /mnt/datasets/my_training_data.jsonl
 type: chat_template
 chat_template: chatml

dataset_prepared_path: /mnt/datasets/.cache/llama31-8b
val_set_size: 0.02
output_dir: /mnt/outputs/llama31-8b-qlora

Sequence settings
sequence_len: 4096
sample_packing: true
pad_to_sequence_len: true

QLoRA adapter settings
adapter: qlora
lora_model_dir:
lora_r: 32
lora_alpha: 16
lora_dropout: 0.05
lora_target_linear: true
lora_fan_in_fan_out:

Training hyperparameters
gradient_accumulation_steps: 4
micro_batch_size: 2
num_epochs: 3
optimizer: paged_adamw_32bit
lr_scheduler: cosine
learning_rate: 2e-4
train_on_inputs: false
group_by_length: false
bf16: auto
fp16:
tf32: false

gradient_checkpointing: true
early_stopping_patience:
resume_from_checkpoint:
local_rank:
logging_steps: 10
xformers_attention:
flash_attention: true

warmup_steps: 100
evals_per_epoch: 4
eval_table_size:
saves_per_epoch: 1
debug:
deepspeed:
weight_decay: 0.0
fsdp:
fsdp_config:
special_tokens:
 bos_token: "<|begin_of_text|>"
 eos_token: "<|eot_id|>"
```

When you describe your training goals to Claude Code, specifying the base model, dataset location, and desired QLoRA parameters, it can generate a complete configuration file tailored to your setup. This includes critical parameters like `lora_r`, `lora_alpha`, `lora_dropout`, and target modules that determine how aggressively the model adapts.

## Understanding Key QLoRA Parameters

Claude Code can explain what each parameter controls and help you choose appropriate values:

| Parameter | Typical Range | Effect |
|---|---|---|
| `lora_r` | 8–128 | Rank of adaptation matrices. Higher = more parameters, more expressive but slower |
| `lora_alpha` | 8–64 | Scaling factor. Common practice: set equal to lora_r |
| `lora_dropout` | 0.0–0.1 | Regularization. Use 0.05 for most tasks |
| `learning_rate` | 1e-5–3e-4 | Start with 2e-4, reduce if loss spikes |
| `sequence_len` | 512–8192 | Longer = more VRAM. Match to your data's natural length |
| `micro_batch_size` | 1–4 | Reduce first when hitting OOM |
| `gradient_accumulation_steps` | 4–32 | Multiply by micro_batch_size for effective batch size |

Claude Code validates your configuration against common pitfalls: incompatible model architectures, mismatched sequence lengths, memory-insufficient batch sizes, and incorrect learning rate schedules. This validation happens before you waste hours on a failed training run.

## Managing Training Scripts and Arguments

Beyond the YAML configuration, Axolotl training often requires custom scripts or wrapper commands. Claude Code excels at generating these scripts with proper error handling, logging, and checkpoint management.

Here's an example of a training launch script that Claude Code might help you create:

```bash
#!/bin/bash
scripts/train.sh - QLoRA Training Launch Script

set -euo pipefail

MODEL_NAME="meta-llama/Llama-3.1-8B-Instruct"
CONFIG_PATH="./configs/llama31-8b-qlora.yaml"
OUTPUT_DIR="./outputs/${MODEL_NAME##*/}-$(date +%Y%m%d-%H%M%S)"
LOG_FILE="${OUTPUT_DIR}/training.log"

mkdir -p "$OUTPUT_DIR"

echo "Starting QLoRA training run"
echo "Config: $CONFIG_PATH"
echo "Output: $OUTPUT_DIR"
echo "Started: $(date)" | tee "$LOG_FILE"

Validate config before launching
python -c "
import yaml
with open('$CONFIG_PATH') as f:
 cfg = yaml.safe_load(f)
print('Config loaded successfully')
print(f'Model: {cfg[\"base_model\"]}')
print(f'LoRA r={cfg[\"lora_r\"]}, alpha={cfg[\"lora_alpha\"]}')
"

Launch training
accelerate launch \
 --config_file ./accelerate_configs/single_gpu.yaml \
 -m axolotl.cli.train \
 "$CONFIG_PATH" \
 --output_dir "$OUTPUT_DIR" \
 2>&1 | tee -a "$LOG_FILE"

EXIT_CODE=${PIPESTATUS[0]}

if [ $EXIT_CODE -eq 0 ]; then
 echo "Training completed successfully at $(date)" | tee -a "$LOG_FILE"
 # Merge adapters automatically on success
 python scripts/merge_adapter.py --adapter "$OUTPUT_DIR" --output "${OUTPUT_DIR}-merged"
else
 echo "Training FAILED with exit code $EXIT_CODE at $(date)" | tee -a "$LOG_FILE"
 exit $EXIT_CODE
fi
```

Claude Code can generate this script, explain each parameter's purpose, and even adapt it for different hardware configurations, from single RTX 3090 setups to multi-GPU clusters.

## Multi-GPU Training with Accelerate

Scaling to multiple GPUs requires an accelerate config. Claude Code can generate this file for your specific hardware:

```yaml
accelerate_configs/multi_gpu.yaml
compute_environment: LOCAL_MACHINE
distributed_type: MULTI_GPU
downcast_bf16: 'no'
gpu_ids: all
machine_rank: 0
main_training_function: main
mixed_precision: bf16
num_machines: 1
num_processes: 4 # Adjust to your GPU count
rdzv_backend: static
same_network: true
tpu_env: []
tpu_use_cluster: false
tpu_use_sudo: false
use_cpu: false
```

## Dataset Preparation and Formatting

One of the most time-consuming aspects of fine-tuning is preparing your training data. Claude Code skills can assist with converting datasets between formats, validating JSONL structure, and splitting data into train/validation sets.

If you're working with conversational data, Claude Code understands the chat template formats that Axolotl supports, including ChatML, Alpaca, and Vicuna formats. You simply describe your data source, and Claude Code can transform it into the exact format your configuration expects.

## Converting CSV to ChatML JSONL

For instance, if you have a CSV file of instruction-response pairs, Claude Code can generate a Python script to convert it to the required JSONL format:

```python
#!/usr/bin/env python3
scripts/prepare_dataset.py

import json
import csv
import random
import sys
from pathlib import Path

def convert_csv_to_jsonl(input_csv, output_dir, val_ratio=0.02):
 """Convert instruction/response CSV to ChatML JSONL format."""
 output_dir = Path(output_dir)
 output_dir.mkdir(parents=True, exist_ok=True)

 records = []
 with open(input_csv, 'r', encoding='utf-8') as infile:
 reader = csv.DictReader(infile)
 for row in reader:
 instruction = row.get('instruction', '').strip()
 response = row.get('response', '').strip()
 system = row.get('system', '').strip()

 if not instruction or not response:
 continue

 messages = []
 if system:
 messages.append({"role": "system", "content": system})
 messages.append({"role": "user", "content": instruction})
 messages.append({"role": "assistant", "content": response})

 records.append({"messages": messages})

 # Shuffle and split
 random.shuffle(records)
 split_idx = max(1, int(len(records) * val_ratio))
 val_records = records[:split_idx]
 train_records = records[split_idx:]

 def write_jsonl(path, data):
 with open(path, 'w', encoding='utf-8') as f:
 for record in data:
 f.write(json.dumps(record, ensure_ascii=False) + '\n')

 write_jsonl(output_dir / 'train.jsonl', train_records)
 write_jsonl(output_dir / 'val.jsonl', val_records)

 print(f"Wrote {len(train_records)} training records")
 print(f"Wrote {len(val_records)} validation records")
 return len(train_records), len(val_records)

if __name__ == '__main__':
 convert_csv_to_jsonl(sys.argv[1], sys.argv[2])
```

## Validating Dataset Quality Before Training

Poor data quality is the most common cause of disappointing fine-tune results. Claude Code can help you build a validation script that catches problems before they waste GPU time:

```python
#!/usr/bin/env python3
scripts/validate_dataset.py

import json
import sys
from collections import Counter

def validate_jsonl(path, min_response_len=20, max_sequence_len=4096):
 """Check a JSONL dataset for common quality issues."""
 issues = []
 stats = {"total": 0, "empty_responses": 0, "too_short": 0, "too_long": 0}
 role_counts = Counter()

 with open(path) as f:
 for line_num, line in enumerate(f, 1):
 line = line.strip()
 if not line:
 continue
 try:
 record = json.loads(line)
 except json.JSONDecodeError as e:
 issues.append(f"Line {line_num}: Invalid JSON - {e}")
 continue

 stats["total"] += 1
 messages = record.get("messages", [])

 if not messages:
 issues.append(f"Line {line_num}: No messages field")
 continue

 for msg in messages:
 role_counts[msg.get("role", "unknown")] += 1

 # Check assistant responses
 assistant_msgs = [m for m in messages if m.get("role") == "assistant"]
 if not assistant_msgs:
 issues.append(f"Line {line_num}: No assistant response")
 stats["empty_responses"] += 1
 continue

 total_chars = sum(len(m.get("content", "")) for m in messages)
 # Rough token estimate: 4 chars per token
 estimated_tokens = total_chars // 4

 if len(assistant_msgs[0].get("content", "")) < min_response_len:
 stats["too_short"] += 1

 if estimated_tokens > max_sequence_len:
 stats["too_long"] += 1

 print(f"Dataset validation results for: {path}")
 print(f" Total records: {stats['total']}")
 print(f" Empty responses: {stats['empty_responses']}")
 print(f" Too short responses: {stats['too_short']}")
 print(f" Exceeds sequence length: {stats['too_long']}")
 print(f" Role distribution: {dict(role_counts)}")

 if issues:
 print(f"\nFound {len(issues)} issues:")
 for issue in issues[:20]:
 print(f" {issue}")

 return len(issues) == 0

if __name__ == '__main__':
 valid = validate_jsonl(sys.argv[1])
 sys.exit(0 if valid else 1)
```

## Monitoring and Debugging Training Runs

Training runs can fail for myriad reasons, OOM errors, gradient explosion, data loading issues. Claude Code helps you interpret error messages, identify root causes, and adjust parameters accordingly.

When training stalls or produces unexpected results, you can paste error logs or metric outputs into Claude Code, which analyzes the patterns and suggests specific configuration changes. For QLoRA training specifically, common adjustments include reducing `per_device_train_batch_size`, increasing `gradient_accumulation_steps`, or tweaking `lora_r` values.

## Common Error Patterns and Fixes

Claude Code recognizes these frequent failure patterns and knows their remedies:

| Error Message | Root Cause | Fix |
|---|---|---|
| `CUDA out of memory` | VRAM exhausted | Reduce micro_batch_size or sequence_len |
| `RuntimeError: expected scalar type Half` | BF16/FP16 mismatch | Set `bf16: auto` and `fp16: false` |
| `Loss is NaN` | Gradient explosion | Add `max_grad_norm: 1.0`, lower learning rate |
| `DataLoader worker crash` | RAM exhaustion | Reduce `num_workers`, disable `pin_memory` |
| `tokenizer has no padding token` | Missing pad token | Add `pad_token: eos_token` in special_tokens |
| `Checkpoint resume mismatch` | Config changed mid-run | Clear cache dir, restart from scratch |

## Setting Up Weights & Biases Monitoring

Claude Code helps configure experiment tracking that persists across runs:

```yaml
Add to your Axolotl config
wandb_project: llm-finetunes
wandb_entity: your-username
wandb_watch: gradients
wandb_log_model: checkpoint
```

Then create a monitoring script that checks on your run from the command line:

```bash
#!/bin/bash
scripts/check_training.sh

RUN_DIR="${1:?Usage: check_training.sh <output_dir>}"

echo "=== Training Status ==="
echo "Directory: $RUN_DIR"

Show last 20 lines of log
if [ -f "$RUN_DIR/training.log" ]; then
 echo ""
 echo "--- Recent Log Output ---"
 tail -20 "$RUN_DIR/training.log"
fi

Show checkpoint status
echo ""
echo "--- Checkpoints ---"
ls -lh "$RUN_DIR/checkpoint-"* 2>/dev/null | tail -5 || echo "No checkpoints yet"

Show GPU memory usage
echo ""
echo "--- GPU Status ---"
nvidia-smi --query-gpu=name,memory.used,memory.total,utilization.gpu \
 --format=csv,noheader,nounits 2>/dev/null || echo "nvidia-smi not available"
```

Claude Code also helps you set up proper monitoring by creating skills that understand Axolotl's log output, parse metrics from TensorBoard or Weights & Biases, and alert you when training deviates from expected behavior.

## Post-Training: Model Conversion and Testing

Once training completes, you need to merge the QLoRA adapters with the base model for deployment. Claude Code guides you through this process, generating the appropriate merge commands and helping you test the resulting model.

## Merging QLoRA Adapters

```python
#!/usr/bin/env python3
scripts/merge_adapter.py

import argparse
from pathlib import Path
import torch
from transformers import AutoModelForCausalLM, AutoTokenizer
from peft import PeftModel

def merge_qlora_adapter(adapter_path, output_path, base_model=None):
 """Merge QLoRA adapter weights into the base model."""
 adapter_path = Path(adapter_path)

 # Load adapter config to find base model if not specified
 if base_model is None:
 import json
 with open(adapter_path / "adapter_config.json") as f:
 adapter_config = json.load(f)
 base_model = adapter_config["base_model_name_or_path"]

 print(f"Loading base model: {base_model}")
 model = AutoModelForCausalLM.from_pretrained(
 base_model,
 torch_dtype=torch.float16,
 device_map="auto",
 trust_remote_code=True
 )

 print(f"Loading adapter from: {adapter_path}")
 model = PeftModel.from_pretrained(model, str(adapter_path))

 print("Merging adapter weights...")
 model = model.merge_and_unload()

 print(f"Saving merged model to: {output_path}")
 model.save_pretrained(output_path, safe_serialization=True)

 tokenizer = AutoTokenizer.from_pretrained(base_model)
 tokenizer.save_pretrained(output_path)

 print("Merge complete!")

if __name__ == "__main__":
 parser = argparse.ArgumentParser()
 parser.add_argument("--adapter", required=True)
 parser.add_argument("--output", required=True)
 parser.add_argument("--base-model", default=None)
 args = parser.parse_args()
 merge_qlora_adapter(args.adapter, args.output, args.base_model)
```

## Automated Inference Testing

Testing involves running inference with sample prompts and comparing outputs against baseline expectations. Claude Code can automate this validation, running a suite of test cases and reporting whether the fine-tuned model exhibits the desired behaviors.

```python
#!/usr/bin/env python3
scripts/test_model.py

import json
import torch
from transformers import AutoModelForCausalLM, AutoTokenizer, pipeline

def run_inference_tests(model_path, test_file, max_new_tokens=512):
 """Run inference tests and report results."""
 tokenizer = AutoTokenizer.from_pretrained(model_path)
 model = AutoModelForCausalLM.from_pretrained(
 model_path,
 torch_dtype=torch.float16,
 device_map="auto"
 )
 pipe = pipeline("text-generation", model=model, tokenizer=tokenizer)

 with open(test_file) as f:
 test_cases = json.load(f)

 results = []
 for i, case in enumerate(test_cases):
 messages = [{"role": "user", "content": case["input"]}]
 output = pipe(
 messages,
 max_new_tokens=max_new_tokens,
 do_sample=False,
 temperature=None,
 top_p=None,
 )
 generated = output[0]["generated_text"][-1]["content"]

 # Simple keyword check
 passed = all(kw.lower() in generated.lower()
 for kw in case.get("expected_keywords", []))

 results.append({
 "test_id": i + 1,
 "input": case["input"],
 "output": generated[:200] + "..." if len(generated) > 200 else generated,
 "passed": passed
 })
 print(f"Test {i+1}: {'PASS' if passed else 'FAIL'}")

 passed_count = sum(1 for r in results if r["passed"])
 print(f"\nResults: {passed_count}/{len(results)} tests passed")
 return results
```

## Conclusion

Claude Code transforms Axolotl QLoRA training from a manual, error-prone process into a streamlined workflow where configuration generation, script creation, debugging, and monitoring all receive intelligent assistance. By using Claude Code skills throughout your training pipeline, you spend less time wrestling with configuration files and more time iterating on your model.

The key is treating Claude Code not just as a chat interface, but as an integrated development partner that understands the specifics of Axolotl configurations, QLoRA parameters, and LLM training best practices. With the right skills loaded, Claude Code becomes invaluable for both newcomers learning fine-tuning and experienced practitioners optimizing their workflows.

Start with a single working configuration, build your dataset validation and launch scripts, and progressively add monitoring and post-training automation as your pipeline matures. Each component you automate with Claude Code's help is one less distraction from the core work: building models that actually solve real problems.


---

---

<div class="mastery-cta">

I'm a solo developer in Vietnam. 50K Chrome extension users. $500K+ on Upwork. 5 Claude Max subscriptions running agent fleets in parallel.

These are my actual CLAUDE.md templates, orchestration configs, and prompts. Not a course. Not theory. The files I copy into every project before I write a line of code.

**[See what's inside →](https://zovo.one/lifetime?utm_source=ccg&utm_medium=cta-default&utm_campaign=claude-code-axolotl-qlora-training-script-workflow)**

$99 once. Free forever. 47/500 founding spots left.

</div>

Related Reading

- [Claude Code Diffusers Stable Diffusion Training Guide](/claude-code-diffusers-stable-diffusion-training-guide/)
- [Claude Code for Unsloth Fast Fine Tuning Workflow Tutorial](/claude-code-for-unsloth-fast-fine-tuning-workflow-tutorial/)
- [Claude Code for ZenML MLOps Workflow Guide](/claude-code-for-zenml-mlops-workflow-guide/)

Built by theluckystrike. More at [zovo.one](https://zovo.one)



**Find the right skill →** Browse 155+ skills in our [Skill Finder](/skill-finder/).

## See Also

**Try it:** Paste your error into our [Error Diagnostic](/diagnose/) for an instant fix.

- [Claude Code Hook Script Not Executable — Fix (2026)](/claude-code-hook-script-not-executable-fix-2026/)
