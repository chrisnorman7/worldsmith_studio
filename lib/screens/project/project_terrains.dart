import 'package:flutter/material.dart';

import '../../project_context.dart';
import '../../util.dart';
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
  _ProjectTerrainsState createState() => _ProjectTerrainsState();
}

/// State for [ProjectTerrains].
class _ProjectTerrainsState extends State<ProjectTerrains> {
  /// Build a widget.
  @override
  Widget build(BuildContext context) {
    final world = widget.projectContext.world;
    return ListView.builder(
      itemBuilder: (context, index) {
        final terrain = world.terrains[index];
        return ListTile(
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
        );
      },
      itemCount: world.terrains.length,
    );
  }
}
