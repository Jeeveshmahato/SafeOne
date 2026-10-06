import 'dart:async';

import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../services/app_lock_service.dart';
import '../theme/app_theme.dart';
import '../widgets/app_ui.dart';
import '../widgets/pin_pad.dart';
import 'lock_screen.dart' show formatWait;
import 'pin_reset_screen.dart';

/// Screen for creating a PIN (first run, or the first time a contact is
/// added) or changing it (from Settings).
///
/// When [requireCurrent] is true the user must first type their existing PIN
/// before choosing a new one. On success it calls [onComplete] if given,
/// otherwise the screen pops with `true`.
class PinSetupScreen extends StatefulWidget {
  const PinSetupScreen({
    super.key,
    this.kind = PinKind.app,
    this.requireCurrent = false,
    this.onComplete,
    this.title,
    this.closeWhenHidden = false,
  });

  final PinKind kind;
  final bool requireCurrent;
  final VoidCallback? onComplete;

  /// Override the default title (e.g. "Reset PIN").
  final String? title;

  /// Leave the screen if the app goes to the background. Used after a PIN
  /// reset, so a phone left on this screen can't be picked up and given a
  /// PIN by someone else.
  final bool closeWhenHidden;

  @override
  State<PinSetupScreen> createState() => _PinSetupScreenState();
}

enum _Step { current, create, confirm }

class _PinSetupScreenState extends State<PinSetupScreen> {
  final AppLockService _lock = AppLockService();

  late _Step _step = widget.requireCurrent ? _Step.current : _Step.create;
  String _entry = '';
  String _firstPin = '';
  String? _error;
  bool _busy = false;
  Duration _lockout = Duration.zero;
  Timer? _lockoutTimer;
  AppLifecycleListener? _lifecycle;

  bool get _isApp => widget.kind == PinKind.app;

  @override
  void initState() {
    super.initState();
    if (widget.requireCurrent) _loadLockout();
    if (widget.closeWhenHidden) {
      _lifecycle = AppLifecycleListener(onHide: () {
        if (mounted && !AppLockService.systemPromptActive) {
          Navigator.maybePop(context, false);
        }
      });
    }
  }

  @override
  void dispose() {
    _lockoutTimer?.cancel();
    _lifecycle?.dispose();
    super.dispose();
  }

  Future<void> _loadLockout() async {
    final left = await _lock.lockoutRemaining(widget.kind);
    if (mounted && left > Duration.zero) _startLockout(left);
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
    if (_busy) return;
    setState(() => _busy = true);
    try {
      await _handleStep();
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _handleStep() async {
    final t = AppLocalizations.of(context);
    switch (_step) {
      case _Step.current:
        // Throttled like the lock screen, otherwise this step would be a
        // free way to guess the PIN.
        final result = await _lock.attempt(_entry, widget.kind);
        if (!mounted) return;
        if (result.success) {
          setState(() {
            _step = _Step.create;
            _entry = '';
          });
        } else {
          setState(() {
            _error = t.lockWrongPin;
            _entry = '';
          });
          if (result.lockedOut) _startLockout(result.lockout);
        }
      case _Step.create:
        if (_entry.length != 6) {
          setState(() => _error = t.pinTooShort);
          return;
        }
        final reuseError = await _reuseError(t);
        if (!mounted) return;
        if (reuseError != null) {
          setState(() {
            _error = reuseError;
            _entry = '';
          });
          return;
        }
        setState(() {
          _firstPin = _entry;
          _step = _Step.confirm;
          _entry = '';
        });
      case _Step.confirm:
        if (_entry != _firstPin) {
          setState(() {
            _error = t.pinMismatch;
            _step = _Step.create;
            _entry = '';
            _firstPin = '';
          });
          return;
        }
        await _lock.setPin(_entry, widget.kind);
        if (!mounted) return;
        showAppSnack(context, t.pinSaved, tone: Tone.success);
        if (widget.onComplete != null) {
          widget.onComplete!();
        } else {
          Navigator.pop(context, true);
        }
    }
  }

  /// The two PINs must differ, or the contacts PIN adds no protection. The
  /// comparison goes through the other PIN's throttle so this screen can't be
  /// used to guess it.
  Future<String?> _reuseError(AppLocalizations t) async {
    final other = _isApp ? PinKind.contacts : PinKind.app;
    if (!await _lock.isPinSet(other)) return null;
    final result = await _lock.attempt(_entry, other);
    if (result.success) return _isApp ? t.pinSameAsContacts : t.pinSameAsApp;
    if (result.lockedOut) return t.lockTryAgainIn(formatWait(result.lockout));
    return null;
  }

  Future<void> _forgot() async {
    final reset = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => PinResetScreen(kind: widget.kind)),
    );
    if (reset != true || !mounted) return;
    // A new PIN was chosen as part of the reset; nothing left to do here.
    if (widget.onComplete != null) {
      widget.onComplete!();
    } else {
      Navigator.pop(context, true);
    }
  }

  String _stepTitle(AppLocalizations t) {
    return switch (_step) {
      _Step.current => t.pinCurrentStep,
      _Step.create => t.pinCreateStep,
      _Step.confirm => t.pinConfirmStep,
    };
  }

  String _screenTitle(AppLocalizations t) {
    if (widget.title != null) return widget.title!;
    if (_isApp) return widget.requireCurrent ? t.pinChangeTitle : t.pinSetTitle;
    return widget.requireCurrent
        ? t.contactsPinChangeTitle
        : t.contactsPinSetTitle;
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    // Progress through the steps (current PIN is only asked when changing).
    final steps = widget.requireCurrent
        ? const [_Step.current, _Step.create, _Step.confirm]
        : const [_Step.create, _Step.confirm];
    final stepIndex = steps.indexOf(_step);
    final lockedOut = _step == _Step.current && _lockout > Duration.zero;
    final disabled = lockedOut || _busy;
    return Scaffold(
      appBar: AppBar(
        title: Text(_screenTitle(t)),
        // On first-run setup there is nothing to go back to.
        automaticallyImplyLeading: widget.onComplete == null,
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconBadge(
                  icon: _isApp ? Icons.lock_rounded : Icons.contacts_rounded,
                  color: scheme.primary,
                  background: scheme.secondaryContainer,
                  size: 64,
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    for (var i = 0; i < steps.length; i++)
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.symmetric(horizontal: 3),
                        width: i == stepIndex ? 28 : 12,
                        height: 6,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(3),
                          color: i <= stepIndex
                              ? scheme.primary
                              : scheme.outlineVariant,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 20),
                Text(
                  _stepTitle(t),
                  style: theme.textTheme.headlineSmall,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  _isApp ? t.pinSetSubtitle : t.contactsPinSetSubtitle,
                  style: theme.textTheme.bodyMedium!
                      .copyWith(color: scheme.onSurfaceVariant),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                PinPad(
                  value: _entry,
                  onChanged: disabled ? (_) {} : _onChanged,
                  onSubmit: disabled ? null : _submit,
                  errorText: lockedOut
                      ? t.lockTryAgainIn(formatWait(_lockout))
                      : _error,
                  // All PIN steps are fixed at 6 digits (the default).
                ),
                if (_step == _Step.current) ...[
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
