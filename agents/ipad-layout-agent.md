# iPad Layout Agent

## Purpose
Audit an iOS/macOS project for iPad-specific layout, safe area, Dynamic Type, and orientation issues that cause App Store rejection under Guidelines 2.1, 2.4.1, and HIG.

## Skills Used
- `skills/layout/ipad-layout-audit.md` — hardcoded widths, size classes, split view, iPad idiom handling
- `skills/layout/safe-area-compliance.md` — Dynamic Island, notch, home indicator insets
- `skills/layout/dynamic-type-support.md` — fixed fonts, fixed-height text containers
- `skills/layout/orientation-support.md` — portrait/landscape adaptability, iPad plist keys

## Phase 1: Analysis (Read-Only)

1. Use `Glob` to find `**/*.swift` and `**/*.xib` and `**/*.storyboard` — collect all UI files
2. Use `Glob` to find `**/Info.plist` — read with `Read`
3. Use `Bash`: `! grep -r "UISupportedInterfaceOrientations" <Info.plist path>` — check orientation keys
4. Note project name and iOS deployment target from Info.plist

## Phase 2: Audit (Read-Only — No File Edits)

**iPad Layout (Guideline 2.4.1)**
- Use `Grep` to search all Swift files for hardcoded screen widths: `375`, `390`, `414`, `CGRect.*width: 3[789]`
- Use `Grep` for `UIDevice.current.userInterfaceIdiom == .phone` blocks that exclude `.pad`
- Use `Grep` for `UISplitViewController` — verify it's configured for iPad
- Use `Grep` for fixed `frame(width:` in SwiftUI views

**Safe Area (HIG)**
- Use `Grep` for `.ignoresSafeArea(.all)` or `edgesIgnoringSafeArea(.all)` on content views
- Use `Grep` for hardcoded inset values: `44`, `34`, `20` used as status bar or home indicator offsets
- Use `Grep` for `safeAreaInsets` — verify it's used where device-specific spacing is needed

**Dynamic Type (HIG)**
- Use `Grep` for `UIFont.systemFont(ofSize:` without `UIFontMetrics`
- Use `Grep` for `.font(.system(size:` in SwiftUI — fixed numeric sizes don't scale; suggest semantic styles (`.body`, `.headline`, etc.)
- Use `Grep` for `.frame(height: [0-9]` on views containing `Text` or `UILabel`
- Use `Grep` for `adjustsFontForContentSizeCategory` — verify it's set to `true` on UILabels

**Orientation (Guideline 2.4.1)**
- Check Info.plist for `UISupportedInterfaceOrientations~ipad` — must include both portrait AND landscape keys:
  - `UIInterfaceOrientationLandscapeLeft`
  - `UIInterfaceOrientationLandscapeRight`
- Use `Grep` for `viewWillTransition(to:with:)` — verify layout updates on rotation

## Phase 3: Report

1. Run: `! mkdir -p docs/appstore-audit`
2. Save report to `docs/appstore-audit/YYYY-MM-DD-ipad-layout.md`
3. Print findings to terminal

## Report Format

```
# iPad Layout Audit — YYYY-MM-DD
Project: <AppName>

## 🔴 CRITICAL — Reject almost certain
- [ ] TODO: <actionable step> — `file:line` — Guideline 2.4.1

## 🟠 HIGH
- [ ] TODO: <actionable step> — HIG

## 🟡 MEDIUM
- [ ] TODO: <actionable step>

---
Total: N findings · 🔴 N · 🟠 N · 🟡 N
Saved: docs/appstore-audit/YYYY-MM-DD-ipad-layout.md
```

## Usage

```
/ipad-layout-audit
```

Run when: TestFlight testers report layout issues on iPad, or before any submission targeting iPad.

## Constraints
- Read-only — never edits source files
- Reference `file:line` for every finding
- Only flag confirmed code patterns, not hypothetical issues
