import 'package:flutter/material.dart';

import '../theme/palette.dart';

/// A big-button 4-digit PIN entry pad (SPEC.md §5). Calls [onCompleted] with
/// the 4-digit string once four digits are entered, then clears itself so the
/// caller can verify and show an error or move on.
class PinPad extends StatefulWidget {
  const PinPad({
    super.key,
    required this.title,
    required this.onCompleted,
    this.subtitle,
    this.errorText,
  });

  final String title;
  final String? subtitle;
  final String? errorText;
  final ValueChanged<String> onCompleted;

  static const int length = 4;

  @override
  State<PinPad> createState() => _PinPadState();
}

class _PinPadState extends State<PinPad> {
  String _entry = '';

  void _tap(String digit) {
    if (_entry.length >= PinPad.length) return;
    setState(() => _entry += digit);
    if (_entry.length == PinPad.length) {
      final pin = _entry;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) setState(() => _entry = '');
      });
      widget.onCompleted(pin);
    }
  }

  void _backspace() {
    if (_entry.isEmpty) return;
    setState(() => _entry = _entry.substring(0, _entry.length - 1));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          widget.title,
          textAlign: TextAlign.center,
          style: const TextStyle(
              fontSize: 24, fontWeight: FontWeight.w700, color: Palette.text),
        ),
        if (widget.subtitle != null) ...[
          const SizedBox(height: 6),
          Text(widget.subtitle!,
              style: const TextStyle(fontSize: 15, color: Palette.text)),
        ],
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (var i = 0; i < PinPad.length; i++)
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 8),
                width: 18,
                height: 18,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: i < _entry.length
                      ? Palette.primary
                      : Colors.transparent,
                  border: Border.all(color: Palette.text, width: 2),
                ),
              ),
          ],
        ),
        SizedBox(
          height: 36,
          child: Center(
            child: widget.errorText == null
                ? null
                : Text(
                    widget.errorText!,
                    style: const TextStyle(
                        color: Palette.wrong,
                        fontSize: 15,
                        fontWeight: FontWeight.w600),
                  ),
          ),
        ),
        _Pad(onDigit: _tap, onBackspace: _backspace),
      ],
    );
  }
}

class _Pad extends StatelessWidget {
  const _Pad({required this.onDigit, required this.onBackspace});

  final ValueChanged<String> onDigit;
  final VoidCallback onBackspace;

  @override
  Widget build(BuildContext context) {
    Widget digit(String d) => _PadKey(label: d, onTap: () => onDigit(d));
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          digit('1'),
          digit('2'),
          digit('3'),
        ]),
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          digit('4'),
          digit('5'),
          digit('6'),
        ]),
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          digit('7'),
          digit('8'),
          digit('9'),
        ]),
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          const _PadKey(),
          digit('0'),
          _PadKey(icon: Icons.backspace_outlined, onTap: onBackspace),
        ]),
      ],
    );
  }
}

class _PadKey extends StatelessWidget {
  const _PadKey({this.label, this.icon, this.onTap});

  final String? label;
  final IconData? icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    if (onTap == null) return const SizedBox(width: 84, height: 76);
    return Padding(
      padding: const EdgeInsets.all(6),
      child: SizedBox(
        width: 72,
        height: 64,
        child: Material(
          color: Colors.white,
          elevation: 1,
          borderRadius: BorderRadius.circular(14),
          child: InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: onTap,
            child: Center(
              child: icon != null
                  ? Icon(icon, size: 26, color: Palette.text)
                  : Text(
                      label!,
                      style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w600,
                          color: Palette.text),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
