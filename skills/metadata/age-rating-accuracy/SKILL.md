---
name: age-rating-accuracy
description: >-
  Detects feature patterns that require a higher age rating than commonly submitted, enforcing Guideline 2.3.6 which requires age ratings to accurately reflect the app's content and social features.
---

# Skill: Age Rating Accuracy
<!-- SEO: age rating 4+ 12+ 17+ stranger chat alcohol gambling UGC Guideline 2.3.6 iOS App Store rejection -->

## Purpose
Detects feature patterns that require a higher age rating than commonly submitted, enforcing Guideline 2.3.6 which requires age ratings to accurately reflect the app's content and social features.

## Apple Guideline
- **Primary:** 2.3.6 — Performance: Accurate Metadata — Age Ratings
- **Related:** 2.3.1
- **Reference:** `references/guidelines/2-performance.md`

## Real-World Rejection Cases
- **Case:** Social chat app rated 4+ — reviewer found strangers could message each other — rejected, must be 12+ minimum
  **Source:** Apple Developer Forums (Guideline 2.3.6 enforcement)
  **Root cause:** Age rating must accurately reflect content; apps enabling stranger communication require 12+ or 17+ rating — reviewers test social features and will flag a 4+ rating if strangers can interact

## Trigger
Invoke on any iOS/macOS project before App Store submission to verify the selected age rating is appropriate for the app's features.

## Inputs
| Name | Type | Default | Description |
|------|------|---------|-------------|
| `project_root` | path | cwd | iOS/macOS project root |
| `shared_context` | object | nil | Pre-collected context from appstore-full-audit Phase 1 |

## Actions

### Phase 1: Context Collection
*Skip this phase if `shared_context` is provided.*

1. `Glob` `**/*.swift` — collect all Swift source files.
2. `Glob` `**/*.m` — collect Objective-C source files.

### Phase 2: Checks

1. **Stranger communication features (12+ minimum)**
   `Grep` pattern `"message"|"chat"|"inbox"|"direct message"|"DM"|"send.*message"|"message.*stranger"` in `**/*.swift`.
   If found and app enables communication with unknown users (not just friends/contacts) → 🟠 HIGH. Flag for 12+ age rating review. Reviewer will test whether strangers can contact each other.

2. **Alcohol or substance references (17+ consideration)**
   `Grep` pattern `"alcohol"|"beer"|"wine"|"spirits"|"liquor"|"cocktail"|"whiskey"` in `**/*.swift`.
   If found as primary app theme or purchasable content → 🟠 HIGH. Flag for 17+ age rating consideration.

3. **Gambling or wagering features (17+)**
   `Grep` pattern `SKProduct|StoreKit` near `"bet"|"wager"|"casino"|"slots"|"poker"|"gamble"` in `**/*.swift`.
   If real-money or simulated gambling found → 🟠 HIGH. Flag for 17+ age rating requirement.

4. **Unmoderated user-generated content (12+ or 17+)**
   `Grep` pattern `"post"|"comment"|"UGC"|"userContent"|"community"` in `**/*.swift`.
   If unmoderated UGC is possible and no `contentFilter|moderateContent` patterns detected → 🟠 HIGH. Unmoderated UGC apps typically require 12+ or 17+ rating depending on content type.

### Phase 3: Output
Collect all findings from Phase 2 and build the prioritised findings list below. Include file paths and line numbers. Omit tiers with no findings.

## Output Format

```
## Age Rating Accuracy — Findings

### 🔴 CRITICAL — Guaranteed rejection
- [ ] TODO: <exact actionable step> — `file:line` — Guideline 2.3.6

### 🟠 HIGH — Very likely rejection
- [ ] TODO: Review age rating — app enables stranger-to-stranger messaging; minimum 12+ rating required — `ChatViewController.swift` — Guideline 2.3.6
- [ ] TODO: Review age rating — alcohol purchasing/content found; consider 17+ rating — `DrinkMenuViewController.swift:44` — Guideline 2.3.6
- [ ] TODO: Review age rating — simulated gambling or wagering detected; 17+ rating required — `CasinoViewController.swift` — Guideline 2.3.6
- [ ] TODO: Review age rating — unmoderated user-generated content without content filter requires at minimum 12+ rating — Guideline 2.3.6

### 🟡 MEDIUM — Possible rejection
- [ ] TODO: Manually verify age rating in App Store Connect matches all features — use Apple's rating questionnaire as a checklist

### 🟢 LOW — Best practice
- [ ] TODO: Document the age rating rationale in review notes — helps reviewers understand why certain features are rated appropriately
```

## Tools Used
`Glob`, `Grep`, `Read`

## Constraints
- Read-only. No file edits.
- No network calls.
- Skip Phase 1 if `shared_context` is provided by orchestrating agent.
- Works on Swift, Objective-C, React Native, Flutter projects.

## Quick Commands

Run these in your project root to check manually:

```bash
# Check for chat/messaging features (may require 12+ rating)
!grep -rn "message\|chat\|inbox\|DirectMessage\b\|\"DM\"" . --include="*.swift" | grep -v "//" | wc -l

# Check for gambling keywords
!grep -rn "bet\b\|wager\|casino\|gambling" . --include="*.swift" -i | grep -v "//"

# Check current age rating in project
!grep -rn "ITSAppUsesNonExemptEncryption\|MinimumOSVersion" . --include="*.plist" | head -5
```

## Swift Anti-Pattern Reference
`examples/swift/QualityPatterns.swift`

## Detection Steps

1. **Find target files**
   - Glob: `**/*.swift`, `**/*.m`, `**/Info.plist`

2. **Search for rejection patterns**
   - Grep `NSLocationWhenInUseUsageDescription\|NSLocationAlwaysUsageDescription` — location features
   - Grep `AVCaptureDevice\|AVCaptureSession\|camera` — camera features
   - Grep `MessageUI\|MFMailComposeViewController\|MFMessageComposeViewController` — messaging
   - Grep `MKMapView\|MapKit` — map/location display
   - Check `Info.plist` `ITSAppUsesNonExemptEncryption`

3. **Determine verdict**
   - Location + camera + messaging features present → minimum age rating 12+ → flag if rated 4+
   - User chat or stranger messaging possible → minimum age rating 17+ → flag if rated lower
   - Features match declared age rating → 🟢 pass

4. **Report**
   - Features detected that may require higher age rating
   - Note: Age rating is set in App Store Connect, not in code — this is a consistency check
   - Fix: Review age rating in App Store Connect and raise it to match app features