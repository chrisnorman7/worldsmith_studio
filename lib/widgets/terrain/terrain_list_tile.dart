import 'package:flutter/material.dart';
import 'package:worldsmith/worldsmith.dart';

import '../../intents.dart';
import '../../project_context.dart';
import '../../screens/terrain/edit_terrain.dart';
import '../../screens/terrain/select_terrain.dart';
import '../../util.dart';

/// A widget for selecting a new terrain.
class TerrainListTile extends StatefulWidget {
  /// Create an instance.
  const TerrainListTile({
    required this.projectContext,
    required this.onDone,
    required this.terrains,
    this.currentTerrainId,
    this.title = 'Terrain',
    Key? key,
  }) : super(key: key);

  /// The project context to use.
  final ProjectContext projectContext;

  /// The function to be called with the new value.
  final ValueChanged<Terrain> onDone;

  /// The list of terrains to choose from.
  final List<Terrain> terrains;

  /// The ID of the current terrain, if any.
  final String? currentTerrainId;

  /// The title of the resulting [ListTile].
  final String title;

  @override
  State<TerrainListTile> createState() => _TerrainListTileState();
}

class _TerrainListTileState extends State<TerrainListTile> {
  @override
  Widget build(BuildContext context) {
    final currentTerrain = widget.terrains.firstWhere(
      (element) => element.id == widget.currentTerrainId,
    );
    return CallbackShortcuts(
      bindings: {
        EditIntent.hotkey: () async {
          await pushWidget(
            context: context,
            builder: (context) => EditTerrain(
              projectContext: widget.projectContext,
              terrain: currentTerrain,
            ),
          );
          setState(() {});
        }
      },
      child: ListTile(
        title: Text(widget.title),
        subtitle: Text(currentTerrain.name),
        onTap: () => pushWidget(
          context: context,
          builder: (context) => SelectTerrain(
            onDone: widget.onDone,
            terrains: widget.terrains,
            currentTerrainId: widget.currentTerrainId,
          ),
        ),
      ),
    );
  }
}
