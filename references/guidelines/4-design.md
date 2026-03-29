# App Store Review Guidelines — Section 4: Design

Source: https://developer.apple.com/app-store/review/guidelines/#design

## 4.1 Copycats

Apps must offer genuine value and not simply replicate another app's functionality to profit from its success.

> "Don't simply copy the latest, most popular apps on the App Store and then make cosmetic changes to the name or UI."

Cloning a competitor's app with minor visual differences is grounds for rejection. Apps that imitate or impersonate other apps, developers, or companies will be rejected.

## 4.2 Minimum Functionality

Apps must provide a meaningful, lasting user experience beyond what a website offers.

> "Your app should include features, content, and UI that elevate it beyond a repackaged website."

Apps that are thin wrappers around a website (WebViews without native functionality), apps that only display static information, or apps that provide no lasting utility will be rejected. The app must be "app-like" — using native capabilities, not just rendering a URL.

## 4.3 Spam

Apple actively combats App Store spam:

- Do not submit multiple Bundle IDs of the same app. Submit one app and use in-app purchases to offer variations.
- Do not create multiple accounts to submit copies of the same app.
- Do not flood the App Store with minor template-based variations of the same app.

Repeated submissions of near-identical apps from the same developer will result in rejection and may trigger account-level action.

## 4.5 Apple Sites and Services

### 4.5.5 Push Notifications

> "Push notifications must not be used for advertising, promotions, or direct marketing purposes."

Push notifications are a trust-sensitive feature. Misuse is one of the most common post-approval rejection and removal triggers:

**Prohibited uses:**
- Sending promotional or advertising content (sales, discounts, offers) without a separate explicit opt-in for marketing communications
- Displaying ads inside notification payloads
- Requesting push permission before the user has any context for why notifications would be valuable

**Required implementation:**
- Push permission must be requested in context — at the moment when a notification-driven feature is first encountered, not at app launch
- Apps must implement `UNUserNotificationCenterDelegate` to handle notification taps — unhandled taps signal a broken implementation
- The `aps-environment` entitlement must be present in the app's `.entitlements` file

**Recommended pattern:** Show a pre-permission screen explaining what notifications will be used for (order updates, reminders, etc.) before triggering the system permission dialog. This demonstrates context to reviewers and improves user opt-in rates.

## 4.8 Sign in with Apple

If an app offers third-party login (e.g., Sign in with Facebook, Sign in with Google, Twitter login), it **must** also offer Sign in with Apple as an equivalent option.

> "Apps that use a third-party or social login service... must also offer Sign in with Apple as an equivalent option."

This requirement applies when login is optional or required. Sign in with Apple must be presented with equal or greater prominence compared to other login options. Failure to include Sign in with Apple when any other third-party login is offered will result in rejection.
