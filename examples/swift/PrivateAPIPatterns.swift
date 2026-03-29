// PrivateAPIPatterns.swift
// apple-app-review-skills — examples/swift/
//
// Anti-patterns that cause App Store rejection for private API usage.
// References: skills/quality/private-api-audit.md, references/guidelines/2-performance.md
//
// Guideline: 2.5.1 Public APIs Only

import UIKit
import ObjectiveC.runtime

// MARK: - Private Class Access via NSClassFromString (Guideline 2.5.1)

// ❌ REJECTION RISK — Accessing private UIKit class at runtime
class BadVisualEffectHelper {
    func addPrivateBlurEffect(to view: UIView) {
        // ❌ _UIBackdropView is a private UIKit class — Apple's binary scanner flags this
        // Causes ITMS-90338 automated rejection before human review
        if let backdropClass = NSClassFromString("_UIBackdropView") as? UIView.Type {
            let backdropView = backdropClass.init(frame: view.bounds)
            view.addSubview(backdropView)
        }
    }
}

// ✅ CORRECT — Use public UIVisualEffectView for blur effects
class GoodVisualEffectHelper {
    func addBlurEffect(to view: UIView) {
        // ✅ Public API — UIVisualEffectView is fully documented and supported
        let blurEffect = UIBlurEffect(style: .systemMaterial)
        let blurView = UIVisualEffectView(effect: blurEffect)
        blurView.frame = view.bounds
        blurView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(blurView)
    }
}

// MARK: - Underscore-Prefixed Private Methods (Guideline 2.5.1)

// ❌ REJECTION RISK — Calling private UIDevice method via performSelector
class BadFeatureDetector {
    func checkForceTouch() -> Bool {
        let device = UIDevice.current
        // ❌ _supportsForceTouch is a private method — binary scanner detects it
        // Even via performSelector, the symbol reference is visible in the binary
        let selector = NSSelectorFromString("_supportsForceTouch")
        if device.responds(to: selector) {
            return device.perform(selector) != nil
        }
        return false
    }
}

// ✅ CORRECT — Use public traitCollection API for force touch / interaction capability detection
class GoodFeatureDetector {
    func checkForceTouchCapability(in viewController: UIViewController) -> Bool {
        // ✅ Public API — traitCollection is fully supported
        return viewController.traitCollection.forceTouchCapability == .available
    }
}

// MARK: - Method Swizzling on System Classes (Guideline 2.5.1)

// ❌ REJECTION RISK — Swizzling UIViewController to track all view appearances
class BadAnalyticsSetup {
    static func setupTracking() {
        // ❌ Swizzling Apple system classes is fragile and may be flagged as private API abuse
        // Breaks across iOS versions, bypasses intended behavior, risks binary rejection
        let originalMethod = class_getInstanceMethod(UIViewController.self, #selector(UIViewController.viewDidAppear(_:)))
        let swizzledMethod = class_getInstanceMethod(UIViewController.self, #selector(UIViewController.swizzled_viewDidAppear(_:)))
        if let original = originalMethod, let swizzled = swizzledMethod {
            method_exchangeImplementations(original, swizzled) // ❌ swizzling UIViewController
        }
    }
}

extension UIViewController {
    @objc func swizzled_viewDidAppear(_ animated: Bool) {
        swizzled_viewDidAppear(animated)
        Analytics.track(screen: String(describing: type(of: self))) // ❌ via swizzle
    }
}

// ✅ CORRECT — Subclass or use protocol-based tracking without swizzling
class TrackedViewController: UIViewController {
    // ✅ Subclass and override — no runtime manipulation
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        Analytics.track(screen: String(describing: type(of: self)))
    }
}

// ✅ CORRECT — Use environment or SwiftUI view modifier for analytics without swizzling
import SwiftUI

struct ScreenTrackingModifier: ViewModifier {
    let screenName: String

    func body(content: Content) -> some View {
        content
            .onAppear { Analytics.track(screen: screenName) } // ✅ no swizzling required
    }
}

extension View {
    func trackScreen(_ name: String) -> some View {
        modifier(ScreenTrackingModifier(screenName: name))
    }
}

// MARK: - Dynamic Library Loading (Guideline 2.5.1)

// ❌ REJECTION RISK — dlopen of private framework
class BadDynamicLoader {
    func loadPrivateFramework() {
        // ❌ dlopen with a private framework path triggers ITMS-90338 at upload
        let handle = dlopen("/System/Library/PrivateFrameworks/SpringBoardServices.framework/SpringBoardServices", RTLD_NOW)
        if handle == nil {
            print("Failed to load: \(String(cString: dlerror()))")
        }
    }
}

// ✅ CORRECT — Use only public frameworks via standard imports
// If you need system service integration, check for a public API equivalent:
// - SpringBoard interactions → use UIKit/UIApplication public APIs
// - System preferences → use Settings bundle
// - Background tasks → use BackgroundTasks framework (BGTaskScheduler)

// MARK: - Stub helpers

struct Analytics {
    static func track(screen: String) { }
}
