// ignore_for_file: prefer_final_parameters
import 'package:dart_sdl/dart_sdl.dart';
import 'package:flutter/material.dart';
import 'package:worldsmith/worldsmith.dart';
import 'package:ziggurat/ziggurat.dart';

import '../../constants.dart';
import '../../project_context.dart';
import '../../util.dart';
import '../../widgets/cancel.dart';
import '../../widgets/clickable.dart';
import '../../widgets/focus_text.dart';
import '../../widgets/get_text.dart';
import '../../widgets/select_item.dart';
import '../edit_command_keyboard_key.dart';

/// A widget for viewing custom command triggers.
class CustomCommandTriggersListView extends StatefulWidget {
  /// Create an instance.
  const CustomCommandTriggersListView({
    required this.projectContext,
    super.key,
  });

  /// The project context to use.
  final ProjectContext projectContext;

  ///  Create state for this widget.
  @override
  CustomCommandTriggersListViewState createState() =>
      CustomCommandTriggersListViewState();
}

/// State for [CustomCommandTriggersListView].
class CustomCommandTriggersListViewState
    extends State<CustomCommandTriggersListView> {
  /// Build a widget.
  @override
  Widget build(final BuildContext context) {
    final customCommandTriggers =
        widget.projectContext.world.customCommandTriggers;
    return Cancel(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Custom Command Triggers'),
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
                FocusText(text: 'Keyboard Key'),
                FocusText(text: 'Edit Command')
              ],
            ),
            ...customCommandTriggers.map<TableRow>(
              (trigger) {
                final commandTrigger = trigger.commandTrigger;
                return TableRow(
                  children: [
                    Clickable(
                      child: FocusText(text: commandTrigger.description),
                      onActivate: () => pushWidget(
                        context: context,
                        builder: (context) => GetText(
                          onDone: (value) {
                            Navigator.pop(context);
                            trigger.commandTrigger = CommandTrigger(
                              name: commandTrigger.name,
                              description: value,
                              button: commandTrigger.button,
                              keyboardKey: commandTrigger.keyboardKey,
                            );
                            save();
                          },
                          labelText: 'Description',
                          text: commandTrigger.description,
                          title: 'Trigger Description',
                        ),
                      ),
                    ),
                    Clickable(
                      child: FocusText(text: '${commandTrigger.button?.name}'),
                      onActivate: () => pushWidget(
                        context: context,
                        builder: (context) => SelectItem<GameControllerButton?>(
                          onDone: (button) {
                            Navigator.pop(context);
                            trigger.commandTrigger = CommandTrigger(
                              name: commandTrigger.name,
                              description: commandTrigger.description,
                              button: button,
                              keyboardKey: commandTrigger.keyboardKey,
                            );
                            save();
                          },
                          values: [
                            null,
                            ...GameControllerButton.values.where(
                              (element) =>
                                  element != GameControllerButton.invalid,
                            )
                          ],
                          getItemWidget: (value) {
                            final String text;
                            if (value == null) {
                              text = 'Clear';
                            } else {
                              text = value.name;
                            }
                            return Text(text);
                          },
                          title: 'Select Game Controller Button',
                          value: commandTrigger.button,
                        ),
                      ),
                    ),
                    Clickable(
                      child: FocusText(
                        text: trigger.commandTrigger.keyboardKey
                                ?.toPrintableString() ??
                            'null',
                      ),
                      onActivate: () => pushWidget(
                        context: context,
                        builder: (context) => EditCommandKeyboardKey(
                          keyboardKey: trigger.commandTrigger.keyboardKey ??
                              const CommandKeyboardKey(ScanCode.space),
                          onChanged: (value) {
                            trigger.commandTrigger = CommandTrigger(
                              name: commandTrigger.name,
                              description: commandTrigger.description,
                              button: commandTrigger.button,
                              keyboardKey: value,
                            );
                            save();
                          },
                        ),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {},
                      child:
                          const Icon(Icons.edit, semanticLabel: 'Edit Command'),
                    )
                  ],
                );
              },
            )
          ],
        ),
        floatingActionButton: FloatingActionButton(
          autofocus: customCommandTriggers.isEmpty,
          onPressed: () {
            final commandTrigger = CommandTrigger(
              name: newId(),
              description: 'Do something custom',
            );
            final customCommand = WorldCommandTrigger(
              commandTrigger: commandTrigger,
            );
            widget.projectContext.world.customCommandTriggers.add(
              customCommand,
            );
            save();
          },
          child: createIcon,
          tooltip: 'Add Custom Command Trigger',
        ),
      ),
    );
  }

  /// Save the project.
  void save() {
    widget.projectContext.save();
    setState(() {});
  }
}
