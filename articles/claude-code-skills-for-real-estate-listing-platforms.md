---
layout: default
title: "Claude Code Skills for Real Estate (2026)"
description: "Practical Claude Code skills for building real estate listing platforms: property data management, map integrations, search filtering, and automated."
date: 2026-03-14
last_modified_at: 2026-04-17
categories: [use-cases]
tags: [claude-code, claude-skills, real-estate, listing-platforms]
author: "Claude Skills Guide"
reviewed: true
score: 8
permalink: /claude-code-skills-for-real-estate-listing-platforms/
render_with_liquid: false
geo_optimized: true
---

{% raw %}
Building a real estate listing platform involves managing property data, integrating maps, implementing search filters, and handling media assets. Claude Code provides skills that accelerate development across these areas. This guide covers practical skills for real estate developers. from bulk data ingestion and document generation to geospatial filtering, automated testing, and production deployment considerations.

xlsx: Property Data Management

[Real estate platforms rely heavily on structured data](/claude-code-skills-for-travel-booking-platforms/). property listings, agent information, pricing history, and neighborhood statistics. The xlsx skill handles spreadsheet operations that power your backend data pipeline.

```python
Generate property listings from spreadsheet data
import openpyxl

wb = openpyxl.load_workbook('listings.xlsx')
sheet = wb.active

properties = []
for row in sheet.iter_rows(min_row=2, values_only=True):
 properties.append({
 'address': row[0],
 'price': row[1],
 'bedrooms': row[2],
 'sqft': row[3],
 'listing_agent': row[4]
 })
```

Use this skill to import bulk property data, generate CSV exports for listing feeds, or create dynamic pricing reports. The skill supports formulas, so you can calculate metrics like price-per-square-foot automatically:

```
=A2/B2 // Price per sqft for each listing
=AVERAGE(C2:C100) // Average property price
```

Beyond basic imports, the xlsx skill shines when your MLS (Multiple Listing Service) feed delivers data in spreadsheet format. Many regional MLS providers export in Excel-compatible formats, and building a reliable ingestion pipeline saves hours of manual data entry each week. A real-world pattern is to schedule a daily import job that reads the MLS export, computes derived fields, and upserts records into your database:

```python
import openpyxl
from datetime import datetime

def ingest_mls_export(filepath: str, db_session) -> dict:
 wb = openpyxl.load_workbook(filepath)
 sheet = wb.active

 stats = {'inserted': 0, 'updated': 0, 'skipped': 0}

 for row in sheet.iter_rows(min_row=2, values_only=True):
 mls_id, address, price, beds, baths, sqft, status, listed_date = row[:8]

 if not mls_id:
 stats['skipped'] += 1
 continue

 price_per_sqft = round(price / sqft, 2) if sqft else None
 days_on_market = (datetime.now().date() - listed_date).days if listed_date else None

 existing = db_session.query(Listing).filter_by(mls_id=mls_id).first()
 if existing:
 existing.price = price
 existing.status = status
 existing.days_on_market = days_on_market
 stats['updated'] += 1
 else:
 db_session.add(Listing(
 mls_id=mls_id,
 address=address,
 price=price,
 bedrooms=beds,
 bathrooms=baths,
 sqft=sqft,
 price_per_sqft=price_per_sqft,
 status=status,
 listed_date=listed_date
 ))
 stats['inserted'] += 1

 db_session.commit()
 return stats
```

This pattern handles the common MLS workflow: new listings get inserted, price reductions update existing records, and sold or expired listings flip their status field without data loss.

pdf: Property Document Generation

Real estate transactions require documents. listing agreements, disclosure forms, and marketing flyers. [The pdf skill automates PDF creation from property data](/what-is-the-best-claude-skill-for-generating-documentation/).

```python
from reportlab.lib.pagesizes import letter
from reportlab.platypus import SimpleDocTemplate, Paragraph, Spacer

def generate_listing_sheet(property_data):
 doc = SimpleDocTemplate(f"listing_{property_data['id']}.pdf", pagesize=letter)
 story = []

 story.append(Paragraph(f"<b>{property_data['address']}</b>", "Title"))
 story.append(Spacer(1, 12))
 story.append(Paragraph(f"Price: ${property_data['price']:,}", "Normal"))
 story.append(Paragraph(f"Beds: {property_data['bedrooms']} | Baths: {property_data['bathrooms']}", "Normal"))
 story.append(Paragraph(f"SQFT: {property_data['sqft']}", "Normal"))

 doc.build(story)
```

This approach generates consistent marketing materials for each listing. You can also merge multiple PDFs into a neighborhood guide or annual report.

A more complete listing sheet includes a photo placeholder, key metrics table, agent contact block, and QR code linking to the live listing URL. The pdf skill can handle all of these elements in a single document generation call:

```python
from reportlab.lib import colors
from reportlab.lib.pagesizes import letter
from reportlab.platypus import SimpleDocTemplate, Paragraph, Spacer, Table, TableStyle, Image
from reportlab.lib.units import inch

def generate_full_listing_sheet(prop, output_path):
 doc = SimpleDocTemplate(output_path, pagesize=letter,
 leftMargin=0.75*inch, rightMargin=0.75*inch,
 topMargin=0.75*inch, bottomMargin=0.75*inch)
 story = []

 # Header
 story.append(Paragraph(prop['address'], styles['Title']))
 story.append(Paragraph(f"Listed at ${prop['price']:,}", styles['Heading2']))
 story.append(Spacer(1, 0.2*inch))

 # Key facts table
 data = [
 ['Bedrooms', prop['bedrooms'], 'Bathrooms', prop['bathrooms']],
 ['Square Feet', f"{prop['sqft']:,}", 'Lot Size', prop.get('lot_size', 'N/A')],
 ['Year Built', prop.get('year_built', 'N/A'), 'Garage', prop.get('garage', 'N/A')],
 ['Price/SqFt', f"${prop['price'] // prop['sqft']}", 'MLS #', prop['mls_id']],
 ]
 table = Table(data, colWidths=[1.5*inch, 1.5*inch, 1.5*inch, 1.5*inch])
 table.setStyle(TableStyle([
 ('BACKGROUND', (0,0), (-1,0), colors.lightblue),
 ('GRID', (0,0), (-1,-1), 0.5, colors.grey),
 ('FONTNAME', (0,0), (-1,-1), 'Helvetica'),
 ('ALIGN', (0,0), (-1,-1), 'CENTER'),
 ]))
 story.append(table)
 story.append(Spacer(1, 0.2*inch))

 # Description
 story.append(Paragraph(prop.get('description', ''), styles['Normal']))

 doc.build(story)
```

Listing sheets generated programmatically ensure every property leaves your platform with the same professional format, regardless of which agent submitted the data.

docx: Listing Descriptions and Marketing Copy

The docx skill creates and edits Word documents for listing descriptions, agent contracts, and client communications. For real estate platforms, this skill helps maintain consistent branding across documents.

```
/docx
Create a listing description document for this property:
- Address: 123 Oak Street
- Type: Single-family home, 3 bed / 2 bath, 1,850 sqft
- Features: Updated kitchen, hardwood floors, attached garage, private backyard
- Price: $485,000

Include a professional description paragraph, feature highlights list,
and a section with neighborhood amenities.
```

Invoke the docx skill whenever you add a new property to auto-generate listing content from your property data.

The docx skill is especially valuable for agents who need branded client proposal packets. A typical packet contains a cover page, comparative market analysis (CMA) summary, recommended list price breakdown, marketing strategy overview, and an agent bio page. Rather than re-assembling this packet manually for each client, you can template it in docx format and populate fields from your database:

```python
from docx import Document
from docx.shared import Pt, Inches

def generate_cma_packet(prop, comparable_sales, agent, output_path):
 doc = Document('templates/cma_template.docx')

 # Replace template placeholders
 for paragraph in doc.paragraphs:
 if '{{ADDRESS}}' in paragraph.text:
 paragraph.text = paragraph.text.replace('{{ADDRESS}}', prop['address'])
 if '{{LIST_PRICE}}' in paragraph.text:
 paragraph.text = paragraph.text.replace('{{LIST_PRICE}}', f"${prop['recommended_price']:,}")
 if '{{AGENT_NAME}}' in paragraph.text:
 paragraph.text = paragraph.text.replace('{{AGENT_NAME}}', agent['name'])

 # Populate the comparable sales table
 table = doc.tables[0]
 for sale in comparable_sales[:5]:
 row = table.add_row()
 row.cells[0].text = sale['address']
 row.cells[1].text = f"${sale['sold_price']:,}"
 row.cells[2].text = str(sale['sqft'])
 row.cells[3].text = f"${sale['sold_price'] // sale['sqft']}/sqft"
 row.cells[4].text = str(sale['days_on_market'])

 doc.save(output_path)
```

This pattern produces a ready-to-print or email PDF-convertible packet in seconds rather than the 30-45 minutes it typically takes to assemble manually.

canvas-design: Property Visualization

Visual marketing drives real estate engagement. The canvas-design skill generates promotional graphics, social media images, and email campaign banners without leaving your development environment.

```
Create a property highlight image
"Generate a 1200x630px listing card showing a modern home with price tag,
bed/bath count, and 'View Details' button in the bottom right"
```

This skill produces PNG or PDF outputs that you can directly embed in your platform's marketing emails or social posts. Use it for:

- Property spotlight images for email newsletters
- Open house announcements
- Price change alerts
- Neighborhood comparison graphics

For automated social media campaigns, pair the canvas-design skill with a scheduling library. Each time a property's status changes. new listing, price reduction, under contract, sold. a new graphic is generated and queued to post:

```python
import anthropic
import base64
from pathlib import Path

def generate_status_graphic(prop, status: str) -> bytes:
 client = anthropic.Anthropic()

 prompt_map = {
 'new_listing': f"Real estate listing card: '{prop['address']}', ${prop['price']:,}, "
 f"{prop['bedrooms']}bd/{prop['bathrooms']}ba, {prop['sqft']:,} sqft. "
 f"Bold 'NEW LISTING' badge, clean modern design, 1200x628px.",
 'price_reduced': f"Real estate price reduction card: '{prop['address']}', "
 f"NOW ${prop['price']:,}. 'PRICE REDUCED' banner, before/after price.",
 'sold': f"Real estate sold card: '{prop['address']}'. "
 f"Bold 'SOLD' overlay, celebration design, 1200x628px.",
 }

 message = client.messages.create(
 model="claude-opus-4-6",
 max_tokens=1024,
 messages=[{"role": "user", "content": prompt_map.get(status, prompt_map['new_listing'])}]
 )

 return message.content[0].text
```

## Map Integration: Location-Based Features

Real estate platforms require map integrations. While Claude Code doesn't directly handle map APIs, the skills here support the coordinate data that drives mapping libraries.

```javascript
// Transform property coordinates for map display
const properties = [
 { address: "123 Main St", lat: 40.7128, lng: -74.0060, price: 850000 },
 { address: "456 Oak Ave", lat: 40.7580, lng: -73.9855, price: 1200000 }
];

// Filter properties within map viewport
function getVisibleProperties(bounds, properties) {
 return properties.filter(p =>
 p.lat >= bounds.south && p.lat <= bounds.north &&
 p.lng >= bounds.west && p.lng <= bounds.east
 );
}
```

Combine coordinate data with the xlsx skill to manage neighborhood boundaries and school district zones stored in spreadsheets.

For production platforms, you need efficient proximity search. Storing a geometry column in PostgreSQL with PostGIS and querying with ST_DWithin is the standard approach for "properties within X miles of this point" queries:

```sql
-- Find all active listings within 5 miles of a user's location
SELECT
 id,
 address,
 price,
 bedrooms,
 bathrooms,
 sqft,
 ST_Distance(coordinates::geography, ST_MakePoint(-73.9857, 40.7484)::geography) / 1609.34 AS miles_away
FROM listings
WHERE
 status = 'active'
 AND ST_DWithin(
 coordinates::geography,
 ST_MakePoint(-73.9857, 40.7484)::geography,
 8046.72 -- 5 miles in meters
 )
ORDER BY miles_away ASC
LIMIT 50;
```

On the frontend, a common pattern is to debounce the map's `bounds_changed` event so you don't fire an API call on every pixel of panning:

```javascript
import { useCallback, useEffect, useRef } from 'react';

function useMapListings(mapRef) {
 const debounceTimer = useRef(null);

 const fetchListingsInView = useCallback(async () => {
 if (!mapRef.current) return;

 const bounds = mapRef.current.getBounds();
 const params = new URLSearchParams({
 south: bounds.getSouth(),
 north: bounds.getNorth(),
 west: bounds.getWest(),
 east: bounds.getEast(),
 });

 const res = await fetch(`/api/listings/in-bounds?${params}`);
 return res.json();
 }, [mapRef]);

 const handleBoundsChanged = useCallback(() => {
 clearTimeout(debounceTimer.current);
 debounceTimer.current = setTimeout(fetchListingsInView, 400);
 }, [fetchListingsInView]);

 return { handleBoundsChanged };
}
```

This approach keeps the map responsive while avoiding excessive API calls.

## Data Visualization

Claude Code generates visualization code for market trends, price histories, and neighborhood statistics. Describe what you need and Claude will implement the chart or dashboard component.

```
"Create a line chart showing median home prices over 12 months,
using a gradient from blue to orange, clean minimal style"
```

Generate custom visualizations for:

- Price trend graphs
- Days-on-market comparisons
- Inventory levels by neighborhood
- Price distribution histograms

For a market statistics dashboard, a common visualization stack pairs Chart.js or Recharts with aggregated data from your database. Here is a Recharts implementation for a price history chart that is readable on both desktop and mobile:

```jsx
import { LineChart, Line, XAxis, YAxis, CartesianGrid, Tooltip, ResponsiveContainer } from 'recharts';

function PriceHistoryChart({ data }) {
 const formatted = data.map(d => ({
 month: new Date(d.month).toLocaleDateString('en-US', { month: 'short', year: '2-digit' }),
 medianPrice: d.median_price,
 avgPrice: d.avg_price,
 }));

 const formatPrice = (value) => `$${(value / 1000).toFixed(0)}k`;

 return (
 <ResponsiveContainer width="100%" height={320}>
 <LineChart data={formatted} margin={{ top: 8, right: 16, left: 8, bottom: 8 }}>
 <CartesianGrid strokeDasharray="3 3" stroke="#e5e7eb" />
 <XAxis dataKey="month" tick={{ fontSize: 12 }} />
 <YAxis tickFormatter={formatPrice} tick={{ fontSize: 12 }} />
 <Tooltip formatter={(value) => [`$${value.toLocaleString()}`, '']} />
 <Line type="monotone" dataKey="medianPrice" stroke="#3b82f6" strokeWidth={2}
 dot={false} name="Median Price" />
 <Line type="monotone" dataKey="avgPrice" stroke="#f97316" strokeWidth={2}
 dot={false} name="Average Price" strokeDasharray="5 5" />
 </LineChart>
 </ResponsiveContainer>
 );
}
```

Days-on-market bar charts segmented by neighborhood give buyers and sellers a quick read on market velocity. Inventory level line charts show seasonal patterns that help agents advise clients on timing. Price distribution histograms help buyers understand whether a listing is priced at the low end or high end of comparable properties.

## Search and Filtering Implementation

Effective search functionality separates professional platforms from basic listings. Here's how to structure property search:

```python
from typing import List, Dict, Optional

def filter_properties(
 properties: List[Dict],
 min_price: Optional[int] = None,
 max_price: Optional[int] = None,
 min_beds: Optional[int] = None,
 max_beds: Optional[int] = None,
 property_type: Optional[str] = None,
 min_sqft: Optional[int] = None
) -> List[Dict]:
 results = properties

 if min_price:
 results = [p for p in results if p['price'] >= min_price]
 if max_price:
 results = [p for p in results if p['price'] <= max_price]
 if min_beds:
 results = [p for p in results if p['bedrooms'] >= min_beds]
 if property_type:
 results = [p for p in results if p['property_type'] == property_type]
 if min_sqft:
 results = [p for p in results if p['sqft'] >= min_sqft]

 return results
```

Add geospatial filtering for proximity to schools, transit, or amenities. Store amenity locations in your database and query within radius thresholds.

For a production API endpoint, you typically translate these filters into parameterized SQL rather than in-memory list filtering. This is more efficient for large datasets and lets the database use indexes:

```python
from sqlalchemy import and_, or_
from sqlalchemy.orm import Session

def search_listings(session: Session, filters: dict, page: int = 1, per_page: int = 24):
 query = session.query(Listing).filter(Listing.status == 'active')

 if filters.get('min_price'):
 query = query.filter(Listing.price >= filters['min_price'])
 if filters.get('max_price'):
 query = query.filter(Listing.price <= filters['max_price'])
 if filters.get('min_beds'):
 query = query.filter(Listing.bedrooms >= filters['min_beds'])
 if filters.get('max_beds'):
 query = query.filter(Listing.bedrooms <= filters['max_beds'])
 if filters.get('property_type'):
 query = query.filter(Listing.property_type == filters['property_type'])
 if filters.get('min_sqft'):
 query = query.filter(Listing.sqft >= filters['min_sqft'])
 if filters.get('keywords'):
 keyword = f"%{filters['keywords']}%"
 query = query.filter(
 or_(Listing.address.ilike(keyword), Listing.description.ilike(keyword))
 )

 # Sort options
 sort_map = {
 'price_asc': Listing.price.asc(),
 'price_desc': Listing.price.desc(),
 'newest': Listing.listed_date.desc(),
 'dom_asc': Listing.days_on_market.asc(),
 }
 sort = filters.get('sort', 'newest')
 query = query.order_by(sort_map.get(sort, Listing.listed_date.desc()))

 total = query.count()
 listings = query.offset((page - 1) * per_page).limit(per_page).all()

 return {
 'listings': listings,
 'total': total,
 'page': page,
 'pages': (total + per_page - 1) // per_page,
 }
```

A well-designed search API also surfaces saved searches and email alerts. When a new listing matches a saved search, your platform can immediately notify interested buyers. a feature that dramatically improves buyer engagement metrics.

## Automated Testing with TDD

Quality real estate platforms require rigorous testing. [Use the TDD skill to write tests first](/claude-tdd-skill-test-driven-development-workflow/):

```
"Write tests for property search filtering function covering
price ranges, bedroom counts, property types, and square footage"
```

This generates comprehensive test suites covering edge cases like zero results, invalid inputs, and boundary conditions.

A concrete test suite for the search and filtering logic looks like this:

```python
import pytest
from app.search import search_listings, filter_properties

SAMPLE_PROPERTIES = [
 {'id': 1, 'address': '10 Main St', 'price': 300000, 'bedrooms': 2, 'sqft': 900, 'property_type': 'condo'},
 {'id': 2, 'address': '20 Oak Ave', 'price': 550000, 'bedrooms': 3, 'sqft': 1500, 'property_type': 'single_family'},
 {'id': 3, 'address': '30 Elm Rd', 'price': 850000, 'bedrooms': 4, 'sqft': 2400, 'property_type': 'single_family'},
 {'id': 4, 'address': '40 Pine Ln', 'price': 1200000, 'bedrooms': 5, 'sqft': 3800, 'property_type': 'single_family'},
]

class TestFilterProperties:
 def test_price_range_filters_correctly(self):
 results = filter_properties(SAMPLE_PROPERTIES, min_price=400000, max_price=900000)
 assert len(results) == 2
 assert all(400000 <= p['price'] <= 900000 for p in results)

 def test_min_beds_excludes_smaller_homes(self):
 results = filter_properties(SAMPLE_PROPERTIES, min_beds=4)
 assert len(results) == 2
 assert all(p['bedrooms'] >= 4 for p in results)

 def test_property_type_filter(self):
 results = filter_properties(SAMPLE_PROPERTIES, property_type='condo')
 assert len(results) == 1
 assert results[0]['id'] == 1

 def test_combined_filters(self):
 results = filter_properties(
 SAMPLE_PROPERTIES,
 min_price=500000, max_price=1000000,
 min_beds=3, property_type='single_family'
 )
 assert len(results) == 2

 def test_no_results_returns_empty_list(self):
 results = filter_properties(SAMPLE_PROPERTIES, min_price=5000000)
 assert results == []

 def test_empty_filters_returns_all(self):
 results = filter_properties(SAMPLE_PROPERTIES)
 assert len(results) == len(SAMPLE_PROPERTIES)
```

Beyond unit tests, real estate platforms benefit from integration tests that verify the full request-to-response cycle, including database queries and pagination. Property data integrity tests. ensuring that price-per-sqft is always computed correctly and that sold properties don't appear in active searches. catch the kind of subtle bugs that erode user trust.

## Handling Media Assets

Property photos are the most critical content on a real estate listing platform. Photo management involves upload, storage, resizing, and delivery at the right resolution for each context.

```python
from PIL import Image
import boto3
import uuid
from io import BytesIO

def process_property_photo(image_file, property_id: str, position: int) -> dict:
 s3 = boto3.client('s3')
 img = Image.open(image_file)

 # Convert to RGB if needed (handles PNG with transparency)
 if img.mode in ('RGBA', 'P'):
 img = img.convert('RGB')

 photo_id = str(uuid.uuid4())
 urls = {}

 # Generate multiple sizes
 sizes = {
 'thumbnail': (400, 300),
 'card': (800, 600),
 'full': (1600, 1200),
 }

 for size_name, dimensions in sizes.items():
 resized = img.copy()
 resized.thumbnail(dimensions, Image.LANCZOS)

 buffer = BytesIO()
 resized.save(buffer, format='JPEG', quality=85, optimize=True)
 buffer.seek(0)

 key = f"listings/{property_id}/photos/{photo_id}/{size_name}.jpg"
 s3.put_object(
 Bucket='your-listings-bucket',
 Key=key,
 Body=buffer,
 ContentType='image/jpeg',
 CacheControl='max-age=31536000',
 )
 urls[size_name] = f"https://cdn.yourplatform.com/{key}"

 return {'photo_id': photo_id, 'position': position, 'urls': urls}
```

Storing multiple resolutions lets you serve thumbnail-sized images on the search results grid, card-sized images on the listing detail page, and full-resolution images in the photo gallery lightbox. keeping page load times fast at every entry point.

## Putting It Together

A production real estate platform combines these skills:

1. Ingest listing data via xlsx imports from MLS exports, running nightly as a scheduled job
2. Generate marketing materials using pdf and canvas-design, triggered when listings go active
3. Create listing descriptions and CMA packets through docx automation
4. Visualize market data through Chart.js or Recharts components powered by aggregated database queries
5. Build search functionality with parameterized SQL, PostGIS proximity filters, and debounced map viewport queries
6. Process property photos into multiple resolutions stored on S3 or equivalent object storage
7. Test everything using TDD workflows, covering unit, integration, and data integrity scenarios

Each skill handles a specific domain, reducing context switching and maintaining consistency across your codebase. The combination also creates natural boundaries for team ownership. backend engineers own the data ingestion and search layer, frontend engineers own the visualization and map components, and marketing teams can generate collateral without touching the codebase.

## Deployment Considerations

For a real estate platform serving tens of thousands of listings, a few infrastructure decisions matter more than others:

| Concern | Recommendation | Why It Matters |
|---|---|---|
| Search indexing | PostgreSQL full-text search + PostGIS | Handles keyword + proximity queries without a separate search service |
| Photo delivery | CDN with signed URLs | Keeps S3 costs low while preventing hotlinking |
| MLS sync | Nightly batch job with idempotent upserts | Avoids duplicate listings on re-import |
| Map tile caching | Mapbox or Google Maps with tile caching | Reduces API costs on high-traffic pages |
| Listing cache | Redis with 5-minute TTL | Absorbs read traffic spikes without hitting the database |

The xlsx and pdf skills reduce the engineering burden on the data pipeline and document generation side, freeing engineering time for the user-facing search and map experience that drives platform differentiation.

---


**Try it:** Estimate your monthly spend with our [Cost Calculator](/calculator/).
---

<div class="mastery-cta">

This site was built by 5 autonomous agents running in tmux while I was in Bali. 2,500 articles. Zero manual work. 100% quality gate pass rate.

The orchestration configs, sprint templates, and quality gates that made that possible are in the Zovo Lifetime bundle. Along with 16 CLAUDE.md templates and 80 tested prompts.

**[See how the pipeline works →](https://zovo.one/lifetime?utm_source=ccg&utm_medium=cta-skills&utm_campaign=claude-code-skills-for-real-estate-listing-platforms)**

$99 once. I'm a solo dev in Da Nang. This is how I scale.

</div>

Related Reading

- [Automated Testing Pipeline with Claude TDD Skill](/claude-tdd-skill-test-driven-development-workflow/). write tests for property search filtering and pricing logic
- [Automated Code Documentation Workflow with Claude Skills](/automated-code-documentation-workflow-with-claude-skills/). generate property listing documentation automatically
- [Claude Code Skills for Travel Booking Platforms](/claude-code-skills-for-travel-booking-platforms/). similar patterns for booking and availability management
- [Use Cases Hub](/use-cases-hub/). explore Claude Code skills for property and booking platforms
- [Claude Code Skills for Nonprofit Donation Platforms (2026)](/claude-code-skills-for-nonprofit-donation-platforms/)

Built by theluckystrike. More at [zovo.one](https://zovo.one)
{% endraw %}


