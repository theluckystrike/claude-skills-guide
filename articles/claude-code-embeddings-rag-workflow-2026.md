---
layout: post
title: "Claude Code Embeddings and RAG Workflow (2026)"
description: "Build RAG pipelines with Claude Code: generate embeddings, create vector stores, and implement retrieval-augmented generation for codebases."
permalink: /claude-code-embeddings-rag-workflow-2026/
date: 2026-04-21
last_tested: "2026-04-21"
---

## The Workflow

Build a retrieval-augmented generation (RAG) pipeline using Claude Code to make large codebases queryable. This workflow indexes source code into vector embeddings, stores them in a local vector database, and retrieves relevant context before prompting Claude for answers.

Expected time: 30-60 minutes for initial setup and indexing
Prerequisites: Claude Code installed, Python 3.10+, a codebase to index (any language)

## Setup

### 1. Install Dependencies

```bash
pip install chromadb sentence-transformers tiktoken
```

ChromaDB provides the local vector store. sentence-transformers generates embeddings without API costs.

### 2. Create the Indexing Script

```bash
mkdir -p ~/rag-pipeline && cat > ~/rag-pipeline/index_codebase.py << 'EOF'
#!/usr/bin/env python3
"""Index a codebase into ChromaDB for RAG retrieval."""

import os
import hashlib
from pathlib import Path
from typing import Generator

import chromadb
from chromadb.config import Settings
from sentence_transformers import SentenceTransformer

# Configuration
CHUNK_SIZE = 512  # tokens per chunk
CHUNK_OVERLAP = 64
EXTENSIONS = {'.py', '.ts', '.js', '.rs', '.go', '.java', '.rb', '.md'}
IGNORE_DIRS = {'node_modules', '.git', 'dist', 'build', 'venv', '__pycache__'}

model = SentenceTransformer('all-MiniLM-L6-v2')


def chunk_file(filepath: Path, chunk_size: int = CHUNK_SIZE) -> Generator:
    """Split a file into overlapping chunks with metadata."""
    try:
        content = filepath.read_text(encoding='utf-8', errors='ignore')
    except (PermissionError, OSError):
        return

    lines = content.split('\n')
    current_chunk = []
    current_length = 0

    for i, line in enumerate(lines):
        line_tokens = len(line) // 4  # rough estimate
        if current_length + line_tokens > chunk_size and current_chunk:
            yield {
                'content': '\n'.join(current_chunk),
                'file': str(filepath),
                'start_line': i - len(current_chunk) + 1,
                'end_line': i,
            }
            # Keep overlap
            overlap_lines = current_chunk[-3:]
            current_chunk = overlap_lines
            current_length = sum(len(l) // 4 for l in overlap_lines)

        current_chunk.append(line)
        current_length += line_tokens

    if current_chunk:
        yield {
            'content': '\n'.join(current_chunk),
            'file': str(filepath),
            'start_line': len(lines) - len(current_chunk) + 1,
            'end_line': len(lines),
        }


def index_directory(project_path: str, collection_name: str = 'codebase'):
    """Index all source files in a directory."""
    project = Path(project_path).resolve()
    db_path = str(project / '.rag-index')

    client = chromadb.PersistentClient(path=db_path)

    # Delete existing collection to reindex
    try:
        client.delete_collection(collection_name)
    except ValueError:
        pass

    collection = client.create_collection(
        name=collection_name,
        metadata={'hnsw:space': 'cosine'}
    )

    documents = []
    metadatas = []
    ids = []

    for root, dirs, files in os.walk(project):
        dirs[:] = [d for d in dirs if d not in IGNORE_DIRS]

        for fname in files:
            fpath = Path(root) / fname
            if fpath.suffix not in EXTENSIONS:
                continue

            for chunk in chunk_file(fpath):
                doc_id = hashlib.md5(
                    f"{chunk['file']}:{chunk['start_line']}".encode()
                ).hexdigest()

                documents.append(chunk['content'])
                metadatas.append({
                    'file': str(fpath.relative_to(project)),
                    'start_line': chunk['start_line'],
                    'end_line': chunk['end_line'],
                })
                ids.append(doc_id)

    # Batch insert (ChromaDB limit: 5461 per batch)
    batch_size = 5000
    for i in range(0, len(documents), batch_size):
        batch_docs = documents[i:i + batch_size]
        batch_meta = metadatas[i:i + batch_size]
        batch_ids = ids[i:i + batch_size]

        embeddings = model.encode(batch_docs).tolist()

        collection.add(
            documents=batch_docs,
            embeddings=embeddings,
            metadatas=batch_meta,
            ids=batch_ids,
        )

    print(f"Indexed {len(documents)} chunks from {project}")
    print(f"Database stored at: {db_path}")
    return len(documents)


if __name__ == '__main__':
    import sys
    path = sys.argv[1] if len(sys.argv) > 1 else '.'
    index_directory(path)
EOF
chmod +x ~/rag-pipeline/index_codebase.py
```

### 3. Index Your Project

```bash
python ~/rag-pipeline/index_codebase.py /path/to/your/project
# Expected output:
# Indexed 847 chunks from /path/to/your/project
# Database stored at: /path/to/your/project/.rag-index
```

## Usage Example

Create a query script that retrieves relevant code and feeds it to Claude:

```python
#!/usr/bin/env python3
"""Query codebase via RAG and pass context to Claude Code."""

import subprocess
import sys
from pathlib import Path

import chromadb
from sentence_transformers import SentenceTransformer

model = SentenceTransformer('all-MiniLM-L6-v2')


def query_codebase(project_path: str, question: str, top_k: int = 5):
    """Retrieve relevant code chunks for a question."""
    db_path = str(Path(project_path).resolve() / '.rag-index')
    client = chromadb.PersistentClient(path=db_path)
    collection = client.get_collection('codebase')

    query_embedding = model.encode([question]).tolist()

    results = collection.query(
        query_embeddings=query_embedding,
        n_results=top_k,
        include=['documents', 'metadatas', 'distances']
    )

    context_parts = []
    for doc, meta, dist in zip(
        results['documents'][0],
        results['metadatas'][0],
        results['distances'][0]
    ):
        relevance = 1 - dist  # cosine distance to similarity
        context_parts.append(
            f"--- {meta['file']} (lines {meta['start_line']}-{meta['end_line']}, "
            f"relevance: {relevance:.2f}) ---\n{doc}"
        )

    return '\n\n'.join(context_parts)


def ask_with_context(project_path: str, question: str):
    """Query RAG then pass context to Claude Code."""
    context = query_codebase(project_path, question)

    prompt = f"""Based on the following code context retrieved from the project:

{context}

Answer this question about the codebase: {question}

Reference specific files and line numbers in your answer."""

    result = subprocess.run(
        ['claude', '--print', prompt],
        capture_output=True, text=True, cwd=project_path
    )
    return result.stdout


if __name__ == '__main__':
    project = sys.argv[1]
    question = ' '.join(sys.argv[2:])
    answer = ask_with_context(project, question)
    print(answer)
```

Run a query:

```bash
python ~/rag-pipeline/query.py /path/to/project "How does authentication work?"
# Claude receives the 5 most relevant code chunks and produces
# a detailed answer referencing specific files and line numbers
```

## Common Issues

- **Indexing is slow on large repos:** The bottleneck is embedding generation. Use a GPU-accelerated machine or index only changed files: `git diff --name-only HEAD~10 | xargs python index_incremental.py`.
- **Results return irrelevant chunks:** Increase `CHUNK_SIZE` to 1024 for better semantic coherence, or switch to a code-specific embedding model like `microsoft/codebert-base`.
- **ChromaDB "too many elements" error:** ChromaDB limits batch inserts to 5461 items. The script handles this with batch_size=5000, but if you hit it, reduce the batch size further.

## Why This Matters

Large codebases exceed Claude's context window. RAG lets you query 100,000+ lines of code accurately by retrieving only the relevant 500 lines as context, eliminating hallucination about code that does not exist.



**Set it up →** Build your permission config with our [Permission Configurator](/permissions/).

## Related Guides

**Estimate tokens →** Calculate your usage with our [Token Estimator](/token-estimator/).

**Try it:** Paste your error into our [Error Diagnostic](/diagnose/) for an instant fix.

- [Claude Code for Embedding Pipeline Workflow](/claude-code-for-embedding-pipeline-workflow/)
- [Context Window Size Drives Claude API Bills](/context-window-size-drives-claude-api-bills/)
- [Automate Source Code Analysis with Claude 2026](/automate-source-code-analysis-claude-2026/)


## Frequently Asked Questions

### What is the minimum setup required?

You need Claude Code installed (Node.js 18+), a project with a `CLAUDE.md` file, and the relevant toolchain for your project type (e.g., npm for JavaScript, pip for Python). The CLAUDE.md file should describe your project structure, conventions, and common commands so Claude Code can work effectively.

### How long does the initial setup take?

For a typical project, initial setup takes 10-20 minutes. This includes creating the CLAUDE.md file, configuring `.claude/settings.json` for permissions, and running a test task to verify everything works. Subsequent sessions start immediately because the configuration persists.

### Can I use this with a team?

Yes. Commit your `.claude/` directory and `CLAUDE.md` to version control so the entire team uses the same configuration. Each developer can add personal preferences in `~/.claude/settings.json` (user-level) without affecting the project configuration. Review CLAUDE.md changes in pull requests like any other configuration file.

### What if Claude Code produces incorrect output?

First check that your CLAUDE.md accurately describes your project conventions. Incorrect or outdated context is the most common cause of wrong output. If the output is still wrong, provide feedback in the same session — Claude Code learns from corrections within a conversation. For persistent issues, add explicit rules to CLAUDE.md (e.g., "Always use single quotes" or "Never modify files in the config/ directory").


## Best Practices

1. **Start with a clear CLAUDE.md.** Describe your project structure, tech stack, coding conventions, and common commands in under 300 words. This single file has the largest impact on Claude Code's accuracy and efficiency.

2. **Use skills for domain knowledge.** Move detailed reference information (API routes, database schemas, deployment procedures) into `.claude/skills/` files. This keeps CLAUDE.md concise while making specialized knowledge available when needed.

3. **Review changes before committing.** Always run `git diff` after Claude Code makes changes. Verify the edits are correct, match your project style, and do not introduce unintended side effects. This habit prevents compounding errors across sessions.

4. **Set up permission guardrails.** Configure `.claude/settings.json` with explicit allow and deny lists. Allow your standard development commands (test, build, lint) and deny destructive operations (rm -rf, git push --force, database drops).

5. **Keep sessions focused.** Give Claude Code one clear task per prompt. Multi-step requests like "refactor auth, add tests, and update docs" produce better results when broken into three separate prompts, each building on the previous result.


<script type="application/ld+json">
{
  "@context": "https://schema.org",
  "@type": "FAQPage",
  "mainEntity": [
    {
      "@type": "Question",
      "name": "What is the minimum setup required?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "You need Claude Code installed (Node.js 18+), a project with a CLAUDE.md file, and the relevant toolchain for your project type (e.g., npm for JavaScript, pip for Python). The CLAUDE.md file should describe your project structure, conventions, and common commands so Claude Code can work effectively."
      }
    },
    {
      "@type": "Question",
      "name": "How long does the initial setup take?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "For a typical project, initial setup takes 10-20 minutes. This includes creating the CLAUDE.md file, configuring .claude/settings.json for permissions, and running a test task to verify everything works. Subsequent sessions start immediately because the configuration persists."
      }
    },
    {
      "@type": "Question",
      "name": "Can I use this with a team?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "Yes. Commit your .claude/ directory and CLAUDE.md to version control so the entire team uses the same configuration. Each developer can add personal preferences in ~/.claude/settings.json (user-level) without affecting the project configuration."
      }
    },
    {
      "@type": "Question",
      "name": "What if Claude Code produces incorrect output?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "First check that your CLAUDE.md accurately describes your project conventions. Incorrect or outdated context is the most common cause of wrong output. If the output is still wrong, provide feedback in the same session — Claude Code learns from corrections within a conversation."
      }
    }
  ]
}
</script>
