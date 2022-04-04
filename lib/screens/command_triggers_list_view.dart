import 'package:flutter/material.dart';
import 'package:worldsmith/command_triggers.dart';

import '../widgets/cancel.dart';
import '../widgets/focus_text.dart';

/// A widget that shows the supported command triggers.
class CommandTriggersListView extends StatelessWidget {
  /// Create an instance.
  const CommandTriggersListView({final Key? key}) : super(key: key);

  @override
  Widget build(final BuildContext context) {
    final triggers = defaultTriggerMap.triggers;
    return Cancel(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Default Command Triggers'),
        ),
        body: Table(
          children: [
            const TableRow(
              children: [
                FocusText(
                  text: 'Trigger Name',
                  autofocus: true,
                ),
                FocusText(text: 'Trigger Description'),
                FocusText(text: 'Controller Button'),
                FocusText(text: 'Keyboard Key')
              ],
            ),
            ...[
              for (final trigger in triggers)
                TableRow(
                  children: [
                    FocusText(text: trigger.name),
                    FocusText(text: trigger.description),
                    FocusText(text: '${trigger.button?.name}'),
                    FocusText(
                      text: '${trigger.keyboardKey?.toPrintableString()}',
                    )
                  ],
                )
            ]
          ],
        ),
      ),
    );
  }
}
