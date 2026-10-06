import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';

import '../config/features.dart';
import '../l10n/app_localizations.dart';
import '../services/app_lock_service.dart';
import '../services/locale_controller.dart';
import '../services/safety_monitor_service.dart';
import '../services/settings_repository.dart';
import '../services/sms_service.dart';
import '../theme/app_theme.dart';
import '../widgets/app_ui.dart';
import '../widgets/reveal.dart';
import '../widgets/duration_field.dart';
import 'pin_setup_screen.dart';

/// Screen where the user changes app settings: language, app lock, how the
/// SOS behaves, hands-free triggers, and links to the privacy policy/support.
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
  bool _contactsPinSet = false;
  // Where the encryption keys live, and whether the phone looks rooted
  // (Android only; null elsewhere).
  String? _keyStorage;
  bool _rooted = false;
  int _graceSeconds = AppLockService.defaultGraceSeconds;

  /// Whether SOS SMS go out automatically (SEND_SMS granted), and whether
  /// Android will still show the permission prompt.
  bool _autoSms = false;
  bool _smsBlocked = false;

  /// The "safety mode" note appears below the triggers when one is turned
  /// on; it's scrolled into view so the user sees it.
  final GlobalKey _safetyNoteKey = GlobalKey();

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
    final contactsPinSet = await _lock.isPinSet(PinKind.contacts);
    Map<Object?, Object?>? security;
    try {
      security = await const MethodChannel('com.safeone.app/device')
          .invokeMethod<Map<Object?, Object?>>('securityStatus');
    } catch (_) {/* not Android */}
    final autoSms = await SmsService.canSendAutomatically();
    final smsStatus = await SmsService.permissionStatus();
    if (!mounted) return;
    setState(() {
      _autoSms = autoSms;
      _smsBlocked = smsStatus.isPermanentlyDenied;
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
      _contactsPinSet = contactsPinSet;
      _keyStorage = security?['binding'] as String?;
      _rooted = security?['rooted'] == true;
    });
  }

  Future<void> _allowAutoSms() async {
    if (_smsBlocked) {
      await openAppSettings();
    } else {
      await SmsService.requestPermission();
    }
    final autoSms = await SmsService.canSendAutomatically();
    final smsStatus = await SmsService.permissionStatus();
    if (!mounted) return;
    setState(() {
      _autoSms = autoSms;
      _smsBlocked = smsStatus.isPermanentlyDenied;
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

  /// Change the contacts PIN, or create it if there isn't one yet.
  Future<void> _changeContactsPin() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PinSetupScreen(
          kind: PinKind.contacts,
          requireCurrent: _contactsPinSet,
        ),
      ),
    );
    final set = await _lock.isPinSet(PinKind.contacts);
    if (mounted) setState(() => _contactsPinSet = set);
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
    if (v) _revealSafetyNote();
    await _settings.saveVolumeTrigger(v);
    await _syncMonitor();
  }

  Future<void> _setPowerTrigger(bool v) async {
    setState(() => _powerTrigger = v);
    if (v) _revealSafetyNote();
    await _settings.savePowerTrigger(v);
    await _syncMonitor();
  }

  void _revealSafetyNote() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final ctx = _safetyNoteKey.currentContext;
      if (ctx != null) revealInScrollable(ctx);
    });
  }

  Future<void> _syncMonitor() {
    if (!Features.backgroundTriggers) return Future.value();
    return SafetyMonitorService.sync(
      shake: _shakeEnabled,
      volume: _volumeTrigger,
      power: _powerTrigger,
    );
  }

  Future<void> _saveMessage(String message) async {
    await _settings.saveSosMessage(message);
  }

  Future<void> _select(int seconds) async {
    setState(() => _selectedSeconds = seconds);
    await _settings.saveCountdownSeconds(seconds);
  }

  Future<void> _setShake(bool enabled) async {
    setState(() => _shakeEnabled = enabled);
    if (enabled) _revealSafetyNote();
    await _settings.saveShakeEnabled(enabled);
    await _syncMonitor();
  }

  /// Open a sheet to pick the app language.
  void _openLanguagePicker() {
    final t = AppLocalizations.of(context);
    final current = LocaleController.instance.value?.languageCode;
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) {
        return SafeArea(
          child: ListView(
            shrinkWrap: true,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                child: Text(
                  t.language,
                  style: Theme.of(context).textTheme.titleLarge,
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

  static final Uri _privacyUrl =
      Uri.parse('https://jeeveshmahato.github.io/SafeOne/privacy.html');
  static final Uri _supportUrl =
      Uri.parse('mailto:safeeonee@gmail.com?subject=SafeOne%20support');

  Future<void> _openLink(Uri uri) async {
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {/* no browser / mail app */}
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Scaffold(
      appBar: AppBar(title: Text(t.settingsTitle)),
      body: _selectedSeconds == null
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: EdgeInsets.fromLTRB(
                  16, 0, 16, 32 + MediaQuery.paddingOf(context).bottom),
              children: [
                // ---- General ----
                SectionLabel(t.settingsSectionGeneral,
                    padding: const EdgeInsets.fromLTRB(4, 8, 4, 12)),
                _SettingsGroup(children: [
                  ListTile(
                    leading: _leading(Icons.translate_rounded),
                    title: Text(t.language),
                    subtitle: Text(t.languageSubtitle),
                    trailing: Text(
                      LocaleController.displayName(
                        LocaleController.instance.value ??
                            Localizations.localeOf(context),
                      ),
                      style: theme.textTheme.labelLarge!
                          .copyWith(color: scheme.primary),
                    ),
                    onTap: _openLanguagePicker,
                  ),
                ]),

                // ---- Security ----
                SectionLabel(t.securitySection),
                _SettingsGroup(children: [
                  ListTile(
                    leading: _leading(Icons.pin_rounded),
                    title: Text(t.securityAppPin),
                    subtitle: Text(t.securityAppPinSubtitle),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: _changePin,
                  ),
                  ListTile(
                    leading: _leading(Icons.contacts_rounded),
                    title: Text(t.securityContactsPin),
                    subtitle: Text(_contactsPinSet
                        ? t.securityContactsPinOn
                        : t.securityContactsPinOff),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: _changeContactsPin,
                  ),
                  SwitchListTile(
                    secondary: _leading(Icons.fingerprint_rounded),
                    title: Text(t.securityBiometric),
                    subtitle: Text(t.securityBiometricSubtitle),
                    value: _biometricEnabled,
                    onChanged: _biometricAvailable ? _setBiometric : null,
                  ),
                  if (_keyStorage != null)
                    ListTile(
                      leading: _leading(Icons.verified_user_outlined),
                      title: Text(t.securityProtection),
                      subtitle: Text(switch (_keyStorage) {
                        'strongbox' => t.securityProtectionStrongBox,
                        'tee' => t.securityProtectionTee,
                        _ => t.securityProtectionSoftware,
                      }),
                    ),
                  if (_rooted)
                    ListTile(
                      leading: Icon(Icons.warning_amber_rounded,
                          color: scheme.error),
                      title: Text(t.securityRootedTitle),
                      subtitle: Text(t.securityRootedBody),
                    ),
                  ListTile(
                    leading: _leading(Icons.lock_clock_rounded),
                    title: Text(t.securityAutoLock),
                    subtitle: Text(_graceLabel(t, _graceSeconds)),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: _openAutoLockPicker,
                  ),
                ]),

                // ---- SOS alert ----
                SectionLabel(t.settingsSectionSos),
                _SettingsGroup(children: [
                  ListTile(
                    leading: _leading(Icons.sms_outlined),
                    title: Text(t.settingsAutoSmsTitle),
                    subtitle: Text(
                        _autoSms ? t.settingsAutoSmsOn : t.settingsAutoSmsOff),
                    trailing: _autoSms
                        ? Icon(Icons.check_circle_rounded,
                            color: context.safety.success)
                        : FilledButton.tonal(
                            style: FilledButton.styleFrom(
                                minimumSize: const Size(0, 40)),
                            onPressed: _allowAutoSms,
                            child: Text(t.settingsAutoSmsAllow),
                          ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            _leading(Icons.timer_outlined),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(t.settingsCountdownTitle,
                                      style: theme.listTileTheme.titleTextStyle),
                                  Text(t.settingsCountdownSubtitle,
                                      style:
                                          theme.listTileTheme.subtitleTextStyle),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        // Fully customisable countdown in seconds / minutes / hours.
                        DurationField(
                          initial: Duration(seconds: _selectedSeconds ?? 5),
                          initialUnit: TimeUnit.seconds,
                          onChanged: (d) => _select(d.inSeconds),
                        ),
                      ],
                    ),
                  ),
                  SwitchListTile(
                    secondary: _leading(Icons.notifications_off_outlined),
                    title: Text(t.securitySilentSos),
                    subtitle: Text(t.securitySilentSosSubtitle),
                    value: _silentSos,
                    onChanged: _setSilentSos,
                  ),
                  if (Features.backgroundLocation)
                    SwitchListTile(
                      secondary: _leading(Icons.share_location_rounded),
                      title: Text(t.securityLiveUpdates),
                      subtitle: Text(t.securityLiveUpdatesSubtitle),
                      value: _liveUpdates,
                      onChanged: _setLiveUpdates,
                    ),
                  // Editable SOS message.
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            _leading(Icons.sms_outlined),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(t.settingsMessageTitle,
                                      style: theme.listTileTheme.titleTextStyle),
                                  Text(
                                    t.settingsMessageSubtitle('{location}'),
                                    style:
                                        theme.listTileTheme.subtitleTextStyle,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: _messageController,
                          minLines: 3,
                          maxLines: 6,
                          decoration: InputDecoration(
                            hintText: t.settingsMessageHint,
                          ),
                          // Save automatically as the user types.
                          onChanged: _saveMessage,
                        ),
                      ],
                    ),
                  ),
                ]),

                // ---- Hands-free triggers ----
                if (Features.backgroundTriggers) ...[
                  SectionLabel(t.settingsSectionTriggers),
                  _SettingsGroup(children: [
                    SwitchListTile(
                      secondary: _leading(Icons.vibration_rounded),
                      title: Text(t.settingsShakeTitle),
                      subtitle: Text(t.settingsShakeSubtitle),
                      value: _shakeEnabled,
                      onChanged: _setShake,
                    ),
                    SwitchListTile(
                      secondary: _leading(Icons.volume_up_rounded),
                      title: Text(t.securityVolumeTrigger),
                      subtitle: Text(t.securityVolumeTriggerSubtitle),
                      value: _volumeTrigger,
                      onChanged: _setVolumeTrigger,
                    ),
                    SwitchListTile(
                      secondary: _leading(Icons.power_settings_new_rounded),
                      title: Text(t.settingsPowerTitle),
                      subtitle: Text(t.settingsPowerSubtitle),
                      value: _powerTrigger,
                      onChanged: _setPowerTrigger,
                    ),
                  ]),
                  if (_shakeEnabled || _volumeTrigger || _powerTrigger)
                    NoticeCard(
                      key: _safetyNoteKey,
                      tone: Tone.info,
                      message: t.settingsSafetyModeNote,
                      margin: const EdgeInsets.only(top: 12),
                    ),
                ],

                // ---- About ----
                SectionLabel(t.settingsSectionAbout),
                _SettingsGroup(children: [
                  ListTile(
                    leading: _leading(Icons.privacy_tip_outlined),
                    title: Text(t.settingsPrivacyPolicy),
                    subtitle: Text(t.settingsPrivacySubtitle),
                    trailing: const Icon(Icons.open_in_new_rounded, size: 20),
                    onTap: () => _openLink(_privacyUrl),
                  ),
                  ListTile(
                    leading: _leading(Icons.mail_outline_rounded),
                    title: Text(t.settingsSupport),
                    subtitle: const Text('safeeonee@gmail.com'),
                    trailing: const Icon(Icons.open_in_new_rounded, size: 20),
                    onTap: () => _openLink(_supportUrl),
                  ),
                ]),
                const SizedBox(height: 24),
                Center(
                  child: Text(
                    t.settingsMadeBy,
                    style: theme.textTheme.bodySmall,
                  ),
                ),
              ],
            ),
    );
  }

  Widget _leading(IconData icon) =>
      Icon(icon, color: Theme.of(context).colorScheme.onSurfaceVariant);

  String _graceLabel(AppLocalizations t, int seconds) =>
      seconds == 0 ? t.securityAutoLockImmediate : t.securityAutoLockGrace(seconds);

  /// Pick the auto-lock delay in a bottom sheet (standard settings pattern;
  /// an inline dropdown squeezed the title onto two lines).
  void _openAutoLockPicker() {
    final t = AppLocalizations.of(context);
    showModalBottomSheet<void>(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
              child: Text(t.securityAutoLock,
                  style: Theme.of(context).textTheme.titleLarge),
            ),
            RadioGroup<int>(
              groupValue: _graceSeconds,
              onChanged: (v) {
                if (v != null) _setGrace(v);
                Navigator.pop(sheetContext);
              },
              child: Column(
                children: [
                  for (final s in const [0, 30, 60, 300])
                    RadioListTile<int>(
                      value: s,
                      title: Text(_graceLabel(t, s)),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

/// A rounded card holding a group of related settings, separated by
/// inset dividers.
class _SettingsGroup extends StatelessWidget {
  const _SettingsGroup({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: Column(
        children: [
          for (var i = 0; i < children.length; i++) ...[
            if (i > 0) const Divider(indent: 56),
            children[i],
          ],
        ],
      ),
    );
  }
}
