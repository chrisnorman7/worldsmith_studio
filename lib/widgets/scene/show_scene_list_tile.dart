// ignore_for_file: prefer_final_parameters
import 'package:flutter/material.dart';
import 'package:worldsmith/worldsmith.dart';

import '../../intents.dart';
import '../../project_context.dart';
import '../../screens/scene/edit_scene.dart';
import '../../screens/scene/edit_show_scene.dart';
import '../../util.dart';
import '../../world_command_location.dart';

/// A widget that shows a [showScene] command.
class ShowSceneListTile extends StatefulWidget {
  /// Create an instance.
  const ShowSceneListTile({
    required this.projectContext,
    required this.showScene,
    required this.onChanged,
    this.title = 'Show Scene',
    this.autofocus = false,
    super.key,
  });

  /// The project context to use.
  final ProjectContext projectContext;

  /// The show scene command to use.
  final ShowScene? showScene;

  /// The function to call when [showScene] changes.
  final ValueChanged<ShowScene?> onChanged;

  /// The title of the resulting [ListTile].
  final String title;

  /// Whether the resulting [ListTile] should be autofocused.
  final bool autofocus;

  /// Create state for this widget.
  @override
  ShowSceneListTileState createState() => ShowSceneListTileState();
}

/// State for [ShowSceneListTile].
class ShowSceneListTileState extends State<ShowSceneListTile> {
  /// Build a widget.
  @override
  Widget build(final BuildContext context) {
    final world = widget.projectContext.world;
    final showScene = widget.showScene;
    final scene = showScene == null ? null : world.getScene(showScene.sceneId);
    final callCommand = showScene?.callCommand;
    final location = callCommand == null
        ? null
        : WorldCommandLocation.find(
            categories: world.commandCategories,
            commandId: callCommand.commandId,
          );
    return CallbackShortcuts(
      bindings: {
        EditIntent.hotkey: () async {
          if (scene != null) {
            await pushWidget(
              context: context,
              builder: (final context) => EditScene(
                projectContext: widget.projectContext,
                scene: scene,
              ),
            );
            setState(() {});
          }
        }
      },
      child: ListTile(
        autofocus: widget.autofocus,
        title: Text(widget.title),
        subtitle: Text(
          scene == null ? 'Not set' : '${scene.name} (${location?.description}',
        ),
        onTap: () async {
          if (world.scenes.isEmpty) {
            return showError(
              context: context,
              message: 'There are no scenes to show.',
            );
          }
          final value = showScene ?? ShowScene(sceneId: world.scenes.first.id);
          if (widget.showScene == null) {}
          widget.onChanged(value);
          await pushWidget(
            context: context,
            builder: (final context) => EditShowScene(
              projectContext: widget.projectContext,
              showScene: value,
              onChanged: widget.onChanged,
            ),
          );
        },
      ),
    );
  }
}
