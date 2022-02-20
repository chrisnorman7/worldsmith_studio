import 'package:flutter/material.dart';
import 'package:worldsmith/worldsmith.dart';

import '../../widgets/center_text.dart';

/// Select a [WorldCommand] from the given [category].
class SelectWorldCommand extends StatelessWidget {
  /// Create an instance.
  const SelectWorldCommand({
    required this.category,
    required this.onDone,
    this.currentId,
    this.nullable = false,
    Key? key,
  }) : super(key: key);

  /// The category to select a command from.
  final CommandCategory category;

  /// The function to call with the new value.
  final ValueChanged<WorldCommand?> onDone;

  /// The ID of the current command.
  final String? currentId;

  /// Whether or not the value can be set to `null`.
  final bool nullable;

  @override
  Widget build(BuildContext context) {
    final listTiles = <ListTile>[];
    if (nullable) {
      listTiles.add(
        ListTile(
          autofocus: currentId == null,
          title: const Text('Clear'),
          onTap: () => onDone(null),
        ),
      );
    }
    for (var i = 0; i < category.commands.length; i++) {
      final command = category.commands[i];
      listTiles.add(
        ListTile(
          autofocus: currentId == command.id || (nullable == false && i == 0),
          title: Text(command.name),
          onTap: () => onDone(command),
        ),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Command'),
      ),
      body: listTiles.isEmpty
          ? const CenterText(text: 'There are no commands to show.')
          : ListView.builder(
              itemBuilder: (context, index) => listTiles[index],
              itemCount: listTiles.length,
            ),
    );
  }
}
