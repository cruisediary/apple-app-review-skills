// swift-tools-version: 5.9
// This Package.swift exists solely to give SourceKit iOS platform context
// so that UIKit, SwiftUI, and AppTrackingTransparency resolve in editors.
// These files are documentation examples — they are not a distributable library.

import PackageDescription

let package = Package(
    name: "AppStorePatterns",
    platforms: [.iOS(.v16)],
    targets: [
        .target(name: "AppStorePatterns", path: ".")
    ]
)
