---
layout: default
title: "Chrome Site Isolation Explained (2026)"
last_tested: "2026-04-22"
description: "Understand Chrome site isolation mechanics, security benefits, and implementation details. Learn how process separation protects your browser from."
date: 2026-03-15
last_modified_at: 2026-04-17
author: theluckystrike
permalink: /chrome-site-isolation-explained/
categories: [guides]
tags: [tools]
reviewed: true
score: 8
geo_optimized: true
sitemap: false
robots: "noindex, nofollow"
---
# Chrome Site Isolation Explained: A Developer Guide

Chrome site isolation is a security architecture that treats each website as running in its own separate process. This fundamental design change protects users from cross-site scripting attacks, Spectre-like speculative execution vulnerabilities, and other browser-based threats. Understanding how site isolation works helps developers make informed decisions about security-sensitive web applications and debug cross-origin behavior that can otherwise seem arbitrary.

## How Site Isolation Works

Chrome traditionally ran all tabs within a single renderer process, sharing memory space across different origins. When you open five websites, they typically share one or two browser processes. Site isolation changes this by enforcing strict process boundaries based on the "site" concept, a combination of scheme and registered domain.

When site isolation is enabled, Chrome assigns each site to its own renderer process. The browser maintains a mapping between frames and processes:

```javascript
// Conceptual representation of process-site mapping
const siteToProcess = new Map();

function getProcessForFrame(frame) {
 const site = extractSite(frame.url);

 if (!siteToProcess.has(site)) {
 // Create new renderer process for this site
 siteToProcess.set(site, chrome.processes.create());
 }

 return siteToProcess.get(site);
}

function extractSite(url) {
 // Chrome uses scheme + registered domain (eTLD+1) as the "site"
 // https://example.com -> https://example.com
 // https://api.example.com -> https://example.com (same site)
 // http://example.com -> http://example.com (different: scheme differs)
 const parsed = new URL(url);
 const domain = getRegisteredDomain(parsed.hostname); // e.g. "example.com"
 return `${parsed.protocol}//${domain}`;
}
```

This separation happens automatically. Chrome determines the "site" by extracting the scheme and registered domain (the eTLD+1) from a URL. Both `https://example.com` and `https://api.example.com` belong to the same site because they share the registered domain `example.com`. However, `https://example.com` and `http://example.com` are different sites due to the scheme difference. This distinction matters a great deal for how isolation is applied.

The isolation architecture involves multiple Chrome processes working together:

| Process Type | Responsibility | Isolation Level |
|---|---|---|
| Browser process | UI, navigation, security policy | Runs with full OS privileges |
| Renderer process | Parse HTML, run JavaScript, paint | Sandboxed, one per site |
| GPU process | Accelerated rendering | Shared across sites |
| Network process | Fetch resources | Shared, enforces CORS |
| Utility processes | Codecs, extensions | Varies |

Each renderer process is sandboxed by the OS, meaning it cannot directly access the filesystem, network stack, or other processes' memory. Communication between the renderer and browser processes happens through a defined IPC channel with strict message validation.

## The Security Benefits

Site isolation provides defense against several attack vectors that plague traditional browser architectures. Each benefit addresses a specific threat model.

## Cross-Site Scripting Containment

Without isolation, an XSS vulnerability on one domain can attempt to steal cookies, tokens, or data from any other open tab via timing attacks or shared memory. Site isolation ensures that malicious code running in one origin cannot access the memory or state of other sites.

```javascript
// What an attacker CAN do with XSS when site isolation is active:
// - Read cookies for the vulnerable site's origin
// - Modify the DOM on the vulnerable site
// - Steal data submitted to forms on the vulnerable site
// - Make requests from the vulnerable site's origin

// What an attacker CANNOT do:
// - Read cookies from open tabs on other sites
// - Access localStorage or sessionStorage from other origins
// - Read authentication tokens or headers from other origins
// - Access the DOM of cross-origin iframes embedded in the page
// - Read memory belonging to other renderer processes
```

This containment is meaningful even when an attacker fully compromises a renderer process. The sandbox prevents the compromised process from reaching beyond its assigned site.

## Spectre Mitigation

The Spectre class of vulnerabilities (CVE-2017-5753, CVE-2017-5715) allows attackers to read arbitrary memory locations through timing side channels in speculative execution. JavaScript running in the browser can exploit these CPU-level vulnerabilities to read memory that belongs to other processes, or even to other parts of the same process.

By separating sites into distinct processes, Chrome limits the blast radius of a Spectre attack. An attacker exploiting Spectre from a compromised tab can only read memory belonging to that site's renderer process. They cannot reach memory from a banking site open in another tab.

This is also why Chrome temporarily disabled high-resolution timers (`performance.now()`) and `SharedArrayBuffer` after Spectre became public in 2018. Those features make Spectre attacks significantly easier by providing precise timing. They were re-enabled later for pages that opt into explicit isolation via COOP and COEP headers (covered below).

## Renderer Process Compromise Isolation

When a renderer process is compromised through a browser vulnerability (not just JavaScript, sometimes a malformed image or video codec can trigger a renderer bug), process isolation prevents lateral movement. The attacker controls one sandboxed renderer. They cannot:

- Read memory from other renderer processes
- Escalate privileges to the browser process directly
- Access the filesystem or network stack without going through the IPC channel

This does not make Chrome invulnerable, there are documented sandbox escapes, but it raises the cost and complexity of a full browser compromise significantly.

## Verifying Site Isolation in Your Browser

Chrome enables site isolation by default for most users since Chrome 67. You can verify its status and observe its behavior through several built-in tools.

## Checking via chrome://process-internals

Navigate to `chrome://process-internals` in your browser. This page displays active renderer processes and their assigned sites. You should see different process IDs for different registered domains, and the same process ID for subdomains sharing a registered domain:

```
Renderer Process 4852: https://example.com
 Frame: https://example.com (main frame)
 Frame: https://api.example.com (same site, same process)

Renderer Process 4857: https://different-site.com
 Frame: https://different-site.com (main frame)

Renderer Process 4861: https://widget.third-party.com
 Frame: https://widget.third-party.com (cross-site iframe, own process)
```

The cross-site iframe getting its own process is a key site isolation behavior. Before site isolation, that iframe would share a process with the page embedding it, creating a potential attack surface.

## Checking via chrome://flags

You can inspect and configure isolation settings:

1. Navigate to `chrome://flags`
2. Search for "site isolation" or "site-per-process"
3. Check `chrome://flags/#enable-site-per-process`. this is enabled by default

## Enabling Strict Site Isolation

Standard site isolation assigns each registered domain its own process. Strict site isolation goes further by isolating frames even when they share a registered domain but differ in subdomain:

1. Navigate to `chrome://flags/#enable-site-per-process`
2. Set the flag to "Enabled"
3. Restart Chrome

With strict isolation, `https://api.example.com` embedded in `https://www.example.com` gets its own renderer process. This provides maximum protection at the cost of slightly higher memory usage, and can expose cross-origin assumption bugs in web applications that relied on subdomain sharing.

## Developer Considerations

Site isolation has real consequences for how cross-origin communication and storage work. Understanding these details prevents debugging time spent on mysterious behavior.

## Cross-Origin Communication

With site isolation, cross-origin frames run in separate processes with no shared memory. Direct property access across origin boundaries is blocked. The `postMessage` API is the standard approach for intentional cross-origin communication:

```javascript
// In the parent page. sending to a cross-origin iframe
const iframe = document.querySelector('#payment-frame');

function sendPaymentData(cardData) {
 iframe.contentWindow.postMessage(
 {
 type: 'payment-data',
 payload: cardData
 },
 'https://payment-processor.example.com' // Always specify target origin
 );
}

// In the iframe. receiving from the parent
window.addEventListener('message', (event) => {
 // CRITICAL: Always verify origin before processing
 if (event.origin !== 'https://your-app.com') {
 console.warn('Rejected message from unexpected origin:', event.origin);
 return;
 }

 if (event.data.type === 'payment-data') {
 processPayment(event.data.payload);
 }
});
```

Never use `'*'` as the target origin in `postMessage` when transmitting sensitive data. Specifying the exact origin ensures malicious pages cannot intercept the message if they manage to inject an iframe into the same page.

The `document.domain` Legacy

Historically, two pages on different subdomains could share a JavaScript context by both setting `document.domain` to the shared parent domain. This worked because they ended up in the same renderer process. Site isolation breaks this pattern in strict mode:

```javascript
// On https://app.example.com
document.domain = 'example.com'; // Deprecated behavior

// On https://api.example.com
document.domain = 'example.com'; // No longer grants shared access

// Modern alternative: use postMessage or a shared API layer
```

Chrome deprecated `document.domain` mutability in Chrome 115. Applications that relied on this pattern need to migrate to `postMessage` or a proper API backend.

## Storage Isolation

Site isolation affects how browser storage is scoped. The rules are consistent but worth knowing explicitly:

| Storage Type | Scoped By | Notes |
|---|---|---|
| Cookies | Domain + path (set by server) | Subdomains can share via `Domain=.example.com` |
| localStorage | Exact origin (scheme + host + port) | `api.example.com` != `www.example.com` |
| sessionStorage | Exact origin + tab | Not shared across tabs at all |
| IndexedDB | Exact origin | Strict per-origin isolation |
| Cache API | Exact origin | Service worker caches are origin-scoped |
| SharedArrayBuffer | Requires COOP + COEP | Only available in cross-origin isolated contexts |

The `localStorage` behavior surprises many developers. `localStorage` set on `https://api.example.com` is completely invisible to code running on `https://www.example.com`, even though they share the same registered domain. If your application uses `localStorage` for shared state between subdomains, you need to either consolidate to a single subdomain or use cookies with a `Domain=.example.com` flag.

## Performance Implications

Site isolation increases memory usage because each site requires a separate OS process with its own heap. A fresh renderer process typically costs 30–80MB of memory before loading any content. This is manageable for users with a few tabs open but becomes noticeable with many tabs across many distinct sites.

Chrome manages this overhead through several strategies:

- Process reuse: If you already have a tab open for `example.com` and navigate another tab to `example.com`, they share a renderer process
- Spare process pool: Chrome pre-warms a small number of spare renderer processes to reduce navigation latency
- Back/forward cache (bfcache): Rather than destroying and recreating processes on navigation, Chrome can keep renderer state cached for fast back/forward navigation

For developers, the practical impact is that applications with many cross-origin iframes (ads, widgets, analytics, embeds) will consume more memory per page load than they did before site isolation was enforced.

## Advanced: Controlling Isolation with COOP and COEP

Developers can opt their pages into stricter isolation using HTTP response headers. This unlocks powerful browser APIs that are disabled by default due to Spectre risk.

Cross-Origin-Opener-Policy (COOP)

```http
Cross-Origin-Opener-Policy: same-origin
```

COOP controls whether your document can share a browsing context group (and therefore a process) with cross-origin popups or pages that opened yours. The `same-origin` value gives your page a dedicated browsing context group, isolating it from any cross-origin opener or opened window.

Available values:

| Value | Behavior |
|---|---|
| `unsafe-none` | Default. No isolation. |
| `same-origin-allow-popups` | Isolates from cross-origin openers, but can open cross-origin popups |
| `same-origin` | Full isolation. No cross-origin opener/opened window sharing |

Cross-Origin-Embedder-Policy (COEP)

```http
Cross-Origin-Embedder-Policy: require-corp
```

COEP controls which cross-origin resources your page may load. With `require-corp`, every cross-origin resource must either be served with a `Cross-Origin-Resource-Policy` header or have an appropriate CORS header. This prevents your page from loading third-party content that hasn't explicitly opted into cross-origin embedding.

Available values:

| Value | Behavior |
|---|---|
| `unsafe-none` | Default. No restrictions. |
| `require-corp` | All cross-origin subresources must opt in via CORP or CORS |
| `credentialless` | Cross-origin resources load without credentials; no CORP opt-in needed |

## Combining COOP and COEP for Cross-Origin Isolation

When you set both headers to their strictest values, your page achieves "cross-origin isolated" status:

```http
Cross-Origin-Opener-Policy: same-origin
Cross-Origin-Embedder-Policy: require-corp
```

Cross-origin isolated pages gain access to APIs that remain disabled for normal pages:

```javascript
// Check if cross-origin isolated
if (crossOriginIsolated) {
 // SharedArrayBuffer is available
 const sharedBuffer = new SharedArrayBuffer(1024);
 const view = new Int32Array(sharedBuffer);

 // High-resolution performance timing is available
 const preciseTime = performance.now(); // Microsecond resolution

 // Atomics.wait works on the main thread
 // (useful for WASM threading)
} else {
 console.warn('Not cross-origin isolated. SharedArrayBuffer unavailable');
}
```

These APIs are valuable for WebAssembly applications, audio worklets, and other performance-sensitive use cases that require shared memory between workers.

Cross-Origin Resource Policy (CORP)

If your server serves resources that should be embeddable by specific cross-origin pages, add the `Cross-Origin-Resource-Policy` header to those responses:

```http
Allow the resource to be loaded by same-site pages
Cross-Origin-Resource-Policy: same-site

Allow any cross-origin page to embed this resource
Cross-Origin-Resource-Policy: cross-origin

Only allow same-origin pages (default behavior for many resource types)
Cross-Origin-Resource-Policy: same-origin
```

A common pattern: your API server sets `Cross-Origin-Resource-Policy: same-site` on all responses so that pages on subdomains can include the resource while COEP-enabled pages work correctly.

## Debugging Site Isolation Issues

Site isolation introduces behaviors that can look like bugs if you're unfamiliar with the underlying mechanics.

Symptom: `localStorage` changes on one subdomain don't appear on another.
Cause: `localStorage` is origin-scoped, not site-scoped. Use cookies with `Domain=.yourdomain.com` for shared state.

Symptom: Cross-origin iframe communication breaks or becomes unreliable.
Cause: Direct property access (`iframe.contentWindow.someVariable`) is blocked across origins. Use `postMessage`.

Symptom: `SharedArrayBuffer` throws a security error.
Cause: The page is not cross-origin isolated. Add COOP and COEP headers.

Symptom: A third-party script that worked before now fails to load when COEP is enabled.
Cause: The third-party resource doesn't include `Cross-Origin-Resource-Policy: cross-origin` or appropriate CORS headers. Contact the vendor or use `credentialless` COEP as a workaround.

Symptom: `document.domain` mutation is ignored or throws.
Cause: Chrome deprecated `document.domain` mutability. Migrate to `postMessage`.

## Summary

Chrome site isolation represents a fundamental shift in browser security architecture. By treating each registered domain as a separate renderer process, Chrome provides meaningful protection against cross-site attacks, speculative execution vulnerabilities, and compromised renderer escalation. For developers, understanding this architecture informs better security decisions, explains storage scoping behavior that can otherwise seem inconsistent, and guides the implementation of proper cross-origin communication patterns.

The default isolation level suits most applications. Developers building performance-sensitive applications that need `SharedArrayBuffer` or high-resolution timers should implement COOP and COEP headers. Developers debugging subdomain state-sharing issues should audit their use of `localStorage` and `document.domain`. Browser vendors continue to refine these protections as new vulnerabilities emerge, making Chrome's process architecture meaningfully more secure with each release.

---

---

<div class="mastery-cta">

I'm a solo developer in Vietnam. 50K Chrome extension users. $500K+ on Upwork. 5 Claude Max subscriptions running agent fleets in parallel.

These are my actual CLAUDE.md templates, orchestration configs, and prompts. Not a course. Not theory. The files I copy into every project before I write a line of code.

**[See what's inside →](https://zovo.one/lifetime?utm_source=ccg&utm_medium=cta-default&utm_campaign=chrome-site-isolation-explained)**

$99 once. Free forever. 47/500 founding spots left.

</div>

Related Reading

- [Chrome Extension Site Audit Tool: A Developer's Guide](/chrome-extension-site-audit-tool/)
- [AI Citation Generator Chrome: A Developer Guide](/ai-citation-generator-chrome/)
- [AI Color Picker Chrome Extension: A Developer's Guide](/ai-color-picker-chrome-extension/)

Built by theluckystrike. More at [zovo.one](https://zovo.one)


