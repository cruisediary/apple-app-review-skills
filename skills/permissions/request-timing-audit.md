# Skill: Request Timing Audit
<!-- SEO: permission request timing App Launch AppDelegate viewDidLoad location camera tracking prompt too early iOS rejection -->

## Purpose
Detects permission requests triggered at app launch or before meaningful user interaction, which violates Guideline 5.1.1(ii) requiring permissions to be requested only at the moment of need with contextual explanation.

## Apple Guideline
- **Primary:** 5.1.1(ii) — Data Collection and Storage: Permission Request Context
- **Related:** 5.1.1(i), 5.1.2
- **Reference:** `references/guidelines/5-legal.md`

## Real-World Rejection Cases
- **Case:** App requested location permission in applicationDidFinishLaunching before any user interaction — rejected
  **Source:** Apple Developer Forums
  **Root cause:** Permissions must be requested at the moment they are needed, with context explaining why — launching the app does not constitute a moment of need

## Trigger
Invoke on any iOS/macOS project to verify permission prompts are contextually timed and not presented at app launch.

## Inputs
| Name | Type | Default | Description |
|------|------|---------|-------------|
| `project_root` | path | cwd | iOS/macOS project root |
| `shared_context` | object | nil | Pre-collected context from appstore-full-audit Phase 1 |

## Actions

### Phase 1: Context Collection
*Skip this phase if `shared_context` is provided.*

1. `Glob` `**/AppDelegate.swift` — locate AppDelegate.
2. `Glob` `**/SceneDelegate.swift` — locate SceneDelegate.
3. `Glob` `**/*.swift` — collect all Swift source files.
4. `Glob` `**/*.m` — collect Objective-C source files.

### Phase 2: Checks

1. **Location permission at launch**
   `Grep` pattern `requestWhenInUseAuthorization|requestAlwaysAuthorization` in `AppDelegate.swift` and `SceneDelegate.swift`.
   Any match found in `applicationDidFinishLaunching`, `application(_:didFinishLaunchingWithOptions:)`, `scene(_:willConnectTo:)`, or `sceneDidBecomeActive` → 🟠 HIGH. Permission should be deferred until the feature requiring location is actually invoked.

2. **Camera/microphone permission at launch**
   `Grep` pattern `AVCaptureDevice\.requestAccess|AVAudioSession.*requestRecordPermission|requestAuthorization` in `AppDelegate.swift` and `SceneDelegate.swift`.
   Any match in top-level launch methods → 🟠 HIGH.

3. **Camera/microphone permission in root view's viewDidLoad**
   `Grep` pattern `AVCaptureDevice\.requestAccess|requestAuthorization` in `**/*.swift`.
   For each match, `Read` surrounding context — if located inside `viewDidLoad` of a root/initial view controller (e.g., `ViewController`, `HomeViewController`, `MainViewController`, `RootViewController`), flag → 🟠 HIGH.

4. **Tracking authorization before onboarding**
   `Grep` pattern `requestTrackingAuthorization` in `**/*.swift`.
   For each match, `Read` surrounding context — if called before any onboarding UI is presented (e.g., directly in `applicationDidFinishLaunching` or before a splash/welcome screen), flag → 🟠 HIGH.

### Phase 3: Output
Collect all findings from Phase 2 and build the prioritised findings list below. Include file paths and line numbers. Omit tiers with no findings.

## Output Format

```
## Request Timing Audit — Findings

### 🔴 CRITICAL — Guaranteed rejection
- [ ] TODO: <exact actionable step> — `file:line` — Guideline 5.1.1(ii)

### 🟠 HIGH — Very likely rejection
- [ ] TODO: Move requestWhenInUseAuthorization out of applicationDidFinishLaunching — defer until user initiates a location-dependent action — `AppDelegate.swift:42` — Guideline 5.1.1(ii)
- [ ] TODO: Move requestTrackingAuthorization to after onboarding is complete — do not call before any user interaction — `AppDelegate.swift:55` — Guideline 5.1.1(ii)

### 🟡 MEDIUM — Possible rejection
- [ ] TODO: Verify AVCaptureDevice.requestAccess is called only when user explicitly opens camera — not in viewDidLoad — `HomeViewController.swift:88`

### 🟢 LOW — Best practice
- [ ] TODO: Add a contextual pre-permission UI explaining why permission is needed before presenting the system prompt
```

## Tools Used
`Glob`, `Grep`, `Read`

## Constraints
- Read-only. No file edits.
- No network calls.
- Skip Phase 1 if `shared_context` is provided by orchestrating agent.
- Works on Swift, Objective-C, React Native, Flutter projects.

## Swift Anti-Pattern Reference
`examples/swift/PermissionPatterns.swift`
