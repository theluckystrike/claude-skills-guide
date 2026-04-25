---
title: "CLAUDE.md Example for React Native +"
description: "Complete 300-line CLAUDE.md for React Native 0.76 with Expo SDK 52. Covers Expo Router, EAS Build, Reanimated, and native module patterns."
permalink: /claude-md-example-for-react-native-expo/
render_with_liquid: false
categories: [claude-md, templates, 2026]
tags: [claude-code, claude-md, react-native, expo]
last_updated: 2026-04-19
---

## What This Template Does

This CLAUDE.md configures Claude Code for React Native 0.76 applications using Expo SDK 52, Expo Router for file-based navigation, and EAS Build for cloud compilation. It prevents Claude from using React Navigation stack navigator patterns when Expo Router is configured, enforces proper native module handling through Expo modules, and ensures Reanimated animations run on the UI thread. The template covers EAS Build profiles, platform-specific code patterns, and Detox testing conventions. Tested against production apps on iOS and Android with 40+ screens and offline-first data sync.

## The Complete Template

{% raw %}
```markdown
# CLAUDE.md — React Native 0.76 + Expo SDK 52

## Project Stack

- React Native 0.76.6 (New Architecture enabled)
- Expo SDK 52.0.23
- TypeScript 5.6.3 (strict mode)
- Expo Router 4.0.17 (file-based routing)
- React 19.0.0
- Tanstack Query 5.62.0 (server state)
- Zustand 5.0.3 (client state)
- React Native Reanimated 3.16.6 (animations)
- Expo SecureStore 14.0.1 (secure storage)
- Expo SQLite 15.0.6 (local database)
- React Hook Form 7.54.2 + Zod 3.24.1
- EAS Build + EAS Submit
- pnpm 9.15.4

## Build & Dev Commands

- Start: `npx expo start` (Expo Go / dev client)
- iOS: `npx expo run:ios` (native build)
- Android: `npx expo run:android`
- Test: `pnpm test` (Jest)
- Test watch: `pnpm test --watch`
- Lint: `pnpm lint` (ESLint)
- Type check: `pnpm tsc --noEmit`
- Format: `pnpm prettier --write .`
- EAS build dev: `eas build --profile development --platform all`
- EAS build preview: `eas build --profile preview --platform all`
- EAS build production: `eas build --profile production --platform all`
- EAS submit iOS: `eas submit --platform ios`
- EAS submit Android: `eas submit --platform android`
- EAS update: `eas update --branch production --message "description"`
- Prebuild: `npx expo prebuild --clean` (generate native projects)
- Doctor: `npx expo-doctor` (check for issues)

## Project Layout

```
app/
  _layout.tsx                # Root layout (providers, fonts, splash)
  (tabs)/
    _layout.tsx              # Tab bar layout
    index.tsx                # Home tab
    profile.tsx              # Profile tab
    settings.tsx             # Settings tab
  (auth)/
    _layout.tsx              # Auth flow layout (no tabs)
    login.tsx                # Login screen
    signup.tsx               # Signup screen
  users/
    [id].tsx                 # User detail (dynamic route)
  modal.tsx                  # Modal screen
  +not-found.tsx             # 404 screen
src/
  components/
    ui/                      # Design system (Button, Input, Card)
    layout/                  # Screen wrappers, SafeArea helpers
    feedback/                # Toast, Alert, Skeleton
  hooks/
    useAuth.ts               # Authentication hook
    useColorScheme.ts        # Dark/light mode
    useKeyboard.ts           # Keyboard avoidance
  lib/
    api-client.ts            # Fetch/Axios wrapper with auth
    query-keys.ts            # Tanstack Query key factory
    storage.ts               # SecureStore wrapper
    database.ts              # Expo SQLite setup
    validations.ts           # Zod schemas
  services/
    auth-service.ts          # Auth API calls
    user-service.ts          # User API calls
  stores/
    auth-store.ts            # Zustand auth state
    app-store.ts             # App-level UI state
  types/
    api.ts                   # API types
    navigation.ts            # Route parameter types
  constants/
    colors.ts                # Theme colors
    layout.ts                # Spacing, sizes
    config.ts                # App configuration
assets/
  images/                    # Static images
  fonts/                     # Custom fonts
eas.json                     # EAS Build configuration
app.json                     # Expo app configuration
```

## Architecture Rules

- Expo Router file-based routing. Every file in `app/` directory becomes a route. Layouts in `_layout.tsx`. Groups with `(groupname)`.
- No React Navigation direct usage. Expo Router wraps React Navigation internally. Use `<Link>`, `router.push()`, `router.replace()` from `expo-router`.
- Screen components in `app/` directory are thin: they compose feature components from `src/components/` and connect to hooks/stores.
- Data fetching: Tanstack Query for server state. Zustand for client-only state (auth tokens, UI preferences).
- Expo managed workflow. No direct native code modifications. Use Expo modules and config plugins for native functionality.
- New Architecture enabled: Fabric renderer, TurboModules. Use `InteractionManager.runAfterInteractions` for heavy post-mount work.
- Platform-specific code: `Platform.select({ ios: ..., android: ..., default: ... })` or `.ios.tsx` / `.android.tsx` file extensions.
- No web-specific code in mobile screens. Shared logic in `src/lib/`. Platform divergence at the component level.
- EAS Build for all builds. No local Xcode/Android Studio builds for distribution. Dev builds for debugging only.
- OTA updates via EAS Update for JavaScript-only changes. Native changes require new build.

## Coding Conventions

- TypeScript strict mode. No `any`. No `@ts-ignore`.
- Named exports for components. Default exports only for `app/` route files (Expo Router requirement).
- Component files: PascalCase (`UserCard.tsx`). Hook files: camelCase with `use` prefix (`useAuth.ts`).
- Path alias: `@/` maps to `src/`. Configure in `tsconfig.json`.
- Import order: react/react-native, expo, third-party, @/ aliases, relative.
- StyleSheet: use `StyleSheet.create()` for all styles. No inline style objects (they create new objects on every render).
- Colors/spacing from constants: `colors.primary`, `spacing.md`. No hardcoded values.
- Animated components: `Animated.View`, `Animated.Text` from Reanimated. Define `useAnimatedStyle` and `useSharedValue` in the component.
- Conditional rendering: ternary for simple conditions. Early return for complex conditions. Never render `undefined` or `false` directly in text.
- Event handlers: `handleAction` naming. `onAction` for prop callbacks passed to children.
- Async operations: async/await in hooks and services. No raw `.then()` chains.
- Error boundaries: `ErrorBoundary` component wrapping each tab/screen group.
- Gesture handling: `react-native-gesture-handler` for complex gestures. Simple `Pressable`/`TouchableOpacity` for taps.
- Keyboard avoidance: `KeyboardAvoidingView` with platform-specific behavior. `keyboardDismissMode` on scroll views.

## Error Handling

- Tanstack Query error handling: `onError` callbacks, `error` state from `useQuery`/`useMutation`.
- API errors: typed error responses. Map HTTP status codes to user-friendly messages.
- Network detection: `expo-network` NetInfo. Show offline banner when disconnected.
- Form validation: Zod schemas with React Hook Form. Field-level and form-level errors.
- Auth errors: 401 → clear tokens, redirect to login. 403 → show permission error.
- Crash reporting: Sentry React Native (`@sentry/react-native`). Configure in `_layout.tsx`.
- ErrorBoundary: wrap screen groups. Render fallback UI with retry button on uncaught errors.
- Alert.alert() for critical errors requiring user acknowledgment.
- Never swallow errors. Every catch block must display error or log to crash reporting.
- Toast notifications: `react-native-toast-message` for transient success/error messages.

## Testing Conventions

- Jest with `@testing-library/react-native`.
- Component tests: render with `render(<Component />)`. Query by role, text, or testID.
- Hook tests: `renderHook(() => useAuth())` with provider wrapper.
- API mocking: MSW for network request interception.
- Navigation tests: mock `expo-router` with `jest.mock('expo-router')`. Assert `router.push` calls.
- Snapshot tests: only for design system components. No snapshots on feature screens.
- Test file naming: `ComponentName.test.tsx` co-located with source.
- User events: `fireEvent.press`, `fireEvent.changeText`. Assert UI state changes.
- Async testing: `waitFor(() => expect(...))` for async state updates.
- Platform-specific tests: conditional test blocks with `Platform.OS` checks.
- E2E: Detox for critical user flows (login, purchase, onboarding).
- Coverage: 80% for hooks, 70% for services, 60% for components.

## Native & Platform Patterns

- Expo modules: use Expo SDK packages for native features (Camera, Location, Notifications, Haptics).
- Config plugins: `app.config.ts` with plugins array for native configuration (permissions, entitlements).
- EAS Build profiles: `development` (dev client), `preview` (internal distribution), `production` (store submission).
- App signing: EAS manages certificates and provisioning profiles. Configure in `eas.json`.
- Deep linking: configure URL scheme in `app.json`. Handle with Expo Router catch-all routes.
- Push notifications: `expo-notifications` with EAS Push service or Firebase Cloud Messaging.
- Splash screen: `expo-splash-screen` with `SplashScreen.preventAutoHideAsync()`. Hide after initial data loads.
- App icons: provide 1024x1024 source image. Expo generates all required sizes.
- Permissions: `expo-*` packages handle runtime permissions. Request with `requestPermissionsAsync()`.
- Secure storage: `expo-secure-store` for auth tokens. Never use `AsyncStorage` for sensitive data.

## Animations & Performance

- Reanimated for layout animations: `entering`, `exiting`, `layout` props on `Animated.View`.
- Shared values: `useSharedValue` for values that change on UI thread. `useAnimatedStyle` for animated styles.
- Worklets: mark animation callbacks with `'worklet'` directive. Run on UI thread, not JS thread.
- FlatList: use `keyExtractor`, `getItemLayout` (when possible), `maxToRenderPerBatch`, `windowSize`.
- Image optimization: `expo-image` (not `Image` from react-native). Supports caching, blurhash placeholders.
- Memoization: `React.memo` for list items. `useMemo` for expensive computations. `useCallback` for callbacks passed to memoized children.
- Avoid re-renders: split components receiving different update frequencies. Heavy components in `React.memo`.

## What Claude Should Never Do

- Never use React Navigation `createStackNavigator` or `createBottomTabNavigator` directly. Expo Router handles navigation via file-based routing.
- Never create native iOS/Android code files directly. Use Expo modules and config plugins.
- Never use `AsyncStorage` for sensitive data (tokens, passwords). Use `expo-secure-store`.
- Never use inline style objects. Use `StyleSheet.create()` for all styles.
- Never use `Image` from `react-native` for network images. Use `expo-image` for caching and performance.
- Never use `console.log` in production code. Use a logging service or `__DEV__` conditional logging.
- Never use `any` type in TypeScript. Define proper types for all data structures.
- Never use `window`, `document`, or browser APIs. Use React Native equivalents or Expo modules.
- Never modify files in `ios/` or `android/` directories directly. Use config plugins in `app.config.ts`.
- Never skip `EAS Build` for distribution builds. Local builds are for development debugging only.
- Never use `Animated` from `react-native`. Use `Animated` from `react-native-reanimated`.
- Never store API keys in JavaScript code. Use environment variables via `eas.json` secrets or `expo-constants`.

## Project-Specific Context

- [YOUR APP NAME] — update with your project details
- Backend: [REST API / Firebase / Supabase / Appwrite]
- Analytics: [Expo Analytics / Firebase / Amplitude / Mixpanel]
- Crash reporting: Sentry (`@sentry/react-native`)
- Push notifications: [Expo Push / Firebase Cloud Messaging]
- IAP: [expo-in-app-purchases / react-native-iap]
- Distribution: EAS Submit → [App Store Connect / Google Play Console]
- OTA updates: EAS Update for JavaScript-only changes
```
{% endraw %}

## How to Adapt This For Your Project

Start with the **Project Stack** section and match versions from your `package.json` and `app.json`. If you use bare workflow instead of managed, remove the config plugins section and add guidance for direct native code modifications. If you use Redux instead of Zustand, swap the state management patterns. The Expo Router file-based routing section is critical — if your project still uses React Navigation directly, replace the routing patterns entirely. Keep the EAS Build section regardless, as it covers the correct build and submission workflow.

## Common CLAUDE.md Mistakes in React Native + Expo Projects

1. **Not specifying Expo Router vs React Navigation.** Claude generates `createStackNavigator` and `NavigationContainer` when Expo Router handles routing through the file system. These are fundamentally different navigation paradigms that cannot be mixed.

2. **Using `AsyncStorage` for tokens.** Claude stores JWT tokens in `AsyncStorage` (unencrypted) because it is the most common example online. Specify `expo-secure-store` for any sensitive data.

3. **Using inline styles.** Claude creates inline style objects, which creates new objects on every render and bypasses React Native's style optimization. Mandate `StyleSheet.create()`.

4. **Using `react-native` `Animated` instead of Reanimated.** The built-in Animated API runs on the JavaScript thread and janks during heavy JS work. Reanimated runs on the UI thread for 60fps animations.

5. **Modifying native directories directly.** Claude edits `ios/Podfile` or `android/build.gradle` when Expo config plugins should handle native configuration. Direct edits are overwritten on next `prebuild`.

## What Claude Code Does With This

With this CLAUDE.md loaded, Claude Code generates Expo Router file-based routes instead of React Navigation stacks. Sensitive data goes to `expo-secure-store` instead of `AsyncStorage`. Animations use Reanimated with worklets running on the UI thread. All styles use `StyleSheet.create()`. Native features use Expo modules with config plugins instead of direct native code modifications. Builds go through EAS with proper profiles for development, preview, and production.

## The Full 16-Template Pack

This is one of 16 production CLAUDE.md templates available in the Lifetime pack. Includes templates for Flutter + Dart, Android + Kotlin, iOS + SwiftUI, Next.js + TypeScript, and 11 more stacks. Each template is 200-400 lines of production-tested configuration. Get all 16 at [claudecodeguides.com/generator/](https://claudecodeguides.com/generator/).
