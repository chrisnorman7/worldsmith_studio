import 'package:flutter/material.dart';
import 'package:worldsmith/worldsmith.dart';

import '../../intents.dart';
import '../../project_context.dart';
import '../../util.dart';
import '../../widgets/cancel.dart';
import '../../widgets/center_text.dart';
import '../../widgets/keyboard_shortcuts_list.dart';

/// Select a [WorldCommand] from the given [category].
class SelectWorldCommand extends StatefulWidget {
  /// Create an instance.
  const SelectWorldCommand({
    required this.projectContext,
    required this.category,
    required this.onDone,
    this.currentId,
    this.nullable = false,
    Key? key,
  }) : super(key: key);

  /// The project context to use.
  final ProjectContext projectContext;

  /// The category to select a command from.
  final CommandCategory category;

  /// The function to call with the new value.
  final ValueChanged<WorldCommand?> onDone;

  /// The ID of the current command.
  final String? currentId;

  /// Whether or not the value can be set to `null`.
  final bool nullable;

  @override
  State<SelectWorldCommand> createState() => _SelectWorldCommandState();
}

class _SelectWorldCommandState extends State<SelectWorldCommand> {
  @override
  Widget build(BuildContext context) {
    final listTiles = <ListTile>[];
    if (widget.nullable) {
      listTiles.add(
        ListTile(
          autofocus: widget.currentId == null,
          title: const Text('Clear'),
          onTap: () => widget.onDone(null),
        ),
      );
    }
    for (var i = 0; i < widget.category.commands.length; i++) {
      final command = widget.category.commands[i];
      listTiles.add(
        ListTile(
          autofocus: widget.currentId == command.id ||
              (widget.nullable == false && i == 0),
          selected: command.id == widget.currentId,
          title: Text(command.name),
          onTap: () => widget.onDone(command),
        ),
      );
    }
    return Cancel(
      child: WithKeyboardShortcuts(
        keyboardShortcuts: const [
          KeyboardShortcut(
            description: 'Add a new command.',
            keyName: 'A',
            control: true,
          )
        ],
        child: CallbackShortcuts(
          bindings: {AddIntent.hotkey: addCommand},
          child: Scaffold(
            appBar: AppBar(
              actions: [
                ElevatedButton(
                  onPressed: addCommand,
                  child: const Icon(
                    Icons.add,
                    semanticLabel: 'Add Command',
                  ),
                )
              ],
              title: const Text('Select Command'),
            ),
            body: listTiles.isEmpty
                ? const CenterText(text: 'There are no commands to show.')
                : ListView.builder(
                    itemBuilder: (context, index) => listTiles[index],
                    itemCount: listTiles.length,
                  ),
          ),
        ),
      ),
    );
  }

  /// Add a new command.
  void addCommand() => setState(
        () {
          widget.category.commands.add(
            WorldCommand(id: newId(), name: 'Untitled Command'),
          );
          widget.projectContext.save();
        },
      );
}
