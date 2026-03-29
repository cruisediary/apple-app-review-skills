// PushNotificationPatterns.swift
// apple-app-review-skills — examples/swift/
//
// Anti-patterns that cause App Store rejection for push notification violations.
// References: skills/quality/push-notification-audit.md, references/guidelines/4-design.md
//
// Guideline: 4.5.5 Push Notifications

import UIKit
import UserNotifications

// MARK: - Push Permission at Launch (Guideline 4.5.5)

// ❌ REJECTION RISK — Requesting push permission at app launch with no context
@main
class BadAppDelegate: UIResponder, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // ❌ Requesting permission immediately on launch before any user interaction
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { _, _ in }
        return true
    }
}

// ✅ CORRECT — Request push permission in context, when a notification-driven feature is first used
class GoodNotificationManager {
    static func requestPermissionForOrderUpdates() {
        // ✅ Called when user places first order — the context explains the value
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { granted, _ in
            if granted {
                DispatchQueue.main.async { UIApplication.shared.registerForRemoteNotifications() }
            }
        }
    }
}

// MARK: - Marketing Content in Push (Guideline 4.5.5)

// ❌ REJECTION RISK — Push notification body contains promotional/ad content
class BadNotificationScheduler {
    func schedulePromo() {
        let content = UNMutableNotificationContent()
        content.title = "🔥 Limited Time Offer!"
        content.body = "50% OFF — Today only! Upgrade to Premium now." // ❌ promotional content without separate opt-in
        content.sound = .default

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 3600, repeats: false)
        let request = UNNotificationRequest(identifier: "promo_push", content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request)
    }
}

// ✅ CORRECT — Only send transactional/utility notifications via standard push
//              Add a separate opt-in for promotional notifications
class GoodNotificationScheduler {
    private var promotionalPushEnabled: Bool {
        // ✅ Separate user preference for marketing notifications (distinct from system permission)
        UserDefaults.standard.bool(forKey: "promotionalPushEnabled")
    }

    func scheduleOrderReady(orderNumber: String) {
        // ✅ Transactional notification — directly tied to user action, always appropriate
        let content = UNMutableNotificationContent()
        content.title = "Your order is ready"
        content.body = "Order #\(orderNumber) is ready for pickup."
        content.sound = .default

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(identifier: "order_\(orderNumber)", content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request)
    }

    func schedulePromo(message: String) {
        guard promotionalPushEnabled else { return } // ✅ only send if user opted into marketing
        let content = UNMutableNotificationContent()
        content.title = "Special offer"
        content.body = message
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(identifier: "promo_\(UUID())", content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request)
    }
}

// MARK: - Missing Notification Delegate (Guideline 2.1)

// ❌ REJECTION RISK — Push registered but tap responses never handled (broken implementation)
class BadAppDelegateNoDelegate: UIResponder, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert]) { _, _ in }
        application.registerForRemoteNotifications()
        // ❌ No delegate set — notification taps silently do nothing
        return true
    }
}

// ✅ CORRECT — Always set the delegate and handle notification responses
class GoodAppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        UNUserNotificationCenter.current().delegate = self // ✅ set delegate before app finishes launching
        return true
    }

    // ✅ Handle notification tap — navigate to the relevant screen
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                 didReceive response: UNNotificationResponse,
                                 withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        if let orderId = userInfo["order_id"] as? String {
            navigateToOrder(orderId)
        }
        completionHandler()
    }

    // ✅ Show notification banner even when app is in foreground
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                 willPresent notification: UNNotification,
                                 withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner, .sound])
    }

    private func navigateToOrder(_ orderId: String) { /* navigate */ }
}

// MARK: - Pre-Permission Prompt (Best Practice)

// ✅ BEST PRACTICE — Show an in-app explanation before requesting system permission
struct NotificationPrePermissionView: View {
    @Binding var isPresented: Bool
    var onAllow: () -> Void

    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "bell.badge")
                .font(.system(size: 48))
                .foregroundStyle(.blue)
            Text("Stay updated on your orders")
                .font(.title2.bold())
            Text("We'll notify you when your order is ready and when it ships. No spam, ever.")
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
            Button("Enable Notifications") {
                isPresented = false
                onAllow() // ✅ System prompt appears after user has seen the value proposition
            }
            .buttonStyle(.borderedProminent)
            Button("Not Now") { isPresented = false }
                .foregroundStyle(.secondary)
        }
        .padding()
    }
}

import SwiftUI
