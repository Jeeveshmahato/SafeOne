import 'dart:async';

import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../services/notification_service.dart';
import '../services/safety_monitor_service.dart';
import '../services/settings_repository.dart';
import '../theme/app_theme.dart';
import '../widgets/app_ui.dart';
import '../widgets/duration_field.dart';

/// "Reach home safely" timer.
///
/// You set how long your journey should take. If you DON'T tap "I'm safe"
/// before the time runs out, the app automatically sends the SOS.
///
/// The deadline is scheduled as a NATIVE exact alarm (CheckinAlarmReceiver),
/// which sends the SOS even if the app is later closed or the phone is locked —
/// without relying on a background Dart isolate (which aggressive OEMs block
/// once the app is swiped away). The deadline the native side saved is the
/// only record of the timer: this screen reads it back, so a running timer
/// shows up again after the app is closed and reopened.
class SafetyTimerScreen extends StatefulWidget {
  const SafetyTimerScreen({super.key});

  @override
  State<SafetyTimerScreen> createState() => _SafetyTimerScreenState();
}

class _SafetyTimerScreenState extends State<SafetyTimerScreen> {
  static const _defaultDuration = Duration(minutes: 15);

  final SettingsRepository _settings = SettingsRepository();

  // The chosen journey duration, in minutes or hours. Starts from the last
  // one used.
  Duration _duration = _defaultDuration;

  bool _loaded = false;
  CheckinStatus? _status;
  // The timer ran out while this screen was open.
  bool _ranOut = false;
  bool _busy = false;

  Timer? _tick; // redraws the countdown; the alarm keeps the real deadline
  late final AppLifecycleListener _lifecycle;

  @override
  void initState() {
    super.initState();
    _lifecycle = AppLifecycleListener(onResume: _load);
    _init();
  }

  @override
  void dispose() {
    _tick?.cancel();
    _lifecycle.dispose();
    super.dispose();
  }

  Future<void> _init() async {
    final duration =
        await _settings.loadTimerPreset(TimerPreset.checkin, _defaultDuration);
    if (!mounted) return;
    _duration = duration;
    await _load();
    _tick = Timer.periodic(const Duration(seconds: 1), (_) => _onTick());
  }

  /// Reads the running check-in back from what the native side saved.
  Future<void> _load() async {
    final status = await SafetyMonitorService.checkinStatus();
    if (!mounted) return;
    setState(() {
      // Was running and is gone after its deadline: it ran out (rather than
      // the user tapping "I'm safe").
      final was = _status;
      if (was != null &&
          status == null &&
          !DateTime.now().isBefore(was.deadline)) {
        _ranOut = true;
      }
      _status = status;
      _loaded = true;
    });
  }

  void _onTick() {
    if (!mounted) return;
    final status = _status;
    // Past the deadline: check every few seconds until the alarm has sent
    // the alert and ended the check-in.
    if (status != null &&
        !DateTime.now().isBefore(status.deadline) &&
        DateTime.now().second % 3 == 0) {
      _load();
    } else {
      setState(() {});
    }
  }

  Future<void> _start() async {
    if (_busy) return;
    if (_duration < const Duration(minutes: 1)) {
      showAppSnack(context, 'Pick at least 1 minute.', tone: Tone.danger);
      return;
    }
    setState(() => _busy = true);
    await _settings.saveTimerPreset(TimerPreset.checkin, _duration);
    // Schedule the native exact-alarm deadline; if not cancelled it sends the
    // SOS natively (CheckinAlarmReceiver), even with the app closed/locked.
    await SafetyMonitorService.scheduleCheckin(DateTime.now().add(_duration));
    if (!mounted) return;
    _ranOut = false;
    await _load();
    if (mounted) setState(() => _busy = false);
  }

  /// User arrived safely -> cancel the scheduled alert.
  Future<void> _imSafe() async {
    await SafetyMonitorService.cancelCheckin();
    await NotificationService.instance.cancelCheckin();
    if (!mounted) return;
    setState(() {
      _status = null;
      _ranOut = false;
    });
    showAppSnack(context, "Glad you're safe. Timer stopped.",
        tone: Tone.success);
  }

  /// Format seconds as HH:MM:SS (hours shown only when needed).
  String _formatTime(int totalSeconds) {
    final h = totalSeconds ~/ 3600;
    final m = (totalSeconds % 3600) ~/ 60;
    final s = totalSeconds % 60;
    final mm = m.toString().padLeft(2, '0');
    final ss = s.toString().padLeft(2, '0');
    return h > 0 ? '${h.toString().padLeft(2, '0')}:$mm:$ss' : '$mm:$ss';
  }

  String _clock(DateTime t) =>
      MaterialLocalizations.of(context).formatTimeOfDay(
          TimeOfDay.fromDateTime(t),
          alwaysUse24HourFormat: MediaQuery.alwaysUse24HourFormatOf(context));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context).tileSafetyCheckin)),
      body: SafeArea(
        top: false,
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: !_loaded
                ? const CircularProgressIndicator()
                : _status != null
                    ? _buildRunning(_status!)
                    : _buildSetup(),
          ),
        ),
      ),
    );
  }

  /// The screen shown BEFORE the timer starts (pick a duration + Start).
  Widget _buildSetup() {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Center(child: IconBadge(icon: Icons.timer_rounded, size: 72)),
        const SizedBox(height: 20),
        Text('Safety check-in',
            textAlign: TextAlign.center, style: theme.textTheme.headlineSmall),
        const SizedBox(height: 8),
        Text(
          'If you don\'t tap "I\'m safe" before the timer runs out, your '
          'contacts get an alert with your location.',
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyLarge!
              .copyWith(color: scheme.onSurfaceVariant),
        ),
        const SizedBox(height: 28),
        if (_ranOut) ...[
          const NoticeCard(
            tone: Tone.danger,
            message: 'Your timer ran out, so your contacts were sent an '
                'alert with your location. You can see it in Records.',
          ),
          const SizedBox(height: 16),
        ],
        Card(
          margin: EdgeInsets.zero,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Journey time', style: theme.textTheme.titleSmall),
                const SizedBox(height: 12),
                DurationField(
                  initial: _duration,
                  units: TimeUnit.minutesAndHours,
                  initialUnit:
                      TimeUnit.bestFor(_duration, TimeUnit.minutesAndHours),
                  onChanged: (d) => _duration = d,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
        FilledButton.icon(
          onPressed: _busy ? null : _start,
          icon: const Icon(Icons.play_arrow_rounded),
          label: const Text('Start timer'),
        ),
      ],
    );
  }

  /// The screen shown WHILE the timer is counting down.
  Widget _buildRunning(CheckinStatus status) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final s = context.safety;
    final total = status.deadline
        .difference(status.startedAt)
        .inSeconds
        .clamp(1, 1 << 31);
    final secondsLeft =
        status.deadline.difference(DateTime.now()).inSeconds.clamp(0, total);
    final timeUp = secondsLeft == 0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Center(
          child: SizedBox(
            width: 240,
            height: 240,
            child: Stack(
              fit: StackFit.expand,
              children: [
                CircularProgressIndicator(
                  value: secondsLeft / total,
                  strokeWidth: 10,
                  strokeCap: StrokeCap.round,
                  backgroundColor: scheme.surfaceContainerHighest,
                ),
                Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(timeUp ? "Time's up" : 'Time left',
                          style: theme.textTheme.labelLarge!
                              .copyWith(color: scheme.onSurfaceVariant)),
                      Text(
                        _formatTime(secondsLeft),
                        style: theme.textTheme.displaySmall!.copyWith(
                          fontFeatures: const [FontFeature.tabularFigures()],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          timeUp
              ? 'Alerting your contacts…'
              : 'Your contacts get an alert at ${_clock(status.deadline)} '
                  'unless you tap "I\'m safe".',
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyMedium!
              .copyWith(color: scheme.onSurfaceVariant),
        ),
        const SizedBox(height: 24),
        FilledButton.icon(
          style: FilledButton.styleFrom(
            backgroundColor: s.success,
            foregroundColor: scheme.surface,
            minimumSize: const Size.fromHeight(60),
          ),
          onPressed: _imSafe,
          icon: const Icon(Icons.check_rounded),
          label: const Text("I'm safe"),
        ),
        const SizedBox(height: 16),
        const NoticeCard(
          tone: Tone.info,
          message: 'You can lock your phone or close the app. The alert '
              'still goes out.',
        ),
      ],
    );
  }
}
