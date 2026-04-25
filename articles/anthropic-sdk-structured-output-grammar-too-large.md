---
layout: default
title: "Fix: Anthropic SDK Grammar Too Large"
description: "Claude Code troubleshooting: fix the Anthropic API 'compiled grammar is too large' 400 error when using structured outputs with complex JSON schemas...."
date: 2026-04-14
last_modified_at: 2026-04-17
author: "Claude Code Guides"
permalink: /anthropic-sdk-structured-output-grammar-too-large/
reviewed: true
categories: [troubleshooting]
tags: [anthropic-sdk, python, error, troubleshooting, api, structured-output]
geo_optimized: true
last_tested: "2026-04-22"
---
# Fix: 'Compiled Grammar Is Too Large' Anthropic Error

## The Error

```
400 {"type":"error","error":{"type":"invalid_request_error",
"message":"The compiled grammar is too large, which would cause performance
issues. Simplify your tool schemas or reduce the number of strict tools."},
"request_id":"req_011CYFKFQUW16kvBsXKy4JSr"}
```

This occurs when using `output_config.format` with `json_schema` or `strict: true` tools with moderately complex schemas.

## Quick Fix

Reduce schema complexity by extracting repeated sub-schemas and limiting nullable types:

```python
# BEFORE: Repeated sub-schema (triggers grammar explosion)
schema = {
 "type": "object",
 "properties": {
 "mapper1_input": { "$ref": "#/$defs/TypeSchema" },
 "mapper1_output": { "$ref": "#/$defs/TypeSchema" },
 "mapper2_input": { "$ref": "#/$defs/TypeSchema" },
 "mapper2_output": { "$ref": "#/$defs/TypeSchema" },
 }
}

# AFTER: Flatten and simplify
schema = {
 "type": "object",
 "properties": {
 "mappers": {
 "type": "array",
 "items": {
 "type": "object",
 "properties": {
 "name": {"type": "string"},
 "input_type": {"type": "string"},
 "output_type": {"type": "string"}
 },
 "required": ["name", "input_type", "output_type"],
 "additionalProperties": False
 }
 }
 }
}
```

## What's Happening

When you use structured outputs (`output_config.format` with `json_schema`) or `strict: true` tools, the API compiles a **constrained decoding grammar** from your JSON Schema. This grammar is a finite-state automaton that guarantees the model's output is valid JSON matching your schema.

Three factors cause the grammar to explode beyond the internal size limit:

### 1. Nullable Types Create Grammar Branching

Each `"type": ["number", "null"]` compiles to an `anyOf` branch in the automaton. With 12 nullable fields per sub-schema and 4 instances, that is ~48 branching points causing exponential state growth.

```json
// Each of these creates a branch:
"minimum": { "type": ["number", "null"] },
"maximum": { "type": ["number", "null"] },
"minLength": { "type": ["number", "null"] },
"maxLength": { "type": ["number", "null"] },
"pattern": { "type": ["string", "null"] }
```

### 2. Repeated Sub-Schemas Are Expanded Inline

Even though `$ref` and `$defs` are listed as supported features, the grammar compiler expands everything inline rather than reusing grammar rules for shared definitions. Using `$defs`/`$ref` does not reduce compiled grammar size.

A schema with the same `TypeWithSchema` object inlined 4 times per mapper and 2 times per reducer means the grammar contains 6 copies of every sub-schema's states and transitions.

### 3. Deep Nesting Multiplies Complexity

The path `schema -> mappers[] -> TypeWithSchema -> fields[] -> TypeFieldDefinition -> constraints{}` creates 5 levels of nesting. Each level has its own object with multiple properties, and the grammar states compound multiplicatively at each level.

**Approximate grammar size calculation:**

```
Base schema: ~20 states
Per nullable field: 2x branching
Per repeated sub-schema: full duplication (no sharing)
Per nesting level: multiplicative compounding

With 48 nullable fields, 6 sub-schema copies, 5 nesting levels:
Estimated states: 20 * 2^48 (theoretical) -> practically hits limit
```

## Step-by-Step Solution

### Strategy 1: Eliminate Nullable Types

Replace `"type": ["number", "null"]` with non-nullable types and use sentinel values:

```python
# BEFORE: Nullable (causes grammar branching)
{
 "minimum": {"type": ["number", "null"]},
 "maximum": {"type": ["number", "null"]},
 "pattern": {"type": ["string", "null"]}
}

# AFTER: Non-nullable with sentinels
{
 "minimum": {"type": "number"}, # Use -1 as sentinel for "not set"
 "maximum": {"type": "number"}, # Use -1 as sentinel for "not set"
 "pattern": {"type": "string"} # Use "" as sentinel for "not set"
}
```

### Strategy 2: Flatten Nested Structures

Encode complex inner types as JSON strings:

```python
# BEFORE: Deep nesting
{
 "mappers": {
 "type": "array",
 "items": {
 "type": "object",
 "properties": {
 "inputType": { /* complex TypeWithSchema */ },
 "outputType": { /* complex TypeWithSchema */ }
 }
 }
 }
}

# AFTER: Flat with string-encoded inner types
{
 "mappers": {
 "type": "array",
 "items": {
 "type": "object",
 "properties": {
 "name": {"type": "string"},
 "input_type_json": {"type": "string"},
 "output_type_json": {"type": "string"}
 },
 "required": ["name", "input_type_json", "output_type_json"],
 "additionalProperties": False
 }
 }
}
```

Then parse the JSON strings yourself:

```python
import json

for mapper in result["mappers"]:
 input_type = json.loads(mapper["input_type_json"])
 output_type = json.loads(mapper["output_type_json"])
```

### Strategy 3: Two-Pass Generation

Split into a simple structured output pass and a detailed follow-up:

```python
from anthropic import Anthropic

client = Anthropic()

# Pass 1: Get the high-level structure (simple schema, strict)
simple_schema = {
 "type": "object",
 "properties": {
 "description": {"type": "string"},
 "mapper_names": {
 "type": "array",
 "items": {"type": "string"}
 }
 },
 "required": ["description", "mapper_names"],
 "additionalProperties": False
}

overview = client.messages.create(
 model="claude-sonnet-4-5-20250929",
 max_tokens=2000,
 messages=[{"role": "user", "content": prompt}],
 output_config={"format": {"type": "json_schema", "schema": simple_schema}}
)

# Pass 2: Get details for each mapper (simple per-item schema, strict)
for mapper_name in json.loads(overview.content[0].text)["mapper_names"]:
 detail = client.messages.create(
 model="claude-sonnet-4-5-20250929",
 max_tokens=2000,
 messages=[{
 "role": "user",
 "content": f"Give me the full definition for mapper '{mapper_name}'"
 }],
 output_config={"format": {"type": "json_schema", "schema": mapper_detail_schema}}
 )
```

### Strategy 4: Use Non-Strict Mode with Validation

```python
from pydantic import BaseModel, ValidationError
from typing import Optional

class TypeSchema(BaseModel):
 type_name: str
 type_kind: str
 fields: Optional[list[dict]] = None
 constraints: Optional[dict] = None

class MapperDefinition(BaseModel):
 name: str
 description: str
 input_type: TypeSchema
 output_type: TypeSchema

class GenerationResult(BaseModel):
 description: str
 mappers: list[MapperDefinition]

# Use non-strict mode
response = client.messages.create(
 model="claude-sonnet-4-5-20250929",
 max_tokens=4000,
 messages=[{"role": "user", "content": prompt}],
 # No output_config — let the model generate freely
)

# Validate with Pydantic
try:
 result = GenerationResult.model_validate_json(response.content[0].text)
except ValidationError as e:
 print(f"Validation failed: {e}")
 # Retry or fall back
```

## Prevention

- **Count nullable fields**: each one doubles grammar complexity. Keep under 10 nullable fields per schema
- **Avoid repeating sub-schemas**: use flat structures or string-encoded JSON for repeated types
- **Limit nesting to 3 levels**: flatten anything deeper
- **Test incrementally**: add schema properties one at a time, testing after each addition
- **Use Pydantic validation as primary**: structured outputs are a convenience, not a requirement

---

---

<div class="mastery-cta">

I'm a solo developer in Vietnam. 50K Chrome extension users. $500K+ on Upwork. 5 Claude Max subscriptions running agent fleets in parallel.

These are my actual CLAUDE.md templates, orchestration configs, and prompts. Not a course. Not theory. The files I copy into every project before I write a line of code.

**[See what's inside →](https://zovo.one/lifetime?utm_source=ccg&utm_medium=cta-default&utm_campaign=anthropic-sdk-structured-output-grammar-too-large)**

$99 once. Free forever. 47/500 founding spots left.

</div>

## Related Issues

- [Fix: Anthropic API 500 Error with strict: true](/anthropic-sdk-strict-true-500-error)
- [Anthropic SDK Structured Output Thinking Tool Use Bug](/anthropic-sdk-structured-output-thinking-tool-use-bug/)
- [Fix: Claude API Error 400 Invalid Request](/claude-api-error-400-invalidrequesterror-explained/)

## Tools That Help

For developers building complex API integrations with structured outputs, a dev tool extension can help inspect and debug JSON Schema compilation issues by visualizing the schema structure.

## See Also

- [Anthropic SDK Python Async Context Manager — Fix (2026)](/anthropic-sdk-python-async-context-manager-error-fix/)
- [Anthropic SDK TypeScript Tool Results Type Error — Fix (2026)](/anthropic-sdk-typescript-type-mismatch-tool-results-fix/)
- [Anthropic SDK Streaming Connection Dropped — Fix (2026)](/anthropic-sdk-streaming-connection-dropped-fix/)
