---
layout: default
title: "Chrome Topics API Privacy — Honest Review 2026"
description: "Learn how the Chrome Topics API enables interest-based advertising while preserving user privacy. Includes implementation examples and privacy best."
date: 2026-03-15
last_modified_at: 2026-04-17
categories: [guides]
tags: [chrome, privacy, topics-api, web-development, advertising, cookies]
author: theluckystrike
reviewed: true
score: 8
permalink: /chrome-topics-api-privacy/
geo_optimized: true
robots: "noindex, nofollow"
sitemap: false
---
# Chrome Topics API: Privacy-First Advertising Without Third-Party Cookies

The Chrome Topics API represents Google's answer to a growing problem in web advertising: how do you deliver personalized content without relying on invasive third-party cookies? This API enables interest-based advertising while keeping user privacy at the forefront. For developers building advertising platforms or publishers monetizing content, understanding the Topics API is essential for the post-cookie web.

What Is the Chrome Topics API?

The Topics API is a Privacy Sandbox proposal that allows browsers to surface broad interest categories without tracking users across websites. Instead of following users across the web with unique identifiers, the browser itself learns about user interests based on browsing activity and shares those interests with participating sites.

When a user visits websites, Chrome periodically calculates topic assignments based on the domains visited. These topics are stored locally on the user's device and can be accessed by third-party scripts through a JavaScript API. The key difference from cookies: topics are derived from domain names, not personal data, and users maintain control over which topics are shared.

The Topics API sits within Google's broader Privacy Sandbox initiative, which aims to deprecate third-party cookies and replace them with purpose-built APIs that limit data exposure while still supporting advertising use cases. Unlike previous proposals like FLoC (Federated Learning of Cohorts), which grouped users into cohorts that could theoretically be used for fingerprinting, Topics assigns individuals to coarse interest categories from a fixed, public taxonomy. This design choice makes it significantly harder to build persistent cross-site identifiers.

## How the Topics API Works

The API operates on a simple three-step model that balances personalization with privacy:

1. Topic Calculation: Chrome observes the domains a user visits over a rolling week. It then assigns the user to topic categories based on these domains. Topics are derived from a public taxonomy covering interests like "Technology," "Fitness," "Travel," and hundreds of other categories.

2. Topic Retrieval: When a site requests topics, Chrome returns the top five topics from the past three weeks. Each topic includes a confidence score indicating how strongly the user relates to that interest. Topics are only shared with sites running third-party scripts that request them.

3. Topic Filtering: Users can view and remove topics in Chrome settings. The browser never shares topics from sensitive categories like health, politics, or ethnicity. Users can also disable the API entirely.

## The Taxonomy in Depth

The Topics API taxonomy currently covers around 350 categories organized into a hierarchical structure. Top-level categories include Arts and Entertainment, Autos and Vehicles, Beauty and Fitness, Books and Literature, Business and Industrial, and many more. Within each top-level category sit subcategories: under Technology you might find categories like Mobile Phones, Software, or Computer Security.

Domain-to-topic classification is performed by a machine learning model that Chrome ships with. The model maps domain names to topics using a combination of training data and the site's content signals. Publishers can also declare their own topics using a header, giving them more control over how they're classified:

```
Sec-Browsing-Topics: (103)
```

The number `103` corresponds to a topic ID from the public taxonomy. Publishers who know their content aligns with a specific interest can declare it directly, improving classification accuracy for their domain.

## Implementing the Topics API

To access topic data, add the Permissions-Policy header and use the JavaScript API:

```javascript
// Check if the Topics API is available
async function getTopics() {
 if (!('browsingTopics' in document)) {
 console.log('Topics API not supported');
 return [];
 }

 try {
 // Get topics for the current user
 const topics = await document.browsingTopics();
 return topics.map(topic => ({
 topicName: topic.topic,
 taxonomyVersion: topic.taxonomyVersion,
 modelVersion: topic.modelVersion
 }));
 } catch (error) {
 console.error('Error getting topics:', error);
 return [];
 }
}

// Example: Log user's current topics
getTopics().then(topics => {
 topics.forEach(topic => {
 console.log(`Interest: ${topic.topicName}`);
 });
});
```

On the server side, include the Topics API in your Permissions-Policy header:

```
Permissions-Policy: browsing-topics=(self)
```

## Fetch Header Integration

A second method for accessing topics uses the `browsingTopics: true` option in the Fetch API. When you make a fetch request with this option, Chrome attaches the user's topics as a `Sec-Browsing-Topics` request header, which your server can read directly:

```javascript
async function fetchAdWithTopics(adServerUrl) {
 const response = await fetch(adServerUrl, {
 browsingTopics: true
 });
 return response.json();
}
```

On the server side, you'd read the header:

```javascript
// Node.js/Express example
app.get('/ad', (req, res) => {
 const topicsHeader = req.headers['sec-browsing-topics'];
 // topicsHeader is: "103;v=chrome.1:1:1, 258;v=chrome.1:1:1"
 // Parse topic IDs and serve relevant ad creative
 const topicIds = parseTopicsHeader(topicsHeader);
 const selectedAd = selectAdForTopics(topicIds);
 res.json(selectedAd);
});
```

This server-side approach is useful for ad servers that want to keep topic interpretation logic off the client.

iframe and Cross-Origin Considerations

When implementing Topics in a third-party ad iframe, the parent page must explicitly delegate permission:

```html
<!-- Parent page must include this attribute -->
<iframe src="https://adserver.example/ad"
 allow="browsing-topics">
</iframe>
```

Without the `allow` attribute, the iframe context will not have access to topics even if the Permissions-Policy header is set. This is a common source of confusion when migrating from cookie-based ad integrations.

## Privacy Protections Built Into the API

The Topics API includes several mechanisms that make privacy a core feature rather than an afterthought:

On-Device Processing: All topic calculations happen locally on the user's device. No data is sent to Google's servers for topic assignment. The browser simply surfaces topics it has already calculated.

No Cross-Site Tracking: Topics are derived from domain names, not from user accounts or persistent identifiers. A user cannot be tracked across sites because each site only receives the current topic selections, not a persistent ID.

Sensitive Category Exclusion: Chrome automatically excludes topics related to sensitive categories. Users cannot be categorized based on health conditions, religious beliefs, political affiliations, sexual orientation, or other protected characteristics.

User Control: Chrome provides settings to view assigned topics, remove individual topics, or disable the API entirely. Users can access these controls through `chrome://settings/topics`.

Frequency Limits: Topics are recalculated weekly and only the top five are shared. This prevents detailed profiling and ensures users are represented by broad interest categories rather than specific behaviors.

Noise Injection: The API intentionally introduces a small amount of randomness by occasionally returning a random topic instead of a real one. This provides plausible deniability for users and makes it harder for sites to build profiles through repeated queries. Approximately 5% of topic responses are random.

## Comparing Topics API to Third-Party Cookies

| Feature | Third-Party Cookies | Topics API |
|---|---|---|
| Data storage | Server-side, per advertiser | On-device, browser-managed |
| User identifier | Persistent cross-site ID | No persistent ID |
| Granularity | Exact page URLs, behaviors | Broad interest categories |
| Sensitive data | Can include anything | Automatically excluded |
| User control | Difficult to audit/remove | Visible in browser settings |
| Cross-browser | Works everywhere | Chrome/Chromium only |
| Expiry | Set by advertiser | 3-week rolling window |

The comparison makes clear that Topics represents a meaningful privacy improvement, though it comes with the trade-off of reduced targeting precision and limited browser support.

## Practical Use Cases for Developers

The Topics API opens several possibilities for web developers and advertisers:

Content Personalization: Publishers can use topic data to recommend articles, videos, or products that align with demonstrated interests. A news site might prioritize technology coverage for users interested in tech topics.

Ad Selection: Advertisers can use topics to choose relevant creative without requiring personal data. A fitness brand can prioritize showing ads to users categorized as having fitness interests.

Audience Insights: Marketing teams can use aggregated topic data to understand which interest categories their audience falls into, informing content strategy and campaign targeting.

Here's how you might use topics for ad selection:

```javascript
async function selectRelevantAd(ads) {
 const topics = await document.browsingTopics();

 if (topics.length === 0) {
 // Fall back to contextual or default ads
 return ads.default;
 }

 const userTopic = topics[0].topicName;

 // Filter ads matching user's top topic
 const matchingAds = ads.filter(ad =>
 ad.topics.includes(userTopic)
 );

 return matchingAds.length > 0
 ? matchingAds[0]
 : ads.default;
}
```

## Real-World Scenario: Publisher Ad Stack Migration

Consider a news publisher that currently relies on a third-party data management platform (DMP) passing segment IDs via cookies. To migrate toward Topics:

1. Audit current cookie usage: Identify which third-party scripts currently read user cookies for interest targeting.

2. Implement Topics on the ad call: Update the ad request to pass topics instead of (or alongside) cookie-based segments during a transition period.

3. Map taxonomy: Build a mapping between your DMP's proprietary segment taxonomy and the Topics API taxonomy. Many segments will map cleanly to Topics categories.

4. A/B test performance: Run campaigns targeting cookie-based segments against campaigns using Topics to measure CPM and click-through rate parity.

5. Remove cookie dependency: Once Topics-based targeting meets performance thresholds, phase out the cookie-dependent paths.

A practical migration script that handles both signal sources during the transition:

```javascript
async function buildAudienceSignal() {
 const signal = { source: null, topics: [], legacySegments: [] };

 // Try Topics API first
 if ('browsingTopics' in document) {
 try {
 const topics = await document.browsingTopics();
 if (topics.length > 0) {
 signal.source = 'topics-api';
 signal.topics = topics.map(t => t.topic);
 return signal;
 }
 } catch (e) {
 // Fall through to legacy
 }
 }

 // Fallback: read from first-party data
 const firstPartySegments = getFirstPartySegments();
 if (firstPartySegments.length > 0) {
 signal.source = 'first-party';
 signal.legacySegments = firstPartySegments;
 return signal;
 }

 // Final fallback: contextual only
 signal.source = 'contextual';
 return signal;
}
```

This pattern lets you ship the migration incrementally rather than as a hard cutover.

## Browser Support and Considerations

The Topics API is available in Chrome and Chromium-based browsers starting around version 110. Other browsers have not adopted the API, so implement feature detection and provide fallback experiences:

```javascript
function isTopicsAPIAvailable() {
 return 'browsingTopics' in document &&
 document.featurePolicy?.allowedFeatures().includes('browsing-topics');
}

// Use fallback for unsupported browsers
if (!isTopicsAPIAvailable()) {
 loadContextualAds();
}
```

Remember that the Privacy Sandbox is an evolving specification. The API surface, topic taxonomy, and behavior may change as the feature matures. Test thoroughly and monitor Google's developer documentation for updates.

## Testing in Development

Manually testing the Topics API in development is non-trivial because it requires actual browsing history to generate meaningful topics. Chrome provides an override mechanism for testing:

1. Open Chrome DevTools and navigate to the Application panel.
2. Under Privacy Sandbox, find Topics.
3. You can manually add topics to simulate a user with specific interests.

Alternatively, use the command-line flag approach for automated testing:

```bash
Launch Chrome with Topics API enabled and test topics injected
google-chrome \
 --enable-features=BrowsingTopics \
 --browsing-topics-bypass-ip-is-publicly-routable-check \
 --privacy-sandbox-enrollment-overrides=https://your-test-domain.com
```

For CI environments, you can use the `chrome://flags/#privacy-sandbox-enrollment-overrides` flag to whitelist test domains without going through the enrollment process.

## The Enrollment Requirement

As of late 2023, accessing the Topics API (along with other Privacy Sandbox APIs) requires enrolling your origin with Google's Privacy Sandbox enrollment service. This is a one-time process that verifies your use case and grants access:

- Visit the [Privacy Sandbox enrollment portal](https://privacysandbox.google.com/intl/en_us/open-web/enroll)
- Submit your origin and intended use case
- Once approved, your origin can call `document.browsingTopics()` in production

Development and testing environments can bypass this requirement using the override flags mentioned above.

## Topics API vs. Other Privacy Sandbox APIs

The Topics API is not the only tool in the Privacy Sandbox. Understanding where it fits relative to other APIs helps you choose the right one for your use case:

| API | Purpose | Best For |
|---|---|---|
| Topics API | Interest-based targeting | Broad audience advertising |
| Protected Audience (FLEDGE) | Remarketing | Re-engaging past visitors |
| Attribution Reporting | Conversion measurement | Campaign ROI measurement |
| Shared Storage | Cross-site data access | Frequency capping |
| Private Aggregation | Aggregate reporting | Reach and frequency stats |

A mature advertising stack in the post-cookie web will likely use all of these APIs in combination. Topics handles the prospecting use case. reaching new users with relevant interests. while Protected Audience handles remarketing to users who have already visited your site or landing page.

## The Future of Privacy-First Advertising

The Topics API represents a shift toward advertising models that respect user privacy while still enabling relevant content delivery. For developers, this means learning new APIs and thinking differently about how personalization works. The days of opaque tracking scripts and persistent third-party cookies are fading, replaced by browser-level controls that give users the final say.

Several trends will shape how Topics evolves:

Taxonomy expansion: The current ~350-category taxonomy will likely grow as Google gathers publisher feedback on coverage gaps. Niche content verticals that don't map cleanly to existing categories have been a consistent problem.

Publisher-declared topics: The ability for publishers to declare their own topic classifications via HTTP headers is underused today but will become more important as more inventory migrates to Topics-based targeting.

Programmatic integration: Major SSPs and DSPs are building Topics support into their bid request specifications. As adoption grows, the signal will appear natively in OpenRTB bid requests, reducing the implementation burden on individual publishers.

Regulatory landscape: European regulators have raised questions about whether Topics constitutes personal data processing under GDPR. The outcome of these deliberations will determine whether the API can be used without explicit consent in EU markets.

Building with the Topics API today positions your projects for a web where privacy is a feature, not a compromise. The API provides enough signal for effective advertising while keeping user data where it belongs: on the user's device, under the user's control.

---

---

<div class="mastery-cta">

I'm a solo developer in Vietnam. 50K Chrome extension users. $500K+ on Upwork. 5 Claude Max subscriptions running agent fleets in parallel.

These are my actual CLAUDE.md templates, orchestration configs, and prompts. Not a course. Not theory. The files I copy into every project before I write a line of code.

**[See what's inside →](https://zovo.one/lifetime?utm_source=ccg&utm_medium=cta-default&utm_campaign=chrome-topics-api-privacy)**

$99 once. Free forever. 47/500 founding spots left.

</div>

Related Reading

- [Chrome Fingerprint Test Extension: A Developer's Guide.](/chrome-fingerprint-test-extension/)
- [DuckDuckGo vs Chrome Privacy: A Developer & Power User Guide](/duckduckgo-vs-chrome-privacy/)
- [Chrome Extensions That Track You: What Developers Need.](/chrome-extensions-that-track-you/)

Built by theluckystrike. More at [zovo.one](https://zovo.one)


