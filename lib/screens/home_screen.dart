import 'package:flutter/material.dart';

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
import 'medical_screen.dart';
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

class _HomeScreenState extends State<HomeScreen> {
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
    _loadContacts();
    _loadSettings();
  }

  @override
  void dispose() {
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
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(text),
        backgroundColor: isError ? Colors.red : Colors.green,
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // SOS
  // ---------------------------------------------------------------------------

  /// Normal SOS: a cancellable countdown, then send + (optionally) start live
  /// location sharing.
  Future<void> _triggerSos() async {
    if (_sendingSos) return;
    if (_contacts.isEmpty) {
      _showMessage('Please add at least one emergency contact first.',
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
      _showMessage('Please add at least one emergency contact first.',
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
      _showMessage('Please add at least one emergency contact first.',
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
    if (!await _flashlightService.isAvailable()) {
      _showMessage('This phone has no flashlight.', isError: true);
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
    if (!await _flashlightService.isAvailable()) {
      _showMessage('This phone has no flashlight.', isError: true);
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
      _showMessage(path != null ? 'Recording saved.' : 'Recording stopped.');
    } else {
      final started = await _recorderService.start();
      if (!mounted) return;
      if (!started) {
        _showMessage('Microphone permission denied.', isError: true);
        return;
      }
      setState(() => _recording = true);
      _showMessage('Recording started.');
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
        .then((_) => _loadContacts());
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
        HubTab(icon: Icons.badge, label: t.tabEmergencyId, screen: const EmergencyIDScreen()),
        HubTab(icon: Icons.medical_services, label: t.tabMedical, screen: const MedicalScreen()),
        HubTab(icon: Icons.qr_code_2, label: t.tabQr, screen: const EmergencyQrScreen()),
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
    return Scaffold(
      appBar: AppBar(
        title: Text(t.appTitle),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: t.settingsTitle,
            onPressed: _openSettings,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Text(
                _contacts.isEmpty
                    ? t.homeNoContacts
                    : t.homeContactsSaved(_contacts.length),
                style: const TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 20),

            // The big SOS button: tap = countdown, long-press = silent.
            Center(
              child: GestureDetector(
                onTap: _triggerSos,
                onLongPress: _triggerSilentSos,
                child: Container(
                  width: 180,
                  height: 180,
                  decoration: const BoxDecoration(
                      shape: BoxShape.circle, color: Colors.red),
                  child: Center(
                    child: _sendingSos
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Text(t.sos,
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 44,
                                fontWeight: FontWeight.bold)),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Center(
              child: Text(
                '${t.homeSosHint}\n${t.homeSilentSosHint}',
                style: const TextStyle(color: Colors.black54),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 16),

            // Live location sharing banner (only while active and feature is on).
            if (Features.backgroundLocation && _liveSharing)
              Card(
                color: Colors.orange.shade50,
                child: ListTile(
                  leading: const Icon(Icons.location_on, color: Colors.orange),
                  title: Text(t.sosLiveBannerActive),
                  trailing: TextButton(
                    onPressed: _stopLiveSharing,
                    child: Text(t.sosLiveStop),
                  ),
                ),
              ),
            if (Features.backgroundLocation && _liveSharing) const SizedBox(height: 8),

            // Quick actions: instant toggles.
            _SectionHeader(t.quickActions),
            Row(
              children: [
                Expanded(
                  child: _QuickAction(
                    icon: _sirenOn ? Icons.volume_off : Icons.volume_up,
                    label: _sirenOn ? t.tileStopSiren : t.tileSiren,
                    active: _sirenOn,
                    onTap: _toggleSiren,
                  ),
                ),
                Expanded(
                  child: _QuickAction(
                    icon: Icons.flashlight_on,
                    label: _sosBlinkOn
                        ? t.tileStopBlink
                        : (_flashOn ? t.tileStopLight : t.tileFlashlight),
                    active: _flashOn || _sosBlinkOn,
                    onTap: _toggleFlashlight,
                    onLongPress: _toggleSosBlink,
                  ),
                ),
                Expanded(
                  child: _QuickAction(
                    icon: _recording ? Icons.stop : Icons.mic,
                    label: _recording ? t.tileStopRec : t.tileRecord,
                    active: _recording,
                    onTap: _toggleRecording,
                  ),
                ),
              ],
            ),

            // Grouped tools.
            _SectionHeader(t.sectionGetHelp),
            _grid([
              _Tile(Icons.call, t.tileHelplines, () => _open(_helplinesHub(t))),
              _Tile(Icons.travel_explore, t.tileNearbyHelp,
                  () => _open(const NearbyPlacesScreen())),
              _Tile(Icons.phone_in_talk, t.tileFakeCall,
                  () => _open(const FakeCallSetupScreen())),
              _Tile(Icons.gavel, 'Report / Portals',
                  () => _open(const IndiaEmergencyResourcesScreen(
                      initialTab: 'portals'))),
            ]),

            _SectionHeader(t.sectionShareTrack),
            _grid([
              if (Features.followMe)
                _Tile(Icons.my_location, t.tileLiveTracking,
                    () => _open(_liveTrackingHub(t))),
              if (Features.shareLocation)
                _Tile(Icons.share_location, t.tileShareLocation, _shareLocation),
              if (Features.safetyCheckin)
                _Tile(Icons.timer, t.tileSafetyCheckin,
                    () => _open(const SafetyTimerScreen())),
              if (Features.imSafe)
                _Tile(Icons.check_circle, t.tileImSafe, _checkIn),
            ]),

            _SectionHeader(t.sectionMyInfo),
            _grid([
              if (Features.emergencyProfile)
                _Tile(Icons.badge, t.tileEmergencyProfile,
                    () => _open(_profileHub(t))),
              if (Features.emergencyContacts)
                _Tile(Icons.contacts, t.tileContacts, () => _open(_contactsHub(t))),
              if (Features.eventLog)
                _Tile(Icons.folder_shared, t.tileRecords,
                    () => _open(const SafetyEventLogScreen())),
            ]),

            _SectionHeader(t.sectionLearn),
            _grid([
              _Tile(Icons.menu_book, t.tileSafetyTips, () => _open(_learnHub(t))),
            ]),
          ],
        ),
      ),
    );
  }

  Widget _grid(List<_Tile> tiles) {
    return GridView.count(
      crossAxisCount: 3,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 0.95,
      children: tiles,
    );
  }
}

/// A bold section heading on the home screen.
class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.title);
  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }
}

/// A compact instant-action button used in the quick-actions row.
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
    final color = active ? Colors.orange : Theme.of(context).colorScheme.primary;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Icon(icon, size: 28, color: color),
              const SizedBox(height: 6),
              Text(label,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 12)),
            ],
          ),
        ),
      ),
    );
  }
}

/// One square button in a section grid.
class _Tile extends StatelessWidget {
  const _Tile(this.icon, this.label, this.onTap);

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.primary;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 34, color: color),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(label,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 13)),
            ),
          ],
        ),
      ),
    );
  }
}
