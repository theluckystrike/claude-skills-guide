#!/bin/bash
set -euo pipefail

echo "=== KEYWORD PAGE STATUS — $(date '+%Y-%m-%d %H:%M') ==="
echo ""

PASS=0; FAIL=0
for slug in \
  claude-code-dangerously-skip-permissions-guide \
  claude-code-vs-cursor-definitive-comparison-2026 \
  claude-code-process-exited-code-1-fix \
  claude-internal-server-error-fix \
  claude-agent-sdk-complete-guide \
  claude-rate-exceeded-error-fix \
  super-claude-code-framework-guide \
  claude-api-pricing-complete-guide \
  claude-code-hooks-complete-guide \
  how-to-use-claude-code-beginner-guide \
  claude-md-best-practices-definitive-guide \
  ai-coding-tools-comparison-roundup-2026 \
  claude-code-for-context-window-optimization-workflow-guide \
  claude-code-permission-modes \
  claude-code-failed-to-authenticate \
  mcp-servers-claude-code-complete-setup-2026; do
  STATUS=$(curl -sI "https://claudecodeguides.com/${slug}/" -o /dev/null -w "%{http_code}" --max-time 5 2>/dev/null || echo "ERR")
  if [ "$STATUS" = "200" ]; then
    echo "  ✓ /${slug}/"
    PASS=$((PASS + 1))
  else
    echo "  ✗ /${slug}/ → HTTP ${STATUS}"
    FAIL=$((FAIL + 1))
  fi
done

echo ""
echo "Result: ${PASS} PASS / ${FAIL} FAIL"
echo ""
echo "Run again: bash ~/claude-skills-guide/scripts/keyword-check.sh"
