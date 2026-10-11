import 'package:shared_preferences/shared_preferences.dart';

/// Saves and loads app settings ON THE PHONE.
///
/// Right now it only stores one setting: how many seconds the SOS countdown
/// lasts. It works just like [ContactsRepository] but for simple numbers.
class SettingsRepository {
  static const String _countdownKey = 'countdown_seconds';
  static const String _shakeKey = 'shake_enabled';
  static const String _messageKey = 'sos_message';
  static const String _silentSosKey = 'silent_sos';
  static const String _liveUpdatesKey = 'live_updates';
  static const String _volumeTriggerKey = 'volume_trigger';
  static const String _powerTriggerKey = 'power_trigger';
  static const String _liveSharingActiveKey = 'live_sharing_active';
  static const String _fakeCallRingtoneKey = 'fake_call_ringtone_uri';
  // Read natively by the safety service ("off" | "active" | "always").
  static const String _shutdownAlertKey = 'shutdown_alert_mode';
  static const String defaultShutdownAlert = 'active';
  // The last "on" choice, so switching off and on again keeps it.
  static const String _shutdownScopeKey = 'shutdown_alert_scope';

  /// The values used if the user has never changed the settings.
  static const int defaultCountdownSeconds = 5;
  static const bool defaultShakeEnabled = false;
  static const bool defaultSilentSos = false;
  static const bool defaultLiveUpdates = true;
  static const bool defaultVolumeTrigger = false;
  static const bool defaultPowerTrigger = false;

  /// The default SOS text. The word {location} is replaced with a live map
  /// link when the alert is sent.
  /// Keep in sync with SosSender.DEFAULT_SOS (Android).
  static const String defaultSosMessage =
      'I need help right now. This is where I am: {location}';

  /// What the default SOS says when the phone can't get any location.
  static const String defaultSosMessageNoLocation =
      "I need help right now. My phone couldn't find my location, please call me.";

  /// Earlier default texts: anyone who never changed theirs gets the new one.
  static const Set<String> _oldDefaultSosMessages = {
    'EMERGENCY! I need help. My current location: {location}',
  };

  /// Read the chosen countdown length (in seconds).
  Future<int> loadCountdownSeconds() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_countdownKey) ?? defaultCountdownSeconds;
  }

  /// Save a new countdown length (in seconds).
  Future<void> saveCountdownSeconds(int seconds) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_countdownKey, seconds);
  }

  /// Read whether "shake to send SOS" is turned on.
  Future<bool> loadShakeEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_shakeKey) ?? defaultShakeEnabled;
  }

  /// Save whether "shake to send SOS" is turned on.
  Future<void> saveShakeEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_shakeKey, enabled);
  }

  /// Read the SOS message template (may contain the {location} placeholder).
  Future<String> loadSosMessage() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_messageKey);
    // Fall back to the default if nothing is saved or it was cleared to empty.
    if (saved == null ||
        saved.trim().isEmpty ||
        _oldDefaultSosMessages.contains(saved)) {
      return defaultSosMessage;
    }
    return saved;
  }

  /// Save a new SOS message template.
  Future<void> saveSosMessage(String message) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_messageKey, message);
  }

  /// When on, the SOS sends with no vibration confirmation (stealth).
  Future<bool> loadSilentSos() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_silentSosKey) ?? defaultSilentSos;
  }

  Future<void> saveSilentSos(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_silentSosKey, enabled);
  }

  /// When on, the app keeps sending location updates after an SOS until the
  /// user marks themselves safe.
  Future<bool> loadLiveUpdates() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_liveUpdatesKey) ?? defaultLiveUpdates;
  }

  Future<void> saveLiveUpdates(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_liveUpdatesKey, enabled);
  }

  /// When on, triple-pressing a volume button starts the SOS.
  Future<bool> loadVolumeTrigger() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_volumeTriggerKey) ?? defaultVolumeTrigger;
  }

  Future<void> saveVolumeTrigger(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_volumeTriggerKey, enabled);
  }

  /// When on, rapidly pressing the power button (3×) starts the SOS. Detected
  /// natively by the background safety service via screen on/off.
  Future<bool> loadPowerTrigger() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_powerTriggerKey) ?? defaultPowerTrigger;
  }

  Future<void> savePowerTrigger(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_powerTriggerKey, enabled);
  }

  /// Whether live location sharing is currently active. Persisted so the home
  /// screen still knows (and can stop it) after the app is closed and reopened.
  Future<bool> loadLiveSharingActive() async {
    final prefs = await SharedPreferences.getInstance();
    // The background service starts and ends sharing too.
    await prefs.reload();
    return prefs.getBool(_liveSharingActiveKey) ?? false;
  }

  Future<void> saveLiveSharingActive(bool active) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_liveSharingActiveKey, active);
  }

  /// When contacts are told the phone is being switched off: "active" (during
  /// an SOS with live sharing or a check-in), "always", or "off".
  Future<String> loadShutdownAlert() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_shutdownAlertKey) ?? defaultShutdownAlert;
  }

  Future<void> saveShutdownAlert(String mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_shutdownAlertKey, mode);
    if (mode != 'off') await prefs.setString(_shutdownScopeKey, mode);
  }

  /// What switching the alert back on restores: "active" or "always".
  Future<String> loadShutdownScope() async {
    final prefs = await SharedPreferences.getInstance();
    final mode = prefs.getString(_shutdownAlertKey);
    if (mode != null && mode != 'off') return mode;
    return prefs.getString(_shutdownScopeKey) ?? defaultShutdownAlert;
  }

  /// The ringtone picked for fake calls (a content URI), or null for the
  /// phone's own default ringtone.
  Future<String?> loadFakeCallRingtone() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_fakeCallRingtoneKey);
  }

  Future<void> saveFakeCallRingtone(String? uri) async {
    final prefs = await SharedPreferences.getInstance();
    if (uri == null) {
      await prefs.remove(_fakeCallRingtoneKey);
    } else {
      await prefs.setString(_fakeCallRingtoneKey, uri);
    }
  }

  /// The time the user last picked for a timer ([TimerPreset]), so the next
  /// one starts from it. [fallback] if never set.
  Future<Duration> loadTimerPreset(TimerPreset preset, Duration fallback) async {
    final prefs = await SharedPreferences.getInstance();
    final seconds = prefs.getInt('timer_preset_${preset.name}');
    return seconds == null || seconds <= 0
        ? fallback
        : Duration(seconds: seconds);
  }

  Future<void> saveTimerPreset(TimerPreset preset, Duration value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('timer_preset_${preset.name}', value.inSeconds);
  }
}

/// Timers whose last-picked length is remembered.
enum TimerPreset { checkin, followMeInterval, journeyEta, journeyInterval }
