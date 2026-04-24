---
layout: default
title: "Claude Code ISO 27001 Evidence"
description: "Learn how to build automated ISO 27001 evidence collection workflows using Claude Code skills. Streamline your compliance audits with practical."
date: 2026-03-14
last_modified_at: 2026-04-17
categories: [guides]
tags: [claude-code, iso27001, compliance, evidence-collection, automation, security, claude-skills]
author: "Claude Skills Guide"
permalink: /claude-code-iso27001-evidence-collection-workflow/
reviewed: true
score: 7
render_with_liquid: false
geo_optimized: true
---
{% raw %}
Claude Code ISO 27001 Evidence Collection Workflow

ISO 27001 certification requires organizations to demonstrate systematic evidence collection across 93 security controls. For many teams, this means manually gathering screenshots, configuration dumps, and audit logs, a time-consuming process prone to gaps and inconsistencies. Claude Code transforms this workflow by enabling automated, reproducible evidence collection that integrates directly into your development and operations pipelines.

## Understanding the Evidence Collection Challenge

ISO 27001 evidence falls into several categories that Claude Code can help automate:

- Configuration evidence: Firewall rules, access control lists, encryption settings
- Operational evidence: Log excerpts, incident reports, change management records
- Process evidence: Policy acknowledgments, training records, risk assessments
- Technical evidence: Vulnerability scan results, penetration test reports, backup verification

Traditional approaches require manual documentation or expensive GRC platforms. Claude Code offers a middle ground, lightweight automation that captures evidence during normal development operations.

## Manual vs. Automated Evidence Collection

Before committing to an automation approach, it helps to understand exactly where manual workflows break down:

| Dimension | Manual Collection | Automated (Claude Code) | Enterprise GRC Platform |
|-----------|------------------|------------------------|------------------------|
| Setup time | None | 1–3 days | Weeks to months |
| Per-audit effort | 40–120 hours | 2–4 hours | 4–8 hours |
| Evidence freshness | Point-in-time | Continuous or scheduled | Scheduled |
| Audit trail | Ad hoc | Git history + timestamps | Platform logs |
| Cost | Staff time only | Staff time + compute | $20k–$200k+ per year |
| Customizability | High (but slow) | High (code) | Low (vendor lock-in) |
| Scalability | Poor | Good | Excellent |

For organizations with fewer than 200 employees or those in an early compliance maturity phase, the Claude Code approach delivers most of the automation benefit at a fraction of the GRC platform cost.

## Core Claude Code Skills for Evidence Collection

1. File Operations Skill for Documenting Configurations

The file operations skill enables Claude Code to read, analyze, and document configuration files as evidence:

```python
def collect_configuration_evidence(config_paths):
 """Collect configuration files as audit evidence"""
 evidence = {}
 for path in config_paths:
 with open(path, 'r') as f:
 evidence[path] = {
 'content': f.read(),
 'timestamp': get_audit_timestamp(),
 'hash': calculate_hash(f)
 }
 return evidence
```

This pattern works for documenting:
- AWS/IAM policy files
- Kubernetes manifests
- Application configuration files
- Database security settings

A more production-hardened version adds error handling, encoding normalization, and structured metadata:

```python
import hashlib
import json
from datetime import datetime, timezone
from pathlib import Path
from typing import Optional

def get_audit_timestamp() -> str:
 """Return ISO 8601 UTC timestamp suitable for audit records."""
 return datetime.now(timezone.utc).isoformat()

def calculate_file_hash(path: Path) -> str:
 """Calculate SHA-256 hash of file contents."""
 sha256 = hashlib.sha256()
 with open(path, 'rb') as f:
 for chunk in iter(lambda: f.read(8192), b''):
 sha256.update(chunk)
 return sha256.hexdigest()

def collect_configuration_evidence(
 config_paths: list[str],
 control_id: str,
 collector: str = "automated",
 notes: Optional[str] = None
) -> dict:
 """
 Collect configuration files as ISO 27001 audit evidence.

 Args:
 config_paths: List of file paths to collect
 control_id: ISO 27001 control identifier (e.g. 'A.9.1.1')
 collector: Name or ID of the collecting system/person
 notes: Optional narrative notes about this evidence

 Returns:
 Structured evidence record ready for archival
 """
 evidence_record = {
 'control_id': control_id,
 'collection_timestamp': get_audit_timestamp(),
 'collector': collector,
 'notes': notes,
 'files': {}
 }

 for raw_path in config_paths:
 path = Path(raw_path)
 if not path.exists():
 evidence_record['files'][raw_path] = {
 'status': 'missing',
 'error': f'File not found: {raw_path}'
 }
 continue

 try:
 content = path.read_text(encoding='utf-8', errors='replace')
 evidence_record['files'][raw_path] = {
 'status': 'collected',
 'size_bytes': path.stat().st_size,
 'sha256': calculate_file_hash(path),
 'last_modified': datetime.fromtimestamp(
 path.stat().st_mtime, tz=timezone.utc
 ).isoformat(),
 'content': content
 }
 except PermissionError as e:
 evidence_record['files'][raw_path] = {
 'status': 'permission_denied',
 'error': str(e)
 }

 return evidence_record
```

2. Git Integration for Change Management Evidence

Claude Code's git integration naturally supports change management documentation:

```bash
Automated commit with evidence metadata
git commit -m "Evidence: Access control update for ISO A.9 - $(date +%Y-%m-%d)"
```

The git history becomes your change management evidence, with each modification automatically timestamped and attributed.

For richer evidence, use structured commit messages that map directly to ISO 27001 control identifiers:

```bash
#!/usr/bin/env bash
scripts/evidence-commit.sh
Usage: ./scripts/evidence-commit.sh A.9.1.1 "Updated IAM role bindings to remove excess privileges"

CONTROL_ID=$1
CHANGE_DESCRIPTION=$2
EVIDENCE_DIR="evidence/$(date +%Y-%m)"

Export current IAM configuration as snapshot
aws iam get-account-authorization-details \
 --output json > "$EVIDENCE_DIR/${CONTROL_ID}_iam_snapshot_$(date +%Y%m%d_%H%M%S).json"

Stage evidence file
git add "$EVIDENCE_DIR/"

Create structured commit
git commit -m "iso27001(${CONTROL_ID}): ${CHANGE_DESCRIPTION}

Evidence: ${CONTROL_ID} $(date -u +%Y-%m-%dT%H:%M:%SZ)
Collector: $(git config user.email)
Scope: IAM configuration snapshot
Retention: 3 years"
```

Structured commit messages allow auditors to grep the git log for specific controls:

```bash
Find all commits related to access control evidence
git log --oneline --grep="iso27001(A.9"
```

3. Automated Screenshot and State Capture

For visual evidence, Claude Code can invoke screenshot tools:

```python
def capture_dashboard_state(dashboard_url):
 """Capture dashboard state for evidence"""
 result = run_command([
 'screenshot-cli',
 '--url', dashboard_url,
 '--output', f'evidence/{get_timestamp()}_dashboard.png'
 ])
 return result
```

This captures vulnerability dashboards, access logs, and compliance dashboards at scheduled intervals.

For headless capture in CI environments, use Playwright:

```python
from playwright.sync_api import sync_playwright
from datetime import datetime, timezone
import hashlib
from pathlib import Path

def capture_compliance_dashboard(
 dashboard_url: str,
 output_dir: str,
 control_id: str,
 auth_token: str | None = None
) -> dict:
 """
 Capture a compliance dashboard screenshot as audit evidence.

 Returns evidence metadata including file path, hash, and timestamp.
 """
 output_path = Path(output_dir)
 output_path.mkdir(parents=True, exist_ok=True)

 timestamp = datetime.now(timezone.utc)
 filename = f"{control_id}_{timestamp.strftime('%Y%m%d_%H%M%S')}_dashboard.png"
 screenshot_path = output_path / filename

 with sync_playwright() as p:
 browser = p.chromium.launch(headless=True)
 context = browser.new_context(
 viewport={'width': 1920, 'height': 1080}
 )

 if auth_token:
 context.set_extra_http_headers({
 'Authorization': f'Bearer {auth_token}'
 })

 page = context.new_page()
 page.goto(dashboard_url, wait_until='networkidle', timeout=30000)

 # Wait for dashboard to fully render
 page.wait_for_timeout(2000)

 page.screenshot(path=str(screenshot_path), full_page=True)
 browser.close()

 # Calculate hash for integrity verification
 sha256 = hashlib.sha256(screenshot_path.read_bytes()).hexdigest()

 return {
 'control_id': control_id,
 'file': str(screenshot_path),
 'sha256': sha256,
 'timestamp': timestamp.isoformat(),
 'source_url': dashboard_url
 }
```

## Building the Evidence Collection Workflow

## Step 1: Define Your Control Mapping

Map each ISO 27001 control to evidence types:

| Control | Evidence Type | Collection Method |
|---------|---------------|-------------------|
| A.5.1.1 | Information security policies | Document version control |
| A.6.1.2 | Risk assessment records | Automated scan exports |
| A.9.1.1 | Access control policy | Configuration snapshots |
| A.12.4.1 | Event logging | Log aggregation queries |
| A.18.1.3 | Technical compliance review | Vulnerability scan reports |

Extending this mapping to the full ISO 27001:2022 control set gives you a complete automation blueprint. The 2022 revision reorganized controls into four themes:

| Theme | Controls | Key Evidence Types |
|-------|----------|--------------------|
| Organizational (5.x) | 37 controls | Policies, risk registers, supplier contracts |
| People (6.x) | 8 controls | Training records, background check logs, HR records |
| Physical (7.x) | 14 controls | CCTV exports, access badge logs, clean desk audits |
| Technological (8.x) | 34 controls | Config snapshots, scan reports, log exports, code reviews |

Claude Code is most impactful for Technological controls (8.x) since those are the most automatable. Organizational and People controls still require human process validation but can use Claude Code to draft policy documents and track acknowledgments.

## Step 2: Create Evidence Collection Skills

Build custom Claude Code skills that wrap evidence collection logic:

```python
class ISO27001EvidenceSkill:
 """Skill for ISO 27001 evidence collection"""

 def collect_control_evidence(self, control_id):
 """Collect evidence for specific control"""
 evidence_map = {
 'A.9.1.1': self.get_access_control_evidence,
 'A.12.4.1': self.get_logging_evidence,
 'A.16.1.1': self.get_incident_evidence,
 }
 collector = evidence_map.get(control_id)
 if collector:
 return collector()
 return None
```

A more complete implementation covers AWS, Azure, and GCP cloud environments:

```python
import subprocess
import json
from dataclasses import dataclass, field
from typing import Callable

@dataclass
class EvidenceRecord:
 control_id: str
 description: str
 data: dict
 timestamp: str
 collector: str
 errors: list[str] = field(default_factory=list)

class ISO27001EvidenceSkill:
 """
 Claude Code skill for automated ISO 27001 evidence collection.
 Supports AWS, Azure, and GCP environments.
 """

 def __init__(self, cloud_provider: str = "aws", output_dir: str = "./evidence"):
 self.cloud_provider = cloud_provider
 self.output_dir = output_dir
 self.evidence_map: dict[str, Callable] = {
 # Access control
 '8.2': self.collect_privileged_access_evidence,
 '8.3': self.collect_info_access_restriction_evidence,
 # Logging and monitoring
 '8.15': self.collect_logging_evidence,
 '8.16': self.collect_monitoring_evidence,
 # Vulnerability management
 '8.8': self.collect_vulnerability_evidence,
 # Configuration management
 '8.9': self.collect_configuration_evidence,
 # Cryptography
 '8.24': self.collect_encryption_evidence,
 }

 def collect_control_evidence(self, control_id: str) -> EvidenceRecord:
 """Dispatch evidence collection for a specific control."""
 collector = self.evidence_map.get(control_id)
 if not collector:
 return EvidenceRecord(
 control_id=control_id,
 description="No automated collector registered",
 data={},
 timestamp=get_audit_timestamp(),
 collector="iso27001-skill",
 errors=[f"No collector registered for control {control_id}"]
 )
 return collector()

 def collect_privileged_access_evidence(self) -> EvidenceRecord:
 """Collect evidence for 8.2 Privileged Access Rights."""
 data = {}
 errors = []

 if self.cloud_provider == "aws":
 # List IAM users with AdministratorAccess
 result = self._run_aws_cli([
 'iam', 'get-account-authorization-details',
 '--filter', 'User'
 ])
 if result['success']:
 data['iam_users'] = result['output']
 else:
 errors.append(result['error'])

 # Check for users without MFA
 result = self._run_aws_cli([
 'iam', 'generate-credential-report'
 ])
 if result['success']:
 data['credential_report_requested'] = True
 else:
 errors.append(result['error'])

 return EvidenceRecord(
 control_id='8.2',
 description='Privileged access rights snapshot',
 data=data,
 timestamp=get_audit_timestamp(),
 collector='iso27001-skill',
 errors=errors
 )

 def collect_logging_evidence(self) -> EvidenceRecord:
 """Collect evidence for 8.15 Logging."""
 data = {}
 errors = []

 if self.cloud_provider == "aws":
 # Verify CloudTrail is enabled
 result = self._run_aws_cli([
 'cloudtrail', 'describe-trails',
 '--include-shadow-trails'
 ])
 if result['success']:
 data['cloudtrail_config'] = result['output']
 else:
 errors.append(result['error'])

 # Check CloudWatch log retention
 result = self._run_aws_cli([
 'logs', 'describe-log-groups',
 '--query', 'logGroups[*].{name:logGroupName,retentionDays:retentionInDays}'
 ])
 if result['success']:
 data['log_retention_config'] = result['output']
 else:
 errors.append(result['error'])

 return EvidenceRecord(
 control_id='8.15',
 description='Logging configuration and retention snapshot',
 data=data,
 timestamp=get_audit_timestamp(),
 collector='iso27001-skill',
 errors=errors
 )

 def _run_aws_cli(self, args: list[str]) -> dict:
 """Run an AWS CLI command and return structured result."""
 try:
 result = subprocess.run(
 ['aws'] + args + ['--output', 'json'],
 capture_output=True, text=True, timeout=30
 )
 if result.returncode == 0:
 return {'success': True, 'output': json.loads(result.stdout)}
 return {'success': False, 'error': result.stderr.strip()}
 except subprocess.TimeoutExpired:
 return {'success': False, 'error': 'AWS CLI command timed out'}
 except json.JSONDecodeError as e:
 return {'success': False, 'error': f'Failed to parse AWS CLI output: {e}'}
```

## Step 3: Schedule Automated Collection

Use cron or CI/CD pipelines to trigger evidence collection:

```yaml
GitHub Actions workflow for scheduled evidence collection
name: ISO 27001 Evidence Collection
on:
 schedule:
 - cron: '0 2 * * *' # Daily at 2 AM
 workflow_dispatch:

jobs:
 collect-evidence:
 runs-on: ubuntu-latest
 steps:
 - uses: actions/checkout@v4
 - name: Run Claude Evidence Collection
 run: |
 # Claude Code reads instructions from CLAUDE.md at repo root
 # Place your iso27001-evidence skill instructions in CLAUDE.md
 # or pass a prompt directly:
 claude -p "Run ISO27001 evidence collection: audit logs, access reviews, change records. Output findings to ./evidence/"
 - name: Archive Evidence
 uses: actions/upload-artifact@v4
 with:
 name: iso27001-evidence
 path: ./evidence/
```

For organizations needing immutable evidence storage, extend the workflow to push to a write-protected S3 bucket:

```yaml
jobs:
 collect-and-archive-evidence:
 runs-on: ubuntu-latest
 permissions:
 id-token: write # Required for OIDC AWS auth
 contents: read

 steps:
 - uses: actions/checkout@v4

 - name: Configure AWS credentials via OIDC
 uses: aws-actions/configure-aws-credentials@v4
 with:
 role-to-assume: arn:aws:iam::123456789:role/iso27001-evidence-collector
 aws-region: us-east-1

 - name: Set up Python
 uses: actions/setup-python@v5
 with:
 python-version: '3.12'

 - name: Install evidence collection dependencies
 run: pip install boto3 playwright

 - name: Install Playwright browsers
 run: playwright install chromium --with-deps

 - name: Run evidence collection
 env:
 EVIDENCE_DATE: ${{ github.run_id }}
 CONTROL_SET: "8.2,8.3,8.15,8.16,8.8"
 run: python scripts/collect_evidence.py --controls "$CONTROL_SET"

 - name: Upload evidence to S3 (immutable)
 run: |
 EVIDENCE_PATH="s3://myorg-iso27001-evidence/$(date +%Y/%m/%d)/"
 aws s3 sync ./evidence/ "$EVIDENCE_PATH" \
 --storage-class GLACIER_IR \
 --metadata "collection-run=${{ github.run_id }},workflow=${{ github.workflow }}"

 - name: Tag evidence collection run
 run: |
 echo "Evidence archived: s3://myorg-iso27001-evidence/$(date +%Y/%m/%d)/" >> $GITHUB_STEP_SUMMARY
```

## Step 4: Generate Compliance Reports

Claude Code can compile evidence into audit-ready reports:

```python
def generate_compliance_report(control_id, evidence_dir):
 """Generate markdown compliance report"""
 evidence_files = list(Path(evidence_dir).glob(f'{control_id}*'))

 report = f"""# ISO 27001 Control {control_id} Evidence Report

Collected Evidence

"""
 for evidence_file in evidence_files:
 report += f"- [{evidence_file.name}]({evidence_file})\n"

 report += f"""
Collection Timestamp
{get_audit_timestamp()}

Evidence Hash
{calculate_directory_hash(evidence_dir)}
"""
 return report
```

A more complete report generator adds pass/fail assessment for each control and a summary dashboard:

```python
from pathlib import Path
from datetime import datetime, timezone
import hashlib
import json

def calculate_directory_hash(directory: str) -> str:
 """Calculate a reproducible SHA-256 hash of all files in a directory."""
 dir_path = Path(directory)
 sha256 = hashlib.sha256()

 for file_path in sorted(dir_path.rglob('*')):
 if file_path.is_file():
 sha256.update(file_path.name.encode())
 sha256.update(file_path.read_bytes())

 return sha256.hexdigest()

def assess_control_status(evidence_files: list[Path]) -> str:
 """
 Determine control compliance status based on collected evidence.
 Returns: COMPLIANT, PARTIALLY_COMPLIANT, NON_COMPLIANT, or NOT_ASSESSED
 """
 if not evidence_files:
 return "NOT_ASSESSED"

 # Check for error markers in evidence files
 errors_found = False
 for f in evidence_files:
 if f.suffix == '.json':
 try:
 data = json.loads(f.read_text())
 if data.get('errors'):
 errors_found = True
 except (json.JSONDecodeError, KeyError):
 pass

 if errors_found:
 return "PARTIALLY_COMPLIANT"

 return "COMPLIANT"

def generate_compliance_report(
 control_id: str,
 evidence_dir: str,
 control_description: str = "",
 assessor: str = "automated"
) -> str:
 """Generate a full markdown compliance evidence report."""
 evidence_path = Path(evidence_dir)
 evidence_files = sorted(evidence_path.glob(f'{control_id}*'))
 status = assess_control_status(evidence_files)

 status_badge = {
 "COMPLIANT": " COMPLIANT",
 "PARTIALLY_COMPLIANT": "~ PARTIALLY COMPLIANT",
 "NON_COMPLIANT": " NON-COMPLIANT",
 "NOT_ASSESSED": "? NOT ASSESSED"
 }.get(status, status)

 report_lines = [
 f"# ISO 27001 Control {control_id} Evidence Report",
 "",
 f"Control: {control_id} {control_description}",
 f"Status: {status_badge}",
 f"Assessor: {assessor}",
 f"Report Generated: {datetime.now(timezone.utc).isoformat()}",
 "",
 "---",
 "",
 "## Collected Evidence",
 "",
 ]

 if evidence_files:
 for ef in evidence_files:
 file_hash = hashlib.sha256(ef.read_bytes()).hexdigest()[:16]
 size_kb = ef.stat().st_size / 1024
 report_lines.append(
 f"| `{ef.name}` | {size_kb:.1f} KB | `{file_hash}...` |"
 )
 report_lines.insert(-1, "| File | Size | SHA-256 (first 16) |")
 report_lines.insert(-1, "|------|------|---------------------|")
 else:
 report_lines.append("_No evidence files collected for this control._")

 report_lines += [
 "",
 "## Evidence Integrity",
 "",
 f"Directory Hash: `{calculate_directory_hash(evidence_dir)}`",
 "",
 "_This hash covers all evidence files in this collection. "
 "Recalculate to verify no files have been modified._"
 ]

 return "\n".join(report_lines)
```

## Practical Example: Access Control Evidence

Let's walk through a complete example for ISO 27001 control A.9 (Access Control):

1. Document the access control policy: Use Claude Code to read and version control IAM policies
2. Capture current state: Query AWS IAM or Azure AD for current user assignments
3. Verify privileged access: Check for users with elevated permissions
4. Generate evidence package: Compile everything into a timestamped report

```python
def collect_access_control_evidence():
 """Complete evidence collection for A.9 controls"""
 evidence = {
 'policy_documents': read_versioned_files('configs/iam/*.json'),
 'current_users': run_aws_command('iam list-users'),
 'role_assignments': run_azure_command('role assignments list'),
 'mfa_status': check_mfa_enforcement(),
 'timestamp': get_iso_timestamp()
 }

 # Archive to evidence store
 archive_evidence('A.9', evidence)
 return evidence
```

## Detecting Access Control Weaknesses During Collection

Evidence collection is more valuable when it flags problems automatically. Augment the basic collection with policy analysis:

```python
def analyze_iam_evidence(iam_data: dict) -> dict:
 """
 Analyze collected IAM evidence for common ISO 27001 A.9 findings.
 Returns a list of findings suitable for inclusion in the audit report.
 """
 findings = []

 users = iam_data.get('UserDetailList', [])
 for user in users:
 username = user.get('UserName', 'unknown')

 # Check for users without MFA
 mfa_devices = user.get('MFADevices', [])
 if not mfa_devices:
 findings.append({
 'severity': 'HIGH',
 'control': '8.5',
 'finding': f'User {username} has no MFA device registered',
 'recommendation': 'Enforce MFA via IAM policy condition'
 })

 # Check for inline policies (harder to audit than managed policies)
 inline_policies = user.get('UserPolicyList', [])
 if inline_policies:
 findings.append({
 'severity': 'MEDIUM',
 'control': '8.2',
 'finding': f'User {username} has {len(inline_policies)} inline policy/policies',
 'recommendation': 'Convert to managed policies for easier review'
 })

 # Check for direct policy attachments (should use roles/groups instead)
 attached_managed = user.get('AttachedManagedPolicies', [])
 admin_policies = [
 p for p in attached_managed
 if 'AdministratorAccess' in p.get('PolicyName', '')
 ]
 if admin_policies:
 findings.append({
 'severity': 'CRITICAL',
 'control': '8.2',
 'finding': f'User {username} has direct AdministratorAccess',
 'recommendation': 'Remove and assign to a break-glass group with time-limited access'
 })

 return {
 'total_users_reviewed': len(users),
 'findings': findings,
 'critical_count': sum(1 for f in findings if f['severity'] == 'CRITICAL'),
 'high_count': sum(1 for f in findings if f['severity'] == 'HIGH'),
 'medium_count': sum(1 for f in findings if f['severity'] == 'MEDIUM')
 }
```

## Best Practices for Automated Evidence Collection

1. Immutability: Store evidence in append-only storage (S3 with bucket policies, Git with branch protection)
2. Integrity: Generate cryptographic hashes for all evidence files
3. Timestamp accuracy: Use synchronized NTP time across all systems
4. Audit trails: Log all evidence collection actions with attribution
5. Retention: Define evidence retention policies aligned with ISO 27001 requirements (typically 3+ years)

## Evidence Storage Architecture

Choosing the right storage architecture determines whether auditors trust your evidence. Here is a comparison of common approaches:

| Storage Option | Immutability | Searchability | Cost | Recommended For |
|----------------|-------------|---------------|------|-----------------|
| S3 + Object Lock | High (WORM) | Via Athena | Low | Production |
| Git + branch protection | Moderate | git log/grep | Free | Small teams |
| SharePoint/Confluence | Low | Good | Included | Document evidence |
| Dedicated GRC platform | High | Excellent | High | Regulated enterprise |
| Local filesystem | None | Basic | Free | Development only |

For most organizations using Claude Code automation, S3 with Object Lock in Governance mode is the ideal backend. It prevents deletion and modification during the retention period while still allowing authorized administrators to clean up mistakes.

## Implementing S3 WORM Storage for Evidence

```python
import boto3
from datetime import datetime, timezone, timedelta

def archive_evidence_to_s3_worm(
 evidence_dir: str,
 bucket_name: str,
 retention_years: int = 3
) -> list[str]:
 """
 Upload evidence files to S3 with Object Lock for immutable retention.

 Returns list of S3 URIs for uploaded files.
 """
 s3 = boto3.client('s3')
 uploaded = []
 retain_until = datetime.now(timezone.utc) + timedelta(days=retention_years * 365)

 for file_path in Path(evidence_dir).rglob('*'):
 if not file_path.is_file():
 continue

 s3_key = f"evidence/{file_path.relative_to(evidence_dir)}"

 s3.put_object(
 Bucket=bucket_name,
 Key=s3_key,
 Body=file_path.read_bytes(),
 ObjectLockMode='GOVERNANCE',
 ObjectLockRetainUntilDate=retain_until,
 Metadata={
 'collection-timestamp': datetime.now(timezone.utc).isoformat(),
 'source-file': file_path.name,
 'sha256': calculate_file_hash(file_path)
 }
 )
 uploaded.append(f"s3://{bucket_name}/{s3_key}")

 return uploaded
```

## Integration with Existing Workflows

Claude Code evidence collection integrates naturally with:

- CI/CD pipelines: Collect evidence as part of deployment processes
- Infrastructure as Code: Version control becomes evidence documentation
- Security scanning: Automated tool outputs become compliance evidence
- Incident response: Post-incident documentation automatically captured

## Connecting to Common Security Tooling

Most security teams already have scanning tools. Claude Code can translate their outputs into ISO 27001 evidence:

| Security Tool | ISO 27001 Control | Integration Method |
|--------------|-------------------|--------------------|
| AWS Security Hub | 8.8, 8.16 | `aws securityhub get-findings --filters ...` |
| Tenable / Nessus | 8.8 | Nessus API export to CSV/JSON |
| Snyk / Dependabot | 8.8 | GitHub API or Snyk API |
| Splunk / Elastic | 8.15, 8.16 | Query API → JSON export |
| Hashicorp Vault | 8.24, 8.10 | Vault audit log export |
| GitHub Advanced Security | 8.25, 8.28 | GitHub Security API |
| Lacework / Wiz | 8.7, 8.8 | Platform API JSON export |

The integration pattern is consistent: query the tool's API, save the output as a timestamped JSON file, calculate its hash, and include it in the evidence package.

## CLAUDE.md for Compliance Projects

Document your evidence collection setup in a project-level `CLAUDE.md` so any session can pick up where the last one left off:

```markdown
ISO 27001 Compliance Automation

Project Purpose
Automated evidence collection for annual ISO 27001 surveillance audit (scope: AWS us-east-1).

Evidence Collection Schedule
- Daily: Logging config, access reviews (via GitHub Actions)
- Weekly: Vulnerability scan exports, config snapshots
- Monthly: Full IAM review, encryption key rotation status
- Pre-audit: Full evidence package generation

Control Coverage
Automated: 8.2, 8.3, 8.5, 8.8, 8.9, 8.15, 8.16, 8.24
Manual required: 5.x (policies), 6.x (HR), 7.x (physical)

Running Collection Manually
python scripts/collect_evidence.py --controls all --output ./evidence/$(date +%Y-%m-%d)

Evidence Storage
Archived to: s3://myorg-iso27001-evidence/
Retention: 3 years (Object Lock Governance mode)
```

## Conclusion

Claude Code transforms ISO 27001 evidence collection from a manual, periodic burden into an automated, continuous process. By integrating evidence collection into development workflows, organizations maintain audit-ready documentation without additional overhead. The key is starting with high-value controls, privileged access, logging, vulnerability management, and gradually expanding coverage as your evidence collection matures.

The workflow demonstrated here provides a foundation. Customize the evidence types, collection methods, and reporting formats to match your specific ISO 27001 scope and organizational context. As your automation library grows, you will find that audit preparation shrinks from weeks of frantic document gathering to a few hours of reviewing what the system has already collected.

The most important shift is cultural: once evidence collection is automated and continuous, your team stops thinking about compliance as a periodic event and starts treating it as a live, always-current view of your security posture.


---

---

<div class="mastery-cta">

I'm a solo developer in Vietnam. 50K Chrome extension users. $500K+ on Upwork. 5 Claude Max subscriptions running agent fleets in parallel.

These are my actual CLAUDE.md templates, orchestration configs, and prompts. Not a course. Not theory. The files I copy into every project before I write a line of code.

**[See what's inside →](https://zovo.one/lifetime?utm_source=ccg&utm_medium=cta-default&utm_campaign=claude-code-iso27001-evidence-collection-workflow)**

$99 once. Free forever. 47/500 founding spots left.

</div>

Related Reading

- [Claude Skills Compliance SOC2 ISO27001 Guide](/claude-skills-compliance-soc2-iso27001-guide/)
- [Claude Code for Wazuh SIEM Workflow Tutorial](/claude-code-for-wazuh-siem-workflow-tutorial/)
- [Claude Code CIS Benchmark Hardening Script Automation](/claude-code-cis-benchmark-hardening-script-automation/)

Built by theluckystrike. More at [zovo.one](https://zovo.one)
{% endraw %}


