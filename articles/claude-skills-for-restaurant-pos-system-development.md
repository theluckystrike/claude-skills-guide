---
layout: default
title: "Claude Skills For Restaurant Pos System"
description: "Practical guide to building restaurant POS systems using Claude Code skills: spreadsheet automation, PDF invoicing, document generation, and testing."
date: 2026-03-14
last_modified_at: 2026-04-17
categories: [use-cases]
tags: [claude-code, claude-skills, restaurant-pos, automation, development]
author: "Claude Skills Guide"
reviewed: true
score: 8
permalink: /claude-skills-for-restaurant-pos-system-development/
geo_optimized: true
last_tested: "2026-04-22"
---
# Claude Skills for Restaurant POS System Development

Building a restaurant point-of-sale system requires handling orders, inventory, payments, and reporting. Claude Code skills streamline this development by automating document generation, testing, data management, and reporting workflows. This guide covers practical applications for developers building restaurant POS solutions. For a broader look at how skills handle domain-specific automation, see the [use cases hub](/use-cases-hub/).

## Order Management with Spreadsheet Automation

Restaurant POS systems generate substantial operational data: daily sales, inventory counts, employee shifts, and customer orders. The [xlsx skill](/claude-xlsx-skill-spreadsheet-automation-tutorial/) enables rapid data analysis and report generation without manual spreadsheet manipulation.

```python
Generate daily sales report from order data
import pandas as pd
from openpyxl import Workbook

def generate_daily_report(orders: list[dict], output_path: str):
 wb = Workbook()
 ws = wb.active
 ws.title = "Daily Sales"
 
 # Headers
 ws.append(["Order ID", "Time", "Items", "Total", "Payment Method"])
 
 for order in orders:
 ws.append([
 order["id"],
 order["timestamp"],
 ", ".join(order["items"]),
 order["total"],
 order["payment"]
 ])
 
 wb.save(output_path)
```

Use the xlsx skill to automate recurring reports:

```
/xlsx create weekly-inventory.xlsx: Sheet1=inventory_data, Sheet2=reorder_suggestions, formulas for stock_alert column
```

```
/xlsx analyze sales-data.csv: calculate daily revenue, top 10 items, peak hours, group by payment method
```

## Invoice and Receipt Generation with PDF Skills

Every transaction in a restaurant POS requires documentation. The pdf skill handles invoice generation, receipt formatting, and [batch processing](/claude-code-batch-processing-with-skills-guide/) of daily transactions.

```python
Generate receipt PDF for restaurant orders
from reportlab.lib.pagesizes import letter
from reportlab.pdfgen import canvas

def generate_receipt(order: dict, filename: str):
 c = canvas.Canvas(filename, pagesize=letter)
 y = 750
 
 c.setFont("Helvetica-Bold", 16)
 c.drawString(50, y, "Restaurant Receipt")
 y -= 30
 
 c.setFont("Helvetica", 10)
 c.drawString(50, y, f"Order #: {order['order_id']}")
 y -= 15
 c.drawString(50, y, f"Date: {order['timestamp']}")
 y -= 30
 
 for item in order["items"]:
 c.drawString(50, y, f"{item['name']} x{item['qty']}")
 c.drawRightString(550, y, f"${item['price'] * item['qty']:.2f}")
 y -= 15
 
 y -= 10
 c.line(50, y, 550, y)
 y -= 20
 
 c.setFont("Helvetica-Bold", 12)
 c.drawRightString(550, y, f"Total: ${order['total']:.2f}")
 
 c.save()
```

Practical PDF commands for POS development:

```
/pdf merge all receipts in ./day-2026-03-14/*.pdf into daily-report.pdf
```

```
/pdf extract transaction totals from ./invoices/march-2026.pdf: create summary table
```

```
/pdf create receipt.pdf: Order #1234, Table 5, 2x Burger, 1x Fries, Total $24.50
```

## Testing POS Workflows with TDD and Web Testing

Restaurant POS systems involve complex state management: order creation, payment processing, inventory deduction, and kitchen ticket routing. The [tdd skill](/claude-tdd-skill-test-driven-development-workflow/) and webapp-testing skill ensure reliable POS behavior.

```python
Test order state transitions
import pytest
from pos.order import Order
from pos.payment import PaymentProcessor

class TestOrderWorkflow:
 def test_order_creation(self):
 order = Order(table_id=5)
 assert order.status == "open"
 assert order.items == []
 
 def test_add_items_updates_total(self):
 order = Order(table_id=5)
 order.add_item({"name": "Burger", "price": 12.00, "qty": 2})
 assert order.total == 24.00
 
 def test_payment_completes_order(self):
 order = Order(table_id=5)
 order.add_item({"name": "Salad", "price": 8.00, "qty": 1})
 
 processor = PaymentProcessor()
 result = processor.process_payment(order, method="card")
 
 assert result["status"] == "completed"
 assert order.status == "paid"
```

Test POS workflows with Claude:

```
/tdd write pytest tests for Order class: test_add_item, test_remove_item, test_apply_discount, test_checkout
```

```
/tdd given this failing test, implement the PaymentProcessor.process_cash() method: [paste test]
```

```
/webapp-testing verify POS frontend: add item to order, apply 10% discount, process payment, verify receipt shows correct total
```

## Menu Management and Data Pipelines

Restaurant POS systems require dynamic menu management: items, prices, modifiers, availability, and category organization. Combine spreadsheet automation with code generation for structured menu data handling.

```python
Menu item with modifiers
MENU_ITEM_SCHEMA = {
 "id": "burger-classic",
 "name": "Classic Burger",
 "price": 12.99,
 "category": "mains",
 "modifiers": {
 "cooking_temp": ["rare", "medium-rare", "medium", "medium-well", "well-done"],
 "extras": [
 {"name": "Add Cheese", "price": 1.50},
 {"name": "Add Bacon", "price": 2.00},
 {"name": "Add Avocado", "price": 2.50}
 ],
 "sides": ["fries", "salad", "onion rings"]
 },
 "available": True,
 "preparation_time_minutes": 15
}
```

Use Claude skills for menu operations:

```
/xlsx import menu-data.csv into menu.json: transform prices to cents, validate modifier arrays, output structured JSON
```

```
/xlsx create menu-pricing.xlsx: Sheet1=items, Sheet2=modifiers, Sheet3=categories, VLOOKUP for price calculations
```

## Inventory Tracking Integration

Restaurant POS systems connect closely with inventory management. Track ingredient usage, trigger reorder alerts, and calculate food costs using data automation skills.

```
/xlsx analyze inventory.csv: calculate usage per menu item, identify low-stock ingredients, suggest reorder quantities
```

```
/xlsx create food-cost-report.xlsx: link to sales data, calculate actual food cost percentage per day, highlight variance over 5%
```

## Shift and Labor Reporting

Beyond orders and inventory, restaurant POS systems must handle labor data: clock-in and clock-out times, shift assignments, overtime calculations, and tip distributions. This is an area where the xlsx skill provides immediate value because restaurant managers typically want labor data in spreadsheet form alongside sales data for cost-of-labor analysis.

```python
Compute shift duration and flag overtime
from datetime import datetime, timedelta

def calculate_shift_metrics(shifts: list[dict]) -> list[dict]:
 results = []
 for shift in shifts:
 clock_in = datetime.fromisoformat(shift["clock_in"])
 clock_out = datetime.fromisoformat(shift["clock_out"])
 duration_hours = (clock_out - clock_in).seconds / 3600

 results.append({
 "employee_id": shift["employee_id"],
 "name": shift["name"],
 "date": clock_in.date().isoformat(),
 "hours_worked": round(duration_hours, 2),
 "overtime": round(max(0, duration_hours - 8), 2),
 "role": shift["role"]
 })
 return results
```

Use the xlsx skill to generate the weekly labor summary managers review every Monday:

```
/xlsx create labor-report.xlsx: Sheet1=daily_shifts, Sheet2=weekly_totals, Sheet3=overtime_summary, conditional formatting for rows where overtime > 0
```

```
/xlsx analyze shifts-march.csv: group by employee, calculate total hours, flag employees over 40 hours this week, calculate labor cost using hourly rates from staff.csv
```

Exporting labor reports as PDFs for payroll records is a natural extension of this workflow, use the pdf skill to merge weekly labor sheets into a single monthly payroll reference document.

## Kitchen Display System Integration and Ticket Routing

A functional POS system in a full-service restaurant needs to route orders to the correct kitchen station: cold prep, grill, fryer, and expediter. Building and testing this routing logic is where the tdd skill earns its place in the workflow.

```python
Order routing logic with TDD
class KitchenRouter:
 STATION_MAP = {
 "burger": "grill",
 "steak": "grill",
 "salad": "cold-prep",
 "fries": "fryer",
 "onion-rings": "fryer",
 "dessert": "cold-prep"
 }

 def route_order_items(self, order: dict) -> dict:
 tickets = {}
 for item in order["items"]:
 station = self.STATION_MAP.get(item["category"], "expediter")
 if station not in tickets:
 tickets[station] = {"station": station, "items": [], "order_id": order["id"]}
 tickets[station]["items"].append(item)
 return tickets
```

```python
Tests generated with /tdd
class TestKitchenRouter:
 def test_burger_routes_to_grill(self):
 router = KitchenRouter()
 order = {"id": "100", "items": [{"name": "Burger", "category": "burger", "qty": 1}]}
 tickets = router.route_order_items(order)
 assert "grill" in tickets
 assert tickets["grill"]["items"][0]["name"] == "Burger"

 def test_mixed_order_splits_across_stations(self):
 router = KitchenRouter()
 order = {
 "id": "101",
 "items": [
 {"name": "Salad", "category": "salad", "qty": 1},
 {"name": "Fries", "category": "fries", "qty": 2}
 ]
 }
 tickets = router.route_order_items(order)
 assert "cold-prep" in tickets
 assert "fryer" in tickets

 def test_unknown_category_routes_to_expediter(self):
 router = KitchenRouter()
 order = {"id": "102", "items": [{"name": "Special", "category": "daily-special", "qty": 1}]}
 tickets = router.route_order_items(order)
 assert "expediter" in tickets
```

Generate this test suite with Claude:

```
/tdd write pytest tests for KitchenRouter: test routing for each station, test mixed orders split correctly, test unknown categories default to expediter, test order_id preserved in all tickets
```

## End-of-Day Closing Reports

Every restaurant closes out the day by reconciling cash drawers, reviewing voids and refunds, and summarizing sales by category. This report goes to the owner or GM and often needs to be both a digital record and a printed document. The combination of xlsx for data and pdf for the final deliverable handles this pattern well.

```python
Build end-of-day summary structure
def build_eod_summary(orders: list[dict], payments: list[dict]) -> dict:
 total_sales = sum(o["total"] for o in orders if o["status"] == "paid")
 total_voids = sum(o["total"] for o in orders if o["status"] == "voided")
 cash_total = sum(p["amount"] for p in payments if p["method"] == "cash")
 card_total = sum(p["amount"] for p in payments if p["method"] == "card")

 category_sales = {}
 for order in orders:
 if order["status"] != "paid":
 continue
 for item in order["items"]:
 cat = item.get("category", "uncategorized")
 category_sales[cat] = category_sales.get(cat, 0) + item["price"] * item["qty"]

 return {
 "date": orders[0]["date"] if orders else None,
 "total_orders": len([o for o in orders if o["status"] == "paid"]),
 "total_sales": round(total_sales, 2),
 "total_voids": round(total_voids, 2),
 "cash": round(cash_total, 2),
 "card": round(card_total, 2),
 "category_breakdown": category_sales
 }
```

Skill commands for generating the closing report package:

```
/xlsx create eod-2026-03-20.xlsx: Sheet1=order_summary, Sheet2=payment_breakdown, Sheet3=category_sales, Sheet4=voids_refunds, bold totals row, freeze header row on all sheets
```

```
/pdf create eod-report-2026-03-20.pdf: include restaurant name header, daily totals table, category breakdown chart, payment method split, footer with manager signature line
```

```
/pdf merge eod-report-2026-03-20.pdf with eod-2026-03-20.xlsx export: combine into single closing-package-2026-03-20.pdf for records
```

## Why These Skills Matter for POS Development

Restaurant POS development involves multiple data types: orders, payments, menus, inventory, labor, and reports. Claude skills handle the document and data automation that would otherwise consume significant development time.

The spreadsheet skill transforms raw transaction data into actionable insights for managers who live in Excel. The PDF skill generates the receipts, invoices, and closing reports every restaurant operation requires. Testing skills ensure the complex state transitions in order processing and kitchen routing work correctly before a single table is served.

Start with these skills when building restaurant POS solutions. They handle the operational complexity so you can focus on core POS functionality.

---

---

<div class="mastery-cta">

This site was built by 5 autonomous agents running in tmux while I was in Bali. 2,500 articles. Zero manual work. 100% quality gate pass rate.

The orchestration configs, sprint templates, and quality gates that made that possible are in the Zovo Lifetime bundle. Along with 16 CLAUDE.md templates and 80 tested prompts.

**[See how the pipeline works →](https://zovo.one/lifetime?utm_source=ccg&utm_medium=cta-skills&utm_campaign=claude-skills-for-restaurant-pos-system-development)**

$99 once. I'm a solo dev in Da Nang. This is how I scale.

</div>

Related Reading

- [Claude /xlsx Skill: Spreadsheet Automation Guide](/claude-xlsx-skill-spreadsheet-automation-tutorial/). full reference for the xlsx skill
- [Claude TDD Skill: Test-Driven Development Guide](/claude-tdd-skill-test-driven-development-workflow/). test-first workflow for complex state machines
- [Claude Code Batch Processing with Skills Guide](/claude-code-batch-processing-with-skills-guide/). batch document generation and processing
- [Claude Skills for Financial Modeling: Excel Alternative](/claude-skills-for-financial-modeling-excel-alternative/). financial data automation with Claude skills

Built by theluckystrike. More at [zovo.one](https://zovo.one)

## See Also

- [Build a Loyalty Rewards System with Claude Code (2026)](/claude-code-for-loyalty-rewards-system-development/)
