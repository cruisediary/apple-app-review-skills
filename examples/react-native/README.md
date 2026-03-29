# React Native Examples

> Coming soon — anti-patterns and fixes for App Store rejection in React Native apps.

## Planned Coverage

- **Layout:** Fixed pixel widths that break on iPad, missing safe area handling with `react-native-safe-area-context`
- **Permissions:** Requesting permissions at app launch in `AppRegistry`, missing `NSUsageDescription` for Expo/RN SDK-injected keys
- **Privacy:** `@react-native-firebase/analytics` without ATT prompt, account deletion in React Native settings screens
- **IAP:** Using `react-native-iap` correctly vs external payment bypass
- **UGC:** Report/block in `FlatList` rendered user content

## Contributing

If your React Native app was rejected and you have a reproducible pattern, please open an issue using the [rejection case template](../../.github/ISSUE_TEMPLATE/rejection_case.md).
