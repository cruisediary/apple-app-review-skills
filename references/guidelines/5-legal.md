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

#### 5.1.2(i) Tracking, ATT, and Third-Party AI Data Sharing

> "Apps cannot use or transmit data about a user's device without their consent."

**App Tracking Transparency (ATT):**
Apps that perform cross-app or cross-site tracking **must** use Apple's App Tracking Transparency framework and request permission via `ATTrackingManager.requestTrackingAuthorization` before accessing the IDFA or performing any tracking. Using device fingerprinting or other workarounds to track users without ATT authorization is prohibited.

**Third-Party AI Data Sharing (enforced from 2023; Guideline 1.6.1):**
Apps that transmit user data to third-party AI services (OpenAI, Google Gemini, Anthropic, and similar) must:

1. Disclose the AI data sharing explicitly within the app — before the first API call occurs
2. Obtain explicit user consent (not just a generic "we share data with partners" clause in the privacy policy)
3. Name the specific AI provider(s) in the privacy policy
4. For sensitive data categories (health, messages, location, financial), require a separate, category-specific opt-in

A generic privacy policy mentioning "third-party services" is insufficient. The disclosure must be specific, actionable, and presented in-app before data is sent.

On-device ML processing using Core ML, Create ML, or Apple's on-device frameworks (Vision, NaturalLanguage, Sound Analysis) does **not** require this disclosure — only external API calls trigger the requirement.

### 5.1.5 Location Services

Location data may only be collected when directly relevant to the app's core features:

> "Don't use location data for anything other than providing the requested service."

Apps must notify users and obtain consent before collecting location data. Using location in the background when the user has only granted foreground access is a violation.

---

## 5.6 App Store Reviews and Ratings

### 5.6.1 Manipulating Reviews

> "You may not use mechanisms to artificially inflate or manipulate your app's reviews and ratings."

Prohibited practices:

- **Review gating:** Asking users if they are satisfied, then only showing the `SKStoreReviewController` prompt to those who respond positively — while routing unsatisfied users to a feedback form instead. All users must have equal access to the system review prompt.
- **Button-triggered prompts:** Calling `SKStoreReviewController.requestReview()` directly from a "Rate Us" button tap. Review requests must be triggered at appropriate moments in the user journey, not as a direct response to user action.
- **Incentivized reviews:** Offering rewards, unlocks, or benefits in exchange for leaving a review.
- **Direct write-review deep links:** Using `itms-apps://...?action=write-review` bypasses Apple's system controls and is treated as manipulation.

**Apple's system cap:** `SKStoreReviewController.requestReview()` is silently rate-limited to 3 prompts per 365-day period per user. Apps cannot override this cap. Calls beyond the limit are ignored.

**Correct usage pattern:** Trigger `requestReview()` programmatically at natural positive moments — after completing a task, after a meaningful session milestone, or after a positive user-initiated event. Implement a local rate-limiting guard (e.g., minimum 120 days between prompts) in addition to Apple's system cap.

---

## Enforcement Dates (Important)

| Requirement | Enforcement Date |
|---|---|
| In-app account deletion | June 30, 2022 |
| PrivacyInfo.xcprivacy manifest (required reason APIs) | May 1, 2024 |

**PrivacyInfo.xcprivacy** — Since May 1, 2024, apps that use any of Apple's "required reason" APIs (e.g., file timestamp APIs, system boot time, disk space, keyboard APIs, UserDefaults) must declare the reason in a `PrivacyInfo.xcprivacy` manifest. Missing or incomplete manifests produce the ITMS-91053 error and block submission.
