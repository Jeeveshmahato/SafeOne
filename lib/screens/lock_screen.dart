import 'dart:async';

import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../services/app_lock_service.dart';
import '../widgets/pin_pad.dart';

/// The screen shown whenever the app is locked. The user types their PIN (or
/// uses biometrics). On success it calls [onUnlocked].
///
/// Wrong PINs are throttled with an escalating delay so the PIN can't be
/// brute-forced by tapping quickly.
class LockScreen extends StatefulWidget {
  const LockScreen({super.key, required this.onUnlocked});

  final VoidCallback onUnlocked;

  @override
  State<LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends State<LockScreen> {
  final AppLockService _lock = AppLockService();

  String _entry = '';
  String? _error;
  int _failedAttempts = 0;
  int _lockoutSeconds = 0;
  Timer? _lockoutTimer;
  bool _biometricAvailable = false;
  // Guards against stacking biometric prompts (e.g. the auto-prompt and a
  // button tap, or rapid rebuilds).
  bool _authInProgress = false;

  @override
  void initState() {
    super.initState();
    _maybePromptBiometric();
  }

  @override
  void dispose() {
    _lockoutTimer?.cancel();
    super.dispose();
  }

  Future<void> _maybePromptBiometric() async {
    final enabled = await _lock.isBiometricEnabled();
    final available = enabled && await _lock.canUseBiometrics();
    if (!mounted) return;
    setState(() => _biometricAvailable = available);
    if (available) _authenticateBiometric();
  }

  Future<void> _authenticateBiometric() async {
    if (_authInProgress) return;
    _authInProgress = true;
    final t = AppLocalizations.of(context);
    try {
      final ok = await _lock.authenticateBiometric(t.lockBiometricReason);
      if (ok && mounted) widget.onUnlocked();
    } finally {
      _authInProgress = false;
    }
  }

  void _startLockout() {
    // 0,0,0 then 15s, 30s, 60s… capped at 60s.
    final penalty = (_failedAttempts - 3).clamp(0, 100);
    if (penalty <= 0) return;
    _lockoutSeconds = (15 * penalty).clamp(15, 60);
    _lockoutTimer?.cancel();
    _lockoutTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      setState(() {
        _lockoutSeconds--;
        if (_lockoutSeconds <= 0) timer.cancel();
      });
    });
  }

  Future<void> _onChanged(String value) async {
    setState(() {
      _entry = value;
      _error = null;
    });
  }

  Future<void> _submit() async {
    final t = AppLocalizations.of(context);
    if (_lockoutSeconds > 0) return;
    if (await _lock.verifyPin(_entry)) {
      widget.onUnlocked();
      return;
    }
    _failedAttempts++;
    _startLockout();
    if (!mounted) return;
    setState(() {
      _entry = '';
      _error = t.lockWrongPin;
    });
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final lockedOut = _lockoutSeconds > 0;
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.shield_outlined, size: 56),
                const SizedBox(height: 16),
                Text(
                  t.lockTitle,
                  style: const TextStyle(
                      fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  t.lockSubtitle,
                  style: const TextStyle(color: Colors.black54),
                ),
                const SizedBox(height: 32),
                PinPad(
                  value: _entry,
                  onChanged: lockedOut ? (_) {} : _onChanged,
                  onSubmit: lockedOut ? null : _submit,
                  errorText: lockedOut
                      ? t.lockTooManyAttempts(_lockoutSeconds)
                      : _error,
                  // Login requires the full 6-digit PIN (the default).
                ),
                if (_biometricAvailable) ...[
                  const SizedBox(height: 16),
                  TextButton.icon(
                    onPressed: _authenticateBiometric,
                    icon: const Icon(Icons.fingerprint),
                    label: Text(t.lockUseBiometric),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
