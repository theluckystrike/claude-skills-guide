---

layout: default
title: "Chrome Block Phishing Extension: A Developer Guide to Building Browser-Based Threat Detection"
description: "Learn how to build a Chrome extension that detects and blocks phishing attempts. Covers URL analysis, domain verification, and practical implementation patterns for developers."
date: 2026-03-15
author: "Claude Skills Guide"
permalink: /chrome-block-phishing-extension/
reviewed: true
score: 8
categories: [troubleshooting]
tags: [claude-code, claude-skills]
---


# Chrome Block Phishing Extension: A Developer Guide to Building Browser-Based Threat Detection

Phishing attacks remain one of the most effective vectors for credential theft and financial fraud. As a developer, building a Chrome extension that actively blocks phishing attempts gives you granular control over threat detection that browser defaults cannot match. This guide walks through the architecture, detection strategies, and implementation patterns for creating a production-ready phishing blocker.

## Extension Architecture Overview

A Chrome phishing blocker operates at multiple points in the browser request lifecycle. The most effective extensions combine several detection mechanisms:

1. **URL pattern matching** - Heuristic analysis of suspicious URL structures
2. **Domain reputation checking** - Cross-referencing against known phishing databases
3. **Visual deception detection** - Identifying look-alike domains and typosquatting
4. **Content-based analysis** - Examining page content for credential harvesting patterns

The manifest file defines these capabilities:

```json
{
  "manifest_version": 3,
  "name": "PhishGuard",
  "version": "1.0.0",
  "permissions": [
    "activeTab",
    "scripting",
    "storage"
  ],
  "host_permissions": [
    "<all_urls>"
  ],
  "background": {
    "service_worker": "background.js"
  },
  "action": {
    "default_popup": "popup.html",
    "default_icon": {
      "16": "icons/icon16.png",
      "48": "icons/icon48.png",
      "128": "icons/icon128.png"
    }
  }
}
```

## Core Detection Components

### URL Analysis Engine

The foundation of any phishing blocker is URL analysis. Focus on detecting these common attack patterns:

```javascript
// URL analysis utilities
const suspiciousPatterns = {
  // IP addresses used as hostname
  ipAddress: /^https?:\/\/\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}/,
  
  // Excessive subdomains (common in phishing)
  excessiveSubdomains: /^https?:\/\/([a-z0-9-]+\.){4,}/i,
  
  // Homograph attacks (look-alike characters)
  homograph: /[аеоресху]/i,
  
  // Common typosquatting targets
  typosquatting: /(g00gle|paypa1|amaz0n|faceb00k)/i,
  
  // URL shortener services (hides destination)
  urlShortener: /(bit\.ly|tinyurl\.com|t\.co|goo\.gl)\//
};

function analyzeURL(url) {
  const warnings = [];
  const parsed = new URL(url);
  
  // Check for IP address hostname
  if (suspiciousPatterns.ipAddress.test(url)) {
    warnings.push('IP address used as hostname');
  }
  
  // Check subdomain count
  if (suspiciousPatterns.excessiveSubdomains.test(url)) {
    warnings.push('Excessive subdomain depth');
  }
  
  // Check for suspicious TLDs
  const suspiciousTLDs = ['.xyz', '.top', '.work', '.click', '.gq', '.tk'];
  if (suspiciousTLDs.some(tld => parsed.hostname.endsWith(tld))) {
    warnings.push('Suspicious top-level domain');
  }
  
  // Check for login keywords in non-expected domains
  const loginKeywords = ['login', 'signin', 'account', 'verify', 'secure'];
  const isLoginPage = loginKeywords.some(kw => 
    url.toLowerCase().includes(kw)
  );
  
  if (isLoginPage && !isKnownBankingSite(parsed.hostname)) {
    warnings.push('Login page on unrecognized domain');
  }
  
  return warnings;
}

function isKnownBankingSite(hostname) {
  const trustedDomains = [
    'chase.com', 'bankofamerica.com', 'wellsfargo.com',
    'paypal.com', 'amazon.com', 'apple.com', 'google.com'
  ];
  return trustedDomains.some(domain => hostname.endsWith(domain));
}
```

### Domain Reputation Service

For production extensions, integrate with reputation APIs. A practical approach uses multiple data sources:

```javascript
class ReputationChecker {
  constructor() {
    this.cache = new Map();
    this.cacheTTL = 3600000; // 1 hour
  }

  async checkDomain(domain) {
    // Check cache first
    const cached = this.cache.get(domain);
    if (cached && Date.now() - cached.timestamp < this.cacheTTL) {
      return cached.result;
    }

    // Query multiple sources in parallel
    const [googleResult, phishTankResult] = await Promise.all([
      this.checkGoogleSafeBrowsing(domain),
      this.checkPhishTank(domain)
    ]);

    const result = {
      isPhishing: googleResult || phishTankResult,
      sources: {
        google: googleResult,
        phishtank: phishTankResult
      },
      timestamp: Date.now()
    };

    this.cache.set(domain, result);
    return result;
  }

  async checkGoogleSafeBrowsing(domain) {
    // Requires API key - use environment variable
    const apiKey = process.env.GOOGLE_SAFE_BROWSING_KEY;
    const url = `https://safebrowsing.googleapis.com/v4/threatMatches:find?key=${apiKey}`;
    
    // Implementation would POST to Google API
    // This is a simplified example
    return false;
  }

  async checkPhishTank(domain) {
    // PhishTank provides a free API for lookup
    // Implementation would query their endpoint
    return false;
  }
}
```

## Integrating with Chrome APIs

The background service worker handles the core logic:

```javascript
// background.js
chrome.runtime.onInstalled.addListener(() => {
  console.log('PhishGuard extension installed');
});

// Listen for navigation events
chrome.webNavigation.onCompleted.addListener(async (details) => {
  if (details.frameId !== 0) return; // Only main frame
  
  const url = details.url;
  const analysis = analyzeURL(url);
  
  if (analysis.warnings.length > 0) {
    // Query reputation service
    const reputation = await reputationChecker.checkDomain(
      new URL(url).hostname
    );
    
    if (analysis.warnings.length >= 2 || reputation.isPhishing) {
      // Block the page
      chrome.tabs.update(details.tabId, {
        url: `data:blocked.html?url=${encodeURIComponent(url)}&reasons=${encodeURIComponent(
          JSON.stringify(analysis.warnings)
        )}`
      });
      
      // Show warning icon
      chrome.action.setBadgeText({ text: '!', tabId: details.tabId });
      chrome.action.setBadgeBackgroundColor({ color: '#FF0000' });
    }
  }
});
```

## Content-Based Detection

Beyond URL analysis, examine page content for phishing indicators:

```javascript
// Inject script to analyze page content
async function analyzePageContent(tabId) {
  const results = await chrome.scripting.executeScript({
    target: { tabId },
    func: () => {
      const indicators = [];
      
      // Check for password fields in suspicious contexts
      const passwordFields = document.querySelectorAll('input[type="password"]');
      if (passwordFields.length > 0) {
        // Check if form action points to external domain
        passwordFields.forEach(field => {
          const form = field.closest('form');
          if (form && form.action) {
            try {
              const formDomain = new URL(form.action).hostname;
              const pageDomain = window.location.hostname;
              if (formDomain !== pageDomain) {
                indicators.push('Password field submits to different domain');
              }
            } catch (e) {}
          }
        });
      }
      
      // Check for common phishing page patterns
      const title = document.title.toLowerCase();
      if (title.includes('verify your account') || 
          title.includes('confirm your identity')) {
        indicators.push('Common phishing title pattern');
      }
      
      // Check for hidden iframes (credential harvesting)
      const hiddenIframes = document.querySelectorAll('iframe[style*="display: none"]');
      if (hiddenIframes.length > 0) {
        indicators.push('Hidden iframe detected');
      }
      
      return indicators;
    }
  });
  
  return results[0].result;
}
```

## Performance and Privacy Considerations

When building a phishing blocker, consider these implementation details:

**Local Processing First**: Perform URL analysis entirely in the browser. Only query external reputation services when local heuristics flag something suspicious. This reduces API calls and protects user privacy.

**Rate Limiting**: Implement request throttling to prevent abuse:

```javascript
class RateLimiter {
  constructor(maxRequests, windowMs) {
    this.maxRequests = maxRequests;
    this.windowMs = windowMs;
    this.requests = [];
  }

  canProceed() {
    const now = Date.now();
    this.requests = this.requests.filter(r => now - r < this.windowMs);
    return this.requests.length < this.maxRequests;
  }

  recordRequest() {
    this.requests.push(Date.now());
  }
}
```

**Storage Optimization**: Use Chrome's storage API efficiently:

```javascript
// Prefer sync storage for small, frequently accessed data
// Use storage.session for temporary data
// Reserve storage.local for large datasets

chrome.storage.local.get(['blocklist', 'settings'], (result) => {
  // Load blocklist on startup, cache in memory
  blocklist = result.blocklist || [];
});
```

## Testing Your Extension

Before distribution, test thoroughly:

1. **Unit test detection logic** with known phishing URLs
2. **Integration test** with Chrome APIs using Puppeteer
3. **Performance test** with 1000+ URL evaluations
4. **False positive testing** against common legitimate sites

```javascript
// Example test case
const testCases = [
  { url: 'https://paypal.com/login', expected: false },
  { url: 'https://paypa1.com/login', expected: true },
  { url: 'https://192.168.1.1/login', expected: true },
  { url: 'https://login.secure-chase.phishing.xyz/', expected: true }
];

testCases.forEach(tc => {
  const result = analyzeURL(tc.url);
  console.assert(
    (result.warnings.length > 0) === tc.expected,
    `Failed: ${tc.url}`
  );
});
```

Building a Chrome extension to block phishing requires balancing detection accuracy with performance. Start with robust URL analysis, add reputation checking for borderline cases, and continuously refine based on user feedback and emerging threat patterns.

## Related Reading

- [Claude Code for Beginners: Complete Getting Started Guide](/claude-skills-guide/claude-code-for-beginners-complete-getting-started-2026/)
- [Best Claude Skills for Developers in 2026](/claude-skills-guide/best-claude-skills-for-developers-2026/)
- [Claude Skills Guides Hub](/claude-skills-guide/guides-hub/)

Built by theluckystrike — More at [zovo.one](https://zovo.one)
