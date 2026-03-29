# Privacy Audit Agent

## Purpose
Audit an iOS/macOS app for privacy-related App Store rejection risks: missing privacy policy, absent PrivacyInfo.xcprivacy manifest, ATT missing before tracking, no account deletion option, and excessive data collection — covering Guidelines 5.1.1 and 5.1.2.

## Skills Used
- `skills/privacy/privacy-policy-check.md` — privacy policy URL resolves and is linked in-app
- `skills/privacy/privacy-manifest-check.md` — PrivacyInfo.xcprivacy with required reason API codes
- `skills/privacy/att-framework-audit.md` — ATTrackingManager before any analytics/tracking SDK
- `skills/privacy/account-deletion-check.md` — in-app account deletion (not just deactivation)
- `skills/privacy/data-minimization-audit.md` — only necessary data collected, pickers over full access

## Phase 1: Analysis (Read-Only)

1. Use `Glob` to find `**/Info.plist` — read with `Read`
2. Use `Glob` to find `**/PrivacyInfo.xcprivacy` — note if present or absent
3. Use `Glob` to find `**/*.swift` — collect all Swift source files
4. Use `Glob` to find `**/Podfile` or `**/Package.resolved` — identify third-party SDKs
5. Use `Bash`: `! grep -r "NSPrivacyTracking\|NSPrivacyAccessedAPITypes" <PrivacyInfo.xcprivacy path>` — if file exists
6. Use `Grep` to find analytics/tracking SDKs: `Firebase`, `Amplitude`, `Mixpanel`, `Segment`, `Braze`, `Adjust`, `AppsFlyer`, `FacebookCore`, `GoogleAnalytics`

## Phase 2: Audit (Read-Only — No File Edits)

**Privacy Policy (Guideline 5.1.1(i))**
- Use `Grep` for privacy policy URL patterns: `privacyPolicyURL`, `privacy-policy`, `/privacy`, `privacy.html`
- Flag if no in-app link to privacy policy is found in settings or onboarding
- Use `Bash`: `! curl -sI <privacy-policy-url> | head -1` — verify URL returns 200 (if URL found)
- Flag if URL is not present or returns non-200

**Privacy Manifest (ITMS-91053, enforced May 1, 2024)**
- If `PrivacyInfo.xcprivacy` is absent → 🔴 CRITICAL
- If present, use `Read` to verify required API reason codes are declared for APIs found in source:

  | API Used | Required Reason Code |
  |----------|---------------------|
  | `UserDefaults` | `CA92.1` under `NSPrivacyAccessedAPICategoryUserDefaults` |
  | `NSFileSystemFreeSize` | `E174.1` under `NSPrivacyAccessedAPICategoryDiskSpace` |
  | `NSProcessInfo.systemUptime` | `35F9.1` under `NSPrivacyAccessedAPICategorySystemBootTime` |
  | `UIDevice.identifierForVendor` | `3EC4.1` under `NSPrivacyAccessedAPICategoryDeviceID` |

- Use `Grep` to find each API in source, then verify corresponding reason in manifest

**ATT Framework (Guideline 5.1.2(i))**
- If analytics SDK detected in Phase 1:
  - Use `Grep` for `ATTrackingManager.requestTrackingAuthorization` — must be present
  - Use `Grep` for analytics SDK initialization: `FirebaseApp.configure()`, `Amplitude.instance().initializeApiKey`, etc.
  - Verify ATT request appears BEFORE or in the same launch sequence as analytics initialization
  - Flag if analytics SDK is initialized in `application(_:didFinishLaunchingWithOptions:)` without ATT check
- If `NSUserTrackingUsageDescription` is absent from Info.plist but tracking SDK found → 🔴 CRITICAL

**Account Deletion (Guideline 5.1.1(v), required since June 30, 2022)**
- Use `Grep` for account deletion UI: `deleteAccount`, `delete_account`, `DeleteAccount`, `"Delete Account"`
- Use `Grep` for deactivation: `deactivateAccount`, `"Deactivate Account"`, `deactivate`
- Flag if only deactivation is present without true deletion — `Deactivate ≠ Delete`
- Flag if account management requires navigating to external website (in-app option required)
- Verify deletion: backend call to remove user data, local data cleared, signed out

**Data Minimization (Guideline 5.1.1(iii))**
- Use `Grep` for full contact access: `CNContactStore().requestAccess` → suggest `CNContactPickerViewController`
- Use `Grep` for full photo access: `PHPhotoLibrary.requestAuthorization` → suggest `PHPickerViewController`
- Use `Grep` for precise location when approximate may suffice: `kCLLocationAccuracyBest`, `kCLLocationAccuracyNearestTenMeters`
- Use `Grep` for background location: `allowsBackgroundLocationUpdates = true` — verify it's genuinely needed

## Phase 3: Report

1. Run: `! mkdir -p docs/appstore-audit`
2. Save report to `docs/appstore-audit/YYYY-MM-DD-privacy.md`
3. Print findings to terminal

## Report Format

```
# Privacy Audit — YYYY-MM-DD
Project: <AppName>

## 🔴 CRITICAL — Reject almost certain
- [ ] TODO: Create PrivacyInfo.xcprivacy — UserDefaults used without manifest (ITMS-91053) — Guideline 5.1
- [ ] TODO: Add ATT prompt before Firebase initialization — AppDelegate.swift:22 — Guideline 5.1.2(i)
- [ ] TODO: Add in-app account deletion (not just deactivation) — Guideline 5.1.1(v)

## 🟠 HIGH — Very likely rejection
- [ ] TODO: Add in-app privacy policy link in Settings — Guideline 5.1.1(i)
- [ ] TODO: Replace PHPhotoLibrary with PHPickerViewController — Guideline 5.1.1(iii)

## 🟡 MEDIUM — Possible rejection
- [ ] TODO: Verify privacy policy URL returns 200 — URL found but not verified

---
Total: N findings · 🔴 N · 🟠 N · 🟡 N
Saved: docs/appstore-audit/YYYY-MM-DD-privacy.md
```

## Usage

```
/privacy-audit
```

Run when: Integrating any analytics SDK, adding user accounts, collecting any personal data, or before every App Store submission.

## Constraints
- Read-only — never edits source files
- Reference `file:line` for every code-level finding
- When no analytics SDK is detected, skip ATT check and report "No tracking SDKs detected"
- `mkdir -p docs/appstore-audit/` must run before writing the report
