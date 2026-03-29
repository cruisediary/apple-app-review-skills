// SubscriptionPatterns.swift
// apple-app-review-skills — examples/swift/
//
// Anti-patterns that cause App Store rejection for subscription and IAP implementations.
// References: skills/business/, references/guidelines/3-business.md
//
// Guideline: 3.1.1 (In-App Purchase), 3.1.2(c) (Subscription Information)

import SwiftUI
import StoreKit

// MARK: - Subscription Disclosure (Guideline 3.1.2(c))

// ❌ REJECTION RISK — Guideline 3.1.2(c): Discount percentage shown prominently, actual price hidden
// Apple Developer Forums #127616: "50% OFF" displayed at 24pt, "$9.99/mo" at 10pt gray text
struct BadPaywallView: View {
    var body: some View {
        VStack(spacing: 16) {
            Text("50% OFF TODAY ONLY") // ❌ discount is the hero
                .font(.largeTitle)
                .foregroundColor(.red)
            Text("$9.99/month") // ❌ actual price small and de-emphasized
                .font(.caption)
                .foregroundColor(.gray)
            Button("Subscribe") { }
            // ❌ no mention of auto-renewal
            // ❌ no mention of what happens after any trial
            // ❌ no cancellation instructions
        }
    }
}

// ✅ CORRECT — Actual price prominent, all required disclosures present
struct GoodPaywallView: View {
    let product: Product

    var body: some View {
        VStack(spacing: 16) {
            Text("Go Premium")
                .font(.title)

            // ✅ Actual price is the hero — prominent size and weight
            Text(product.displayPrice + "/month")
                .font(.title2.bold())

            // ✅ Discount shown subordinate to actual price
            Text("50% off for your first 3 months")
                .font(.subheadline)
                .foregroundColor(.secondary)

            Button("Start Subscription") {
                Task { try? await product.purchase() }
            }

            // ✅ All required disclosures present
            VStack(alignment: .leading, spacing: 4) {
                Text("• Subscription renews automatically at \(product.displayPrice)/month")
                Text("• Cancel anytime in Settings > Apple ID > Subscriptions")
                Text("• Payment charged to your Apple ID account at confirmation")
            }
            .font(.caption)
            .foregroundColor(.secondary)
        }
    }
}

// ❌ REJECTION RISK — Guideline 3.1.2(c): Free trial with no post-trial amount shown
// RevenueCat Community: app rejected for not stating post-trial billing amount
struct BadTrialPaywallView: View {
    var body: some View {
        VStack {
            Text("Try free for 7 days") // ❌ no mention of what happens after 7 days
                .font(.title)
            Button("Start Free Trial") { }
        }
    }
}

// ✅ CORRECT — Trial end and post-trial amount clearly stated
struct GoodTrialPaywallView: View {
    let product: Product

    var body: some View {
        VStack(spacing: 12) {
            Text("Try free for 7 days")
                .font(.title)

            // ✅ Exactly what happens after trial — required disclosure
            Text("Then \(product.displayPrice)/month, auto-renewing")
                .font(.subheadline)
                .foregroundColor(.secondary)

            Button("Start Free Trial") {
                Task { try? await product.purchase() }
            }

            Text("Cancel before \(trialEndDate()) to avoid being charged.")
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }

    func trialEndDate() -> String {
        let date = Calendar.current.date(byAdding: .day, value: 7, to: Date()) ?? Date()
        return DateFormatter.localizedString(from: date, dateStyle: .medium, timeStyle: .none)
    }
}

// MARK: - IAP Compliance (Guideline 3.1.1)

// ❌ REJECTION RISK — Guideline 3.1.1: External payment for digital content
// purchasely.com: Stripe for in-app subscription rejected immediately
import UIKit
class BadPurchaseViewController: UIViewController {
    func purchasePremium() {
        // ❌ Stripe/PayPal for digital subscription — immediate rejection
        // STPPaymentHandler.sharedHandler.confirmPayment(...)
        openWebViewPayment()
    }
    func openWebViewPayment() {
        // ❌ WKWebView showing payment page to bypass IAP — also rejected
    }
}

// ✅ CORRECT — StoreKit for all digital purchases
class GoodPurchaseViewController: UIViewController {
    func purchasePremium() async throws {
        let products = try await Product.products(for: ["com.example.app.premium"])
        guard let product = products.first else { return }
        let result = try await product.purchase()
        switch result {
        case .success(let verification):
            // validate and unlock
            break
        case .userCancelled, .pending:
            break
        @unknown default:
            break
        }
    }

    // ✅ Required: restore purchases for non-consumable IAP
    func restorePurchases() async throws {
        try await AppStore.sync()
    }
}

// MARK: - Loot Box Disclosure (Guideline 3.1.1)

// ❌ REJECTION RISK — Guideline 3.1.1: Gacha/loot box with no odds disclosure
struct BadGachaView: View {
    var body: some View {
        VStack {
            Text("Mystery Box")
            Text("$0.99") // ❌ no odds shown before purchase
            Button("Open Box") { } // ❌ purchase without odds disclosure
        }
    }
}

// ✅ CORRECT — Odds disclosed before purchase
struct GoodGachaView: View {
    var body: some View {
        VStack(spacing: 12) {
            Text("Mystery Box")
            Text("$0.99")

            // ✅ Drop rates shown before purchase — required by Guideline 3.1.1
            VStack(alignment: .leading, spacing: 4) {
                Text("Drop Rates:").font(.headline)
                Text("⭐⭐⭐ Rare item: 5%")
                Text("⭐⭐ Uncommon item: 20%")
                Text("⭐ Common item: 75%")
            }
            .font(.caption)
            .padding()
            .background(Color.secondary.opacity(0.1))
            .cornerRadius(8)

            Button("Purchase Mystery Box") { } // purchase after odds shown
        }
    }
}
