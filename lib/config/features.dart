/// Feature flags for Play Store release gating.
///
/// v1.0 ships with high-risk permissions disabled to ensure a smooth first
/// review on a new developer account. Flip a flag to true, bump the version
/// in pubspec.yaml, and upload a new .aab to re-enable the feature.
///
/// Disabled for v1.0 (require Special Use FGS / background location review):
///   - backgroundTriggers  (shake / volume / power SOS via foreground service)
///   - backgroundLocation  (live location sharing after SOS)
///   - safetyCheckin       (auto-deadline SOS via scheduled alarm)
///   - followMe            (periodic location SMS while travelling)
///
/// Always-on for v1.0 (no sensitive permissions needed):
///   - manualSos, silentSos, sirenFlashlight, audioRecording, fakeCall,
///     nearbyPlaces, emergencyContacts, emergencyId, helplines, safetyTips
class Features {
  Features._();

  // ── v1.0: OFF ──────────────────────────────────────────────────────────────

  /// Shake / volume-triple-press / power-triple-press SOS triggers.
  /// Requires the always-on foreground service (Special Use FGS declaration).
  static const bool backgroundTriggers = true;

  /// Live location sharing that continues after an SOS (foreground service +
  /// background location permission).
  static const bool backgroundLocation = true;

  /// Safety check-in timer that auto-sends SOS if you don't confirm safe
  /// arrival (uses foreground service scheduled alarm).
  static const bool safetyCheckin = true;

  /// "Follow Me" mode — periodic location SMS while travelling
  /// (foreground service + background location).
  static const bool followMe = true;

  // ── v1.0: ON ───────────────────────────────────────────────────────────────

  /// Manual & silent SOS button (opens SMS composer — no SEND_SMS permission).
  static const bool manualSos = true;

  /// Siren, flashlight, Morse SOS blink, audio recording.
  static const bool quickActions = true;

  /// Fake-call scheduler.
  static const bool fakeCall = true;

  /// Nearby hospitals / police via Maps search.
  static const bool nearbyPlaces = true;

  /// Emergency contacts management.
  static const bool emergencyContacts = true;

  /// Emergency ID, Medical card, QR code.
  static const bool emergencyProfile = true;

  /// Helplines, India emergency resources, police SOS portal.
  static const bool helplines = true;

  /// Safety tips and emergency protocols.
  static const bool safetyTips = true;

  /// Danger zones map.
  static const bool dangerZones = true;

  /// One-tap location share (opens share sheet — no background permission).
  static const bool shareLocation = true;

  /// "I'm Safe" check-in message to contacts (no timer/alarm).
  static const bool imSafe = true;

  /// Safety event log.
  static const bool eventLog = true;
}
