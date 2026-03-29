// ReviewRequestPatterns.swift
// apple-app-review-skills — examples/swift/
//
// Anti-patterns that cause App Store rejection for review manipulation.
// References: skills/quality/review-request-audit.md, references/guidelines/5-legal.md
//
// Guideline: 5.6.1 Manipulating Reviews

import SwiftUI
import StoreKit

// MARK: - Review Request Triggered by Button Tap (Guideline 5.6.1)

// ❌ REJECTION RISK — requestReview() called directly from a "Rate Us" button tap
struct BadRateUsButton: View {
    @Environment(\.requestReview) var requestReview

    var body: some View {
        // ❌ User tapping this button directly triggers the review prompt
        // Guideline 5.6.1: prompts must NOT be a direct response to user action
        Button("Rate Us ⭐️") {
            requestReview() // ❌ prohibited — must not be in a button action
        }
    }
}

// ✅ CORRECT — Request triggered programmatically after a meaningful milestone
class ReviewRequestManager {
    private static let tasksCompletedKey = "tasksCompletedCount"
    private static let lastReviewRequestKey = "lastReviewRequestDate"

    static func recordTaskCompleted() {
        let count = UserDefaults.standard.integer(forKey: tasksCompletedKey) + 1
        UserDefaults.standard.set(count, forKey: tasksCompletedKey)

        // ✅ Trigger after every 10th completed task — a natural positive moment
        if count % 10 == 0 {
            requestReviewIfAppropriate()
        }
    }

    private static func requestReviewIfAppropriate() {
        // ✅ Additional rate-limiting guard beyond Apple's system cap
        if let lastDate = UserDefaults.standard.object(forKey: lastReviewRequestKey) as? Date,
           Date().timeIntervalSince(lastDate) < 60 * 60 * 24 * 120 { // 120 days
            return
        }
        UserDefaults.standard.set(Date(), forKey: lastReviewRequestKey)
        if let scene = UIApplication.shared.connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene {
            SKStoreReviewController.requestReview(in: scene) // ✅ system-controlled, in a positive moment
        }
    }
}

// MARK: - Review Gating (Guideline 5.6.1)

// ❌ REJECTION RISK — Only shows review prompt to "satisfied" users (review gating)
struct BadSatisfactionGate: View {
    @Environment(\.requestReview) var requestReview
    @State private var showFeedbackForm = false

    var body: some View {
        VStack {
            Text("Are you enjoying the app?")
            HStack {
                Button("Yes! 😊") {
                    requestReview() // ❌ only satisfied users see the App Store prompt
                }
                Button("Not really 😕") {
                    showFeedbackForm = true // ❌ unsatisfied users are diverted to feedback form
                }
            }
        }
        .sheet(isPresented: $showFeedbackForm) { FeedbackFormView() }
    }
}

// ✅ CORRECT — All users have equal access to review prompt; feedback is separate
struct GoodFeedbackView: View {
    @State private var showFeedbackForm = false

    var body: some View {
        VStack(spacing: 16) {
            // ✅ Feedback form available to everyone — entirely separate from review logic
            Button("Send Feedback") {
                showFeedbackForm = true
            }
            // ✅ Review prompt is triggered by ReviewRequestManager at milestones, not here
        }
        .sheet(isPresented: $showFeedbackForm) { FeedbackFormView() }
    }
}

struct FeedbackFormView: View {
    var body: some View { Text("Feedback Form") }
}

// MARK: - Direct App Store Review URL (Guideline 5.6.1)

// ❌ REJECTION RISK — Opens App Store write-review URL directly, bypassing system controls
struct BadDirectReviewLink: View {
    var body: some View {
        Button("Leave a Review") {
            // ❌ Deep-linking directly to write-review bypasses Apple's 3-per-year cap
            // and is treated as an attempt to manipulate review counts
            if let url = URL(string: "itms-apps://itunes.apple.com/app/id123456789?action=write-review") {
                UIApplication.shared.open(url)
            }
        }
    }
}

// ✅ CORRECT — Use SKStoreReviewController for in-app prompts; deep link only for App Store page (not write-review)
struct GoodAppStoreLink: View {
    var body: some View {
        // ✅ Linking to the App Store page (without action=write-review) is acceptable for "View in App Store"
        Link("View in App Store",
             destination: URL(string: "itms-apps://itunes.apple.com/app/id123456789")!)
        // ✅ Review prompt is handled separately via ReviewRequestManager at milestones
    }
}
