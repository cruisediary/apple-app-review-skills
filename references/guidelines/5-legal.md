# App Store Review Guidelines — Section 5: Legal

Source: https://developer.apple.com/app-store/review/guidelines/#legal

## 5.1 Privacy

### 5.1.1 Data Collection and Storage

#### 5.1.1(i) Privacy Policy

A privacy policy is **required** for all apps:

> "All apps must include a link to their privacy policy in the App Store Connect metadata fields and within the app in an easily accessible manner."

The policy must be accessible both via the App Store listing and from within the app itself. A policy that is present in App Store Connect but not linkable/accessible inside the app is a rejection reason.

#### 5.1.1(ii) Permission Request Consent

Apps must obtain user consent before collecting personal data:

> "You must provide the system-provided permission request alert, and you may include a purpose string that explains the reason for the request."

- Purpose strings (NSUsageDescription keys) must **clearly and completely** describe how the data will be used
- Vague descriptions ("App needs access to improve your experience") are insufficient
- Paid features or core functionality **cannot depend on granting data access** — users must be able to use paid features without surrendering data

#### 5.1.1(iii) Data Minimization

> "Only request access to data relevant to the core functionality of your app."

Apps must not collect data beyond what is needed for the features the user actively uses. Requesting permissions speculatively ("we might need this later") violates this requirement.

#### 5.1.1(iv) Data Safety

Apps must take reasonable steps to protect personal data from unauthorized access, use, or disclosure:

> "Apps should only transmit user or usage data over encrypted connections. Apps that store personal or sensitive user data must use appropriate encryption."

Personal data must be transmitted over HTTPS. Apps that store sensitive data (passwords, tokens, health data) locally must use encrypted storage (Keychain, encrypted Core Data, etc.). Cleartext transmission of credentials or personal data is a rejection reason.

#### 5.1.1(v) Account Sign-In and Deletion

- Apps must not require login if no significant account-based features exist
- Apps offering account creation **must also provide in-app account deletion**

> In-app account deletion has been required since **June 30, 2022**. Apps that allow account creation but do not provide a mechanism to delete the account within the app will be rejected.

### 5.1.2 Data Use and Sharing

#### 5.1.2(i) Tracking and ATT

> "Apps cannot use or transmit data about a user's device without their consent."

Apps that perform cross-app or cross-site tracking **must** use Apple's App Tracking Transparency (ATT) framework and request permission via `ATTrackingManager.requestTrackingAuthorization` before accessing the IDFA or performing any tracking. Using device fingerprinting or other workarounds to track users without ATT authorization is prohibited.

### 5.1.5 Location Services

Location data may only be collected when directly relevant to the app's core features:

> "Don't use location data for anything other than providing the requested service."

Apps must notify users and obtain consent before collecting location data. Using location in the background when the user has only granted foreground access is a violation.

---

## Enforcement Dates (Important)

| Requirement | Enforcement Date |
|---|---|
| In-app account deletion | June 30, 2022 |
| PrivacyInfo.xcprivacy manifest (required reason APIs) | May 1, 2024 |

**PrivacyInfo.xcprivacy** — Since May 1, 2024, apps that use any of Apple's "required reason" APIs (e.g., file timestamp APIs, system boot time, disk space, keyboard APIs, UserDefaults) must declare the reason in a `PrivacyInfo.xcprivacy` manifest. Missing or incomplete manifests produce the ITMS-91053 error and block submission.
