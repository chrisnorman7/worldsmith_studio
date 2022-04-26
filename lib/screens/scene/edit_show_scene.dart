// ignore_for_file: prefer_final_parameters
import 'package:flutter/material.dart';
import 'package:worldsmith/worldsmith.dart';

import '../../project_context.dart';
import '../../widgets/cancel.dart';
import '../../widgets/command/call_command_list_tile.dart';
import '../../widgets/scene/scene_list_tile.dart';

/// Edit the given [showScene].
class EditShowScene extends StatefulWidget {
  /// Create an instance.
  const EditShowScene({
    required this.projectContext,
    required this.showScene,
    required this.onChanged,
    super.key,
  });

  /// The project context to use.
  final ProjectContext projectContext;

  /// The command to use.
  final ShowScene showScene;

  /// The function to call when [showScene] changes.
  final ValueChanged<ShowScene?> onChanged;

  /// Create state for this widget.
  @override
  EditShowSceneState createState() => EditShowSceneState();
}

/// State for [EditShowScene].
class EditShowSceneState extends State<EditShowScene> {
  /// Build a widget.
  @override
  Widget build(final BuildContext context) {
    final world = widget.projectContext.world;
    final scene = world.getScene(widget.showScene.sceneId);
    return Cancel(
      child: Scaffold(
        appBar: AppBar(
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                widget.onChanged(null);
              },
              child: const Icon(
                Icons.clear_outlined,
                semanticLabel: 'Clear Value',
              ),
            )
          ],
          title: const Text('Edit Show Scene'),
        ),
        body: ListView(
          children: [
            SceneListTile(
              projectContext: widget.projectContext,
              scene: scene,
              onChanged: (final value) {
                widget.showScene.sceneId = value.id;
                save();
              },
              autofocus: true,
            ),
            CallCommandListTile(
              projectContext: widget.projectContext,
              callCommand: widget.showScene.callCommand,
              onChanged: (final value) {
                widget.showScene.callCommand = value;
                save();
              },
            )
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
}
