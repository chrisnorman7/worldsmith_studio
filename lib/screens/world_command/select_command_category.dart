// ignore_for_file: prefer_final_parameters
import 'package:flutter/material.dart';
import 'package:worldsmith/worldsmith.dart';

import '../../project_context.dart';
import '../../widgets/cancel.dart';
import '../../widgets/center_text.dart';

/// A widget for selecting a [CommandCategory].
class SelectCommandCategory extends StatelessWidget {
  /// Create an instance.
  const SelectCommandCategory({
    required this.projectContext,
    required this.onDone,
    this.currentId,
    this.nullable = false,
    super.key,
  });

  /// The project context to use.
  final ProjectContext projectContext;

  /// The function to be called with the new value.
  final ValueChanged<CommandCategory?> onDone;

  /// The ID of the current value.
  final String? currentId;

  /// Whether or not the value can be set to null.
  final bool nullable;

  /// Build the widget.
  @override
  Widget build(final BuildContext context) {
    final listTiles = <ListTile>[];
    if (nullable) {
      listTiles.add(
        ListTile(
          autofocus: nullable == true && currentId == null,
          title: const Text('Clear'),
          onTap: () => onDone(null),
        ),
      );
    }
    for (var i = 0; i < projectContext.world.commandCategories.length; i++) {
      final category = projectContext.world.commandCategories[i];
      listTiles.add(
        ListTile(
          autofocus: currentId == category.id || (nullable == false && i == 0),
          selected: category.id == currentId,
          title: Text(category.name),
          onTap: () => onDone(category),
        ),
      );
    }
    return Cancel(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Select Category'),
        ),
        body: listTiles.isEmpty
            ? const CenterText(text: 'There are no command categories.')
            : ListView.builder(
                itemBuilder: (final context, final index) => listTiles[index],
                itemCount: listTiles.length,
              ),
      ),
    );
  }
}
