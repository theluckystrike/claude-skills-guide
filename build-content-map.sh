#!/usr/bin/env bash
# PM2-B: Content Map Builder
# Scans articles/, assigns clusters, checks for Related Reading, builds content-map.json

REPO="/Users/mike/zovo-workspaces/pm2-seo"
STATUS_LOG="/Users/mike/zovo-oss/minimax-fleet/state/agent-status.md"
OUTPUT="$REPO/_data/content-map.json"

build_content_map() {
  local generated
  generated=$(date '+%Y-%m-%d %H:%M')

  # Get all non-hub md files
  local files=()
  while IFS= read -r f; do
    files+=("$f")
  done < <(ls "$REPO/articles/"*.md 2>/dev/null | grep -v 'hub\.md$')

  local total="${#files[@]}"

  # Build JSON articles array
  local articles_json=""
  local first=1

  for filepath in "${files[@]}"; do
    local filename
    filename=$(basename "$filepath")
    local slug="${filename%.md}"

    # Extract title from front matter
    local title
    title=$(grep -m1 '^title:' "$filepath" 2>/dev/null | sed 's/^title:[[:space:]]*//' | sed 's/^"//' | sed 's/"$//' | sed "s/^'//; s/'$//")
    if [[ -z "$title" ]]; then
      title="$slug"
    fi

    # Extract description from front matter
    local description
    description=$(grep -m1 '^description:' "$filepath" 2>/dev/null | sed 's/^description:[[:space:]]*//' | sed 's/^"//' | sed 's/"$//' | sed "s/^'//; s/'$//")

    # Assign cluster based on filename pattern matching
    local cluster="best-of"
    local fn_lower
    fn_lower=$(echo "$filename" | tr '[:upper:]' '[:lower:]')

    # Check patterns in order (most specific first)
    if echo "$fn_lower" | grep -qE 'vs|comparison|cursor|gpt|copilot|replit|amazon|windsurf|bolt'; then
      cluster="comparisons"
    # Advanced: MCP, agents, orchestration, token/context optimization
    elif echo "$fn_lower" | grep -qE 'mcp|multi-agent|orchestrat|subagent|agent-sandbox|building-production.*agent|stateful.agent|personal.*assistant.*guide|langchain|tool.use.*function|function.calling|worktree'; then
      cluster="advanced"
    elif echo "$fn_lower" | grep -qE 'token-optim|api-cost|context-window-management|memory.*context|context.*architecture|supermemory|persistent-context|extended-thinking'; then
      cluster="advanced"
    elif echo "$fn_lower" | grep -qE 'protocol-updates|mcp-server|build.*ai.*assistant|build.*agent'; then
      cluster="advanced"
    # Troubleshooting: runs BEFORE integrations to catch error/debug articles mentioning platforms
    elif echo "$fn_lower" | grep -qE 'troubleshoot|fix-guide|debug.*step|crash.*debug|permission.*denied|infinite.*loop|slow.*performance|not.*showing|not.*saving|not.*triggering|output.*format.*broken|permission.*scope'; then
      cluster="troubleshooting"
    elif echo "$fn_lower" | grep -qE 'error.*fix|error.*solution|error.*how|error.*debug|-error-fix|-fix-2026|error-handling|timeout.*error|memory.*limit.*exceed|output.*length.*error|circular.*depend.*error|invalid.*yaml.*error|context.*window.*exceed.*fix'; then
      cluster="troubleshooting"
    elif echo "$fn_lower" | grep -qE 'crashes.*when|crash.*loading|silently.*fail|fail.*in.*ci|work.*locally.*but.*fail|not-found.*how.*fix|not-recog'; then
      cluster="troubleshooting"
    elif echo "$fn_lower" | grep -qE '^why-does|^why-is-my|^how-to-fix|^how-do-i-debug|^how-do-i-rollback'; then
      cluster="troubleshooting"
    # Integrations: platforms and tools (no bare 'teams'/'terraform' to avoid false positives)
    elif echo "$fn_lower" | grep -qE 'n8n|zapier|notion|supabase|github.*action|gitlab|jenkins|slack.*integration|airtable|monday|hubspot|discord.*bot|webhook|api.*integration'; then
      cluster="integrations"
    elif echo "$fn_lower" | grep -qE 'github|gitlab|vscode|jetbrains|vim|neovim|emacs|slack|discord|ms-teams|microsoft-teams|jira|confluence|figma|vercel|netlify|railway|render|fly-io|heroku|cloudflare|helm'; then
      cluster="integrations"
    elif echo "$fn_lower" | grep -qE 'with-github|with-gitlab|with-slack|with-linear|with-supabase|with-vercel|with-n8n|with-notion|with-discord|with-jira'; then
      cluster="integrations"
    elif echo "$fn_lower" | grep -qE 'with-linear|linear.*tutorial|linear.*integration|linear.*project'; then
      cluster="integrations"
    # Workflows: TDD, CI/CD, automation, code review, contribute/share
    elif echo "$fn_lower" | grep -qE 'tdd|automated-testing|test-driven|ci-cd|github-actions|pull-request-review|code-review|automate.*review|review.*automat|selenium|browser-testing'; then
      cluster="workflows"
    elif echo "$fn_lower" | grep -qE 'contribute|open-source|share.*team|team.*share'; then
      cluster="workflows"
    elif echo "$fn_lower" | grep -qE 'workflow.*guide|workflow.*tutorial|workflow.*tips|-workflow|automated-blog|automated-dep|automated-social|competitive-analysis|daily-standup|automated-github|seo-content.*workflow|client-report|email-draft|benchmarking|migration.*workflow'; then
      cluster="workflows"
    elif echo "$fn_lower" | grep -qE 'documentation-workflow|code-documentation|automate.*doc'; then
      cluster="workflows"
    elif echo "$fn_lower" | grep -qE 'automate.*report|automate.*review|automate.*pull|batch.*processing|how-to-automate|how-to-share'; then
      cluster="workflows"
    # Best of (before use-cases so best-for-X articles land here)
    elif echo "$fn_lower" | grep -qE '^best-|^top-|developers-2026|skills-2026|install-first|worth-it|honest.*review'; then
      cluster="best-of"
    # Use cases: frameworks, devops/infra, data, building-X patterns
    elif echo "$fn_lower" | grep -qE 'frontend|ui|react|canvas|theme|astro|flutter|dart|kotlin|spring-boot|scala|semantic-html|accessibility|bundle-size|fastify|webpack|vite'; then
      cluster="use-cases"
    elif echo "$fn_lower" | grep -qE 'devops|deployment|infra.*code|terraform|docker|kubernetes|aws-lambda|serverless|mongodb|postgresql|gcp|google-cloud|azure'; then
      cluster="use-cases"
    elif echo "$fn_lower" | grep -qE 'data-analysis|data-science|jupyter|xlsx|spreadsheet|full-stack|saas-mvp|startup|solopreneur|solo-developer|freelancer|writing-and-content|seo-content|api-guide'; then
      cluster="use-cases"
    elif echo "$fn_lower" | grep -qE 'for-[a-z]|using-claude|with-claude|claude-for|building-[a-z].*-with'; then
      cluster="use-cases"
    # Getting started: install/what-is/format/how-it-works/security-basics only
    elif echo "$fn_lower" | grep -qE 'skill-md-file|skill.*md.*format|skill.*format.*spec|write-a-skill|how-to-write.*skill|yaml-front-matter|front-matter|what-is-claude|getting-started|install|explained-simply|directory-where'; then
      cluster="getting-started"
    elif echo "$fn_lower" | grep -qE 'auto-invocation|auto.invoc|how-it-works|actually-works'; then
      cluster="getting-started"
    elif echo "$fn_lower" | grep -qE 'security.*guide|compliance.*guide|gdpr|hipaa|soc2|owasp|csp.*guide|secret-scanning|credential|permissions-model|input-valid|sanitiz|hooks-system'; then
      cluster="getting-started"
    fi

    # Check for Related Reading section
    local linked="false"
    if grep -q '## Related Reading' "$filepath" 2>/dev/null; then
      linked="true"
    fi

    # Build URL
    local url="/claude-skills-guide/articles/${slug}/"

    # Escape title and description for JSON
    local title_escaped
    title_escaped=$(echo "$title" | sed 's/\\/\\\\/g' | sed 's/"/\\"/g')

    # Append to JSON
    if [[ $first -eq 1 ]]; then
      first=0
    else
      articles_json="${articles_json},"
    fi

    articles_json="${articles_json}
    {
      \"filename\": \"${filename}\",
      \"title\": \"${title_escaped}\",
      \"url\": \"${url}\",
      \"cluster\": \"${cluster}\",
      \"linked\": ${linked}
    }"
  done

  # Write the JSON file
  cat > "$OUTPUT" <<EOF
{
  "generated": "${generated}",
  "total": ${total},
  "articles": [${articles_json}
  ]
}
EOF

  echo "$total"
}

# Run one cycle
cd "$REPO" || exit 1

# Step 1: Pull latest
git pull --rebase origin main 2>/dev/null || (git rebase --abort 2>/dev/null && git merge origin/main -X theirs --no-edit 2>/dev/null)

# Step 2-6: Build the content map
MAPPED=$(build_content_map)

# Step 7: Commit and push
git add _data/content-map.json

ARTICLE_COUNT=$(ls articles/*.md 2>/dev/null | grep -v hub | wc -l | tr -d ' ')
git commit -m "data: update content-map.json — ${ARTICLE_COUNT} articles mapped"

for i in {1..8}; do
  git pull --rebase origin main 2>/dev/null && git push origin main && break
  git rebase --abort 2>/dev/null
  sleep 2
done

# Step 8: Log status
echo "[$(date '+%H:%M:%S')] PM2-B: content-map updated, ${MAPPED} articles mapped" >> "$STATUS_LOG"

echo "Done: ${MAPPED} articles mapped"
