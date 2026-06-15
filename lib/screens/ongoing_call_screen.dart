import 'dart:async';

import 'package:flutter/material.dart';
import 'package:vibration/vibration.dart';

import '../l10n/app_localizations.dart';
import '../widgets/caller_avatar.dart';

/// The ONGOING-call screen shown after the user accepts a fake call.
///
/// It looks like a real connected call: a running timer, mute / speaker /
/// keypad toggles (cosmetic, for realism), and a red "end call" button that
/// hangs up and closes the screen. It can also auto-end after a set time.
class OngoingCallScreen extends StatefulWidget {
  final String callerName;
  final String callerPhone;

  /// If set, the call hangs up automatically after this many seconds.
  final int? autoEndSeconds;

  const OngoingCallScreen({
    super.key,
    required this.callerName,
    required this.callerPhone,
    this.autoEndSeconds,
  });

  @override
  State<OngoingCallScreen> createState() => _OngoingCallScreenState();
}

class _OngoingCallScreenState extends State<OngoingCallScreen> {
  Timer? _elapsedTimer;
  Timer? _autoEndTimer;
  int _elapsedSeconds = 0;
  bool _muted = false;
  bool _speaker = false;
  bool _ended = false;

  @override
  void initState() {
    super.initState();

    // A short buzz to mimic the "call connected" feedback.
    _connectBuzz();

    // Count up the call duration once per second.
    _elapsedTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted && !_ended) setState(() => _elapsedSeconds++);
    });

    // Optional auto hang-up.
    if (widget.autoEndSeconds != null) {
      _autoEndTimer = Timer(
        Duration(seconds: widget.autoEndSeconds!),
        _endCall,
      );
    }
  }

  @override
  void dispose() {
    _elapsedTimer?.cancel();
    _autoEndTimer?.cancel();
    Vibration.cancel();
    super.dispose();
  }

  Future<void> _connectBuzz() async {
    if (await Vibration.hasVibrator()) {
      Vibration.vibrate(duration: 120);
    }
  }

  /// Format elapsed time as MM:SS.
  String _formatElapsed(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:'
        '${secs.toString().padLeft(2, '0')}';
  }

  /// Hang up and close the screen.
  void _endCall() {
    if (_ended) return;
    setState(() => _ended = true);
    _elapsedTimer?.cancel();
    _autoEndTimer?.cancel();
    Vibration.cancel();
    Future<void>.delayed(const Duration(milliseconds: 250), () {
      if (mounted) Navigator.pop(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF12303B), Color(0xFF0A0A0A)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 40),

              CallerAvatar(name: widget.callerName, radius: 48),
              const SizedBox(height: 18),

              Text(
                widget.callerName,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 30,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),

              // Live call timer (or "Call Ended").
              Text(
                _ended ? t.callEnded : _formatElapsed(_elapsedSeconds),
                style: TextStyle(
                  color: _ended ? Colors.redAccent : Colors.white70,
                  fontSize: 16,
                  letterSpacing: 1,
                ),
              ),

              if (widget.autoEndSeconds != null && !_ended)
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(
                    t.autoEndsIn(widget.autoEndSeconds! - _elapsedSeconds),
                    style: const TextStyle(color: Colors.white38, fontSize: 12),
                  ),
                ),

              const Spacer(),

              // In-call controls grid (like the Google Phone app).
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 36),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _ToggleControl(
                          icon: _muted ? Icons.mic_off : Icons.mic,
                          label: t.mute,
                          active: _muted,
                          onTap: () => setState(() => _muted = !_muted),
                        ),
                        _ToggleControl(
                          icon: Icons.dialpad,
                          label: t.keypad,
                          active: false,
                          onTap: () {},
                        ),
                        _ToggleControl(
                          icon: _speaker ? Icons.volume_up : Icons.volume_down,
                          label: t.speaker,
                          active: _speaker,
                          onTap: () => setState(() => _speaker = !_speaker),
                        ),
                      ],
                    ),
                    const SizedBox(height: 28),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _ToggleControl(
                          icon: Icons.add_call,
                          label: 'Add call',
                          active: false,
                          onTap: () {},
                        ),
                        _ToggleControl(
                          icon: Icons.pause,
                          label: 'Hold',
                          active: false,
                          onTap: () {},
                        ),
                        _ToggleControl(
                          icon: Icons.videocam_outlined,
                          label: 'Video',
                          active: false,
                          onTap: () {},
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),

              // End-call button — wide pill like the real dialer.
              Padding(
                padding: const EdgeInsets.only(bottom: 44),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Material(
                      color: const Color(0xFFEA4335),
                      shape: const StadiumBorder(),
                      elevation: 4,
                      child: InkWell(
                        customBorder: const StadiumBorder(),
                        onTap: _endCall,
                        child: const SizedBox(
                          width: 150,
                          height: 64,
                          child: Icon(Icons.call_end,
                              color: Colors.white, size: 32),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      t.endCall,
                      style:
                          const TextStyle(color: Colors.white70, fontSize: 12),
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

/// A round toggleable in-call control (mute, speaker, keypad).
class _ToggleControl extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback onTap;

  const _ToggleControl({
    required this.icon,
    required this.label,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: onTap,
          child: CircleAvatar(
            radius: 28,
            backgroundColor: active ? Colors.white : Colors.white24,
            child: Icon(
              icon,
              color: active ? Colors.black : Colors.white,
              size: 26,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
      ],
    );
  }
}
