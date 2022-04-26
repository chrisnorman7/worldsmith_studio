// ignore_for_file: prefer_final_parameters
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../constants.dart';
import '../intents.dart';
import '../util.dart';
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
    final keys = <String>[];
    if (control) {
      keys.add(Platform.isMacOS ? 'CMD' : 'Control');
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
    super.key,
  });

  /// The keyboard shortcuts list to use.
  final List<KeyboardShortcut> keyboardShortcuts;

  /// The title of the resulting [Scaffold].
  final String title;

  /// Build the widget.
  @override
  Widget build(final BuildContext context) => Cancel(
        child: Scaffold(
          appBar: AppBar(
            actions: [
              ElevatedButton(
                onPressed: () => launchUrl(manualUrl),
                child: const Icon(
                  Icons.help_outline,
                  semanticLabel: 'Open Manual',
                ),
              )
            ],
            title: Text(title),
          ),
          body: ListView.builder(
            itemBuilder: (final context, final index) {
              final keyboardShortcut = keyboardShortcuts[index];
              return ListTile(
                autofocus: index == 0,
                title: Text(keyboardShortcut.keyDescription),
                subtitle: Text(keyboardShortcut.description),
                onTap: () {
                  final string = '${keyboardShortcut.keyDescription}: '
                      '${keyboardShortcut.description}';
                  setClipboardText(string);
                },
              );
            },
            itemCount: keyboardShortcuts.length,
          ),
        ),
      );
}

/// A widget with a list of [keyboardShortcuts] for display.
class WithKeyboardShortcuts extends StatelessWidget {
  /// Create an instance.
  const WithKeyboardShortcuts({
    required this.child,
    required this.keyboardShortcuts,
    super.key,
  });

  /// The widget below this one in the tree.
  final Widget child;

  /// The keyboard shortcuts to show.
  final List<KeyboardShortcut> keyboardShortcuts;

  /// Build the widget.
  @override
  Widget build(final BuildContext context) {
    final helpAction = CallbackAction<HelpIntent>(
      onInvoke: (final intent) => pushWidget(
        context: context,
        builder: (final context) =>
            KeyboardShortcuts(keyboardShortcuts: keyboardShortcuts),
      ),
    );
    return Shortcuts(
      shortcuts: {HelpIntent.hotkey: const HelpIntent()},
      child: Actions(
        actions: {HelpIntent: helpAction},
        child: child,
      ),
    );
  }
}
