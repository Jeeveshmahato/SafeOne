import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../services/app_lock_service.dart';
import '../services/locale_controller.dart';
import '../services/safety_monitor_service.dart';
import '../services/settings_repository.dart';
import '../widgets/duration_field.dart';
import 'pin_setup_screen.dart';

/// Screen where the user changes app settings.
///
/// For now it has one setting: how many seconds the SOS countdown lasts.
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final SettingsRepository _settings = SettingsRepository();
  final AppLockService _lock = AppLockService();

  int? _selectedSeconds; // null until we have loaded the saved value
  bool _shakeEnabled = SettingsRepository.defaultShakeEnabled;
  bool _silentSos = SettingsRepository.defaultSilentSos;
  bool _liveUpdates = SettingsRepository.defaultLiveUpdates;
  bool _volumeTrigger = SettingsRepository.defaultVolumeTrigger;
  bool _powerTrigger = SettingsRepository.defaultPowerTrigger;
  bool _biometricEnabled = false;
  bool _biometricAvailable = false;
  int _graceSeconds = AppLockService.defaultGraceSeconds;

  // Controls the text the user types for the SOS message.
  final TextEditingController _messageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final seconds = await _settings.loadCountdownSeconds();
    final shake = await _settings.loadShakeEnabled();
    final message = await _settings.loadSosMessage();
    final silent = await _settings.loadSilentSos();
    final live = await _settings.loadLiveUpdates();
    final volume = await _settings.loadVolumeTrigger();
    final power = await _settings.loadPowerTrigger();
    final biometricOn = await _lock.isBiometricEnabled();
    final biometricAvailable = await _lock.canUseBiometrics();
    final grace = await _lock.loadGraceSeconds();
    if (!mounted) return;
    setState(() {
      _selectedSeconds = seconds;
      _shakeEnabled = shake;
      _messageController.text = message;
      _silentSos = silent;
      _liveUpdates = live;
      _volumeTrigger = volume;
      _powerTrigger = power;
      _biometricEnabled = biometricOn;
      _biometricAvailable = biometricAvailable;
      _graceSeconds = grace;
    });
  }

  Future<void> _changePin() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const PinSetupScreen(requireCurrent: true),
      ),
    );
  }

  Future<void> _setBiometric(bool enabled) async {
    if (enabled && !await _lock.canUseBiometrics()) return;
    await _lock.setBiometricEnabled(enabled);
    setState(() => _biometricEnabled = enabled);
  }

  Future<void> _setGrace(int seconds) async {
    setState(() => _graceSeconds = seconds);
    await _lock.saveGraceSeconds(seconds);
  }

  Future<void> _setSilentSos(bool v) async {
    setState(() => _silentSos = v);
    await _settings.saveSilentSos(v);
  }

  Future<void> _setLiveUpdates(bool v) async {
    setState(() => _liveUpdates = v);
    await _settings.saveLiveUpdates(v);
  }

  Future<void> _setVolumeTrigger(bool v) async {
    setState(() => _volumeTrigger = v);
    await _settings.saveVolumeTrigger(v);
    await _syncMonitor();
  }

  Future<void> _setPowerTrigger(bool v) async {
    setState(() => _powerTrigger = v);
    await _settings.savePowerTrigger(v);
    await _syncMonitor();
  }

  /// Start/stop the always-on safety service to match the enabled triggers.
  Future<void> _syncMonitor() => SafetyMonitorService.sync(
        shake: _shakeEnabled,
        volume: _volumeTrigger,
        power: _powerTrigger,
      );

  Future<void> _saveMessage(String message) async {
    await _settings.saveSosMessage(message);
  }

  Future<void> _select(int seconds) async {
    setState(() => _selectedSeconds = seconds);
    await _settings.saveCountdownSeconds(seconds);
  }

  Future<void> _setShake(bool enabled) async {
    setState(() => _shakeEnabled = enabled);
    await _settings.saveShakeEnabled(enabled);
    await _syncMonitor();
  }

  /// Open a sheet to pick the app language.
  void _openLanguagePicker() {
    final t = AppLocalizations.of(context);
    final current = LocaleController.instance.value?.languageCode;
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) {
        return SafeArea(
          child: ListView(
            shrinkWrap: true,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                child: Text(
                  t.language,
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              RadioGroup<String>(
                groupValue: current,
                onChanged: (code) {
                  if (code != null) {
                    LocaleController.instance.setLocale(Locale(code));
                  }
                  Navigator.pop(sheetContext);
                },
                child: Column(
                  children: [
                    for (final locale in LocaleController.supportedLocales)
                      RadioListTile<String>(
                        title: Text(LocaleController.displayName(locale)),
                        value: locale.languageCode,
                      ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(t.settingsTitle)),
      body: _selectedSeconds == null
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              children: [
                // Language picker.
                ListTile(
                  leading: const Icon(Icons.language),
                  title: Text(t.language),
                  subtitle: Text(t.languageSubtitle),
                  trailing: Text(
                    LocaleController.displayName(
                      LocaleController.instance.value ??
                          Localizations.localeOf(context),
                    ),
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  onTap: _openLanguagePicker,
                ),
                const Divider(),

                // ---- Security ----
                _SectionHeader(t.securitySection),
                ListTile(
                  leading: const Icon(Icons.password),
                  title: Text(t.securityChangePin),
                  onTap: _changePin,
                ),
                SwitchListTile(
                  secondary: const Icon(Icons.fingerprint),
                  title: Text(t.securityBiometric),
                  subtitle: Text(t.securityBiometricSubtitle),
                  value: _biometricEnabled,
                  onChanged: _biometricAvailable ? _setBiometric : null,
                ),
                ListTile(
                  leading: const Icon(Icons.lock_clock),
                  title: Text(t.securityAutoLock),
                  trailing: DropdownButton<int>(
                    value: _graceSeconds,
                    onChanged: (v) => _setGrace(v ?? 0),
                    items: [
                      DropdownMenuItem(
                        value: 0,
                        child: Text(t.securityAutoLockImmediate),
                      ),
                      for (final s in const [30, 60, 300])
                        DropdownMenuItem(
                          value: s,
                          child: Text(t.securityAutoLockGrace(s)),
                        ),
                    ],
                  ),
                ),
                const Divider(),

                const Padding(
                  padding: EdgeInsets.fromLTRB(16, 20, 16, 8),
                  child: Text(
                    'SOS countdown length',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    'How long you have to cancel before the SOS is sent.',
                    style: TextStyle(color: Colors.black54),
                  ),
                ),
                const SizedBox(height: 8),
                // Fully customisable countdown in seconds / minutes / hours.
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: DurationField(
                    initial: Duration(seconds: _selectedSeconds ?? 5),
                    initialUnit: TimeUnit.seconds,
                    onChanged: (d) => _select(d.inSeconds),
                  ),
                ),
                const SizedBox(height: 16),
                const Divider(),
                // Shake to send SOS toggle.
                SwitchListTile(
                  title: const Text('Shake to send SOS'),
                  subtitle: const Text(
                    'When on, shaking the phone starts the SOS countdown.',
                  ),
                  value: _shakeEnabled,
                  onChanged: _setShake,
                ),
                SwitchListTile(
                  title: Text(t.securityVolumeTrigger),
                  subtitle: Text(t.securityVolumeTriggerSubtitle),
                  value: _volumeTrigger,
                  onChanged: _setVolumeTrigger,
                ),
                SwitchListTile(
                  title: const Text('Power button SOS'),
                  subtitle: const Text(
                    'When on, rapidly pressing the power button (3×) starts '
                    'the SOS.',
                  ),
                  value: _powerTrigger,
                  onChanged: _setPowerTrigger,
                ),
                // These three triggers keep working while the screen is locked
                // or the app is closed, via an always-on "Safety mode active"
                // notification.
                if (_shakeEnabled || _volumeTrigger || _powerTrigger)
                  const Padding(
                    padding: EdgeInsets.fromLTRB(16, 0, 16, 8),
                    child: Text(
                      'Safety mode runs in the background so shake / volume / '
                      'power can send an SOS even when your phone is locked. '
                      'You\'ll see a permanent "Safety mode active" '
                      'notification while it\'s on.',
                      style: TextStyle(fontSize: 12, color: Colors.black54),
                    ),
                  ),
                SwitchListTile(
                  title: Text(t.securitySilentSos),
                  subtitle: Text(t.securitySilentSosSubtitle),
                  value: _silentSos,
                  onChanged: _setSilentSos,
                ),
                SwitchListTile(
                  title: Text(t.securityLiveUpdates),
                  subtitle: Text(t.securityLiveUpdatesSubtitle),
                  value: _liveUpdates,
                  onChanged: _setLiveUpdates,
                ),
                const Divider(),
                // Editable SOS message.
                const Padding(
                  padding: EdgeInsets.fromLTRB(16, 12, 16, 8),
                  child: Text(
                    'SOS message',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    'This text is sent to your contacts. Keep the word '
                    '{location} where you want the map link to appear.',
                    style: TextStyle(color: Colors.black54),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: TextField(
                    controller: _messageController,
                    maxLines: 4,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Type your emergency message…',
                    ),
                    // Save automatically as the user types.
                    onChanged: _saveMessage,
                  ),
                ),
              ],
            ),
    );
  }
}

/// A small bold heading used to group settings into sections.
class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.title);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }
}
