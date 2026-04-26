---
layout: default
title: "Claude Code for Data Science Analysis (2026)"
description: "Data scientists use Claude Code for exploratory analysis, feature engineering, and visualization. Practical workflows with pandas, numpy, and sklearn."
date: 2026-03-14
last_modified_at: 2026-04-17
categories: [use-cases]
tags: [claude-code, claude-skills, data-science, analysis, workflow, python]
author: "Claude Skills Guide"
reviewed: true
score: 7
permalink: /how-data-scientists-use-claude-code-for-analysis/
geo_optimized: true
last_tested: "2026-04-21"
---

# How Data Scientists Use Claude Code for Analysis

Data science workflows involve repetitive tasks: cleaning datasets, generating reports, running statistical models, and documenting findings. Claude Code with its skill system streamlines these workflows by providing specialized commands for common data science operations. This guide shows practical ways to integrate Claude Code into your analysis pipeline. from raw data ingestion through production-ready pipelines, with concrete code examples at every stage.

## Activating Data Science Skills

[Claude Code skills are Markdown files that define specialized behavior](/claude-skill-md-format-complete-specification-guide/) The system loads these skills when you invoke them with a forward slash command. For data science work, several skills prove particularly valuable.

[The `/pdf` skill handles PDF document processing](/best-claude-code-skills-to-install-first-2026/) or extracting tables from reports. The `/xlsx` skill manages spreadsheet operations, enabling you to read, write, and transform Excel files programmatically. The `/tdd` skill applies test-driven development principles, useful when building reproducible analysis pipelines.

To activate a skill in your Claude Code session, simply type:

```
/pdf
/xlsx
/tdd
```

Each skill loads its instructions and tailors Claude's responses to that domain. You can activate multiple skills in a single session. Claude accumulates their context, so a session running `/xlsx` and `/tdd` simultaneously will apply both spreadsheet handling patterns and test-writing discipline to the same problem.

## Loading and Cleaning Data

When starting a new analysis project, describe your data source to Claude. For example, tell Claude you have a CSV file with customer purchase history and need to identify trends. Claude can then guide you through loading the data with pandas, handling missing values, and performing initial exploration.

The `/xlsx` skill extends this by handling Excel-specific operations:

```python
import pandas as pd

Load data from Excel with multiple sheets
df = pd.read_excel('sales_data.xlsx', sheet_name='Q4_Transactions')

Clean and transform using skill guidance
df['date'] = pd.to_datetime(df['date'])
df = df.dropna(subset=['revenue', 'customer_id'])
```

Claude with the xlsx skill understands Excel file structures, can suggest appropriate transformations, and helps you build reproducible data cleaning scripts.

Real-world data is rarely clean. A common scenario: you receive a file with mixed date formats (`2024-01-05`, `Jan 5 2024`, `1/5/24`) in the same column. Claude helps you write a solid parser:

```python
from dateutil import parser as dateutil_parser

def normalize_dates(series):
 """
 Handle mixed date formats in a pandas Series.
 Returns a datetime Series, NaT for unparseable entries.
 """
 def safe_parse(val):
 try:
 return dateutil_parser.parse(str(val))
 except (ValueError, TypeError):
 return pd.NaT

 return series.apply(safe_parse)

df['date'] = normalize_dates(df['raw_date_column'])
invalid_count = df['date'].isna().sum()
print(f"Could not parse {invalid_count} dates. review raw_date_column for these rows")
```

Another frequent cleaning task is detecting and handling outliers without losing valid extreme values. Claude can help you build rule-based filters that document their own decisions:

```python
def flag_outliers(df, column, method='iqr', factor=1.5):
 """
 Flag outliers using IQR method. Does NOT drop rows. adds a boolean column.
 This preserves the full audit trail in the output dataset.
 """
 if method == 'iqr':
 q1 = df[column].quantile(0.25)
 q3 = df[column].quantile(0.75)
 iqr = q3 - q1
 lower = q1 - factor * iqr
 upper = q3 + factor * iqr
 df[f'{column}_outlier'] = ~df[column].between(lower, upper)
 return df

df = flag_outliers(df, 'revenue')
print(df['revenue_outlier'].value_counts())
```

## Automating Report Generation

Data scientists spend significant time creating reports. The `/pdf` skill combined with Python's report generation libraries automates much of this work.

```python
from fpdf import FPDF

def generate_analysis_report(data, output_path='analysis.pdf'):
 pdf = FPDF()
 pdf.add_page()
 pdf.set_font('Arial', 'B', 16)
 pdf.cell(0, 10, 'Q4 Sales Analysis', ln=True)

 # Add summary statistics
 pdf.set_font('Arial', '', 12)
 pdf.cell(0, 10, f"Total Revenue: ${data['revenue'].sum():,.2f}", ln=True)
 pdf.cell(0, 10, f"Records Analyzed: {len(data)}", ln=True)

 pdf.output(output_path)
 return output_path
```

This automation becomes especially powerful when combined with scheduled analysis pipelines. You set up the script once, and Claude helps you maintain it as data sources evolve.

For richer reports, the `/pdf` skill helps you structure multi-section documents with charts embedded as images. Here is a pattern that ties together matplotlib visualization and PDF generation:

```python
import matplotlib.pyplot as plt
import tempfile
import os
from fpdf import FPDF

def embed_chart_in_report(pdf, data, section_title):
 """Generate a chart as a temp PNG and embed it in the PDF."""
 fig, ax = plt.subplots(figsize=(8, 4))
 monthly = data.set_index('date').resample('M')['revenue'].sum()
 ax.plot(monthly.index, monthly.values, marker='o', linewidth=2)
 ax.set_title(section_title)
 ax.set_ylabel('Revenue ($)')
 ax.grid(True, alpha=0.3)

 with tempfile.NamedTemporaryFile(suffix='.png', delete=False) as tmp:
 fig.savefig(tmp.name, dpi=150, bbox_inches='tight')
 plt.close(fig)
 pdf.image(tmp.name, x=10, w=180)
 os.unlink(tmp.name)

def build_full_report(data, output_path='report.pdf'):
 pdf = FPDF()
 pdf.add_page()
 pdf.set_font('Arial', 'B', 18)
 pdf.cell(0, 12, 'Monthly Revenue Report', ln=True)
 embed_chart_in_report(pdf, data, 'Revenue Trend by Month')
 pdf.output(output_path)
 print(f"Report saved: {output_path}")
```

## Documenting Analysis Workflows

Reproducibility matters in data science. The `/supermemory` skill helps you maintain a knowledge base of your analysis decisions, code snippets, and findings. When you document your methodology within this skill, future iterations become faster because Claude remembers your prior approaches.

For documenting code itself, the skill system integrates with standard documentation practices:

```python
def calculate_customer_lifetime_value(transactions, discount_rate=0.1):
 """
 Calculate CLV for each customer based on transaction history.

 Args:
 transactions: DataFrame with 'customer_id', 'date', 'amount'
 discount_rate: Annual discount rate for present value calculation

 Returns:
 DataFrame with customer_id and lifetime_value columns
 """
 # Implementation here
 pass
```

Claude with appropriate skills reviews your documentation, suggests improvements, and ensures your code remains understandable to teammates.

Good documentation goes beyond docstrings. Claude helps you create README files for analysis projects that explain data sources, transformations applied, and known limitations. A typical structure Claude might scaffold:

```
project/
 README.md # Context, data sources, how to run
 data/
 raw/ # Never modified
 processed/ # Output of cleaning scripts
 notebooks/
 01_exploration.ipynb
 src/
 clean.py # Data cleaning functions
 features.py # Feature engineering
 report.py # Report generation
 tests/
 test_clean.py
```

This structure, paired with `/supermemory` context, means Claude can pick up context about your project across sessions without re-explaining the full architecture each time.

## Building Testable Analysis Pipelines

The `/tdd` skill brings test-driven development to data science workflows. While traditional TDD focuses on application code, the principles apply well to analysis pipelines:

```python
import pytest
import pandas as pd

def test_revenue_calculation():
 """Verify revenue totals match expected values."""
 test_data = pd.DataFrame({
 'amount': [100, 200, 150]
 })
 result = calculate_total_revenue(test_data)
 assert result == 450

def test_missing_data_handling():
 """Ensure missing values don't break calculations."""
 test_data = pd.DataFrame({
 'amount': [100, None, 200]
 })
 result = calculate_total_revenue(test_data)
 assert not pd.isna(result)
```

These tests catch data quality issues early and validate that your transformations produce expected outputs.

With the `/tdd` skill active, Claude pushes you to write the test before the implementation. even for data transformation functions that feel trivial. This discipline pays off when upstream data changes: a test that once passed and now fails tells you exactly which transformation broke, without manual inspection.

Here is a more complete test module for a cleaning pipeline:

```python
import pytest
import pandas as pd
import numpy as np
from src.clean import normalize_dates, flag_outliers, drop_duplicate_transactions

@pytest.fixture
def sample_transactions():
 return pd.DataFrame({
 'transaction_id': [1, 2, 2, 3],
 'customer_id': ['A', 'B', 'B', 'C'],
 'revenue': [500, 12000, 12000, 250],
 'raw_date_column': ['2024-01-05', 'Jan 6 2024', '1/6/24', 'bad-date']
 })

def test_normalize_dates_handles_mixed_formats(sample_transactions):
 result = normalize_dates(sample_transactions['raw_date_column'])
 assert result.iloc[0] == pd.Timestamp('2024-01-05')
 assert result.iloc[1] == pd.Timestamp('2024-01-06')
 assert pd.isna(result.iloc[3]), "Unparseable dates should be NaT"

def test_flag_outliers_does_not_drop_rows(sample_transactions):
 result = flag_outliers(sample_transactions, 'revenue')
 assert len(result) == len(sample_transactions), "No rows should be dropped"
 assert 'revenue_outlier' in result.columns

def test_drop_duplicate_transactions_keeps_first(sample_transactions):
 result = drop_duplicate_transactions(sample_transactions)
 assert len(result) == 3
 assert result['transaction_id'].nunique() == 3
```

## Visualizing Results

The `/frontend-design` skill occasionally helps data scientists create dashboards or interactive visualizations. While primarily aimed at web developers, the skill's guidance on layout and user experience improves any data presentation:

```python
import matplotlib.pyplot as plt

def create_revenue_trend(data, output_path='trend.png'):
 monthly = data.set_index('date').resample('M')['amount'].sum()

 plt.figure(figsize=(12, 6))
 plt.plot(monthly.index, monthly.values, marker='o')
 plt.title('Monthly Revenue Trend')
 plt.xlabel('Month')
 plt.ylabel('Revenue ($)')
 plt.grid(True, alpha=0.3)
 plt.savefig(output_path, dpi=150)
 plt.close()
```

Claude helps you iterate on visualization code, suggesting improvements for clarity and effectiveness.

For multi-panel summary dashboards, Claude can scaffold the full layout. Here is a pattern for a four-panel executive summary figure:

```python
import matplotlib.pyplot as plt
import matplotlib.gridspec as gridspec

def build_summary_dashboard(data, output_path='dashboard.png'):
 fig = plt.figure(figsize=(16, 10))
 gs = gridspec.GridSpec(2, 2, figure=fig, hspace=0.4, wspace=0.3)

 # Panel 1: Revenue over time
 ax1 = fig.add_subplot(gs[0, 0])
 monthly = data.set_index('date').resample('M')['revenue'].sum()
 ax1.plot(monthly.index, monthly.values, color='#2563eb', linewidth=2)
 ax1.set_title('Monthly Revenue')
 ax1.set_ylabel('Revenue ($)')

 # Panel 2: Customer count
 ax2 = fig.add_subplot(gs[0, 1])
 customers = data.set_index('date').resample('M')['customer_id'].nunique()
 ax2.bar(customers.index, customers.values, color='#7c3aed', width=20)
 ax2.set_title('Active Customers per Month')

 # Panel 3: Revenue by segment
 ax3 = fig.add_subplot(gs[1, 0])
 segment_rev = data.groupby('segment')['revenue'].sum().sort_values()
 ax3.barh(segment_rev.index, segment_rev.values, color='#059669')
 ax3.set_title('Revenue by Segment')

 # Panel 4: Outlier summary
 ax4 = fig.add_subplot(gs[1, 1])
 outlier_counts = data.groupby('revenue_outlier').size()
 ax4.pie(outlier_counts, labels=['Normal', 'Outlier'], autopct='%1.1f%%',
 colors=['#e5e7eb', '#ef4444'])
 ax4.set_title('Outlier Rate')

 fig.suptitle('Q4 Analysis Summary', fontsize=16, fontweight='bold')
 plt.savefig(output_path, dpi=150, bbox_inches='tight')
 plt.close()
 print(f"Dashboard saved: {output_path}")
```

## Skill Selection Reference

Different data science tasks map to different Claude Code skills. This table helps you pick the right skill before starting a task:

| Task | Recommended Skill | Why |
|---|---|---|
| Extract tables from PDF reports | `/pdf` | Understands PDF structure, table parsing |
| Transform or write Excel files | `/xlsx` | Handles sheet names, formulas, data types |
| Build a pipeline with validation | `/tdd` | Prompts test-first discipline |
| Maintain methodology notes | `/supermemory` | Persists context across sessions |
| Build a results dashboard UI | `/frontend-design` | UX guidance for charts and layout |
| Any scripted analysis task | None (plain session) | Claude's base Python knowledge is solid |

When in doubt, start with no skill active. If you find Claude is missing domain-specific patterns. for example, it keeps forgetting how your team names Excel sheets. activate the relevant skill or document your conventions using `/supermemory`.

## Integration with Existing Tools

Claude Code works alongside your existing data science stack. Whether you use Jupyter notebooks, VS Code with the Jupyter extension, or Python scripts in your terminal, Claude integrates through conversation rather than replacing your tools.

Tell Claude about your environment. mention that you use dbt for data transformation, or that your team follows specific coding standards. and Claude adapts its suggestions accordingly. This flexibility makes Claude Code valuable whether you're doing ad-hoc exploration or building production pipelines.

A concrete example: if your team uses dbt for transformations, you can paste a model's SQL into Claude and ask it to generate the corresponding pandas equivalent for local testing:

```sql
-- dbt model: revenue_by_segment.sql
SELECT
 segment,
 DATE_TRUNC('month', created_at) AS month,
 SUM(amount) AS total_revenue
FROM transactions
WHERE status = 'completed'
GROUP BY 1, 2
```

Claude translates this to:

```python
def revenue_by_segment(transactions):
 """Local pandas equivalent of the revenue_by_segment dbt model."""
 completed = transactions[transactions['status'] == 'completed'].copy()
 completed['month'] = completed['created_at'].dt.to_period('M')
 return (
 completed
 .groupby(['segment', 'month'])['amount']
 .sum()
 .reset_index()
 .rename(columns={'amount': 'total_revenue'})
 )
```

This lets you run the same logic locally. with the test suite from `/tdd`. before the dbt model runs in production.

## Getting Started

Begin by identifying repetitive tasks in your workflow. Common starting points include:

- Data cleaning scripts that need documentation
- Report generation that takes manual effort
- Analysis pipelines that require validation tests

For each task, invoke the relevant skill in Claude Code and describe what you're trying to accomplish. Claude guides you through implementation while applying best practices from that domain.

The skill system continues evolving as the community contributes new capabilities. Check the official Claude documentation for newly available skills, and consider creating custom skills for your team's specific workflows.

---


**Try it:** Paste your error into our [Error Diagnostic](/diagnose/) for an instant fix.
---

<div class="mastery-cta">

I'm a solo developer in Vietnam. 50K Chrome extension users. $500K+ on Upwork. 5 Claude Max subscriptions running agent fleets in parallel.

These are my actual CLAUDE.md templates, orchestration configs, and prompts. Not a course. Not theory. The files I copy into every project before I write a line of code.

**[See what's inside →](https://zovo.one/lifetime?utm_source=ccg&utm_medium=cta-default&utm_campaign=how-data-scientists-use-claude-code-for-analysis)**

$99 once. Free forever. 47/500 founding spots left.

</div>

Related Reading

- [Best Claude Code Skills to Install First (2026)](/best-claude-code-skills-to-install-first-2026/)
- [Claude Skills for Data Science and Jupyter Notebooks](/claude-skills-for-data-science-and-jupyter-notebooks/)
- [Claude Supermemory Skill: Persistent Context Explained](/claude-supermemory-skill-persistent-context-explained/)
- [Use Cases Hub](/use-cases-hub/)

Built by theluckystrike. More at [zovo.one](https://zovo.one)


**Find the right skill →** Browse 155+ skills in our [Skill Finder](/skill-finder/).

