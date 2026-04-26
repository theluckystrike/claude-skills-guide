---
layout: default
title: "Claude Computer Use Token Cost (2026)"
description: "Computer use sessions cost $1.12+ in tool overhead per 100 screenshots. Full breakdown of the 735-token per-call cost structure."
date: 2026-04-19
author: "Claude Skills Guide"
permalink: /claude-computer-use-token-cost-breakdown/
reviewed: true
score: 8
categories: [cost-optimization]
tags: [claude, cost-reduction, computer-use, tokens]
---

# Claude Computer Use Token Cost Breakdown

Claude's computer use tool adds 735 input tokens per turn -- the heaviest of all built-in tools. Combined with screenshot image tokens (1,000-2,000 per screenshot) and the 346-token system overhead, a 100-step computer use session on Opus 4.7 racks up $1.12 in tool overhead alone. That's before counting your actual conversation tokens or the model's output. Understanding this cost structure is the first step to controlling it.

## The Setup

Computer use enables Claude to interact with desktop applications by viewing screenshots and issuing mouse/keyboard actions. The tool definition itself costs 735 tokens because it describes a complex interface: coordinate systems, action types (click, type, scroll, screenshot), and display parameters. Each turn in a computer use session involves the model receiving a screenshot (image tokens billed at input rate), processing the visual information, and emitting a `tool_use` block specifying the next action. Screenshots are the dominant cost driver -- a 1920x1080 screenshot can consume 1,500-2,000 input tokens depending on complexity.

## The Math

A typical computer use session: filling out a web form across 100 steps.

**Per-turn costs at Opus 4.7 ($5.00/$25.00 per MTok):**

| Component | Tokens | Per-Turn Cost |
|-----------|--------|---------------|
| System overhead | 346 | $0.00173 |
| Computer use tool def | 735 | $0.00368 |
| Screenshot (avg) | 1,500 | $0.00750 |
| Conversation context (growing) | ~5,000 avg | $0.02500 |
| **Total input** | **~7,581** | **$0.03791** |
| Action output | 200 | $0.00500 |
| **Total per turn** | **~7,781** | **$0.04291** |

**100-step session total:**
- Fixed tool overhead: 100 x (346 + 735) x $5/MTok = **$0.54**
- Screenshots: 100 x 1,500 x $5/MTok = **$0.75**
- Growing context: sum of 100 turns with increasing history = ~$2.50
- Output: 100 x 200 x $25/MTok = **$0.50**
- **Total session cost: ~$4.29**
- **Tool overhead portion: $1.29 (30% of total)**

**Optimized (batch actions, reduce screenshots by 40%):**
- 60 steps instead of 100 (batch sequential actions)
- Tool overhead: 60 x 1,081 x $5/MTok = **$0.32**
- Screenshots: 60 x 1,500 x $5/MTok = **$0.45**
- **Savings: $0.52 per session (40% reduction in overhead)**

## The Technique

Reduce computer use costs with screenshot optimization and action batching.

```python
import anthropic
import base64
from PIL import Image
import io

client = anthropic.Anthropic()

def optimize_screenshot(
    screenshot_path: str,
    max_width: int = 1280,
    quality: int = 60
) -> str:
    """Reduce screenshot token cost by resizing and compressing."""
    img = Image.open(screenshot_path)

    # Resize if wider than max_width
    if img.width > max_width:
        ratio = max_width / img.width
        new_height = int(img.height * ratio)
        img = img.resize((max_width, new_height), Image.LANCZOS)

    # Convert to JPEG with lower quality (fewer tokens)
    buffer = io.BytesIO()
    img.save(buffer, format="JPEG", quality=quality)
    buffer.seek(0)

    return base64.b64encode(buffer.read()).decode("utf-8")


def should_take_screenshot(
    last_action: str,
    step_count: int,
    consecutive_types: int
) -> bool:
    """Skip screenshots when outcome is predictable."""
    # After typing a single character, no need to screenshot
    if last_action == "type" and consecutive_types < 5:
        return False
    # After clicking a known safe location, skip
    if last_action == "click" and step_count % 3 != 0:
        return False
    return True


def run_computer_session(task: str, max_steps: int = 100):
    """Computer use session with cost optimizations."""
    messages = [{"role": "user", "content": task}]
    total_input_tokens = 0
    total_output_tokens = 0
    screenshots_taken = 0

    for step in range(max_steps):
        response = client.messages.create(
            model="claude-opus-4-7",
            max_tokens=1024,
            tools=[{
                "type": "computer_20250124",
                "name": "computer",
                "display_width_px": 1280,  # reduced from 1920
                "display_height_px": 800,
                "display_number": 1
            }],
            messages=messages
        )

        total_input_tokens += response.usage.input_tokens
        total_output_tokens += response.usage.output_tokens

        if response.stop_reason == "end_turn":
            break

        # Process tool use actions
        for block in response.content:
            if block.type == "tool_use":
                result = execute_action(block.input)
                screenshot = None

                if should_take_screenshot(
                    block.input.get("action", ""),
                    step,
                    count_consecutive_types(messages)
                ):
                    screenshot = optimize_screenshot("current_screen.png")
                    screenshots_taken += 1

                # Build tool result
                tool_result = {"type": "tool_result", "tool_use_id": block.id}
                if screenshot:
                    tool_result["content"] = [{
                        "type": "image",
                        "source": {
                            "type": "base64",
                            "media_type": "image/jpeg",
                            "data": screenshot
                        }
                    }]
                else:
                    tool_result["content"] = "Action completed successfully"

                messages.append({"role": "assistant", "content": response.content})
                messages.append({"role": "user", "content": [tool_result]})

    input_cost = total_input_tokens * 5.00 / 1_000_000
    output_cost = total_output_tokens * 25.00 / 1_000_000
    print(f"Steps: {step + 1}, Screenshots: {screenshots_taken}")
    print(f"Input: {total_input_tokens:,} tokens (${input_cost:.2f})")
    print(f"Output: {total_output_tokens:,} tokens (${output_cost:.2f})")
    print(f"Total: ${input_cost + output_cost:.2f}")
```

Key optimizations: resize display to 1280x800 instead of 1920x1080 (fewer image tokens), compress screenshots to JPEG quality 60, and skip screenshots after predictable actions like single keystrokes.

## The Tradeoffs

Reducing screenshot frequency means the model operates partially blind. It might click a button that triggers an unexpected dialog, then issue the next action against a stale mental model of the screen. Skipping too many screenshots increases error rates and retry loops, which can cost more than the screenshots you saved. Start conservative: skip screenshots only after well-understood actions (typing into a text field), and always screenshot after navigation events (clicking buttons, switching pages).

## Implementation Checklist

- Reduce display resolution in the tool configuration to 1280x800
- Compress screenshots to JPEG quality 60 before sending
- Implement conditional screenshot logic based on action type
- Batch sequential typing actions into single keystrokes where possible
- Log per-session costs including screenshot count and total steps
- Set a maximum step limit to prevent runaway sessions

## Measuring Impact

Track three metrics per session: total steps, screenshots taken, and total cost (input + output tokens). After optimization, compare average session cost with the same task types. Target a 30-40% reduction in screenshots taken, which should yield 20-25% cost savings. At Opus 4.7 rates, saving 40 screenshots per session saves 40 x 1,500 x $5.00/MTok = $0.30 per session.

## Related Guides

**Try it:** Estimate your monthly spend with our [Cost Calculator](/calculator/).

- [Claude API Tool Use Function Calling Deep Dive](/claude-api-tool-use-function-calling-deep-dive-guide/)
- [Advanced Claude Skills with Tool Use](/advanced-claude-skills-with-tool-use-and-function-calling/)
- [Claude Skills Token Optimization Reduce API Costs](/claude-skills-token-optimization-reduce-api-costs/)

## See Also

- [Claude Cost Anomaly Detection Setup Guide](/claude-cost-anomaly-detection-setup-guide/)
- [Claude Code Cost Per Project Estimation Guide](/claude-code-cost-per-project-estimation-guide/)
- [Token-Efficient Few-Shot Examples for Claude](/token-efficient-few-shot-examples-claude/)
- [InsForge vs Supabase: Claude Code Token Cost (2026)](/insforge-vs-supabase-claude-code-token-cost-2026/)
