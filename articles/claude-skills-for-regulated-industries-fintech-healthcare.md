---
layout: default
title: "Claude Skills for Regulated Industries (2026)"
description: "Discover Claude skills tailored for fintech and healthcare development. Practical examples, compliance workflows, and code patterns for regulated."
date: 2026-03-14
last_modified_at: 2026-04-17
author: "Claude Skills Guide"
categories: [guides]
tags: [claude-code, claude-skills, fintech, healthcare, compliance]
reviewed: true
score: 7
permalink: /claude-skills-for-regulated-industries-fintech-healthcare/
geo_optimized: true
---

# Claude Skills for Regulated Industries: Fintech & Healthcare Development

Building software for fintech and healthcare sectors requires more than standard development practices. These industries operate under strict regulatory frameworks, PCI-DSS for payments, SOC 2 for service organizations, HIPAA for healthcare data, and GDPR for privacy. Developers in these spaces need specialized workflows that prioritize compliance without sacrificing productivity.

Claude skills provide targeted solutions for regulated industry challenges. This guide covers practical implementations for financial services and healthcare applications, with code examples you can adapt immediately.

## Core Challenges in Regulated Industries

Regulated development differs from typical software engineering in several critical ways:

- Audit trails: Every action must be traceable
- Data protection: Encryption at rest and in transit is mandatory
- Access controls: Role-based permissions with granular boundaries
- Compliance documentation: Evidence collection for audits
- Incident response: Rapid detection and remediation capabilities

The tdd skill helps enforce test coverage requirements that satisfy compliance auditors. When building for regulated industries, tests serve dual purposes: validating functionality and demonstrating due diligence.

## Regulatory Framework Comparison

Understanding the distinctions between major frameworks helps you prioritize compliance effort. Here is a quick reference across the four most common frameworks developers encounter:

| Framework | Industry | Primary Focus | Key Controls | Audit Frequency |
|-----------|----------|---------------|--------------|-----------------|
| HIPAA | Healthcare | PHI protection | Access controls, encryption, audit logs | Annual risk assessment |
| PCI-DSS | Payments | Cardholder data | Network segmentation, tokenization, monitoring | Annual QSA assessment |
| SOC 2 | SaaS / Cloud | Trust service criteria | Availability, confidentiality, security | Annual or continuous |
| GDPR | EU data subjects | Data privacy rights | Consent, data portability, right to erasure | No fixed audit cycle |

Each framework has overlapping requirements around access control and logging, which means a well-structured compliance architecture can satisfy multiple frameworks simultaneously. The sections below focus on building that shared foundation first, then adding framework-specific controls on top.

## Building HIPAA-Compliant Healthcare Applications

Healthcare developers must handle protected health information (PHI) with strict safeguards. The [claude-code-hipaa-compliant-development-workflow-guide](/claude-code-hipaa-compliant-development-workflow-guide/) provides comprehensive patterns, but here are essential implementations:

```javascript
// PHI access control with audit logging
class HealthcareDataAccess {
 constructor(auditLogger) {
 this.auditLogger = auditLogger;
 this.encryption = new AES256Encryption();
 }

 async accessPatientRecord(patientId, userContext, authorizedRoles) {
 // Verify authorization
 if (!authorizedRoles.includes(userContext.role)) {
 await this.auditLogger.log({
 event: 'ACCESS_DENIED',
 user: userContext.id,
 resource: `patient:${patientId}`,
 timestamp: new Date().toISOString()
 });
 throw new AccessDeniedError('Insufficient privileges');
 }

 // Log successful access
 await this.auditLogger.log({
 event: 'PHI_ACCESS',
 user: userContext.id,
 resource: `patient:${patientId}`,
 purpose: userContext.purpose,
 timestamp: new Date().toISOString()
 });

 return this.fetchEncryptedRecord(patientId);
 }
}
```

The [supermemory skill](/claude-supermemory-skill-persistent-context-explained/) helps maintain compliance context across sessions without storing sensitive data in logs.

## PHI De-identification Patterns

HIPAA's Safe Harbor method requires removing 18 specific identifiers before data can be treated as de-identified. Automating this removal prevents accidental PHI exposure in development and test environments:

```javascript
// HIPAA Safe Harbor de-identification (removes all 18 identifiers)
const PHI_PATTERNS = {
 ssn: /\b\d{3}-\d{2}-\d{4}\b/g,
 phone: /\b(\+?1[-.\s]?)?\(?\d{3}\)?[-.\s]\d{3}[-.\s]\d{4}\b/g,
 email: /\b[a-zA-Z0-9._%+\-]+@[a-zA-Z0-9.\-]+\.[a-zA-Z]{2,}\b/g,
 dob: /\b(0?[1-9]|1[0-2])[\/\-](0?[1-9]|[12]\d|3[01])[\/\-]\d{2,4}\b/g,
 zip: /\b\d{5}(-\d{4})?\b/g,
 mrn: /\bMRN[:\s#]*\d+\b/gi,
 ipAddress: /\b\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}\b/g,
};

function deidentifyRecord(text) {
 let sanitized = text;
 for (const [type, pattern] of Object.entries(PHI_PATTERNS)) {
 sanitized = sanitized.replace(pattern, `[REDACTED_${type.toUpperCase()}]`);
 }
 return sanitized;
}

// Test with a synthetic record
const raw = 'Patient Jane Doe, DOB 04/12/1985, SSN 123-45-6789, MRN: 987654';
const clean = deidentifyRecord(raw);
// → 'Patient Jane Doe, DOB [REDACTED_DOB], SSN [REDACTED_SSN], MRN: [REDACTED_MRN]'
```

Note that name de-identification requires NLP-based entity recognition rather than simple regex. Libraries like spaCy's `en_core_web_sm` model or AWS Comprehend Medical handle named entity recognition for clinical text and should replace the regex approach for production PHI pipelines.

## Encryption Key Management for PHI at Rest

Choosing the right key management strategy is often where teams make expensive mistakes. Here is a comparison of common approaches:

| Approach | Key Storage | Rotation | HIPAA Suitability | Cost |
|----------|------------|----------|-------------------|------|
| Application-managed keys | Config / secrets manager | Manual | Weak. keys co-located with data | Low |
| AWS KMS customer-managed | AWS KMS | Automatic or scheduled | Strong | ~$1/key/month |
| HashiCorp Vault | Vault cluster | Policy-driven | Strong | Infrastructure cost |
| Azure Key Vault | Azure managed | Automatic | Strong | Pay-per-operation |
| Hardware Security Module (HSM) | Dedicated hardware | Manual | Strongest | High |

For most teams, AWS KMS or Azure Key Vault provides the right balance of security and operational overhead. Here is a KMS-backed encryption wrapper in Python:

```python
import boto3
import base64
from cryptography.fernet import Fernet

class KMSEncryptionService:
 def __init__(self, kms_key_id: str, region: str = 'us-east-1'):
 self.kms = boto3.client('kms', region_name=region)
 self.kms_key_id = kms_key_id

 def generate_data_key(self) -> dict:
 """Generate a data key encrypted by KMS. Never store the plaintext key."""
 response = self.kms.generate_data_key(
 KeyId=self.kms_key_id,
 KeySpec='AES_256'
 )
 return {
 'plaintext': response['Plaintext'], # Use to encrypt, then discard
 'ciphertext_blob': response['CiphertextBlob'] # Store alongside data
 }

 def encrypt_phi(self, plaintext: str) -> dict:
 data_key = self.generate_data_key()
 f = Fernet(base64.urlsafe_b64encode(data_key['plaintext'][:32]))

 encrypted = f.encrypt(plaintext.encode())

 # Explicitly zero out plaintext key from memory
 data_key['plaintext'] = b'\x00' * len(data_key['plaintext'])

 return {
 'ciphertext': base64.b64encode(encrypted).decode(),
 'encrypted_data_key': base64.b64encode(data_key['ciphertext_blob']).decode()
 }

 def decrypt_phi(self, payload: dict) -> str:
 encrypted_data_key = base64.b64decode(payload['encrypted_data_key'])
 response = self.kms.decrypt(CiphertextBlob=encrypted_data_key)

 f = Fernet(base64.urlsafe_b64encode(response['Plaintext'][:32]))
 return f.decrypt(base64.b64decode(payload['ciphertext'])).decode()
```

This pattern, called envelope encryption, stores only the encrypted data key alongside the ciphertext. The actual encryption key never persists in your database.

## Fintech Payment Processing Compliance

Financial applications require PCI-DSS compliance. Use the [claude-code-soc2-compliance-audit-preparation-guide-2026](/claude-code-soc2-compliance-audit-preparation-guide-2026/) for SOC 2 preparation, but implement payment handling with tokenization:

```python
Payment tokenization pattern for PCI compliance
class PaymentTokenizer:
 def __init__(self, vault_client, audit_service):
 self.vault = vault_client
 self.audit = audit_service

 def tokenize_card(self, card_data, merchant_id):
 # Never store raw card data - tokenize immediately
 token = self.vault.create_token({
 'card_number': card_data['number'],
 'cvv': card_data['cvv'], # Never persisted
 'merchant': merchant_id
 })

 self.audit.log_tokenization(
 merchant_id=merchant_id,
 token_id=token['id'],
 last_four=card_data['number'][-4:],
 timestamp=datetime.utcnow().isoformat()
 )

 return {'token': token['id'], 'last_four': token['last_four']}
```

The [claude-code-secret-scanning-prevent-credential-leaks-guide](/claude-code-secret-scanning-prevent-credential-leaks-guide/) prevents accidentally committing API keys or payment credentials.

## PCI-DSS Scope Reduction Strategies

The cheapest compliance is compliance you do not have to do. Reducing your PCI scope is the most impactful action a fintech team can take. Here is how different architectural choices affect your scope:

| Architecture | PCI Scope | Implementation Complexity | Recommended For |
|--------------|-----------|--------------------------|-----------------|
| Collect card data in your app | Full scope (SAQ D) | Low initially, high long-term | Never recommended |
| Hosted payment page (Stripe, Braintree) | Minimal (SAQ A) | Low | Most SaaS products |
| JavaScript tokenization (Stripe.js) | Reduced (SAQ A-EP) | Medium | Custom checkout flows |
| In-app mobile SDK | Medium scope | Medium | Mobile-first apps |
| P2PE hardware terminal | Reduced hardware scope | High | In-person payments |

For the vast majority of fintech applications, using a hosted payment page or a JavaScript tokenization library like Stripe.js reduces your PCI scope to SAQ A or SAQ A-EP, which are self-assessment questionnaires requiring far less evidence than a full QSA audit.

## Transaction Anomaly Detection

Compliance frameworks increasingly require controls around fraud detection. Here is a lightweight rule-based anomaly detector you can extend:

```python
from dataclasses import dataclass
from datetime import datetime, timedelta
from typing import List
import statistics

@dataclass
class Transaction:
 id: str
 user_id: str
 amount: float
 merchant_id: str
 timestamp: datetime
 country_code: str

class AnomalyDetector:
 def __init__(self, audit_service):
 self.audit = audit_service
 self.velocity_window = timedelta(hours=1)

 def evaluate(self, tx: Transaction, history: List[Transaction]) -> dict:
 findings = []

 # Rule 1: Velocity check. more than 10 transactions in 1 hour
 recent = [h for h in history if tx.timestamp - h.timestamp < self.velocity_window]
 if len(recent) > 10:
 findings.append({'rule': 'VELOCITY', 'severity': 'HIGH',
 'detail': f'{len(recent)} transactions in last hour'})

 # Rule 2: Amount deviation. more than 3 standard deviations above user mean
 if len(history) >= 10:
 amounts = [h.amount for h in history[-90:]]
 mean = statistics.mean(amounts)
 std = statistics.stdev(amounts)
 if std > 0 and (tx.amount - mean) / std > 3:
 findings.append({'rule': 'AMOUNT_DEVIATION', 'severity': 'MEDIUM',
 'detail': f'Amount {tx.amount} exceeds 3σ threshold'})

 # Rule 3: Country mismatch. transaction from unexpected geography
 common_countries = {h.country_code for h in history[-30:]}
 if tx.country_code not in common_countries and len(common_countries) > 0:
 findings.append({'rule': 'GEO_ANOMALY', 'severity': 'MEDIUM',
 'detail': f'Unexpected country: {tx.country_code}'})

 if findings:
 self.audit.log_anomaly(tx.id, tx.user_id, findings)

 return {'transaction_id': tx.id, 'risk_level': self._aggregate_risk(findings),
 'findings': findings}

 def _aggregate_risk(self, findings: list) -> str:
 if any(f['severity'] == 'HIGH' for f in findings):
 return 'HIGH'
 if findings:
 return 'MEDIUM'
 return 'LOW'
```

This pattern generates structured audit log entries for every anomalous transaction, which satisfies PCI-DSS Requirement 10 (track and monitor all access to network resources and cardholder data) and SOC 2 CC7.2 (anomaly and event monitoring).

## Automating Compliance Documentation

Regulated industries require extensive documentation. The [/pdf skill](/best-claude-skills-for-data-analysis/) generates compliance reports:

```
/pdf
Generate a compliance audit report covering:
- Access log summary for Q1 2026
- SOC 2 control evidence for CC6.1 through CC6.8
- HIPAA security rule compliance status
Output as a formal PDF report with executive summary.
```

The [/xlsx skill](/claude-xlsx-skill-spreadsheet-automation-tutorial/) builds evidence spreadsheets auditors expect:

```
/xlsx
Create a compliance evidence workbook with:
- Sheet 1: Access log data from audit_trail.json (columns: User, Action, Resource, Timestamp)
- Sheet 2: Control status summary
- Sheet 3: Remediation tracking
Save as compliance-evidence.xlsx
```

`from xlsx import Workbook` is not valid. the xlsx skill is invoked with `/xlsx`, not imported as a Python package.

## SOC 2 Control Evidence Mapping

When preparing for a SOC 2 audit, auditors expect evidence mapped to specific Trust Service Criteria (TSC). Here is how to structure your evidence workbook output from the `/xlsx` skill:

| TSC Control | Control Description | Evidence Type | Collection Method |
|-------------|--------------------|--------------|--------------------|
| CC6.1 | Logical and physical access controls | Access control policy, IAM screenshots | Manual + automated export |
| CC6.2 | Access provisioning | Ticket records, provisioning logs | JIRA/ServiceNow export |
| CC6.3 | Access removal | Offboarding checklists, account deletion logs | HR system export |
| CC6.6 | Logical access boundaries | Network diagrams, firewall rule exports | Infrastructure as code |
| CC7.1 | System monitoring | SIEM alerts, monitoring dashboards | CloudWatch / Splunk export |
| CC7.2 | Anomaly detection | Anomaly alert logs | Security tool export |
| CC8.1 | Change management | Deployment records, change tickets | CI/CD pipeline logs |

Using Claude Code with the `/xlsx` skill to ingest your CI/CD pipeline logs and generate this evidence workbook takes roughly 15 minutes rather than the 4–8 hours a manual evidence collection process typically requires.

## Generating a HIPAA Risk Assessment Narrative

The HIPAA Security Rule requires a documented risk analysis at least annually. Claude Code can draft the narrative structure from your existing technical controls:

```
/pdf
Draft a HIPAA Security Risk Assessment for our patient portal application.

Context:
- Application type: web portal with mobile companion app
- Data stored: patient demographics, appointment records, lab results
- Hosting: AWS us-east-1, encrypted EBS volumes, KMS key management
- Authentication: SSO via Okta with MFA enforced
- Monitoring: CloudTrail + GuardDuty enabled
- Backup: daily snapshots retained 90 days, cross-region replication enabled

Generate:
1. Executive summary
2. Asset inventory table
3. Threat/vulnerability matrix with likelihood and impact ratings
4. Current controls assessment
5. Residual risk ratings
6. Recommended remediation items with priority rankings

Output as a formal PDF with section headers matching NIST SP 800-30 format.
```

## Security Code Review Workflow

Integrate security scanning using Claude Code hooks in `~/.claude/settings.json`. The `PreToolUse` hook can block dangerous patterns before Claude executes bash commands:

```json
{
 "hooks": {
 "PreToolUse": [
 {
 "matcher": {"tool_name": "bash"},
 "command": ".claude/hooks/security-check.sh"
 }
 ]
 }
}
```

The hook script can scan for hardcoded credentials or dangerous patterns:

```bash
#!/bin/bash
.claude/hooks/security-check.sh
INPUT=$(cat)
CMD=$(echo "$INPUT" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('tool_input',{}).get('command',''))")

Block eval usage
if echo "$CMD" | grep -qP '\beval\s*\('; then
 echo '{"decision": "block", "reason": "Dynamic code execution not allowed"}'
 exit 0
fi

echo "$INPUT"
```

Use the `/tdd` skill to enforce test coverage for security-critical paths before merging.

## Extended Security Hook: Credential and Secret Detection

The hook above catches `eval`, but a regulated environment needs broader coverage. Here is a more complete version that blocks common secret patterns:

```bash
#!/bin/bash
.claude/hooks/security-check.sh. Extended version
INPUT=$(cat)
CMD=$(echo "$INPUT" | python3 -c "
import sys, json
d = json.load(sys.stdin)
print(d.get('tool_input', {}).get('command', ''))
")

block_with_reason() {
 echo "{\"decision\": \"block\", \"reason\": \"$1\"}"
 exit 0
}

Block dynamic code execution
echo "$CMD" | grep -qP '\beval\s*\(' && block_with_reason "Dynamic code execution (eval) not allowed"

Block hardcoded AWS keys
echo "$CMD" | grep -qP 'AKIA[0-9A-Z]{16}' && block_with_reason "Hardcoded AWS access key detected"

Block hardcoded secrets in environment variable assignments
echo "$CMD" | grep -qiP '(password|secret|api_key|token)\s*=\s*["\x27][^"\x27]{8,}' && \
 block_with_reason "Potential hardcoded credential in command"

Block writing to /etc or system paths
echo "$CMD" | grep -qP '>\s*/etc/' && block_with_reason "Writing to /etc is not permitted"

Block curl | bash patterns (supply chain risk)
echo "$CMD" | grep -qP 'curl\s.+\|\s*(bash|sh|zsh)' && \
 block_with_reason "Piping remote content to shell is not allowed"

echo "$INPUT"
```

Pair this hook with a `PostToolUse` hook that writes every executed command to an immutable audit log, satisfying the traceability requirements shared by HIPAA, PCI-DSS, and SOC 2.

## TDD for Compliance-Critical Paths

Compliance auditors often ask for evidence that security controls are tested, not just present. The `/tdd` skill workflow forces tests to exist before implementation, creating a natural paper trail:

```
/tdd
Write tests first for the PaymentTokenizer class, covering:
- tokenize_card stores no raw PAN in the return value
- tokenize_card calls audit.log_tokenization with correct arguments
- tokenize_card raises ValueError when card_number fails Luhn check
- decrypt_token returns original card data only for same merchant_id
- decrypt_token raises PermissionError for cross-merchant access attempts

Run the tests (they should fail), then implement the class to make them pass.
```

This workflow produces both a test suite and a traceable commit history showing tests were written before code, strong evidence for SOC 2 CC8.1 change management controls.

## Frontend Design for Compliance Forms

The [frontend-design skill](/claude-frontend-design-skill-review-and-tutorial/) helps build accessible, compliant forms:

```jsx
// WCAG-compliant healthcare data entry form
function PatientDataForm({ onSubmit }) {
 const [errors, setErrors] = useState({});

 const validateAndSubmit = (formData) => {
 // Field-level validation
 const newErrors = {};

 if (!formData.ssn || !/^\d{3}-\d{2}-\d{4}$/.test(formData.ssn)) {
 newErrors.ssn = 'Valid SSN required (XXX-XX-XXXX)';
 }

 if (Object.keys(newErrors).length > 0) {
 setErrors(newErrors);
 return;
 }

 // Encrypt before transmission
 const encrypted = encryptField(formData, 'ssn');
 onSubmit(encrypted);
 };

 return (
 <form onSubmit={validateAndSubmit} aria-label="Patient Data Entry">
 <label htmlFor="ssn">Social Security Number</label>
 <input
 id="ssn"
 type="password"
 aria-describedby="ssn-error"
 onChange={(e) => formatSSN(e.target.value)}
 />
 {errors.ssn && (
 <span id="ssn-error" role="alert">{errors.ssn}</span>
 )}
 </form>
 );
}
```

## Consent Management for GDPR and HIPAA

Forms in regulated industries often require explicit consent capture with a verifiable audit record. Here is a consent component that records the consent event with the exact text the user agreed to:

```jsx
import { useState } from 'react';

function ConsentCapture({ consentVersion, onConsent }) {
 const [agreed, setAgreed] = useState(false);

 const handleConsent = async () => {
 if (!agreed) return;

 const consentRecord = {
 user_agent: navigator.userAgent,
 timestamp: new Date().toISOString(),
 consent_version: consentVersion,
 consent_text_hash: await hashText(document.getElementById('consent-text').innerText),
 ip_address: null // Populated server-side. never log client-side IPs
 };

 // Send to server for immutable audit log storage
 await fetch('/api/consent', {
 method: 'POST',
 headers: { 'Content-Type': 'application/json' },
 body: JSON.stringify(consentRecord)
 });

 onConsent(consentRecord);
 };

 return (
 <div role="region" aria-label="Consent Agreement">
 <div id="consent-text" aria-live="polite">
 <p>By proceeding, you authorize this application to collect and process
 your health information as described in our{' '}
 <a href="/privacy-notice" target="_blank" rel="noopener noreferrer">
 Privacy Notice
 </a>
 {' '}(Version {consentVersion}).</p>
 </div>
 <label>
 <input
 type="checkbox"
 checked={agreed}
 onChange={(e) => setAgreed(e.target.checked)}
 aria-required="true"
 />
 I have read and agree to the above terms
 </label>
 <button onClick={handleConsent} disabled={!agreed} aria-disabled={!agreed}>
 Proceed
 </button>
 </div>
 );
}

async function hashText(text) {
 const encoder = new TextEncoder();
 const data = encoder.encode(text);
 const hashBuffer = await crypto.subtle.digest('SHA-256', data);
 return Array.from(new Uint8Array(hashBuffer))
 .map(b => b.toString(16).padStart(2, '0'))
 .join('');
}
```

Hashing the consent text and storing it with the timestamp proves the user saw a specific version of the consent language, a requirement under GDPR Article 7(1) that auditors frequently check.

## Infrastructure for Regulated Workloads

The [claude-skills-for-infrastructure-as-code-terraform](/claude-code-skills-for-infrastructure-as-code-terraform/) skill helps provision compliant infrastructure:

```hcl
HIPAA-compliant AWS infrastructure
module "encrypted_vpc" {
 source = "./modules/vpc"

 name = "hipaa-vpc"

 # Encryption at rest
 enable_encryption = true
 kms_key_id = aws_kms_key.hipaa.arn

 # Network isolation
 enable_flow_log = true
 flow_log_destination = aws_s3_bucket.flow_logs.arn

 # Private subnets for PHI processing
 private_subnets = ["10.0.1.0/24", "10.0.2.0/24"]
}
```

## Compliance Infrastructure Checklist by Cloud Provider

Different cloud providers expose the same controls through different service names. Here is a cross-provider reference for the infrastructure controls that appear most frequently in HIPAA and PCI audits:

| Control | AWS | Azure | GCP |
|---------|-----|-------|-----|
| Encryption at rest (managed keys) | SSE with AWS-managed keys | Azure Storage Service Encryption | Google-managed encryption keys |
| Encryption at rest (customer keys) | KMS CMK | Azure Key Vault | Cloud KMS CMEK |
| Network flow logs | VPC Flow Logs | NSG Flow Logs | VPC Flow Logs |
| Immutable audit trail | CloudTrail + S3 Object Lock | Azure Monitor + Immutable Storage | Cloud Audit Logs + WORM buckets |
| Intrusion detection | GuardDuty | Microsoft Defender for Cloud | Security Command Center |
| Secrets management | AWS Secrets Manager | Azure Key Vault | Secret Manager |
| Privileged access management | AWS IAM + AWS Organizations | Azure PIM | Cloud Identity |
| Database encryption | RDS encrypted storage | Azure SQL TDE | Cloud SQL encryption |

## Terraform Module for Audit-Ready S3 Bucket

Compliance often requires proving that audit logs cannot be deleted or modified. Here is a Terraform module that creates an S3 bucket with Object Lock and access logging:

```hcl
resource "aws_s3_bucket" "audit_logs" {
 bucket = "${var.environment}-audit-logs-${var.account_id}"
}

resource "aws_s3_bucket_object_lock_configuration" "audit_logs" {
 bucket = aws_s3_bucket.audit_logs.id

 rule {
 default_retention {
 mode = "COMPLIANCE" # GOVERNANCE allows authorized deletions; COMPLIANCE does not
 days = 365 # HIPAA requires 6 years; PCI-DSS requires 1 year (logs)
 }
 }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "audit_logs" {
 bucket = aws_s3_bucket.audit_logs.id

 rule {
 apply_server_side_encryption_by_default {
 sse_algorithm = "aws:kms"
 kms_master_key_id = aws_kms_key.audit.arn
 }
 bucket_key_enabled = true
 }
}

resource "aws_s3_bucket_public_access_block" "audit_logs" {
 bucket = aws_s3_bucket.audit_logs.id
 block_public_acls = true
 block_public_policy = true
 ignore_public_acls = true
 restrict_public_buckets = true
}

resource "aws_s3_bucket_logging" "audit_logs" {
 bucket = aws_s3_bucket.audit_logs.id
 target_bucket = aws_s3_bucket.audit_logs.id # Self-logging for access tracking
 target_prefix = "access-logs/"
}
```

Using COMPLIANCE mode Object Lock means not even the bucket owner or AWS root account can delete objects before the retention period expires. This is a strong control for HIPAA §164.312(b) audit control requirements.

## Selecting the Right Skills for Your Stack

For fintech development, prioritize:

- [claude-code-soc2-compliance-audit-preparation-guide-2026](/claude-code-soc2-compliance-audit-preparation-guide-2026/) for compliance preparation
- [claude-code-secret-scanning-prevent-credential-leaks-guide](/claude-code-secret-scanning-prevent-credential-leaks-guide/) for security
- [claude-tdd-skill-test-driven-development-workflow](/claude-tdd-skill-test-driven-development-workflow/) for test coverage

For healthcare applications, focus on:

- [claude-code-hipaa-compliant-development-workflow-guide](/claude-code-hipaa-compliant-development-workflow-guide/) for HIPAA patterns
- [claude-code-gdpr-data-privacy-implementation-checklist](/claude-code-gdpr-data-privacy-implementation-checklist/) for privacy compliance
- [supermemory skill](/claude-supermemory-skill-persistent-context-explained/) for session management

Both industries benefit from the [claude-code-permissions-model-security-guide-2026](/claude-code-permissions-model-security-guide-2026/) to enforce principle of least privilege.

## Skill Selection by Compliance Priority

The table below maps common compliance requirements to the Claude skills best suited to address them:

| Compliance Requirement | Primary Skill | Supporting Skill |
|------------------------|---------------|-----------------|
| PHI access control implementation | hipaa-workflow | tdd |
| PCI tokenization and cardholder data flow | secret-scanning | tdd |
| SOC 2 evidence collection | pdf, xlsx | supermemory |
| GDPR data subject request handling | gdpr-checklist | frontend-design |
| Audit log infrastructure | terraform | permissions-model |
| Security code review automation | PreToolUse hooks | secret-scanning |
| Risk assessment documentation | pdf | supermemory |
| Incident response runbooks | pdf | tdd |

## Summary

Building for regulated industries doesn't mean abandoning developer productivity. Claude skills provide specialized workflows that embed compliance into your development process:

- Automated audit logging and evidence generation
- Security scanning integrated into code review
- Test-driven development with compliance verification
- Infrastructure as code with encryption and isolation defaults

Start with the skills matching your primary compliance framework, then expand to cover additional requirements as your application grows.

Built by theluckystrike. More at [zovo.one](https://zovo.one)

---


**Try it:** Paste your error into our [Error Diagnostic](/diagnose/) for an instant fix.
---

<div class="mastery-cta">

This site was built by 5 autonomous agents running in tmux while I was in Bali. 2,500 articles. Zero manual work. 100% quality gate pass rate.

The orchestration configs, sprint templates, and quality gates that made that possible are in the Zovo Lifetime bundle. Along with 16 CLAUDE.md templates and 80 tested prompts.

**[See how the pipeline works →](https://zovo.one/lifetime?utm_source=ccg&utm_medium=cta-skills&utm_campaign=claude-skills-for-regulated-industries-fintech-healthcare)**

$99 once. I'm a solo dev in Da Nang. This is how I scale.

</div>

Related Reading

- [Claude Code HIPAA Compliant Development Workflow Guide](/claude-code-hipaa-compliant-development-workflow-guide/). Comprehensive HIPAA implementation patterns referenced throughout this guide, with deeper PHI handling workflows
- [Claude Code SOC 2 Compliance Audit Preparation Guide 2026](/claude-code-soc2-compliance-audit-preparation-guide-2026/). Step-by-step SOC 2 preparation workflow for fintech teams using Claude skills for evidence generation
- [Claude Code OWASP Top 10 Security Scanning Workflow](/claude-code-owasp-top-10-security-scanning-workflow/). Automated security scanning workflows that complement compliance documentation requirements
- [Claude Skills Use Cases Hub](/use-cases-hub/). Explore additional use-case skill guides for security, compliance, and regulated industry development
- [Claude Skills Feature Flag Implementation Workflow](/claude-skills-feature-flag-implementation-workflow/)


