import 'package:flutter/material.dart';
import 'package:worldsmith/worldsmith.dart';

import '../../intents.dart';
import '../../project_context.dart';
import '../../screens/world_command/edit_world_command.dart';
import '../../screens/world_command/select_command_category.dart';
import '../../screens/world_command/select_world_command.dart';
import '../../util.dart';
import '../../world_command_location.dart';
import '../keyboard_shortcuts_list.dart';

/// A list tile that allows the viewing and editing of a [currentId].
class WorldCommandListTile extends StatefulWidget {
  /// Create an instance.
  const WorldCommandListTile({
    required this.projectContext,
    required this.currentId,
    required this.onChanged,
    required this.title,
    this.nullable = false,
    this.autofocus = false,
    Key? key,
  }) : super(key: key);

  /// The project context to use.
  final ProjectContext projectContext;

  /// The command to display.
  final String? currentId;

  /// The function to be called when the value changes.
  final ValueChanged<WorldCommand?> onChanged;

  /// The title of the resulting [ListTile].
  final String title;

  /// Whether or not the value can be set to `null`.
  final bool nullable;

  /// Whether or not the resulting [ListTile] is autofocused.
  final bool autofocus;

  @override
  State<WorldCommandListTile> createState() => _WorldCommandListTileState();
}

class _WorldCommandListTileState extends State<WorldCommandListTile> {
  /// Build a widget.
  @override
  Widget build(BuildContext context) {
    final id = widget.currentId;
    final WorldCommandLocation? location = id == null
        ? null
        : WorldCommandLocation.find(
            categories: widget.projectContext.world.commandCategories,
            commandId: id,
          );
    final currentCategory = location?.category;
    final currentValue = location?.command;
    return WithKeyboardShortcuts(
      child: CallbackShortcuts(
        child: ListTile(
          autofocus: widget.autofocus,
          title: Text(widget.title),
          subtitle: Text(
            location == null
                ? 'Not set'
                : '${location.category.name} -> ${location.command.name}',
          ),
          onTap: () => pushWidget(
            context: context,
            builder: (context) => SelectCommandCategory(
              projectContext: widget.projectContext,
              onDone: (commandCategory) {
                if (widget.nullable == true && commandCategory == null) {
                  Navigator.pop(context);
                  return widget.onChanged(null);
                }
                pushWidget(
                  context: context,
                  builder: (context) => SelectWorldCommand(
                    projectContext: widget.projectContext,
                    category: commandCategory!,
                    onDone: (worldCommand) {
                      Navigator.pop(context);
                      Navigator.pop(context);
                      widget.onChanged(worldCommand);
                    },
                    currentId: currentValue?.id,
                    nullable: widget.nullable,
                  ),
                );
              },
              currentId: currentCategory?.id,
              nullable: widget.nullable,
            ),
          ),
        ),
        bindings: {
          EditIntent.hotkey: () async {
            final category = currentCategory;
            final command = currentValue;
            if (category != null && command != null) {
              await pushWidget(
                context: context,
                builder: (context) => EditWorldCommand(
                  projectContext: widget.projectContext,
                  category: category,
                  command: command,
                ),
              );
              widget.projectContext.save();
              setState(() {});
            }
          }
        },
      ),
      keyboardShortcuts: const [
        KeyboardShortcut(
          description: 'Edit the command.',
          keyName: 'E',
          control: true,
        )
      ],
    );
  }
}
