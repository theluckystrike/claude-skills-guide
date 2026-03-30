---

layout: default
title: "Building a Chrome Extension for Break Reminders in."
description: "Learn how to build a Chrome extension that helps remote workers take regular breaks. Complete with code examples and practical implementation guide."
date: 2026-03-15
last_modified_at: 2026-03-15
author: "Claude Skills Guide"
permalink: /chrome-extension-break-reminder-remote-work/
reviewed: true
score: 8
categories: [guides]
tags: [chrome-extension, claude-skills]
---


{% raw %}
Remote work offers flexibility and freedom, but it also blurs the boundaries between focused work and rest. Without the natural interruptions of an office environment, colleagues stopping by, meetings, or simply walking to a different room, developers and power users often find themselves staring at screens for hours without taking breaks. This habit leads to eye strain, decreased productivity, and burnout.

A well-designed Chrome extension for break reminders solves this problem by proactively nudging you to step away from the keyboard. I'll walk you through building a break reminder extension tailored for remote workers, complete with practical code examples you can customize.

Why Break Reminders Matter for Developers

As developers, we spend countless hours debugging code, writing functions, and reviewing pull requests. The Pomodoro Technique and similar productivity methods work because they acknowledge a simple truth: our brains need recovery time to maintain peak performance.

Chrome extensions offer the perfect vehicle for break reminders because they run directly in your browser, the same place you likely spend most of your work hours. Unlike standalone apps that might get hidden behind other windows, a browser extension can display notifications directly in your workflow.

Project Structure

A Chrome extension requires a few essential files:

```
break-reminder/
 manifest.json
 popup.html
 popup.js
 background.js
 icon.png
 styles.css
```

The manifest.json file defines the extension's configuration and permissions:

```json
{
  "manifest_version": 3,
  "name": "Remote Work Break Reminder",
  "version": "1.0",
  "description": "Gentle reminders to take breaks during remote work sessions",
  "permissions": ["notifications", "storage", "alarms"],
  "background": {
    "service_worker": "background.js"
  },
  "action": {
    "default_popup": "popup.html",
    "default_icon": "icon.png"
  },
  "icons": {
    "48": "icon.png"
  }
}
```

Notice we're using Manifest V3, which is the current standard for Chrome extensions. This version requires service workers instead of background pages, which we'll implement in background.js.

Implementing the Timer Logic

The core functionality lives in the background service worker. This script runs independently of any open tabs, making it ideal for timing-based features:

```javascript
// background.js
let workDuration = 25; // minutes
let breakDuration = 5; // minutes
let isWorking = true;

chrome.alarms.create('breakReminder', { periodInMinutes: workDuration });

chrome.alarms.onAlarm.addListener((alarm) => {
  if (alarm.name === 'breakReminder') {
    if (isWorking) {
      showNotification('Time for a break!', 'Step away from your screen for a few minutes.');
      isWorking = false;
      chrome.alarms.create('workReminder', { periodInMinutes: breakDuration });
    } else {
      showNotification('Break over!', 'Ready to get back to work?');
      isWorking = true;
      chrome.alarms.create('breakReminder', { periodInMinutes: workDuration });
    }
  }
});

function showNotification(title, message) {
  chrome.notifications.create({
    type: 'basic',
    iconUrl: 'icon.png',
    title: title,
    message: message,
    priority: 2
  });
}
```

This implementation alternates between work and break periods. After each work duration, it triggers a notification reminding you to take a break. After each break, it notifies you when it's time to resume working.

Building the Settings Popup

Users need a way to configure their preferred intervals. The popup.html provides a simple interface:

```html
<!DOCTYPE html>
<html>
<head>
  <link rel="stylesheet" href="styles.css">
</head>
<body>
  <div class="container">
    <h2>Break Reminder Settings</h2>
    <label>
      Work duration (minutes):
      <input type="number" id="workDuration" value="25" min="5" max="120">
    </label>
    <label>
      Break duration (minutes):
      <input type="number" id="breakDuration" value="5" min="1" max="30">
    </label>
    <button id="saveSettings">Save Settings</button>
    <p id="status"></p>
  </div>
  <script src="popup.js"></script>
</body>
</html>
```

The corresponding popup.js handles saving user preferences to Chrome's storage API:

```javascript
// popup.js
document.addEventListener('DOMContentLoaded', () => {
  // Load saved settings
  chrome.storage.sync.get(['workDuration', 'breakDuration'], (result) => {
    if (result.workDuration) {
      document.getElementById('workDuration').value = result.workDuration;
    }
    if (result.breakDuration) {
      document.getElementById('breakDuration').value = result.breakDuration;
    }
  });

  document.getElementById('saveSettings').addEventListener('click', () => {
    const workDuration = parseInt(document.getElementById('workDuration').value);
    const breakDuration = parseInt(document.getElementById('breakDuration').value);

    chrome.storage.sync.set({ workDuration, breakDuration }, () => {
      document.getElementById('status').textContent = 'Settings saved!';
      setTimeout(() => {
        document.getElementById('status').textContent = '';
      }, 2000);
    });
  });
});
```

Adding Sound Notifications

For developers who might miss visual notifications, adding an audio cue increases the likelihood of actually taking a break. Chrome extensions can play sounds using the HTML5 Audio API through content scripts or by using chrome.alarms with audio playback in the background.

To add sound support, modify background.js to include audio playback:

```javascript
function playNotificationSound() {
  const audio = new Audio('notification.mp3');
  audio.play().catch(err => console.log('Audio playback failed:', err));
}

chrome.alarms.onAlarm.addListener((alarm) => {
  if (alarm.name === 'breakReminder') {
    showNotification('Time for a break!', 'Step away from your screen.');
    playNotificationSound();
    // ... rest of the logic
  }
});
```

Customizing for Different Work Styles

Every developer works differently. Some prefer the Pomodoro-style 25/5 intervals, while others might prefer longer deep work sessions with less frequent breaks. The extension's settings allow customization, but you can also add presets:

```javascript
const presets = {
  pomodoro: { work: 25, break: 5 },
  deepWork: { work: 50, break: 10 },
  light: { work: 45, break: 15 }
};
```

Add these to your popup.js to give users quick configuration options.

Testing Your Extension

Before publishing to the Chrome Web Store, test your extension locally:

1. Open Chrome and navigate to `chrome://extensions/`
2. Enable "Developer mode" in the top right corner
3. Click "Load unpacked" and select your extension folder
4. The extension icon should appear in your toolbar
5. Test the notifications and verify settings persist across browser restarts

Installation and Usage

To install your custom extension:
- Click the extension icon in the Chrome toolbar
- Adjust your preferred work and break durations
- Click "Save Settings"
- Start working, the notifications will begin automatically

The extension runs in the background, so you don't need to keep the popup open. Your settings persist across browser sessions and even after closing and reopening Chrome.

Extending the Extension

Once you have the basic break reminder working, consider adding these enhancements:
- Website blocking during break times to enforce the pause
- Statistics tracking to see your break patterns over time
- Integration with task managers like Todoist or Notion
- Focus mode that suppresses notifications during critical debugging sessions

Building a break reminder extension teaches valuable skills about Chrome's extension APIs while creating a genuinely useful tool for your own productivity. The combination of background service workers, the notifications API, and storage synchronization provides a solid foundation for more complex extensions.

Remember: the best productivity tools are the ones you'll actually use. Start with a simple implementation, test it in your daily workflow, and iterate based on what works for your specific remote work situation.


Related Reading

- [Claude Code for Beginners: Complete Getting Started Guide](/claude-code-for-beginners-complete-getting-started-2026/)
- [Best Claude Skills for Developers in 2026](/best-claude-skills-for-developers-2026/)
- [Claude Skills Guides Hub](/guides-hub/)

Built by theluckystrike. More at [zovo.one](https://zovo.one)
{% endraw %}
