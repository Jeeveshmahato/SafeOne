import 'package:flutter/material.dart';

/// A fake "calculator" that disguises the app.
///
/// If someone nearby is watching, this looks like an ordinary calculator. It
/// actually works (you can do simple sums). To secretly return to the safety
/// app, LONG-PRESS the result display at the top.
class DecoyScreen extends StatefulWidget {
  const DecoyScreen({super.key});

  @override
  State<DecoyScreen> createState() => _DecoyScreenState();
}

class _DecoyScreenState extends State<DecoyScreen> {
  String _display = '0';
  double _stored = 0;
  String _pendingOp = '';
  bool _freshEntry = true; // next digit starts a new number

  void _onKey(String key) {
    setState(() {
      switch (key) {
        case 'C':
          _display = '0';
          _stored = 0;
          _pendingOp = '';
          _freshEntry = true;
        case '+':
        case '-':
        case '×':
        case '÷':
          _stored = double.tryParse(_display) ?? 0;
          _pendingOp = key;
          _freshEntry = true;
        case '=':
          _display = _formatResult(_calculate());
          _pendingOp = '';
          _freshEntry = true;
        case '.':
          if (_freshEntry) {
            _display = '0.';
            _freshEntry = false;
          } else if (!_display.contains('.')) {
            _display += '.';
          }
        default: // a digit 0-9
          if (_freshEntry || _display == '0') {
            _display = key;
            _freshEntry = false;
          } else {
            _display += key;
          }
      }
    });
  }

  double _calculate() {
    final current = double.tryParse(_display) ?? 0;
    switch (_pendingOp) {
      case '+':
        return _stored + current;
      case '-':
        return _stored - current;
      case '×':
        return _stored * current;
      case '÷':
        return current == 0 ? 0 : _stored / current;
      default:
        return current;
    }
  }

  /// Show whole numbers without a trailing ".0".
  String _formatResult(double value) {
    if (value == value.roundToDouble()) {
      return value.toInt().toString();
    }
    return value.toString();
  }

  @override
  Widget build(BuildContext context) {
    // The button layout, row by row.
    const rows = [
      ['C', '÷'],
      ['7', '8', '9', '×'],
      ['4', '5', '6', '-'],
      ['1', '2', '3', '+'],
      ['0', '.', '='],
    ];

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            // The result display. Long-press here to secretly exit.
            GestureDetector(
              onLongPress: () => Navigator.pop(context),
              child: Container(
                width: double.infinity,
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.all(24),
                child: Text(
                  _display,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 64,
                    fontWeight: FontWeight.w300,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
            const Spacer(),
            // The calculator buttons.
            ...rows.map((row) {
              return Row(
                children: row.map((key) {
                  return Expanded(
                    flex: key == '0' ? 1 : 1,
                    child: _CalcButton(
                      label: key,
                      onTap: () => _onKey(key),
                    ),
                  );
                }).toList(),
              );
            }),
          ],
        ),
      ),
    );
  }
}

/// One calculator key.
class _CalcButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _CalcButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isOperator = ['÷', '×', '-', '+', '='].contains(label);
    final isClear = label == 'C';
    final Color bg = isOperator
        ? Colors.orange
        : isClear
            ? Colors.redAccent
            : const Color(0xFF333333);

    return Padding(
      padding: const EdgeInsets.all(6),
      child: SizedBox(
        height: 72,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: bg,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          onPressed: onTap,
          child: Text(label, style: const TextStyle(fontSize: 26)),
        ),
      ),
    );
  }
}
