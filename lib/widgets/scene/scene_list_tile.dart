import 'package:flutter/material.dart';
import 'package:worldsmith/worldsmith.dart';

import '../../project_context.dart';
import '../../util.dart';
import '../select_item.dart';

/// A list tile that shows a [scene].
class SceneListTile extends StatefulWidget {
  /// Create an instance.
  const SceneListTile({
    required this.projectContext,
    required this.scene,
    required this.onChanged,
    this.title = 'Scene',
    this.autofocus = false,
    final Key? key,
  }) : super(key: key);

  /// The project context to use.
  final ProjectContext projectContext;

  /// The scene to show.
  final Scene scene;

  /// The function to call when [scene] changes.
  final ValueChanged<Scene> onChanged;

  /// The title of the resulting [ListTile].
  final String title;

  /// Whether the resulting [ListTile] should be autofocused.
  final bool autofocus;

  /// Create state for this widget.
  @override
  SceneListTileState createState() => SceneListTileState();
}

/// State for [SceneListTile].
class SceneListTileState extends State<SceneListTile> {
  /// Build a widget.
  @override
  Widget build(final BuildContext context) {
    final scene = widget.scene;
    final world = widget.projectContext.world;
    return ListTile(
      autofocus: widget.autofocus,
      title: Text(widget.title),
      subtitle: Text(scene.name),
      onTap: () => pushWidget(
        context: context,
        builder: (final context) => SelectItem<Scene>(
          onDone: (final value) {
            Navigator.pop(context);
            widget.onChanged(value);
          },
          values: world.scenes,
          getItemWidget: (final item) => Text(item.name),
          title: 'Select Scene',
          value: widget.scene,
        ),
      ),
    );
  }
}
