---
layout: default
title: "Claude Code Mobile Push Notifications Implementation Guide"
description: "A comprehensive guide to implementing mobile push notifications in iOS and Android apps. Learn APNs, FCM setup, token management, and best practices for reliable delivery."
date: 2026-03-14
categories: [guides]
tags: [claude-code, claude-skills]
author: "Claude Skills Guide"
permalink: /claude-code-mobile-push-notifications-implementation-guide/
---

# Claude Code Mobile Push Notifications Implementation Guide

Push notifications remain one of the most effective ways to re-engage mobile app users. Whether you're sending breaking news alerts, transaction confirmations, or personalized reminders, implementing push notifications correctly is essential for a seamless user experience. This guide walks you through the complete implementation process for both iOS and Android platforms.

## Understanding Push Notification Architecture

Before diving into code, it's important to understand how push notifications work across platforms. The architecture involves three main components:

1. **Device Token** - A unique identifier assigned to your app instance by the push service
2. **Push Notification Service** - Apple's APNs (Apple Push Notification service) for iOS or Firebase Cloud Messaging (FCM) for Android
3. **Your Backend Server** - Sends notification payloads through the push service to reach user devices

When a user installs your app, the app registers with the appropriate push service and receives a device token. Your app sends this token to your backend, which stores it associated with the user. When you want to send a notification, your server constructs a payload and sends it through APNs or FCM, which then delivers it to the specific device.

## Setting Up Apple Push Notification Service (APNs)

For iOS apps, you'll need to configure APNs through the Apple Developer Portal. Start by creating an App ID with Push Notifications capability enabled. You'll also need to create a Push Notification SSL certificate (for sandbox and production) or a authentication key for token-based authentication.

### Generating APNs Credentials

Navigate to the Apple Developer Portal, select your app ID, and enable Push Notifications. Then create either a SSL certificate (which requires renewal annually) or a token authentication key (which doesn't expire). Download the .p8 file for token authentication and note your Key ID and Team ID.

```bash
# Convert your certificate to PEM format if using certificate-based auth
openssl pkcs12 -in cert.p12 -out apns-cert.pem -nodes -clcerts
```

For token-based authentication, keep your .p8 file secure and note these values for your server configuration:
- Key ID (10-character string)
- Team ID (10-character string)
- Bundle ID
- The .p8 file path

## Setting Up Firebase Cloud Messaging (FCM)

For Android, FCM provides a unified solution across Google services. Create a Firebase project at console.firebase.google.com, add your Android app, and download the google-services.json file. Place this file in your app's app directory.

### Configuring FCM in Your Android Project

Add the required dependencies to your build.gradle files:

```gradle
// Project-level build.gradle
classpath 'com.google.gms:google-services:4.4.0'

// App-level build.gradle
implementation 'com.google.firebase:firebase-messaging:23.4.0'
apply plugin: 'com.google.gms.google-services'
```

## Implementing Client-Side Registration

### iOS Implementation with Swift

Register for push notifications in your AppDelegate or SceneDelegate:

```swift
import UserNotifications

class AppDelegate: NSObject, UIApplicationDelegate {
    
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        UNUserNotificationCenter.current().requestAuthorization(
            options: [.alert, .badge, .sound]
        ) { granted, error in
            if granted {
                DispatchQueue.main.async {
                    application.registerForRemoteNotifications()
                }
            }
        }
        return true
    }
    
    func application(
        _ application: UIApplication,
        didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
    ) {
        let tokenString = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()
        // Send tokenString to your backend server
        print("APNs Device Token: \(tokenString)")
    }
    
    func application(
        _ application: UIApplication,
        didFailToRegisterForRemoteNotificationsWithError error: Error
    ) {
        print("Failed to register: \(error.localizedDescription)")
    }
}
```

### Android Implementation with Kotlin

Create a service to handle FCM registration and incoming messages:

```kotlin
import com.google.firebase.messaging.FirebaseMessaging
import com.google.firebase.messaging.FirebaseMessagingService
import com.google.firebase.messaging.RemoteMessage

class MyFirebaseMessagingService : FirebaseMessagingService() {
    
    override fun onNewToken(token: String) {
        super.onNewToken(token)
        // Send token to your backend server
        sendTokenToServer(token)
    }
    
    override fun onMessageReceived(message: RemoteMessage) {
        super.onMessageReceived(message)
        // Handle incoming notification
        message.notification?.let { notification ->
            showNotification(notification.title, notification.body)
        }
    }
    
    private fun sendTokenToServer(token: String) {
        // API call to your backend
    }
    
    private fun showNotification(title: String?, body: String?) {
        // Display local notification
    }
}
```

Register this service in your AndroidManifest.xml:

```xml
<service
    android:name=".MyFirebaseMessagingService"
    android:exported="false">
    <intent-filter>
        <action android:name="com.google.firebase.MESSAGING_EVENT" />
    </intent-filter>
</service>
```

## Sending Notifications from Your Backend

### Node.js Example with FCM

Here's a practical server-side implementation for sending notifications:

```javascript
const admin = require('firebase-admin');
const apn = require('apn');

// Initialize FCM
admin.initializeApp({
  credential: admin.credential.cert(serviceAccount)
});

// Send to Android devices
async function sendAndroidNotification(token, title, body) {
  const message = {
    notification: { title, body },
    token: token
  };
  
  try {
    const response = await admin.messaging().send(message);
    console.log('Successfully sent message:', response);
    return { success: true, response };
  } catch (error) {
    console.error('Error sending message:', error);
    return { success: false, error: error.message };
  }
}

// Send to iOS devices
async function sendiOSNotification(token, title, body) {
  const apnProvider = new apn.Provider({
    token: {
      key: 'path/to/auth-key.p8',
      keyId: 'YOUR_KEY_ID',
      teamId: 'YOUR_TEAM_ID'
    },
    production: true // false for sandbox
  });
  
  const notification = new apn.Notification({
    alert: { title, body },
    badge: 1,
    sound: 'default'
  });
  
  const result = await apnProvider.send(notification, token);
  return result;
}
```

## Handling Notification Interactions

When users tap notifications, you need to handle deep links to navigate them to the relevant content. Store the navigation path in the notification payload:

```javascript
// Include custom data in payload
const message = {
  notification: { title: 'New Message', body: 'You have a new message' },
  data: {
    screen: 'messages',
    messageId: '12345'
  },
  apns: {
    payload: {
      aps: {
        'mutable-content': 1
      }
    }
  }
};
```

On the client side, extract this data to determine navigation:

```swift
// iOS - in your UNUserNotificationCenter delegate
func userNotificationCenter(
    _ center: UNUserNotificationCenter,
    didReceive response: UNNotificationResponse,
    withCompletionHandler completionHandler: @escaping () -> Void
) {
    let userInfo = response.notification.request.content.userInfo
    
    if let screen = userInfo["screen"] as? String,
       let messageId = userInfo["messageId"] as? String {
        // Navigate to the specified screen
        navigateToScreen(screen: screen, messageId: messageId)
    }
    
    completionHandler()
}
```

## Best Practices for Reliable Delivery

Implementing push notifications is only half the battle. Ensuring reliable delivery requires attention to several operational concerns:

**Token Management**: Device tokens can change when users reinstall the app, update iOS, or clear app data. Implement token refresh handling on both client and server. Store tokens with user IDs and update them whenever you receive a new token.

**Opt-In and Permissions**: Request notification permissions at appropriate moments—typically after the user has experienced some value in your app. Explain why notifications benefit them before prompting.

**Rate Limiting**: Both Apple and FCM impose rate limits. Design your notification strategy to batch messages when possible, and handle rejection gracefully.

**Testing**: Use sandbox environments for iOS (APNs sandbox) and Android (FCM testing) before production. Test edge cases like airplane mode, Do Not Disturb, and low battery scenarios.

## Conclusion

Push notifications remain a powerful tool for mobile engagement when implemented thoughtfully. The key takeaways are: properly configure your APNs and FCM credentials, handle device tokens robustly on your backend, implement proper notification interaction handling, and respect user permissions and preferences. With this foundation in place, you can build engaging notification experiences that bring users back to your app at the right moments.
