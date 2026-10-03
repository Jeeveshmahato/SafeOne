import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../services/app_lock_service.dart';
import '../theme/app_theme.dart';
import '../widgets/app_ui.dart';
import '../widgets/pin_pad.dart';

/// Screen for creating a PIN (first run) or changing it (from Settings).
///
/// When [requireCurrent] is true the user must first type their existing PIN
/// before choosing a new one. On success the screen pops with `true`.
class PinSetupScreen extends StatefulWidget {
  const PinSetupScreen({super.key, this.requireCurrent = false});

  final bool requireCurrent;

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

  Future<void> _onChanged(String value) async {
    setState(() {
      _entry = value;
      _error = null;
    });
  }

  Future<void> _submit() async {
    final t = AppLocalizations.of(context);
    switch (_step) {
      case _Step.current:
        if (await _lock.verifyPin(_entry)) {
          setState(() {
            _step = _Step.create;
            _entry = '';
          });
        } else {
          setState(() {
            _error = t.lockWrongPin;
            _entry = '';
          });
        }
      case _Step.create:
        if (_entry.length != 6) {
          setState(() => _error = t.pinTooShort);
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
        await _lock.setPin(_entry);
        if (!mounted) return;
        showAppSnack(context, t.pinSaved, tone: Tone.success);
        Navigator.pop(context, true);
    }
  }

  String _title(AppLocalizations t) {
    return switch (_step) {
      _Step.current => t.pinCurrentStep,
      _Step.create => t.pinCreateStep,
      _Step.confirm => t.pinConfirmStep,
    };
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
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.requireCurrent ? t.pinChangeTitle : t.pinSetTitle),
        // On first-run setup there is nothing to go back to.
        automaticallyImplyLeading: widget.requireCurrent,
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconBadge(
                  icon: Icons.lock_rounded,
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
                  _title(t),
                  style: theme.textTheme.headlineSmall,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  t.pinSetSubtitle,
                  style: theme.textTheme.bodyMedium!
                      .copyWith(color: scheme.onSurfaceVariant),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                PinPad(
                  value: _entry,
                  onChanged: _onChanged,
                  onSubmit: _submit,
                  errorText: _error,
                  // All PIN steps are fixed at 6 digits (the default).
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
