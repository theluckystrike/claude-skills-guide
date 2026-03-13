---
layout: default
title: "Claude xlsx Skill Spreadsheet Automation Tutorial"
description: "Learn how to automate spreadsheet tasks using Claude's xlsx skill. Practical examples for developers and power users working with Excel, CSV, and data manipulation."
date: 2026-03-13
author: theluckystrike
---

# Claude xlsx Skill Spreadsheet Automation Tutorial

Spreadsheet automation saves developers and analysts countless hours of repetitive work. The xlsx skill for Claude Code transforms manual Excel tasks into programmable, repeatable processes. This tutorial walks through practical automation scenarios with code examples you can apply immediately.

## Prerequisites

Before starting, ensure you have:
- Claude Code installed and configured
- Python environment with openpyxl available
- Basic familiarity with spreadsheet structures

The xlsx skill works with `.xlsx`, `.xlsm`, `.csv`, and `.tsv` files, preserving formulas and formatting throughout operations.

## Setting Up Your Environment

Initialize your Python environment with uv for dependency management:

```bash
# Create virtual environment
uv venv
uv pip install openpyxl pandas
```

The xlsx skill leverages openpyxl for low-level Excel manipulation and pandas for data analysis workflows. Both libraries integrate seamlessly with Claude's skill system.

## Basic Spreadsheet Operations

### Creating a New Workbook

The xlsx skill handles workbook creation with automatic formatting:

```python
from openpyxl import Workbook
from openpyxl.styles import Font, PatternFill

def create_report(workbook_name, data):
    """Create formatted Excel report from data dictionary"""
    wb = Workbook()
    ws = wb.active
    ws.title = "Summary"
    
    # Headers with styling
    headers = list(data.keys())
    header_font = Font(bold=True, color="FFFFFF")
    header_fill = PatternFill(start_color="366092", 
                               end_color="366092", 
                               fill_type="solid")
    
    for col, header in enumerate(headers, 1):
        cell = ws.cell(row=1, column=col, value=header)
        cell.font = header_font
        cell.fill = header_fill
    
    # Data rows
    for row_idx, row_data in enumerate(data[headers[0]], 2):
        for col_idx, header in enumerate(headers, 1):
            ws.cell(row=row_idx, column=col_idx, 
                   value=data[header][row_idx - 2])
    
    wb.save(workbook_name)
    return workbook_name
```

This pattern creates professionally formatted reports without manual cell-by-cell styling. The xlsx skill automatically applies the pattern when you invoke it with your data.

### Reading and Processing Existing Data

Extracting data from existing spreadsheets:

```python
import pandas as pd
from openpyxl import load_workbook

def extract_sales_data(file_path, sheet_name="Sales"):
    """Extract and aggregate sales data from Excel"""
    # Load with openpyxl for formula preservation
    wb = load_workbook(file_path, data_only=False)
    ws = wb[sheet_name]
    
    # Read with pandas for analysis
    df = pd.read_excel(file_path, sheet_name=sheet_name)
    
    # Calculate totals
    total_revenue = df['Revenue'].sum()
    avg_order_value = df['Revenue'].mean()
    
    return {
        'total_revenue': total_revenue,
        'avg_order_value': avg_order_value,
        'row_count': len(df)
    }
```

This hybrid approach preserves formulas using openpyxl while enabling rapid analysis with pandas. The xlsx skill manages both libraries transparently.

## Automating Recurring Reports

### Weekly Sales Dashboard

Build automated weekly reports that refresh from source data:

```python
def generate_weekly_dashboard(source_file, output_file):
    """Generate weekly sales dashboard with charts"""
    # Read source data
    df = pd.read_csv(source_file)
    
    # Calculate metrics
    weekly_stats = df.groupby('Week').agg({
        'Sales': 'sum',
        'Orders': 'count',
        'Customers': 'nunique'
    }).reset_index()
    
    # Create output workbook
    wb = Workbook()
    
    # Summary sheet
    ws_summary = wb.active
    ws_summary.title = "Weekly Summary"
    
    for row_idx, row in weekly_stats.iterrows():
        ws_summary.append([
            row['Week'],
            row['Sales'],
            row['Orders'],
            row['Customers']
        ])
    
    # Add formulas for growth calculations
    ws_summary['E1'] = "Growth %"
    for row in range(2, len(weekly_stats) + 2):
        prev_row = row - 1
        ws_summary[f'E{row}'] = f"=((C{row}-C{prev_row})/C{prev_row})*100"
    
    wb.save(output_file)
    return output_file
```

The formula preservation means your Excel dashboards maintain their calculations even when regenerated from new data.

### Batch Processing Multiple Files

Process entire directories of spreadsheets automatically:

```python
import os
from pathlib import Path

def batch_process_invoices(input_dir, output_dir):
    """Process all invoice files in directory"""
    input_path = Path(input_dir)
    output_path = Path(output_dir)
    output_path.mkdir(parents=True, exist_ok=True)
    
    results = []
    
    for invoice_file in input_path.glob("*.xlsx"):
        # Extract data from each invoice
        df = pd.read_excel(invoice_file)
        
        # Apply business logic
        df['Total'] = df['Quantity'] * df['Unit Price']
        df['Tax'] = df['Total'] * 0.08
        
        # Save processed version
        output_file = output_path / invoice_file.name
        df.to_excel(output_file, index=False)
        
        results.append({
            'file': invoice_file.name,
            'total': df['Total'].sum(),
            'tax': df['Tax'].sum()
        })
    
    return results
```

This pattern handles dozens of files without manual intervention, ideal for processing daily or weekly batches.

## Advanced Formatting and Charts

### Conditional Formatting

Apply conditional formatting programmatically:

```python
from openpyxl.formatting.rule import ColorScaleRule, FormulaRule
from openpyxl.styles import PatternFill

def apply_performance_formatting(ws, data_range="B2:B100"):
    """Apply color scale to performance metrics"""
    
    # Red-Yellow-Green color scale
    color_rule = ColorScaleRule(
        start_type='min', start_color='F8696B',
        mid_type='percentile', mid_value=50, mid_color='FFEB84',
        end_type='max', end_color='63BE7B'
    )
    
    ws.conditional_formatting.add(data_range, color_rule)
    
    # Highlight above-threshold values
    threshold_rule = FormulaRule(
        formula=['$B2>10000'],
        fill=PatternFill(start_color='C6EFCE', 
                        end_color='C6EFCE', 
                        fill_type='solid')
    )
    
    ws.conditional_formatting.add(data_range, threshold_rule)
```

Conditional formatting helps teams quickly identify trends and outliers without applying formats manually each time.

### Chart Generation

Create charts automatically from data:

```python
from openpyxl.chart import BarChart, Reference

def add_sales_chart(ws, data_start_row=2, data_end_row=13):
    """Add bar chart to worksheet"""
    
    # Create chart
    chart = BarChart()
    chart.type = "col"
    chart.style = 10
    chart.title = "Monthly Sales"
    chart.y_axis.title = "Revenue ($)"
    chart.x_axis.title = "Month"
    
    # Reference data
    data = Reference(ws, 
                     min_col=2, 
                     min_row=data_start_row - 1,
                     max_row=data_end_row,
                     max_col=2)
    
    categories = Reference(ws, 
                           min_col=1,
                           min_row=data_start_row,
                           max_row=data_end_row)
    
    chart.add_data(data, titles_from_data=True)
    chart.set_categories(categories)
    chart.height = 10
    chart.width = 20
    
    # Add to worksheet
    ws.add_chart(chart, "E2")
    
    return chart
```

Charts update automatically when source data changes, maintaining visual reports without manual recreation.

## Integration with Other Skills

The xlsx skill combines powerfully with other Claude skills:

- **pdf**: Extract data from invoices, then process with xlsx
- **docx**: Generate supporting documents from spreadsheet analysis
- **tdd**: Test spreadsheet transformation functions before production use
- **supermemory**: Maintain context across complex multi-file analysis projects
- **frontend-design**: Display spreadsheet data in web dashboards

Example pipeline:

```python
def monthly_close_pipeline(invoice_pdfs, output_dir):
    """Complete monthly close workflow"""
    # 1. Extract from PDFs
    extracted = []
    for pdf in invoice_pdfs:
        data = extract_invoice_data(pdf)  # pdf skill
        extracted.append(data)
    
    # 2. Process with xlsx
    summary = create_summary_spreadsheet(extracted, output_dir)
    
    # 3. Generate report
    generate_management_report(summary)  # docx skill
    
    return summary
```

## Error Handling and Validation

Robust spreadsheet automation requires proper error handling:

```python
def safe_spreadsheet_operation(func):
    """Decorator for spreadsheet operations with error handling"""
    def wrapper(*args, **kwargs):
        try:
            return func(*args, **kwargs)
        except FileNotFoundError as e:
            print(f"Source file not found: {e}")
            raise
        except PermissionError as e:
            print(f"File in use, cannot write: {e}")
            raise
        except Exception as e:
            print(f"Unexpected error: {e}")
            raise
    return wrapper

@safe_spreadsheet_operation
def update_spreadsheet(file_path, updates):
    """Update spreadsheet with error handling"""
    # Implementation here
    pass
```

## Performance Optimization

For large datasets, optimize your operations:

```python
# Disable calculation during bulk updates
wb.calculation.calcMode = 'manual'

# Use bulk operations
for row in data_rows:
    ws.append(row)

# Re-enable and force recalculation
wb.calculation.calcMode = 'auto'
wb.calculation.fullCalcOnLoad = True
```

This approach significantly reduces processing time for workbooks with thousands of rows.

## Conclusion

The xlsx skill transforms spreadsheet work from manual clicking to programmable automation. Start with simple file creation, then expand into batch processing, conditional formatting, and multi-skill pipelines. Each automation investment pays returns across every subsequent run.

For teams managing recurring reports or processing large data volumes, the xlsx skill provides the foundation for reliable, maintainable spreadsheet workflows.

---

Built by theluckystrike — More at [zovo.one](https://zovo.one)
