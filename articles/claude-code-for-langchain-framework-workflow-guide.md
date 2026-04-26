---
layout: default
title: "Claude Code for LangChain (2026)"
description: "Claude Code for LangChain — practical guide with working examples, tested configurations, and tips for developer workflows."
date: 2026-04-18
permalink: /claude-code-for-langchain-framework-workflow-guide/
categories: [workflow, niche-tools]
tags: [claude-code, langchain, workflow]
---

## The Setup

You are building LLM-powered applications using LangChain, the framework for chaining AI model calls with tools, retrievers, and memory. Claude Code can generate LangChain chains and agents, but it generates outdated API patterns from the rapidly evolving library and mixes up LangChain.js with LangChain Python.

## What Claude Code Gets Wrong By Default

1. **Uses deprecated chain classes.** Claude writes `new LLMChain({ llm, prompt })` which is deprecated. Modern LangChain uses LCEL (LangChain Expression Language): `prompt.pipe(model).pipe(outputParser)`.

2. **Mixes Python and JavaScript APIs.** Claude generates `from langchain import ...` Python imports in a TypeScript project. LangChain.js uses `import { ChatOpenAI } from '@langchain/openai'` — completely different module paths.

3. **Uses the legacy `langchain` package.** Claude imports from `langchain`. LangChain.js has been split: use `@langchain/core`, `@langchain/openai`, `@langchain/anthropic`, etc. The monolithic package is deprecated.

4. **Creates manual prompt templating.** Claude concatenates strings for prompts. LangChain provides `ChatPromptTemplate.fromMessages()` which handles variable substitution, message roles, and type safety.

## The CLAUDE.md Configuration

```
# LangChain Application

## Framework
- LangChain: @langchain/core + provider packages
- Model: @langchain/anthropic (Claude) or @langchain/openai
- Expression: LCEL (pipe-based chain composition)
- Vector store: depends on project (@langchain/pinecone, etc.)

## LangChain Rules
- Use LCEL: prompt.pipe(model).pipe(parser)
- Import from @langchain/core, NOT from 'langchain'
- Models: new ChatAnthropic({ model: 'claude-sonnet-4-20250514' })
- Prompts: ChatPromptTemplate.fromMessages([...])
- Output: StringOutputParser, JsonOutputParser
- Tools: @tool decorator or DynamicTool for function calling
- Retrieval: retriever.pipe(formatDocsFn).pipe(prompt).pipe(model)
- Memory: use RunnableWithMessageHistory for chat memory

## Conventions
- Chains in src/chains/ directory
- Tools in src/tools/ directory
- Prompts in src/prompts/ directory
- Use LCEL pipe syntax, not legacy Chain classes
- Streaming: .stream() for real-time output
- Error handling: .withFallbacks() for model fallback chains
- Never import from 'langchain' directly
```

## Workflow Example

You want to create a RAG (Retrieval-Augmented Generation) chain. Prompt Claude Code:

"Create a LangChain RAG chain that searches a Pinecone vector store for relevant documents, formats them as context, and generates an answer using Claude. Use LCEL pipe syntax and support streaming responses."

Claude Code should create a chain using `retriever.pipe(formatDocs).pipe(ragPrompt).pipe(new ChatAnthropic()).pipe(new StringOutputParser())` with a `ChatPromptTemplate` that includes system message with `{context}` and user message with `{question}`, format retrieved documents into the context variable, and use `.stream()` for the response.

## Common Pitfalls

1. **Importing from wrong package scope.** Claude uses `import { ChatPromptTemplate } from 'langchain/prompts'`. The correct import is `import { ChatPromptTemplate } from '@langchain/core/prompts'`. The scoped packages are required since LangChain's package split.

2. **Not handling streaming correctly.** Claude collects the entire response with `.invoke()`. For chat applications, use `.stream()` which returns an async iterable of chunks. Each chunk is a partial response that can be sent to the client immediately.

3. **Memory management across requests.** Claude creates a new memory instance per request, losing conversation history. Use `RunnableWithMessageHistory` with a session ID-based message store (Redis, database) to persist chat history across requests.

## Related Guides

**Configure permissions →** Build your settings with our [Permission Configurator](/permissions/).

**Try it:** Browse 155+ skills in our [Skill Finder](/skill-finder/).

- [Claude Code for AI Agent Tool Calling](/claude-code-for-ai-agent-tool-calling-implementation/)
- [Claude Code for Embedding Pipeline Workflow](/claude-code-for-embedding-pipeline-workflow/)
- [Building Production AI Agents with Claude Skills 2026](/building-production-ai-agents-with-claude-skills-2026/)

## See Also

- [Claude Code for Waku React Framework — Guide](/claude-code-for-waku-react-framework-workflow-guide/)
- [Claude Code for HTMX — Workflow Guide](/claude-code-for-htmx-framework-workflow-guide/)


## Frequently Asked Questions

### What is the minimum setup required?

You need Claude Code installed (Node.js 18+), a project with a `CLAUDE.md` file, and the relevant toolchain for your project type (e.g., npm for JavaScript, pip for Python). The CLAUDE.md file should describe your project structure, conventions, and common commands so Claude Code can work effectively.

### How long does the initial setup take?

For a typical project, initial setup takes 10-20 minutes. This includes creating the CLAUDE.md file, configuring `.claude/settings.json` for permissions, and running a test task to verify everything works. Subsequent sessions start immediately because the configuration persists.

### Can I use this with a team?

Yes. Commit your `.claude/` directory and `CLAUDE.md` to version control so the entire team uses the same configuration. Each developer can add personal preferences in `~/.claude/settings.json` (user-level) without affecting the project configuration. Review CLAUDE.md changes in pull requests like any other configuration file.

### What if Claude Code produces incorrect output?

First check that your CLAUDE.md accurately describes your project conventions. Incorrect or outdated context is the most common cause of wrong output. If the output is still wrong, provide feedback in the same session — Claude Code learns from corrections within a conversation. For persistent issues, add explicit rules to CLAUDE.md (e.g., "Always use single quotes" or "Never modify files in the config/ directory").


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
