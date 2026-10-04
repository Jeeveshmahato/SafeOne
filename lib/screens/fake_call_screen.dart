import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vibration/vibration.dart';

import '../l10n/app_localizations.dart';
import '../services/call_sound.dart';
import '../services/device_ringtone.dart';
import '../services/police_siren_service.dart';
import '../widgets/caller_avatar.dart';
import 'ongoing_call_screen.dart';

/// Which sound plays while the fake call is ringing.
enum RingSound {
  /// A real phone ringtone (the phone's default, or one the user picked) plus
  /// vibration.
  phoneRing,

  /// A loud police-vehicle siren (wee-woo) to draw attention.
  policeSiren,
}

/// A fake INCOMING-call screen that looks like a real ringing phone call.
///
/// While ringing it:
/// - vibrates continuously (looping) until the user accepts or declines,
/// - plays the chosen ring sound (silent phone-ring feel, or police siren).
///
/// Declining either closes the screen or re-rings (if [shouldRepeat] is on).
/// Accepting stops the ringing and opens the [OngoingCallScreen].
class FakeCallScreen extends StatefulWidget {
  /// The name shown as the caller (e.g. "Mom", "Dad", "Boss").
  final String callerName;

  /// The phone number shown for the caller (for realism).
  final String callerPhone;

  /// If true, the call "rings" again if the user declines it.
  final bool shouldRepeat;

  /// If set, the ongoing call auto-ends after this many seconds.
  final int? autoEndSeconds;

  /// What plays while ringing.
  final RingSound ringSound;

  /// The ringtone for [RingSound.phoneRing]; null = the phone's default.
  final String? ringtoneUri;

  /// Test-only override for the ring sound. When null, the real ringtone or
  /// siren service is used based on [ringSound].
  @visibleForTesting
  final CallSound? sound;

  const FakeCallScreen({
    super.key,
    this.callerName = 'Mom',
    this.callerPhone = '+91 98765 43210',
    this.shouldRepeat = false,
    this.autoEndSeconds,
    this.ringSound = RingSound.phoneRing,
    this.ringtoneUri,
    this.sound,
  });

  @override
  State<FakeCallScreen> createState() => _FakeCallScreenState();
}

class _FakeCallScreenState extends State<FakeCallScreen> {
  /// The ring sound for this call. Only the chosen one is created (or an
  /// injected fake in tests), so we never spin up audio we won't use.
  late final CallSound _sound = widget.sound ??
      (widget.ringSound == RingSound.policeSiren
          ? PoliceSirenService()
          : DeviceRingtoneSound(widget.ringtoneUri));
  bool _handled = false; // true once accepted/declined

  @override
  void initState() {
    super.initState();
    _startRinging();
  }

  @override
  void dispose() {
    _stopRinging();
    _sound.dispose();
    super.dispose();
  }

  /// Begin the continuous ring: looping vibration (+ siren if chosen).
  Future<void> _startRinging() async {
    // Loop a "ring … pause … ring" vibration pattern forever. The `repeat`
    // index makes it keep going until we explicitly cancel it, so the phone
    // buzzes the entire time the call is "coming" — until the user taps a
    // button.
    if (await Vibration.hasVibrator()) {
      // Pattern is [wait, vibrate, wait, vibrate, …] in milliseconds.
      // repeat: 1 loops from the first vibrate, giving a steady ring buzz that
      // continues until we call Vibration.cancel() on accept/decline.
      Vibration.vibrate(
        pattern: [0, 800, 600, 800, 600],
        repeat: 1,
      );
    }

    // Play the chosen ring sound on top of the vibration.
    await _sound.start();
  }

  /// Stop all ringing feedback (vibration + sound). Best-effort: a failure to
  /// stop the audio must NEVER block the UI (e.g. answering the call), so each
  /// step is guarded and nothing here is awaited by the button handlers.
  Future<void> _stopRinging() async {
    try {
      Vibration.cancel();
    } catch (_) {/* ignore */}
    try {
      if (_sound.isActive) await _sound.stop();
    } catch (_) {/* ignore */}
  }

  /// Handle decline: either close, or re-ring if repeat is enabled.
  Future<void> _onDecline() async {
    if (_handled) return;
    await _stopRinging();

    if (widget.shouldRepeat && mounted) {
      // Brief pause, then ring again — mimics a persistent caller.
      await Future<void>.delayed(const Duration(seconds: 2));
      if (mounted && !_handled) {
        _startRinging();
      }
    } else if (mounted) {
      Navigator.pop(context);
    }
  }

  /// Handle accept: move to the ongoing-call screen IMMEDIATELY, then stop the
  /// ring in the background. Navigation must not depend on the audio stopping
  /// (if that ever hangs/throws, the green button would otherwise do nothing).
  /// The ringtone is also stopped by [dispose] when this screen is replaced.
  void _onAccept() {
    if (_handled) return;
    _handled = true;
    unawaited(_stopRinging());
    if (!mounted) return;
    // Replace the ringing screen with the ongoing call so the back button
    // doesn't bring the ringing screen back.
    Navigator.pushReplacement(
      context,
      MaterialPageRoute<void>(
        builder: (_) => OngoingCallScreen(
          callerName: widget.callerName,
          callerPhone: widget.callerPhone,
          autoEndSeconds: widget.autoEndSeconds,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return Scaffold(
      // Solid near-black like the stock phone-call screen, in both themes so
      // the fake call always looks real.
      backgroundColor: const Color(0xFF121212),
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light,
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 56),

              // Status line at the top, like a real incoming call.
              Text(
                t.incomingCall,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 15,
                  letterSpacing: 0.3,
                ),
              ),
              const SizedBox(height: 28),

              CallerAvatar(name: widget.callerName, radius: 56),
              const SizedBox(height: 24),

              // Caller name.
              Text(
                widget.callerName,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 34,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),

              // Caller phone number.
              Text(
                widget.callerPhone,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                  letterSpacing: 0.3,
                ),
              ),

              if (widget.shouldRepeat)
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Text(
                    t.callWillRepeat,
                    style: TextStyle(
                      color: Colors.yellow[200],
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),

              const Spacer(),

              // Quick replies, like the real dialer (cosmetic).
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _MiniAction(icon: Icons.alarm, label: t.cancel),
                  const SizedBox(width: 48),
                  _MiniAction(icon: Icons.message, label: t.decline),
                ],
              ),
              const SizedBox(height: 28),

              // Decline / Answer — big round buttons like a real call.
              Padding(
                padding: const EdgeInsets.fromLTRB(48, 0, 48, 48),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _AnswerButton(
                      color: const Color(0xFFEA4335),
                      icon: Icons.call_end,
                      label: t.decline,
                      onTap: _onDecline,
                    ),
                    _AnswerButton(
                      color: const Color(0xFF34A853),
                      icon: Icons.call,
                      label: t.accept,
                      onTap: _onAccept,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Big round answer/decline button used on the incoming-call screen.
class _AnswerButton extends StatelessWidget {
  final Color color;
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _AnswerButton({
    required this.color,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Material(
          color: color,
          shape: const CircleBorder(),
          elevation: 4,
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: onTap,
            child: SizedBox(
              width: 72,
              height: 72,
              child: Icon(icon, color: Colors.white, size: 34),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(label,
            style: const TextStyle(color: Colors.white70, fontSize: 13)),
      ],
    );
  }
}

/// Small cosmetic action (reminder / message) above the answer buttons.
class _MiniAction extends StatelessWidget {
  final IconData icon;
  final String label;

  const _MiniAction({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CircleAvatar(
          radius: 22,
          backgroundColor: Colors.white12,
          child: Icon(icon, color: Colors.white70, size: 20),
        ),
        const SizedBox(height: 6),
        Text(label,
            style: const TextStyle(color: Colors.white54, fontSize: 11)),
      ],
    );
  }
}
