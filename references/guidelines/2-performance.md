# App Store Review Guidelines — Section 2: Performance

Source: https://developer.apple.com/app-store/review/guidelines/#performance

## 2.1 App Completeness

Apps submitted for review must be final versions. Common rejection reasons:

- Placeholder or "lorem ipsum" content present in the build
- App has not been tested on a device (only simulator)
- Backend services are not enabled/accessible during review
- App requires a demo account but no credentials were provided in App Review Notes
- Features are locked behind login without providing reviewer access

> "Submissions to App Review, including apps you make available for pre-order, should be final versions ready for release to the App Store."

Reviewers must be able to fully exercise the app's features. Include demo accounts and all necessary access in the App Review Information section.

## 2.3 Accurate Metadata

### 2.3.1 Metadata Accuracy

All app metadata — name, description, screenshots, previews — must accurately represent the app. Do not include features or content that the app does not currently offer.

### 2.3.3 Screenshots

> "Screenshots should show the app in use, and not merely title art, login screens, or splash screens."

Screenshots must depict actual app functionality. Marketing-only imagery, splash screens, or login-only screenshots will trigger rejection. Must represent all supported devices where required.

### 2.3.6 Age Ratings

The age rating must accurately reflect the app's content. Selecting an inaccurate rating to broaden reach is a violation. Apps with user-generated content, mature themes, gambling, or infrequent/mild content must set the appropriate rating level.

### 2.3.7 App Name

- Maximum **30 characters**
- Must not include pricing information
- Must not include terms that are not the app's name (e.g., "best," "free," "#1")
- Must not include trademarked terms the developer does not own
- Keywords in the name field must be accurate and relevant

### 2.3.10 Non-iOS Platform References

App Store metadata and app content must not reference Android, Windows, or any non-Apple platform.

> "Make sure your app description, screenshots, and previews do not include images or text that reference Android, Windows, or another competing platform."

Any mention of "Android," "Google Play," "Windows," competitor device names, or Android-style UI elements in screenshots or app description is a guaranteed rejection.

## 2.4 Hardware Compatibility

### 2.4.1 iPhone Apps on iPad

> "iPhone apps should work on Apple Silicon Macs and should also be available on iPad unless you specifically exclude it."

Apps should run on iPad natively whenever possible. If an iPhone-only app does not support iPad, this must be intentional and justified. Layouts must adapt properly — fixed iPhone-sized frames on iPad are grounds for rejection.

## 2.5 Software Requirements

Apps must be built with the current public SDK and must target a supported OS version. Apps cannot use private APIs, deprecated frameworks, or APIs in ways inconsistent with their intended purpose.
