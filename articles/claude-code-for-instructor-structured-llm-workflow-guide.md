---
layout: default
title: "Claude Code for Instructor Structured"
description: "Claude Code for Instructor Structured — practical guide with working examples, tested configurations, and tips for developer workflows."
date: 2026-04-18
permalink: /claude-code-for-instructor-structured-llm-workflow-guide/
categories: [workflow, niche-tools]
tags: [claude-code, instructor, workflow]
---

## The Setup

You are extracting structured data from LLMs with Instructor, a Python library that patches the OpenAI SDK to return validated Pydantic models instead of raw text. Instructor handles retries, validation, and streaming of structured output. Claude Code can work with LLM APIs, but it parses JSON from raw text responses instead of using Instructor's validated approach.

## What Claude Code Gets Wrong By Default

1. **Parses JSON from raw text.** Claude writes `json.loads(response.choices[0].message.content)` and hopes the LLM returns valid JSON. Instructor guarantees valid, typed output by using function calling and Pydantic validation.

2. **Writes regex extraction patterns.** Claude uses regex to extract data from LLM text responses. Instructor returns Pydantic models directly — no regex, no string parsing, no hope-based extraction.

3. **Creates retry logic manually.** Claude wraps LLM calls in try/except with manual retries on invalid JSON. Instructor has built-in `max_retries` with automatic re-prompting when validation fails — it tells the LLM what went wrong and asks again.

4. **Ignores Pydantic validation.** Claude accepts any JSON structure without validation. Instructor validates against Pydantic models with type checking, field constraints, and custom validators — invalid data triggers automatic retries.

## The CLAUDE.md Configuration

```
# Instructor Structured LLM Project

## AI
- Library: Instructor (structured LLM output)
- Validation: Pydantic models for response schema
- Retries: automatic with validation error feedback
- Streaming: partial model streaming support

## Instructor Rules
- Patch: client = instructor.from_openai(OpenAI())
- Model: Pydantic BaseModel for response schema
- Call: client.chat.completions.create(response_model=Model)
- Retries: max_retries=3 for automatic retry on invalid
- Streaming: response_model=Partial[Model] for streaming
- Validation: Pydantic validators and Field constraints
- Multi: response_model=Iterable[Model] for lists

## Conventions
- Define Pydantic model per extraction task
- Use Field(description="...") for LLM guidance
- Validators for business logic constraints
- max_retries=3 for production reliability
- Use Partial[Model] for streaming partial results
- Iterable[Model] for extracting lists
- Keep models focused — one per extraction task
```

## Workflow Example

You want to extract structured product information from unstructured text descriptions. Prompt Claude Code:

"Create an Instructor-based extractor that takes product descriptions and returns structured data with name, price (validated as positive float), category (enum), features (list), and availability (boolean). Add retries and proper Pydantic validation."

Claude Code should define a Pydantic `Product` model with typed fields, `Field(description=...)` for LLM guidance, a custom validator ensuring price is positive, a `Category` enum for valid categories, patch the OpenAI client with `instructor.from_openai()`, and call with `response_model=Product, max_retries=3`.

## Common Pitfalls

1. **Model too complex for the LLM.** Claude defines deeply nested Pydantic models with many fields. Complex schemas increase the chance of validation failures and retries. Keep models flat and focused — split complex extractions into multiple calls.

2. **Missing field descriptions.** Claude defines fields without `Field(description="...")`. The description guides the LLM on what to extract — without descriptions, the LLM guesses based on field names alone, leading to incorrect extractions.

3. **Not handling partial failures.** Claude assumes all fields will always be extracted. Some fields may be missing from the source text. Use `Optional[str]` for fields that might not be present and `default=None` for optional values.

## Related Guides

- [Claude Code for LangChain Framework Workflow Guide](/claude-code-for-langchain-framework-workflow-guide/)
- [Claude Code for Groq Inference Workflow Guide](/claude-code-for-groq-inference-workflow-guide/)
- [Best AI Tools for Backend Development 2026](/best-ai-tools-for-backend-development-2026/)

## See Also

- [Claude Code for Promptfoo — Workflow Guide](/claude-code-for-promptfoo-llm-eval-workflow-guide/)


## Common Questions

### How do I get started with claude code for instructor structured?

Begin with the setup instructions in this guide. Install the required dependencies, configure your environment, and test with a small project before scaling to your full codebase.

### What are the prerequisites?

You need a working development environment with Node.js or Python installed. Familiarity with the command line and basic Git operations is helpful. No advanced AI knowledge is required.

### Can I use this with my existing development workflow?

Yes. These techniques integrate with standard development tools and CI/CD pipelines. Start by adding them to a single project and expand once you have verified the benefits.

### Where can I find more advanced techniques?

Explore the related resources below for deeper coverage. The Claude Code documentation and community forums also provide advanced patterns and real-world case studies.

## Related Resources

- [Claude Code Structured Logging](/claude-code-structured-logging-best-practices-workflow/)
- [Claude Code Announcements 2026](/anthropic-claude-code-announcements-2026/)
- [Fix Stream Idle Timeout in Claude Code](/anthropic-sdk-streaming-hang-timeout/)
