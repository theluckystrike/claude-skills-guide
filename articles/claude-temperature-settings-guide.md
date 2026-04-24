---
title: "Claude Temperature Settings: How to Adjust (2026)"
description: "Yes, you can adjust Claude's temperature — but only via the API. Full guide to temperature, top_p, top_k, recommended values by task, and code examples."
permalink: /claude-temperature-settings-guide/
last_tested: "2026-04-24"
render_with_liquid: false
---

# Claude Temperature Settings: How to Adjust (2026)

Yes, you can change Claude's temperature — but only through the Anthropic API. Claude.ai (the web interface) and Claude Code (the CLI) do not expose a temperature slider or flag. This guide covers what temperature does, how to set it in the API, recommended values for different tasks, and alternative sampling parameters.

## What Temperature Does

Temperature controls the randomness of the model's output. It modifies the probability distribution that Claude uses to select each token (word or word-piece) in its response.

### Technical Explanation

When Claude generates text, it produces a probability distribution over all possible next tokens. Temperature scales these probabilities before sampling:

- **Temperature = 0.0** — The model always picks the highest-probability token. Output is deterministic. Same input produces the same output every time.
- **Temperature = 0.5** — Moderate randomness. High-probability tokens are still favored, but there is some variation between runs.
- **Temperature = 1.0** — Full probability distribution is used as-is. Output is creative and varied. Default for Claude models.
- **Temperature > 1.0** — Not supported by the Anthropic API. The valid range is 0.0 to 1.0.

Mathematically, temperature divides the logits (raw model scores) before the softmax function converts them to probabilities. Lower temperature makes the distribution sharper (concentrated on top choices). Higher temperature makes it flatter (more spread across options).

### Practical Impact

| Temperature | Behavior | Best For |
|-------------|----------|----------|
| 0.0 | Deterministic, consistent | Code generation, factual answers, data extraction |
| 0.1-0.3 | Mostly consistent, slight variation | Technical writing, code review, analysis |
| 0.4-0.6 | Balanced creativity and coherence | General conversation, explanations |
| 0.7-0.9 | Creative, varied responses | Brainstorming, fiction, marketing copy |
| 1.0 | Maximum variety | Creative exploration, poetry, ideation |

<div id="temp-demo" style="background:#1a1a2e;border:1px solid #2a2a3a;border-radius:8px;padding:20px;margin:24px 0;font-family:system-ui,-apple-system,sans-serif;">
<h3 style="color:#6ee7b7;margin:0 0 12px 0;font-size:18px;">Temperature Effect Demo</h3>
<p style="color:#94a3b8;margin:0 0 16px 0;font-size:14px;">Drag the slider to see how temperature affects output style.</p>
<div style="margin-bottom:16px;">
<label style="color:#e2e8f0;font-size:14px;">Temperature: <strong id="temp-val" style="color:#6ee7b7;font-size:20px;">0.5</strong></label>
<input type="range" id="temp-slider" min="0" max="10" value="5" style="width:100%;accent-color:#6ee7b7;" oninput="updateTemp()">
<div style="display:flex;justify-content:space-between;font-size:11px;color:#64748b;margin-top:2px;"><span>0.0 Deterministic</span><span>0.5 Balanced</span><span>1.0 Creative</span></div>
</div>
<div style="margin-bottom:12px;">
<span style="color:#94a3b8;font-size:12px;">PROMPT: "Name a variable that stores a user's email address"</span>
</div>
<div id="temp-outputs" style="background:#0f172a;padding:16px;border-radius:6px;font-family:monospace;font-size:13px;color:#e2e8f0;min-height:100px;"></div>
<div style="margin-top:12px;display:grid;grid-template-columns:1fr 1fr 1fr;gap:8px;text-align:center;">
<div id="temp-meter-det" style="background:#0f172a;padding:8px;border-radius:4px;"><span style="color:#94a3b8;font-size:11px;">CONSISTENCY</span><div id="temp-bar-det" style="height:4px;background:#6ee7b7;border-radius:2px;margin-top:4px;width:50%;transition:width 0.3s;"></div></div>
<div id="temp-meter-var" style="background:#0f172a;padding:8px;border-radius:4px;"><span style="color:#94a3b8;font-size:11px;">VARIETY</span><div id="temp-bar-var" style="height:4px;background:#f472b6;border-radius:2px;margin-top:4px;width:50%;transition:width 0.3s;"></div></div>
<div id="temp-meter-rec" style="background:#0f172a;padding:8px;border-radius:4px;"><span style="color:#94a3b8;font-size:11px;">RECOMMENDED</span><div id="temp-rec" style="color:#6ee7b7;font-size:12px;margin-top:4px;">General</div></div>
</div>
</div>
<script>
var tempEx={0:["user_email","user_email","user_email","All 10 runs: identical output"],1:["user_email","userEmail","user_email","9/10 runs: same output"],2:["user_email","userEmail","email_address","8/10 runs: similar output"],3:["userEmail","email_address","user_email_addr","7/10 runs: minor variations"],4:["user_email","emailAddress","user_email_str","Moderate variation between runs"],5:["userEmail","email_addr","user_mail","Balanced: conventional with variety"],6:["emailOfUser","usr_email","mail_address","Noticeable variation each run"],7:["electronic_mail","userContactEmail","inbox_addr","Creative alternatives appear"],8:["digital_postbox","e_correspondence","user_inbox_handle","Unconventional names emerge"],9:["cyber_pigeon_hole","electronic_letterbox","pixel_mailslot","Highly creative, less conventional"],10:["quantum_letter_vessel","astral_message_beacon","ethereal_post_nexus","Maximum creativity, may be impractical"]};
var tempRec={0:"Code generation, data extraction",1:"Code generation, factual answers",2:"Technical writing, analysis",3:"Code review, documentation",4:"General conversation",5:"Balanced general use",6:"Explanations, tutorials",7:"Brainstorming, content writing",8:"Creative writing, marketing",9:"Fiction, poetry, ideation",10:"Creative exploration only"};
function updateTemp(){var v=parseInt(document.getElementById('temp-slider').value);document.getElementById('temp-val').textContent=(v/10).toFixed(1);var ex=tempEx[v];var html='<div style="color:#94a3b8;font-size:11px;margin-bottom:8px;">SAMPLE OUTPUTS (3 runs):</div>';for(var i=0;i<3;i++){html+='<div style="margin-bottom:4px;"><span style="color:#64748b;">Run '+(i+1)+': </span><span style="color:#4ade80;">'+ex[i]+'</span></div>';}html+='<div style="margin-top:8px;padding-top:8px;border-top:1px solid #334155;color:#94a3b8;font-size:12px;">'+ex[3]+'</div>';document.getElementById('temp-outputs').innerHTML=html;document.getElementById('temp-bar-det').style.width=(100-v*10)+'%';document.getElementById('temp-bar-var').style.width=(v*10)+'%';document.getElementById('temp-rec').textContent=tempRec[v];}
updateTemp();
</script>

## Setting Temperature in the API

### Python SDK

```python
import anthropic

client = anthropic.Anthropic()

# Low temperature for code generation
response = client.messages.create(
    model="claude-sonnet-4-20250514",
    max_tokens=2048,
    temperature=0.0,
    messages=[
        {
            "role": "user",
            "content": "Write a Python function to merge two sorted arrays."
        }
    ],
)

print(response.content[0].text)
```

```python
# High temperature for brainstorming
response = client.messages.create(
    model="claude-sonnet-4-20250514",
    max_tokens=2048,
    temperature=0.9,
    messages=[
        {
            "role": "user",
            "content": "Give me 10 creative names for a productivity app."
        }
    ],
)

print(response.content[0].text)
```

### TypeScript / JavaScript SDK

```typescript
import Anthropic from '@anthropic-ai/sdk';

const client = new Anthropic();

// Deterministic output for data extraction
const response = await client.messages.create({
  model: 'claude-sonnet-4-20250514',
  max_tokens: 1024,
  temperature: 0.0,
  messages: [
    {
      role: 'user',
      content: 'Extract all email addresses from this text: ...',
    },
  ],
});

console.log(response.content[0].text);
```

```typescript
// Creative output for content generation
const creative = await client.messages.create({
  model: 'claude-sonnet-4-20250514',
  max_tokens: 2048,
  temperature: 0.8,
  messages: [
    {
      role: 'user',
      content: 'Write a short story about a robot learning to paint.',
    },
  ],
});

console.log(creative.content[0].text);
```

### cURL (Direct API Call)

```bash
curl https://api.anthropic.com/v1/messages \
  -H "content-type: application/json" \
  -H "x-api-key: $ANTHROPIC_API_KEY" \
  -H "anthropic-version: 2023-06-01" \
  -d '{
    "model": "claude-sonnet-4-20250514",
    "max_tokens": 1024,
    "temperature": 0.0,
    "messages": [
      {
        "role": "user",
        "content": "Explain the CAP theorem in one paragraph."
      }
    ]
  }'
```

### Valid Range

- **Minimum:** 0.0
- **Maximum:** 1.0
- **Default:** 1.0

Values outside this range will return an API error. The API does not support temperatures above 1.0.

## Claude Code and Temperature

### No Direct Temperature Flag

Claude Code does not have a `--temperature` CLI flag. When you run `claude` in the terminal, the temperature is managed internally by the Claude Code client.

### Influencing Output Style via CLAUDE.md

While you cannot set a numeric temperature in Claude Code, you can influence the output style through your CLAUDE.md instructions:

For more deterministic behavior, add to your project's `CLAUDE.md`:

```markdown
# Code Style
- Always produce the most standard, conventional solution
- Avoid creative or unconventional approaches
- Match existing code patterns exactly
- Do not improvise when a standard pattern exists
```

For more creative behavior:

```markdown
# Approach
- Explore multiple solution approaches before picking one
- Consider unconventional or novel solutions
- Propose creative alternatives when the standard approach has drawbacks
```

This is not temperature control — it is prompt engineering. But it achieves a similar practical effect.

### API Provider Mode

If you are using Claude Code with the `--api-key` flag connected to the Anthropic API, the temperature is handled by the Claude Code client. To get true temperature control, build a custom integration using the API directly.

## Recommended Temperatures by Task

### Complete Temperature Reference Table

| Task Type | Temperature | Rationale |
|-----------|-------------|-----------|
| Code generation | 0.0 | Deterministic, conventional solutions |
| Code review | 0.0 | Consistent issue detection across runs |
| Unit test generation | 0.0 | Reliable test structure and assertions |
| Bug fix suggestions | 0.0-0.1 | Accuracy over creativity |
| Data extraction (JSON, CSV) | 0.0 | Exact schema adherence |
| SQL query generation | 0.0 | Correctness-critical |
| Translation | 0.0-0.1 | Fidelity to source material |
| Summarization | 0.0-0.2 | Stays close to source, no embellishment |
| API documentation | 0.1-0.2 | Natural phrasing with technical accuracy |
| Technical writing | 0.1-0.2 | Slight variation for readability |
| Commit message generation | 0.0-0.1 | Concise and factual |
| Error message writing | 0.1-0.2 | Clear, varied phrasing |
| Email drafting (professional) | 0.3-0.5 | Natural tone without randomness |
| General conversation | 0.4-0.6 | Balanced and engaging |
| Explanation / teaching | 0.3-0.5 | Clear with some variety in examples |
| Product descriptions | 0.5-0.7 | Engaging copy, varied vocabulary |
| Blog post writing | 0.5-0.7 | Natural flow, avoids repetition |
| Marketing copy | 0.6-0.8 | Creative phrasing and hooks |
| Brainstorming / ideation | 0.8-1.0 | Maximum idea diversity |
| Creative writing (fiction) | 0.7-1.0 | Surprising word choices, varied structure |
| Poetry | 0.8-1.0 | Inventive language, unexpected metaphors |
| Name generation (brands, products) | 0.9-1.0 | Maximally diverse suggestions |
| Roleplaying / dialogue | 0.6-0.8 | Character-appropriate variation |
| Alternative solution exploration | 0.5-0.7 | Different approaches per run |

### Code Generation: 0.0

Deterministic output ensures the same correct solution every time. At temperature 0.0, Claude produces the most likely (usually most conventional and correct) code.

```python
response = client.messages.create(
    model="claude-sonnet-4-20250514",
    max_tokens=4096,
    temperature=0.0,
    messages=[{"role": "user", "content": "Implement a binary search tree in Python with insert, delete, and search methods."}],
)
```

### Code Review: 0.0

Consistency matters for code review. You want the same issues flagged every time.

```python
response = client.messages.create(
    model="claude-sonnet-4-20250514",
    max_tokens=4096,
    temperature=0.0,
    messages=[{"role": "user", "content": f"Review this code for bugs and performance issues:\n\n{code}"}],
)
```

### Technical Documentation: 0.1-0.2

Slight variation produces more natural writing while maintaining accuracy.

### Creative Writing: 0.7-1.0

Higher temperatures produce more surprising word choices, varied sentence structures, and creative ideas.

```python
response = client.messages.create(
    model="claude-sonnet-4-20250514",
    max_tokens=4096,
    temperature=0.9,
    messages=[{"role": "user", "content": "Write a poem about debugging at 3 AM."}],
)
```

### Brainstorming and Ideation: 0.8-1.0

Maximum creativity for generating diverse ideas.

### Data Analysis and Extraction: 0.0

Precision is critical when extracting structured data from unstructured text.

### Summarization: 0.0-0.2

Low temperature ensures the summary sticks to the source material without embellishment.

### Translation: 0.0-0.1

Accuracy over creativity for translation tasks.

## Temperature Experiments: Same Prompt, Different Results

To illustrate how temperature affects output, here is the same prompt sent at three different temperatures. The prompt is: "Suggest a variable name for a function that calculates the total price including tax."

**Temperature 0.0** (three runs produce identical output):
```
calculate_total_with_tax
```

**Temperature 0.5** (three runs produce similar but slightly varied output):
```
Run 1: calculate_total_with_tax
Run 2: compute_price_with_tax
Run 3: calculate_total_with_tax
```

**Temperature 1.0** (three runs produce noticeably different output):
```
Run 1: get_taxed_total
Run 2: compute_final_price_after_tax
Run 3: calculate_gross_amount
```

At temperature 0.0, every run returns the same answer. At 0.5, the model occasionally picks a different but equally valid phrasing. At 1.0, every run explores a different part of the vocabulary, which is exactly what you want for brainstorming but not for deterministic code generation.

---

*This configuration is one of 200 production-ready templates in [The Claude Code Playbook](https://zovo.one/pricing). Permission configs, model selection rules, MCP setups — all tested and ready to copy.*

## Alternative Sampling Parameters

Temperature is not the only way to control output randomness. The Anthropic API supports additional parameters.

### top_p (Nucleus Sampling)

`top_p` limits the model to choosing from the smallest set of tokens whose cumulative probability exceeds the specified value.

```python
response = client.messages.create(
    model="claude-sonnet-4-20250514",
    max_tokens=1024,
    top_p=0.9,
    messages=[{"role": "user", "content": "Explain quantum computing."}],
)
```

- **top_p = 1.0** — Consider all tokens (default)
- **top_p = 0.9** — Only consider tokens in the top 90% of cumulative probability
- **top_p = 0.1** — Very restrictive, only the most likely tokens

### top_k

`top_k` limits the model to choosing from only the top K most likely tokens.

```python
response = client.messages.create(
    model="claude-sonnet-4-20250514",
    max_tokens=1024,
    top_k=40,
    messages=[{"role": "user", "content": "List common design patterns."}],
)
```

- **top_k = 1** — Always pick the single most likely token (equivalent to temperature 0)
- **top_k = 40** — Consider the top 40 tokens
- **top_k = -1 or not set** — No limit (default)

### Combining Parameters

You can use temperature together with top_p and top_k:

```python
response = client.messages.create(
    model="claude-sonnet-4-20250514",
    max_tokens=2048,
    temperature=0.7,
    top_p=0.95,
    top_k=50,
    messages=[{"role": "user", "content": "Suggest innovative features for a task management app."}],
)
```

Anthropic recommends either adjusting temperature or top_p, not both simultaneously in most cases. Using both can produce unexpected interactions.

### How Temperature, top_p, and top_k Interact Technically

These three parameters apply in sequence during token sampling:

1. **top_k filter** runs first. If `top_k=40`, the model discards all tokens except the 40 highest-probability ones. The remaining tokens' probabilities are renormalized to sum to 1.0.

2. **top_p filter** runs second. From the surviving tokens, it keeps the smallest set whose cumulative probability exceeds `top_p`. If `top_p=0.9`, it walks down the ranked list until probabilities sum to 0.9, then discards the rest.

3. **Temperature scaling** runs last. The logits of the remaining tokens are divided by the temperature value before the final softmax. Lower temperature sharpens the distribution (the top token gets even more probability), higher temperature flattens it.

This means combining low `top_k` with high temperature can produce strange results: you restrict the candidate pool to a few tokens, then flatten their probabilities, making the model randomly choose among a very small set. Conversely, combining high `top_k` with low temperature effectively ignores the `top_k` because temperature drives the selection toward the top tokens anyway.

**Practical recommendation:** For most applications, adjust temperature alone and leave `top_p` and `top_k` at their defaults. If you need finer control, use `top_p` as a safety ceiling (set it to 0.95 to prevent extremely unlikely tokens from being selected) while using temperature for the primary creativity control. Reserve `top_k` for specialized applications where you need an absolute cap on the candidate pool size.

## Temperature and Model Selection

Different Claude models may behave differently at the same temperature:

- **Claude Opus** — most capable model, temperature 0.0 produces high-quality deterministic output
- **Claude Sonnet** — balanced speed and quality, good across all temperature ranges
- **Claude Haiku** — fastest model, lower temperatures recommended for accuracy-critical tasks

The temperature parameter works identically across all models — the valid range is always 0.0 to 1.0.

## Frequently Asked Questions

### Can I set temperature in Claude.ai?

No. The Claude.ai web interface does not expose a temperature control. Claude.ai uses Anthropic's default settings. To control temperature, use the API directly.

### What is the default temperature for Claude?

The default temperature is 1.0. If you do not specify a temperature in your API call, Claude uses the full probability distribution for sampling.

### Does lower temperature mean better code?

Not necessarily better, but more consistent and conventional. Temperature 0.0 produces the most standard solution, which is usually what you want for production code. But for exploring alternative approaches, a slightly higher temperature (0.2-0.4) can reveal solutions you would not have considered.

### Can I set temperature per-message in a conversation?

Temperature is set per API call, not per message. In a multi-turn conversation, you can change the temperature between calls, but you must include the full conversation history each time.

### Does temperature affect Claude's reasoning quality?

At very high temperatures (0.9-1.0), Claude may occasionally produce less coherent reasoning because the sampling is more random. For tasks requiring careful logical reasoning, lower temperatures (0.0-0.3) generally produce more reliable results.

### Is temperature 0.0 truly deterministic?

Nearly. At temperature 0.0, the API uses greedy decoding (always selecting the highest-probability token). In practice, results are very consistent, though minor variations can occur due to floating-point arithmetic in distributed systems.

### How does temperature interact with system prompts?

Temperature and system prompts are independent controls. A well-crafted system prompt can constrain output style regardless of temperature. Using both together gives you fine-grained control — the system prompt sets the frame, and temperature controls variation within it.

### Should I use temperature or top_p?

For most use cases, temperature is simpler and more intuitive. Use top_p when you want to cap the randomness without affecting the relative probabilities of the top tokens. Anthropic's general recommendation is to adjust one or the other, not both.

## Related Guides

- [The Claude Code Playbook](/playbook/) — comprehensive workflow reference
- [Claude Code Best Practices](/claude-code-claude-md-best-practices/) — optimize your setup
- [Claude Code Configuration Hierarchy](/claude-code-configuration-hierarchy-explained-2026/) — understand settings files
- [Claude Upload Limit Guide](/claude-upload-limit-guide/) — file size and type limits
- [Claude Code Token Usage Optimization](/claude-code-token-usage-optimization-best-practices-guide/) — manage costs
- [Claude Code REST API Design](/claude-code-rest-api-design-best-practices/) — API integration patterns
- [Claude Code Getting Started](/claude-code-getting-started-terminal-setup/) — initial CLI setup
- [Best MCP Servers for Claude Code](/best-mcp-servers-for-claude-code-2026/) — extend capabilities
- [Claude Code Save Conversation Guide](/claude-code-save-conversation-guide/) — session management

- [Claude Sonnet 4.5 model guide](/claude-sonnet-4-5-20250929-model-guide/) — Sonnet 4.5 default temperature behavior
- [Claude Sonnet 4 model guide](/claude-sonnet-4-20250514-model-guide/) — Sonnet 4 default temperature behavior
### Can I set different temperatures for different parts of the same request?

No. Temperature applies to the entire API response. You cannot set different temperatures for different sections of the output within a single API call.

### Does temperature affect the speed of response generation?

No. Temperature only affects the probability distribution used for token selection. Response generation speed is determined by the model, input length, and output length, not by the temperature setting.

<script type="application/ld+json">
{
  "@context": "https://schema.org",
  "@type": "FAQPage",
  "mainEntity": [
    {"@type": "Question", "name": "Can I set temperature in Claude.ai?", "acceptedAnswer": {"@type": "Answer", "text": "No. The Claude.ai web interface does not expose a temperature control. Claude.ai uses Anthropic's default settings. To control temperature, use the API directly."}},
    {"@type": "Question", "name": "What is the default temperature for Claude?", "acceptedAnswer": {"@type": "Answer", "text": "The default temperature is 1.0. If you do not specify a temperature in your API call, Claude uses the full probability distribution for sampling."}},
    {"@type": "Question", "name": "Does lower temperature mean better code?", "acceptedAnswer": {"@type": "Answer", "text": "Not necessarily better, but more consistent and conventional. Temperature 0.0 produces the most standard solution. For exploring alternatives, a slightly higher temperature can reveal solutions you would not have considered."}},
    {"@type": "Question", "name": "Can I set temperature per-message in a conversation?", "acceptedAnswer": {"@type": "Answer", "text": "Temperature is set per API call, not per message. In a multi-turn conversation, you can change the temperature between calls, but you must include the full conversation history each time."}},
    {"@type": "Question", "name": "Does temperature affect Claude's reasoning quality?", "acceptedAnswer": {"@type": "Answer", "text": "At very high temperatures (0.9-1.0), Claude may occasionally produce less coherent reasoning. For tasks requiring careful logical reasoning, lower temperatures generally produce more reliable results."}},
    {"@type": "Question", "name": "Is temperature 0.0 truly deterministic?", "acceptedAnswer": {"@type": "Answer", "text": "Nearly. At temperature 0.0, the API uses greedy decoding. In practice, results are very consistent, though minor variations can occur due to floating-point arithmetic in distributed systems."}},
    {"@type": "Question", "name": "How does temperature interact with system prompts?", "acceptedAnswer": {"@type": "Answer", "text": "Temperature and system prompts are independent controls. A well-crafted system prompt can constrain output style regardless of temperature. Using both together gives you fine-grained control."}},
    {"@type": "Question", "name": "Should I use temperature or top_p?", "acceptedAnswer": {"@type": "Answer", "text": "For most use cases, temperature is simpler and more intuitive. Anthropic's general recommendation is to adjust one or the other, not both."}},
    {"@type": "Question", "name": "Can I set different temperatures for different parts of the same request?", "acceptedAnswer": {"@type": "Answer", "text": "No. Temperature applies to the entire API response. You cannot set different temperatures for different sections of the output within a single API call."}},
    {"@type": "Question", "name": "Does temperature affect the speed of response generation?", "acceptedAnswer": {"@type": "Answer", "text": "No. Temperature only affects the probability distribution used for token selection. Response generation speed is determined by the model, input length, and output length."}}
  ]
}
</script>
