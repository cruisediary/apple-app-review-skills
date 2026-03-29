# Human Interface Guidelines — Adaptive Layout

Source: https://developer.apple.com/design/human-interface-guidelines/layout

## Safe Areas

Always use safe area insets to lay out content. Never hard-code top or bottom insets based on known device values.

**Correct approach:**
- Use `safeAreaLayoutGuide` with Auto Layout constraints
- Use `safeAreaInsets` in manual layout code
- Respect `additionalSafeAreaInsets` when hosting child view controllers

**Incorrect — will cause layout issues on some devices:**
- Hard-coding `top: 44` (navigation bar) or `bottom: 34` (home indicator)
- Hard-coding `top: 20` (status bar) for older devices
- Assuming the safe area is constant across device families

These hard-coded values break on new device form factors, Stage Manager, Split View, and any configuration where the system chrome differs from assumptions.

## Size Classes

Use `UITraitCollection` to respond to the current layout environment. Do not infer device type from screen size alone.

- `horizontalSizeClass`: `.compact` (iPhone portrait, iPad Split View narrow) or `.regular` (iPad full-screen, iPhone Plus landscape)
- `verticalSizeClass`: `.compact` (iPhone landscape) or `.regular` (all other cases)

Handle trait collection changes via `traitCollectionDidChange(_:)` or SwiftUI's `@Environment(\.horizontalSizeClass)`. Design layouts for all combinations of compact/regular — not for specific devices.

## Split View (iPad)

iPad apps should support `UISplitViewController` for primary/secondary navigation. Do not assume a single-column layout:

- The app may run in 1/3, 1/2, or 2/3 Split View width on iPad
- Stage Manager allows arbitrary window resizing
- A layout that only works at 393pt (iPhone 14 width) will break in iPad Split View

Support all size class combinations. Test in Slide Over and Split View on iPad before submission.

## Dynamic Type

Never use fixed font sizes. All text must scale with the user's preferred text size setting.

**Correct approach:**
- Use `UIFont.preferredFont(forTextStyle:)` for system fonts
- Use `UIFontMetrics(forTextStyle:).scaledFont(for:)` for custom fonts
- Set `adjustsFontForContentSizeCategory = true` on labels

**Incorrect:**
- `UIFont.systemFont(ofSize: 17)` — fixed size, does not respond to Dynamic Type
- Manually clamping font size to avoid layout shifts

Apps must support all accessibility text sizes, including the five extra-large sizes accessible via Settings > Accessibility > Display & Text Size.

## Adaptive Layout

Use Auto Layout with size class variations. Never use fixed widths that match specific iPhone screen sizes:

- Avoid `width == 375` (iPhone SE 2nd/3rd gen, iPhone 8)
- Avoid `width == 390` (iPhone 14, iPhone 16)
- Avoid `width == 393` (iPhone 14 Pro, iPhone 15, iPhone 15 Pro, iPhone 16 Pro)
- Avoid `width == 430` (iPhone 14 Plus, iPhone 14 Pro Max, iPhone 15 Plus)
- Avoid `width == 440` (iPhone 16 Plus)
- Avoid `width == 402` (iPhone 15 Pro Max)
- Avoid `width == 440` (iPhone 17 Pro Max — 6.9", 440×956pt logical resolution)

These constants will produce broken layouts on iPad, in Split View, on future device sizes, and in Stage Manager. Use proportional constraints, flexible margins, and size class variations instead.

## iPhone 17 Series — Key Layout Values (2025)

Apple reviewers may test on any current-generation device. As of 2025, the lineup includes:

| Device | Logical Size (pt) | Dynamic Island | Home Indicator |
|--------|-------------------|----------------|----------------|
| iPhone 16 | 390 × 844 | Yes | No (swipe) |
| iPhone 16 Plus | 440 × 956 | Yes | No (swipe) |
| iPhone 16 Pro | 402 × 874 | Yes | No (swipe) |
| iPhone 16 Pro Max | 440 × 956 | Yes | No (swipe) |
| iPhone 17 | ~390 × 844 | Yes | No (swipe) |
| iPhone 17 Air | ~375 × 812 | Yes | No (swipe) |
| iPhone 17 Pro | ~402 × 874 | Yes | No (swipe) |
| iPhone 17 Pro Max | ~440 × 956 | Yes | No (swipe) |

> Note: iPhone 17 exact logical resolutions are based on pre-release specifications. Verify against official Apple docs after release.

**Key facts for layout correctness:**
- All iPhone 17 models use Dynamic Island — hard-coded `top: 54` or `top: 59` safe area values will break
- No iPhone since iPhone X has a home button — hard-coded `bottom: 34` home indicator inset is wrong on all current devices
- The "notch" (cutout area) is gone on all current iPhones; Dynamic Island has different geometry — never assume notch dimensions
- iPhone 17 Air is the thinnest iPhone ever — some Dynamic Island safe area values may differ slightly from Pro models

**Safe area insets by form factor (approximate, use system values at runtime):**

| Form Factor | Top safe area | Bottom safe area |
|-------------|--------------|-----------------|
| Dynamic Island models (all iPhone 12+) | 59pt | 34pt |
| Older notch models (iPhone X–11) | 44pt | 34pt |
| iPhone SE (home button) | 20pt | 0pt |
| iPad (no notch) | 24pt | 20pt |

**Always read safe area at runtime — never hardcode:**
```swift
// ✅ Correct
let topInset = view.safeAreaInsets.top
let bottomInset = view.safeAreaInsets.bottom

// ❌ Wrong — breaks on every new device form factor
let topInset: CGFloat = 59
let bottomInset: CGFloat = 34
```
