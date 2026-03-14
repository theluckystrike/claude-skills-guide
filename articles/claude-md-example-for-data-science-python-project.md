---
layout: default
title: "Claude.md Example for Data Science Python Project"
description: "Practical Claude.md examples for data science Python projects. Learn how to create effective skill files for data analysis, ML pipelines, and pandas workflows."
date: 2026-03-14
author: theluckystrike
permalink: /claude-md-example-for-data-science-python-project/
---

# Claude.md Example for Data Science Python Project

Claude Code skills use `.md` files to encapsulate project-specific knowledge, preferences, and workflows. For data science Python projects, these skill files become invaluable for maintaining consistent analysis patterns, enforcing coding standards, and accelerating common data tasks. This guide provides practical examples of Claude.md files tailored for data science workflows.

## Why Data Science Projects Need Custom Skills

Data science projects involve repetitive patterns: exploratory data analysis, feature engineering, model training, and results documentation. Each team typically develops their own conventions for handling missing values, encoding categorical variables, or logging experiments. A well-crafted Claude.md file captures these conventions and makes them available to every team member working with Claude Code.

The skill file acts as a persistent context that Claude references for every conversation in your project. Unlike vague prompts, a structured skill file gives Claude specific instructions about your tools, conventions, and preferred libraries.

## Basic Project Setup Skill

The foundation skill for any data science project specifies your environment and core dependencies:

```markdown
# Data Science Python Project Skill

## Environment
- Python 3.10+ required
- Use uv for package management
- All scripts must be runnable with `uv run python script.py`

## Required Libraries
- pandas>=2.0.0
- numpy>=1.24.0
- scikit-learn>=1.3.0
- matplotlib>=3.7.0
- seaborn>=0.12.0
- jupyter>=1.0.0

## Code Standards
- Type hints required for all functions
- Docstrings in NumPy format
- Maximum line length: 88 characters (Black default)
- All dataframes must have dtypes checked after creation
```

This skill ensures Claude understands your stack and enforces your team's coding standards. When you ask Claude to write a new analysis script, it will automatically apply type hints and follow your docstring convention.

## Data Analysis Workflow Skill

For projects focused on exploratory data analysis, extend your skill with specific patterns:

```markdown
## Data Loading Conventions
- Use `pd.read_csv()` with explicit dtypes dictionary
- Always set `engine='python'` for complex CSV files
- Load large files with chunking: `pd.read_csv(file, chunksize=10000)`

## EDA Patterns
When performing exploratory analysis, always:
1. Print shape and column types first
2. Check missing values with `df.isnull().sum()`
3. Generate descriptive statistics with `df.describe()`
4. Plot distributions before feature engineering

## Missing Value Strategy
- Numeric: use median imputation (calculate and log the填充 value)
- Categorical: use 'UNKNOWN' placeholder
- Document all imputation decisions in analysis notebook
```

This skill teaches Claude your preferred EDA sequence. Instead of manually specifying each step, Claude will automatically follow your workflow when you ask for data exploration.

## Machine Learning Pipeline Skill

For ML-focused projects, add specific guidance for model development:

```markdown
## ML Pipeline Standards
- Use scikit-learn Pipeline for all transformations
- Split data: 80% train, 20% test, always set random_state=42
- Cross-validation: 5-fold default, use StratifiedKFold for classification
- Always fit scalers on training data only

## Model Evaluation
- Classification: report accuracy, precision, recall, F1, AUC-ROC
- Regression: report RMSE, MAE, R²
- Log all metrics to MLflow or similar tracking system
- Save the best model with joblib, not pickle

## Feature Engineering
- One-hot encode categoricals with sparse matrices for high cardinality
- Create interaction terms explicitly with PolynomialFeatures
- Document all engineered features in FEATURE.md
```

This skill transforms Claude from a code generator into a domain expert that understands your ML workflow. It will suggest appropriate evaluation metrics and warn against common pitfalls like data leakage.

## Working with PDF and Excel Files

Data science projects often involve importing data from various sources. The pdf and xlsx skills integrate with your Claude.md to handle file processing:

```markdown
## File Import Patterns
- Excel files: use openpyxl engine, specify sheet_name explicitly
- PDF tables: use pdf skill to extract tables before analysis
- Mixed formats: normalize to pandas DataFrame before merging
```

When combined with the pdf skill, Claude can extract tables from research papers or reports and immediately begin analysis without manual copying.

## Testing Data Science Code

The tdd skill complements your data science workflow by ensuring code quality:

```markdown
## Testing Requirements
- Unit tests for all transformation functions
- Use pytest with pandas testing utilities
- Test edge cases: empty dataframes, all-null columns, single-row data
- Integration tests for pipeline end-to-end execution
```

## Project Memory and Documentation

The supermemory skill helps maintain project context across sessions:

```markdown
## Documentation Standards
- Update README.md with each major analysis completed
- Keep a CHANGELOG.md for model version changes
- Document data sources in DATA.md with provenance information
- Export figures to /figures directory with descriptive names
```

This ensures your project remains maintainable as complexity grows. Claude will proactively suggest documentation updates when you complete significant milestones.

## Putting It All Together

Create your project skill by combining relevant sections:

```markdown
# [Project Name] Claude.md

## Environment
[your environment settings]

## Code Standards
[your coding conventions]

## Workflow Patterns
[your analysis/ML patterns]

## Documentation
[your documentation requirements]
```

Place this file in your project root as `CLAUDE.md` or in a `.claude/skills/` directory. Claude automatically loads it when working in your project directory.

The real power emerges when you customize skills for different sub-projects. A data preprocessing skill in your ETL directory, a modeling skill in your experiments folder—Claude adapts its behavior based on which skill file it finds.

Built by theluckystrike — More at [zovo.one](https://zovo.one)
