import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import '../config/features.dart';
import '../l10n/app_localizations.dart';
import '../models/emergency_contact.dart';
import '../services/contacts_repository.dart';
import '../services/flashlight_service.dart';
import '../models/safety_event.dart';
import '../services/recorder_service.dart';
import '../services/safety_event_repository.dart';
import '../services/safety_monitor_service.dart';
import '../services/settings_repository.dart';
import '../services/shake_service.dart';
import '../services/share_location_service.dart';
import '../services/siren_service.dart';
import '../services/sos_service.dart';
import '../services/volume_button_service.dart';
import '../theme/app_theme.dart';
import '../widgets/app_ui.dart';
import '../widgets/tabbed_hub.dart';
import 'contacts_screen.dart';
import 'emergency_id_screen.dart';
import 'emergency_protocol_screen.dart';
import 'emergency_qr_screen.dart';
import 'fake_call_setup_screen.dart';
import 'follow_me_screen.dart';
import 'helpline_screen.dart';
import 'india_emergency_resources_screen.dart';
import 'journey_safe_screen.dart';
import 'nearby_places_screen.dart';
import 'police_sos_screen.dart';
import 'quick_contacts_screen.dart';
import 'safety_event_log_screen.dart';
import 'safety_timer_screen.dart';
import 'safety_tips_screen.dart';
import 'settings_screen.dart';
import 'sos_countdown_dialog.dart';

/// The main screen: a big SOS button, a row of instant quick-actions, and a
/// small set of clearly grouped safety tools.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  final ContactsRepository _contactsRepository = ContactsRepository();
  final SettingsRepository _settingsRepository = SettingsRepository();
  final SosService _sosService = SosService();
  final SirenService _sirenService = SirenService();
  final ShakeService _shakeService = ShakeService();
  final FlashlightService _flashlightService = FlashlightService();
  final RecorderService _recorderService = RecorderService();
  final ShareLocationService _shareLocationService = ShareLocationService();
  final SafetyEventRepository _eventLog = SafetyEventRepository();
  final VolumeButtonService _volumeButtonService = VolumeButtonService();

  List<EmergencyContact> _contacts = [];
  int _countdownSeconds = SettingsRepository.defaultCountdownSeconds;
  String _sosMessage = SettingsRepository.defaultSosMessage;
  bool _silentSos = SettingsRepository.defaultSilentSos;
  bool _liveUpdates = SettingsRepository.defaultLiveUpdates;

  bool _sendingSos = false;

  // Location permission state, so we can ask *before* an emergency rather
  // than interrupting the SOS with a system dialog.
  LocationPermission? _locationPermission;
  bool _sirenOn = false;
  bool _flashOn = false;
  bool _sosBlinkOn = false;
  bool _recording = false;

  // "Live location sharing" that keeps running (via the OS, even if the app is
  // closed) after an SOS until the user marks themselves safe.
  bool _liveSharing = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadContacts();
    _loadSettings();
    _checkLocationPermission();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // The user may have granted location in system Settings meanwhile.
    if (state == AppLifecycleState.resumed) _checkLocationPermission();
  }

  Future<void> _checkLocationPermission() async {
    try {
      final permission = await Geolocator.checkPermission();
      if (!mounted) return;
      setState(() => _locationPermission = permission);
    } catch (_) {/* location unavailable on this device */}
  }

  Future<void> _requestLocationPermission() async {
    if (_locationPermission == LocationPermission.deniedForever) {
      await Geolocator.openAppSettings();
    } else {
      await Geolocator.requestPermission();
    }
    await _checkLocationPermission();
  }

  bool get _needsLocation =>
      _locationPermission == LocationPermission.denied ||
      _locationPermission == LocationPermission.deniedForever;

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _sirenService.dispose();
    _shakeService.stop();
    _flashlightService.stop();
    _recorderService.dispose();
    _volumeButtonService.stop();
    super.dispose();
  }

  Future<void> _loadContacts() async {
    final contacts = await _contactsRepository.loadContacts();
    if (!mounted) return;
    setState(() => _contacts = contacts);
  }

  Future<void> _loadSettings() async {
    final seconds = await _settingsRepository.loadCountdownSeconds();
    final shakeEnabled = await _settingsRepository.loadShakeEnabled();
    final message = await _settingsRepository.loadSosMessage();
    final silent = await _settingsRepository.loadSilentSos();
    final live = await _settingsRepository.loadLiveUpdates();
    final volume = await _settingsRepository.loadVolumeTrigger();
    final power = await _settingsRepository.loadPowerTrigger();
    final sharingActive = await _settingsRepository.loadLiveSharingActive();
    if (!mounted) return;
    setState(() {
      _countdownSeconds = seconds;
      _sosMessage = message;
      _silentSos = silent;
      _liveUpdates = live;
      // Restore the live-sharing banner if it was left running last session.
      _liveSharing = sharingActive;
    });

    // Hands-free triggers are gated behind the backgroundTriggers flag.
    // When the flag is off (v1.0 Play Store build) the foreground service is
    // never started, avoiding the Special Use FGS permission declaration.
    _shakeService.stop();
    _volumeButtonService.stop();
    if (Features.backgroundTriggers) {
      await SafetyMonitorService.sync(
        shake: shakeEnabled,
        volume: volume,
        power: power,
      );
    } else {
      await SafetyMonitorService.stop();
    }
  }

  void _showMessage(String text, {bool isError = false}) {
    if (!mounted) return;
    showAppSnack(context, text, tone: isError ? Tone.danger : Tone.success);
  }

  // ---------------------------------------------------------------------------
  // SOS
  // ---------------------------------------------------------------------------

  /// Normal SOS: a cancellable countdown, then send + (optionally) start live
  /// location sharing.
  Future<void> _triggerSos() async {
    if (_sendingSos) return;
    if (_contacts.isEmpty) {
      _showMessage(AppLocalizations.of(context).errorNoContacts,
          isError: true);
      return;
    }

    final bool confirmed =
        await showSosCountdown(context, seconds: _countdownSeconds);
    if (!confirmed || !mounted) return;

    setState(() => _sendingSos = true);
    final result = await _sosService.sendSos(
      _contacts,
      messageTemplate: _sosMessage,
      silent: _silentSos,
    );
    if (!mounted) return;
    setState(() => _sendingSos = false);
    _checkLocationPermission();
    _showMessage(result.message, isError: !result.success);
    if (result.success) {
      _eventLog.log(
        SafetyEventType.sos,
        'SOS alert sent to ${_contacts.length} contact(s)',
        contacts: _contacts.map((c) => c.name).toList(),
      );
      _maybeStartLiveSharing();
    }
  }

  /// Stealth SOS (long-press): no countdown, no buzz, neutral toast — sent
  /// without an attacker noticing.
  Future<void> _triggerSilentSos() async {
    if (_sendingSos) return;
    final t = AppLocalizations.of(context);
    if (_contacts.isEmpty) {
      _showMessage(AppLocalizations.of(context).errorNoContacts,
          isError: true);
      return;
    }
    setState(() => _sendingSos = true);
    final result = await _sosService.sendSos(
      _contacts,
      messageTemplate: _sosMessage,
      silent: true,
    );
    if (!mounted) return;
    setState(() => _sendingSos = false);
    if (result.success) {
      _eventLog.log(
        SafetyEventType.sos,
        'Silent SOS sent to ${_contacts.length} contact(s)',
        contacts: _contacts.map((c) => c.name).toList(),
      );
      _showMessage(t.silentSosSent(_contacts.length));
      _maybeStartLiveSharing();
    } else {
      _showMessage(result.message, isError: true);
    }
  }

  Future<void> _maybeStartLiveSharing() async {
    if (!Features.backgroundLocation) return;
    if (!_liveUpdates || _liveSharing || _contacts.isEmpty) return;
    final t = AppLocalizations.of(context);
    // Runs inside the native foreground service, so it keeps sending the
    // location even if the app is closed/swiped or the phone is locked — until
    // the user marks themselves safe.
    await _settingsRepository.saveLiveSharingActive(true);
    await SafetyMonitorService.startLiveShare();
    if (!mounted) return;
    setState(() => _liveSharing = true);
    _showMessage(t.sosLiveStarted);
  }

  Future<void> _stopLiveSharing() async {
    // Stop unconditionally — sharing may still be running from a previous app
    // session even if our in-memory flag was reset on restart.
    await _settingsRepository.saveLiveSharingActive(false);
    await SafetyMonitorService.stopLiveShare();
    if (!mounted) return;
    final t = AppLocalizations.of(context);
    setState(() => _liveSharing = false);
    _showMessage(t.sosLiveStopped);
  }

  Future<void> _checkIn() async {
    if (_sendingSos) return;
    if (_contacts.isEmpty) {
      _showMessage(AppLocalizations.of(context).errorNoContacts,
          isError: true);
      return;
    }
    // Marking yourself safe always stops live sharing — even if it was started
    // in a previous app session (so the in-memory flag may be false).
    await _stopLiveSharing();
    setState(() => _sendingSos = true);
    final result = await _sosService.sendCheckIn(_contacts);
    if (!mounted) return;
    setState(() => _sendingSos = false);
    if (result.success) {
      _eventLog.log(
        SafetyEventType.checkIn,
        'Safe check-in sent to ${_contacts.length} contact(s)',
        contacts: _contacts.map((c) => c.name).toList(),
      );
    }
    _showMessage(result.message, isError: !result.success);
  }

  // ---------------------------------------------------------------------------
  // Quick actions
  // ---------------------------------------------------------------------------

  Future<void> _toggleSiren() async {
    if (_sirenOn) {
      await _sirenService.stop();
    } else {
      await _sirenService.start();
    }
    if (!mounted) return;
    setState(() => _sirenOn = !_sirenOn);
  }

  Future<void> _toggleFlashlight() async {
    if (_flashOn || _sosBlinkOn) {
      await _flashlightService.stop();
      if (!mounted) return;
      setState(() {
        _flashOn = false;
        _sosBlinkOn = false;
      });
      return;
    }
    final noFlashlight = AppLocalizations.of(context).errorNoFlashlight;
    if (!await _flashlightService.isAvailable()) {
      _showMessage(noFlashlight, isError: true);
      return;
    }
    await _flashlightService.start();
    if (!mounted) return;
    setState(() => _flashOn = true);
  }

  /// Long-press the flashlight to blink Morse "SOS" instead of a steady light.
  Future<void> _toggleSosBlink() async {
    if (_sosBlinkOn) {
      await _flashlightService.stop();
      if (!mounted) return;
      setState(() => _sosBlinkOn = false);
      return;
    }
    final noFlashlight = AppLocalizations.of(context).errorNoFlashlight;
    if (!await _flashlightService.isAvailable()) {
      _showMessage(noFlashlight, isError: true);
      return;
    }
    await _flashlightService.stop();
    await _flashlightService.startSos();
    if (!mounted) return;
    setState(() {
      _sosBlinkOn = true;
      _flashOn = false;
    });
  }

  Future<void> _toggleRecording() async {
    if (_recording) {
      final path = await _recorderService.stop();
      if (!mounted) return;
      setState(() => _recording = false);
      final t = AppLocalizations.of(context);
      _showMessage(path != null ? t.recordingSaved : t.recordingStopped);
    } else {
      final started = await _recorderService.start();
      if (!mounted) return;
      if (!started) {
        _showMessage(AppLocalizations.of(context).errorMicDenied,
            isError: true);
        return;
      }
      setState(() => _recording = true);
      _showMessage(AppLocalizations.of(context).recordingStarted);
    }
  }

  Future<void> _shareLocation() async {
    try {
      await _shareLocationService.shareCurrentLocation();
      _eventLog.log(SafetyEventType.locationShared, 'Shared current location');
    } catch (error) {
      _showMessage(error.toString().replaceFirst('Exception: ', ''),
          isError: true);
    }
  }

  // ---------------------------------------------------------------------------
  // Navigation
  // ---------------------------------------------------------------------------

  void _open(Widget screen) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => screen))
        .then((_) {
      _loadContacts();
      _checkLocationPermission();
    });
  }

  Future<void> _openSettings() async {
    await Navigator.push(context,
        MaterialPageRoute(builder: (_) => const SettingsScreen()));
    await _loadSettings();
  }

  // Grouped hubs: each gathers related tools behind one tile so the home
  // screen stays uncluttered. The original screens are reused untouched.
  Widget _helplinesHub(AppLocalizations t) => TabbedHub(tabs: [
        HubTab(icon: Icons.call, label: t.tabHelplines, screen: const HelplineScreen()),
        HubTab(icon: Icons.flag, label: t.tabIndia, screen: const IndiaEmergencyResourcesScreen()),
        HubTab(icon: Icons.local_police, label: t.tabPolice, screen: const PoliceSosScreen()),
      ]);

  Widget _liveTrackingHub(AppLocalizations t) => TabbedHub(tabs: [
        HubTab(icon: Icons.my_location, label: t.tabFollowMe, screen: const FollowMeScreen()),
        HubTab(icon: Icons.directions_run, label: t.tabJourney, screen: const JourneySafeScreen()),
      ]);

  Widget _profileHub(AppLocalizations t) => TabbedHub(tabs: [
        // The Medical ID must stay first: the QR tab's "Edit" switches to it.
        HubTab(icon: Icons.medical_information_rounded, label: t.tabEmergencyId, screen: const EmergencyIDScreen()),
        HubTab(icon: Icons.qr_code_2_rounded, label: t.tabQr, screen: const EmergencyQrScreen()),
      ]);

  Widget _contactsHub(AppLocalizations t) => TabbedHub(tabs: [
        HubTab(icon: Icons.contacts, label: t.tabAllContacts, screen: const ContactsScreen()),
        HubTab(icon: Icons.star, label: t.tabQuick, screen: const QuickContactsScreen()),
      ]);


  Widget _learnHub(AppLocalizations t) => TabbedHub(tabs: [
        HubTab(icon: Icons.menu_book, label: t.tabTips, screen: const SafetyTipsScreen()),
        HubTab(icon: Icons.local_police, label: t.tabWhatToDo, screen: const EmergencyProtocolScreen()),
      ]);

  // ---------------------------------------------------------------------------
  // UI
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final s = context.safety;

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: EdgeInsets.fromLTRB(
              20, 8, 20, 32 + MediaQuery.paddingOf(context).bottom),
          children: [
            // Header: brand on the left, settings on the right.
            Row(
              children: [
                const AppLogo(size: 40),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(t.appTitle, style: theme.textTheme.headlineSmall),
                      Text(
                        t.homeTagline,
                        style: theme.textTheme.bodyMedium!
                            .copyWith(color: scheme.onSurfaceVariant),
                      ),
                    ],
                  ),
                ),
                IconButton.filledTonal(
                  icon: const Icon(Icons.settings_rounded),
                  tooltip: t.settingsTitle,
                  onPressed: _openSettings,
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Who will be alerted. Without contacts the SOS can't work, so
            // this becomes a prominent call to action.
            if (_contacts.isEmpty)
              NoticeCard(
                tone: Tone.warning,
                icon: Icons.person_add_alt_1_rounded,
                title: t.homeAddContactsTitle,
                message: t.homeAddContactsBody,
                action: FilledButton.tonal(
                  style: FilledButton.styleFrom(
                    minimumSize: const Size(0, 44),
                    backgroundColor: s.warning,
                    foregroundColor: scheme.surface,
                  ),
                  onPressed: () => _open(_contactsHub(t)),
                  child: Text(t.homeAddContactsAction),
                ),
              )
            else
              Center(
                child: _ContactsPill(
                  label: t.homeContactsReady(_contacts.length),
                  onTap: () => _open(_contactsHub(t)),
                ),
              ),
            // Ready the location permission once contacts exist.
            if (_contacts.isNotEmpty && _needsLocation) ...[
              const SizedBox(height: 12),
              NoticeCard(
                tone: Tone.info,
                icon: Icons.location_on_outlined,
                title: t.homeLocationTitle,
                message: t.homeLocationBody,
                action: FilledButton.tonal(
                  style: FilledButton.styleFrom(minimumSize: const Size(0, 44)),
                  onPressed: _requestLocationPermission,
                  child: Text(
                    _locationPermission == LocationPermission.deniedForever
                        ? t.homeLocationSettings
                        : t.homeLocationAction,
                  ),
                ),
              ),
            ],
            const SizedBox(height: 28),

            // The SOS button: tap = countdown, long-press = silent.
            Center(
              child: _SosButton(
                label: t.sos,
                semanticsLabel: t.sosButtonSemantics,
                busy: _sendingSos,
                onTap: _triggerSos,
                onLongPress: _triggerSilentSos,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              t.sosButtonCaption,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium!
                  .copyWith(color: scheme.onSurfaceVariant),
            ),
            const SizedBox(height: 8),

            // Live location sharing banner (only while active).
            if (Features.backgroundLocation && _liveSharing) ...[
              const SizedBox(height: 16),
              _LiveSharingBanner(
                label: t.sosLiveBannerActive,
                stopLabel: t.sosLiveStop,
                onStop: _stopLiveSharing,
              ),
            ],

            // Quick actions: instant toggles.
            SectionLabel(t.quickActions),
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: _QuickAction(
                      icon: _sirenOn
                          ? Icons.volume_off_rounded
                          : Icons.campaign_rounded,
                      label: _sirenOn ? t.tileStopSiren : t.tileSiren,
                      active: _sirenOn,
                      onTap: _toggleSiren,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _QuickAction(
                      icon: _flashOn || _sosBlinkOn
                          ? Icons.flashlight_off_rounded
                          : Icons.flashlight_on_rounded,
                      label: _sosBlinkOn
                          ? t.tileStopBlink
                          : (_flashOn ? t.tileStopLight : t.tileFlashlight),
                      active: _flashOn || _sosBlinkOn,
                      onTap: _toggleFlashlight,
                      onLongPress: _toggleSosBlink,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _QuickAction(
                      icon: _recording ? Icons.stop_rounded : Icons.mic_rounded,
                      label: _recording ? t.tileStopRec : t.tileRecord,
                      active: _recording,
                      onTap: _toggleRecording,
                    ),
                  ),
                ],
              ),
            ),

            // All tools in one 3-column grid, ordered get help -> share &
            // track -> my info -> learn. Twelve tiles fill four full rows.
            SectionLabel(t.homeTools),
            _ToolGrid(tiles: [
              _Tile(Icons.call_rounded, t.tileHelplines,
                  () => _open(_helplinesHub(t))),
              _Tile(Icons.travel_explore_rounded, t.tileNearbyHelp,
                  () => _open(const NearbyPlacesScreen())),
              _Tile(Icons.phone_in_talk_rounded, t.tileFakeCall,
                  () => _open(const FakeCallSetupScreen())),
              _Tile(Icons.gavel_rounded, t.tileReportPortals,
                  () => _open(const IndiaEmergencyResourcesScreen(
                      initialTab: 'portals'))),
              if (Features.followMe)
                _Tile(Icons.my_location_rounded, t.tileLiveTracking,
                    () => _open(_liveTrackingHub(t))),
              if (Features.shareLocation)
                _Tile(Icons.share_location_rounded, t.tileShareLocation,
                    _shareLocation),
              if (Features.safetyCheckin)
                _Tile(Icons.timer_rounded, t.tileSafetyCheckin,
                    () => _open(const SafetyTimerScreen())),
              if (Features.imSafe)
                _Tile(Icons.verified_user_rounded, t.tileImSafe, _checkIn),
              if (Features.emergencyProfile)
                _Tile(Icons.medical_information_rounded,
                    t.tileEmergencyProfile, () => _open(_profileHub(t))),
              if (Features.emergencyContacts)
                _Tile(Icons.contacts_rounded, t.tileContacts,
                    () => _open(_contactsHub(t))),
              if (Features.eventLog)
                _Tile(Icons.history_rounded, t.tileRecords,
                    () => _open(const SafetyEventLogScreen())),
              _Tile(Icons.menu_book_rounded, t.tileSafetyTips,
                  () => _open(_learnHub(t))),
            ]),
          ],
        ),
      ),
    );
  }
}

/// The hero SOS button: a solid red disc with a slow, calm pulsing ring.
///
/// The halo stops when the system "remove animations" setting is on, and the
/// whole control is exposed to screen readers as one button with both the
/// tap and long-press actions.
class _SosButton extends StatefulWidget {
  const _SosButton({
    required this.label,
    required this.semanticsLabel,
    required this.busy,
    required this.onTap,
    required this.onLongPress,
  });

  final String label;
  final String semanticsLabel;
  final bool busy;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  @override
  State<_SosButton> createState() => _SosButtonState();
}

class _SosButtonState extends State<_SosButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2400),
  );
  bool _pressed = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _pulse.stop();
      _pulse.value = 0;
    } else if (!_pulse.isAnimating) {
      _pulse.repeat();
    }
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = context.safety;
    const core = 196.0;
    const halo = 264.0;

    return Semantics(
      button: true,
      label: widget.semanticsLabel,
      onTap: widget.onTap,
      onLongPress: widget.onLongPress,
      child: ExcludeSemantics(
        child: SizedBox(
          width: halo,
          height: halo,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Two expanding, fading rings, half a cycle apart.
              AnimatedBuilder(
                animation: _pulse,
                builder: (context, _) => Stack(
                  alignment: Alignment.center,
                  children: [
                    for (final offset in const [0.0, 0.5])
                      _ring(((_pulse.value + offset) % 1.0), core, halo, s.sos),
                  ],
                ),
              ),
              // Static soft halo so the button reads well even with no motion.
              Container(
                width: core + 28,
                height: core + 28,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: s.sos.withValues(alpha: 0.12),
                ),
              ),
              GestureDetector(
                onTapDown: (_) => setState(() => _pressed = true),
                onTapUp: (_) => setState(() => _pressed = false),
                onTapCancel: () => setState(() => _pressed = false),
                onTap: widget.onTap,
                onLongPress: () {
                  setState(() => _pressed = false);
                  widget.onLongPress();
                },
                child: AnimatedScale(
                  scale: _pressed ? 0.95 : 1,
                  duration: const Duration(milliseconds: 120),
                  curve: Curves.easeOut,
                  child: Container(
                    width: core,
                    height: core,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: s.sos,
                    ),
                    child: Center(
                      child: widget.busy
                          ? SizedBox(
                              width: 48,
                              height: 48,
                              child: CircularProgressIndicator(
                                color: s.onSos,
                                strokeWidth: 4,
                              ),
                            )
                          : Text(
                              widget.label,
                              style: Theme.of(context)
                                  .textTheme
                                  .displayMedium!
                                  .copyWith(
                                    color: s.onSos,
                                    letterSpacing: 2,
                                  ),
                            ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _ring(double t, double core, double halo, Color color) {
    final size = core + (halo - core) * t;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: color.withValues(alpha: 0.35 * (1 - t)),
          width: 2,
        ),
      ),
    );
  }
}

/// A rounded pill showing how many contacts will be alerted; opens contacts.
class _ContactsPill extends StatelessWidget {
  const _ContactsPill({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final s = context.safety;
    return Material(
      color: s.successContainer,
      shape: const StadiumBorder(),
      child: InkWell(
        customBorder: const StadiumBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.check_circle_rounded, size: 18, color: s.success),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  label,
                  style: theme.textTheme.labelLarge!
                      .copyWith(color: s.onSuccessContainer),
                ),
              ),
              const SizedBox(width: 4),
              Icon(Icons.chevron_right_rounded,
                  size: 18, color: s.onSuccessContainer),
            ],
          ),
        ),
      ),
    );
  }
}

/// Shown while location is being shared live after an SOS.
class _LiveSharingBanner extends StatelessWidget {
  const _LiveSharingBanner({
    required this.label,
    required this.stopLabel,
    required this.onStop,
  });

  final String label;
  final String stopLabel;
  final VoidCallback onStop;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final s = context.safety;
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 12, 12),
      decoration: BoxDecoration(
        color: s.sosContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(Icons.location_on_rounded, color: s.sos),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: theme.textTheme.titleSmall!
                  .copyWith(color: s.onSosContainer),
            ),
          ),
          const SizedBox(width: 8),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: s.sos,
              foregroundColor: s.onSos,
              minimumSize: const Size(0, 40),
            ),
            onPressed: onStop,
            child: Text(stopLabel),
          ),
        ],
      ),
    );
  }
}

/// A compact instant-action toggle used in the quick-actions row. Turns solid
/// while active so it's obvious the siren/light/recording is on.
class _QuickAction extends StatelessWidget {
  const _QuickAction({
    required this.icon,
    required this.label,
    required this.onTap,
    this.onLongPress,
    this.active = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;
  final bool active;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final s = context.safety;
    final fg = active ? s.onSos : scheme.onSurface;
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
      side: active ? BorderSide.none : BorderSide(color: scheme.outlineVariant),
    );
    return Semantics(
      button: true,
      toggled: active,
      child: Material(
        color: active ? s.sos : scheme.surfaceContainerLowest,
        shape: shape,
        child: InkWell(
          onTap: onTap,
          onLongPress: onLongPress,
          customBorder: shape,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 26, color: fg),
                const SizedBox(height: 8),
                Text(
                  label,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.labelLarge!.copyWith(
                    color: fg,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// One tool in a section grid.
class _Tile {
  const _Tile(this.icon, this.label, this.onTap);

  final IconData icon;
  final String label;
  final VoidCallback onTap;
}

/// Lays tool tiles out three per row. Each row sizes to its tallest tile, so
/// long translations or large system font sizes never overflow.
class _ToolGrid extends StatelessWidget {
  const _ToolGrid({required this.tiles});

  final List<_Tile> tiles;

  static const _columns = 3;
  static const _gap = 12.0;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var i = 0; i < tiles.length; i += _columns) ...[
          if (i > 0) const SizedBox(height: _gap),
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (var j = i; j < i + _columns; j++) ...[
                  if (j > i) const SizedBox(width: _gap),
                  Expanded(
                    child: j < tiles.length
                        ? _ToolTile(tile: tiles[j])
                        : const SizedBox.shrink(),
                  ),
                ],
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _ToolTile extends StatelessWidget {
  const _ToolTile({required this.tile});

  final _Tile tile;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
      side: BorderSide(color: scheme.outlineVariant),
    );
    return Semantics(
      button: true,
      child: Material(
        color: scheme.surfaceContainerLowest,
        shape: shape,
        child: InkWell(
          onTap: tile.onTap,
          customBorder: shape,
          child: Container(
            constraints: const BoxConstraints(minHeight: 112),
            padding: const EdgeInsets.fromLTRB(8, 16, 8, 14),
            // Top-aligned so icons line up across a row even when one
            // label wraps to two lines.
            child: Column(
              children: [
                IconBadge(icon: tile.icon, size: 44),
                const SizedBox(height: 10),
                Text(
                  tile.label,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.labelLarge!
                      .copyWith(fontWeight: FontWeight.w500, height: 1.25),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
