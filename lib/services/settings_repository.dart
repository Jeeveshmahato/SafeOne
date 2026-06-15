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

  /// The values used if the user has never changed the settings.
  static const int defaultCountdownSeconds = 5;
  static const bool defaultShakeEnabled = false;
  static const bool defaultSilentSos = false;
  static const bool defaultLiveUpdates = true;
  static const bool defaultVolumeTrigger = false;
  static const bool defaultPowerTrigger = false;

  /// The default SOS text. The word {location} is replaced with a live map
  /// link when the alert is sent.
  static const String defaultSosMessage =
      'EMERGENCY! I need help. My current location: {location}';

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
    if (saved == null || saved.trim().isEmpty) {
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
    return prefs.getBool(_liveSharingActiveKey) ?? false;
  }

  Future<void> saveLiveSharingActive(bool active) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_liveSharingActiveKey, active);
  }
}
