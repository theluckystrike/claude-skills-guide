---

layout: default
title: "How to Use vLLM Inference Server (2026)"
description: "Learn how to integrate Claude Code into your vLLM inference server workflow for efficient LLM deployment and management."
date: 2026-03-15
last_modified_at: 2026-04-17
author: Claude Skills Guide
permalink: /claude-code-for-vllm-inference-server-workflow/
categories: [guides]
tags: [claude-code, claude-skills]
reviewed: true
score: 7
geo_optimized: true
---


Claude Code for vLLM Inference Server Workflow

Building production-ready LLM inference servers requires careful orchestration of multiple components. vLLM has emerged as a high-performance inference engine that dramatically reduces latency and increases throughput for large language models. When combined with Claude Code's development capabilities, you get a powerful workflow for deploying and managing inference services.

This guide walks you through integrating Claude Code into your vLLM inference server workflow, with practical examples and actionable advice for developers.

## Understanding vLLM and Claude Code

vLLM is an open-source inference server that uses PagedAttention technology to achieve state-of-the-art serving throughput. It supports popular models like Llama, Mistral, and Qwen, making it a versatile choice for production deployments.

This guide focuses on the coding workflow: using Claude Code as a development partner to write, extend, and debug the Python code that powers a vLLM inference server. If you are looking for deployment automation with Claude Code skills (Dockerfiles, Kubernetes manifests, CI/CD pipelines), see the companion guide [Claude Code vLLM Inference Server Deployment Workflow](/claude-code-vllm-inference-server-deployment-workflow/).

Claude Code accelerates the coding side of vLLM development by helping you:
- Generate server setup and configuration code
- Write typed API request/response models
- Instrument code with observability metrics
- Debug inference logic and error handling

vLLM vs Other Inference Frameworks

Before committing to vLLM, it helps to understand where it fits relative to other popular options:

| Framework | Throughput | Latency | Quantization | OpenAI Compat | Best For |
|---|---|---|---|---|---|
| vLLM | Very High | Low | GPTQ, AWQ, FP8 | Yes | Production, high concurrency |
| TGI (HuggingFace) | High | Low | GPTQ, bitsandbytes | Yes | HuggingFace ecosystem |
| llama.cpp | Medium | Very Low | GGUF (CPU/GPU) | Yes | CPU inference, edge |
| Triton + TensorRT | Highest | Lowest | FP8, INT8 | Manual | Custom NVIDIA stacks |
| Ollama | Low | Medium | GGUF | Partial | Local dev, prototyping |

vLLM's PagedAttention algorithm virtually eliminates KV-cache memory waste, which is why it handles high-concurrency workloads better than most alternatives. Claude Code can help you benchmark your specific model across frameworks, but for most production Python services, vLLM is the right default.

## Setting Up Your vLLM Environment

Before integrating Claude Code, ensure your vLLM environment is properly configured. Here's a basic setup script that Claude Code can help you generate:

```python
vllm_setup.py
from vllm import LLM, SamplingParams

def initialize_model(model_name: str, tensor_parallel_size: int = 1):
 """Initialize vLLM inference engine."""
 llm = LLM(
 model=model_name,
 tensor_parallel_size=tensor_parallel_size,
 trust_remote_code=True,
 max_num_seqs=256,
 gpu_memory_utilization=0.9
 )
 return llm

def create_sampling_params(
 temperature: float = 0.7,
 max_tokens: int = 512,
 top_p: float = 0.95
) -> SamplingParams:
 """Configure sampling parameters for generation."""
 return SamplingParams(
 temperature=temperature,
 max_tokens=max_tokens,
 top_p=top_p,
 stop=None
 )
```

This foundational setup gives you a starting point that Claude Code can then extend based on your specific requirements.

## GPU Memory Planning

One of the most common sources of OOM errors in vLLM is under-estimating KV cache requirements. Claude Code can generate a memory estimation script for your model:

```python
memory_estimator.py
import math

def estimate_kv_cache_gb(
 num_layers: int,
 num_kv_heads: int,
 head_dim: int,
 max_seq_len: int,
 max_batch_size: int,
 dtype_bytes: int = 2 # fp16 = 2 bytes
) -> float:
 """Estimate KV cache memory in GB."""
 # Each token needs K and V tensors per layer per head
 bytes_per_token = 2 * num_layers * num_kv_heads * head_dim * dtype_bytes
 total_bytes = bytes_per_token * max_seq_len * max_batch_size
 return total_bytes / (1024 3)

Llama-3-8B on A100-80GB
kv_cache_gb = estimate_kv_cache_gb(
 num_layers=32,
 num_kv_heads=8,
 head_dim=128,
 max_seq_len=8192,
 max_batch_size=32
)

model_weights_gb = 16.0 # fp16 weights
print(f"Model weights: {model_weights_gb:.1f} GB")
print(f"KV cache: {kv_cache_gb:.1f} GB")
print(f"Total required: {model_weights_gb + kv_cache_gb:.1f} GB")
```

Prompt Claude Code with your model card parameters and target batch size, and it will produce this estimate plus recommend the right `gpu_memory_utilization` setting for `LLM()`.

## Building the Inference Server API

A production inference server needs a solid API layer. Here's how Claude Code can help you build one using FastAPI:

```python
inference_server.py
from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
from typing import List, Optional
from vllm import LLM, SamplingParams
import logging

app = FastAPI(title="vLLM Inference Server")
logger = logging.getLogger(__name__)

class InferenceRequest(BaseModel):
 prompt: str
 temperature: Optional[float] = 0.7
 max_tokens: Optional[int] = 512
 top_p: Optional[float] = 0.95

class InferenceResponse(BaseModel):
 generated_text: str
 finish_reason: str
 prompt_tokens: int
 completion_tokens: int

Global model instance
llm = None

@app.on_event("startup")
async def load_model():
 global llm
 llm = LLM(
 model="meta-llama/Llama-2-7b-hf",
 tensor_parallel_size=1,
 trust_remote_code=True
 )
 logger.info("Model loaded successfully")

@app.post("/v1/completions", response_model=InferenceResponse)
async def generate(request: InferenceRequest):
 try:
 sampling_params = SamplingParams(
 temperature=request.temperature,
 max_tokens=request.max_tokens,
 top_p=request.top_p
 )

 outputs = llm.generate([request.prompt], sampling_params)
 output = outputs[0]

 return InferenceResponse(
 generated_text=output.outputs[0].text,
 finish_reason=output.outputs[0].finish_reason,
 prompt_tokens=output.prompt_token_ids,
 completion_tokens=len(output.outputs[0].token_ids)
 )
 except Exception as e:
 logger.error(f"Inference error: {str(e)}")
 raise HTTPException(status_code=500, detail=str(e))
```

## Adding Streaming Support

For chat interfaces and long-generation use cases, streaming responses dramatically improves perceived latency. Claude Code can add streaming to your existing endpoint:

```python
from fastapi.responses import StreamingResponse
from vllm import AsyncLLMEngine, AsyncEngineArgs
import asyncio
import json

Use the async engine for streaming
engine_args = AsyncEngineArgs(
 model="meta-llama/Meta-Llama-3-8B-Instruct",
 tensor_parallel_size=1,
 gpu_memory_utilization=0.9,
)
engine = AsyncLLMEngine.from_engine_args(engine_args)

@app.post("/v1/completions/stream")
async def generate_stream(request: InferenceRequest):
 sampling_params = SamplingParams(
 temperature=request.temperature,
 max_tokens=request.max_tokens,
 top_p=request.top_p,
 )

 request_id = f"req-{id(request)}"

 async def event_generator():
 prev_text = ""
 async for output in engine.generate(
 request.prompt, sampling_params, request_id
 ):
 new_text = output.outputs[0].text
 delta = new_text[len(prev_text):]
 prev_text = new_text

 chunk = {
 "choices": [{
 "delta": {"content": delta},
 "finish_reason": output.outputs[0].finish_reason,
 }]
 }
 yield f"data: {json.dumps(chunk)}\n\n"

 if output.finished:
 yield "data: [DONE]\n\n"
 break

 return StreamingResponse(
 event_generator(),
 media_type="text/event-stream",
 headers={"X-Accel-Buffering": "no"},
 )
```

This produces Server-Sent Events that any JavaScript `EventSource` or `fetch` with `ReadableStream` can consume. Claude Code will wire this pattern up from a simple description like "add streaming to my completions endpoint."

## OpenAI-Compatible Chat Endpoint

Many downstream libraries (LangChain, LlamaIndex, OpenAI SDK) expect the `/v1/chat/completions` format. Ask Claude Code to generate an adapter that maps your vLLM engine to the OpenAI schema:

```python
from pydantic import BaseModel, Field
from typing import Literal

class ChatMessage(BaseModel):
 role: Literal["system", "user", "assistant"]
 content: str

class ChatCompletionRequest(BaseModel):
 model: str
 messages: list[ChatMessage]
 temperature: float = 0.7
 max_tokens: int = 512
 stream: bool = False

class ChatChoice(BaseModel):
 index: int
 message: ChatMessage
 finish_reason: str

class ChatCompletionResponse(BaseModel):
 id: str = Field(default_factory=lambda: f"chatcmpl-{id(object())}")
 object: str = "chat.completion"
 model: str
 choices: list[ChatChoice]
 usage: dict

@app.post("/v1/chat/completions")
async def chat_completions(request: ChatCompletionRequest):
 # Apply the model's chat template to convert messages to a prompt string
 tokenizer = engine.get_tokenizer()
 prompt = tokenizer.apply_chat_template(
 [m.dict() for m in request.messages],
 tokenize=False,
 add_generation_prompt=True,
 )

 sampling_params = SamplingParams(
 temperature=request.temperature,
 max_tokens=request.max_tokens,
 )

 request_id = f"chatcmpl-{id(request)}"
 final_output = None
 async for output in engine.generate(prompt, sampling_params, request_id):
 final_output = output

 completion_text = final_output.outputs[0].text
 return ChatCompletionResponse(
 model=request.model,
 choices=[ChatChoice(
 index=0,
 message=ChatMessage(role="assistant", content=completion_text),
 finish_reason=final_output.outputs[0].finish_reason,
 )],
 usage={
 "prompt_tokens": len(final_output.prompt_token_ids),
 "completion_tokens": len(final_output.outputs[0].token_ids),
 "total_tokens": len(final_output.prompt_token_ids) + len(final_output.outputs[0].token_ids),
 }
 )
```

## Creating a Claude Code Workflow Script

Now let's create a Claude Code skill that automates common vLLM workflow tasks:

```yaml
claude-code-vllm-skill.md
---
name: vLLM Inference Workflow
description: Automate vLLM inference server tasks with Claude Code
---

vLLM Inference Workflow

Help with vLLM inference server tasks including:
- Generating deployment scripts and docker-compose configurations
- Running performance benchmarks with locust or wrk
- Analyzing and debugging inference issues from error logs
```

## Practical Claude Code Prompts for vLLM Development

Here are the most effective prompts for using Claude Code in daily vLLM work:

Initial setup: "Create a vLLM server project with FastAPI, Prometheus metrics, health checks, and structured JSON logging. Use Llama-3-8B-Instruct as the default model and support CUDA and CPU backends via an environment flag."

Debugging OOM: "My vLLM server crashes with CUDA OOM during load. My GPU is an A100-40GB, the model is Mixtral-8x7B-Instruct, and I'm using tensor_parallel_size=1. Diagnose what's wrong and suggest configuration fixes."

Performance profiling: "Write a locust benchmark script that sends concurrent chat completion requests to my server at /v1/chat/completions, ramps from 1 to 50 concurrent users, and reports p50/p95/p99 latency and tokens-per-second."

Schema migration: "My InferenceRequest model has grown organically and is missing validation. Add Pydantic v2 validators that enforce: temperature must be 0.0–2.0, max_tokens must be 1–4096, and prompt must be non-empty after stripping whitespace."

## Integrating Monitoring and Observability

Production inference servers require comprehensive monitoring. Here's how to add Prometheus metrics:

```python
metrics.py
from prometheus_client import Counter, Histogram, Gauge
import time

Request metrics
inference_requests = Counter(
 'vllm_inference_requests_total',
 'Total number of inference requests',
 ['model', 'status']
)

inference_duration = Histogram(
 'vllm_inference_duration_seconds',
 'Inference request duration',
 ['model']
)

Model metrics
model_loaded = Gauge(
 'vllm_model_loaded',
 'Whether the model is currently loaded',
 ['model']
)

active_requests = Gauge(
 'vllm_active_requests',
 'Number of currently processing requests',
 ['model']
)
```

Wrap these metrics into your inference endpoint to track performance:

```python
@app.post("/v1/completions")
async def generate_with_metrics(request: InferenceRequest):
 start_time = time.time()
 active_requests.labels(model=request.model).inc()

 try:
 # ... inference logic ...
 inference_requests.labels(model=request.model, status="success").inc()
 return response
 except Exception as e:
 inference_requests.labels(model=request.model, status="error").inc()
 raise
 finally:
 duration = time.time() - start_time
 inference_duration.labels(model=request.model).observe(duration)
 active_requests.labels(model=request.model).dec()
```

## Adding Tokens-Per-Second Tracking

The single most useful metric for an inference server is output tokens per second. Claude Code can extend the metrics module to track this at the token level:

```python
from prometheus_client import Counter, Histogram, Gauge, Summary

Token throughput metrics
tokens_generated = Counter(
 'vllm_tokens_generated_total',
 'Total output tokens generated',
 ['model']
)

tokens_per_second = Summary(
 'vllm_tokens_per_second',
 'Output tokens per second per request',
 ['model']
)

prompt_tokens_processed = Counter(
 'vllm_prompt_tokens_total',
 'Total prompt tokens processed',
 ['model']
)

def record_generation_metrics(
 model: str,
 prompt_token_count: int,
 completion_token_count: int,
 duration_seconds: float
) -> None:
 prompt_tokens_processed.labels(model=model).inc(prompt_token_count)
 tokens_generated.labels(model=model).inc(completion_token_count)
 if duration_seconds > 0:
 tps = completion_token_count / duration_seconds
 tokens_per_second.labels(model=model).observe(tps)
```

Expose the metrics endpoint for Prometheus scraping:

```python
from prometheus_client import make_asgi_app
from fastapi import FastAPI

app = FastAPI()
metrics_app = make_asgi_app()
app.mount("/metrics", metrics_app)
```

A Grafana dashboard showing p95 generation latency, tokens/second, and active request count gives you instant visibility into server health. Claude Code can generate the full dashboard JSON from a description of which panels you need.

## Best Practices for Production Deployment

When deploying vLLM with Claude Code assistance, follow these actionable recommendations:

1. Containerize Your Infrastructure

Use Docker to ensure consistent environments across development and production:

```dockerfile
FROM nvidia/cuda:12.1-runtime-ubuntu22.04

WORKDIR /app
COPY requirements.txt .
RUN pip install -r requirements.txt

COPY . .
EXPOSE 8000

CMD ["python", "inference_server.py"]
```

A more complete Dockerfile that handles vLLM's CUDA dependencies correctly:

```dockerfile
FROM nvcr.io/nvidia/cuda:12.1.0-cudnn8-devel-ubuntu22.04

ARG PYTHON_VERSION=3.11
ARG VLLM_VERSION=0.4.2

ENV DEBIAN_FRONTEND=noninteractive
ENV PYTHONUNBUFFERED=1

RUN apt-get update && apt-get install -y \
 python${PYTHON_VERSION} \
 python${PYTHON_VERSION}-dev \
 python3-pip \
 git \
 && rm -rf /var/lib/apt/lists/*

RUN pip install --no-cache-dir \
 vllm==${VLLM_VERSION} \
 fastapi \
 uvicorn[standard] \
 prometheus-client \
 pydantic>=2.0

WORKDIR /app
COPY . .

EXPOSE 8000
HEALTHCHECK --interval=30s --timeout=10s --retries=3 \
 CMD curl -f http://localhost:8000/health || exit 1

CMD ["uvicorn", "inference_server:app", "--host", "0.0.0.0", "--port", "8000", "--workers", "1"]
```

2. Implement Health Checks

Always include health check endpoints for orchestration systems:

```python
@app.get("/health")
async def health_check():
 return {
 "status": "healthy",
 "model_loaded": llm is not None
 }

@app.get("/ready")
async def readiness_check():
 if llm is None:
 raise HTTPException(status_code=503, detail="Model not loaded")
 return {"status": "ready"}
```

A more informative health endpoint also reports GPU memory usage and the last inference timestamp:

```python
import torch
import time

_last_inference_time: float = 0.0

@app.get("/health/detailed")
async def detailed_health():
 gpu_info = {}
 if torch.cuda.is_available():
 for i in range(torch.cuda.device_count()):
 free, total = torch.cuda.mem_get_info(i)
 gpu_info[f"gpu_{i}"] = {
 "free_gb": round(free / 1e9, 2),
 "total_gb": round(total / 1e9, 2),
 "utilization_pct": round((1 - free / total) * 100, 1),
 }

 return {
 "status": "healthy" if llm is not None else "loading",
 "model_loaded": llm is not None,
 "gpu": gpu_info,
 "seconds_since_last_inference": round(time.time() - _last_inference_time, 1),
 "uptime_seconds": round(time.time() - _start_time, 0),
 }
```

3. Configure Auto-Scaling

For production workloads, configure horizontal pod autoscaling based on inference latency or queue depth:

```yaml
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
 name: vllm-inference-hpa
spec:
 scaleTargetRef:
 apiVersion: apps/v1
 kind: Deployment
 name: vllm-inference
 minReplicas: 2
 maxReplicas: 10
 metrics:
 - type: Resource
 resource:
 name: cpu
 target:
 type: Utilization
 averageUtilization: 70
```

For LLM inference, CPU usage is a poor scaling signal. the bottleneck is GPU. A better approach uses a custom metric based on queue depth or active request count:

```yaml
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
 name: vllm-inference-hpa
spec:
 scaleTargetRef:
 apiVersion: apps/v1
 kind: Deployment
 name: vllm-inference
 minReplicas: 1
 maxReplicas: 8
 metrics:
 - type: Pods
 pods:
 metric:
 name: vllm_active_requests
 target:
 type: AverageValue
 averageValue: "10" # Scale up when avg active requests > 10 per pod
 behavior:
 scaleUp:
 stabilizationWindowSeconds: 60
 policies:
 - type: Pods
 value: 1
 periodSeconds: 90 # Add at most 1 pod per 90s (model load time)
 scaleDown:
 stabilizationWindowSeconds: 300 # 5 min cooldown before scale-down
```

The `stabilizationWindowSeconds` on scale-up matches your model load time so Kubernetes does not over-provision while waiting for new pods to become ready. Claude Code can tune these values based on your measured cold-start duration.

4. Request Queuing and Backpressure

Without backpressure, a traffic spike can cause all in-flight requests to timeout simultaneously. Add a semaphore to cap concurrency:

```python
import asyncio
from fastapi import HTTPException

MAX_CONCURRENT = int(os.environ.get("MAX_CONCURRENT_REQUESTS", "20"))
_semaphore = asyncio.Semaphore(MAX_CONCURRENT)

@app.post("/v1/completions")
async def generate(request: InferenceRequest):
 if _semaphore.locked() and _semaphore._value == 0:
 # Queue is full. return 503 instead of blocking indefinitely
 raise HTTPException(
 status_code=503,
 detail="Server at capacity. Retry after a moment.",
 headers={"Retry-After": "5"},
 )

 async with _semaphore:
 return await _generate_internal(request)
```

## Performance Benchmarking with Claude Code

Before deploying to production, benchmark your server to understand its capacity limits. Claude Code can generate a complete locust benchmark script:

```python
benchmark/locustfile.py
from locust import HttpUser, task, between
import json
import random

SAMPLE_PROMPTS = [
 "Explain the difference between supervised and unsupervised learning.",
 "Write a Python function that reverses a linked list.",
 "What are the main causes of the French Revolution?",
 "Summarize the key principles of object-oriented programming.",
]

class InferenceUser(HttpUser):
 wait_time = between(0.5, 2.0)

 @task(3)
 def chat_completion(self):
 payload = {
 "model": "meta-llama/Meta-Llama-3-8B-Instruct",
 "messages": [{"role": "user", "content": random.choice(SAMPLE_PROMPTS)}],
 "max_tokens": 256,
 "temperature": 0.7,
 }
 with self.client.post(
 "/v1/chat/completions",
 json=payload,
 catch_response=True,
 timeout=30,
 ) as response:
 if response.status_code == 200:
 data = response.json()
 tokens = data.get("usage", {}).get("completion_tokens", 0)
 response.success()
 # Tag with token count for throughput analysis
 self.environment.events.request.fire(
 request_type="TOKENS",
 name="completion_tokens",
 response_time=tokens,
 response_length=0,
 exception=None,
 context={},
 )
 else:
 response.failure(f"HTTP {response.status_code}")

 @task(1)
 def health_check(self):
 self.client.get("/health")
```

Run it with: `locust -f benchmark/locustfile.py --host http://localhost:8000 --users 20 --spawn-rate 2 --run-time 2m`

## Debugging Common vLLM Issues

| Issue | Symptom | Diagnosis Command | Fix |
|---|---|---|---|
| CUDA OOM at load | Server exits immediately | `nvidia-smi` | Reduce `gpu_memory_utilization` or use quantization |
| CUDA OOM at runtime | 500 errors under load | Check `vllm_active_requests` metric | Lower `max_num_seqs` |
| Slow first request | p99 >> p50 on cold start | Log model load time in startup | Pre-warm with a dummy request after startup |
| Generation stops early | `finish_reason: length` | Log `max_tokens` usage | Increase `max_tokens` or add dynamic adjustment |
| Tokenizer mismatch | Garbled or empty output | Compare tokenizer name to model name | Set `tokenizer=` explicitly in `LLM()` |
| High memory fragmentation | Throughput degrades over time | Monitor `vllm_active_requests` over time | Restart on a schedule or tune `block_size` |

Claude Code is particularly effective at diagnosing the first three issues. Paste your server logs and the error message into a Claude Code session and ask "what is wrong with this vLLM configuration?". it will cross-reference the log output against common failure patterns.

## Conclusion

Integrating Claude Code into your vLLM inference server workflow significantly accelerates development and deployment cycles. From generating configuration files to debugging issues, Claude Code serves as an intelligent development partner.

Key takeaways:
- Start with proper model initialization and sampling parameters
- Build solid APIs with FastAPI and comprehensive error handling
- Add streaming and OpenAI-compatible endpoints to maximize downstream compatibility
- Add observability from day one with Prometheus metrics and tokens-per-second tracking
- Containerize everything for reproducible deployments
- Implement health checks and auto-scaling for production resilience
- Benchmark with locust before going live to understand concurrency limits

By following this workflow, you'll have a production-ready LLM inference server that's both performant and maintainable. Once the server code is solid, move on to the infrastructure side with the companion guide [Claude Code vLLM Inference Server Deployment Workflow](/claude-code-vllm-inference-server-deployment-workflow/), which covers using Claude Code skills to build Dockerfiles, Kubernetes manifests, CI/CD pipelines, and security hardening for your vLLM service.



---


**Try it:** Paste your error into our [Error Diagnostic](/diagnose/) for an instant fix.
---

<div class="mastery-cta">

I'm a solo developer in Vietnam. 50K Chrome extension users. $500K+ on Upwork. 5 Claude Max subscriptions running agent fleets in parallel.

These are my actual CLAUDE.md templates, orchestration configs, and prompts. Not a course. Not theory. The files I copy into every project before I write a line of code.

**[See what's inside →](https://zovo.one/lifetime?utm_source=ccg&utm_medium=cta-default&utm_campaign=claude-code-for-vllm-inference-server-workflow)**

$99 once. Free forever. 47/500 founding spots left.

</div>

Related Reading

- [Claude Code vLLM Inference Server Deployment Workflow](/claude-code-vllm-inference-server-deployment-workflow/)
- [Claude Code for Astro Server Endpoints Workflow](/claude-code-for-astro-server-endpoints-workflow/)
- [Claude Code for Language Server Protocol Workflow Guide](/claude-code-for-language-server-protocol-workflow-guide/)
- [Claude Code for Vinxi Server — Workflow Guide](/claude-code-for-vinxi-server-workflow-guide/)

Built by theluckystrike. More at [zovo.one](https://zovo.one)


**Find the right skill →** Browse 155+ skills in our [Skill Finder](/skill-finder/).

**Estimate tokens →** Calculate your usage with our [Token Estimator](/token-estimator/).
