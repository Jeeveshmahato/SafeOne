import 'dart:async';

import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../services/app_lock_service.dart';
import '../services/vault.dart';
import '../widgets/app_ui.dart';
import '../widgets/pin_pad.dart';
import 'pin_reset_screen.dart';

/// Asks for a PIN (or biometrics) and calls [onUnlocked] when it's right.
///
/// Used for the app lock ([PinKind.app]) and, pushed as its own page, for the
/// contacts PIN ([PinKind.contacts]) before the contact list can be changed.
///
/// The app PIN uses the normal keypad and can be skipped with a fingerprint.
/// The contacts PIN guards who gets the SOS, so it is stricter: the keys are
/// shuffled for every attempt and only the PIN itself opens it.
///
/// Wrong PINs are throttled by [AppLockService] with an escalating delay that
/// is stored on the phone, so it survives closing and reopening the app.
class LockScreen extends StatefulWidget {
  const LockScreen({
    super.key,
    required this.onUnlocked,
    this.kind = PinKind.app,
    this.title,
    this.subtitle,
    this.showForgot = true,
  });

  final VoidCallback onUnlocked;
  final PinKind kind;

  /// Override the default heading/explanation for [kind].
  final String? title;
  final String? subtitle;

  /// Hide "Forgot PIN?" when this screen is itself part of a reset.
  final bool showForgot;

  @override
  State<LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends State<LockScreen> {
  final AppLockService _lock = AppLockService();

  String _entry = '';
  String? _error;
  bool _checking = false;
  Duration _lockout = Duration.zero;
  Timer? _lockoutTimer;
  bool _biometricAvailable = false;
  // Guards against stacking biometric prompts (e.g. the auto-prompt and a
  // button tap, or rapid rebuilds).
  bool _authInProgress = false;
  // Set when the app really left the screen (not when the fingerprint prompt
  // covered it), so coming back asks for the fingerprint again.
  bool _wasAway = false;
  late final AppLifecycleListener _lifecycle;

  @override
  void initState() {
    super.initState();
    _lifecycle = AppLifecycleListener(
      onHide: _onHide,
      onResume: _onResume,
    );
    _loadLockout();
    _maybePromptBiometric();
  }

  @override
  void dispose() {
    _lockoutTimer?.cancel();
    _lifecycle.dispose();
    super.dispose();
  }

  Future<void> _loadLockout() async {
    final left = await _lock.lockoutRemaining(widget.kind);
    if (mounted && left > Duration.zero) _startLockout(left);
  }

  /// Opens the fingerprint / face prompt by itself, so the user only has to
  /// touch the sensor. The button stays as a way back to it after cancelling.
  Future<void> _maybePromptBiometric() async {
    if (widget.kind != PinKind.app) return;
    final enabled = await _lock.isBiometricEnabled();
    final available = enabled && await _lock.canUseBiometrics();
    if (!mounted) return;
    setState(() => _biometricAvailable = available);
    // The lock can be put up while the app is going to the background; then
    // the prompt is shown when the app is back on screen (see [_onResume]).
    if (available &&
        WidgetsBinding.instance.lifecycleState == AppLifecycleState.resumed) {
      _authenticateBiometric();
    } else if (available) {
      _wasAway = true;
    }
  }

  void _onHide() {
    // The system prompt itself hides the app on some phones: that isn't
    // leaving, and re-prompting for it would loop after a cancel.
    if (!AppLockService.systemPromptActive && !_authInProgress) {
      _wasAway = true;
    }
  }

  void _onResume() {
    if (!_wasAway) return;
    _wasAway = false;
    if (_biometricAvailable) _authenticateBiometric();
  }

  Future<void> _authenticateBiometric() async {
    if (_authInProgress) return;
    _authInProgress = true;
    final t = AppLocalizations.of(context);
    try {
      final ok = await _lock.authenticateBiometric(t.lockBiometricReason);
      if (!ok || !mounted) return;
      if (widget.kind == PinKind.app) {
        // The fingerprint must also open the encrypted data, through the
        // hardware key that only a strong biometric can release.
        final result = await Vault.instance.openWithRecovery();
        if (!mounted) return;
        if (result != RecoveryResult.opened &&
            result != RecoveryResult.noVault) {
          setState(() => _error = t.lockBiometricNeedsPin);
          return;
        }
      }
      await _lock.clearFailures(widget.kind);
      widget.onUnlocked();
    } finally {
      _authInProgress = false;
    }
  }

  void _startLockout(Duration wait) {
    _lockoutTimer?.cancel();
    final until = DateTime.now().add(wait);
    setState(() => _lockout = wait);
    _lockoutTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      final left = until.difference(DateTime.now());
      setState(() => _lockout = left.isNegative ? Duration.zero : left);
      if (_lockout == Duration.zero) timer.cancel();
    });
  }

  Future<void> _onChanged(String value) async {
    setState(() {
      _entry = value;
      _error = null;
    });
  }

  Future<void> _submit() async {
    if (_lockout > Duration.zero || _checking) return;
    final t = AppLocalizations.of(context);
    setState(() => _checking = true);
    final result = await _lock.attempt(_entry, widget.kind);
    if (!mounted) return;
    setState(() => _checking = false);
    if (result.success) {
      widget.onUnlocked();
      return;
    }
    setState(() {
      _entry = '';
      _error = t.lockWrongPin;
    });
    if (result.lockedOut) _startLockout(result.lockout);
  }

  Future<void> _forgot() async {
    final reset = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => PinResetScreen(kind: widget.kind)),
    );
    // The user proved who they are and chose a new PIN.
    if (reset == true && mounted) widget.onUnlocked();
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final lockedOut = _lockout > Duration.zero;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isApp = widget.kind == PinKind.app;
    return Scaffold(
      // The contacts PIN is asked on its own page, with a way back.
      appBar: isApp ? null : AppBar(),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isApp)
                  const AppLogo(size: 64)
                else
                  IconBadge(
                    icon: Icons.contacts_rounded,
                    color: scheme.primary,
                    background: scheme.secondaryContainer,
                    size: 64,
                  ),
                const SizedBox(height: 20),
                Text(
                  widget.title ??
                      (isApp ? t.lockTitle : t.contactsPinEnterTitle),
                  textAlign: TextAlign.center,
                  style: theme.textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                Text(
                  widget.subtitle ??
                      (isApp ? t.lockSubtitle : t.contactsPinEnterSubtitle),
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium!
                      .copyWith(color: scheme.onSurfaceVariant),
                ),
                const SizedBox(height: 32),
                PinPad(
                  value: _entry,
                  scramble: !isApp,
                  onChanged: lockedOut || _checking ? (_) {} : _onChanged,
                  onSubmit: lockedOut || _checking ? null : _submit,
                  errorText: lockedOut
                      ? t.lockTryAgainIn(formatWait(_lockout))
                      : _error,
                ),
                if (_biometricAvailable) ...[
                  const SizedBox(height: 16),
                  FilledButton.tonalIcon(
                    onPressed: _authenticateBiometric,
                    icon: const Icon(Icons.fingerprint_rounded),
                    label: Text(t.lockUseBiometric),
                  ),
                ],
                if (widget.showForgot) ...[
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: _forgot,
                    child: Text(t.lockForgotPin),
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

/// "45s" under a minute, otherwise "4:05".
String formatWait(Duration d) {
  final seconds = (d.inMilliseconds / 1000).ceil();
  if (seconds < 60) return '${seconds}s';
  return '${seconds ~/ 60}:${(seconds % 60).toString().padLeft(2, '0')}';
}
