import 'package:flutter/material.dart';

import '../../project_context.dart';
import '../../util.dart';
import '../../widgets/searchable_list_view.dart';
import '../terrain/edit_terrain.dart';

/// A widget for displaying and editing terrain types.
class ProjectTerrains extends StatefulWidget {
  /// Create an instance.
  const ProjectTerrains({
    required this.projectContext,
    Key? key,
  }) : super(key: key);

  /// The project context to use.
  final ProjectContext projectContext;

  /// Create state for this widget.
  @override
  ProjectTerrainsState createState() => ProjectTerrainsState();
}

/// State for [ProjectTerrains].
class ProjectTerrainsState extends State<ProjectTerrains> {
  /// Build a widget.
  @override
  Widget build(BuildContext context) {
    final world = widget.projectContext.world;
    final children = <SearchableListTile>[];
    for (var i = 0; i < world.terrains.length; i++) {
      final terrain = world.terrains[i];
      children.add(
        SearchableListTile(
          searchString: terrain.name,
          child: ListTile(
            autofocus: i == 0,
            title: Text(terrain.name),
            onTap: () async {
              await pushWidget(
                context: context,
                builder: (context) => EditTerrain(
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
    return SearchableListView(children: children);
  }
}
