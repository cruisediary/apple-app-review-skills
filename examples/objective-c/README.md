# Objective-C Examples

> Coming soon — anti-patterns and fixes for App Store rejection in Objective-C apps.

## Planned Coverage

- **Layout:** `[[UIScreen mainScreen] bounds].size.width` hardcoded comparisons, missing `safeAreaInsets` usage
- **Permissions:** Permission requests in `application:didFinishLaunchingWithOptions:`, missing `NS*UsageDescription` keys
- **Privacy:** `[[NSUserDefaults standardUserDefaults] setObject:forKey:]` without `PrivacyInfo.xcprivacy`
- **Crash Risk:** `NSArray` / `NSDictionary` unsafe access without bounds checking, force casting with `(ClassName *)` without type checks
- **IAP:** `SKPaymentQueue` usage patterns and external payment bypass via `UIWebView`

## Contributing

If your Objective-C app was rejected and you have a reproducible pattern, please open an issue using the [rejection case template](../../.github/ISSUE_TEMPLATE/rejection_case.md).
