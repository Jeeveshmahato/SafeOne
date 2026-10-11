import 'dart:async';

import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../services/notification_service.dart';
import '../services/safety_monitor_service.dart';
import '../theme/app_theme.dart';
import '../widgets/app_ui.dart';
import '../widgets/duration_field.dart';

/// "Reach home safely" timer.
///
/// You set how many minutes your journey should take. If you DON'T tap
/// "I'm safe" before the time runs out, the app automatically sends the SOS.
///
/// The deadline is scheduled as a NATIVE exact alarm (CheckinAlarmReceiver),
/// which sends the SOS even if the app is later closed or the phone is locked —
/// without relying on a background Dart isolate (which aggressive OEMs block
/// once the app is swiped away).
class SafetyTimerScreen extends StatefulWidget {
  const SafetyTimerScreen({super.key});

  @override
  State<SafetyTimerScreen> createState() => _SafetyTimerScreenState();
}

class _SafetyTimerScreenState extends State<SafetyTimerScreen> {
  // The chosen journey duration. Customisable in seconds, minutes or hours.
  Duration _duration = const Duration(minutes: 15);

  Timer? _timer; // drives the on-screen countdown only
  int _secondsLeft = 0;
  bool _running = false;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _start() async {
    if (_duration.inSeconds <= 0) return;

    // Schedule the native exact-alarm deadline; if not cancelled it sends the
    // SOS natively (CheckinAlarmReceiver), even with the app closed/locked.
    final deadline = DateTime.now().add(_duration);
    await SafetyMonitorService.scheduleCheckin(deadline);

    if (!mounted) return;
    setState(() {
      _running = true;
      _secondsLeft = _duration.inSeconds;
    });

    // On-screen countdown for feedback while the app is open.
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      setState(() => _secondsLeft--);
      if (_secondsLeft <= 0) {
        timer.cancel();
        setState(() => _running = false);
      }
    });
  }

  /// User arrived safely -> cancel the scheduled alert.
  Future<void> _imSafe() async {
    _timer?.cancel();
    await SafetyMonitorService.cancelCheckin();
    await NotificationService.instance.cancelCheckin();
    if (!mounted) return;
    setState(() => _running = false);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context).tileSafetyCheckin)),
      body: SafeArea(
        top: false,
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: _running ? _buildRunning() : _buildSetup(),
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
                  initialUnit: TimeUnit.minutes,
                  onChanged: (d) => _duration = d,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
        FilledButton.icon(
          onPressed: _start,
          icon: const Icon(Icons.play_arrow_rounded),
          label: const Text('Start timer'),
        ),
      ],
    );
  }

  /// The screen shown WHILE the timer is counting down.
  Widget _buildRunning() {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final s = context.safety;
    final total = _duration.inSeconds <= 0 ? 1 : _duration.inSeconds;
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
                  value: (_secondsLeft / total).clamp(0.0, 1.0),
                  strokeWidth: 10,
                  strokeCap: StrokeCap.round,
                  backgroundColor: scheme.surfaceContainerHighest,
                ),
                Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('Time left',
                          style: theme.textTheme.labelLarge!
                              .copyWith(color: scheme.onSurfaceVariant)),
                      Text(
                        _formatTime(_secondsLeft),
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
        const SizedBox(height: 32),
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
