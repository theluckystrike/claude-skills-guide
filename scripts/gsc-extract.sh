#!/bin/bash
set -euo pipefail

echo "=== CCG SEO METRICS EXTRACT — $(date '+%Y-%m-%d %H:%M') ==="
echo ""

# Sitemap URL count
echo "--- Sitemap ---"
SITEMAP_URLS=$(curl -s "https://claudecodeguides.com/sitemap.xml" --max-time 15 2>/dev/null | grep -c "<loc>" || echo "ERROR")
echo "  Sitemap URLs: ${SITEMAP_URLS}"

# robots.txt check
echo ""
echo "--- robots.txt ---"
ROBOTS=$(curl -s "https://claudecodeguides.com/robots.txt" --max-time 5 2>/dev/null)
SITEMAP_LINE=$(echo "$ROBOTS" | grep -i "sitemap:" || echo "MISSING")
echo "  Sitemap declaration: ${SITEMAP_LINE}"
DISALLOW_COUNT=$(echo "$ROBOTS" | grep -c "Disallow:" || echo "0")
ALLOW_COUNT=$(echo "$ROBOTS" | grep -c "Allow:" || echo "0")
echo "  Disallow rules: ${DISALLOW_COUNT}"
echo "  Allow rules: ${ALLOW_COUNT}"

# Page sizes for key pages
echo ""
echo "--- Page Sizes ---"
for url in "/" "/compare/" "/workflows/" "/ecosystem/" "/cost-optimization/" "/diagnose/" "/calculator/"; do
  SIZE=$(curl -s "https://claudecodeguides.com${url}" --max-time 10 2>/dev/null | wc -c | tr -d ' ')
  echo "  ${url}: ${SIZE} bytes"
done

# IndexNow key check
echo ""
echo "--- IndexNow ---"
INDEXNOW=$(curl -sI "https://claudecodeguides.com/c4ded4558ba249bbbd828bbfd67ebe80.txt" -o /dev/null -w "%{http_code}" --max-time 5 2>/dev/null || echo "ERR")
echo "  Key file: HTTP ${INDEXNOW}"

# Feed check
echo ""
echo "--- Feed ---"
FEED_STATUS=$(curl -sI "https://claudecodeguides.com/feed.xml" -o /dev/null -w "%{http_code}" --max-time 5 2>/dev/null || echo "ERR")
FEED_ITEMS=$(curl -s "https://claudecodeguides.com/feed.xml" --max-time 10 2>/dev/null | grep -c "<entry>" || echo "0")
echo "  Feed status: HTTP ${FEED_STATUS}"
echo "  Feed entries: ${FEED_ITEMS}"

echo ""
echo "=== Done. Save this output for Day 14 comparison. ==="
echo "Run again: bash ~/claude-skills-guide/scripts/gsc-extract.sh"
