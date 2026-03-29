// AIDisclosurePatterns.swift
// apple-app-review-skills — examples/swift/
//
// Anti-patterns that cause App Store rejection for undisclosed AI data sharing.
// References: skills/privacy/ai-data-disclosure.md, references/guidelines/5-legal.md
//
// Guideline: 5.1.2(i) Third-Party AI Data Sharing, 1.6.1 Data Security

import SwiftUI
import Foundation

// MARK: - Sending User Data to AI Without Consent (Guideline 5.1.2(i))

// ❌ REJECTION RISK — Sends user message to OpenAI with no disclosure or consent
class BadChatViewModel: ObservableObject {
    @Published var response = ""

    func sendMessage(_ userText: String) {
        // ❌ Transmitting user content to third-party AI with zero in-app notice
        var request = URLRequest(url: URL(string: "https://api.openai.com/v1/chat/completions")!)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body: [String: Any] = [
            "model": "gpt-4o",
            "messages": [["role": "user", "content": userText]] // ❌ user data sent silently
        ]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        URLSession.shared.dataTask(with: request) { data, _, _ in
            // handle response
        }.resume()
    }

    let apiKey = "sk-..."
}

// ✅ CORRECT — Show AI disclosure before first use; gate API call on consent
class GoodChatViewModel: ObservableObject {
    @Published var response = ""
    @Published var showAIDisclosure = false

    private var aiConsentGranted: Bool {
        UserDefaults.standard.bool(forKey: "aiDataSharingConsented")
    }

    func sendMessage(_ userText: String) {
        guard aiConsentGranted else {
            // ✅ Block AI call until user has seen and accepted the disclosure
            showAIDisclosure = true
            return
        }
        callOpenAI(userText)
    }

    func userAcceptedAIDisclosure() {
        UserDefaults.standard.set(true, forKey: "aiDataSharingConsented")
        showAIDisclosure = false
    }

    private func callOpenAI(_ text: String) {
        var request = URLRequest(url: URL(string: "https://api.openai.com/v1/chat/completions")!)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body: [String: Any] = [
            "model": "gpt-4o",
            "messages": [["role": "user", "content": text]]
        ]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        URLSession.shared.dataTask(with: request) { _, _, _ in }.resume()
    }

    let apiKey = "sk-..."
}

// ✅ CORRECT — AI Disclosure Sheet (required UI before first AI API call)
struct AIDataDisclosureSheet: View {
    var onAccept: () -> Void
    var onDecline: () -> Void

    var body: some View {
        VStack(spacing: 20) {
            Text("AI-Powered Replies")
                .font(.headline)

            Text("""
                To generate smart replies, your messages are sent to OpenAI's servers \
                and processed by their AI model. OpenAI may retain data per their \
                privacy policy. No messages are stored by us.
                """)
                .font(.body)
                .multilineTextAlignment(.center)

            // ✅ Link to both your privacy policy AND OpenAI's
            Link("Our Privacy Policy", destination: URL(string: "https://example.com/privacy")!)
            Link("OpenAI Privacy Policy", destination: URL(string: "https://openai.com/policies/privacy-policy")!)

            HStack(spacing: 16) {
                Button("Decline", action: onDecline)
                    .foregroundStyle(.secondary)
                Button("Allow AI Replies", action: onAccept)
                    .buttonStyle(.borderedProminent)
            }
        }
        .padding()
    }
}

// MARK: - Sensitive Data + AI (Heightened disclosure required)

// ❌ REJECTION RISK — Sends health data to AI without explicit opt-in
import HealthKit

class BadHealthAIService {
    func analyzeHeartRate(_ samples: [HKQuantitySample]) {
        let values = samples.map { $0.quantity.doubleValue(for: .count().unitDivided(by: .minute())) }
        // ❌ Health data sent to external AI — requires explicit consent beyond standard privacy policy
        sendToAI("Analyze these heart rate values: \(values)")
    }

    private func sendToAI(_ prompt: String) {
        // calls OpenAI API without health-data-specific disclosure
    }
}

// ✅ CORRECT — Gate health AI on a dedicated, health-specific consent
class GoodHealthAIService {
    private var healthAIConsentGranted: Bool {
        // ✅ Separate consent key for sensitive-category AI sharing
        UserDefaults.standard.bool(forKey: "healthDataAIConsented")
    }

    func analyzeHeartRate(_ samples: [HKQuantitySample], completion: @escaping (String?) -> Void) {
        guard healthAIConsentGranted else {
            completion(nil) // ✅ refuse to send until health-specific consent obtained
            return
        }
        let values = samples.map { $0.quantity.doubleValue(for: .count().unitDivided(by: .minute())) }
        sendToAI("Analyze these heart rate values: \(values)", completion: completion)
    }

    private func sendToAI(_ prompt: String, completion: @escaping (String?) -> Void) {
        // AI call only after explicit health data consent
    }
}

// MARK: - On-Device AI — No disclosure required

import CoreML
import NaturalLanguage

// ✅ SAFE — On-device inference via Core ML does not trigger 5.1.2(i)
class OnDeviceSentimentAnalyzer {
    let tagger = NLTagger(tagSchemes: [.sentimentScore])

    func sentiment(for text: String) -> Double {
        tagger.string = text
        let (tag, _) = tagger.tag(at: text.startIndex, unit: .paragraph, scheme: .sentimentScore)
        return Double(tag?.rawValue ?? "0") ?? 0
    }
    // ✅ No network call, no third-party SDK — no AI disclosure needed
}
