---

layout: default
title: "Building a Mobile App with Claude Code and Expo"
description: "A practical guide to building React Native mobile applications using Claude Code AI assistant and Expo. Includes project setup, component development, and deployment workflow."
date: 2026-03-14
categories: [tutorials]
tags: [claude-code, expo, react-native, mobile-development, ai-assisted-development, claude-skills]
author: "Claude Skills Guide"
permalink: /building-a-mobile-app-with-claude-code-and-expo/
reviewed: true
score: 7
---


# Building a Mobile App with Claude Code and Expo

Creating mobile applications has become increasingly accessible thanks to modern tooling. Combining Claude Code with Expo provides a powerful workflow for developers who want AI-assisted development without sacrificing native performance or developer experience.

## Prerequisites and Project Setup

Before starting, ensure you have Node.js 18+ installed, along with the Expo CLI. Initialize your project using the standard Expo workflow:

```bash
npx create-expo-app my-mobile-app
cd my-mobile-app
```

Once your project exists, you can invoke Claude Code and work with it directly. The workflow differs slightly from web development because Expo handles the native compilation layer, but Claude Code can still assist with every aspect of your React Native code.

## Project Structure and Initial Configuration

Expo projects follow a predictable structure. Your main entry point is `App.js` (or `App.tsx` if using TypeScript). Configure your `app.json` for proper metadata:

```json
{
  "expo": {
    "name": "My Mobile App",
    "slug": "my-mobile-app",
    "version": "1.0.0",
    "orientation": "portrait",
    "icon": "./assets/icon.png",
    "splash": {
      "image": "./assets/splash.png",
      "resizeMode": "contain"
    }
  }
}
```

When you need to add dependencies, Claude Code can help identify compatible packages. For navigation, use `expo-router` or `@react-navigation/native`. For state management, consider `zustand` or React Context depending on your complexity requirements.

## Building Your First Screen

Create a simple home screen to understand the component patterns. Expo uses React Native primitives, so you'll work with `View`, `Text`, `TouchableOpacity`, and `StyleSheet`:

```javascript
import React from 'react';
import { View, Text, StyleSheet, TouchableOpacity } from 'react-native';

export default function HomeScreen({ navigation }) {
  return (
    <View style={styles.container}>
      <Text style={styles.title}>Welcome</Text>
      <TouchableOpacity 
        style={styles.button}
        onPress={() => navigation.navigate('Details')}
      >
        <Text style={styles.buttonText}>View Details</Text>
      </TouchableOpacity>
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    backgroundColor: '#f5f5f5'
  },
  title: {
    fontSize: 24,
    fontWeight: 'bold',
    marginBottom: 20
  },
  button: {
    backgroundColor: '#007AFF',
    paddingHorizontal: 20,
    paddingVertical: 12,
    borderRadius: 8
  },
  buttonText: {
    color: '#fff',
    fontSize: 16
  }
});
```

This pattern scales to more complex screens. For styling consistency across your app, consider creating a theme file with your color palette and typography values, then import those values throughout your components.

## Implementing Navigation

For multi-screen applications, install `@react-navigation/native` and its dependencies:

```bash
npx expo install @react-navigation/native @react-navigation/native-stack react-native-screens react-native-safe-area-context
```

Set up your navigation container in your entry file:

```javascript
import { NavigationContainer } from '@react-navigation/native';
import { createNativeStackNavigator } from '@react-navigation/native-stack';
import HomeScreen from './screens/HomeScreen';
import DetailsScreen from './screens/DetailsScreen';

const Stack = createNativeStackNavigator();

export default function App() {
  return (
    <NavigationContainer>
      <Stack.Navigator>
        <Stack.Screen name="Home" component={HomeScreen} />
        <Stack.Screen name="Details" component={DetailsScreen} />
      </Stack.Navigator>
    </NavigationContainer>
  );
}
```

Claude Code can generate complete navigation structures based on your requirements. Describe your screen hierarchy and ask for the boilerplate to be created.

## State Management Patterns

For simpler apps, React's built-in `useState` and `useContext` work well. As your app grows, consider Zustand for a minimal but powerful state solution:

```javascript
import { create } from 'zustand';

const useStore = create((set) => ({
  user: null,
  isAuthenticated: false,
  setUser: (user) => set({ user, isAuthenticated: !!user }),
  logout: () => set({ user: null, isAuthenticated: false })
}));

// Usage in a component
function ProfileScreen() {
  const { user, logout } = useStore();
  // ...
}
```

This avoids the complexity of Redux while providing centralized state access across your component tree.

## Leveraging Claude Skills for Mobile Development

Several Claude skills enhance mobile development workflows. The **frontend-design** skill helps generate consistent styling and component patterns. When you need to validate your implementation, the **tdd** skill can guide test creation for your components.

For documentation purposes, you might integrate the **pdf** skill to generate user manuals or export data from your app. The **supermemory** skill proves valuable for maintaining context across long development sessions, especially when working on larger feature sets.

## Testing Your Application

Run your app in development mode:

```bash
npx expo start
```

This launches the Metro bundler. Scan the QR code with the Expo Go app on your physical device, or press 'a' for Android emulator or 'i' for iOS simulator. Hot reloading enables rapid iteration on your UI and logic.

For component testing, `@testing-library/react-native` provides utilities matching the web testing-library philosophy. Write tests like:

```javascript
import { render, fireEvent } from '@testing-library/react-native';
import HomeScreen from '../screens/HomeScreen';

test('button navigation works', () => {
  const navigation = { navigate: jest.fn() };
  const { getByText } = render(
    <HomeScreen navigation={navigation} />
  );
  
  fireEvent.press(getByText('View Details'));
  expect(navigation.navigate).toHaveBeenCalledWith('Details');
});
```

## Building for Production

When ready to deploy, generate native projects using `npx expo prebuild`. This creates the `ios` and `android` directories required for platform-specific builds:

```bash
npx expo prebuild --clean
```

For iOS, you'll need to configure signing in Xcode or via the Apple Developer portal. Build with:

```bash
eas build -p ios --profile production
```

For Android, create a keystore and configure your `app.json` with the appropriate keys, then build using EAS or locally with `cd android && ./gradlew assembleRelease`.

## Summary

Building mobile apps with Claude Code and Expo combines the productivity of AI-assisted development with the cross-platform capabilities of React Native. The workflow involves initializing your project, creating component-based UIs, managing navigation and state, and deploying through Expo's build system.

The key advantages include rapid prototyping through hot reloading, a unified codebase for iOS and Android, and AI assistance throughout the development process. As you advance, explore platform-specific modules through Expo's ecosystem of libraries, and consider integrating additional Claude skills to streamline documentation, testing, and memory management across your project.

Built by theluckystrike — More at [zovo.one](https://zovo.one)
