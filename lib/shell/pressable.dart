import 'package:flutter/material.dart';

/// Adds a subtle scale-down while pressed for tactile tap feedback. Uses a
/// [Listener] so it only observes pointer events — the child's own InkWell /
/// onTap keeps handling the actual tap (no double-firing).
class PressableScale extends StatefulWidget {
  const PressableScale({super.key, required this.child, this.pressedScale = 0.95});

  final Widget child;
  final double pressedScale;

  @override
  State<PressableScale> createState() => _PressableScaleState();
}

class _PressableScaleState extends State<PressableScale> {
  bool _down = false;

  void _set(bool down) {
    if (_down != down) setState(() => _down = down);
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: (_) => _set(true),
      onPointerUp: (_) => _set(false),
      onPointerCancel: (_) => _set(false),
      child: AnimatedScale(
        scale: _down ? widget.pressedScale : 1.0,
        duration: const Duration(milliseconds: 90),
        curve: Curves.easeOut,
        child: widget.child,
      ),
    );
  }
}
