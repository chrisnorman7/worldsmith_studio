// ignore_for_file: prefer_final_parameters
import 'package:dart_sdl/dart_sdl.dart';
import 'package:flutter/material.dart';
import 'package:ziggurat/ziggurat.dart';

import '../project_context.dart';
import '../util.dart';
import '../widgets/cancel.dart';
import '../widgets/clickable.dart';
import '../widgets/focus_text.dart';
import '../widgets/get_text.dart';
import '../widgets/select_item.dart';
import 'edit_command_keyboard_key.dart';

/// A widget that shows the supported command triggers.
class CommandTriggersListView extends StatefulWidget {
  /// Create an instance.
  const CommandTriggersListView({
    required this.projectContext,
    super.key,
  });

  /// The project context to use.
  final ProjectContext projectContext;

  @override
  State<CommandTriggersListView> createState() =>
      _CommandTriggersListViewState();
}

class _CommandTriggersListViewState extends State<CommandTriggersListView> {
  @override
  Widget build(final BuildContext context) {
    final defaultTriggers = widget.projectContext.world.defaultCommandTriggers;
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
                  text: 'Trigger Description',
                  autofocus: true,
                ),
                FocusText(text: 'Controller Button'),
                FocusText(text: 'Keyboard Key')
              ],
            ),
            ...[
              for (final trigger in defaultTriggers)
                TableRow(
                  children: [
                    Clickable(
                      child: FocusText(text: trigger.description),
                      onActivate: () => pushWidget(
                        context: context,
                        builder: (context) => GetText(
                          onDone: (value) {
                            Navigator.pop(context);
                            alterCommandTrigger(
                              name: trigger.name,
                              description: value,
                              button: trigger.button,
                              keyboardKey: trigger.keyboardKey,
                            );
                          },
                          labelText: 'Description',
                          text: trigger.description,
                          title: 'Trigger Description',
                        ),
                      ),
                    ),
                    Clickable(
                      onActivate: () => pushWidget(
                        context: context,
                        builder: (context) => SelectItem<GameControllerButton?>(
                          onDone: (value) {
                            Navigator.pop(context);
                            alterCommandTrigger(
                              name: trigger.name,
                              description: trigger.description,
                              button: value,
                              keyboardKey: trigger.keyboardKey,
                            );
                          },
                          values: const [null, ...GameControllerButton.values],
                          getItemWidget: (value) => Text(
                            value == null ? 'Clear' : value.name,
                          ),
                          title: 'Game Controller Button',
                          value: trigger.button,
                        ),
                      ),
                      child: FocusText(text: '${trigger.button?.name}'),
                    ),
                    Clickable(
                      onActivate: () => pushWidget(
                        context: context,
                        builder: (context) => EditCommandKeyboardKey(
                          keyboardKey: trigger.keyboardKey ??
                              const CommandKeyboardKey(ScanCode.space),
                          onChanged: (value) => alterCommandTrigger(
                            name: trigger.name,
                            description: trigger.description,
                            button: trigger.button,
                            keyboardKey: value,
                          ),
                        ),
                      ),
                      child: FocusText(
                        text: '${trigger.keyboardKey?.toPrintableString()}',
                      ),
                    ),
                  ],
                )
            ]
          ],
        ),
      ),
    );
  }

  /// Save the project.
  void save() {
    widget.projectContext.save();
    setState(() {});
  }

  /// Alter a default trigger.
  void alterCommandTrigger({
    required String name,
    required String description,
    GameControllerButton? button,
    CommandKeyboardKey? keyboardKey,
  }) {
    final defaultCommandTriggers =
        widget.projectContext.world.defaultCommandTriggers;
    final index =
        defaultCommandTriggers.indexWhere((element) => element.name == name);
    defaultCommandTriggers.removeAt(index);
    final newTrigger = CommandTrigger(
      name: name,
      description: description,
      button: button,
      keyboardKey: keyboardKey,
    );
    if (index == defaultCommandTriggers.length) {
      defaultCommandTriggers.add(newTrigger);
    } else {
      defaultCommandTriggers.insert(index, newTrigger);
    }
    save();
  }
}
