---
layout: post
title: "Claude /xlsx Skill: Spreadsheet Automation Guide"
description: "How to use Claude Code's /xlsx skill to automate Excel and CSV tasks — practical examples for reports, batch processing, and data cleanup."
date: 2026-03-13
categories: [tutorials]
tags: [claude-code, claude-skills, xlsx, spreadsheets, automation]
author: "Claude Skills Guide"
reviewed: true
score: 8
---

# Claude /xlsx Skill: Spreadsheet Automation Guide

The `/xlsx` skill in Claude Code provides structured guidance for working with Excel files, CSVs, and tabular data. This tutorial covers practical scenarios: creating formatted reports, processing batches of files, and generating charts — with working code examples you can adapt immediately.

## How the /xlsx Skill Works

The `/xlsx` skill is a `.md` file stored in `~/.claude/skills/` that loads when you type `/xlsx` in Claude Code. It gives Claude specialized context for spreadsheet tasks: understanding file formats, common libraries, formula conventions, and data processing patterns.

To invoke it:

```
/xlsx

I have a folder of monthly sales CSVs. I need a Python script
that reads each one, calculates totals per region, and writes
a summary workbook with one sheet per month.
```

Claude loads the skill's guidance and produces code appropriate to your task. The skill does not run code itself — it helps Claude give you better, more accurate code for your spreadsheet work.

## Setting Up Your Environment

The `/xlsx` skill works best when you have Python with `openpyxl` and `pandas` available, or Node.js with the `xlsx` package depending on your preference. Install what you need before starting:

```bash
# Python approach
pip install openpyxl pandas

# Or with uv
uv pip install openpyxl pandas
```

Mention your environment when invoking the skill so Claude generates compatible code:

```
/xlsx

Using Python with openpyxl. I need to create a new workbook
with a header row, styled blue, and three data columns.
```

## Creating Formatted Workbooks

Here is a working example of formatted workbook creation using openpyxl:

```python
from openpyxl import Workbook
from openpyxl.styles import Font, PatternFill

def create_report(output_path, headers, rows):
    """Create a formatted Excel report."""
    wb = Workbook()
    ws = wb.active
    ws.title = "Report"

    # Write styled headers
    header_font = Font(bold=True, color="FFFFFF")
    header_fill = PatternFill(
        start_color="366092",
        end_color="366092",
        fill_type="solid"
    )

    for col_idx, header in enumerate(headers, start=1):
        cell = ws.cell(row=1, column=col_idx, value=header)
        cell.font = header_font
        cell.fill = header_fill

    # Write data rows
    for row_idx, row_data in enumerate(rows, start=2):
        for col_idx, value in enumerate(row_data, start=1):
            ws.cell(row=row_idx, column=col_idx, value=value)

    # Auto-fit column widths
    for col in ws.columns:
        max_length = max(len(str(cell.value or "")) for cell in col)
        ws.column_dimensions[col[0].column_letter].width = max_length + 4

    wb.save(output_path)
    return output_path
```

Use the `/xlsx` skill to ask for variations — adding freeze panes, applying number formats, or adding a totals row with SUM formulas.

## Processing Existing Data

Reading and analyzing spreadsheet data with pandas:

```python
import pandas as pd

def summarize_sales_file(file_path):
    """Read an Excel file and return summary statistics."""
    df = pd.read_excel(file_path, sheet_name="Sales")

    return {
        "total_revenue": df["Revenue"].sum(),
        "average_order": df["Revenue"].mean(),
        "order_count": len(df),
        "top_region": df.groupby("Region")["Revenue"].sum().idxmax()
    }
```

When the file has multiple sheets or mixed data types, describe the structure to Claude after invoking `/xlsx` — it will generate the appropriate `read_excel` parameters.

## Batch Processing Multiple Files

Processing a directory of files is a common request the `/xlsx` skill handles well:

```python
from pathlib import Path
import pandas as pd
from openpyxl import Workbook

def consolidate_monthly_reports(input_dir, output_path):
    """Merge all Excel files in a directory into one summary workbook."""
    input_path = Path(input_dir)
    wb = Workbook()
    wb.remove(wb.active)  # Remove default sheet

    for excel_file in sorted(input_path.glob("*.xlsx")):
        df = pd.read_excel(excel_file)
        ws = wb.create_sheet(title=excel_file.stem[:31])  # Sheet names max 31 chars

        # Write headers
        ws.append(list(df.columns))

        # Write rows
        for _, row in df.iterrows():
            ws.append(list(row))

    wb.save(output_path)
    return output_path
```

Ask Claude for additions like summary sheets, cross-sheet formulas, or conditional formatting across the consolidated output.

## Adding Charts

Chart generation is a common follow-on request once the data is written:

```python
from openpyxl.chart import BarChart, Reference

def add_bar_chart(ws, data_range_rows, title="Summary"):
    """Add a bar chart to a worksheet."""
    chart = BarChart()
    chart.type = "col"
    chart.style = 10
    chart.title = title
    chart.y_axis.title = "Value"
    chart.x_axis.title = "Category"

    start_row, end_row = data_range_rows
    data_ref = Reference(ws, min_col=2, min_row=start_row, max_row=end_row)
    cats_ref = Reference(ws, min_col=1, min_row=start_row + 1, max_row=end_row)

    chart.add_data(data_ref, titles_from_data=True)
    chart.set_categories(cats_ref)
    chart.height = 12
    chart.width = 20

    ws.add_chart(chart, "E2")
```

When invoking `/xlsx` for chart work, describe the chart type, what the X and Y axes represent, and where the source data lives. Claude generates the Reference configuration accurately when given that detail.

## Error Handling for Production Scripts

Spreadsheet automation scripts that run unattended need reliable error handling:

```python
def safe_read_excel(file_path, sheet_name=0):
    """Read an Excel file with informative error messages."""
    try:
        return pd.read_excel(file_path, sheet_name=sheet_name)
    except FileNotFoundError:
        raise FileNotFoundError(f"File not found: {file_path}")
    except PermissionError:
        raise PermissionError(f"File is open in another program: {file_path}")
    except Exception as e:
        raise RuntimeError(f"Could not read {file_path}: {e}") from e
```

Use `/tdd` alongside `/xlsx` to write tests for your processing functions before deploying them to run on live data.

## Performance for Large Files

For workbooks with tens of thousands of rows:

```python
# Disable automatic formula recalculation during writes
wb.calculation.calcMode = 'manual'

# Write data in bulk using ws.append() rather than cell-by-cell
for row in data_rows:
    ws.append(row)

# Re-enable recalculation on open
wb.calculation.calcMode = 'auto'
wb.calculation.fullCalcOnLoad = True
```

This reduces processing time significantly for large datasets. Ask Claude via `/xlsx` for write-optimized variants when working with files over 10,000 rows.

## Combining with Other Skills

The `/xlsx` skill pairs naturally with others:

- [`/pdf`](/claude-skills-guide/articles/best-claude-skills-for-data-analysis/) — extract invoice data from PDFs, then write it to a summary spreadsheet
- `/docx` — pull tables from Word documents into Excel for further analysis
- [`/tdd`](/claude-skills-guide/articles/best-claude-skills-for-developers-2026/) — write tests for your data transformation functions
- [`/supermemory`](/claude-skills-guide/articles/claude-skills-token-optimization-reduce-api-costs/) — save column mapping configurations between sessions

---

## Related Reading

- [Best Claude Skills for Data Analysis](/claude-skills-guide/articles/best-claude-skills-for-data-analysis/) — Full data skill overview
- [Claude Skills Token Optimization: Reduce API Costs](/claude-skills-guide/articles/claude-skills-token-optimization-reduce-api-costs/) — Keep sessions efficient
- [Claude Skills Auto Invocation: How It Works](/claude-skills-guide/articles/claude-skills-auto-invocation-how-it-works/) — How skills activate in context


Built by theluckystrike — More at [zovo.one](https://zovo.one)
