// BackgroundExecutionPatterns.swift
// apple-app-review-skills — examples/swift/
//
// Anti-patterns that cause App Store rejection for background execution abuse.
// References: skills/quality/background-execution-audit.md, references/guidelines/2-performance.md
//
// Guideline: 2.5.3 Background Execution

import UIKit
import AVFoundation
import BackgroundTasks
import CoreMotion
import CoreLocation

// MARK: - Silent Audio Keep-Alive (Guideline 2.5.3)

// ❌ REJECTION RISK — Playing silent audio to keep app alive in background
class BadAudioKeepAlive {
    var player: AVAudioPlayer?

    func startSilentAudio() {
        // ❌ Declaring 'audio' background mode + playing silence = prohibited keep-alive abuse
        // Apple's reviewers specifically test for this pattern
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch { }

        // ❌ Playing a 1-second silent file on repeat to block system suspension
        if let url = Bundle.main.url(forResource: "silence", withExtension: "mp3") {
            player = try? AVAudioPlayer(contentsOf: url)
            player?.volume = 0.0       // ❌ zero volume — silent audio
            player?.numberOfLoops = -1 // ❌ infinite loop
            player?.play()
        }
    }
}

// ✅ CORRECT — Use BGTaskScheduler for background processing; audio mode only for audible content
class GoodBackgroundManager {
    static let refreshTaskIdentifier = "com.example.app.refresh"

    static func registerBackgroundTasks() {
        // ✅ Register BGAppRefreshTask for periodic lightweight background work
        BGTaskScheduler.shared.register(forTaskWithIdentifier: refreshTaskIdentifier, using: nil) { task in
            guard let refreshTask = task as? BGAppRefreshTask else { return }
            handleAppRefresh(task: refreshTask)
        }
    }

    static func scheduleAppRefresh() {
        let request = BGAppRefreshTaskRequest(identifier: refreshTaskIdentifier)
        request.earliestBeginDate = Date(timeIntervalSinceNow: 15 * 60) // earliest 15 min from now
        try? BGTaskScheduler.shared.submit(request)
    }

    private static func handleAppRefresh(task: BGAppRefreshTask) {
        scheduleAppRefresh() // schedule next refresh
        task.expirationHandler = { task.setTaskCompleted(success: false) }
        // do lightweight work here
        task.setTaskCompleted(success: true) // ✅ signal completion
    }
}

// MARK: - Location Background for Step Counting (Guideline 2.5.3)

// ❌ REJECTION RISK — Using CoreLocation background mode for step counting
class BadStepTracker: NSObject, CLLocationManagerDelegate {
    let locationManager = CLLocationManager()

    func startTracking() {
        // ❌ Requesting Always authorization + background location mode to keep app alive
        // for step counting — CoreMotion/CMPedometer is the correct API for this
        locationManager.requestAlwaysAuthorization()
        locationManager.allowsBackgroundLocationUpdates = true // ❌ location used as keep-alive
        locationManager.startUpdatingLocation()
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        // ❌ Location updates used only to trigger step counting logic — misuse of background location
        countSteps()
    }

    private func countSteps() { /* step counting logic */ }
}

// ✅ CORRECT — Use CMPedometer for step counting (no background location required)
class GoodStepTracker {
    let pedometer = CMPedometer()

    func startTracking() {
        guard CMPedometer.isStepCountingAvailable() else { return }
        // ✅ CMPedometer works in the background without declaring location background mode
        pedometer.startUpdates(from: Date()) { data, error in
            guard let data = data, error == nil else { return }
            print("Steps: \(data.numberOfSteps)")
        }
    }

    func stopTracking() {
        pedometer.stopUpdates()
    }
}

// MARK: - VoIP Background Mode Without CallKit (Guideline 2.5.3)

// ❌ REJECTION RISK — voip background mode used for persistent socket, no CallKit
class BadSocketManager {
    // ❌ Declared UIBackgroundModes: [voip] in Info.plist to keep socket alive
    // but no CallKit (CXProvider) integration exists — voip mode misused as keep-alive
    var socket: URLSessionWebSocketTask?

    func connect() {
        let session = URLSession(configuration: .default)
        socket = session.webSocketTask(with: URL(string: "wss://example.com/chat")!)
        socket?.resume()
        // ❌ voip mode keeps this socket alive but no telephone-like functionality exists
    }
}

// ✅ CORRECT — Use BGProcessingTask for persistent work; CallKit required for voip mode
import CallKit

class GoodVoIPCallManager: NSObject, CXProviderDelegate {
    let provider: CXProvider
    let callController = CXCallController()

    override init() {
        let config = CXProviderConfiguration()
        config.supportsVideo = false
        provider = CXProvider(configuration: config)
        super.init()
        provider.setDelegate(self, queue: nil) // ✅ CallKit delegate — voip mode is justified
    }

    func providerDidReset(_ provider: CXProvider) { }
    // ✅ Implement full CXProviderDelegate for incoming/outgoing calls
}

// ✅ CORRECT — For chat socket persistence, use BGProcessingTask (not voip)
class GoodChatBackgroundSync {
    static let processingTaskIdentifier = "com.example.app.chat-sync"

    static func registerBackgroundTasks() {
        BGTaskScheduler.shared.register(forTaskWithIdentifier: processingTaskIdentifier, using: nil) { task in
            guard let processingTask = task as? BGProcessingTask else { return }
            syncMessages(task: processingTask) // ✅ sync messages in background without voip abuse
        }
    }

    private static func syncMessages(task: BGProcessingTask) {
        task.expirationHandler = { task.setTaskCompleted(success: false) }
        // fetch new messages, update local store
        task.setTaskCompleted(success: true)
    }
}
