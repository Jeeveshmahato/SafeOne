import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// A self-contained PIN entry widget: a row of dots showing how many digits
/// have been typed, plus a numeric keypad. It deliberately does NOT use the
/// system keyboard, so the PIN is never exposed to autofill/clipboard.
///
/// Security: by default the keypad is **scrambled** — the digit positions are
/// randomised (with a cryptographically-secure RNG) and re-shuffled at the
/// start of every entry attempt. This defeats shoulder-surfing and "smudge"
/// attacks, where someone learns the PIN from the finger path or fingerprints
/// left on the glass, because the layout is different each time.
///
/// The parent owns the entered value via [value] and reacts through
/// [onChanged]; the scramble order is the widget's own state.
class PinPad extends StatefulWidget {
  const PinPad({
    super.key,
    required this.value,
    required this.onChanged,
    this.maxLength = 6,
    // PINs are fixed at 6 digits. The lock screen overrides this so a
    // previously-set shorter PIN can still be entered (no lock-out on upgrade).
    this.minLength = 6,
    this.onSubmit,
    this.errorText,
    this.scramble = true,
  });

  final String value;
  final ValueChanged<String> onChanged;
  final int maxLength;
  final int minLength;

  /// Called when the user presses the confirm (✓) key, if the PIN is long
  /// enough. When null, no confirm key is shown.
  final VoidCallback? onSubmit;
  final String? errorText;

  /// Randomise the key positions for each attempt (security). Turn off only
  /// where layout predictability matters more than shoulder-surf resistance.
  final bool scramble;

  @override
  State<PinPad> createState() => _PinPadState();
}

class _PinPadState extends State<PinPad> with SingleTickerProviderStateMixin {
  final Random _rng = Random.secure();

  /// The 10 digit characters in display order. Index 0-8 fill the 3×3 grid,
  /// index 9 sits in the bottom-middle slot (so 0 is shuffled too, not always
  /// in a known place).
  late List<String> _keys = _buildKeys();

  /// Shakes the dots sideways when a new error appears (wrong PIN).
  late final AnimationController _shake = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 420),
  );

  List<String> _buildKeys() {
    if (!widget.scramble) {
      // Natural phone layout: 1-9 then 0.
      return ['1', '2', '3', '4', '5', '6', '7', '8', '9', '0'];
    }
    final digits = List<String>.generate(10, (i) => '$i');
    digits.shuffle(_rng);
    return digits;
  }

  @override
  void didUpdateWidget(PinPad oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Re-shuffle at the start of each fresh attempt: when the entry is cleared
    // back to empty (e.g. after a wrong PIN) or the scramble flag changes.
    final newAttempt = oldWidget.value.isNotEmpty && widget.value.isEmpty;
    if (oldWidget.scramble != widget.scramble || newAttempt) {
      setState(() => _keys = _buildKeys());
    }
    if (widget.errorText != null && widget.errorText != oldWidget.errorText) {
      HapticFeedback.heavyImpact();
      _shake.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _shake.dispose();
    super.dispose();
  }

  void _press(String digit) {
    if (widget.value.length >= widget.maxLength) return;
    HapticFeedback.selectionClick();
    widget.onChanged(widget.value + digit);
  }

  void _backspace() {
    if (widget.value.isEmpty) return;
    HapticFeedback.selectionClick();
    widget.onChanged(widget.value.substring(0, widget.value.length - 1));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final hasError = widget.errorText != null;
    final dotColor = hasError ? scheme.error : scheme.primary;
    final canSubmit =
        widget.onSubmit != null && widget.value.length >= widget.minLength;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // The dots, which shake on a wrong PIN.
        AnimatedBuilder(
          animation: _shake,
          builder: (context, child) => Transform.translate(
            offset: Offset(sin(_shake.value * pi * 6) * 10 * (1 - _shake.value), 0),
            child: child,
          ),
          child: Semantics(
            label: '${widget.value.length} / ${widget.maxLength}',
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (var i = 0; i < widget.maxLength; i++)
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    curve: Curves.easeOut,
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    width: i < widget.value.length ? 16 : 14,
                    height: i < widget.value.length ? 16 : 14,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: i < widget.value.length
                          ? dotColor
                          : Colors.transparent,
                      border: Border.all(
                        color: i < widget.value.length
                            ? dotColor
                            : scheme.outline,
                        width: 2,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 24,
          child: !hasError
              ? null
              : Semantics(
                  liveRegion: true,
                  child: Text(
                    widget.errorText!,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium!
                        .copyWith(color: scheme.error),
                  ),
                ),
        ),
        const SizedBox(height: 16),
        // The keypad: the 3×3 grid uses the (possibly scrambled) first 9 keys.
        for (var row = 0; row < 3; row++)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (var col = 0; col < 3; col++)
                _key(_keys[row * 3 + col],
                    () => _press(_keys[row * 3 + col])),
            ],
          ),
        // Bottom row: confirm (when allowed), the 10th key, backspace.
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            canSubmit
                ? _KeyButton(
                    onTap: widget.onSubmit!,
                    background: scheme.primary,
                    semanticLabel:
                        MaterialLocalizations.of(context).okButtonLabel,
                    child: Icon(Icons.arrow_forward_rounded,
                        size: 30, color: scheme.onPrimary),
                  )
                : const SizedBox(width: _KeyButton.size + 16),
            _key(_keys[9], () => _press(_keys[9])),
            _KeyButton(
              onTap: _backspace,
              background: Colors.transparent,
              semanticLabel:
                  MaterialLocalizations.of(context).deleteButtonTooltip,
              child: Icon(Icons.backspace_outlined,
                  size: 26, color: scheme.onSurfaceVariant),
            ),
          ],
        ),
      ],
    );
  }

  Widget _key(String label, VoidCallback onTap) {
    return _KeyButton(
      onTap: onTap,
      child: Text(
        label,
        style: Theme.of(context).textTheme.headlineMedium!.copyWith(
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }
}

class _KeyButton extends StatelessWidget {
  const _KeyButton({
    required this.onTap,
    required this.child,
    this.background,
    this.semanticLabel,
  });

  static const double size = 76;

  final VoidCallback onTap;
  final Widget child;
  final Color? background;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Semantics(
        button: true,
        label: semanticLabel,
        child: Material(
          color: background ?? scheme.surfaceContainerHigh,
          shape: const CircleBorder(),
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: onTap,
            child: SizedBox(
              width: size,
              height: size,
              child: Center(child: child),
            ),
          ),
        ),
      ),
    );
  }
}
