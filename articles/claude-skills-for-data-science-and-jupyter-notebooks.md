---
layout: default
title: "Claude Skills for Data Science and Jupyter: 2026 Guide"
description: "Claude skills for data science and Jupyter: automate data cleaning, generate visualizations, build ML pipelines, and accelerate research workflows."
date: 2026-03-13
categories: [guides]
tags: [claude-code, claude-skills, data-science, jupyter, python, machine-learning]
author: "Claude Skills Guide"
reviewed: true
score: 9
---

Data science workflows involve repetitive tasks that drain productivity: cleaning messy datasets, generating visualizations, building machine learning pipelines, and documenting findings. Claude Code skills transform these workflows by automating common operations and enabling AI-assisted development directly within Jupyter notebooks and Python environments.

Claude skills are Markdown files stored in `~/.claude/skills/` and invoked with `/skill-name` inside a Claude Code session. They give Claude standing instructions for specialized tasks. There are no `from canvas_design import` or `from supermemory import` Python packages—skills are invoked conversationally, not imported.

This guide covers practical Claude skills that data scientists and developers use daily.

## Foundation Skills for Data Science

### xlsx Skill for Data Import and Export

The xlsx skill handles spreadsheet operations essential to data science workflows. Loading datasets from Excel, applying transformations, and exporting results all benefit from programmatic guidance.

Invoke the skill when working with Excel files:

```
/xlsx
Load dataset.xlsx, check for missing values in all columns, and export a cleaned version with rows containing >50% null values removed
```

Claude will write the pandas code to accomplish this and run it in your session:

```python
import pandas as pd

df = pd.read_excel('dataset.xlsx', sheet_name='TrainingData')
threshold = len(df.columns) * 0.5
df_cleaned = df.dropna(thresh=threshold)
df_cleaned.to_excel('processed_data.xlsx', index=False)
print(f"Removed {len(df) - len(df_cleaned)} rows with >50% null values")
```

The skill knows how to handle merged cells, multiple sheets, and type inference edge cases without requiring you to specify every detail.

### pdf Skill for Research Paper Extraction

Extracting data from academic papers, financial reports, and industry studies is straightforward with the [pdf skill](/claude-skills-guide/articles/best-claude-skills-for-data-analysis/):

```
/pdf
Extract all tables from pages 3-5 of research_paper.pdf and convert them to CSV format
```

Claude uses available tools to parse the PDF and output the tables as structured data you can load directly into pandas. This accelerates literature review and lets you integrate published data into analysis pipelines without manual transcription.

## Jupyter Notebook Automation

### Code Generation and Refactoring with tdd

The [tdd skill](/claude-skills-guide/articles/best-claude-skills-for-developers-2026/) promotes test-driven development practices even in notebook environments, ensuring reproducible results:

```
/tdd
I need a function that calculates classification metrics. Write the tests first, then implement it.
```

Claude produces the test and implementation together:

```python
def calculate_metrics(predictions, actual):
    """Calculate classification metrics with built-in validation"""
    from sklearn.metrics import accuracy_score, precision_score, recall_score

    assert len(predictions) == len(actual), "Length mismatch"

    return {
        'accuracy': accuracy_score(actual, predictions),
        'precision': precision_score(actual, predictions, average='weighted'),
        'recall': recall_score(actual, predictions, average='weighted')
    }

# Tests
test_preds = [1, 0, 1, 1, 0]
test_actual = [1, 0, 0, 1, 1]
metrics = calculate_metrics(test_preds, test_actual)
assert 0 <= metrics['accuracy'] <= 1
assert 0 <= metrics['precision'] <= 1
```

The tdd skill generates test cases alongside implementation, reducing errors in complex transformations.

### Visualization and Reporting

For custom visualizations, describe what you need directly in a Claude Code session or invoke skills for specific output formats:

```
/pdf
Generate a PDF report containing: title page, summary statistics table, and the three charts I just created in this session
```

```
/pptx
Create a presentation from today's model evaluation results. Include the confusion matrix, ROC curve, and a feature importance bar chart. Use a clean, minimal theme.
```

The [**supermemory** skill](/claude-skills-guide/articles/claude-skills-token-optimization-reduce-api-costs/) tracks experiment context across sessions:

```
/supermemory store: RandomForest with n_estimators=200, max_depth=10 achieved accuracy=0.92, f1=0.89 on customer_churn dataset 2026-03-13
/supermemory find: best accuracy on customer_churn dataset
```

This replaces manual experiment logging in notebooks and makes it easy to recall configurations weeks later.

## Machine Learning Pipeline Skills

### Data Preprocessing Automation

Claude Code can generate and refine preprocessing pipelines through conversation. Describe your data characteristics and ask for appropriate transformations:

```
/tdd
Build a preprocessing pipeline for a dataset with 10 numeric features and 3 categorical features. Handle missing values, scale numerics, and one-hot encode categoricals. Write tests for each transformation step.
```

Claude produces:

```python
from sklearn.pipeline import Pipeline
from sklearn.preprocessing import StandardScaler, OneHotEncoder
from sklearn.compose import ColumnTransformer
from sklearn.impute import SimpleImputer

numeric_features = ['age', 'income', 'score', ...]
categorical_features = ['region', 'product_type', 'tier']

numeric_transformer = Pipeline([
    ('imputer', SimpleImputer(strategy='median')),
    ('scaler', StandardScaler())
])

categorical_transformer = Pipeline([
    ('imputer', SimpleImputer(strategy='constant', fill_value='missing')),
    ('onehot', OneHotEncoder(handle_unknown='ignore'))
])

preprocessor = ColumnTransformer([
    ('num', numeric_transformer, numeric_features),
    ('cat', categorical_transformer, categorical_features)
])
```

### Model Evaluation Tracking

Use supermemory to maintain experiment history across notebook sessions:

```
/supermemory store: GradientBoosting, lr=0.1, n_estimators=300, accuracy=0.94, f1=0.91, dataset=churn_v2, date=2026-03-13
/supermemory find: all experiments with accuracy > 0.90 on churn dataset
```

Combine this with the xlsx skill to export your experiment log to a spreadsheet for sharing with colleagues:

```
/xlsx
Create a spreadsheet from these experiment results: [paste supermemory query output]. Include columns for model, hyperparameters, accuracy, f1, and date.
```

## Production Deployment Considerations

### Converting Notebooks to Scripts

When moving from exploration to production, use Claude Code to refactor notebook cells into modular Python scripts:

```
Review my Jupyter notebook attached here. Extract the training logic into src/models/train.py and the preprocessing into src/features/preprocess.py. Add docstrings and type hints.
```

Claude reads the notebook structure and produces clean, importable modules.

### API Validation

The **webapp-testing** skill validates that deployed models function correctly:

```
/webapp-testing
Test the prediction API at http://localhost:8000/predict. Send POST requests with sample feature vectors and verify the response schema contains 'prediction' (float) and 'confidence' (float between 0 and 1).
```

## Workflow Integration Strategies

### Version Control for Notebooks

Track notebook changes effectively using nbdime:

```bash
pip install nbdime
nbdime config-git --enable --global
```

This gives you readable diffs for notebook cells in git. Use it alongside Claude Code's ability to review and summarize notebook changes:

```
Review the git diff for analysis.ipynb and summarize what changed in the model training section
```

### Environment Management

Reproducible environments ensure others can run your notebooks:

```bash
uv venv .venv
uv pip install pandas scikit-learn matplotlib jupyterlab
uv pip freeze > requirements.txt
```

Ask Claude Code to verify your environment setup matches the notebook requirements before sharing:

```
Check my requirements.txt against the imports in all .ipynb files in this directory and flag any missing dependencies
```

## Practical Starting Point

Select skills based on your primary workflow needs rather than trying to use all of them at once. For most data science workflows, start with:

- `/xlsx` for data import/export and reporting
- `/pdf` for research paper and report extraction
- `/tdd` for reliable, tested transformations
- `/supermemory` for experiment tracking

Add `/webapp-testing` and `/pptx` as your needs expand into deployment validation and stakeholder reporting.

Claude skills for data science and Jupyter notebooks eliminate friction between exploration and production. By automating repetitive tasks, maintaining experiment history, and enabling reproducible workflows, these tools let data scientists focus on extracting insights rather than managing infrastructure.

---

## Related Reading

- [Best Claude Skills for Data Analysis](/claude-skills-guide/articles/best-claude-skills-for-data-analysis/) — Complete data analysis skill guide
- [Claude Skills Token Optimization: Reduce API Costs](/claude-skills-guide/articles/claude-skills-token-optimization-reduce-api-costs/) — Keep data workflows cost-efficient
- [Claude Skills Auto Invocation: How It Works](/claude-skills-guide/articles/claude-skills-auto-invocation-how-it-works/) — How skills activate automatically


Built by theluckystrike — More at [zovo.one](https://zovo.one)
