# SafeOne — Google Play release checklist

## ✅ Already done (in the code/repo)
- [x] Application ID set to `com.safeone.app` (no more com.example).
- [x] Upload keystore created: `android/upload-keystore.jks` (alias `upload`).
- [x] `android/key.properties` wired into release signing (gitignored).
- [x] SEND_SMS removed; SOS uses the system SMS composer (Play-compliant).
- [x] targetSdk / compileSdk = 35 (meets new-app requirement).
- [x] Release `.aab` builds & is signed with the upload key.

## 🔐 Protect your keys (do this NOW)
- [ ] Back up `android/upload-keystore.jks` AND the passwords somewhere safe
      (password manager + offline copy). **If you lose it you can never update
      the app.** Passwords are in `android/key.properties`.

## 🎨 Assets to create
- [ ] Replace the default Flutter launcher icon with a real SafeOne icon
      (use `flutter_launcher_icons` or Android Studio Image Asset). The default
      icon looks unprofessional and weakens review.
- [ ] 512x512 app icon, 1024x500 feature graphic, 2–8 phone screenshots
      (see store_listing.md).

## 📄 Console content
- [ ] Host `privacy_policy.html` at a public URL (GitHub Pages, your site, etc.)
      and note the URL.
- [ ] Fill Store listing using `store_listing.md`.
  - Choose `Lifestyle` category only.
  - Do not declare the app as a Health/Medical app if you are publishing from a personal developer account.
- [ ] Fill Data Safety using `data_safety_form.md`.
- [ ] Complete content rating questionnaire (answer location-sharing truthfully).
- [ ] Submit sensitive-permission declarations using `permission_declarations.md`
      (background location needs a demo video; specialUse FGS needs justification).
- [ ] Add the in-app prominent disclosure for background location BEFORE the
      "Allow all the time" prompt (see permission_declarations.md). *Code change —
      ask if you want this added.*

## 🏷️ Versioning for future updates
- Current: `version: 1.0.0+1` in pubspec.yaml. For each new upload bump the build
  number (the `+N`), e.g. `1.0.1+2`. Play rejects a re-used versionCode.

## 🚀 Submission flow
- [ ] Pay the one-time **$25** Google Play developer registration.
- [ ] (New personal accounts) Run **closed testing with 12+ testers for 14 days**
      before production access is unlocked.
- [ ] Upload `build/app/outputs/bundle/release/app-release.aab`.
- [ ] Enroll in **Play App Signing** when prompted (recommended — Google manages
      the app signing key; your upload key just signs uploads).
- [ ] Roll out to Internal testing → Closed → Production.

## ⚠️ Test before submitting
- [ ] Install the release build on a device and verify the new SMS-intent SOS
      flow: trigger SOS → Messages app opens pre-filled with the maps link.
- [ ] Verify the background-trigger "tap to send SOS" notification appears and
      opens the composer (shake/volume/power, check-in deadline).
