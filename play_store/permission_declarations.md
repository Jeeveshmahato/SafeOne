# Sensitive permission declarations (Play Console)

SafeOne requests several permissions Google reviews manually. For each, paste the
justification below into the relevant declaration form. Keep the in-app
"prominent disclosure" wording consistent with these.

---

## 1. Background location (ACCESS_BACKGROUND_LOCATION) — REQUIRES declaration + video
**Why the app needs it (paste):**
"SafeOne is a personal-safety app. When a user triggers a hands-free SOS (shake,
volume or power button) or a scheduled safety check-in deadline passes, the app
must include the user's current location in the emergency alert even when the app
is closed or the screen is locked. Background location is read only at that moment
to build a map link for the alert the user sends to their chosen emergency
contacts. Location is not transmitted to any server and is not used for any other
purpose."

**Also required:**
- A short screen-recording demo showing the prominent in-app disclosure, the
  runtime permission request, and the background-location use during an SOS.
- A **prominent disclosure** screen in-app shown BEFORE requesting "Allow all the
  time", e.g.: *"SafeOne uses your location in the background to include it in
  emergency SOS and check-in alerts when the app is closed or locked. Your
  location is only added to messages you send and is never uploaded."*

## 2. Foreground service – special use (FOREGROUND_SERVICE_SPECIAL_USE)
**PROPERTY_SPECIAL_USE_FGS_SUBTYPE / console justification (paste):**
"A persistent foreground service is required to detect the user's hands-free
emergency triggers (rapid shake, triple volume-press, triple power-press) using
device sensors and broadcasts while the screen is locked or the app is
backgrounded — exactly the situations in which a person in danger cannot open the
app. No other foreground service type fits: the service's purpose is emergency
trigger monitoring, not media, location tracking, data sync, phone call, or
connected device. Location is only read opportunistically at the moment an SOS is
sent."
> Note: if Google rejects `specialUse`, the fallback is to change the service
> type to `location` in the manifest and ensure ACCESS_FINE_LOCATION is granted
> before the service starts (see app notes — this previously caused a startup
> failure on some OEMs and must be re-tested).

## 3. Full-screen intent (USE_FULL_SCREEN_INTENT)
**Justification (paste):**
"SafeOne provides a scheduled 'fake call' safety feature and a full-screen
emergency SOS prompt that must appear over the lock screen, like an incoming
phone call or alarm, so the user can act immediately in a dangerous situation."

## 4. Exact alarms (SCHEDULE_EXACT_ALARM / USE_EXACT_ALARM)
**Justification (paste):**
"Exact alarms are required to (a) ring the user's scheduled 'fake call' at the
precise time they set as a safety exit strategy, and (b) trigger the safety
check-in SOS at the exact deadline if the user has not marked themselves safe.
Approximate timing would undermine both safety features."

## 5. REQUEST_IGNORE_BATTERY_OPTIMIZATIONS
**Justification / risk note:**
This is the most likely to be flagged. The app only *asks* the user to exempt it
so OEM battery managers do not kill the scheduled fake call / check-in SOS. If
Google objects, you can remove the permission and instead deep-link the user to
battery settings without the direct exemption request. Keep the wording: "needed
so emergency alerts are not delayed or cancelled by battery optimization."

---

## In-app prominent disclosure checklist
- [ ] Location disclosure shown before the "Allow all the time" prompt.
- [ ] Microphone/camera explained at first use.
- [ ] Each disclosure is dismissible and states data is never uploaded.
