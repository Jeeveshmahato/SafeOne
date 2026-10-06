import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../services/app_lock_service.dart';
import '../services/app_reset_service.dart';
import '../services/vault.dart';
import '../theme/app_theme.dart';
import '../widgets/app_ui.dart';
import 'lock_screen.dart';
import 'pin_setup_screen.dart';

/// "Forgot PIN?": lets the owner choose a new PIN without a server.
///
/// SafeOne never stores the PIN, so it can't be recovered, only replaced, and
/// only after the person proves it's their phone:
///   * Any PIN: with the phone's own screen lock (PIN, pattern, fingerprint…).
///   * Contacts PIN, if the phone has no screen lock: with the app PIN.
///   * App PIN, as a last resort: erase all SafeOne data and start over, so
///     a stranger can't reset the PIN and read what was there.
///
/// Pops with `true` once a new PIN has been saved.
class PinResetScreen extends StatefulWidget {
  const PinResetScreen({super.key, required this.kind});

  final PinKind kind;

  @override
  State<PinResetScreen> createState() => _PinResetScreenState();
}

class _PinResetScreenState extends State<PinResetScreen> {
  final AppLockService _lock = AppLockService();

  bool? _deviceSecure; // null while checking
  bool _busy = false;
  // Whether the app was already unlocked (reset from Settings) when this
  // screen opened, as opposed to reset from the lock screen.
  final bool _appUnlocked = Vault.instance.isOpen;

  @override
  void initState() {
    super.initState();
    _lock.isDeviceSecure().then((secure) {
      if (mounted) setState(() => _deviceSecure = secure);
    });
  }

  Future<void> _verifyWithDevice() async {
    final t = AppLocalizations.of(context);
    setState(() => _busy = true);
    final ok = await _lock.authenticateDevice(t.pinResetDeviceReason);
    if (!mounted) return;
    setState(() => _busy = false);
    if (!ok) {
      showAppSnack(context, t.pinResetDeviceFailed, tone: Tone.danger);
      return;
    }
    if (widget.kind == PinKind.app) {
      // The new PIN must be able to open the existing encrypted data, so
      // the vault is opened with the hardware recovery key first.
      final result = await Vault.instance.openWithRecovery();
      if (!mounted) return;
      switch (result) {
        case RecoveryResult.opened:
        case RecoveryResult.noVault:
          break;
        case RecoveryResult.needsStrongAuth:
          showAppSnack(context, t.pinResetNeedsStrongAuth, tone: Tone.danger);
          return;
        case RecoveryResult.unavailable:
          await showDialog<void>(
            context: context,
            builder: (context) => AlertDialog(
              content: Text(t.pinResetRecoveryUnavailable),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(MaterialLocalizations.of(context).okButtonLabel),
                ),
              ],
            ),
          );
          return;
      }
    }
    await _chooseNewPin();
  }

  Future<void> _verifyWithAppPin() async {
    final t = AppLocalizations.of(context);
    final ok = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => LockScreen(
          kind: PinKind.app,
          title: t.pinResetWithAppPin,
          subtitle: t.pinResetWithAppPinSubtitle,
          showForgot: false,
          onUnlocked: () => Navigator.pop(context, true),
        ),
      ),
    );
    if (ok == true && mounted) await _chooseNewPin();
  }

  Future<void> _chooseNewPin() async {
    final t = AppLocalizations.of(context);
    final saved = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => PinSetupScreen(
          kind: widget.kind,
          title: t.pinResetTitle,
          closeWhenHidden: true,
        ),
      ),
    );
    if (saved == true) {
      if (mounted) Navigator.pop(context, true);
    } else if (widget.kind == PinKind.app && !_appUnlocked) {
      // Gave up before choosing a PIN: don't leave the data open behind the
      // lock screen.
      Vault.instance.lock();
    }
  }

  Future<void> _erase() async {
    final t = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        icon: Icon(Icons.warning_amber_rounded, color: scheme.error),
        title: Text(t.pinResetEraseConfirmTitle),
        content: Text(t.pinResetEraseConfirmBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(MaterialLocalizations.of(context).cancelButtonLabel),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: scheme.error,
              foregroundColor: scheme.onError,
              minimumSize: const Size(0, 44),
            ),
            onPressed: () => Navigator.pop(context, true),
            child: Text(t.pinResetEraseConfirm),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    setState(() => _busy = true);
    // The app gate listens for this and restarts from PIN setup, closing
    // every open screen (including this one).
    await AppResetService.eraseEverything();
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final secure = _deviceSecure;
    final isApp = widget.kind == PinKind.app;
    return Scaffold(
      appBar: AppBar(title: Text(t.pinResetTitle)),
      body: secure == null || _busy
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: EdgeInsets.fromLTRB(
                  16, 8, 16, 32 + MediaQuery.paddingOf(context).bottom),
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(4, 8, 4, 20),
                  child: Text(
                    t.pinResetIntro,
                    style: theme.textTheme.bodyLarge!
                        .copyWith(color: scheme.onSurfaceVariant),
                  ),
                ),
                if (secure)
                  Card(
                    child: ListTile(
                      leading: const Icon(Icons.phonelink_lock_rounded),
                      title: Text(t.pinResetWithDevice),
                      subtitle: Text(t.pinResetWithDeviceSubtitle),
                      trailing: const Icon(Icons.chevron_right_rounded),
                      onTap: _verifyWithDevice,
                    ),
                  )
                else ...[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(4, 0, 4, 12),
                    child: Text(
                      t.pinResetNoDeviceLock,
                      style: theme.textTheme.bodyMedium,
                    ),
                  ),
                  if (!isApp)
                    Card(
                      child: ListTile(
                        leading: const Icon(Icons.lock_rounded),
                        title: Text(t.pinResetWithAppPin),
                        subtitle: Text(t.pinResetWithAppPinSubtitle),
                        trailing: const Icon(Icons.chevron_right_rounded),
                        onTap: _verifyWithAppPin,
                      ),
                    ),
                ],
                // Erasing is only for the app PIN: for the contacts PIN it
                // would let anyone holding the unlocked app wipe the SOS list.
                if (isApp) ...[
                  const SizedBox(height: 12),
                  Card(
                    child: ListTile(
                      leading: Icon(Icons.delete_forever_rounded,
                          color: scheme.error),
                      title: Text(t.pinResetErase,
                          style: TextStyle(color: scheme.error)),
                      subtitle: Text(t.pinResetEraseSubtitle),
                      onTap: _erase,
                    ),
                  ),
                ],
              ],
            ),
    );
  }
}
