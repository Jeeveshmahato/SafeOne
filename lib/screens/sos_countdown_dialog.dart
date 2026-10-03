import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../l10n/app_localizations.dart';
import '../theme/app_theme.dart';

/// Shows a full-screen countdown before the SOS is actually sent.
///
/// Why: it lets you cancel an accidental alert (handy with "shake to send").
///
/// [seconds] is how long the countdown lasts (the user can change this in
/// Settings).
///
/// Returns:
///   - true  -> the countdown finished (or user tapped "Send now")  => send SOS
///   - false -> the user tapped "Cancel" (or pressed back)          => do nothing
///
/// Usage:
///   final confirmed = await showSosCountdown(context, seconds: 5);
///   if (confirmed) { ...send the SOS... }
Future<bool> showSosCountdown(BuildContext context, {required int seconds}) async {
  final bool? result = await showGeneralDialog<bool>(
    context: context,
    barrierDismissible: false, // user must choose Cancel or Send
    barrierColor: Colors.transparent,
    transitionDuration: const Duration(milliseconds: 220),
    pageBuilder: (context, _, _) => _SosCountdown(startSeconds: seconds),
    transitionBuilder: (context, animation, _, child) =>
        FadeTransition(opacity: animation, child: child),
  );
  // Closed without a value (e.g. back button) means "cancelled".
  return result ?? false;
}

class _SosCountdown extends StatefulWidget {
  final int startSeconds;

  const _SosCountdown({required this.startSeconds});

  @override
  State<_SosCountdown> createState() => _SosCountdownState();
}

class _SosCountdownState extends State<_SosCountdown>
    with SingleTickerProviderStateMixin {
  // Drives both the ring and the number. `preserve` is essential: with the
  // default behaviour, Android's "Remove animations" setting would shrink the
  // duration to ~0 and send the SOS instantly with no chance to cancel.
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: Duration(seconds: widget.startSeconds.clamp(1, 1 << 20)),
    animationBehavior: AnimationBehavior.preserve,
  )
    ..addStatusListener((status) {
      if (status == AnimationStatus.completed) _finish(true);
    })
    ..forward();

  bool _done = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _finish(bool send) {
    if (_done || !mounted) return;
    _done = true;
    _controller.stop();
    Navigator.pop(context, send);
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final s = context.safety;
    final onSos = s.onSos;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Material(
        type: MaterialType.transparency,
        child: ColoredBox(
          color: s.sos,
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
              child: Column(
                children: [
                  Icon(Icons.sos_rounded, color: onSos, size: 40),
                  const SizedBox(height: 16),
                  Text(
                    t.sosCountdownTitle,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.headlineMedium!
                        .copyWith(color: onSos),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    t.sosCountdownBody,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyLarge!
                        .copyWith(color: onSos.withValues(alpha: 0.85)),
                  ),
                  const Spacer(),
                  // The draining ring with the seconds left inside.
                  AnimatedBuilder(
                    animation: _controller,
                    builder: (context, _) {
                      final left = (widget.startSeconds *
                              (1 - _controller.value))
                          .ceil()
                          .clamp(0, widget.startSeconds);
                      return SizedBox(
                        width: 220,
                        height: 220,
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            CircularProgressIndicator(
                              value: 1 - _controller.value,
                              strokeWidth: 10,
                              strokeCap: StrokeCap.round,
                              color: onSos,
                              backgroundColor: onSos.withValues(alpha: 0.2),
                            ),
                            Center(
                              child: Semantics(
                                liveRegion: true,
                                child: Text(
                                  '$left',
                                  style: theme.textTheme.displayLarge!.copyWith(
                                    color: onSos,
                                    fontSize: 88,
                                    fontFeatures: const [
                                      FontFeature.tabularFigures(),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  const Spacer(),
                  Text(
                    t.sosCountdownHint,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium!
                        .copyWith(color: onSos.withValues(alpha: 0.85)),
                  ),
                  const SizedBox(height: 16),
                  // Cancel is the big, high-contrast action: under stress it
                  // must be the easiest thing on screen to hit.
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      style: FilledButton.styleFrom(
                        minimumSize: const Size.fromHeight(64),
                        backgroundColor: onSos,
                        foregroundColor: s.sos,
                        textStyle: theme.textTheme.titleLarge,
                      ),
                      onPressed: () => _finish(false),
                      child: Text(t.cancel),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size.fromHeight(56),
                        foregroundColor: onSos,
                        side: BorderSide(
                            color: onSos.withValues(alpha: 0.6), width: 1.5),
                      ),
                      onPressed: () => _finish(true),
                      child: Text(t.sosSendNow),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
