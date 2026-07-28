---
name: ugc-safety-agent
description: Audits an iOS/macOS app for User-Generated Content safety features required by Guideline 1.2 — report/block on feeds, profiles, messages, EULA acceptance, content moderation integration, and age rating accuracy. Use when building social/community features, adding user profiles, or adding any UGC feed.
tools: Glob, Grep, Read, Bash, Write
model: sonnet
---

# UGC Safety Agent

## Purpose
Audit an iOS/macOS app for User-Generated Content safety features required by Guideline 1.2 — report/block on feeds, profiles, messages, EULA acceptance, content moderation integration, and age rating accuracy.

## Skills Used
- `skills/ugc/ugc-safety-features.md` — report/block on posts, comments, messages, and user profiles
- `skills/ugc/content-moderation-api.md` — moderation service integration, EULA acceptance flow
- `skills/metadata/age-rating-accuracy.md` — rating matches actual UGC/social content type

## Phase 1: Analysis (Read-Only)

1. Use `Glob` to find `**/*.swift` — collect all Swift source files
2. Use `Grep` to identify if app has social/UGC features: search for `tableView`, `collectionView`, `List`, `ForEach`, `UICollectionView`, `LazyVGrid`
3. Use `Glob` to find `**/Info.plist` — read to check age rating-related keys
4. Use `Grep` for messaging patterns: `messageCell`, `ChatView`, `MessageView`, `ConversationView`
5. Determine: Does this app have UGC? (posts, comments, profiles, messages) — if no UGC found, report "No UGC features detected" and exit

## Phase 2: Audit (Read-Only — No File Edits)

**Feed-Level Safety (Guideline 1.2)**
- Use `Grep` to find cells/rows rendering user posts or comments: `PostCell`, `CommentCell`, `FeedCell`, `postView`, `commentView`
- For each, check nearby code for report action: `report`, `flag`, `inappropriate`
- Use `Grep` for `UIContextMenuConfiguration`, `swipeActions`, `contextMenu` — verify report/flag is present
- Flag if report button is absent from any user-content-rendering cell

**Profile-Level Safety (Guideline 1.2)**
- Use `Grep` for profile views: `ProfileView`, `UserProfileView`, `ProfileViewController`
- Check for both report AND block actions: `blockUser`, `reportUser`, `block`, `report`
- Flag if profile views show user content but lack report or block options

**Message Safety (Guideline 1.2)**
- Use `Grep` for DM/chat views: `DirectMessage`, `ChatView`, `MessageView`
- Check for block/report actions accessible from message or conversation view

**EULA / Terms Acceptance (Guideline 1.2)**
- Use `Grep` for terms/EULA acceptance in onboarding: `termsAccepted`, `agreeToTerms`, `EULA`, `acceptTerms`
- Flag if registration flow completes without Terms/EULA acknowledgment

**Content Moderation Integration (Guideline 1.2)**
- Use `Grep` for moderation service calls: `moderateContent`, `checkContent`, `moderationAPI`
- Use `Grep` for image upload without moderation: `uploadImage`, `postImage` without adjacent moderation call
- Flag if user-submitted media is posted without any moderation step

**Age Rating Accuracy (Guideline 2.3.6)**
- If app has direct user-to-user messaging with strangers → age rating must be 12+ minimum
- If app has unmoderated UGC → 12+ minimum
- If app has gambling/loot boxes → 17+
- Read Info.plist `LSApplicationCategoryType` and note the declared age rating if present

## Phase 3: Report

1. Run: `! mkdir -p docs/appstore-audit`
2. Save report to `docs/appstore-audit/YYYY-MM-DD-ugc-safety.md`
3. Print findings to terminal

## Report Format

```
# UGC Safety Audit — YYYY-MM-DD
Project: <AppName>

## 🔴 CRITICAL — Reject almost certain
- [ ] TODO: Add report button to <PostCell> — `FeedView.swift:42` — Guideline 1.2
- [ ] TODO: Add block/report to user profile view — `ProfileView.swift:15` — Guideline 1.2

## 🟠 HIGH — Very likely rejection
- [ ] TODO: Add EULA acceptance to onboarding — Guideline 1.2

## 🟡 MEDIUM — Possible rejection
- [ ] TODO: Review age rating — direct messaging requires 12+ — Guideline 2.3.6

---
Total: N findings · 🔴 N · 🟠 N · 🟡 N
Saved: docs/appstore-audit/YYYY-MM-DD-ugc-safety.md
```

## Usage

```
/ugc-safety-audit
```

Run when: Building social or community features, adding user profiles, or adding any UGC feed.

## Constraints
- Read-only — never edits source files
- If no UGC found, report that clearly rather than generating false positives
- Only report findings confirmed by code evidence (`file:line` required)
