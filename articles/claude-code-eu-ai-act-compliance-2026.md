---
layout: default
title: "Claude Code for EU AI Act Compliance (2026)"
permalink: /claude-code-eu-ai-act-compliance-2026/
date: 2026-04-20
description: "Implement EU AI Act compliance with Claude Code. Classify AI system risk levels, generate technical documentation, and build transparency logs."
last_tested: "2026-04-22"
domain: "AI regulation"
---

## Why Claude Code for EU AI Act

The EU AI Act (Regulation 2024/1689) entered into force August 2024 with phased compliance deadlines: prohibited practices by February 2025, GPAI model obligations by August 2025, and high-risk system requirements by August 2026. Organizations deploying AI systems in the EU must classify their systems by risk level, implement transparency requirements, maintain technical documentation, and establish human oversight mechanisms. For high-risk systems (Article 6), the requirements include risk management, data governance, technical documentation, record-keeping, and accuracy/robustness testing.

Claude Code can analyze AI system codebases to determine risk classification, generate Article 11 technical documentation, implement Article 13 transparency logging, and verify that human oversight mechanisms (Article 14) are actually functional in the code.

## The Workflow

### Step 1: Classify AI System Risk Level

```python
#!/usr/bin/env python3
"""EU AI Act risk classification for AI systems.
Based on Regulation 2024/1689 Articles 5, 6, and Annex III."""

from enum import Enum
from dataclasses import dataclass

class RiskLevel(Enum):
    PROHIBITED = "prohibited"      # Article 5
    HIGH_RISK = "high_risk"        # Article 6 + Annex III
    LIMITED_RISK = "limited_risk"  # Article 50 transparency
    MINIMAL_RISK = "minimal_risk"  # No mandatory requirements

# Annex III: High-risk AI system categories
HIGH_RISK_DOMAINS = {
    "biometrics": {
        "description": "Biometric identification and categorisation",
        "indicators": ["facial_recognition", "biometric", "face_detection",
                      "emotion_recognition", "gait_analysis"],
        "annex_ref": "Annex III, 1"
    },
    "critical_infrastructure": {
        "description": "Management and operation of critical infrastructure",
        "indicators": ["traffic_management", "energy_grid", "water_supply",
                      "gas_supply", "digital_infrastructure"],
        "annex_ref": "Annex III, 2"
    },
    "education": {
        "description": "Education and vocational training",
        "indicators": ["student_assessment", "admission_decision",
                      "learning_outcome", "grading_algorithm",
                      "proctoring", "plagiarism_detection"],
        "annex_ref": "Annex III, 3"
    },
    "employment": {
        "description": "Employment, workers management",
        "indicators": ["recruitment", "hiring_decision", "resume_screening",
                      "performance_evaluation", "promotion_decision",
                      "task_allocation", "termination"],
        "annex_ref": "Annex III, 4"
    },
    "essential_services": {
        "description": "Access to essential private/public services",
        "indicators": ["credit_scoring", "insurance_pricing",
                      "benefits_eligibility", "emergency_dispatch",
                      "health_insurance", "loan_decision"],
        "annex_ref": "Annex III, 5"
    },
    "law_enforcement": {
        "description": "Law enforcement",
        "indicators": ["risk_assessment", "polygraph", "evidence_analysis",
                      "crime_prediction", "profiling"],
        "annex_ref": "Annex III, 6"
    }
}

# Article 5: Prohibited practices
PROHIBITED_PATTERNS = [
    "social_scoring",          # Social credit scoring
    "subliminal_manipulation", # Subliminal techniques
    "exploit_vulnerability",   # Exploiting vulnerable groups
    "real_time_biometric_public",  # Real-time remote biometric ID in public
]

@dataclass
class ClassificationResult:
    risk_level: RiskLevel
    domain: str | None
    annex_reference: str | None
    indicators_found: list[str]
    obligations: list[str]

def classify_ai_system(codebase_analysis: dict) -> ClassificationResult:
    """Classify AI system risk level per EU AI Act."""

    # Check prohibited practices first (Article 5)
    for pattern in PROHIBITED_PATTERNS:
        if pattern in codebase_analysis.get("features", []):
            return ClassificationResult(
                risk_level=RiskLevel.PROHIBITED,
                domain="prohibited_practice",
                annex_reference="Article 5",
                indicators_found=[pattern],
                obligations=["SYSTEM MUST NOT BE DEPLOYED IN THE EU"]
            )

    # Check high-risk categories (Annex III)
    for domain, config in HIGH_RISK_DOMAINS.items():
        found = [ind for ind in config["indicators"]
                 if ind in codebase_analysis.get("features", [])]
        if found:
            return ClassificationResult(
                risk_level=RiskLevel.HIGH_RISK,
                domain=domain,
                annex_reference=config["annex_ref"],
                indicators_found=found,
                obligations=[
                    "Art 9: Risk management system",
                    "Art 10: Data governance",
                    "Art 11: Technical documentation",
                    "Art 12: Record-keeping (logging)",
                    "Art 13: Transparency and information",
                    "Art 14: Human oversight",
                    "Art 15: Accuracy, robustness, cybersecurity",
                    "Art 16: Obligations of providers",
                    "Art 17: Quality management system"
                ]
            )

    # Check limited-risk transparency obligations (Article 50)
    limited_risk_indicators = ["chatbot", "deepfake", "synthetic_content",
                                "text_generation", "image_generation"]
    found = [ind for ind in limited_risk_indicators
             if ind in codebase_analysis.get("features", [])]
    if found:
        return ClassificationResult(
            risk_level=RiskLevel.LIMITED_RISK,
            domain="transparency_required",
            annex_reference="Article 50",
            indicators_found=found,
            obligations=[
                "Art 50(1): Notify users they are interacting with AI",
                "Art 50(2): Label AI-generated content",
                "Art 50(4): Mark synthetic content as AI-generated"
            ]
        )

    return ClassificationResult(
        risk_level=RiskLevel.MINIMAL_RISK,
        domain=None, annex_reference=None,
        indicators_found=[],
        obligations=["No mandatory requirements (voluntary codes of conduct)"]
    )
```

### Step 2: Implement Article 12 Logging

```python
# services/ai_transparency_log.py
"""Article 12: Record-keeping — automatic logging of AI system operation."""

import json
import logging
from datetime import datetime
from typing import Any

class AITransparencyLogger:
    """Structured logging for EU AI Act Article 12 compliance."""

    def __init__(self, system_name: str, version: str):
        self.system_name = system_name
        self.version = version
        self.logger = logging.getLogger(f"ai_act.{system_name}")

    def log_prediction(
        self,
        input_data: dict,
        output: Any,
        confidence: float,
        model_version: str,
        human_override: bool = False,
        override_reason: str | None = None
    ):
        """Log every AI system decision for Article 12 compliance."""
        record = {
            "timestamp": datetime.utcnow().isoformat(),
            "system": self.system_name,
            "system_version": self.version,
            "model_version": model_version,
            "event_type": "prediction",
            "input_hash": hash_input(input_data),  # Don't log raw PII
            "output": str(output),
            "confidence": confidence,
            "human_oversight": {
                "override_applied": human_override,
                "override_reason": override_reason
            },
            "article_12_fields": {
                "period_of_use": datetime.utcnow().isoformat(),
                "reference_database": model_version,
                "input_data_description": list(input_data.keys()),
                "output_description": type(output).__name__
            }
        }
        self.logger.info(json.dumps(record))

    def log_human_override(
        self,
        original_output: Any,
        overridden_output: Any,
        operator_id: str,
        reason: str
    ):
        """Log Article 14 human oversight interventions."""
        record = {
            "timestamp": datetime.utcnow().isoformat(),
            "event_type": "human_override",
            "system": self.system_name,
            "original_output": str(original_output),
            "overridden_output": str(overridden_output),
            "operator_id": operator_id,
            "reason": reason
        }
        self.logger.info(json.dumps(record))
```

### Step 3: Implement Article 14 Human Oversight

```python
# services/human_oversight.py
"""Article 14: Human oversight mechanisms for high-risk AI systems."""

class HumanOversightGate:
    """Enforce human-in-the-loop for high-risk decisions."""

    def __init__(self, ai_logger: AITransparencyLogger, confidence_threshold: float = 0.85):
        self.logger = ai_logger
        self.threshold = confidence_threshold

    async def evaluate_with_oversight(
        self,
        model_output: Any,
        confidence: float,
        context: dict
    ) -> dict:
        """Route decisions through human oversight when needed."""

        if confidence >= self.threshold:
            # High confidence: auto-approve but log for review
            self.logger.log_prediction(
                input_data=context,
                output=model_output,
                confidence=confidence,
                model_version=context.get("model_version", "unknown"),
                human_override=False
            )
            return {"decision": model_output, "method": "automated", "confidence": confidence}

        # Low confidence: require human review (Article 14(4)(a))
        review_request = await create_review_queue_item(
            model_output=model_output,
            confidence=confidence,
            context=context
        )

        return {
            "decision": "pending_human_review",
            "method": "human_oversight",
            "review_id": review_request.id,
            "reason": f"Confidence {confidence:.2f} below threshold {self.threshold}"
        }
```

### Step 4: Verify

```bash
# Run risk classification
python3 ~/ai-act/classifier.py \
  --codebase /path/to/ai-system \
  --output classification.json

# Verify logging completeness
python3 -c "
import json
with open('classification.json') as f:
    c = json.load(f)
print(f'Risk Level: {c[\"risk_level\"]}')
print(f'Obligations: {len(c[\"obligations\"])}')
for o in c['obligations']:
    print(f'  - {o}')
"

# Test human oversight gate
python3 -m pytest tests/test_human_oversight.py -v
```

## CLAUDE.md for EU AI Act Compliance

```markdown
# EU AI Act Compliance Standards

## Domain Rules
- Classify system risk before deployment (Art 6 + Annex III)
- High-risk: implement all Chapter III Section 2 requirements (Art 9-15)
- Limited-risk: implement transparency obligations (Art 50)
- All AI-generated content must be labeled as AI-generated
- Human oversight mechanism required for high-risk systems (Art 14)
- Technical documentation must be maintained and updated (Art 11)
- Logging must capture all inputs, outputs, and human overrides (Art 12)

## File Patterns
- Classification: ai_act/classifier.py
- Logging: services/ai_transparency_log.py
- Oversight: services/human_oversight.py
- Documentation: docs/ai_act/ (technical documentation per Art 11)
- Tests: tests/test_ai_act*.py

## Common Commands
- python3 classifier.py --codebase . --output classification.json
- python3 -m pytest tests/test_ai_act_compliance.py -v
- python3 generate_tech_doc.py --system-name MyAI --output docs/
```

## Common Pitfalls in EU AI Act Compliance

- **Risk classification underestimation:** Teams building recommendation systems for employment or credit often do not realize they are building high-risk AI systems. Claude Code scans for domain-specific indicators and flags potential Annex III classification.

- **Transparency theater:** Disclosing "AI is used" without explaining how or providing meaningful human recourse does not satisfy Article 13. Claude Code verifies that transparency implementations include specific decision factors, confidence levels, and appeal mechanisms.

- **GPAI model provider obligations forgotten:** Organizations using foundation models (GPT, Claude, Gemini) must comply with Article 53 GPAI transparency requirements including model cards and training data documentation, even for minimal-risk applications.

## Related

- [Claude Code for GDPR Data Mapping](/claude-code-gdpr-data-mapping-2026/)
- [Claude Code for WCAG Accessibility Testing](/claude-code-wcag-accessibility-testing-2026/)
- [Claude Code for ISO 27001 Controls Implementation](/claude-code-iso-27001-controls-implementation-2026/)


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




**Set it up →** Build your permission config with our [Permission Configurator](/permissions/).

## Related Guides

**Estimate tokens →** Calculate your usage with our [Token Estimator](/token-estimator/).

**Try it:** Estimate your monthly spend with our [Cost Calculator](/calculator/).

- [Claude Code for Prowler Compliance](/claude-code-for-prowler-compliance-workflow/)
- [Claude Code SOC 2 Compliance Audit Prep](/claude-code-soc2-compliance-audit-preparation-guide-2026/)
- [CCPA Compliance with Claude Code (2026)](/claude-code-ccpa-privacy-compliance-guide/)
- [Claude Code for SOX Compliance Audits](/claude-code-sox-financial-code-audit-workflow-guide/)

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
        "text": "Claude Code works with any Anthropic API plan, including the free tier. However, the free tier has lower rate limits (requests per minute and tokens per minute) that may slow down multi-step workflows."
      }
    },
    {
      "@type": "Question",
      "name": "How does this affect token usage and cost?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "The token cost depends on the size of your prompts and Claude's responses. Typical development tasks consume 10K-50K tokens per interaction. Using a CLAUDE.md file and skills reduces exploration tokens by 50-80%, which directly lowers costs."
      }
    },
    {
      "@type": "Question",
      "name": "Can I customize this for my specific project?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "Yes. All Claude Code behavior can be customized through CLAUDE.md (project rules), .claude/settings.json (permissions), and .claude/skills/ (domain knowledge). The most impactful customization is adding your project's specific patterns, conventions, and common commands to CLAUDE.md so Claude Code..."
      }
    },
    {
      "@type": "Question",
      "name": "What happens when Claude Code makes a mistake?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "Claude Code creates files and edits through standard filesystem operations, so all changes are visible in git diff. If a change is wrong, revert it with git checkout -- <file> for a single file or git stash for all changes."
      }
    }
  ]
}
</script>
