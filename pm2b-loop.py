#!/usr/bin/env python3
"""PM2-B: Content Map & Cluster Maintainer
Runs continuously for 3+ hours, rebuilding content-map.json every 10 minutes.
"""

import os
import re
import json
import time
import subprocess
import sys
from datetime import datetime

REPO = "/Users/mike/zovo-workspaces/pm2-seo"
ARTICLES_DIR = os.path.join(REPO, "articles")
OUTPUT = os.path.join(REPO, "_data/content-map.json")
STATUS_LOG = "/Users/mike/zovo-oss/minimax-fleet/state/agent-status.md"
CYCLE_LOG = "/Users/mike/zovo-workspaces/pm2-seo/pm2b-cycles.log"
SLEEP_SECONDS = 600  # 10 minutes
TOTAL_CYCLES = 12    # cycles 9-20 remaining (~2.0 more hours)
START_CYCLE = 9      # continue from cycle 9
START_TIME = time.time()


def log(msg):
    ts = datetime.now().strftime('%H:%M:%S')
    line = f"[{ts}] {msg}"
    print(line, flush=True)
    with open(CYCLE_LOG, 'a') as f:
        f.write(line + "\n")


def assign_cluster(filename):
    fn = filename.lower()
    fn_stem = fn[:-3] if fn.endswith('.md') else fn

    # Comparisons (check early - specific pattern)
    if re.search(r'\bvs\b|-vs-|comparison|cursor|gpt-4|copilot|replit|amazon-q|windsurf|bolt\.new|bolt-new|gpt4o|opus.*gpt|gpt.*opus|openai.assistant|custom.gpt', fn_stem):
        return "comparisons"

    # Advanced: agents, orchestration, MCP, stateful, tool-use, langchain, worktrees
    if re.search(r'mcp|multi-agent|orchestrat|subagent|agent-sandbox|building-production.*agent|stateful.agent|personal.*assistant.*guide|langchain|tool.use.*function|function.calling|worktree', fn_stem):
        return "advanced"
    if re.search(r'token-optim|api-cost|context-window-management|memory.*context|context.*architecture|supermemory|persistent-context|extended-thinking', fn_stem):
        return "advanced"
    if re.search(r'protocol-updates|mcp-server|build.*ai.*assistant|build.*agent', fn_stem):
        return "advanced"

    # Troubleshooting: error fixes, debug guides, permission errors (runs BEFORE integrations)
    if re.search(r'troubleshoot|fix-guide|debug.*step|crash.*debug|permission.*denied|infinite.*loop|slow.*performance|not.*showing|not.*saving|not.*triggering|output.*format.*broken|permission.*scope', fn_stem):
        return "troubleshooting"
    if re.search(r'error.*fix|error.*solution|error.*how|error.*debug|-error-fix|-fix-2026|error-handling|timeout.*error|memory.*limit.*exceed|output.*length.*error|circular.*depend.*error|invalid.*yaml.*error|context.*window.*exceed.*fix', fn_stem):
        return "troubleshooting"
    if re.search(r'crashes.*when|crash.*loading|silently.*fail|fail.*in.*ci|work.*locally.*but.*fail|not-found.*how.*fix|not-recog|not.*invoc.*fail|produce.*different.*output|skill.*take.*so.*long', fn_stem):
        return "troubleshooting"
    if re.search(r'^why-does|^why-is-my|^how-to-fix|^how-do-i-debug|^how-do-i-rollback', fn_stem):
        return "troubleshooting"

    # Integrations: specific platform/tool integrations (expanded; excludes bare 'teams'/'terraform' to avoid false positives)
    if re.search(r'n8n|zapier|notion|supabase|github.*action|gitlab|jenkins|slack.*integration|airtable|monday|hubspot|discord.*bot|webhook|api.*integration', fn_stem):
        return "integrations"
    if re.search(r'github|gitlab|vscode|jetbrains|vim|neovim|emacs|slack|discord|ms-teams|microsoft-teams|jira|confluence|figma|vercel|netlify|railway|render|fly-io|heroku|cloudflare|helm', fn_stem):
        return "integrations"
    if re.search(r'with-github|with-gitlab|with-slack|with-linear|with-supabase|with-vercel|with-n8n|with-notion|with-discord|with-jira', fn_stem):
        return "integrations"
    if re.search(r'with-linear|linear.*tutorial|linear.*integration|linear.*project', fn_stem):
        return "integrations"

    # Workflows: TDD, testing, CI/CD, automation workflows, code review, contribute/share
    if re.search(r'tdd|automated-testing|test-driven|ci-cd|github-actions|pull-request-review|code-review|automate.*review|review.*automat|selenium|browser-testing', fn_stem):
        return "workflows"
    if re.search(r'contribute|open-source|share.*team|team.*share', fn_stem):
        return "workflows"
    if re.search(r'workflow.*guide|workflow.*tutorial|workflow.*tips|-workflow\b|automated-blog|automated-dep|automated-social|competitive-analysis|daily-standup|automated-github|seo-content.*workflow|client-report|n8n-|email-draft|git-bisect|lighthouse.*automat|migration.*workflow|llm-eval|benchmarking', fn_stem):
        return "workflows"
    if re.search(r'documentation-workflow|code-documentation|automate.*doc', fn_stem):
        return "workflows"
    if re.search(r'automate.*report|automate.*review|automate.*pull|batch.*processing|how-to-automate|how-to-share', fn_stem):
        return "workflows"

    # Best of (before use-cases so best-for-X articles are captured here)
    if re.search(r'^best-|^top-|developers-2026|skills-2026|install-first|worth-it|honest.*review', fn_stem):
        return "best-of"

    # Use cases: frontend/UI/design/mobile/backend frameworks
    if re.search(r'frontend|frontend-design|ui\b|react|canvas|theme|astro|flutter|dart|kotlin|spring-boot|scala|semantic-html|accessibility|bundle-size|express.*fastify|fastify|webpack|vite', fn_stem):
        return "use-cases"
    # Use cases: devops/infra/databases
    if re.search(r'devops|deployment|infra.*code|terraform|docker|kubernetes|aws-lambda|serverless|mongodb|postgresql|gcp|google-cloud|azure', fn_stem):
        return "use-cases"
    # Use cases: data/spreadsheet/fullstack/reports
    if re.search(r'data-analysis|data-science|jupyter|xlsx|spreadsheet|full-stack|saas-mvp|startup|solopreneur|solo-developer|freelancer|writing-and-content|seo-content|api-guide|optimize.*prompt|prompt.*accuracy', fn_stem):
        return "use-cases"
    # Use cases: for-X / building-X-with / using-claude / claude-for patterns
    if re.search(r'for-\w+|using-claude|with-claude|claude-for|building-\w+-with', fn_stem):
        return "use-cases"

    # Getting started: only install/what-is/format/how-it-works/security-basics
    if re.search(r'skill-md-file|skill.*md.*format|skill.*format.*spec|write-a-skill|how-to-write.*skill|yaml-front-matter|front-matter|what-is-claude|getting-started|install|explained-simply|directory-where', fn_stem):
        return "getting-started"
    if re.search(r'auto-invocation|auto.invoc|how-it-works|actually-works', fn_stem):
        return "getting-started"
    if re.search(r'security.*guide|compliance.*guide|gdpr|hipaa|soc2|owasp|csp.*guide|secret-scanning|credential|permissions-model|input-valid|sanitiz|segfault|hooks-system', fn_stem):
        return "getting-started"

    return "best-of"


def get_front_matter_value(content, key):
    match = re.search(rf'^{key}:\s*(.+)$', content, re.MULTILINE)
    if match:
        val = match.group(1).strip()
        if (val.startswith('"') and val.endswith('"')) or \
           (val.startswith("'") and val.endswith("'")):
            val = val[1:-1]
        return val
    return ""


def check_related_reading(content):
    return bool(re.search(r'^## Related Reading', content, re.MULTILINE))


def build_content_map():
    all_files = sorted([
        f for f in os.listdir(ARTICLES_DIR)
        if f.endswith('.md') and not f.endswith('hub.md')
    ])

    articles = []
    for filename in all_files:
        filepath = os.path.join(ARTICLES_DIR, filename)
        try:
            with open(filepath, 'r', encoding='utf-8') as fh:
                content = fh.read()
        except Exception as e:
            log(f"  WARNING: Could not read {filename}: {e}")
            continue

        title = get_front_matter_value(content, 'title')
        if not title:
            title = filename.replace('.md', '').replace('-', ' ').title()

        slug = filename.replace('.md', '')
        url = f"/claude-skills-guide/articles/{slug}/"
        cluster = assign_cluster(filename)
        linked = check_related_reading(content)

        articles.append({
            "filename": filename,
            "title": title,
            "url": url,
            "cluster": cluster,
            "linked": linked
        })

    output = {
        "generated": datetime.now().strftime("%Y-%m-%d %H:%M"),
        "total": len(articles),
        "articles": articles
    }

    with open(OUTPUT, 'w', encoding='utf-8') as fh:
        json.dump(output, fh, indent=2)

    return len(articles)


def run_cmd(cmd):
    result = subprocess.run(
        cmd, shell=True, cwd=REPO,
        stdout=subprocess.PIPE, stderr=subprocess.PIPE,
        text=True, timeout=60
    )
    return result.returncode, result.stdout.strip(), result.stderr.strip()


def resolve_conflicts():
    """Resolve any merge/rebase conflicts by taking 'theirs' for articles, ours for content-map."""
    rc, out, _ = run_cmd("git diff --name-only --diff-filter=U 2>&1")
    if rc == 0 and out:
        for conflicted in out.splitlines():
            conflicted = conflicted.strip()
            if conflicted.startswith('articles/'):
                run_cmd(f"git checkout --theirs '{conflicted}' 2>/dev/null")
                run_cmd(f"git add '{conflicted}' 2>/dev/null")
            elif conflicted == '_data/content-map.json':
                run_cmd(f"git checkout --ours '{conflicted}' 2>/dev/null")
                run_cmd(f"git add '{conflicted}' 2>/dev/null")
            else:
                run_cmd(f"git checkout --theirs '{conflicted}' 2>/dev/null")
                run_cmd(f"git add '{conflicted}' 2>/dev/null")


def git_pull():
    rc, out, err = run_cmd("git pull --rebase origin main 2>&1")
    if rc != 0:
        # Try to resolve conflicts then continue rebase
        resolve_conflicts()
        rc2, out2, err2 = run_cmd("git rebase --continue 2>&1")
        if rc2 != 0:
            run_cmd("git rebase --abort 2>/dev/null")
            # Fall back to merge
            rc3, out3, err3 = run_cmd("git fetch origin main 2>&1")
            rc4, out4, err4 = run_cmd("git merge origin/main -X theirs --no-edit 2>&1")
            return f"merge-fallback: {rc4}"
        return f"rebase-conflict-resolved: {rc2}"
    return f"pull: {rc}"


def git_commit_and_push(article_count):
    run_cmd("git add _data/content-map.json")
    rc, out, err = run_cmd(
        f'git commit -m "data: update content-map.json — {article_count} articles mapped"'
    )
    if rc != 0:
        if "nothing to commit" in out + err:
            return "no-change"
        return f"commit-failed: {err[:80]}"

    # Push with retry - handle conflicts during pull
    for attempt in range(1, 9):
        rc_pull, pull_out, pull_err = run_cmd("git pull --rebase origin main 2>&1")
        if rc_pull != 0:
            # Resolve conflicts
            resolve_conflicts()
            run_cmd("git rebase --continue 2>&1")
            rc_pull2, _, _ = run_cmd("git rebase --continue 2>&1")
            if rc_pull2 != 0:
                run_cmd("git rebase --abort 2>/dev/null")
                run_cmd("git fetch origin main 2>&1")
                run_cmd("git merge origin/main -X theirs --no-edit 2>&1")
        rc_push, out_push, err_push = run_cmd("git push origin main 2>&1")
        if rc_push == 0:
            return f"pushed (attempt {attempt})"
        run_cmd("git rebase --abort 2>/dev/null")
        time.sleep(2)
    return "push-failed-all-retries"


def log_status(message):
    with open(STATUS_LOG, 'a') as fh:
        fh.write(f"[{datetime.now().strftime('%H:%M:%S')}] {message}\n")


def run_cycle(cycle_num):
    log(f"=== Cycle {cycle_num} starting ===")

    # Step 1: Pull latest
    pull_result = git_pull()
    log(f"  git pull: {pull_result}")

    # Steps 2-6: Build content map
    article_count = build_content_map()
    log(f"  content-map built: {article_count} articles")

    # Step 7: Commit and push
    push_result = git_commit_and_push(article_count)
    log(f"  commit/push: {push_result}")

    # Step 8: Log to status file
    status_msg = f"PM2-B: content-map updated, {article_count} articles mapped (cycle {cycle_num})"
    log_status(status_msg)
    log(f"  status logged")

    return article_count


def main():
    log(f"PM2-B restarting from cycle {START_CYCLE}. {TOTAL_CYCLES} remaining cycles over ~{TOTAL_CYCLES * SLEEP_SECONDS / 3600:.1f}h")
    log(f"Cycles 1-8 already completed.")

    for cycle_num in range(START_CYCLE, START_CYCLE + TOTAL_CYCLES):
        # Sleep 10 minutes
        next_cycle_time = datetime.fromtimestamp(time.time() + SLEEP_SECONDS).strftime('%H:%M:%S')
        log(f"Sleeping {SLEEP_SECONDS}s. Next cycle at {next_cycle_time}")
        time.sleep(SLEEP_SECONDS)

        # Run cycle
        try:
            count = run_cycle(cycle_num)
        except Exception as e:
            log(f"  ERROR in cycle {cycle_num}: {e}")
            log_status(f"PM2-B: ERROR in cycle {cycle_num}: {e}")

    elapsed = (time.time() - START_TIME) / 3600
    final_cycle = START_CYCLE + TOTAL_CYCLES - 1
    log(f"PM2-B loop complete. Ran cycles {START_CYCLE}-{final_cycle} over {elapsed:.1f}h")
    log_status(f"PM2-B: COMPLETE - ran cycles {START_CYCLE}-{final_cycle} over {elapsed:.1f}h")


if __name__ == "__main__":
    main()
