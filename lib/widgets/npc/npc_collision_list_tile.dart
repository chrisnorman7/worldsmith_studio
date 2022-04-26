// ignore_for_file: prefer_final_parameters
import 'package:flutter/material.dart';
import 'package:worldsmith/worldsmith.dart';

import '../../project_context.dart';
import '../../screens/npc/edit_npc_collision.dart';
import '../../util.dart';
import '../../world_command_location.dart';

/// A list tile to show the given [npcCollision].
class NpcCollisionListTile extends StatelessWidget {
  /// Create an instance.
  const NpcCollisionListTile({
    required this.projectContext,
    required this.npcCollision,
    required this.onChanged,
    this.autofocus = false,
    this.title = 'Collision',
    super.key,
  });

  /// The project context to use.
  final ProjectContext projectContext;

  /// The npc collision to show and edit.
  final NpcCollision? npcCollision;

  /// The function to call when [npcCollision] changes.
  final ValueChanged<NpcCollision?> onChanged;

  /// The title for the resulting [ListTile].
  final String title;

  /// Whether the resulting [ListTile] should be autofocused.
  final bool autofocus;

  @override
  Widget build(final BuildContext context) {
    final value = npcCollision;
    final callCommand = value?.callCommand;
    final location = callCommand == null
        ? null
        : WorldCommandLocation.find(
            categories: projectContext.world.commandCategories,
            commandId: callCommand.commandId,
          );
    final String subtitle;
    if (location != null) {
      subtitle = location.description;
    } else if (value == null) {
      subtitle = 'No collision';
    } else {
      subtitle = 'Command not set';
    }
    return ListTile(
      autofocus: autofocus,
      title: Text(title),
      subtitle: Text(subtitle),
      onTap: () async {
        final defaultCollision = NpcCollision();
        if (value == null) {
          onChanged(defaultCollision);
        }
        await pushWidget(
          context: context,
          builder: (final context) => EditNpcCollision(
            projectContext: projectContext,
            npcCollision: defaultCollision,
            onChanged: onChanged,
          ),
        );
      },
    );
  }
}
