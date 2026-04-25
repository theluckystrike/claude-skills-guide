---
layout: default
title: "Claude Code Academic Workflow Guide (2026)"
description: "Set up claude-code-my-workflow for academic LaTeX and R projects — 28 skills, 14 agents, 24 rules battle-tested on PhD courses at Emory."
permalink: /claude-code-academic-workflow-guide-2026/
date: 2026-04-20
last_tested: "2026-04-22"
---

# Claude Code Academic Workflow Guide (2026)

The `claude-code-my-workflow` repository by Pedro H.C. Sant'Anna (963+ stars) configures Claude Code for academic research workflows. It packages 28 skills, 14 agents, and 24 rules specifically for LaTeX paper writing, R statistical analysis, and academic project management. Battle-tested on a PhD course at Emory University.

## What It Is

A CLAUDE.md configuration and supporting files designed for academics who use Claude Code for research. It teaches Claude Code to:

- Write and edit LaTeX documents following academic conventions
- Run R statistical analyses with proper methodology
- Manage bibliographies (BibTeX)
- Handle multi-file academic projects (paper, appendix, figures, tables)
- Follow citation standards and avoid statistical errors

The 28 skills cover specific academic tasks (writing abstracts, formatting tables, running regressions). The 14 agents provide role-based behavior (co-author, statistician, reviewer, copy editor). The 24 rules enforce academic integrity constraints.

## Why It Matters

Academics face unique challenges with AI coding assistants. Claude Code's default behavior optimizes for software development — it writes clean code but doesn't understand academic conventions like double-blind formatting, journal-specific LaTeX templates, or the difference between a fixed-effects and random-effects regression.

This workflow was developed alongside a PhD econometrics course at Emory, where students used Claude Code daily for research. The rules evolved from real mistakes: Claude Code hallucinating citations, using wrong standard errors, or reformatting a LaTeX document in ways that broke journal submission requirements.

## Installation

### Quick Setup

```bash
cd /path/to/your/academic-project
git clone https://github.com/pedrohcgs/claude-code-my-workflow.git .claude-workflow
cp .claude-workflow/CLAUDE.md ./CLAUDE.md
cp -r .claude-workflow/commands/ .claude/commands/
```

### Customize for Your Project

Edit the CLAUDE.md to set your project specifics:

```markdown
# Project: [Your Paper Title]

## LaTeX
- Main file: paper.tex
- Bibliography: references.bib
- Style: [AER / NBER / Econometrica / custom]
- Compiler: pdflatex → bibtex → pdflatex → pdflatex

## R / Statistical Analysis
- Main analysis: analysis/main.R
- Data directory: data/
- Packages: tidyverse, fixest, modelsummary
- Standard errors: clustered by [variable]
```

### Install R and LaTeX Dependencies

```bash
# R packages used by the analysis agents
Rscript -e 'install.packages(c("tidyverse", "fixest", "modelsummary", "kableExtra"))'

# LaTeX (if not already installed)
# macOS
brew install --cask mactex

# Ubuntu
sudo apt install texlive-full
```

## Key Features

1. **28 Academic Skills** — writing abstracts, introduction sections, literature reviews, methodology descriptions, results tables, robustness checks, and more. Each skill follows academic writing conventions.

2. **14 Specialized Agents** — co-author (writes sections), statistician (runs analyses), reviewer (critiques methodology), copy editor (fixes grammar and formatting), bibliography manager (maintains BibTeX), and others.

3. **24 Academic Rules** — constraints that prevent common AI mistakes in research: no hallucinated citations, no p-hacking, correct standard error clustering, proper table formatting.

4. **LaTeX-Aware Editing** — Claude Code understands LaTeX structure, won't break mathematical notation, respects `\label` and `\ref` consistency, and follows journal-specific templates.

5. **R Statistical Workflow** — agents that write reproducible R code with proper random seeds, documentation, and methodology comments.

6. **BibTeX Management** — bibliography agents that verify DOIs, format entries consistently, and flag missing citations.

7. **Multi-File Project Support** — handles papers with separate files for sections, appendices, figures, and tables. Maintains cross-reference integrity.

8. **Emory-Tested** — refined through real academic use. The rules address actual mistakes students encountered, not hypothetical problems.

For more on this topic, see [Claude Code for UnoCSS — Workflow Guide](/claude-code-for-unocss-workflow-guide/).

For more on this topic, see [Claude Code for Devbox — Workflow Guide](/claude-code-for-devbox-jetify-workflow-guide/).



For more on this topic, see [Claude Code for Direnv — Workflow Guide](/claude-code-for-direnv-workflow-guide/).


## Real Usage Example

### Writing a Results Section

```
You: Write the results section for the difference-in-differences analysis

Claude Code: [reads analysis/did_estimation.R for results]
[reads paper.tex for context and existing notation]

I have the regression output. Before writing, two clarifications:

1. The pre-trend test (event study) shows a marginally significant
   coefficient at t-2 (p=0.07). Should I discuss this as a potential
   concern or treat it as statistically insignificant?

2. The main effect uses clustered SEs at the state level (50 clusters).
   Should I also report wild bootstrap p-values given the small
   cluster count?

Once you confirm, I'll write the section following your paper's
existing notation (β̂ for coefficients, parenthetical SEs).
```

Note how the [Karpathy-style Don't Assume behavior](/karpathy-dont-assume-principle-claude-code-2026/) surfaces here — the agent asks about methodological judgment calls rather than making them silently.

### Managing Citations

```
You: Add a citation for Callaway and Sant'Anna (2021) to the methodology section

Claude Code: [reads references.bib]

I found the entry already in your bibliography:

@article{callaway2021difference,
  title={Difference-in-Differences with Multiple Time Periods},
  author={Callaway, Brantly and Sant'Anna, Pedro H.C.},
  journal={Journal of Econometrics},
  year={2021}
}

Adding \cite{callaway2021difference} to the methodology section at the
point where you discuss heterogeneous treatment effects.
```

### Running Reproducible Analysis

The R statistician agent enforces reproducibility:

```r
# Generated by Claude Code with academic workflow
# Seed set for reproducibility
set.seed(42)

# Load data with explicit path
data <- read_csv("data/panel_data.csv")

# DiD estimation with clustered SEs
model <- feols(
  outcome ~ treat:post | unit + time,
  data = data,
  cluster = ~state  # Clustered at state level per methodology section
)

# Export table for LaTeX
modelsummary(
  model,
  output = "tables/did_results.tex",
  stars = c('*' = 0.1, '**' = 0.05, '***' = 0.01),
  gof_map = c("nobs", "r.squared", "FE: unit", "FE: time")
)
```

## When To Use

- **Academic paper writing** — LaTeX + BibTeX + statistical analysis workflows
- **PhD and graduate research** — the workflow was designed for this exact use case
- **Econometrics and statistics** — the R agents understand regression methodology
- **Reproducible research** — enforces seeds, documentation, and methodological transparency
- **Journal submission preparation** — LaTeX formatting follows major journal requirements

## When NOT To Use

- **Software development** — this is purely academic; use [general Claude Code practices](/karpathy-skills-vs-claude-code-best-practices-2026/) for coding
- **Non-LaTeX writing** — the templates assume LaTeX; Google Docs or Word users need a different workflow
- **Non-R statistical tools** — the agents target R specifically; Stata, Python (statsmodels), or Julia users need adaptation
- **Quick drafts** — the rules add rigor that slows down exploratory writing

## FAQ

### Does it support journals other than economics?

The LaTeX and citation skills are journal-agnostic. The statistical agents lean toward econometrics (DiD, IV, RDD). For other fields, you'll need to customize the methodology agents.

### Can I use Python instead of R?

The CLAUDE.md rules are R-focused, but you can adapt them. Replace R package names with Python equivalents (pandas, statsmodels, linearmodels) and update the analysis commands.

### How do I prevent citation hallucination?

The workflow includes a rule: "NEVER generate a citation not present in references.bib. If a citation is needed but not in the bibliography, tell me and I'll provide the correct reference." This eliminates hallucinated references.

### Is this suitable for undergraduate courses?

Yes, with supervision. The rules enforce good practices but can't replace understanding. Students should review all generated statistical output.

## Our Take

**9/10.** The most specialized Claude Code workflow available, and the specialization pays off. Academic writing has enough domain-specific conventions that general-purpose configurations miss important constraints. The citation hallucination prevention alone is worth the setup. The PhD course battle-testing gives confidence that these rules handle real edge cases. Only loses a point because the R/econometrics focus limits applicability to other fields.

## Related Resources

- [CLAUDE.md Best Practices](/claude-md-best-practices-10-templates-compared-2026/) — general configuration patterns that complement academic rules
- [Karpathy Don't Assume Principle](/karpathy-dont-assume-principle-claude-code-2026/) — the behavioral principle behind the academic workflow's clarifying questions
- [The Claude Code Playbook](/playbook/) — workflow patterns that apply across domains

## See Also

- [Set Up Academic Workflow in Claude Code (2026)](/how-to-setup-academic-workflow-claude-code-2026/)
