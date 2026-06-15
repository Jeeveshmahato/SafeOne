import 'dart:async';

import 'package:flutter/material.dart';

/// Shows a countdown before the SOS is actually sent.
///
/// Why: it lets you cancel an accidental alert (handy with "shake to send").
///
/// [seconds] is how long the countdown lasts (the user can change this in
/// Settings).
///
/// Returns:
///   - true  -> the countdown finished (or user tapped "Send now")  => send SOS
///   - false -> the user tapped "Cancel" (or closed it)             => do nothing
///
/// Usage:
///   final confirmed = await showSosCountdown(context, seconds: 5);
///   if (confirmed) { ...send the SOS... }
Future<bool> showSosCountdown(BuildContext context, {required int seconds}) async {
  final bool? result = await showDialog<bool>(
    context: context,
    barrierDismissible: false, // user must choose Cancel or Send
    builder: (context) => _SosCountdownDialog(startSeconds: seconds),
  );
  // If the dialog somehow closed without a value, treat it as "cancelled".
  return result ?? false;
}

class _SosCountdownDialog extends StatefulWidget {
  final int startSeconds;

  const _SosCountdownDialog({required this.startSeconds});

  @override
  State<_SosCountdownDialog> createState() => _SosCountdownDialogState();
}

class _SosCountdownDialogState extends State<_SosCountdownDialog> {
  late int _secondsLeft = widget.startSeconds;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    // Tick once every second.
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() => _secondsLeft--);

      // When we reach 0, stop the timer and confirm (send the SOS).
      if (_secondsLeft <= 0) {
        timer.cancel();
        if (mounted) Navigator.pop(context, true);
      }
    });
  }

  @override
  void dispose() {
    // Always cancel the timer so it can't fire after the dialog is gone.
    _timer?.cancel();
    super.dispose();
  }

  void _cancel() {
    _timer?.cancel();
    Navigator.pop(context, false);
  }

  void _sendNow() {
    _timer?.cancel();
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Sending SOS…'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Your alert will be sent in:'),
          const SizedBox(height: 16),
          // The big countdown number.
          Text(
            '$_secondsLeft',
            style: const TextStyle(
              fontSize: 64,
              fontWeight: FontWeight.bold,
              color: Colors.red,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Tap Cancel if this was a mistake.',
            style: TextStyle(color: Colors.black54),
            textAlign: TextAlign.center,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: _cancel,
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          onPressed: _sendNow,
          child: const Text('Send now'),
        ),
      ],
    );
  }
}
