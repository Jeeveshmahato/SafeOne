import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// The time units a [DurationField] can express.
enum TimeUnit {
  seconds,
  minutes,
  hours;

  String get label => switch (this) {
        TimeUnit.seconds => 'Seconds',
        TimeUnit.minutes => 'Minutes',
        TimeUnit.hours => 'Hours',
      };

  Duration toDuration(int value) => switch (this) {
        TimeUnit.seconds => Duration(seconds: value),
        TimeUnit.minutes => Duration(minutes: value),
        TimeUnit.hours => Duration(hours: value),
      };

  /// Minutes and hours only, for timers that can't be shorter than a minute.
  static const minutesAndHours = [TimeUnit.minutes, TimeUnit.hours];

  /// The largest of [units] that shows [d] as a whole number, so a saved
  /// "2 hours" comes back as 2 Hours rather than 120 Minutes.
  static TimeUnit bestFor(Duration d, List<TimeUnit> units) {
    for (final unit in units.reversed) {
      final size = unit.toDuration(1).inSeconds;
      if (d.inSeconds >= size && d.inSeconds % size == 0) return unit;
    }
    return units.first;
  }
}

/// A reusable control to pick a duration as a number + unit
/// (seconds / minutes / hours). Reports the chosen [Duration] via [onChanged].
///
/// Used everywhere the app lets the user set a time. [units] limits the
/// choice: timers that need at least a minute don't offer seconds.
class DurationField extends StatefulWidget {
  /// Starting duration.
  final Duration initial;

  /// The unit shown when the field first appears.
  final TimeUnit initialUnit;

  /// Called whenever a valid duration is entered.
  final ValueChanged<Duration> onChanged;

  /// The units offered, smallest first.
  final List<TimeUnit> units;

  const DurationField({
    super.key,
    required this.initial,
    required this.onChanged,
    this.initialUnit = TimeUnit.minutes,
    this.units = TimeUnit.values,
  });

  @override
  State<DurationField> createState() => _DurationFieldState();
}

class _DurationFieldState extends State<DurationField> {
  late TimeUnit _unit;
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _unit = widget.units.contains(widget.initialUnit)
        ? widget.initialUnit
        : widget.units.first;
    _controller = TextEditingController(text: '${_valueForUnit(_unit)}');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// The whole-number value of [widget.initial] expressed in [unit].
  int _valueForUnit(TimeUnit unit) {
    final secs = widget.initial.inSeconds;
    return switch (unit) {
      TimeUnit.seconds => secs,
      TimeUnit.minutes => (secs / 60).round().clamp(1, 1 << 31),
      TimeUnit.hours => (secs / 3600).round().clamp(1, 1 << 31),
    };
  }

  void _emit() {
    final value = int.tryParse(_controller.text.trim()) ?? 0;
    if (value > 0) widget.onChanged(_unit.toDuration(value));
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Number input.
        SizedBox(
          width: 96,
          child: TextField(
            controller: _controller,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: const InputDecoration(
              isDense: true,
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            ),
            onChanged: (_) => _emit(),
          ),
        ),
        const SizedBox(width: 12),
        // Unit selector.
        DropdownMenu<TimeUnit>(
          initialSelection: _unit,
          onSelected: (unit) {
            if (unit == null) return;
            setState(() => _unit = unit);
            _emit();
          },
          dropdownMenuEntries: widget.units
              .map((u) => DropdownMenuEntry(value: u, label: u.label))
              .toList(),
        ),
      ],
    );
  }
}
