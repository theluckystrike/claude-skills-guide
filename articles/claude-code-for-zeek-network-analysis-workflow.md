---

layout: default
title: "How to Use Zeek Network Analysis (2026)"
description: "Learn how to use Claude Code CLI to streamline Zeek network analysis workflows, automate log processing, and build efficient security."
date: 2026-03-15
last_modified_at: 2026-04-17
author: Claude Skills Guide
permalink: /claude-code-for-zeek-network-analysis-workflow/
categories: [tutorials]
tags: [claude-code, claude-skills, zeek, network-analysis, security]
reviewed: true
score: 7
geo_optimized: true
---

Network security monitoring is essential for modern infrastructure, and Zeek (formerly Bro) remains one of the most powerful open-source network security analyzers available. However, the sheer volume of logs Zeek generates can overwhelm even experienced analysts. This guide shows how Claude Code transforms your Zeek analysis workflow through intelligent automation, contextual understanding, and rapid investigation capabilities.

## Understanding the Zeek Analysis Challenge

Zeek produces multiple log types, conn.log, http.log, dns.log, files.log, and more, each containing rich metadata about network traffic. A typical busy network can generate gigabytes of logs daily. The challenge isn't just volume; it's extracting meaningful insights quickly when investigating security incidents or conducting routine threat hunting.

Traditional approaches require manual log parsing, custom scripting for each analysis task, and constant context-switching between tools. Claude Code addresses these problems by acting as an intelligent assistant that understands both your codebase and your analysis patterns.

## Zeek Log Types at a Glance

Understanding what each log type contains helps you know where to look first during an investigation.

| Log File | Contents | Primary Use Case |
|---|---|---|
| conn.log | All network connections: IPs, ports, bytes, duration, state | Lateral movement, C2 beaconing, exfiltration |
| http.log | HTTP requests: method, host, URI, user-agent, status | Web-based attacks, malware C2 over HTTP |
| dns.log | DNS queries and responses | Domain generation algorithms, DNS tunneling |
| ssl.log | TLS/SSL sessions: certificates, versions, cipher suites | Encrypted C2, certificate anomalies |
| files.log | Files transferred over the network | Malware delivery, data exfiltration |
| notice.log | Zeek-generated alerts from built-in analysis | Policy violations, known signatures |
| weird.log | Unusual/unexpected protocol behaviors | Zero-day indicators, protocol abuse |
| x509.log | Certificate details for TLS sessions | Expired certs, self-signed, malicious CAs |

## Setting Up Claude Code for Zeek Workflows

Before diving into advanced analysis, ensure your environment is properly configured. Create a dedicated Zeek analysis skill that understands your log structure and common analysis patterns:

```yaml
---
name: zeek-analysis
description: Analyzes Zeek network logs for security insights
---
```

A more complete skill file gives Claude Code persistent context about your environment. Save this to `.claude/skills/zeek-analyst.md`:

```markdown
---
name: zeek-analyst
description: Network security analyst assistant for Zeek log investigation
---

Environment

- Zeek logs stored at: /var/log/zeek/current/ (live) and /var/log/zeek/logs/ (archived)
- Log format: TSV with header comment lines starting with #
- Typical volume: 2-5GB per day across all log types
- Retention: 90 days online, 1 year in cold storage

Analysis Priorities

1. Threat hunting: focus on conn.log for beaconing, dns.log for DGA, http.log for C2
2. Incident response: correlate by UID across log types for full session reconstruction
3. Compliance: weekly reports on TLS versions, unusual ports, policy violations

Known Baseline

- Internal CIDR: 10.0.0.0/8 and 192.168.0.0/16
- Known-good external resolvers: 8.8.8.8, 1.1.1.1
- Authorized RDP hosts: 10.10.5.0/24
- Business hours: Mon-Fri 08:00-18:00 UTC
```

Initialize your analysis environment with structured log directories:

```bash
Create organized directory structure for Zeek logs
mkdir -p zeek-logs/{current,archived,reports,indicators}

Create a basic indicator library
cat > zeek-logs/indicators/known_bad_ips.txt << 'EOF'
Known malicious IPs - update regularly from threat feeds
Format: IP # source # description
185.220.101.1 # TOR exit node
198.98.54.119 # Known C2 infrastructure
EOF
```

## Automated Log Parsing and Filtering

One of Claude Code's strongest capabilities is transforming raw data into actionable insights. For Zeek analysis, you can use this to create powerful parsing pipelines.

## Parsing Connection Logs

Connection logs (conn.log) form the backbone of most network investigations. Here's how to efficiently parse and filter them:

```python
#!/usr/bin/env python3
scripts/parse_conn_log.py

import json
from datetime import datetime
from pathlib import Path

Zeek conn.log field names in order
CONN_FIELDS = [
 'ts', 'uid', 'id.orig_h', 'id.orig_p', 'id.resp_h', 'id.resp_p',
 'proto', 'service', 'duration', 'orig_bytes', 'resp_bytes',
 'conn_state', 'local_orig', 'local_resp', 'missed_bytes', 'history',
 'orig_pkts', 'orig_ip_bytes', 'resp_pkts', 'resp_ip_bytes', 'tunnel_parents'
]

def parse_zeek_connlog(log_path, filters=None):
 """Parse Zeek connection logs with optional filtering."""
 results = []
 with open(log_path, 'r') as f:
 for line in f:
 if line.startswith('#') or not line.strip():
 continue
 fields = line.rstrip('\n').split('\t')

 # Build record using field names
 conn_record = {}
 for i, field_name in enumerate(CONN_FIELDS):
 if i < len(fields):
 val = fields[i]
 conn_record[field_name] = None if val == '-' else val

 # Apply filters if provided
 if filters:
 orig_bytes = int(conn_record.get('orig_bytes') or 0)
 resp_bytes = int(conn_record.get('resp_bytes') or 0)
 total_bytes = orig_bytes + resp_bytes

 if filters.get('high_traffic') and total_bytes > filters['high_traffic']:
 results.append(conn_record)
 elif filters.get('dest_ip') and conn_record.get('id.resp_h') == filters['dest_ip']:
 results.append(conn_record)
 elif filters.get('proto') and conn_record.get('proto') == filters['proto']:
 results.append(conn_record)
 else:
 results.append(conn_record)

 return results

def detect_beaconing(conn_records, min_connections=10, jitter_threshold=0.15):
 """
 Detect potential C2 beaconing by finding regular connection intervals.
 Returns connections that show periodic patterns.
 """
 from collections import defaultdict
 import statistics

 # Group connections by src->dst pair
 pairs = defaultdict(list)
 for conn in conn_records:
 key = (conn.get('id.orig_h'), conn.get('id.resp_h'), conn.get('id.resp_p'))
 if conn.get('ts'):
 pairs[key].append(float(conn['ts']))

 beacons = []
 for (src, dst, port), timestamps in pairs.items():
 if len(timestamps) < min_connections:
 continue

 timestamps.sort()
 intervals = [timestamps[i+1] - timestamps[i] for i in range(len(timestamps)-1)]

 if len(intervals) < 2:
 continue

 mean_interval = statistics.mean(intervals)
 stdev_interval = statistics.stdev(intervals)

 # Low jitter relative to interval = likely beaconing
 if mean_interval > 0 and (stdev_interval / mean_interval) < jitter_threshold:
 beacons.append({
 'src': src,
 'dst': dst,
 'port': port,
 'connection_count': len(timestamps),
 'mean_interval_seconds': round(mean_interval, 1),
 'jitter_ratio': round(stdev_interval / mean_interval, 3)
 })

 return sorted(beacons, key=lambda x: x['jitter_ratio'])
```

## Creating Reusable Analysis Scripts

Rather than rewriting analysis logic for each investigation, create reusable scripts that Claude Code can invoke:

```bash
#!/bin/bash
scripts/zeek-summary.sh - Quick summary of Zeek logs

LOG_DIR="${1:-.}"
echo "=== Zeek Log Summary: $LOG_DIR ==="
echo "Generated: $(date -u)"
echo ""

Count non-comment lines in each log
for log in conn http dns ssl files notice weird; do
 log_file="$LOG_DIR/${log}.log"
 if [ -f "$log_file" ]; then
 count=$(grep -cv '^#' "$log_file" 2>/dev/null || echo 0)
 printf "%-20s %s events\n" "${log}.log:" "$count"
 fi
done

echo ""
echo "--- Top Source IPs (conn.log) ---"
grep -v '^#' "$LOG_DIR/conn.log" 2>/dev/null \
 | awk -F'\t' '{print $3}' \
 | sort | uniq -c | sort -rn | head -10

echo ""
echo "--- Top Destination Ports (conn.log) ---"
grep -v '^#' "$LOG_DIR/conn.log" 2>/dev/null \
 | awk -F'\t' '{print $6}' \
 | sort | uniq -c | sort -rn | head -10

echo ""
echo "--- Notice Log Alerts ---"
grep -v '^#' "$LOG_DIR/notice.log" 2>/dev/null \
 | awk -F'\t' '{print $11}' \
 | sort | uniq -c | sort -rn | head -10 || echo "No notices found"
```

## Building Incident Investigation Workflows

When security incidents occur, speed matters. Claude Code helps standardize and accelerate investigation procedures.

## Correlating Across Log Types by UID

One of Zeek's most powerful features is the `uid` field that correlates the same network session across log types. When you find a suspicious connection, you can pivot to every related log entry.

```python
#!/usr/bin/env python3
scripts/pivot_by_uid.py

import sys
import glob
from pathlib import Path

def pivot_by_uid(log_dir, target_uid):
 """Find all log entries matching a given connection UID."""
 log_dir = Path(log_dir)
 results = {}

 for log_file in log_dir.glob("*.log"):
 log_type = log_file.stem
 matches = []

 with open(log_file) as f:
 headers = []
 for line in f:
 if line.startswith('#fields'):
 headers = line.strip().split('\t')[1:]
 continue
 if line.startswith('#'):
 continue

 fields = line.rstrip('\n').split('\t')
 # UID is typically in position 1 for most log types
 if len(fields) > 1 and target_uid in fields:
 record = dict(zip(headers, fields)) if headers else {'raw': line.strip()}
 matches.append(record)

 if matches:
 results[log_type] = matches

 return results

if __name__ == '__main__':
 if len(sys.argv) != 3:
 print("Usage: pivot_by_uid.py <log_dir> <uid>")
 sys.exit(1)

 results = pivot_by_uid(sys.argv[1], sys.argv[2])
 for log_type, records in results.items():
 print(f"\n=== {log_type}.log ({len(records)} records) ===")
 for r in records:
 for k, v in r.items():
 if v and v != '-':
 print(f" {k}: {v}")
```

## Suspicious Connection Analysis

Create a workflow that quickly identifies malicious connections:

```python
#!/usr/bin/env python3
scripts/analyze_suspicious.py

def analyze_suspicious_connections(conn_logs, indicators):
 """Analyze connections against known threat indicators."""
 suspicious = []
 for conn in conn_logs:
 orig_h = conn.get('id.orig_h', '')
 resp_h = conn.get('id.resp_h', '')
 resp_p = conn.get('id.resp_p', '')
 orig_bytes = int(conn.get('orig_bytes') or 0)

 # Check against known bad IPs
 if orig_h in indicators.get('bad_ips', []) or resp_h in indicators.get('bad_ips', []):
 suspicious.append({
 'type': 'known_malicious_ip',
 'connection': conn,
 'severity': 'high',
 'detail': f"IP {resp_h} found in threat feed"
 })

 # Check for unusual ports
 if resp_p in indicators.get('suspicious_ports', []):
 suspicious.append({
 'type': 'suspicious_port',
 'connection': conn,
 'severity': 'medium',
 'detail': f"Uncommon destination port {resp_p}"
 })

 # Check for excessive data transfer
 if orig_bytes > 10_000_000: # >10MB outbound
 suspicious.append({
 'type': 'high_volume_transfer',
 'connection': conn,
 'severity': 'low',
 'detail': f"{orig_bytes / 1e6:.1f}MB transferred outbound"
 })

 # Check for long-duration connections (potential tunneling)
 duration = float(conn.get('duration') or 0)
 if duration > 3600: # >1 hour
 suspicious.append({
 'type': 'long_duration_connection',
 'connection': conn,
 'severity': 'low',
 'detail': f"Connection lasted {duration/3600:.1f} hours"
 })

 # Deduplicate and sort by severity
 severity_order = {'high': 0, 'medium': 1, 'low': 2}
 suspicious.sort(key=lambda x: severity_order.get(x['severity'], 3))
 return suspicious
```

## HTTP Traffic Detailed look

HTTP logs reveal significant threat intelligence. Build analysis that surfaces anomalies:

```python
#!/usr/bin/env python3
scripts/analyze_http.py

from collections import Counter, defaultdict

def analyze_http_anomalies(http_logs):
 """Identify unusual HTTP traffic patterns."""
 anomalies = []
 user_agents = Counter()
 requested_domains = Counter()
 uri_patterns = defaultdict(list)
 status_codes = Counter()

 for entry in http_logs:
 ua = entry.get('user_agent', 'unknown') or 'unknown'
 host = entry.get('host', 'unknown') or 'unknown'
 uri = entry.get('uri', '/') or '/'
 status = entry.get('status_code', '-') or '-'

 user_agents[ua] += 1
 requested_domains[host] += 1
 status_codes[status] += 1

 # Track URI patterns per host for DGA/C2 detection
 uri_patterns[host].append(uri)

 total_requests = sum(user_agents.values())

 # Identify rare user agents (potential automation/tooling/malware)
 for ua, count in user_agents.items():
 if total_requests > 0 and count / total_requests < 0.01:
 anomalies.append({
 'type': 'rare_user_agent',
 'value': ua,
 'count': count,
 'severity': 'low'
 })

 # Identify high-frequency destinations
 for host, count in requested_domains.most_common(10):
 if count > 1000:
 anomalies.append({
 'type': 'high_frequency_destination',
 'value': host,
 'count': count,
 'severity': 'info'
 })

 # Flag high error rates (potential scanning or broken apps)
 error_count = sum(v for k, v in status_codes.items() if k.startswith('4') or k.startswith('5'))
 if total_requests > 0 and error_count / total_requests > 0.3:
 anomalies.append({
 'type': 'high_error_rate',
 'value': f"{error_count / total_requests * 100:.1f}% errors",
 'count': error_count,
 'severity': 'medium'
 })

 # Detect hosts with high URI uniqueness (potential DGA callbacks)
 for host, uris in uri_patterns.items():
 unique_ratio = len(set(uris)) / len(uris) if uris else 0
 if len(uris) > 20 and unique_ratio > 0.9:
 anomalies.append({
 'type': 'high_uri_uniqueness',
 'value': host,
 'count': len(uris),
 'severity': 'medium',
 'detail': f"{unique_ratio*100:.0f}% unique URIs. possible DGA or C2"
 })

 return anomalies
```

## DNS Analysis for Threat Hunting

DNS logs are among the richest sources for threat hunting. Domain Generation Algorithm (DGA) detection, DNS tunneling, and fast-flux detection are all achievable with automated analysis.

```python
#!/usr/bin/env python3
scripts/analyze_dns.py

import math
import re
from collections import Counter

def calculate_entropy(domain):
 """Calculate Shannon entropy of a string. high entropy suggests DGA."""
 if not domain:
 return 0
 counts = Counter(domain)
 length = len(domain)
 return -sum((c / length) * math.log2(c / length) for c in counts.values())

def analyze_dns_logs(dns_records, entropy_threshold=3.5, min_label_len=12):
 """Hunt for DGA domains and DNS tunneling in Zeek dns.log records."""
 findings = []
 query_counts = Counter()
 nx_domains = []

 for record in dns_records:
 query = record.get('query', '') or ''
 rcode_name = record.get('rcode_name', '') or ''

 if not query:
 continue

 query_counts[query] += 1

 # Track NXDOMAIN responses
 if rcode_name == 'NXDOMAIN':
 nx_domains.append(query)

 # Analyze the leftmost label for DGA characteristics
 labels = query.split('.')
 if labels:
 leftmost = labels[0]
 entropy = calculate_entropy(leftmost)

 # High entropy + long label = likely DGA
 if entropy > entropy_threshold and len(leftmost) >= min_label_len:
 findings.append({
 'type': 'possible_dga',
 'query': query,
 'entropy': round(entropy, 2),
 'label_length': len(leftmost),
 'severity': 'high'
 })

 # Very long subdomain = possible DNS tunneling
 if len(leftmost) > 50:
 findings.append({
 'type': 'possible_dns_tunnel',
 'query': query,
 'label_length': len(leftmost),
 'severity': 'high'
 })

 # High NXDOMAIN rate suggests DGA scanning
 total_queries = sum(query_counts.values())
 if total_queries > 0 and len(nx_domains) / total_queries > 0.4:
 findings.append({
 'type': 'high_nxdomain_rate',
 'rate': f"{len(nx_domains)/total_queries*100:.1f}%",
 'sample_domains': nx_domains[:5],
 'severity': 'high'
 })

 return findings
```

## Integrating Zeek with SIEM and SOAR

Modern security operations require integration with broader platforms. Claude Code facilitates building these integration layers.

## Log Export and Normalization

```python
#!/usr/bin/env python3
scripts/normalize_for_siem.py

import json
from datetime import datetime, timezone

def normalize_zeek_to_json(log_type, records):
 """Convert Zeek logs to normalized JSON for SIEM ingestion."""
 normalized = []
 for record in records:
 ts_raw = record.get('ts') or record.get('timestamp')

 normalized_record = {
 'timestamp': ts_raw,
 'event_type': f"zeek.{log_type}",
 'source_ip': record.get('id.orig_h'),
 'source_port': record.get('id.orig_p'),
 'dest_ip': record.get('id.resp_h'),
 'dest_port': record.get('id.resp_p'),
 'uid': record.get('uid'),
 'metadata': {
 'original_log_type': log_type,
 'processing_time': datetime.now(timezone.utc).isoformat(),
 'sensor': 'zeek'
 }
 }

 # Type-specific fields
 if log_type == 'http':
 normalized_record.update({
 'http_method': record.get('method'),
 'http_host': record.get('host'),
 'http_uri': record.get('uri'),
 'http_status': record.get('status_code'),
 'http_user_agent': record.get('user_agent'),
 'http_resp_mime': record.get('resp_mime_types')
 })
 elif log_type == 'dns':
 normalized_record.update({
 'dns_query': record.get('query'),
 'dns_qtype': record.get('qtype_name'),
 'dns_answers': record.get('answers'),
 'dns_rcode': record.get('rcode_name')
 })
 elif log_type == 'ssl':
 normalized_record.update({
 'tls_version': record.get('version'),
 'tls_cipher': record.get('cipher'),
 'tls_subject': record.get('subject'),
 'tls_issuer': record.get('issuer'),
 'tls_server_name': record.get('server_name')
 })
 elif log_type == 'conn':
 normalized_record.update({
 'proto': record.get('proto'),
 'service': record.get('service'),
 'duration': record.get('duration'),
 'bytes_out': record.get('orig_bytes'),
 'bytes_in': record.get('resp_bytes'),
 'conn_state': record.get('conn_state')
 })

 # Remove None values for cleaner SIEM ingestion
 normalized_record = {k: v for k, v in normalized_record.items() if v is not None}
 normalized.append(normalized_record)

 return normalized
```

## Generating Structured Incident Reports

Claude Code can help write a report generator that produces analyst-ready summaries:

```python
#!/usr/bin/env python3
scripts/generate_report.py

import json
from datetime import datetime, timezone

def generate_incident_report(findings, output_path):
 """Generate a structured markdown incident report from analysis findings."""
 timestamp = datetime.now(timezone.utc).strftime('%Y-%m-%d %H:%M UTC')
 high = [f for f in findings if f.get('severity') == 'high']
 medium = [f for f in findings if f.get('severity') == 'medium']
 low = [f for f in findings if f.get('severity') == 'low']

 lines = [
 f"# Zeek Analysis Report",
 f"Generated: {timestamp}",
 "",
 f"## Summary",
 f"- High severity findings: {len(high)}",
 f"- Medium severity findings: {len(medium)}",
 f"- Low severity findings: {len(low)}",
 ""
 ]

 for severity, group in [("High", high), ("Medium", medium), ("Low", low)]:
 if not group:
 continue
 lines.append(f"## {severity} Severity Findings")
 for finding in group:
 lines.append(f"### {finding.get('type', 'Unknown')}")
 for k, v in finding.items():
 if k not in ('type', 'severity'):
 lines.append(f"- {k}: {v}")
 lines.append("")

 report = '\n'.join(lines)
 with open(output_path, 'w') as f:
 f.write(report)

 print(f"Report written to {output_path}")
 return report
```

## Best Practices for Zeek Analysis with Claude Code

To maximize your analysis efficiency, follow these proven practices:

1. Structure your log storage - Organize Zeek logs by date and log type in consistent directory structures. This enables rapid retrieval and archival management.

2. Create domain-specific skills - Build specialized Claude Code skills for different analysis scenarios (incident response, threat hunting, compliance reporting). Each skill file should document your network's baseline behavior.

3. Automate routine summaries - Generate daily/weekly summary reports automatically, allowing analysts to focus on anomalies rather than basic metrics.

4. Maintain indicator libraries - Keep updated lists of known malicious IPs, suspicious domains, and threat actor signatures that can be quickly referenced. Automate imports from OSINT feeds like Abuse.ch, AlienVault OTX, or your SIEM's threat intel module.

5. Version control your analysis scripts - Treat your analysis code as production code with proper versioning, testing, and documentation. Git-track your scripts directory alongside your skill files.

6. Establish baseline metrics - Before you can detect anomalies, you need to know what normal looks like. Run your analysis scripts against several weeks of clean traffic to establish baseline values for bytes per connection, DNS query rates, and connection durations.

7. Use UID pivoting as a first step - When any finding surfaces, immediately pivot by UID to see the full session across all log types. This single habit dramatically speeds up triage.

## Conclusion

Claude Code transforms Zeek network analysis from a manual, time-intensive process into an efficient, automated workflow. By using intelligent parsing, reusable analysis scripts, and standardized investigation procedures, security teams can dramatically reduce response times and improve threat detection accuracy.

The key is starting simple: set up proper log organization, create your first analysis scripts, and progressively build more sophisticated automation as your needs evolve. With Claude Code as your analysis partner, you have a powerful ally for navigating even the most complex network security investigations. The combination of Zeek's deep protocol visibility and Claude Code's ability to rapidly generate, test, and refine analysis scripts gives your team a significant edge in both proactive threat hunting and reactive incident response.

---

---

<div class="mastery-cta">

I'm a solo developer in Vietnam. 50K Chrome extension users. $500K+ on Upwork. 5 Claude Max subscriptions running agent fleets in parallel.

These are my actual CLAUDE.md templates, orchestration configs, and prompts. Not a course. Not theory. The files I copy into every project before I write a line of code.

**[See what's inside →](https://zovo.one/lifetime?utm_source=ccg&utm_medium=cta-default&utm_campaign=claude-code-for-zeek-network-analysis-workflow)**

$99 once. Free forever. 47/500 founding spots left.

</div>

Related Reading

- [Claude Code for Go Fuzz Workflow Tutorial Guide](/claude-code-for-go-fuzz-workflow-tutorial-guide/)
- [Claude Code for Mythril Workflow Tutorial](/claude-code-for-mythril-workflow-tutorial/)
- [Claude Code for OSS Security Policy Workflow Tutorial](/claude-code-for-oss-security-policy-workflow-tutorial/)
- [Claude Code for Taint Analysis Workflow Tutorial Guide](/claude-code-for-taint-analysis-workflow-tutorial-guide/)
- [Claude Code for Network Firewall Workflow](/claude-code-for-network-firewall-workflow/)

Built by theluckystrike. More at [zovo.one](https://zovo.one)



---

## Frequently Asked Questions

### What is Understanding the Zeek Analysis Challenge?

The Zeek analysis challenge is the difficulty of extracting meaningful security insights from the massive volume of logs Zeek generates across conn.log, http.log, dns.log, ssl.log, files.log, and more. A busy network produces gigabytes of logs daily. Traditional approaches require manual parsing and custom scripting for each task. Claude Code addresses this by acting as an intelligent assistant that automates log processing and understands analysis patterns.

### What is Zeek Log Types at a Glance?

Zeek produces eight primary log types, each serving specific investigation needs. conn.log tracks all network connections (IPs, ports, bytes, duration) for detecting lateral movement and C2 beaconing. http.log captures HTTP requests for web-based attack analysis. dns.log records DNS queries for DGA and tunneling detection. ssl.log covers TLS sessions and certificate anomalies. files.log tracks transferred files, notice.log holds Zeek-generated alerts, weird.log captures unusual protocol behaviors, and x509.log stores certificate details.

### What is Setting Up Claude Code for Zeek Workflows?

Setting up Claude Code for Zeek workflows involves creating a dedicated skill file at `.claude/skills/zeek-analyst.md` that documents your log storage paths, typical daily volume (2-5GB), retention periods, internal CIDRs (e.g., 10.0.0.0/8), known-good DNS resolvers, authorized hosts, and business hours. You also initialize a structured directory layout with current, archived, reports, and indicators subdirectories, plus a known-bad IP library sourced from threat feeds like Abuse.ch and AlienVault OTX.

### What is Automated Log Parsing and Filtering?

Automated log parsing and filtering uses Claude Code to build Python pipelines that read Zeek's TSV-formatted logs, skip comment lines starting with `#`, split fields by tab, and apply filters such as high-traffic thresholds, destination IP matching, or protocol filtering. The parsed records become structured dictionaries keyed by standard Zeek field names. Claude Code transforms raw log data into actionable insights by generating reusable parsing scripts that can be invoked across investigations.

### What is Parsing Connection Logs?

Parsing connection logs (conn.log) involves reading Zeek's 21-field TSV records covering timestamp, UID, source/destination IPs and ports, protocol, service, duration, bytes transferred, and connection state. A Python parser maps each tab-separated field to named keys, converts dashes to None, and applies optional filters. The parsed data feeds into detection functions like `detect_beaconing()`, which groups connections by src-dst-port tuples and calculates interval jitter ratios to identify C2 beaconing patterns.
