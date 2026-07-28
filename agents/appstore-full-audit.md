---
name: appstore-full-audit
description: Runs all 31 App Store review skills in a single pass against an iOS/macOS project and produces a prioritized rejection risk report. Use for a full pre-submission check, or when a change touches multiple areas (layout, permissions, privacy, UGC, quality, business/IAP, metadata).
tools: Glob, Grep, Read, Bash, Write
model: sonnet
---

# App Store Full Audit Agent

## Purpose
Run all 31 App Store review skills in a single pass, collect shared project context once, and produce a prioritized rejection risk report saved to `docs/appstore-audit/YYYY-MM-DD-audit.md`.

## Skills Used
- `skills/layout/ipad-layout-audit.md` — iPad size class, split view, text truncation
- `skills/layout/safe-area-compliance.md` — Dynamic Island, notch, home indicator insets
- `skills/layout/dynamic-type-support.md` — UIFontMetrics, fixed-height text containers
- `skills/layout/orientation-support.md` — Portrait/landscape on iPad
- `skills/permissions/usage-description-audit.md` — NS*UsageDescription completeness
- `skills/permissions/request-timing-audit.md` — Permissions at launch detection
- `skills/permissions/permission-scope-audit.md` — Always vs WhenInUse, full access vs picker
- `skills/ugc/ugc-safety-features.md` — Report/block on feeds and profiles
- `skills/ugc/content-moderation-api.md` — Moderation service integration
- `skills/privacy/privacy-policy-check.md` — Privacy policy URL and in-app presence
- `skills/privacy/privacy-manifest-check.md` — PrivacyInfo.xcprivacy required API reasons
- `skills/privacy/att-framework-audit.md` — ATT before analytics SDKs
- `skills/privacy/account-deletion-check.md` — True deletion vs deactivation-only
- `skills/privacy/data-minimization-audit.md` — Minimal data access, out-of-process pickers
- `skills/privacy/ai-data-disclosure.md` — Third-party AI SDK usage without user consent
- `skills/quality/app-completeness-check.md` — Lorem ipsum, staging URLs, broken buttons
- `skills/quality/crash-risk-audit.md` — Force unwrap, force cast, background thread UI
- `skills/quality/review-readiness-check.md` — Version name, demo account, backend reachable
- `skills/quality/sdk-version-check.md` — Deprecated APIs, UIWebView, deployment target
- `skills/quality/push-notification-audit.md` — Push permission timing, marketing push, broken delegate
- `skills/quality/review-request-audit.md` — SKStoreReviewController abuse, review gating
- `skills/quality/private-api-audit.md` — dlopen, NSClassFromString private classes, method swizzling
- `skills/quality/background-execution-audit.md` — Silent audio abuse, location background misuse, VoIP mode
- `skills/business/iap-compliance.md` — StoreKit usage, no IAP bypass
- `skills/business/subscription-disclosure.md` — Auto-renewal, trial, price prominence
- `skills/business/loot-box-disclosure.md` — Odds table for randomized rewards
- `skills/business/sign-in-with-apple.md` — Sign in with Apple when third-party auth present
- `skills/metadata/screenshot-guidelines.md` — Real UI in screenshots
- `skills/metadata/age-rating-accuracy.md` — Rating matches actual content
- `skills/metadata/app-name-compliance.md` — Name length, no "beta", trademarks
- `skills/metadata/metadata-accuracy.md` — Description matches implemented features

## Phase 1: Collect Shared Context (Read-Only)

Collect all project files once so all 25 skills share the same context without re-reading files.

1. Use `Glob` to find `**/*.xcodeproj` or `**/*.xcworkspace` — identify project name and structure
2. Use `Glob` to find `**/Info.plist` — read with `Read`
3. Use `Glob` to find `**/*.swift` — collect all Swift source files (store paths for Phase 2 use)
4. Use `Glob` to find `**/project.pbxproj` — read build settings section
5. Use `Glob` to find `**/PrivacyInfo.xcprivacy` — note presence/absence
6. Use `Bash` to run: `! plutil -p <path-to-Info.plist>` — extract bundle ID, version, iOS deployment target
7. Store as `shared_context`:
   - `app_name`, `bundle_id`, `ios_version`, `xcode_version`
   - `info_plist_path`, `info_plist_contents`
   - `swift_file_paths` (all .swift files)
   - `privacy_manifest_path` (or null)
   - `pbxproj_path`

## Phase 2: Audit — Run All 25 Skills (Read-Only, No File Edits)

Run all 31 skills using `shared_context`. For each skill, perform its Phase 2 checks directly (skip Phase 1 context collection since data is already gathered).

**Layout (4 skills)**
- Check all .swift files for hardcoded widths (375, 390, 414), `edgesIgnoringSafeArea(.all)` on content views, `UIFont.systemFont(ofSize:)` without `UIFontMetrics`, fixed `.frame(height:)` on text, missing iPad `userInterfaceIdiom` handling
- Check Info.plist for `UISupportedInterfaceOrientations~ipad` — must include landscape keys

**Permissions (3 skills)**
- Check Info.plist for all required `NS*UsageDescription` keys
- Use `Grep` on all .swift files for permission requests in `applicationDidFinishLaunching`, `viewDidLoad` of root controller, or `init`
- Check for `requestAlwaysAuthorization()` when `requestWhenInUseAuthorization()` suffices
- Check for `PHPhotoLibrary.requestAuthorization` instead of `PHPickerViewController`

**UGC (2 skills)**
- Use `Grep` to find `tableView`, `collectionView`, `List`, `ForEach` rendering user content
- Use `Grep` for report/block action patterns near those views
- Check onboarding/signup flow for EULA or Terms acceptance

**Privacy (6 skills)**
- Search for `privacyPolicyURL`, `privacy`, `policy` links in views
- Check `PrivacyInfo.xcprivacy` for required API reason codes (CA92.1, DDA9.1, 3EC4.1, 35F9.1)
- Use `Grep` for `ATTrackingManager` and analytics SDK imports
- Use `Grep` for "Delete Account" vs "Deactivate" in settings views
- Check for full `CNContactStore` / `PHPhotoLibrary` access vs pickers
- Use `Grep` for OpenAI/Gemini/Anthropic SDK imports and API endpoints — if found, verify consent modal exists before API call

**Quality (9 skills)**
- Use `Grep` for `Lorem ipsum`, `Coming Soon`, `TODO`, staging/localhost URLs
- Use `Grep` for `!` force unwrap, `as!` force cast, `try!`, `DispatchQueue.main` absence in UI updates from background
- Check bundle version — flag if `CFBundleShortVersionString` starts with `0.` or contains "beta"/"alpha"
- Use `Grep` for `UIWebView` (ITMS-90809), `UIAlertView`, `UIActionSheet` — deprecated/removed APIs
- Use `Grep` for `requestAuthorization` in AppDelegate/SceneDelegate — push permission at launch
- Use `Grep` for `requestReview` in Button actions or satisfaction gate patterns
- Use `Grep` for `dlopen`, `NSClassFromString` with `_UI`/`_NS` prefix, `method_exchangeImplementations`
- Read Info.plist `UIBackgroundModes` — check for `audio`/`voip`/`location` with silent abuse patterns
- Check `IPHONEOS_DEPLOYMENT_TARGET` in pbxproj — flag if 13 or below

**Business (4 skills)**
- Use `Grep` for Stripe, PayPal, Braintree, WebView payment patterns
- Use `Grep` for subscription price/renewal disclosure in paywall views
- Use `Grep` for loot box / gacha / random reward patterns with odds disclosure
- Use `Grep` for `GoogleSignIn`, `GIDSignIn`, `FBSDKLoginKit`, `OAuthProvider` — if found, verify `ASAuthorizationAppleIDProvider` and `ASAuthorizationAppleIDButton` are also present (Guideline 4.8)

**Metadata (4 skills)**
- Use `Glob` to check for screenshot assets in `*.xcassets`
- Use `Grep` for Android references in any file
- Check `CFBundleDisplayName` length (≤30 chars) and content
- Cross-check description keywords against actual code features

## Phase 3: Report & Save

1. Aggregate all findings from Phase 2
2. Sort by priority: 🔴 CRITICAL first, then 🟠 HIGH, 🟡 MEDIUM, 🟢 LOW
3. Run: `! mkdir -p docs/appstore-audit`
4. Save report to `docs/appstore-audit/YYYY-MM-DD-audit.md` using today's date
5. Print the full report to the terminal

## Report Format

```
# App Store Audit — YYYY-MM-DD
Project: <AppName> (<bundle.id>) · iOS X+ · Xcode X

## 🔴 CRITICAL — Reject almost certain
- [ ] TODO: <exact actionable step> — `file:line` — Guideline X.X

## 🟠 HIGH — Very likely rejection
- [ ] TODO: <exact actionable step> — Guideline X.X

## 🟡 MEDIUM — Possible rejection
- [ ] TODO: <exact actionable step>

## 🟢 LOW — Best practice
- [ ] TODO: <exact actionable step>

---
Total: N findings · 🔴 N · 🟠 N · 🟡 N · 🟢 N
Saved: docs/appstore-audit/YYYY-MM-DD-audit.md
```

## Usage

```
/appstore-full-audit
```

Run before every App Store submission. Expected runtime: 2–5 minutes depending on project size.

## Constraints
- **Read-only:** This agent never edits source files
- **No guessing:** Only report findings confirmed by code evidence
- **Exact file:line references** for every finding where possible
- Every finding must reference the Apple Guideline number (e.g., `Guideline 2.4.1`)
- `mkdir -p docs/appstore-audit/` must run before writing the report
