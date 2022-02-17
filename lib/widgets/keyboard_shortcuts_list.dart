import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'cancel.dart';

/// A keyboard shortcut and a description.
class KeyboardShortcut {
  /// Create an instance.
  const KeyboardShortcut({
    required this.description,
    required this.keyName,
    this.control = false,
    this.shift = false,
    this.alt = false,
  });

  /// The name of the primary key.
  final String keyName;

  /// Whether the control key is required.
  final bool control;

  /// Whether the shift key is required.
  final bool shift;

  /// Whether the alt key is required.
  final bool alt;

  /// The description of what this key does.
  final String description;

  /// Returns a string representation of the required key.
  String get keyDescription {
    final List<String> keys = [];
    if (control) {
      keys.add('Control');
    }
    if (alt) {
      keys.add('Alt');
    }
    if (shift) {
      keys.add('Shift');
    }
    keys.add(keyName);
    return keys.join(' + ');
  }
}

/// A widget for displaying a list of [keyboardShortcuts].
class KeyboardShortcuts extends StatelessWidget {
  /// Create an instance.
  const KeyboardShortcuts({
    required this.keyboardShortcuts,
    this.title = 'Keyboard Shortcuts',
    Key? key,
  }) : super(key: key);

  /// The keyboard shortcuts list to use.
  final List<KeyboardShortcut> keyboardShortcuts;

  /// The title of the resulting [Scaffold].
  final String title;

  @override
  Widget build(BuildContext context) => Cancel(
        child: Scaffold(
          appBar: AppBar(
            title: Text(title),
          ),
          body: ListView.builder(
            itemBuilder: (context, index) {
              final keyboardShortcut = keyboardShortcuts[index];
              return ListTile(
                autofocus: index == 0,
                title: Text(keyboardShortcut.keyDescription),
                subtitle: Text(keyboardShortcut.description),
                onTap: () {
                  final string = '${keyboardShortcut.keyDescription}: '
                      '${keyboardShortcut.description}';
                  Clipboard.setData(ClipboardData(text: string));
                },
              );
            },
            itemCount: keyboardShortcuts.length,
          ),
        ),
      );
}