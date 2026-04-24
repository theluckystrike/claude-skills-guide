---
title: "Claude Code for SOC 2 Evidence (2026)"
description: "Claude Code for SOC 2 Evidence — practical guide with working examples, tested configurations, and tips for developer workflows."
permalink: /claude-code-soc2-evidence-collection-2026/
last_tested: "2026-04-21"
---

## Why Claude Code for SOC 2 Evidence

SOC 2 Type II audits require months of evidence: change management logs, access reviews, vulnerability scan reports, backup verification, incident response records, and monitoring dashboards. Engineering teams waste hundreds of hours manually exporting screenshots, pulling Git logs, and formatting spreadsheets for auditors who need evidence mapped to specific Trust Services Criteria (CC6, CC7, CC8).

Claude Code generates evidence collection scripts that pull data from Git, CI/CD pipelines, cloud provider APIs, and identity providers, then formats it into the tabular evidence packages that auditors expect. It maps each artifact to the specific SOC 2 criteria it satisfies.

## The Workflow

### Step 1: Setup

```bash
pip install PyGithub boto3 google-auth requests \
  pandas openpyxl jinja2

# CLI tools
# gh (GitHub CLI), aws (AWS CLI), gcloud (GCP CLI)

mkdir -p soc2/{collectors,evidence,reports,templates}
```

### Step 2: Automated Evidence Collectors

```python
# soc2/collectors/change_management.py
"""Collect SOC 2 CC8.1 change management evidence from Git and CI/CD."""
import subprocess
import json
import pandas as pd
from datetime import datetime, timedelta
from pathlib import Path

AUDIT_PERIOD_DAYS = 365
MAX_COMMITS = 50000


def collect_git_evidence(repo_path: str, days: int = AUDIT_PERIOD_DAYS) -> pd.DataFrame:
    """Extract change management evidence from Git history."""
    assert Path(repo_path).is_dir(), f"Not a directory: {repo_path}"

    since_date = (datetime.now() - timedelta(days=days)).strftime("%Y-%m-%d")

    result = subprocess.run(
        ["git", "log", f"--since={since_date}",
         "--pretty=format:%H|%an|%ae|%aI|%s",
         "--no-merges"],
        capture_output=True, text=True, cwd=repo_path)

    assert result.returncode == 0, f"Git log failed: {result.stderr}"

    rows = []
    for line in result.stdout.strip().split("\n"):
        if not line:
            continue
        parts = line.split("|", 4)
        if len(parts) == 5:
            rows.append({
                "commit_hash": parts[0][:8],
                "author": parts[1],
                "email": parts[2],
                "date": parts[3],
                "message": parts[4],
            })

    assert len(rows) <= MAX_COMMITS, \
        f"Too many commits: {len(rows)}"

    df = pd.DataFrame(rows)
    df["soc2_criteria"] = "CC8.1 - Changes to Information Systems"
    return df


def collect_pr_reviews(repo: str, token: str,
                       days: int = AUDIT_PERIOD_DAYS) -> pd.DataFrame:
    """Collect pull request review evidence from GitHub."""
    from github import Github

    assert token, "GitHub token required"
    g = Github(token)
    gh_repo = g.get_repo(repo)

    since = datetime.now() - timedelta(days=days)
    pulls = gh_repo.get_pulls(state="closed", sort="updated",
                              direction="desc")

    rows = []
    for pr in pulls:
        if pr.merged_at and pr.merged_at >= since:
            reviews = pr.get_reviews()
            review_list = [
                {"reviewer": r.user.login, "state": r.state}
                for r in reviews
            ]
            approved = any(r["state"] == "APPROVED" for r in review_list)

            rows.append({
                "pr_number": pr.number,
                "title": pr.title[:100],
                "author": pr.user.login,
                "created": pr.created_at.isoformat(),
                "merged": pr.merged_at.isoformat(),
                "reviewers": ", ".join(r["reviewer"] for r in review_list),
                "approved": approved,
                "review_count": len(review_list),
            })

        if len(rows) >= 1000:
            break

    df = pd.DataFrame(rows)
    df["soc2_criteria"] = "CC8.1 - Peer Review of Changes"
    return df


def collect_ci_cd_evidence(repo_path: str) -> pd.DataFrame:
    """Collect CI/CD pipeline execution evidence."""
    # Check for GitHub Actions
    workflows_dir = Path(repo_path) / ".github" / "workflows"
    rows = []

    if workflows_dir.exists():
        for wf in workflows_dir.glob("*.yml"):
            with open(wf) as f:
                content = f.read()
            has_tests = "test" in content.lower() or "pytest" in content.lower()
            has_lint = "lint" in content.lower() or "eslint" in content.lower()
            has_security = ("security" in content.lower()
                           or "snyk" in content.lower()
                           or "semgrep" in content.lower())
            rows.append({
                "workflow_file": wf.name,
                "has_tests": has_tests,
                "has_linting": has_lint,
                "has_security_scan": has_security,
                "status": "Active",
            })

    df = pd.DataFrame(rows)
    df["soc2_criteria"] = "CC7.1 - System Monitoring"
    return df


def collect_access_review(provider: str = "github",
                          org: str = "", token: str = "") -> pd.DataFrame:
    """Collect access review evidence (CC6.1, CC6.2, CC6.3)."""
    rows = []

    if provider == "github" and org and token:
        from github import Github
        g = Github(token)
        gh_org = g.get_organization(org)

        for member in gh_org.get_members():
            teams = [t.name for t in member.get_teams()
                     if t.organization.login == org]
            rows.append({
                "user": member.login,
                "name": member.name or "N/A",
                "role": "admin" if gh_org.has_in_members(member) else "member",
                "teams": ", ".join(teams),
                "two_factor": member.two_factor_authentication or "Unknown",
                "last_active": "See GitHub audit log",
            })

    df = pd.DataFrame(rows)
    df["soc2_criteria"] = "CC6.1 - Logical Access Security"
    return df


def generate_evidence_package(repo_path: str, output_dir: str,
                              github_token: str = "",
                              github_repo: str = "") -> None:
    """Generate complete SOC 2 evidence package."""
    Path(output_dir).mkdir(parents=True, exist_ok=True)

    # Change management
    git_evidence = collect_git_evidence(repo_path)
    git_evidence.to_excel(
        f"{output_dir}/CC8.1_change_management.xlsx", index=False)
    print(f"CC8.1: {len(git_evidence)} change records")

    # CI/CD monitoring
    cicd_evidence = collect_ci_cd_evidence(repo_path)
    cicd_evidence.to_excel(
        f"{output_dir}/CC7.1_cicd_monitoring.xlsx", index=False)
    print(f"CC7.1: {len(cicd_evidence)} CI/CD workflows")

    # PR reviews (if GitHub token provided)
    if github_token and github_repo:
        pr_evidence = collect_pr_reviews(github_repo, github_token)
        pr_evidence.to_excel(
            f"{output_dir}/CC8.1_peer_reviews.xlsx", index=False)
        print(f"CC8.1: {len(pr_evidence)} reviewed PRs")

    print(f"\nEvidence package: {output_dir}/")


if __name__ == "__main__":
    import sys
    assert len(sys.argv) >= 2, \
        "Usage: python change_management.py <repo_path>"

    generate_evidence_package(
        repo_path=sys.argv[1],
        output_dir="evidence",
        github_token=os.environ.get("GITHUB_TOKEN", ""),
        github_repo=os.environ.get("GITHUB_REPO", ""),
    )
```

### Step 3: Validate Evidence

```bash
export GITHUB_TOKEN="ghp_..."
export GITHUB_REPO="org/repo"
python3 soc2/collectors/change_management.py /path/to/repo
# Expected: Excel files in evidence/ mapped to SOC 2 criteria

# Verify completeness
ls -la evidence/
# Expected: CC6.1_access_review.xlsx, CC7.1_cicd_monitoring.xlsx,
#           CC8.1_change_management.xlsx, CC8.1_peer_reviews.xlsx
```

## CLAUDE.md for SOC 2 Evidence

```markdown
# SOC 2 Evidence Collection Rules

## Standards
- AICPA Trust Services Criteria (2017)
- SOC 2 Type II audit requirements
- Common Criteria: CC6 (Access), CC7 (Monitoring), CC8 (Change Mgmt)

## File Formats
- .xlsx (evidence artifacts for auditors)
- .json (raw API responses, archived)
- .pdf (screenshots and reports)

## Libraries
- PyGithub 2.x (GitHub API)
- boto3 1.34+ (AWS evidence)
- pandas, openpyxl (reporting)
- jinja2 (report templates)

## Testing
- Evidence must cover full audit period (12 months Type II)
- Every artifact must map to a specific TSC criterion
- Automated collection must match manual spot-check

## Evidence Requirements
- CC6.1: Access provisioning and deprovisioning logs
- CC6.2: MFA enforcement evidence
- CC6.3: Access review completion records
- CC7.1: Monitoring and alerting configuration
- CC7.2: Vulnerability scan results
- CC8.1: Change management and peer review logs
```

## Common Pitfalls

- **Evidence gaps in audit period:** Auditors check for continuous coverage. A 2-week gap in monitoring evidence fails the criterion. Claude Code verifies date continuity in all collected evidence.
- **Unmapped artifacts:** An Excel spreadsheet without a TSC criterion mapping is useless to the auditor. Claude Code adds the `soc2_criteria` column to every evidence artifact.
- **Stale access reviews:** Collecting current GitHub org members does not prove quarterly access reviews happened. Claude Code generates diff reports between quarters showing added/removed users.

## Related

- [Claude Code for PCI-DSS Scanning](/claude-code-pci-dss-code-scanning-2026/)
- [Claude Code for FDA 21 CFR Part 11](/claude-code-fda-21-cfr-part-11-validation-2026/)
- [CLAUDE.md File Guide](/claude-md-file-complete-guide-what-it-does/)


## Frequently Asked Questions

### Do I need a paid Anthropic plan to use this?

Claude Code works with any Anthropic API plan, including the free tier. However, the free tier has lower rate limits (requests per minute and tokens per minute) that may slow down multi-step workflows. For professional use, the Build or Scale plan provides higher limits and priority access during peak hours.

### How does this affect token usage and cost?

The token cost depends on the size of your prompts and Claude's responses. Typical development tasks consume 10K-50K tokens per interaction. Using a CLAUDE.md file and skills reduces exploration tokens by 50-80%, which directly lowers costs. Monitor your usage at console.anthropic.com/settings/billing.

### Can I customize this for my specific project?

Yes. All Claude Code behavior can be customized through CLAUDE.md (project rules), `.claude/settings.json` (permissions), and `.claude/skills/` (domain knowledge). The most impactful customization is adding your project's specific patterns, conventions, and common commands to CLAUDE.md so Claude Code follows your standards from the start.

### What happens when Claude Code makes a mistake?

Claude Code creates files and edits through standard filesystem operations, so all changes are visible in `git diff`. If a change is wrong, revert it with `git checkout -- <file>` for a single file or `git stash` for all changes. Claude Code does not make irreversible changes unless you explicitly allow destructive commands in settings.json.


## Practical Details

When working with Claude Code on this topic, keep these implementation details in mind:

**Project Configuration.** Your CLAUDE.md should include specific references to how your project handles this area. Include file paths, naming conventions, and any project-specific patterns that differ from defaults. Claude Code reads this file at session start and uses it to guide all operations.

**Integration with Existing Tools.** Claude Code works alongside your existing development tools rather than replacing them. It respects .gitignore for file visibility, uses your project's installed dependencies, and follows the build/test scripts defined in package.json (or equivalent). Ensure your toolchain is working correctly before involving Claude Code.

**Performance Considerations.** For large codebases (10,000+ files), Claude Code's file scanning can be slow if not properly scoped. Use `.claudeignore` to exclude generated directories (dist, build, .next, coverage) and dependency directories (node_modules, vendor). This typically reduces scan time by 80-90%.

**Version Control Integration.** All changes Claude Code makes are regular filesystem operations visible to git. Use `git diff` after each significant change to review what was modified. For experimental changes, create a branch first with `git checkout -b experiment/topic` so you can easily discard or keep the results.


## Related Guides

- [Claude Code ISO 27001 Evidence](/claude-code-iso27001-evidence-collection-workflow/)

<script type="application/ld+json">
{
  "@context": "https://schema.org",
  "@type": "FAQPage",
  "mainEntity": [
    {
      "@type": "Question",
      "name": "Do I need a paid Anthropic plan to use this?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "Claude Code works with any Anthropic API plan, including the free tier. However, the free tier has lower rate limits (requests per minute and tokens per minute) that may slow down multi-step workflows. For professional use, the Build or Scale plan provides higher limits and priority access during peak hours."
      }
    },
    {
      "@type": "Question",
      "name": "How does this affect token usage and cost?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "The token cost depends on the size of your prompts and Claude's responses. Typical development tasks consume 10K-50K tokens per interaction. Using a CLAUDE.md file and skills reduces exploration tokens by 50-80%, which directly lowers costs. Monitor your usage at console.anthropic.com/settings/billing."
      }
    },
    {
      "@type": "Question",
      "name": "Can I customize this for my specific project?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "Yes. All Claude Code behavior can be customized through CLAUDE.md (project rules), `.claude/settings.json` (permissions), and `.claude/skills/` (domain knowledge). The most impactful customization is adding your project's specific patterns, conventions, and common commands to CLAUDE.md so Claude Code follows your standards from the start."
      }
    },
    {
      "@type": "Question",
      "name": "What happens when Claude Code makes a mistake?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "Claude Code creates files and edits through standard filesystem operations, so all changes are visible in `git diff`. If a change is wrong, revert it with `git checkout -- <file>` for a single file or `git stash` for all changes. Claude Code does not make irreversible changes unless you explicitly allow destructive commands in settings.json. When working with Claude Code on this topic, keep these implementation details in mind: **Project Configuration.** Your CLAUDE.md should include specific references to how your project handles this area. Include file paths, naming conventions, and any project-specific patterns that differ from defaults. Claude Code reads this file at session start and uses it to guide all operations. **Integration with Existing Tools.** Claude Code works alongside your existing development tools rather than replacing them. It respects .gitignore for file visibility, uses your project's installed dependencies, and follows the build/test scripts defined in package.json (or equivalent). Ensure your toolchain is working correctly before involving Claude Code. **Performance Considerations.** For large codebases (10,000+ files), Claude Code's file scanning can be slow if not properly scoped. Use `.claudeignore` to exclude generated directories (dist, build, .next, coverage) and dependency directories (node_modules, vendor). This typically reduces scan time by 80-90%. **Version Control Integration.** All changes Claude Code makes are regular filesystem operations visible to git. Use `git diff` after each significant change to review what was modified. For experimental changes, create a branch first with `git checkout -b experiment/topic` so you can easily discard or keep the results."
      }
    }
  ]
}
</script>
