import 'dart:async';

import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../services/notification_service.dart';
import '../services/safety_monitor_service.dart';
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
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Glad you are safe! Check-in cancelled.'),
        backgroundColor: Colors.green,
      ),
    );
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
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: _running ? _buildRunning() : _buildSetup(),
        ),
      ),
    );
  }

  /// The screen shown BEFORE the timer starts (pick minutes + Start).
  Widget _buildSetup() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          'If you do not tap "I\'m safe" before the timer ends, an SOS with '
          'your location is sent automatically.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16),
        ),
        const SizedBox(height: 24),
        const Text('Journey time:', style: TextStyle(fontSize: 16)),
        const SizedBox(height: 8),
        DurationField(
          initial: _duration,
          initialUnit: TimeUnit.minutes,
          onChanged: (d) => _duration = d,
        ),
        const SizedBox(height: 32),
        FilledButton.icon(
          style: FilledButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          ),
          onPressed: _start,
          icon: const Icon(Icons.play_arrow),
          label: const Text('Start timer'),
        ),
      ],
    );
  }

  /// The screen shown WHILE the timer is counting down.
  Widget _buildRunning() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text('Time left', style: TextStyle(fontSize: 18)),
        const SizedBox(height: 12),
        Text(
          _formatTime(_secondsLeft),
          style: const TextStyle(fontSize: 64, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 32),
        SizedBox(
          width: 220,
          height: 60,
          child: FilledButton.icon(
            style: FilledButton.styleFrom(backgroundColor: Colors.green),
            onPressed: _imSafe,
            icon: const Icon(Icons.check),
            label: const Text("I'm safe", style: TextStyle(fontSize: 20)),
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'You can lock or close the phone — the alert still works in the '
          'background.',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.black54),
        ),
      ],
    );
  }
}
