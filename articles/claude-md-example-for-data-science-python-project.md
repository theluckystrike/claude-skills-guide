---

layout: default
title: "Claude.md Example for Data Science (2026)"
description: "Configure Claude Code for data science with real CLAUDE.md examples. Covers pandas workflows, ML pipelines, Jupyter integration, and analysis patterns."
date: 2026-03-14
last_modified_at: 2026-04-17
author: "Claude Skills Guide"
permalink: /claude-md-example-for-data-science-python-project/
categories: [guides]
reviewed: true
score: 7
tags: [claude-code, claude-skills]
geo_optimized: true
last_tested: "2026-04-21"
---

Claude Code skills use `.md` files to encapsulate project-specific knowledge, preferences, and workflows. For data science Python projects, these skill files become invaluable for maintaining consistent analysis patterns, enforcing coding standards, and accelerating common data tasks. This guide provides practical examples of Claude.md files tailored for data science workflows.

## Why Data Science Projects Need Custom Skills

Data science projects involve repetitive patterns: exploratory data analysis, feature engineering, model training, and results documentation. Each team typically develops their own conventions for handling missing values, encoding categorical variables, or logging experiments. A well-crafted Claude.md file captures these conventions and makes them available to every team member working with Claude Code.

The skill file acts as a persistent context that Claude references for every conversation in your project. Unlike vague prompts, a structured skill file gives Claude specific instructions about your tools, conventions, and preferred libraries.

## Basic Project Setup Skill

The foundation skill for any data science project specifies your environment and core dependencies:

```markdown
Data Science Python Project Skill

Environment
- Python 3.10+ required
- Use uv for package management
- All scripts must be runnable with `uv run python script.py`

Required Libraries
- pandas>=2.0.0
- numpy>=1.24.0
- scikit-learn>=1.3.0
- matplotlib>=3.7.0
- seaborn>=0.12.0
- jupyter>=1.0.0

Code Standards
- Type hints required for all functions
- Docstrings in NumPy format
- Maximum line length: 88 characters (Black default)
- All dataframes must have dtypes checked after creation
```

This skill ensures Claude understands your stack and enforces your team's coding standards. When you ask Claude to write a new analysis script, it will automatically apply type hints and follow your docstring convention.

## Data Analysis Workflow Skill

For projects focused on exploratory data analysis, extend your skill with specific patterns:

```markdown
Data Loading Conventions
- Use `pd.read_csv()` with explicit dtypes dictionary
- Always set `engine='python'` for complex CSV files
- Load large files with chunking: `pd.read_csv(file, chunksize=10000)`

EDA Patterns
When performing exploratory analysis, always:
1. Print shape and column types first
2. Check missing values with `df.isnull().sum()`
3. Generate descriptive statistics with `df.describe()`
4. Plot distributions before feature engineering

Missing Value Strategy
- Numeric: use median imputation (calculate and log the value)
- Categorical: use 'UNKNOWN' placeholder
- Document all imputation decisions in analysis notebook
```

This skill teaches Claude your preferred EDA sequence. Instead of manually specifying each step, Claude will automatically follow your workflow when you ask for data exploration.

## Machine Learning Pipeline Skill

For ML-focused projects, add specific guidance for model development:

```markdown
ML Pipeline Standards
- Use scikit-learn Pipeline for all transformations
- Split data: 80% train, 20% test, always set random_state=42
- Cross-validation: 5-fold default, use StratifiedKFold for classification
- Always fit scalers on training data only

Model Evaluation
- Classification: report accuracy, precision, recall, F1, AUC-ROC
- Regression: report RMSE, MAE, R²
- Log all metrics to MLflow or similar tracking system
- Save the best model with joblib, not pickle

Feature Engineering
- One-hot encode categoricals with sparse matrices for high cardinality
- Create interaction terms explicitly with PolynomialFeatures
- Document all engineered features in FEATURE.md
```

This skill transforms Claude from a code generator into a domain expert that understands your ML workflow. It will suggest appropriate evaluation metrics and warn against common pitfalls like data leakage.

## Working with PDF and Excel Files

Data science projects often involve importing data from various sources. The pdf and xlsx skills integrate with your Claude.md to handle file processing:

```markdown
File Import Patterns
- Excel files: use openpyxl engine, specify sheet_name explicitly
- PDF tables: use pdf skill to extract tables before analysis
- Mixed formats: normalize to pandas DataFrame before merging
```

When combined with the pdf skill, Claude can extract tables from research papers or reports and immediately begin analysis without manual copying.

## Testing Data Science Code

The tdd skill complements your data science workflow by ensuring code quality:

```markdown
Testing Requirements
- Unit tests for all transformation functions
- Use pytest with pandas testing utilities
- Test edge cases: empty dataframes, all-null columns, single-row data
- Integration tests for pipeline end-to-end execution
```

## Project Memory and Documentation

The supermemory skill helps maintain project context across sessions:

```markdown
Documentation Standards
- Update README.md with each major analysis completed
- Keep a CHANGELOG.md for model version changes
- Document data sources in DATA.md with provenance information
- Export figures to /figures directory with descriptive names
```

This ensures your project remains maintainable as complexity grows. Claude will proactively suggest documentation updates when you complete significant milestones.

## Putting It All Together

Create your project skill by combining relevant sections:

```markdown
[Project Name] Claude.md

Environment
[your environment settings]

Code Standards
[your coding conventions]

Workflow Patterns
[your analysis/ML patterns]

Documentation
[your documentation requirements]
```

Place this file in your project root as `CLAUDE.md` or in a `.claude/skills/` directory. Claude automatically loads it when working in your project directory.

The real power emerges when you customize skills for different sub-projects. A data preprocessing skill in your ETL directory, a modeling skill in your experiments folder, Claude adapts its behavior based on which skill file it finds.

## Step-by-Step Guide: Building Your Data Science CLAUDE.md

Here is a concrete workflow for creating an effective CLAUDE.md file for your data science project.

Step 1. Start with your project's problems. Before writing any skill content, list the three most common mistakes or inconsistencies in your team's data code. Maybe functions lack docstrings, or people keep fitting scalers on test data. These problems become the first rules in your skill file. Claude Code uses them as a checklist when reviewing or generating code.

Step 2. Document your data conventions explicitly. Add a section describing your data directory structure, naming conventions for raw versus processed files, and the column naming scheme your team uses. Claude Code uses these conventions when generating file I/O code, ensuring generated scripts write to the right directories and follow your naming patterns without prompting.

Step 3. Add experiment tracking instructions. Specify which MLflow tracking server URL, experiment naming convention, and mandatory tags your team requires. When you ask Claude Code to train a model, it automatically wraps the training loop with experiment tracking and logs the hyperparameters and metrics without you having to remember each call.

Step 4. Include environment troubleshooting hints. Document known issues with your setup: which CUDA version your team uses, any conda conflicts, or environment variables required before running GPU training. When Claude Code encounters errors, it checks these hints before suggesting generic fixes.

Step 5. Version your skill file alongside your data code. Commit CLAUDE.md to the same Git repository as your data pipeline. When the project's conventions change, update CLAUDE.md in the same commit. This keeps the skill file synchronized with the actual project state.

## Common Pitfalls

Writing vague instructions. Saying "use good variable names" gives Claude Code nothing actionable. Instead, be specific: DataFrame variables must be named df_purpose (e.g. df_train, df_features). Specific rules produce consistent code.

Forgetting to update the skill file when conventions change. A CLAUDE.md that documents your old sklearn pipeline structure while the project has moved to PyTorch misleads Claude Code and generates code that does not match your actual codebase. Treat the skill file as living documentation that requires the same maintenance as your README.

Including sensitive information in the skill file. Do not put database connection strings, API keys, or internal server URLs in CLAUDE.md if the repository is public. Use environment variable names instead: specify that credentials are loaded from DATABASE_URL, not the values themselves.

Making the skill file too long. Skill files over 500 lines dilute the signal. Claude Code parses the entire file as context, and a very long file means important rules compete with less important ones for attention. Keep your CLAUDE.md focused on the 20 rules that matter most.

Not testing the skill file with real tasks. After writing CLAUDE.md, test it by asking Claude Code to complete a representative task from scratch. Review the output for compliance with your rules. This testing reveals ambiguous instructions before they confuse the team.

## Best Practices

Use hierarchical skill files for multi-project workspaces. Place a global CLAUDE.md in your home directory with organization-wide conventions, and project-specific CLAUDE.md files in each project root. Claude Code merges both when working in a project directory, applying the most specific rule when there is a conflict.

Add a Quick Reference section at the top. The first section of your CLAUDE.md should be a brief bulleted list of the most important constraints. Developers and Claude Code get the critical context immediately without reading every section.

Include example code snippets for non-obvious conventions. For complex patterns like your custom cross-validation loop or your feature store integration, include a short code snippet showing the correct pattern. Claude Code learns from examples faster than from prose descriptions.

Document what to do when things go wrong. Add a section describing common failure modes and their remedies. This turns CLAUDE.md into a troubleshooting guide as well as a style guide.

## Integration Patterns

DVC pipeline integration. For projects using DVC to version data and pipeline stages, add a CLAUDE.md section documenting your dvc.yaml stage names and their expected inputs and outputs. Claude Code then generates code that reads from and writes to the correct DVC-managed paths.

Jupyter and VS Code integration. Add VS Code workspace settings that enable the Claude Code extension to automatically load CLAUDE.md from the project root when you open a notebook. Teams that use JupyterHub can configure a startup hook that loads the skill file into every new notebook session.

CI integration for skill file compliance. Claude Code can generate a GitHub Actions job that runs a compliance check against your CLAUDE.md rules, verifying that all Python files have type hints, all functions have docstrings, and all notebooks have been cleared of output before commit.

## Organizing Multi-Stage Pipelines

Data science projects often involve multiple stages: raw data ingestion, cleaning, feature engineering, model training, and evaluation. Each stage has different performance characteristics, data dependencies, and failure modes. Document these stages explicitly in your CLAUDE.md so Claude Code understands the pipeline context when generating code.

Specify which stages should be idempotent (safe to re-run), which should be skipped if outputs already exist, and which should always regenerate outputs. Claude Code uses these annotations when generating pipeline scripts, adding the appropriate existence checks and cache validation logic. When a pipeline stage fails mid-run, the restart behavior should be clear from the CLAUDE.md annotations rather than requiring developer investigation.

For large datasets, document the approximate size of each stage's inputs and outputs. Claude Code uses this information to suggest appropriate chunk sizes for pandas operations and to flag operations likely to exhaust memory. such as a merge that would create a DataFrame too large to fit in RAM given your documented dataset sizes.

---

---

<div class="mastery-cta">

This site was built by 5 autonomous agents running in tmux while I was in Bali. 2,500 articles. Zero manual work. 100% quality gate pass rate.

The orchestration configs, sprint templates, and quality gates that made that possible are in the Zovo Lifetime bundle. Along with 16 CLAUDE.md templates and 80 tested prompts.

**[See how the pipeline works →](https://zovo.one/lifetime?utm_source=ccg&utm_medium=cta-skills&utm_campaign=claude-md-example-for-data-science-python-project)**

$99 once. I'm a solo dev in Da Nang. This is how I scale.

</div>

Related Reading

- [Claude Code for Rye Python Project Workflow Guide](/claude-code-for-rye-python-project-workflow-guide/)
- [Claude MD Example for Android Kotlin Project](/claude-md-example-for-android-kotlin-project/)
- [Claude MD Example for .NET ASP.NET Core Project](/claude-md-example-for-dotnet-aspnet-core-project/)
- [Claude MD Example For Next.js TypeScript — Developer Guide](/claude-md-example-for-nextjs-typescript-project/)
- [Why Does Claude Code Perform Better With — Developer Guide](/why-does-claude-code-perform-better-with-claude-md/)
- [CLAUDE.md Example for Rails and Ruby Apps](/claude-md-example-for-rails-ruby-application/)
- [Claude Md For Contractor And Vendor Teams — Developer Guide](/claude-md-for-contractor-and-vendor-teams/)
- [Claude Md Example For Machine Learning — Developer Guide](/claude-md-example-for-machine-learning-project/)
- [CLAUDE.md Example for Elixir + Phoenix + LiveView — Production Template (2026)](/claude-md-example-for-elixir-phoenix-liveview/)
- [CLAUDE.md Example for Node.js + Express + Prisma — Production Template (2026)](/claude-md-example-for-nodejs-express-prisma/)
- [CLAUDE.md Example for Android + Kotlin + Jetpack Compose — Production Template (2026)](/claude-md-example-for-android-kotlin-jetpack/)

Built by theluckystrike. More at [zovo.one](https://zovo.one)


