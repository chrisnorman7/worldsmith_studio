import 'package:flutter/material.dart';
import 'package:worldsmith/worldsmith.dart';

import '../../util.dart';
import 'select_terrain.dart';

/// A widget for selecting a new terrain.
class TerrainListTile extends StatelessWidget {
  /// Create an instance.
  const TerrainListTile({
    required this.onDone,
    required this.terrains,
    this.currentTerrainId,
    this.title = 'Terrain',
    Key? key,
  }) : super(key: key);

  /// The function to be called with the new value.
  final ValueChanged<Terrain> onDone;

  /// The list of terrains to choose from.
  final List<Terrain> terrains;

  /// The ID of the current terrain, if any.
  final String? currentTerrainId;

  /// The title of the resulting [ListTile].
  final String title;

  @override
  Widget build(BuildContext context) {
    final currentTerrain = terrains.firstWhere(
      (element) => element.id == currentTerrainId,
    );
    return ListTile(
      title: Text(title),
      subtitle: Text(currentTerrain.name),
      onTap: () => pushWidget(
        context: context,
        builder: (context) => SelectTerrain(
          onDone: onDone,
          terrains: terrains,
          currentTerrainId: currentTerrainId,
        ),
      ),
    );
  }
}
