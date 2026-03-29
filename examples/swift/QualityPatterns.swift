// QualityPatterns.swift
// apple-app-review-skills — examples/swift/
//
// Anti-patterns that cause App Store rejection due to quality issues.
// References: skills/quality/, references/guidelines/2-performance.md
//
// Guideline: 2.1 (App Completeness)

import UIKit
import SwiftUI

// MARK: - Crash Risk (Guideline 2.1)

// ❌ REJECTION RISK — Guideline 2.1: Force unwrap crashes when server returns nil
struct APIResponse {
    var user: User?
}
struct User {
    let id: String
    let name: String
}

class BadProfileViewController: UIViewController {
    var response: APIResponse?

    func displayUser() {
        let user = response!.user! // ❌ crashes if response is nil OR user is nil
        titleLabel.text = user.name
    }

    let titleLabel = UILabel()
}

// ✅ CORRECT — Safe unwrapping with guard
class GoodProfileViewController: UIViewController {
    var response: APIResponse?

    func displayUser() {
        guard let response = response, let user = response.user else {
            showEmptyState()
            return
        }
        titleLabel.text = user.name
    }

    func showEmptyState() { }
    let titleLabel = UILabel()
}

// ❌ REJECTION RISK — Guideline 2.1: Force cast crashes when view controller type is wrong
class BadNavigationHelper {
    func getProfileVC(from storyboard: UIStoryboard) -> UIViewController {
        return storyboard.instantiateViewController(withIdentifier: "Profile") as! ProfileVC // ❌ crash if identifier is wrong
    }
}
class ProfileVC: UIViewController {}

// ✅ CORRECT — Use conditional cast with fallback
class GoodNavigationHelper {
    func getProfileVC(from storyboard: UIStoryboard) -> UIViewController {
        guard let vc = storyboard.instantiateViewController(withIdentifier: "Profile") as? ProfileVC else {
            assertionFailure("ProfileVC not found — check storyboard identifier")
            return UIViewController()
        }
        return vc
    }
}

// ❌ REJECTION RISK — Guideline 2.1: UI update on background thread causes crash/visual glitch
class BadDataLoader {
    let tableView: UITableView = UITableView()
    var items: [String] = []

    func loadData() {
        URLSession.shared.dataTask(with: URL(string: "https://api.example.com/items")!) { data, _, _ in
            self.items = ["Item 1", "Item 2"]
            self.tableView.reloadData() // ❌ UI update on background thread — crash or visual corruption
        }.resume()
    }
}

// ✅ CORRECT — UI updates always on main thread
class GoodDataLoader {
    let tableView: UITableView = UITableView()
    var items: [String] = []

    func loadData() {
        URLSession.shared.dataTask(with: URL(string: "https://api.example.com/items")!) { [weak self] data, _, _ in
            guard let self = self else { return }
            self.items = ["Item 1", "Item 2"]
            DispatchQueue.main.async { // ✅ UI update on main thread
                self.tableView.reloadData()
            }
        }.resume()
    }
}

// MARK: - App Completeness (Guideline 2.1)

// ❌ REJECTION RISK — Guideline 2.1: Placeholder text visible to reviewer
struct BadOnboardingView: View {
    var body: some View {
        VStack {
            Text("Lorem ipsum dolor sit amet") // ❌ placeholder text — immediate rejection
            Text("TODO: add real description") // ❌ development note exposed
            Button("Get Started") { }
        }
    }
}

// ✅ CORRECT — All content is final production copy
struct GoodOnboardingView: View {
    var body: some View {
        VStack {
            Text("Discover events near you, connect with your community, and never miss what matters.")
            Button("Get Started") { }
        }
    }
}

// ❌ REJECTION RISK — Guideline 2.1: Version number signals incomplete app
// In project.pbxproj:
// MARKETING_VERSION = 0.1; ❌ sub-1.0 signals beta/incomplete to reviewer

// ✅ CORRECT
// MARKETING_VERSION = 1.0; ✅ signals production-ready

// MARK: - Review Readiness (Guideline 2.1)

// ❌ REJECTION RISK — Guideline 2.1: Backend points to staging/localhost during App Store review
struct BadAPIConfig {
    static let baseURL = "http://localhost:3000/api" // ❌ 404 during App Store review — backend unreachable
}

// ✅ CORRECT — Production URL active during review
struct GoodAPIConfig {
    static let baseURL = "https://api.yourapp.com/v1" // ✅ production endpoint, active during review
}

// ❌ REJECTION RISK — Guideline 2.1: App requires login but no demo credentials provided to reviewer
// In App Review Notes (App Store Connect), always include:
// Demo Account: reviewer@yourapp.com
// Password: AppReview2024!
// Note: This account has sample data loaded for all features
