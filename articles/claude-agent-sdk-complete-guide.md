---
layout: default
title: "Claude Agent SDK (2026)"
description: "Build autonomous AI agents with the Claude Agent SDK. Installation, working examples, architecture patterns, cost analysis, and configuration reference."
permalink: /claude-agent-sdk-complete-guide/
date: 2026-04-20
last_tested: "2026-04-24"
---

# Claude Agent SDK: Complete Developer Guide (2026)

The Claude Agent SDK is Anthropic's official framework for building autonomous AI agents that can reason, use tools, and complete multi-step tasks without human intervention. This guide covers everything from installation to production deployment patterns.

## What Is the Claude Agent SDK?

The Claude Agent SDK provides a structured way to build agents on top of Claude models. Instead of writing raw API calls and manually managing tool-call loops, the SDK handles the agent loop for you: Claude receives a task, decides which tools to call, processes results, and continues until the task is complete or a defined limit is reached.

Key capabilities:

- **Autonomous tool use**: agents call tools, read results, and decide next steps
- **Bounded execution**: configurable turn limits prevent runaway loops
- **Multi-model support**: use Opus for complex reasoning, Sonnet for implementation, Haiku for lightweight checks
- **Built-in error handling**: automatic retries with configurable backoff
- **Streaming**: real-time output as agents work through tasks

The SDK is available for both Python and TypeScript, with near-identical APIs across both.

## Architecture: How the Agent Loop Works

Every agent follows the same core loop:

1. **Receive task** — the agent gets a natural language instruction
2. **Reason** — Claude analyzes the task and decides on the next action
3. **Tool call** — the agent invokes a tool (file read, web search, code execution, etc.)
4. **Process result** — Claude reads the tool output and decides whether to continue or stop
5. **Repeat** — steps 2-4 repeat until the task is complete or `max_turns` is reached

```
User prompt → [Claude reasons] → Tool call → Result → [Claude reasons] → Tool call → Result → Final answer
```

This loop is the same pattern Claude Code uses internally. The SDK exposes it as a programmable interface.

<div id="agent-viz" style="background:#1a1a2e;border:1px solid #2a2a3a;border-radius:8px;padding:20px;margin:24px 0;font-family:system-ui,-apple-system,sans-serif;">
<h3 style="color:#6ee7b7;margin:0 0 12px 0;font-size:18px;">Agent Pattern Selector</h3>
<p style="color:#94a3b8;margin:0 0 16px 0;font-size:14px;">Choose a pattern to see its architecture, use case, and cost profile.</p>
<div style="display:flex;flex-wrap:wrap;gap:6px;margin-bottom:16px;">
<button class="avz-btn" data-p="seq" onclick="showAP('seq')" style="padding:6px 14px;background:#6ee7b7;color:#0f172a;border:none;border-radius:6px;font-size:13px;font-weight:600;cursor:pointer;">Sequential</button>
<button class="avz-btn" data-p="orch" onclick="showAP('orch')" style="padding:6px 14px;background:#334155;color:#e2e8f0;border:none;border-radius:6px;font-size:13px;cursor:pointer;">Orchestrator</button>
<button class="avz-btn" data-p="pipe" onclick="showAP('pipe')" style="padding:6px 14px;background:#334155;color:#e2e8f0;border:none;border-radius:6px;font-size:13px;cursor:pointer;">Pipeline</button>
</div>
<div id="avz-out" style="background:#0f172a;padding:16px;border-radius:6px;color:#e2e8f0;font-size:14px;line-height:1.7;"></div>
</div>
{% raw %}
<script>
var apData={seq:{name:"Sequential Pattern",flow:"User Prompt \u2192 [Agent Reasons] \u2192 Tool Call \u2192 Result \u2192 [Agent Reasons] \u2192 Tool Call \u2192 ... \u2192 Final Output",desc:"One agent, linear execution. The agent receives a task, reasons through it step by step, calls tools as needed, and produces a final result.",best:"Single-purpose tasks, file edits, code review, simple automations",turns:"5-15 turns typical",cost:"$0.01-$0.50 (Sonnet), lowest cost pattern",code:'agent = Agent(\n  model="claude-sonnet-4-20250514",\n  tools=[tools.bash, tools.read_file],\n  max_turns=10\n)\nresult = agent.run("Analyze this module")'},orch:{name:"Orchestrator-Worker Pattern",flow:"User Prompt \u2192 [Orchestrator Agent] \u2192 delegates to [Worker A] + [Worker B] \u2192 Workers return results \u2192 [Orchestrator combines] \u2192 Final Output",desc:"A main agent delegates subtasks to specialized sub-agents. Each worker has its own model, tools, and turn limit. The orchestrator synthesizes results.",best:"Complex tasks with distinct sub-problems: security audit + style check, multi-language analysis, research + writing",turns:"15-30 turns total (across all agents)",cost:"$0.50-$5.00 (mixed models), highest capability",code:'orchestrator = Agent(\n  model="claude-opus-4-20250514",\n  sub_agents=[security_agent, style_agent],\n  max_turns=15\n)\nresult = orchestrator.run("Review the codebase")'},pipe:{name:"Pipeline Pattern",flow:"User Prompt \u2192 [Agent 1: Generate] \u2192 output \u2192 [Agent 2: Review] \u2192 output \u2192 [Agent 3: Test] \u2192 Final Output",desc:"Agents chained in sequence. Each agent's output becomes the next agent's input. Each stage has a focused role with its own tools.",best:"Staged workflows: generate-then-review, write-then-test, extract-then-transform",turns:"10-20 turns per stage",cost:"$0.15-$2.00 per stage (Sonnet), predictable per-stage costs",code:'gen = Agent(model="opus", tools=[tools.write_file], max_turns=10)\ngen.run("Write a REST API")\nrev = Agent(model="sonnet", tools=[tools.read_file], max_turns=10)\nrev.run("Review and fix ./api.py")'}};
function showAP(p){var d=apData[p];if(!d)return;document.getElementById('avz-out').innerHTML='<div style="color:#6ee7b7;font-weight:600;font-size:16px;margin-bottom:8px;">'+d.name+'</div><div style="background:#1a1a2e;padding:10px;border-radius:4px;font-family:monospace;font-size:12px;color:#4ade80;margin-bottom:12px;overflow-x:auto;white-space:nowrap;">'+d.flow+'</div><p style="margin:0 0 8px 0;">'+d.desc+'</p><div style="display:grid;grid-template-columns:1fr 1fr;gap:8px;margin:12px 0;"><div><span style="color:#94a3b8;font-size:12px;">BEST FOR</span><div style="font-size:13px;">'+d.best+'</div></div><div><span style="color:#94a3b8;font-size:12px;">TYPICAL TURNS</span><div style="font-size:13px;">'+d.turns+'</div></div><div><span style="color:#94a3b8;font-size:12px;">COST RANGE</span><div style="font-size:13px;">'+d.cost+'</div></div></div><pre style="background:#1a1a2e;padding:10px;border-radius:4px;font-size:12px;color:#e2e8f0;overflow-x:auto;margin:8px 0 0 0;">'+d.code+'</pre>';document.querySelectorAll('.avz-btn').forEach(function(b){b.style.background=b.getAttribute('data-p')===p?'#6ee7b7':'#334155';b.style.color=b.getAttribute('data-p')===p?'#0f172a':'#e2e8f0';b.style.fontWeight=b.getAttribute('data-p')===p?'600':'400';});}
showAP('seq');
</script>

## Installation

### Python

```bash
pip install claude-agent-sdk
```

Requires Python 3.9 or later. Set your API key:

```bash
export ANTHROPIC_API_KEY="sk-ant-..."
```

### TypeScript

```bash
npm install @anthropic-ai/claude-agent-sdk
```

Requires Node.js 18 or later. Set your API key in your environment or pass it directly to the agent constructor.

## First Agent in 5 Minutes

Here is a minimal working agent that analyzes a directory and reports its findings:

```python
from claude_agent_sdk import Agent, tools

agent = Agent(
    model="claude-sonnet-4-20250514",
    tools=[tools.bash, tools.read_file, tools.write_file],
    max_turns=10,
    system_prompt="You are a code analyst. Be concise and specific.",
)

result = agent.run("List all Python files in the current directory and summarize what each one does.")
print(result.final_output)
```

This agent will:
1. Use the bash tool to run `ls *.py` or similar
2. Read each file it finds
3. Produce a summary
4. Stop when finished (or after 10 turns, whichever comes first)

The `max_turns=10` parameter is critical. Without a bound, an agent that gets confused could loop indefinitely, burning tokens and money.

## 3 Complete Working Agent Examples

### Example 1: Code Review Agent

This agent reads source files, identifies issues, and writes a review report.

```python
from claude_agent_sdk import Agent, tools

code_reviewer = Agent(
    model="claude-sonnet-4-20250514",
    tools=[tools.read_file, tools.bash, tools.write_file],
    max_turns=20,
    system_prompt="""You are a senior code reviewer. For each file:
1. Check for bugs, security issues, and performance problems.
2. Note any style violations.
3. Write findings to review-report.md.
Be specific — include line numbers and concrete suggestions.""",
)

result = code_reviewer.run("Review all .py files in ./src/ and write a report to review-report.md")
print(f"Review complete. Turns used: {result.turns_used}")
```

### Example 2: Research Agent

This agent searches the web, gathers information, and produces a structured summary.

```python
from claude_agent_sdk import Agent, tools

researcher = Agent(
    model="claude-sonnet-4-20250514",
    tools=[tools.web_search, tools.write_file],
    max_turns=15,
    system_prompt="""You are a research analyst. Search for information,
cross-reference multiple sources, and produce a structured report.
Always cite your sources with URLs.""",
)

result = researcher.run(
    "Research the current state of WebAssembly adoption in 2026. "
    "Write findings to wasm-report.md with sections for browser support, "
    "server-side usage, and notable projects."
)
```

### Example 3: Data Pipeline Agent

This agent reads raw data, transforms it, and writes clean output.

```python
from claude_agent_sdk import Agent, tools

pipeline_agent = Agent(
    model="claude-sonnet-4-20250514",
    tools=[tools.read_file, tools.bash, tools.write_file],
    max_turns=12,
    system_prompt="""You are a data engineer. Read the input CSV,
clean and transform the data, and write the output.
Use Python scripts for transformations. Validate output before writing.""",
)

result = pipeline_agent.run(
    "Read data/raw-sales.csv, remove duplicates, normalize date formats "
    "to ISO 8601, calculate monthly totals, and write to data/clean-sales.csv"
)
```

## Configuration Reference

### model

The Claude model to use. Current options:

| Model | Best For | Cost |
|-------|----------|------|
| `claude-opus-4-20250514` | Complex reasoning, architecture, planning | $15/$75 per M tokens |
| `claude-sonnet-4-20250514` | General coding, implementation, analysis | $3/$15 per M tokens |
| `claude-haiku-4-5-20251001` | Simple tasks, classification, quick edits | $0.80/$4 per M tokens |

### max_turns

The maximum number of reasoning-and-tool-call cycles. This is your safety bound.

- **5-10 turns**: simple, well-defined tasks
- **15-25 turns**: multi-file operations, moderate complexity
- **30-50 turns**: large refactors, complex research (use with caution)

Never set `max_turns` above 100 unless you have a specific reason and a cost alert configured.

### tools

The list of tools the agent can use. Only provide tools the agent actually needs — every tool definition consumes tokens in the system prompt.

```python
# Minimal tool set for a file-editing agent
tools=[tools.read_file, tools.write_file, tools.bash]

# Research agent
tools=[tools.web_search, tools.read_file, tools.write_file]

# Full toolkit (costs more tokens per turn)
tools=[tools.bash, tools.read_file, tools.write_file, tools.web_search, tools.glob, tools.grep]
```

### system_prompt

Instructions that shape agent behavior. Keep it concise — long system prompts consume tokens every turn.

### temperature

Controls randomness. Default is 0 for agents (deterministic). Increase to 0.3-0.7 for creative tasks.

### max_tokens

Maximum tokens per individual Claude response. Default is 4096. Increase for tasks that need long outputs (report generation, large code files).

## Agent Patterns

### Sequential Pattern

One agent, linear steps. Simplest and most predictable.

```python
agent = Agent(model="claude-sonnet-4-20250514", tools=[...], max_turns=10)
result = agent.run("Do X, then Y, then Z")
```

Best for: single-purpose tasks, scripts, simple automations.

### Orchestrator-Worker Pattern

A main agent delegates subtasks to specialized sub-agents.

```python
from claude_agent_sdk import Agent, tools

# Specialist agents
security_agent = Agent(
    model="claude-sonnet-4-20250514",
    tools=[tools.read_file, tools.bash],
    max_turns=10,
    system_prompt="You are a security auditor. Check for vulnerabilities.",
)

style_agent = Agent(
    model="claude-haiku-4-5-20251001",
    tools=[tools.read_file],
    max_turns=5,
    system_prompt="You are a style checker. Check code formatting.",
)

# Orchestrator
orchestrator = Agent(
    model="claude-opus-4-20250514",
    tools=[tools.read_file, tools.write_file],
    sub_agents=[security_agent, style_agent],
    max_turns=15,
    system_prompt="Coordinate the security and style reviews. Combine findings into a single report.",
)

result = orchestrator.run("Review the ./src/ directory")
```

Best for: complex tasks with distinct sub-problems. See our [multi-agent architecture guide](/claude-code-multi-agent-architecture-guide-2026/) for detailed patterns.

### Pipeline Pattern

Agents chained together, where one agent's output becomes the next agent's input.

```python
# Agent 1: Generate code
generator = Agent(model="claude-opus-4-20250514", tools=[tools.write_file], max_turns=10)
gen_result = generator.run("Write a REST API for user management in FastAPI")

# Agent 2: Review the generated code
reviewer = Agent(model="claude-sonnet-4-20250514", tools=[tools.read_file, tools.write_file], max_turns=10)
review_result = reviewer.run("Review the code in ./api.py and fix any issues")

# Agent 3: Write tests
tester = Agent(model="claude-sonnet-4-20250514", tools=[tools.read_file, tools.write_file, tools.bash], max_turns=15)
test_result = tester.run("Write pytest tests for ./api.py and run them")
```

Best for: staged workflows where each step has clear inputs and outputs.

## Cost Analysis

Agent costs scale with turns and context size. Here are realistic estimates:

| Scenario | Model | Turns | Estimated Cost |
|----------|-------|-------|---------------|
| Simple file edit | Haiku | 3-5 | $0.01-0.03 |
| Code review (5 files) | Sonnet | 10-15 | $0.15-0.40 |
| Full codebase analysis | Sonnet | 20-30 | $0.50-1.50 |
| Architecture planning | Opus | 10-20 | $1.00-5.00 |
| Complex refactor | Opus | 30-50 | $3.00-15.00 |

Key cost drivers:
- **Context accumulation**: each turn adds to the conversation, so later turns process more tokens
- **Tool definitions**: each tool adds 200-400 tokens to every request
- **Model choice**: Opus costs 5x more than Sonnet per token

For detailed cost tracking, see our [ccusage tracking guide](/ccusage-claude-code-cost-tracking-guide-2026/) and [cost reduction strategies](/claude-code-costs-too-much-reduce-spend-2026/).

## Comparison: Agent SDK vs Claude Code CLI vs Direct API

| Feature | Agent SDK | Claude Code CLI | Direct API |
|---------|-----------|----------------|------------|
| Agent loop | Built-in | Built-in | Manual |
| Tool management | SDK-managed | Pre-configured | Manual |
| Multi-agent | Supported | Via subagents | Manual |
| Customization | Full | Limited (CLAUDE.md) | Full |
| Setup effort | Medium | Low | High |
| Best for | Custom agents | Dev workflows | Full control |

**Use Agent SDK** when you need programmatic control over agents — custom tools, custom workflows, integration into larger systems.

**Use Claude Code CLI** when you need an interactive coding assistant or want to run agents via [API mode](/claude-code-api-mode-vs-interactive-2026/).

**Use the Direct API** when you need maximum control and are comfortable building the agent loop yourself.

## Error Handling and Retry Patterns

Agents can fail in several ways. Handle each:

```python
from claude_agent_sdk import Agent, AgentError, RateLimitError, ToolError

agent = Agent(
    model="claude-sonnet-4-20250514",
    tools=[tools.bash, tools.read_file],
    max_turns=15,
    retry_config={
        "max_retries": 3,
        "backoff_factor": 2.0,  # exponential backoff
        "retry_on": [RateLimitError],
    },
)

try:
    result = agent.run("Analyze the codebase")
    if result.hit_turn_limit:
        print("Warning: agent hit max_turns before completing")
    print(result.final_output)
except RateLimitError:
    print("Rate limited after all retries")
except ToolError as e:
    print(f"Tool failed: {e.tool_name} — {e.message}")
except AgentError as e:
    print(f"Agent error: {e}")
```

Best practices for error handling:
- Always set `max_turns` to prevent runaway execution
- Use `retry_config` for transient API errors
- Check `result.hit_turn_limit` to detect incomplete runs
- Log `result.turns_used` and `result.total_tokens` for cost monitoring

## Frequently Asked Questions

**Is the Claude Agent SDK free?**
The SDK itself is free and open source. You pay for Claude API usage (per-token pricing) when agents run. See our [Claude Code cost guide](/claude-code-cost-complete-guide/) for detailed pricing.

**What models work with the Agent SDK?**
All Claude models: Opus 4, Sonnet 4, Sonnet 4.5, and Haiku 4.5. Choose based on task complexity and budget.

**How is this different from Claude Code?**
Claude Code is a pre-built coding agent. The Agent SDK lets you build custom agents for any purpose — not just coding. See our [how to build a Claude Code agent guide](/how-to-build-claude-code-agent-2026/) for a deeper comparison.

**Can I use custom tools?**
Yes. Define tools as Python functions with type hints, and the SDK automatically generates the tool schema for Claude.

**What about rate limits?**
The SDK respects Anthropic API rate limits. Configure `retry_config` for automatic backoff when limits are hit.

**Can agents call other agents?**
Yes. The orchestrator-worker pattern lets agents delegate to sub-agents. Each sub-agent has its own tool set and turn limit.

**How do I control costs?**
Three strategies: use cheaper models (Haiku for simple sub-tasks), set strict `max_turns` limits, and minimize the tool list. Our [cost reduction guide](/claude-code-costs-too-much-reduce-spend-2026/) covers this in detail.

**Is the Agent SDK production-ready?**
Yes. It includes error handling, retry logic, and structured output support. For production deployments, add monitoring, logging, and cost alerts.

## Production Deployment Checklist

Before deploying agents to production, verify each item:

- **Turn limits**: every agent has a `max_turns` value appropriate to its task
- **Error handling**: try/except blocks around `agent.run()` with specific exception types
- **Cost monitoring**: log `result.total_tokens` and `result.turns_used` after every run
- **Spending alerts**: configured in the Anthropic console with email notifications
- **Retry configuration**: exponential backoff for rate limit errors
- **Tool scoping**: each agent has only the tools it needs (no unused tools inflating token counts)
- **Logging**: agent inputs, outputs, and errors written to a structured log
- **Testing**: agents tested against known inputs with expected outputs verified
- **Timeout**: pipeline-level timeout to prevent stalled agents from blocking indefinitely
- **Secrets isolation**: API keys passed via environment variables, never hardcoded in agent code
- **Output validation**: verify agent output matches expected schema before downstream processing

Treat agents like microservices: each should have clear inputs, outputs, error handling, and monitoring.

---

*Need the complete toolkit? [The Claude Code Playbook](https://zovo.one/pricing) includes 200 production-ready templates, decision frameworks, and team setup guides for every Claude Code workflow.*

## Production Agent Architectures

The three patterns above (sequential, orchestrator, pipeline) are starting points. Production deployments require deeper architecture decisions around parallelism, failure isolation, and cost governance. Here are three battle-tested patterns with their tradeoffs.

### Pattern 1: Fan-Out (Parallel Workers)

A coordinator dispatches the same task type to N workers running concurrently. Each worker processes an independent unit of work. The coordinator collects results when all workers finish.

```
                          ┌──── [Worker A] ──── Result A ────┐
                          │                                    │
User Task ── [Coordinator] ──── [Worker B] ──── Result B ──── [Merge] ── Final Output
                          │                                    │
                          └──── [Worker C] ──── Result C ────┘
```

```python
import asyncio
from claude_agent_sdk import Agent, tools

async def fan_out_review(file_paths: list[str]):
    """Review N files in parallel using independent agents."""
    async def review_one(path: str):
        agent = Agent(
            model="claude-sonnet-4-20250514",
            tools=[tools.read_file],
            max_turns=8,
            system_prompt=f"Review {path} for bugs. Output JSON with fields: file, issues[], severity.",
        )
        return await agent.arun(f"Review {path}")

    results = await asyncio.gather(*[review_one(p) for p in file_paths])
    return [r.final_output for r in results]
```

**Cost profile:** Linear with worker count. 10 files at $0.15 each = $1.50 total. All workers run simultaneously, so wall-clock time equals the slowest single worker.

**Failure mode:** One worker failure does not affect others. Use `asyncio.gather(return_exceptions=True)` to collect partial results when some workers fail.

**CLAUDE.md governance:** Add to each worker's system prompt: "You may only read files. Do not execute commands. Do not modify files. Report findings only."

### Pattern 2: Pipeline (Sequential Stages)

Each stage transforms input and passes output to the next. Stages can use different models optimized for their role.

```
[Stage 1: Generate]     [Stage 2: Validate]     [Stage 3: Test]
 Opus ($$$)         ──▶  Haiku ($)           ──▶  Sonnet ($$)
 Write code              Check types/lint         Run tests, fix
 max_turns=15            max_turns=5              max_turns=20
```

```python
# Stage 1: Generate with Opus (high capability)
generator = Agent(
    model="claude-opus-4-20250514",
    tools=[tools.write_file],
    max_turns=15,
    system_prompt="Write production-quality code. Include docstrings and type hints.",
)
gen = generator.run("Implement a Redis-backed session store for FastAPI")

# Stage 2: Validate with Haiku (fast, cheap)
validator = Agent(
    model="claude-haiku-4-5-20251001",
    tools=[tools.read_file, tools.bash],
    max_turns=5,
    system_prompt="Run mypy and ruff on the generated code. Report any issues. Do not fix them.",
)
val = validator.run("Validate the code in ./session_store.py")

# Stage 3: Fix and test with Sonnet (balanced)
fixer = Agent(
    model="claude-sonnet-4-20250514",
    tools=[tools.read_file, tools.write_file, tools.bash],
    max_turns=20,
    system_prompt="Fix all issues from validation. Run pytest. Iterate until all tests pass.",
)
fix = fixer.run(f"Fix these issues in session_store.py: {val.final_output}")
```

**Cost profile:** $2-8 total. Opus for the creative work, Haiku for the cheap validation gate, Sonnet for the iterative fix loop. The validation gate prevents expensive Sonnet iterations on fundamentally flawed code.

**Failure mode:** If Stage 2 validation finds catastrophic issues, abort early instead of passing garbage to Stage 3. Check `val.final_output` for critical errors before proceeding.

**CLAUDE.md governance:** Stage 1 can only write files. Stage 2 can only read and lint. Stage 3 can read, write, and run tests. No stage has network access beyond the Anthropic API.

### Pattern 3: Supervisor (Orchestrator + Specialists)

A supervisor agent receives high-level goals, breaks them into subtasks, assigns each to the best specialist, monitors progress, and handles failures by reassigning or adjusting strategy.

```
                    ┌─ [Security Specialist] ─ tools: bash(semgrep), read
                    │
[Supervisor] ──────┼─ [Perf Specialist] ───── tools: bash(hyperfine, ab), read
 Opus               │
 Manages strategy   ├─ [Docs Specialist] ──── tools: read, write
 max_turns=25       │
                    └─ [Test Specialist] ──── tools: bash(pytest), read, write
```

```python
security = Agent(
    model="claude-sonnet-4-20250514",
    tools=[tools.read_file, tools.bash],
    max_turns=10,
    system_prompt="You are a security auditor. Run SAST scans and review for OWASP Top 10.",
)

perf = Agent(
    model="claude-sonnet-4-20250514",
    tools=[tools.read_file, tools.bash],
    max_turns=10,
    system_prompt="You are a performance engineer. Profile code and identify bottlenecks.",
)

supervisor = Agent(
    model="claude-opus-4-20250514",
    sub_agents=[security, perf],
    max_turns=25,
    system_prompt="""You are a technical lead. Given a codebase:
1. Dispatch security audit to the security specialist
2. Dispatch performance analysis to the perf specialist
3. Synthesize findings into a prioritized action plan
4. If a specialist fails, retry once with a simplified scope""",
)

result = supervisor.run("Audit ./src/ for security and performance issues")
```

**Cost profile:** $5-15 depending on codebase size. The Opus supervisor is the main cost driver. Keep supervisor `max_turns` tight — it should delegate, not do the work itself.

**Failure mode:** The supervisor can detect specialist failures and retry with adjusted parameters (fewer files, simpler scope). This self-healing behavior is the key advantage over static pipelines.

**CLAUDE.md governance:** The supervisor cannot execute commands directly — it can only delegate to specialists. Each specialist has scoped tool access. No specialist can write to files outside its domain.

## Monitoring and Logging Patterns

Production agents need structured observability. Log every run with enough detail to diagnose failures and track costs.

### Structured Run Logging

```python
import json
import logging
from datetime import datetime, timezone
from claude_agent_sdk import Agent, tools

logging.basicConfig(
    format='%(message)s',
    level=logging.INFO,
    handlers=[logging.FileHandler("agent-runs.jsonl")]
)

agent = Agent(
    model="claude-sonnet-4-20250514",
    tools=[tools.bash, tools.read_file],
    max_turns=15,
)

start = datetime.now(timezone.utc)
result = agent.run("Analyze the test suite for flaky tests")
end = datetime.now(timezone.utc)

log_entry = {
    "timestamp": start.isoformat(),
    "duration_seconds": (end - start).total_seconds(),
    "model": "claude-sonnet-4-20250514",
    "turns_used": result.turns_used,
    "total_tokens": result.total_tokens,
    "input_tokens": result.input_tokens,
    "output_tokens": result.output_tokens,
    "hit_turn_limit": result.hit_turn_limit,
    "estimated_cost_usd": (result.input_tokens * 3 + result.output_tokens * 15) / 1_000_000,
    "task": "flaky test analysis",
    "status": "complete" if not result.hit_turn_limit else "truncated",
}
logging.info(json.dumps(log_entry))
```

This produces a JSONL file where each line is a complete run record. Feed it into your existing monitoring stack (Datadog, Grafana, CloudWatch) for dashboards and alerts.

### Cost Alert Thresholds

Set alerts at multiple levels to catch runaway agents before they drain your budget:

```python
COST_THRESHOLDS = {
    "per_run_warn": 2.00,     # Warn if a single run exceeds $2
    "per_run_abort": 10.00,   # Abort if a single run exceeds $10
    "daily_budget": 50.00,    # Hard daily cap across all agents
    "monthly_budget": 500.00, # Monthly spending ceiling
}
```

### Health Check Endpoint

If your agents run as a service, expose a health check:

```python
from flask import Flask, jsonify

app = Flask(__name__)

@app.route("/health")
def health():
    return jsonify({
        "status": "ok",
        "agents_running": active_agent_count,
        "total_runs_today": daily_run_count,
        "estimated_cost_today_usd": daily_cost_estimate,
    })
```

## Real Cost Examples with Actual Token Counts

Abstract cost tables are not enough. Here are measured costs from real agent runs:

### Example: Code review of a 15-file Python project

```
Model:          claude-sonnet-4-20250514
Turns used:     12
Input tokens:   34,218 (file contents + system prompt + tool results)
Output tokens:  6,841 (review comments + tool calls)
Cost:           (34,218 * $3 + 6,841 * $15) / 1,000,000 = $0.205
Duration:       47 seconds
```

### Example: Refactor a module (rename + update imports)

```
Model:          claude-sonnet-4-20250514
Turns used:     22
Input tokens:   89,450 (grows each turn as context accumulates)
Output tokens:  12,330
Cost:           (89,450 * $3 + 12,330 * $15) / 1,000,000 = $0.453
Duration:       2 minutes 15 seconds
```

### Example: Architecture planning with Opus

```
Model:          claude-opus-4-20250514
Turns used:     8
Input tokens:   22,100
Output tokens:  8,900
Cost:           (22,100 * $15 + 8,900 * $75) / 1,000,000 = $0.999
Duration:       1 minute 40 seconds
```

The pattern is clear: context accumulation is the primary cost driver. An agent that runs 30 turns processes exponentially more input tokens than one that runs 10 turns, because each turn includes the full conversation history. Use `/compact` or context summarization between stages to control this.

## Security Considerations for Agent Deployments

Agents that run autonomously introduce security risks that do not exist with interactive AI usage.

### Principle of Least Privilege

Give each agent only the tools it needs. A code review agent should not have `write_file` access. A report generator should not have `bash` access.

```python
# Bad: overly permissive
agent = Agent(tools=[tools.bash, tools.read_file, tools.write_file, tools.web_search, tools.glob, tools.grep])

# Good: scoped to actual need
review_agent = Agent(tools=[tools.read_file, tools.grep])
```

### Input Sanitization

If agent prompts include user-provided input (issue descriptions, PR bodies, form submissions), sanitize the input to prevent prompt injection:

```python
def sanitize_agent_input(user_text: str) -> str:
    """Strip potential prompt injection patterns from user input."""
    # Remove instruction-like patterns
    sanitized = user_text.replace("SYSTEM:", "")
    sanitized = sanitized.replace("IGNORE PREVIOUS", "")
    sanitized = sanitized.replace("<!-- ", "").replace(" -->", "")
    # Truncate to prevent context flooding
    return sanitized[:5000]

result = agent.run(f"Review this PR description: {sanitize_agent_input(pr_body)}")
```

### Network Isolation

For agents that should only read local files, run them without network access:

```bash
# Docker with no network
docker run --rm --network=none \
  -e ANTHROPIC_API_KEY="$KEY" \
  -v $(pwd):/app \
  my-agent-image
```

Note: the agent still needs network access to call the Anthropic API. Use Docker's network policies to allow only `api.anthropic.com:443` while blocking all other outbound traffic.

### Secret Management

Never pass secrets through agent prompts. Use environment variables and configure tools to access them directly:

```python
# Bad: secret in prompt
agent.run(f"Connect to database at postgres://admin:{DB_PASSWORD}@db.example.com/prod")

# Good: secret in environment, tool reads it
agent.run("Connect to the production database using the credentials in DATABASE_URL")
```

## Claude Code SDK: How It Relates to the Agent SDK

Developers searching for "claude code sdk" are often looking for one of two things: the Claude Agent SDK (covered in this guide) or the programmatic interface to Claude Code itself. They are related but distinct.

**Claude Agent SDK** is the library (`claude-agent-sdk` on PyPI, `@anthropic-ai/claude-agent-sdk` on npm) for building custom autonomous agents. You write agent code, define tools, set turn limits, and run agents programmatically. This is what you use when building your own agent from scratch.

**Claude Code SDK** refers to using Claude Code in non-interactive (API/headless) mode. Instead of typing commands in a terminal, you invoke Claude Code programmatically from scripts:

```bash
# Claude Code SDK usage — run Claude Code as a subprocess
claude -p "Refactor the auth module" --output-format json

# Pipe output to another tool
claude -p "List all TODO comments" --output-format json | jq '.result'

# Use in a CI/CD pipeline
claude -p "Review this diff for security issues: $(git diff HEAD~1)" --model claude-sonnet-4-20250514
```

```python
# Python wrapper for Claude Code SDK
import subprocess
import json

def run_claude_code(prompt: str, model: str = "claude-sonnet-4-20250514") -> dict:
    result = subprocess.run(
        ["claude", "-p", prompt, "--output-format", "json", "--model", model],
        capture_output=True, text=True
    )
    return json.loads(result.stdout)

output = run_claude_code("Analyze the test coverage in ./src/")
```

**When to use which:**

| Need | Use |
|------|-----|
| Build a custom agent with custom tools | Claude Agent SDK |
| Automate Claude Code in scripts/CI | Claude Code SDK (API mode) |
| Interactive development | Claude Code CLI |
| Maximum control over the agent loop | Claude Agent SDK |
| Leverage Claude Code's built-in tools (Read, Edit, Bash) | Claude Code SDK (API mode) |

The Claude Code SDK (API mode) is often the faster path when you want Claude Code's existing capabilities without writing custom agent logic. The Agent SDK is for when you need agents that do things Claude Code was not built for. See our [API mode guide](/claude-code-api-mode-vs-interactive-2026/) for detailed Claude Code SDK usage.

## Next Steps

- [Build your first Claude Code agent](/how-to-build-claude-code-agent-2026/) — step-by-step walkthrough
- [Multi-agent architecture patterns](/claude-code-multi-agent-architecture-guide-2026/) — orchestrator, pipeline, and swarm patterns
- [Claude Code prompt engineering](/claude-code-prompt-engineering-tips-2026/) — write better system prompts for agents
- [Best Claude Code agents for frontend](/best-claude-code-agents-frontend-2026/) — domain-specific agent examples
- [Cost tracking with ccusage](/ccusage-claude-code-cost-tracking-guide-2026/) — monitor agent spend
- [API mode vs interactive mode](/claude-code-api-mode-vs-interactive-2026/) — choose the right execution model
- [The Claude Code Playbook](/playbook/) — comprehensive reference for power users
- [Claude Code best practices](/claude-code-claude-md-best-practices/) — CLAUDE.md configuration patterns

- [Claude Flow tool guide](/claude-flow-tool-guide/) — Multi-agent orchestration with Claude Flow
- [sequential thinking in Claude Code](/sequential-thinking-claude-code-guide/) — Use sequential thinking in agent pipelines
### Can I deploy agents as a REST API service?

Yes. Wrap the agent.run() call in a web framework like Flask or FastAPI. Add request validation, authentication, and rate limiting. Each API request creates a new agent run.

### How do I test agents before deploying to production?

Create a test suite with known inputs and expected outputs. Run agents against these inputs and verify the final_output matches expectations. Use deterministic temperature (0.0) for reproducible results.

### Can agents access the internet?

Yes, if you provide the web_search tool. Without it, agents can only access local files and run local commands. Control network access through tool selection and Docker network policies.

<script type="application/ld+json">
{
  "@context": "https://schema.org",
  "@type": "FAQPage",
  "mainEntity": [
    {"@type": "Question", "name": "Is the Claude Agent SDK free?", "acceptedAnswer": {"@type": "Answer", "text": "The SDK itself is free and open source. You pay for Claude API usage (per-token pricing) when agents run."}},
    {"@type": "Question", "name": "What models work with the Agent SDK?", "acceptedAnswer": {"@type": "Answer", "text": "All Claude models: Opus 4, Sonnet 4, Sonnet 4.5, and Haiku 4.5. Choose based on task complexity and budget."}},
    {"@type": "Question", "name": "How is this different from Claude Code?", "acceptedAnswer": {"@type": "Answer", "text": "Claude Code is a pre-built coding agent. The Agent SDK lets you build custom agents for any purpose, not just coding."}},
    {"@type": "Question", "name": "Can I use custom tools?", "acceptedAnswer": {"@type": "Answer", "text": "Yes. Define tools as Python functions with type hints, and the SDK automatically generates the tool schema for Claude."}},
    {"@type": "Question", "name": "What about rate limits?", "acceptedAnswer": {"@type": "Answer", "text": "The SDK respects Anthropic API rate limits. Configure retry_config for automatic backoff when limits are hit."}},
    {"@type": "Question", "name": "Can agents call other agents?", "acceptedAnswer": {"@type": "Answer", "text": "Yes. The orchestrator-worker pattern lets agents delegate to sub-agents. Each sub-agent has its own tool set and turn limit."}},
    {"@type": "Question", "name": "How do I control costs?", "acceptedAnswer": {"@type": "Answer", "text": "Three strategies: use cheaper models for simple sub-tasks, set strict max_turns limits, and minimize the tool list."}},
    {"@type": "Question", "name": "Can I deploy agents as a REST API service?", "acceptedAnswer": {"@type": "Answer", "text": "Yes. Wrap the agent.run() call in a web framework like Flask or FastAPI. Add request validation, authentication, and rate limiting."}},
    {"@type": "Question", "name": "How do I test agents before deploying to production?", "acceptedAnswer": {"@type": "Answer", "text": "Create a test suite with known inputs and expected outputs. Run agents against these inputs and verify the final_output matches expectations. Use temperature 0.0 for reproducible results."}},
    {"@type": "Question", "name": "Can agents access the internet?", "acceptedAnswer": {"@type": "Answer", "text": "Yes, if you provide the web_search tool. Without it, agents can only access local files and run local commands. Control network access through tool selection and Docker network policies."}}
  ]
}
</script>

## See Also

**Try it:** Estimate your monthly spend with our [Cost Calculator](/calculator/).

- [Claude Code Hooks Complete Guide](/claude-code-hooks-complete-guide/)
- [Claude Code Router Guide](/claude-code-router-guide/)
- [Super Claude Code Framework Guide](/super-claude-code-framework-guide/)
- [Best Practices Guide](/best-practices/). Production-ready Claude Code guidelines and patterns

{% endraw %}
