// PrivacyPatterns.swift
// apple-app-review-skills — examples/swift/
//
// Anti-patterns that cause App Store rejection for privacy compliance.
// References: skills/privacy/, references/guidelines/5-legal.md
//
// Guidelines: 5.1.1 (Privacy), 5.1.2 (Data Use & Sharing)

import SwiftUI
import AppTrackingTransparency
import AdSupport
// Firebase — add to your project via SPM: https://github.com/firebase/firebase-ios-sdk
// import Firebase

// MARK: - App Tracking Transparency (Guideline 5.1.2(i))

// ❌ REJECTION RISK — Guideline 5.1.2(i): Tracking analytics without ATT consent
// (Assumes Firebase SDK is added to project)
class BadAnalyticsManager {
    func setupAnalytics() {
        // FirebaseApp.configure() // ❌ tracking starts without ATT consent request
        // Analytics.logEvent("app_open", parameters: nil)
        print("Analytics started without ATT consent — REJECTION RISK")
    }
}

// ✅ CORRECT — Request ATT consent before any tracking
class GoodAnalyticsManager {
    func setupAnalytics() {
        Task {
            await requestTrackingPermission()
        }
    }

    @MainActor
    func requestTrackingPermission() async {
        let status = await ATTrackingManager.requestTrackingAuthorization()
        // Only configure analytics after user decision
        if status == .authorized {
            // FirebaseApp.configure()
            // Analytics.logEvent("app_open", parameters: nil)
            print("ATT authorized — analytics with full tracking")
        } else {
            // FirebaseApp.configure()
            // Do not send advertising identifiers
            print("ATT denied — analytics in limited mode only")
        }
    }
}

// MARK: - Account Deletion (Guideline 5.1.1(v))
// Required since June 30, 2022 — developer.apple.com/news/?id=12m75xbj

// ❌ REJECTION RISK — Guideline 5.1.1(v): Settings screen with only deactivation, no deletion
struct BadAccountSettingsView: View {
    var body: some View {
        List {
            Button("Edit Profile") { }
            Button("Change Password") { }
            Button("Deactivate Account") { } // ❌ deactivation ≠ deletion — Apple requires true deletion
            // ❌ no "Delete Account" option
        }
    }
}

// ✅ CORRECT — Permanent account deletion option required
struct GoodAccountSettingsView: View {
    @State private var showDeleteConfirmation = false

    var body: some View {
        List {
            Button("Edit Profile") { }
            Button("Change Password") { }
            Button("Deactivate Account") { }

            // ✅ True account deletion — permanently removes account and personal data
            Button("Delete Account", role: .destructive) {
                showDeleteConfirmation = true
            }
        }
        .confirmationDialog(
            "Delete your account?",
            isPresented: $showDeleteConfirmation,
            titleVisibility: .visible
        ) {
            Button("Delete Account and All Data", role: .destructive) {
                Task { await deleteAccountPermanently() }
            }
        } message: {
            Text("This permanently deletes your account and all associated data. This action cannot be undone.")
        }
    }

    func deleteAccountPermanently() async {
        // 1. Call DELETE /api/users/me on backend
        // 2. Sign out locally
        // 3. Clear all local data and keychain
    }
}

// MARK: - PrivacyInfo.xcprivacy (iOS 17+, enforced May 2024)

// ❌ REJECTION RISK — ITMS-91053: Using UserDefaults without declaring reason CA92.1
class BadSettingsManager {
    func saveUserPreference(_ value: Bool) {
        UserDefaults.standard.set(value, forKey: "notifications_enabled")
        // ❌ UserDefaults used but PrivacyInfo.xcprivacy not created, or CA92.1 reason not declared
    }
}

// ✅ CORRECT — Create PrivacyInfo.xcprivacy with required reason
// File: PrivacyInfo.xcprivacy (add to Xcode project target)
// Required content for UserDefaults usage:
/*
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>NSPrivacyAccessedAPITypes</key>
    <array>
        <dict>
            <key>NSPrivacyAccessedAPIType</key>
            <string>NSPrivacyAccessedAPICategoryUserDefaults</string>
            <key>NSPrivacyAccessedAPITypeReasons</key>
            <array>
                <string>CA92.1</string>  <!-- Access UserDefaults to read/write app preferences -->
            </array>
        </dict>
    </array>
</dict>
</plist>
*/
class GoodSettingsManager {
    func saveUserPreference(_ value: Bool) {
        UserDefaults.standard.set(value, forKey: "notifications_enabled")
        // ✅ PrivacyInfo.xcprivacy declares NSPrivacyAccessedAPICategoryUserDefaults with reason CA92.1
    }
}

// MARK: - Privacy Policy (Guideline 5.1.1(i))

// ❌ REJECTION RISK — Guideline 5.1.1(i): Privacy policy not accessible from within the app
struct BadSettingsView: View {
    var body: some View {
        List {
            Text("Notifications")
            Text("Theme")
            // ❌ no privacy policy link in-app — only added to App Store Connect
        }
    }
}

// ✅ CORRECT — Privacy policy linked from within the app
struct GoodSettingsView: View {
    var body: some View {
        List {
            Text("Notifications")
            Text("Theme")
            Section("Legal") {
                // ✅ Privacy policy accessible from within the app
                Link("Privacy Policy", destination: URL(string: "https://yourapp.com/privacy")!)
                Link("Terms of Service", destination: URL(string: "https://yourapp.com/terms")!)
            }
        }
    }
}
