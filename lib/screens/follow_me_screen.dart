import 'dart:async';

import 'package:flutter/material.dart';

import '../models/safety_event.dart';
import '../services/contacts_repository.dart';
import '../services/location_service.dart';
import '../services/safety_event_repository.dart';
import '../services/safety_monitor_service.dart';
import '../services/sms_service.dart';
import '../services/sos_service.dart';
import '../widgets/duration_field.dart';
import '../theme/app_theme.dart';
import '../widgets/app_ui.dart';

/// "Follow Me" live-tracking.
///
/// While this is running, the phone texts your current location to your
/// emergency contacts every few minutes, so they can follow your journey,
/// until you tap Stop. The sending is done by the native safety service on
/// alarms, so it carries on with the app closed, the screen off, or the phone
/// restarted. This screen only shows what the service is doing.
class FollowMeScreen extends StatefulWidget {
  const FollowMeScreen({super.key});

  @override
  State<FollowMeScreen> createState() => _FollowMeScreenState();
}

class _FollowMeScreenState extends State<FollowMeScreen> {
  final ContactsRepository _contactsRepository = ContactsRepository();
  final LocationService _locationService = LocationService();
  final SafetyEventRepository _eventLog = SafetyEventRepository();

  // How often to send an update. Customisable in seconds, minutes or hours.
  Duration _interval = const Duration(minutes: 5);

  LiveShareStatus? _status;
  bool _busy = false;
  bool _autoSms = true;
  Timer? _refresh;
  late final AppLifecycleListener _lifecycle;

  bool get _running =>
      _status?.active == true && _status?.mode == LiveShareMode.followMe;

  /// Sharing that something else started (an SOS or a journey).
  LiveShareMode? get _otherSession =>
      _status?.active == true && !_running ? _status!.mode : null;

  @override
  void initState() {
    super.initState();
    _lifecycle = AppLifecycleListener(onResume: _load);
    _load();
    // The service sends in the background: keep the count current.
    _refresh = Timer.periodic(const Duration(seconds: 10), (_) => _load());
  }

  @override
  void dispose() {
    _refresh?.cancel();
    _lifecycle.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final status = await SafetyMonitorService.liveShareStatus();
    final autoSms = await SmsService.canSendAutomatically();
    if (!mounted) return;
    setState(() {
      _status = status;
      _autoSms = autoSms;
    });
  }

  void _showMessage(String text, {bool isError = false}) {
    if (!mounted) return;
    showAppSnack(context, text, tone: isError ? Tone.danger : Tone.success);
  }

  Future<void> _start() async {
    if (_busy) return;
    if (_interval < const Duration(minutes: 1)) {
      _showMessage('Pick at least 1 minute between updates.', isError: true);
      return;
    }
    final contacts = await _contactsRepository.loadContacts();
    if (contacts.isEmpty) {
      _showMessage('Add at least one emergency contact first.',
          isError: true);
      return;
    }
    setState(() => _busy = true);
    // Ask for location now, while the app is open: the background service
    // can't ask, and without it contacts would only get "can't find my
    // location".
    final problem = await _locationService.checkReady();
    if (problem != null) {
      if (mounted) setState(() => _busy = false);
      _showMessage(problem, isError: true);
      return;
    }

    final started = await SafetyMonitorService.startLiveShare(
      interval: _interval,
      mode: LiveShareMode.followMe,
    );
    if (!mounted) return;
    setState(() => _busy = false);
    if (!started) {
      _showMessage("Couldn't start sharing. Please try again.",
          isError: true);
      return;
    }
    _eventLog.log(
      SafetyEventType.locationShared,
      'Started sharing your location with ${contactsPhrase(contacts.length)}',
      contacts: contacts.map((c) => c.name).toList(),
    );
    _showMessage('Your contacts will get your location until you tap Stop.');
    // The service sends the first text straight away.
    await Future<void>.delayed(const Duration(seconds: 2));
    await _load();
  }

  Future<void> _stop() async {
    final sent = _status?.updatesSent ?? 0;
    await SafetyMonitorService.stopLiveShare();
    _eventLog.log(
      SafetyEventType.locationShared,
      'Stopped sharing your location '
      '(${sent == 1 ? '1 update' : '$sent updates'} sent)',
    );
    await _load();
    _showMessage('Stopped sharing your location.');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Follow Me')),
      body: SafeArea(
        top: false,
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: _status == null
                ? const CircularProgressIndicator()
                : _running
                    ? _buildRunning()
                    : _buildSetup(),
          ),
        ),
      ),
    );
  }

  Widget _buildSetup() {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final other = _otherSession;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Center(
          child: IconBadge(icon: Icons.my_location_rounded, size: 72),
        ),
        const SizedBox(height: 20),
        Text('Share your journey',
            textAlign: TextAlign.center, style: theme.textTheme.headlineSmall),
        const SizedBox(height: 8),
        Text(
          'Your contacts get a text with your location every few minutes, '
          'until you tap Stop. It keeps going with SafeOne closed or your '
          'screen off.',
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyLarge!
              .copyWith(color: scheme.onSurfaceVariant),
        ),
        const SizedBox(height: 28),
        if (other != null) ...[
          NoticeCard(
            tone: Tone.info,
            message: other == LiveShareMode.journey
                ? 'Your journey is already sharing your location. End it '
                    'first to use Follow Me.'
                : 'Your contacts are already getting your location after '
                    'your SOS. Tap "I\'m safe" on the home screen to stop it.',
          ),
        ] else ...[
          Card(
            margin: EdgeInsets.zero,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Send an update every',
                      style: theme.textTheme.titleSmall),
                  const SizedBox(height: 12),
                  DurationField(
                    initial: _interval,
                    initialUnit: TimeUnit.minutes,
                    onChanged: (d) => _interval = d,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: _busy ? null : _start,
            icon: _busy
                ? const SizedBox.square(
                    dimension: 18,
                    child: CircularProgressIndicator(strokeWidth: 2))
                : const Icon(Icons.play_arrow_rounded),
            label: const Text('Start sharing'),
          ),
          if (!_autoSms) ...[
            const SizedBox(height: 16),
            const NoticeCard(
              tone: Tone.warning,
              message: 'Each update will wait for you to tap Send. To send '
                  'them by themselves, turn on "Send SOS automatically" in '
                  'Settings.',
            ),
          ],
        ],
      ],
    );
  }

  Widget _buildRunning() {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final s = context.safety;
    final status = _status!;
    final last = status.lastSentAt;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Center(
          child: IconBadge(
            icon: Icons.location_on_rounded,
            color: s.success,
            size: 72,
          ),
        ),
        const SizedBox(height: 20),
        Text('Sharing your location',
            textAlign: TextAlign.center, style: theme.textTheme.headlineSmall),
        const SizedBox(height: 8),
        Text(
          last == null
              ? 'Sending the first update…'
              : '${status.updatesSent == 1 ? '1 update' : '${status.updatesSent} updates'} '
                  'sent  ·  last at ${_clock(last)}',
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyLarge!
              .copyWith(color: scheme.onSurfaceVariant),
        ),
        const SizedBox(height: 28),
        FilledButton.icon(
          style: FilledButton.styleFrom(
            backgroundColor: s.sos,
            foregroundColor: s.onSos,
            minimumSize: const Size.fromHeight(56),
          ),
          onPressed: _stop,
          icon: const Icon(Icons.stop_rounded),
          label: const Text('Stop sharing'),
        ),
        const SizedBox(height: 16),
        const NoticeCard(
          tone: Tone.info,
          message: 'You can close SafeOne or lock your phone. Updates keep '
              'going until you tap Stop sharing.',
        ),
      ],
    );
  }

  String _clock(DateTime t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';
}
