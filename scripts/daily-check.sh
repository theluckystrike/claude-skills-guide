#!/bin/bash
set -euo pipefail

echo "═══════════════════════════════════════════"
echo "CCG DAILY HEALTH CHECK — $(date '+%Y-%m-%d %H:%M')"
echo "═══════════════════════════════════════════"
echo ""

# 1. Production status (critical URLs)
echo "=== PRODUCTION STATUS ==="
PASS=0; FAIL=0
for url in "/" "/compare/" "/workflows/" "/ecosystem/" "/cost-optimization/" "/best-practices/" "/error-handling/" "/troubleshooting/" "/getting-started/" "/configuration/" "/advanced-usage/" "/diagnose/" "/calculator/" "/skill-finder/" "/model-selector/" "/generator/"; do
  STATUS=$(curl -sI "https://claudecodeguides.com${url}" -o /dev/null -w "%{http_code}" --max-time 5 2>/dev/null || echo "ERR")
  if [ "$STATUS" = "200" ]; then
    echo "  ✓ ${url} → HTTP ${STATUS}"
    PASS=$((PASS + 1))
  else
    echo "  ✗ ${url} → HTTP ${STATUS}"
    FAIL=$((FAIL + 1))
  fi
done
echo "  Result: ${PASS} PASS / ${FAIL} FAIL"
echo ""

# 2. Sitemap health
echo "=== SITEMAP ==="
SITEMAP_COUNT=$(curl -s "https://claudecodeguides.com/sitemap.xml" --max-time 10 2>/dev/null | grep -c "<loc>" || echo "ERROR")
echo "  URLs in sitemap: ${SITEMAP_COUNT}"
echo ""

# 3. Git status
echo "=== GIT STATUS ==="
cd ~/claude-skills-guide 2>/dev/null || { echo "  ERROR: repo not found"; }
UNCOMMITTED=$(git status --porcelain 2>/dev/null | wc -l | tr -d ' ')
LAST_COMMIT=$(git log --oneline -1 2>/dev/null || echo "unknown")
BRANCH=$(git branch --show-current 2>/dev/null || echo "unknown")
echo "  Branch: ${BRANCH}"
echo "  Last commit: ${LAST_COMMIT}"
echo "  Uncommitted: ${UNCOMMITTED} files"
echo ""

# 4. Article count
echo "=== CONTENT ==="
TOTAL=$(find articles/ -name "*.md" 2>/dev/null | wc -l | tr -d ' ')
NOINDEX=$(grep -rl "sitemap: false" articles/ 2>/dev/null | wc -l | tr -d ' ')
INDEXABLE=$((TOTAL - NOINDEX))
echo "  Total articles: ${TOTAL}"
echo "  Noindexed: ${NOINDEX}"
echo "  Indexable: ${INDEXABLE}"
echo ""

# 5. Tool page sizes (detect corruption)
echo "=== TOOL SIZES ==="
for tool in calculator diagnose skill-finder model-selector generator; do
  if [ -f "${tool}/index.html" ]; then
    SIZE=$(wc -c < "${tool}/index.html" | tr -d ' ')
    if [ "$SIZE" -lt 1000 ]; then
      echo "  ✗ ${tool}: ${SIZE} bytes (SUSPICIOUS — too small)"
    else
      echo "  ✓ ${tool}: ${SIZE} bytes"
    fi
  else
    echo "  ✗ ${tool}: MISSING"
  fi
done
echo ""

# 6. CI pipeline status
echo "=== CI PIPELINE ==="
LAST_RUN=$(gh run list --limit 1 --json status,conclusion,displayTitle 2>/dev/null || echo "ERROR")
echo "  ${LAST_RUN}"
echo ""

echo "═══════════════════════════════════════════"
echo "Done. Run again: bash ~/claude-skills-guide/scripts/daily-check.sh"
echo "═══════════════════════════════════════════"
