---
layout: default
title: "Claude Code CSP Content Security Policy Generation Guide"
description: "Generate and implement Content Security Policy headers with Claude Code. Secure your web apps against XSS and data injection attacks."
date: 2026-03-13
author: "Claude Skills Guide"
categories: [guides]
tags: [claude-code, claude-skills]
reviewed: true
score: 8
---

# Claude Code CSP Content Security Policy Generation Guide

Content Security Policy (CSP) is one of the most effective defenses against cross-site scripting (XSS) attacks and data injection vulnerabilities. When properly implemented, CSP tells browsers exactly which resources are allowed to load on your page, blocking malicious scripts from executing. This guide shows you how to use Claude Code to generate, validate, and maintain CSP headers for your projects.

## Why Content Security Policy Matters

Modern web applications load resources from multiple sources: your own servers, third-party APIs, content delivery networks, analytics tools, and embedded widgets. Each of these represents a potential attack vector. Without a CSP, browsers execute any script that arrives alongside your HTML, leaving users vulnerable to credential theft, session hijacking, and malware distribution.

A well-configured CSP reduces your attack surface significantly. According to the OWASP Foundation, proper CSP implementation can prevent up to 90% of cross-site scripting attacks. The challenge is that CSP can be complex to configure correctly—too restrictive and your application breaks, too permissive and you gain little security benefit.

## Generating CSP Headers with Claude Code

Claude Code can help you generate appropriate CSP headers by analyzing your application's resource loading patterns. Here's a practical workflow:

### Step 1: Analyze Your Application's Resource Loading

Ask Claude Code to examine your codebase and identify all external resource dependencies:

```
Analyze this project's index.html and JavaScript files to identify all external resource sources including scripts, stylesheets, images, fonts, and API endpoints.
```

Claude will scan your files and produce a comprehensive list. For a typical React application, you might see something like this:

```javascript
// External resources found in your project
const resources = {
  scripts: [
    'https://www.google-analytics.com/analytics.js',
    'https://cdn.example.com/library.js'
  ],
  styles: [
    'https://fonts.googleapis.com/css',
    'https://cdn.example.com/styles.css'
  ],
  images: [
    'https://storage.example.com/images/'
  ],
  fonts: [
    'https://fonts.gstatic.com'
  ],
  connects: [
    'https://api.example.com'
  ]
};
```

### Step 2: Generate the CSP Header

Based on the analysis, generate your CSP header:

```
Generate a Content Security Policy header for a React application that loads resources from google-analytics.com, cdn.example.com, storage.example.com, api.example.com, and fonts.googleapis.com. Include strict fallbacks and report-uri for violation reporting.
```

Claude will generate a header like this:

```
Content-Security-Policy: 
  default-src 'self';
  script-src 'self' https://www.google-analytics.com https://cdn.example.com;
  style-src 'self' 'unsafe-inline' https://fonts.googleapis.com https://cdn.example.com;
  img-src 'self' https://storage.example.com data:;
  font-src 'self' https://fonts.gstatic.com;
  connect-src 'self' https://api.example.com;
  report-uri https://your-domain.com/csp-report
```

### Step 3: Test in Report-Only Mode

Before enforcing your CSP, test it in report-only mode to identify any violations without breaking functionality:

```javascript
// In your server configuration (Express example)
app.use((req, res, next) => {
  res.setHeader(
    'Content-Security-Policy-Report-Only',
    "default-src 'self'; script-src 'self' https://www.google-analytics.com https://cdn.example.com; report-uri https://your-domain.com/csp-report"
  );
  next();
});
```

Collect reports for several days. You'll likely discover resources you missed in your initial analysis—third-party widgets, browser extensions, or legacy code that loads content dynamically.

## Implementing CSP with Different Frameworks

### Express.js

```javascript
const helmet = require('helmet');

app.use(helmet.contentSecurityPolicy({
  directives: {
    defaultSrc: ["'self'"],
    scriptSrc: ["'self'", 'https://www.google-analytics.com'],
    styleSrc: ["'self'", "'unsafe-inline'", 'https://fonts.googleapis.com'],
    imgSrc: ["'self'", 'data:', 'https://storage.example.com'],
    fontSrc: ["'self'", 'https://fonts.gstatic.com'],
    connectSrc: ["'self'", 'https://api.example.com'],
    reportUri: 'https://your-domain.com/csp-report'
  }
}));
```

### Next.js (next.config.js)

```javascript
module.exports = {
  async headers() {
    return [
      {
        source: '/:path*',
        headers: [
          {
            key: 'Content-Security-Policy',
            value: "default-src 'self'; script-src 'self' 'unsafe-eval' 'unsafe-inline' https://www.google-analytics.com; style-src 'self' 'unsafe-inline' https://fonts.googleapis.com; img-src 'self' data: blob: https://storage.example.com; font-src 'self' data: https://fonts.gstatic.com; connect-src 'self' https://api.example.com"
          }
        ]
      }
    ];
  }
};
```

### Nginx

```
add_header Content-Security-Policy "default-src 'self'; script-src 'self' https://www.google-analytics.com; style-src 'self' 'unsafe-inline' https://fonts.googleapis.com; img-src 'self' data: https://storage.example.com; font-src 'self' https://fonts.gstatic.com;";
```

## Iterative CSP Hardening

Once your basic CSP is working, progressively harden it:

1. **Remove 'unsafe-inline' from script-src** - This is the most significant security improvement. Move inline scripts to external files.

2. **Add nonces or hashes** - For scripts that must remain inline, use cryptographic nonces:
   ```
   Content-Security-Policy: script-src 'nonce-{RANDOM}' 'strict-dynamic'
   ```

3. **Enable strict-dynamic** - This tells browsers to trust scripts loaded by trusted scripts, reducing reliance on whitelisted domains.

4. **Add upgrade-insecure-requests** - Automatically upgrade HTTP resources to HTTPS:
   ```
   Content-Security-Policy: upgrade-insecure-requests
   ```

## Automating CSP with Claude Skills

Several Claude skills can assist with CSP management:

- The [**tdd** skill](/claude-skills-guide/articles/best-claude-skills-for-developers-2026/) helps you write tests that verify CSP headers are correctly applied
- The **frontend-design** skill can audit your frontend code for CSP compliance
- Use [**supermemory**](/claude-skills-guide/articles/claude-skills-token-optimization-reduce-api-costs/) to maintain a record of approved domains and their purposes
- The **xlsx** skill helps you track CSP violations across different environments

## Common CSP Pitfalls

Avoid these frequent mistakes when implementing CSP:

- **Overly permissive defaults**: Starting with `default-src *` provides minimal security
- **Forgetting about iframes**: The `frame-ancestors` directive replaces the deprecated `X-Frame-Options`
- **Ignoring report-uri**: Without violation reporting, you won't know when your policy blocks legitimate resources
- **Missing fallback policies**: Some older browsers don't support CSP—continue using X-XSS-Protection as a fallback

## Conclusion

Content Security Policy is essential for securing modern web applications. Using Claude Code to generate, test, and iterate on your CSP implementation makes the process significantly more manageable. Start with a report-only policy, gather data on actual resource usage, then progressively tighten your restrictions.

Remember that CSP is not a one-time configuration—it requires ongoing maintenance as your application evolves. Regular audits using Claude Code's analysis capabilities help ensure your CSP remains effective against emerging threats.
---

## Related Reading

- [Claude Skills for Enterprise Security and Compliance](/claude-skills-guide/articles/claude-skills-for-enterprise-security-compliance-guide/) — Enterprise security framework patterns that complement CSP implementation
- [Best Claude Skills for Developers 2026](/claude-skills-guide/articles/best-claude-skills-for-developers-2026/) — Developer skills for building and testing security configurations
- [Claude Skills Token Optimization: Reduce API Costs](/claude-skills-guide/articles/claude-skills-token-optimization-reduce-api-costs/) — Efficiently generate and iterate on security policy configurations

Built by theluckystrike — More at [zovo.one](https://zovo.one)
