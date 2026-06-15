import 'package:flutter/material.dart';

/// A circular caller avatar like the Google Phone app: a coloured circle with
/// the caller's first initial (or a person icon when there's no name). The
/// colour is derived from the name so each caller looks consistent.
class CallerAvatar extends StatelessWidget {
  const CallerAvatar({super.key, required this.name, this.radius = 56});

  final String name;
  final double radius;

  static const _palette = [
    Color(0xFF1A73E8), // blue
    Color(0xFF34A853), // green
    Color(0xFFEA4335), // red
    Color(0xFFFBBC04), // amber
    Color(0xFF9334E6), // purple
    Color(0xFF12B5CB), // teal
    Color(0xFFE8710A), // orange
  ];

  Color get _color {
    if (name.isEmpty) return _palette[0];
    final sum = name.codeUnits.fold<int>(0, (a, b) => a + b);
    return _palette[sum % _palette.length];
  }

  String get _initial {
    final trimmed = name.trim();
    return trimmed.isEmpty ? '' : trimmed.characters.first.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: radius,
      backgroundColor: _color,
      child: _initial.isEmpty
          ? Icon(Icons.person, size: radius, color: Colors.white)
          : Text(
              _initial,
              style: TextStyle(
                color: Colors.white,
                fontSize: radius * 0.8,
                fontWeight: FontWeight.w500,
              ),
            ),
    );
  }
}
