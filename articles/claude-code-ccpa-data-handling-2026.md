---
title: "Claude Code for CCPA Data Handling"
permalink: /claude-code-ccpa-data-handling-2026/
description: "Implement CCPA/CPRA consumer rights with Claude Code. Build opt-out mechanisms, data deletion workflows, and sale disclosure tracking."
last_tested: "2026-04-22"
domain: "privacy compliance"
---

## Why Claude Code for CCPA Data Handling

The California Consumer Privacy Act (CCPA) and its amendment CPRA require businesses to implement specific technical capabilities: right to know, right to delete, right to opt-out of sale/sharing, and right to limit use of sensitive personal information. Unlike GDPR's broad consent framework, CCPA has specific requirements around "sale" of personal information that includes sharing data with third-party analytics, advertising SDKs, and data brokers. The California Privacy Protection Agency (CPPA) actively enforces violations with fines of $2,500-$7,500 per intentional violation.

Claude Code can implement the technical infrastructure for CCPA compliance: consumer request intake APIs, data deletion cascading across microservices, opt-out signal handling (Global Privacy Control), and third-party data sharing controls that actually stop data flow rather than just recording preferences.

## The Workflow

### Step 1: Identify Personal Information Categories

```python
#!/usr/bin/env python3
"""CCPA personal information category discovery.
Maps to Cal. Civ. Code 1798.140(v) categories."""

CCPA_PI_CATEGORIES = {
    "A_identifiers": {
        "description": "Identifiers (name, SSN, email, IP address, account name)",
        "field_patterns": ["name", "email", "ssn", "ip_address", "username",
                          "account_id", "customer_id", "device_id", "cookie"],
        "sensitive": False
    },
    "B_customer_records": {
        "description": "Personal information per Cal. Civ. Code 1798.80(e)",
        "field_patterns": ["address", "phone", "credit_card", "bank_account",
                          "insurance_policy", "education", "employment"],
        "sensitive": False
    },
    "D_commercial_info": {
        "description": "Commercial information (purchase history, tendencies)",
        "field_patterns": ["purchase", "order", "cart", "wishlist",
                          "subscription", "transaction", "payment_history"],
        "sensitive": False
    },
    "F_internet_activity": {
        "description": "Internet or network activity (browsing, search, interaction)",
        "field_patterns": ["page_view", "click", "session", "referrer",
                          "search_query", "user_agent", "browser"],
        "sensitive": False
    },
    "G_geolocation": {
        "description": "Geolocation data",
        "field_patterns": ["latitude", "longitude", "location", "geo",
                          "zip_code", "coordinates"],
        "sensitive": True  # Precise geolocation is sensitive PI under CPRA
    },
    "K_sensitive_PI": {
        "description": "Sensitive Personal Information (CPRA addition)",
        "field_patterns": ["ssn", "driver_license", "passport", "racial_origin",
                          "ethnic_origin", "religious", "genetic", "biometric",
                          "health", "sexual_orientation", "precise_geolocation"],
        "sensitive": True
    }
}
```

### Step 2: Implement Consumer Rights API

```python
# routes/privacy.py — CCPA consumer rights endpoints
from fastapi import APIRouter, HTTPException, BackgroundTasks
from pydantic import BaseModel, EmailStr
from datetime import datetime, timedelta
from enum import Enum

router = APIRouter(prefix="/api/privacy", tags=["CCPA"])

class RequestType(str, Enum):
    RIGHT_TO_KNOW = "know"
    RIGHT_TO_DELETE = "delete"
    RIGHT_TO_OPTOUT = "optout"
    RIGHT_TO_CORRECT = "correct"
    RIGHT_TO_LIMIT = "limit_sensitive"

class ConsumerRequest(BaseModel):
    email: EmailStr
    request_type: RequestType
    verified: bool = False

class VerifiedRequest(BaseModel):
    request_id: str
    verification_code: str

# CCPA requires response within 45 days (extendable to 90)
RESPONSE_DEADLINE_DAYS = 45

@router.post("/request")
async def submit_consumer_request(
    req: ConsumerRequest,
    background_tasks: BackgroundTasks
):
    """Intake consumer rights request (CCPA 1798.105, 1798.120)."""
    request_id = generate_request_id()
    deadline = datetime.utcnow() + timedelta(days=RESPONSE_DEADLINE_DAYS)

    # Store request and send verification email
    await store_privacy_request(request_id, req, deadline)
    background_tasks.add_task(send_verification_email, req.email, request_id)

    return {
        "request_id": request_id,
        "status": "verification_pending",
        "deadline": deadline.isoformat(),
        "message": "Verification email sent. Complete verification within 15 days."
    }

@router.post("/request/verify")
async def verify_and_process(
    verification: VerifiedRequest,
    background_tasks: BackgroundTasks
):
    """Verify identity and begin processing (CCPA 1798.185 verification)."""
    request = await get_privacy_request(verification.request_id)
    if not request:
        raise HTTPException(404, "Request not found")

    if not verify_code(verification.request_id, verification.verification_code):
        raise HTTPException(403, "Invalid verification code")

    # Mark verified and begin processing
    await mark_verified(verification.request_id)

    if request.request_type == RequestType.RIGHT_TO_DELETE:
        background_tasks.add_task(
            cascade_deletion, request.email, verification.request_id
        )
    elif request.request_type == RequestType.RIGHT_TO_KNOW:
        background_tasks.add_task(
            compile_data_report, request.email, verification.request_id
        )
    elif request.request_type == RequestType.RIGHT_TO_OPTOUT:
        background_tasks.add_task(
            process_optout, request.email, verification.request_id
        )

    return {"status": "processing", "request_id": verification.request_id}

async def cascade_deletion(email: str, request_id: str):
    """Delete consumer data across all services (CCPA 1798.105)."""
    services = [
        {"name": "user-service", "endpoint": "/internal/delete-user"},
        {"name": "order-service", "endpoint": "/internal/delete-orders"},
        {"name": "analytics-service", "endpoint": "/internal/delete-events"},
        {"name": "email-service", "endpoint": "/internal/delete-subscriber"},
        {"name": "support-service", "endpoint": "/internal/delete-tickets"},
    ]

    results = []
    for service in services:
        # Each service must delete or de-identify PI
        result = await call_internal_service(
            service["name"],
            service["endpoint"],
            {"email": email, "request_id": request_id}
        )
        results.append({
            "service": service["name"],
            "status": result.status_code,
            "records_affected": result.json().get("deleted_count", 0)
        })

    # Log completion for audit trail
    await log_request_completion(request_id, results)
```

### Step 3: Implement Global Privacy Control (GPC) Handling

```javascript
// middleware/gpc.js — Handle Global Privacy Control signal
// Required under CCPA regulations (Cal. Code Regs. 7025)

function handleGlobalPrivacyControl(req, res, next) {
  // Sec-GPC header: browser-level opt-out signal
  const gpcEnabled = req.headers['sec-gpc'] === '1';

  if (gpcEnabled) {
    // Must treat as valid opt-out of sale/sharing
    req.privacyPreferences = {
      optOutSale: true,
      optOutSharing: true,
      source: 'GPC',
      timestamp: new Date().toISOString()
    };

    // Disable third-party tracking scripts
    res.locals.disableAnalytics = true;
    res.locals.disableAdTracking = true;

    // Set response header to acknowledge GPC
    res.setHeader('Sec-GPC', '1');
  }

  next();
}

// Apply to all routes
module.exports = handleGlobalPrivacyControl;
```

### Step 4: Verify

```bash
# Test consumer request flow
curl -X POST http://localhost:3000/api/privacy/request \
  -H "Content-Type: application/json" \
  -d '{"email":"test@example.com","request_type":"delete"}'

# Test GPC handling
curl -H "Sec-GPC: 1" http://localhost:3000/ -I | grep -i sec-gpc

# Verify deletion cascade
python3 tests/test_ccpa_deletion.py -v

# Check 45-day deadline tracking
python3 -c "
from datetime import datetime, timedelta
print(f'Deadline: {(datetime.now() + timedelta(days=45)).strftime(\"%Y-%m-%d\")}')"
```

## CLAUDE.md for CCPA Implementation

```markdown
# CCPA/CPRA Data Handling Standards

## Domain Rules
- Consumer requests must be acknowledged within 10 business days
- Consumer requests must be fulfilled within 45 calendar days (extendable to 90)
- Global Privacy Control (GPC) must be treated as valid opt-out
- "Do Not Sell or Share" must actually stop data transmission to third parties
- Sensitive PI (CPRA) requires separate opt-in consent
- Minors under 16: opt-in required for sale/sharing (under 13: parental)
- Financial incentive programs require explicit opt-in and value calculation

## File Patterns
- Privacy API: src/routes/privacy.py or src/routes/privacy.ts
- GPC middleware: src/middleware/gpc.js
- Deletion cascade: src/services/deletion.py
- PI inventory: docs/pi-inventory.json

## Common Commands
- python3 -m pytest tests/test_ccpa*.py -v
- curl -H "Sec-GPC: 1" localhost:3000 -I
- python3 scripts/audit_pi_categories.py
- python3 scripts/check_deadline_compliance.py
```

## Common Pitfalls in CCPA Data Handling

- **Opt-out does not stop data flow:** Many implementations record the opt-out preference but continue sending data to analytics and ad platforms. Claude Code verifies that opt-out actually disables third-party SDK loading and data transmission, not just sets a database flag.

- **Deletion misses derived data:** Consumer deletion requests must cover derived data (predictions, profiles, recommendations). Claude Code maps all data derivation pipelines and ensures deletion cascades through ML feature stores and recommendation caches.

- **Service provider vs third party confusion:** CCPA distinguishes between service providers (processors) and third parties (data buyers). Claude Code analyzes data sharing agreements and flags any vendor receiving PI without a compliant service provider agreement.

## Related

- [Claude Code for GDPR Data Mapping](/claude-code-gdpr-data-mapping-2026/)
- [Claude Code for HIPAA Compliance Code Review](/claude-code-hipaa-compliance-code-review-2026/)
- [Claude Code for EU AI Act Compliance](/claude-code-eu-ai-act-compliance-2026/)


## Frequently Asked Questions

### Do I need a paid Anthropic plan to use this?

Claude Code works with any Anthropic API plan, including the free tier. However, the free tier has lower rate limits (requests per minute and tokens per minute) that may slow down multi-step workflows. For professional use, the Build or Scale plan provides higher limits and priority access during peak hours.

### How does this affect token usage and cost?

The token cost depends on the size of your prompts and Claude's responses. Typical development tasks consume 10K-50K tokens per interaction. Using a CLAUDE.md file and skills reduces exploration tokens by 50-80%, which directly lowers costs. Monitor your usage at console.anthropic.com/settings/billing.

### Can I customize this for my specific project?

Yes. All Claude Code behavior can be customized through CLAUDE.md (project rules), `.claude/settings.json` (permissions), and `.claude/skills/` (domain knowledge). The most impactful customization is adding your project's specific patterns, conventions, and common commands to CLAUDE.md so Claude Code follows your standards from the start.

### What happens when Claude Code makes a mistake?

Claude Code creates files and edits through standard filesystem operations, so all changes are visible in `git diff`. If a change is wrong, revert it with `git checkout -- <file>` for a single file or `git stash` for all changes. Claude Code does not make irreversible changes unless you explicitly allow destructive commands in settings.json.


## Related Guides

- [CCPA Compliance with Claude Code (2026)](/claude-code-ccpa-privacy-compliance-guide/)
- [Structured Error Handling to Reduce](/structured-error-handling-reduce-claude-code-tokens/)
- [Fix: Claude MD Error Handling Patterns](/claude-md-for-error-handling-patterns-guide/)
- [How to Use Claude Error Handling](/claude-code-for-claude-error-handling-patterns-workflow-guid/)

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
        "text": "Claude Code creates files and edits through standard filesystem operations, so all changes are visible in `git diff`. If a change is wrong, revert it with `git checkout -- <file>` for a single file or `git stash` for all changes. Claude Code does not make irreversible changes unless you explicitly allow destructive commands in settings.json."
      }
    }
  ]
}
</script>
