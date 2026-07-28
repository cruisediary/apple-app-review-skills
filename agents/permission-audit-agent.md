---
name: permission-audit-agent
description: Audits an iOS/macOS app for permission-related App Store rejection risks — missing usage descriptions, permissions requested too early, and over-broad permission scope, covering Guideline 5.1.1(ii) and 5.1.1(iii). Use when adding or changing permission requests.
tools: Glob, Grep, Read, Bash, Write
model: sonnet
---

# Permission Audit Agent

## Purpose
Audit an iOS/macOS app for permission-related App Store rejection risks: missing usage descriptions, permissions requested too early, and over-broad permission scope — covering Guideline 5.1.1(ii) and 5.1.1(iii).

## Skills Used
- `skills/permissions/usage-description-audit.md` — all NS*UsageDescription keys present and descriptive
- `skills/permissions/request-timing-audit.md` — no permission requests at app launch
- `skills/permissions/permission-scope-audit.md` — minimum necessary permissions (Always vs WhenInUse, pickers vs full access)

## Phase 1: Analysis (Read-Only)

1. Use `Glob` to find `**/Info.plist` — read with `Read`
2. Use `Bash`: `! plutil -p <Info.plist>` — extract all `NS*UsageDescription` key-value pairs
3. Use `Glob` to find `**/*.swift` — collect all Swift source files
4. Use `Grep` to find all permission request calls:
   - `requestAuthorization`, `requestAlwaysAuthorization`, `requestWhenInUseAuthorization`
   - `AVCaptureDevice.requestAccess`
   - `PHPhotoLibrary.requestAuthorization`
   - `UNUserNotificationCenter.*requestAuthorization`
   - `CNContactStore.*requestAccess`
   - `CMMotionActivityManager.*startActivityUpdates`

## Phase 2: Audit (Read-Only — No File Edits)

**Usage Description Completeness (Guideline 5.1.1(ii))**
- For each permission API found in source, verify the corresponding key exists in Info.plist:

  | API | Required Info.plist Key |
  |-----|------------------------|
  | `CLLocationManager` | `NSLocationWhenInUseUsageDescription` |
  | `requestAlwaysAuthorization` | `NSLocationAlwaysAndWhenInUseUsageDescription` |
  | `AVCaptureDevice` (camera) | `NSCameraUsageDescription` |
  | `AVAudioSession` | `NSMicrophoneUsageDescription` |
  | `PHPhotoLibrary` | `NSPhotoLibraryUsageDescription` |
  | `CNContactStore` | `NSContactsUsageDescription` |
  | `UNUserNotificationCenter` | (no plist key required — push notification authorization is separate from ATT) |
  | `CBCentralManager` | `NSBluetoothAlwaysUsageDescription` |
  | `CMMotionActivityManager` | `NSMotionUsageDescription` |
  | `HKHealthStore` | `NSHealthShareUsageDescription` |
  | `EKEventStore` | `NSCalendarsUsageDescription` |
  | `SFSpeechRecognizer` | `NSSpeechRecognitionUsageDescription` |
  | `NFCReaderSession` | `NFCReaderUsageDescription` |

- For each present key, check that the value is descriptive (>15 characters, not generic like "App requires access")
- Use `Grep` to find SDK-injected usage descriptions in Pods or SPM `.resolved` — flag if SDK adds `NSLocationAlwaysUsageDescription` unexpectedly

**Request Timing (Guideline 5.1.1(ii))**
- Use `Grep` for permission requests inside:
  - `application(_:didFinishLaunchingWithOptions:)` — flag as CRITICAL
  - `viewDidLoad` of initial/root view controller — flag as HIGH
  - `init` of any view or manager — flag as HIGH
- Verify permission is requested only after the user has taken an action that makes the need obvious

**Permission Scope (Guideline 5.1.1(iii))**
- Use `Grep` for `requestAlwaysAuthorization()` — flag if `requestWhenInUseAuthorization()` would suffice
- Use `Grep` for `PHPhotoLibrary.requestAuthorization` — flag if `PHPickerViewController` would be appropriate
- Use `Grep` for `CNContactStore().requestAccess` — flag if `CNContactPickerViewController` would be appropriate
- Use `Grep` for `AVCaptureDevice.requestAccess(for: .video)` with `.audio` separately — ensure only required media types are requested

## Phase 3: Report

1. Run: `! mkdir -p docs/appstore-audit`
2. Save report to `docs/appstore-audit/YYYY-MM-DD-permissions.md`
3. Print findings to terminal

## Report Format

```
# Permission Audit — YYYY-MM-DD
Project: <AppName>

## 🔴 CRITICAL — Reject almost certain
- [ ] TODO: Add NSCameraUsageDescription to Info.plist — camera access found in CameraManager.swift:12 — Guideline 5.1.1(ii)
- [ ] TODO: Move location permission request out of application(_:didFinishLaunchingWithOptions:) — AppDelegate.swift:34 — Guideline 5.1.1(ii)

## 🟠 HIGH — Very likely rejection
- [ ] TODO: Replace PHPhotoLibrary.requestAuthorization with PHPickerViewController — Guideline 5.1.1(iii)
- [ ] TODO: Replace requestAlwaysAuthorization with requestWhenInUseAuthorization — Guideline 5.1.1(iii)

## 🟡 MEDIUM — Possible rejection
- [ ] TODO: Make NSLocationWhenInUseUsageDescription more descriptive (current: "App needs location")

---
Total: N findings · 🔴 N · 🟠 N · 🟡 N
Saved: docs/appstore-audit/YYYY-MM-DD-permissions.md
```

## Usage

```
/permission-audit
```

Run when: Adding any new permission request, integrating a new SDK that may declare permissions, or before every App Store submission.

## Constraints
- Read-only — never edits source files or Info.plist
- Reference `file:line` for every permission API call finding
- Do not report permissions that are declared in Info.plist but have no corresponding API usage — these are fine
