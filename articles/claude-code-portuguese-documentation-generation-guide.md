---
layout: default
title: "Claude Code Portuguese Documentation Generation Guide"
description: "Generate Portuguese documentation for your codebase using Claude Code skills: workflow setup, language configuration, and practical examples."
date: 2026-03-14
categories: [workflows]
tags: [claude-code, claude-skills, documentation, portuguese, localization, pdf, supermemory]
author: "Claude Skills Guide"
reviewed: true
score: 8
permalink: /claude-code-portuguese-documentation-generation-guide/
---

# Claude Code Portuguese Documentation Generation Guide

Generating documentation in Portuguese opens your projects to Brazilian and Portuguese-speaking development teams. Claude Code handles this efficiently when you configure the right workflow, whether you need API docs, README files, or inline code comments in Portuguese.

This guide walks through setting up a Portuguese [documentation generation workflow](/claude-skills-guide/automated-code-documentation-workflow-with-claude-skills/) using Claude skills, covering language configuration, skill selection, and practical examples you can apply immediately. If you need to handle multiple languages, see the [i18n localization workflow automation guide](/claude-skills-guide/claude-skills-for-localization-i18n-workflow-automation/).

## Prerequisites

Before starting, ensure you have:

- Claude Code installed and operational
- A project requiring documentation in Portuguese
- The `pdf` skill for generating formatted output documents
- The `supermemory` skill for persisting language preferences across sessions
- Optional: the `tdd` skill if you want to generate documentation alongside test cases

No additional language models or translation services required. Claude Code generates Portuguese directly from your codebase context.

## Configuring Portuguese as the Output Language

The first step is establishing Portuguese as the default output language for documentation tasks. Store this preference in supermemory so every Claude session knows your documentation language:

```
/supermemory
Store documentation language preference for this project:
- Primary language: Portuguese (Brazilian)
- All generated docs, comments, and READMEs must be in Portuguese
- Use Brazilian Portuguese conventions (pt-BR)
- Date format: DD/MM/YYYY
- Code comments: Portuguese explanations, English variable names remain unchanged
```

Retrieve this preference at the start of each documentation session:

```
/supermemory
Retrieve documentation language preference before generating any docs.
```

## Generating Inline Documentation in Portuguese

For inline comments and function documentation, specify the language explicitly in your prompt. Claude scans your code and generates Portuguese comments that accurately describe functionality.

For a JavaScript service file:

```
Generate JSDoc comments in Portuguese (pt-BR) for every exported function in src/services/pagamento.js.
For each function include:
- Descrição do que a função faz em português brasileiro
- @param com tipos e descrições em português
- @returns com tipo e descrição
- @example com exemplo de uso real em português
- @throws se a função pode lançar erros

Mantenha os comentários precisos em relação ao código real.
```

For a Python module:

```
Add docstrings in Portuguese (Brazilian) to every class and public method in src/models/cliente.py.
Use the Google Python docstring format translated to Portuguese:
- Args (translated to "Argumentos")
- Returns (translated to "Retorna")
- Raises (translated to "Lança")
- Example (translated to "Exemplo")

Base all descriptions on the actual code implementation.
```

## Creating README Files in Portuguese

Generate complete README documentation in Portuguese by providing the project context:

```
Generate a developer-focused README.md in Portuguese (Brazilian) for this project.
Structure it with these sections:
1. Nome do projeto e descrição em uma frase
2. Pré-requisitos (versões exatas de Node, Python, etc)
3. Installation steps (copy-paste ready commands)
4. Configuração (cada variável de ambiente com descrição e exemplo)
5. Usage (three to five real examples using actual functions)
6. API reference (brief endpoint list if applicable)
7. Executando testes
8. Contributing guidelines (direct translation to Portuguese)
9. Licença

Base everything on the actual code. Do not invent features.
```

Claude produces a README with headers like "Instalação", "Configuração", "Uso", and "Contribuindo" that matches Brazilian developer expectations.

## Generating API Documentation in Portuguese

For REST API projects, the `pdf` skill creates formatted, professional documentation in Portuguese. Use it after Claude generates the content:

```
/pdf
Create an API reference document in Portuguese (Brazilian) from the endpoints defined in src/api/pedidos.py.
For each endpoint include:
- Método HTTP e caminho
- Requisitos de autenticação
- Schema do corpo da requisição com tipos de campos
- Schema da resposta para casos de sucesso e erro
- Exemplo de comando curl

Output as a well-formatted document suitable for sharing with development teams.
Format headers in Portuguese: "Referência da API", "Autenticação", "Endpoints", etc.
```

The [pdf skill](/claude-skills-guide/what-is-the-best-claude-skill-for-generating-documentation/) handles all formatting automatically, producing a document ready for distribution.

## Documenting Test Cases in Portuguese

If you use the `tdd` skill, generate test documentation alongside your test cases:

```
/tdd
Generate unit tests for src/utils/validador.py.
Write the tests in Portuguese:
- Test function names in Portuguese (e.g., "deveValidarEmailCorretamente")
- Comments explaining each assertion in Portuguese
- Docstrings for each test describe what is being validated

Include tests for happy path and error cases.
```

This produces tests that serve as executable documentation, useful for onboarding Brazilian developers to your codebase. For multilingual projects, also consider the [translate code comments between languages guide](/claude-skills-guide/claude-code-translate-code-comments-between-languages/).

## Automating Documentation Updates

Set up a documentation update workflow that runs after code commits. Create a skill at `~/.claude/skills/doc-pt-update.md`:

```markdown
# doc-pt-update

You are a documentation updater for Portuguese documentation. When invoked:
1. Review the changed files provided
2. Check if existing Portuguese documentation is still accurate
3. Update any stale comments or docstrings in Portuguese
4. Generate a changelog entry in Portuguese describing changes
5. Suggest if README needs updates

Be specific, concise, and accurate. Always write in Portuguese (Brazilian).
```

Invoke it after commits:

```
/doc-pt-update
Changed files from last commit:
- src/services/carrinho.js (added método calcularTotal)
- src/models/produto.js (added campo desconto)
```

## Persisting Documentation Standards

Maintain consistent documentation standards across sessions using supermemory:

```
/supermemory
Store Portuguese documentation standards:
- Use JSDoc for all JS/TS files with Portuguese descriptions
- Use Google-style docstrings for Python in Portuguese
- README uses H2 headers only, all text in Portuguese
- API docs regenerated monthly and committed to docs/referencia-api.md
- Changelog format: "DD/MM/YYYY — breve resumo das alterações"
- Never document private methods (underscore prefix)
- Code comments: Portuguese explanations, English for variable/function names
```

## Quality Verification

After generating Portuguese documentation, verify quality:

```
Review the Portuguese documentation just generated.
Check for:
- Correct Brazilian Portuguese spelling and grammar
- Technical terms used correctly (whether to use English terms or their Portuguese translations)
- Consistent terminology throughout
- Accurate code descriptions that match actual implementation
- Proper accent marks and punctuation

Report any issues found.
```

Common issues to watch for: mixing European and Brazilian Portuguese, incorrect gender assignment, or machine-translated-sounding phrases that feel unnatural.

## Workflow Summary

Your Portuguese documentation generation workflow:

1. **Session start**: Retrieve language preferences from supermemory
2. **Code changes**: Generate inline comments in Portuguese immediately
3. **API updates**: Use `/pdf` to create formatted API reference
4. **Commits**: Run `/doc-pt-update` to keep docs synchronized
5. **Reviews**: Verify Portuguese quality before committing
6. **Sprints**: Run documentation coverage audit, address gaps

This workflow produces consistent, high-quality Portuguese documentation that serves Brazilian developers effectively. The time investment is minimal compared to manual documentation, and the results are more accurate because Claude generates descriptions directly from your actual code.

---

## Related Reading

- [Automated Code Documentation Workflow with Claude Skills](/claude-skills-guide/automated-code-documentation-workflow-with-claude-skills/) — Core documentation workflow patterns
- [Best Claude Skills for Developers in 2026](/claude-skills-guide/best-claude-skills-for-developers-2026/) — Full developer skill stack
- [Claude Code Skills for Technical Writing](/claude-skills-guide/what-is-the-best-claude-skill-for-generating-documentation/) — Technical writing with Claude skills

Built by theluckystrike — More at [zovo.one](https://zovo.one)
