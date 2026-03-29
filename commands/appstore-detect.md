# App Store Project Detection

Quick terminal commands to inspect your iOS project before running a full audit.

## Project Info
Run !`find . -name "Info.plist" -not -path "*/Pods/*" -not -path "*/.build/*"` to locate Info.plist files.
Run !`find . -name "PrivacyInfo.xcprivacy" -not -path "*/Pods/*"` to check Privacy Manifest existence.
Run !`find . -name "*.xcodeproj" -o -name "*.xcworkspace" | head -5` to identify project type.

## iOS Version & Build Config
Run !`grep -r "IPHONEOS_DEPLOYMENT_TARGET\|MARKETING_VERSION\|CURRENT_PROJECT_VERSION" . --include="*.pbxproj" | head -10` to check deployment target and version.
Run !`find . -name "Info.plist" -not -path "*/Pods/*" | head -1 | xargs plutil -convert json -o - | python3 -c "import sys,json; d=json.load(sys.stdin); print('Name:', d.get('CFBundleDisplayName', d.get('CFBundleName'))); print('Version:', d.get('CFBundleShortVersionString')); print('Bundle ID:', d.get('CFBundleIdentifier'))"` to show app name, version, and bundle ID.

## Permissions Summary
Run !`find . -name "Info.plist" -not -path "*/Pods/*" | head -1 | xargs plutil -convert json -o - | python3 -c "import sys,json; [print(k, '=', repr(v[:60])+'...') for k,v in json.load(sys.stdin).items() if 'UsageDescription' in k]"` to list all permission descriptions.
Run !`grep -rn "requestAuthorization\|requestWhenInUseAuthorization\|requestAlwaysAuthorization\|requestTrackingAuthorization" . --include="*.swift" | wc -l` to count permission requests.

## Privacy Manifest
Run !`find . -name "PrivacyInfo.xcprivacy" -not -path "*/Pods/*"` to check if PrivacyInfo.xcprivacy exists (required since May 2024).
Run !`grep -rn "UserDefaults\|identifierForVendor\|mach_absolute_time" . --include="*.swift" | grep -v "//" | wc -l` to count required-reason API usages.

## Account Deletion (Required since June 2022)
Run !`grep -rn "deleteAccount\|Delete Account\|destroyAccount" . --include="*.swift"` to check account deletion implementation.

## IAP & Subscriptions
Run !`grep -rn "StoreKit\|SKPayment\|Product.purchase" . --include="*.swift" | wc -l` to check StoreKit usage.
Run !`grep -rn "Stripe\|PayPal\|paypal\|braintree" . --include="*.swift" -i` to check for prohibited external payments.

## UGC Safety
Run !`grep -rn "reportContent\|reportUser\|blockUser\|Report\b" . --include="*.swift" | grep -v "//"` to check report/block mechanisms.

## Crash Risk
Run !`grep -rn " as! \|try!" . --include="*.swift" | grep -v "//" | wc -l` to count force casts and force try.
