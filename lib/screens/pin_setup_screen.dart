import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../services/app_lock_service.dart';
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
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(t.pinSaved)));
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
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.requireCurrent ? t.pinChangeTitle : t.pinSetTitle),
        // On first-run setup there is nothing to go back to.
        automaticallyImplyLeading: widget.requireCurrent,
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.lock_outline, size: 56),
                const SizedBox(height: 16),
                Text(
                  _title(t),
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  t.pinSetSubtitle,
                  style: const TextStyle(color: Colors.black54),
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
