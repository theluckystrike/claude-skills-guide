---
layout: default
title: "Claude Code ISO 27001 Evidence Collection Workflow"
description: "Learn how to build automated ISO 27001 evidence collection workflows using Claude Code skills. Streamline your compliance audits with practical examples and best practices."
date: 2026-03-14
categories: [guides]
tags: [claude-code, iso27001, compliance, evidence-collection, automation, security]
author: theluckystrike
permalink: /claude-code-iso27001-evidence-collection-workflow/
---

{% raw %}
# Claude Code ISO 27001 Evidence Collection Workflow

ISO 27001 certification requires organizations to demonstrate systematic evidence collection across 93 security controls. For many teams, this means manually gathering screenshots, configuration dumps, and audit logs—a time-consuming process prone to gaps and inconsistencies. Claude Code transforms this workflow by enabling automated, reproducible evidence collection that integrates directly into your development and operations pipelines.

## Understanding the Evidence Collection Challenge

ISO 27001 evidence falls into several categories that Claude Code can help automate:

- **Configuration evidence**: Firewall rules, access control lists, encryption settings
- **Operational evidence**: Log excerpts, incident reports, change management records
- **Process evidence**: Policy acknowledgments, training records, risk assessments
- **Technical evidence**: Vulnerability scan results, penetration test reports, backup verification

Traditional approaches require manual documentation or expensive GRC platforms. Claude Code offers a middle ground—lightweight automation that captures evidence during normal development operations.

## Core Claude Code Skills for Evidence Collection

### 1. File Operations Skill for Documenting Configurations

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

### 2. Git Integration for Change Management Evidence

Claude Code's git integration naturally supports change management documentation:

```bash
# Automated commit with evidence metadata
git commit -m "Evidence: Access control update for ISO A.9 - $(date +%Y-%m-%d)"
```

The git history becomes your change management evidence, with each modification automatically timestamped and attributed.

### 3. Automated Screenshot and State Capture

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

## Building the Evidence Collection Workflow

### Step 1: Define Your Control Mapping

Map each ISO 27001 control to evidence types:

| Control | Evidence Type | Collection Method |
|---------|---------------|-------------------|
| A.5.1.1 | Information security policies | Document version control |
| A.6.1.2 | Risk assessment records | Automated scan exports |
| A.9.1.1 | Access control policy | Configuration snapshots |
| A.12.4.1 | Event logging | Log aggregation queries |
| A.18.1.3 | Technical compliance review | Vulnerability scan reports |

### Step 2: Create Evidence Collection Skills

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

### Step 3: Schedule Automated Collection

Use cron or CI/CD pipelines to trigger evidence collection:

```yaml
# GitHub Actions workflow for scheduled evidence collection
name: ISO 27001 Evidence Collection
on:
  schedule:
    - cron: '0 2 * * *'  # Daily at 2 AM
  workflow_dispatch:

jobs:
  collect-evidence:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Run Claude Evidence Collection
        run: |
          claude --skill iso27001-evidence \
            --collect all \
            --output ./evidence/
      - name: Archive Evidence
        uses: actions/upload-artifact@v4
        with:
          name: iso27001-evidence
          path: ./evidence/
```

### Step 4: Generate Compliance Reports

Claude Code can compile evidence into audit-ready reports:

```python
def generate_compliance_report(control_id, evidence_dir):
    """Generate markdown compliance report"""
    evidence_files = list(Path(evidence_dir).glob(f'{control_id}*'))
    
    report = f"""# ISO 27001 Control {control_id} Evidence Report
    
## Collected Evidence
    
"""
    for evidence_file in evidence_files:
        report += f"- [{evidence_file.name}]({evidence_file})\n"
    
    report += f"""
## Collection Timestamp
{get_audit_timestamp()}

## Evidence Hash
{calculate_directory_hash(evidence_dir)}
"""
    return report
```

## Practical Example: Access Control Evidence

Let's walk through a complete example for ISO 27001 control A.9 (Access Control):

1. **Document the access control policy**: Use Claude Code to read and version control IAM policies
2. **Capture current state**: Query AWS IAM or Azure AD for current user assignments
3. **Verify privileged access**: Check for users with elevated permissions
4. **Generate evidence package**: Compile everything into a timestamped report

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

## Best Practices for Automated Evidence Collection

1. **Immutability**: Store evidence in append-only storage (S3 with bucket policies, Git with branch protection)
2. **Integrity**: Generate cryptographic hashes for all evidence files
3. **Timestamp accuracy**: Use synchronized NTP time across all systems
4. **Audit trails**: Log all evidence collection actions with attribution
5. **Retention**: Define evidence retention policies aligned with ISO 27001 requirements (typically 3+ years)

## Integration with Existing Workflows

Claude Code evidence collection integrates naturally with:

- **CI/CD pipelines**: Collect evidence as part of deployment processes
- **Infrastructure as Code**: Version control becomes evidence documentation
- **Security scanning**: Automated tool outputs become compliance evidence
- **Incident response**: Post-incident documentation automatically captured

## Conclusion

Claude Code transforms ISO 27001 evidence collection from a manual, periodic burden into an automated, continuous process. By integrating evidence collection into development workflows, organizations maintain audit-ready documentation without额外的 overhead. The key is starting with high-value controls and gradually expanding coverage as your evidence collection matures.

The workflow demonstrated here provides a foundation—customize the evidence types, collection methods, and reporting formats to match your specific ISO 27001 scope and organizational context.
{% endraw %}
