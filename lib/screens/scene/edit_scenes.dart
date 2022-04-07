import 'package:flutter/material.dart';
import 'package:worldsmith/worldsmith.dart';

import '../../constants.dart';
import '../../project_context.dart';
import '../../util.dart';
import '../../widgets/cancel.dart';
import '../../widgets/center_text.dart';
import '../../widgets/searchable_list_view.dart';
import 'edit_scene.dart';

/// A widget for editing scenes.
class EditScenes extends StatefulWidget {
  /// Create an instance.
  const EditScenes({
    required this.projectContext,
    final Key? key,
  }) : super(key: key);

  /// The project context to use.
  final ProjectContext projectContext;

  /// Create state for this widget.
  @override
  EditScenesState createState() => EditScenesState();
}

/// State for [EditScenes].
class EditScenesState extends State<EditScenes> {
  /// Build a widget.
  @override
  Widget build(final BuildContext context) {
    final world = widget.projectContext.world;
    final scenes = world.scenes;
    final Widget child;
    if (scenes.isEmpty) {
      child = const CenterText(text: 'There are no scenes to show.');
    } else {
      final children = <SearchableListTile>[];
      for (var i = 0; i < scenes.length; i++) {
        final scene = scenes[i];
        final n = scene.sections.length;
        children.add(
          SearchableListTile(
            searchString: scene.name,
            child: ListTile(
              autofocus: i == 0,
              title: Text(scene.name),
              subtitle: Text('$n ${n == 1 ? "section" : "sections"}'),
              onTap: () async {
                await pushWidget(
                  context: context,
                  builder: (final context) => EditScene(
                    projectContext: widget.projectContext,
                    scene: scene,
                  ),
                );
                setState(() {});
              },
            ),
          ),
        );
      }
      child = SearchableListView(children: children);
    }
    return Cancel(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Scenes'),
        ),
        body: child,
        floatingActionButton: FloatingActionButton(
          autofocus: scenes.isEmpty,
          onPressed: () async {
            final scene = Scene(
              id: newId(),
              name: 'Untitled Scene',
              sections: [],
            );
            world.scenes.add(scene);
            widget.projectContext.save();
            setState(() {});
          },
          tooltip: 'Add Scene',
          child: createIcon,
        ),
      ),
    );
  }
}
