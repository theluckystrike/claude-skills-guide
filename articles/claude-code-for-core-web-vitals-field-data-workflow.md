---

layout: default
title: "Claude Code for Core Web Vitals Field Data Workflow"
description: "Learn how to build an automated workflow for collecting, analyzing, and monitoring Core Web Vitals field data using Claude Code. Practical examples and."
date: 2026-03-15
author: "Claude Skills Guide"
permalink: /claude-code-for-core-web-vitals-field-data-workflow/
categories: [guides]
tags: [claude-code, claude-skills]
reviewed: true
score: 7
---


{% raw %}
# Claude Code for Core Web Vitals Field Data Workflow

Core Web Vitals have become the gold standard for measuring user experience on the web. While lab data gives you controlled environment insights, field data reveals how real users actually experience your site. Building an automated workflow with Claude Code to collect, analyze, and act on this field data can dramatically improve your site's performance over time.

## Understanding Field Data vs Lab Data

Before diving into the workflow, it's important to understand what makes field data valuable. Field data comes from actual user sessions in the Chrome User Experience Report (CrUX), while lab data comes from controlled testing environments like Lighthouse.

The three Core Web Vitals metrics are:

- **Largest Contentful Paint (LCP)**: Measures loading performance. Good is under 2.5 seconds.
- **First Input Delay (FID)**: Measures interactivity. Good is under 100 milliseconds.
- **Cumulative Layout Shift (CLS)**: Measures visual stability. Good is under 0.1.

Field data captures the 75th percentile of these metrics across all users, giving you a realistic picture of what most visitors experience.

## Setting Up Field Data Collection

The foundation of your workflow starts with accessing Google's PageSpeed Insights API, which provides CrUX data. You'll need a Claude skill that can authenticate and query this API.

Create a skill file called `cWV-field-data.md` in your skills directory:

```yaml
---
name: cwv-field-data
description: Query Core Web Vitals field data from Google PageSpeed Insights API
tools:
  - Bash
  - Write
  - Read
---

This skill helps you fetch and analyze Core Web Vitals field data from Google's CrUX API.
```

For authentication, you'll need a Google API key with PageSpeed Insights enabled. Store this securely as an environment variable:

```bash
export GOOGLE_API_KEY="your-api-key-here"
```

## Building the Data Collection Script

Create a bash script that Claude Code can invoke to fetch field data. This script will query the PageSpeed Insights API for a given URL:

```bash
#!/bin/bash
# fetch-cwv-field-data.sh

URL="$1"
API_KEY="$2"

if [ -z "$URL" ] || [ -z "$API_KEY" ]; then
  echo "Usage: $0 <url> <api-key>"
  exit 1
fi

curl -s "https://www.googleapis.com/pagespeedonline/v5/runPagespeed?url=${URL}&key=${API_KEY}&strategy=mobile&category=PERFORMANCE" | jq '.loadingExperience.metrics'
```

The response includes field data metrics with performance categories (fast, average, slow). Parse this data to get the 75th percentile values:

```bash
./fetch-cwv-field-data.sh "https://example.com" "$GOOGLE_API_KEY" | jq -r '
.LCP.value as $lcp |
.FID.value as $fid |
.CLS.value as $cls |
"\($lcp)\n\($fid)\n\($cls)"
'
```

## Automating the Analysis Workflow

Once you have the raw data, the real value comes from analyzing trends over time. Create a workflow that Claude Code can execute to track these metrics across multiple pages.

### Step 1: Define Your URLs

Create a `urls.txt` file with all pages you want to monitor:

```
https://example.com/
https://example.com/about
https://example.com/products
https://example.com/contact
```

### Step 2: Collect Baseline Data

Use Claude Code to iterate through each URL and collect field data:

```bash
#!/bin/bash
# collect-all-cwv.sh

API_KEY="$1"
OUTPUT_DIR="cwv-data"

mkdir -p "$OUTPUT_DIR"

while read -r url; do
  filename=$(echo "$url" | sed 's|https://||' | sed 's|/|_|g' | sed 's|\.|_|g')
  ./fetch-cwv-field-data.sh "$url" "$API_KEY" > "$OUTPUT_DIR/${filename}.json"
  echo "Collected: $url"
done < urls.txt
```

### Step 3: Generate Reports

Create a Python script that analyzes the collected data and generates a readable report:

```python
import json
import os
from datetime import datetime

def analyze_cwv_data(data_dir):
    results = []
    
    for filename in os.listdir(data_dir):
        if not filename.endswith('.json'):
            continue
            
        with open(os.path.join(data_dir, filename)) as f:
            data = json.load(f)
            
        url = filename.replace('_', '/').replace('.json', '')
        url = 'https://' + url if not url.startswith('http') else url
        
        metrics = data.get('loadingExperience', {}).get('metrics', {})
        
        lcp = metrics.get('LARGEST_CONTENTFUL_PAINT_MS75', {}).get('percentile', 0)
        fid = metrics.get('FIRST_INPUT_DELAY_MS75', {}).get('percentile', 0)
        cls = metrics.get('CUMULATIVE_LAYOUT_SHIFT_SCORE75', {}).get('percentile', 0)
        
        results.append({
            'url': url,
            'lcp': lcp / 1000 if lcp else 0,  # Convert to seconds
            'fid': fid,
            'cls': cls / 100  # Convert to decimal
        })
    
    return results

def generate_report(results):
    print(f"Core Web Vitals Report - {datetime.now().date()}\n")
    print(f"{'URL':<40} {'LCP':>8} {'FID':>8} {'CLS':>8} {'Status'}")
    print("-" * 80)
    
    for r in results:
        lcp_status = "✅" if r['lcp'] < 2.5 else "⚠️"
        fid_status = "✅" if r['fid'] < 100 else "⚠️"
        cls_status = "✅" if r['cls'] < 0.1 else "⚠️"
        
        print(f"{r['url']:<40} {r['lcp']:>7.2f}s {r['fid']:>7.0f}ms {r['cls']:>7.3f} {lcp_status}{fid_status}{cls_status}")
```

## Integrating with Your Development Workflow

The most powerful aspect of using Claude Code for this workflow is integration with your existing development processes.

### Automated Alerts

Set up threshold alerts that trigger when metrics cross acceptable limits. Add this to your CI/CD pipeline:

```bash
# Check if any metric exceeds threshold
if [ $(jq '.lcp' latest.json) -gt 2500 ]; then
  echo "::warning::LCP exceeds 2.5s threshold"
fi
```

### Trend Analysis

Compare current data against historical baselines to track improvement:

```bash
# Compare with previous week's data
diff <(jq -s 'sort_by(.url)' week1.json) <(jq -s 'sort_by(.url)' week2.json)
```

This helps you understand whether performance changes are actually improving the user experience.

## Best Practices for Field Data Workflows

When implementing this workflow in your projects, keep these recommendations in mind:

**Collect data consistently**: Field data fluctuates daily based on network conditions, device types, and user locations. Run your collection on a schedule—weekly or bi-weekly—to get meaningful trends.

**Focus on percentile changes**: The 75th percentile means 25% of users have worse experiences. Small improvements at the median can significantly impact your overall user base.

**Segment your data**: Not all users have the same experience. Consider collecting data by device type (mobile vs desktop) and connection type (4G vs WiFi).

**Correlate with lab data**: When field data shows issues, use Lighthouse to diagnose the root cause in a controlled environment.

## Conclusion

Building a Claude Code workflow for Core Web Vitals field data transforms raw metrics into actionable insights. By automating collection, analysis, and reporting, you can continuously monitor and improve your site's real-world performance. Start with the scripts above, adapt them to your specific needs, and establish a regular cadence for reviewing this critical data.

The key is consistency—regular monitoring leads to measurable improvements in user experience over time.
{% endraw %}

## Related Reading

- [Claude Code for Beginners: Complete Getting Started Guide](/claude-skills-guide/claude-code-for-beginners-complete-getting-started-2026/)
- [Best Claude Skills for Developers in 2026](/claude-skills-guide/best-claude-skills-for-developers-2026/)
- [Claude Skills Guides Hub](/claude-skills-guide/guides-hub/)

