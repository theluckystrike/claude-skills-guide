---
layout: default
title: "Redux DevTools Chrome Tutorial (2026)"
description: "A comprehensive guide to using Redux DevTools in Chrome for debugging Redux applications. Learn time-travel debugging, action inspection, and state."
date: 2026-03-15
last_modified_at: 2026-04-17
author: theluckystrike
permalink: /redux-devtools-chrome-tutorial/
categories: [guides]
tags: [tools]
reviewed: true
score: 8
geo_optimized: true
---

Redux DevTools is a powerful browser extension that transforms how developers debug and inspect Redux applications. If you're building applications with Redux, this tool provides essential visibility into your application's state changes and helps you track down bugs faster. Instead of sprinkling `console.log` calls throughout your reducers and action creators, Redux DevTools gives you a visual, interactive debugger that shows exactly what happened, when it happened, and what the state looked like at every step.

This tutorial covers installation, store configuration, core debugging techniques, advanced usage patterns, and solutions to the most common problems developers run into.

## Installing Redux DevTools

You can install Redux DevTools from the Chrome Web Store by searching for "Redux DevTools" or directly from the GitHub repository at `reduxjs/redux-devtools`. The extension adds a new panel to your Chrome DevTools that displays your Redux store state, dispatched actions, and allows for time-travel debugging.

After installation, open Chrome DevTools (F12 or right-click and choose Inspect) and look for the "Redux" tab in the toolbar. If you don't see it immediately, click the double-arrow icon (`>>`) at the right end of the DevTools tab bar to find it in the overflow menu.

The extension automatically detects Redux stores in your application once your store is configured correctly. You do not need to do anything beyond the store configuration covered in the next section.

You will also need the npm package that bridges your store to the extension:

```bash
npm install @redux-devtools/extension
or
yarn add @redux-devtools/extension
```

If you're using Redux Toolkit (which is the recommended approach for new Redux projects in 2026), DevTools integration is built in and requires zero additional configuration. covered further below.

## Setting Up Your Redux Store

For Redux DevTools to work, you need to configure your store with the appropriate middleware. Here's a basic setup using the classic `createStore` API:

```javascript
import { createStore, applyMiddleware } from 'redux';
import { composeWithDevTools } from '@redux-devtools/extension';

// Your reducer
function counterReducer(state = { count: 0 }, action) {
 switch (action.type) {
 case 'INCREMENT':
 return { count: state.count + 1 };
 case 'DECREMENT':
 return { count: state.count - 1 };
 case 'SET_COUNT':
 return { count: action.payload };
 default:
 return state;
 }
}

// Configure store with DevTools
const store = createStore(
 counterReducer,
 composeWithDevTools(
 applyMiddleware()
 )
);

export default store;
```

The `composeWithDevTools` function from `@redux-devtools/extension` automatically integrates DevTools into your store. This is the recommended approach for classic Redux applications still using `createStore`.

## Setup with Redux Toolkit

If you're using Redux Toolkit's `configureStore`, DevTools is enabled automatically in development mode. No extra packages or configuration are required:

```javascript
import { configureStore } from '@reduxjs/toolkit';
import counterReducer from './counterSlice';
import todosReducer from './todosSlice';
import userReducer from './userSlice';

const store = configureStore({
 reducer: {
 counter: counterReducer,
 todos: todosReducer,
 user: userReducer,
 },
 // DevTools is enabled by default in development.
 // To disable it explicitly:
 // devTools: false,
});

export default store;
```

Redux Toolkit automatically disables DevTools in production builds when `process.env.NODE_ENV === 'production'`, so you don't need to add conditional logic yourself.

## Setup with Middleware

Most real applications include middleware like `redux-thunk` or `redux-saga`. Here's how to combine DevTools with middleware:

```javascript
import { createStore, applyMiddleware } from 'redux';
import { composeWithDevTools } from '@redux-devtools/extension';
import thunk from 'redux-thunk';
import logger from 'redux-logger';
import rootReducer from './reducers';

const store = createStore(
 rootReducer,
 composeWithDevTools(
 applyMiddleware(thunk, logger)
 )
);

export default store;
```

The key is that `composeWithDevTools` replaces the standard `compose` from Redux. If you were previously using `compose` to chain your enhancers, swap it for `composeWithDevTools` directly.

## Understanding the DevTools Interface

The Redux DevTools panel displays several key areas worth understanding before you start debugging:

- Action Log: Shows all dispatched actions in chronological order, newest at the bottom. Each entry shows the action type and a timestamp.
- State Inspector: Displays the current state of your Redux store in an expandable tree. Nested objects can be expanded to inspect deeply nested values.
- Diff View: Highlights changes between the state before and after a given action. Green means added, red means removed.
- Jump Controls: Allows time-travel to any previous state by clicking an action in the log.
- Action Detail Panel: Clicking any action in the log shows three sub-tabs: Action (the action object), State (the state after this action), and Diff (what changed).

The toolbar at the top of the panel includes controls to pause recording, clear the action log, and access settings. The slider at the bottom of the panel is how you scrub through your action history interactively.

## Time-Travel Debugging

One of the most powerful features of Redux DevTools is time-travel debugging. You can literally travel back in time to inspect your application's state at any point in its history during the current session.

Click on any action in the log, and the application's UI jumps to that state moment. The application is fully interactive at that historical state. you can see exactly what your user was looking at when a specific action was dispatched.

To test this feature, dispatch a sequence of actions and observe them in the panel:

```javascript
// Dispatch some actions to build up history
store.dispatch({ type: 'INCREMENT' });
store.dispatch({ type: 'INCREMENT' });
store.dispatch({ type: 'DECREMENT' });
store.dispatch({ type: 'SET_COUNT', payload: 10 });
store.dispatch({ type: 'INCREMENT' });
```

When you view these actions in DevTools, clicking on the `DECREMENT` action shows your application exactly as it was after that decrement. even though two more actions have fired since then. Your React components re-render to reflect that historical state, giving you a live preview of each step.

The "Slider" control at the bottom lets you scrub through your entire action history smoothly. This is particularly useful for debugging animations or transitions tied to state changes. you can step frame-by-frame through a sequence to find exactly where a visual glitch originates.

## Commit and Revert

The DevTools panel has two important buttons in the action log:

- Commit: Collapses all current history into a single baseline. Use this when the early actions are no longer relevant and you want to focus on recent activity.
- Revert: Undoes all actions back to the last committed state. Useful when you've dispatched test actions and want to return to a known-good baseline without refreshing the page.

These controls let you create a checkpoint in your session, experiment with actions, and roll back cleanly if needed.

## Inspecting Action Payloads

Redux DevTools automatically displays the full payload of each action in a formatted, expandable tree. This helps you verify that your actions carry the correct data before they reach the reducer:

```javascript
// Actions with payloads are clearly displayed
store.dispatch({
 type: 'ADD_TODO',
 payload: {
 id: 1,
 text: 'Learn Redux DevTools',
 completed: false
 }
});

store.dispatch({
 type: 'UPDATE_USER',
 payload: {
 userId: 42,
 updates: {
 name: 'New Name',
 email: 'user@example.com'
 }
 }
});

// Async action results from thunks look the same
store.dispatch({
 type: 'FETCH_POSTS/fulfilled',
 payload: [
 { id: 1, title: 'First Post', body: '...' },
 { id: 2, title: 'Second Post', body: '...' }
 ],
 meta: { requestId: 'abc123', requestStatus: 'fulfilled' }
});
```

The DevTools panel shows these nested objects in a readable format, making it easy to verify your data structures match what your reducer expects. If you're seeing unexpected state values, checking the action payload first often reveals the problem immediately. either the payload structure is wrong, or the reducer is handling it incorrectly.

## Using Selective Monitoring

For larger applications, You should limit what DevTools tracks. High-frequency actions like WebSocket heartbeats, polling ticks, or scroll position updates can flood the action log and make it hard to find relevant actions.

The extension supports selective monitoring through configuration options:

```javascript
import { composeWithDevTools } from '@redux-devtools/extension';
import thunk from 'redux-thunk';
import rootReducer from './reducers';

const composeEnhancers = composeWithDevTools({
 // Exclude noisy actions from the log
 actionsBlacklist: ['HEARTBEAT', 'TICK', 'SCROLL_POSITION_UPDATED'],

 // Or whitelist only specific actions you care about:
 // actionsWhitelist: ['ADD_TODO', 'DELETE_TODO', 'UPDATE_USER'],

 // Limit how many actions are kept in history
 maxAge: 50,

 // Serialize non-serializable values (e.g., Dates, Sets)
 serialize: {
 replacer: (key, value) => {
 if (value instanceof Date) return value.toISOString();
 if (value instanceof Set) return Array.from(value);
 return value;
 }
 }
});

const store = createStore(
 rootReducer,
 composeEnhancers(applyMiddleware(thunk))
);
```

Setting `maxAge` to 50 means DevTools only keeps the last 50 actions in history. This improves memory usage and panel performance for long-running sessions.

The `serialize` option is particularly important for applications that store non-serializable values like `Date` objects, `Map`, or `Set` instances in Redux state. By default, Redux DevTools will warn about these. the serializer lets you control how they appear in the panel.

## Debugging with State Diff

The Diff view shows exactly what changed between two states. Click on an action, then click the "Diff" tab to see a color-coded breakdown:

- Green additions: New properties added or values that increased
- Red deletions: Removed properties or decreased values
- Gray unchanged: Properties that didn't change

This feature makes it easy to spot unexpected state mutations or verify that updates are working correctly. A common use case is debugging a reducer that's supposed to update one property but is accidentally clearing another.

Consider this reducer bug:

```javascript
// Buggy reducer. accidentally overwrites entire todos array
function todosReducer(state = { items: [], filter: 'all' }, action) {
 switch (action.type) {
 case 'ADD_TODO':
 // BUG: This replaces the whole state object instead of spreading it
 return { items: [...state.items, action.payload] };
 default:
 return state;
 }
}
```

When you dispatch `ADD_TODO` and look at the Diff tab, you'll immediately see `filter` shown in red (deleted) even though you only intended to add a todo item. The Diff view catches this kind of mutation bug instantly, whereas a console log might only show you the new state without comparing it to the old one.

The fixed version would spread the existing state:

```javascript
case 'ADD_TODO':
 return { ...state, items: [...state.items, action.payload] };
```

## Exporting and Importing State

Redux DevTools lets you export your entire action history or current state, which is useful in several scenarios:

- Bug reports: Share the exact state that reproduces an issue with a teammate
- Testing: Create reproducible test cases from real user sessions
- Collaboration: Hand off a specific app state to a designer or QA engineer

Click the "Export" button (down-arrow icon) in the DevTools panel to download your action log as a JSON file. You can then share this file, and anyone with the same application can import it to replay the exact sequence of events.

```json
{
 "actionsById": {
 "0": { "type": "PERFORM_ACTION", "action": { "type": "@@INIT" } },
 "1": { "type": "PERFORM_ACTION", "action": { "type": "ADD_TODO", "payload": { "id": 1, "text": "Fix login bug" } } },
 "2": { "type": "PERFORM_ACTION", "action": { "type": "SET_FILTER", "payload": "active" } }
 },
 "currentStateIndex": 2,
 "computedStates": [...]
}
```

To import, click the folder icon in the DevTools panel and select the exported JSON file. The entire action history replays, and you can step through it just as if you had dispatched those actions yourself.

This is particularly valuable in remote debugging scenarios. A user can trigger "Export State" from a debug menu in your application (which calls `window.__REDUX_DEVTOOLS_EXTENSION__.exportState()`) and attach the file to a support ticket.

## Advanced: Customizing DevTools

For development environments where you want DevTools embedded directly in the application (not as a browser extension), you can create a custom DevTools component:

```javascript
import { createDevTools } from '@redux-devtools/core';
import { LogMonitor } from '@redux-devtools/log-monitor';
import { DockMonitor } from '@redux-devtools/dock-monitor';

const DevTools = createDevTools(
 <DockMonitor
 toggleVisibilityKey="ctrl-h"
 changePositionKey="ctrl-q"
 defaultIsVisible={false}
 >
 <LogMonitor theme="tomorrow" hideMainButtons={false} />
 </DockMonitor>
);

export default DevTools;
```

Then use it in your store configuration and render it in your app:

```javascript
// store.js
import { createStore } from 'redux';
import rootReducer from './reducers';
import DevTools from './DevTools';

const store = createStore(
 rootReducer,
 DevTools.instrument()
);

export default store;
```

```javascript
// App.jsx
import DevTools from './DevTools';

function App() {
 return (
 <div>
 <Router>
 {/* your application routes */}
 </Router>
 {process.env.NODE_ENV !== 'production' && <DevTools store={store} />}
 </div>
 );
}
```

This gives you keyboard shortcuts to show/hide and reposition the DevTools panel within your application. useful for testing environments where you can't open browser DevTools, such as a dedicated QA machine or a CI browser test.

## Integrating DevTools with Redux Toolkit Slices

Redux Toolkit slices work transparently with DevTools. Action types are automatically namespaced by the slice name, making them easy to identify in the action log:

```javascript
import { createSlice } from '@reduxjs/toolkit';

const todosSlice = createSlice({
 name: 'todos',
 initialState: { items: [], status: 'idle' },
 reducers: {
 addTodo: (state, action) => {
 state.items.push({ id: Date.now(), ...action.payload, completed: false });
 },
 toggleTodo: (state, action) => {
 const todo = state.items.find(t => t.id === action.payload);
 if (todo) todo.completed = !todo.completed;
 },
 removeTodo: (state, action) => {
 state.items = state.items.filter(t => t.id !== action.payload);
 }
 }
});
```

In DevTools, these actions appear as `todos/addTodo`, `todos/toggleTodo`, and `todos/removeTodo`. immediately clear about which slice and which operation. When your application has many slices, this namespacing makes the action log much easier to scan.

Async thunks created with `createAsyncThunk` appear as three lifecycle actions per request: `pending`, `fulfilled`, and `rejected`. This gives you full visibility into async flows:

```javascript
import { createAsyncThunk } from '@reduxjs/toolkit';

export const fetchTodos = createAsyncThunk(
 'todos/fetchAll',
 async (userId) => {
 const response = await fetch(`/api/users/${userId}/todos`);
 return response.json();
 }
);

// In DevTools, you'll see:
// todos/fetchAll/pending . when the request starts
// todos/fetchAll/fulfilled. when it resolves
// todos/fetchAll/rejected . if it errors
```

## Common Issues and Solutions

Redux DevTools isn't appearing in the panel:
1. Verify your store is configured with `composeWithDevTools` or that you're using `configureStore` from Redux Toolkit
2. Open the browser console and look for errors related to the DevTools extension
3. Refresh the page. DevTools only initializes at page load, not after hot module replacement
4. Confirm the Redux DevTools extension is enabled in Chrome's extensions manager (`chrome://extensions`)

DevTools appears but shows no actions:
1. Check that your React components are actually connected to the Redux store (using `useSelector` or `connect`)
2. Verify actions are being dispatched. add a temporary `console.log` in your action creator to confirm
3. Ensure you're not accidentally creating a second store instance that isn't connected to DevTools

Warning about non-serializable values in state:
Redux state should only contain plain serializable values. If you're storing class instances, Dates, or functions, you'll see warnings. Fix this by converting to serializable equivalents:

```javascript
// Instead of storing Date objects:
{ createdAt: new Date() }

// Store ISO strings:
{ createdAt: new Date().toISOString() }

// Instead of storing a Set:
{ selectedIds: new Set([1, 2, 3]) }

// Store an array:
{ selectedIds: [1, 2, 3] }
```

DevTools slows down after many actions:
Set the `maxAge` option to limit history length. For applications with very frequent updates (like real-time collaborative tools), consider filtering out high-frequency actions with `actionsBlacklist`.

DevTools shows stale state after a hot reload:
This is expected. Hot module replacement replaces your reducer code but doesn't replay actions through the new reducer logic. Refresh the page to start fresh with the updated reducers.

For production builds, DevTools automatically disables itself. you don't need to remove the integration code. The `composeWithDevTools` function returns the plain `compose` function when the extension isn't present, so there's no runtime error if a user doesn't have the extension installed.

## Summary

Redux DevTools is an indispensable tool for Redux developers that pays for its setup time within the first debugging session. Key takeaways:

- Install the Chrome extension and configure your store with `@redux-devtools/extension`, or use Redux Toolkit's `configureStore` which includes DevTools automatically
- Use time-travel debugging to replay your entire action history and inspect application state at any point
- Inspect action payloads and state changes in real-time without console.log calls
- Use the Diff view to identify exactly what changed between two states and catch accidental mutations
- Filter high-frequency actions with `actionsBlacklist` to reduce noise in large applications
- Export action history as JSON for bug reports, testing, and team collaboration
- Integrate the custom DevTools component for embedded debugging in non-browser environments

With these techniques in hand, you'll debug Redux applications significantly faster and gain much deeper insight into how your state evolves over time. The combination of time-travel, action inspection, and diff views removes most of the guesswork from state-related bugs.

---

---

<div class="mastery-cta">

I'm a solo developer in Vietnam. 50K Chrome extension users. $500K+ on Upwork. 5 Claude Max subscriptions running agent fleets in parallel.

These are my actual CLAUDE.md templates, orchestration configs, and prompts. Not a course. Not theory. The files I copy into every project before I write a line of code.

**[See what's inside →](https://zovo.one/lifetime?utm_source=ccg&utm_medium=cta-default&utm_campaign=redux-devtools-chrome-tutorial)**

$99 once. Free forever. 47/500 founding spots left.

</div>

Related Reading

- [AI Citation Generator Chrome: A Developer Guide](/ai-citation-generator-chrome/)
- [AI Color Picker Chrome Extension: A Developer's Guide](/ai-color-picker-chrome-extension/)
- [AI Competitive Analysis Chrome Extension: A Developer's Guide](/ai-competitive-analysis-chrome-extension/)

Built by theluckystrike. More at [zovo.one](https://zovo.one)


