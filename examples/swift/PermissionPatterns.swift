// PermissionPatterns.swift
// apple-app-review-skills — examples/swift/
//
// Anti-patterns that cause App Store rejection due to permission handling.
// References: skills/permissions/, references/guidelines/5-legal.md
//
// Guideline: 5.1.1(ii) Permission, 5.1.1(iii) Data Minimization

import UIKit
import CoreLocation
import Photos
import Contacts
import AppTrackingTransparency

// MARK: - Permission Request Timing (Guideline 5.1.1(ii))

// ❌ REJECTION RISK — Guideline 5.1.1(ii): Permission requested at launch before any user context
@main
class BadAppDelegate: UIResponder, UIApplicationDelegate {
    let locationManager = CLLocationManager()
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        locationManager.requestWhenInUseAuthorization() // ❌ before user sees any UI
        return true
    }
}

// ✅ CORRECT — Request permission at the point of use with context
class MapViewController: UIViewController {
    let locationManager = CLLocationManager()

    @IBAction func showNearbyButtonTapped(_ sender: UIButton) {
        // User just tapped "Find Nearby" — context is clear WHY location is needed
        locationManager.requestWhenInUseAuthorization()
    }
}

// MARK: - Permission Scope (Guideline 5.1.1(iii))

// ❌ REJECTION RISK — Guideline 5.1.1(iii): Requesting Always location when WhenInUse suffices
class BadLocationManager: NSObject, CLLocationManagerDelegate {
    let manager = CLLocationManager()

    func startTracking() {
        manager.requestAlwaysAuthorization() // ❌ unless app is navigation/fitness/delivery
    }
}

// ✅ CORRECT — Request minimum necessary location access
class GoodLocationManager: NSObject, CLLocationManagerDelegate {
    let manager = CLLocationManager()

    func startTracking() {
        manager.requestWhenInUseAuthorization() // ✅ sufficient for most use cases
    }
}

// ❌ REJECTION RISK — Guideline 5.1.1(iii): Full photo library access for single photo selection
class BadPhotoPickerViewController: UIViewController {
    func selectProfilePhoto() {
        PHPhotoLibrary.requestAuthorization(.readWrite) { status in // ❌ full library access
            if status == .authorized {
                // show image picker
            }
        }
    }
}

// ✅ CORRECT — Use PHPickerViewController (no permission required)
import PhotosUI
class GoodPhotoPickerViewController: UIViewController, PHPickerViewControllerDelegate {
    func selectProfilePhoto() {
        var config = PHPickerConfiguration()
        config.selectionLimit = 1
        config.filter = .images
        let picker = PHPickerViewController(configuration: config) // ✅ no permission dialog needed
        picker.delegate = self
        present(picker, animated: true)
    }
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)
    }
}

// ❌ REJECTION RISK — Guideline 5.1.1(iii): Full contacts access just to get one email
class BadContactsViewController: UIViewController {
    func getContactEmail() {
        let store = CNContactStore()
        store.requestAccess(for: .contacts) { granted, _ in // ❌ full contact book access
            guard granted else { return }
            // fetch all contacts to find one email
        }
    }
}

// ✅ CORRECT — Use CNContactPickerViewController (no permission required)
class GoodContactsViewController: UIViewController, CNContactPickerDelegate {
    func getContactEmail() {
        let picker = CNContactPickerViewController() // ✅ no permission dialog
        picker.predicateForEnablingContact = NSPredicate(format: "emailAddresses.@count > 0")
        picker.delegate = self
        present(picker, animated: true)
    }
    func contactPicker(_ picker: CNContactPickerViewController, didSelect contact: CNContact) {
        let email = contact.emailAddresses.first?.value as String?
        // use email
    }
}

// MARK: - Usage Description Quality (Guideline 5.1.1(ii))

// ❌ REJECTION RISK — Generic usage descriptions are rejected by App Store review
// In Info.plist:
// NSCameraUsageDescription = "App needs camera access" ❌ — too generic
// NSLocationWhenInUseUsageDescription = "For location" ❌ — too vague

// ✅ CORRECT — Specific, user-friendly descriptions
// NSCameraUsageDescription = "Your camera is used to scan QR codes for joining events and to upload profile photos."
// NSLocationWhenInUseUsageDescription = "Your location helps us show nearby events and calculate distances in search results."
