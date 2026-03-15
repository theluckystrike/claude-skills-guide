---

layout: default
title: "Wave Chrome Extension Accessibility: A Complete Guide for Developers"
description: "Learn how to build accessible Chrome extensions using Wave accessibility testing principles. Practical code examples and best practices for developers."
date: 2026-03-15
author: "theluckystrike"
permalink: /wave-chrome-extension-accessibility/
reviewed: true
score: 8
categories: [guides]
tags: [claude-code, claude-skills]
---


Wave is a popular web accessibility evaluation tool, and many developers want to integrate accessibility testing directly into their Chrome extensions. Whether you're building an extension inspired by Wave's functionality or adding accessibility features to an existing extension, understanding the core accessibility concepts is essential.

This guide covers practical techniques for creating accessible Chrome extensions that test and improve web accessibility.

## Understanding Wave and Accessibility Testing

Wave (Web Accessibility Evaluation Tool) was developed by WebAIM and provides comprehensive accessibility auditing directly in the browser. It checks for:

- Alternative text for images
- Proper heading structure
- Color contrast ratios
- ARIA attribute usage
- Form label associations
- Keyboard navigation issues

When building a Chrome extension that performs accessibility testing, you'll want to replicate and extend these capabilities.

## Setting Up Your Extension's Manifest

Every Chrome extension starts with a manifest file. For accessibility-focused extensions, here's a practical setup:

```json
{
  "manifest_version": 3,
  "name": "Accessibility Tester",
  "version": "1.0",
  "description": "Automated accessibility testing for any webpage",
  "permissions": ["activeTab", "scripting"],
  "host_permissions": ["<all_urls>"],
  "action": {
    "default_popup": "popup.html",
    "default_icon": "icon.png"
  },
  "content_scripts": [{
    "matches": ["<all_urls>"],
    "js": ["content.js"]
  }]
}
```

## Analyzing Page Accessibility

Your content script will inject into web pages to analyze accessibility issues. Here's a practical implementation:

```javascript
// content.js - Analyze page accessibility
function analyzeAccessibility() {
  const issues = [];
  
  // Check for images missing alt text
  const images = document.querySelectorAll('img');
  images.forEach((img, index) => {
    if (!img.hasAttribute('alt') && img.src) {
      issues.push({
        type: 'missing-alt',
        element: 'img',
        selector: getSelector(img),
        message: 'Image missing alternative text'
      });
    }
  });
  
  // Check heading structure
  const headings = document.querySelectorAll('h1, h2, h3, h4, h5, h6');
  let lastLevel = 0;
  headings.forEach(heading => {
    const currentLevel = parseInt(heading.tagName.charAt(1));
    if (currentLevel > lastLevel + 1 && lastLevel !== 0) {
      issues.push({
        type: 'heading-skip',
        element: heading.tagName,
        message: `Heading level skipped: ${lastLevel} to ${currentLevel}`
      });
    }
    lastLevel = currentLevel;
  });
  
  // Check form labels
  const inputs = document.querySelectorAll('input:not([type="hidden"]):not([type="submit"])');
  inputs.forEach(input => {
    const id = input.getAttribute('id');
    const labelled = document.querySelector(`label[for="${id}"]`);
    const parentLabel = input.closest('label');
    if (!labelled && !parentLabel) {
      issues.push({
        type: 'missing-label',
        element: 'input',
        selector: getSelector(input),
        message: 'Form input missing associated label'
      });
    }
  });
  
  return issues;
}

function getSelector(el) {
  if (el.id) return `#${el.id}`;
  let selector = el.tagName.toLowerCase();
  if (el.className) {
    selector += '.' + el.className.split(' ')[0];
  }
  return selector;
}
```

## Implementing Color Contrast Checking

Wave checks color contrast ratios, which is crucial for users with visual impairments. WCAG 2.1 requires:

- 4.5:1 for normal text
- 3:1 for large text

Here's how to implement contrast checking in your extension:

```javascript
function getContrastRatio(foreground, background) {
  const lum1 = getLuminance(foreground);
  const lum2 = getLuminance(background);
  const brightest = Math.max(lum1, lum2);
  const darkest = Math.min(lum1, lum2);
  return (brightest + 0.05) / (darkest + 0.05);
}

function getLuminance(hex) {
  const rgb = hexToRgb(hex);
  const [r, g, b] = rgb.map(c => {
    c = c / 255;
    return c <= 0.03928 ? c / 12.92 : Math.pow((c + 0.055) / 1.055, 2.4);
  });
  return 0.2126 * r + 0.7152 * g + 0.0722 * b;
}

function hexToRgb(hex) {
  const result = /^#?([a-f\d]{2})([a-f\d]{2})([a-f\d]{2})$/i.exec(hex);
  return result ? [
    parseInt(result[1], 16),
    parseInt(result[2], 16),
    parseInt(result[3], 16)
  ] : [0, 0, 0];
}
```

## Keyboard Navigation Testing

Accessibility extends beyond visual checks. Your extension should verify keyboard navigability:

```javascript
function checkKeyboardAccessibility() {
  const issues = [];
  
  // Check for positive tabindex
  const positiveTabindex = document.querySelectorAll('[tabindex="1"], [tabindex="2"], [tabindex="3"]');
  positiveTabindex.forEach(el => {
    issues.push({
      type: 'positive-tabindex',
      message: 'Avoid positive tabindex values; use 0 or -1'
    });
  });
  
  // Check for focusable elements without visible focus
  const focusableSelectors = 'a[href], button, input, select, textarea, [tabindex]';
  const focusableElements = document.querySelectorAll(focusableSelectors);
  
  focusableElements.forEach(el => {
    const style = window.getComputedStyle(el);
    if (style.outline === 'none' || style.outlineColor === 'transparent') {
      issues.push({
        type: 'missing-focus-style',
        message: 'Focusable element lacks visible focus indicator'
      });
    }
  });
  
  return issues;
}
```

## ARIA Validation

Wave checks for proper ARIA attribute usage. Here's a validation helper:

```javascript
function validateARIA() {
  const issues = [];
  
  // Check for invalid ARIA roles
  const invalidRoles = document.querySelectorAll('[role=""], [role="null"]');
  invalidRoles.forEach(el => {
    issues.push({
      type: 'invalid-aria-role',
      message: 'Element has empty or invalid ARIA role'
    });
  });
  
  // Check for required ARIA properties
  const ariaRequired = document.querySelectorAll('[aria-required="true"]');
  ariaRequired.forEach(el => {
    if (!el.hasAttribute('required') && el.tagName !== 'INPUT' && el.tagName !== 'SELECT') {
      issues.push({
        type: 'aria-required-check',
        message: 'Element has aria-required but missing native required'
      });
    }
  });
  
  return issues;
}
```

## Displaying Results in Your Extension

Create a popup to display accessibility findings:

```html
<!-- popup.html -->
<!DOCTYPE html>
<html>
<head>
  <style>
    body { width: 350px; padding: 16px; font-family: system-ui, sans-serif; }
    .issue { padding: 8px; margin: 4px 0; border-radius: 4px; background: #fee; }
    .issue-type { font-weight: bold; color: #c00; }
    .issue-message { font-size: 13px; color: #333; }
    .summary { padding: 12px; background: #eef; border-radius: 4px; margin-bottom: 12px; }
  </style>
</head>
<body>
  <h2>Accessibility Report</h2>
  <div id="summary" class="summary"></div>
  <div id="issues"></div>
  <script src="popup.js"></script>
</body>
</html>
```

```javascript
// popup.js
document.addEventListener('DOMContentLoaded', () => {
  chrome.tabs.query({ active: true, currentWindow: true }, (tabs) => {
    chrome.tabs.sendMessage(tabs[0].id, { action: 'analyze' }, (response) => {
      if (response && response.issues) {
        displayResults(response.issues);
      }
    });
  });
});

function displayResults(issues) {
  const summary = document.getElementById('summary');
  const container = document.getElementById('issues');
  
  summary.textContent = `Found ${issues.length} accessibility issue${issues.length !== 1 ? 's' : ''}`;
  
  issues.forEach(issue => {
    const div = document.createElement('div');
    div.className = 'issue';
    div.innerHTML = `
      <div class="issue-type">${issue.type}</div>
      <div class="issue-message">${issue.message}</div>
    `;
    container.appendChild(div);
  });
}
```

## Testing Your Extension

After implementing your accessibility checker, test it thoroughly:

1. Install your extension in developer mode
2. Visit various websites with known accessibility issues
3. Verify that your extension correctly identifies problems
4. Test the popup displays results correctly
5. Check that the extension doesn't break page functionality

## Best Practices

When building accessibility-focused Chrome extensions:

- **Scan dynamically**: Use MutationObserver to catch dynamically added content
- **Provide actionable feedback**: Each issue should include clear remediation steps
- **Support export**: Allow users to export reports for stakeholders
- **Stay updated**: Follow WCAG guidelines as they evolve
- **Test with screen readers**: Verify your extension works with NVDA, JAWS, and VoiceOver

Building accessibility testing into Chrome extensions empowers developers to catch issues before deployment. By following these patterns, you can create powerful tools that help make the web more accessible for everyone.

---

## Related Reading

- [Claude Code for Beginners: Complete Getting Started Guide](/claude-skills-guide/claude-code-for-beginners-complete-getting-started-2026/)
- [Best Claude Skills for Developers in 2026](/claude-skills-guide/best-claude-skills-for-developers-2026/)
- [Claude Skills Guides Hub](/claude-skills-guide/guides-hub/)

Built by theluckystrike — More at [zovo.one](https://zovo.one)
