# Women Safety App

A Flutter (Android-first) personal-safety app: one-tap SOS, hands-free triggers
that work with the screen locked, live location sharing, scheduled fake calls,
and quick access to India emergency/complaint resources.

## Core features

### Emergency
- **SOS button** — cancellable countdown, then sends your location + message by
  SMS to your emergency contacts. **Long-press** = silent/stealth SOS.
- **Hands-free SOS (works when locked / app closed)** — shake, triple-press
  volume, or triple-press power. Backed by an always-on foreground service
  ("Safety mode active"); toggle each in Settings.
- **Quick actions** — siren, flashlight / SOS-blink, audio recording.

### Share & track
- **Live Tracking** hub — *Follow Me* (sends your location to contacts on a
  repeating timer, keeps running in the background) and *Journey Safe* (track a
  trip to a destination with ETA + auto-SOS if you don't arrive).
- **Share location** — one-off share of your current location.
- **Safety check-in timer** — auto-sends an SOS if you don't tap "I'm safe"
  before the timer ends.
- **I'm Safe** — sends a "reached safely" message and stops live sharing.

### Get help
- **Helplines** + **India Emergency Resources** (emergency numbers, online-fraud
  guides, and **government complaint portals**). The portals tab has a
  **"Copy my live location"** button so you can paste your location straight into
  a complaint form.
- **Nearby help** — find nearby police/hospitals.
- **Fake call** — schedule realistic incoming calls (single or several at once;
  each editable/cancelable) that ring even when the app is closed or locked.

### My info & records
- **Emergency profile**, **medical info**, **emergency QR/ID**.
- **Contacts** (all + quick favourites).
- **Safety Log** — a single, real, persisted log of SOS alerts, check-ins,
  location shares and incidents you log by hand. Export/share or clear it.

### Privacy
- App lock (PIN + optional biometric); hidden behind a decoy calculator.

## Notes for testers (Android)
- Install the APK from `Downloads`, allow "install from unknown sources", and tap
  "Install anyway" if Play Protect warns (normal for non-Play-Store apps).
- In the app, open **Settings → Background setup** and grant: Location
  ("Allow all the time"), SMS, Notifications, battery **unrestricted**, exact
  alarms, and full-screen / display-over-apps. These make background calls and
  the locked-screen SOS reliable.
- ⚠️ The SOS triggers send a **real SMS** to your emergency contacts — add a test
  number before trying them.

## iOS
Not currently distributed. Sharing an iOS build with friends requires the Apple
Developer Program ($99/yr) + TestFlight, and several core features (background
SMS, the always-on SOS service, full-screen fake calls, volume/power triggers)
are blocked by iOS.

## Build
```sh
flutter pub get
flutter build apk --release   # build/app/outputs/flutter-apk/app-release.apk
```
