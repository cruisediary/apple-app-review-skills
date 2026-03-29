# App Store Review Guidelines — Section 1: Safety

Source: https://developer.apple.com/app-store/review/guidelines/#safety

## 1.1 Objectionable Content

Apps may not contain content that is offensive, insensitive, upsetting, intended to disgust, or in exceptionally poor taste. Apple will reject content that depicts realistic portrayals of people or animals being killed, maimed, tortured, or abused; or content with sustained portrayals of cruelty or torture.

## 1.2 User Generated Content (UGC)

Apps with user-generated content present particular challenges. Apple requires that all such apps include:

> "...a method for filtering objectionable material from being posted to the app, a mechanism to report offensive content and timely responses to concerns, the ability to block abusive users from the service, and published contact information so users can easily reach you."

Specifically, apps with UGC **must** provide all four of the following or face rejection:

**(a) Filter objectionable material** — Implement content filtering to prevent offensive material from being posted.

**(b) Report and respond mechanism** — Users must be able to report offensive content. The developer must respond to reports in a timely manner.

**(c) Block abusive users** — Users must be able to block other users who behave abusively.

**(d) Published contact information** — Developer contact information must be accessible within the app so users can reach support.

Failure to implement any one of these four requirements is grounds for rejection.

## 1.4 Physical Harm / Medical Apps

Apps offering medical advice or health data must be from licensed medical providers or institutions. Apps that could provide incorrect data and endanger health or safety will be rejected. Medical apps that may impact physical health require extra scrutiny.

## 1.5 Developer Information

Apps must provide accurate contact information and not mislead users about the developer's identity or qualifications.

## 1.6 Data Security

Apps must implement appropriate security measures to protect user data:

> "Apps should implement appropriate security measures to ensure proper handling of user information collected pursuant to your Privacy Policy and applicable law."

### 1.6.1 Third-Party AI Data Sharing

Apps that share user data with third-party AI systems must disclose this and obtain explicit user permission:

> "Apps that use third-party AI services must disclose this to users and get their permission before sharing any data with such services."

Apps integrating external AI APIs (OpenAI, Google Gemini, Anthropic, etc.) must:

1. Present an explicit in-app disclosure before the first API call — naming the AI provider and describing what data is sent
2. Obtain affirmative user consent (not buried in a generic privacy policy)
3. Disclose the AI data sharing specifically by name in the privacy policy
4. For sensitive data categories (health, messages, location), require a separate opt-in

This requirement was introduced as part of Apple's expanded AI governance posture in 2023–2024 and is enforced under both 1.6.1 and 5.1.2(i). On-device processing via Core ML or Apple's on-device frameworks does not trigger this requirement.
