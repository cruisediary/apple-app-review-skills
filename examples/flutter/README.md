# Flutter Examples

> Coming soon — anti-patterns and fixes for App Store rejection in Flutter apps.

## Planned Coverage

- **Layout:** `MediaQuery.of(context).size.width` hardcoded breakpoints that break on iPad, missing `SafeArea` widget
- **Permissions:** `permission_handler` package requesting permissions in `main()` before context is clear
- **Privacy:** `firebase_analytics` without ATT prompt on iOS, account deletion in Flutter settings
- **IAP:** `in_app_purchase` package usage vs external payment bypass
- **Metadata:** Flutter-generated screenshots showing debug banners or simulator chrome

## Contributing

If your Flutter app was rejected and you have a reproducible pattern, please open an issue using the [rejection case template](../../.github/ISSUE_TEMPLATE/rejection_case.md).
