import 'dart:async';

import 'package:flutter/foundation.dart';

/// Tracks the per-session screen-time countdown and lock state (SPEC.md §5).
/// A fresh allowance starts each launch; when it runs out the app locks until
/// the parent enters the PIN ([unlock]).
class ScreenTimeController extends ChangeNotifier {
  ScreenTimeController({required this.limitMinutes}) {
    _start();
  }

  int limitMinutes;
  int _remainingSeconds = 0;
  bool _locked = false;
  Timer? _timer;

  int get remainingSeconds => _remainingSeconds;
  bool get locked => _locked;
  bool get active => limitMinutes > 0;

  void _start() {
    _timer?.cancel();
    _locked = false;
    _remainingSeconds = limitMinutes * 60;
    if (limitMinutes > 0) {
      _timer = Timer.periodic(const Duration(seconds: 1), _tick);
    }
    notifyListeners();
  }

  void _tick(Timer _) {
    if (_remainingSeconds <= 0) return;
    _remainingSeconds--;
    if (_remainingSeconds <= 0) {
      _locked = true;
      _timer?.cancel();
      notifyListeners(); // only notify on the lock transition, not every second
    }
  }

  /// Parent entered the PIN at the lock screen: grant a fresh allowance so the
  /// limit still applies after the extension.
  void unlock() => _start();

  /// Parent changed the limit in settings; restart with the new value.
  void setLimit(int minutes) {
    limitMinutes = minutes;
    _start();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
