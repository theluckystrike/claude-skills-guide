---
layout: default
title: "Generate CSP Headers with Claude Code"
description: "Generate Content Security Policy headers with Claude Code to block XSS and data injection attacks. Includes policy testing and report-uri setup."
date: 2026-03-13
last_modified_at: 2026-04-17
last_tested: "2026-04-21"
author: "Claude Skills Guide"
categories: [guides]
tags: [claude-code, claude-skills]
reviewed: true
score: 8
permalink: /claude-code-csp-content-security-policy-generation-guide/
render_with_liquid: false
geo_optimized: true
---
{% raw %}
[Content Security Policy (CSP) is one of the most effective defenses](/best-claude-code-skills-to-install-first-2026/) against cross-site scripting (XSS) attacks and data injection vulnerabilities. When properly implemented, CSP tells browsers exactly which resources are allowed to load on your page, blocking malicious scripts from executing. This guide shows you how to use Claude Code to generate, validate, and maintain CSP headers for your projects.

## Why Content Security Policy Matters

[Modern web applications load resources from multiple sources](/claude-skill-md-format-complete-specification-guide/): your own servers, third-party APIs, content delivery networks, analytics tools, and embedded widgets. Each of these represents a potential attack vector. Without a CSP, browsers execute any script that arrives alongside your HTML, leaving users vulnerable to credential theft, session hijacking, and malware distribution.

A well-configured CSP reduces your attack surface significantly. According to the OWASP Foundation, proper CSP implementation can prevent up to 90% of cross-site scripting attacks. The challenge is that CSP can be complex to configure correctly, too restrictive and your application breaks, too permissive and you gain little security benefit.

The stakes have increased as web applications have grown more complex. A typical SPA in 2026 might pull scripts from a CDN, load fonts from Google, send analytics data to multiple vendors, fetch from a backend API, and embed third-party widgets, all simultaneously. Each domain in that chain is an implicit trust relationship that browsers have no way to evaluate without explicit guidance from you. CSP is that guidance.

Beyond XSS prevention, CSP also addresses other attack classes. The `frame-ancestors` directive prevents clickjacking by controlling which pages can embed yours in an iframe. The `upgrade-insecure-requests` directive forces HTTP resource requests to HTTPS automatically. The `block-all-mixed-content` directive prevents mixed content warnings that erode user trust. A single well-crafted header addresses multiple vulnerability categories at once.

## Understanding CSP Directives

Before generating a CSP with Claude Code, understanding the key directives helps you evaluate the output and ask better questions.

| Directive | Controls | Common Values |
|-----------|----------|---------------|
| `default-src` | Fallback for all resource types | `'self'` |
| `script-src` | JavaScript execution | `'self'`, domain names, `'nonce-...'` |
| `style-src` | CSS loading | `'self'`, `'unsafe-inline'`, domains |
| `img-src` | Image loading | `'self'`, `data:`, CDN domains |
| `font-src` | Font loading | `'self'`, font CDN domains |
| `connect-src` | Fetch, XHR, WebSocket | `'self'`, API domains |
| `frame-src` | iframe sources | `'none'` or specific domains |
| `frame-ancestors` | Who can embed your page | `'none'` or specific domains |
| `object-src` | Plugin content | `'none'` (almost always) |
| `base-uri` | Base tag sources | `'self'` |
| `form-action` | Form submission targets | `'self'`, specific domains |

The `default-src` directive acts as a fallback: any resource type not explicitly listed uses `default-src` rules. This is why starting with `default-src 'self'` is a good baseline, it restricts everything by default and forces you to explicitly allow each resource type you actually use.

Two directives that confuse developers: `frame-src` controls which external sources your page can load in iframes, while `frame-ancestors` controls which pages can embed your page in their iframes. They point in opposite directions. For most applications, `frame-ancestors 'none'` is the right choice unless you intentionally allow embedding.

## Generating CSP Headers with Claude Code

Claude Code can help you generate appropriate CSP headers by analyzing your application's resource loading patterns. Here's a practical workflow:

## Step 1: Analyze Your Application's Resource Loading

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

This analysis step is crucial because it surfaces dependencies you may have forgotten about or that were added by a colleague. Dynamic imports, lazy-loaded components, and third-party SDKs all add domains that a manual audit would likely miss.

## Step 2: Generate the CSP Header

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

Notice the `'unsafe-inline'` on `style-src`. This is often unavoidable with CSS-in-JS libraries and Google Fonts, which injects inline styles. Claude Code will flag these as areas to address in a hardening pass rather than silently accepting them.

## Step 3: Test in Report-Only Mode

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

Collect reports for several days. You'll likely discover resources you missed in your initial analysis, third-party widgets, browser extensions, or legacy code that loads content dynamically.

## Step 4: Collect and Analyze Violation Reports

CSP violation reports arrive as JSON POST requests to your `report-uri` endpoint. A minimal endpoint to collect them:

```javascript
// Express route to capture CSP violations
app.post('/csp-report', express.json({ type: 'application/csp-report' }), (req, res) => {
 const violation = req.body['csp-report'];
 console.log({
 blockedUri: violation['blocked-uri'],
 violatedDirective: violation['violated-directive'],
 documentUri: violation['document-uri'],
 originalPolicy: violation['original-policy']
 });
 res.status(204).send();
});
```

After a few days of production traffic, ask Claude Code to analyze your collected violation logs:

```
Here are 200 CSP violation reports from the past 72 hours. Identify which violations represent legitimate resources I need to whitelist versus violations that suggest actual attack attempts or misconfigured third-party code.
```

Claude will categorize violations, explain which domains are safe to add, and identify suspicious patterns like unusual injected scripts or unexpected eval() usage.

## Implementing CSP with Different Frameworks

## Express.js

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

Helmet is the standard approach for Express CSP. The library handles proper header formatting and normalizes directive names between camelCase (Helmet convention) and the hyphenated format browsers expect. Ask Claude Code to help you migrate an existing Helmet configuration to a stricter policy by passing the current directives and asking for a hardened version.

Next.js (next.config.js)

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

Next.js development mode requires `'unsafe-eval'` because of how hot module replacement works. You can use environment variables to apply a stricter policy in production:

```javascript
const isDev = process.env.NODE_ENV === 'development';

const cspHeader = isDev
 ? "default-src 'self'; script-src 'self' 'unsafe-eval' 'unsafe-inline';"
 : "default-src 'self'; script-src 'self' 'nonce-{{NONCE}}';";
```

Claude Code can generate nonce-injection middleware for Next.js that creates a fresh nonce per request and injects it into both the CSP header and the relevant script tags automatically.

## Nginx

```
add_header Content-Security-Policy "default-src 'self'; script-src 'self' https://www.google-analytics.com; style-src 'self' 'unsafe-inline' https://fonts.googleapis.com; img-src 'self' data: https://storage.example.com; font-src 'self' https://fonts.gstatic.com;";
```

For Nginx, place this directive in your `server` or `location` block. If you serve multiple applications from one Nginx instance with different security requirements, use separate `location` blocks with per-path CSP headers.

## Apache

```apache
Header always set Content-Security-Policy "default-src 'self'; script-src 'self' https://cdn.example.com; style-src 'self' 'unsafe-inline'; img-src 'self' data:;"
```

For Apache, ensure `mod_headers` is enabled. The `always` keyword ensures the header is set even for error responses, preventing information leakage through error pages that might load external resources.

## Iterative CSP Hardening

Once your basic CSP is working, progressively harden it:

1. Remove 'unsafe-inline' from script-src - This is the most significant security improvement. Move inline scripts to external files.

2. Add nonces or hashes - For scripts that must remain inline, use cryptographic nonces:
 ```
 Content-Security-Policy: script-src 'nonce-{RANDOM}' 'strict-dynamic'
 ```

3. Enable strict-dynamic - This tells browsers to trust scripts loaded by trusted scripts, reducing reliance on whitelisted domains.

4. Add upgrade-insecure-requests - Automatically upgrade HTTP resources to HTTPS:
 ```
 Content-Security-Policy: upgrade-insecure-requests
 ```

5. Lock down object-src - Plugin-based attacks (Flash, Java applets) are rare but still possible in legacy enterprise environments. Adding `object-src 'none'` closes this vector entirely at no cost.

6. Add base-uri restriction - The `base-uri 'self'` directive prevents attackers from injecting a `<base>` tag to redirect all relative URLs:
 ```
 Content-Security-Policy: base-uri 'self';
 ```

The hardening process is where Claude Code earns its keep. You can iterate quickly:

```
Here's my current CSP. I've moved all inline scripts to external files. Which unsafe-inline flags can I now remove, and what should I replace them with?
```

Claude will walk through each remaining `unsafe-inline` occurrence, explain why it exists, and suggest a compliant alternative, whether that's a nonce, a hash, or a specific code refactor.

## Nonce-Based CSP in Practice

Nonces represent the gold standard for `script-src` security. Instead of whitelisting domains (which could serve malicious scripts), you generate a random value per request and mark each legitimate script with that value:

```javascript
// Middleware that generates and injects nonces
const crypto = require('crypto');

function cspMiddleware(req, res, next) {
 const nonce = crypto.randomBytes(16).toString('base64');
 res.locals.nonce = nonce;
 res.setHeader(
 'Content-Security-Policy',
 `default-src 'self'; script-src 'nonce-${nonce}' 'strict-dynamic'; style-src 'self' 'unsafe-inline'; img-src 'self' data:;`
 );
 next();
}
```

In your HTML templates, every legitimate script tag gets the nonce attribute:

```html
<script nonce="<%= nonce %>">
 // Inline script that needs to run
 window.__INITIAL_STATE__ = <%= JSON.stringify(state) %>;
</script>
```

Any injected script without the matching nonce is blocked. Since nonces change on every request, an attacker cannot pre-compute or reuse one. The `'strict-dynamic'` keyword extends this trust to scripts loaded by the nonced script, which handles dynamic imports cleanly.

## CSP and Single-Page Applications

SPAs present unique challenges. Client-side routing, dynamic component loading, and state hydration all involve patterns that naive CSP configurations break. Common issues and fixes:

Webpack hot module replacement: Requires WebSocket connections to the dev server. Add `connect-src 'self' ws://localhost:3000` in development.

CSS-in-JS (styled-components, Emotion): These libraries inject style tags at runtime, triggering `style-src` violations. Solutions include using the `nonce` prop on your CSS-in-JS provider component, enabling the `StyleSheetManager` in nonce mode, or switching to static CSS files for production builds.

Dynamic imports: Code splitting generates chunk files that load from your own domain, so these typically work fine under `script-src 'self'`. Problems arise when chunks load from a CDN. Make sure your CDN domain is listed or use relative URLs for chunk loading.

Ask Claude Code to audit your SPA configuration specifically:

```
Review my webpack config and styled-components setup for CSP compatibility issues. Suggest concrete changes to make the app work with script-src 'nonce-...' and style-src 'self' 'unsafe-inline'.
```

## Automating CSP with Claude Skills

Several Claude skills can assist with CSP management:

- The [tdd skill](/best-claude-skills-for-developers-2026/) helps you write tests that verify CSP headers are correctly applied
- The frontend-design skill can audit your frontend code for CSP compliance
- Use [supermemory](/claude-skills-token-optimization-reduce-api-costs/) to maintain a record of approved domains and their purposes
- The xlsx skill helps you track CSP violations across different environments

Automated testing for CSP is underused. With the tdd skill, you can write integration tests that verify headers on real responses:

```javascript
describe('Security headers', () => {
 it('sets Content-Security-Policy header on all responses', async () => {
 const res = await request(app).get('/');
 expect(res.headers['content-security-policy']).toBeDefined();
 expect(res.headers['content-security-policy']).toContain("default-src 'self'");
 expect(res.headers['content-security-policy']).not.toContain("'unsafe-eval'");
 });

 it('does not allow framing from external origins', async () => {
 const res = await request(app).get('/');
 const csp = res.headers['content-security-policy'];
 expect(csp).toMatch(/frame-ancestors 'none'|frame-ancestors 'self'/);
 });
});
```

These tests run in CI and catch regressions before they reach production, for example, if a new dependency adds a Helmet override that relaxes your policy.

## Common CSP Pitfalls

Avoid these frequent mistakes when implementing CSP:

- Overly permissive defaults: Starting with `default-src *` provides minimal security
- Forgetting about iframes: The `frame-ancestors` directive replaces the deprecated `X-Frame-Options`
- Ignoring report-uri: Without violation reporting, you won't know when your policy blocks legitimate resources
- Missing fallback policies: Some older browsers don't support CSP, continue using X-XSS-Protection as a fallback
- Using report-uri in production only: You want violation data from staging and development environments too, since developers often add third-party integrations locally that never get accounted for in the policy
- Forgetting WebSocket connections: If your app uses WebSockets, the `connect-src` directive must include the `wss://` or `ws://` origins explicitly
- Not testing with extensions disabled: Browser extensions inject content scripts that trigger CSP violations, which can produce a lot of noise in your violation reports and mask real issues

## Conclusion

Content Security Policy is essential for securing modern web applications. Using Claude Code to generate, test, and iterate on your CSP implementation makes the process significantly more manageable. Start with a report-only policy, gather data on actual resource usage, then progressively tighten your restrictions.

The real value of using Claude Code for CSP work is the iteration speed. Going from a violation report to a policy update that handles it correctly, while not regressing on other resources, is the kind of task that previously required a security specialist and half a day. With Claude Code, it becomes a ten-minute conversation.

Remember that CSP is not a one-time configuration, it requires ongoing maintenance as your application evolves. New dependencies, new third-party integrations, and architectural changes all affect your resource loading patterns. Regular audits using Claude Code's analysis capabilities help ensure your CSP remains effective against emerging threats.
---

---

<div class="mastery-cta">

I'm a solo developer in Vietnam. 50K Chrome extension users. $500K+ on Upwork. 5 Claude Max subscriptions running agent fleets in parallel.

These are my actual CLAUDE.md templates, orchestration configs, and prompts. Not a course. Not theory. The files I copy into every project before I write a line of code.

**[See what's inside →](https://zovo.one/lifetime?utm_source=ccg&utm_medium=cta-default&utm_campaign=claude-code-csp-content-security-policy-generation-guide)**

$99 once. Free forever. 47/500 founding spots left.

</div>

Related Reading

- [Claude Skills for Enterprise Security and Compliance](/claude-skills-for-enterprise-security-compliance-guide/). Enterprise security framework patterns that complement CSP implementation
- [Best Claude Skills for Developers 2026](/best-claude-skills-for-developers-2026/). Developer skills for building and testing security configurations
- [Claude Skills Token Optimization: Reduce API Costs](/claude-skills-token-optimization-reduce-api-costs/). Efficiently generate and iterate on security policy configurations
- [Claude Code For Modsecurity Waf — Complete Developer Guide](/claude-code-for-modsecurity-waf-workflow-guide/)
- [How to Add Authentication to Your App Using Claude Code](/how-to-add-authentication-to-your-app-using-claude-code/)
- [Claude Code for Runbook Authoring Workflow Tutorial](/claude-code-for-runbook-authoring-workflow-tutorial/)
- [Claude Code for Vault Transit Encryption Guide](/claude-code-for-vault-transit-encryption-guide/)
- [Claude Code Permission Rules in settings.json](/claude-code-permission-rules-settings-json-guide/)
- [Claude Code for WorkOS AuthKit — Workflow Guide](/claude-code-for-workos-authkit-workflow-guide/)
- [Claude Code for Vault Secrets Management Workflow](/claude-code-for-vault-secrets-management-workflow/)

Built by theluckystrike. More at [zovo.one](https://zovo.one)
{% endraw %}


