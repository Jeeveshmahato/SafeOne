# Play Console → Data Safety form answers (SafeOne)

Fill the Data Safety section exactly as below. SafeOne has no backend, so the
core answer is: **we do not collect or share any data.** Be precise — Google
cross-checks this against your APK's permissions.

## ⚠️ Fix the live listing (October 2026)
The published listing currently says *"This app may collect: Personal info, Audio
and Contacts"* and *"Data can't be deleted"*. That doesn't match the app: SafeOne
has no server and no network SDKs (no Firebase, analytics, ads or HTTP calls). It
only opens other apps (Messages, Maps, Dialer) via `url_launcher`.

Play Console → **Policy and programs → App content → Data safety → Manage**:
1. Data collection and security → *Does your app collect or share any of the
   required user data types?* → **No**.
2. Remove every data type that was ticked (Personal info, Audio, Contacts).
3. Save → Submit. The listing will then show **"No data collected"** and
   **"No data shared with third parties"**.
4. Make sure the privacy policy URL (App content → Privacy policy) is
   `https://jeeveshmahato.github.io/SafeOne/privacy.html`.

## Data collection & sharing (top-level)
- **Does your app collect or share any of the required user data types?**
  → **No.**
  (All data is processed on-device only and never sent to you or a third party.
  The SOS SMS (with location) goes from the user's phone straight to the
  emergency contacts the user added. That is not "collected" (the app has no
  server and nothing reaches the developer) and not "shared" in Play's
  definition, because it's a transfer the user initiates (SOS button, trigger,
  check-in or live sharing they turned on) to recipients they chose and
  reasonably expect to receive it.)

- **Is all of the user data encrypted in transit?**
  → Not applicable / Yes (no data is transmitted by the app to any server).

- **Do you provide a way for users to request that their data be deleted?**
  → Data is stored only on-device; users delete it in-app or by uninstalling.
  Provide the privacy policy URL which states this.

## If the form forces you to declare processed-on-device types
If Google's flow asks about data "accessed" even when not collected, declare each
as **processed ephemerally / on-device, not collected, not shared**:

| Data type | Collected? | Shared? | Purpose | Notes |
|-----------|-----------|---------|---------|-------|
| Approximate/precise location | No | No | App functionality (safety alerts) | Only inserted into a message the user themselves sends; never sent to us |
| Phone numbers (emergency contacts) | No | No | App functionality | Entered by user, stored locally |
| Photos / audio (evidence) | No | No | App functionality | Saved locally, user-controlled |
| Audio recordings (microphone) | No | No | App functionality | Local files only |

## Security practices to declare
- Data is **encrypted in transit**: N/A (no transmission) — or "Yes".
- Users can **request deletion**: Yes (on-device, via uninstall/clear).
- Committed to Play **Families policy**: only if you target children (you do not).

## Privacy policy URL
Host `privacy_policy.html` (see below) and paste the public URL here. This URL is
**mandatory**.
