import 'package:flutter/material.dart';

import '../settings/settings_controller.dart';
import '../theme/palette.dart';
import 'pin_pad.dart';

/// Gates an action behind the parental PIN (SPEC.md §5). If no PIN is set yet,
/// runs the first-run "choose a PIN" flow (enter twice). Returns true on
/// success, false if the parent backs out.
Future<bool> showPinGate(BuildContext context, SettingsController controller) {
  return _push(context, controller, forceSet: false);
}

/// Forces the "choose a new PIN" flow even when a PIN already exists (used by
/// the "change PIN" action in settings).
Future<bool> showSetPin(BuildContext context, SettingsController controller) {
  return _push(context, controller, forceSet: true);
}

Future<bool> _push(
    BuildContext context, SettingsController controller, {required bool forceSet}) async {
  final ok = await Navigator.of(context).push<bool>(
    MaterialPageRoute(
      fullscreenDialog: true,
      builder: (_) => _PinGateScreen(controller: controller, forceSet: forceSet),
    ),
  );
  return ok ?? false;
}

class _PinGateScreen extends StatefulWidget {
  const _PinGateScreen({required this.controller, required this.forceSet});

  final SettingsController controller;
  final bool forceSet;

  @override
  State<_PinGateScreen> createState() => _PinGateScreenState();
}

class _PinGateScreenState extends State<_PinGateScreen> {
  String? _error;
  String? _firstEntry; // captured during the set flow, awaiting confirmation

  bool get _setting => widget.forceSet || !widget.controller.settings.hasPin;

  Future<void> _onCompleted(String pin) async {
    if (_setting) {
      if (_firstEntry == null) {
        setState(() {
          _firstEntry = pin;
          _error = null;
        });
      } else if (_firstEntry == pin) {
        await widget.controller
            .update(widget.controller.settings.copyWith(parentalPin: pin));
        if (mounted) Navigator.of(context).pop(true);
      } else {
        setState(() {
          _firstEntry = null;
          _error = 'Koderna matchar inte — försök igen';
        });
      }
    } else {
      if (pin == widget.controller.settings.parentalPin) {
        if (mounted) Navigator.of(context).pop(true);
      } else {
        setState(() => _error = 'Fel kod');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = _setting
        ? (_firstEntry == null ? 'Välj en förälderkod' : 'Bekräfta koden')
        : 'Ange förälderkod';
    return Scaffold(
      backgroundColor: Palette.background,
      appBar: AppBar(),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: PinPad(
                title: title,
                subtitle: _setting ? '4 siffror' : 'Fråga en vuxen',
                errorText: _error,
                onCompleted: _onCompleted,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
