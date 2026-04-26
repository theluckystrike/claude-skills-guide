---
layout: default
title: "Chunking Strategies to Cut Claude (2026)"
description: "Split documents into chunks and send only relevant pieces to Claude — reduce 500K context to 30K and save $70.50 per 50 Opus requests."
date: 2026-04-19
author: "Claude Skills Guide"
permalink: /chunking-strategies-cut-claude-context-costs/
reviewed: true
score: 8
categories: [cost-optimization]
tags: [claude, cost-reduction]
---

# Chunking Strategies to Cut Claude Context Costs

Sending an entire 500K-token codebase to Claude Opus 4.7 costs $2.50 per request. Chunking the codebase and sending only the relevant 30K tokens costs $0.15 per request — a 94% reduction. Over 50 code review requests per day, that is $117.50/day saved, or $3,525/month.

## The Setup

Chunking divides large documents or codebases into smaller segments. Instead of loading everything into Claude's context, you select the relevant chunks based on the query and send only those. The result is dramatically smaller context with equivalent answer quality for most queries.

The challenge is choosing the right chunking strategy. Too coarse and you miss relevant information. Too fine and you fragment context that Claude needs to see together. This guide covers four chunking strategies optimized for cost reduction in Claude API workflows.

## The Math

**Scenario: Code review pipeline processing 50 requests/day, Opus 4.7**

**Without chunking (full codebase per request):**
- Input: 500K tokens * $5.00/MTok = $2.50/request
- Output: 3K tokens * $25.00/MTok = $0.075/request
- Daily: 50 * $2.575 = $128.75
- **Monthly: $3,862.50**

**With chunking (relevant files only):**
- Input: 30K tokens * $5.00/MTok = $0.15/request
- Output: 3K tokens * $25.00/MTok = $0.075/request
- Daily: 50 * $0.225 = $11.25
- **Monthly: $337.50**

**Savings: $3,525/month (91%)**

Even moderate chunking (100K instead of 500K):
- Monthly: $1,125 -> **Savings: $2,737.50 (71%)**

## The Technique

### Strategy 1: File-Level Chunking for Codebases

```python
import os
from pathlib import Path
from typing import Optional

def chunk_codebase_by_file(
    root_dir: str,
    extensions: list = None,
    max_file_size: int = 50000,
) -> list:
    """Chunk a codebase into individual files."""
    if extensions is None:
        extensions = [".py", ".ts", ".js", ".go", ".rs", ".java"]

    chunks = []
    root = Path(root_dir)

    for ext in extensions:
        for filepath in root.rglob(f"*{ext}"):
            # Skip node_modules, venv, etc.
            if any(skip in str(filepath) for skip in ["node_modules", "venv", ".git", "__pycache__"]):
                continue

            content = filepath.read_text(errors="ignore")
            char_count = len(content)

            if char_count > max_file_size:
                # Split large files by function/class
                sub_chunks = split_by_function(content, str(filepath))
                chunks.extend(sub_chunks)
            else:
                chunks.append({
                    "path": str(filepath.relative_to(root)),
                    "content": content,
                    "tokens_est": char_count // 4,
                    "type": "file",
                })

    return chunks

def split_by_function(content: str, filepath: str) -> list:
    """Split a large file into function-level chunks."""
    chunks = []
    lines = content.split("\n")
    current_chunk = []
    current_name = filepath

    for line in lines:
        stripped = line.strip()
        if stripped.startswith(("def ", "class ", "async def ", "function ")):
            if current_chunk:
                chunk_text = "\n".join(current_chunk)
                chunks.append({
                    "path": current_name,
                    "content": chunk_text,
                    "tokens_est": len(chunk_text) // 4,
                    "type": "function",
                })
            current_chunk = [line]
            current_name = f"{filepath}::{stripped.split('(')[0].split()[-1]}"
        else:
            current_chunk.append(line)

    if current_chunk:
        chunk_text = "\n".join(current_chunk)
        chunks.append({
            "path": current_name,
            "content": chunk_text,
            "tokens_est": len(chunk_text) // 4,
            "type": "function",
        })

    return chunks
```

### Strategy 2: Semantic Chunking for Documents

```python
def chunk_document_semantic(
    text: str,
    target_chunk_size: int = 1000,
    overlap: int = 100,
) -> list:
    """Chunk document by semantic boundaries (paragraphs, sections)."""
    # Split by section headers first
    sections = []
    current_section = {"title": "", "content": ""}

    for line in text.split("\n"):
        if line.startswith("#") or (line.strip() and line.strip().isupper() and len(line) < 100):
            if current_section["content"].strip():
                sections.append(current_section)
            current_section = {"title": line.strip(), "content": ""}
        else:
            current_section["content"] += line + "\n"

    if current_section["content"].strip():
        sections.append(current_section)

    # Split oversized sections into paragraph-level chunks
    chunks = []
    for section in sections:
        words = section["content"].split()
        if len(words) <= target_chunk_size:
            chunks.append({
                "title": section["title"],
                "content": section["content"].strip(),
                "tokens_est": len(words) * 2,
            })
        else:
            # Split by paragraphs
            paragraphs = section["content"].split("\n\n")
            current_chunk_words = []
            for para in paragraphs:
                para_words = para.split()
                if len(current_chunk_words) + len(para_words) > target_chunk_size:
                    chunks.append({
                        "title": section["title"],
                        "content": " ".join(current_chunk_words),
                        "tokens_est": len(current_chunk_words) * 2,
                    })
                    # Overlap: keep last N words
                    current_chunk_words = current_chunk_words[-overlap:] + para_words
                else:
                    current_chunk_words.extend(para_words)

            if current_chunk_words:
                chunks.append({
                    "title": section["title"],
                    "content": " ".join(current_chunk_words),
                    "tokens_est": len(current_chunk_words) * 2,
                })

    return chunks
```

### Strategy 3: Relevance-Based Chunk Selection

```python
import anthropic

client = anthropic.Anthropic()

def select_relevant_chunks(
    query: str,
    chunks: list,
    max_tokens: int = 30000,
) -> list:
    """Select the most relevant chunks within a token budget."""
    # Score chunks by keyword overlap (replace with embeddings in production)
    query_words = set(query.lower().split())

    scored_chunks = []
    for chunk in chunks:
        content_words = set(chunk["content"].lower().split())
        overlap = len(query_words & content_words)
        path_match = any(qw in chunk.get("path", "").lower() for qw in query_words)
        score = overlap + (5 if path_match else 0)
        scored_chunks.append((score, chunk))

    scored_chunks.sort(reverse=True, key=lambda x: x[0])

    # Select chunks within token budget
    selected = []
    total_tokens = 0
    for score, chunk in scored_chunks:
        if total_tokens + chunk["tokens_est"] > max_tokens:
            break
        selected.append(chunk)
        total_tokens += chunk["tokens_est"]

    return selected

def chunked_query(
    query: str,
    chunks: list,
    model: str = "claude-sonnet-4-6",
    max_context_tokens: int = 30000,
) -> dict:
    """Query Claude with only the relevant chunks."""
    relevant = select_relevant_chunks(query, chunks, max_context_tokens)

    context = "\n\n---\n\n".join(
        f"File: {c.get('path', c.get('title', 'unknown'))}\n{c['content']}"
        for c in relevant
    )

    response = client.messages.create(
        model=model,
        max_tokens=4096,
        system="Answer based on the provided code/document context. Reference specific files and line numbers.",
        messages=[{
            "role": "user",
            "content": f"Context:\n{context}\n\nQuestion: {query}",
        }],
    )

    return {
        "answer": response.content[0].text,
        "chunks_used": len(relevant),
        "context_tokens": response.usage.input_tokens,
        "full_codebase_tokens": sum(c["tokens_est"] for c in chunks),
        "reduction": f"{(1 - sum(c['tokens_est'] for c in relevant) / max(sum(c['tokens_est'] for c in chunks), 1)) * 100:.0f}%",
    }
```

### Strategy 4: Sliding Window for Sequential Processing

```python
def sliding_window_process(
    chunks: list,
    instruction: str,
    window_size: int = 5,
    model: str = "claude-haiku-4-5-20251001",
) -> list:
    """Process chunks in a sliding window for large document analysis."""
    results = []
    for i in range(0, len(chunks), window_size):
        window = chunks[i:i + window_size]
        context = "\n\n".join(c["content"] for c in window)

        response = client.messages.create(
            model=model,
            max_tokens=1024,
            system=instruction,
            messages=[{"role": "user", "content": context}],
        )
        results.append({
            "window": f"{i}-{i + len(window)}",
            "result": response.content[0].text,
        })

    return results
```

## The Tradeoffs

Chunking adds a retrieval step that can miss relevant context. If the answer requires information spread across multiple distant chunks, simple keyword-based retrieval may fail. Production systems should use embedding-based retrieval for better recall.

Fine-grained chunking (function-level) provides better precision but more chunks to manage. Coarse chunking (file-level) is simpler but may include irrelevant code.

The chunking and retrieval overhead adds latency (10-100ms) and infrastructure cost (embedding model, vector database). For low-volume applications under 50 requests/day, the infrastructure cost may exceed the context savings.

## Implementation Checklist

1. Chunk your codebase or documents using file-level strategy
2. Implement keyword-based chunk selection for a first pass
3. Test answer quality on 50 representative queries
4. Measure context size reduction and cost savings
5. Upgrade to embedding-based retrieval if keyword matching shows gaps
6. Set a context budget per request type
7. Monitor chunk retrieval recall weekly

## Measuring Impact

Compare average context size per request before and after implementing chunking. Track the answer quality score alongside cost reduction. Target: 80-95% context reduction with less than 5% quality degradation. Calculate ROI by dividing monthly savings by the engineering time invested in building the chunking pipeline.



**Which model? →** Take the 5-question quiz in our [Model Selector](/model-selector/).

## Related Guides

**Try it:** Estimate your monthly spend with our [Cost Calculator](/calculator/).

- [Why Is Claude Code Expensive](/why-is-claude-code-expensive-large-context-tokens/) — context size as the main cost driver
- [Claude Code Context Window Management Guide](/claude-code-context-window-management-guide/) — broader context management strategies
- [Why Does Anthropic Limit Claude Code Context Window](/why-does-anthropic-limit-claude-code-context-window/) — understanding context design decisions

## Related Articles

- [System Prompt Optimization to Cut Claude Costs](/system-prompt-optimization-cut-claude-costs/)
- [Shrink Claude Context Without Losing Quality](/shrink-claude-context-without-losing-quality/)
- [System Prompt Optimization to Cut Claude Costs](/system-prompt-optimization-cut-claude-costs/)
- [Model Routing by Task Cuts Claude API Bills](/model-routing-cut-claude-api-bills/)
- [When Full Context Costs More Than a RAG Pipeline](/when-full-context-costs-more-than-rag/)
