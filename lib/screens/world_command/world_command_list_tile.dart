import 'package:flutter/material.dart';
import 'package:worldsmith/worldsmith.dart';

import '../../project_context.dart';
import '../../util.dart';
import 'select_command_category.dart';
import 'select_world_command.dart';

/// A list tile that allows the viewing and editing of a [currentId].
class WorldCommandListTile extends StatelessWidget {
  /// Create an instance.
  const WorldCommandListTile({
    required this.projectContext,
    required this.currentId,
    required this.onChanged,
    required this.title,
    this.nullable = false,
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

  /// Build a widget.
  @override
  Widget build(BuildContext context) {
    CommandCategory? currentCategory;
    WorldCommand? currentValue;
    if (currentId != null) {
      for (final category in projectContext.world.commandCategories) {
        final possibles = category.commands
            .where(
              (element) => element.id == currentId,
            )
            .toList();
        if (possibles.isNotEmpty) {
          currentValue = possibles.first;
          currentCategory = category;
          break;
        }
      }
    }
    return ListTile(
      title: Text(title),
      subtitle: Text(
        currentValue != null && currentCategory != null
            ? '${currentCategory.name} -> ${currentValue.name}'
            : 'Not set',
      ),
      onTap: () => pushWidget(
        context: context,
        builder: (context) => SelectCommandCategory(
          projectContext: projectContext,
          onDone: (commandCategory) {
            if (nullable == true && commandCategory == null) {
              Navigator.pop(context);
              return onChanged(null);
            }
            pushWidget(
              context: context,
              builder: (context) => SelectWorldCommand(
                category: commandCategory!,
                onDone: (worldCommand) {
                  Navigator.pop(context);
                  Navigator.pop(context);
                  onChanged(worldCommand);
                },
                currentId: currentValue?.id,
                nullable: nullable,
              ),
            );
          },
          currentId: currentCategory?.id,
          nullable: nullable,
        ),
      ),
    );
  }
}
