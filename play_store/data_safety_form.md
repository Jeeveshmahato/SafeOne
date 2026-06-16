# Play Console → Data Safety form answers (SafeOne)

Fill the Data Safety section exactly as below. SafeOne has no backend, so the
core answer is: **we do not collect or share any data.** Be precise — Google
cross-checks this against your APK's permissions.

## Data collection & sharing (top-level)
- **Does your app collect or share any of the required user data types?**
  → **No.**
  (All data is processed on-device only and never sent to you or a third party.
  Location/messages the *user* sends via their own SMS app are not "collected"
  by your app in Play's definition, because your app has no server and does not
  transmit them to you.)

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
