import 'package:flutter/material.dart';
import 'package:worldsmith/worldsmith.dart';

/// A widget for selecting a terrain.
class SelectTerrain extends StatelessWidget {
  /// Create an instance.
  const SelectTerrain({
    required this.onDone,
    required this.terrains,
    this.currentTerrainId,
    this.title = 'Select Terrain',
    Key? key,
  }) : super(key: key);

  /// The function to call with the new value.
  final ValueChanged<Terrain> onDone;

  /// The terrains to choose from.
  final List<Terrain> terrains;

  /// The ID of the current terrain.
  final String? currentTerrainId;

  /// The title of the resulting scaffold.
  final String title;

  /// Build the widget.
  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: Text(title),
        ),
        body: ListView.builder(
          itemBuilder: (context, index) {
            final terrain = terrains[index];
            final selected = terrain.id == currentTerrainId;
            return ListTile(
              autofocus: selected,
              title: Text(terrain.name),
              onTap: () => onDone(terrain),
              selected: selected,
            );
          },
          itemCount: terrains.length,
        ),
      );
}
