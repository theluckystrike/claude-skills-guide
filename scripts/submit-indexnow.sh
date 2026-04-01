#!/usr/bin/env bash
# submit-indexnow.sh - Submit all claudecodeguides.com URLs to IndexNow
# Pushes URLs to Bing, Yandex, and other participating search engines
# Usage: ./submit-indexnow.sh [--dry-run]

set -euo pipefail

SITE="https://claudecodeguides.com"
HOST="claudecodeguides.com"
KEY="c4ded4558ba249bbbd828bbfd67ebe80"
KEY_LOCATION="${SITE}/${KEY}.txt"
ARTICLES_DIR="$(cd "$(dirname "$0")/../articles" && pwd)"
PAYLOAD_FILE="/tmp/indexnow-payload-$(date +%Y%m%d-%H%M%S).json"
BATCH_SIZE=500
DRY_RUN=false

if [[ "${1:-}" == "--dry-run" ]]; then
    DRY_RUN=true
    echo "[DRY RUN] Will generate payload but not submit"
fi

echo "=== IndexNow Submission for ${HOST} ==="
echo "Date: $(date)"
echo ""

# Build URL list
KEY_PAGES=(
    "${SITE}/"
    "${SITE}/about/"
    "${SITE}/all-articles/"
    "${SITE}/topic/getting-started/"
    "${SITE}/topic/core-features/"
    "${SITE}/topic/advanced-usage/"
    "${SITE}/topic/development-workflow/"
    "${SITE}/topic/best-practices/"
    "${SITE}/topic/integration/"
    "${SITE}/topic/troubleshooting/"
)

# Collect all article URLs
ARTICLE_URLS=()
for file in "${ARTICLES_DIR}"/*.md; do
    filename="$(basename "$file")"
    slug="${filename%.md}"
    ARTICLE_URLS+=("${SITE}/${slug}/")
done

ALL_URLS=("${KEY_PAGES[@]}" "${ARTICLE_URLS[@]}")
TOTAL=${#ALL_URLS[@]}

echo "Key pages: ${#KEY_PAGES[@]}"
echo "Articles: ${#ARTICLE_URLS[@]}"
echo "Total URLs: ${TOTAL}"
echo ""

if [[ "$DRY_RUN" == true ]]; then
    echo "First 10 URLs:"
    for url in "${ALL_URLS[@]:0:10}"; do
        echo "  $url"
    done
    echo "  ..."
    echo ""
    echo "[DRY RUN] Exiting without submission."
    exit 0
fi

# Function to submit a batch
submit_batch() {
    local batch_file="$1"
    local batch_num="$2"
    local batch_total="$3"
    local url_count="$4"

    echo -n "  Batch ${batch_num}/${batch_total} (${url_count} URLs)... "

    local response
    local http_code
    http_code=$(curl -s -w "%{http_code}" \
        -X POST "https://api.indexnow.org/IndexNow" \
        -H "Content-Type: application/json; charset=utf-8" \
        -d @"${batch_file}" \
        -o /tmp/indexnow-response-batch-${batch_num}.txt \
        --max-time 30)

    if [[ "$http_code" == "200" || "$http_code" == "202" ]]; then
        echo "OK (HTTP ${http_code})"
        return 0
    elif [[ "$http_code" == "429" ]]; then
        echo "RATE LIMITED (HTTP 429) - waiting 60s and retrying..."
        sleep 60
        http_code=$(curl -s -w "%{http_code}" \
            -X POST "https://api.indexnow.org/IndexNow" \
            -H "Content-Type: application/json; charset=utf-8" \
            -d @"${batch_file}" \
            -o /tmp/indexnow-response-batch-${batch_num}.txt \
            --max-time 30)
        if [[ "$http_code" == "200" || "$http_code" == "202" ]]; then
            echo "OK on retry (HTTP ${http_code})"
            return 0
        else
            echo "FAILED on retry (HTTP ${http_code})"
            return 1
        fi
    else
        echo "FAILED (HTTP ${http_code})"
        cat /tmp/indexnow-response-batch-${batch_num}.txt 2>/dev/null
        echo ""
        return 1
    fi
}

# Try single batch first if under 10,000 URLs
if [[ $TOTAL -le 10000 ]]; then
    echo "Attempting single-batch submission..."

    # Build JSON payload using python3
    python3 -c "
import json, sys
urls = sys.stdin.read().strip().split('\n')
payload = {
    'host': '${HOST}',
    'key': '${KEY}',
    'keyLocation': '${KEY_LOCATION}',
    'urlList': urls
}
with open('${PAYLOAD_FILE}', 'w') as f:
    json.dump(payload, f)
" <<< "$(printf '%s\n' "${ALL_URLS[@]}")"

    http_code=$(curl -s -w "%{http_code}" \
        -X POST "https://api.indexnow.org/IndexNow" \
        -H "Content-Type: application/json; charset=utf-8" \
        -d @"${PAYLOAD_FILE}" \
        -o /tmp/indexnow-response-full.txt \
        --max-time 60)

    if [[ "$http_code" == "200" || "$http_code" == "202" ]]; then
        echo "SUCCESS: All ${TOTAL} URLs submitted (HTTP ${http_code})"
        echo ""
        echo "=== Done ==="
        rm -f "${PAYLOAD_FILE}"
        exit 0
    else
        echo "Single batch failed (HTTP ${http_code}). Falling back to chunked submission..."
        cat /tmp/indexnow-response-full.txt 2>/dev/null
        echo ""
    fi
fi

# Chunked submission
NUM_BATCHES=$(( (TOTAL + BATCH_SIZE - 1) / BATCH_SIZE ))
echo "Submitting in ${NUM_BATCHES} batches of up to ${BATCH_SIZE} URLs..."
echo ""

FAILED=0
for (( i=0; i<NUM_BATCHES; i++ )); do
    START=$(( i * BATCH_SIZE ))
    BATCH_URLS=("${ALL_URLS[@]:$START:$BATCH_SIZE}")
    BATCH_COUNT=${#BATCH_URLS[@]}
    BATCH_FILE="/tmp/indexnow-batch-${i}.json"

    python3 -c "
import json, sys
urls = sys.stdin.read().strip().split('\n')
payload = {
    'host': '${HOST}',
    'key': '${KEY}',
    'keyLocation': '${KEY_LOCATION}',
    'urlList': urls
}
with open('${BATCH_FILE}', 'w') as f:
    json.dump(payload, f)
" <<< "$(printf '%s\n' "${BATCH_URLS[@]}")"

    if ! submit_batch "${BATCH_FILE}" "$((i+1))" "${NUM_BATCHES}" "${BATCH_COUNT}"; then
        FAILED=$((FAILED + 1))
    fi

    rm -f "${BATCH_FILE}"

    # Small delay between batches to be polite
    if [[ $i -lt $((NUM_BATCHES - 1)) ]]; then
        sleep 2
    fi
done

rm -f "${PAYLOAD_FILE}"

echo ""
if [[ $FAILED -eq 0 ]]; then
    echo "=== All ${TOTAL} URLs submitted successfully ==="
else
    echo "=== WARNING: ${FAILED}/${NUM_BATCHES} batches failed ==="
    exit 1
fi
