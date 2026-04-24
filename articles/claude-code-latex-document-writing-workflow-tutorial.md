---

layout: default
title: "How to Use LaTeX Document Writing"
description: "Learn how to create professional LaTeX documents efficiently using Claude Code. This comprehensive tutorial covers setup, writing, compilation, and."
date: 2026-03-14
last_modified_at: 2026-04-17
author: Claude Skills Guide
permalink: /claude-code-latex-document-writing-workflow-tutorial/
categories: [tutorials, guides]
tags: [claude-code, claude-skills]
reviewed: true
score: 7
geo_optimized: true
---


Claude Code LaTeX Document Writing Workflow Tutorial

LaTeX remains the gold standard for scientific and technical document preparation, offering unparalleled control over formatting and typography. When combined with Claude Code's AI capabilities, you get a powerful workflow that dramatically accelerates document creation while maintaining professional quality. This tutorial walks you through setting up and mastering a LaTeX writing workflow with Claude Code.

## Prerequisites and Environment Setup

Before diving into the workflow, ensure you have the necessary tools installed. You'll need:

- LaTeX distribution: TeX Live (cross-platform), MacTeX (macOS), or MiKTeX (Windows)
- Claude Code: Installed and configured on your system
- A code editor: VS Code with LaTeX Workshop, or your preferred editor
- Perl: Required by latexmk, the recommended build tool

Verify your LaTeX installation by running:

```bash
pdflatex --version
latexmk --version
```

If you receive version numbers, you're ready to proceed. If `latexmk` is not found, install it via your TeX distribution's package manager. it ships by default with TeX Live and MacTeX.

Next, create a new directory for your project:

```bash
mkdir my-latex-project && cd my-latex-project
```

## Choosing a LaTeX Distribution

Not all distributions are equal for every workflow:

| Distribution | Platform | Best For |
|---|---|---|
| TeX Live | Linux, macOS, Windows | Full-featured, large package library |
| MacTeX | macOS | TeX Live repackaged with macOS tools |
| MiKTeX | Windows | On-demand package installation |
| TinyTeX | All (R/Python users) | Minimal, scriptable |

If you're starting fresh and are on macOS, MacTeX is the simplest path. On Linux, install TeX Live via your system package manager (`apt install texlive-full` on Debian/Ubuntu). Ask Claude Code to help you pick and configure the right distribution for your operating system.

## Structuring Your LaTeX Project

A well-organized LaTeX project makes collaboration and maintenance significantly easier. Here's a recommended structure:

```
my-latex-project/
 main.tex # Main document file
 preamble.tex # Package imports and custom commands
 content/
 abstract.tex
 introduction.tex
 methods.tex
 results.tex
 conclusion.tex
 references.bib # Bibliography database
 figures/ # Image files (PDF, PNG, EPS)
 .latexmkrc # Build configuration
 Makefile # Build automation shortcut
```

This modular approach allows you to work on sections independently and reuse components across documents. Claude Code excels at generating these structural templates when you describe your document type. Try prompting: "Create a complete LaTeX project structure for a journal article submission to IEEE."

## Using \input vs \include

Understanding the difference between these two commands saves debugging time:

- `\input{file}` pastes the file content inline, as if you typed it there. No new page break.
- `\include{file}` forces a new page before and after, and works with `\includeonly` for selective compilation.

For long documents like theses, use `\include` for chapters and `\input` for smaller fragments like custom commands or abbreviation lists. Claude Code can refactor an existing single-file document into this modular structure on request.

## Creating Your First Document

Start with a minimal working document. In your `main.tex`:

```latex
\documentclass{article}
\usepackage[utf8]{inputenc}
\usepackage[T1]{fontenc}
\usepackage{amsmath, amssymb}
\usepackage{graphicx}
\usepackage{hyperref}
\usepackage{cleveref}

\title{Your Document Title}
\author{Your Name}
\date{\today}

\begin{document}

\maketitle

\begin{abstract}
Your abstract goes here.
\end{abstract}

\section{Introduction}
\label{sec:introduction}
Your introduction content.

\end{document}
```

When working with Claude Code, you can generate this structure conversationally. Simply describe what you need: "Create a LaTeX article template with AMS math packages, a two-column layout, and hyperref configured for PDF bookmarks." Claude Code will generate the appropriate preamble and structure, including package options you might not know about.

## Document Classes Comparison

The choice of document class shapes everything else:

| Class | Use Case | Notable Features |
|---|---|---|
| `article` | Journal papers, short reports | No chapters, compact |
| `book` | Long documents, theses | Chapters, front/back matter |
| `report` | Technical reports | Chapters, no publisher info |
| `beamer` | Presentations | Slide environments, themes |
| `memoir` | Flexible books | Highly customizable |
| `IEEEtran` | IEEE submissions | Double-column, strict style |
| `acmart` | ACM submissions | Conference/journal variants |

Many journals provide their own `.cls` file. When you receive a submission template, ask Claude Code to explain the custom commands and environments defined in that class file. it can reverse-engineer unfamiliar macros and explain what they produce.

## Writing with Claude Code

Claude Code transforms LaTeX writing through its contextual understanding of mathematical notation, document structure, and proper package usage. Here are practical strategies:

## Generating Mathematical Content

LaTeX math notation can be challenging. Describe mathematical concepts naturally:

> "Write the quadratic formula and explain it, then create a system of three linear equations with matrix notation."

Claude Code produces properly formatted LaTeX:

```latex
The quadratic formula is given by:
\begin{equation}
 x = \frac{-b \pm \sqrt{b^2 - 4ac}}{2a}
\end{equation}

A system of three linear equations can be represented in matrix form:
\begin{equation}
 \begin{bmatrix}
 a_{11} & a_{12} & a_{13} \\
 a_{21} & a_{22} & a_{23} \\
 a_{31} & a_{32} & a_{33}
 \end{bmatrix}
 \begin{bmatrix}
 x_1 \\ x_2 \\ x_3
 \end{bmatrix}
 =
 \begin{bmatrix}
 b_1 \\ b_2 \\ b_3
 \end{bmatrix}
\end{equation}
```

For more complex mathematical content, specify the notation style you need:

```latex
% Probability and statistics notation
\begin{align}
 P(A \mid B) &= \frac{P(B \mid A)\, P(A)}{P(B)} \label{eq:bayes} \\
 \mathbb{E}[X] &= \int_{-\infty}^{\infty} x\, f(x)\, dx \label{eq:expectation}
\end{align}
```

Ask Claude to generate definitions for custom macros that shorten frequently-used notation. For instance:

```latex
% Ask Claude: "Create macros for common probability notation"
\newcommand{\given}{\mid}
\newcommand{\E}[1]{\mathbb{E}\left[#1\right]}
\newcommand{\Var}[1]{\mathrm{Var}\left(#1\right)}
\newcommand{\prob}[1]{P\!\left(#1\right)}
```

## Refactoring Existing Content

When you have draft LaTeX that needs improvement, paste it and ask Claude Code to enhance it:

- "Convert this plain text to proper LaTeX with appropriate sectioning"
- "Add cross-references and citations to this content"
- "Format these bullet points as a proper itemize environment"
- "Add the `booktabs` package and reformat this table with proper horizontal rules"
- "Replace all manual spacing like `\\[10pt]` with semantic spacing commands"

This refactoring workflow is one of the fastest ways to upgrade a draft document from functional to publication-ready.

## Handling Complex Structures

For tables, figures, and advanced layouts, describe your requirements:

> "Create a table with three columns: Procedure, Expected Output, and Time Complexity. Include a caption and label for cross-referencing."

Claude Code generates:

```latex
\begin{table}[htbp]
 \centering
 \caption{Experimental Procedures and Results}
 \label{tab:procedures}
 \begin{tabular}{|l|l|c|}
 \hline
 \textbf{Procedure} & \textbf{Expected Output} & \textbf{Time} \\
 \hline
 Algorithm A & Optimal solution & $O(n \log n)$ \\
 \hline
 Algorithm B & Approximate solution & $O(n^2)$ \\
 \hline
 \end{tabular}
\end{table}
```

For publication-quality tables, ask Claude to use the `booktabs` package instead:

```latex
\usepackage{booktabs}

\begin{table}[htbp]
 \centering
 \caption{Experimental Procedures and Results}
 \label{tab:procedures}
 \begin{tabular}{llc}
 \toprule
 \textbf{Procedure} & \textbf{Expected Output} & \textbf{Time Complexity} \\
 \midrule
 Algorithm A & Optimal solution & $O(n \log n)$ \\
 Algorithm B & Approximate solution & $O(n^2)$ \\
 \bottomrule
 \end{tabular}
\end{table}
```

The `booktabs` style avoids vertical rules and uses proper horizontal spacing, which is the standard in most academic journals.

## Figures and Subfigures

Including figures is straightforward, but managing multiple related images requires care:

```latex
\usepackage{graphicx}
\usepackage{subcaption}

\begin{figure}[htbp]
 \centering
 \begin{subfigure}[b]{0.45\textwidth}
 \includegraphics[width=\textwidth]{figures/result_a.pdf}
 \caption{Baseline method}
 \label{fig:baseline}
 \end{subfigure}
 \hfill
 \begin{subfigure}[b]{0.45\textwidth}
 \includegraphics[width=\textwidth]{figures/result_b.pdf}
 \caption{Proposed method}
 \label{fig:proposed}
 \end{subfigure}
 \caption{Comparison of baseline and proposed approaches on Dataset X.}
 \label{fig:comparison}
\end{figure}
```

Ask Claude Code to generate figure placement code when you describe the layout: "I have two plots side by side, each taking up about half the column width, with individual captions and a shared caption." Claude will produce exactly this structure.

## Bibliography Management

Bibliography handling is an area where many LaTeX beginners struggle. There are two main approaches:

BibTeX (Traditional)

BibTeX is the classic approach, requiring a `.bib` file and a style file:

```latex
% In main.tex
\bibliographystyle{plain} % or ieeetr, abbrv, alpha, etc.
\bibliography{references} % references.bib

% Example .bib entry
```

```bibtex
@article{smith2024deep,
 author = {Smith, John and Jones, Alice},
 title = {Deep Learning for Document Understanding},
 journal = {Journal of Machine Learning},
 year = {2024},
 volume = {15},
 number = {3},
 pages = {101--120},
 doi = {10.1000/jml.2024.15.3.101}
}
```

BibLaTeX + Biber (Modern)

For new projects, `biblatex` with the `biber` backend offers better Unicode support, more citation styles, and easier customization:

```latex
\usepackage[
 backend=biber,
 style=authoryear,
 sorting=nyt
]{biblatex}
\addbibresource{references.bib}

% At the end of document
\printbibliography
```

Ask Claude Code which bibliography system matches your target journal's requirements. Most modern venues accept either, but some (like ACL in NLP) provide their own `.bst` style files.

## Building and Compiling Documents

Compilation is where many developers struggle. While `pdflatex` is common, `latexmk` is the recommended tool because it handles multi-pass compilation and bibliography rebuilds automatically.

## Using latexmk

```bash
Compile to PDF (handles all passes automatically)
latexmk -pdf main.tex

Continuous compilation mode. recompiles on file changes
latexmk -pdf -pvc main.tex

Clean build artifacts
latexmk -C
```

Create a `.latexmkrc` file to configure latexmk for your project:

```perl
.latexmkrc
$pdf_mode = 1; # Use pdflatex
$bibtex_use = 2; # Run bibtex/biber as needed
$clean_ext = "bbl blg synctex.gz";
```

If you're using `biblatex` with `biber`:

```perl
.latexmkrc for biber
$pdf_mode = 1;
$biber = 'biber %O %S';
```

## Makefile for Convenience

Create a `Makefile` for automated builds:

```makefile
TEX = latexmk -pdf
MAIN = main

all:
	$(TEX) $(MAIN).tex

watch:
	$(TEX) -pvc $(MAIN).tex

clean:
	latexmk -C
	rm -f *.bbl *.synctex.gz

view: all
	open $(MAIN).pdf

.PHONY: all watch clean view
```

With this setup, `make` builds the document, `make watch` starts continuous compilation, and `make clean` removes all generated files. Ask Claude Code to extend this Makefile for your specific needs. for instance, to automatically copy the final PDF to a submission directory.

## Advanced Workflow Tips

## Version Control for LaTeX

LaTeX documents are text files, making them ideal for Git. Add a `.gitignore`:

```
LaTeX build artifacts
*.aux
*.log
*.out
*.toc
*.bbl
*.blg
*.synctex.gz
*.fls
*.fdb_latexmk
*.nav
*.snm
*.vrb

Generated PDF (optional. some teams commit the PDF)
main.pdf
```

Commit your `.tex`, `.bib`, and figure source files. The build artifacts stay untracked. For figures, prefer PDF or EPS over raster formats so your document scales cleanly at any resolution.

A useful Git workflow for LaTeX: work on a `draft` branch for major revisions, and merge to `main` for submitted versions. Tag each submission: `git tag -a v1.0 -m "Initial submission"`. This creates a clean history of what was submitted to which venue.

## Real-time Collaboration

For collaborative writing, consider these approaches:

| Method | Pros | Cons |
|---|---|---|
| Overleaf | Real-time, no setup, web-based | Requires subscription for private repos |
| Git + GitHub | Full version control, free | Merge conflicts in `.tex` files can be tricky |
| Git + VS Code Live Share | Real-time co-editing with local toolchain | Requires identical editor setup |
| Dropbox + Makefile | Simple sync | No conflict resolution |

For most academic collaborations, Overleaf is the path of least resistance. For larger projects with strict version control requirements, Git is the right choice. Ask Claude Code to help you set up a `.latexindent.yaml` configuration that normalizes whitespace in `.tex` files before commits. this prevents spurious diffs from indentation changes.

## Debugging Compilation Errors

LaTeX errors can be cryptic. When stuck:

1. Check the `.log` file for the first error. later errors often cascade from the first
2. Look for `!` lines in the log, which indicate hard errors vs `Warning` lines
3. Simplify your document by commenting out sections to isolate the problem
4. Use `\tracingall` temporarily to get verbose output (warning: this produces enormous logs)

Common error categories and their causes:

| Error Message | Likely Cause |
|---|---|
| `Undefined control sequence` | Misspelled macro or missing package |
| `Missing $ inserted` | Math command used outside math mode |
| `File not found` | Missing figure file or wrong path |
| `Too many }'s` | Mismatched braces |
| `LaTeX Error: \begin{X} on input line N ended by \end{Y}` | Mismatched environment names |
| `Runaway argument` | Missing closing brace somewhere above |

Claude Code can also help interpret error messages. Paste the relevant lines from the `.log` file and ask for explanation and solution. Unlike searching Stack Overflow, Claude will explain the root cause in the context of your specific document structure.

## Optimizing for Specific Journals

Most publishers provide author guidelines and a LaTeX template. Claude Code can help you:

- Adapt your document to a journal's class file requirements
- Check that your preamble doesn't conflict with the journal's macros
- Generate a submission checklist based on the author guidelines
- Convert between citation styles (e.g., from numbered to author-year)

Prompt example: "Here is the preamble from the ACL 2025 template. I have an existing paper using the article class. What changes do I need to make to convert it to ACL format?"

## Using LuaLaTeX and XeLaTeX for Modern Typography

While `pdflatex` is the most common compiler, `lualatex` and `xelatex` offer significant advantages for documents that need:

- Unicode character support and non-Latin scripts
- System font access (use fonts from your OS rather than TeX-specific fonts)
- Advanced OpenType features like ligatures and old-style numerals

```latex
% XeLaTeX preamble for custom fonts
\documentclass{article}
\usepackage{fontspec}
\setmainfont{Palatino}
\setsansfont{Helvetica Neue}
\setmonofont{JetBrains Mono}
```

Ask Claude Code to help you migrate a pdflatex document to xelatex when you need better font support. The main changes involve replacing `inputenc`/`fontenc` packages with `fontspec`.

## Conclusion

Integrating Claude Code into your LaTeX workflow significantly enhances productivity while maintaining document quality. The AI assistance handles routine formatting tasks, generates complex mathematical notation, builds bibliography entries, and provides contextual suggestions that would otherwise require extensive manual reference lookup.

Start with simple documents, gradually incorporate more advanced features, and build your personal template library. With practice, you'll find Claude Code becoming an invaluable writing partner for all your LaTeX projects.

The most effective use pattern is iterative: draft your content in plain prose, then ask Claude Code to convert sections to proper LaTeX, add appropriate environments, generate complex notation, and polish the overall structure. This keeps your focus on the intellectual content while Claude handles the mechanical aspects of LaTeX syntax.

Remember: Claude Code handles the mechanical aspects of LaTeX, but your expertise and content remain central. Use the AI to amplify your capabilities, not replace your knowledge.


---

---

<div class="mastery-cta">

I'm a solo developer in Vietnam. 50K Chrome extension users. $500K+ on Upwork. 5 Claude Max subscriptions running agent fleets in parallel.

These are my actual CLAUDE.md templates, orchestration configs, and prompts. Not a course. Not theory. The files I copy into every project before I write a line of code.

**[See what's inside →](https://zovo.one/lifetime?utm_source=ccg&utm_medium=cta-default&utm_campaign=claude-code-latex-document-writing-workflow-tutorial)**

$99 once. Free forever. 47/500 founding spots left.

</div>

Related Reading

- [Claude Code for Apache Drill Workflow Tutorial](/claude-code-for-apache-drill-workflow-tutorial/)
- [Claude Code for Astro Actions Workflow Tutorial](/claude-code-for-astro-actions-workflow-tutorial/)
- [Claude Code for Automated PR Checks Workflow Tutorial](/claude-code-for-automated-pr-checks-workflow-tutorial/)
- [Claude Code For Pr Status Check — Complete Developer Guide](/claude-code-for-pr-status-check-workflow-tutorial/)
- [Claude Code For AI Red Teaming — Complete Developer Guide](/claude-code-for-ai-red-teaming-workflow-guide/)
- [Claude Code for Delta Lake Workflow Guide](/claude-code-for-delta-lake-workflow-guide/)
- [Claude Code For Kube State — Complete Developer Guide](/claude-code-for-kube-state-metrics-workflow/)
- [Claude Code Laravel Livewire Real-Time Workflow Tutorial](/claude-code-laravel-livewire-real-time-workflow-tutorial/)
- [Claude Code for Sanity CMS Workflow Tutorial](/claude-code-for-sanity-cms-workflow-tutorial/)
- [Claude Code for LM Studio — Workflow Guide](/claude-code-for-lm-studio-workflow-guide/)
- [Claude Code for Fig — Workflow Guide](/claude-code-for-fig-workflow-guide/)

Built by theluckystrike. More at [zovo.one](https://zovo.one)

## See Also

- [Claude Code for LaTeX Document Workflow 2026](/claude-code-latex-document-workflow-2026/)
