// ignore_for_file: prefer_final_parameters
import 'package:flutter/material.dart';
import 'package:worldsmith/worldsmith.dart';

import '../../intents.dart';
import '../../project_context.dart';
import '../../screens/terrain/edit_terrain.dart';
import '../../screens/terrain/select_terrain.dart';
import '../../util.dart';
import '../push_widget_list_tile.dart';

/// A widget for selecting a new terrain.
class TerrainListTile extends StatefulWidget {
  /// Create an instance.
  const TerrainListTile({
    required this.projectContext,
    required this.onDone,
    required this.terrains,
    this.currentTerrainId,
    this.title = 'Terrain',
    super.key,
  });

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
  Widget build(final BuildContext context) {
    final currentTerrain = widget.terrains.firstWhere(
      (final element) => element.id == widget.currentTerrainId,
    );
    return CallbackShortcuts(
      bindings: {
        EditIntent.hotkey: () async {
          await pushWidget(
            context: context,
            builder: (final context) => EditTerrain(
              projectContext: widget.projectContext,
              terrain: currentTerrain,
            ),
          );
          setState(() {});
        }
      },
      child: PushWidgetListTile(
        title: widget.title,
        subtitle: currentTerrain.name,
        builder: (final context) => SelectTerrain(
          onDone: widget.onDone,
          terrains: widget.terrains,
          currentTerrainId: widget.currentTerrainId,
        ),
      ),
    );
  }
}
