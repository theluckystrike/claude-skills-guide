---
layout: post
title: "Claude Code for React Native"
description: "Use Claude Code for React Native: component generation, navigation setup, native module bridging, and cross-platform testing workflows."
permalink: /claude-code-react-native-development-2026/
date: 2026-04-21
last_tested: "2026-04-21"
render_with_liquid: false
---
{% raw %}

## The Workflow

Use Claude Code to accelerate React Native mobile development: generate cross-platform components, configure navigation stacks, handle platform-specific code, and write tests. Covers both Expo and bare React Native workflows.

Expected time: 10 minutes setup
Prerequisites: React Native CLI or Expo CLI, Claude Code installed, Node.js 18+

## Setup

### 1. Initialize Project with Claude Code Context

```bash
# For Expo projects
npx create-expo-app@latest my-app --template blank-typescript
cd my-app

# For bare React Native
npx @react-native-community/cli init MyApp --template react-native-template-typescript
cd MyApp
```

### 2. Create CLAUDE.md for React Native

```markdown
# Project: MyApp (React Native)

Expo SDK 52, React Native 0.76, TypeScript strict mode.

## Stack
- Navigation: React Navigation v7 (native stack)
- State: Zustand + React Query (TanStack Query v5)
- Styling: NativeWind v4 (Tailwind for RN)
- Forms: React Hook Form + Zod
- Testing: Jest + React Native Testing Library

## Conventions
- Components: src/components/ (one file per component)
- Screens: src/screens/ (screen components only)
- Hooks: src/hooks/ (custom hooks)
- Platform-specific: use .ios.tsx / .android.tsx suffixes
- All components must have displayName for debugging
- Use SafeAreaView wrapper on all screens
- Minimum touch target: 44x44 points
```

### 3. Verify

```bash
claude --print "List the screens in src/screens/ and describe the navigation structure"
# Expected output:
# Describes your app's screen files and navigation setup
```

## Usage Example

Generate a complete authentication flow with Claude Code:

```bash
claude

> Create a login screen with:
> - Email and password fields with validation (React Hook Form + Zod)
> - "Remember me" toggle
> - Biometric authentication option (Face ID / fingerprint)
> - Loading state during authentication
> - Error display for invalid credentials
> - Use NativeWind for styling
> - Platform-specific biometric handling
```

Claude Code generates:

```typescript
// src/screens/LoginScreen.tsx
import { useState } from "react";
import {
  View,
  Text,
  TextInput,
  TouchableOpacity,
  ActivityIndicator,
  Platform,
  Alert,
  KeyboardAvoidingView,
} from "react-native";
import { SafeAreaView } from "react-native-safe-area-context";
import { useForm, Controller } from "react-hook-form";
import { zodResolver } from "@hookform/resolvers/zod";
import { z } from "zod";
import * as LocalAuthentication from "expo-local-authentication";
import { useAuthStore } from "@/stores/auth";

const loginSchema = z.object({
  email: z.string().email("Please enter a valid email"),
  password: z.string().min(8, "Password must be at least 8 characters"),
  rememberMe: z.boolean().default(false),
});

type LoginFormData = z.infer<typeof loginSchema>;

export function LoginScreen() {
  const [isLoading, setIsLoading] = useState(false);
  const [biometricAvailable, setBiometricAvailable] = useState(false);
  const login = useAuthStore((state) => state.login);

  const {
    control,
    handleSubmit,
    formState: { errors },
  } = useForm<LoginFormData>({
    resolver: zodResolver(loginSchema),
    defaultValues: { email: "", password: "", rememberMe: false },
  });

  const onSubmit = async (data: LoginFormData) => {
    setIsLoading(true);
    try {
      await login(data.email, data.password, data.rememberMe);
    } catch (error) {
      Alert.alert("Login Failed", "Invalid email or password.");
    } finally {
      setIsLoading(false);
    }
  };

  const handleBiometric = async () => {
    const result = await LocalAuthentication.authenticateAsync({
      promptMessage: "Authenticate to log in",
      cancelLabel: "Cancel",
      disableDeviceFallback: false,
    });
    if (result.success) {
      await login("biometric", "", false);
    }
  };

  return (
    <SafeAreaView className="flex-1 bg-white">
      <KeyboardAvoidingView
        behavior={Platform.OS === "ios" ? "padding" : "height"}
        className="flex-1 justify-center px-6"
      >
        <Text className="text-3xl font-bold text-center mb-8">
          Welcome Back
        </Text>

        <Controller
          control={control}
          name="email"
          render={({ field: { onChange, onBlur, value } }) => (
            <View className="mb-4">
              <TextInput
                className="border border-gray-300 rounded-xl px-4 py-3 text-base"
                placeholder="Email"
                keyboardType="email-address"
                autoCapitalize="none"
                autoComplete="email"
                onChangeText={onChange}
                onBlur={onBlur}
                value={value}
              />
              {errors.email && (
                <Text className="text-red-500 text-sm mt-1">
                  {errors.email.message}
                </Text>
              )}
            </View>
          )}
        />

        <Controller
          control={control}
          name="password"
          render={({ field: { onChange, onBlur, value } }) => (
            <View className="mb-4">
              <TextInput
                className="border border-gray-300 rounded-xl px-4 py-3 text-base"
                placeholder="Password"
                secureTextEntry
                autoComplete="password"
                onChangeText={onChange}
                onBlur={onBlur}
                value={value}
              />
              {errors.password && (
                <Text className="text-red-500 text-sm mt-1">
                  {errors.password.message}
                </Text>
              )}
            </View>
          )}
        />

        <TouchableOpacity
          onPress={handleSubmit(onSubmit)}
          disabled={isLoading}
          className="bg-blue-600 rounded-xl py-4 items-center mb-4"
          style={{ minHeight: 48 }}
        >
          {isLoading ? (
            <ActivityIndicator color="white" />
          ) : (
            <Text className="text-white font-semibold text-base">Log In</Text>
          )}
        </TouchableOpacity>

        {biometricAvailable && (
          <TouchableOpacity
            onPress={handleBiometric}
            className="border border-blue-600 rounded-xl py-4 items-center"
            style={{ minHeight: 48 }}
          >
            <Text className="text-blue-600 font-semibold text-base">
              {Platform.OS === "ios" ? "Sign in with Face ID" : "Sign in with Fingerprint"}
            </Text>
          </TouchableOpacity>
        )}
      </KeyboardAvoidingView>
    </SafeAreaView>
  );
}

LoginScreen.displayName = "LoginScreen";
```

Generate the matching test:

```bash
> Write a test for LoginScreen covering form validation, submission,
> and biometric fallback
```

```typescript
// src/screens/__tests__/LoginScreen.test.tsx
import { render, fireEvent, waitFor } from "@testing-library/react-native";
import { LoginScreen } from "../LoginScreen";

jest.mock("expo-local-authentication", () => ({
  authenticateAsync: jest.fn().mockResolvedValue({ success: true }),
  hasHardwareAsync: jest.fn().mockResolvedValue(true),
  isEnrolledAsync: jest.fn().mockResolvedValue(true),
}));

describe("LoginScreen", () => {
  it("shows validation errors for empty fields", async () => {
    const { getByText } = render(<LoginScreen />);
    fireEvent.press(getByText("Log In"));

    await waitFor(() => {
      expect(getByText("Please enter a valid email")).toBeTruthy();
    });
  });

  it("calls login on valid submission", async () => {
    const { getByPlaceholderText, getByText } = render(<LoginScreen />);

    fireEvent.changeText(getByPlaceholderText("Email"), "test@example.com");
    fireEvent.changeText(getByPlaceholderText("Password"), "password123");
    fireEvent.press(getByText("Log In"));

    await waitFor(() => {
      expect(getByText("Log In")).toBeTruthy();
    });
  });
});
```

## Common Issues

- **NativeWind classes not applying:** Ensure `nativewind/babel` is in your `babel.config.js` plugins and restart Metro bundler with cache clear: `npx expo start -c`.
- **Platform-specific code not picked up:** Use `.ios.tsx` and `.android.tsx` suffixes, not conditional imports. Claude Code handles this when instructed in CLAUDE.md.
- **Expo modules not available in bare RN:** Tell Claude Code which environment you use in CLAUDE.md. Expo modules require `expo install`, bare RN uses `npm install` with native linking.

## Why This Matters

React Native projects have significant boilerplate per screen. Claude Code generates a production-ready screen with validation, error handling, and tests in under 3 minutes instead of the typical 30-minute manual effort.

## Related Guides

- [Claude Code for React Native Navigation Setup Guide](/claude-code-for-react-native-navigation-setup-guide/)
- [Claude Code for React Native Push Notifications Guide](/claude-code-for-react-native-push-notifications-guide/)
- [How to Create React Components Faster with Claude Code](/how-to-create-react-components-faster-with-claude-code/)
{% endraw %}

## See Also

- [Claude Code for ESP32 Firmware with ESP-IDF (2026)](/claude-code-esp32-firmware-development-2026/)
- [Claude Code for Godot GDScript Development (2026)](/claude-code-godot-gdscript-development-2026/)
- [Claude Code for VBA Macro Development 2026](/claude-code-vba-macro-development-2026/)
