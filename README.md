# apple-app-review-skills

> A curated collection of Claude Code skills and agents to eliminate App Store rejections — built from **real-world rejection cases** reported by developers on Stack Overflow, Apple Developer Forums, RevenueCat Community, and tech blogs.

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![Swift](https://img.shields.io/badge/Swift-5.9%2B-orange.svg)](https://swift.org)
[![Platform](https://img.shields.io/badge/iOS%20%7C%20macOS%20%7C%20tvOS%20%7C%20watchOS-blue.svg)](https://developer.apple.com)
[![Guidelines](https://img.shields.io/badge/App%20Store%20Review%20Guidelines-2025-informational)](https://developer.apple.com/app-store/review/guidelines/)
[![agentskills](https://img.shields.io/badge/agentskills.io-compatible-blueviolet)](https://agentskills.io/specification)

---

## Why This Exists

In 2024, Apple rejected **1.93 million** out of 7.77 million app submissions. Over **40% of rejections** were from preventable mistakes.

This project encodes Apple's full [App Store Review Guidelines](https://developer.apple.com/app-store/review/guidelines/) — combined with **dozens of real developer rejection cases** — into reusable Claude Code skills and autonomous agents you can run before every submission.

### Real Rejection Cases That Inspired This Project

| # | Rejection Pattern | Guideline | Source |
|---|------------------|-----------|--------|
| 1 | App crashes / broken layout on iPad Air (reviewers use iPad Air) | 2.1, 2.4.1 | Apple Developer Forums |
| 2 | Permission requested at app launch with no context | 5.1.1(ii) | Stack Overflow, GitHub Issues |
| 3 | Third-party SDK (OneSignal, Urban Airship) adds `NSLocationAlwaysUsageDescription` silently | 5.1.1(ii) | OneSignal/iOS-SDK #490 |
| 4 | No report/block feature on user profiles or UGC feeds | 1.2 | Apple Developer Forums #116703 |
| 5 | Missing `PrivacyInfo.xcprivacy` for required reason APIs (enforced May 1, 2024) | 5.1 | ITMS-91053 emails |
| 6 | No in-app account deletion (required since June 30, 2022) | 5.1.1(v) | Apple Developer News |
| 7 | Auto-renewable subscription: renewal amount not shown prominently | 3.1.2(c) | RevenueCat Community |
| 8 | Subscription paywall shows discount percentage but hides actual billed amount | 3.1.2(c) | Apple Developer Forums #127616 |
| 9 | Free trial paywall doesn't state what happens after trial ends | 3.1.2(c) | RevenueCat Community |
| 10 | Placeholder "Lorem Ipsum" text found by reviewer | 2.1 | Multiple dev blogs |
| 11 | Support URL in App Store Connect returns 404 | 2.1 | decode.agency |
| 12 | App version shows "0.1" or "beta" in name | 2.1 | mobiloud.com |
| 13 | Screenshots show only splash screen, not actual app UI | 2.3.3 | Apple guidelines |
| 14 | Privacy policy URL is broken or missing | 5.1.1(i) | Multiple sources |
| 15 | Force unwrap `!` crash found during review on edge-case data | 2.1 | Developer experience |
| 16 | App references Android or shows Android screenshots | 2.3.10 | mobiloud.com |
| 17 | IAP bypass via WebView payment page for digital content | 3.1.1 | purchasely.com |
| 18 | Text truncation on iPad due to fixed-width constraints | 2.4.1 | Adalo Resources |
| 19 | Dynamic Type disabled — text clips at large accessibility sizes | HIG | Apple HIG |
| 20 | No Safe Area insets — content hidden behind Dynamic Island | HIG | Developer experience |

---

## Installation

### User-level install (global — works in all your projects)

One-line install — copies all skills and agents to `~/.claude/`:

```bash
curl -fsSL https://raw.githubusercontent.com/cruisediary/apple-app-review-skills/main/install.sh | bash
```

Or clone and install manually:

```bash
git clone https://github.com/cruisediary/apple-app-review-skills.git
cd apple-app-review-skills
bash install.sh
```

### Project-level install (team sharing or per-project isolation)

Install into a specific iOS/macOS app repo so the skills are pinned to your project:

```bash
# Clone the skills repo
git clone https://github.com/cruisediary/apple-app-review-skills.git

# cd to your iOS app repo root, then run:
cd /path/to/your-ios-app
bash /path/to/apple-app-review-skills/install.sh --project

# Commit .claude/ to share with your team
git add .claude/
git commit -m "chore: add app-review-skills for team"
```

Team members automatically get the skills on `git pull` — no individual install required.

### What Gets Installed

```
~/.claude/skills/layout/            4 skills
~/.claude/skills/permissions/       3 skills
~/.claude/skills/ugc/               2 skills
~/.claude/skills/privacy/           6 skills
~/.claude/skills/quality/           8 skills
~/.claude/skills/business/          4 skills
~/.claude/skills/metadata/          4 skills
~/.claude/agents/                   5 agents
```

### Custom config directory

If `CLAUDE_CONFIG_DIR` is set, `install.sh` and `uninstall.sh` both install to
and remove from that path instead of `~/.claude`:

```bash
CLAUDE_CONFIG_DIR=/path/to/config bash install.sh
```

### Updating

Re-running `install.sh` skips files that already exist. To pull in the latest
version of every skill, agent, and command, use `--force` (or its alias
`--update`):

```bash
git pull
bash install.sh --update
```

### Uninstalling

`uninstall.sh` removes everything `install.sh` puts in place, mirroring its
flags (`--project`, and `CLAUDE_CONFIG_DIR` support):

```bash
bash uninstall.sh              # user-level
bash uninstall.sh --project    # project-level (.claude/ in the current repo)
bash uninstall.sh --dry-run    # preview what would be deleted
```

It derives the file list from the skills, agents, and commands currently in
this checkout, so if you've since pulled a version of the repo with fewer
skills than what you originally installed, those older files won't be cleaned
up automatically.

---

## Usage

Open any iOS/macOS project in Claude Code, then run:

### Quick Demo

Ask Claude Code in natural language — no slash commands needed if you've added `CLAUDE.md.example`:

```
"Will my app pass App Store review?"
"Check my app for rejection risks before I submit"
"Fix the subscription paywall so it doesn't get rejected"
```

Claude routes to the appropriate skill and returns a prioritized report:

```
🔴 CRITICAL — account-deletion-check
   No in-app account deletion found. Required since June 30, 2022.
   Fix: Add Settings → Account → Delete Account flow with server-side deletion.

🟠 HIGH — subscription-disclosure
   Free trial paywall does not state what happens after the trial ends.
   Fix: Add "Then $9.99/month, cancel anytime" below the CTA button.

🟡 MEDIUM — privacy-manifest-check
   PrivacyInfo.xcprivacy missing NSFileSystemFreeSize declaration.
   Fix: Add reason "E174.1" to PrivacyInfo.xcprivacy.

🟢 LOW — dynamic-type-support
   3 labels use fixed font size. Consider UIFontMetrics for accessibility.
```

### Enable natural language triggers (optional)

To let Claude respond to natural language requests like "앱 리뷰 통과 가능하게 고쳐줘" without explicit slash commands, add the contents of [`CLAUDE.md.example`](CLAUDE.md.example) to your project's `CLAUDE.md`:

```bash
cat CLAUDE.md.example >> /path/to/your-ios-app/CLAUDE.md
```

### Full audit (recommended before every submission)

```
/appstore-full-audit
```

Runs all 31 skills and produces a prioritized rejection risk report.

### Targeted audits

```
/ipad-layout-audit        # iPad layout, safe area, Dynamic Type, orientation
/permission-audit         # NSUsageDescription completeness + request timing
/ugc-safety-audit         # Report/block for user content and profiles
/privacy-audit            # Privacy policy, account deletion, ATT, manifest
```

### Use individual skills in your own agents

Skills are atomic and composable:

```markdown
## Skills Used
- `~/.claude/skills/layout/ipad-layout-audit.md`
- `~/.claude/skills/business/subscription-disclosure.md`
- `~/.claude/skills/privacy/account-deletion-check.md`
```

---

## Skills Reference

### Layout & UI — `skills/layout/`

| Skill | What It Checks | Key Rejection Cases |
|-------|---------------|-------------------|
| `ipad-layout-audit` | Size classes, split view, adaptive layout, text truncation on iPad | Fixed UIStackView widths, hardcoded frame sizes |
| `safe-area-compliance` | Dynamic Island, notch, home indicator insets via `safeAreaInsets` | Content hidden behind status bar, bottom nav behind home indicator |
| `dynamic-type-support` | `UIFontMetrics` (UIKit), semantic SwiftUI font styles, fixed-height containers that clip text | `font: .systemFont(ofSize: 14)` without scaling |
| `orientation-support` | Portrait/landscape adaptability, trait collection handling | Layout breaks on iPad rotation |

### Permissions — `skills/permissions/`

| Skill | What It Checks | Key Rejection Cases |
|-------|---------------|-------------------|
| `usage-description-audit` | All `NS*UsageDescription` keys present, non-generic, descriptive | Generic strings like "App needs access", missing keys from SDK dependencies |
| `request-timing-audit` | Permissions not requested at app launch or before context is clear | `requestAlwaysAuthorization()` called in `application(_:didFinishLaunchingWithOptions:)` |
| `permission-scope-audit` | Minimum necessary permissions (Always vs WhenInUse, full contacts vs picker) | Requesting Always location when WhenInUse suffices |

### User-Generated Content — `skills/ugc/`

| Skill | What It Checks | Key Rejection Cases |
|-------|---------------|-------------------|
| `ugc-safety-features` | Report/block/filter on feed posts, comments, messages **and** user profile views | Missing "Report" button on posts/profiles, no user blocking — Guideline 1.2 |
| `content-moderation-api` | Content filtering integration, EULA acceptance flow | No terms agreement, no moderation backend |

### Privacy — `skills/privacy/`

| Skill | What It Checks | Key Rejection Cases |
|-------|---------------|-------------------|
| `privacy-policy-check` | Privacy policy linked in app + App Store Connect, URL resolves | 404 support URL, missing data retention explanation |
| `privacy-manifest-check` | `PrivacyInfo.xcprivacy` exists with all required reason APIs declared (iOS 17+, enforced May 2024) | ITMS-91053: Missing API declaration |
| `att-framework-audit` | `ATTrackingManager.requestTrackingAuthorization` before any tracking | Tracking without ATT prompt |
| `account-deletion-check` | In-app account deletion flow (not just deactivation), required since June 30, 2022 | Settings → Account → only "Deactivate" found, no delete option |
| `data-minimization-audit` | Only required data collected, out-of-process pickers used where possible | Requesting full Contacts access when only email needed |
| `ai-data-disclosure` | Third-party AI SDK/API (OpenAI, Gemini, Anthropic) usage with no in-app consent — Guideline 5.1.2(i) | Sending user messages to OpenAI without disclosure modal |

### Quality — `skills/quality/`

| Skill | What It Checks | Key Rejection Cases |
|-------|---------------|-------------------|
| `app-completeness-check` | No Lorem Ipsum, placeholder images, broken buttons, "Coming Soon" screens | "Lorem ipsum" in body text, greyed-out unimplemented tabs |
| `crash-risk-audit` | Force unwrap `!`, force cast `as!`, unsafe array access, main thread violations | `let x = value!` crash on nil, `tableView.reloadData()` off main thread |
| `review-readiness-check` | Demo account credentials in review notes, backend reachable, no "beta" in version name | App requires login with no demo account, backend returns 503 |
| `sdk-version-check` | Deprecated/removed APIs (`UIWebView`), outdated deployment target, missing `@available` guards | ITMS-90809 UIWebView rejection, crash on minimum-OS device — Guideline 2.5.10 |
| `push-notification-audit` | Push permission at launch, marketing content in notifications, missing delegate — Guideline 4.5.5 | Push requested before any user context, promotional push without opt-in |
| `review-request-audit` | `SKStoreReviewController` in button actions, review gating, direct write-review URL — Guideline 5.6.1 | "Rate Us" button calling requestReview() directly, satisfaction gate |
| `private-api-audit` | `dlopen`, `NSClassFromString` with private classes, underscore-prefixed methods, swizzling — Guideline 2.5.1 | ITMS-90338 private API binary rejection |
| `background-execution-audit` | Silent audio keep-alive, location misused for non-navigation, VoIP mode without CallKit — Guideline 2.5.3 | Silent audio looping to prevent suspension |

### Business & IAP — `skills/business/`

| Skill | What It Checks | Key Rejection Cases |
|-------|---------------|-------------------|
| `iap-compliance` | No IAP bypass via WebView or external links for digital goods, correct StoreKit usage | WebView payment page for subscription, `purchase()` not using StoreKit |
| `subscription-disclosure` | Auto-renewal amount displayed prominently, free trial end date shown, no misleading discount framing | Discount % displayed large, actual billed amount displayed small — Guideline 3.1.2(c) |
| `loot-box-disclosure` | Odds of each item type disclosed before purchase for randomized reward systems | Gacha mechanic with no odds table |
| `sign-in-with-apple` | Sign in with Apple present when third-party auth is used, official button styling, credential state handling | Google Sign-In without Apple option, custom-styled button rejected — Guideline 4.8 |

### Metadata — `skills/metadata/`

| Skill | What It Checks | Key Rejection Cases |
|-------|---------------|-------------------|
| `screenshot-guidelines` | Screenshots show actual in-app UI, not splash screens or mockups | Only logo/splash screen shown, screenshots from non-iOS device |
| `age-rating-accuracy` | Age rating matches actual content in app | User chat app rated 4+ despite allowing strangers to message |
| `app-name-compliance` | Name ≤30 chars, no trademark conflicts, no "beta"/"test" suffix | Name 34 chars, contains competitor trademark |
| `metadata-accuracy` | Description, keywords, and subtitle match actual functionality | Description claims features not yet implemented |

---

## Swift Code Examples

The [`examples/swift/`](examples/swift/) directory contains annotated Swift code showing **exactly what patterns cause rejection** and how to fix them — organized by category.

---

## Agents Reference

| Agent | Skills Used | Use When |
|-------|-------------|----------|
| `appstore-full-audit` | All 31 skills | Final pre-submission check |
| `ipad-layout-agent` | layout/* | iPad layout complaints from TestFlight |
| `ugc-safety-agent` | ugc/*, metadata/age-rating-accuracy | Building social/community features |
| `permission-audit-agent` | permissions/* | Adding new permission requests |
| `privacy-audit-agent` | privacy/* | Handling user data, subscriptions |

---

## Contributing

We welcome real-world rejection cases, skill improvements, and new coverage areas.

- Read [CONTRIBUTING.md](CONTRIBUTING.md) before opening a PR
- Submit rejection cases via [rejection case template](.github/ISSUE_TEMPLATE/rejection_case.md)
- One skill or fix per PR — follow [Conventional Commits](https://www.conventionalcommits.org/)

---

## Sources & References

Skills in this project are derived from:

- [Apple App Store Review Guidelines](https://developer.apple.com/app-store/review/guidelines/)
- [Apple Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/)
- [Apple Developer Forums](https://developer.apple.com/forums/)
- [RevenueCat Blog — Ultimate Guide to App Store Rejections](https://www.revenuecat.com/blog/growth/the-ultimate-guide-to-app-store-rejections/)
- [BuddyBoss — Guideline 1.2 UGC](https://buddyboss.com/docs/app-store-guideline-1-2-safety-user-generated-content/)
- [Apple Developer News — Account Deletion Requirement](https://developer.apple.com/news/?id=12m75xbj)
- [Apple Developer Documentation — PrivacyInfo.xcprivacy](https://developer.apple.com/documentation/bundleresources/privacy-manifest-files)
- Stack Overflow, GitHub Issues (OneSignal, Urban Airship, React Native, Expo)

---

## Specification

Skills follow the [agentskills.io specification](https://agentskills.io/specification) ([github.com/agentskills/agentskills](https://github.com/agentskills/agentskills)) — each skill is a directory containing a `SKILL.md` file with YAML frontmatter.

---

## License

MIT — see [LICENSE](LICENSE).
