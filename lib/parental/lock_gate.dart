import 'package:flutter/material.dart';

import '../settings/settings_scope.dart';
import '../theme/palette.dart';
import 'pin_pad.dart';
import 'screen_time_scope.dart';

/// Wraps the whole app (via MaterialApp.builder) and drops a full-screen lock
/// over everything when the screen-time countdown runs out (SPEC.md §5).
/// The parent's PIN dismisses it and restarts the countdown.
class LockGate extends StatelessWidget {
  const LockGate({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final screenTime = ScreenTimeScope.of(context);
    final settings = SettingsScope.of(context).settings;
    final showLock = screenTime.locked && settings.hasPin;

    return Stack(
      children: [
        child,
        if (showLock)
          _LockOverlay(
            expectedPin: settings.parentalPin,
            onUnlock: screenTime.unlock,
          ),
      ],
    );
  }
}

class _LockOverlay extends StatefulWidget {
  const _LockOverlay({required this.expectedPin, required this.onUnlock});

  final String expectedPin;
  final VoidCallback onUnlock;

  @override
  State<_LockOverlay> createState() => _LockOverlayState();
}

class _LockOverlayState extends State<_LockOverlay> {
  String? _error;

  void _check(String pin) {
    if (pin == widget.expectedPin) {
      widget.onUnlock();
    } else {
      setState(() => _error = 'Fel kod');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Material(
        color: Palette.background,
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.lock_rounded,
                        size: 64, color: Palette.primary),
                    const SizedBox(height: 16),
                    const Text(
                      'Tiden är slut',
                      style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w700,
                          color: Palette.text),
                    ),
                    const SizedBox(height: 24),
                    PinPad(
                      title: 'Ange förälderkod',
                      subtitle: 'Fråga en vuxen',
                      errorText: _error,
                      onCompleted: _check,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
