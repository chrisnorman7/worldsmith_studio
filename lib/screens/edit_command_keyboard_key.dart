// ignore_for_file: prefer_final_parameters
import 'package:dart_sdl/dart_sdl.dart';
import 'package:flutter/material.dart';
import 'package:ziggurat/ziggurat.dart';

import '../util.dart';
import '../widgets/cancel.dart';
import '../widgets/select_item.dart';

/// A widget for editing the given [keyboardKey].
class EditCommandKeyboardKey extends StatefulWidget {
  /// Create an instance.
  const EditCommandKeyboardKey({
    required this.keyboardKey,
    required this.onChanged,
    super.key,
  });

  /// The keyboard key to edit.
  final CommandKeyboardKey keyboardKey;

  /// The function to call when [keyboardKey] has changed.
  final ValueChanged<CommandKeyboardKey?> onChanged;

  /// Create state for this widget.
  @override
  EditCommandKeyboardKeyState createState() => EditCommandKeyboardKeyState();
}

/// State for [EditCommandKeyboardKey].
class EditCommandKeyboardKeyState extends State<EditCommandKeyboardKey> {
  /// The keyboard key to work with.
  late CommandKeyboardKey keyboardKey;
  @override
  void initState() {
    super.initState();
    keyboardKey = widget.keyboardKey;
  }

  /// Build a widget.
  @override
  Widget build(final BuildContext context) => Cancel(
        child: Scaffold(
          appBar: AppBar(
            actions: [
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  widget.onChanged(null);
                },
                child: const Icon(
                  Icons.clear,
                  semanticLabel: 'Clear Key',
                ),
              )
            ],
            title: const Text('Keyboard Key'),
          ),
          body: ListView(
            children: [
              ListTile(
                autofocus: true,
                title: const Text('Scan Code'),
                subtitle: Text(keyboardKey.scanCode.name),
                onTap: () => pushWidget(
                  context: context,
                  builder: (final context) => SelectItem<ScanCode>(
                    onDone: (final value) {
                      Navigator.pop(context);
                      submitKey(scanCode: value);
                    },
                    values: ScanCode.values,
                    getItemWidget: (final value) => Text(value.name),
                    title: 'Select Key',
                    value: keyboardKey.scanCode,
                  ),
                ),
              ),
              CheckboxListTile(
                value: keyboardKey.controlKey,
                onChanged: (value) => submitKey(
                  controlKey: value ?? false,
                ),
                title: Text(
                  '${keyboardKey.controlKey ? "Disable" : "Enable"} '
                  'Control Key',
                ),
              ),
              CheckboxListTile(
                value: keyboardKey.shiftKey,
                onChanged: (value) => submitKey(
                  shiftKey: value ?? false,
                ),
                title: Text(
                  '${keyboardKey.shiftKey ? "Disable" : "Enable"} Shift Key',
                ),
              ),
              CheckboxListTile(
                value: keyboardKey.altKey,
                onChanged: (value) => submitKey(
                  altKey: value ?? false,
                ),
                title: Text(
                  '${keyboardKey.altKey ? "Disable" : "Enable"} Alt Key',
                ),
              )
            ],
          ),
        ),
      );

  /// Submit a new key to the `onChanged` function.
  void submitKey({
    ScanCode? scanCode,
    bool? altKey,
    bool? controlKey,
    bool? shiftKey,
  }) {
    keyboardKey = CommandKeyboardKey(
      scanCode ?? keyboardKey.scanCode,
      altKey: altKey ?? keyboardKey.altKey,
      controlKey: controlKey ?? keyboardKey.controlKey,
      shiftKey: shiftKey ?? keyboardKey.shiftKey,
    );
    widget.onChanged(keyboardKey);
    setState(() {});
  }
}
