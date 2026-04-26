---
layout: default
title: "Claude Skills with Embedded Scripts (2026)"
description: "How to bundle executable scripts inside SKILL.md directories with allowed-tools permissions, dynamic context injection, and visual HTML output."
permalink: /claude-skills-with-embedded-scripts/
date: 2026-04-20
render_with_liquid: false
categories: [skills, 2026]
tags: [claude-code, claude-skills, scripts, python, bash, automation]
last_updated: 2026-04-19
---

## The Specific Situation

You want Claude to generate an interactive dependency graph of your codebase. The skill needs to run a Python script that parses import statements, builds a graph, and produces a self-contained HTML file. SKILL.md alone cannot do this -- it needs to bundle the Python script and tell Claude how and when to execute it. This pattern also applies to validation scripts, data processing, report generation, and any skill that needs to execute code.

## Technical Foundation

Skills can bundle scripts in any language inside their directory structure. Claude executes these scripts using the Bash tool. The `allowed-tools` frontmatter field pre-approves specific commands so Claude does not prompt for permission each time.

Two mechanisms enable script execution in skills:

1. **Direct execution**: Claude reads the SKILL.md instructions and runs the bundled script via Bash.
2. **Dynamic context injection**: The `!`command`` syntax runs shell commands before the skill content reaches Claude. The command output replaces the placeholder inline.

The `${CLAUDE_SKILL_DIR}` substitution variable resolves to the directory containing SKILL.md, making script paths portable across installations.

## The Working SKILL.md

Directory structure:

```
codebase-deps/
├── SKILL.md
└── scripts/
    └── deps.py
```

SKILL.md:

```yaml
---
name: codebase-deps
description: >
  Generate an interactive dependency graph visualization of the
  codebase. Use when the user asks to "show dependencies",
  "visualize imports", or "map the codebase structure".
allowed-tools: Bash(python3 *)
---

# Codebase Dependency Visualizer

Generate an interactive HTML dependency graph for the current project.

## Steps

1. Run the visualization script from the project root:
   ```bash
   python3 ${CLAUDE_SKILL_DIR}/scripts/deps.py .
   ```

2. The script creates `dependency-graph.html` in the current directory

3. Open the file in the default browser:
   ```bash
   open dependency-graph.html  # macOS
   ```

4. Report what the graph shows:
   - Most connected modules (highest import count)
   - Circular dependencies if any
   - Isolated modules with no imports or exports
```

The Python script (`scripts/deps.py`) should use only standard library modules (no pip install required):

{% raw %}
```python
#!/usr/bin/env python3
"""Scan a directory for imports and generate an HTML dependency graph."""
import os
import sys
import re
import json
from pathlib import Path

def scan_imports(root_dir):
    graph = {}
    for path in Path(root_dir).rglob("*.py"):
        module = str(path.relative_to(root_dir))
        imports = []
        with open(path) as f:
            for line in f:
                match = re.match(r'^(?:from|import)\s+([\w.]+)', line)
                if match:
                    imports.append(match.group(1))
        graph[module] = imports
    return graph

def generate_html(graph, output_path):
    nodes = list(graph.keys())
    edges = []
    for src, targets in graph.items():
        for target in targets:
            for node in nodes:
                if target in node:
                    edges.append({"source": src, "target": node})
                    break
    html = f"""<!DOCTYPE html>
<html><head><title>Dependency Graph</title>
<style>
  body {{ font-family: monospace; margin: 20px; }}
  .node {{ padding: 4px 8px; margin: 2px; display: inline-block;
           background: #e0e0e0; border-radius: 4px; }}
  .edge {{ color: #666; font-size: 12px; }}
</style></head><body>
<h1>Dependency Graph ({len(nodes)} modules)</h1>
<pre>{json.dumps(graph, indent=2)}</pre>
</body></html>"""
    with open(output_path, "w") as f:
        f.write(html)

if __name__ == "__main__":
    root = sys.argv[1] if len(sys.argv) > 1 else "."
    graph = scan_imports(root)
    generate_html(graph, "dependency-graph.html")
    print(f"Generated dependency-graph.html with {len(graph)} modules")
```

## Frequently Asked Questions

### Do I need a paid Anthropic plan to use this?

Claude Code works with any Anthropic API plan, including the free tier. However, the free tier has lower rate limits (requests per minute and tokens per minute) that may slow down multi-step workflows. For professional use, the Build or Scale plan provides higher limits and priority access during peak hours.

### How does this affect token usage and cost?

The token cost depends on the size of your prompts and Claude's responses. Typical development tasks consume 10K-50K tokens per interaction. Using a CLAUDE.md file and skills reduces exploration tokens by 50-80%, which directly lowers costs. Monitor your usage at console.anthropic.com/settings/billing.

### Can I customize this for my specific project?

Yes. All Claude Code behavior can be customized through CLAUDE.md (project rules), `.claude/settings.json` (permissions), and `.claude/skills/` (domain knowledge). The most impactful customization is adding your project's specific patterns, conventions, and common commands to CLAUDE.md so Claude Code follows your standards from the start.

### What happens when Claude Code makes a mistake?

Claude Code creates files and edits through standard filesystem operations, so all changes are visible in `git diff`. If a change is wrong, revert it with `git checkout -- <file>` for a single file or `git stash` for all changes. Claude Code does not make irreversible changes unless you explicitly allow destructive commands in settings.json.


<script type="application/ld+json">
{
  "@context": "https://schema.org",
  "@type": "FAQPage",
  "mainEntity": [
    {
      "@type": "Question",
      "name": "Do I need a paid Anthropic plan to use this?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "Claude Code works with any Anthropic API plan, including the free tier. However, the free tier has lower rate limits (requests per minute and tokens per minute) that may slow down multi-step workflows."
      }
    },
    {
      "@type": "Question",
      "name": "How does this affect token usage and cost?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "The token cost depends on the size of your prompts and Claude's responses. Typical development tasks consume 10K-50K tokens per interaction. Using a CLAUDE.md file and skills reduces exploration tokens by 50-80%, which directly lowers costs."
      }
    },
    {
      "@type": "Question",
      "name": "Can I customize this for my specific project?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "Yes. All Claude Code behavior can be customized through CLAUDE.md (project rules), .claude/settings.json (permissions), and .claude/skills/ (domain knowledge). The most impactful customization is adding your project's specific patterns, conventions, and common commands to CLAUDE.md so Claude Code..."
      }
    },
    {
      "@type": "Question",
      "name": "What happens when Claude Code makes a mistake?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "Claude Code creates files and edits through standard filesystem operations, so all changes are visible in git diff. If a change is wrong, revert it with git checkout -- <file> for a single file or git stash for all changes."
      }
    }
  ]
}
</script>

{% endraw %}

## Dynamic Context Injection Pattern

For skills that need runtime data before Claude sees the instructions:

```yaml
---
name: pr-review
description: Review the current pull request
context: fork
agent: Explore
allowed-tools: Bash(gh *)
---

## Current PR Context

- PR diff: !`gh pr diff`
- Changed files: !`gh pr diff --name-only`
- PR comments: !`gh pr view --comments`

## Review Instructions

Based on the PR context above, provide a structured review...
```

The `!`command`` blocks execute before Claude processes the skill content. The output replaces the placeholder. Multi-line commands use the triple-backtick form:

````
```!
gh pr diff | head -200
gh pr view --json title,body
```
````

The `disableSkillShellExecution: true` setting prevents `!`command`` execution for user, project, and plugin skills. Bundled and managed skills are unaffected.

## Common Problems and Fixes

**Script not found**: Use `${CLAUDE_SKILL_DIR}/scripts/script.py` for paths. This resolves to the actual directory regardless of where the skill is installed.

**Permission denied on script**: Set execute permissions before committing: `chmod +x scripts/*.py scripts/*.sh`. Git preserves these permissions.

**Python script requires pip packages**: Use only standard library modules. If external packages are needed, document them in the SKILL.md and have Claude check/install them as a first step.

**Dynamic injection disabled by policy**: Check if `disableSkillShellExecution` is set in your Claude Code settings. When disabled, `!`command`` output is replaced with `[shell command execution disabled by policy]`.

**Script produces too much output**: Claude's context window has limits. Add output truncation to your scripts (e.g., `| head -500`) or write large output to files that Claude can then read selectively.

## Production Gotchas

Scripts bundled in skills run with the same permissions as Claude Code itself. They have access to the filesystem, environment variables, and network. For project-level skills committed to a shared repo, anyone who pushes a modified script can execute arbitrary code on every team member's machine the next time the skill triggers.

The visual output pattern (generating interactive HTML) is explicitly endorsed by Anthropic. It works well for data exploration, debugging output, test coverage reports, and architectural diagrams. The key constraint: use only built-in libraries so the script runs without setup.

When using `context: fork` with scripts, the subagent has its own tool permissions. The `allowed-tools` field applies to the forked context, but deny rules from the main session still override.

## Checklist

- [ ] Scripts use only standard library modules (no external dependencies)
- [ ] Script paths use `${CLAUDE_SKILL_DIR}` for portability
- [ ] `allowed-tools` includes the correct execution pattern
- [ ] Execute permissions set on all scripts before git commit
- [ ] Output is bounded (truncated or written to file)

## Related Guides

- [Claude Skills Folder Structure](/claude-skills-folder-structure/)
- [Build Your First Claude Code Skill](/building-your-first-claude-skill/)
- [Claude Skills vs MCP Servers](/claude-skills-vs-mcp-servers-differences/)
