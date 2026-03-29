// LayoutPatterns.swift
// apple-app-review-skills — examples/swift/
//
// Anti-patterns that cause App Store rejection due to layout issues.
// References: skills/layout/, references/hig/adaptive-layout.md
//
// Guidelines: 2.1 (App Completeness), 2.4.1 (Hardware Compatibility), HIG

import UIKit
import SwiftUI

// MARK: - iPad Layout (Guideline 2.1, 2.4.1)

// ❌ REJECTION RISK — Guideline 2.4.1: Hardcoded iPhone screen width causes overflow on iPad Air
// App Store reviewers use iPad Air — layout breaks when width != 375
class BadLayoutViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        let card = UIView(frame: CGRect(x: 0, y: 100, width: 375, height: 200))
        view.addSubview(card)
    }
}

// ✅ CORRECT — Use Auto Layout with proportional sizing
class GoodLayoutViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        let card = UIView()
        card.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(card)
        NSLayoutConstraint.activate([
            card.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
            card.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor),
            card.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 100),
            card.heightAnchor.constraint(equalToConstant: 200)
        ])
    }
}

// ❌ REJECTION RISK — Guideline 2.4.1: iPad idiom not handled — layout breaks on iPad split view
func configureSidebar() {
    if UIDevice.current.userInterfaceIdiom == .phone {
        // show bottom sheet
    }
    // iPad gets nothing — blank screen for reviewer
}

// ✅ CORRECT — Handle all idioms explicitly
func configureSidebarFixed() {
    switch UIDevice.current.userInterfaceIdiom {
    case .phone:
        break // show bottom sheet
    case .pad:
        break // show sidebar / split view
    default:
        break // show bottom sheet as fallback
    }
}

// MARK: - Safe Area (HIG)

// ❌ REJECTION RISK — HIG: Hardcoded status bar / home indicator insets break on Dynamic Island devices
struct BadSafeAreaView: View {
    var body: some View {
        VStack {
            Spacer().frame(height: 44) // hardcoded status bar height — wrong on Dynamic Island
            Text("Content")
            Spacer().frame(height: 34) // hardcoded home indicator — wrong on older devices
        }
    }
}

// ✅ CORRECT — Use safeAreaInsets
struct GoodSafeAreaView: View {
    var body: some View {
        VStack {
            Text("Content")
        }
        .ignoresSafeArea(.keyboard) // only ignore keyboard, not device chrome
    }
}

// ❌ REJECTION RISK — HIG: ignoresSafeArea(.all) hides content behind Dynamic Island
struct BadIgnoreSafeAreaView: View {
    var body: some View {
        ZStack {
            Color.blue.ignoresSafeArea(.all) // background is fine
            Text("Important action") // this also gets hidden behind Dynamic Island
                .ignoresSafeArea(.all) // ❌ content hidden behind device chrome
        }
    }
}

// ✅ CORRECT — Only ignore safe area for background elements
struct GoodIgnoreSafeAreaView: View {
    var body: some View {
        ZStack {
            Color.blue.ignoresSafeArea() // background fills edge to edge
            Text("Important action") // respects safe area — visible on all devices
        }
    }
}

// MARK: - Dynamic Type (HIG)

// ❌ REJECTION RISK — HIG: Fixed font size ignores user's accessibility text size setting
class BadFontViewController: UIViewController {
    let titleLabel = UILabel()
    override func viewDidLoad() {
        super.viewDidLoad()
        titleLabel.font = UIFont.systemFont(ofSize: 17, weight: .semibold) // fixed — doesn't scale
    }
}

// ✅ CORRECT — Use UIFontMetrics to support Dynamic Type
class GoodFontViewController: UIViewController {
    let titleLabel = UILabel()
    override func viewDidLoad() {
        super.viewDidLoad()
        let baseFont = UIFont.systemFont(ofSize: 17, weight: .semibold)
        titleLabel.font = UIFontMetrics(forTextStyle: .body).scaledFont(for: baseFont)
        titleLabel.adjustsFontForContentSizeCategory = true
        titleLabel.numberOfLines = 0 // allow wrapping at large sizes
    }
}

// ❌ REJECTION RISK — HIG: Fixed-height container clips text at large Dynamic Type sizes
struct BadFixedHeightView: View {
    var body: some View {
        Text("User name")
            .frame(height: 44) // clips at accessibility XXL sizes
    }
}

// ✅ CORRECT — Use flexible height
struct GoodFlexibleHeightView: View {
    var body: some View {
        Text("User name")
            .frame(minHeight: 44) // minimum height, grows with content
    }
}
