---
layout: default
title: "Octotree GitHub Chrome Extension Guide (2026)"
description: "Master Octotree for GitHub: the Chrome extension that adds a file tree sidebar to repositories. Learn setup, features, customization, and practical."
date: 2026-03-15
last_modified_at: 2026-04-17
author: "Claude Skills Guide"
permalink: /octotree-chrome-extension-github/
reviewed: true
score: 8
categories: [guides]
tags: [chrome, claude-skills]
geo_optimized: true
---
## Octotree Chrome Extension GitHub. A Developer's Navigation Guide

If you spend significant time browsing GitHub repositories, you've likely experienced the frustration of clicking through multiple directory levels just to find a single file. Octotree solves this problem by adding a collapsible file tree sidebar to every GitHub repository you visit, transforming how you navigate codebases in the browser.

## What Octotree Does

Octotree is a Chrome extension that displays a VS Code-style file tree navigation panel on the left side of any GitHub repository page. Instead of repeatedly clicking ".." to navigate up and down directory hierarchies, you get a persistent hierarchical view of the entire repository structure.

The extension works entirely client-side, requiring no authentication or configuration to display public repositories. For private repositories, you can optionally authenticate with GitHub to access those as well.

## Installation and Initial Setup

Install Octotree from the Chrome Web Store or visit the GitHub repository at buunguyen/octotree. After installation, you'll immediately see a sidebar appear on any GitHub repository page.

The sidebar defaults to a collapsed state. Click the Octotree icon (or press the keyboard shortcut) to expand it. The first time you load a repository, Octotree fetches the file structure in the background, subsequent visits to the same repository load instantly from cache.

## Essential Keyboard Shortcuts

Octotree provides several keyboard shortcuts for power users:

| Shortcut | Action |
|----------|--------|
| `Cmd/Ctrl + \` | Toggle sidebar visibility |
| `Enter` | Open selected file |
| `Backspace` | Go to parent directory |
| `j` / `k` | Move selection down/up |
| `h` / `l` | Collapse/expand directory |

## Practical Usage Patterns

## Navigating Large Codebases

Consider a typical open-source project like a React application with this structure:

```
src/
 components/
 Header.jsx
 Footer.jsx
 Sidebar/
 index.jsx
 SidebarItem.jsx
 hooks/
 useAuth.js
 useTheme.js
 utils/
 api.js
 helpers.js
 App.jsx
```

Without Octotree, reaching `SidebarItem.jsx` requires four clicks: into `components`, into `Sidebar`, find the file. With Octotree visible, you see the entire tree and click directly to your target, typically one or two clicks regardless of nesting depth.

## Code Review Workflow

When reviewing pull requests, Octotree becomes particularly valuable. You can:

1. Open the PR and toggle Octotree with `Ctrl + \`
2. Navigate to files changed in the PR using the tree view
3. Jump between files without losing context of the overall structure

The extension highlights files that were modified in the current PR, making it easy to identify changed files within larger repositories.

## Finding Configuration Files

Every developer knows the pain of locating `.gitignore`, `package.json`, or `tsconfig.json` in unfamiliar repositories. With Octotree's search feature (`Cmd/Ctrl + f` when focused on the sidebar), you can instantly filter and locate these files.

## Configuration Options

Access Octotree settings by right-clicking the extension icon and selecting "Options" or visiting `chrome://extensions` and clicking the extension's "Options" link.

## Key Settings

Theme Selection: Choose between light, dark, or system-default themes. The dark theme matches GitHub's dark mode for consistent aesthetics.

Sidebar Width: Adjust the default width of the navigation panel. Default is 250px, but you can increase to 400px for large monorepos with long file paths.

File Popout Mode: When enabled, clicking a file opens it in a new tab rather than navigating within the current view. This preserves your place in the repository.

Remember State: Enable this to persist sidebar collapsed/expanded state across page navigation within the same repository.

Personal Access Token (Optional)

For accessing private repositories, you'll need to configure a GitHub Personal Access Token:

1. Generate a token at GitHub Settings > Developer Settings > Personal Access Tokens
2. Grant `repo` scope for full private repository access
3. Enter the token in Octotree settings

The token is stored locally in your Chrome profile, never transmitted anywhere except to GitHub's API for authentication.

## Performance Considerations

Octotree caches repository structures locally, so navigating between branches or commits in the same repo loads instantly. However, very large repositories (thousands of files) may experience initial load delays.

For monorepos exceeding 10,000 files, consider enabling "Show only relevant files" in settings if available, or loading specific subdirectories instead of the full tree.

## Comparison with Alternatives

GitHub's native file navigation has improved in recent years, but Octotree offers distinct advantages:

- Persistent visibility: Native GitHub requires clicking each folder; Octotree shows the entire tree
- Keyboard navigation: Full vim-style navigation support
- Search integration: Quick filtering across all files
- Quick file access: Hover files for instant preview without leaving context

For developers who prefer keyboard-driven workflows or regularly navigate large repositories, Octotree remains the superior choice despite GitHub's native improvements.

## Troubleshooting Common Issues

## Sidebar Not Appearing

Some GitHub pages exclude the sidebar by design, file diff views, pull request conversations, and issue pages don't benefit from directory trees. Navigate to the main "Code" tab of any repository.

## Stale Cache

If repository structure seems outdated, right-click the Octotree icon and select "Clear Cache" to force a fresh fetch on your next visit.

## Conflicting Extensions

Other extensions modifying GitHub's DOM can sometimes interfere with Octotree. Disable other GitHub-related extensions temporarily to diagnose conflicts.

## Octotree Pro Features for Enterprise Teams

Octotree Pro adds several features that benefit development teams working in private repositories at scale.

Multiple GitHub accounts: Enterprise developers often work across a personal GitHub account and one or more organizational accounts. Octotree Pro lets you store separate Personal Access Tokens for each GitHub instance (including GitHub Enterprise Server) and switches contexts automatically based on the domain.

File bookmarks: Pro users can bookmark specific files across repositories. For developers who frequently check the same config files, test utilities, or reference implementations across projects, bookmarks provide instant access without navigating the tree each time.

Pinned repositories: Pin your most-visited repositories to the top of Octotree's repository picker. This is useful for monorepos where you regularly switch between the main repository and several satellite repos, all in the same browser window.

Dark mode consistency: While the free version supports dark mode for the sidebar, the Pro version applies dark theming to inline code previews and the extended file detail panel, maintaining visual consistency across the entire Octotree UI.

For teams evaluating Pro, the multiple-account support alone pays back the subscription cost in time saved per week. Context-switching between accounts through GitHub's native interface involves signing out, signing in, and losing your place. Octotree Pro eliminates this entirely for common multi-account workflows.

## Conclusion

Octotree transforms GitHub from a flat file list into a navigable directory tree, saving developers countless clicks and maintaining spatial awareness of codebase structure. Whether you're exploring unfamiliar repositories, reviewing pull requests, or traversing your own large projects, the sidebar becomes an essential part of your GitHub workflow.

The extension requires no configuration to get started with public repositories, making it immediately useful. Optional authentication unlocks private repository support for enterprise users.

## Using Octotree with GitHub Enterprise Server

Public GitHub users get the full Octotree experience without any configuration. the extension works immediately on github.com. Enterprise teams on self-hosted infrastructure need two additional steps. Organizations running GitHub Enterprise Server (GHES) on-premises can use Octotree with their private instance by providing the domain and an authentication token. The configuration is straightforward but requires two steps that public repository users skip entirely.

First, configure Octotree to recognize your GHES domain. Open Octotree settings and add your instance URL in the "GitHub Enterprise URLs" field:

```
https://github.yourcompany.com
```

Octotree then activates its sidebar when you browse repositories on that domain, exactly as it does on github.com.

Second, generate a Personal Access Token on your GHES instance (Settings > Developer Settings > Personal Access Tokens) with `repo` scope. Enter this token in Octotree's "Access Token" field for your enterprise domain. Without the token, Octotree can only display public repositories. private repositories on GHES require authentication.

If your GHES instance uses a self-signed SSL certificate, you may need to configure Chrome to trust the certificate before Octotree can connect. Navigate to your GHES domain in Chrome and accept the certificate warning; Chrome remembers the exception and Octotree can subsequently authenticate.

For organizations managing Chrome through GPO, you can pre-install the trusted certificate via Group Policy, eliminating the manual trust-acceptance step for all managed machines.

---


**Try it:** Estimate your monthly spend with our [Cost Calculator](/calculator/).
---

<div class="mastery-cta">

I'm a solo developer in Vietnam. 50K Chrome extension users. $500K+ on Upwork. 5 Claude Max subscriptions running agent fleets in parallel.

These are my actual CLAUDE.md templates, orchestration configs, and prompts. Not a course. Not theory. The files I copy into every project before I write a line of code.

**[See what's inside →](https://zovo.one/lifetime?utm_source=ccg&utm_medium=cta-default&utm_campaign=octotree-chrome-extension-github)**

$99 once. Free forever. 47/500 founding spots left.

</div>

Related Reading

- [Claude Code for Beginners: Complete Getting Started Guide](/claude-code-for-beginners-complete-getting-started-2026/)
- [Best Claude Skills for Developers in 2026](/best-claude-skills-for-developers-2026/)
- [Claude Skills Guides Hub](/guides-hub/)

Built by theluckystrike. More at [zovo.one](https://zovo.one)


