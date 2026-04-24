---
layout: default
title: "Miro Chrome Extension"
description: "Set up the Miro Chrome extension for whiteboard collaboration. Features, integration techniques, and team workflow tips included. Tested on Chrome."
date: 2026-03-15
last_modified_at: 2026-04-17
author: theluckystrike
permalink: /chrome-extension-miro-whiteboard/
categories: [guides]
tags: [tools]
reviewed: true
score: 8
render_with_liquid: false
geo_optimized: true
sitemap: false
robots: "noindex, nofollow"
---

{% raw %}
The Miro whiteboard platform has become an essential tool for remote collaboration, design thinking, and visual project management. While the web-based version offers solid functionality, the Chrome extension brings additional capabilities that streamline your workflow directly from the browser. This guide explores how developers and power users can maximize their productivity with the Miro Chrome extension.

What is the Miro Chrome Extension?

The Miro Chrome extension is a browser-based companion app that allows you to access Miro boards without opening a separate tab or window. It provides quick access to your recent boards, enables embedded viewing capabilities, and integrates with Chrome's native features to enhance your collaborative experience.

Unlike the full web application, the extension focuses on rapid access and lightweight interactions. You can quickly jump into boards, search through your content, and even embed Miro frames directly into web pages you visit.

Extension vs. Web App vs. Desktop App: Which to Use?

Many teams run all three interfaces simultaneously without a clear sense of which is best for which task. The table below clarifies the tradeoffs:

| Interface | Launch Time | Offline Support | Full Feature Set | Best For |
|---|---|---|---|---|
| Chrome Extension | Under 2 seconds | No | No | Quick board lookup, context menu capture, embed insertion |
| Web App (browser tab) | 4–8 seconds | Partial (cached) | Yes | Full board editing, workshops, design sessions |
| Desktop App (Electron) | 6–12 seconds | Yes | Yes | Extended sessions, presentation mode, no tab switching |
| Mobile App | Varies | Partial | Limited | Review and light annotation on the go |

The Chrome extension wins on speed and friction reduction. Use it as the entry point for your workflow, then open the full web app when you need the complete toolset.

## Key Features for Developers and Power Users

## Quick Board Access

The extension maintains a list of your recently accessed boards, making it trivial to switch between active projects. This feature proves invaluable when you're working across multiple sprints or client projects simultaneously.

```javascript
// Using the Miro Web SDK to access board information
const board = await miro.board.get();
console.log(`Current board: ${board.name}`);
console.log(`Board ID: ${board.id}`);
```

The extension's board list respects your workspace and team structure. If you work across multiple Miro teams, common for contractors and consultants, you can switch the active workspace from the extension popup without navigating the full web app.

## Embed Integration

One of the most powerful features allows you to embed Miro boards or specific frames into documentation, wikis, or internal tools. This creates living documents that teams can interact with directly.

```html
<!-- Embed a Miro board frame -->
<iframe
 src="https://miro.com/app/live-embed/{board-id}/?moveToViewport=-1000,-500,2000,1000"
 width="800"
 height="600"
 allowfullscreen>
</iframe>
```

The `moveToViewport` parameter deserves special attention: the four values represent `x, y, width, height` of the viewport rectangle. Use Miro's board coordinates (visible in the URL bar when you navigate the board) to pinpoint the exact frame you want to show.

For responsive embeds that fill a container, wrap the iframe in a CSS aspect-ratio container:

```css
.miro-embed-wrapper {
 position: relative;
 width: 100%;
 aspect-ratio: 16 / 9;
}

.miro-embed-wrapper iframe {
 position: absolute;
 inset: 0;
 width: 100%;
 height: 100%;
 border: none;
 border-radius: 8px;
}
```

```html
<div class="miro-embed-wrapper">
 <iframe
 src="https://miro.com/app/live-embed/{board-id}/"
 allowfullscreen>
 </iframe>
</div>
```

## Chrome Context Menu Integration

Right-click functionality in Chrome allows you to quickly create new Miro items from selected content. You can transform text selections, images, or links into sticky notes, frames, or embed cards within your active board.

This feature is particularly useful when conducting research. Highlight a paragraph from a competitor's documentation, right-click, and add it directly to your analysis board as a sticky note, without losing your place in the source page.

## Miro Web SDK: Programmatic Board Control

For developers who want to build on top of Miro rather than just use it, the Web SDK exposes a comprehensive API for reading and writing board content. The extension acts as the authentication layer, so SDK calls made from a browser page can interact with whatever board is currently active.

```javascript
// Initialize the SDK and check available permissions
await miro.board.ui.on('icon:click', async () => {
 const appData = await miro.board.getAppData();
 console.log('App data:', appData);
});

// Read all items on the current board
const items = await miro.board.get();
console.log(`Board has ${items.length} items`);

// Filter to just sticky notes
const stickyNotes = await miro.board.get({ type: 'sticky_note' });
stickyNotes.forEach(note => {
 console.log(`[${note.style.fillColor}] ${note.content}`);
});
```

## Setting Up the Extension

Installing the Miro Chrome extension follows the standard Chrome Web Store process:

1. Navigate to the Miro extension page in the Chrome Web Store
2. Click "Add to Chrome"
3. Sign in to your Miro account when prompted
4. Grant necessary permissions for board access

After installation, you'll see the Miro icon in your Chrome toolbar. Clicking it opens a compact interface showing your recent boards, team workspaces, and quick actions.

## Pinning and Customizing the Extension

After installation, pin the extension to your toolbar for one-click access. In Chrome, click the puzzle-piece Extensions icon in the top-right corner and click the pin icon next to Miro. Pinned extensions are always visible, saving the step of opening the Extensions panel each time.

You can also customize the extension's behavior through Chrome's extension management page (`chrome://extensions`). Toggle site access between "On click" and "On all sites" depending on your trust level, "On click" is the more conservative default for enterprise environments.

## Post-Install Checklist

| Step | What to Do | Why It Matters |
|---|---|---|
| Pin to toolbar | Click puzzle piece, pin Miro | Saves 2 clicks every time you use it |
| Set default workspace | Click extension, select workspace | Ensures new boards land in the right team |
| Enable context menu | Verify in extension settings | Enables right-click capture feature |
| Allow notifications | Grant permission if prompted | Alerts for board comments and mentions |
| Test embed permissions | Try embedding on your wiki | Some company wikis block iframes by default |

## Practical Workflow Examples

## Sprint Planning Sessions

For development teams using Agile methodologies, the Miro Chrome extension accelerates sprint planning. Instead of navigating through multiple menus, you can:

- Open your sprint board directly from the extension icon
- Use keyboard shortcuts to add user stories as cards
- Create velocity trackers that update in real-time

```javascript
// Example: Creating a card via Miro Web SDK
async function createStoryCard(storyText, estimate) {
 const card = await miro.board.createCard({
 content: storyText,
 description: `Story Points: ${estimate}`,
 x: 0,
 y: 0
 });
 return card;
}
```

A more complete sprint card creator that assigns color by priority and positions cards in a column:

```javascript
const PRIORITY_COLORS = {
 critical: '#ff5252', // red
 high: '#ffab40', // orange
 medium: '#ffee58', // yellow
 low: '#69f0ae', // green
};

async function createBacklogItem({ title, points, priority, columnIndex }) {
 const CARD_HEIGHT = 120;
 const COLUMN_WIDTH = 220;
 const existingCards = await miro.board.get({ type: 'card' });
 const cardsInColumn = existingCards.filter(
 c => Math.abs(c.x - columnIndex * COLUMN_WIDTH) < 50
 );

 const card = await miro.board.createCard({
 content: title,
 description: `${points} pts · ${priority}`,
 x: columnIndex * COLUMN_WIDTH,
 y: cardsInColumn.length * CARD_HEIGHT,
 style: {
 fillColor: PRIORITY_COLORS[priority] || '#ffffff',
 },
 });

 return card;
}

// Usage
await createBacklogItem({
 title: 'Implement OAuth flow',
 points: 5,
 priority: 'high',
 columnIndex: 0, // "To Do" column
});
```

## Technical Architecture Reviews

When documenting system architectures, developers can use the extension to embed interactive diagrams directly into GitHub README files or internal wikis. Stakeholders can then view and comment on architecture decisions without leaving their current context.

For GitHub specifically, Miro does not render inside a markdown file, GitHub strips iframes. The practical workaround is to export a static screenshot from Miro and link it to the live board:

```markdown
<!-- README.md. static image linked to live Miro board -->
[![System Architecture](./docs/architecture-preview.png)](https://miro.com/app/board/{board-id}/)

> Click the diagram to open the interactive version in Miro.
```

For Confluence or Notion wikis that do support embeds, use the full iframe approach:

```html
<!-- Notion: use the /embed block command, then paste this URL -->
https://miro.com/app/live-embed/{board-id}/?moveToViewport=-2000,-1000,4000,2000

<!-- Confluence: use the HTML macro with the iframe code directly -->
<iframe
 src="https://miro.com/app/live-embed/{board-id}/"
 width="100%"
 height="600"
 allow="fullscreen; clipboard-read; clipboard-write"
 allowfullscreen>
</iframe>
```

## Bug Triage Workflows

Support teams can use the extension to visualize bug distributions. By creating sticky note mappings in Miro, teams can categorize issues by severity, component, or frequency, then export these views for sprint planning.

A practical triage board automation script that pulls from a GitHub Issues JSON export and creates a Miro board layout:

```javascript
// Assumes you have a JSON array of GitHub issues
async function populateBugTriageBoard(issues) {
 const SEVERITY_COLUMNS = {
 'critical': -600,
 'high': -200,
 'medium': 200,
 'low': 600,
 };

 for (const issue of issues) {
 const severity = issue.labels.find(l =>
 ['critical', 'high', 'medium', 'low'].includes(l.name)
 )?.name || 'low';

 const columnX = SEVERITY_COLUMNS[severity];
 const existingNotes = await miro.board.get({ type: 'sticky_note' });
 const notesInColumn = existingNotes.filter(
 n => Math.abs(n.x - columnX) < 100
 );

 await miro.board.createStickyNote({
 content: `#${issue.number}: ${issue.title}`,
 x: columnX,
 y: notesInColumn.length * 140,
 style: {
 fillColor: severity === 'critical' ? 'red' :
 severity === 'high' ? 'orange' :
 severity === 'medium' ? 'yellow' : 'green',
 textAlign: 'left',
 },
 });
 }
}
```

## Design Sprint Facilitation

Design sprints compress months of design work into five days. The Miro Chrome extension supports facilitators by keeping the board one click away throughout the sprint:

- Day 1 (Map): Use context menu to capture competitor screenshots directly into the "How Might We" frame
- Day 2 (Sketch): Open the board instantly between sketching sessions to reference the sprint challenge
- Day 3 (Decide): Share the live embed URL in Slack for async dot-voting before the sync session
- Day 4 (Prototype): Embed the prototype flow board in the brief document shared with user research
- Day 5 (Test): Use the extension to take notes as a sticky note stream during user sessions

## Advanced Configuration Options

## Keyboard Shortcuts

The Miro Chrome extension supports several keyboard shortcuts for power users:

- `Ctrl+Shift+M`: Open Miro extension popup
- `Ctrl+Shift+N`: Create new board
- `Ctrl+Shift+O`: Open recent board

You can customize Chrome extension shortcuts globally under `chrome://extensions/shortcuts`. Reassign the defaults to match your muscle memory or avoid conflicts with other tools. For example, if `Ctrl+Shift+M` conflicts with your mail client, you can remap it to `Ctrl+Shift+W` for "whiteboard."

## Permission Management

For enterprise deployments, administrators can manage extension permissions through Chrome Enterprise policies. This controls which domains can access Miro boards and what level of interaction is permitted.

```json
// Chrome Enterprise policy example (admin-configured)
{
 "MiroExtension": {
 "AllowedDomains": ["*.yourcompany.com"],
 "EmbedPolicy": "strict",
 "ApiAccess": "read-only"
 }
}
```

Enterprise policy enforcement happens via Google Admin Console or on-premise endpoint management tools like Jamf (macOS) or Intune (Windows). The key policy settings to review with your IT team:

| Policy Setting | Options | Recommended Default |
|---|---|---|
| ExtensionInstallAllowlist | List of allowed extension IDs | Add Miro's extension ID |
| ExtensionInstallBlocklist | `*` to block all unlisted | Combine with allowlist |
| URLBlocklist | Specific Miro API endpoints | Leave open unless compliance requires it |
| DefaultClipboardSetting | Allow or block clipboard access | Allow (Miro paste feature) |

## Building a Custom Miro App with the Extension as Shell

Advanced teams build internal Miro apps that appear as custom icons in the left sidebar of every board. The Chrome extension handles OAuth, and the app itself is just an iframe loaded from your own server:

```javascript
// app.js. a minimal Miro app panel
import { Board } from '@mirohq/websdk-types';

async function init() {
 // Register app on first load
 await miro.board.ui.on('icon:click', openPanel);
}

async function openPanel() {
 await miro.board.ui.openPanel({
 url: '/panel.html', // served from your own origin
 width: 320,
 });
}

init();
```

```html
<!-- panel.html. custom sidebar UI -->
<!DOCTYPE html>
<html>
<body>
 <h3>Story Importer</h3>
 <input id="jira-query" placeholder="JQL query..." />
 <button onclick="importStories()">Import to Board</button>
 <script src="app.js"></script>
</body>
</html>
```

This pattern powers tools like the official Jira and GitHub integrations. Building your own means you can pull from any internal data source, a spreadsheet, a Postgres table, a REST API, and visualize it directly in Miro.

## Integration with Development Tools

The Miro Chrome extension integrates smoothly with popular developer tools:

GitHub Integration: Embed Miro diagrams in PR descriptions and issues. Visualize feature branches as mind maps or architectural decision records.

Slack Integration: Share board links directly from the extension to Slack channels. Quick-create boards from Slack messages.

Jira Integration: Link Miro boards to Jira epics. Visualize sprint progress with embedded Miro widgets.

## Setting Up the GitHub + Miro Workflow

The most practical GitHub integration is a board-per-PR convention. Each significant PR gets a linked Miro frame for design review notes and architecture diagrams. A GitHub Actions workflow can automate board creation:

```yaml
.github/workflows/miro-board.yml
name: Create Miro Review Board

on:
 pull_request:
 types: [opened]
 branches: [main]

jobs:
 create-board:
 runs-on: ubuntu-latest
 steps:
 - name: Create Miro board for PR
 run: |
 BOARD_NAME="PR #${{ github.event.pull_request.number }} Review"
 RESPONSE=$(curl -s -X POST \
 "https://api.miro.com/v2/boards" \
 -H "Authorization: Bearer ${{ secrets.MIRO_API_TOKEN }}" \
 -H "Content-Type: application/json" \
 -d "{\"name\": \"$BOARD_NAME\", \"policy\": {\"sharingPolicy\": {\"access\": \"team\"}}}")
 BOARD_URL=$(echo $RESPONSE | jq -r '.viewLink')
 echo "MIRO_URL=$BOARD_URL" >> $GITHUB_ENV

 - name: Comment board link on PR
 uses: actions/github-script@v7
 with:
 script: |
 github.rest.issues.createComment({
 owner: context.repo.owner,
 repo: context.repo.repo,
 issue_number: context.issue.number,
 body: `Miro review board created: ${{ env.MIRO_URL }}\n\nUse this board for architecture diagrams and design review notes.`
 });
```

## Jira Integration Detailed look

Miro's official Jira integration syncs Jira cards directly into Miro as cards you can drag around. For teams that already use Jira as their source of truth, this removes the copy-paste step during sprint planning:

1. Open your sprint board in Miro
2. Click the Jira logo in the left sidebar (requires the Jira app installed)
3. Search for your sprint or project by JQL
4. Drag issues from the panel onto the board

The cards stay in sync: changing status in Jira updates the card color in Miro, and vice versa if you enable bidirectional sync.

## Troubleshooting Common Issues

## Board Loading Problems

If boards fail to load within the extension, first verify your network connection. The extension requires WebSocket connectivity for real-time updates. Check Chrome's developer console for specific error messages.

More detailed troubleshooting steps:

1. Open Chrome DevTools (`F12`) while the extension popup is open (right-click the popup and choose "Inspect")
2. Look for WebSocket errors in the Network tab. filter by `WS` type
3. Check the Console tab for CORS errors, which indicate a proxy or firewall is stripping headers
4. If you see `ERR_NETWORK_CHANGED`, your corporate VPN is interfering with WebSocket upgrades

| Symptom | Likely Cause | Fix |
|---|---|---|
| Board loads then freezes | WebSocket blocked | Whitelist `*.miro.com` in firewall |
| "Access denied" on board open | Wrong Miro account | Sign out and sign back in |
| Extension popup blank | Corrupted extension data | Remove and reinstall extension |
| Embed not rendering in wiki | CSP header blocking iframe | Add `miro.com` to Content-Security-Policy |
| Sync delays over 10 seconds | Slow connection or large board | Use frame-level embeds, not full board |

## Permission Denied Errors

When the extension cannot access certain boards, ensure you're signed into the correct Miro account. The extension uses OAuth, so your browser session must include valid Miro credentials.

For teams using SSO (SAML or OIDC), the OAuth flow redirects through your identity provider. If that redirect fails silently, the extension appears signed in but lacks a valid token. The fix: sign out from both Chrome and your identity provider, then sign back into Miro through the full web app first, then reopen the extension.

## Sync Delays

Real-time collaboration may experience brief delays on slower connections. The extension operates in a cached mode when offline, synchronizing changes when connectivity restores.

## Security Considerations

The Miro Chrome extension operates with specific permissions that developers should understand:

- Board Access: The extension can read and modify boards you have permission to access
- Domain Embeds: Embedded content may load external resources
- OAuth Tokens: Session tokens are stored securely within Chrome's encrypted storage

For organizations with strict security requirements, Miro offers enterprise-grade admin controls that let IT teams configure which users can install extensions and which boards are accessible.

## Data Classification and Board Sensitivity

Not all Miro boards carry equal risk. Define a classification policy before deploying at scale:

| Classification | Example Content | Extension Access | Embed Allowed |
|---|---|---|---|
| Public | Marketing materials, open-source diagrams | Allowed | Yes, any domain |
| Internal | Sprint boards, team OKRs | Allowed | Intranet only |
| Confidential | Customer data, financial models | Allowed with audit log | No |
| Restricted | IP, M&A planning | Explicit allowlist only | Never |

Miro's enterprise tier supports board-level access controls that align with this model. Configure them in the Miro Admin Console under Security > Board Permissions.

## Extension Permissions Audit

When you install the Miro extension, Chrome requests these permissions. Understand each one:

| Permission | What It Enables | Risk Level |
|---|---|---|
| `storage` | Saves recent boards and preferences locally | Low |
| `contextMenus` | Adds right-click "Add to Miro" option | Low |
| `tabs` | Reads current tab URL to suggest board context | Medium |
| `notifications` | Shows board comment alerts | Low |
| `identity` | OAuth token exchange | Medium |

The `tabs` permission is the most sensitive: it means the extension can read the URL of every tab you have open. This is used to match boards to the pages you visit. If your organization prohibits this, use the web app instead of the extension for confidential browsing sessions.

## Extending Miro with the REST API

Beyond the extension and Web SDK, Miro offers a REST API that lets you automate board management from any language or tool:

```bash
List all boards in your team
curl -s "https://api.miro.com/v2/boards" \
 -H "Authorization: Bearer $MIRO_ACCESS_TOKEN" | \
 jq '.data[] | {id: .id, name: .name, modified: .modifiedAt}'

Create a sticky note on a specific board
curl -s -X POST \
 "https://api.miro.com/v2/boards/$BOARD_ID/sticky_notes" \
 -H "Authorization: Bearer $MIRO_ACCESS_TOKEN" \
 -H "Content-Type: application/json" \
 -d '{
 "data": {
 "content": "Automated note from API",
 "shape": "square"
 },
 "style": {
 "fillColor": "light_yellow"
 },
 "position": {
 "x": 0.0,
 "y": 0.0
 }
 }'
```

A Python script that reads a CSV of action items and creates a Miro sticky note grid:

```python
import csv
import httpx

MIRO_TOKEN = "your_token_here"
BOARD_ID = "your_board_id"

def create_sticky(content: str, x: float, y: float, color: str = "light_yellow") -> dict:
 response = httpx.post(
 f"https://api.miro.com/v2/boards/{BOARD_ID}/sticky_notes",
 headers={"Authorization": f"Bearer {MIRO_TOKEN}"},
 json={
 "data": {"content": content, "shape": "square"},
 "style": {"fillColor": color},
 "position": {"x": x, "y": y},
 },
 )
 response.raise_for_status()
 return response.json()

with open("action_items.csv") as f:
 reader = csv.DictReader(f)
 for i, row in enumerate(reader):
 col = i % 5 # 5 columns wide
 row_num = i // 5
 create_sticky(
 content=f"{row['owner']}: {row['action']}",
 x=col * 220.0,
 y=row_num * 160.0,
 color="light_green" if row["status"] == "done" else "light_yellow",
 )
 print(f"Created note {i+1}: {row['action'][:40]}...")
```

## Conclusion

The Miro Chrome extension transforms how developers and power users interact with collaborative whiteboards. By bringing board access directly into the browser, it reduces friction in workflows that constantly switch between documentation, code, and visual planning tools. Whether you're running sprint retrospectives, designing system architectures, or facilitating design sprints, the extension provides the quick access and integration points that modern development teams need.

Start by installing the extension, pinning it to your toolbar, and exploring your recent boards. Then layer in the Web SDK for programmatic board control, the REST API for automation, and enterprise policy management for secure team-wide deployment. The productivity gains become apparent within the first few sessions, and the automation possibilities compound as your team builds tooling on top of the Miro platform.

---

---

<div class="mastery-cta">

I'm a solo developer in Vietnam. 50K Chrome extension users. $500K+ on Upwork. 5 Claude Max subscriptions running agent fleets in parallel.

These are my actual CLAUDE.md templates, orchestration configs, and prompts. Not a course. Not theory. The files I copy into every project before I write a line of code.

**[See what's inside →](https://zovo.one/lifetime?utm_source=ccg&utm_medium=cta-default&utm_campaign=chrome-extension-miro-whiteboard)**

$99 once. Free forever. 47/500 founding spots left.

</div>

Related Reading

- [Session Buddy Alternative Chrome Extension 2026: Top Picks for Power Users](/session-buddy-alternative-chrome-extension-2026/)
- [Workona Alternative Chrome Extension 2026: Top Picks for Power Users](/workona-alternative-chrome-extension-2026/)
- [AI Screen Reader Chrome Extension: A Complete Guide for Developers](/ai-screen-reader-chrome-extension/)
- [Mendeley Chrome Extension — Honest Review 2026](/mendeley-chrome-extension-review/)
- [Responsive Design Tester Chrome Extension Guide (2026)](/chrome-extension-responsive-design-tester/)
- [GraphQL Playground Chrome Extension Guide (2026)](/graphql-chrome-extension-playground/)
- [Best Screenshot Chrome Extensions 2026](/best-screenshot-chrome-extension-2026/)
- [Momentum Alternative Chrome — Developer Comparison 2026](/momentum-alternative-chrome-extension-2026/)
- [Ghostery Alternative Chrome Extension in 2026](/ghostery-alternative-chrome-extension-2026/)
- [How to Export Passwords from Chrome Safely](/export-passwords-chrome-safely/)
- [Lusha Alternative Chrome Extension in 2026](/lusha-alternative-chrome-extension-2026/)

Built by theluckystrike. More at [zovo.one](https://zovo.one)
{% endraw %}



---

## Frequently Asked Questions

### What are the key features for developers and power users?

Key features include quick board access with a recent boards list respecting workspace and team structure, embed integration for inserting interactive Miro frames into documentation and wikis using iframes with moveToViewport parameters, Chrome context menu integration for right-click capture of selected text, images, or links directly into boards as sticky notes, and the Miro Web SDK for programmatic board control including reading items, creating cards, and filtering by type.

### What is Quick Board Access?

Quick board access maintains a list of recently accessed boards in the extension popup, enabling instant switching between active projects without navigating Miro's full web interface. The board list respects your workspace and team structure, and if you work across multiple Miro teams (common for contractors and consultants), you can switch the active workspace from the extension popup. The extension launches in under 2 seconds compared to 4-8 seconds for the web app.

### What is Embed Integration?

Embed integration allows you to insert interactive Miro boards or specific frames into documentation, wikis, and internal tools using iframes. The src URL format is `https://miro.com/app/live-embed/{board-id}/` with an optional moveToViewport parameter specifying x, y, width, height coordinates to target a specific board region. For responsive embeds, wrap the iframe in a CSS container using aspect-ratio: 16/9 with position: absolute and inset: 0 on the iframe.

### What is Chrome Context Menu Integration?

Chrome context menu integration enables right-click functionality to quickly create Miro items from selected web content. Highlight text from a competitor's documentation, right-click, and add it directly to your active board as a sticky note without losing your place in the source page. This feature is especially useful during research sessions, competitive analysis, and design sprint Day 1 mapping activities where you need to capture information rapidly from multiple web sources.

### What is Miro Web SDK: Programmatic Board Control?

The Miro Web SDK exposes a comprehensive JavaScript API for reading and writing board content programmatically. Use miro.board.get() to retrieve all board items, filter by type with miro.board.get({ type: 'sticky_note' }), and create new elements with miro.board.createCard() or miro.board.createStickyNote(). The Chrome extension handles OAuth authentication, so SDK calls from browser pages interact with the currently active board. This powers custom apps, sprint planning automations, and bug triage board generators.
