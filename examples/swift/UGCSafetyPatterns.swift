// UGCSafetyPatterns.swift
// apple-app-review-skills — examples/swift/
//
// Anti-patterns that cause App Store rejection for apps with User-Generated Content.
// References: skills/ugc/, references/guidelines/1-safety.md
//
// Guideline: 1.2 User-Generated Content, 4.7.1

import UIKit
import SwiftUI

// MARK: - Report/Block on Feed (Guideline 1.2)

// ❌ REJECTION RISK — Guideline 1.2: Post cell with no report/block action
// Apple Developer Forums Thread #116703: rejected for missing report mechanism
struct BadPostCell: View {
    let post: Post

    var body: some View {
        VStack(alignment: .leading) {
            Text(post.authorName).font(.headline)
            Text(post.content)
            HStack {
                Button("Like") { }
                Button("Comment") { }
                // ❌ No "Report" or "Block" action
            }
        }
    }
}

// ✅ CORRECT — Include report/block in post context menu
struct GoodPostCell: View {
    let post: Post
    @State private var showReportSheet = false

    var body: some View {
        VStack(alignment: .leading) {
            Text(post.authorName).font(.headline)
            Text(post.content)
            HStack {
                Button("Like") { }
                Button("Comment") { }
            }
        }
        .contextMenu {
            Button(role: .destructive) {
                showReportSheet = true
            } label: {
                Label("Report Post", systemImage: "flag")
            }
            Button(role: .destructive) {
                // block user
            } label: {
                Label("Block \(post.authorName)", systemImage: "hand.raised")
            }
        }
        .sheet(isPresented: $showReportSheet) {
            ReportContentView(contentId: post.id, contentType: .post)
        }
    }
}

// MARK: - Report/Block on Profile (Guideline 1.2)

// ❌ REJECTION RISK — Guideline 1.2: User profile with no moderation actions
struct BadUserProfileView: View {
    let user: User

    var body: some View {
        VStack {
            AsyncImage(url: user.avatarURL)
            Text(user.displayName).font(.title)
            Text(user.bio)
            Button("Follow") { }
            // ❌ No report or block option on profile
        }
    }
}

// ✅ CORRECT — Report/block accessible from profile
struct GoodUserProfileView: View {
    let user: User
    @State private var showReportSheet = false
    @State private var showBlockConfirmation = false

    var body: some View {
        VStack {
            AsyncImage(url: user.avatarURL)
            Text(user.displayName).font(.title)
            Text(user.bio)
            Button("Follow") { }
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu {
                    Button("Report User", role: .destructive) {
                        showReportSheet = true
                    }
                    Button("Block User", role: .destructive) {
                        showBlockConfirmation = true
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
            }
        }
        .sheet(isPresented: $showReportSheet) {
            ReportContentView(contentId: user.id, contentType: .user)
        }
        .confirmationDialog("Block \(user.displayName)?", isPresented: $showBlockConfirmation) {
            Button("Block", role: .destructive) {
                // call block API
            }
        }
    }
}

// MARK: - EULA Acceptance (Guideline 1.2)

// ❌ REJECTION RISK — Guideline 1.2: No terms agreement in onboarding
class BadOnboardingViewController: UIViewController {
    @IBAction func signUpTapped(_ sender: UIButton) {
        // ❌ skips terms — no EULA, no UGC policy agreement
        navigateToHome()
    }
    func navigateToHome() {}
}

// ✅ CORRECT — Require EULA agreement before accessing UGC features
class GoodOnboardingViewController: UIViewController {
    @IBOutlet weak var termsCheckbox: UISwitch!
    @IBOutlet weak var signUpButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        signUpButton.isEnabled = false
        termsCheckbox.addTarget(self, action: #selector(termsToggled), for: .valueChanged)
    }

    @objc func termsToggled() {
        signUpButton.isEnabled = termsCheckbox.isOn
    }

    @IBAction func signUpTapped(_ sender: UIButton) {
        guard termsCheckbox.isOn else { return }
        // proceed with signup — user agreed to terms of service + community guidelines
        navigateToHome()
    }
    func navigateToHome() {}
}

// MARK: - Supporting Types
struct Post { let id: String; let authorName: String; let content: String }
struct User { let id: String; let displayName: String; let bio: String; let avatarURL: URL? }
enum ContentType { case post, comment, user }
struct ReportContentView: View {
    let contentId: String; let contentType: ContentType
    var body: some View { Text("Report") }
}
