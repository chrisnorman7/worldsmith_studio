import 'package:flutter/material.dart';
import 'package:worldsmith/worldsmith.dart';

import '../../constants.dart';
import '../../project_context.dart';
import '../../util.dart';
import '../../widgets/cancel.dart';
import '../../widgets/center_text.dart';
import '../../widgets/searchable_list_view.dart';
import 'edit_terrain.dart';

/// A widget for displaying and editing terrain types.
class EditTerrains extends StatefulWidget {
  /// Create an instance.
  const EditTerrains({
    required this.projectContext,
    final Key? key,
  }) : super(key: key);

  /// The project context to use.
  final ProjectContext projectContext;

  /// Create state for this widget.
  @override
  EditTerrainsState createState() => EditTerrainsState();
}

/// State for [EditTerrains].
class EditTerrainsState extends State<EditTerrains> {
  /// Build a widget.
  @override
  Widget build(final BuildContext context) {
    final terrains = widget.projectContext.world.terrains;
    final Widget child;
    if (terrains.isEmpty) {
      child = const CenterText(text: 'There are no terrains to show.');
    } else {
      final children = <SearchableListTile>[];
      for (var i = 0; i < terrains.length; i++) {
        final terrain = terrains[i];
        children.add(
          SearchableListTile(
            searchString: terrain.name,
            child: ListTile(
              autofocus: i == 0,
              title: Text(terrain.name),
              onTap: () async {
                await pushWidget(
                  context: context,
                  builder: (final context) => EditTerrain(
                    projectContext: widget.projectContext,
                    terrain: terrain,
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
          title: const Text('Terrains'),
        ),
        body: child,
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            final terrain = Terrain(
              id: newId(),
              name: 'Untitled Terrain',
              slowWalk: WalkingOptions(
                interval: 1000,
                joystickValue: 0.1,
              ),
              fastWalk: WalkingOptions(
                interval: 500,
                joystickValue: 0.5,
              ),
            );
            terrains.add(terrain);
            widget.projectContext.save();
            await pushWidget(
              context: context,
              builder: (final context) => EditTerrain(
                projectContext: widget.projectContext,
                terrain: terrain,
              ),
            );
            setState(() {});
          },
          autofocus: terrains.isEmpty,
          tooltip: 'Add Terrain',
          child: createIcon,
        ),
      ),
    );
  }
}
