import 'dart:math';

import 'package:flutter/material.dart';

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

class _PinPadState extends State<PinPad> {
  final Random _rng = Random.secure();

  /// The 10 digit characters in display order. Index 0-8 fill the 3×3 grid,
  /// index 9 sits in the bottom-middle slot (so 0 is shuffled too, not always
  /// in a known place).
  late List<String> _keys = _buildKeys();

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
  }

  void _press(String digit) {
    if (widget.value.length >= widget.maxLength) return;
    widget.onChanged(widget.value + digit);
  }

  void _backspace() {
    if (widget.value.isEmpty) return;
    widget.onChanged(widget.value.substring(0, widget.value.length - 1));
  }

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.primary;
    final canSubmit =
        widget.onSubmit != null && widget.value.length >= widget.minLength;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // The dots.
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (var i = 0; i < widget.maxLength; i++)
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 8),
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: i < widget.value.length ? color : Colors.transparent,
                  border: Border.all(color: color, width: 2),
                ),
              ),
          ],
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 24,
          child: widget.errorText == null
              ? null
              : Text(
                  widget.errorText!,
                  style: const TextStyle(color: Colors.red, fontSize: 14),
                ),
        ),
        const SizedBox(height: 8),
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
                ? _iconKey(Icons.check_circle, widget.onSubmit!,
                    color: Colors.green)
                : const SizedBox(width: 72, height: 72),
            _key(_keys[9], () => _press(_keys[9])),
            _iconKey(Icons.backspace_outlined, _backspace),
          ],
        ),
      ],
    );
  }

  Widget _key(String label, VoidCallback onTap) {
    return _KeyButton(
        onTap: onTap, child: Text(label, style: const TextStyle(fontSize: 28)));
  }

  Widget _iconKey(IconData icon, VoidCallback onTap, {Color? color}) {
    return _KeyButton(onTap: onTap, child: Icon(icon, size: 28, color: color));
  }
}

class _KeyButton extends StatelessWidget {
  const _KeyButton({required this.onTap, required this.child});

  final VoidCallback onTap;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(6),
      child: InkResponse(
        onTap: onTap,
        radius: 40,
        child: SizedBox(
          width: 72,
          height: 72,
          child: Center(child: child),
        ),
      ),
    );
  }
}
