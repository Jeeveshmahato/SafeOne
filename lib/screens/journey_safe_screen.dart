import 'dart:async';
import 'package:flutter/material.dart';
import 'package:vibration/vibration.dart';

import '../models/safety_event.dart';
import '../services/contacts_repository.dart';
import '../services/location_service.dart';
import '../services/safety_event_repository.dart';
import '../services/safety_monitor_service.dart';
import '../services/settings_repository.dart';
import '../services/sms_service.dart';
import '../services/sos_service.dart';
import '../widgets/duration_field.dart';
import '../theme/app_theme.dart';
import '../widgets/app_ui.dart';

/// Track your journey to a destination. Your contacts get your location as
/// often as you choose. If you haven't tapped "I arrived" by the time you set,
/// they're alerted automatically, and keep getting your location until you
/// do.
///
/// The updates and the deadline run in the native safety service, on alarms,
/// so they work with the app closed, the screen off or the phone restarted.
/// This screen only shows what the service is doing.
class JourneySafeScreen extends StatefulWidget {
  const JourneySafeScreen({super.key});

  @override
  State<JourneySafeScreen> createState() => _JourneySafeScreenState();
}

class _JourneySafeScreenState extends State<JourneySafeScreen> {
  final ContactsRepository _contactsRepository = ContactsRepository();
  final SosService _sosService = SosService();
  final LocationService _locationService = LocationService();
  final SafetyEventRepository _eventLog = SafetyEventRepository();

  final SettingsRepository _settings = SettingsRepository();

  static const _defaultEta = Duration(minutes: 30);
  static const _defaultInterval = Duration(minutes: 5);

  String _destination = '';
  // Both in minutes or hours, starting from the last ones used.
  Duration _eta = _defaultEta;
  Duration _pingInterval = _defaultInterval;

  LiveShareStatus? _status;
  bool _busy = false;
  bool _autoSms = true;
  // Redraws the countdown; the service keeps the real deadline.
  Timer? _tick;
  int _ticks = 0;
  late final AppLifecycleListener _lifecycle;

  bool get _journeyActive =>
      _status?.active == true && _status?.mode == LiveShareMode.journey;

  /// Sharing that something else started (an SOS or Follow Me).
  LiveShareMode? get _otherSession =>
      _status?.active == true && !_journeyActive ? _status!.mode : null;

  @override
  void initState() {
    super.initState();
    _lifecycle = AppLifecycleListener(onResume: _load);
    _load();
    _tick = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() {});
      // Pick up what the service did in the background now and then.
      if (++_ticks % 10 == 0) _load();
    });
  }

  @override
  void dispose() {
    _tick?.cancel();
    _lifecycle.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    // The fields read these once, when they first show.
    if (_status == null) {
      _eta = await _settings.loadTimerPreset(TimerPreset.journeyEta, _defaultEta);
      _pingInterval = await _settings.loadTimerPreset(
          TimerPreset.journeyInterval, _defaultInterval);
    }
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

  /// Start the journey tracking.
  Future<void> _startJourney() async {
    if (_busy) return;
    final destination = _destination.trim();
    if (destination.isEmpty) {
      _showMessage('Where are you going? Add a destination first.',
          isError: true);
      return;
    }
    if (_eta < const Duration(minutes: 1) ||
        _pingInterval < const Duration(minutes: 1)) {
      _showMessage('Pick at least 1 minute for both times.', isError: true);
      return;
    }
    final contacts = await _contactsRepository.loadContacts();
    if (contacts.isEmpty) {
      _showMessage('Add an emergency contact first.', isError: true);
      return;
    }
    setState(() => _busy = true);
    await _settings.saveTimerPreset(TimerPreset.journeyEta, _eta);
    await _settings.saveTimerPreset(TimerPreset.journeyInterval, _pingInterval);
    // Ask for location now, while the app is open: the background service
    // can't ask.
    final problem = await _locationService.checkReady();
    if (problem != null) {
      if (mounted) setState(() => _busy = false);
      _showMessage(problem, isError: true);
      return;
    }

    final started = await SafetyMonitorService.startLiveShare(
      interval: _pingInterval,
      mode: LiveShareMode.journey,
      destination: destination,
      deadline: DateTime.now().add(_eta),
    );
    if (!mounted) return;
    setState(() => _busy = false);
    if (!started) {
      _showMessage("Couldn't start the journey. Please try again.",
          isError: true);
      return;
    }
    _eventLog.log(
      SafetyEventType.locationShared,
      'Started a journey to $destination, sharing your location with '
      '${contactsPhrase(contacts.length)}',
      contacts: contacts.map((c) => c.name).toList(),
    );
    if (await Vibration.hasVibrator()) Vibration.vibrate(duration: 200);
    _showMessage('Journey started. Your contacts will get your location.');
    // The service sends the first text straight away.
    await Future<void>.delayed(const Duration(seconds: 2));
    await _load();
  }

  /// Cancel the journey without telling anyone.
  Future<void> _cancelJourney() async {
    final destination = _status?.destination ?? '';
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel this journey?'),
        content: const Text(
          'Your contacts stop getting your location, and no one is alerted '
          'if you don\'t arrive. To let them know you got there, tap '
          '"I arrived" instead.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Keep going'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Cancel journey'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await SafetyMonitorService.stopLiveShare();
    _eventLog.log(
      SafetyEventType.locationShared,
      'Cancelled the journey to $destination',
    );
    await _load();
    _showMessage('Journey cancelled.');
  }

  /// Mark as safely arrived.
  Future<void> _markArrived() async {
    if (_busy) return;
    final destination = _status?.destination ?? _destination.trim();
    setState(() => _busy = true);
    await SafetyMonitorService.stopLiveShare();
    final contacts = await _contactsRepository.loadContacts();
    final result = await _sosService.sendCheckIn(contacts, arrivedAt: destination);
    if (result.success) {
      _eventLog.log(
        SafetyEventType.checkIn,
        'Reached $destination. Told ${contactsPhrase(contacts.length)}',
        contacts: contacts.map((c) => c.name).toList(),
      );
    }
    await _load();
    if (!mounted) return;
    setState(() => _busy = false);
    _showMessage(
      result.success
          ? 'Glad you made it. ${result.message}'
          : result.message,
      isError: !result.success,
    );
  }

  String _formatTime(int seconds) {
    final h = seconds ~/ 3600;
    final m = (seconds % 3600) ~/ 60;
    final s = seconds % 60;
    final mm = m.toString().padLeft(2, '0');
    final ss = s.toString().padLeft(2, '0');
    return h > 0 ? '$h:$mm:$ss' : '$mm:$ss';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Journey')),
      body: _status == null
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: EdgeInsets.fromLTRB(
                  16, 8, 16, 24 + MediaQuery.paddingOf(context).bottom),
              children: _journeyActive ? _buildRunning() : _buildSetup(),
            ),
    );
  }

  List<Widget> _buildSetup() {
    final theme = Theme.of(context);
    final other = _otherSession;
    if (other != null) {
      return [
        NoticeCard(
          tone: Tone.info,
          message: other == LiveShareMode.followMe
              ? 'Follow Me is already sharing your location. Stop it first '
                  'to start a journey.'
              : 'Your contacts are already getting your location after your '
                  'SOS. Tap "I\'m safe" on the home screen to stop it.',
        ),
      ];
    }
    return [
      Card(
        margin: EdgeInsets.zero,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Journey details', style: theme.textTheme.titleMedium),
              const SizedBox(height: 16),
              TextField(
                onChanged: (value) {
                  setState(() => _destination = value);
                },
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  labelText: 'Destination',
                  hintText: 'e.g. Home, Work, Station',
                  prefixIcon: Icon(Icons.place_outlined),
                ),
              ),
              const SizedBox(height: 20),
              Text('Expected time to arrive',
                  style: theme.textTheme.titleSmall),
              const SizedBox(height: 8),
              DurationField(
                initial: _eta,
                units: TimeUnit.minutesAndHours,
                initialUnit:
                    TimeUnit.bestFor(_eta, TimeUnit.minutesAndHours),
                onChanged: (d) => _eta = d,
              ),
              const SizedBox(height: 20),
              Text('Send location updates every',
                  style: theme.textTheme.titleSmall),
              const SizedBox(height: 8),
              DurationField(
                initial: _pingInterval,
                units: TimeUnit.minutesAndHours,
                initialUnit:
                    TimeUnit.bestFor(_pingInterval, TimeUnit.minutesAndHours),
                onChanged: (d) => _pingInterval = d,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: _busy ? null : _startJourney,
                  icon: _busy
                      ? const SizedBox.square(
                          dimension: 18,
                          child: CircularProgressIndicator(strokeWidth: 2))
                      : const Icon(Icons.play_arrow_rounded),
                  label: const Text('Start journey'),
                ),
              ),
            ],
          ),
        ),
      ),
      const SizedBox(height: 16),
      const NoticeCard(
        tone: Tone.info,
        title: 'How it works',
        message: '• Your contacts get a text with your location as '
            'often as you choose\n'
            '• Tap "I arrived" when you get there\n'
            "• If you don't by the time you set, they're alerted "
            'automatically\n'
            '• It keeps going with SafeOne closed or your screen off',
      ),
      if (!_autoSms) ...[
        const SizedBox(height: 12),
        const NoticeCard(
          tone: Tone.warning,
          message: 'Each update will wait for you to tap Send. To send them '
              'by themselves, turn on "Send SOS automatically" in Settings.',
        ),
      ],
    ];
  }

  List<Widget> _buildRunning() {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final sc = context.safety;
    final status = _status!;
    final deadline = status.deadline ?? DateTime.now();
    final started = status.startedAt ?? deadline;
    final totalSeconds =
        deadline.difference(started).inSeconds.clamp(1, 1 << 31);
    final remainingSeconds = deadline.difference(DateTime.now()).inSeconds;
    final isExpired = status.overdue || remainingSeconds <= 0;
    final progressValue =
        (1 - remainingSeconds / totalSeconds).clamp(0.0, 1.0);
    final statusColor = isExpired ? sc.sos : scheme.primary;
    final updates = status.updatesSent;

    return [
      Card(
        margin: EdgeInsets.zero,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Journey to ${status.destination ?? ''}',
                textAlign: TextAlign.center,
                style: theme.textTheme.titleLarge,
              ),
              const SizedBox(height: 24),
              Text(
                isExpired ? "Time's up" : 'Time remaining',
                textAlign: TextAlign.center,
                style:
                    theme.textTheme.labelLarge!.copyWith(color: statusColor),
              ),
              const SizedBox(height: 4),
              Text(
                _formatTime(remainingSeconds.clamp(0, totalSeconds)),
                textAlign: TextAlign.center,
                style: theme.textTheme.displayMedium!.copyWith(
                  color: statusColor,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
              const SizedBox(height: 16),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: progressValue,
                  minHeight: 8,
                  color: statusColor,
                  backgroundColor: scheme.surfaceContainerHighest,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                updates == 0
                    ? 'Sending your first update…'
                    : '${updates == 1 ? '1 update' : '$updates updates'} sent',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ),
      if (isExpired) ...[
        const SizedBox(height: 16),
        NoticeCard(
          tone: Tone.danger,
          message: status.overdue
              ? 'Your contacts were alerted that you haven\'t arrived. They '
                  'keep getting your location until you tap "I arrived".'
              : 'Alerting your contacts…',
        ),
      ],
      const SizedBox(height: 20),
      FilledButton.icon(
        style: FilledButton.styleFrom(
          backgroundColor: sc.success,
          foregroundColor: scheme.surface,
          minimumSize: const Size.fromHeight(56),
        ),
        onPressed: _busy ? null : _markArrived,
        icon: const Icon(Icons.check_rounded),
        label: const Text('I arrived'),
      ),
      const SizedBox(height: 12),
      OutlinedButton.icon(
        onPressed: _busy ? null : _cancelJourney,
        icon: const Icon(Icons.close_rounded),
        label: const Text('Cancel journey'),
      ),
      const SizedBox(height: 16),
      const NoticeCard(
        tone: Tone.info,
        message: 'You can close SafeOne or lock your phone. It keeps going '
            'until you tap "I arrived".',
      ),
    ];
  }
}
